package app

import (
    "struct"
)

#ConstrainedString: string
#Port: int & >0 & <=65535

#Deployment: {
    preview: #App
    preprod: #App
    prod: #App

    let deploymentTargets = {
        "preview": preview
        "preprod": preprod
        "prod": prod
    }

    for deploymentTargetName, appDefinition in deploymentTargets {
        let ingress = {
            kind: "Ingress"
            metadata: name: appDefinition.name
            spec: hostname: appDefinition.hostname
        }
        let service = {
            kind: "Service"
            metadata: name: appDefinition.name
            spec: port: appDefinition.port
        },
        let deployment = {
            kind: "Deployment"
            metadata: name: appDefinition.name
            spec: container: env: appDefinition.env
        }
        
        manifests: (deploymentTargetName): [ingress, service, deployment]
    }
}

#AppManifests: {
    "ingress": {}
    "service": {}
    "deployment": {}
}

#App: {
    name: #ConstrainedString
    image: {
        registry: string
        name: string
        tag: string
    }
    port: [PortName=#ConstrainedString]: #Port
    env: [EnvName=string]: string
    hostname: string
    healthCheck: {
        path: string | *"/healthz"
        port: #Port
    }
    scaling: {
        minReplicas: 3
        maxReplicas: 999
        cpuUtilizationThreshold: float & >=0.1 & <=0.95
    }
}

#App: port: struct.MinFields(1)

#Deployment: preview: hostname: =~ "example-dev.com$"

app: #Deployment & {
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
