#!/sbin/openrc-run
# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

pidfile="${RC_PREFIX%/}/run/${SVCNAME}.pid"
cfgfile="${RC_PREFIX%/}/etc/${SVCNAME}/homeserver.yaml"

depend() {
	need net
}

start() {
	ebegin "Starting Synapse server"
	start-stop-daemon --start --user synapse --group synapse --pidfile "${pidfile}" \
		--exec /usr/bin/python --background --make-pidfile \
		-- -m synapse.app.homeserver --config-path="${cfgfile}" \
		--report-stats=no ${SYNAPSE_OPTS}
}
