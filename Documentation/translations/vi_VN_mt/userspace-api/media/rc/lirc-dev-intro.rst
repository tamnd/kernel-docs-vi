.. SPDX-License-Identifier: GPL-2.0 OR GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/rc/lirc-dev-intro.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

.. _lirc_dev_intro:

************
Giới thiệu
************

LIRC là viết tắt của Điều khiển từ xa hồng ngoại Linux. Giao diện thiết bị LIRC là
giao diện hai chiều để truyền IR thô và mã quét được giải mã
dữ liệu giữa không gian người dùng và không gian kernel. Về cơ bản nó chỉ là một chardev
(/dev/lircX, với X = 0, 1, 2, ...), với một số struct tiêu chuẩn
file_Operations được xác định trên đó. Đối với việc vận chuyển IR thô và
scancode được giải mã qua lại, các fops thiết yếu là đọc, viết và ioctl.

Cũng có thể đính kèm chương trình BPF vào thiết bị LIRC để giải mã
IR thô thành scancode.

Ví dụ đầu ra dmesg khi đăng ký trình điều khiển w/LIRC:

.. code-block:: none

    $ dmesg |grep lirc_dev
    rc rc0: lirc_dev: driver mceusb registered at minor = 0, raw IR receiver, raw IR transmitter

Những gì bạn sẽ thấy cho một chardev:

.. code-block:: none

    $ ls -l /dev/lirc*
    crw-rw---- 1 root root 248, 0 Jul 2 22:20 /dev/lirc0

Lưu ý rằng gói ZZ0000ZZ
chứa các công cụ để làm việc với các thiết bị LIRC:

- ir-ctl: có thể nhận IR thô và truyền IR, cũng như truy vấn LIRC
   tính năng của thiết bị.

- ir-keytable: có thể tải sơ đồ bàn phím; cho phép bạn thiết lập các giao thức hạt nhân IR; tải
   Bộ giải mã IR BPF và thử nghiệm giải mã IR. Một số bộ giải mã IR BPF cũng có
   được cung cấp.

.. _lirc_modes:

**********
Chế độ LIRC
**********

LIRC hỗ trợ một số chế độ nhận và gửi mã IR như hình
trên bảng sau.

.. _lirc-mode-scancode:
.. _lirc-scancode-flag-toggle:
.. _lirc-scancode-flag-repeat:

ZZ0000ZZ

Chế độ này dành cho cả gửi và nhận IR.

Để truyền (còn gọi là gửi), hãy tạo cấu trúc lirc_scancode với
    scancode mong muốn được đặt trong thành viên ZZ0002ZZ, ZZ0000ZZ
    được đặt thành ZZ0001ZZ và tất cả các giá trị khác
    thành viên được đặt thành 0. Viết cấu trúc này vào thiết bị lirc.

Để nhận, bạn đọc struct lirc_scancode từ thiết bị LIRC.
    Trường ZZ0002ZZ được đặt thành scancode đã nhận và
    ZZ0000ZZ được đặt trong
    ZZ0001ZZ. Nếu scancode ánh xạ tới mã khóa hợp lệ thì mã này được đặt
    trong trường ZZ0003ZZ, nếu không nó được đặt thành ZZ0004ZZ.

ZZ0000ZZ có thể được đặt ZZ0001ZZ nếu nút chuyển đổi
    bit được đặt trong các giao thức hỗ trợ nó (ví dụ: RC-5 và RC-6) hoặc
    ZZ0002ZZ khi nhận được lặp lại cho các giao thức
    hỗ trợ nó (ví dụ: nec).

Trong giao thức Sanyo và NEC, nếu bạn giữ một nút trên điều khiển từ xa, thay vì
    lặp lại toàn bộ scancode, điều khiển từ xa sẽ gửi một tin nhắn ngắn hơn với
    không có scancode, điều đó chỉ có nghĩa là nút được giữ, "lặp lại". Khi đây là
    đã nhận được, ZZ0000ZZ được đặt và scancode và
    mã khóa được lặp lại.

Với nec, không có cách nào để phân biệt "giữ nút" với "nhấn nút liên tục".
    nhấn nút tương tự". Giao thức RC-5 và RC-6 có bit chuyển đổi.
    Khi một nút được thả ra và nhấn lại, bit chuyển đổi sẽ bị đảo ngược.
    Nếu bit chuyển đổi được đặt, ZZ0000ZZ được đặt.

Trường ZZ0000ZZ chứa đầy thời gian nano giây
    (trong ZZ0001ZZ) khi mã quét được giải mã.

.. _lirc-mode-mode2:

ZZ0000ZZ

Trình điều khiển trả về một chuỗi mã xung và mã không gian cho không gian người dùng,
    dưới dạng một chuỗi các giá trị u32.

Chế độ này chỉ được sử dụng để nhận IR.

    The upper 8 bits determine the packet type, and the lower 24 bits
    the payload. Use ``LIRC_VALUE()`` macro to get the payload, and
    the macro ``LIRC_MODE2()`` will give you the type, which
    is one of:

    ``LIRC_MODE2_PULSE``

        Signifies the presence of IR in microseconds, also known as *flash*.

    ``LIRC_MODE2_SPACE``

        Signifies absence of IR in microseconds, also known as *gap*.

    ``LIRC_MODE2_FREQUENCY``

        If measurement of the carrier frequency was enabled with
        :ref:`lirc_set_measure_carrier_mode` then this packet gives you
        the carrier frequency in Hertz.

    ``LIRC_MODE2_TIMEOUT``

        When the timeout set with :ref:`lirc_set_rec_timeout` expires due
        to no IR being detected, this packet will be sent, with the number
        of microseconds with no IR.

ZZ0000ZZ

Biểu thị rằng bộ thu IR gặp phải tình trạng tràn và một số lỗi IR
        bị thiếu. Dữ liệu IR sau đó sẽ chính xác trở lại. các
        giá trị thực tế không quan trọng, nhưng giá trị này được đặt thành 0xffffff bởi
        kernel để tương thích với lircd.

.. _lirc-mode-pulse:

ZZ0000ZZ

Trong chế độ xung, một chuỗi các giá trị nguyên xung/không gian được ghi vào
    thiết bị lirc sử dụng ZZ0000ZZ.

Các giá trị là độ dài xung và không gian xen kẽ, tính bằng micro giây. các
    mục đầu tiên và cuối cùng phải là xung, do đó phải có số lẻ
    của các mục.

Chế độ này chỉ được sử dụng để gửi IR.

*************************************
Các loại dữ liệu được LIRC_MODE_SCANCODE sử dụng
*************************************

.. kernel-doc:: include/uapi/linux/lirc.h
    :identifiers: lirc_scancode rc_proto

********************
Bộ giải mã hồng ngoại dựa trên BPF
********************

Kernel có hỗ trợ giải mã phổ biến nhất
ZZ0000ZZ, nhưng ở đó
có nhiều giao thức không được hỗ trợ. Để hỗ trợ những điều này, có thể
để tải chương trình BPF thực hiện việc giải mã. Điều này chỉ có thể được thực hiện trên
Các thiết bị LIRC hỗ trợ đọc IR thô.

Đầu tiên, sử dụng tòa nhà ZZ0006ZZ với đối số ZZ0001ZZ,
chương trình phải được tải loại ZZ0002ZZ. Sau khi đính kèm
đến thiết bị LIRC, chương trình này sẽ được gọi cho từng xung, khoảng trống hoặc
sự kiện hết thời gian chờ trên thiết bị LIRC. Bối cảnh của chương trình BPF là một
con trỏ tới một int không dấu, đó là ZZ0000ZZ
giá trị. Khi chương trình đã giải mã được scancode, nó có thể được gửi bằng cách sử dụng
BPF có chức năng ZZ0003ZZ hoặc ZZ0004ZZ. Chuột hoặc con trỏ
chuyển động có thể được báo cáo bằng ZZ0005ZZ.

Khi bạn có bộ mô tả tệp cho ZZ0000ZZ BPF
chương trình, nó có thể được gắn vào thiết bị LIRC bằng cách sử dụng syscall ZZ0002ZZ.
Mục tiêu phải là bộ mô tả tệp cho thiết bị LIRC và
loại đính kèm phải là ZZ0001ZZ. Không thể có nhiều hơn 64 chương trình BPF
được gắn vào một thiết bị LIRC tại một thời điểm.

.. _bpf(2): http://man7.org/linux/man-pages/man2/bpf.2.html