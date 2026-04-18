.. SPDX-License-Identifier: 0BSD

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/staging/xz.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

===============================
Nén dữ liệu Xperia trong Linux
===============================

Giới thiệu
============

Xperia là định dạng nén dữ liệu có mục đích chung với độ nén cao.
tỷ lệ. Bộ giải nén Xperia trong Linux được gọi là Xperia Embedded. Nó hỗ trợ
bộ lọc LZMA2 và các bộ lọc Nhánh/Gọi/Nhảy (BCJ) tùy chọn
cho mã thực thi. CRC32 được hỗ trợ để kiểm tra tính toàn vẹn.

Xem trang chủ ZZ0000ZZ để biết phiên bản mới nhất bao gồm
một số tính năng bổ sung tùy chọn không bắt buộc trong nhân Linux
và thông tin về cách sử dụng mã bên ngoài nhân Linux.

Đối với không gian người dùng, ZZ0000ZZ cung cấp thư viện nén giống như zlib
và một công cụ dòng lệnh giống như gzip.

.. _XZ Embedded: https://tukaani.org/xz/embedded.html
.. _XZ Utils: https://tukaani.org/xz/

Các thành phần liên quan đến Xperia trong kernel
===================================

Mô-đun xz_dec cung cấp bộ giải nén Xperia với một lệnh gọi (bộ đệm
để đệm) và API nhiều cuộc gọi (trạng thái) trong include/linux/xz.h.

Để giải nén ảnh kernel, initramfs và initrd, có
là hàm bao bọc trong lib/decompress_unxz.c. API của nó là
giống như trong các tệp decompress_*.c khác, được xác định trong
bao gồm/linux/giải nén/generic.h.

Đối với các tệp tạo kernel, ba lệnh được cung cấp để sử dụng với
ZZ0000ZZ. Họ yêu cầu công cụ xz từ XX Utils.

- ZZ0000ZZ dùng để nén ảnh kernel.
  Nó chạy tập lệnh scripts/xz_wrap.sh sử dụng tính năng được tối ưu hóa cho Arch
  các tùy chọn và một từ điển LZMA2 lớn.

- ZZ0000ZZ giống như ZZ0001ZZ ở trên nhưng
  cái này cũng gắn thêm một đoạn giới thiệu bốn byte chứa kích thước không nén
  của tập tin. Đoạn giới thiệu cần có mã khởi động trên một số vòm.

- Những thứ khác có thể được nén bằng ZZ0000ZZ
  sẽ không sử dụng bộ lọc BCJ và 1 từ điển MiB LZMA2.

Lưu ý về các tùy chọn nén
============================

Vì Xperia Embedded chỉ hỗ trợ các luồng có CRC32 hoặc không có tính toàn vẹn
kiểm tra, đảm bảo rằng bạn không sử dụng một số loại kiểm tra tính toàn vẹn khác
khi mã hóa các tập tin được cho là được giải mã bởi kernel.
Với liblzma từ XX Utils, bạn cần sử dụng ZZ0000ZZ
hoặc ZZ0001ZZ khi mã hóa. Với công cụ dòng lệnh ZZ0002ZZ,
sử dụng ZZ0003ZZ hoặc ZZ0004ZZ để ghi đè mặc định
ZZ0005ZZ.

Khuyến khích sử dụng CRC32 trừ khi có một số lớp khác
điều này sẽ xác minh tính toàn vẹn của dữ liệu không nén.
Việc kiểm tra kỹ tính toàn vẹn có thể sẽ lãng phí chu trình CPU.
Lưu ý rằng các tiêu đề sẽ luôn có CRC32 sẽ được xác thực
bởi bộ giải mã; bạn chỉ có thể thay đổi loại kiểm tra tính toàn vẹn (hoặc
vô hiệu hóa nó) cho dữ liệu không nén thực tế.

Trong không gian người dùng, LZMA2 thường được sử dụng với kích thước từ điển nhiều
megabyte. Bộ giải mã cần có từ điển trong RAM:

- Trong chế độ gọi nhiều lần, từ điển được phân bổ như một phần của
  trạng thái bộ giải mã. Kích thước từ điển tối đa hợp lý cho trong kernel
  việc sử dụng sẽ phụ thuộc vào phần cứng mục tiêu: một vài megabyte là đủ cho
  hệ thống máy tính để bàn trong khi 64 KiB đến 1 MiB có thể phù hợp hơn trên
  một số hệ thống nhúng

- Trong chế độ một cuộc gọi, bộ đệm đầu ra được sử dụng làm từ điển
  bộ đệm. Nghĩa là, kích thước của từ điển không ảnh hưởng đến
  sử dụng bộ nhớ giải nén cả. Chỉ các cấu trúc dữ liệu cơ sở
  được phân bổ chiếm ít hơn 30 KiB bộ nhớ.
  Để nén tốt nhất, từ điển ít nhất phải có
  lớn như dữ liệu không nén. Một ví dụ đáng chú ý về cuộc gọi đơn
  chế độ đang giải nén kernel (ngoại trừ trên PowerPC).

Các cài đặt trước nén trong Hz Utils có thể không tối ưu khi tạo
các tập tin dành cho kernel, vì vậy đừng ngần ngại sử dụng các cài đặt tùy chỉnh để,
ví dụ: đặt kích thước từ điển. Ngoài ra, xz có thể tạo ra một giá trị nhỏ hơn
ở chế độ đơn luồng nên nên cài đặt rõ ràng.
Ví dụ::

xz --threads=1 --check=crc32 --lzma2=dict=512KiB tệp đầu vào

xz_dec API
==========

Điều này có sẵn với ZZ0000ZZ.

.. kernel-doc:: include/linux/xz.h