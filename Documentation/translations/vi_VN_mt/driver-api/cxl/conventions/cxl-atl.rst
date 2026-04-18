.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/driver-api/cxl/conventions/cxl-atl.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

ACPI PRM CXL Dịch địa chỉ
================================

Tài liệu
--------

CXL Phiên bản 3.2, Phiên bản 1.0

Giấy phép
---------

SPDX-Số nhận dạng giấy phép: CC-BY-4.0

Người sáng tạo/Người đóng góp
-----------------------------

- Robert Richter, AMD và cộng sự.

Tóm tắt sự thay đổi
---------------------

Cấu trúc cửa sổ bộ nhớ cố định CXL (CFMWS) mô tả không hoặc nhiều Máy chủ
Cửa sổ Địa chỉ vật lý (HPA) được liên kết với một hoặc nhiều Cầu nối máy chủ CXL.
Mỗi phạm vi HPA của Cầu chủ CXL được biểu thị bằng một mục nhập CFMWS. Một chiếc HPA
phạm vi có thể bao gồm các địa chỉ hiện được gán cho thiết bị CXL.mem hoặc HĐH có thể
gán phạm vi từ cửa sổ địa chỉ cho thiết bị.

Bộ nhớ thiết bị do máy chủ quản lý là bộ nhớ gắn với thiết bị được ánh xạ tới hệ thống
không gian địa chỉ mạch lạc và có thể truy cập được vào Máy chủ bằng cách sử dụng tính năng ghi lại tiêu chuẩn
ngữ nghĩa. Dải địa chỉ được quản lý được định cấu hình trong Bộ giải mã CXL HDM
các thanh ghi của thiết bị. Bộ giải mã HDM trong thiết bị chịu trách nhiệm
chuyển đổi HPA thành DPA bằng cách loại bỏ các bit địa chỉ cụ thể.

Các thiết bị CXL và cầu nối CXL sử dụng cùng một không gian HPA. Nó phổ biến ở tất cả
các thành phần thuộc cùng một miền máy chủ. Chế độ xem vùng địa chỉ
phải nhất quán trên đường dẫn CXL.mem giữa Máy chủ và Thiết bị.

Điều này được mô tả trong ZZ0000ZZ (Bảng 1-1, 3.3.1,
8.2.4.20, 9.13.1, 9.18.1.3). [#cxl-spec-3.2]_

Tùy thuộc vào kiến trúc kết nối của nền tảng, các thành phần gắn liền
đến một máy chủ có thể không chia sẻ cùng một không gian địa chỉ vật lý của máy chủ. Những nền tảng đó
cần dịch địa chỉ để chuyển đổi HPA giữa máy chủ và thiết bị đính kèm
thành phần, chẳng hạn như thiết bị CXL. Cơ chế dịch thuật dành riêng cho từng máy chủ và
phụ thuộc vào việc thực hiện.

Ví dụ: nền tảng x86 AMD sử dụng Cấu trúc dữ liệu để quản lý quyền truy cập vào vật lý
trí nhớ. Các thiết bị có không gian bộ nhớ riêng và có thể được cấu hình để sử dụng
'Địa chỉ chuẩn hóa' khác với Địa chỉ vật lý hệ thống (SPA). Địa chỉ
thì cần phải dịch thuật. Để biết chi tiết, xem
ZZ0000ZZ.

Các nền tảng AMD đó cung cấp trình xử lý PRM [#prm-spec]_ trong phần sụn để thực hiện
nhiều loại dịch địa chỉ khác nhau, bao gồm cả điểm cuối CXL. AMD Zen5
các hệ thống triển khai lệnh gọi chương trình cơ sở Dịch địa chỉ ACPI PRM CXL. ACPI
Trình xử lý PRM có GUID cụ thể để nhận dạng duy nhất các nền tảng có hỗ trợ
Địa chỉ được chuẩn hóa Điều này được ghi lại trong ZZ0000ZZ
(Dịch địa chỉ - CXL DPA sang Địa chỉ vật lý hệ thống). [#amd-ppr-58088]_

Khi ở chế độ địa chỉ Chuẩn hóa, phải định cấu hình dải địa chỉ bộ giải mã HDM
và xử lý khác nhau. Địa chỉ phần cứng được sử dụng trong bộ giải mã HDM
cấu hình của điểm cuối không phải là SPA và cần được dịch từ
phạm vi địa chỉ của điểm cuối đến phạm vi địa chỉ của cầu nối máy chủ CXL. Điều này đặc biệt
quan trọng để tìm Cầu máy chủ CXL và cửa sổ HPA được liên kết của điểm cuối
được mô tả trong CFMWS. Ngoài ra, việc giải mã xen kẽ được thực hiện bởi
Cấu trúc dữ liệu và điểm cuối không thực hiện giải mã khi chuyển đổi HPA sang
DPA. Thay vào đó, chức năng xen kẽ bị tắt đối với điểm cuối (1 chiều). Cuối cùng,
cũng có thể cần dịch địa chỉ để kiểm tra phần cứng của điểm cuối
địa chỉ, chẳng hạn như trong quá trình lập hồ sơ, theo dõi hoặc xử lý lỗi.

Ví dụ: với địa chỉ Chuẩn hóa, bộ giải mã HDM có thể trông như sau ::

-------------------------------
                          ZZ0000ZZ
                          ZZ0001ZZ
                          ZZ0002ZZ
                          ZZ0003ZZ
                          -------------------------------
                                        |
                                        v
                          -------------------------------
                          ZZ0004ZZ
                          ZZ0005ZZ
                          ZZ0006ZZ
                          ZZ0007ZZ
                          ZZ0008ZZ
                          ZZ0009ZZ
                          -------------------------------
                                        |
           -----------------------------+------------------------------
           ZZ0010ZZ ZZ0011ZZ
           v v v v
 ------------------- ------------------- ------------------- -------------------
 ZZ0012ZZ ZZ0013ZZ ZZ0014ZZ ZZ0015ZZ
 ZZ0016ZZ ZZ0017ZZ ZZ0018ZZ ZZ0019ZZ
 ZZ0020ZZ ZZ0021ZZ ZZ0022ZZ ZZ0023ZZ
 ZZ0024ZZ ZZ0025ZZ ZZ0026ZZ ZZ0027ZZ
 ZZ0028ZZ ZZ0029ZZ ZZ0030ZZ ZZ0031ZZ
 ZZ0032ZZ ZZ0033ZZ ZZ0034ZZ ZZ0035ZZ
 ZZ0036ZZ ZZ0037ZZ ZZ0038ZZ ZZ0039ZZ
 ZZ0040ZZ ZZ0041ZZ ZZ0042ZZ ZZ0043ZZ
 ZZ0044ZZ ZZ0045ZZ ZZ0046ZZ ZZ0047ZZ
 ZZ0048ZZ ZZ0049ZZ ZZ0050ZZ ZZ0051ZZ
 ZZ0052ZZ ZZ0053ZZ ZZ0054ZZ ZZ0055ZZ
 ZZ0056ZZ ZZ0057ZZ ZZ0058ZZ ZZ0059ZZ
 ------------------- ------------------- ------------------- -------------------
          ZZ0060ZZ ZZ0061ZZ
          v v v v
         DPA DPA DPA DPA

Điều này cho thấy sự thể hiện trong sysfs:

.. code-block:: none

 /sys/bus/cxl/devices/endpoint5/decoder5.0/interleave_granularity:256
 /sys/bus/cxl/devices/endpoint5/decoder5.0/interleave_ways:1
 /sys/bus/cxl/devices/endpoint5/decoder5.0/size:0x2000000000
 /sys/bus/cxl/devices/endpoint5/decoder5.0/start:0x0
 /sys/bus/cxl/devices/endpoint8/decoder8.0/interleave_granularity:256
 /sys/bus/cxl/devices/endpoint8/decoder8.0/interleave_ways:1
 /sys/bus/cxl/devices/endpoint8/decoder8.0/size:0x2000000000
 /sys/bus/cxl/devices/endpoint8/decoder8.0/start:0x0
 /sys/bus/cxl/devices/endpoint11/decoder11.0/interleave_granularity:256
 /sys/bus/cxl/devices/endpoint11/decoder11.0/interleave_ways:1
 /sys/bus/cxl/devices/endpoint11/decoder11.0/size:0x2000000000
 /sys/bus/cxl/devices/endpoint11/decoder11.0/start:0x0
 /sys/bus/cxl/devices/endpoint13/decoder13.0/interleave_granularity:256
 /sys/bus/cxl/devices/endpoint13/decoder13.0/interleave_ways:1
 /sys/bus/cxl/devices/endpoint13/decoder13.0/size:0x2000000000
 /sys/bus/cxl/devices/endpoint13/decoder13.0/start:0x0

Lưu ý rằng cấu hình xen kẽ điểm cuối sử dụng ánh xạ trực tiếp (1 chiều).

Với các lệnh gọi PRM, kernel có thể xác định các ánh xạ sau:

.. code-block:: none

 cxl decoder5.0: address mapping found for 0000:e2:00.0 (hpa -> spa):
   0x0+0x2000000000 -> 0x850000000+0x8000000000 ways:4 granularity:256
 cxl decoder8.0: address mapping found for 0000:e3:00.0 (hpa -> spa):
   0x0+0x2000000000 -> 0x850000000+0x8000000000 ways:4 granularity:256
 cxl decoder11.0: address mapping found for 0000:e4:00.0 (hpa -> spa):
   0x0+0x2000000000 -> 0x850000000+0x8000000000 ways:4 granularity:256
 cxl decoder13.0: address mapping found for 0000:e1:00.0 (hpa -> spa):
   0x0+0x2000000000 -> 0x850000000+0x8000000000 ways:4 granularity:256

Bộ giải mã cầu máy chủ CXL (HDM) tương ứng và bộ giải mã gốc (CFMWS) khớp nhau
ánh xạ điểm cuối được tính toán hiển thị:

.. code-block:: none

 /sys/bus/cxl/devices/port1/decoder1.0/interleave_granularity:256
 /sys/bus/cxl/devices/port1/decoder1.0/interleave_ways:4
 /sys/bus/cxl/devices/port1/decoder1.0/size:0x8000000000
 /sys/bus/cxl/devices/port1/decoder1.0/start:0x850000000
 /sys/bus/cxl/devices/port1/decoder1.0/target_list:0,1,2,3
 /sys/bus/cxl/devices/port1/decoder1.0/target_type:expander
 /sys/bus/cxl/devices/root0/decoder0.0/interleave_granularity:256
 /sys/bus/cxl/devices/root0/decoder0.0/interleave_ways:1
 /sys/bus/cxl/devices/root0/decoder0.0/size:0x8000000000
 /sys/bus/cxl/devices/root0/decoder0.0/start:0x850000000
 /sys/bus/cxl/devices/root0/decoder0.0/target_list:7

Những thay đổi sau đây đối với đặc điểm kỹ thuật là cần thiết:

* Cho phép thiết bị CXL ở trong không gian HPA khác với không gian địa chỉ của máy chủ.

* Cho phép nền tảng sử dụng dịch địa chỉ dành riêng cho việc triển khai khi
  vượt qua các miền bộ nhớ trên đường dẫn CXL.mem giữa máy chủ và thiết bị.

* Xác định phương thức xử lý PRM để chuyển đổi địa chỉ thiết bị thành SPA.

* Chỉ định rằng nền tảng sẽ cung cấp phương thức xử lý PRM cho
  Hệ điều hành để phát hiện địa chỉ được chuẩn hóa và để xác định Điểm cuối
  Phạm vi SPA và cấu hình xen kẽ.

* Thêm tài liệu tham khảo:

| Đặc tả cơ chế thời gian chạy nền tảng, Phiên bản 1.1 – Tháng 11 năm 2020
  | ZZ0000ZZ

Lợi ích của sự thay đổi
-----------------------

Nếu không có thay đổi, Hệ điều hành có thể không xác định được bộ nhớ
vùng và Bộ giải mã gốc cho Điểm cuối và bộ giải mã HDM tương ứng của nó.
Việc tạo vùng sẽ thất bại. Nền tảng có kiến trúc kết nối khác nhau
sẽ không thể thiết lập và sử dụng CXL.

Tài liệu tham khảo
------------------

.. [#cxl-spec-3.2] Compute Express Link Specification, Revision 3.2, Version 1.0,
   https://www.computeexpresslink.org/

.. [#amd-ppr-58088] AMD Family 1Ah Models 00h–0Fh and Models 10h–1Fh,
   ACPI v6.5 Porting Guide, Publication # 58088,
   https://www.amd.com/en/search/documentation/hub.html

.. [#prm-spec] Platform Runtime Mechanism, Version: 1.1,
   https://uefi.org/sites/default/files/resources/PRM_Platform_Runtime_Mechanism_1_1_release_candidate.pdf

Mô tả chi tiết về sự thay đổi
----------------------------------

Phần sau đây mô tả những thay đổi cần thiết đối với ZZ0000ZZ
[#cxl-spec-3.2]_:

Thêm tham chiếu sau vào bảng:

Bảng 1-2. Tài liệu tham khảo

+-----------------------------+-------------------+--------------------------+
ZZ0000ZZ Tham khảo chương ZZ0001ZZ
+=====================================================================================+
ZZ0002ZZ Chương 8, 9 ZZ0003ZZ
ZZ0004ZZ ZZ0005ZZ
+-----------------------------+-------------------+--------------------------+

Thêm các đoạn văn sau vào cuối phần:

ZZ0000ZZ

"Một thiết bị có thể sử dụng không gian HPA không phổ biến đối với các thành phần khác của
miền máy chủ. Nền tảng chịu trách nhiệm dịch địa chỉ khi băng qua
Không gian HPA. Hệ điều hành phải xác định cấu hình xen kẽ
và thực hiện dịch địa chỉ sang phạm vi HPA của bộ giải mã HDM nếu cần.
Cơ chế dịch thuật tùy thuộc vào máy chủ và phụ thuộc vào việc triển khai.

Nền tảng này cho thấy sự hỗ trợ của các không gian HPA độc lập và nhu cầu về
dịch địa chỉ bằng cách cung cấp trình xử lý Cơ chế thời gian chạy nền tảng (PRM). các
HĐH sẽ sử dụng trình xử lý đó để thực hiện các bản dịch cần thiết từ DPA
không gian vào không gian HPA. Trình xử lý được xác định trong Phần 9.18.4 *Trình xử lý PRM
dành cho CXL DPA sang Dịch địa chỉ vật lý hệ thống*."

Thêm phần và tiểu mục sau bao gồm các bảng:

ZZ0000ZZ

"Một nền tảng có thể được cấu hình để sử dụng 'Địa chỉ chuẩn hóa'. Máy chủ vật lý
Không gian địa chỉ (HPA) dành riêng cho từng thành phần và khác với không gian vật lý của hệ thống
địa chỉ (SPA). Điểm cuối có không gian địa chỉ vật lý riêng. Tất cả các yêu cầu
được trình bày cho thiết bị đã sử dụng Địa chỉ vật lý của thiết bị (DPA). CXL
bộ giải mã điểm cuối đã vô hiệu hóa chức năng xen kẽ (xen kẽ 1 chiều) và thiết bị
không thực hiện giải mã HPA để xác định DPA.

Nền tảng này cung cấp trình xử lý PRM cho CXL DPA tới Địa chỉ vật lý hệ thống
Bản dịch. Trình xử lý PRM dịch Địa chỉ vật lý của thiết bị (DPA) thành
Địa chỉ vật lý hệ thống (SPA) cho điểm cuối CXL được chỉ định. Trong không gian địa chỉ
của máy chủ, SPA và HPA tương đương nhau và HĐH sẽ sử dụng trình xử lý này để
xác định HPA tương ứng với địa chỉ thiết bị, ví dụ: khi
định cấu hình bộ giải mã HDM trên nền tảng có địa chỉ Chuẩn hóa. GUID và
định dạng bộ đệm tham số của trình xử lý được chỉ định trong phần 9.18.4.1. Nếu
HĐH xác định trình xử lý PRM, nền tảng hỗ trợ địa chỉ Chuẩn hóa
và HĐH phải thực hiện dịch địa chỉ DPA nếu cần."

ZZ0000ZZ

"Hệ điều hành gọi trình xử lý PRM cho CXL DPA sang Dịch địa chỉ vật lý hệ thống
sử dụng cơ chế gọi trực tiếp. Chi tiết về cách gọi trình xử lý PRM là
được mô tả trong thông số kỹ thuật Cơ chế thời gian chạy nền tảng (PRM).

Trình xử lý PRM được xác định bởi GUID sau:

EE41B397-25D4-452C-AD54-48C6E3480B94

Người gọi phân bổ và chuẩn bị Bộ đệm tham số, sau đó chuyển PRM
trình xử lý GUID và một con trỏ tới Bộ đệm tham số để gọi trình xử lý. các
Bộ đệm tham số được mô tả trong Bảng 9-32."

ZZ0000ZZ

+-------------+-----------+-----------------------------------------------------------------------+
ZZ0003ZZ Chiều dài trong ZZ0004ZZ
ZZ0005ZZ Byte ZZ0006ZZ
+=============================================================================================================================================
ZZ0007ZZ 8 ZZ0008ZZ
ZZ0009ZZ ZZ0010ZZ
+-------------+-----------+-----------------------------------------------------------------------+
ZZ0011ZZ 4 ZZ0012ZZ
ZZ0013ZZ ZZ0014ZZ
ZZ0015ZZ ZZ0016ZZ
ZZ0017ZZ ZZ0018ZZ
ZZ0019ZZ ZZ0020ZZ
ZZ0021ZZ ZZ0022ZZ
ZZ0023ZZ ZZ0024ZZ
ZZ0025ZZ ZZ0026ZZ
ZZ0027ZZ ZZ0028ZZ
+-------------+-----------+-----------------------------------------------------------------------+
ZZ0029ZZ 8 ZZ0030ZZ
ZZ0031ZZ ZZ0032ZZ
+-------------+-----------+-----------------------------------------------------------------------+

ZZ0000ZZ

+-------------+-----------+-----------------------------------------------------------------------+
ZZ0001ZZ Chiều dài trong ZZ0002ZZ
ZZ0003ZZ Byte ZZ0004ZZ
+=============================================================================================================================================
ZZ0005ZZ 8 ZZ0006ZZ
ZZ0007ZZ ZZ0008ZZ
+-------------+-----------+-----------------------------------------------------------------------+