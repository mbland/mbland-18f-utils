#! /bin/bash
#
# Clones multiple repositories from https://github.com/18F.
#
# New hires can copy this script and set REPOS to contain all of the 18F
# repositories in which they might be interested, to check them all out in a
# single command-line invocation.
#
# Author: Mike Bland (michael.bland@gsa.gov)
# Date:   2014-11-06
# URL:    https://github.com/mbland/mbland-18f-utils/hacks/clone-18f-repos.sh

REPOS="
  18f-slack \
  18f.github.io \
  API-All-the-X \
  DevOps \
  answers \
  api-standards \
  blog-drafts \
  code-of-conduct \
  consulting \
  css-style-guide \
  design \ 
  design-standards \
  docker-es \
  foia \
  javascript-lessons \
  microsite-18f \
  microsite-template \
  microsite-template-18f \
  open-source-policy \
  open-source-program \
  playbook \
  starter-ui \
  team-ops \
  tls-standards \
  vagrant-chef-elasticsearch \
  "

for r in $REPOS
do
  set -x
  git clone git@github.com:18F/$r
  set +x
done
