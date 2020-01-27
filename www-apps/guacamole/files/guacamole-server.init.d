#!/sbin/openrc-run
# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

PID_FILE="${EROOT}/run/${RC_SVCNAME}.pid"

name="guacamole-server daemon"
description="Guacamole Proxy Daemon"
command=/usr/sbin/guacd
command_args="-f ${GUACD_OPTS}"
command_background=true
pidfile="${PID_FILE}"
start_stop_daemon_args="--stdout ${EROOT}/tmp/guacd.stdout.log --stderr ${EROOT}/tmp/guacd.stderr.log"
command_user=guacamole
