#!/sbin/openrc-run
# Copyright 2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

description="Moloch Capture"
command="${EROOT}/usr/bin/moloch-capture"
command_args="${MOLOCH_CAPTURE_OPTIONS}"
pidfile="${EROOT}/run/${RC_SVCNAME}.pid"
start_stop_daemon_args="--make-pidfile --stdout ${MOLOCH_CAPTURE_STDOUT} --stderr ${MOLOCH_CAPTURE_STDERR}"
command_background=true
