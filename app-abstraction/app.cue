package app

#Deployment & {
    let base = #App & {
        AppName=name: "test-app"
        image: {
            registry: "my-registry.com"
            name: AppName
        }
        AppPort=port: http: 8080
        env: {
            "FOO": "1"
        }
        hostname: string | *"test-app.example.com"
        healthCheck: port: AppPort.http
        scaling: cpuUtilizationThreshold: 0.7
    }

    preview: base & {
        image: tag: "v3"
        hostname: "test-app.example-dev.com"
        env: DEBUG: "true"
    }
    preprod: base & {
        image: tag: "v2"
    }
    prod: base & {
        image: tag: "v1"
    }
}
