# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: dev-libs/sord/sord-0.12.0.ebuild,v 1.4 2015/06/01 10:12:33 Exp $

EAPI=5
PYTHON_COMPAT=( python{2_7,3_{3,4,5}} )
PYTHON_REQ_USE='threads(+)'

case "${PV}" in
	(9999*)
	KEYWORDS=""
	VCS_ECLASS=subversion
	ESVN_REPO_URI="http://svn.drobilla.net/${PN}/trunk/"
	ESVN_PROJECT="${PN}"
	;;
	(*)
	KEYWORDS="~amd64 ~ppc ~x86"
	SRC_URI="http://download.drobilla.net/${P}.tar.bz2"
	;;
esac
inherit python-any-r1 waf-utils multilib-minimal ${VCS_ECLASS}

DESCRIPTION="Library for storing RDF data in memory"
HOMEPAGE="http://drobilla.net/software/sord/"

LICENSE="ISC"
SLOT="0"
KEYWORDS="~amd64 ~ppc ~x86"
IUSE="doc static static-libs test +utils"
REQUIRED_USE=" static? ( utils )"

RDEPEND=">=dev-libs/serd-0.14.0[${MULTILIB_USEDEP}]"
DEPEND="${RDEPEND}
	${PYTHON_DEPS}
	doc? ( app-doc/doxygen )
	virtual/pkgconfig"

DOCS=( AUTHORS NEWS README )

src_prepare()
{
	sed -i -e 's/^.*run_ldconfig/#\0/' wscript || die
	epatch_user
	multilib_copy_sources
}

multilib_src_configure()
{
	local -a mywafargs=(
		"--docdir=${EPREFIX}/usr/share/doc/${PF}"
		$(use doc && echo '--docs')
		$(use static && echo '--static-progs')
		$(use static-libs && echo '--static')
		$(use test && echo '--test')
		$(use utils || echo '--no-utils')
	)
	WAF_BINARY="${BUILD_DIR}"/waf waf-utils_src_configure "${mywafargs[@]}"
}

multilib_src_compile()
{
	WAF_BINARY="${BUILD_DIR}"/waf waf-utils_src_compile
}

multilib_src_install()
{
	WAF_BINARY="${BUILD_DIR}"/waf waf-utils_src_install
}

multilib_src_test()
{
	./waf test || die
}

