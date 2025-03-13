// Prometheus Rules
//
// Prometheus rules file
package prometheus

import "strings"

@jsonschema(schema="http://json-schema.org/draft-07/schema#")

null | close({
	@jsonschema(id="https://json.schemastore.org/prometheus.rules.json")
	groups?: null | [...close({
		// The name of the group. Must be unique within a file.
		name!:     string
		interval?: #duration
		labels?:   #labels

		// Limit the number of alerts an alerting rule and series a
		// recording rule can produce. 0 is no limit.
		limit?: null | int
		rules?: null | [...matchN(1, [#recording_rule, #alerting_rule])]
	})]
})

#alerting_rule: close({
	// The name of the alert. Must be a valid metric name.
	alert!: string

	// The PromQL expression to evaluate. Every evaluation cycle this
	// is evaluated at the current time, and all resultant time
	// series become pending/firing alerts.
	expr!: matchN(>=1, [string, int])
	for?:             #duration
	keep_firing_for?: #duration
	labels?:          #labels
	annotations?:     #annotations
})

#annotations: null | close({
	{[=~"^[a-zA-Z_][a-zA-Z0-9_]*$"]: #tmpl_string}
})

#duration: null | =~"^((([0-9]+)y)?(([0-9]+)w)?(([0-9]+)d)?(([0-9]+)h)?(([0-9]+)m)?(([0-9]+)s)?(([0-9]+)ms)?|0)$" & strings.MinRunes(1)

#label_name: =~"^[a-zA-Z_][a-zA-Z0-9_]*$"

#label_value: string

#labels: null | close({
	{[=~"^[a-zA-Z_][a-zA-Z0-9_]*$"]: #label_value}
})

#recording_rule: close({
	// The name of the time series to output to. Must be a valid
	// metric name.
	record!: string

	// The PromQL expression to evaluate. Every evaluation cycle this
	// is evaluated at the current time, and the result recorded as a
	// new set of time series with the metric name as given by
	// 'record'.
	expr!: matchN(>=1, [string, int])
	labels?: #labels
})

// A string which is template-expanded before usage.
#tmpl_string: string
