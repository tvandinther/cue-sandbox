#!/usr/bin/env bash

cue eval app.cue -c -e "yaml.MarshalStream(app.manifests.$1)" --out text
