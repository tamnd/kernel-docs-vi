.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/security/tpm/tpm_ffa_crb.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

==================================
TPM CRB trên Trình điều khiển FF-A
==================================

Giao diện Bộ đệm phản hồi lệnh TPM (CRB) là giao diện TPM tiêu chuẩn
được xác định trong Thông số kỹ thuật Cấu hình TPM của Nền tảng máy khách PC TCG (PTP) [1]_.
CRB cung cấp một bộ thanh ghi điều khiển có cấu trúc mà khách hàng sử dụng khi
tương tác với TPM cũng như bộ đệm dữ liệu để lưu trữ các lệnh TPM và
những phản hồi. Giao diện CRB có thể được triển khai trong:

- thanh ghi phần cứng trong chip TPM riêng biệt

- trong bộ nhớ dành cho TPM chạy trong môi trường biệt lập nơi có bộ nhớ dùng chung
  cho phép khách hàng tương tác với TPM

Firmware Framework cho Arm A-profile (FF-A) [2]_ là một thông số kỹ thuật
xác định các giao diện và giao thức cho các mục đích sau:

- Phân chia firmware thành các phân vùng phần mềm chạy trong Arm
  Môi trường thế giới an toàn (còn được gọi là TrustZone)

- Cung cấp giao diện chuẩn cho các thành phần phần mềm trong Non-secure
  trạng thái, ví dụ như HĐH và Hypervisors, để giao tiếp với phần sụn này.

TPM có thể được triển khai như một dịch vụ bảo mật FF-A.  Đây có thể là một phần sụn
TPM hoặc có thể là dịch vụ TPM hoạt động như một proxy cho một mạng rời rạc
Chip TPM. TPM dựa trên FF-A tóm tắt chi tiết phần cứng (ví dụ: bộ điều khiển bus
và chọn chip) khỏi hệ điều hành và có thể bảo vệ địa phương 4 khỏi sự truy cập
bởi một hệ điều hành.  Giao diện CRB do TCG xác định được khách hàng sử dụng để tương tác
với dịch vụ TPM.

Giao diện bộ đệm phản hồi lệnh dịch vụ Arm TPM qua FF-A [3]_
đặc điểm kỹ thuật xác định các tin nhắn FF-A có thể được khách hàng sử dụng để báo hiệu
khi các bản cập nhật được thực hiện cho CRB.

Cách trình điều khiển Linux CRB tương tác với FF-A được tóm tắt bên dưới:

- Trình điều khiển tpm_crb_ffa đăng ký với hệ thống con FF-A trong kernel
  với dịch vụ TPM có kiến trúc UUID được xác định trong thông số CRB trên FF-A.

- Nếu dịch vụ TPM được FF-A phát hiện, hàm thăm dò() trong
  Trình điều khiển tpm_crb_ffa chạy và trình điều khiển sẽ khởi chạy.

- Quá trình thăm dò và khởi tạo trình điều khiển Linux CRB được kích hoạt
  do phát hiện ra TPM được quảng cáo qua ACPI.  Trình điều khiển CRB có thể
  phát hiện loại TPM thông qua phương pháp 'bắt đầu' ACPI.  Sự khởi đầu
  phương pháp cho Arm FF-A đã được xác định trong TCG ACPI v1.4 [4]_.

- Khi trình điều khiển CRB thực hiện các chức năng bình thường như phát tín hiệu 'bắt đầu'
  và yêu cầu/từ bỏ cục bộ, nó gọi hàm tpm_crb_ffa_start()
  trong trình điều khiển tpm_crb_ffa xử lý tin nhắn FF-A tới TPM.

Tài liệu tham khảo
==========

.. [1] **TCG PC Client Platform TPM Profile (PTP) Specification**
   https://trustedcomputinggroup.org/resource/pc-client-platform-tpm-profile-ptp-specification/
.. [2] **Arm Firmware Framework for Arm A-profile (FF-A)**
   https://developer.arm.com/documentation/den0077/latest/
.. [3] **Arm TPM Service Command Response Buffer Interface Over FF-A**
   https://developer.arm.com/documentation/den0138/latest/
.. [4] **TCG ACPI Specification**
   https://trustedcomputinggroup.org/resource/tcg-acpi-specification/