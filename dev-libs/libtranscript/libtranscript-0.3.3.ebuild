# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

DESCRIPTION="A character set conversion library"
HOMEPAGE="https://os.ghalkes.nl/libtranscript.html"
SRC_URI="https://os.ghalkes.nl/dist/${P}.tar.bz2"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86 ~arm ~ppc64"
IUSE="nls +ucm2ltc doc"
RESTRICT="mirror"

DEPEND="sys-devel/libtool
		doc? ( app-doc/doxygen )"

src_configure() {
	myeconfargs=(
			$(use_with nls gettext)
			$(use_with ucm2ltc)
	)

	econf "${myeconfargs[@]}"
}

src_compile() {
	default
	use doc && { doxygen doc/doxygen.conf || die ; }
}

src_install() {
	use doc && local HTML_DOCS=( "API/." )
	default
}
