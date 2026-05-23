# 23520678_lab1
## 🏗 Kiến Trúc Tổng Thể

Hạ tầng được triển khai bao gồm một VPC chính với hai lớp mạng riêng biệt:
*   **Public Subnet:** Kết nối Internet thông qua Internet Gateway (IGW). Chứa Public EC2 (đóng vai trò như một Bastion Host).
*   **Private Subnet:** Không có Public IP, chỉ kết nối ra Internet một chiều thông qua NAT Gateway. Chứa Private EC2.


---

## 📂 Cấu Trúc Thư Mục

Dự án được phân tách thành ba module độc lập và được điều phối bởi các tệp cấu hình tại thư mục gốc:

```text
.
├── main.tf                # Điều phối, gọi các module và truyền tham số
├── variables.tf           # Chứa các biến môi trường (Region, CIDR, Key Pair...)
├── modules/
│   ├── vpc/               # Chứa cấu hình VPC, Subnets, IGW, NAT Gateway, Route Tables
│   ├── sg/                # Chứa cấu hình Security Groups (Public & Private)
│   └── ec2/               # Chứa cấu hình khởi tạo các EC2 Instances (AMI Amazon Linux 2)
```


## 🧩 Chi Tiết Các Module

### 1. Module VPC (`modules/vpc`)
*   **VPC & Subnets:** Một VPC được khởi tạo làm môi trường chứa toàn bộ tài nguyên. Bên trong VPC, hai subnet được phân chia: Public Subnet (cho phép cấp phát Public IP tự động) và Private Subnet (chỉ sử dụng địa chỉ IP nội bộ).
*   **Gateways:**
    *   `Internet Gateway (IGW)`: Được gắn vào VPC để cung cấp kết nối Internet cho Public Subnet.
    *   `NAT Gateway`: Được triển khai tại Public Subnet và được cấp phát một Elastic IP tĩnh. Cơ chế này cho phép các tài nguyên trong Private Subnet khởi tạo kết nối ra ngoài Internet mà không để lộ địa chỉ IP nội bộ.
*   **Route Tables:** Bảng định tuyến được cấu hình riêng cho từng subnet — traffic từ Public Subnet được dẫn qua IGW, trong khi traffic từ Private Subnet được định tuyến qua NAT Gateway.

### 2. Module Security Groups (`modules/sg`)
*   **Public Security Group:** Cổng 22 (SSH) được mở có chọn lọc — chỉ cho phép kết nối từ địa chỉ IP xác định của máy thực hành.
    > **Lưu ý:** Đây là biện pháp bảo mật nhằm hạn chế Attack Surface. Tuy nhiên, nếu môi trường mạng sử dụng IP động (như KTX, Wifi công cộng), cần cập nhật lại Rule này mỗi khi IP nguồn thay đổi để tránh lỗi *Connection Timed Out*. Ở đây sẽ mở `0.0.0.0/0` chỉ với mục đích test.
*   **Private Security Group:** Được cấu hình chặt chẽ hơn — chỉ chấp nhận kết nối SSH từ nguồn là chính Public Security Group, loại bỏ hoàn toàn khả năng truy cập trực tiếp từ bên ngoài.

### 3. Module EC2 (`modules/ec2`)
*   Sử dụng **Amazon Machine Image (AMI) Amazon Linux 2** phiên bản mới nhất cho cả hai máy ảo.
*   **Public EC2:** Được đặt trong Public Subnet, có địa chỉ IP công cộng để phục vụ kết nối SSH từ máy thực hành.
*   **Private EC2:** Được đặt trong Private Subnet, không được cấp Public IP. Mọi kết nối vào máy này đều phải thực hiện gián tiếp thông qua Public EC2.

---

## 🚀 Hướng Dẫn Triển Khai

**Yêu cầu hệ thống:**
*   Đã cài đặt [Terraform](https://developer.hashicorp.com/terraform/downloads).
*   Đã cấu hình AWS CLI với quyền truy cập (Access Key/Secret Key).
*   Đã tạo sẵn Key Pair trên AWS hoặc tạo cục bộ.

**Các bước thực hiện:**
1. Clone repository này về máy.
2. Cập nhật các thông số (tên Key Pair, AWS Region, dải địa chỉ IP...) trong tệp `variables.tf`.
3. Khởi tạo Terraform:
   ```bash
   terraform init
   ```
4. Kiểm tra kế hoạch triển khai:
    ```bash
    terraform plan
    ```
5. Áp dụng triển khai tài nguyên:
    ```bash
    terraform apply -auto-approve
    ```

 ---   

## 🧪 Kết Quả Kiểm Thử (Test Cases)

### 🔹 Test Case 1: Kiểm tra kết nối SSH vào Public EC2
*   **Phương pháp:** Sử dụng tệp khóa `.pem` kết hợp với địa chỉ IP công cộng để thực hiện SSH từ máy thực hành.
*   **Kết quả:** 
    *   ✅ Kết nối thành công với tư cách người dùng `ec2-user`.
    

---

### 🔹 Test Case 2: Kiểm tra kết nối Internet qua Internet Gateway
*   **Phương pháp:** Từ phiên SSH trên Public EC2, thực thi lệnh `ping 8.8.8.8`.
*   **Kết quả:** 
    *   ✅ Các gói tin được truyền và nhận thành công. Xác nhận Public Subnet có khả năng truy cập Internet thông qua IGW.

---

### 🔹 Test Case 3: Kiểm tra cơ chế kiểm soát truy cập của Private SG
*   **Phương pháp:** Từ phiên SSH trên Public EC2, sử dụng Agent Forwarding hoặc chuyển tệp khóa để SSH tiếp vào địa chỉ IP nội bộ của Private EC2 (ví dụ: `10.18.2.x`).
*   **Kết quả:**
    *   ✅ **Luồng hợp lệ:** Kết nối từ Public EC2 sang Private EC2 thành công.
    *   ⛔ **Luồng bị chặn:** Kết nối SSH trực tiếp từ máy thực hành đến Private EC2 bị từ chối *(Timeout)*. Xác nhận Private Security Group hoạt động đúng thiết kế (chỉ nhận traffic nội bộ) và máy tính không thể bị truy cập trực tiếp do không có Public IP.
    

---

### 🔹 Test Case 4: Kiểm tra kết nối Internet qua NAT Gateway
*   **Phương pháp:** Từ phiên SSH trên Private EC2, thực thi lệnh `ping 8.8.8.8` hoặc `sudo yum update`.
*   **Kết quả:** 
    *   ✅ Lệnh thực thi thành công. Máy có thể tải về các bản cập nhật và kết nối ra ngoài Internet bình thường dù không được cấp Public IP. Điều này xác nhận cơ chế định tuyến qua NAT Gateway hoạt động hoàn hảo.
    