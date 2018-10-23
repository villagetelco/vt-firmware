$(document).ready( function() {
// call easytabs
	$('#outer-container, #inner-container').easytabs();
	


// function to refresh iframes on status page
    setInterval(refreshIframe, 10000);
    function refreshIframe() {
        $("#FrameID10")[0].src = $("#FrameID10")[0].src;
        $("#FrameID20")[0].src = $("#FrameID20")[0].src;
        $("#FrameID30")[0].src = $("#FrameID30")[0].src;
        $("#FrameID40")[0].src = $("#FrameID40")[0].src;
        $("#FrameID50")[0].src = $("#FrameID50")[0].src;
    }


// jquery form validator code
	jQuery.validator.addMethod('IP4Checker', function(value) {
		var split = value.split('.');
		if (split.length != 4)
			return false;
		for (var i=0; i<split.length; i++) {
			var s = split[i];
			if (s.length===0 || isNaN(s) || s<0 || s>255)
				return false;
		}
		return true;
	}, ' Invalid IP Address');
	$.validator.addMethod('PassChecker', function(value) {
			var pass ="^[a-zA-Z0-9_*.$%<>;:?@=!^|&+()\{\}\`\#\~\-]*$";
			return value.match(pass);
	}, 'Sorry, special characters not permitted');
	$.validator.addMethod('PassChecker2', function(value) {
			var pass ="^[a-zA-Z0-9_*.\-]*$";
			return value.match(pass);
	}, 'Sorry, special characters not permitted');
	$.validator.addMethod('HexChecker', function(value) {
		var hex = "^([0-9a-fA-F]{2}([:-]|$)){6}$|([0-9a-fA-F]{4}([.]|$)){3}$";
		return value.match(hex);
	}, 'Invalid MAC address');
	$.validator.addMethod('CountryChecker', function(value) {
			var pass ="^([A-Z]{2}|[]{0})$";
			return value.match(pass);
	}, 'Requires two character code eg AU');

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
			SSID: {
			maxlength: 32,
			minlength: 1,
			PassChecker: true
			},
			SSID1: {
			maxlength: 32,
			minlength: 1,
			PassChecker: true
			},
			SSIDPREFIX: {
			maxlength: 32,
			minlength: 2,
			PassChecker: true
			},
			SSIDPREFIX2: {
			maxlength: 32,
			minlength: 2,
			PassChecker: true
			},
			PASSPHRASE: {
			maxlength: 32,
			minlength: 8,
			PassChecker: true
			},
			PASSPHRASE1: {
			maxlength: 32,
			minlength: 8,
			PassChecker: true
			},
			PASSPHRASE2: {
			maxlength: 32,
			minlength: 8,
			PassChecker: true
			},
			HOST: {
			PassChecker2: true
			},
			USER: {
			PassChecker2: true
			},
			SECRET: {
			maxlength: 32,
			minlength: 4,
			PassChecker: true
			},
			PASSWORD1: {
			maxlength: 32,
			minlength: 3,
			PassChecker: true
			},
			PASSWORD2: {
			maxlength: 32,
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
			ATH0_IPADDR1: {
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
			ATH0_NETMASK1: {
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
			DOMAIN: {
			PassChecker2: true
			},
			MAXLEASES: {
			range: [0, 254]
			},
			LEASETERM: {
			range: [0, 65536]
			},
			ATH0_TXPOWER: {
			range: [0, 27]
			},
			ATH0_TXPOWER1: {
			range: [0, 23]
			},
			ATH0_SSID: {
			maxlength: 32,
			minlength: 1,
			PassChecker2: true
			},
			ATH0_SSID1: {
			maxlength: 32,
			minlength: 1,
			PassChecker2: true
			},
			SSID: {
			maxlength: 32,
			minlength: 1,
			PassChecker: true
			},
			SSID1: {
			maxlength: 32,
			minlength: 1,
			PassChecker: true
			},
			PASSPHRASE: {
			maxlength: 32,
			minlength: 8,
			PassChecker: true
			},
			MESH_ID: {
			maxlength: 32,
			minlength: 1,
			PassChecker: true
			},
			MESHPASSPHRASE: {
			maxlength: 32,
			minlength: 8,
			PassChecker: true
			},
			COUNTRY: {
			CountryChecker: true
			},
			COVERAGE: {
			range: [0, 255]
			},
			HOST: {
			PassChecker2: true
			},
			REGHOST: {
			PassChecker2: true
			},
			USER: {
			maxlength: 32,
			minlength: 4,
			PassChecker2: true
			},
			SECRET: {
			maxlength: 32,
			minlength: 4,
			PassChecker: true
			},
			OPTION_DNS: {
			IP4Checker: true
			},
			OPTION_DNS2: {
			IP4Checker: true
			},
		},
		success: function(label) {
			label.html("").addClass("checked");
		}
	});

	$('#MP-WAN').validate({
		rules: {
			WANIP: {
			IP4Checker: true
			},
			SECWANIP: {
			IP4Checker: true
			},
			WANGATEWAY: {
			IP4Checker: true
			},
			WANMASK: {
			IP4Checker: true
			},
			WANDNS: {
			IP4Checker: true
			},
			WANSSID: {
			maxlength: 32,
			minlength: 1,
			PassChecker: true
			},
			WANPASS: {
			maxlength: 32,
			minlength: 1,
			PassChecker: true
			},
			APN: {
			PassChecker2: true
			},
			APNUSER: {
			PassChecker: true
			},
			APNPW: {
			PassChecker: true
			},
			MODEMPIN: {
			PassChecker2: true
			},
			PRODUCT: {
			PassChecker2: true
			},
			VENDOR: {
			PassChecker2: true
			},
			DIALSTR: {
			PassChecker: true
			},
			PIN: {
			PassChecker2: true
			},
		},
		success: function(label) {
			label.html("").addClass("checked");
		}
	});

	$('#MP-SPH').validate({
		rules: {
			SP_NAME: {
			minlength: 2,
			maxlength: 16,
			PassChecker: true
			},
			SP_PW1: {
			minlength: 4,
			maxlength: 16,
			PassChecker: true
			},
			SP_PW2: {
			minlength: 4,
			maxlength: 16,
			equalTo: "#SP_PW1"
			},
			SP_NUMBER: {
			range: [300, 399],
			PassChecker: true
			},
		},
		success: function(label) {
			label.html("").addClass("checked");
		}
	});

});


