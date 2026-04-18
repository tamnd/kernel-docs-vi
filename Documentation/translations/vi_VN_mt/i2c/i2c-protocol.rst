.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/i2c/i2c-protocol.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

==================
Giao thức I2C
================

Tài liệu này là tổng quan về các giao dịch I2C cơ bản và kernel
API để thực hiện chúng.

Chìa khóa ký hiệu
==============

==================================================================================
S Điều kiện bắt đầu
P Điều kiện dừng
Rd/Wr (1 bit) Bit đọc/ghi. Rd bằng 1, Wr bằng 0.
Bit A, NA (1 bit) Xác nhận (ACK) và Không xác nhận (NACK)
Addr (7 bit) I2C Địa chỉ 7 bit. Lưu ý rằng điều này có thể được mở rộng thành
                lấy địa chỉ I2C 10 bit.
Dữ liệu (8 bit) Một byte dữ liệu đơn giản.

[..] Dữ liệu được gửi bởi thiết bị I2C, trái ngược với dữ liệu được gửi bởi thiết bị
                bộ điều hợp máy chủ.
==================================================================================


Giao dịch gửi đơn giản
=======================

Được triển khai bởi i2c_master_send()::

S Addr Wr [A] Dữ liệu [A] Dữ liệu [A] ... [A] Dữ liệu [A] P


Giao dịch nhận đơn giản
==========================

Được triển khai bởi i2c_master_recv()::

S Addr Rd [A] [Dữ liệu] A [Dữ liệu] A ... A [Dữ liệu] NA P


Giao dịch kết hợp
=====================

Được triển khai bởi i2c_transfer().

Chúng giống như các giao dịch trên, nhưng thay vì dừng lại
điều kiện P điều kiện bắt đầu S được gửi và giao dịch tiếp tục.
Một ví dụ về đọc byte, theo sau là ghi byte ::

S Addr Rd [A] [Dữ liệu] NA S Addr Wr [A] Dữ liệu [A] P


Giao dịch sửa đổi
=====================

Các sửa đổi sau đây đối với giao thức I2C cũng có thể được tạo bởi
thiết lập các cờ này cho tin nhắn I2C. Ngoại trừ I2C_M_NOSTART, họ
thường chỉ cần thiết để khắc phục sự cố của thiết bị:

I2C_M_IGNORE_NAK:
    Thông thường tin nhắn sẽ bị gián đoạn ngay lập tức nếu có [NA] từ
    khách hàng. Việc đặt cờ này coi bất kỳ [NA] nào là [A] và tất cả
    tin nhắn được gửi đi.
    Những tin nhắn này có thể vẫn không đạt được thời gian chờ SCL lo->hi.

I2C_M_NO_RD_ACK:
    Trong thông báo đã đọc, bit A/NA chính bị bỏ qua.

I2C_M_NOSTART:
    Trong một giao dịch kết hợp, không có 'S Addr Wr/Rd [A]' nào được tạo ra tại một số thời điểm.
    điểm. Ví dụ: cài đặt I2C_M_NOSTART trên tin nhắn phần thứ hai
    tạo ra một cái gì đó như ::

S Addr Rd [A] [Dữ liệu] NA Dữ liệu [A] P

Nếu bạn đặt biến I2C_M_NOSTART cho thông báo một phần đầu tiên,
    chúng tôi không tạo Addr nhưng chúng tôi tạo điều kiện bắt đầu S.
    Điều này có thể sẽ gây nhầm lẫn cho tất cả các khách hàng khác trên xe buýt của bạn, vì vậy đừng
    hãy thử cái này

Điều này thường được sử dụng để thu thập các dữ liệu truyền từ nhiều bộ đệm dữ liệu trong
    bộ nhớ hệ thống thành thứ gì đó xuất hiện dưới dạng một lần truyền duy nhất tới
    Thiết bị I2C nhưng cũng có thể được sử dụng giữa các lần thay đổi hướng bởi một số
    thiết bị hiếm.

I2C_M_REV_DIR_ADDR:
    Điều này chuyển đổi cờ Rd/Wr. Nghĩa là, nếu bạn muốn viết, nhưng
    cần phát ra Rd thay vì Wr hoặc ngược lại, bạn đặt cái này
    cờ. Ví dụ::

S Addr Rd [A] Dữ liệu [A] Dữ liệu [A] ... [A] Dữ liệu [A] P

I2C_M_STOP:
    Buộc một điều kiện dừng (P) sau tin nhắn. Một số giao thức liên quan đến I2C
    như SCCB yêu cầu điều đó. Thông thường, bạn thực sự không muốn bị gián đoạn
    giữa các tin nhắn của một lần chuyển.
