.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/dev-tools/context-analysis.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. Copyright (C) 2025, Google LLC.

.. _context-analysis:

Phân tích bối cảnh dựa trên trình biên dịch
===========================================

Phân tích bối cảnh là một phần mở rộng ngôn ngữ, cho phép kiểm tra tĩnh
ngữ cảnh được yêu cầu đang hoạt động (hoặc không hoạt động) bằng cách thu thập và giải phóng
"khóa ngữ cảnh" do người dùng xác định. Một ứng dụng rõ ràng là kiểm tra độ an toàn của khóa
cho các nguyên tắc đồng bộ hóa khác nhau của kernel (mỗi nguyên mẫu đại diện cho một
"khóa ngữ cảnh") và kiểm tra xem quy tắc khóa có bị vi phạm hay không.

Trình biên dịch Clang hiện hỗ trợ toàn bộ phân tích ngữ cảnh
tính năng. Để kích hoạt Clang, hãy định cấu hình kernel bằng ::

CONFIG_WARN_CONTEXT_ANALYSIS=y

Tính năng này yêu cầu Clang 22 trở lên.

Phân tích là ZZ0001ZZ và yêu cầu khai báo mô-đun và
các hệ thống con nên được phân tích trong ZZ0000ZZ tương ứng::

CONTEXT_ANALYSIS_mymodule.o := y

Hoặc cho tất cả các đơn vị dịch trong thư mục::

CONTEXT_ANALYSIS := y

Tuy nhiên, có thể kích hoạt tính năng phân tích trên toàn cây, điều này sẽ dẫn đến
hiện có nhiều cảnh báo dương tính giả và ZZ0000ZZ thường được khuyến nghị ::

CONFIG_WARN_CONTEXT_ANALYSIS_ALL=y

Mô hình lập trình
-----------------

Phần dưới đây mô tả mô hình lập trình xung quanh việc sử dụng các loại khóa ngữ cảnh.

.. note::
   Enabling context analysis can be seen as enabling a dialect of Linux C with
   a Context System. Some valid patterns involving complex control-flow are
   constrained (such as conditional acquisition and later conditional release
   in the same function).

Phân tích bối cảnh là một cách để xác định khả năng cho phép của các hoạt động phụ thuộc vào
khóa ngữ cảnh đang được giữ (hoặc không được giữ). Thông thường chúng tôi quan tâm đến
bảo vệ dữ liệu và mã trong phần quan trọng bằng cách yêu cầu ngữ cảnh cụ thể
để hoạt động, ví dụ bằng cách giữ một khóa cụ thể. Việc phân tích đảm bảo rằng
người gọi không thể thực hiện thao tác nếu không có ngữ cảnh cần thiết được kích hoạt.

Khóa ngữ cảnh được liên kết với các cấu trúc được đặt tên, cùng với các hàm
hoạt động trên các phiên bản cấu trúc để thu thập và giải phóng khóa ngữ cảnh liên quan.

Khóa ngữ cảnh có thể được giữ độc quyền hoặc chia sẻ. Cơ chế này cho phép
gán các đặc quyền chính xác hơn khi bối cảnh đang hoạt động, thường là để
phân biệt nơi một chủ đề chỉ có thể đọc (chia sẻ) hoặc cũng có thể ghi (độc quyền) vào
dữ liệu được bảo vệ trong một bối cảnh.

Tập hợp các ngữ cảnh thực sự hoạt động trong một luồng nhất định tại một điểm nhất định
trong việc thực hiện chương trình là một khái niệm về thời gian chạy. Phân tích tĩnh hoạt động bằng cách
tính toán xấp xỉ của tập hợp đó, được gọi là môi trường ngữ cảnh. các
môi trường ngữ cảnh được tính toán cho mọi điểm của chương trình và mô tả
tập hợp các bối cảnh được xác định tĩnh là đang hoạt động hoặc không hoạt động tại thời điểm đó
điểm cụ thể. Môi trường này là một xấp xỉ bảo thủ của toàn bộ
tập hợp các ngữ cảnh sẽ thực sự hoạt động trong một luồng tại thời gian chạy.

Thông tin chi tiết cũng được ghi lại ZZ0000ZZ.

.. note::
   Clang's analysis explicitly does not infer context locks acquired or
   released by inline functions. It requires explicit annotations to (a) assert
   that it's not a bug if a context lock is released or acquired, and (b) to
   retain consistency between inline and non-inline function declarations.

Hạt nhân nguyên thủy được hỗ trợ
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Hiện nay các nguyên thủy đồng bộ hóa sau đây được hỗ trợ:
ZZ0000ZZ, ZZ0001ZZ, ZZ0002ZZ, ZZ0003ZZ, ZZ0004ZZ,
ZZ0005ZZ, RCU, SRCU (ZZ0006ZZ), ZZ0007ZZ, ZZ0008ZZ,
ZZ0009ZZ.

Để khởi tạo các biến được bảo vệ bởi khóa ngữ cảnh bằng cách khởi tạo
(ZZ0000ZZ), thích sử dụng ZZ0001ZZ hoặc
ZZ0002ZZ để khởi tạo các thành viên được bảo vệ như vậy
hoặc toàn cầu trong phạm vi kèm theo. Điều này khởi tạo khóa ngữ cảnh và xử lý
bối cảnh đang hoạt động trong phạm vi khởi tạo (khởi tạo ngụ ý
quyền truy cập độc quyền vào đối tượng cơ bản).

Ví dụ::

cấu trúc my_data {
            khóa spinlock_t;
            bộ đếm int __guarded_by(&lock);
    };

void init_my_data(struct my_data *d)
    {
            ...
bảo vệ(spinlock_init)(&d->lock);
            d->bộ đếm = 0;
            ...
    }

Ngoài ra, việc khởi tạo các biến được bảo vệ có thể được thực hiện bằng phân tích ngữ cảnh
bị vô hiệu hóa, tốt nhất là ở phạm vi nhỏ nhất có thể (do thiếu bất kỳ
kiểm tra): bằng biểu thức ZZ0000ZZ hoặc bằng
đánh dấu các chức năng khởi tạo nhỏ bằng ZZ0001ZZ
thuộc tính.

Các xác nhận của Lockdep, chẳng hạn như ZZ0001ZZ không phù hợp.

Từ khóa
~~~~~~~~

.. kernel-doc:: include/linux/compiler-context-analysis.h
   :identifiers: context_lock_struct
                 token_context_lock token_context_lock_instance
                 __guarded_by __pt_guarded_by
                 __must_hold
                 __must_not_hold
                 __acquires
                 __cond_acquires
                 __releases
                 __must_hold_shared
                 __acquires_shared
                 __cond_acquires_shared
                 __releases_shared
                 __acquire
                 __release
                 __acquire_shared
                 __release_shared
                 __acquire_ret
                 __acquire_shared_ret
                 context_unsafe
                 __context_unsafe
                 disable_context_analysis enable_context_analysis

.. note::
   The function attribute `__no_context_analysis` is reserved for internal
   implementation of context lock types, and should be avoided in normal code.

Lý lịch
----------

Clang ban đầu gọi tính năng này là ZZ0000ZZ, kèm theo một số từ khóa
và tài liệu vẫn sử dụng thuật ngữ chỉ phân tích an toàn luồng. Cái này
sau đó đã được thay đổi và tính năng trở nên linh hoạt hơn, có khả năng
xác định "khả năng" tùy chỉnh. Nền tảng của nó có thể được tìm thấy trong ZZ0001ZZ, được sử dụng để
chỉ định sự cho phép của các hoạt động phụ thuộc vào một số "khả năng"
nắm giữ (hoặc không nắm giữ).

Bởi vì tính năng này không chỉ có khả năng thể hiện các khả năng liên quan đến
nguyên thủy đồng bộ hóa và "khả năng" đã bị quá tải trong
kernel, cách đặt tên được chọn cho kernel khác với "Thread" ban đầu của Clang
danh pháp an toàn" và "khả năng"; chúng tôi gọi tính năng này là "Ngữ cảnh
Phân tích" để tránh nhầm lẫn. Việc triển khai nội bộ vẫn khiến
tham chiếu đến thuật ngữ của Clang ở một số nơi, chẳng hạn như ZZ0000ZZ
là tùy chọn cảnh báo vẫn xuất hiện trong thông báo chẩn đoán.