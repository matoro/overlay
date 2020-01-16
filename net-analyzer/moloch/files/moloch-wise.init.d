#!/sbin/openrc-run
# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

description="Moloch WISE"
command="${EROOT}/usr/bin/node"
command_args="wiseService.js ${MOLOCH_WISE_OPTIONS}"
pidfile="/run/${RC_SVCNAME}.pid"
start_stop_daemon_args="--make-pidfile --chdir ${EROOT}/usr/lib/moloch/wiseService --stdout ${MOLOCH_WISE_STDOUT} --stderr ${MOLOCH_WISE_STDERR}"
command_background=true
command_user="nobody:daemon"
