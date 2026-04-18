.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/driver-api/driver-model/design-patterns.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

======================================
Mẫu thiết kế trình điều khiển thiết bị
======================================

Tài liệu này mô tả một số mẫu thiết kế phổ biến có trong trình điều khiển thiết bị.
Có khả năng là những người bảo trì hệ thống con sẽ yêu cầu các nhà phát triển trình điều khiển
phù hợp với các mẫu thiết kế này.

1. Vùng chứa trạng thái
2. container_of()


1. Vùng chứa trạng thái
~~~~~~~~~~~~~~~~~~~~~~~

Trong khi kernel chứa một số trình điều khiển thiết bị giả định rằng chúng sẽ
chỉ được thăm dò() một lần trên một hệ thống nhất định (singletons), người ta thường giả sử
thiết bị mà trình điều khiển liên kết sẽ xuất hiện trong một số trường hợp. Cái này
có nghĩa là hàm thăm dò() và tất cả lệnh gọi lại cần phải được thực hiện lại.

Cách phổ biến nhất để đạt được điều này là sử dụng thiết kế vùng chứa trạng thái
mẫu. Nó thường có dạng này::

cấu trúc foo {
      khóa spinlock_t; /* Thành viên mẫu */
      (...)
  };

int tĩnh foo_probe(...)
  {
      struct foo *foo;

foo = devm_kzalloc(dev, sizeof(*foo), GFP_KERNEL);
      nếu (!foo)
          trả về -ENOMEM;
      spin_lock_init(&foo->lock);
      (...)
  }

Điều này sẽ tạo một thể hiện của struct foo trong bộ nhớ mỗi khi thăm dò() được thực hiện
được gọi. Đây là vùng chứa trạng thái của chúng tôi cho phiên bản trình điều khiển thiết bị này.
Tất nhiên là cần thiết phải luôn vượt qua phiên bản này của
trạng thái xung quanh tất cả các chức năng cần quyền truy cập vào trạng thái và các thành viên của nó.

Ví dụ: nếu trình điều khiển đang đăng ký một trình xử lý ngắt, bạn sẽ
chuyển một con trỏ tới struct foo như thế này ::

irqreturn_t tĩnh foo_handler(int irq, void *arg)
  {
      struct foo *foo = arg;
      (...)
  }

int tĩnh foo_probe(...)
  {
      struct foo *foo;

(...)
      ret = request_irq(irq, foo_handler, 0, "foo", foo);
  }

Bằng cách này, bạn luôn đưa con trỏ quay lại phiên bản chính xác của foo trong
trình xử lý ngắt của bạn.


2. container_of()
~~~~~~~~~~~~~~~~~

Tiếp tục ví dụ trên, chúng tôi thêm một tác phẩm đã giảm tải::

cấu trúc foo {
      khóa spinlock_t;
      cấu trúc Workqueue_struct *wq;
      struct Work_struct giảm tải;
      (...)
  };

static void foo_work(struct work_struct *work)
  {
      struct foo *foo = container_of(work, struct foo, offload);

      (...)
  }

irqreturn_t tĩnh foo_handler(int irq, void *arg)
  {
      struct foo *foo = arg;

queue_work(foo->wq, &foo->offload);
      (...)
  }

int tĩnh foo_probe(...)
  {
      struct foo *foo;

foo->wq = create_singlethread_workqueue("foo-wq");
      INIT_WORK(&foo->giảm tải, foo_work);
      (...)
  }

Mẫu thiết kế giống nhau đối với đồng hồ bấm giờ hoặc thứ gì đó tương tự sẽ
trả về một đối số duy nhất là một con trỏ tới thành viên cấu trúc trong
gọi lại.

container_of() là macro được xác định trong <linux/container_of.h>

Những gì container_of() làm là lấy một con trỏ tới cấu trúc chứa từ
một con trỏ tới một thành viên bằng phép trừ đơn giản bằng cách sử dụng macro offsetof() từ
tiêu chuẩn C, cho phép thực hiện những hành vi tương tự như hướng đối tượng.
Lưu ý rằng thành viên được chứa không phải là con trỏ mà là thành viên thực sự
để cái này hoạt động.

Ở đây chúng ta có thể thấy rằng chúng ta tránh có con trỏ toàn cục tới struct foo *
dụ theo cách này, trong khi vẫn giữ số lượng tham số được truyền cho
chức năng làm việc cho một con trỏ duy nhất.
