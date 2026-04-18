.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/virt/kvm/devices/mpic.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

===========================
Bộ điều khiển ngắt MPIC
=========================

Các loại thiết bị được hỗ trợ:

- KVM_DEV_TYPE_FSL_MPIC_20 Freescale MPIC v2.0
  - KVM_DEV_TYPE_FSL_MPIC_42 Freescale MPIC v4.2

Chỉ một phiên bản MPIC, thuộc bất kỳ loại nào, có thể được khởi tạo.  Đã tạo
MPIC sẽ đóng vai trò là bộ điều khiển ngắt hệ thống, kết nối với từng thiết bị
đầu vào ngắt của vcpu.

Nhóm:
  KVM_DEV_MPIC_GRP_MISC
   Thuộc tính:

KVM_DEV_MPIC_BASE_ADDR (rw, 64-bit)
      Địa chỉ cơ sở của không gian đăng ký 256 KiB MPIC.  Phải là
      căn chỉnh một cách tự nhiên.  Giá trị bằng 0 sẽ vô hiệu hóa ánh xạ.
      Giá trị đặt lại bằng không.

KVM_DEV_MPIC_GRP_REGISTER (rw, 32-bit)
    Truy cập vào thanh ghi MPIC, như thể quyền truy cập được thực hiện từ khách.
    "attr" là phần bù byte vào không gian thanh ghi MPIC.  Truy cập
    phải được căn chỉnh 4 byte.

MSI có thể được báo hiệu bằng cách sử dụng nhóm thuộc tính này để ghi
    tới MSIIR có liên quan.

KVM_DEV_MPIC_GRP_IRQ_ACTIVE (rw, 32-bit)
    Dòng đầu vào IRQ cho từng nguồn openpic tiêu chuẩn.  0 không hoạt động và 1
    đang hoạt động, bất kể cảm giác ngắt.

Đối với các ngắt kích hoạt cạnh: Viết 1 được coi là kích hoạt
    cạnh và việc ghi 0 bị bỏ qua.  Việc đọc trả về 1 nếu trước đó
    cạnh được báo hiệu chưa được xác nhận và 0 nếu không.

"attr" là số IRQ.  Số IRQ cho các nguồn tiêu chuẩn là
    độ lệch byte của IVPR có liên quan từ EIVPR0, chia cho 32.

Định tuyến IRQ:

Mô phỏng MPIC hỗ trợ định tuyến IRQ. Chỉ một thiết bị MPIC duy nhất có thể
  được khởi tạo. Khi thiết bị đó đã được tạo, nó sẽ có sẵn dưới dạng
  id chip 0.

Irqchip 0 này có 256 chân ngắt, hiển thị các ngắt trong
  mảng chính của các nguồn ngắt (còn gọi là ngắt "SRC").

Việc đánh số giống như liên kết cây thiết bị MPIC -- dựa trên
  phần bù thanh ghi tính từ đầu mảng nguồn, không có
  liên quan đến bất kỳ phân mục nào trong tài liệu về chip, chẳng hạn như "nội bộ"
  hoặc ngắt "bên ngoài".

Việc truy cập vào các ngắt không phải SRC không được thực hiện thông qua các cơ chế định tuyến IRQ.