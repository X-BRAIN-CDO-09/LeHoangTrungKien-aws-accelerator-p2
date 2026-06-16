# External Secrets Operator

ESO đọc secret từ external provider như AWS Secrets Manager, Parameter Store, Vault và tạo `Secret` Kubernetes.

## 3 object cần nhớ

- `SecretStore` / `ClusterSecretStore`: cách kết nối provider.
- `ExternalSecret`: mapping secret nào cần đồng bộ.
- `Secret`: object cuối cùng trong Kubernetes.

## Điều cần quan sát trong bài

- `refreshInterval`.
- Cách app đọc secret sau khi rotate.
- Khi nào cần restart app, khi nào không.

Nếu app đọc secret qua mounted volume, secret thay đổi có thể vào container mà không cần restart. Nếu app nạp env vars một lần lúc start, thường sẽ cần restart để nhận giá trị mới.
