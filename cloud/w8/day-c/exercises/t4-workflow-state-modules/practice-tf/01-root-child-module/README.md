# 01 - Root Gọi Child Module EC2

## Mục tiêu

Luyện cách root module truyền input vào child module để tạo một EC2 instance tối thiểu.

## Bài Tập

Root module truyền các giá trị sau vào child module `modules/EC2`:

- `project_name`
- `environment`
- `aws_region`
- `ami_id`
- `instance_type`
- `subnet_id`
- `security_group_ids`
- `key_name` nếu cần

Child module dùng các input đó để:

- tạo `aws_instance`
- gắn tags
- trả về `instance_id`, `public_ip`, `private_ip`

## Cấu Trúc File

```text
01-root-child-module/
  versions.tf
  provider.tf
  variables.tf
  terraform.tfvars
  main.tf
  outputs.tf
  modules/
    EC2/
      variables.tf
      locals.tf
      main.tf
      outputs.tf
```

## Cách Đọc Luồng

`terraform.tfvars` đưa giá trị vào root `variables.tf`. Root `main.tf` gọi `module "ec2"`, rồi truyền `var.*` vào module input. Child module tính thêm `local.name_prefix`, tạo `aws_instance.this`, sau đó xuất `instance_id`, `public_ip`, `private_ip`. Root `outputs.tf` đọc lại các giá trị đó qua `module.ec2.<output_name>`.

## Chạy

```bash
terraform fmt
terraform init
terraform validate
terraform plan
```

## Ghi Nhớ

- Root module không tạo resource trực tiếp trong bài này.
- Child module mới là nơi viết `aws_instance`.
- Input thật đi từ `terraform.tfvars`, không viết cứng vào resource.
