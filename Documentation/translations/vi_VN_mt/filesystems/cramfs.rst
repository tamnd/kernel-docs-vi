.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/filesystems/cramfs.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

===============================================
Cramfs - nhồi nhét hệ thống tập tin vào một ROM nhỏ
===========================================

cramfs được thiết kế đơn giản, nhỏ gọn và nén mọi thứ tốt.

Nó sử dụng các thủ tục zlib để nén từng trang một tệp và
cho phép truy cập trang ngẫu nhiên.  Siêu dữ liệu không được nén, nhưng được
được thể hiện bằng một cách trình bày rất ngắn gọn để làm cho nó ít được sử dụng hơn
không gian đĩa hơn các hệ thống tập tin truyền thống.

Bạn không thể ghi vào hệ thống tập tin cramfs (làm cho nó có thể nén và
nhỏ gọn cũng khiến cho việc cập nhật nhanh chóng trở nên _rất_ khó khăn), vì vậy bạn phải
tạo ảnh đĩa bằng tiện ích "mkcramfs".


Ghi chú sử dụng
-----------

Kích thước tệp được giới hạn dưới 16MB.

Kích thước hệ thống tập tin tối đa là hơn 256MB một chút.  (Tệp cuối cùng trên
hệ thống tập tin được phép mở rộng quá 256 MB.)

Chỉ có 8 bit thấp của gid được lưu trữ.  Phiên bản hiện tại của
mkcramfs chỉ cần cắt ngắn thành 8 bit, đây là một biện pháp bảo mật tiềm năng
vấn đề.

Liên kết cứng được hỗ trợ, nhưng các tệp được liên kết cứng
vẫn sẽ có số lượng liên kết là 1 trong hình ảnh cramfs.

Thư mục Cramfs không có mục ZZ0000ZZ hoặc ZZ0001ZZ.  Các thư mục (như
mọi tệp khác trên cramfs) luôn có số lượng liên kết là 1. (Có
không cần sử dụng -noleaf trong ZZ0002ZZ, btw.)

Không có dấu thời gian nào được lưu trữ trong cramfs, vì vậy những dấu thời gian này mặc định là kỷ nguyên
(1970 GMT).  Các tệp được truy cập gần đây có thể có dấu thời gian được cập nhật, nhưng
quá trình cập nhật chỉ kéo dài chừng nào inode được lưu trong bộ nhớ, sau
mà dấu thời gian quay trở lại năm 1970, tức là di chuyển ngược thời gian.

Hiện tại, các bài nhồi nhét phải được viết và đọc với kiến trúc của
cùng độ bền và chỉ có thể được đọc bởi các hạt nhân có PAGE_SIZE
== 4096. Ít nhất lỗi sau là một lỗi, nhưng nó chưa xảy ra
đã quyết định cách khắc phục tốt nhất là gì.  Hiện tại nếu bạn có trang lớn hơn
bạn chỉ có thể thay đổi #define trong mkcramfs.c, miễn là bạn không
hãy nhớ rằng hệ thống tập tin trở nên không thể đọc được đối với các hạt nhân trong tương lai.


Hình ảnh nhồi nhét được ánh xạ vào bộ nhớ
--------------------------

Tùy chọn CRAMFS_MTD Kconfig bổ sung hỗ trợ tải dữ liệu trực tiếp từ
phạm vi bộ nhớ tuyến tính vật lý (thường là bộ nhớ không thay đổi như Flash)
thay vì đi qua lớp thiết bị khối. Điều này tiết kiệm một số bộ nhớ
vì không cần đệm trung gian để giữ dữ liệu trước khi
giải nén.

Và khi các khối dữ liệu không bị nén và căn chỉnh chính xác, chúng sẽ
tự động được ánh xạ trực tiếp vào không gian người dùng bất cứ khi nào có thể, cung cấp
eXecute-In-Place (XIP) từ ROM của các phân đoạn chỉ đọc. Đã ánh xạ các phân đoạn dữ liệu
đọc-ghi (do đó chúng phải được sao chép sang RAM) vẫn có thể được nén ở dạng
hình ảnh cramfs trong cùng một tệp cùng với chế độ chỉ đọc không nén
phân đoạn. Cả hai hệ thống MMU và no-MMU đều được hỗ trợ. Điều này đặc biệt
tiện dụng cho các hệ thống nhúng nhỏ có hạn chế về bộ nhớ rất chặt chẽ.

Vị trí của hình ảnh cramfs trong bộ nhớ phụ thuộc vào hệ thống. Bạn phải
biết địa chỉ vật lý thích hợp nơi đặt hình ảnh cramfs và
cấu hình một thiết bị MTD cho nó. Ngoài ra, thiết bị MTD đó phải được hỗ trợ
bởi trình điều khiển bản đồ thực hiện phương pháp "điểm". Ví dụ như vậy
Trình điều khiển MTD là cfi_cmdset_0001 (Intel/Sharp CFI flash) hoặc physmap
(Thiết bị flash trong bản đồ bộ nhớ vật lý). Phân vùng MTD dựa trên các thiết bị đó
cũng ổn. Sau đó, thiết bị đó phải được chỉ định bằng tiền tố "mtd:"
làm đối số thiết bị gắn kết. Ví dụ: để gắn thiết bị MTD có tên
"fs_partition" trên thư mục /mnt::

$ mount -t cramfs mtd:fs_partition /mnt

Để khởi động kernel với hệ thống tập tin gốc này, chỉ cần chỉ định
đại loại như "root=mtd:fs_partition" trên dòng lệnh kernel.


Công cụ
-----

Một phiên bản của mkcramfs có thể tận dụng những khả năng mới nhất
được mô tả ở trên có thể được tìm thấy ở đây:

ZZ0000ZZ


Dành cho /usr/share/magic
--------------------

===== ==================================================
0 ulelong 0x28cd3d45 Phần bù nhồi nhét Linux 0
>4 ulelong x kích thước %d
>8 cờ ulelong x 0x%x
>12 ulelong x tương lai 0x%x
>16 chuỗi >\0 chữ ký "%.16s"
>32 ulelong x fsid.crc 0x%x
>36 ulelong x fsid.edition %d
>40 ulelong x fsid.blocks %d
>44 ulelong x fsid.files %d
>48 chuỗi >\0 tên "%.16s"
512 ulelong 0x28cd3d45 Linux cramfs bù đắp 512
>516 ulelong x kích thước %d
>520 cờ ulelong x 0x%x
>524 ulelong x tương lai 0x%x
>528 chuỗi >\0 chữ ký "%.16s"
>544 ulelong x fsid.crc 0x%x
>548 ulelong x fsid.edition %d
>552 ulelong x fsid.blocks %d
>556 ulelong x fsid.files %d
>chuỗi 560 >\0 tên "%.16s"
===== ==================================================


Ghi chú của hacker
------------

Xem fs/cramfs/README để biết bố cục hệ thống tập tin và ghi chú triển khai.