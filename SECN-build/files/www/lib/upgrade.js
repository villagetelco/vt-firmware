$(document).ready( function() {
	// option to hide checkum in firmware upgrade 
    $('#showchecksum').change(function() {
    	$('#' + $(this).data('toggles')).toggle();
	});
	// File upload progress bar
    (function() {
        var bar = $('.bar');
        var percent = $('.percent');
        var status = $('#status');
        $('#fupload').ajaxForm({
            beforeSend: function() {
                status.empty();
                var percentVal = '0%';
                bar.width(percentVal)
                percent.html(percentVal);
            },
            uploadProgress: function(event, position, total, percentComplete) {
                var percentVal = percentComplete + '%';
                bar.width(percentVal)
                percent.html(percentVal);
            },
            complete: function(xhr) {
                status.html(xhr.responseText);
            }
        }); 
    })();     
});
