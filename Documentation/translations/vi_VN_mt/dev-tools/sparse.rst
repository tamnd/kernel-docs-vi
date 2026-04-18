.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/dev-tools/sparse.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

.. Copyright 2004 Linus Torvalds
.. Copyright 2004 Pavel Machek <pavel@ucw.cz>
.. Copyright 2006 Bob Copeland <me@bobcopeland.com>

thưa thớt
======

Sparse là công cụ kiểm tra ngữ nghĩa cho các chương trình C; nó có thể được sử dụng để tìm một
số vấn đề tiềm ẩn với mã hạt nhân.  Xem
ZZ0000ZZ để biết tổng quan về thưa thớt; tài liệu này
chứa một số thông tin thưa thớt dành riêng cho kernel.
Thông tin thêm về thưa thớt, chủ yếu là về nội bộ của nó, có thể được tìm thấy trong
các trang chính thức của nó tại ZZ0001ZZ


Sử dụng thưa thớt để kiểm tra đánh máy
-----------------------------

"__bitwise" là thuộc tính loại, vì vậy bạn phải làm điều gì đó như thế này ::

typedef int __bitwise pm_request_t;

enum chiều_request {
                PM_SUSPEND = (__buộc pm_request_t) 1,
                PM_RESUME = (__buộc pm_request_t) 2
        };

tạo ra các số nguyên "bitwise" PM_SUSPEND và PM_RESUME ("__force" là
ở đó bởi vì thưa thớt sẽ phàn nàn về việc truyền tới/từ kiểu bitwise,
nhưng trong trường hợp này chúng tôi thực sự muốn ép buộc chuyển đổi). Và bởi vì
các giá trị enum đều có cùng loại, bây giờ "enum pm_request" sẽ như vậy
gõ quá.

Và với gcc, tất cả nội dung "__bitwise"/"__force" đều biến mất và tất cả
cuối cùng trông giống như số nguyên đối với gcc.

Thành thật mà nói, bạn không cần enum ở đó. Trên đây thực sự chỉ là
rút gọn thành một loại "int __bitwise" đặc biệt.

Vì vậy, cách đơn giản hơn là chỉ cần làm::

typedef int __bitwise pm_request_t;

#define PM_SUSPEND ((__buộc pm_request_t) 1)
        #define PM_RESUME ((__buộc pm_request_t) 2)

và bây giờ bạn có tất cả cơ sở hạ tầng cần thiết cho việc kiểm tra đánh máy nghiêm ngặt.

Một lưu ý nhỏ: số nguyên không đổi "0" là đặc biệt. Bạn có thể sử dụng một
hằng số 0 dưới dạng kiểu số nguyên theo bit mà không hề phàn nàn.
Điều này là do "bitwise" (như tên ngụ ý) được thiết kế để thực hiện
đảm bảo rằng các kiểu bitwise không bị lẫn lộn (little-endian vs big-endian
vs cpu-endian vs bất cứ thứ gì), và có hằng số "0" thực sự _is_
đặc biệt.

Trở nên thưa thớt
--------------

Bạn có thể lấy tarball của các phiên bản được phát hành mới nhất từ:
ZZ0000ZZ

Ngoài ra, bạn có thể lấy ảnh chụp nhanh của phiên bản phát triển mới nhất
thưa thớt bằng cách sử dụng git để sao chép ::

git://git.kernel.org/pub/scm/devel/sparse/sparse.git

Một khi bạn đã có nó, chỉ cần làm::

làm
        thực hiện cài đặt

với tư cách là người dùng thông thường và nó sẽ cài đặt thưa thớt trong thư mục ~/bin của bạn.

Sử dụng thưa thớt
------------

Thực hiện tạo hạt nhân bằng "make C=1" để chạy thưa thớt trên tất cả các tệp C nhận được
được biên dịch lại hoặc sử dụng "make C=2" để chạy thưa thớt trên các tệp nếu chúng cần
có được biên dịch lại hay không.  Cách thứ hai là một cách nhanh chóng để kiểm tra toàn bộ cây nếu bạn
đã xây dựng nó rồi.

Biến tạo CF tùy chọn có thể được sử dụng để chuyển các đối số thành thưa thớt.  các
hệ thống xây dựng tự động chuyển -Wbitwise sang thưa thớt.

Lưu ý rằng thưa thớt xác định ký hiệu tiền xử lý __CHECKER__.
