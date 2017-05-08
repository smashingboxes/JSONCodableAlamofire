#!/usr/bin/env sh

if ! command -v carthage > /dev/null; then
  echo 'Carthage is not installed.'
  echo 'See https://github.com/Carthage/Carthage for install instructions.'
  exit 1
fi

carthage update --no-use-binaries --no-build
