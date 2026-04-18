.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/process/debugging/userspace_debugging_guide.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

=============================
Lời khuyên gỡ lỗi không gian người dùng
==========================

Tài liệu này cung cấp một cái nhìn tổng quan ngắn gọn về các công cụ phổ biến để gỡ lỗi Linux
Hạt nhân từ không gian người dùng.
Để có lời khuyên gỡ lỗi dành cho các nhà phát triển trình điều khiển, hãy truy cập ZZ0000ZZ.
Để biết lời khuyên gỡ lỗi chung, hãy xem ZZ0001ZZ.

.. contents::
    :depth: 3

Các phần sau đây cho bạn thấy các công cụ có sẵn.

Gỡ lỗi động
-------------

Cơ chế lọc những gì kết thúc trong nhật ký kernel bằng nhật ký dis-/en-abling
tin nhắn.

Điều kiện tiên quyết: ZZ0000ZZ

Gỡ lỗi động chỉ có thể nhắm mục tiêu:

- pr_debug()
- dev_dbg()
- print_hex_dump_debug()
- print_hex_dump_bytes()

Do đó, tính đến thời điểm hiện tại, khả năng sử dụng của công cụ này khá hạn chế vì có
không có quy tắc thống nhất để thêm bản in gỡ lỗi vào cơ sở mã, dẫn đến nhiều loại
về cách các bản in này được thực hiện.

Ngoài ra, hãy lưu ý rằng hầu hết các câu lệnh gỡ lỗi được triển khai dưới dạng một biến thể của
dprintk(), phải được kích hoạt thông qua một tham số trong mô-đun tương ứng,
gỡ lỗi động không thể thực hiện bước đó cho bạn.

Đây là một ví dụ cho phép tất cả pr_debug() có sẵn trong tệp::

$ bí danh ddcmd='echo $* > /proc/dynamic_debug/control'
  $ ddcmd '-p; tập tin v4l2-h264.c +p'
  $ grep =p /proc/dynamic_debug/control
   trình điều khiển/media/v4l2-core/v4l2-h264.c:372 [v4l2_h264]print_ref_list_b =p
   "ref_pic_list_b%u (cur_poc %u%c) %s"
   trình điều khiển/media/v4l2-core/v4l2-h264.c:333 [v4l2_h264]print_ref_list_p =p
   "ref_pic_list_p (cur_poc %u%c) %s\n"

ZZ0000ZZ

- Khi mã chứa một trong các câu lệnh in hợp lệ (xem ở trên) hoặc khi
  bạn đã thêm nhiều câu lệnh pr_debug() trong quá trình phát triển
- Khi thời gian không phải là vấn đề, nghĩa là nếu có nhiều câu lệnh pr_debug() trong
  mã sẽ không gây ra sự chậm trễ
- Khi bạn quan tâm đến việc nhận thông điệp tường trình cụ thể hơn là truy tìm
  mô hình về cách gọi một hàm

Để có tài liệu đầy đủ, hãy xem ZZ0000ZZ

Ftrace
------

Điều kiện tiên quyết: ZZ0000ZZ

Công cụ này sử dụng hệ thống tệp tracefs cho các tệp điều khiển và tệp đầu ra.
Hệ thống tập tin đó sẽ được gắn dưới dạng thư mục ZZ0000ZZ, có thể tìm thấy
trong ZZ0001ZZ hoặc ZZ0002ZZ.

Một số thao tác quan trọng nhất để gỡ lỗi là:

- Bạn có thể thực hiện theo dõi hàm bằng cách thêm tên hàm vào
  Tệp ZZ0002ZZ (chấp nhận bất kỳ tên hàm nào được tìm thấy trong
  ZZ0003ZZ) hoặc bạn có thể vô hiệu hóa cụ thể một số
  hoạt động bằng cách thêm tên của chúng vào tệp ZZ0004ZZ (thông tin thêm
  tại: ZZ0000ZZ).
- Để biết cuộc gọi bắt nguồn từ đâu, bạn có thể kích hoạt
  Tùy chọn ZZ0005ZZ trong ZZ0006ZZ.
- Truy tìm phần tử con của lệnh gọi hàm và hiển thị giá trị trả về là
  có thể bằng cách thêm chức năng mong muốn vào tệp ZZ0007ZZ
  (yêu cầu cấu hình ZZ0008ZZ); thêm thông tin tại
  ZZ0001ZZ.

Để có tài liệu Ftrace đầy đủ, hãy xem ZZ0000ZZ

Hoặc bạn cũng có thể theo dõi các sự kiện cụ thể bằng ZZ0000ZZ, có thể được xác định như mô tả ở đây:
ZZ0001ZZ.

Để có tài liệu theo dõi sự kiện Ftrace đầy đủ, hãy xem ZZ0000ZZ

.. _read_ftrace_log:

Đọc nhật ký ftrace
~~~~~~~~~~~~~~~~~~~~~~

Tệp ZZ0001ZZ có thể được đọc giống như bất kỳ tệp nào khác (ZZ0002ZZ, ZZ0003ZZ,
ZZ0004ZZ, ZZ0005ZZ, v.v.), kích thước của tệp bị giới hạn bởi
ZZ0006ZZ (ZZ0007ZZ). các
ZZ0000ZZ sẽ hoạt động tương tự như tệp ZZ0008ZZ, nhưng
bất cứ khi nào bạn đọc từ tệp, nội dung sẽ được sử dụng.

cá mập hạt nhân
~~~~~~~~~~~

Giao diện GUI để hiển thị dấu vết dưới dạng biểu đồ và chế độ xem danh sách từ
đầu ra của ứng dụng ZZ0000ZZ.

Để có tài liệu đầy đủ, hãy xem ZZ0000ZZ

Hiệu suất & lựa chọn thay thế
-------------------

Các công cụ được đề cập ở trên cung cấp các cách để kiểm tra mã kernel, kết quả,
các giá trị biến đổi, v.v. Đôi khi bạn phải tìm ra nơi cần tìm và
đối với những trường hợp đó, một hộp công cụ theo dõi hiệu suất có thể giúp bạn định hình
vấn đề.

Tại sao bạn nên thực hiện phân tích hiệu suất?
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Phân tích hiệu suất là bước đầu tiên tốt khi:

- bạn không thể xác định được vấn đề
- bạn không biết nó xảy ra ở đâu
- hệ thống đang chạy không bị gián đoạn hoặc đó là hệ thống từ xa, trong đó
  bạn không thể cài đặt mô-đun/kernel mới

Làm cách nào để thực hiện phân tích đơn giản với các công cụ linux?
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Để bắt đầu phân tích hiệu suất, bạn có thể bắt đầu với các công cụ thông thường
như:

- ZZ0000ZZ / ZZ0001ZZ / ZZ0002ZZ (*xem tổng quan về tải hệ thống, xem
  tăng đột biến trên các quy trình cụ thể*)
-ZZ0003ZZ (ZZ0009ZZ)
-ZZ0004ZZ (ZZ0010ZZ)
-ZZ0005ZZ (ZZ0011ZZ)
- ZZ0006ZZ (ZZ0012ZZ ZZ0007ZZ *nhưng theo quy trình, hãy quay số xuống
  mục tiêu*)
- ZZ0008ZZ (*một khi bạn biết quy trình, bạn có thể tìm ra cách thực hiện nó
  giao tiếp với Kernel*)

Những điều này sẽ giúp thu hẹp các khu vực để xem xét đầy đủ.

Lặn sâu hơn với sự hoàn hảo
~~~~~~~~~~~~~~~~~~~~~~~

Công cụ ZZ0000ZZ cung cấp một loạt số liệu và sự kiện để tiếp tục quay số
về các vấn đề.

Điều kiện tiên quyết: xây dựng hoặc cài đặt perf trên hệ thống của bạn

Thu thập dữ liệu thống kê để tìm tất cả các tệp bắt đầu bằng ZZ0000ZZ trong ZZ0001ZZ::

# perf stat -d find /usr -name 'gcc*' | wc -l

Thống kê bộ đếm hiệu suất cho 'find /usr -name gcc*':

CPU #    0.997 xung nhịp tác vụ 1277,81 mili giây được sử dụng
     9 công tắc ngữ cảnh #    7.043 / giây
     1 lần di chuyển cpu #    0.783 / giây
     704 lỗi trang #  550.943 /giây
     766548897 chu kỳ #    0.600 GHz (97,15%)
     798285467 hướng dẫn #    1.04 insn mỗi chu kỳ (97,15%)
     57582731 nhánh #   45.064 M/giây (2,85%)
     3842573 chi nhánh bỏ sót #    6.67% trong tổng số chi nhánh (97,15%)
     281616097 Tải L1-dcache #  220.390 M/giây (97,15%)
     4220975 L1-dcache-load-miss #    1.50% trong tổng số lượt truy cập L1-dcache (97,15%)
     <không được hỗ trợ> Tải LLC
     <không được hỗ trợ> LLC-lỡ tải

Thời gian đã trôi qua 1,281746009 giây

Người dùng 0,508796000 giây
   0,773209000 giây hệ thống


52

Tính khả dụng của các sự kiện và số liệu tùy thuộc vào hệ thống bạn đang chạy.

Để có tài liệu đầy đủ, hãy xem
ZZ0000ZZ

Perfetto
~~~~~~~~

Một bộ công cụ để đo lường và phân tích mức độ hoạt động của các ứng dụng và hệ thống.
Bạn có thể sử dụng nó để:

* xác định điểm nghẽn
* tối ưu hóa mã
* làm cho phần mềm chạy nhanh hơn và hiệu quả hơn.

ZZ0000ZZ

* perf là một công cụ chuyên biệt dành cho Linux Kernel và có người dùng CLI
  giao diện.
* ngăn xếp phân tích hiệu suất đa nền tảng perfetto, đã mở rộng
  chức năng vào không gian người dùng và cung cấp giao diện người dùng WEB.

Để có tài liệu đầy đủ, hãy xem ZZ0000ZZ

Công cụ phân tích hoảng loạn hạt nhân
---------------------------

Để ghi lại kết xuất sự cố, vui lòng sử dụng ZZ0000ZZ & ZZ0001ZZ. Dưới đây bạn có thể tìm thấy
  một số lời khuyên cho việc phân tích dữ liệu.

Để có tài liệu đầy đủ, hãy xem ZZ0000ZZ

Để tìm dòng tương ứng trong mã, bạn có thể sử dụng ZZ0001ZZ; ghi chú
  rằng bạn cần kích hoạt ZZ0000ZZ để nó hoạt động.

Một cách khác để sử dụng ZZ0000ZZ là sử dụng ZZ0001ZZ (và
  phái sinh cho các nền tảng khác nhau như ZZ0002ZZ).
  Lấy dòng này làm ví dụ:

ZZ0000ZZ.

Chúng ta có thể tìm thấy dòng mã tương ứng bằng cách thực thi::

aarch64-linux-gnu-objdump -dS trình điều khiển/dàn dựng/media/rkvdec/rockchip-vdec.ko | grep rkvdec_device_run\>: -A 40
    0000000000000ac8 <rkvdec_device_run>:
     ac8: d503201f không
     acc: d503201f không
    {
     ad0: d503233f paciasp
     ad4: a9bd7bfd stp x29, x30, [sp, #-48]!
     ad8: 910003fd mov x29, sp
     quảng cáo: a90153f3 stp x19, x20, [sp, #16]
     ae0: a9025bf5 stp x21, x22, [sp, #32]
        const struct rkvdec_coded_fmt_desc *desc = ctx->coded_fmt_desc;
     ae4: f9411814 ldr x20, [x0, #560]
        struct rkvdec_dev *rkvdec = ctx->dev;
     ae8: f9418015 ldr x21, [x0, #768]
        nếu (WARN_ON(!desc))
     aec: b4000654 cbz x20, bb4 <rkvdec_device_run+0xec>
        ret = pm_runtime_resume_and_get(rkvdec->dev);
     af0: f943d2b6 ldr x22, [x21, #1952]
        ret = __pm_runtime_resume(dev, RPM_GET_PUT);
     af4: aa0003f3 mov x19, x0
     af8: 52800081 mov w1, #0x4 // #4
     afc: aa1603e0 mov x0, x22
     b00: 94000000 bl 0 <__pm_runtime_resume>
        nếu (ret < 0) {
     b04: 37f80340 tbnz w0, #31, b6c <rkvdec_device_run+0xa4>
        dev_warn(rkvdec->dev, "Không ổn\n");
     b08: f943d2a0 ldr x0, [x21, #1952]
     b0c: 90000001 adrp x1, 0 <rkvdec_try_ctrl-0x8>
     b10: 91000021 thêm x1, x1, #0x0
     b14: 94000000 bl 0 <_dev_warn>
        *xấu = 1;
     b18: d2800001 mov x1, #0x0 // #0
     ...

Có nghĩa là, trong dòng này từ kết xuất sự cố ::

[ +0,000240] rkvdec_device_run+0x50/0x138 [rockchip_vdec]

Tôi có thể lấy ZZ0000ZZ làm phần bù, tôi phải thêm số này vào địa chỉ cơ sở
  của hàm tương ứng mà tôi tìm thấy trong dòng này ::

0000000000000ac8 <rkvdec_device_run>:

Kết quả của ZZ0000ZZ
  Và khi tôi tìm kiếm địa chỉ đó trong hàm, tôi nhận được
  dòng sau::

*xấu = 1;
    b18: d2800001 mov x1, #0x0

ZZ0000ZZ ©2024 : Cộng tác