/*----------------------------------------------------------------------------*\
 
  FILE....: chan_mp.c
  AUTHOR..: David Rowe
  CREATED.: May 20 2009
 
  Asterisk channel driver for the Mesh Potato.

  Channel Driver Tests:
  
    1/ Set up a SIP phone (sipguest) and a dialplan like:

       [default]
       exten => 4000,1,Dial(MP/1)
       exten => 4001,1,Answer
       exten => 4001,2,Echo
       exten => 4002,1,Dial(SIP/sipguest)

    2/ Tests

       [ ] Pick up analog phone, dial 4000, wait for busy, hangup
           + 4001 is ourself, which is busy
       [ ] Pick up analog phone, dial 4005, hangup
           + a number outside the dial plan
       [ ] Pick up analog phone, dial 4000, don't hangup
           + While still off hook making busy, dial 4000 with SIP phone
       [ ] Dial 4000 from SIP phone, but hangup SIP before picking up analog
           + test hangup while ringing
       [ ] Dial 4002 from analog phone, but hangup analog before picking up SIP
           + if SIP phone not registered power cycle it
       [ ] Dial 4001 from SIP phone
           + test dialing echo application

  TODO:

    [ ] Handle collecting DTMFs while in a call
    [ ] Hook flash detection and transmission
    [ ] transfers - does Asterisk handle this?
 
  Asterisk Channel Driver Reference:

  1/ http://www.voip-info.org/wiki/view/Asterisk+Internal+Architecture+Overview
  2/ Other channel drivers in "channel" directory of asterisk tar ball.

  GOTCHAS:

  1/ The biggest problem encountered while writing this driver was the effect of
  multiple threads messing with the same state variables at the same time.  For
  example it is possible for a thread to call mp_hangup and free the mp_pvt and
  ast_channel structures while your state machine is using them in another thread.  

  2/ Some messages sent to the Asterisk logging facilities can cause a
  write to serial flash which is very slow and may interfere with
  real-time operation.  Check out /var/log/asterisk to see if any messages
  are being logged.

\*----------------------------------------------------------------------------*/

/*
  Copyright (C) 2009 Shuttleworth Foundation

  This program is free software; you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation; either version 2 of the License, or
  (at your option) any later version.

  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with this program; if not, write to the Free Software
  Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
*/

#include <stdio.h>
#include <string.h>
#include "asterisk/lock.h"
#include "asterisk/channel.h"
#include "asterisk/config.h"
#include "asterisk/logger.h"
#include "asterisk/module.h"
#include "asterisk/pbx.h"
#include "asterisk/options.h"
#include "asterisk/lock.h"
#include "asterisk/sched.h"
#include "asterisk/io.h"
#include "asterisk/acl.h"
#include "asterisk/callerid.h"
#include "asterisk/file.h"
#include "asterisk/cli.h"
#include "asterisk/rtp.h"
#include "asterisk/causes.h"
#include "asterisk/devicestate.h"
#include <asterisk/dsp.h>
#include <asterisk/ulaw.h>

#include <echo.h>

#include <errno.h>
#include <unistd.h>
#include <stdlib.h>
#include <netdb.h>
#include <arpa/inet.h>

#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <sys/ioctl.h>
#include <termios.h> /* POSIX terminal control definitions */

#include "../driver/mp.h"
#include "busy.h"
#include "ringtone.h"
#include "dialtone.h"

/*---------------------------------------------------------------------*\

                                 DEFINES

\*---------------------------------------------------------------------*/

#define MAX_STR     128
#define MP_MAX_CHAN 1
#define MP_BUF_SZ   160  /* bytes (and ulaw samples) in mp driver 
			    ping-pong transfers                     */
#define BUF_SZ      1600 /* bytes (and ulaw samples) in FIFO buffer */
#define TAPS        64   /* echo canceller taps - 64 or 8 ms is 
			    plenty for a FXS port                   */

/* play() state variables, tone or silence */

#define SOUND_TONE  0
#define SOUND_SIL   1

/* time we wait for digit before starting dialling */

#define DIGIT_TIMEOUT 24000

/* FXS ringer state machine */

#define RING_ON  0
#define RING_OFF 1
#define RING_CADENCE 16000

/*---------------------------------------------------------------------*\

                                 HEADERS

\*---------------------------------------------------------------------*/

static struct ast_channel *mp_request(const char *type, int format, void *data, int *cause);
static int mp_call(struct ast_channel *ast, char *dest, int timeout);
static int mp_hangup(struct ast_channel *ast);
static int mp_answer(struct ast_channel *ast);
static struct ast_frame *mp_read(struct ast_channel *ast);
static int mp_write(struct ast_channel *ast, struct ast_frame *frame);
static int mp_indicate(struct ast_channel *ast, int ind, const void *data, size_t datalen);
static int mp_fixup(struct ast_channel *oldchan, struct ast_channel *newchan);
static void fifo_write(char *data, int datalen);

/*---------------------------------------------------------------------*\

                                 STATICS

\*---------------------------------------------------------------------*/

static const char desc[] = "Mesh Potato FXS Channel";
static const char type[] = "MP";
static const char tdesc[] = "Mesh Potato FXS Channel Driver";

/* usecount */

AST_MUTEX_DEFINE_STATIC(usecountlock);
static int usecount = 0;

/* Monitor thread */

static pthread_t monitor_thread = AST_PTHREADT_NULL;

/* Protect the interface list (of mp_pvt's) */

AST_MUTEX_DEFINE_STATIC(mplock); 

/* file descriptors for our device drivers */

static int fd_serial;
static int fd_8250mp;
static int fd_mp;

/* TX (mp_write) FIFO buffer states */

AST_MUTEX_DEFINE_STATIC(fifolock); 
static char  buf[BUF_SZ];
static int   nbuf;
static char *pin;
static char *pout;    
static int   notxdata;

/* handle to Asterisk dsp routines */

static struct ast_dsp *dsp;

/*
  Read (RX) buffer used in mp_read - AST_FRIENDLY_OFFSET space
  for headers plus enough room for a full frame.
*/

static unsigned char rxbuf[AST_FRIENDLY_OFFSET + MP_BUF_SZ];

/*
  Write buffer - used to delay tx signal to time align tx and
  rx for echo cancellation.  From when we write a sample to
  the 8250mp driver to when it's echo returns is a minimum of
  320 samples (two buffers) due to ping pong buffer delays.
*/

unsigned char txbuf[3*MP_BUF_SZ];

/* Echo canceller states */

static echo_can_state_t *ec;

/* Technical details of MP channel driver */

static const struct ast_channel_tech mp_tech = {
    .type         = type,
    .description  = tdesc,
    .capabilities = AST_FORMAT_ULAW,
    .requester    = mp_request,
    .call         = mp_call,
    .hangup       = mp_hangup,
    .answer       = mp_answer,
    .read         = mp_read,
    .write        = mp_write,
    .exception    = NULL,
    .indicate     = mp_indicate,
    .fixup        = mp_fixup,
};

/* set of state variables created for each call */

static struct mp_pvt {
    ast_mutex_t lock;			        /* Channel private lock */
    struct ast_channel   *owner;		/* owner of this pvt    */
    
    char                  cid_num[MAX_STR];
    char                  cid_name[MAX_STR];

} *mp = NULL;

/* prepare asterisk generaic asterisk frame for read (Rx) side */

static struct ast_frame  read_frame = {
    .src       = type,
    .frametype = AST_FRAME_VOICE,
    .subclass  = AST_FORMAT_ULAW,
    .samples   = MP_BUF_SZ,
    .datalen   = MP_BUF_SZ,
    .data      = rxbuf + AST_FRIENDLY_OFFSET,
    .offset    = AST_FRIENDLY_OFFSET,
};

/* From chan_oss.c:
 *
 * Each sound is made of 'datalen' samples of sound, repeated as needed to
 * generate 'samplen' samples of data, then followed by 'silencelen' samples
 * of silence. The loop is repeated if 'repeat' is set.
 */
struct sound {
        int ind;
        char *desc;
        short *data;
        int datalen;
        int samplen;
        int silencelen;
        int repeat;
};

static struct sound s_dialtone = 
    { AST_CONTROL_OFFHOOK, "DIALTONE", dialtone, sizeof(dialtone)/2, 16000, 0, 1 };
static struct sound s_ringtone = 
    { AST_CONTROL_RINGING, "RINGING", ringtone, sizeof(ringtone)/2, 16000, 32000, 1 };
static struct sound s_busy = 
    { AST_CONTROL_BUSY, "BUSY", busy, sizeof(busy)/2, 4000, 4000, 1 };
static struct sound s_silence = 
    { AST_CONTROL_OFFHOOK, "SILENCE", NULL, 0, 0, 4000, 1 };

static struct sound *sound_current = &s_silence;
static struct sound *sound_previous = NULL;
static short *psound_data;
static int sound_samples;
static int sound_state = SOUND_TONE;
static int sound_on = 0;

/* ringer states */

static int ringer_on = 0;
static int ring_timer = 0;
static int ring_state = RING_OFF;

/* state machine variables */

static char  ext[MAX_STR];
static char *pext;
static int   digit_timer, digit_timer_on;
static int   down_but_busy;

/* dialplan context hard coded for now */

static char *context = "meshpotato";

static struct ast_channel *mp_new(int state, char *ext, char *ctx);

/*---------------------------------------------------------------------*\

                                 FUNCTIONS

\*---------------------------------------------------------------------*/

#ifdef NOT_NEEDED
static int mp_devicestate(void *data)
{
	int res = AST_DEVICE_INVALID;
	if (option_verbose > 2)
	    ast_verbose( VERBOSE_PREFIX_3 "start mp_devicestate\n");
	return res;
}
#endif

static int mp_fixup(struct ast_channel *oldchan, struct ast_channel *newchan)
{
        struct mp_pvt *p = newchan->tech_pvt;
	if (option_verbose > 2)
	    ast_verbose( VERBOSE_PREFIX_3 "start mp_fixup\n");
        p->owner = newchan;
        return 0;
}

static char *control2str(int ind) {
        switch (ind) {
        case AST_CONTROL_HANGUP:
                return "Other end has hungup";
        case AST_CONTROL_RING:
                return "Local ring";
        case AST_CONTROL_RINGING:
                return "Remote end is ringing";
        case AST_CONTROL_ANSWER:
                return "Remote end has answered";
        case AST_CONTROL_BUSY:
                return "Remote end is busy";
        case AST_CONTROL_TAKEOFFHOOK:
                return "Make it go off hook";
        case AST_CONTROL_OFFHOOK:
                return "Line is off hook";
        case AST_CONTROL_CONGESTION:
                return "Congestion (circuits busy)";
        case AST_CONTROL_FLASH:
                return "Flash hook";
        case AST_CONTROL_WINK:
                return "Wink";
        case AST_CONTROL_OPTION:
                return "Set a low-level option";
        case AST_CONTROL_RADIO_KEY:
                return "Key Radio";
        case AST_CONTROL_RADIO_UNKEY:
                return "Un-Key Radio";
        case AST_CONTROL_PROGRESS:
                return "Remote end is making Progress";
        case AST_CONTROL_PROCEEDING:
                return "Remote end is proceeding";
        case AST_CONTROL_HOLD:
                return "Hold";
        case AST_CONTROL_UNHOLD:
                return "Unhold";
        case -1:
                return "Stop tone";
        default:
	    return "Unknown";
        }
}

static int mp_indicate(struct ast_channel *ast, int ind, const void *data, size_t datalen)
{
    char exten[AST_MAX_EXTENSION] = "";

    ast_copy_string(exten, S_OR(ast->macroexten, ast->exten), sizeof(exten));
    if (option_verbose > 2)
	ast_verbose(VERBOSE_PREFIX_3 "Asked to indicate '%s' condition on channel %s\n", 
		    control2str(ind), ast->name);

    if (ind == AST_CONTROL_RINGING) {
	/* other end has actually started ringing */
	sound_current = &s_ringtone;
	sound_on = 1;
    }

    if ((ind == AST_CONTROL_BUSY) || (ind == AST_CONTROL_CONGESTION)) {
	/* call we tried to dial didn't go through */

	sound_current = &s_busy;
	sound_on = 1;
	down_but_busy = 1;
	ast_setstate(ast, AST_STATE_BUSY); /* helps us call the correct ast_hangup() */
    }

    if (ind == -1) {
	/* Stop Tone - other end has picked up */
	sound_on = 0;
    }

    return 0;
}

#ifdef FOR_LATER_USE
static int mp_senddigit(struct ast_channel *ast, char digit)
{
	ast_verbose("sending digit %c\n NOT IMPLEMENTED YET", digit);
	return 0;
}

static int mp_queuedigit(struct ast_channel *ast, char digit)
{
	struct ast_frame f = { AST_FRAME_DTMF, digit };
	ast_verbose("digit is %c\n", digit);
	return ast_queue_frame(ast, &f);
}
#endif

/********************************************************************************
 * mp_call - Asterisk calls this function when we have an incoming call
 ********************************************************************************/

static int mp_call(struct ast_channel *ast, char *dest, int timeout)
{
    struct ast_frame f = { 0, };
    int    ring;

    if (option_verbose > 2)
	ast_verbose( VERBOSE_PREFIX_3 "start mp_call\n");

    f.frametype = AST_FRAME_CONTROL;
    f.subclass = AST_CONTROL_RINGING;
    ast_queue_frame(ast, &f);
    ast_setstate(ast, AST_STATE_RINGING);
    
    /* start analog phone ringing */

    ring_timer = 0;
    ring_state = RING_ON;
    ring = 4; /* "ringing" state of reg 64 Si3215 */
    ioctl(fd_mp, MP_RING, &ring);
    ringer_on = 1;

    return 0;
}

/********************************************************************************
 * mp_answer - other end has answered our call
 ********************************************************************************/

static int mp_answer(struct ast_channel *ast)
{
    if (option_verbose > 2)
	ast_verbose( VERBOSE_PREFIX_3 "start mp_answer\n");

    /* other end has answered so stop ring back */

    sound_on = 0;

    return 0;
}

/*  
    read_write_buf: Waits for available buffer of samples from the
    8050mp driver then reads and writes a RX and TX buffer.  Sends the
    RX buffer off to the network end if the channel is up.  TX
    buffers are fed to this function in through the TX FIFO.
*/

static void read_write_buf(void)
{
    unsigned char    *prxbuf, *ptxbuf;
    unsigned short    txslin, rxslin;
    int               len, i;
    struct ast_channel *ch = NULL;    

    len = read(fd_8250mp, read_frame.data, MP_BUF_SZ);
    if(len == -1) {
	ast_log(LOG_ERROR, "read() error in read_write_buf()!\n");
	memset(read_frame.data, 0, MP_BUF_SZ);
    }

    ast_mutex_lock(&fifolock);

    /* 
       Grab block of samples to write from TX FIFO, they get stored
       at the end of txbuf to facilitate echo cancellation.
    */

    if (nbuf > MP_BUF_SZ) {

	notxdata = 0;

	/* write newest samples to end of txbuf */

	ptxbuf = &txbuf[2*MP_BUF_SZ];  

	for(i=0; i<MP_BUF_SZ; i++) {
	    *ptxbuf++ = *pout++;
	    if (pout == (buf + BUF_SZ))
		pout = buf;
	}
	nbuf -= MP_BUF_SZ;
    }
    else {

	/* 
	   No data is available in the TX FIFO.  This could be due to:

	   i) An isolated frame slip due to differences in clocks
	   between the FXS interface and the clock of the network end.

	   ii) The network end may not be sending any data.

	   To handle (i) the previous txbuf will simply be
	   repeated. If more than 1 consecutive frames are missing we
	   assume there is no data from the network end and start
	   sending silence.

	   Note that if the network end is writing faster than we are
	   reading write buffers will be dropped inside mp_write()
	*/

	if (notxdata < 2) {
	    notxdata++;
	}
	
	if (notxdata == 2) {
	    for(i=0; i<MP_BUF_SZ; i++) {
		txbuf[2*MP_BUF_SZ + i] = AST_LIN2MU(0);
	    }
	}

	if (option_verbose > 8)
	    ast_verbose("FIFO underflow in read_write_buf nbuf: %d !\n", nbuf);
    }

    ast_mutex_unlock(&fifolock);

    /* straight after read we write TX samples to 8250mp driver */

    len = write(fd_8250mp, &txbuf[2*MP_BUF_SZ], MP_BUF_SZ);
    if(len == -1) {
 	ast_log(LOG_ERROR, "write() error in read_write_buf!\n");
    }
   
    /* Echo cancel each received sample.  Note we perform echo
       cancellation in user mode which is novel but OK as long as the
       TX and RX time alignment is constant and known. */

    prxbuf = read_frame.data;
    for(i=0; i<MP_BUF_SZ; i++) {
	txslin = AST_MULAW(txbuf[i]);
	rxslin = AST_MULAW(prxbuf[i]);
	rxslin = echo_can_update(ec, txslin, rxslin);
	prxbuf[i] = AST_LIN2MU(rxslin);
    }

    /* shift tx buffer along, oldest samples at start, newest at end */
    
    for(i=0; i<2*MP_BUF_SZ; i++)
	txbuf[i] = txbuf[i+MP_BUF_SZ];

    /* send echo cancelled read frame to network if channel is up  */

    /* 
       Note: This code was a problem area when writing chan_mp.  I am
       still not 100% convinced the code below is OK.  One potential
       failure case to consider:
         + ch get set inside the mutex
	 + mp_hangup is called before from another thread before we call 
           ast_queue_frame().
	 + ast_queue_frame() is called on a ch that points to recently free-ed
	   memory (possible re-used somwhere else)
       
       When ast_queue_frame() was placed inside the mutex the driver would lock up
       around the time ast_queue_hangup() was called from event_onhook().  This mutex
       seemed to block the mplock mutex in mp_hangup.
    */

    ast_mutex_lock(&mplock);
    if (mp)
	ch = mp->owner;
    ast_mutex_unlock(&mplock);
    if (ch && ch->_state == AST_STATE_UP)
	ast_queue_frame(ch, &read_frame);
}

/* sends one buf of sound_current to the write fifo */

static void play_sound(void)
{
    int            i;
    char           buf[MP_BUF_SZ];
    struct sound  *s;

    /* check if we have changed sound */
    
    s = sound_current;
    if (s != sound_previous) {
	/* init states for new tone */
	sound_previous = s;
	sound_state = SOUND_TONE;
	psound_data = s->data;
	sound_samples = 0;
    }
    
    /* generate the sound, all these if-thens allow for
       variable on-off cadence */

    for(i=0; i<MP_BUF_SZ; i++) {
	if ((sound_state == SOUND_TONE) && (s->samplen > 0)) {
	    buf[i] = AST_LIN2MU((unsigned short)(*psound_data++ >> 2));
	    if (psound_data == s->data + s->datalen)
		psound_data = s->data;
	    sound_samples++;
	    if (sound_samples >= s->samplen) {
		if (s->silencelen > 0)
		    sound_state = SOUND_SIL;
		sound_samples = 0;
	    }	    
	}
	else {
	    buf[i] = AST_LIN2MU(0);
	    sound_samples++;
	    if (sound_samples >= s->silencelen) {
		if (s->samplen > 0)
		    sound_state = SOUND_TONE;
		sound_samples = 0;
	    }
	}
    }

    /* send sound to the write (TX) stream using the write FIFO */

    fifo_write(buf, MP_BUF_SZ);
}

/************************************************************************************\
 *  event_offhook: offhook event handler for state machine
 ************************************************************************************/

static void event_offhook(void)
{
    int                 state;
    struct ast_frame    f = { 0, };
    struct ast_channel *ch = NULL;

    ast_verbose( VERBOSE_PREFIX_3 "event_offhook\n");

    /* we use mplock to prevent any simultaneous events (say a hangup
       from the network end) bringing down the channel while we are
       using it */
    ast_mutex_lock(&mplock);

    if (mp) {
	ch = mp->owner;
	state = ch->_state;
        ast_verbose( VERBOSE_PREFIX_3 "  mp exists\n");
    }
    else
	state = AST_STATE_DOWN;

    switch(state) {
    case AST_STATE_DOWN:
	ast_verbose( VERBOSE_PREFIX_3 "  AST_STATE_DOWN: \n");
	memset(ext, 0, MAX_STR); /* guarantee null terminator */
	pext = ext;
	ch = mp_new(AST_STATE_OFFHOOK, ext, context);
	sound_current = &s_dialtone;
	sound_on = 1;
	break;
    case AST_STATE_RINGING:
	ast_verbose( VERBOSE_PREFIX_3 "  AST_STATE_RINGING: answer\n");
	ringer_on = 0;
	sound_on = 0;
	f.frametype = AST_FRAME_CONTROL;
	f.subclass = AST_CONTROL_ANSWER;
	ast_queue_frame(ch, &f);
	break;
    }

    /* 
       Hybrid and hence echo path only starts working when we go off
       hook so good idea to reset echo can states now.  Perhaps an
       even better approach would be to freeze echo canceller states
       when on hook, then unfreeze them when we go off hook.  This
       would mean the e/c might stay converged between calls.
    */

    echo_can_flush(ec);

    ast_mutex_unlock(&mplock);
}

/************************************************************************************\
 *  event_onhook: onhook event handler for state machine
 ************************************************************************************/

static void event_onhook(void)
{
    int                 state;
    struct ast_channel *ch = NULL;

    ast_verbose( VERBOSE_PREFIX_3 "event_onhook\n");

    /* we use mplock to prevent any simultaneous events (say a
       mp_request or mp_hangup from the network end) bringing up the
       channel while we are using it */
    ast_mutex_lock(&mplock);

    if (mp) {
	ch = mp->owner;
	state = ch->_state;
    }
    else
	state = AST_STATE_DOWN;

    switch(state) {
    case AST_STATE_DOWN:
	ast_verbose( VERBOSE_PREFIX_3 "  AST_STATE_DOWN: \n");
	sound_on = 0;
	break;
    case AST_STATE_OFFHOOK:
    case AST_STATE_DIALING:
	ast_verbose( VERBOSE_PREFIX_3 " AST_STATE_OFFHOOK, AST_STATE_DIALING : hangup\n");
	ast_hangup(ch);
	digit_timer_on = 0;
	break;
    default:
	ast_verbose( VERBOSE_PREFIX_3 "  default: hangup  sound_on = %d\n", sound_on);
	ast_queue_hangup(ch);
	ringer_on = 0;
	break;
    }

    down_but_busy = 0;

    ast_mutex_unlock(&mplock);
}

/************************************************************************************\
 *  event_dtmf: dtmf event handler for state machine
 ************************************************************************************/

static void event_dtmf(char dtmf)
{
    int                 state;
    struct ast_channel *ch = NULL;
    struct ast_frame    f = { AST_FRAME_DTMF, 0 };

    ast_verbose( VERBOSE_PREFIX_3 "event_dtmf %c\n", dtmf);

    /* we use mplock to prevent any simultaneous events (say a
       mp_request or mp_hangup from the network end) bringing up the
       channel while we are using it */
    ast_mutex_lock(&mplock);

    if (mp) {
	ch = mp->owner;
	state = ch->_state;
    }
    else {
	ast_log(LOG_WARNING, "event_dtmf called with no channel!\n");
	ast_mutex_unlock(&mplock);
	return;
    }

    switch(state) {
    case AST_STATE_OFFHOOK:
	*pext++ = dtmf;
	digit_timer = 0;
	digit_timer_on = 1;
	ast_setstate(ch, AST_STATE_DIALING); 
	sound_current = &s_silence; 
	break;
    case AST_STATE_DIALING:
	digit_timer += MP_BUF_SZ;
	if ((pext-ext) < MAX_STR-1)
	    *pext++ = dtmf;
	digit_timer = 0;
	break;
    default:
	f.subclass = dtmf;
	ast_queue_frame(ch, &f);
	break;
    }

    ast_mutex_unlock(&mplock);
}

/************************************************************************************\
 *  event_digit_timer: digit_timer event handler for state machine
 ************************************************************************************/

static void event_digit_timer(void)
{
    int                 state;
    struct ast_channel *ch = NULL;

    ast_verbose( VERBOSE_PREFIX_3 "event_digit_timer\n");

    ast_mutex_lock(&mplock);

    if (mp) {
	ch = mp->owner;
	state = ch->_state;
    }
    else {
	ast_log(LOG_WARNING, "  event_digit_timer called with no channel!\n");
	ast_mutex_unlock(&mplock);
	return;
    }

    switch(state) {
    case AST_STATE_DIALING:
	if (ast_exists_extension(NULL, context, ext, 1, NULL)) {
	    ast_verbose( VERBOSE_PREFIX_3 "  extension exists, starting PBX %s\n", ext);
	    strcpy(ch->exten, ext);
	    ast_setstate(ch, AST_STATE_RING);
	    if (ast_pbx_start(ch)) {
		ast_log(LOG_WARNING, "  Unable to start PBX on %s\n", ch->name);
		ast_hangup(ch);
	    }
	}
	else {
	    sound_current = &s_busy;
	    sound_on = 1;
	    ast_setstate(ch, AST_STATE_OFFHOOK); /* force ast_hangup() on onhook event
						    as channel thread not started */
	}
	break;
    default:
	ast_log(LOG_WARNING, "  event_digit_timer called is state other than "
		"AST_STATE_DIALING!\n");
	break;
    }

    ast_mutex_unlock(&mplock);
}

/*
  The do_monitor thread handles read and write sample I/O and detects
  DTMF and hook events.  When detected, events are passed to state
  machine event handlers to iterate the state machine.
*/

static void *do_monitor(void *data)
{
    int                     offhook, prev_offhook, ring; 
    struct ast_frame       *dtmf;

    prev_offhook = 0;
    digit_timer_on = digit_timer = 0;
    ringer_on = ring_timer = 0;

    for(;;) {
	pthread_testcancel();

	/* do a read and write (RX and TX) buffer transfer to kernel mode,
	   this blocks for around 20ms */

	read_write_buf();

	/* look for any DTMF digit events in the lastest read_frame */

	dtmf = ast_dsp_process(NULL, dsp, &read_frame);
	if (dtmf->frametype == AST_FRAME_DTMF) 
	    event_dtmf((char)dtmf->subclass);
		
	/* look for any hook switch events */

	ioctl(fd_mp, MP_HOOK, &offhook);
	if ((prev_offhook == 0) && (offhook == 1))
	    event_offhook();
	if ((prev_offhook == 1) && (offhook == 0))
	    event_onhook();
	prev_offhook = offhook;

	/* look for any digit timer events */

	if (digit_timer_on) {
	    digit_timer += MP_BUF_SZ;
	    if (digit_timer >= DIGIT_TIMEOUT) {
		digit_timer = 0;
		digit_timer_on = 0;
		event_digit_timer();
	    }
	}

	/* iterate ringer process */

	if (ringer_on) {
	    ring_timer += MP_BUF_SZ;
	    if (ring_timer >= RING_CADENCE) {
		ring_timer = 0;
		if (ring_state == RING_ON) {
		    ring = 1; /* "forward active" state of reg 64 Si3215 */
		    ioctl(fd_mp, MP_RING, &ring);
		    ring_state = RING_OFF;
		}
		else {
		    ring = 4; /* "ringing" state of reg 64 Si3215 */
		    ioctl(fd_mp, MP_RING, &ring);
		    ring_state = RING_ON;		    
		}
	    }
	}
	else {
	    ring = 1; /* "forward active" state of reg 64 Si3215 */
	    ioctl(fd_mp, MP_RING, &ring);
	}
    
	/* iterate sound process */

	if (sound_on)
	    play_sound();
	
    }

    return NULL; /* never gets here */
}

/********************************************************************************
 * mp_read - not used in this driver
 ********************************************************************************/

static struct ast_frame *mp_read(struct ast_channel *ast)
{
    ast_log(LOG_WARNING, "mp_read called - this shouldn't happen\n");

    return &ast_null_frame;
}


/********************************************************************************
 * fifo_write - Write a block of samples to the TX FIFO
 ********************************************************************************/

static void fifo_write(char *data, int datalen)
{
    int            i;
    int            fifo_free;
    char          *pdata;

    ast_mutex_lock(&fifolock);

    fifo_free = BUF_SZ - nbuf;

    if (datalen > fifo_free) {

	/* this is usually no big deal, and oftens happens at the start and/or
	   end of a call */

	if (option_verbose > 8)
	    ast_verbose("FIFO overflow in fifo_write nbuf: %d fifo_free "
			"%d datalen: %d!\n",nbuf, fifo_free, datalen);
    }
    else {

	/* This could be made more efficient with block copies
	   using memcpy */

	pdata = data;
	for(i=0; i<datalen; i++) {
	    *pin++ = *pdata++;
	    if (pin == (buf + BUF_SZ))
		pin = buf;
	}
	nbuf += datalen;
    }
    ast_mutex_unlock(&fifolock);
}

/********************************************************************************
 * mp_write - buffers coming in from network, sent to FXS port
 ********************************************************************************/

static int mp_write(struct ast_channel *ast, struct ast_frame *frame)
{
    struct mp_pvt *p = ast->tech_pvt;

    if (frame->frametype != AST_FRAME_VOICE)
	return 0;

    /* 
       The 8250mp driver requires writes to occur just after
       reads, so we simply write the data to a FIFO buffer and let
       the read_write_buf() function handle the actual transfer to
       kernel mode.  The FIFO also allows for the case where the
       incoming write frames from the network are different in
       length to the MP write frames.
    */

    if (p) {
	fifo_write((char*)frame->data, frame->datalen);
    }

    return 0;
}

/********************************************************************************
 * mp_new - helper function thats return a new ast_channel when we kick off a
 *          new incoming or outgoing call
 ********************************************************************************/

static struct ast_channel *mp_new(int state, char *ext, char *ctx)
{
    struct ast_channel *tmp = NULL;

    if (option_verbose > 2)
	ast_verbose( VERBOSE_PREFIX_3 "start mp_new\n");

    ast_mutex_lock(&usecountlock);
    usecount++;
    if (usecount > 1)
	ast_log(LOG_WARNING, "usecount > 1, usecount: %d\n", usecount);
    ast_mutex_unlock(&usecountlock);
    
    mp = malloc(sizeof(struct mp_pvt));
    if (mp) {
	memset(mp, 0, sizeof(struct mp_pvt));
    }
    else {
	ast_log(LOG_WARNING, "Unable to allocate mp_pvt structure\n");
	return NULL;
    }

    /* create and ast_channel and fill in a few fields */

    tmp = ast_channel_alloc(1, state, NULL, NULL, "", ext, ctx, 0, "MP/%s", "1");

    if (!tmp) {
	ast_log(LOG_WARNING, "Unable to allocate channel structure\n");
	return NULL;
    }
    
    tmp->tech = &mp_tech;
    tmp->nativeformats = AST_FORMAT_ULAW;
    tmp->readformat  = AST_FORMAT_ULAW;
    tmp->writeformat = AST_FORMAT_ULAW;
    tmp->tech_pvt = mp;
    mp->owner = tmp;
    ast_module_ref(ast_module_info->self);

    return tmp;
}

/********************************************************************************
 * mp_request - Called by * to request we set up internal data structures
 *              for a new call
 ********************************************************************************/

static struct ast_channel *mp_request(const char *type, int format, void *data, 
				      int *cause)
{
    struct ast_channel *chan = NULL;

    if (option_verbose > 2)
	ast_verbose( VERBOSE_PREFIX_3 "start mp_request\n");
    
    ast_mutex_lock(&mplock);

    if (mp || down_but_busy) {
	ast_log(LOG_NOTICE, "Already have a call on the MP channel\n");
	*cause = AST_CAUSE_BUSY;
	ast_mutex_unlock(&mplock);
	return NULL;
    }

    chan = mp_new(AST_STATE_DOWN, NULL, NULL);

    ast_mutex_unlock(&mplock);

    return chan;
}

/********************************************************************************
 * mp_hangup - called by * when a call finishes so we can clean up.
 ********************************************************************************/

static int mp_hangup(struct ast_channel *ast)
{
    int            offhook;

    struct mp_pvt *p;

    if (option_verbose > 2)
	ast_verbose( VERBOSE_PREFIX_3 "start mp_hangup\n");

    /* lock to prevent simultaneous access with do_monitor thread processing */

    ast_mutex_lock(&mplock);

    if (ast->_state == AST_STATE_RINGING) {
	ringer_on = 0;
    }

    /* If we are off hook we need to tell state_machine() to play a busy
       tone to the phone */
    ioctl(fd_mp, MP_HOOK, &offhook);
    if (offhook) {
	sound_current = &s_busy;
	sound_on = 1;
	down_but_busy = 1;
    }

    p = ast->tech_pvt;
    ast->tech_pvt = NULL;
    free(p);
    mp = NULL; /* 
		  note p and mp are the same thing, mp is a static so we
		  can detect when the MP channel is in use 
	       */

    ast_mutex_lock(&usecountlock);
    usecount--;
    if (usecount)
	ast_log(LOG_WARNING, "usecount != 0, usecount: %d\n", usecount);
    ast_mutex_unlock(&usecountlock);

    ast_module_unref(ast_module_info->self);

    ast_mutex_unlock(&mplock);

    return 0;
}

/********************************************************************************
 * initport - sets up the RS232 UART for 115200 baud using the conventional
 *            serial port control path.
 ********************************************************************************/

static int initport(int fd) {
    struct termios options;

    // Get the current options for the port...

    tcgetattr(fd, &options);

    // Set the baud rates to 115200...

    cfsetispeed(&options, B115200);
    cfsetospeed(&options, B115200);

    // Enable the receiver and set local mode...

    options.c_cflag |= (CLOCAL | CREAD);

    options.c_cflag &= ~PARENB;
    options.c_cflag &= ~CSTOPB;
    options.c_cflag &= ~CSIZE;
    options.c_cflag |=  CS8;
    options.c_cflag &= ~ECHO;
    options.c_cflag &= ~ECHONL;

    // Set the new options for the port...

    cfmakeraw(&options);
    tcsetattr(fd, TCSANOW, &options);

    return 1;
}

/********************************************************************************
 * load_module - Asterisk calls this when chan_ac is loaded
 ********************************************************************************/

static int load_module(void)
{
    ast_verbose( VERBOSE_PREFIX_3 "start load_module\n");

    /* Open regular serial port device - this is used to set speed
       RS232 speed */

    fd_serial = open("/dev/ttyS0", O_RDWR | O_NOCTTY | O_NDELAY);
    if (fd_serial == -1) {
        ast_log(LOG_ERROR, "/dev/ttyS0 open() error\n");
	return AST_MODULE_LOAD_FAILURE;
    } else {
	fcntl(fd_serial, F_SETFL, 0);
    }
    initport(fd_serial);

    /* 
       Open our ping-pong buffer TDM sample interface to our modified
       serial driver - this handles tx/rx speech samples from the FXS
       chip set TDM bus via the RS232 UART.
    */

    fd_8250mp = open("/dev/8250mp", O_RDWR);
    if(fd_8250mp == -1) {
	ast_log(LOG_ERROR, "/dev/8250mp open error\n");
	close(fd_serial);
	return AST_MODULE_LOAD_FAILURE;
    }
	
    /* Open out Mesh Potato driver - this handles signalling such as
       hook detection and ringing */

    fd_mp = open("/dev/mp", O_RDWR);
    if( fd_mp == -1 ) {
	ast_log(LOG_WARNING, "/dev/mp open error\n");
	close(fd_serial);
	close(fd_8250mp);
	return AST_MODULE_LOAD_FAILURE;
    }

    /* Make sure we can register our channel type */

    if (ast_channel_register(&mp_tech)) {
	ast_log(LOG_ERROR, "Unable to register channel class %s\n", type);
	return AST_MODULE_LOAD_FAILURE;
    }

    /* init Asterisk DSP routines */
    
    dsp = ast_dsp_new();
    ast_dsp_set_features(dsp,  DSP_FEATURE_DTMF_DETECT);

    /* init the FIFO used for buffering write samples */

    nbuf = 0;
    pin = pout = buf;
    notxdata = 0;

    /* init the Oslec echo canceller */

    ec = echo_can_create(TAPS,   ECHO_CAN_USE_ADAPTION
                               | ECHO_CAN_USE_NLP
                               | ECHO_CAN_USE_CLIP
                               | ECHO_CAN_USE_TX_HPF
                               | ECHO_CAN_USE_RX_HPF);

    /* start monitor thread */

    if (ast_pthread_create(&monitor_thread, NULL, do_monitor, NULL) < 0) {
	ast_log(LOG_ERROR, "Unable to start monitor thread.\n");   
	return AST_MODULE_LOAD_FAILURE;
    }

    return AST_MODULE_LOAD_SUCCESS;
}

/********************************************************************************
 * unload_module - tidy up before chan_ac is unloaded
 ********************************************************************************/

static int unload_module(void)
{
    struct mp_pvt *p=mp;

    /* Hangup up if we have an active call */

    ast_mutex_lock(&mplock);
    if (p) {
	if (p->owner)
	    ast_softhangup(p->owner, AST_SOFTHANGUP_APPUNLOAD);
    }
    mp = NULL;
    ast_mutex_unlock(&mplock);

    echo_can_free(ec);

    /* shut down monitor thread */

    pthread_cancel(monitor_thread);
    pthread_join(monitor_thread, NULL);

    /* unregister and close file descriptors */

    ast_channel_unregister(&mp_tech);
 
    close(fd_mp);
    close(fd_8250mp);
    close(fd_serial);

    return 0;
}

AST_MODULE_INFO_STANDARD(ASTERISK_GPL_KEY, "Mesh Potato Channel");
