.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/trace/ftrace-uses.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

====================================
Sử dụng ftrace để nối vào các hàm
====================================

.. Copyright 2017 VMware Inc.
..   Author:   Steven Rostedt <srostedt@goodmis.org>
..  License:   The GNU Free Documentation License, Version 1.2
..               (dual licensed under the GPL v2)

Viết cho: 4.14

Giới thiệu
============

Cơ sở hạ tầng ftrace ban đầu được tạo ra để gắn các lệnh gọi lại vào
bắt đầu các chức năng để ghi lại và theo dõi dòng chảy của kernel.
Tuy nhiên, lệnh gọi lại khi bắt đầu hàm có thể có các trường hợp sử dụng khác. Hoặc
để vá kernel trực tiếp hoặc để giám sát bảo mật. Tài liệu này mô tả
cách sử dụng ftrace để triển khai lệnh gọi lại hàm của riêng bạn.


Bối cảnh ftrace
==================
.. warning::

  The ability to add a callback to almost any function within the
  kernel comes with risks. A callback can be called from any context
  (normal, softirq, irq, and NMI). Callbacks can also be called just before
  going to idle, during CPU bring up and takedown, or going to user space.
  This requires extra care to what can be done inside a callback. A callback
  can be called outside the protective scope of RCU.

Có các chức năng trợ giúp để chống lại sự đệ quy và đảm bảo
RCU đang xem. Những điều này được giải thích dưới đây.


Cấu trúc ftrace_ops
========================

Để đăng ký một hàm gọi lại, cần có ftrace_ops. Cấu trúc này
được sử dụng để báo cho ftrace biết hàm nào nên được gọi là hàm gọi lại
cũng như những biện pháp bảo vệ mà lệnh gọi lại sẽ thực hiện và không yêu cầu
ftrace để xử lý.

Chỉ có một trường cần được đặt khi đăng ký
một ftrace_ops với ftrace:

.. code-block:: c

 struct ftrace_ops ops = {
       .func			= my_callback_func,
       .flags			= MY_FTRACE_FLAGS
       .private			= any_private_data_structure,
 };

Cả .flags và .private đều là tùy chọn. Chỉ cần .func.

Để bật theo dõi cuộc gọi::

register_ftrace_function(&ops);

Để tắt tính năng theo dõi cuộc gọi::

unregister_ftrace_function(&ops);

Ở trên được xác định bằng cách bao gồm tiêu đề::

#include <linux/ftrace.h>

Cuộc gọi lại đã đăng ký sẽ bắt đầu được gọi một thời gian sau
register_ftrace_function() được gọi và trước khi nó trả về. Thời gian chính xác
việc gọi lại bắt đầu được gọi phụ thuộc vào kiến trúc và lập kế hoạch
của các dịch vụ. Bản thân cuộc gọi lại sẽ phải xử lý bất kỳ sự đồng bộ hóa nào nếu nó
phải bắt đầu vào một thời điểm chính xác.

unregister_ftrace_function() sẽ đảm bảo rằng lệnh gọi lại được thực hiện
không còn được gọi bởi các hàm sau unregister_ftrace_function()
trở lại. Lưu ý rằng để thực hiện đảm bảo này, hàm unregister_ftrace_function()
có thể mất một thời gian để hoàn thành.


Chức năng gọi lại
=====================

Nguyên mẫu của hàm gọi lại như sau (kể từ v4.14):

.. code-block:: c

   void callback_func(unsigned long ip, unsigned long parent_ip,
                      struct ftrace_ops *op, struct pt_regs *regs);

@ip
	 Đây là con trỏ lệnh của hàm đang được theo dõi.
      	 (trong đó fentry hoặc mcount nằm trong hàm)

@parent_ip
	Đây là con trỏ lệnh của hàm được gọi là
	hàm đang được truy tìm (nơi xảy ra lệnh gọi hàm).

@op
	Đây là con trỏ tới ftrace_ops được sử dụng để đăng ký lệnh gọi lại.
	Điều này có thể được sử dụng để truyền dữ liệu tới cuộc gọi lại thông qua con trỏ riêng.

@regs
	Nếu FTRACE_OPS_FL_SAVE_REGS hoặc FTRACE_OPS_FL_SAVE_REGS_IF_SUPPORTED
	cờ được đặt trong cấu trúc ftrace_ops, thì điều này sẽ trỏ
	với cấu trúc pt_regs giống như khi đặt một điểm dừng
	khi bắt đầu hàm mà ftrace đang truy tìm. Nếu không thì nó
	chứa rác hoặc NULL.

Bảo vệ cuộc gọi lại của bạn
===========================

Vì các hàm có thể được gọi từ bất cứ đâu và có thể một hàm
được gọi bằng một cuộc gọi lại cũng có thể được theo dõi và gọi lại cuộc gọi lại đó,
phải sử dụng bảo vệ đệ quy. Có hai hàm trợ giúp
có thể giúp đỡ trong vấn đề này. Nếu bạn bắt đầu mã của mình bằng:

.. code-block:: c

	int bit;

	bit = ftrace_test_recursion_trylock(ip, parent_ip);
	if (bit < 0)
		return;

và kết thúc nó bằng:

.. code-block:: c

	ftrace_test_recursion_unlock(bit);

Mã ở giữa sẽ an toàn khi sử dụng, ngay cả khi cuối cùng nó gọi một
chức năng mà cuộc gọi lại đang theo dõi. Lưu ý, về sự thành công,
ftrace_test_recursion_trylock() sẽ vô hiệu hóa quyền ưu tiên và
ftrace_test_recursion_unlock() sẽ kích hoạt lại nó (nếu trước đó
đã bật). Con trỏ lệnh (ip) và cha của nó (parent_ip) được truyền tới
ftrace_test_recursion_trylock() để ghi lại nơi xảy ra đệ quy
(nếu CONFIG_FTRACE_RECORD_RECURSION được đặt).

Ngoài ra, nếu cờ FTRACE_OPS_FL_RECURSION được đặt trên ftrace_ops
(như được giải thích bên dưới), sau đó tấm bạt lò xo trợ giúp sẽ được sử dụng để kiểm tra
để đệ quy cho lệnh gọi lại và không cần thực hiện kiểm tra đệ quy.
Nhưng điều này phải trả giá bằng chi phí chung cao hơn một chút từ chi phí bổ sung
lời gọi hàm.

Nếu lệnh gọi lại của bạn truy cập bất kỳ dữ liệu hoặc phần quan trọng nào yêu cầu RCU
bảo vệ, tốt nhất là đảm bảo rằng RCU đang "quan sát", nếu không
dữ liệu hoặc phần quan trọng đó sẽ không được bảo vệ như mong đợi. Trong này
trường hợp thêm:

.. code-block:: c

	if (!rcu_is_watching())
		return;

Ngoài ra, nếu cờ FTRACE_OPS_FL_RCU được đặt trên ftrace_ops
(như được giải thích bên dưới), sau đó tấm bạt lò xo trợ giúp sẽ được sử dụng để kiểm tra
cho rcu_is_watching để gọi lại và không cần thực hiện kiểm tra nào khác.
Nhưng điều này phải trả giá bằng chi phí chung cao hơn một chút từ chi phí bổ sung
lời gọi hàm.


Ftrace FLAGS
================

Tất cả các cờ ftrace_ops đều được xác định và ghi lại trong include/linux/ftrace.h.
Một số cờ được sử dụng cho cơ sở hạ tầng nội bộ của ftrace, nhưng
những điều mà người dùng nên biết là:

FTRACE_OPS_FL_SAVE_REGS
	Nếu cuộc gọi lại yêu cầu đọc hoặc sửa đổi pt_regs
	được chuyển tới lệnh gọi lại thì nó phải đặt cờ này. Đăng ký
	một ftrace_ops với cờ này được đặt trên kiến trúc không
	hỗ trợ chuyển pt_regs tới cuộc gọi lại sẽ không thành công.

FTRACE_OPS_FL_SAVE_REGS_IF_SUPPORTED
	Tương tự như SAVE_REGS nhưng việc đăng ký
	ftrace_ops trên kiến trúc không hỗ trợ chuyển reg
	sẽ không thất bại với bộ cờ này. Nhưng cuộc gọi lại phải kiểm tra xem
	regs có phải là NULL hay không để xác định xem kiến trúc có hỗ trợ nó hay không.

FTRACE_OPS_FL_RECURSION
	Theo mặc định, cuộc gọi lại có thể xử lý đệ quy.
	Nhưng nếu lệnh gọi lại không gây lo ngại về chi phí chung thì
	thiết lập bit này sẽ thêm bảo vệ đệ quy xung quanh
	gọi lại bằng cách gọi hàm trợ giúp sẽ thực hiện đệ quy
	Protection và chỉ gọi lại lệnh gọi lại nếu nó không tái diễn.

Lưu ý, nếu cờ này không được đặt và việc đệ quy xảy ra, nó có thể
	khiến hệ thống gặp sự cố và có thể khởi động lại do lỗi ba lần.

Lưu ý, nếu cờ này được đặt thì lệnh gọi lại sẽ luôn được gọi
	với quyền ưu tiên bị vô hiệu hóa. Nếu nó không được thiết lập thì có thể
	(nhưng không được đảm bảo) rằng cuộc gọi lại sẽ được gọi
	bối cảnh có sẵn.

FTRACE_OPS_FL_IPMODIFY
	Yêu cầu bộ FTRACE_OPS_FL_SAVE_REGS. Nếu lệnh gọi lại là "chiếm quyền điều khiển"
	hàm truy tìm (có một hàm khác được gọi thay vì
	chức năng truy tìm), nó yêu cầu thiết lập cờ này. Đây là những gì sống
	sử dụng các bản vá kernel. Nếu không có cờ này thì không thể có pt_regs->ip
	đã sửa đổi.

Lưu ý, chỉ có thể có một ftrace_ops với bộ FTRACE_OPS_FL_IPMODIFY
	được đăng ký vào bất kỳ chức năng nào tại một thời điểm.

FTRACE_OPS_FL_RCU
	Nếu điều này được đặt thì cuộc gọi lại sẽ chỉ được gọi bởi các hàm
	nơi RCU đang "xem". Điều này là bắt buộc nếu chức năng gọi lại
	thực hiện bất kỳ thao tác rcu_read_lock() nào.

RCU dừng xem khi hệ thống không hoạt động, thời điểm CPU
	được gỡ xuống và trực tuyến trở lại và khi nhập từ kernel
	vào không gian người dùng và quay lại không gian kernel. Trong những quá trình chuyển đổi này,
	một cuộc gọi lại có thể được thực thi và đồng bộ hóa RCU sẽ không bảo vệ
	nó.

FTRACE_OPS_FL_PERMANENT
        Nếu điều này được đặt trên bất kỳ hoạt động ftrace nào thì việc theo dõi không thể bị vô hiệu hóa bởi
        ghi 0 vào proc sysctl ftrace_enabled. Tương tự, một cuộc gọi lại với
        bộ cờ không thể được đăng ký nếu ftrace_enabled bằng 0.

Livepatch sử dụng nó để không làm mất chức năng chuyển hướng nên hệ thống
        vẫn được bảo vệ.


Lọc các chức năng để theo dõi
==================================

Nếu một cuộc gọi lại chỉ được gọi từ các chức năng cụ thể thì phải có bộ lọc
thiết lập. Các bộ lọc được thêm theo tên hoặc ip nếu biết.

.. code-block:: c

   int ftrace_set_filter(struct ftrace_ops *ops, unsigned char *buf,
                         int len, int reset);

@ops
	Các hoạt động để thiết lập bộ lọc với

@buf
	Chuỗi chứa văn bản bộ lọc hàm.
@len
	Độ dài của chuỗi.

@reset
	Khác 0 để đặt lại tất cả các bộ lọc trước khi áp dụng bộ lọc này.

Bộ lọc biểu thị những chức năng nào sẽ được bật khi bật tính năng theo dõi.
Nếu @buf là NULL và thiết lập lại được đặt, tất cả các chức năng sẽ được bật để theo dõi.

@buf cũng có thể là một biểu thức toàn cầu để kích hoạt tất cả các chức năng
phù hợp với một mẫu cụ thể.

Xem Lệnh lọc trong Tài liệu/trace/ftrace.rst.

Để chỉ theo dõi chức năng lịch trình:

.. code-block:: c

   ret = ftrace_set_filter(&ops, "schedule", strlen("schedule"), 0);

Để thêm nhiều chức năng hơn, hãy gọi ftrace_set_filter() nhiều lần bằng
Tham số @reset được đặt thành 0. Để loại bỏ bộ lọc hiện tại và thay thế nó
với các hàm mới được xác định bởi @buf, @reset phải khác 0.

Để xóa tất cả các hàm đã lọc và theo dõi tất cả các hàm:

.. code-block:: c

   ret = ftrace_set_filter(&ops, NULL, 0, 1);


Đôi khi có nhiều hàm có cùng tên. Để theo dõi chỉ một cụ thể
trong trường hợp này, ftrace_set_filter_ip() có thể được sử dụng.

.. code-block:: c

   ret = ftrace_set_filter_ip(&ops, ip, 0, 0);

Mặc dù ip phải là địa chỉ nơi cuộc gọi đến fentry hoặc mcount được thực hiện
nằm trong hàm. Hàm này được sử dụng bởi perf và kprobes
lấy địa chỉ IP từ người dùng (thường sử dụng thông tin gỡ lỗi từ kernel).

Nếu sử dụng hình cầu để đặt bộ lọc, các chức năng có thể được thêm vào "notrace"
list sẽ ngăn các chức năng đó gọi lại.
Danh sách "notrace" được ưu tiên hơn danh sách "bộ lọc". Nếu
hai danh sách không trống và chứa các chức năng giống nhau, lệnh gọi lại sẽ không
được gọi bởi bất kỳ chức năng nào.

Danh sách "notrace" trống có nghĩa là cho phép tất cả các hàm được bộ lọc xác định
để được truy tìm.

.. code-block:: c

   int ftrace_set_notrace(struct ftrace_ops *ops, unsigned char *buf,
                          int len, int reset);

Cái này có cùng tham số với ftrace_set_filter() nhưng sẽ thêm
các chức năng mà nó tìm thấy không thể truy tìm được. Đây là một danh sách riêng biệt với
danh sách bộ lọc và chức năng này không sửa đổi danh sách bộ lọc.

@reset khác 0 sẽ xóa danh sách "notrace" trước khi thêm chức năng
khớp với @buf với nó.

Xóa danh sách "notrace" cũng giống như xóa danh sách bộ lọc

.. code-block:: c

  ret = ftrace_set_notrace(&ops, NULL, 0, 1);

Danh sách bộ lọc và notrace có thể được thay đổi bất kỳ lúc nào. Nếu chỉ có một bộ
các hàm nên gọi lại, tốt nhất nên đặt bộ lọc trước
đăng ký gọi lại. Nhưng những thay đổi cũng có thể xảy ra sau khi gọi lại
đã được đăng ký.

Nếu một bộ lọc được đặt đúng chỗ và @reset khác 0 và @buf chứa một
khớp toàn cầu với các hàm, việc chuyển đổi sẽ diễn ra trong thời gian
lệnh gọi ftrace_set_filter(). Tất cả các chức năng sẽ không bao giờ gọi lại cuộc gọi lại.

.. code-block:: c

   ftrace_set_filter(&ops, "schedule", strlen("schedule"), 1);

   register_ftrace_function(&ops);

   msleep(10);

   ftrace_set_filter(&ops, "try_to_wake_up", strlen("try_to_wake_up"), 1);

không giống như:

.. code-block:: c

   ftrace_set_filter(&ops, "schedule", strlen("schedule"), 1);

   register_ftrace_function(&ops);

   msleep(10);

   ftrace_set_filter(&ops, NULL, 0, 1);

   ftrace_set_filter(&ops, "try_to_wake_up", strlen("try_to_wake_up"), 0);

Vì cái sau sẽ có một khoảng thời gian ngắn để tất cả các hàm sẽ gọi
cuộc gọi lại, giữa thời gian đặt lại và thời gian
cài đặt mới của bộ lọc.
