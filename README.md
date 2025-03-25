# cray-vpa (Vertical Pod Autoscaler)

## Overview
The `cray-vpa` chart implements the VPA chart from [Fairwinds](https://github.com/FairwindsOps/charts/blob/master/stable/vpa/README.md) to install the [Kubernetes Vertical Pod Autoscaler](https://github.com/kubernetes/autoscaler/tree/master/vertical-pod-autoscaler).

There are three [components](https://github.com/kubernetes/autoscaler/blob/master/vertical-pod-autoscaler/docs/components.md) within VPA: `recommender`, `updater`, and `admission-controller`.

The `cray-vpa` chart currently deploys the `recommender` and the `updater` components, but not the `admission-controller` component.

The `recommender` will monitor the current and past resource consumption and then provides CPU and Memory request recommendations per container.

The `updater` checks which managed pods have correct resources set. If not correctly set, kills the pods so they can be recreated by their controllers with updated requests.

## Create a VSP object
Create VSP objects for the deployments that you would like recommendations on.

In this example, we are creating a VPA object for the `cray-dns-unbound` deployment. We have `updatePolicy` turned off so that the `updater` doesn't kill the pod. We only want recommendations at this time.

1. Create a yaml file of kind `VerticalPodAutoscaler`.
```bash
% cat cray-dns-unbound-vpa.yaml
apiVersion: "autoscaling.k8s.io/v1"
kind: VerticalPodAutoscaler
metadata:
  name: cray-dns-unbound-vpa
  namespace: services
spec:
  targetRef:
    apiVersion: "apps/v1"
    kind: Deployment
    name: cray-dns-unbound
  updatePolicy:
    updateMode: "Off"
```

2. Apply the yaml file
```bash
% kubectl apply -f cray-dns-unbound-vpa.yaml
verticalpodautoscaler.autoscaling.k8s.io/cray-dns-unbound-vpa created
```

## Check recommendations
The `cray-vpa-recommender` will update the VPA object with CPU and Memory recommendations for each of the containers in the deployment.

Check the recommendations using `kubectl describe vpa`.

```bash
% kubectl describe vpa -n services cray-dns-unbound-vpa
Name:         cray-dns-unbound-vpa
Namespace:    services
Labels:       <none>
Annotations:  <none>
API Version:  autoscaling.k8s.io/v1
Kind:         VerticalPodAutoscaler
Metadata:
  Creation Timestamp:  2025-03-27T13:56:33Z
  Generation:          1
  Resource Version:    15356613
  UID:                 4ad48357-2af2-4ca8-8288-c3fc8072e9c8
Spec:
  Target Ref:
    API Version:  apps/v1
    Kind:         Deployment
    Name:         cray-dns-unbound
  Update Policy:
    Update Mode:  Off
Status:
  Conditions:
    Last Transition Time:  2025-03-27T17:06:07Z
    Status:                True
    Type:                  RecommendationProvided
  Recommendation:
    Container Recommendations:
      Container Name:  cray-dns-unbound
      Lower Bound:
        Cpu:     22m
        Memory:  34952533
      Target:
        Cpu:     23m
        Memory:  34952533
      Uncapped Target:
        Cpu:     23m
        Memory:  34952533
      Upper Bound:
        Cpu:           45m
        Memory:        46538435
      Container Name:  istio-proxy
      Lower Bound:
        Cpu:     10m
        Memory:  109601131
      Target:
        Cpu:     11m
        Memory:  109814751
      Uncapped Target:
        Cpu:     11m
        Memory:  109814751
      Upper Bound:
        Cpu:           21m
        Memory:        216780788
      Container Name:  unbound-exporter
      Lower Bound:
        Cpu:     10m
        Memory:  36183224
      Target:
        Cpu:     11m
        Memory:  36253748
      Uncapped Target:
        Cpu:     11m
        Memory:  36253748
      Upper Bound:
        Cpu:     21m
        Memory:  71567034
Events:          <none>
```