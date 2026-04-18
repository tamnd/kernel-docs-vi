.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/arch/arm64/amu.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. _amu_index:

====================================================================
Tiện ích mở rộng Đơn vị giám sát hoạt động (AMU) trong AArch64 Linux
====================================================================

Tác giả: Ionela Voinescu <ionela.voinescu@arm.com>

Ngày: 2019-09-10

Tài liệu này mô tả ngắn gọn việc cung cấp Đơn vị giám sát hoạt động
hỗ trợ trong AArch64 Linux.


Tổng quan về kiến ​​trúc
---------------------

Tiện ích mở rộng giám sát hoạt động là một tiện ích mở rộng tùy chọn được giới thiệu bởi
Kiến trúc ARMv8.4 CPU.

Đơn vị giám sát hoạt động, được triển khai trong mỗi CPU, cung cấp hiệu suất
bộ đếm dành cho mục đích sử dụng quản lý hệ thống. Tiện ích mở rộng AMU cung cấp
giao diện đăng ký hệ thống với các thanh ghi bộ đếm và cũng hỗ trợ một
giao diện ánh xạ bộ nhớ ngoài tùy chọn.

Phiên bản 1 của kiến trúc Giám sát hoạt động triển khai một nhóm truy cập
gồm bốn bộ đếm sự kiện 64-bit cố định và được xác định về mặt kiến trúc.

- Bộ đếm chu kỳ CPU: tăng theo tần số của CPU.
  - Bộ đếm không đổi: tăng theo tần số cố định của hệ thống
    đồng hồ.
  - Hướng dẫn đã ngừng hoạt động: tăng dần theo mỗi lần thực thi về mặt kiến trúc
    hướng dẫn.
  - Chu kỳ dừng bộ nhớ: đếm số chu kỳ ngừng gửi lệnh do
    bỏ lỡ bộ đệm cấp cuối cùng trong miền đồng hồ.

Khi ở WFI hoặc WFE, các bộ đếm này không tăng.

Kiến trúc Giám sát hoạt động cung cấp không gian cho tối đa 16 kiến trúc
quầy sự kiện. Các phiên bản tương lai của kiến trúc có thể sử dụng không gian này để
triển khai các bộ đếm sự kiện được kiến trúc bổ sung.

Ngoài ra, phiên bản 1 còn triển khai một nhóm bộ đếm lên tới 16 bộ đếm phụ trợ.
Bộ đếm sự kiện 64-bit

Khi thiết lập lại nguội tất cả các bộ đếm được đặt lại về 0.


Hỗ trợ cơ bản
-------------

Hạt nhân có thể chạy một cách an toàn hỗn hợp các CPU có và không có hỗ trợ cho
phần mở rộng giám sát hoạt động. Vì vậy, khi CONFIG_ARM64_AMU_EXTN
đã chọn, chúng tôi kích hoạt vô điều kiện khả năng cho phép mọi CPU muộn
(thứ cấp hoặc cắm nóng) để phát hiện và sử dụng tính năng này.

Khi phát hiện thấy tính năng này trên CPU, chúng tôi sẽ gắn cờ tính khả dụng của
tính năng nhưng điều này không đảm bảo chức năng chính xác của
quầy, chỉ có sự hiện diện của phần mở rộng.

Hỗ trợ phần sụn (mã chạy ở mức ngoại lệ cao hơn, ví dụ: arm-tf) là
cần thiết để:

- Cho phép truy cập các mức ngoại lệ thấp hơn (EL2 và EL1) vào AMU
   sổ đăng ký.
 - Kích hoạt bộ đếm. Nếu không được kích hoạt, chúng sẽ đọc là 0.
 - Lưu/khôi phục bộ đếm trước/sau khi CPU được đặt/mang lên
   từ trạng thái nguồn 'tắt'.

Khi sử dụng kernel đã bật tính năng này nhưng khởi động bị hỏng
chương trình cơ sở, người dùng có thể gặp phải tình trạng hoảng loạn hoặc bị khóa khi truy cập vào
các thanh ghi bộ đếm. Ngay cả khi những triệu chứng này không được quan sát thấy, các giá trị
được trả về bởi các lần đọc sổ đăng ký có thể không phản ánh chính xác thực tế. Hầu hết
thông thường, các bộ đếm sẽ đọc là 0, cho biết rằng chúng không
đã bật.

Nếu phần sụn không được hỗ trợ thích hợp thì tốt nhất nên tắt
CONFIG_ARM64_AMU_EXTN. Cần lưu ý rằng vì lý do bảo mật, điều này không
bỏ qua cài đặt của AMUSERENR_EL0 để chặn các truy cập từ EL0 (không gian người dùng) vào
EL1 (hạt nhân). Do đó, phần sụn vẫn phải đảm bảo quyền truy cập vào các thanh ghi AMU
không bị mắc kẹt trong EL2/EL3.

Các bộ đếm cố định của AMUv1 có thể truy cập được thông qua hệ thống sau
đăng ký định nghĩa:

-SYS_AMEVCNTR0_CORE_EL0
 -SYS_AMEVCNTR0_CONST_EL0
 -SYS_AMEVCNTR0_INST_RET_EL0
 -SYS_AMEVCNTR0_MEM_STALL_EL0

Các bộ đếm cụ thể của nền tảng phụ trợ có thể được truy cập bằng cách sử dụng
SYS_AMEVCNTR1_EL0(n), trong đó n là giá trị từ 0 đến 15.

Bạn có thể tìm thấy thông tin chi tiết tại: Arch/arm64/include/asm/sysreg.h.


Quyền truy cập không gian người dùng
----------------

Hiện tại, quyền truy cập từ không gian người dùng vào các thanh ghi AMU bị vô hiệu hóa do:

- Lý do bảo mật: chúng có thể tiết lộ thông tin về mã được thực thi trong
   chế độ an toàn.
 - Mục đích: Bộ đếm AMU được thiết kế để sử dụng cho việc quản lý hệ thống.

Ngoài ra, sự hiện diện của tính năng này không hiển thị với không gian người dùng.


Ảo hóa
--------------

Hiện tại, truy cập từ không gian người dùng (EL0) và không gian kernel (EL1) trên KVM
phía khách bị vô hiệu hóa do:

- Lý do bảo mật: chúng có thể tiết lộ thông tin về mã được thực thi
   bởi những vị khách khác hoặc chủ nhà.

Mọi nỗ lực truy cập vào thanh ghi AMU sẽ dẫn đến UNDEFINED
ngoại lệ được tiêm vào khách.
