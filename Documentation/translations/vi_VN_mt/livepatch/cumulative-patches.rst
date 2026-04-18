.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/livepatch/cumulative-patches.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

======================================
Bản vá thay thế nguyên tử & tích lũy
======================================

Có thể có sự phụ thuộc giữa các bản vá trực tiếp. Nếu cần nhiều bản vá
để thực hiện các thay đổi khác nhau cho (các) chức năng giống nhau thì chúng ta cần xác định
thứ tự cài đặt các bản vá. Và thực hiện chức năng
từ bất kỳ bản vá trực tiếp mới nào đều phải được thực hiện chồng lên các bản cũ hơn.

Điều này có thể trở thành cơn ác mộng khi bảo trì. Đặc biệt là khi có nhiều bản vá hơn
đã sửa đổi cùng một chức năng theo những cách khác nhau.

Một giải pháp tao nhã đi kèm với tính năng có tên "Thay thế nguyên tử". Nó cho phép
tạo ra cái gọi là "Bản vá tích lũy". Chúng bao gồm tất cả những thay đổi mong muốn
từ tất cả các bản vá lỗi trực tiếp cũ hơn và thay thế chúng hoàn toàn trong một lần chuyển đổi.

Cách sử dụng
-----

Việc thay thế nguyên tử có thể được kích hoạt bằng cách đặt cờ "thay thế" trong struct klp_patch,
ví dụ::

cấu trúc tĩnh bản vá klp_patch = {
		.mod = THIS_MODULE,
		.objs = objs,
		.replace = đúng,
	};

Sau đó, tất cả các quy trình sẽ được di chuyển để chỉ sử dụng mã từ bản vá mới.
Sau khi quá trình chuyển đổi kết thúc, tất cả các bản vá cũ hơn sẽ tự động được
bị vô hiệu hóa.

Trình xử lý Ftrace được loại bỏ một cách minh bạch khỏi các hàm không có
được sửa đổi lâu hơn bởi bản vá tích lũy mới.

Kết quả là, các tác giả của bản vá trực tiếp có thể chỉ duy trì nguồn cho một
bản vá tích lũy. Nó giúp giữ cho bản vá nhất quán trong khi thêm hoặc
loại bỏ các bản sửa lỗi hoặc tính năng khác nhau.

Người dùng chỉ có thể giữ lại bản vá cuối cùng được cài đặt trên hệ thống sau
quá trình chuyển đổi sang đã kết thúc. Nó giúp nhìn rõ mã gì
thực tế đang được sử dụng. Ngoài ra, livepatch có thể được coi là "bình thường"
mô-đun sửa đổi hành vi kernel. Sự khác biệt duy nhất đó là
nó có thể được cập nhật trong thời gian chạy mà không làm hỏng chức năng của nó.


Đặc trưng
--------

Việc thay thế nguyên tử cho phép:

- Hoàn nguyên nguyên tử một số chức năng trong bản vá trước đó trong khi
    nâng cấp các chức năng khác.

- Loại bỏ tác động hiệu suất cuối cùng do chuyển hướng lõi gây ra
    cho các chức năng không còn được vá.

- Giảm sự nhầm lẫn của người dùng về sự phụ thuộc giữa các bản vá trực tiếp.


Hạn chế:
------------

- Sau khi hoạt động kết thúc, không có cách nào đơn giản
    để đảo ngược nó và khôi phục các bản vá được thay thế một cách nguyên tử.

Một cách thực hành tốt là đặt cờ .replace trong bất kỳ bản vá trực tiếp nào được phát hành.
    Sau đó, việc thêm lại một livepatch cũ hơn tương đương với việc hạ cấp
    vào bản vá đó. Điều này là an toàn miễn là các bản vá trực tiếp làm _không_ làm
    các sửa đổi bổ sung trong (bỏ) các lệnh gọi lại vá hoặc trong module_init()
    hoặc các hàm module_exit(), xem bên dưới.

Cũng lưu ý rằng bản vá thay thế có thể được gỡ bỏ và tải lại
    chỉ khi quá trình chuyển đổi không bị ép buộc.


- Chỉ các lệnh gọi lại bản vá (không) từ bản vá trực tiếp tích lũy _new_ mới được
    bị xử tử. Mọi lệnh gọi lại từ các bản vá được thay thế đều bị bỏ qua.

Nói cách khác, bản vá tích lũy chịu trách nhiệm thực hiện bất kỳ hành động nào
    cần thiết để thay thế đúng cách bất kỳ bản vá cũ nào.

Do đó, có thể nguy hiểm khi thay thế các bản vá tích lũy mới hơn bằng cách
    những cái cũ hơn. Các bản vá lỗi trực tiếp cũ có thể không cung cấp các lệnh gọi lại cần thiết.

Điều này có thể được coi là một hạn chế trong một số trường hợp. Nhưng nó làm cho cuộc sống
    dễ dàng hơn ở nhiều người khác. Chỉ có bản vá trực tiếp tích lũy mới biết điều gì
    các bản sửa lỗi/tính năng được thêm/xóa và những hành động đặc biệt nào là cần thiết
    để có một quá trình chuyển đổi suôn sẻ.

Trong mọi trường hợp, sẽ là một cơn ác mộng khi nghĩ về thứ tự của
    các cuộc gọi lại khác nhau và sự tương tác của chúng nếu các cuộc gọi lại từ tất cả
    các bản vá kích hoạt đã được gọi.


- Không có cách xử lý đặc biệt nào đối với các biến bóng. Tác giả Livepatch
    phải tạo ra các quy tắc riêng của họ làm thế nào để vượt qua chúng từ một tích lũy
    vá sang cái khác. Đặc biệt là không nên mù quáng loại bỏ
    chúng trong các hàm module_exit().

Một cách thực hành tốt có thể là loại bỏ các biến bóng trong phần sau chưa vá
    gọi lại. Nó chỉ được gọi khi livepatch bị vô hiệu hóa đúng cách.
