#!/sbin/openrc-run
# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

description="Arkime Parliament"
command="${EPREFIX}/usr/lib/arkime/bin/node"
command_args="parliament.js -c \"${EPREFIX}/usr/lib/arkime/etc/parliament.json\" ${OPTIONS}"
pidfile="${EROOT}/run/${RC_SVCNAME}.pid"
command_background=yes
directory="${EPREFIX}/usr/lib/arkime/parliament"
