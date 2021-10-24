# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

DESCRIPTION="A C++ terminal dialog toolkit"
HOMEPAGE="https://os.ghalkes.nl/t3/libt3widget.html"
SRC_URI="https://os.ghalkes.nl/dist/${P}.tar.bz2"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86 ~arm ~ppc64"
IUSE="X gpm nls doc"
RESTRICT="mirror"

RDEPEND=">=dev-libs/libtranscript-0.2.2
		>=dev-libs/libt3key-0.2.0
		>=dev-libs/libt3window-0.4.0
		dev-libs/libunistring
		dev-libs/libsigc++
		dev-libs/libpcre2
		gpm? ( sys-libs/gpm )
		X? ( x11-libs/libxcb )"
DEPEND="sys-devel/libtool
		doc? ( app-doc/doxygen )"

src_configure() {
	local myeconfargs=(
		$(use_with gpm)
		$(use_with X x11)
		$(use_with nls gettext)
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
