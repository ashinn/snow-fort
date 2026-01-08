#!/bin/sh

snow-chibi --use-curl=t update
chibi-scheme update.scm s/repo.scm ${HOME}/.snow/repo/*.scm
