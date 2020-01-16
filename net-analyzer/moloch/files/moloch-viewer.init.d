#!/sbin/openrc-run
# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

description="Moloch Viewer"
command="${EROOT}/usr/bin/node"
command_args="viewer.js ${MOLOCH_VIEWER_OPTIONS}"
pidfile="/run/${RC_SVCNAME}.pid"
start_stop_daemon_args="--make-pidfile --chdir ${EROOT}/usr/lib/moloch/viewer --stdout ${MOLOCH_VIEWER_STDOUT} --stderr ${MOLOCH_VIEWER_STDERR}"
command_background=true
