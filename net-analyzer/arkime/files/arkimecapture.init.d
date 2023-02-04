#!/sbin/openrc-run
# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

function nodename() {
    [[ "${RC_SVCNAME#*.}" == "arkimecapture" ]] && echo "default" && return
    echo "${RC_SVCNAME#*.}"
}

function nodeargs() {
    local name="$(nodename)"
    [[ "${name}" == "default" ]] && return
    echo "-n ${name}"
}

description="Arkime Capture"
command="${EPREFIX}/usr/lib/arkime/bin/capture"
command_args="-c \"${EPREFIX}/usr/lib/arkime/etc/config.ini\" $(nodeargs) ${OPTIONS}"
pidfile="${EROOT}/run/${RC_SVCNAME}.pid"
command_background=yes
directory="${EPREFIX}/usr/lib/arkime"

depend() {
    local interface="$(grep -Pzo "\[$(nodename)\](.*\n)*" /etc/arkime/config.ini | grep -Paio "(?<=^interface=).+" | head -n 1)"
    need "net.${interface}"
}

start_pre() {
    ebegin "Preparing interfaces for sniffing"
    "${EPREFIX}/usr/lib/arkime/bin/arkime_config_interfaces.sh" -c "${EPREFIX}/usr/lib/arkime/etc/config.ini" $(nodeargs)
    eend "${?}"
}
