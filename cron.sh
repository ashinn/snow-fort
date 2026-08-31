#!/bin/sh

snow-chibi --use-curl=t update
rm -rf new-page
mkdir -p new-page/s
cd new-page || exit 1
chibi-scheme ../update.scm ../s/repo.scm ${HOME}/.snow/repo/*.scm
cd .. || exit 1
cp new-page/s/package-list.scm s/package-list.scm
cp -r new-page/s/pkg-data s/pkg-data
cp new-page/s/recent-feed.xml s/recent-feed.xml
cp new-page/s/recent-list.scm s/recent-list.scm


