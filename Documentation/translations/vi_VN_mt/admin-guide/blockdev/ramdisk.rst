.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/admin-guide/blockdev/ramdisk.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

==============================================
Sử dụng thiết bị chặn đĩa RAM với Linux
==============================================

.. Contents:

	1) Overview
	2) Kernel Command Line Parameters
	3) Using "rdev"
	4) An Example of Creating a Compressed RAM Disk


1) Tổng quan
------------

Trình điều khiển đĩa RAM là một cách sử dụng bộ nhớ hệ thống chính làm thiết bị khối.  Nó
là bắt buộc đối với initrd, hệ thống tập tin ban đầu được sử dụng nếu bạn cần tải các mô-đun
để truy cập hệ thống tập tin gốc (xem Tài liệu/admin-guide/initrd.rst).  Nó có thể
cũng có thể được sử dụng làm hệ thống tệp tạm thời cho công việc mã hóa, vì nội dung
sẽ bị xóa khi khởi động lại.

Đĩa RAM tự động phát triển khi cần nhiều dung lượng hơn. Nó thực hiện điều này bằng cách sử dụng
RAM từ bộ đệm đệm. Trình điều khiển đánh dấu bộ đệm mà nó đang sử dụng là bẩn
để hệ thống con VM không cố gắng lấy lại chúng sau này.

Theo mặc định, đĩa RAM hỗ trợ tối đa 16 đĩa RAM và có thể được cấu hình lại
để hỗ trợ số lượng đĩa RAM không giới hạn (bạn tự chịu rủi ro).  Chỉ cần thay đổi
biểu tượng cấu hình BLK_DEV_RAM_COUNT trong menu cấu hình Trình điều khiển khối
và (tái) xây dựng hạt nhân.

Để sử dụng hỗ trợ đĩa RAM với hệ thống của bạn, hãy chạy './MAKEDEV ram' từ /dev
thư mục.  Các đĩa RAM đều có số chính 1 và bắt đầu bằng số 0 phụ
cho /dev/ram0, v.v. Nếu được sử dụng, các hạt nhân hiện đại sẽ sử dụng /dev/ram0 cho initrd.

Đĩa RAM mới cũng có khả năng tải ảnh đĩa RAM đã nén,
cho phép người ta chèn thêm nhiều chương trình vào một bản cài đặt trung bình hoặc
cứu đĩa mềm.


2) Thông số
---------------------------------

2a) Tham số dòng lệnh hạt nhân

ramdisk_size=N
		Kích thước của đĩa RAM.

Tham số này yêu cầu trình điều khiển đĩa RAM thiết lập các đĩa RAM có kích thước N k.  các
mặc định là 4096 (4 MB).

2b) Thông số mô-đun

thứ_nr
		Đã tạo thiết bị /dev/ramX.

phần tối đa
		Số phân vùng tối đa.

thứ_kích thước
		Xem ramdisk_size.

3) Sử dụng "rdev"
-----------------

"rdev" là một tiện ích lỗi thời, không được dùng nữa, có thể được sử dụng
để đặt thiết bị khởi động trong hình ảnh hạt nhân Linux.

Thay vì sử dụng rdev, chỉ cần đặt thông tin thiết bị khởi động vào
dòng lệnh kernel và chuyển nó vào kernel từ bộ nạp khởi động.

Bạn cũng có thể truyền đối số cho kernel bằng cách đặt FDARGS trong
Arch/x86/boot/Makefile và chỉ định trong hình ảnh initrd bằng cách đặt FDINITRD trong
Arch/x86/boot/Makefile.

Một số tùy chọn khởi động dòng lệnh kernel có thể áp dụng ở đây là::

ramdisk_start=N
  ramdisk_size=M

Nếu bạn tạo một đĩa khởi động có LILO, thì với mục đích trên, bạn sẽ sử dụng::

nối thêm = "ramdisk_start=N ramdisk_size=M"

4) Ví dụ về tạo đĩa nén RAM
-----------------------------------------------

Để tạo ảnh đĩa RAM, bạn sẽ cần một thiết bị khối dự phòng để
xây dựng nó trên. Đây có thể là chính thiết bị đĩa RAM hoặc một
phân vùng đĩa không được sử dụng (chẳng hạn như phân vùng trao đổi chưa được đếm). Vì điều này
ví dụ: chúng tôi sẽ sử dụng thiết bị đĩa RAM, "/dev/ram0".

Lưu ý: Kỹ thuật này không nên thực hiện trên máy có dung lượng dưới 8 MB
của RAM. Nếu sử dụng phân vùng đĩa dự phòng thay vì/dev/ram0 thì điều này
hạn chế không được áp dụng.

a) Quyết định kích thước đĩa RAM mà bạn muốn. Nói 2 MB cho ví dụ này.
   Tạo nó bằng cách ghi vào thiết bị đĩa RAM. (Bước này hiện chưa được thực hiện
   cần thiết, nhưng có thể trong tương lai.) Sẽ là khôn ngoan nếu loại bỏ
   khu vực (đặc biệt đối với đĩa) để đạt được độ nén tối đa cho
   các khối hình ảnh chưa sử dụng mà bạn sắp tạo::

dd if=/dev/zero of=/dev/ram0 bs=1k count=2048

b) Tạo một hệ thống tập tin trên đó. Nói ext2fs cho ví dụ này::

mke2fs -vm0 /dev/ram0 2048

c) Mount nó, sao chép các tập tin bạn muốn vào nó (ví dụ: /etc/* /dev/* ...)
   và tháo nó ra lần nữa.

d) Nén nội dung của đĩa RAM. Mức độ nén
   sẽ chiếm khoảng 50% dung lượng được sử dụng bởi các tập tin. Chưa sử dụng
   dung lượng trên đĩa RAM sẽ nén gần như không có gì ::

	dd if=/dev/ram0 bs=1k count=2048 | gzip -v9 > /tmp/ram_image.gz

e) Put the kernel onto the floppy::

	dd if=zImage of=/dev/fd0 bs=1k

f) Put the RAM disk image onto the floppy, after the kernel. Use an offset
   that is slightly larger than the kernel, so that you can put another
   (possibly larger) kernel onto the same floppy later without overlapping
   the RAM disk image. An offset of 400 kB for kernels about 350 kB in
   size would be reasonable. Make sure offset+size of ram_image.gz is
   not larger than the total space on your floppy (usually 1440 kB)::

	dd if=/tmp/ram_image.gz of=/dev/fd0 bs=1k seek=400

g) Make sure that you have already specified the boot information in
   FDARGS and FDINITRD or that you use a bootloader to pass kernel
   command line boot options to the kernel.

That is it. You now have your boot/root compressed RAM disk floppy. Some
users may wish to combine steps (d) and (f) by using a pipe.


						Paul Gortmaker 12/95

Changelog:
----------

SEPT-2020 :

                Removed usage of "rdev"

10-22-04 :
		Updated to reflect changes in command line options, remove
		obsolete references, general cleanup.
		James Nelson (james4765@gmail.com)

12-95 :
		Original Document
