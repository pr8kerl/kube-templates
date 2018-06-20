{
    repo: "kube-templates",
    name: "privatebin",
    containerPort: 80,
    image: "wonderfall/privatebin:latest",
    replicas: 1,
    servicePort: 80,
    type: "ClusterIP",
    ingress: {
    hostname: "privatebin.example.com",
      annotations+: {
        "kubernetes.io/tls-acme": "true",
      },
    },
}
