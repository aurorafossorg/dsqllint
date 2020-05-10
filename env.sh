#!/usr/bin/env bash

## prepare
function p() { dub fetch reggae && dub run reggae -- -b ninja --per_module --dc ldmd2 }
## build
function b() { ninja; }
## run
function r() { ./dsqllint $@ }
