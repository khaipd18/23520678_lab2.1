# 🚀 Triển Khai Hạ Tầng AWS Tự Động Hóa Với Terraform & GitHub Actions (Lab 2.1)

Dự án này triển khai hạ tầng mạng và máy chủ tính toán trên Amazon Web Services (AWS) sử dụng công cụ **Terraform**. Toàn bộ quy trình triển khai được tự động hóa hoàn toàn thông qua **GitHub Actions (CI/CD)**, kết hợp cùng **Checkov** để quét lỗ hổng bảo mật cấu hình (DevSecOps) và xác thực không mật khẩu bằng **AWS OIDC**.

---

## 🏗 1. Kiến Trúc Tổng Thể

Hạ tầng được cấp phát bao gồm:
* **VPC (Virtual Private Cloud):** Dải mạng riêng lập `10.18.0.0/16`.
* **Public Subnet:** Chứa Public EC2 (Bastion Host) và NAT Gateway, có kết nối trực tiếp Internet qua Internet Gateway (IGW).
* **Private Subnet:** Chứa Private EC2, không có Public IP, chỉ kết nối Internet một chiều qua NAT Gateway.
* **Security Groups:** Kiểm soát truy cập SSH chặt chẽ.
* **Terraform Backend:** Quản lý file trạng thái (`terraform.tfstate`) tập trung trên Amazon S3.
* **IAM OIDC Provider:** Phân quyền truy cập tạm thời và an toàn cho GitHub Actions.

---

## ⚙️ 2. Yêu Cầu & Cài Đặt Môi Trường (Prerequisites)

Để có thể chạy được mã nguồn này, bạn cần chuẩn bị môi trường AWS và GitHub như sau:

### 2.1. Chuẩn bị trên AWS
1.  **Tài khoản AWS:** Có quyền quản trị (AdministratorAccess).
2.  **Khởi tạo S3 Bucket (Backend):**
    * Tạo một bucket S3 với tên chính xác là `lab02-1-23520678` tại Region `ap-southeast-1`.
    * Mục đích: Để lưu trữ tập tin trạng thái (`.tfstate`) của Terraform.
3.  **Thiết lập OIDC Provider (Xác thực không mật khẩu):**
    * Vào **AWS IAM** > **Identity providers** > **Add provider**.
    * Chọn OpenID Connect.
    * Provider URL: `https://token.actions.githubusercontent.com`
    * Audience: `sts.amazonaws.com`
4.  **Tạo IAM Role cho GitHub Actions:** * Tạo Role thông qua code Terraform (lần chạy nội bộ đầu tiên) hoặc tạo tay với tên `github-actions-terraform-role`.
    * Cấp quyền `AdministratorAccess`.
    * Chỉnh sửa *Trust Relationship* để giới hạn chỉ cho phép Repository GitHub này truy cập.

### 2.2. Chuẩn bị trên GitHub Repository
1.  Truy cập vào kho lưu trữ chứa mã nguồn này trên GitHub.
2.  Vào **Settings** > **Secrets and variables** > **Actions**.
3.  Thêm một Secret mới:
    * **Name:** `AWS_ACCOUNT_ID`
    * **Secret:** `[Nhập 12 chữ số Account ID AWS của bạn]`

---

## 🚀 3. Cách Chạy Mã Nguồn (Tự Động Hóa)

Hệ thống đã được thiết lập CI/CD Pipeline. Bạn **không cần** cài đặt Terraform hay cấu hình AWS CLI trên máy cá nhân để triển khai hạ tầng.

**Các bước chạy mã nguồn:**

1. Clone dự án về máy:
```bash
   git clone https://github.com/khaipd18/23520678_lab2.1.git
   cd 23520678_lab2.1
```

2. Thực hiện thay đổi trên mã nguồn (Ví dụ: Thêm tài nguyên mới hoặc tinh chỉnh file `variables.tf`).

3. Đẩy (Push) mã nguồn lên nhánh `main`:
```bash
   git add .
   git commit -m "feat: deploy aws infrastructure"
   git push origin main
```

4. Ngay khi nhận được sự kiện Push, GitHub Actions sẽ tự động kích hoạt Pipeline thực hiện tuần tự:
   - **Job 1:** Quét bảo mật mã nguồn bằng Checkov.
   - **Job 2:** Khởi tạo Backend S3, lập kế hoạch (`terraform plan`) và triển khai hạ tầng thực tế (`terraform apply`).

---

## 🔍 4. Cách Kiểm Tra Kết Quả Triển Khai

Sau khi bạn đã Push code lên GitHub, hãy nghiệm thu kết quả theo các bước sau:

### 4.1. Kiểm tra trên GitHub Actions

- Vào tab **Actions** trên Repository.
- Chọn workflow **"Terraform Deploy & Checkov Scan"** mới nhất.
- Kết quả thành công khi cả 2 job `Checkov Security Scan` và `Terraform Deploy` đều hiển thị trạng thái **Success** (✅ Tích xanh).

### 4.2. Kiểm tra trên AWS Management Console

- **Dịch vụ VPC** (`ap-southeast-1`): Xác nhận có `Lab01-VPC`, các Subnet, Internet Gateway và NAT Gateway tương ứng.
- **Dịch vụ EC2**: Chuyển sang mục **Instances**, xác nhận có 2 máy chủ:
  - `Lab01-Public-EC2` (Trạng thái **Running**, có Public IP).
  - `Lab01-Private-EC2` (Trạng thái **Running**, không có Public IP).
- **Dịch vụ S3**: Mở bucket `lab02-1-23520678`, vào thư mục `lab2/` và kiểm tra sự tồn tại của tệp `terraform.tfstate`.

---

## 🧹 5. Dọn Dẹp Tài Nguyên (Clean-up)

Để tránh phát sinh chi phí sau khi kiểm tra xong, bạn có thể xóa toàn bộ hạ tầng đã tạo.

Chạy lệnh thủ công trên máy trạm (yêu cầu đã cấu hình AWS CLI):

```bash
terraform init
terraform destroy -auto-approve
```
   