#!/sbin/openrc-run
# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

description="Arkime Cont3xt"
command="${EPREFIX}/usr/lib/arkime/bin/node"
command_args="cont3xt.js -c \"${EPREFIX}/usr/lib/arkime/etc/cont3xt.ini\" ${OPTIONS}"
pidfile="${EROOT}/run/${RC_SVCNAME}.pid"
command_background=yes
directory="${EPREFIX}/usr/lib/arkime/cont3xt"
