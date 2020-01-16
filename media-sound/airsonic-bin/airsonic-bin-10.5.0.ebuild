# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit user

DESCRIPTION="Airsonic, a Free and Open Source community driven media server"
HOMEPAGE="https://airsonic.github.io"
SRC_URI="https://github.com/airsonic/airsonic/releases/download/v${PV}/airsonic.war -> airsonic-${PV}.war"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~x86 ~amd64 ~arm"
RESTRICT="mirror"

RDEPEND=">=virtual/jre-1.8"
S="${WORKDIR}"

pkg_setup() {
	enewgroup airsonic
	enewuser airsonic -1 -1 "/opt/airsonic" airsonic
}

src_unpack() {
	cp -v "${DISTDIR}/airsonic-${PV}.war" "${S}/"
}

src_prepare() {
	default
}

src_install() {
	dosym "airsonic-${PV}.war" "${EROOT}/opt/airsonic/airsonic.war"
	dodir "${EROOT}/opt/airsonic"
	insinto "${EROOT}/opt/airsonic"
	doins "airsonic-${PV}.war"

	fowners -R airsonic:airsonic "${EROOT}/opt/airsonic"

	newconfd "${FILESDIR}/airsonic.confd" "airsonic"
	newinitd "${FILESDIR}/airsonic.init.d" "airsonic"
}
