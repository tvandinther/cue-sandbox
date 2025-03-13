# Prometheus Alerts

This sandbox shows how CUE can help to define Prometheus alerts.

## Steps
1. Run `cue mod init`.
1. Download the JSON Schema from [GitHub](https://raw.githubusercontent.com/SchemaStore/schemastore/refs/heads/master/src/schemas/json/prometheus.rules.json).
1. Move the JSON Schema into a new directory named `prometheus`.
1. Run `cue import prometheus/prometheus.rules.json -p prometheus`
1. Create `main.cue` and `import "cue.example/prometheus"` and define your rules by starting with the `prometheus` definition.

1. Get the k8s module with `cue mod get github.com/cue-tmp/jsonschema-pub/exp3/k8s.io`.
1. `import kcore "github.com/cue-tmp/jsonschema-pub/exp3/k8s.io/api/core/v1"` and create a ConfigMap using the `kcore.#ConfigMap` definition.
1. `import "encoding/yaml"` and place your rules as a YAML string into the config map's `data` field using `yaml.Marshal()`.
1. Run `cue export --out yaml` to generate YAML output of `main.cue`.
1. Run `cue fmt` to format your code.
