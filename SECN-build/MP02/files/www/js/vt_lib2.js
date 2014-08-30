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

$("#br_gatewayXX").change(function() {
		$this = $("#br_ipaddr").val();
		runPing(this);
    alert();
});

    $('#networkForm').bootstrapValidator({
        // To use feedback icons, ensure that you use Bootstrap v3.1.0 or later
        feedbackIcons: {
            valid: 'glyphicon glyphicon-ok',
            invalid: 'glyphicon glyphicon-remove',
            validating: 'glyphicon glyphicon-refresh'
        },
        fields: {
            BR_IPADDR: {
                message: 'The device IP address is not valid',
                validators: {
                    notEmpty: {
                        message: 'The IP address is required and cannot be empty'
                    },
                    ip: {
                    	ipv4: true,
                    	ipv6: false,
                        message: 'The IP address must be in 4 octets'
                    }
                }
            },
            BR_GATEWAY: {
                message: 'The Gateway IP address is not valid',
                validators: {
                    notEmpty: {
                        message: 'The gateway IP address is required and cannot be empty'
                    },
                    ip: {
                    	ipv4: true,
                    	ipv6: false,
                        message: 'The gateway IP address must be in 4 octets'
                    }
                }
            },
            BR_DNS: {
                message: 'The DNS IP address is not valid',
                validators: {
                    notEmpty: {
                        message: 'The DNS IP address is required and cannot be empty'
                    },
                    ip: {
                    	ipv4: true,
                    	ipv6: false,
                        message: 'The DNS IP address must be in 4 octets'
                    }
                }
            },
            BR_NETMASK: {
                message: 'The Netmask IP address is not valid',
                validators: {
                    notEmpty: {
                        message: 'The netmask IP address is required and cannot be empty'
                    },
                    ip: {
                    	ipv4: true,
                    	ipv6: false,
                        message: 'The netmask IP address must be in 4 octets'
                    }
                }
            },
            ATH0_IPADDR: {
                message: 'The IP address is not valid',
                validators: {
                    notEmpty: {
                        message: 'The IP address is required and cannot be empty'
                    },
                    ip: {
                    	ipv4: true,
                    	ipv6: false,
                        message: 'The IP address must be in 4 octets'
                    }
                }
            },
            ATH0_GATEWAY: {
                message: 'The IP address is not valid',
                validators: {
                    notEmpty: {
                        message: 'The IP address is required and cannot be empty'
                    },
                    ip: {
                    	ipv4: true,
                    	ipv6: false,
                        message: 'The IP address must be in 4 octets'
                    }
                }
            },
            ATH0_DNS: {
                message: 'The IP address is not valid',
                validators: {
                    notEmpty: {
                        message: 'The IP address is required and cannot be empty'
                    },
                    ip: {
                    	ipv4: true,
                    	ipv6: false,
                        message: 'The IP address must be in 4 octets'
                    }
                }
            },
            ATH0_NETMASK: {
                message: 'The IP address is not valid',
                validators: {
                    notEmpty: {
                        message: 'The IP address is required and cannot be empty'
                    },
                    ip: {
                    	ipv4: true,
                    	ipv6: false,
                        message: 'The IP address must be in 4 octets'
                    }
                }
            },
            EXTERNIP: {
                message: 'The IP address is not valid',
                validators: {
                    notEmpty: {
                        message: 'The IP address is required and cannot be empty'
                    },
                    ip: {
                    	ipv4: true,
                    	ipv6: false,
                        message: 'The IP address must be in 4 octets'
                    }
                }
            },
            STARTIP: {
                message: 'The IP address is not valid',
                validators: {
                    notEmpty: {
                        message: 'The IP address is required and cannot be empty'
                    },
                    ip: {
                    	ipv4: true,
                    	ipv6: false,
                        message: 'The IP address must be in 4 octets'
                    }
                }
            },
            ENDIP: {
                message: 'The IP address is not valid',
                validators: {
                    notEmpty: {
                        message: 'The IP address is required and cannot be empty'
                    },
                    ip: {
                    	ipv4: true,
                    	ipv6: false,
                        message: 'The IP address must be in 4 octets'
                    }
                }
            },
            OPTION_ROUTER: {
                message: 'The IP address is not valid',
                validators: {
                    notEmpty: {
                        message: 'The IP address is required and cannot be empty'
                    },
                    ip: {
                    	ipv4: true,
                    	ipv6: false,
                        message: 'The IP address must be in 4 octets'
                    }
                }
            },     
            ATH0_TXPOWER: {
                message: 'The power level is out of bounds',
                validators: {
                    between: {
                    	max: 20,
                    	min: 10,
                        message: 'The power level must be between 10 and 20'
                    }
                }
            },
            ENCRYPTION: {
                message: 'The IP address is not valid',
                validators: {
                    notEmpty: {
                        message: 'The IP address is required and cannot be empty'
                    }
                }
            },
            ATH0_BSSID: {
                message: 'The BSSID address is not valid',
                validators: {
                    notEmpty: {
                        message: 'The BSSID address is required and cannot be empty'
                    },
                    mac: {
                        message: 'The BSSID address must be in valid format'
                    }
                }
            },
            PASSPHRASE: {
                message: 'The passphrase is not valid',
                validators: {
                    notEmpty: {
                        message: 'The passphrase is required and cannot be empty'
                    },
                    stringLength: {
                    	min: 8,
                        message: 'The passphrase must be at least 8 characters'
                    }
                }
            },
            PASSWORD1: {
                message: 'The password is not valid',
                validators: {
                    stringLength: {
                    	min: 3,
                        message: 'The passphrase must be at least 3 characters'
                    }
                }
            },            
            PASSWORD2: {
                message: 'The password is not valid',
                validators: {
                    stringLength: {
                    	min: 3,
                        message: 'The passphrase must be at least 3 characters'
                    },
	                identical: {
	                	field: 'PASSWORD1',
	                	message: 'The passwords do not match'
	                }
                }
            }                
        }
    });
});


