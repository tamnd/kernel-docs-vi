.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/admin-guide/mm/memory-hotplug.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

====================
Cắm nóng bộ nhớ (Un)
====================

Tài liệu này mô tả sự hỗ trợ chung của Linux cho việc cắm nóng(un) bộ nhớ với
tập trung vào Hệ thống RAM, bao gồm hỗ trợ ZONE_MOVABLE.

.. contents:: :local:

Giới thiệu
============

Ổ cắm nóng (un) bộ nhớ cho phép tăng và giảm kích thước vật lý
bộ nhớ có sẵn cho máy khi chạy. Trong trường hợp đơn giản nhất, nó bao gồm
cắm hoặc rút DIMM về mặt vật lý trong thời gian chạy, phối hợp với
hệ điều hành.

Ổ cắm nóng (un) bộ nhớ được sử dụng cho nhiều mục đích khác nhau:

- Bộ nhớ vật lý có sẵn cho máy có thể được điều chỉnh khi chạy, lên hoặc xuống
  giảm dung lượng bộ nhớ. Việc thay đổi kích thước bộ nhớ động này đôi khi
  được gọi là "dung lượng theo yêu cầu", thường được sử dụng với các máy ảo
  và phân vùng logic.

- Thay thế phần cứng, chẳng hạn như DIMM hoặc toàn bộ nút NUMA mà không có thời gian ngừng hoạt động. một
  ví dụ là thay thế các mô-đun bộ nhớ bị lỗi.

- Giảm mức tiêu thụ năng lượng bằng cách rút phích cắm các mô-đun bộ nhớ hoặc
  bằng cách rút (các bộ phận) mô-đun bộ nhớ khỏi Linux một cách hợp lý.

Hơn nữa, cơ sở hạ tầng cắm nóng (bỏ) bộ nhớ cơ bản trong Linux ngày nay cũng
được sử dụng để hiển thị bộ nhớ liên tục, bộ nhớ khác biệt về hiệu năng và
vùng bộ nhớ dành riêng như hệ thống thông thường RAM cho Linux.

Linux chỉ hỗ trợ cắm nóng (un) bộ nhớ trên các kiến trúc 64 bit được chọn, chẳng hạn như
x86_64, arm64, ppc64 và s390x.

Độ chi tiết của phích cắm bộ nhớ nóng (Un)
------------------------------------------

Bộ nhớ nóng(un)plug trong Linux sử dụng mô hình bộ nhớ SPARSEMEM, phân chia
không gian địa chỉ bộ nhớ vật lý thành các phần có cùng kích thước: các phần bộ nhớ. các
kích thước của một phần bộ nhớ phụ thuộc vào kiến trúc. Ví dụ: x86_64 sử dụng
128 MiB và ppc64 sử dụng 16 MiB.

Các phần bộ nhớ được kết hợp thành các khối được gọi là "khối bộ nhớ". các
kích thước của khối bộ nhớ phụ thuộc vào kiến trúc và tương ứng với kích thước nhỏ nhất
độ chi tiết có thể được cắm nóng. Kích thước mặc định của khối bộ nhớ là
giống như kích thước phần bộ nhớ, trừ khi kiến trúc có quy định khác.

Tất cả các khối bộ nhớ đều có cùng kích thước.

Các giai đoạn cắm nóng bộ nhớ
-----------------------------

Bộ nhớ nóng bao gồm hai giai đoạn:

(1) Thêm bộ nhớ vào Linux
(2) Khối bộ nhớ trực tuyến

Trong giai đoạn đầu tiên, siêu dữ liệu, chẳng hạn như bản đồ bộ nhớ ("memmap") và bảng trang
đối với ánh xạ trực tiếp, được phân bổ và khởi tạo, và các khối bộ nhớ được
được tạo ra; cái sau cũng tạo các tệp sysfs để quản lý bộ nhớ mới được tạo
khối.

Trong giai đoạn thứ hai, bộ nhớ được thêm vào sẽ được hiển thị cho bộ cấp phát trang. Sau này
pha, bộ nhớ sẽ hiển thị trong số liệu thống kê về bộ nhớ, chẳng hạn như bộ nhớ trống và tổng
bộ nhớ, của hệ thống.

Các giai đoạn của bộ nhớ Hotunplug
----------------------------------

Bộ nhớ hotunplug bao gồm hai giai đoạn:

(1) Khối bộ nhớ ngoại tuyến
(2) Xóa bộ nhớ khỏi Linux

Trong giai đoạn đầu tiên, bộ nhớ lại bị "ẩn" khỏi bộ cấp phát trang, vì
Ví dụ, bằng cách di chuyển bộ nhớ bận sang các vị trí bộ nhớ khác và loại bỏ tất cả
các trang trống có liên quan từ bộ cấp phát trang Sau giai đoạn này, bộ nhớ không còn
hiển thị lâu hơn trong thống kê bộ nhớ của hệ thống.

Trong giai đoạn thứ hai, các khối bộ nhớ bị loại bỏ và siêu dữ liệu được giải phóng.

Thông báo cắm nóng bộ nhớ
============================

Có nhiều cách khác nhau để Linux được thông báo về các sự kiện cắm nóng bộ nhớ, chẳng hạn như
rằng nó có thể bắt đầu thêm bộ nhớ được cắm nóng. Mô tả này được giới hạn ở
hệ thống hỗ trợ ACPI; cơ chế cụ thể cho các giao diện phần sụn khác hoặc
máy ảo không được mô tả.

Thông báo ACPI
------------------

Các nền tảng hỗ trợ ACPI, chẳng hạn như x86_64, có thể hỗ trợ cắm nóng bộ nhớ
thông báo qua ACPI.

Nói chung, một hotplug bộ nhớ hỗ trợ phần sụn xác định một đối tượng lớp bộ nhớ
HID "PNP0C80". Khi được thông báo về hotplug của thiết bị bộ nhớ mới, ACPI
trình điều khiển sẽ cắm nóng bộ nhớ vào Linux.

Nếu phần sụn hỗ trợ cắm nóng các nút NUMA, nó sẽ xác định một đối tượng _HID
"ACPI0004", "PNP0A05" hoặc "PNP0A06". Khi được thông báo về một sự kiện hotplug, tất cả
các thiết bị bộ nhớ được chỉ định sẽ được thêm vào Linux bằng trình điều khiển ACPI.

Tương tự, Linux có thể được thông báo về các yêu cầu rút phích cắm nóng của thiết bị bộ nhớ hoặc
nút NUMA thông qua ACPI. Trình điều khiển ACPI sẽ thử ngoại tuyến tất cả bộ nhớ có liên quan
chặn và nếu thành công, hãy rút phích cắm bộ nhớ khỏi Linux.

Thăm dò thủ công
----------------

Trên một số kiến trúc, phần sụn có thể không thông báo được cho hệ điều hành
hệ thống về sự kiện cắm nóng bộ nhớ. Thay vào đó, bộ nhớ phải được xử lý thủ công
được thăm dò từ không gian người dùng.

Giao diện thăm dò được đặt tại::

/sys/thiết bị/hệ thống/bộ nhớ/thăm dò

Chỉ có thể thăm dò các khối bộ nhớ hoàn chỉnh. Các khối bộ nhớ riêng lẻ được thăm dò
bằng cách cung cấp địa chỉ bắt đầu vật lý của khối bộ nhớ::

% echo addr > /sys/devices/system/memory/probe

Điều này dẫn đến khối bộ nhớ cho phạm vi [addr, addr + Memory_block_size)
đang được tạo ra.

.. note::

  Using the probe interface is discouraged as it is easy to crash the kernel,
  because Linux cannot validate user input; this interface might be removed in
  the future.

Khối bộ nhớ trực tuyến và ngoại tuyến
=====================================

Sau khi một khối bộ nhớ được tạo ra, Linux phải được hướng dẫn thực sự
tận dụng bộ nhớ đó: khối bộ nhớ phải "trực tuyến".

Trước khi có thể xóa khối bộ nhớ, Linux phải ngừng sử dụng bất kỳ phần bộ nhớ nào của
khối bộ nhớ: khối bộ nhớ phải ở chế độ "ngoại tuyến".

Nhân Linux có thể được cấu hình để tự động thêm các khối bộ nhớ trực tuyến
và trình điều khiển tự động kích hoạt tính năng ngoại tuyến của các khối bộ nhớ khi thử
rút phích cắm nóng của bộ nhớ. Khối bộ nhớ chỉ có thể được xóa sau khi ngoại tuyến thành công
và trình điều khiển có thể kích hoạt ngoại tuyến các khối bộ nhớ khi cố gắng rút phích cắm nóng của
trí nhớ.

Khối bộ nhớ trực tuyến theo cách thủ công
-----------------------------------------

Nếu tính năng tự động trực tuyến của các khối bộ nhớ không được bật, không gian người dùng phải được thực hiện theo cách thủ công
kích hoạt trực tuyến các khối bộ nhớ. Thông thường, các quy tắc udev được sử dụng để tự động hóa việc này
nhiệm vụ trong không gian người dùng.

Việc trực tuyến hóa khối bộ nhớ có thể được kích hoạt thông qua ::

% echo trực tuyến > /sys/devices/system/memory/memoryXXX/state

Hoặc cách khác::

% echo 1 > /sys/devices/system/memory/memoryXXX/online

Hạt nhân sẽ tự động chọn vùng mục tiêu, tùy thuộc vào
được cấu hình ZZ0000ZZ.

Người ta có thể yêu cầu rõ ràng việc liên kết một khối bộ nhớ ngoại tuyến với
ZONE_MOVABLE bởi::

% echo online_movable > /sys/devices/system/memory/memoryXXX/state

Hoặc người ta có thể yêu cầu rõ ràng một vùng kernel (thường là ZONE_NORMAL) bằng cách ::

% echo online_kernel > /sys/devices/system/memory/memoryXXX/state

Trong mọi trường hợp, nếu trực tuyến thành công, trạng thái của khối bộ nhớ sẽ được thay đổi thành
được "trực tuyến". Nếu thất bại, trạng thái của khối bộ nhớ sẽ không thay đổi
và các lệnh trên sẽ thất bại.

Khối bộ nhớ trực tuyến tự động
------------------------------------

Hạt nhân có thể được cấu hình để thử tự động trực tuyến các khối bộ nhớ mới được thêm vào.
Nếu tính năng này bị tắt, các khối bộ nhớ sẽ ở trạng thái ngoại tuyến cho đến khi
trực tuyến rõ ràng từ không gian người dùng.

Hành vi tự động trực tuyến được định cấu hình có thể được quan sát thông qua ::

% cat /sys/devices/system/memory/auto_online_blocks

Tự động trực tuyến có thể được kích hoạt bằng cách viết ZZ0000ZZ, ZZ0001ZZ hoặc
ZZ0002ZZ vào tệp đó, như::

% echo trực tuyến > /sys/devices/system/memory/auto_online_blocks

Tương tự như trực tuyến thủ công, với ZZ0000ZZ kernel sẽ chọn
vùng mục tiêu tự động, tùy thuộc vào ZZ0001ZZ được cấu hình.

Việc sửa đổi hành vi tự động trực tuyến sẽ chỉ ảnh hưởng đến tất cả các nội dung được thêm sau đó
chỉ các khối bộ nhớ.

.. note::

  In corner cases, auto-onlining can fail. The kernel won't retry. Note that
  auto-onlining is not expected to fail in default configurations.

.. note::

  DLPAR on ppc64 ignores the ``offline`` setting and will still online added
  memory blocks; if onlining fails, memory blocks are removed again.

Khối bộ nhớ ngoại tuyến
-----------------------

Trong quá trình triển khai hiện tại, tính năng ngoại tuyến bộ nhớ của Linux sẽ thử di chuyển tất cả
các trang có thể di chuyển ra khỏi khối bộ nhớ bị ảnh hưởng. Như hầu hết các phân bổ hạt nhân, chẳng hạn như
bảng trang không thể di chuyển được, việc di chuyển trang có thể thất bại và do đó cản trở
bộ nhớ ngoại tuyến từ thành công.

Có bộ nhớ được cung cấp bởi khối bộ nhớ được ZONE_MOVABLE quản lý đáng kể
tăng độ tin cậy ngoại tuyến của bộ nhớ; Tuy nhiên, việc ngoại tuyến bộ nhớ có thể bị lỗi
một số trường hợp góc.

Hơn nữa, việc ngoại tuyến bộ nhớ có thể thử lại trong một thời gian dài (hoặc thậm chí là mãi mãi), cho đến khi
bị người dùng hủy bỏ.

Việc ngoại tuyến khối bộ nhớ có thể được kích hoạt thông qua ::

% echo ngoại tuyến > /sys/devices/system/memory/memoryXXX/state

Hoặc cách khác::

% echo 0 > /sys/devices/system/memory/memoryXXX/online

Nếu ngoại tuyến thành công, trạng thái của khối bộ nhớ sẽ thay đổi thành "ngoại tuyến".
Nếu thất bại, trạng thái của khối bộ nhớ sẽ không thay đổi và trạng thái trên
các lệnh sẽ thất bại, ví dụ: thông qua ::

bash: echo: lỗi ghi: Thiết bị hoặc tài nguyên đang bận

hoặc thông qua::

bash: echo: lỗi ghi: Đối số không hợp lệ

Quan sát trạng thái của khối bộ nhớ
------------------------------------

Có thể quan sát trạng thái (trực tuyến/ngoại tuyến/ngoại tuyến) của khối bộ nhớ
hoặc thông qua::

% cat /sys/devices/system/memory/memoryXXX/state

Hoặc cách khác (1/0) qua::

% cat /sys/devices/system/memory/memoryXXX/online

Đối với khối bộ nhớ trực tuyến, vùng quản lý có thể được quan sát thông qua::

% cat /sys/devices/system/memory/memoryXXX/valid_zones

Định cấu hình phích cắm nóng (Un) bộ nhớ
========================================

Có nhiều cách khác nhau để quản trị viên hệ thống có thể định cấu hình bộ nhớ
cắm nóng (un) và tương tác với các khối bộ nhớ, đặc biệt là trực tuyến chúng.

Cấu hình cắm bộ nhớ nóng (Un) thông qua Sysfs
---------------------------------------------

Một số thuộc tính cắm nóng (un) bộ nhớ có thể được định cấu hình hoặc kiểm tra thông qua sysfs trong ::

/sys/thiết bị/hệ thống/bộ nhớ/

Các tệp sau đây hiện được xác định:

=====================================================================================
ZZ0000ZZ đọc-ghi: đặt hoặc lấy trạng thái mặc định của bộ nhớ mới
		       khối; cấu hình tự động trực tuyến.

Giá trị mặc định phụ thuộc vào
		       Cấu hình hạt nhân CONFIG_MHP_DEFAULT_ONLINE_TYPE
		       tùy chọn.

Xem thuộc tính ZZ0000ZZ của khối bộ nhớ để biết chi tiết.
ZZ0001ZZ chỉ đọc: kích thước tính bằng byte của khối bộ nhớ.
ZZ0002ZZ chỉ ghi: thêm (thăm dò) các khối bộ nhớ đã chọn theo cách thủ công
		       từ không gian người dùng bằng cách cung cấp địa chỉ bắt đầu vật lý.

Tính sẵn có tùy thuộc vào CONFIG_ARCH_MEMORY_PROBE
		       tùy chọn cấu hình kernel.
ZZ0000ZZ đọc-ghi: tệp udev chung cho các hệ thống con của thiết bị.
ZZ0001ZZ chỉ đọc: khi thay đổi bản đồ bộ nhớ hệ thống
		       xảy ra do tháo/cắm nóng bộ nhớ, tập tin này chứa
		       '1' nếu kernel cập nhật bộ nhớ kernel chụp kdump
		       bản đồ chính nó (thông qua elfcorehdr và kexec có liên quan khác
		       phân đoạn) hoặc '0' nếu không gian người dùng phải cập nhật kdump
		       chụp bản đồ bộ nhớ kernel.

Tính khả dụng tùy thuộc vào kernel CONFIG_MEMORY_HOTPLUG
		       tùy chọn cấu hình.
=====================================================================================

.. note::

  When the CONFIG_MEMORY_FAILURE kernel configuration option is enabled, two
  additional files ``hard_offline_page`` and ``soft_offline_page`` are available
  to trigger hwpoisoning of pages, for example, for testing purposes. Note that
  this functionality is not really related to memory hot(un)plug or actual
  offlining of memory blocks.

Cấu hình khối bộ nhớ thông qua Sysfs
------------------------------------

Mỗi khối bộ nhớ được biểu diễn dưới dạng một thiết bị khối bộ nhớ có thể được
trực tuyến hoặc ngoại tuyến. Tất cả các khối bộ nhớ đều có thông tin thiết bị của chúng nằm trong
sysfs. Mỗi khối bộ nhớ hiện tại được liệt kê dưới
ZZ0000ZZ như::

/sys/thiết bị/hệ thống/bộ nhớ/bộ nhớXXX

trong đó XXX là id khối bộ nhớ; số chữ số có thể thay đổi.

Khối bộ nhớ hiện tại cho biết có một số bộ nhớ trong phạm vi;
tuy nhiên, khối bộ nhớ có thể mở rộng các lỗ bộ nhớ. Khối bộ nhớ bao trùm bộ nhớ
lỗ không thể được ngoại tuyến.

Ví dụ: giả sử kích thước khối bộ nhớ 1 GiB. Một thiết bị cho bộ nhớ bắt đầu từ
0x100000000 là ZZ0000ZZ::

(0x100000000 / 1Gib = 4)

Thiết bị này bao gồm phạm vi địa chỉ [0x100000000 ... 0x140000000)

Các tệp sau đây hiện được xác định:

=================== ==================================================================
ZZ0000ZZ đọc-ghi: giao diện đơn giản hóa để kích hoạt trực tuyến /
		    ngoại tuyến và quan sát trạng thái của khối bộ nhớ.
		    Khi trực tuyến, vùng được chọn tự động.
ZZ0001ZZ chỉ đọc: giao diện cũ chỉ được sử dụng trên s390x
		    để lộ mức tăng dung lượng lưu trữ được bảo hiểm.
ZZ0002ZZ chỉ đọc: id khối bộ nhớ (XXX).
ZZ0003ZZ chỉ đọc: giao diện kế thừa cho biết liệu bộ nhớ có
		    khối có khả năng ngoại tuyến hay không. Ngày nay, các
		    kernel trả về ZZ0004ZZ khi và chỉ khi nó hỗ trợ bộ nhớ
		    ngoại tuyến.
ZZ0005ZZ đọc-ghi: giao diện nâng cao để kích hoạt trực tuyến /
		    ngoại tuyến và quan sát trạng thái của khối bộ nhớ.

Khi viết, ZZ0000ZZ, ZZ0001ZZ, ZZ0002ZZ và
		    ZZ0003ZZ được hỗ trợ.

ZZ0000ZZ chỉ định trực tuyến tới ZONE_MOVABLE.
		    ZZ0001ZZ chỉ định trực tuyến cho kernel mặc định
		    vùng cho khối bộ nhớ, chẳng hạn như ZONE_NORMAL.
                    ZZ0002ZZ hãy để kernel tự động chọn vùng.

Khi đọc, ZZ0000ZZ, ZZ0001ZZ và ZZ0002ZZ
		    có thể được trả lại.
ZZ0003ZZ đọc-ghi: tệp sự kiện chung cho thiết bị.
ZZ0004ZZ chỉ đọc: khi một khối trực tuyến, hiển thị vùng đó
		    thuộc về ; khi một khối ngoại tuyến, hiển thị vùng nào sẽ
		    quản lý nó khi khối sẽ được trực tuyến.

Đối với các khối bộ nhớ trực tuyến, ZZ0000ZZ, ZZ0001ZZ, ZZ0002ZZ,
		    ZZ0003ZZ và ZZ0004ZZ có thể được trả lại. ZZ0005ZZ chỉ ra
		    bộ nhớ được cung cấp bởi khối bộ nhớ được quản lý bởi
		    nhiều vùng hoặc trải rộng trên nhiều nút; khối bộ nhớ như vậy
		    không thể ngoại tuyến. ZZ0006ZZ biểu thị ZONE_MOVABLE.
		    Các giá trị khác biểu thị vùng hạt nhân.

Đối với các khối bộ nhớ ngoại tuyến, cột đầu tiên hiển thị
		    vùng hạt nhân sẽ chọn khi trực tuyến khối bộ nhớ
		    ngay bây giờ mà không cần chỉ định thêm một khu vực.

Tính sẵn có tùy thuộc vào CONFIG_MEMORY_HOTREMOVE
		    tùy chọn cấu hình kernel.
=================== ==================================================================

.. note::

  If the CONFIG_NUMA kernel configuration option is enabled, the memoryXXX/
  directories can also be accessed via symbolic links located in the
  ``/sys/devices/system/node/node*`` directories.

  For example::

	/sys/devices/system/node/node0/memory9 -> ../../memory/memory9

  A backlink will also be created::

	/sys/devices/system/memory/memory9/node0 -> ../../node/node0

Tham số dòng lệnh
-----------------------

Một số tham số dòng lệnh ảnh hưởng đến việc xử lý cắm nóng (rút) bộ nhớ. Sau đây
tham số dòng lệnh có liên quan:

=====================================================================================
ZZ0000ZZ định cấu hình tự động trực tuyến bằng cách cài đặt cơ bản
                         ZZ0001ZZ.
ZZ0002ZZ cấu hình lựa chọn vùng tự động trong kernel khi
			 sử dụng chính sách trực tuyến ZZ0003ZZ. Khi nào
			 được thiết lập, kernel sẽ mặc định là ZONE_MOVABLE khi
			 trực tuyến một khối bộ nhớ, trừ khi các vùng khác có thể được giữ lại
			 tiếp giáp.
=====================================================================================

Xem Documentation/admin-guide/kernel-parameters.txt để biết thông tin chung hơn
mô tả các tham số dòng lệnh này.

Thông số mô-đun
------------------

Thay vì các tham số dòng lệnh hoặc tệp sysfs bổ sung,
Hệ thống con ZZ0000ZZ hiện cung cấp không gian tên dành riêng cho mô-đun
các thông số. Các tham số mô-đun có thể được đặt thông qua dòng lệnh bằng cách dự đoán
chúng với ZZ0001ZZ chẳng hạn như::

bộ nhớ_hotplug.memmap_on_memory=1

và chúng có thể được quan sát (và một số thậm chí được sửa đổi khi chạy) thông qua ::

/sys/mô-đun/memory_hotplug/tham số/

Các tham số mô-đun sau hiện được xác định:

=====================================================================================
ZZ0000ZZ đọc-ghi: Phân bổ bộ nhớ cho memmap từ
				 chính khối bộ nhớ được thêm vào. Ngay cả khi được kích hoạt,
				 hỗ trợ thực tế phụ thuộc vào nhiều hệ thống khác
				 thuộc tính và chỉ nên được coi là một
				 gợi ý liệu hành vi đó có được mong muốn hay không.

Trong khi phân bổ memmap từ bộ nhớ
				 chính khối đó làm cho khả năng cắm nóng bộ nhớ ít hơn
				 không thành công và giữ bản đồ ghi nhớ trên cùng NUMA
				 nút trong mọi trường hợp, nó có thể phân mảnh vật lý
				 bộ nhớ theo cách mà các trang lớn sẽ lớn hơn
				 độ chi tiết không thể được hình thành trên cắm nóng
				 trí nhớ.

Với giá trị "lực" nó có thể dẫn đến bộ nhớ
				 lãng phí do giới hạn kích thước memmap. cho
				 ví dụ: nếu bản đồ ghi nhớ cho một khối bộ nhớ
				 yêu cầu 1 MiB, nhưng kích thước khối trang là 2
				 MiB, 1 MiB bộ nhớ cắm nóng sẽ bị lãng phí.
				 Lưu ý rằng vẫn có trường hợp
				 tính năng này không thể được thực thi: ví dụ: nếu
				 memmap nhỏ hơn một trang hoặc nếu
				 kiến trúc không hỗ trợ chế độ bắt buộc
				 trong mọi cấu hình.

ZZ0000ZZ đọc-ghi: Đặt chính sách cơ bản được sử dụng cho
				 lựa chọn vùng tự động khi bộ nhớ trực tuyến
				 khối mà không chỉ định vùng mục tiêu.
				 ZZ0001ZZ là kernel mặc định
				 trước khi tham số này được thêm vào. Sau một
				 chính sách trực tuyến đã được cấu hình và bộ nhớ đã được
				 trực tuyến, chính sách không nên thay đổi
				 nữa.

Khi được đặt thành ZZ0000ZZ, kernel sẽ
				 hãy thử giữ các khu vực liền kề nhau. Nếu một khối bộ nhớ
				 giao nhau với nhiều vùng hoặc không có vùng nào,
				 hành vi phụ thuộc vào kernel ZZ0001ZZ
				 tham số dòng lệnh: mặc định là ZONE_MOVABLE
				 nếu được đặt, mặc định là vùng kernel áp dụng
				 (thường là ZONE_NORMAL) nếu không được đặt.

Khi được đặt thành ZZ0000ZZ, kernel sẽ
				 thử gắn các khối bộ nhớ trực tuyến vào ZONE_MOVABLE nếu
				 có thể theo cấu hình và
				 chi tiết thiết bị bộ nhớ. Với chính sách này, một
				 có thể tránh sự mất cân bằng vùng khi cuối cùng
				 cắm nóng rất nhiều bộ nhớ sau đó mà vẫn
				 muốn có thể rút phích cắm nóng càng nhiều càng tốt
				 có thể đáng tin cậy, rất mong muốn trong
				 môi trường ảo hóa. Chính sách này bỏ qua
				 dòng lệnh hạt nhân ZZ0001ZZ
				 tham số và không thực sự áp dụng được trong
				 môi trường yêu cầu nó (ví dụ: kim loại trần
				 với các nút có thể cắm nóng) nơi được cắm nóng
				 bộ nhớ có thể bị lộ thông qua
				 bản đồ bộ nhớ do chương trình cơ sở cung cấp sớm trong khi khởi động
				 vào hệ thống thay vì bị phát hiện,
				 được thêm và trực tuyến sau trong khi khởi động (chẳng hạn như
				 được thực hiện bởi virtio-mem hoặc bởi một số nhà giám sát ảo
				 triển khai DIMM mô phỏng). Như một ví dụ, một
				 DIMM đã được cắm nóng cũng sẽ được trực tuyến
				 hoàn toàn đến ZONE_MOVABLE hoặc hoàn toàn đến
				 ZONE_NORMAL, không phải hỗn hợp.
				 Một ví dụ khác, càng nhiều khối bộ nhớ
				 thuộc về một thiết bị virtio-mem sẽ
				 trực tuyến tới ZONE_MOVABLE càng tốt,
				 các khối bộ nhớ có vỏ đặc biệt có thể
				 chỉ được cắm nóng cùng nhau. *Chính sách này
				 không bảo vệ khỏi các thiết lập
				 có vấn đề với ZONE_MOVABLE và không
				 thay đổi vùng khối bộ nhớ một cách linh hoạt
				 sau khi chúng được trực tuyến.*
ZZ0002ZZ đọc-ghi: Đặt mức tối đa MOVABLE:KERNEL
				 tỷ lệ bộ nhớ tính bằng % cho ZZ0003ZZ
				 chính sách trực tuyến. Tỷ lệ này chỉ áp dụng
				 cho hệ thống trên tất cả các nút NUMA hoặc cả
				 mỗi nút NUMA phụ thuộc vào
				 Cấu hình ZZ0004ZZ.

Tất cả việc tính toán đều dựa trên các trang bộ nhớ hiện tại
				 trong các khu vực kết hợp với kế toán mỗi
				 thiết bị bộ nhớ. Bộ nhớ dành riêng cho CMA
				 bộ cấp phát được tính là MOVABLE, mặc dù
				 cư trú trên một trong các vùng hạt nhân. các
				 tỷ lệ có thể phụ thuộc vào khối lượng công việc thực tế.
				 Ví dụ, mặc định kernel là "301"%,
				 cho phép cắm nóng 24 GiB vào máy ảo 8 GiB
				 và tự động trực tuyến tất cả các cắm nóng
				 bộ nhớ vào ZONE_MOVABLE trong nhiều thiết lập. các
				 giao dịch bổ sung 1% với một số trang không
				 hiện tại, ví dụ, vì một số phần sụn
				 phân bổ.

Lưu ý rằng bộ nhớ ZONE_NORMAL được cung cấp bởi một
				 thiết bị bộ nhớ không cho phép nhiều hơn
				 Bộ nhớ ZONE_MOVABLE cho bộ nhớ khác
				 thiết bị. Một ví dụ, bộ nhớ trực tuyến của một
				 cắm nóng DIMM vào ZONE_NORMAL sẽ không cho phép
				 để một DIMM được cắm nóng khác có thể truy cập trực tuyến
				 ZONE_MOVABLE tự động. Ngược lại, trí nhớ
				 được cắm nóng bởi một thiết bị virtio-mem có
				 trực tuyến tới ZONE_NORMAL sẽ cho phép nhiều hơn nữa
				 Bộ nhớ ZONE_MOVABLE trong ZZ0003ZZ
				 thiết bị virtio-mem.
ZZ0000ZZ đọc-ghi: Định cấu hình xem
				 ZZ0001ZZ trong ZZ0002ZZ
				 chính sách trực tuyến cũng được áp dụng cho mỗi NUMA
				 nút ngoài toàn bộ hệ thống trên tất cả
				 Các nút NUMA. Mặc định kernel là "Y".

Vô hiệu hóa nhận thức NUMA có thể hữu ích khi
				 xử lý các nút NUMA cần phải
				 hoàn toàn có thể cắm nóng, trực tuyến bộ nhớ
				 hoàn toàn tự động sang ZONE_MOVABLE nếu
				 có thể.

Tính khả dụng của thông số phụ thuộc vào CONFIG_NUMA.
=====================================================================================

ZONE_MOVABLE
============

ZONE_MOVABLE là một cơ chế quan trọng giúp bộ nhớ ngoại tuyến đáng tin cậy hơn.
Hơn nữa, có hệ thống RAM được quản lý bởi ZONE_MOVABLE thay vì một trong các
vùng hạt nhân có thể tăng số lượng trang lớn trong suốt có thể và
các trang lớn được phân bổ động.

Hầu hết các phân bổ hạt nhân đều không thể di chuyển được. Các ví dụ quan trọng bao gồm bộ nhớ
bản đồ (thường là 1/64 bộ nhớ), bảng trang và kmalloc(). Việc phân bổ như vậy
chỉ có thể được phục vụ từ vùng kernel.

Hầu hết các trang không gian người dùng, chẳng hạn như bộ nhớ ẩn danh và các trang bộ đệm trang đều được
di chuyển được. Việc phân bổ như vậy có thể được phục vụ từ ZONE_MOVABLE và các vùng kernel.

Chỉ phân bổ có thể di chuyển được phân phát từ ZONE_MOVABLE, dẫn đến phân bổ không thể di chuyển
phân bổ bị giới hạn trong các vùng hạt nhân. Nếu không có ZONE_MOVABLE thì có
hoàn toàn không có gì đảm bảo liệu một khối bộ nhớ có thể được ngoại tuyến thành công hay không.

Mất cân bằng vùng
-----------------

Có quá nhiều hệ thống RAM do ZONE_MOVABLE quản lý được gọi là mất cân bằng vùng,
có thể gây hại cho hệ thống hoặc làm giảm hiệu suất. Một ví dụ, hạt nhân
có thể bị sập vì hết bộ nhớ trống cho các phân bổ không thể di chuyển,
mặc dù vẫn còn nhiều bộ nhớ trống trong ZONE_MOVABLE.

Thông thường, tỷ lệ MOVABLE:KERNEL lên tới 3:1 hoặc thậm chí 4:1 là ổn. Tỷ lệ 63:1
chắc chắn là không thể do chi phí cho bản đồ bộ nhớ.

Tỷ lệ vùng an toàn thực tế phụ thuộc vào khối lượng công việc. Những trường hợp cực đoan, như quá mức
việc ghim các trang trong thời gian dài có thể không giải quyết được ZONE_MOVABLE.

.. note::

  CMA memory part of a kernel zone essentially behaves like memory in
  ZONE_MOVABLE and similar considerations apply, especially when combining
  CMA with ZONE_MOVABLE.

Cân nhắc về kích thước ZONE_MOVABLE
-----------------------------------

Chúng tôi thường mong đợi rằng một phần lớn hệ thống RAM có sẵn sẽ thực sự
được sử dụng bởi không gian người dùng, trực tiếp hoặc gián tiếp thông qua bộ đệm trang. trong
trong trường hợp bình thường, ZONE_MOVABLE có thể được sử dụng khi phân bổ các trang như vậy một cách tốt đẹp.

Với ý nghĩ đó, thật hợp lý khi chúng ta có thể có một phần lớn hệ thống RAM
được quản lý bởi ZONE_MOVABLE. Tuy nhiên, có một số điều cần cân nhắc khi sử dụng
ZONE_MOVABLE, đặc biệt khi tinh chỉnh tỷ lệ vùng:

- Có nhiều khối bộ nhớ ngoại tuyến. Ngay cả khối bộ nhớ ngoại tuyến cũng tiêu thụ
  bộ nhớ dành cho siêu dữ liệu và bảng trang trong bản đồ trực tiếp; có rất nhiều ngoại tuyến
  Tuy nhiên, khối bộ nhớ không phải là trường hợp điển hình.

- Tăng vọt bộ nhớ mà không hỗ trợ di chuyển bộ nhớ bong bóng là không tương thích
  với ZONE_MOVABLE. Chỉ một số triển khai, chẳng hạn như virtio-balloon và
  pseries CMM, hỗ trợ đầy đủ việc di chuyển bộ nhớ bong bóng.

Hơn nữa, tùy chọn cấu hình kernel CONFIG_BALLOON_MIGRATION có thể là
  bị vô hiệu hóa. Trong trường hợp đó, lạm phát bong bóng sẽ chỉ thực hiện không thể di chuyển được.
  phân bổ và âm thầm tạo ra sự mất cân bằng vùng, thường được kích hoạt bởi
  yêu cầu lạm phát từ hypervisor.

- Các trang khổng lồ không thể di chuyển được khi kiến trúc không hỗ trợ
  di chuyển trang lớn và/hoặc sysctl ZZ0000ZZ là sai.
  Xem Tài liệu/admin-guide/sysctl/vm.rst để biết thêm thông tin về sysctl này.

- Các trang lớn không thể di chuyển được khi kiến trúc không hỗ trợ các trang lớn
  di chuyển trang, dẫn đến vấn đề tương tự như với các trang khổng lồ.

- Bảng trang không thể di chuyển được. Trao đổi quá nhiều, ánh xạ cực lớn
  các tập tin hoặc bộ nhớ ZONE_DEVICE có thể có vấn đề, mặc dù chỉ thực sự có liên quan
  trong trường hợp góc. Khi chúng tôi quản lý nhiều bộ nhớ không gian người dùng đã bị
  bị tráo đổi hoặc được phục vụ từ một tập tin/bộ nhớ liên tục/... chúng tôi vẫn cần rất nhiều
  bảng trang để quản lý bộ nhớ đó khi không gian người dùng truy cập vào bộ nhớ đó.

- Trong một số cấu hình DAX nhất định, bản đồ bộ nhớ cho bộ nhớ thiết bị sẽ là
  được phân bổ từ các vùng kernel.

- KASAN có thể tiêu tốn nhiều bộ nhớ, chẳng hạn như tiêu thụ 1/8
  tổng kích thước bộ nhớ hệ thống dưới dạng siêu dữ liệu theo dõi (không thể di chuyển).

- Ghim trang lâu dài. Các kỹ thuật dựa vào việc ghim lâu dài
  (đặc biệt là RDMA và vfio/mdev) về cơ bản có vấn đề với
  ZONE_MOVABLE, và do đó, bộ nhớ ngoại tuyến. Các trang được ghim không thể cư trú
  trên ZONE_MOVABLE vì điều đó sẽ khiến các trang này không thể di chuyển được. Vì vậy, họ
  phải được di chuyển ra khỏi vùng đó trong khi ghim. Việc ghim một trang có thể không thành công
  ngay cả khi có nhiều bộ nhớ trống trong ZONE_MOVABLE.

Ngoài ra, việc sử dụng ZONE_MOVABLE có thể khiến việc ghim trang trở nên tốn kém hơn,
  vì chi phí di chuyển trang.

Theo mặc định, tất cả bộ nhớ được cấu hình khi khởi động đều được quản lý bởi kernel
vùng và ZONE_MOVABLE không được sử dụng.

Để cho phép ZONE_MOVABLE bao gồm bộ nhớ có khi khởi động và điều khiển
Tỷ lệ giữa vùng di động và vùng kernel có hai tùy chọn dòng lệnh:
ZZ0000ZZ và ZZ0001ZZ. Xem
Tài liệu/admin-guide/kernel-parameters.rst cho mô tả của họ.

Bộ nhớ ngoại tuyến và ZONE_MOVABLE
----------------------------------

Ngay cả với ZONE_MOVABLE, vẫn có một số trường hợp ngoại tuyến bộ nhớ.
khối có thể thất bại:

- Khối bộ nhớ có lỗ bộ nhớ; điều này áp dụng cho các khối bộ nhớ hiện diện trong
  khởi động và có thể áp dụng cho các khối bộ nhớ được cắm nóng thông qua bóng XEN và
  Bóng bay Hyper-V.

- Các nút NUMA hỗn hợp và các vùng hỗn hợp trong một khối bộ nhớ duy nhất ngăn chặn bộ nhớ
  ngoại tuyến; điều này chỉ áp dụng cho các khối bộ nhớ có trong quá trình khởi động.

- Các khối bộ nhớ đặc biệt được hệ thống ngăn không cho ngoại tuyến. Ví dụ
  bao gồm mọi bộ nhớ có sẵn trong quá trình khởi động trên arm64 hoặc mở rộng các khối bộ nhớ
  khu vực Crashkernel trên s390x; điều này thường áp dụng cho các khối bộ nhớ hiện có
  chỉ trong khi khởi động.

- Không thể ngoại tuyến các khối bộ nhớ chồng chéo với các vùng CMA, điều này áp dụng cho
  khối bộ nhớ chỉ xuất hiện trong khi khởi động.

- Hoạt động đồng thời hoạt động trên cùng một vùng bộ nhớ vật lý, chẳng hạn như
  phân bổ các trang khổng lồ có thể dẫn đến lỗi ngoại tuyến tạm thời.

- Khi quản trị viên đặt sysctl ZZ0000ZZ thành true, khổng lồ
  các trang được phép trong ZONE_MOVABLE.  Điều này chỉ cho phép di chuyển khổng lồ
  các trang được phân bổ; tuy nhiên, nếu không có điểm đến đủ điều kiện khổng lồ
  các trang ngoại tuyến, thao tác ngoại tuyến sẽ thất bại.

Người dùng tận dụng ZZ0000ZZ nên cân nhắc giá trị của
  ZONE_MOVABLE để tăng độ tin cậy của việc phân bổ trang khổng lồ
  chống lại khả năng mất độ tin cậy khi rút phích cắm nóng.

- Hết bộ nhớ khi giải thể các trang lớn, đặc biệt khi HugeTLB Vmemmap
  Tối ưu hóa (HVO) được bật.

Mã ngoại tuyến có thể di chuyển được nội dung trang lớn, nhưng có thể không
  để giải thể trang lớn nguồn vì nó không phân bổ được các trang (không thể di chuyển)
  đối với vmemmap, vì hệ thống có thể không có bộ nhớ trống trong kernel
  các khu còn lại.

Người dùng phụ thuộc vào việc ngoại tuyến bộ nhớ để thành công đối với các vùng có thể di chuyển nên
  xem xét cẩn thận liệu mức tiết kiệm bộ nhớ có được từ tính năng này có
  có nguy cơ không thể lưu trữ bộ nhớ ngoại tuyến trong một số trường hợp nhất định
  tình huống.

Hơn nữa, khi gặp tình huống hết bộ nhớ trong khi di chuyển trang hoặc
khi vẫn gặp phải các trang vĩnh viễn không thể di chuyển được trong ZONE_MOVABLE
(-> BUG), việc ngoại tuyến bộ nhớ sẽ tiếp tục thử lại cho đến khi thành công.

Khi ngoại tuyến được kích hoạt từ không gian người dùng, bối cảnh ngoại tuyến có thể được
kết thúc bằng cách gửi tín hiệu. Có thể dễ dàng thực hiện việc ngoại tuyến dựa trên thời gian chờ
được thực hiện thông qua::

% thời gian chờ $TIMEOUT offline_block | xử lý thất bại
