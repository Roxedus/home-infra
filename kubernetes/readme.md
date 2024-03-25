# Notes

```sh
sudo kubeadm init --pod-network-cidr=172.16.0.0/12 --ignore-preflight-errors=SystemVerification --skip-phases=addon/kube-proxy
```

```sh
helm install cilium cilium/cilium --version 1.15.1 \
    --namespace kube-system -f kubernetes/apps/kube-system/cilium/app/helm-values.yaml
```
