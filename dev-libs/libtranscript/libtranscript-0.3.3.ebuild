# Copyright 2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

DESCRIPTION="A character set conversion library"
HOMEPAGE="https://os.ghalkes.nl/libtranscript.html"
SRC_URI="https://os.ghalkes.nl/dist/${P}.tar.bz2"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86 ~arm"
IUSE="nls +ucm2ltc"
RESTRICT="mirror"

DEPEND="sys-devel/libtool"

src_configure() {
	myeconfargs=(
			$(use_with nls gettext)
			$(use_with ucm2ltc)
	)

	econf "${myeconfargs[@]}"
}
