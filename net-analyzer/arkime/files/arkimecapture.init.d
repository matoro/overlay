#!/sbin/openrc-run
# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

function nodeargs() {
    [[ "${RC_SVCNAME#*.}" == "arkimecapture" ]] && return
    echo "-n ${RC_SVCNAME#*.}"
}

description="Arkime Capture"
command="${EPREFIX}/usr/lib/arkime/bin/capture"
command_args="-c \"${EPREFIX}/usr/lib/arkime/etc/config.ini\" $(nodeargs) ${OPTIONS}"
pidfile="${EROOT}/run/${RC_SVCNAME}.pid"
command_background=yes
directory="${EPREFIX}/usr/lib/arkime"

start_pre() {
    ebegin "Preparing interfaces for sniffing"
    "${EPREFIX}/usr/lib/arkime/bin/arkime_config_interfaces.sh" -c "${EPREFIX}/usr/lib/arkime/etc/config.ini" $(nodeargs)
    eend "${?}"
}
