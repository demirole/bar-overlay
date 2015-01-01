# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: sys-kernel/git-sources/git-sources-3.4.97.ebuild,v 2.0 2014/12/31 13:45:34 -tclover Exp $

EAPI="5"

ETYPE="sources"
K_DEBLOB_AVAILABLE="1"

inherit kernel-git
detect_version
detect_arch

DESCRIPTION="latest linux-stable.git pulled by git from the stable tree"
HOMEPAGE="http://www.kernel.org"

KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~ppc ~ppc64 ~sh ~sparc ~x86"
IUSE="aufs bfs ck fbcondecor +gentoo hardened +optimization rt toi uksm"
REQUIRED_USE="ck? ( bfs )"

CKV="${PV}-git"
OKV="${PV}"
MKV="${KV_MAJOR}.${KV_MINOR}"

BFS_VER="424"
CK_VER="${MKV}-ck3"
GEN_VER="${MKV}-87"
FBC_VER="${GEN_VER}"
GHP_VER="${MKV}.7-1"
RT_VER="${OKV}-rt128"
RS4_VER="${MKV}"
TOI_VER="${MKV}.99-2014-07-19"
UKSM_VER="${MKV}.ge.96"

BFS_SRC="${MKV}-sched-bfs-${BFS_VER}.patch"
CK_SRC="${CK_VER}-broken-out.tar.bz2"
GEN_SRC="genpatches-${GEN_VER}.base.tar.xz"
FBC_SRC="genpatches-${FBC_VER}.extras.tar.xz"
GHP_SRC="hardened-patches-${GHP_VER}.extras.tar.bz2"
RS4_SRC="reiser4-for-${RS4_VER}.patch.gz"
RT_URI="https://www.kernel.org/pub/linux/kernel/projects/rt/${MKV}"
RT_SRC="patch-${RT_VER}.patch.xz"
TOI_SRC="tuxonice-for-linux-${TOI_VER}.patch.bz2"
UKSM_URI="http://kerneldedup.org/download/uksm/${UKSM_EXV}"
UKSM_SRC="uksm-${UKSM_EXV}-for-v${UKSM_VER}.patch"

SRC_URI="bfs? ( ${CK_URI}/${CK_VER}/${CK_SRC} )
	ck?  ( ${CK_URI}/${CK_VER}/${CK_SRC} )
	gentoo? ( ${GEN_URI}/${GEN_SRC} )
	fbcondecor? ( ${GEN_URI}/${FBC_SRC} )
	optimization? ( ${OPT_URI}/${OPT_VER}/${OPT_FILE} -> ${OPT_SRC} )
	hardened? ( ${GHP_URI}/${GHP_SRC} )
	toi? ( ${TOI_URI}/${TOI_SRC} )
	uksm? ( ${UKSM_URI}/${UKSM_SRC} )
	rt? ( ${RT_URI}/${RT_SRC} )"

K_EXTRAEINFO="This kernel is not supported by Gentoo due to its (unstable and)
experimental nature. If you have any issues, try disabling a few USE flags
that you may suspect being the source of your issues because this ebuild is
based on the latest stable tree."
