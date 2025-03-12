package platform

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

#App: #WebApp // | #OtherApp

#WebApp: {
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
