.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/filesystems/fuse/fuse-io-uring.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

==========================================
Tài liệu thiết kế FUSE-over-io-uring
==========================================

Tài liệu này bao gồm các chi tiết cơ bản về cách cầu chì
giao tiếp kernel/không gian người dùng thông qua io-uring được định cấu hình
và hoạt động. Để biết thông tin chi tiết chung về FUSE, hãy xem Fuse.rst.

Tài liệu này cũng bao gồm giao diện hiện tại, đó là
vẫn đang trong quá trình phát triển và có thể thay đổi.

Hạn chế
===========
Hiện tại, không phải tất cả các loại yêu cầu đều được hỗ trợ thông qua io-uring, không gian người dùng
cũng được yêu cầu xử lý các yêu cầu thông qua /dev/fuse sau khi thiết lập io-uring
đã hoàn tất. Thông báo cụ thể (bắt đầu từ phía daemon)
và ngắt quãng.

Cấu hình io-uring cầu chì
===========================

Các yêu cầu kernel Fuse được xếp hàng đợi thông qua /dev/fuse cổ điển
giao diện đọc/ghi - cho đến khi thiết lập io-uring hoàn tất.

Để thiết lập Fuse-over-io-uring Fuse-server (không gian người dùng)
cần gửi SQE (opcode = IORING_OP_URING_CMD) tới/dev/fuse
mô tả tập tin kết nối. Gửi ban đầu là với lệnh phụ
FUSE_URING_REQ_REGISTER, sẽ chỉ đăng ký các mục được
có sẵn trong hạt nhân.

Khi ít nhất một mục trên mỗi hàng đợi được gửi, kernel sẽ bắt đầu
để xếp hàng vào hàng đợi đổ chuông.
Lưu ý, mỗi lõi CPU đều có hàng đợi Fuse-io-uring riêng.
Không gian người dùng xử lý CQE/fuse-request và gửi kết quả dưới dạng
lệnh con FUSE_URING_REQ_COMMIT_AND_FETCH - kernel hoàn thành
các yêu cầu và cũng đánh dấu mục có sẵn một lần nữa. Nếu có
yêu cầu đang chờ xử lý đang chờ yêu cầu sẽ được gửi ngay lập tức
đến daemon một lần nữa.

SQE ban đầu
-----------::

Trình nền hệ thống tập tin ZZ0000ZZ FUSE
 ZZ0001ZZ
 ZZ0002ZZ >io_uring_submit()
 ZZ0003ZZ IORING_OP_URING_CMD /
 ZZ0004ZZ FUSE_URING_CMD_REGISTER
 ZZ0005ZZ [chờ cqe]
 ZZ0006ZZ >io_uring_wait_cqe() hoặc
 ZZ0007ZZ >io_uring_submit_and_wait()
 ZZ0008ZZ
 ZZ0009ZZ
 ZZ0010ZZ


Gửi yêu cầu với CQE
--------------------------::

Trình nền hệ thống tập tin ZZ0000ZZ FUSE
 ZZ0001ZZ [đang chờ CQE]
 ZZ0002ZZ
 ZZ0003ZZ
 ZZ0004ZZ
 ZZ0005ZZ
 ZZ0006ZZ
 ZZ0007ZZ
 ZZ0008ZZ
 ZZ0009ZZ
 ZZ0010ZZ
 ZZ0011ZZ
 ZZ0012ZZ
 ZZ0013ZZ
 ZZ0014ZZ
 ZZ0015ZZ
 ZZ0016ZZ
 ZZ0017ZZ [nhận và xử lý CQE]
 ZZ0018ZZ [gửi kết quả và tìm nạp tiếp theo]
 ZZ0019ZZ >io_uring_submit()
 ZZ0020ZZ IORING_OP_URING_CMD/
 ZZ0021ZZ FUSE_URING_CMD_COMMIT_AND_FETCH
 ZZ0022ZZ
 ZZ0023ZZ
 ZZ0024ZZ
 ZZ0025ZZ
 ZZ0026ZZ
 ZZ0027ZZ
 ZZ0028ZZ
 ZZ0029ZZ
 ZZ0030ZZ
 ZZ0031ZZ
 ZZ0032ZZ
 ZZ0033ZZ
 ZZ0034ZZ
 ZZ0035ZZ


