# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id: dev-util/edi/edi-9999.ebuild,v 1.1 2017/10/02 12:02:10 Exp $

EAPI=5

case "${PV}" in
	(*9999*)
	KEYWORDS=""
	VCS_ECLASS=git-2
	EGIT_REPO_URI="git://git.enlightenment.org/tools/${PN}.git"
	EGIT_PROJECT="${PN}.git"
	;;
	(*)
	KEYWORDS="~amd64 ~arm ~x86"
	SRC_URI="https://github.com/ajwillia-ms/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"
	;;
esac
inherit autotools-utils ${VCS_ECLASS}

DESCRIPTION="EFL based IDE"
HOMEPAGE="https://www.enlightenment.org/about-edi"

IUSE="clang doc test"
LICENSE="GPL-2 LGPL-2.1"
SLOT="0"

RDEPEND=">=dev-libs/efl-1.20.0"
DEPEND="${RDEPEND}
	app-portage/elt-patches
	doc? ( app-doc/doxygen )
	clang? ( sys-devel/clang )
	virtual/libintl"

DOCS=( AUTHORS ChangeLog NEWS README TODO )
AUTOTOOLS_AUTORECONF=1

src_configure()
{
	local -a myeconfargs=(
		${EXTRA_EFLETE_CONF}
		--with-tests=$(usex test regular coverage)
		$(use_enable clang libclang)
	)
	autotools-utils_src_configure
}
