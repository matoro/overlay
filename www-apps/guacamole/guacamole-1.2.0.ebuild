# Copyright 2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit user

DESCRIPTION="A clientless HTML5 remote desktop gateway"
HOMEPAGE="https://guacamole.apache.org http://guacamole.sourceforge.net"
SRC_URI="https://apache.org/dyn/closer.cgi?action=download&filename=guacamole/${PV}/source/${PN}-server-${PV}.tar.gz
		https://apache.org/dyn/closer.cgi?action=download&filename=guacamole/${PV}/source/${PN}-client-${PV}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86 ~arm"
IUSE="vnc rdp ssh telnet guacenc pulseaudio vorbis webp ssl static-libs doc kubernetes"
RESTRICT="mirror network-sandbox"
REQUIRED_USE="pulseaudio? ( vnc ) ssh? ( ssl ) kubernetes? ( ssl )"
S="${WORKDIR}"

RDEPEND="x11-libs/cairo
		virtual/jpeg
		media-libs/libpng
		dev-libs/ossp-uuid
		ssl? ( dev-libs/openssl )
		vnc? ( net-libs/libvncserver )
		rdp? ( net-misc/freerdp:0/2 )
		ssh? ( net-libs/libssh2
				x11-libs/pango
		)
		telnet? ( net-libs/libtelnet
					x11-libs/pango
		)
		guacenc? ( virtual/ffmpeg )
		vorbis? ( media-libs/libvorbis )
		webp? ( media-libs/libwebp )
		kubernetes? ( net-libs/libwebsockets
						x11-libs/pango
		)"
DEPEND="${RDEPEND}
		dev-java/maven-bin
		doc? ( app-doc/doxygen )"

pkg_setup() {
	enewgroup "${PN}"
	enewuser "${PN}" -1 -1 "${EROOT}/var/lib/${PN}" "${PN}"
}

src_configure() {
	# server
	pushd "${PN}-server-${PV}"
	TERM_PROTO="without"
	if use ssh || use telnet || use kubernetes
	then
		TERM_PROTO="with"
	fi
	econf \
		$(use_enable guacenc) \
		--enable-guacd \
		--enable-guaclog \
		$(use_enable static-libs static) \
		$(use_with ssl) \
		--without-winsock \
		$(use_with pulseaudio pulse) \
		"--${TERM_PROTO}-pango" \
		"--${TERM_PROTO}-terminal" \
		$(use_with vnc) \
		$(use_with rdp) \
		$(use_with ssh) \
		$(use_with telnet) \
		$(use_with vorbis) \
		$(use_with webp) \
		$(use_with kubernetes websockets)
	popd
}

src_compile() {
	# server
	pushd "${PN}-server-${PV}"
	default
	use doc && { doxygen doc/Doxyfile || die ; }
	popd

	# client
	pushd "${PN}-client-${PV}"
	# javadoc is broken on java 11 & 12
	# https://bugs.java.com/bugdatabase/view_bug.do?bug_id=8212233
	mvn -Dmaven.javadoc.skip=true package || die
	popd
}

src_install() {
	dodir "${EROOT}/var/lib/${PN}"
	keepdir "${EROOT}/var/lib/${PN}"
	fowners "${PN}:${PN}" "${EROOT}/var/lib/${PN}"
	fperms 0700 "${EROOT}/var/lib/${PN}"

	# server
	pushd "${PN}-server-${PV}"
	default
	keepdir /etc/guacamole
	keepdir /etc/guacamole/extensions
	keepdir /etc/guacamole/lib
	newconfd "${FILESDIR}/${PN}-server.conf.d" "${PN}-server"
	newinitd "${FILESDIR}/${PN}-server.init.d" "${PN}-server"
	popd

	# client
	pushd "${PN}-client-${PV}"
	dosym "${P}.war" "${EROOT}/opt/${PN}/${PN}.war"
	dodir "${EROOT}/opt/${PN}"
	insinto "${EROOT}/opt/${PN}"
	doins "guacamole/target/${P}.war"
	popd
}

pkg_postinst() {
	einfo "Guacamole does not include default config files."
	einfo "To configure it, you will need to manually create your config"
	einfo "files in the empty directory ${EROOT}/etc/${PN}"
	einfo
	einfo "The webapp is deployed in ${EROOT}/opt/${PN}"
	einfo "You can easily deploy it to a Tomcat instance by symlinking like so:"
	einfo "ln -sv ${EROOT}/opt/${PN}/${PN}.war \${CATALINA_HOME}/webapps/"
}
