.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/driver-api/firmware/firmware-usage-guidelines.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

=====================
Hướng dẫn về phần sụn
===================

Người dùng chuyển sang kernel mới hơn nên ZZ0000ZZ phải cài đặt kernel mới hơn
tập tin phần sụn để giữ cho phần cứng của chúng hoạt động. Đồng thời cập nhật
các tập tin phần sụn không được gây ra bất kỳ sự hồi quy nào cho người dùng kernel cũ hơn
phát hành.

Trình điều khiển sử dụng phần sụn từ linux-firmware phải tuân theo các quy tắc trong
hướng dẫn này. (Khi có sự kiểm soát hạn chế đối với phần sụn,
tức là công ty không hỗ trợ Linux, phần mềm có nguồn gốc từ nhiều nơi khác nhau,
thì tất nhiên những quy tắc này sẽ không được áp dụng nghiêm ngặt.)

* Các tập tin phần sụn phải được thiết kế theo cách cho phép kiểm tra
  Phiên bản firmware ABI thay đổi. Khuyến cáo nên có các tập tin phần sụn
  được phiên bản với ít nhất một phiên bản chính/phụ. Người ta đề nghị rằng
  các tập tin firmware trong linux-firmware được đặt tên theo một số thiết bị
  tên cụ thể và chỉ là phiên bản chính. Phiên bản phần sụn nên
  được lưu trữ trong tiêu đề phần sụn hoặc như một ngoại lệ, như một phần của
  tên tệp chương trình cơ sở, để cho phép trình điều khiển phát hiện bất kỳ tệp nào không phải ABI
  sửa chữa/thay đổi. Các tập tin phần sụn trong linux-firmware phải là
  được ghi đè bằng phiên bản chính tương thích mới nhất. Chuyên ngành mới hơn
  phiên bản phần sụn sẽ vẫn tương thích với tất cả các hạt nhân tải
  số chính đó.

* Nếu hỗ trợ kernel cho phần cứng thường không hoạt động, hoặc
  phần cứng không có sẵn cho công chúng sử dụng, điều này có thể
  bị bỏ qua cho đến khi có bản phát hành kernel đầu tiên kích hoạt phần cứng đó.
  Điều này có nghĩa là không có sự cố phiên bản chính nào mà không giữ lại kernel
  khả năng tương thích ngược cho các phiên bản chính cũ hơn.  Phiên bản nhỏ
  các va chạm không nên giới thiệu các tính năng mới mà các hạt nhân mới hơn phụ thuộc vào
  không tùy ý.

* Nếu bản sửa lỗi bảo mật cần bản sửa lỗi chương trình cơ sở và hạt nhân lockstep để
  thành công thì tất cả các phiên bản chính được hỗ trợ trong phần sụn linux
  repo được yêu cầu bởi các hạt nhân ổn định/LTS hiện được hỗ trợ,
  nên được cập nhật với bản sửa lỗi bảo mật. Các bản vá kernel nên
  phát hiện xem phần sụn có đủ mới để khai báo nếu vấn đề bảo mật không
  đã được sửa.  Tất cả thông tin liên lạc xung quanh các bản sửa lỗi bảo mật phải hướng tới
  sửa cả firmware và kernel. Nếu một bản sửa lỗi bảo mật yêu cầu
  không dùng các phiên bản chính cũ nữa thì việc này chỉ nên được thực hiện dưới dạng
  lựa chọn cuối cùng và phải được nêu rõ trong mọi thông tin liên lạc.

* Các tệp chương trình cơ sở ảnh hưởng đến Người dùng API (UAPI) sẽ không được giới thiệu
  những thay đổi phá vỡ các chương trình không gian người dùng hiện có. Cập nhật chương trình cơ sở như vậy
  phải đảm bảo khả năng tương thích ngược với các ứng dụng không gian người dùng hiện có.
  Điều này bao gồm việc duy trì các giao diện và hành vi nhất quán
  chương trình không gian người dùng dựa vào.
