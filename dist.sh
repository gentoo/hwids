#!/bin/sh

PV=${1:-$(date +%Y%m%d)}
P=hwids-${PV}

git tag ${P}
git archive --prefix=${P}/ ${P} | xz -9e > ${P}.tar.xz
