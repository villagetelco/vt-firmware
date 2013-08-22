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

$('#networkFormzz').on('submit',function(e) {
	var thisForm = $(this);
	e.preventDefault();

	//Hide the form
	$(this).fadeOut(function(){
	  //Display the "loading" message
	  $("#loading").fadeIn(function(){
	    //Post the form to the send script
			$.ajax({
				url: thisForm.attr('action'),
				type: thisForm.attr('method'),
				data: thisForm.serialize(),
				success : function(data) {
				  //Hide the "loading" message
				  $("#loading").fadeOut(function(){
				    //Display the "success" message
				    $("#success").html(data).fadeIn();
				    document.location.reload(true);
				  });
				}
			});
		});
	});	
});

// jquery form validator code

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
		submitHandler: function(form) {
			alert('valid form submission'); // for demo
			$.ajax({
      	url:  "/cgi-bin/net_save.sh",
      	type: "POST",
      	data: $(form).serialize(),
  			success: function(data) {
          $("#success").html(data).fadeIn();
          document.location.reload(true);
      	}
      });
      return false;
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
		success: function(label) { 
			label.html("").addClass("checked");
		}
	});
});



