#!/sbin/openrc-run
# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

description="Moloch Parliament"
command="${EROOT}/usr/bin/node"
command_args="parliament.js ${MOLOCH_PARLIAMENT_OPTIONS}"
pidfile="/run/${RC_SVCNAME}.pid"
start_stop_daemon_args="--make-pidfile --chdir ${EROOT}/usr/lib/moloch/parliament --stdout ${MOLOCH_PARLIAMENT_STDOUT} --stderr ${MOLOCH_PARLIAMENT_STDERR}"
command_background=true
