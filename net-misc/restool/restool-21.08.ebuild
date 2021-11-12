# Copyright 2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit git-r3 bash-completion-r1

DESCRIPTION="DPAA2 Resource Management Tool"
HOMEPAGE="https://source.codeaurora.org/external/qoriq/qoriq-components/restool/about/"
EGIT_REPO_URI="https://source.codeaurora.org/external/qoriq/qoriq-components/restool"
EGIT_COMMIT="LSDK-${PV}"

LICENSE="|| ( BSD GPL-2+ )"
SLOT="0"
KEYWORDS="~arm64"

# man page is behind doc USE flag because we can't pull in app-text/pandoc on non-x86 arch
# because dev-lang/ghc is not supported :(
IUSE="doc"
BDEPEND="doc? ( app-text/pandoc )"

export EXTRA_CFLAGS="${CFLAGS}"

src_install() {
	dobin "${PN}"
	for f in scripts/ls-*
	do
		newbin "${f}" "$(basename "${f}")"
	done
	for f in $(grep -m1 "RESTOOL_SCRIPT_SYMLINKS" "Makefile" | egrep -o "ls-[^ ]+" | tr "\n" " ")
	do
		dosym "ls-main" "/usr/bin/$(basename "${f}")"
	done
	newbashcomp "scripts/restool_completion.sh" "${PN}"
	use doc && ( ( pandoc --standalone --to man "${PN}.md" -o "${PN}.1" && doman "${PN}.1" ) || die )
}
