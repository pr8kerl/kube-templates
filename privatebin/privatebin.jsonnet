
local k = import "ksonnet.beta.2/k.libsonnet";
local params = import 'params.libsonnet';
local deployment = k.apps.v1beta1.deployment;
local container = k.apps.v1beta1.deployment.mixin.spec.template.spec.containersType;
local containerPort = container.portsType;
local service = k.core.v1.service;
local servicePort = k.core.v1.service.mixin.spec.portsType;
local ingress = k.extensions.v1beta1.ingress;
local annotations = k.extensions.v1beta1.ingress.mixin.metadata.annotations.new(params.ingress.annotations);

local labels = {
  app: params.name,
  repo: params.repo,
};

local appService = service.new(
    params.name,
    labels,
    servicePort.new(params.servicePort, params.containerPort));

local appContainer = 
    container.new(params.name, params.image) +
    container.ports(containerPort.containerPort(params.containerPort));

local appDeployment = deployment.new(
    params.name,
    params.replicas,
    appContainer,
    labels);

local ingressRule = {
  host: params.ingress.hostname,
  http: {
    paths: [
      {
        backend: {
          serviceName: params.name + "-svc",
          servicePort: params.servicePort,
        },
        path: "/",
      },
    ],
  },
};

local appIngress = ingress.new() + {
  metadata+: {
    name: params.name,
    labels+: labels,
    annotations+: params.ingress.annotations,
  },
  spec+:{
    rules:[ ingressRule ]
  },

};

k.core.v1.list.new([appService, appDeployment, appIngress])