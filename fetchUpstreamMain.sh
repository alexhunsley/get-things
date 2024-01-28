#!/bin/zsh

export BRANCH=main

git fetch upstream; git rebase upstream/${BRANCH}
