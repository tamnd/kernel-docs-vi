.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/dev-tools/clang-format.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. _clangformat:

định dạng clang
===============

ZZ0000ZZ là công cụ định dạng mã C/C++/... theo
một tập hợp các quy tắc và heuristic. Giống như hầu hết các công cụ, nó không hoàn hảo
cũng không bao gồm mọi trường hợp riêng lẻ, nhưng nó đủ tốt để có ích.

ZZ0000ZZ có thể được sử dụng cho một số mục đích:

- Định dạng lại nhanh chóng một khối mã theo kiểu kernel. Đặc biệt hữu ích
    khi di chuyển mã xung quanh và căn chỉnh/sắp xếp. Xem clangformatreformat_.

- Phát hiện các lỗi về kiểu dáng, lỗi chính tả và các cải tiến có thể có trong tệp
    bạn duy trì, các bản vá bạn xem xét, các điểm khác biệt, v.v. Xem clangformatreview_.

- Giúp bạn tuân theo các quy tắc về phong cách mã hóa, đặc biệt hữu ích cho những người
    mới phát triển kernel hoặc làm việc cùng lúc trong một số
    các dự án có phong cách mã hóa khác nhau.

Tệp cấu hình của nó là ZZ0001ZZ trong thư mục gốc của cây hạt nhân.
Các quy tắc trong đó cố gắng xấp xỉ hạt nhân phổ biến nhất
phong cách mã hóa. Họ cũng cố gắng theo dõi ZZ0000ZZ
càng nhiều càng tốt. Vì không phải tất cả kernel đều theo cùng một kiểu,
có thể bạn muốn điều chỉnh các giá trị mặc định cho một mục cụ thể
hệ thống con hoặc thư mục. Để làm như vậy, bạn có thể ghi đè các giá trị mặc định bằng cách viết
một tệp ZZ0002ZZ khác trong thư mục con.

Bản thân công cụ này đã được đưa vào kho lưu trữ phổ biến
Bản phân phối Linux trong một thời gian dài. Tìm kiếm ZZ0000ZZ trong
kho lưu trữ của bạn. Nếu không, bạn có thể tải xuống bản dựng sẵn
Các tệp nhị phân LLVM/clang hoặc xây dựng mã nguồn từ:

ZZ0000ZZ

Xem thêm thông tin về công cụ tại:

ZZ0000ZZ

ZZ0000ZZ


.. _clangformatreview:

Xem lại các tập tin và bản vá cho phong cách mã hóa
---------------------------------------------------

Bằng cách chạy công cụ ở chế độ nội tuyến, bạn có thể xem lại toàn bộ hệ thống con,
các thư mục hoặc tệp riêng lẻ để tìm lỗi kiểu mã, lỗi chính tả hoặc cải tiến.

Để làm như vậy, bạn có thể chạy một cái gì đó như::

# Make chắc chắn rằng thư mục làm việc của bạn sạch sẽ!
    clang-format -i kernel/*.[ch]

Và sau đó hãy xem git diff.

Việc đếm các dòng của sự khác biệt như vậy cũng hữu ích cho việc cải thiện/tinh chỉnh
các tùy chọn kiểu trong tệp cấu hình; cũng như thử nghiệm cái mới
Các tính năng/phiên bản ZZ0000ZZ.

ZZ0000ZZ cũng hỗ trợ đọc các khác biệt thống nhất để bạn có thể xem lại
các bản vá và git khác nhau một cách dễ dàng. Xem tài liệu tại:

ZZ0000ZZ

Để tránh ZZ0000ZZ định dạng một số phần của tệp, bạn có thể thực hiện ::

int format_code;
    // tắt định dạng clang
        void unformatted_code ;
    // bật định dạng clang
    vô hiệu hóa định dạng_code_again;

Mặc dù việc sử dụng tính năng này để giữ cho tệp luôn được đồng bộ hóa với
ZZ0000ZZ, đặc biệt nếu bạn đang ghi các tập tin mới hoặc nếu bạn đang
người bảo trì, xin lưu ý rằng mọi người có thể đang chạy khác
Phiên bản ZZ0001ZZ hoặc không có sẵn. Vì vậy,
có lẽ bạn nên hạn chế sử dụng điều này trong các nguồn kernel;
ít nhất là cho đến khi chúng ta thấy liệu ZZ0002ZZ có trở nên phổ biến hay không.


.. _clangformatreformat:

Định dạng lại khối mã
---------------------------

Bằng cách sử dụng tích hợp với trình soạn thảo văn bản của bạn, bạn có thể định dạng lại tùy ý
khối (lựa chọn) mã chỉ bằng một lần nhấn phím. Điều này đặc biệt
hữu ích khi di chuyển mã xung quanh, đối với mã phức tạp được thụt lề sâu,
đối với macro nhiều dòng (và căn chỉnh dấu gạch chéo ngược của chúng), v.v.

Hãy nhớ rằng bạn luôn có thể điều chỉnh các thay đổi sau đó trong những trường hợp đó
nơi công cụ không thực hiện công việc tối ưu. Nhưng như một phép tính gần đúng đầu tiên,
nó có thể rất hữu ích.

Có tích hợp cho nhiều trình soạn thảo văn bản phổ biến. Đối với một số người trong số họ,
như vim, emacs, BBEdit và Visual Studio, bạn có thể tìm thấy sự hỗ trợ tích hợp sẵn.
Để được hướng dẫn, hãy đọc phần thích hợp tại:

ZZ0000ZZ

Dành cho Atom, Eclipse, Sublime Text, Visual Studio Code, XCode và các loại khác
trình soạn thảo và IDE, bạn sẽ có thể tìm thấy các plugin sẵn sàng sử dụng.

Đối với trường hợp sử dụng này, hãy cân nhắc sử dụng ZZ0000ZZ thứ cấp
để bạn có thể điều chỉnh một vài tùy chọn. Xem clangformatextra_.


.. _clangformatmissing:

Thiếu hỗ trợ
---------------

ZZ0000ZZ thiếu hỗ trợ cho một số tính năng phổ biến
trong mã hạt nhân. Chúng rất dễ nhớ nên nếu bạn sử dụng công cụ này
thường xuyên, bạn sẽ nhanh chóng học cách tránh/bỏ qua những điều đó.

Đặc biệt, một số điều rất phổ biến bạn sẽ nhận thấy là:

- Các khối thẳng hàng của ZZ0000ZZ một dòng, ví dụ::

#define TRACING_MAP_BITS_DEFAULT 11
        #define TRACING_MAP_BITS_MAX 17
        #define TRACING_MAP_BITS_MIN 7

so với::

#define TRACING_MAP_BITS_DEFAULT 11
        #define TRACING_MAP_BITS_MAX 17
        #define TRACING_MAP_BITS_MIN 7

- Các công cụ khởi tạo được chỉ định căn chỉnh, ví dụ::

const tĩnh struct file_Operations uprobe_events_ops = {
                .chủ sở hữu = THIS_MODULE,
                .open = thăm dò_open,
                .read = seq_read,
                .llseek = seq_lseek,
                .release = seq_release,
                .write = thăm dò_write,
        };

so với::

const tĩnh struct file_Operations uprobe_events_ops = {
                .chủ sở hữu = THIS_MODULE,
                .open = thăm dò_open,
                .read = seq_read,
                .llseek = seq_lseek,
                .release = seq_release,
                .write = thăm dò_write,
        };


.. _clangformatextra:

Các tính năng/tùy chọn bổ sung
------------------------------

Một số tùy chọn tính năng/kiểu dáng không được bật theo mặc định trong cấu hình
tập tin để giảm thiểu sự khác biệt giữa đầu ra và hiện tại
mã. Nói cách khác, để tạo ra sự khác biệt càng nhỏ càng tốt,
giúp việc xem lại kiểu tệp đầy đủ cũng như các khác biệt và bản vá trở nên dễ dàng
càng tốt.

Trong các trường hợp khác (ví dụ: các hệ thống con/thư mục/tệp cụ thể), kiểu kernel
có thể khác và việc bật một số tùy chọn này có thể gần đúng
phong cách ở đó tốt hơn

Ví dụ:

- Căn chỉnh bài tập (ZZ0000ZZ).

- Căn chỉnh tờ khai (ZZ0000ZZ).

- Chỉnh lại văn bản trong nhận xét (ZZ0000ZZ).

- Sắp xếp ZZ0000ZZ (ZZ0001ZZ).

Chúng thường hữu ích cho việc định dạng lại khối, thay vì toàn bộ tệp.
Bạn có thể muốn tạo một tệp ZZ0000ZZ khác và sử dụng tệp đó
thay vào đó từ trình soạn thảo/IDE của bạn.
