# Demo App

Static UI demo app for the `K8s on AWS - Terraform 1-Click` lab.

## Run Locally

Open `index.html` in a browser.

## Build Container

```bash
docker build -t k8s-demo-app:local .
docker run --rm -p 8080:80 k8s-demo-app:local
```

Then open:

```text
http://localhost:8080
```
