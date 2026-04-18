.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/security/tpm/tpm_vtpm_proxy.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=================================================
Trình điều khiển proxy TPM ảo cho bộ chứa Linux
=================================================

| tác giả:
| Stefan Berger <stefanb@linux.vnet.ibm.com>

Tài liệu này mô tả Mô-đun nền tảng đáng tin cậy ảo (vTPM)
trình điều khiển thiết bị proxy cho vùng chứa Linux.

Giới thiệu
============

Mục tiêu của công việc này là cung cấp chức năng TPM cho mỗi Linux
thùng chứa. Điều này cho phép các chương trình tương tác với TPM trong vùng chứa
giống như cách chúng tương tác với TPM trên hệ thống vật lý. Mỗi
container có phần mềm mô phỏng độc đáo TPM của riêng nó.

Thiết kế
======

Để cung cấp phần mềm mô phỏng TPM cho mỗi vùng chứa, vùng chứa
ngăn xếp quản lý cần tạo một cặp thiết bị bao gồm máy khách TPM
thiết bị ký tự ZZ0000ZZ (với X=0,1,2...) và tệp 'phía máy chủ'
mô tả. Cái trước được chuyển vào vùng chứa bằng cách tạo một ký tự
thiết bị có số chính và số phụ thích hợp trong khi bộ mô tả tệp
được chuyển tới trình mô phỏng TPM. Phần mềm bên trong container sau đó có thể gửi
Các lệnh TPM sử dụng thiết bị ký tự và trình giả lập sẽ nhận được
các lệnh thông qua bộ mô tả tệp và sử dụng nó để gửi phản hồi lại.

Để hỗ trợ điều này, trình điều khiển proxy TPM ảo cung cấp thiết bị ZZ0000ZZ
được sử dụng để tạo các cặp thiết bị bằng ioctl. ioctl mất như
một cờ đầu vào để cấu hình thiết bị. Các lá cờ ví dụ chỉ ra
liệu chức năng TPM 1.2 hay TPM 2 có được trình mô phỏng TPM hỗ trợ hay không.
Kết quả của ioctl là bộ mô tả tệp cho 'phía máy chủ'
cũng như số chính và số phụ của thiết bị ký tự đã được tạo.
Ngoài ra, số của thiết bị ký tự TPM được trả về. Nếu vì
ví dụ ZZ0001ZZ đã được tạo, số (ZZ0002ZZ) 10 được trả về.

Khi thiết bị đã được tạo, trình điều khiển sẽ ngay lập tức cố gắng nói chuyện
đến TPM. Tất cả các lệnh từ trình điều khiển có thể được đọc từ bộ mô tả tập tin
được trả về bởi ioctl. Các lệnh cần được phản hồi ngay lập tức.

UAPI
====

.. kernel-doc:: include/uapi/linux/vtpm_proxy.h

.. kernel-doc:: drivers/char/tpm/tpm_vtpm_proxy.c
   :functions: vtpmx_ioc_new_dev
