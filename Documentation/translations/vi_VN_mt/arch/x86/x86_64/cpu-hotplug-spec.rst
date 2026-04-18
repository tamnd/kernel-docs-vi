.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/arch/x86/x86_64/cpu-hotplug-spec.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

============================================================
Hỗ trợ chương trình cơ sở cho hotplug CPU trong Linux/x86-64
============================================================

Linux/x86-64 hiện hỗ trợ hotplug CPU. Vì nhiều lý do khác nhau Linux muốn
biết trước thời gian khởi động số lượng CPU tối đa có thể được cắm
vào hệ thống. ACPI 3.0 hiện tại chưa có đường cung cấp chính thức
thông tin này từ phần sụn đến hệ điều hành.

Trong ACPI, mỗi CPU cần một đối tượng LAPIC trong bảng MADT (5.2.11.5 trong bảng
Đặc điểm kỹ thuật ACPI 3.0).  ACPI đã có khái niệm LAPIC bị vô hiệu hóa
đối tượng bằng cách đặt bit Đã bật trong đối tượng LAPIC về 0.

Đối với CPU hotplug Linux/x86-64 bây giờ hy vọng rằng bất kỳ hotpluggable nào có thể có trong tương lai
CPU đã có sẵn trong MADT. Nếu CPU chưa có sẵn
nó phải có bit Kích hoạt LAPIC được đặt thành 0. Linux sẽ sử dụng số
của LAPIC bị vô hiệu hóa để tính toán số lượng CPU tối đa trong tương lai.

Trong trường hợp xấu nhất, người dùng có thể ghi đè lựa chọn này bằng dòng lệnh
tùy chọn (bổ sung_cpus=...), nhưng nên cung cấp chính xác
số (hoặc một giá trị gần đúng hợp lý của nó, với sai số lớn hơn hoặc ít hơn)
trong MADT để tránh cấu hình thủ công.