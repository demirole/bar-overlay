# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

case "${PV}" in
	(*9999*)
		KEYWORDS=""
		VCS_ECLASS=git-2
		EGIT_REPO_URI="git://gitorious.org/${PN}/${PN}.git"
		EGIT_PROJECT="${PN}.git"
		AUTOTOOLS_AUTORECONF=1
		AUTOTOOLS_IN_SOURCE_BUILD=1
		;;
	(*)
		KEYWORDS="~amd64 ~arm ~x86"
		SRC_URI="https://gitlab.com/${PN/_/-}/releases/raw/${COMMIT}/${PN/_/-}_${PV}.tar.xz -> ${P}.tar.xz"
		;;
esac
inherit autotools-utils ${VCS_ECLASS}

DESCRIPTION="intel(r) 64 and IA-32 processor microcode tool"
HOMEPAGE="https://gitlab.com/groups/iucode-tool"

LICENSE="|| ( GPL-2 GPL-3 )"
SLOT="0"
IUSE="debug"

DEPEND="debug? ( dev-util/valgrind )"
RDEPEND="${DEPEND}"
DEPEND="${DEPEND}
	app-portage/elt-patches"

DOCS=( AUTHORS README NEWS TODO )

src_configure()
{
	local -a myeconfargs=(
		${EXTRA_IUCODE_CONF}
		$(use_enable debug valgrind-build)
	)
	autotools-utils_src_configure
}
