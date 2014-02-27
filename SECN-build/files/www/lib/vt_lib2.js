$(document).ready(function() {

// toggle basic and advanced UI
$('#adv_ui').on('switch-change', function (e, data) {
    var swState = data.value;
    if (!swState) {
    	$(".adv_ui").addClass("hide");
    } else {
			$(".adv_ui").removeClass("hide");
    }
});

var runPing = function (ip) {
    $.get('/cgi-bin/ping.sh ip', function () {
        alert('Shell script done!');
    });
};

$('#gwstatusXX').load("/cgi-bin/ping.sh 192.168.3.1");

$("#br_ipaddr").change(function() {
		var cClass = $("#br_ipaddr").val().match(/\b\d{1,3}\.\d{1,3}\.\d{1,3}\./);
    $("#br_gateway").val(cClass + "1");
});

$("#br_gateway").change(function() {
		$this = $("#br_ipaddr").val();
		runPing(this);
    alert('doing something new');
});

// jquery form validator code

	jQuery.validator.setDefaults({
		errorClass : "help-inline"
	});

	$.validator.addMethod('IP4Checker', function(value) {
		var ip = "^(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$";
		return value.match(ip);
	}, 'Invalid IP address');
	$.validator.addMethod('HexChecker', function(value) {
		var hex = "^([0-9a-fA-F]{2}([:-]|$)){6}$|([0-9a-fA-F]{4}([.]|$)){3}$";
		return value.match(hex);
	}, 'Invalid MAC address');

	$('#networkForm').validate({
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
			range: [10, 20]
			},
			ENCRYPTION: {
			required: true
			},
			SSID: {
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
		highlight: function(element) {
			$(element).closest('.form-group').removeClass('has-success').addClass('has-error');
		},
		success: function(element) {
			$(element).closest('.form-group').removeClass('has-error').addClass('has-success');
		},	
		submitHandler: function(form) {
			// alert('valid form submission'); // for demo
			$.ajax({
      	url:  "/cgi-bin/net_save.sh",
      	type: "POST",
      	data: $(form).serialize(),
  			success: function(data) {
          $("#nsuccess").html(data).fadeIn();
      	}
      });
      return false;
    }
	});

	$('#voiceForm').validate({
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
			range: [10, 20]
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
		highlight: function(element) {
			$(element).closest('.form-group').removeClass('has-success').addClass('has-error');
		},
		success: function(element) {
			element
			.text('OK!').addClass('valid')
			.closest('.form-group').removeClass('has-error').addClass('has-success');
		},
		submitHandler: function(form) {
			// alert('valid form submission'); // for demo
			$.ajax({
      	url:  "/cgi-bin/voice_save.sh",
      	type: "POST",
      	data: $(form).serialize(),
  			success: function(data) {
          $("#vsuccess").html(data).fadeIn();
      	}
      });
      return false;
    }
	});


});



