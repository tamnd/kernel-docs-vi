.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/userspace-api/futex2.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

======
futex2
======

:Tác giả: André Almeida <andrealmeid@collabora.com>

futex, hay mutex người dùng nhanh, là một tập hợp các cuộc gọi hệ thống cho phép không gian người dùng tạo
cơ chế đồng bộ hóa hiệu suất, chẳng hạn như mutexes, semaphores và
các biến có điều kiện trong không gian người dùng. Các thư viện chuẩn C, như glibc, sử dụng nó
như một phương tiện để triển khai các giao diện cấp cao hơn như pthreads.

futex2 là phiên bản tiếp theo của tòa nhà futex ban đầu, được thiết kế để khắc phục
hạn chế của giao diện ban đầu.

Người dùng API
========

ZZ0000ZZ
-----------------

Đợi trên một mảng futex, đánh thức bất kỳ ::

futex_waitv(struct futex_waitv *waiters, unsigned int nr_futexes,
              cờ int không dấu, struct timespec *timeout, clockid_t clockid)

cấu trúc futex_waitv {
        __u64 giá trị;
        __u64 uaddr;
        __u32 cờ;
        __u32 __reserved;
  };

Không gian người dùng đặt một mảng cấu trúc futex_waitv (tối đa 128 mục),
sử dụng ZZ0000ZZ cho địa chỉ chờ đợi, ZZ0001ZZ cho giá trị mong đợi
và ZZ0002ZZ để chỉ định loại (ví dụ: riêng tư) và kích thước của futex.
ZZ0003ZZ cần phải bằng 0, nhưng nó có thể được sử dụng để mở rộng trong tương lai. các
con trỏ cho mục đầu tiên của mảng được chuyển dưới dạng ZZ0004ZZ. Không hợp lệ
địa chỉ cho ZZ0005ZZ hoặc cho bất kỳ ZZ0006ZZ nào trả về ZZ0007ZZ.

Nếu không gian người dùng có con trỏ 32 bit, nó sẽ thực hiện chuyển đổi rõ ràng để đảm bảo
các bit trên bằng 0. ZZ0000ZZ thực hiện được công việc phức tạp và hiệu quả
cả hai con trỏ 32/64-bit.

ZZ0000ZZ chỉ định kích thước của mảng. Các số trong [1, 128]
interval sẽ khiến syscall trả về ZZ0001ZZ.

Đối số ZZ0000ZZ của tòa nhà cao tầng cần phải bằng 0, nhưng nó có thể được sử dụng cho
phần mở rộng trong tương lai.

Đối với mỗi mục trong mảng ZZ0000ZZ, giá trị hiện tại tại ZZ0001ZZ được so sánh
tới ZZ0002ZZ. Nếu nó khác, syscall sẽ hoàn tác tất cả công việc đã thực hiện cho đến nay và
trả lại ZZ0003ZZ. Nếu tất cả các thử nghiệm và xác minh thành công, syscall sẽ đợi cho đến khi
một trong những điều sau đây xảy ra:

- Hết thời gian chờ, trả về ZZ0000ZZ.
- Một tín hiệu được gửi đến tác vụ ngủ, trả về ZZ0001ZZ.
- Một số futex trong danh sách đã được đánh thức, trả về chỉ số của một số futex đã đánh thức.

Bạn có thể tìm thấy ví dụ về cách sử dụng giao diện tại ZZ0000ZZ.

Hết giờ
-------

Đối số ZZ0000ZZ là đối số tùy chọn trỏ đến một
thời gian chờ tuyệt đối. Bạn cần chỉ định loại đồng hồ đang được sử dụng tại
Đối số ZZ0001ZZ. ZZ0002ZZ và ZZ0003ZZ được hỗ trợ.
Tòa nhà cao tầng này chỉ chấp nhận cấu trúc timespec 64bit.

Các loại futex
--------------

Futex có thể là riêng tư hoặc chia sẻ. Riêng tư được sử dụng cho các quy trình
chia sẻ cùng một không gian bộ nhớ và địa chỉ ảo của futex sẽ là
giống nhau cho tất cả các quá trình. Điều này cho phép tối ưu hóa trong kernel. Để sử dụng
futex riêng tư, cần chỉ định ZZ0000ZZ trong futex
cờ. Đối với các tiến trình không chia sẻ cùng một không gian bộ nhớ và do đó có thể
có các địa chỉ ảo khác nhau cho cùng một futex (ví dụ: sử dụng một
bộ nhớ chia sẻ dựa trên tập tin) yêu cầu các cơ chế nội bộ khác nhau để có được
được xếp hàng đúng cách. Đây là hành vi mặc định và nó hoạt động với cả chế độ riêng tư
và chia sẻ futexes.

Futexes có thể có kích thước khác nhau: 8, 16, 32 hoặc 64 bit. Hiện tại, duy nhất
cái được hỗ trợ là futex có kích thước 32 bit và nó cần được chỉ định bằng cách sử dụng
Cờ ZZ0000ZZ.