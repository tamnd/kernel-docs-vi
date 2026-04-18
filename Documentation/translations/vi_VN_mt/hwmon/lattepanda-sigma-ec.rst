.. SPDX-License-Identifier: GPL-2.0-or-later

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/hwmon/lattepanda-sigma-ec.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

Trình điều khiển hạt nhân latepanda-sigma-ec
=================================

Các hệ thống được hỗ trợ:

* LattePanda Sigma (Intel thế hệ thứ 13 i5-1340P)

Nhà cung cấp DMI: LattePanda

Sản phẩm DMI: LattePanda Sigma

Phiên bản BIOS: 5.27 (đã xác minh)

Bảng dữ liệu: Không có sẵn (các thanh ghi EC được phát hiện theo kinh nghiệm)

Tác giả: Mariano Abad <weimaraner@gmail.com>

Sự miêu tả
-----------

Trình điều khiển này cung cấp khả năng giám sát phần cứng cho LattePanda Sigma
máy tính bảng đơn do DFRobot sản xuất. Bo mạch sử dụng ITE IT8613E
Bộ điều khiển nhúng để quản lý quạt làm mát CPU và cảm biến nhiệt.

BIOS khai báo Bộ điều khiển nhúng ACPI (ZZ0000ZZ) với
ZZ0001ZZ trả về 0, ngăn hệ thống con ACPI EC của kernel khỏi
đang khởi tạo. Trình điều khiển này đọc EC trực tiếp thông qua ACPI tiêu chuẩn
Cổng I/O EC (dữ liệu ZZ0002ZZ, lệnh/trạng thái ZZ0003ZZ).

Thuộc tính Sysfs
----------------

============================================================================
ZZ0000ZZ Tốc độ quạt trong RPM (EC đăng ký 0x2E:0x2F,
                        Phần cuối lớn 16-bit)
ZZ0001ZZ "Quạt CPU"
ZZ0002ZZ Bảng/nhiệt độ môi trường tính bằng mili độ
                        Độ C (đăng ký EC 0x60, chưa ký)
ZZ0003ZZ "Nhiệt độ bảng"
ZZ0004ZZ CPU nhiệt độ gần tính bằng mili độ
                        Độ C (đăng ký EC 0x70, chưa ký)
ZZ0005ZZ "Nhiệt độ CPU"
============================================================================

Thông số mô-đun
-----------------

ZZ0000ZZ (bool, mặc định là sai)
    Buộc tải trên các phiên bản BIOS khác 5.27. Người lái xe vẫn
    yêu cầu nhà cung cấp DMI phải khớp tên sản phẩm và tên nhà cung cấp.

Những hạn chế đã biết
-----------------

* Kiểm soát tốc độ quạt không được hỗ trợ. Quạt luôn ở chế độ EC
  điều khiển tự động.
* Bản đồ đăng ký EC chỉ được xác minh trên BIOS phiên bản 5.27.
  Các phiên bản khác có thể sử dụng độ lệch thanh ghi khác nhau; sử dụng ZZ0000ZZ
  tham số có nguy cơ của riêng bạn.