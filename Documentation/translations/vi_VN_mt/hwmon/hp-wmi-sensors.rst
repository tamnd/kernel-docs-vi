.. SPDX-License-Identifier: GPL-2.0-or-later

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/hwmon/hp-wmi-sensors.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. include:: <isonum.txt>

======================================
Trình điều khiển cảm biến Linux HP WMI
======================================

:Bản quyền: ZZ0000ZZ 2023 James Seo <james@equiv.tech>

Sự miêu tả
===========

Máy tính cấp doanh nghiệp Hewlett-Packard (và một số HP Compaq) báo cáo phần cứng
thông tin giám sát thông qua Công cụ quản lý Windows (WMI).
Trình điều khiển này hiển thị thông tin đó cho hệ thống con hwmon Linux, cho phép
các tiện ích không gian người dùng như ZZ0000ZZ để thu thập các chỉ số cảm biến số.

giao diện sysfs
===============

Khi trình điều khiển được tải, nó sẽ phát hiện các cảm biến có sẵn trên
hệ thống và tạo các thuộc tính sysfs sau nếu cần thiết trong
ZZ0000ZZ:

(ZZ0000ZZ là một số phụ thuộc vào các thành phần hệ thống khác.)

======================== ======= ========================================
Tên Perm Mô tả
======================== ======= ========================================
ZZ0000ZZ RO Dòng điện tính bằng miliampe (mA).
ZZ0001ZZ RO Nhãn cảm biến dòng điện.
Tốc độ quạt RO ZZ0002ZZ trong RPM.
Nhãn cảm biến quạt RO ZZ0003ZZ.
Đèn báo lỗi cảm biến quạt RO ZZ0004ZZ.
Đèn báo cảnh báo cảm biến quạt RO ZZ0005ZZ.
ZZ0006ZZ RO Điện áp tính bằng milivolt (mV).
Nhãn cảm biến điện áp RO ZZ0007ZZ.
ZZ0008ZZ RO Nhiệt độ tính bằng mili độ C
                                (m\ZZ0013ZZ\C).
Nhãn cảm biến nhiệt độ RO ZZ0009ZZ.
ZZ0010ZZ RO Chỉ báo lỗi cảm biến nhiệt độ.
ZZ0011ZZ RO Chỉ báo cảnh báo cảm biến nhiệt độ.
ZZ0012ZZ RW Chỉ báo cảnh báo xâm nhập khung gầm.
======================== ======= ========================================

Thuộc tính ZZ0000ZZ
  Đọc ZZ0001ZZ thay vì ZZ0002ZZ làm thuộc tính ZZ0003ZZ cho cảm biến
  cho biết rằng nó đã gặp phải một số vấn đề trong quá trình hoạt động như vậy
  các phép đo từ nó không đáng tin cậy. Nếu cảm biến bị lỗi
  tình trạng phục hồi sau, việc đọc thuộc tính này sẽ trả về ZZ0004ZZ một lần nữa.

Thuộc tính ZZ0000ZZ
  Đọc ZZ0001ZZ thay vì ZZ0002ZZ làm thuộc tính ZZ0003ZZ cho cảm biến
  chỉ ra rằng một trong những điều sau đây đã xảy ra, tùy thuộc vào loại của nó:

- ZZ0000ZZ: Quạt bị chết máy hoặc bị ngắt kết nối khi đang chạy.
  - ZZ0001ZZ: Việc đọc cảm biến đã đạt đến ngưỡng tới hạn.
    Ngưỡng chính xác phụ thuộc vào hệ thống.
  - ZZ0002ZZ: Thùng máy của hệ thống đã được mở.

Sau khi ZZ0000ZZ được đọc từ thuộc tính ZZ0001ZZ, thuộc tính này sẽ tự đặt lại
  và trả về ZZ0002ZZ trong những lần đọc tiếp theo. Như một ngoại lệ, một
  ZZ0003ZZ chỉ có thể được đặt lại theo cách thủ công bằng cách ghi ZZ0004ZZ vào nó.

giao diện gỡ lỗi
=================

.. warning:: The debugfs interface is subject to change without notice
             and is only available when the kernel is compiled with
             ``CONFIG_DEBUG_FS`` defined.

Giao diện hwmon tiêu chuẩn trong sysfs hiển thị các cảm biến thuộc một số loại phổ biến
được kết nối kể từ khi khởi tạo trình điều khiển. Tuy nhiên, thường có
các cảm biến khác trong WMI không đáp ứng các tiêu chí này. Ngoài ra, một số
"Đối tượng sự kiện nền tảng" phụ thuộc vào hệ thống được sử dụng cho các thuộc tính ZZ0000ZZ có thể
có mặt. Do đó, giao diện debugfs được cung cấp để truy cập chỉ đọc vào
tất cả các đối tượng sự kiện nền tảng và cảm biến HP WMI có sẵn.

ZZ0000ZZ
chứa một mục được đánh số cho mỗi cảm biến với các thuộc tính sau:

===========================================================================
Tên Ví dụ
===========================================================================
ZZ0000ZZ ZZ0001ZZ
ZZ0002ZZ ZZ0003ZZ
ZZ0004ZZ ZZ0005ZZ
ZZ0006ZZ (một chuỗi trống)
ZZ0007ZZ ZZ0008ZZ
ZZ0009ZZ ZZ0010ZZ
ZZ0011ZZ ZZ0012ZZ
ZZ0013ZZ ZZ0014ZZ
ZZ0015ZZ ZZ0016ZZ
ZZ0017ZZ ZZ0018ZZ
ZZ0019ZZ ZZ0020ZZ (chỉ tồn tại trên một số hệ thống)
===========================================================================

Nếu các đối tượng sự kiện nền tảng có sẵn,
ZZ0000ZZ
chứa một mục được đánh số cho mỗi đối tượng với các thuộc tính sau:

=======================================================
Tên Ví dụ
=======================================================
ZZ0000ZZ ZZ0001ZZ
ZZ0002ZZ ZZ0003ZZ
ZZ0004ZZ ZZ0005ZZ
ZZ0006ZZ ZZ0007ZZ
ZZ0008ZZ ZZ0009ZZ
ZZ0010ZZ ZZ0011ZZ
ZZ0012ZZ ZZ0013ZZ
=======================================================

Chúng đại diện cho các thuộc tính của ZZ0000ZZ cơ bản
và các đối tượng ZZ0001ZZ WMI, khác nhau giữa các hệ thống.
Xem [#]_ để biết thêm chi tiết và định nghĩa Định dạng đối tượng được quản lý (MOF).

Các vấn đề và hạn chế đã biết
============================

- Nếu trình điều khiển hp-wmi hiện có dành cho hệ thống HP không dành cho doanh nghiệp đã có sẵn
  được tải, các thuộc tính ZZ0000ZZ sẽ không khả dụng ngay cả trên các hệ thống
  hỗ trợ họ. Điều này là do sự kiện WMI tương tự GUID được trình điều khiển này sử dụng
  đối với các thuộc tính ZZ0001ZZ được sử dụng trên các hệ thống đó, ví dụ: phím nóng máy tính xách tay.
- Phần cứng cảm biến không rõ ràng và việc triển khai BIOS WMI không nhất quán đã được
  quan sát thấy gây ra kết quả đọc không chính xác và hành vi đặc biệt, chẳng hạn như báo động
  không xảy ra hoặc chỉ xảy ra một lần mỗi lần khởi động.
- Chỉ có các loại cảm biến nhiệt độ, tốc độ quạt và cảm biến xâm nhập được thấy trong
  hoang dã cho đến nay. Do đó, việc hỗ trợ các cảm biến điện áp và dòng điện là
  tạm thời.
- Mặc dù cảm biến HP WMI có thể được cho là thuộc bất kỳ loại nào, bất kỳ cảm biến kỳ quặc nào
  các loại không rõ hwmon sẽ không được hỗ trợ.

Tài liệu tham khảo
==========

.. [#] Hewlett-Packard Development Company, L.P.,
       "HP Client Management Interface Technical White Paper", 2005. [Online].
       Available: https://h20331.www2.hp.com/hpsub/downloads/cmi_whitepaper.pdf