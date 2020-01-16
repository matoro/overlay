# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

DESCRIPTION="A syntax highlighting library"
HOMEPAGE="https://os.ghalkes.nl/t3/libt3highlight.html"
SRC_URI="https://os.ghalkes.nl/dist/${P}.tar.bz2"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86 ~arm"
IUSE="nls doc"
RESTRICT="mirror"

RDEPEND=">=dev-libs/libt3config-0.2.5
		dev-libs/libpcre2"
DEPEND="sys-devel/libtool
		virtual/pkgconfig
		doc? ( app-doc/doxygen )"

src_configure() {
	local myeconfargs=(
				$(use_with nls gettext)
	)

	econf "${myeconfargs[@]}"
}

src_compile() {
	default
	use doc && doxygen doc/doxygen.conf || die
}

src_install() {
	use doc && local HTML_DOCS=( "API/." )
	default
}
