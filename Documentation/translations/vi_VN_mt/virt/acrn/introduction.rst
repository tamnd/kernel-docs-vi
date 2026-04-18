.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/virt/acrn/introduction.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

Giới thiệu về Trình ảo hóa ACRN
============================

ACRN Hypervisor là trình ảo hóa loại 1, chạy trực tiếp trên kim loại trần
phần cứng. Nó có một VM quản lý đặc quyền, được gọi là Service VM, để quản lý Người dùng
VM và thực hiện mô phỏng I/O.

Không gian người dùng ACRN là một ứng dụng chạy trong Service VM mô phỏng
thiết bị cho VM người dùng dựa trên cấu hình dòng lệnh. Trình giám sát ACRN
Mô-đun dịch vụ (HSM) là mô-đun hạt nhân trong VM dịch vụ cung cấp
dịch vụ ảo hóa cho không gian người dùng ACRN.

Hình dưới đây cho thấy kiến ​​trúc.

::

VM dịch vụ VM người dùng
      +-----------------------------+ |  +-------------------+
      ZZ0000ZZ ZZ0001ZZ |
      ZZ0002ZZACRN không gian người dùng|    | ZZ0004ZZ |
      ZZ0005ZZ ZZ0006ZZ |
      ZZ0007ZZ ZZ0008ZZ |   ...
      ZZ0009ZZ ZZ0010ZZ |
      Trình điều khiển ZZ0011ZZ HSM ZZ0012ZZ ZZ0013ZZ |
      ZZ0014ZZ ZZ0015ZZ |
      +-------------------ZZ0016ZZ +-------------------+
  +----------------------hypercall----------------------------------------+
  ZZ0017ZZ
  +-----------------------------------------------------------------------------------+
  ZZ0018ZZ
  +-----------------------------------------------------------------------------------+

Không gian người dùng ACRN phân bổ bộ nhớ cho VM người dùng, định cấu hình và khởi tạo
các thiết bị được sử dụng bởi VM người dùng, tải bộ tải khởi động ảo, khởi tạo
trạng thái CPU ảo và xử lý các truy cập yêu cầu I/O từ VM người dùng. Nó sử dụng
ioctls để liên lạc với HSM. HSM triển khai các dịch vụ ảo hóa bằng cách
tương tác với ACRN Hypervisor thông qua hypercall. HSM xuất thiết bị char
giao diện (/dev/acrn_hsm) tới không gian người dùng.

Trình ảo hóa ACRN sẵn sàng đón nhận sự đóng góp của bất kỳ ai. Repo nguồn là
có sẵn tại ZZ0000ZZ