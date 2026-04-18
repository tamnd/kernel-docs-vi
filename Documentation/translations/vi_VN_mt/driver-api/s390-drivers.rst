.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/driver-api/s390-drivers.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

========================================
Viết trình điều khiển thiết bị kênh s390
========================================

:Tác giả: Cornelia Huck

Giới thiệu
============

Tài liệu này mô tả các giao diện có sẵn cho trình điều khiển thiết bị
điều khiển các thiết bị I/O dựa trên kênh s390. Điều này bao gồm các giao diện
để tương tác với phần cứng và giao diện để tương tác với
lõi điều khiển chung. Các giao diện đó được cung cấp bởi s390 chung
Lớp vào/ra.

Tài liệu này giả định sự quen thuộc với các thuật ngữ kỹ thuật liên quan
với kiến trúc I/O kênh s390. Để mô tả về điều này
kiến trúc, vui lòng tham khảo "z/Architecture: Nguyên tắc của
Hoạt động", ấn phẩm IBM số. SA22-7832.

Trong khi hầu hết các thiết bị I/O trên hệ thống s390 thường được điều khiển thông qua
cơ chế I/O kênh được mô tả ở đây, có nhiều phương pháp khác
(giống như giao diện chẩn đoán). Những điều này nằm ngoài phạm vi của tài liệu này.

Lớp I/O chung của s390 cũng cung cấp quyền truy cập vào một số thiết bị
không được coi là thiết bị I/O một cách chặt chẽ. Chúng cũng được xem xét ở đây,
mặc dù chúng không phải là trọng tâm của tài liệu này.

Một số thông tin bổ sung cũng có thể được tìm thấy trong nguồn kernel bên dưới
Tài liệu/arch/s390/driver-model.rst.

Xe buýt css
===========

Bus css chứa các kênh con có sẵn trên hệ thống. Họ rơi
thành nhiều loại:

* Các kênh con I/O tiêu chuẩn để hệ thống sử dụng. Họ có một đứa con
  thiết bị trên xe buýt ccw và được mô tả dưới đây.
* Các kênh con I/O được liên kết với trình điều khiển vfio-ccw. Xem
  Tài liệu/arch/s390/vfio-ccw.rst.
* Kênh con tin nhắn. Hiện tại không có trình điều khiển Linux nào tồn tại.
* Kênh con CHSC (nhiều nhất là một). Trình điều khiển kênh con chsc có thể được sử dụng
  để gửi lệnh chsc không đồng bộ.
* Kênh con eADM. Được sử dụng để nói chuyện với bộ nhớ lớp lưu trữ.

xe buýt CCW
===========

Bus ccw thường chứa phần lớn các thiết bị có sẵn cho một
hệ thống s390. Được đặt tên theo từ lệnh kênh (ccw), cơ bản
cấu trúc lệnh được sử dụng để đánh địa chỉ các thiết bị của nó, bus ccw chứa
cái gọi là thiết bị gắn kênh. Chúng được giải quyết thông qua I/O
kênh con, hiển thị trên bus css. Trình điều khiển thiết bị dành cho
Tuy nhiên, các thiết bị gắn kênh sẽ không bao giờ tương tác với
kênh con trực tiếp nhưng chỉ thông qua thiết bị I/O trên bus ccw, ccw
thiết bị.

Chức năng I/O cho các thiết bị gắn kênh
------------------------------------------

Một số cấu trúc phần cứng đã được dịch sang cấu trúc C để sử dụng
bởi lớp I/O chung và trình điều khiển thiết bị. Để biết thêm thông tin về
cấu trúc phần cứng được trình bày ở đây, vui lòng tham khảo Nguyên tắc của
Hoạt động.

.. kernel-doc:: arch/s390/include/asm/cio.h
   :internal:

thiết bị ccw
-----------

Các thiết bị muốn bắt đầu I/O kênh cần phải gắn vào bus ccw.
Tương tác với lõi trình điều khiển được thực hiện thông qua lớp I/O chung, lớp này
cung cấp sự trừu tượng hóa của thiết bị ccw và trình điều khiển thiết bị ccw.

Các chức năng khởi tạo hoặc kết thúc I/O kênh đều hoạt động theo ccw.
cấu trúc thiết bị. Trình điều khiển thiết bị không được bỏ qua các chức năng đó hoặc
tác dụng phụ lạ có thể xảy ra.

.. kernel-doc:: arch/s390/include/asm/ccwdev.h
   :internal:

.. kernel-doc:: drivers/s390/cio/device.c
   :export:

.. kernel-doc:: drivers/s390/cio/device_ops.c
   :export:

Thiết bị đo kênh
--------------------------------

Cơ sở đo lường kênh cung cấp phương tiện để thu thập số đo
dữ liệu được hệ thống con kênh cung cấp cho mỗi kênh
thiết bị đính kèm.

.. kernel-doc:: arch/s390/include/uapi/asm/cmb.h
   :internal:

.. kernel-doc:: drivers/s390/cio/cmf.c
   :export:

xe buýt ccwgroup
================

Bus ccwgroup chỉ chứa các thiết bị nhân tạo do người dùng tạo ra.
Nhiều thiết bị mạng (ví dụ qeth) trên thực tế bao gồm một số ccw
các thiết bị (như kênh đọc, ghi và dữ liệu cho qeth). xe buýt ccwgroup
cung cấp một cơ chế để tạo ra một siêu thiết bị chứa các ccw đó
các thiết bị dưới dạng thiết bị phụ và có thể được liên kết với netdevice.

thiết bị nhóm ccw
-----------------

.. kernel-doc:: arch/s390/include/asm/ccwgroup.h
   :internal:

.. kernel-doc:: drivers/s390/cio/ccwgroup.c
   :export:

Giao diện chung
==================

Phần sau đây chứa các giao diện được sử dụng không chỉ bởi trình điều khiển
xử lý các thiết bị ccw, nhưng trình điều khiển cho nhiều phần cứng s390 khác
cũng vậy.

Bộ chuyển đổi ngắt
------------------

Lớp I/O chung cung cấp các chức năng trợ giúp để xử lý bộ điều hợp
ngắt và vectơ ngắt.

.. kernel-doc:: drivers/s390/cio/airq.c
   :export:
