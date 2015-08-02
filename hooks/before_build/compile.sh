#!/usr/bin/env bash
ln -s ${PWD}/packages www/packages
dart2js -o www/index.js www/index.dart
rm -rf www/*.deps
unlink www/packages
