# Dockerhub

```
kubectl create secret docker-registry docker-regcred --docker-server=https://index.docker.io/v2/ --docker-username=<dockerhubusername> --docker-password=<dockerhubpassword> --docker-email=your@email.com --namespace test
```


# Metric server

https://github.com/kubernetes-sigs/metrics-server

```
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml

```