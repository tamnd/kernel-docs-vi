.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/admin-guide/cifs/introduction.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=============
Giới thiệu
============

Đây cũng là mô-đun VFS máy khách cho giao thức SMB3 NAS
  đối với các phương ngữ cũ hơn như Common Internet File System (CIFS)
  giao thức kế thừa cho Khối tin nhắn máy chủ
  (SMB), cơ chế chia sẻ tệp gốc cho hầu hết các phiên bản đầu tiên
  Hệ điều hành PC. Hiện đã có phiên bản mới và cải tiến của CIFS
  được gọi là SMB2 và SMB3. Sử dụng SMB3 (và phiên bản mới hơn, bao gồm SMB3.1.1
  phương ngữ mới nhất) được ưu tiên hơn nhiều so với việc sử dụng các phương ngữ cũ hơn
  các phương ngữ như CIFS vì lý do bảo mật. Tất cả các phương ngữ hiện đại,
  bao gồm cả phiên bản mới nhất, SMB3.1.1, được hỗ trợ bởi CIFS VFS
  mô-đun. Giao thức SMB3 được triển khai và hỗ trợ bởi tất cả các
  máy chủ tệp như Windows (bao gồm Windows 2019 Server), như
  cũng như bởi Samba (cung cấp máy chủ CIFS/SMB2/SMB3 tuyệt vời
  hỗ trợ và công cụ dành cho Linux và nhiều hệ điều hành khác).
  Các hệ thống của Apple cũng hỗ trợ tốt SMB3, cũng như hầu hết Network Attached
  Các nhà cung cấp lưu trữ, vì vậy máy khách hệ thống tập tin mạng này có thể gắn vào một
  hệ thống đa dạng. Nó cũng hỗ trợ gắn vào đám mây
  (ví dụ: Microsoft Azure), bao gồm bảo mật cần thiết
  tính năng.

Mục đích của mô-đun này là cung cấp mạng tiên tiến nhất
  chức năng hệ thống tệp cho các máy chủ tuân thủ SMB3, bao gồm cả nâng cao
  tính năng bảo mật, i/o hiệu suất cao song song tuyệt vời, tốt hơn
  Tuân thủ POSIX, thiết lập phiên an toàn cho mỗi người dùng, mã hóa,
  bộ nhớ đệm phân tán an toàn hiệu suất cao (cho thuê/oplocks), gói tùy chọn
  ký, tệp lớn, hỗ trợ Unicode và quốc tế hóa khác
  cải tiến. Vì cả máy chủ Samba và máy khách hệ thống tập tin này đều hỗ trợ
  Các phần mở rộng Unix CIFS và máy khách Linux cũng hỗ trợ các phần mở rộng SMB3 POSIX,
  sự kết hợp có thể cung cấp một giải pháp thay thế hợp lý cho mạng khác và
  hệ thống tệp cụm để phân phát tệp trong một số môi trường Linux sang Linux,
  không chỉ trong môi trường Linux sang Windows (hoặc Linux sang Mac).

Hệ thống tập tin này có tiện ích gắn kết (mount.cifs) và nhiều không gian người dùng khác nhau
  các công cụ (bao gồm smbinfo và setcifsacl) có thể lấy được từ

ZZ0000ZZ

hoặc

git://git.samba.org/cifs-utils.git

mount.cifs nên được cài đặt trong thư mục cùng với các trình trợ giúp gắn kết khác.

Để biết thêm thông tin về mô-đun, hãy xem trang wiki dự án tại

ZZ0000ZZ

Và

ZZ0000ZZ
