$(document).ready( function() {
// call easytabs
	$('#outer-container, #inner-container').easytabs();
	


// function to refresh iframes on status page
    setInterval(refreshIframe, 10000);
    function refreshIframe() {
        $("#FrameID1")[0].src = $("#FrameID1")[0].src;
        $("#FrameID2")[0].src = $("#FrameID2")[0].src;
        $("#FrameID3")[0].src = $("#FrameID3")[0].src;
        $("#FrameID4")[0].src = $("#FrameID4")[0].src;
    }


// jquery form validator code

	$.validator.addMethod('IP4Checker', function(value) {
		var ip = "^(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$";
		return value.match(ip);
	}, 'Invalid IP address');
	$.validator.addMethod('HexChecker', function(value) {
		var hex = "^([0-9a-fA-F]{2}([:-]|$)){6}$|([0-9a-fA-F]{4}([.]|$)){3}$";
		return value.match(hex);
	}, 'Invalid MAC address');

	$('#MP').validate({
		rules: {
			BR_IPADDR: {
			required: true,
			IP4Checker: true
			},
			BR_GATEWAY: {
			required: true,
			IP4Checker: true
			},
			BR_DNS: {
			IP4Checker: true
			},
			BR_NETMASK: {
			IP4Checker: true
			},
			ATH0_IPADDR: {
			IP4Checker: true
			},
			ATH0_GATEWAY: {
			IP4Checker: true
			},
			ATH0_DNS: {
			IP4Checker: true
			},
			ATH0_NETMASK: {
			IP4Checker: true
			},
			EXTERNIP: {
			IP4Checker: true
			},
			STARTIP: {
			IP4Checker: true
			},
			ENDIP: {
			IP4Checker: true
			},
			OPTION_ROUTER: {
			IP4Checker: true
			},
			ATH0_TXPOWER: {
			range: [0, 20]
			},
			ENCRYPTION: {
			required: true
			},
			ATH0_BSSID: {
			HexChecker: true
			},
			PASSPHRASE: {
			minlength: 8
			},
			PASSWORD1: {
			minlength: 3
			},
			PASSWORD2: {
			minlength: 3,
			equalTo: "#PASSWORD1"
			}
		},
		success: function(label) { 
			label.html("").addClass("checked");
		}
	});

	$('#MP-ADV').validate({
		rules: {
			BR_IPADDR: {
			required: true,
			IP4Checker: true
			},
			BR_GATEWAY: {
			required: true,
			IP4Checker: true
			},
			BR_DNS: {
			IP4Checker: true
			},
			BR_NETMASK: {
			IP4Checker: true
			},
			ATH0_IPADDR: {
			IP4Checker: true
			},
			ATH0_GATEWAY: {
			IP4Checker: true
			},
			ATH0_DNS: {
			IP4Checker: true
			},
			ATH0_NETMASK: {
			IP4Checker: true
			},
			EXTERNIP: {
			IP4Checker: true
			},
			STARTIP: {
			IP4Checker: true
			},
			ENDIP: {
			IP4Checker: true
			},
			OPTION_ROUTER: {
			IP4Checker: true
			},
			ATH0_TXPOWER: {
			range: [0, 20]
			},
			ENCRYPTION: {
			required: true
			},
			ATH0_BSSID: {
			HexChecker: true
			},
			PASSPHRASE: {
			minlength: 8
			},
			PASSWORD1: {
			minlength: 3
			},
			PASSWORD2: {
			minlength: 3,
			equalTo: "#PASSWORD1"
			}
		},
		success: function(label) { 
			label.html("").addClass("checked");
		}
	});
});



