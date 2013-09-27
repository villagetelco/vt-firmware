#!/usr/bin/haserl --shell=/bin/ash
<% 
echo -en "content-type: text/html\r\n\r\n" 
FORM_BUTTON=$( echo "$FORM_BUTTON" | sed "s/ //g" )

if [ $FORM_BUTTON = "Save" ]; then

  # If Master softphone mode is selected, then make sure Asterisk is enabled
  if [ $FORM_ENABLE_AST = "on" ]; then
  ENABLE_AST="checked"
  fi

  # If Master softphone mode is selected, then make sure Asterisk is enabled
  if [ $FORM_SOFTPH = "MASTER" ]; then
    ENABLE_AST="checked"
  fi

  # If Enable SIP mode is selected, then make sure Asterisk is enabled
  if [ $FORM_ENABLE_AST = "checked" ]; then
    ENABLE_AST="checked"
  fi

  # Check if Asterisk is installed and reset UI controls if not
  AST_INSTALLED="`opkg list_installed | grep  'asterisk' | cut -d 'k' -f 1`k"
  if [ $FORM_AST_INSTALLED != "asterisk" ]; then
    SOFTPH="OFF"
    ENABLE_AST="0"
    ENABLE="0"
  fi

  # Write the Asterisk settings into /etc/config/secn
  uci set secn.asterisk.host=$FORM_HOST
  uci set secn.asterisk.reghost=$FORM_REGHOST
  uci set secn.asterisk.proxy=$FORM_PROXY
  uci set secn.asterisk.username=$FORM_USER
  uci set secn.asterisk.fromusername=$FORM_USER
  uci set secn.asterisk.enable=$FORM_ENABLE
  uci set secn.asterisk.enable_ast=$ENABLE_AST
  uci set secn.asterisk.register=$FORM_REGISTER
  uci set secn.asterisk.dialout=$FORM_DIALOUT
  uci set secn.asterisk.codec1=$FORM_CODEC1
  uci set secn.asterisk.codec2=$FORM_CODEC2
  uci set secn.asterisk.codec3=$FORM_CODEC3
  uci set secn.asterisk.externip=$FORM_EXTERNIP
  uci set secn.asterisk.enablenat=$FORM_ENABLENAT
  uci set secn.asterisk.softph=$FORM_SOFTPH

  if [ $FORM_SECRET != "****" ]; then         # Set the password only if newly entered
    uci set secn.asterisk.secret=$FORM_SECRET
  fi

  # Commit the settings into /etc/config/ files

  uci commit secn

%>

<div class="alert alert-success">
  <a class="close" data-dismiss="alert">x</a>
  <h4>Voice changes saved! Reboot for changes to take effect</h4>
</div>
  
<% fi %>

<% if [ $FORM_BUTTON = "RestartAsterisk" ]; then %>

    <div class="alert alert-warning">
      <a class="close" data-dismiss="alert">x</a>
      <h4>Restarting Asterisk!</h4>
      <h5><%= $FORM_BUTTON %> </h5>
    </div>

<% fi %>

<% if [ $FORM_BUTTON = "Reboot" ]; then %>
    <script type="text/javascript">
      (function countdown(remaining) {
          if(remaining <= 0)
            location.reload(true);
            document.getElementById('countdown').innerHTML = 'Counting down: ' + remaining;
          setTimeout(function(){ countdown(remaining - 1); }, 120);
      })(120); // 120 seconds
    </script>
    <div class="alert alert-danger">
      <h4>Rebooting! Please wait till timer counts down then refresh this page</h4>
      <div id="countdown"></div>
    </div>
    <% reboot %>

<% fi %>

