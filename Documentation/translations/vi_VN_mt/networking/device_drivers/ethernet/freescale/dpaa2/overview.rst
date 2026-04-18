.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../../../../disclaimer-vi.rst

:Original: Documentation/networking/device_drivers/ethernet/freescale/dpaa2/overview.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. include:: <isonum.txt>

==============================================================
Tổng quan về DPAA2 (Kiến trúc tăng tốc đường dẫn dữ liệu Gen2)
==============================================================

:Bản quyền: ZZ0000ZZ 2015 Freescale Semiconductor Inc.
:Bản quyền: ZZ0001ZZ 2018 NXP

Tài liệu này cung cấp cái nhìn tổng quan về kiến trúc Freescale DPAA2
và cách nó được tích hợp vào nhân Linux.

Giới thiệu
============

DPAA2 là kiến trúc phần cứng được thiết kế cho mạng tốc độ cao
xử lý gói tin.  DPAA2 bao gồm các cơ chế phức tạp để
xử lý gói Ethernet, quản lý hàng đợi, quản lý bộ đệm,
chuyển mạch L2 tự động, cầu nối Ethernet ảo và bộ tăng tốc
(ví dụ: chia sẻ tiền điện tử).

Thành phần phần cứng DPAA2 được gọi là Tổ hợp quản lý (hoặc MC) quản lý
Tài nguyên phần cứng DPAA2.  MC cung cấp sự trừu tượng hóa dựa trên đối tượng cho
trình điều khiển phần mềm để sử dụng phần cứng DPAA2.
MC sử dụng tài nguyên phần cứng DPAA2 như hàng đợi, vùng đệm và
cổng mạng để tạo ra các đối tượng/thiết bị chức năng như mạng
giao diện, bộ chuyển mạch L2 hoặc phiên bản bộ tăng tốc.
MC cung cấp các giao diện lệnh I/O được ánh xạ bộ nhớ (cổng MC)
trình điều khiển phần mềm DPAA2 nào sử dụng để hoạt động trên các đối tượng DPAA2.

Sơ đồ bên dưới hiển thị tổng quan về quản lý tài nguyên DPAA2
kiến trúc::

+--------------------------------------+
	ZZ0000ZZ
	ZZ0001ZZ
	ZZ0002ZZ |
	+-----------------------------|--------+
	                              |
	                              | (tạo, khám phá, kết nối
	                              |  cấu hình, sử dụng, hủy)
	                              |
	                 DPAA2 |
	+-----------------------ZZ0003ZZ-+
	ZZ0004ZZ |
	ZZ0005ZZ
	ZZ0006ZZ ZZ0007ZZ
	Tổ hợp quản lý ZZ0008ZZ (MC) ZZ0009ZZ
	ZZ0010ZZ ZZ0011ZZ
	ZZ0012ZZ
	ZZ0013ZZ
	ZZ0014ZZ
	ZZ0015ZZ
	ZZ0016ZZ
	ZZ0017ZZ
	ZZ0018ZZ
	ZZ0019ZZ
	ZZ0020ZZ
	ZZ0021ZZ
	ZZ0022ZZ
	ZZ0023ZZ
	ZZ0024ZZ
	ZZ0025ZZ
	+--------------------------------------+


MC làm trung gian cho các hoạt động như tạo, khám phá,
kết nối, cấu hình và hủy.  Hoạt động đường dẫn nhanh
trên dữ liệu, chẳng hạn như truyền/nhận gói, không được trung gian bởi
MC và được thực hiện trực tiếp bằng cách sử dụng các vùng ánh xạ bộ nhớ trong
Đối tượng DPIO.

Tổng quan về đối tượng DPAA2
=========================

Phần này cung cấp tổng quan ngắn gọn về một số đối tượng DPAA2 chính.
Một kịch bản đơn giản được mô tả minh họa các đối tượng liên quan
trong việc tạo ra một giao diện mạng.

DPRC (Bộ chứa tài nguyên đường dẫn dữ liệu)
----------------------------------

DPRC là một đối tượng chứa tất cả các đối tượng khác
các loại đối tượng DPAA2.  Trong sơ đồ ví dụ bên dưới có
là 8 đối tượng thuộc 5 loại (DPMCP, DPIO, DPBP, DPNI và DPMAC)
trong thùng chứa.

::

+----------------------------------------------------------+
	ZZ0000ZZ
	ZZ0001ZZ
	ZZ0002ZZ
	ZZ0003ZZ DPMCP ZZ0004ZZ DPIO ZZ0005ZZ DPBP ZZ0006ZZ DPNI ZZ0007ZZ DPMAC ZZ0008ZZ
	ZZ0009ZZ
	ZZ0010ZZ DPMCP ZZ0011ZZ DPIO ZZ0012ZZ
	ZZ0013ZZ
	ZZ0014ZZ DPMCP ZZ0015ZZ
	ZZ0016ZZ
	ZZ0017ZZ
	+----------------------------------------------------------+

Từ quan điểm của một hệ điều hành, DPRC hoạt động tương tự như một phích cắm và
chơi xe buýt, như PCI.  Các lệnh DPRC có thể được sử dụng để liệt kê nội dung
của DPRC, khám phá các đối tượng phần cứng hiện diện (bao gồm cả các đối tượng có thể ánh xạ
vùng và ngắt).

::

DPRC.1 (xe buýt)
	   |
	   +---+--------+-------+-------+-------+
	      ZZ0000ZZ ZZ0001ZZ |
	    DPMCP.1 DPIO.1 DPBP.1 DPNI.1 DPMAC.1
	    DPMCP.2 DPIO.2
	    DPMCP.3

Các đối tượng phần cứng có thể được tạo và hủy một cách linh hoạt, cung cấp
khả năng cắm/rút nóng các vật thể vào và ra khỏi DPRC.

DPRC có vùng MMIO có thể ánh xạ (cổng MC) có thể được sử dụng
để gửi lệnh MC.  Nó có một sự gián đoạn cho các sự kiện trạng thái (như
phích cắm nóng).
Tất cả các đối tượng trong một thùng chứa đều có chung "ngữ cảnh cách ly" phần cứng.
Điều này có nghĩa là đối với IOMMU, độ chi tiết cách ly
ở cấp DPRC (vùng chứa), không phải ở cấp đối tượng riêng lẻ
cấp độ.

DPRC có thể được xác định tĩnh và chứa các đối tượng
thông qua tệp cấu hình được chuyển tới MC khi chương trình cơ sở khởi động nó.

Đối tượng DPAA2 cho giao diện mạng Ethernet
-----------------------------------------------

Ethernet NIC điển hình là nguyên khối-- thiết bị NIC chứa TX/RX
cơ chế xếp hàng, cơ chế cấu hình, quản lý bộ đệm,
các cổng vật lý và các ngắt.  DPAA2 sử dụng cách tiếp cận chi tiết hơn
sử dụng nhiều đối tượng phần cứng.  Mỗi đối tượng cung cấp chuyên biệt
chức năng. Các nhóm đối tượng này được phần mềm sử dụng để cung cấp
Chức năng giao diện mạng Ethernet.  Cách tiếp cận này cung cấp
sử dụng hiệu quả các tài nguyên phần cứng hữu hạn, tính linh hoạt và
lợi thế về hiệu suất.

Sơ đồ dưới đây cho thấy các đối tượng cần thiết cho một
cấu hình giao diện mạng trên hệ thống có 2 CPU.

::

+---+---+ +---+---+
	   CPU0 CPU1
	+---+---+ +---+---+
	    ZZ0000ZZ
	+---+---+ +---+---+
	   DPIO DPIO
	+---+---+ +---+---+
	    \ /
	     \ /
	      \ /
	   +---+---+
	      DPNI --- DPBP,DPMCP
	   +---+---+
	       |
	       |
	   +---+---+
	     DPMAC
	   +---+---+
	       |
	   cổng/PHY

Dưới đây các đối tượng được mô tả.  Đối với mỗi đối tượng một mô tả ngắn gọn
được cung cấp cùng với một bản tóm tắt về các loại hoạt động mà đối tượng
hỗ trợ và tóm tắt các tài nguyên chính của đối tượng (vùng MMIO
và IRQ).

DPMAC (Đường dẫn dữ liệu Ethernet MAC)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Đại diện cho Ethernet MAC, một thiết bị phần cứng kết nối với Ethernet
PHY và cho phép truyền và nhận khung Ethernet vật lý.

- Vùng MMIO: không có
- IRQ: Thay đổi liên kết DPNI
- lệnh: thiết lập liên kết lên/xuống, cấu hình liên kết, lấy số liệu thống kê,
  Cấu hình IRQ, bật, đặt lại

DPNI (Giao diện mạng đường dẫn dữ liệu)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Chứa hàng đợi TX/RX, cấu hình giao diện mạng và vùng đệm RX
các cơ chế cấu hình.  Hàng đợi TX/RX nằm trong bộ nhớ và được xác định
theo số hàng đợi.

- Vùng MMIO: không có
- IRQ: trạng thái liên kết
- các lệnh: cấu hình cổng, cấu hình giảm tải, cấu hình hàng đợi,
  phân tích/phân loại cấu hình, cấu hình IRQ, bật, đặt lại

DPIO (I/O đường dẫn dữ liệu)
~~~~~~~~~~~~~~~~~~~
Cung cấp giao diện cho enqueue và dequeue
các gói và thực hiện các hoạt động quản lý vùng đệm phần cứng.  DPAA2
kiến trúc tách biệt cơ chế truy cập hàng đợi (đối tượng DPIO)
từ chính hàng đợi.  DPIO cung cấp giao diện MMIO cho
gói enqueue/dequeue.  Để liệt kê một cái gì đó một bộ mô tả được viết
đến vùng DPIO MMIO, bao gồm số hàng đợi mục tiêu.
Thông thường sẽ có một DPIO được gán cho mỗi CPU.  Điều này cho phép tất cả
CPU để thực hiện đồng thời các hoạt động enqueue/dequeued.  dpio là
dự kiến sẽ được chia sẻ bởi các trình điều khiển DPAA2 khác nhau.

- Vùng MMIO: hoạt động hàng đợi, quản lý bộ đệm
- IRQ: tính khả dụng của dữ liệu, thông báo tắc nghẽn, bộ đệm
  cạn kiệt hồ bơi
- lệnh: Cấu hình IRQ, bật, đặt lại

DPBP (Nhóm đệm đường dẫn dữ liệu)
~~~~~~~~~~~~~~~~~~~~~~~~~~~
Đại diện cho một vùng đệm phần cứng.

- Vùng MMIO: không có
- IRQ: không có
- lệnh: kích hoạt, thiết lập lại

DPMCP (Cổng dữ liệu MC)
~~~~~~~~~~~~~~~~~~~~~~~~~~
Cung cấp một cổng lệnh MC.
Được sử dụng bởi người lái xe để gửi lệnh tới MC để quản lý
đồ vật.

- Vùng MMIO: Cổng lệnh MC
- IRQ: hoàn thành lệnh
- lệnh: Cấu hình IRQ, bật, đặt lại

Kết nối đối tượng
==================
Một số đối tượng có mối quan hệ rõ ràng phải
được cấu hình:

- DPNI <--> DPMAC
- DPNI <--> DPNI
- DPNI <--> Cổng chuyển mạch L2

DPNI phải được kết nối với thứ gì đó chẳng hạn như DPMAC,
    một cổng chuyển đổi DPNI hoặc L2 khác.  Kết nối DPNI
    được thực hiện thông qua lệnh DPRC.

::

+-------+ +-------+
              ZZ0000ZZ ZZ0001ZZ
              +---+---+ +---+---+
                  ZZ0002ZZ
                  +============+

- DPNI <--> DPBP

Giao diện mạng yêu cầu 'nhóm bộ đệm' (DPBP
    object) cung cấp danh sách các con trỏ tới bộ nhớ
    nơi dữ liệu Ethernet nhận được sẽ được sao chép.  các
    Trình điều khiển Ethernet cấu hình các DPBP được liên kết với
    giao diện mạng.

Ngắt
==========
Tất cả các ngắt được tạo bởi đối tượng DPAA2 đều là thông báo
ngắt quãng.  Ở mức phần cứng thông báo bị gián đoạn
do thiết bị tạo ra thường sẽ có 3 thành phần--
1) 'id thiết bị' không thể giả mạo được thể hiện trên phần cứng
bus, 2) địa chỉ, 3) giá trị dữ liệu.

Trong trường hợp thiết bị/đối tượng DPAA2, tất cả các đối tượng trong
cùng một vùng chứa/DPRC có chung 'id thiết bị'.
Đối với SoC dựa trên ARM, mã này giống với ID luồng.


Tổng quan về trình điều khiển Linux DPAA2
============================

Phần này cung cấp tổng quan về trình điều khiển nhân Linux cho
DPAA2-- 1) trình điều khiển xe buýt và "cơ sở hạ tầng DPAA2" liên quan
trình điều khiển và 2) trình điều khiển đối tượng chức năng (chẳng hạn như Ethernet).

Như đã mô tả trước đây, DPRC là một thùng chứa chứa cái kia
các loại đối tượng DPAA2.  Nó có chức năng tương tự như plug-and-play
điều khiển xe buýt.
Mỗi đối tượng trong DPRC là một "thiết bị" Linux và được liên kết với một trình điều khiển.
Sơ đồ bên dưới hiển thị các trình điều khiển Linux liên quan đến mạng
kịch bản và các đối tượng được liên kết với mỗi trình điều khiển.  Mô tả ngắn gọn
của mỗi trình điều khiển sau.

::

+-----------+
	                                     ZZ0000ZZ
	                                     ZZ0001ZZ
	         +-------------+ +-------------+
	         ZZ0002ZZ. . . . . . . ZZ0003ZZ
	         ZZ0004ZZ ZZ0005ZZ
	         +-.----------+ +---+---+----+
	          .          .                   ^ |
	         .            .     <dữ liệu có sẵn, ZZ0006ZZ <enqueue,
	        .              .     tx xác nhận> Hàng đợi ZZ0007ZZ>
	+-------------+ .                ZZ0008ZZ
	ZZ0009ZZ.           +---+---V----+ +----------+
	ZZ0010ZZ. . . . . .ZZ0011ZZ ZZ0012ZZ
	+----------+--+ ZZ0013ZZ ZZ0014ZZ
	           |                         +------+------+ +------+---+
	           ZZ0015ZZ |
	           ZZ0016ZZ |
	  +--------+----------+ |              +--+---+
	  ZZ0017ZZ ZZ0018ZZ PHY |
	  ZZ0019ZZ |              |driver|
	  ZZ0021ZZ |              +--+---+
	  +-------------------+ ZZ0022ZZ
	                                            ZZ0023ZZ
	=========================== HARDWARE ==========ZZ0024ZZ======
	                                          DPIO |
	                                            ZZ0025ZZ
	                                          DPNI---DPBP |
	                                            ZZ0026ZZ
	                                          DPMAC |
	                                            ZZ0027ZZ
	                                           PHY ---------------+
	==============================================|===========================

Một mô tả ngắn gọn về mỗi trình điều khiển được cung cấp dưới đây.

Tài xế xe buýt MC
-------------
Trình điều khiển MC-bus là trình điều khiển nền tảng và được thăm dò từ một
nút trong cây thiết bị (tương thích "fsl,qoriq-mc") được truyền vào bằng boot
phần sụn.  Nó chịu trách nhiệm khởi động kernel DPAA2
cơ sở hạ tầng.
Các chức năng chính bao gồm:

- đăng ký loại bus mới có tên "fsl-mc" với kernel,
  và triển khai các cuộc gọi lại xe buýt (ví dụ: match/uevent/dev_groups)
- triển khai API để đăng ký trình điều khiển DPAA2 và cho thiết bị
  thêm/xóa
- tạo miền MSI IRQ
- thực hiện 'thêm thiết bị' để hiển thị 'root' DPRC, lần lượt kích hoạt
  liên kết gốc DPRC với trình điều khiển DPRC

Có thể tham khảo liên kết cho nút cây thiết bị MC-bus tại
ZZ0000ZZ.
Bạn có thể tham khảo các giao diện liên kết/hủy liên kết sysfs cho MC-bus tại
ZZ0001ZZ.

Trình điều khiển DPRC
-----------
Trình điều khiển DPRC được liên kết với các đối tượng DPRC và quản lý thời gian chạy
của một trường hợp xe buýt.  Nó thực hiện quét bus ban đầu của DPRC
và xử lý các ngắt cho các sự kiện của vùng chứa chẳng hạn như cắm nóng bằng
quét lại DPRC.

Bộ phân bổ
---------
Một số đối tượng nhất định như DPMCP và DPBP là chung và có thể thay thế được,
và được thiết kế để sử dụng bởi những người lái xe khác.  Ví dụ,
trình điều khiển Ethernet DPAA2 cần:

- DPMCP gửi lệnh MC, cấu hình giao diện mạng
- DPBP cho vùng đệm mạng

Trình điều khiển cấp phát đăng ký các loại đối tượng có thể cấp phát này
và những đối tượng đó được liên kết với bộ cấp phát khi xe buýt được thăm dò.
Bộ cấp phát duy trì một tập hợp các đối tượng có sẵn cho
phân bổ bởi trình điều khiển DPAA2 khác.

Trình điều khiển DPIO
-----------
Trình điều khiển DPIO được liên kết với các đối tượng DPIO và cung cấp các dịch vụ cho phép
các trình điều khiển khác như trình điều khiển Ethernet để sắp xếp và loại bỏ dữ liệu cho
đối tượng tương ứng của chúng.
Các dịch vụ chính bao gồm:

- thông báo về tính khả dụng của dữ liệu
- hoạt động xếp hàng phần cứng (enqueue và dequeue dữ liệu)
- quản lý vùng đệm phần cứng

Để truyền một gói, trình điều khiển Ethernet đặt dữ liệu vào hàng đợi và
gọi DPIO API.  Để nhận, trình điều khiển Ethernet đăng ký
một cuộc gọi lại thông báo về tính sẵn có của dữ liệu.  Để loại bỏ một gói
DPIO API được sử dụng.
Thông thường có một đối tượng DPIO cho mỗi CPU vật lý để tối ưu hóa
hiệu suất, cho phép các CPU khác nhau đồng thời xếp hàng
và dữ liệu dequeue.

Trình điều khiển DPIO hoạt động thay mặt cho tất cả các trình điều khiển DPAA2
hoạt động trong hạt nhân-- Ethernet, mật mã, nén,
v.v.

Trình điều khiển Ethernet
---------------
Trình điều khiển Ethernet được liên kết với DPNI và triển khai kernel
giao diện cần thiết để kết nối giao diện mạng DPAA2 với
ngăn xếp mạng.
Mỗi DPNI tương ứng với giao diện mạng Linux.

Trình điều khiển MAC
----------
Ethernet PHY là một thành phần cụ thể trên bo mạch, ngoài chip và được quản lý
bằng trình điều khiển PHY thích hợp thông qua bus mdio.  Trình điều khiển MAC
đóng vai trò là proxy giữa trình điều khiển PHY và
MC.  Nó thực hiện proxy này thông qua các lệnh MC tới đối tượng DPMAC.
Nếu trình điều khiển PHY báo hiệu thay đổi liên kết, trình điều khiển MAC sẽ thông báo
MC thông qua lệnh DPMAC.  Nếu một giao diện mạng được đưa
lên hoặc xuống, MC thông báo cho trình điều khiển DPMAC thông qua ngắt và
người lái xe có thể thực hiện hành động thích hợp.
