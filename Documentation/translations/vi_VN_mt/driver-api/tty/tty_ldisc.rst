.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/driver-api/tty/tty_ldisc.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=====================
Kỷ luật dòng TTY
=====================

.. contents:: :local:

Kỷ luật dòng TTY xử lý tất cả ký tự đến và đi từ/đến một tty
thiết bị. Kỷ luật dòng mặc định là ZZ0000ZZ. Nó cũng là một
dự phòng nếu việc thiết lập bất kỳ kỷ luật nào khác cho một tty không thành công. Nếu thậm chí N_TTY
thất bại, N_NULL tiếp quản. Điều đó không bao giờ thất bại, nhưng cũng không xử lý bất kỳ
các ký tự -- nó sẽ ném chúng đi.

Sự đăng ký
============

Các nguyên tắc dòng được đăng ký với tty_register_ldisc() vượt qua ldisc
cấu trúc. Tại thời điểm đăng ký, kỷ luật phải sẵn sàng để sử dụng và
có thể nó sẽ được sử dụng trước khi cuộc gọi trả về thành công. Nếu cuộc gọi
trả về một lỗi thì nó sẽ không được gọi. Không sử dụng lại số ldisc vì chúng
là một phần của không gian người dùng ABI và việc ghi lên ldisc hiện có sẽ gây ra
quỷ ăn máy tính của bạn. Bạn không được đăng ký lại quá mức
kỷ luật ngay cả với cùng một dữ liệu nếu không máy tính của bạn sẽ lại bị ăn thịt
quỷ dữ. Để xóa kỷ luật dòng, hãy gọi tty_unregister_ldisc().

Hãy lưu ý cảnh báo này: trường đếm tham chiếu của các bản sao đã đăng ký của
Cấu trúc tty_ldisc trong bảng ldisc đếm số dòng sử dụng cái này
kỷ luật. Số lượng tham chiếu của cấu trúc tty_ldisc trong số lượng tty
số lượng người dùng đang hoạt động của ldisc tại thời điểm này. Trong thực tế, nó được tính
số lượng luồng thực thi trong một phương thức ldisc (cộng với các luồng sắp thực hiện
nhập và thoát mặc dù chi tiết này không quan trọng).

.. kernel-doc:: drivers/tty/tty_ldisc.c
   :identifiers: tty_register_ldisc tty_unregister_ldisc

Các chức năng khác
==================

.. kernel-doc:: drivers/tty/tty_ldisc.c
   :identifiers: tty_set_ldisc tty_ldisc_flush

Tham chiếu Hoạt động Kỷ luật Đường dây
======================================

.. kernel-doc:: include/linux/tty_ldisc.h
   :identifiers: tty_ldisc_ops

Truy cập trình điều khiển
=========================

Các phương pháp xử lý dòng có thể gọi các phương thức của trình điều khiển phần cứng cơ bản.
Chúng được ghi lại như một phần của struct tty_Operations.

Cờ TTY
=========

Các phương pháp kỷ luật dòng có quyền truy cập vào trường ZZ0000ZZ. Xem
ZZ0001ZZ.

Khóa
=======

Người gọi đến các chức năng kỷ luật dòng từ lớp tty được yêu cầu
lấy đường khóa kỷ luật. Điều tương tự cũng đúng với các cuộc gọi từ phía tài xế
nhưng vẫn chưa được thực thi.

.. kernel-doc:: drivers/tty/tty_ldisc.c
   :identifiers: tty_ldisc_ref_wait tty_ldisc_ref tty_ldisc_deref

Mặc dù các hàm này chậm hơn một chút so với mã cũ nhưng đáng ra chúng phải có
tác động tối thiểu vì hầu hết logic nhận đều sử dụng bộ đệm lật và chúng chỉ
cần phải tham khảo khi họ đẩy bit lên qua trình điều khiển.

Cảnh báo: ZZ0000ZZ,
ZZ0001ZZ và ZZ0002ZZ
các hàm được gọi mà không có ldisc. Vì vậy tty_ldisc_ref() sẽ thất bại
trong tình huống này nếu được sử dụng trong các chức năng này.  Ldisc và mã trình điều khiển
gọi các chức năng riêng của nó phải cẩn thận trong trường hợp này.

Chức năng nội bộ
==================

.. kernel-doc:: drivers/tty/tty_ldisc.c
   :internal: