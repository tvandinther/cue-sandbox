#App: {
	spec: {
		image: name: string
		image: tag:  string
		port:     int & >0 & <=65535
		hostname: string
	}

    let appSpec = spec

	kubernetesManifests: [
		{
			kind: "Ingress"
			spec: hostname: appSpec.hostname
		},
		{
			kind: "Service"
			spec: port: appSpec.port
		},
		{
			kind: "Deployment"
			spec: image: appSpec.image
		},
	]
}

app: #App
app: spec: {
	image: {
		name: "my-app"
		tag:  "v1"
	}
	port:     8080
	hostname: "myapp.example.com"
}
