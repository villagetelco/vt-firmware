//Scripts for MoToLi story pages

//Page global variables
var pgOn; //The number of the page to be displayed
var pgMax; //The total number of pages in the story

//Progress timing global variables
var timerInt = 0; 	//handle for interval timer updating a progress bar
var timerOut = 0; 	//handle of timeout timer if running
var timerIDs;	//An array of all timeout timer IDs set when a progress bar is run
var pInterval; 	//length of a pause. Its value is extracted from the story container div in the HTML file
var initStatus = false;	//Set to true if initialisation has already occurred. Needed to overcome multiple onload events in the XOs
var newPlay = false;	//Flags when a play button has been clicked. When true, all updates on a progress bar will be ignored
				
var Key = {
  PAGEUP:	33,
  PAGEDOWN:	34,
  END:		35,
  HOME:		36,
  LEFT:		37,
  UP:		38,
  RIGHT:	39,
  DOWN:		40
};

function initialise() {
	onloadCount = parseInt(document.getElementById("onloads").innerHTML) + 1;
	document.getElementById("onloads").innerHTML = onloadCount;
	//Only process if this is the first call. Subsequent calls are ignored until the file is reloaded.
	if (initStatus === false) {
		initStatus = true;
		
		//Set the page related global variables
		pgOn = 0;
		pgMax = document.getElementsByClassName("page").length;	
		
		//Get the story name for the footers
		for (i = 0; i < document.getElementsByClassName("title").length; i++) {
			document.getElementsByClassName("title")[i].innerHTML = document.getElementsByTagName("title")[0].innerHTML;
		}
		
		//Modify styles specified in the HTML data.
		document.getElementsByTagName("body")[0].style.backgroundColor = document.getElementById("backColor").innerHTML;
		var diagnosticState = document.getElementById("diagnostic").innerHTML;
		document.getElementById("platform").innerHTML = navigator.platform;
		var pauseNodes = document.getElementsByClassName("pause");
		if (diagnosticState === "on"){
			document.getElementsByClassName("data")[0].style.fontSize = "1em";
			for (i = 0; i < pauseNodes.length; i++) {
				pauseNodes[i].style.fontSize = "0.5em";
				pauseNodes[i].style.visibility = "visible";
			}
		} else {
			document.getElementsByClassName("data")[0].style.fontSize = "0.1em";
			for (i = 0; i < pauseNodes.length; i++) {
				pauseNodes[i].style.fontSize = "0.1em";
				pauseNodes[i].style.visibility = "hidden";
			}
		}

		addNavKeyEvt();	//To listen for arrow, Page up/down, and Home/End key events
		setFormat();	//Sets the story format - horizontal or vertical
		limitPictureSize();	//Width for 'sidepic' format, height for 'underpic' format
		timerIDs = [];
		showLanguages(); //Hide all text lines for any language not required
		showPage(pgOn, "load");
		autoPlay(pgOn); //Play the audio automatically for page 0 on first load
		resetEndChangeButtons();	//At the extremes - start and end of the story
		//Display the fully styled first page
		if (document.getElementById("loadmsg")) document.getElementById("loadmsg").style.display = "none";
		document.getElementById("story").style.visibility = "visible";
	}
}

// LAYOUT & FORMATTING FUNCTIONS

function setFormat() {	//Establishes text-beside-pic or text-under-pic format, according the story container div class
	//	Class "underpic" represents text under main picture, class "sidepic" means text beside picture
	if (document.getElementById("story").className === "under") {
		for (i = 0; i < document.getElementsByClassName("underpic").length; i++){
			document.getElementsByClassName("underpic")[i].style.display = "block";
		}
		for (i = 0; i < document.getElementsByClassName("sidepic").length; i++){
			document.getElementsByClassName("sidepic")[i].style.display = "none";
		}
	} else {
		for (i = 0; i < document.getElementsByClassName("underpic").length; i++){
			document.getElementsByClassName("underpic")[i].style.display = "none";
		}
		for (i = 0; i < document.getElementsByClassName("sidepic").length; i++){
			document.getElementsByClassName("sidepic")[i].style.display = "block";
		}
	}
}

function showLanguages() {
    var i, j;
	var visLangs = [];
	var hashIndex = window.location.href.indexOf('#');
	var textLineNodes;
	var textRowNodes;
	var visLangClass;
	
	if (hashIndex > 0) {
		visLangs = window.location.href.slice(hashIndex + 1).split(',');
	}
//	alert(visLangs);
	if (!visLangs[0]) return;
	
	textLineNodes = document.getElementsByClassName("textLine");
	for (i = 0; i < textLineNodes.length; i++) {
	textLineNodes[i].parentNode.style.display = "none";
	}
	for (i = 0; i < visLangs.length; i++){
		visLangClass = visLangs[i]
		textRowNodes = document.getElementsByClassName(visLangClass);
		for (j = 0; j < textRowNodes.length; j++){
			textRowNodes[j].style.display = "block";
		}
	}
}

function limitPictureSize() {
	//Limits the width or height of the main picture, depending on the story format.
	//The limits are a percentage of screen size, defined in the HTML file.
	//This function is called at initialisation, and also at any subsequent change in window size.
	
	if (document.getElementById("story").className === "side") {	//Limit the 'side' picture size
		var w = window.innerWidth;
		var scale = parseInt(document.getElementById("pScaleSide").innerHTML);
		var picSpace = parseInt(w * scale / 100);
		var sidePicNodes = document.getElementsByClassName("sidepic");

		for (i = 0; i < sidePicNodes.length; i++) {
			var picNodes = sidePicNodes[i].getElementsByClassName("mainpic");
			for (j = 0; j < picNodes.length; j++) {
				picNodes[j].width = picSpace;
			}
		}
	} else if (document.getElementById("story").className === "under") { //Limit the 'under' picture size
		var h = window.innerHeight;
		var scale = parseInt(document.getElementById("pScaleTop").innerHTML);
		var picSpace = parseInt(h * scale / 100);
		var topPicNodes = document.getElementsByClassName("underpic");

		for (i = 0; i < topPicNodes.length; i++) {
			var picNodes = topPicNodes[i].getElementsByClassName("mainpic");
			for (j = 0; j < picNodes.length; j++) {
				picNodes[j].height = picSpace;
			}
		}
	}	
}

function resetEndChangeButtons() {
	//There are 2 of each back and fwd buttons on every page - 
	//one set for 'text beside' format, and one set for 'text under' format
	//reset the back button icons on page 0
	var startPageNode = document.getElementById("p0");
	for (i = 0; i < startPageNode.getElementsByClassName("btnback").length; i++) {
		startPageNode.getElementsByClassName("btnback")[i].src = "../../common/home.png";
	}
	//reset the forward button icons on the last page
	var endpID = "p" + (pgMax - 1);
	var endPageNode = document.getElementById(endpID);
	for (i = 0; i < endPageNode.getElementsByClassName("btnfwd").length; i++) {
		endPageNode.getElementsByClassName("btnfwd")[i].src = "../../common/home.png";
	}
}

function newStory() {
   	stopAllTimers();
	window.history.back();
}

function hideAllPages(){
	var pageID;
	for (i = 0; i < pgMax; i++) {
		pageID = "p" + i;
		document.getElementById(pageID).style.display = "none";
	}
}

function showPage(i, evnt) {
	//Function does the basics of making the page visible, and inserting the correct page number.
	//However, its main purpose is to set the lengths (widths) of any progress bars on the page
	//to align exactly with the lengths of the corresponding text lines.
	
	var pagenumber;
	var pageID;
	var textNode;	//the <span> element containing a line of text
	var textLength;	//the length of the text in the textNode, in px
	var progNode;	//the <progress> element corresponding to the textNode
	var lineNodes;	//the set of <td> nodes on the page containing a single line of text
	var wrapNodes;	//the set of <td> nodes on the page containing multiple (wrapped) lines of text	
	var wrapLines;	//the number of text lines in each single wrapNode
	
	var player = document.getElementById("AudioPlayer");
	player.pause();	//In case it's running
	pageID = "p" + i;
	pagenumber = " ";
	if (i > 0) {pagenumber = "&nbsp;&nbsp; Page " + i}; //i.e. don't display it on the title page
	for (j = 0; j < document.getElementsByClassName("pgnum").length; j++) {
		document.getElementsByClassName("pgnum")[j].innerHTML = pagenumber;
	}
	hideAllPages()	//and then display the desired one
	document.getElementById(pageID).style.display = "block"; //enable the page to be displayed
	
	//Now set the progress bar lengths for each text line of the page
	lineNodes = document.getElementById(pageID).getElementsByClassName("textLine");
	//This will also set the first line of a wrapped set, but it will be overwritten in the following for loop.
		for (j = 0; j < lineNodes.length; j++) {
			textNode = lineNodes[j].getElementsByClassName("line")[0];  //This is the text whose length we want
			textLength = textNode.offsetWidth;
			progNode = lineNodes[j].getElementsByTagName("progress")[0];  //This is the progress element to be set
			progNode.style.width = (textLength + "px");
			progNode.value = 0;
		}
	//Set the progress bar lengths for each line of any wrapped sets of lines
	wrapNodes = document.getElementById(pageID).getElementsByClassName("wrap");
		for (j = 0; j < wrapNodes.length; j++) {
			//get number of lines for each node
			wrapLines = wrapNodes[j].getElementsByClassName("line").length;
			for (k = 0; k < wrapLines; k++) {
				textNode = wrapNodes[j].getElementsByClassName("line")[k];
				textLength = textNode.offsetWidth;
				progNode = wrapNodes[j].getElementsByTagName("progress")[k];
				progNode.style.width = (textLength + "px");
				progNode.value = 0;
			}
		}
	//At this point all progress bars for the page have been set to the correct length and initialised to zero.
	//This is true for the XOs, although they do not display the new status, nor respond when activated.
	//The following action seems to be necessary to kick-start them back to life!
	document.getElementById(pageID).style.display = "block"; //enable the page to be displayed
	
	if (evnt === "load") {
		//Use brute force (page fwd and back) to force page 0 buttons to position correctly
		document.getElementById(pageID).getElementsByClassName("btnfwd")[0].click();
		document.getElementById(pageID).getElementsByClassName("btnback")[0].click();
	}
}

function autoPlay(i) {
	var platform = navigator.platform;
	if (platform === "iPad") {return; //function doesn't work on iPad/Android mobile
	} else if (platform === "Linux armv7l") {return;
	} else {
	// Finds the first visible text line on the page, and clicks its play button
	var pageID = "p" + i;
	var textLineNodes = document.getElementById(pageID).getElementsByClassName("textLine");
	var rowNode; //the parent <tr> node of the text line

	for (i = 0; i < textLineNodes.length; i++) {
		rowNode = textLineNodes[i].parentNode;
		if (rowNode.style.display != "none") {
			rowNode.getElementsByClassName("button")[0].childNodes[0].click();
			return;
		}
	}
	}
}

//PAGE NAVIGATION FUNCTIONS

function pageFwd() {
	stopAllTimers();
	pgOn += 1;
	if (pgOn > pgMax - 1){
		newStory();
	} else {
		showPage(pgOn, "change");
	}
}

function pageBack() {
	stopAllTimers();
	if (pgOn > 0){
		pgOn += - 1;
		showPage(pgOn, "change");
	} else {
		newStory();
	}
}

//Add a listener for keyboard events and define the keys to act on
// IE: attachEvent, Firefox & Chrome: addEventListener 
function _addEventListener(evt, element, fn) {
  if (window.addEventListener) {element.addEventListener(evt, fn, false);}
  else {element.attachEvent('on'+evt, fn);}
}

function onInputKeydown(evt) {
  if (!evt) {evt = window.event;} // for IE compatible
  var keycode = evt.keyCode || evt.which; // also for cross-browser compatible
  if (keycode == Key.LEFT) {pageBack();}
  else if (keycode == Key.RIGHT) {pageFwd();}
  else if (keycode == Key.UP) {pageBack();}
  else if (keycode == Key.DOWN) {pageFwd();}
  else if (keycode == Key.PAGEUP) {pageBack();}
  else if (keycode == Key.PAGEDOWN) {pageFwd();}
  else if (keycode == Key.HOME) {pgOn = 0; showPage(pgOn, "change");}
  else if (keycode == Key.END) {pgOn = pgMax - 1; showPage(pgOn, "change");}
  else {//do nothing
  }
}

function addNavKeyEvt() {
  _addEventListener('keydown', document, onInputKeydown);
}				


//FUNCTIONS TO INITIALISE PROGRESS BARS WHEN 'PLAY' BUTTONS ARE CLICKED

function playAudio(file, time, pageNo, lineNo) {
	var player; //The node for the audio player
	var line; //index No. of the text cell matching the audio file
	var audioTime;
	var textNode;	//The text node (single or multi line) matching the audio track
	var progNodes;		//the set of <progress> nodes on a page
	var wrapLineCount;	//the number of lines of text in a wrapped set (i.e. a paragraph)
	var paragraphLength;	//the length in px of all the text in a paragraph
	var partLength;		//the length in px of a line in a paragraph
	var progNode;		//the specific <progress> element corresponding to a single line in a paragraph
	var lineTime; 	//Max time for an individual progress bar (in a wrapped lines paragraph)
	var lineNode;	//the specific <span> element enclosing the full text to match progNode and lineTime
	var pauseListLine;	//Array of pause times for a single line (i.e. a single progress bar)
	var pauseListWrap;	//An array of pauseListLines - only one entry if the text is a 
						//single line, multiple entries for wrapped lines.

	newPlay = true; //This prevents the incProgBar() function from updating anything until newPlay is reset to false
	player = document.getElementById("AudioPlayer");
	player.play();
//	player.src = file;
	line = lineNo - 1;
	audioTime = (time * 1000); //turn it to msec
	stopAllTimers();
	// Clear the interval timer after a delay long enough to ensure all the timeout timers have been cleared,
	// but not too long or it will interfere with the start of the new line. Keep well short of the standard
	// delay at the start of a line. 10 msec seems to quite OK.
	var timer = setTimeout(function() {clearInterval(timerInt);}, 10);
	
	//zero all the progress bars on the page
	progNodes = document.getElementById(pageNo).getElementsByTagName("progress");
	for (i = 0; i < progNodes.length; i++) {
		progNodes[i].value = 0;
	}
	
	//Clear any pause time data
	pauseListLine = [];
	pauseListWrap = [];
	
	textNode = document.getElementById(pageNo).getElementsByClassName("textLine")[line];
	//If it's a set of wrapped lines, we need to set the max times for each progress bar. The full audio time is known, 
	//so each line's proportion of this is simply the ratio of it's width to the total widths of all the lines.
	if (textNode.className === "textLine wrap") {
		//Add the widths of all the lines, i.e. get the paragraph length
		wrapLineCount = textNode.getElementsByTagName("progress").length;
		paragraphLength = 0;
		for (i = 0; i < wrapLineCount; i++){
			partLength = parseInt(textNode.getElementsByTagName("progress")[i].style.width);
			paragraphLength += partLength;
		}
		// Set the proportional times for each line of text
		for (j = 0; j < wrapLineCount; j++){
			progNode = textNode.getElementsByTagName("progress")[j]
			lineTime = parseInt(parseInt(progNode.style.width) / paragraphLength * audioTime);
			progNode.max = lineTime; //Sets the maximum value (in msec) for the line
			lineNode = textNode.getElementsByClassName("line")[j];
			pauseListLine = getPauseList(progNode, lineNode, j);	//Builds a list of data about the line, mainly its nodes and pause times
			pauseListWrap.push(pauseListLine);	//Wrap the line data into a list of line data sets.		
		}
	} else {
		//No wrapped lines so just set the single progress bar node
		progNode = textNode.getElementsByTagName("progress")[0];
		progNode.max = audioTime;	 //Sets the maximum value (in msec) for the line
		lineNode = textNode.getElementsByClassName("line")[0];
		pauseListLine = getPauseList(progNode, lineNode, 0);	//Builds a list of data about the line, mainly its nodes and pause times
		pauseListWrap.push(pauseListLine);	//Wrap the line data into a list of line data sets - although in this case it will be the only entry
	}
	
	//Start the audio file and the progress bar, once the file is loaded
	player.src = file;
	player.oncanplaythrough = startAudioBar(player, pauseListWrap);
}

function startAudioBar(player, pauseListWrap) {
	//wait 1 sec before starting everything - allows additional time for the audio file to load
	var timer = setTimeout(function() {player.play(); runProgBar(pauseListWrap);}, 1000);
}

function getPauseList(progNode, lineNode, index) {
	//Function is called by playAudio() to build an array of objects for a line of text, in order: 
	//line index (starts at 0 for a wrapped set), progress bar node, list of times when pauses will be triggered.
	//This provides all the info needed to run a particular progress bar. 
	
	//The calling function [playAudio()] assembles all line arrays for a single audio file into a wrap 
	//array - even if it's only a single line.
	
	var lineLength;
	var pNodes;	//the set of <span> elements defining pauses in the line
	var pList;	//An array that contains the index, progNode, plus any pause times
	var pTrigTime; //time before pause is triggered
	var numPauses;
	var lineTime;	//audio time for the progress bar
	var prevPauseTime;	//Need to track it to add to each successive pause interval
						//i.e. all pause times are referenced to the start of the bar

	pInterval = parseInt(document.getElementById("barPause").innerHTML);
	pList = [];
	lineLength = lineNode.offsetWidth;
	pNodes = lineNode.getElementsByTagName("span");
	lineTime = progNode.max;
	pList.push(index);		//line index if it's one of a wrapped set
	pList.push(progNode);	//Second item in the array
	prevPauseTime = 0 - pInterval; //to cancel it out when it's added to the first pause in the for loop.

	//Now add the pause times to the array
	numPauses = pNodes.length - 1;	//don't want to count the last one
	if (numPauses > 0) {
		for (i = 0; i < numPauses; i++) {
			pause = pNodes[i].offsetWidth;
			//Only want to trigger a pause if the class="pause", but we need to accumulate the time of *all* the <span> elements
			pTrigTime = prevPauseTime + parseInt(pause / lineLength * lineTime);
			if (pNodes[i].className === "pause") {
				pTrigTime = pTrigTime + pInterval; //pInterval allows for a previous pause, but is cancelled for the first because we started with -pInterval
				pList.push(pTrigTime);
			}
			prevPauseTime = pTrigTime;
		}
	}
	return pList;
}


//FUNCTIONS TO CONTROL AND UPDATE THE PROGRESS BARS

function runProgBar(pauseListWrap) {
	var time; //time until a pause
	var pauseListLine = [];
	var startDelay = 1000;	//applied to first line
	var defaultDelay = 200;	//applied to lines other than first
	var delay;
	var lineIndex;
	var wrapID; 	//the ID of the pauseListWrap object requested to be run.
	var wrapItems;	//the No. of objects in pauseListWrap - wrapID will be the last
	var timer;		//ID for any timer when it is set
	var platform;	//time delays when starting the progress bars will depend on the OS platform.
	
	//This function sets the timer to increment a progress bar and all the timeout timers to trigger pauses
	//along the bar. All the info for this is contained in the pauseListLine array, which itself is an object
	//in the pauseListWrap array. If we are running a multi-line set of progress bars, the incProgBar() function 
	//will detect when a progress bar is full, and recall runProgBar() to set up the new timers for the next 
	//line (if one exists in the pauseListWrap array).
	//Therefore we need to clear all timers before setting up a new line. However, there can be a variable number
	//of timeout timers, depending on the pauses in the line. Their IDs are stored in the global timerIDs array 
	//to enable them all to be cleared in the stopAllTimers() function.
	
	//Stop all timers before continuing
	stopAllTimers();
	clearInterval(timerInt);
	var platform = document.getElementById("platform").innerHTML;
	//Different delay times seem to be desirable for different platforms
	if (platform.search("inux arm") > 0) {
		startDelay = 1500;
		defaultDelay = 300;
	} else {
		startDelay = 1000;
		defaultDelay = 200;
	}
	
	wrapItems = pauseListWrap.length;
	pauseListLine = pauseListWrap.shift();
	
	lineIndex = pauseListLine.shift();
	if (lineIndex == 0) {delay = startDelay} else {delay = defaultDelay};
	progNode = pauseListLine.shift();	//Only pause times will now remain in this array
		progNode.value = 0;
		maxTime = progNode.max;
		//Start the interval timer after the appropriate delay
		//The global newPlay flag *must not* be reset to false until after the setTimeout delay
		//clearInterval must always precede setInterval to ensure only one instance of the timer is ever running.
		timer = setTimeout(function() {clearInterval(timerInt); newPlay = false; timerInt = setInterval(function() {incProgBar(progNode, maxTime, pauseListWrap);}, 50)}, delay);
		timerIDs.push(timer);
	
		//Loop - for each time on pauseListLine
		var numPauses = pauseListLine.length;
		if (numPauses > 0) {
			for (i = 0; i < numPauses; i++) {
				time = pauseListLine[i] + delay;
				timer = setTimeout(function() {pauseBar(progNode, maxTime, pauseListWrap);}, time);
				timerIDs.push(timer);
			}
		}
}

function stopAllTimers() {
	var timer;
	
	for (i = 0; i < timerIDs.length; i++) {
		timer = timerIDs.pop;
		clearTimeout(timer);
	}
	 timerIDs = [];
	 clearInterval(timerInt); //there should only ever be one instance of the interval timer running, and its ID is the global timerInt
}

function incProgBar(progNode, maxTime, pauseListWrap) {
	var barTime;
	
	if (newPlay == true) return;	//This means a Play button has been clicked, and we are not yet cleared to update anything.
	barTime = progNode.value;
	barTime += 50;
	progNode.value = barTime;
	if (barTime >= maxTime) {
		clearInterval(timerInt); //immediately stops the bar
		if (pauseListWrap.length > 0) {	// If it isn't, there's no more to do
			runProgBar(pauseListWrap);
		}
	}
}

function pauseBar(pNode, maxTime, pauseListWrap) {
	clearInterval(timerInt); //Stops the bar immediately
	//clearInterval must always precede setInterval in the following function call to ensure only one instance of the timer is running.
	timer = setTimeout(function() {clearInterval(timerInt); timerInt = setInterval(function() {incProgBar(pNode, maxTime, pauseListWrap);}, 50);}, pInterval);
	timerIDs.push(timer);
}

