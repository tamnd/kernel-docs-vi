.. SPDX-License-Identifier: GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/v4l/pixfmt-intro.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

.. c:namespace:: V4L

**********************
Định dạng hình ảnh tiêu chuẩn
**********************

Để trao đổi hình ảnh giữa trình điều khiển và ứng dụng, cần
cần thiết phải có các định dạng dữ liệu hình ảnh tiêu chuẩn mà cả hai bên sẽ
giải thích theo cùng một cách. V4L2 bao gồm một số định dạng như vậy và định dạng này
phần này được dự định là một đặc điểm kỹ thuật rõ ràng của tiêu chuẩn
định dạng dữ liệu hình ảnh trong V4L2.

Tuy nhiên, trình điều khiển V4L2 không bị giới hạn ở các định dạng này. Trình điều khiển cụ thể
các định dạng có thể. Trong trường hợp đó, ứng dụng có thể phụ thuộc vào codec
để chuyển đổi hình ảnh sang một trong các định dạng tiêu chuẩn khi cần thiết. Nhưng
dữ liệu vẫn có thể được lưu trữ và truy xuất ở định dạng độc quyền. cho
ví dụ: một thiết bị có thể hỗ trợ định dạng nén độc quyền.
Các ứng dụng vẫn có thể thu thập và lưu dữ liệu ở dạng nén
định dạng, tiết kiệm nhiều dung lượng ổ đĩa và sau đó sử dụng codec để chuyển đổi
hình ảnh sang định dạng màn hình X Windows khi video được hiển thị.

Mặc dù vậy, cuối cùng, một số định dạng tiêu chuẩn vẫn cần thiết, vì vậy V4L2
đặc điểm kỹ thuật sẽ không hoàn chỉnh nếu không có tiêu chuẩn được xác định rõ ràng
các định dạng.

Các định dạng tiêu chuẩn V4L2 chủ yếu là các định dạng không nén. Các pixel
luôn được sắp xếp trong bộ nhớ từ trái qua phải và từ trên xuống
đáy. Byte dữ liệu đầu tiên trong bộ đệm hình ảnh luôn dành cho
pixel ngoài cùng bên trái của hàng trên cùng. Theo sau đó là pixel
ngay bên phải của nó, v.v. cho đến hết hàng trên cùng của
pixel. Theo sau pixel ngoài cùng bên phải của hàng có thể có 0 hoặc
nhiều byte đệm hơn để đảm bảo rằng mỗi hàng dữ liệu pixel có một
sự sắp xếp nhất định. Theo sau các byte đệm, nếu có, là dữ liệu cho
pixel ngoài cùng bên trái của hàng thứ hai từ trên xuống, v.v. Hàng cuối cùng
có nhiều byte đệm sau nó như các hàng khác.

Trong V4L2, mỗi định dạng có một mã định danh trông giống như ZZ0002ZZ,
được xác định trong tệp tiêu đề ZZ0000ZZ. Những cái này
định danh đại diện
ZZ0001ZZ cũng là
được liệt kê bên dưới, tuy nhiên chúng không giống với những thứ được sử dụng trong Windows
thế giới.

Đối với một số định dạng, dữ liệu được lưu trữ trong bộ nhớ riêng biệt, không liền kề
bộ đệm. Các định dạng đó được xác định bằng một bộ mã FourCC riêng biệt
và được gọi là "định dạng đa mặt phẳng". Ví dụ, một
Khung ZZ0000ZZ thường được lưu trữ trong một
bộ nhớ đệm, nhưng nó cũng có thể được đặt trong hai hoặc ba phần riêng biệt
bộ đệm, với thành phần Y trong một bộ đệm và các thành phần CbCr trong bộ đệm khác
trong phiên bản 2 mặt phẳng hoặc với mỗi thành phần trong bộ đệm riêng của nó trong
trường hợp 3 mặt phẳng. Những bộ đệm phụ đó được gọi là "ZZ0001ZZ".