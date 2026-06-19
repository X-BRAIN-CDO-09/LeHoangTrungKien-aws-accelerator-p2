# Lab Supply Chain

Folder này chứa phần CI scan, Cosign và verify image cho lab W10.

## Nội dung

```text
supply-chain/
  ci/
    github-actions-trivy.yaml
  signing/
    cosign-commands.md
    50-kyverno-verify-signed-images.yaml
```

## Luồng cần chứng minh

```text
build image
-> Trivy scan
-> Cosign sign
-> admission verify
-> unsigned image bị reject
```

Workflow CI đầy đủ hơn nằm ở:

```text
cloud/w10/security-hardening-lab/ci/w10-build-flipkart-images.example.yml
```
