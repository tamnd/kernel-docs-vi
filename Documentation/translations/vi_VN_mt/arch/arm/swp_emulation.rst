.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/arch/arm/swp_emulation.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

Phần mềm mô phỏng lệnh SWP không được dùng nữa (CONFIG_SWP_EMULATE)
---------------------------------------------------------------------

Kiến trúc ARMv6 không khuyến khích sử dụng các hướng dẫn SWP/SWPB và khuyến nghị
chuyển sang các lệnh khóa tải/lưu trữ có điều kiện LDREX và STREX.

Các tiện ích mở rộng đa xử lý ARMv7 giới thiệu khả năng vô hiệu hóa các tiện ích này
hướng dẫn, kích hoạt một ngoại lệ lệnh không xác định khi được thực thi.
Các lệnh bị bẫy được mô phỏng bằng LDREX/STREX hoặc LDREXB/STREXB
trình tự. Nếu xảy ra lỗi truy cập bộ nhớ (hủy bỏ), lỗi phân đoạn sẽ xảy ra.
báo hiệu cho quá trình kích hoạt.

/proc/cpu/swp_emulation chứa một số số liệu thống kê/thông tin, bao gồm PID của
quá trình cuối cùng để kích hoạt mô phỏng được gọi. Ví dụ::

Mô phỏng SWP: 12
  Mô phỏng SWPB: 0
  Đã hủy SWP{B}: 1
  Quá trình cuối cùng: 314


NOTE:
  khi truy cập vào các vùng chia sẻ không được lưu trong bộ nhớ đệm, LDREX/STREX sẽ dựa vào một
  khối giám sát giao dịch được gọi là màn hình toàn cầu để duy trì cập nhật
  tính nguyên tử. Nếu hệ thống của bạn không triển khai màn hình chung, tùy chọn này có thể
  khiến các chương trình thực hiện thao tác SWP trên bộ nhớ không được lưu trong bộ nhớ đệm rơi vào tình trạng bế tắc, chẳng hạn như
  thao tác STREX sẽ luôn thất bại.
