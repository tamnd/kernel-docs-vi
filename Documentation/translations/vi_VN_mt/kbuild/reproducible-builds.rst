.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/kbuild/reproducible-builds.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

=====================
Bản dựng có thể tái tạo
===================

Nhìn chung, điều mong muốn là việc xây dựng cùng một mã nguồn với
cùng một bộ công cụ có thể tái tạo được, tức là đầu ra luôn
hoàn toàn giống nhau.  Điều này giúp có thể xác minh rằng bản dựng
cơ sở hạ tầng cho hệ thống phân phối nhị phân hoặc hệ thống nhúng chưa
bị lật đổ.  Điều này cũng có thể giúp việc xác minh nguồn
hoặc thay đổi công cụ không tạo ra bất kỳ sự khác biệt nào đối với các tệp nhị phân kết quả.

ZZ0000ZZ có thêm thông tin về điều này
chủ đề chung.  Tài liệu này bao gồm các lý do khác nhau tại sao việc xây dựng
hạt nhân có thể không thể tái tạo được và cách tránh chúng.

Dấu thời gian
----------

Hạt nhân nhúng dấu thời gian ở ba nơi:

* Chuỗi phiên bản được hiển thị bởi ZZ0000ZZ và được bao gồm trong
  ZZ0001ZZ

* Tệp thời gian trong initramfs được nhúng

* Nếu được bật qua ZZ0000ZZ, dấu thời gian của tệp kernel
  các tiêu đề được nhúng trong kernel hoặc mô-đun tương ứng,
  được tiếp xúc qua ZZ0001ZZ

Theo mặc định dấu thời gian là thời gian hiện tại và trong trường hợp
ZZ0000ZZ thời gian sửa đổi của các tập tin khác nhau. Điều này phải
được ghi đè bằng biến ZZ0001ZZ.
Nếu bạn đang xây dựng từ một cam kết git, bạn có thể sử dụng ngày cam kết của nó.

Hạt nhân ZZ0003ZZ sử dụng macro ZZ0000ZZ và ZZ0001ZZ,
và kích hoạt cảnh báo nếu chúng được sử dụng.  Nếu bạn kết hợp bên ngoài
mã sử dụng những mã này, bạn phải ghi đè dấu thời gian mà chúng
tương ứng bằng cách thiết lập môi trường ZZ0002ZZ
biến.

Người dùng, máy chủ
----------

Hạt nhân nhúng tên người dùng và tên máy chủ của tòa nhà vào
ZZ0000ZZ.  Chúng phải được ghi đè bằng cách sử dụng
Biến ZZ0001ZZ.  Nếu bạn là
xây dựng từ một cam kết git, bạn có thể sử dụng địa chỉ cam kết của nó.

Tên tệp tuyệt đối
------------------

Khi hạt nhân được xây dựng ngoài cây, thông tin gỡ lỗi có thể bao gồm
tên tệp tuyệt đối cho các tệp nguồn và thư mục bản dựng.  Những điều này phải
được ghi đè bằng cách bao gồm tùy chọn ZZ0000ZZ cho mỗi tùy chọn trong
các biến ZZ0003ZZ và ZZ0004ZZ để bao gồm cả ZZ0001ZZ và ZZ0002ZZ
tập tin.

Tùy thuộc vào trình biên dịch được sử dụng, macro ZZ0000ZZ cũng có thể mở rộng
thành tên tệp tuyệt đối trong bản dựng ngoài cây.  Kbuild tự động
sử dụng tùy chọn ZZ0001ZZ để ngăn chặn điều này, nếu nó
được hỗ trợ.

Trang web Bản dựng có thể tái tạo có thêm thông tin về những điều này
ZZ0000ZZ.

Một số tùy chọn CONFIG như ZZ0000ZZ nhúng đường dẫn tuyệt đối vào
các tập tin đối tượng Các tùy chọn như vậy nên bị vô hiệu hóa.

Các tệp được tạo trong gói nguồn
----------------------------------

Quá trình xây dựng cho một số chương trình trong ZZ0000ZZ
thư mục con không hoàn toàn hỗ trợ các bản dựng ngoài cây.  Điều này có thể
gây ra việc xây dựng gói nguồn sau này bằng cách sử dụng ví dụ: ZZ0001ZZ tới
bao gồm các tập tin được tạo ra.  Bạn nên đảm bảo cây nguồn là
nguyên sơ bằng cách chạy ZZ0002ZZ hoặc ZZ0003ZZ trước đó
xây dựng một gói nguồn.

Ký mô-đun
--------------

Nếu bạn bật ZZ0000ZZ, hành vi mặc định là
tạo một khóa tạm thời khác nhau cho mỗi bản dựng, dẫn đến
các mô-đun không thể tái tạo được.  Tuy nhiên, bao gồm cả khóa ký với
nguồn của bạn có lẽ sẽ đánh bại mục đích ký các mô-đun.

Một cách tiếp cận vấn đề này là chia quá trình xây dựng sao cho
các bộ phận không thể tái sản xuất có thể được coi là nguồn:

1. Tạo khóa ký liên tục.  Thêm chứng chỉ cho khóa
   tới nguồn kernel.

2. Đặt ký hiệu ZZ0000ZZ để bao gồm
   ký chứng chỉ của khóa, đặt ZZ0001ZZ thành
   chuỗi trống và tắt ZZ0002ZZ.
   Xây dựng hạt nhân và mô-đun.

3. Tạo chữ ký tách rời cho các mô-đun và xuất bản chúng dưới dạng
   nguồn.

4. Thực hiện bản dựng thứ hai gắn chữ ký mô-đun.  Nó
   có thể xây dựng lại các mô-đun hoặc sử dụng đầu ra của bước 2.

Cấu trúc ngẫu nhiên
-----------------------

Nếu bạn bật ZZ0000ZZ, bạn sẽ cần tạo trước
hạt giống ngẫu nhiên trong ZZ0001ZZ cũng vậy
giá trị được sử dụng bởi mỗi bản dựng. Xem ZZ0002ZZ
để biết chi tiết.

Gỡ lỗi xung đột thông tin
--------------------

Đây không phải là vấn đề không thể tái tạo mà là vấn đề về các tệp được tạo
có thể tái tạo ZZ0000ZZ.

Sau khi bạn đặt tất cả các biến cần thiết cho bản dựng có thể tái tạo,
Thông tin gỡ lỗi của vDSO có thể giống nhau ngay cả đối với các kernel khác nhau
các phiên bản.  Điều này có thể dẫn đến xung đột tệp giữa thông tin gỡ lỗi
gói cho các phiên bản kernel khác nhau.

Để tránh điều này, bạn có thể tạo vDSO khác nhau cho các
phiên bản kernel bằng cách thêm một chuỗi "muối" tùy ý vào đó.
Điều này được chỉ định bởi ký hiệu Kconfig ZZ0000ZZ.

Git
---

Những thay đổi không được cam kết hoặc các id cam kết khác nhau trong git cũng có thể dẫn đến
đến các kết quả biên dịch khác nhau. Ví dụ, sau khi thực hiện
ZZ0000ZZ, ngay cả khi mã giống nhau,
ZZ0001ZZ được tạo trong quá trình biên dịch
sẽ khác nhau, điều này cuối cùng sẽ dẫn đến sự khác biệt nhị phân.
Xem ZZ0002ZZ để biết chi tiết.

.. _KBUILD_BUILD_TIMESTAMP: kbuild.html#kbuild-build-timestamp
.. _KBUILD_BUILD_USER and KBUILD_BUILD_HOST: kbuild.html#kbuild-build-user-kbuild-build-host
.. _KCFLAGS: kbuild.html#kcflags
.. _KAFLAGS: kbuild.html#kaflags
.. _prefix-map options: https://reproducible-builds.org/docs/build-path/
.. _Reproducible Builds project: https://reproducible-builds.org/
.. _SOURCE_DATE_EPOCH: https://reproducible-builds.org/docs/source-date-epoch/
