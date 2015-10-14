#!/bin/sh -x

# /www/cgi-bin/config/config-sub-adv3.sh
# This script saves the SoftPhone updates when the page is submitted

# Build the new script file
#---------------------------------------------------
cat > /tmp/conf-save-sph.sh << EOF

#!/bin/sh

# Clear settings for checkboxes and buttons


# Get Field-Value pairs from QUERY_STRING environment variable
# set by the form GET action
# Cut into individual strings: Field=Value


`echo $QUERY_STRING | cut -d \& -f 1`
`echo $QUERY_STRING | cut -d \& -f 2`
`echo $QUERY_STRING | cut -d \& -f 3`
`echo $QUERY_STRING | cut -d \& -f 4`
`echo $QUERY_STRING | cut -d \& -f 5`
`echo $QUERY_STRING | cut -d \& -f 6`
`echo $QUERY_STRING | cut -d \& -f 7`
`echo $QUERY_STRING | cut -d \& -f 8`
`echo $QUERY_STRING | cut -d \& -f 9`
`echo $QUERY_STRING | cut -d \& -f 10`

# Refresh screen without saving 
if [ \$BUTTON = "Refresh" ]; then
	exit
fi

# Save
if [ \$BUTTON = "Save" ]; then
  /bin/set-softph.sh \$SP_NUMBER P:\$SP_PW1 N:\$SP_NAME
fi

# Delete
if [ \$BUTTON = "Delete" ]; then
  /bin/delete-softph.sh \$SP_NUMBER
fi

EOF
#-------------------------------------------------

# Make the file executable and run it to update the config settings.
# Catch any error messages
chmod +x /tmp/conf-save-sph.sh   > /dev/null
/tmp/conf-save-sph.sh

# Build the configuration screen and send it back to the browser.
/www/cgi-bin/secn-tabs

# Clean up temporary files
rm /tmp/conf-save-sph.sh  > /dev/null
rm /tmp/config.html       > /dev/null


