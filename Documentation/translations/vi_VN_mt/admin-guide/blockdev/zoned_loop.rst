.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/admin-guide/blockdev/zoned_loop.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=======================================
Thiết bị chặn vòng lặp được khoanh vùng
=======================================

.. Contents:

	1) Overview
	2) Creating a Zoned Device
	3) Deleting a Zoned Device
	4) Example


1) Tổng quan
------------

Trình điều khiển thiết bị khối vòng lặp được khoanh vùng (zloop) cho phép người dùng tạo một khối được khoanh vùng
thiết bị sử dụng một tệp thông thường cho mỗi vùng làm bộ nhớ đệm. Trình điều khiển này không
trực tiếp kiểm soát mọi phần cứng và sử dụng các thao tác đọc, ghi và cắt bớt để
các tệp thông thường của hệ thống tệp để mô phỏng thiết bị khối được khoanh vùng.

Sử dụng zloop, các thiết bị khối được khoanh vùng với dung lượng, kích thước vùng có thể định cấu hình và
số vùng thông thường có thể được tạo ra. Dung lượng lưu trữ cho từng vùng
thiết bị được triển khai bằng tệp thông thường có kích thước tối đa bằng vùng
kích thước. Kích thước của tệp sao lưu vùng thông thường luôn bằng vùng
kích thước. Kích thước của tệp sao lưu vùng tuần tự cho biết lượng dữ liệu
được ghi tuần tự vào tệp, nghĩa là kích thước của tệp trực tiếp
cho biết vị trí của con trỏ ghi của vùng.

Khi đặt lại vùng tuần tự, kích thước tệp sao lưu của nó sẽ bị cắt bớt về 0.
Ngược lại, đối với thao tác kết thúc vùng, tệp sao lưu sẽ bị cắt bớt thành
kích thước vùng. Với điều này, dung lượng tối đa của thiết bị khối được khoanh vùng zloop được tạo
có thể được cấu hình lớn hơn để lớn hơn dung lượng lưu trữ có sẵn trên
hệ thống tập tin sao lưu. Tất nhiên, với cấu hình như vậy, việc ghi nhiều dữ liệu hơn
không gian lưu trữ có sẵn trên hệ thống tập tin sao lưu sẽ dẫn đến việc ghi
lỗi.

Trình điều khiển thiết bị khối vòng lặp được khoanh vùng thực hiện trạng thái chuyển tiếp vùng hoàn chỉnh
máy. Nghĩa là, các vùng có thể trống, được mở ngầm, được mở rõ ràng,
đóng cửa hoặc đầy đủ. Việc triển khai hiện tại không hỗ trợ bất kỳ giới hạn nào đối với
số lượng tối đa các vùng mở và hoạt động.

Không cần có công cụ người dùng nào để tạo và xóa các thiết bị zloop.

2) Tạo một thiết bị được khoanh vùng
------------------------------------

Khi mô-đun zloop được tải (hoặc nếu zloop được biên dịch trong kernel),
tệp thiết bị ký tự /dev/zloop-control có thể được sử dụng để thêm thiết bị zloop.
Điều này được thực hiện bằng cách viết lệnh "thêm" trực tiếp vào /dev/zloop-control
thiết bị::

$ modprobe zloop
        $ ls -l /dev/zloop*
        quẩy-------. 1 gốc gốc 10, 123 ngày 6 tháng 1 19:18 /dev/zloop-control

$ mkdir -p <thư mục cơ sở/<ID thiết bị>
        $ echo "thêm [tùy chọn]" > /dev/zloop-control

Các tùy chọn có sẵn cho lệnh thêm có thể được liệt kê bằng cách đọc
/dev/zloop-điều khiển thiết bị::

$ cat /dev/zloop-control
        thêm id=%d,capacity_mb=%u,zone_size_mb=%u,zone_capacity_mb=%u,conv_zones=%u,max_open_zones=%u,base_dir=%s,nr_queues=%u,queue_deep=%u,buffered_io,zone_append=%u,ordered_zone_append,discard_write_cache
        xóa id=%d

Chi tiết hơn, các tùy chọn có thể được sử dụng với lệnh "thêm" là như
theo sau.

==================================================================================
id Số thiết bị (X trong /dev/zloopX).
                      Mặc định: được gán tự động.
dung lượng_mb Tổng dung lượng thiết bị tính bằng MiB. Điều này luôn được làm tròn lên
                      đến bội số cao hơn gần nhất của kích thước vùng.
                      Mặc định: 16384 MiB (16 GiB).
Zone_size_mb Kích thước vùng thiết bị tính bằng MiB. Mặc định: 256 MiB.
Zone_capacity_mb Dung lượng vùng thiết bị (phải luôn bằng hoặc thấp hơn
                      hơn kích thước vùng. Mặc định: kích thước vùng.
conv_zones Tổng số khu quy ước bắt đầu từ
                      khu vực 0
                      Mặc định: 8
max_open_zones Số vùng yêu cầu ghi tuần tự mở tối đa
                      (0 không có giới hạn).
                      Mặc định: 0
base_dir Đường dẫn tới thư mục cơ sở nơi tạo thư mục
                      chứa các tập tin vùng của thiết bị.
                      Mặc định=/var/local/zloop.
                      Thư mục thiết bị chứa các tập tin vùng luôn
                      được đặt tên bằng ID thiết bị. Ví dụ: tập tin vùng mặc định
                      thư mục cho /dev/zloop0 là /var/local/zloop/0.
nr_queues Số lượng hàng đợi I/O của thiết bị khối được khoanh vùng. Cái này
                      giá trị luôn bị giới hạn bởi số lượng CPU trực tuyến
                      Mặc định: 1
queue_deep Độ sâu hàng đợi I/O tối đa trên mỗi hàng đợi I/O.
                      Mặc định: 64
buffered_io Thực hiện các IO được đệm thay vì IO trực tiếp (mặc định: false)
Zone_append Bật hoặc tắt tính năng nối thêm vùng gốc của thiết bị zloop
                      hỗ trợ.
                      Mặc định: 1 (đã bật).
                      Nếu hỗ trợ nối thêm vùng gốc bị vô hiệu hóa, lớp khối
                      sẽ mô phỏng thao tác này bằng cách sử dụng chức năng ghi thông thường
                      hoạt động.
order_zone_append Kích hoạt tính năng giảm thiểu zloop của việc sắp xếp lại vùng bổ sung.
                      Mặc định: bị vô hiệu hóa.
                      Điều này hữu ích để kiểm tra ánh xạ dữ liệu tệp hệ thống tệp
                      (phạm vi), vì khi được bật, điều này có thể giảm đáng kể
                      số lượng phạm vi dữ liệu cần thiết cho một tệp dữ liệu
                      lập bản đồ.
loại bỏ_write_cache Loại bỏ tất cả dữ liệu không được lưu giữ rõ ràng bằng cách sử dụng
                      hoạt động tuôn ra khi thiết bị được gỡ bỏ bằng cách cắt ngắn
                      mỗi tệp vùng theo kích thước được ghi trong lần xả cuối cùng
                      hoạt động. Điều này mô phỏng các sự kiện mất điện trong đó
                      dữ liệu không được cam kết sẽ bị mất.
==================================================================================

3) Xóa thiết bị được khoanh vùng
--------------------------------

Việc xóa một thiết bị khối vòng lặp được khoanh vùng không sử dụng được thực hiện bằng cách đưa ra lệnh "xóa"
lệnh tới /dev/zloop-control, chỉ định ID của thiết bị cần xóa ::

$ echo "xóa id=X" > /dev/zloop-control

Lệnh gỡ bỏ không có bất kỳ tùy chọn nào.

Một thiết bị được khoanh vùng đã bị xóa có thể được thêm lại mà không có bất kỳ thay đổi nào đối với
trạng thái của vùng thiết bị: vùng thiết bị được khôi phục về trạng thái cuối cùng
trước khi thiết bị được gỡ bỏ. Thêm lại thiết bị được khoanh vùng sau khi nó bị xóa
phải luôn được thực hiện bằng cách sử dụng cấu hình tương tự như khi thiết bị lần đầu tiên
đã thêm vào. Nếu phát hiện thay đổi cấu hình vùng, lỗi sẽ được trả về và
thiết bị được khoanh vùng sẽ không được tạo.

Để xóa hoàn toàn một thiết bị được khoanh vùng, sau khi thực hiện thao tác xóa, thiết bị đó
thư mục cơ sở chứa các tập tin sao lưu của vùng thiết bị phải được xóa.

4) Ví dụ
----------

Chuỗi lệnh sau đây tạo một thiết bị được khoanh vùng 2GB với các vùng là 64
MB và dung lượng vùng là 63 MB::

$ modprobe zloop
        $ mkdir -p /var/local/zloop/0
        $ echo "thêm dung lượng_mb=2048,zone_size_mb=64,zone_capacity_mb=63" > /dev/zloop-control

Đối với thiết bị được tạo (/dev/zloop0), tất cả các tệp sao lưu vùng đều được tạo
trong thư mục cơ sở mặc định (/var/local/zloop)::

$ ls -l /var/local/zloop/0
        tổng 0
        -rw-------. 1 gốc 67108864 Ngày 6 tháng 1 22:23 cnv-000000
        -rw-------. 1 gốc 67108864 Ngày 6 tháng 1 22:23 cnv-000001
        -rw-------. 1 gốc 67108864 Ngày 6 tháng 1 22:23 cnv-000002
        -rw-------. 1 gốc 67108864 Ngày 6 tháng 1 22:23 cnv-000003
        -rw-------. 1 gốc 67108864 22:23 ngày 6 tháng 1 cnv-000004
        -rw-------. 1 gốc 67108864 22:23 ngày 6 tháng 1 cnv-000005
        -rw-------. 1 gốc 67108864 Ngày 6 tháng 1 22:23 cnv-000006
        -rw-------. 1 gốc 67108864 22:23 ngày 6 tháng 1 cnv-000007
        -rw-------. 1 gốc gốc 0 Ngày 6 tháng 1 22:23 seq-000008
        -rw-------. 1 gốc gốc 0 Ngày 6 tháng 1 22:23 seq-000009
        ...

Sau đó, thiết bị được khoanh vùng được tạo (/dev/zloop0) có thể được sử dụng bình thường ::

$ lsblk -z
        NAME ZONED ZONE-SZ ZONE-NR ZONE-AMAX ZONE-OMAX ZONE-APP ZONE-WGRAN
        zloop0 do máy chủ quản lý 64M 32 0 0 1M 4K
        báo cáo $ blkzone /dev/zloop0
          bắt đầu: 0x000000000, len 0x020000, cap 0x020000, wptr 0x000000 reset:0 non-seq:0, zcond: 0(nw) [loại: 1(CONVENTIONAL)]
          bắt đầu: 0x000020000, len 0x020000, cap 0x020000, wptr 0x000000 reset:0 non-seq:0, zcond: 0(nw) [loại: 1(CONVENTIONAL)]
          bắt đầu: 0x000040000, len 0x020000, cap 0x020000, wptr 0x000000 reset:0 non-seq:0, zcond: 0(nw) [loại: 1(CONVENTIONAL)]
          bắt đầu: 0x000060000, len 0x020000, cap 0x020000, wptr 0x000000 reset:0 non-seq:0, zcond: 0(nw) [loại: 1(CONVENTIONAL)]
          bắt đầu: 0x000080000, len 0x020000, cap 0x020000, wptr 0x000000 reset:0 non-seq:0, zcond: 0(nw) [loại: 1(CONVENTIONAL)]
          bắt đầu: 0x0000a0000, len 0x020000, cap 0x020000, wptr 0x000000 reset:0 non-seq:0, zcond: 0(nw) [loại: 1(CONVENTIONAL)]
          bắt đầu: 0x0000c0000, len 0x020000, cap 0x020000, wptr 0x000000 reset:0 non-seq:0, zcond: 0(nw) [loại: 1(CONVENTIONAL)]
          bắt đầu: 0x0000e0000, len 0x020000, cap 0x020000, wptr 0x000000 reset:0 non-seq:0, zcond: 0(nw) [loại: 1(CONVENTIONAL)]
          bắt đầu: 0x000100000, len 0x020000, cap 0x01f800, wptr 0x000000 reset:0 non-seq:0, zcond: 1(em) [loại: 2(SEQ_WRITE_REQUIRED)]
          bắt đầu: 0x000120000, len 0x020000, cap 0x01f800, wptr 0x000000 reset:0 non-seq:0, zcond: 1(em) [loại: 2(SEQ_WRITE_REQUIRED)]
          ...

Việc xóa thiết bị này được thực hiện bằng lệnh ::

$ echo "xóa id=0" > /dev/zloop-control

Thiết bị đã xóa có thể được thêm lại bằng lệnh "thêm" tương tự như khi
thiết bị lần đầu tiên được tạo ra. Để xóa hoàn toàn một thiết bị được khoanh vùng, các tập tin sao lưu của thiết bị đó
cũng nên bị xóa sau khi thực hiện lệnh xóa ::

$ rm -r /var/local/zloop/0