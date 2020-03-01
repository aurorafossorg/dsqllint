#!/usr/bin/env bash

if [ ! -d .reggae/ ]; then
	dub run reggae -- -b ninja --per_module --dc ldmd2
fi

ninja
