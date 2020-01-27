# All command-line options to guacd are redundant
# with config file settings in /etc/guacamole/guacd.conf
# Equivalent config-file settings are documented here:
# https://guacamole.apache.org/doc/gug/configuring-guacamole.html#guacd.conf

# Changes the host or address that guacd listens on
# This corresponds to the bind_host parameter within the server section of guacd.conf
#GUACD_OPTS="${GUACD_OPTS} -b 127.0.0.1"

# Changes the port that guacd listens on
# This corresponds to the bind_port parameter within the server section of guacd.conf
#GUACD_OPTS="${GUACD_OPTS} -l 4822"

# Sets the maximum level at which guacd will log messages to syslog and, if
# running in foreground, the console.  Legal values are trace, debug, info, warning, and error
#GUACD_OPTS="${GUACD_OPTS} -L info"

# Causes guacd to run in the foreground, rather than automatically forking into the background
#GUACD_OPTS="${GUACD_OPTS} -f"

# If guacd was built with support for SSL, data sent via the Guacamole protocol can be
# encrypted with SSL if an SSL certificate and private key are given with the following options:

# The filename of the certificate to use for SSL encryption of the Guacamole protocol
# If this option is specified, SSL encryption will be enabled, and the Guacamole web application
# will need to be configured within guacamole.properties to use SSL as well
#GUACD_OPTS="${GUACD_OPTS} -C CERTIFICATE"

# The filename of the private key to use for SSL encryption of the Guacamole protocol
# If this option is specified, SSL encryption will be enabled, and the Guacamole web application
# will need to be configured within guacamole.properties to use SSL as well
#GUACD_OPTS="${GUACD_OPTS} -K KEY"
