package main

import (
	"cue.example/prometheus"
	kcore "github.com/cue-tmp/jsonschema-pub/exp3/k8s.io/api/core/v1"
	"encoding/yaml"
)

_rules: prometheus
_rules: groups: [{
	name: "node"
	rules: [{
		alert: "Unresponsive node"
		expr:  "k8s_node_condition_ready == 0"
		for:   "5m"
		annotations: {
			title:       "Node not ready"
			summary:     "The node *{{ $labels.k8s_node_name }}* on *{{ $labels.cluster }}* has not been ready for at least 5 minutes."
			description: "Check the status and events on the node to diagnose the issue."
		}
	}]
}]

kcore.#ConfigMap & {
	apiVersion: "v1"
	kind:       "ConfigMap"
	metadata: name:         "prometheus-rules"
	data: "prometheus.yml": yaml.Marshal(_rules)
}
