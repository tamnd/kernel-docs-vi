.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/misc-devices/spear-pcie-gadget.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

===========================
Trình điều khiển tiện ích Spear PCIe
========================

Tác giả
======
Pratyush Anand (pratyush.anand@gmail.com)

Vị trí
========
trình điều khiển/linh tinh/spear13xx_pcie_gadget.c

Chip được hỗ trợ:
===============
SPEAR1300
SPEAR1310

Tùy chọn cấu hình menu:
==================
Trình điều khiển thiết bị
	Các thiết bị khác
		Hỗ trợ tiện ích PCIe cho nền tảng SPEAR13XX

mục đích
=======
Trình điều khiển này có một số nút có thể được đọc/ghi bằng giao diện configfs.
Mục đích chính của nó là cấu hình bộ điều khiển PCIe chế độ kép được chọn làm thiết bị
và sau đó lập trình các thanh ghi khác nhau của nó để cấu hình nó như một thiết bị cụ thể
loại. Trình điều khiển này có thể được sử dụng để thể hiện khả năng của thiết bị PCIe của Spear.

Mô tả các nút khác nhau:
===============================

đọc hành vi của các nút:
-----------------------

====================================================================================
liên kết cung cấp trạng thái ltssm.
int_type loại ngắt được hỗ trợ
no_of_msi bằng 0 nếu MSI không được máy chủ bật. Giá trị dương là
		số lượng vectơ MSI được cấp.
nhà cung cấp_id trả về id nhà cung cấp được lập trình (hex)
device_id trả về id thiết bị được lập trình (hex)
bar0_size: trả về kích thước của bar0 ở dạng hex.
bar0_address trả về địa chỉ của vùng được ánh xạ bar0 ở dạng hex.
bar0_rw_offset trả về độ lệch của bar0 mà bar0_data sẽ trả về giá trị.
bar0_data trả về dữ liệu tại bar0_rw_offset.
====================================================================================

viết hành vi của các nút:
------------------------

======================================================================================
liên kết ghi LÊN để bật ltsmm DOWN để tắt
int_type loại ngắt ghi cần được cấu hình và (int_type có thể
		INTA, MSI hoặc NO_INT). Chỉ chọn MSI khi bạn đã lập trình
		nút no_of_msi.
cần có số lượng vectơ MSI no_of_msi.
inta viết 1 để xác nhận INTA và 0 để hủy xác nhận.
send_msi ghi vectơ MSI để gửi.
nhà cung cấp_id ghi id nhà cung cấp (hex) để được lập trình.
device_id ghi id thiết bị (hex) sẽ được lập trình.
bar0_size ghi kích thước của bar0 ở dạng hex. kích thước bar0 mặc định là 1000 (hex)
		byte.
bar0_address ghi địa chỉ của vùng được ánh xạ bar0 ở dạng hex. (ánh xạ mặc định của
		bar0 là SYSRAM1(E0800000). Luôn lập trình kích thước thanh trước thanh
		địa chỉ. Hạt nhân có thể sửa đổi kích thước và địa chỉ thanh để căn chỉnh,
		vì vậy hãy đọc lại kích thước và địa chỉ thanh sau khi viết để kiểm tra chéo.
bar0_rw_offset ghi phần bù của bar0 mà bar0_data sẽ ghi giá trị.
bar0_data ghi dữ liệu sẽ được ghi tại bar0_rw_offset.
======================================================================================

Ví dụ lập trình nút
========================

Lập trình tất cả các thanh ghi PCIe theo cách mà khi thiết bị này được kết nối
đến máy chủ PCIe, sau đó máy chủ sẽ xem thiết bị này là 1MB RAM.

::

#mount -t configfs không có/Cấu hình

Dành cho Bộ điều khiển thiết bị PCIe thứ n::

# cd /config/pcie_gadget.n/

Bây giờ bạn có tất cả các nút trong thư mục này.
id nhà cung cấp chương trình là 0x104a::

# echo 104A >> nhà cung cấp_id

id thiết bị chương trình là 0xCD80::

# echo CD80 >> device_id

chương trình BAR0 có kích thước 1MB::

# echo 100000 >> bar0_size

kiểm tra kích thước bar0 được lập trình::

# cat thanh0_size

Địa chỉ chương trình BAR0 là DDR (0x2100000). Đây là địa chỉ vật lý của
bộ nhớ, được hiển thị cho máy chủ PCIe. Tương tự như vậy với bất kỳ thiết bị ngoại vi nào khác
cũng có thể được hiển thị với máy chủ PCIe. Ví dụ: nếu bạn lập trình địa chỉ cơ sở của UART
là địa chỉ BAR0 thì khi thiết bị này được kết nối với máy chủ, nó sẽ
hiển thị dưới dạng UART.

::

# echo 2100000 >> bar0_address

loại ngắt chương trình: INTA::

# echo INTA >> int_type

hãy liên kết ngay bây giờ::

# echo LÊN >> liên kết

Sẽ phải đảm bảo rằng, sau khi hoàn tất liên kết trên thiết bị thì chỉ có máy chủ lưu trữ
được khởi tạo và bắt đầu tìm kiếm các thiết bị PCIe trên cổng của nó.

::

/ZZ0000ZZ/
    Liên kết # cat

Đợi cho đến khi nó trở về UP.

Để khẳng định INTA::

# echo 1 >> vào

Để hủy xác nhận INTA::

# echo 0 >> vào

nếu MSI được sử dụng làm ngắt, thì không cần chương trình vectơ msi (say4)::

# echo 4 >> no_of_msi

chọn MSI làm loại ngắt::

# echo MSI >> int_type

hãy liên kết ngay bây giờ::

# echo LÊN >> liên kết

đợi cho đến khi liên kết được đưa ra::

liên kết # cat

Một ứng dụng có thể đọc nút này nhiều lần cho đến khi tìm thấy liên kết LÊN. Nó có thể
ngủ giữa hai lần đọc.

đợi cho đến khi msi được kích hoạt::

# cat no_of_msi

Nên trả về 4 (số vectơ MSI được yêu cầu)

để gửi vectơ msi 2::

# echo 2 >> send_msi
    # cd -