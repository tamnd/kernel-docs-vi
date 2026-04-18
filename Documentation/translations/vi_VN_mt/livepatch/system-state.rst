.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/livepatch/system-state.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

======================
Thay đổi trạng thái hệ thống
====================

Một số người dùng thực sự miễn cưỡng khởi động lại hệ thống. Điều này mang đến sự cần thiết
để cung cấp nhiều bản vá trực tiếp hơn và duy trì khả năng tương thích giữa chúng.

Việc duy trì nhiều bản vá trực tiếp dễ dàng hơn nhiều với các bản vá trực tiếp tích lũy.
Mỗi bản livepatch mới sẽ thay thế hoàn toàn bất kỳ bản livepatch cũ nào. Nó có thể giữ,
thêm và thậm chí loại bỏ các bản sửa lỗi. Và thông thường việc thay thế bất kỳ phiên bản nào là an toàn
của bản livepatch với bất kỳ bản nào khác nhờ tính năng thay thế nguyên tử.

Sự cố có thể xảy ra với các biến bóng và lệnh gọi lại. Họ có thể
thay đổi hành vi hoặc trạng thái của hệ thống để nó không còn an toàn nữa
quay lại và sử dụng bản livepatch cũ hơn hoặc mã hạt nhân gốc. Ngoài ra
bất kỳ bản vá trực tiếp mới nào cũng phải có khả năng phát hiện những thay đổi đã xảy ra
được thực hiện bởi các bản vá trực tiếp đã được cài đặt.

Đây là lúc việc theo dõi trạng thái hệ thống livepatch trở nên hữu ích. Nó
cho phép:

- lưu trữ dữ liệu cần thiết để thao tác và khôi phục trạng thái hệ thống

- xác định khả năng tương thích giữa các bản vá trực tiếp bằng cách sử dụng id thay đổi
    và phiên bản


1. Trạng thái hệ thống Livepatch API
=============================

Trạng thái của hệ thống có thể được sửa đổi bằng một số lệnh gọi lại bản vá trực tiếp
hoặc bằng mã mới được sử dụng. Ngoài ra, có thể tìm thấy những thay đổi được thực hiện bởi
đã cài đặt các bản vá trực tiếp.

Mỗi trạng thái sửa đổi được mô tả bởi struct klp_state, xem
bao gồm/linux/livepatch.h.

Mỗi livepatch xác định một mảng cấu trúc klp_states. Họ đề cập đến
tất cả các trạng thái mà livepatch sửa đổi.

Tác giả livepatch phải xác định hai trường sau cho mỗi trường
cấu trúc klp_state:

-ZZ0000ZZ

- Số khác 0 dùng để xác định trạng thái hệ thống bị ảnh hưởng.

-ZZ0000ZZ

- Số mô tả sự thay đổi trạng thái của hệ thống đó
      được hỗ trợ bởi livepatch nhất định.

Trạng thái có thể được điều khiển bằng hai hàm:

- klp_get_state()

- Nhận struct klp_state được liên kết với livepatch đã cho
      và id trạng thái.

- klp_get_prev_state()

- Nhận struct klp_state được liên kết với id tính năng đã cho và
      đã cài đặt các bản vá trực tiếp.

2. Khả năng tương thích của Livepatch
==========================

Phiên bản trạng thái hệ thống được sử dụng để ngăn tải các bản vá trực tiếp không tương thích.
Việc kiểm tra được thực hiện khi bản vá trực tiếp được bật. Các quy tắc là:

- Mọi sửa đổi trạng thái hệ thống hoàn toàn mới đều được cho phép.

- Cho phép sửa đổi trạng thái hệ thống với phiên bản tương tự hoặc cao hơn
    cho các trạng thái hệ thống đã được sửa đổi.

- Các bản vá trực tiếp tích lũy phải xử lý tất cả các sửa đổi trạng thái hệ thống từ
    đã cài đặt các bản vá trực tiếp.

- Các bản vá trực tiếp không tích lũy được phép chạm vào đã được sửa đổi
    các trạng thái hệ thống.

3. Các tình huống được hỗ trợ
======================

Livepatch có vòng đời của chúng và hệ thống cũng vậy
những thay đổi trạng thái. Mọi livepatch tương thích đều phải hỗ trợ những điều sau
kịch bản:

- Sửa đổi trạng thái hệ thống khi livepatch được kích hoạt và trạng thái
    chưa được sửa đổi bởi một bản vá trực tiếp đang được
    được thay thế.

- Tiếp quản hoặc cập nhật sửa đổi trạng thái hệ thống khi đã có
    được thực hiện bởi một livepatch đang được thay thế.

- Khôi phục trạng thái ban đầu khi tắt livepatch.

- Khôi phục trạng thái trước đó khi quá trình chuyển đổi được hoàn nguyên.
    Nó có thể là trạng thái hệ thống ban đầu hoặc sự sửa đổi trạng thái
    được thực hiện bởi các bản vá trực tiếp đang được thay thế.

- Xóa mọi thay đổi đã thực hiện khi xảy ra lỗi và bản vá trực tiếp
    không thể kích hoạt được.

4. Dự kiến ​​sử dụng
=================

Trạng thái hệ thống thường được sửa đổi bằng lệnh gọi lại bản vá trực tiếp. Dự kiến
vai trò của mỗi cuộc gọi lại như sau:

ZZ0000ZZ

- Phân bổ ZZ0000ZZ khi cần thiết. Việc phân bổ có thể thất bại
    và ZZ0001ZZ là lệnh gọi lại duy nhất có thể ngừng tải
    của bản vá trực tiếp. Việc phân bổ là không cần thiết khi dữ liệu
    đã được cung cấp bởi các bản vá trực tiếp được cài đặt trước đó.

- Thực hiện bất kỳ hành động chuẩn bị nào khác cần thiết
    mã mới ngay cả trước khi quá trình chuyển đổi kết thúc.
    Ví dụ: khởi tạo ZZ0000ZZ.

Bản thân trạng thái hệ thống thường được sửa đổi trong ZZ0000ZZ
    khi toàn bộ hệ thống có thể xử lý nó.

- Tự dọn dẹp mớ hỗn độn của mình trong trường hợp có lỗi. Nó có thể được thực hiện bởi một phong tục
    mã hoặc bằng cách gọi ZZ0000ZZ một cách rõ ràng.

ZZ0000ZZ

- Sao chép ZZ0000ZZ từ bản livepatch trước đó khi có
    tương thích.

- Thực hiện sửa đổi trạng thái hệ thống thực tế. Cuối cùng cho phép
    mã mới để sử dụng nó.

- Đảm bảo rằng ZZ0000ZZ có tất cả thông tin cần thiết.

- Miễn phí ZZ0000ZZ thay thế các bản vá lỗi trực tiếp khi có
    không còn cần thiết nữa.

ZZ0000ZZ

- Ngăn chặn code, do livepatch thêm vào, dựa vào hệ thống
    sự thay đổi trạng thái.

- Hoàn nguyên việc sửa đổi trạng thái hệ thống..

ZZ0000ZZ

- Phân biệt việc đảo ngược quá trình chuyển đổi và vô hiệu hóa livepatch bằng cách
    kiểm tra ZZ0000ZZ.

- Trường hợp chuyển ngược lại, khôi phục lại hệ thống trước đó
    trạng thái. Nó có thể có nghĩa là không làm gì cả.

- Xóa mọi cài đặt hoặc dữ liệu không còn cần thiết.

.. note::

   *pre_unpatch()* typically does symmetric operations to *post_patch()*.
   Except that it is called only when the livepatch is being disabled.
   Therefore it does not need to care about any previously installed
   livepatch.

   *post_unpatch()* typically does symmetric operations to *pre_patch()*.
   It might be called also during the transition reverse. Therefore it
   has to handle the state of the previously installed livepatches.
