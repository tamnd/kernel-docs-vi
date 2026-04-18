.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/gpu/nova/core/devinit.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=====================================
Khởi tạo thiết bị (deinit)
=====================================
Quá trình deinit rất phức tạp và có thể thay đổi. Tài liệu này cung cấp một mức độ cao
tổng quan bằng cách sử dụng dòng Ampere GPU làm ví dụ. Mục đích là cung cấp một khái niệm
tổng quan về quy trình để hỗ trợ hiểu mã hạt nhân tương ứng.

Khởi tạo thiết bị (devinit) là một chuỗi quan trọng của hoạt động đọc/ghi thanh ghi
xảy ra sau khi thiết lập lại GPU. Trình tự deinit là cần thiết để cấu hình đúng
phần cứng GPU trước khi có thể sử dụng.

Công cụ devinit là một chương trình thông dịch thường chạy trên PMU (Quản lý nguồn
Unit) vi điều khiển của GPU. Trình thông dịch này thực thi một "tập lệnh" khởi tạo
lệnh. Bản thân động cơ devinit là một phần của VBIOS ROM trong cùng hình ảnh ROM với
Hình ảnh FWSEC (Firmware Security) (xem fwsec.rst và vbios.rst) và nó chạy trước
trình điều khiển nova-core thậm chí còn được tải. Trên Ampere GPU, ucode devinit tách biệt với
Mã FWSEC. Nó được khởi chạy bởi FWSEC, chạy trên GSP ở chế độ 'bảo mật cao', trong khi
devinit chạy trên PMU ở chế độ 'bảo vệ ánh sáng'.

Các chức năng chính của devinit
-------------------------------
devinit thực hiện một số nhiệm vụ quan trọng:

1. Lập trình định thời bộ điều khiển bộ nhớ VRAM
2. Trình tự nguồn điện
3. Cấu hình đồng hồ và PLL (Vòng khóa pha)
4. Quản lý nhiệt

Luồng khởi tạo chương trình cơ sở cấp thấp
------------------------------------------
Khi thiết lập lại, một số bộ vi điều khiển trên GPU (chẳng hạn như PMU, SEC2, GSP, v.v.) chạy GPU
mã chương trình cơ sở (gfw) để thiết lập GPU và các thông số cốt lõi của nó. Hầu hết GPU là
được coi là không sử dụng được cho đến khi quá trình khởi tạo này hoàn tất.

Các thành phần phần sụn GPU cấp thấp này thường là:

1. Nằm trong VBIOS ROM trong cùng phân vùng ROM (xem vbios.rst và fwsec.rst).
2. Thực hiện theo trình tự trên các bộ vi điều khiển khác nhau:

- Động cơ devinit thông thường nhưng không nhất thiết phải chạy trên PMU.
  - Trên Ampere GPU, FWSEC thường chạy trên GSP (Bộ xử lý hệ thống GPU) trong
    chế độ bảo mật cao.

Trước khi trình điều khiển có thể tiến hành khởi tạo thêm, nó phải đợi tín hiệu
cho biết quá trình khởi tạo lõi đã hoàn tất (được gọi là GFW_BOOT). Tín hiệu này là
được xác nhận bởi FWSEC chạy trên GSP ở chế độ bảo mật cao.

Cân nhắc về thời gian chạy
--------------------------
Điều quan trọng cần lưu ý là trình tự devinit cũng cần chạy trong quá trình tạm dừng/tiếp tục
hoạt động trong thời gian chạy, không chỉ trong lần khởi động đầu tiên, vì nó rất quan trọng đối với việc quản lý nguồn điện.

Kiểm soát an ninh và truy cập
-----------------------------
Quá trình khởi tạo bao gồm việc quản lý đặc quyền cẩn thận. Ví dụ, trước đây
truy cập vào các thanh ghi trạng thái hoàn thành nhất định, người lái xe phải kiểm tra mức đặc quyền
mặt nạ. Một số thanh ghi chỉ có thể truy cập được sau khi chương trình cơ sở an toàn (FWSEC) hạ thấp
mức đặc quyền để cho phép truy cập CPU (LS/bảo mật thấp). Đây là trường hợp, ví dụ,
khi nhận được tín hiệu GFW_BOOT.