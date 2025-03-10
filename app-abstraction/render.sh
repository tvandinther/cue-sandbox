#!/usr/bin/env bash

cue export -e "yaml.MarshalStream(manifests.$1)" --out text
