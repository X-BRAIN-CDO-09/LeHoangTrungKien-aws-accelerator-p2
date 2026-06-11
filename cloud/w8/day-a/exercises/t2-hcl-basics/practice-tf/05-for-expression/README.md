# 05 - For Expression

## Mục tiêu

Luyện dùng `for` expression để tạo list/map mới.

## Đề bài

Trong `variables.tf`, khai báo:

- `project_name`: string.
- `environment`: string.
- `services`: list(string).

Trong `locals.tf`, tạo:

- `service_names`: list tên service theo format `<project>-<env>-<service>`.
- `service_map`: map service gốc sang service name đầy đủ.

Ví dụ nếu input là:

```hcl
project_name = "xbrain"
environment  = "dev"
services     = ["api", "worker", "web"]
```

thì `service_names` là một list mới:

```hcl
[
  "xbrain-dev-api",
  "xbrain-dev-worker",
  "xbrain-dev-web"
]
```

Nói cách khác, `service_names` chỉ giữ danh sách tên đầy đủ sau khi ghép project, environment và từng service.

Còn `service_map` là map giữ cả tên gốc và tên đầy đủ:

```hcl
{
  api    = "xbrain-dev-api"
  worker = "xbrain-dev-worker"
  web    = "xbrain-dev-web"
}
```

Map này hữu ích khi vẫn muốn tra cứu theo tên service gốc. Ví dụ dùng key `api` để lấy ra `"xbrain-dev-api"`.

Trong `outputs.tf`, output `service_names` và `service_map`.

## Yêu cầu

- Dùng `for` expression.
- Không viết thủ công từng service trong output.
