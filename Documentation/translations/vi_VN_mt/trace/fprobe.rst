.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/trace/fprobe.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=====================================
Fprobe - Đầu dò chức năng vào/ra
=====================================

.. Author: Masami Hiramatsu <mhiramat@kernel.org>

Giới thiệu
============

Fprobe là một đầu dò vào/ra hàm dựa trên việc theo dõi đồ thị hàm
tính năng trong ftrace.
Thay vì truy tìm tất cả các chức năng, nếu bạn muốn đính kèm lệnh gọi lại trên các chức năng cụ thể
chức năng nhập và thoát, tương tự như kprobes và kretprobes, bạn có thể
sử dụng fprobe. So với kprobes và kretprobes, fprobe cho kết quả nhanh hơn
thiết bị đo đạc cho nhiều chức năng với một bộ xử lý duy nhất. Tài liệu này
mô tả cách sử dụng fprobe.

Việc sử dụng fprobe
===================

fprobe là một trình bao bọc của ftrace (+ lệnh gọi lại trả về giống như kretprobe) cho
đính kèm các cuộc gọi lại vào mục nhập và thoát nhiều chức năng. Người dùng cần thiết lập
ZZ0000ZZ và chuyển nó cho ZZ0001ZZ.

Thông thường, cấu trúc dữ liệu ZZ0000ZZ được khởi tạo bằng ZZ0001ZZ
và/hoặc ZZ0002ZZ như dưới đây.

.. code-block:: c

 struct fprobe fp = {
        .entry_handler  = my_entry_callback,
        .exit_handler   = my_exit_callback,
 };

Để kích hoạt fprobe, hãy gọi một trong các register_fprobe(), register_fprobe_ips() và
register_fprobe_syms(). Các hàm này đăng ký fprobe với các loại khác nhau
của các tham số.

register_fprobe() kích hoạt fprobe theo bộ lọc tên hàm.
Ví dụ. điều này kích hoạt @fp trên chức năng "func*()" ngoại trừ "func2()".::

register_fprobe(&fp, "func*", "func2");

register_fprobe_ips() cho phép fprobe theo địa chỉ vị trí ftrace.
Ví dụ.

.. code-block:: c

  unsigned long ips[] = { 0x.... };

  register_fprobe_ips(&fp, ips, ARRAY_SIZE(ips));

Và register_fprobe_syms() kích hoạt fprobe theo tên ký hiệu.
Ví dụ.

.. code-block:: c

  char syms[] = {"func1", "func2", "func3"};

  register_fprobe_syms(&fp, syms, ARRAY_SIZE(syms));

Để tắt (xóa khỏi chức năng) fprobe này, hãy gọi ::

hủy đăng ký_fprobe(&fp);

Bạn có thể vô hiệu hóa tạm thời (mềm) fprobe bằng cách ::

vô hiệu hóa_fprobe(&fp);

và tiếp tục bằng cách::

Enable_fprobe(&fp);

Ở trên được xác định bằng cách bao gồm tiêu đề::

#include <linux/fprobe.h>

Tương tự như ftrace, các lệnh gọi lại đã đăng ký sẽ bắt đầu được gọi vào một thời điểm nào đó
sau khi register_fprobe() được gọi và trước khi nó trả về. Xem
Tài liệu/trace/ftrace.rst.

Ngoài ra, unregister_fprobe() sẽ đảm bảo rằng cả nhập và thoát
các trình xử lý không còn được gọi bởi các hàm sau unregister_fprobe()
trả về giống như unregister_ftrace_function().

Trình xử lý nhập/xuất fprobe
=============================

Nguyên mẫu của hàm gọi lại vào/ra như sau:

.. code-block:: c

 int entry_callback(struct fprobe *fp, unsigned long entry_ip, unsigned long ret_ip, struct ftrace_regs *fregs, void *entry_data);

 void exit_callback(struct fprobe *fp, unsigned long entry_ip, unsigned long ret_ip, struct ftrace_regs *fregs, void *entry_data);

Lưu ý rằng @entry_ip được lưu tại mục nhập hàm và được chuyển để thoát
người xử lý.
Nếu hàm gọi lại mục nhập trả về !0, hàm gọi lại thoát tương ứng
sẽ bị hủy bỏ.

@fp
        Đây là địa chỉ của cấu trúc dữ liệu ZZ0000ZZ liên quan đến trình xử lý này.
        Bạn có thể nhúng ZZ0001ZZ vào cấu trúc dữ liệu của mình và lấy nó bằng cách
        macro container_of() từ @fp. @fp không được là NULL.

@entry_ip
        Đây là địa chỉ ftrace của hàm theo dõi (cả mục nhập và thoát).
        Lưu ý rằng đây có thể không phải là địa chỉ đầu vào thực sự của hàm nhưng
        địa chỉ nơi ftrace được cài đặt.

@ret_ip
        Đây là địa chỉ trả về mà hàm truy tìm sẽ quay trở lại,
        đâu đó trong người gọi. Điều này có thể được sử dụng ở cả lối vào và lối ra.

@fregs
        Đây là cấu trúc dữ liệu ZZ0000ZZ ở đầu vào và đầu ra. Cái này
        bao gồm các tham số hàm hoặc các giá trị trả về. Vì vậy người dùng có thể
        truy cập các giá trị đó thông qua API ZZ0001ZZ thích hợp.

@entry_data
        Đây là bộ lưu trữ cục bộ để chia sẻ dữ liệu giữa các trình xử lý nhập và thoát.
        Bộ nhớ này mặc định là NULL. Nếu người dùng chỉ định trường ZZ0000ZZ
        và trường ZZ0001ZZ khi đăng ký fprobe, dung lượng lưu trữ sẽ là
        được phân bổ và chuyển cho cả ZZ0002ZZ và ZZ0003ZZ.

Kích thước dữ liệu nhập và xử lý thoát trên cùng một chức năng
==============================================================

Vì dữ liệu đầu vào được truyền qua ngăn xếp trên mỗi tác vụ và nó có kích thước giới hạn,
kích thước dữ liệu đầu vào trên mỗi đầu dò được giới hạn ở ZZ0000ZZ. Bạn cũng cần
để đảm bảo rằng các fprobe khác nhau đang thăm dò cùng một chức năng, điều này
giới hạn trở nên nhỏ hơn. Kích thước dữ liệu mục nhập được căn chỉnh theo ZZ0001ZZ và
mỗi fprobe có trình xử lý thoát sử dụng khoảng trống ZZ0002ZZ trên ngăn xếp,
bạn nên giữ số lượng fprobe trên cùng một chức năng càng nhỏ càng tốt
có thể.

Chia sẻ các cuộc gọi lại với kprobes
====================================

Vì độ an toàn đệ quy của fprobe (và ftrace) hơi khác một chút
từ kprobes, điều này có thể gây ra sự cố nếu người dùng muốn chạy tương tự
mã từ fprobe và kprobe.

Kprobes có biến 'current_kprobe' trên mỗi CPU để bảo vệ kprobe
xử lý khỏi đệ quy trong mọi trường hợp. Mặt khác, fprobe sử dụng
chỉ ftrace_test_recursion_trylock(). Điều này cho phép bối cảnh ngắt
gọi một fprobe khác (hoặc tương tự) trong khi trình xử lý người dùng fprobe đang chạy.

Đây không phải là vấn đề nếu mã gọi lại chung có đệ quy riêng
phát hiện hoặc nó có thể xử lý đệ quy trong các bối cảnh khác nhau
(bình thường/ngắt/NMI.)
Nhưng nếu nó dựa vào khóa đệ quy 'current_kprobe' thì nó phải kiểm tra
kprobe_running() và sử dụng API kprobe_busy_*().

Fprobe có cờ FPROBE_FL_KPROBE_SHARED để thực hiện việc này. Nếu cuộc gọi lại chung của bạn
mã sẽ được chia sẻ với kprobes, vui lòng đặt FPROBE_FL_KPROBE_SHARED
ZZ0000ZZ đăng ký fprobe, như:

.. code-block:: c

 fprobe.flags = FPROBE_FL_KPROBE_SHARED;

 register_fprobe(&fprobe, "func*", NULL);

Điều này sẽ bảo vệ cuộc gọi lại chung của bạn khỏi cuộc gọi lồng nhau.

Bộ đếm bị bỏ lỡ
==================

Cấu trúc dữ liệu ZZ0000ZZ có trường bộ đếm ZZ0001ZZ giống như
kprobes.
Bộ đếm này đếm lên khi;

- fprobe không lấy được khóa ftrace_recursion. Điều này thường có nghĩa là một hàm
   được truy tìm bởi những người dùng ftrace khác được gọi từ entry_handler.

- fprobe không thiết lập được chức năng thoát do không phân bổ được
   bộ đệm dữ liệu từ ngăn xếp bóng cho mỗi tác vụ.

Trường ZZ0000ZZ đếm lên trong cả hai trường hợp. Vì vậy, trước đây
bỏ qua cả lệnh gọi lại vào và ra và lệnh sau bỏ qua lệnh thoát
gọi lại, nhưng trong cả hai trường hợp, bộ đếm sẽ tăng thêm 1.

Lưu ý rằng nếu bạn đặt FTRACE_OPS_FL_RECURSION và/hoặc FTRACE_OPS_FL_RCU thành
ZZ0000ZZ (ftrace_ops::flags) khi đăng ký fprobe, điều này
bộ đếm có thể không hoạt động chính xác vì ftrace bỏ qua chức năng fprobe
tăng bộ đếm.


Chức năng và cấu trúc
========================

.. kernel-doc:: include/linux/fprobe.h
.. kernel-doc:: kernel/trace/fprobe.c
