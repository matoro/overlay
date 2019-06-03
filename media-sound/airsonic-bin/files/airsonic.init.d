#!/sbin/openrc-run
# Copyright 1999-2019 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

PID_FILE="/run/airsonic.pid"

start() {
	start-stop-daemon -u airsonic:airsonic -m -b -p "$PID_FILE" -- java \
		${JAVA_OPTS} -Dairsonic.home="${AIRSONIC_HOME}" \
		-Dserver.context-path="${CONTEXT_PATH}" \
		-Dserver.port="${PORT}" \
		-jar "${JAVA_JAR}" ${JAVA_ARGS}
}

stop() {
	start-stop-daemon --stop -p "$PID_FILE"
}
