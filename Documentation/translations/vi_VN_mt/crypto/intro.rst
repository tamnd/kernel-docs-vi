.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/crypto/intro.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

Thông số kỹ thuật giao diện hạt nhân Crypto API
=========================================

Giới thiệu
------------

Tiền điện tử hạt nhân API cũng cung cấp một bộ mật mã phong phú
như các cơ chế và phương pháp chuyển đổi dữ liệu khác để gọi chúng.
Tài liệu này chứa mô tả về API và cung cấp ví dụ
mã.

Để hiểu và sử dụng đúng cách mật mã kernel API, hãy giải thích ngắn gọn
cấu trúc của nó đã cho. Dựa trên kiến trúc, API có thể
tách thành các thành phần khác nhau. Theo kiến trúc
đặc điểm kỹ thuật, gợi ý cho các nhà phát triển mật mã được cung cấp. Con trỏ tới
tài liệu gọi hàm API được cung cấp ở cuối.

Mật mã hạt nhân API gọi tất cả các thuật toán là "biến đổi".
Do đó, biến xử lý mật mã thường có tên "tfm". Ngoài ra
hoạt động mã hóa, kernel crypto API cũng biết nén
các phép biến đổi và xử lý chúng giống như mật mã.

Mật mã hạt nhân API phục vụ các loại thực thể sau:

- người tiêu dùng yêu cầu dịch vụ mật mã

- việc triển khai chuyển đổi dữ liệu (thường là mật mã) có thể
   được người tiêu dùng gọi bằng cách sử dụng kernel crypto API

Thông số kỹ thuật này dành cho người tiêu dùng tiền điện tử hạt nhân API vì
cũng như dành cho các nhà phát triển triển khai mật mã. Thông số kỹ thuật API này,
tuy nhiên, không thảo luận về tất cả các lệnh gọi API có sẵn để chuyển đổi dữ liệu
việc triển khai (tức là việc triển khai mật mã và các hoạt động khác
các phép biến đổi (chẳng hạn như CRC hoặc thậm chí các thuật toán nén) có thể
đăng ký với kernel crypto API).

Lưu ý: Thuật ngữ "chuyển đổi" và thuật toán mã hóa được sử dụng
có thể thay thế cho nhau.

Thuật ngữ
-----------

Việc triển khai chuyển đổi là một mã hoặc giao diện thực tế để
phần cứng thực hiện một chuyển đổi nhất định với độ chính xác
hành vi được xác định.

Đối tượng biến đổi (TFM) là một thể hiện của phép biến đổi
thực hiện. Có thể có nhiều đối tượng chuyển đổi được liên kết
với một lần thực hiện chuyển đổi duy nhất. Mỗi cái đó
các đối tượng chuyển đổi được nắm giữ bởi người tiêu dùng tiền điện tử API hoặc người khác
sự biến đổi. Đối tượng chuyển đổi được phân bổ khi mật mã API
người tiêu dùng yêu cầu thực hiện chuyển đổi. Khi đó người tiêu dùng là
được cung cấp một cấu trúc chứa đối tượng chuyển đổi (TFM).

Cấu trúc chứa các đối tượng chuyển đổi cũng có thể được tham chiếu
thành "tay cầm mật mã". Việc xử lý mật mã như vậy luôn phải tuân theo
các giai đoạn sau được phản ánh trong các cuộc gọi API áp dụng cho các giai đoạn đó
một tay cầm mật mã:

1. Khởi tạo một bộ xử lý mật mã.

2. Thực hiện tất cả các hoạt động mật mã dự định áp dụng cho tay cầm
   trong đó tay cầm mật mã phải được trang bị cho mọi lệnh gọi API.

3. Phá hủy tay cầm mật mã.

Khi sử dụng lệnh gọi API khởi tạo, một bộ xử lý mật mã sẽ được tạo và
được trả lại cho người tiêu dùng. Vì vậy, hãy tham khảo tất cả các bước khởi tạo
Các lệnh gọi API đề cập đến kiểu cấu trúc dữ liệu mà người tiêu dùng mong đợi
nhận và sau đó sử dụng. Các cuộc gọi API khởi tạo có
tất cả các quy ước đặt tên giống nhau của crypto_alloc\*.

Bối cảnh chuyển đổi là dữ liệu riêng tư được liên kết với
đối tượng chuyển đổi.
