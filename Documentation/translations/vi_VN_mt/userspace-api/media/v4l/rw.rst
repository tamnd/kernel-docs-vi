.. SPDX-License-Identifier: GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/v4l/rw.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

.. c:namespace:: V4L

.. _rw:

**********
Đọc/Ghi
**********

Các thiết bị đầu vào và đầu ra hỗ trợ ZZ0000ZZ và
Chức năng ZZ0001ZZ tương ứng khi
Cờ ZZ0004ZZ trong trường ZZ0005ZZ của cấu trúc
ZZ0002ZZ được trả lại bởi
ZZ0003ZZ ioctl được thiết lập.

Trình điều khiển có thể cần CPU để sao chép dữ liệu, nhưng chúng cũng có thể hỗ trợ DMA
đến hoặc từ bộ nhớ người dùng, do đó phương thức I/O này không nhất thiết phải ít hơn
hiệu quả hơn các phương pháp khác chỉ đơn thuần là trao đổi con trỏ bộ đệm. Đó là
được coi là kém hơn vì không có thông tin meta như khung
bộ đếm hoặc dấu thời gian được thông qua. Thông tin này là cần thiết để
nhận biết tình trạng rớt khung và đồng bộ hóa với các luồng dữ liệu khác.
Tuy nhiên đây cũng là phương pháp I/O đơn giản nhất, đòi hỏi ít hoặc không cần
thiết lập để trao đổi dữ liệu. Nó cho phép thực hiện các pha nguy hiểm bằng dòng lệnh như thế này (
công cụ vidctrl là hư cấu):

.. code-block:: none

    $ vidctrl /dev/video --input=0 --format=YUYV --size=352x288
    $ dd if=/dev/video of=myimage.422 bs=202752 count=1

Để đọc từ các ứng dụng của thiết bị, hãy sử dụng ZZ0000ZZ
để viết hàm ZZ0001ZZ. Trình điều khiển
phải triển khai một phương thức I/O nếu chúng trao đổi dữ liệu với các ứng dụng,
nhưng nó không nhất thiết phải như thế này. [#f1]_ Khi hỗ trợ đọc hoặc ghi,
trình điều khiển cũng phải hỗ trợ ZZ0002ZZ và
Chức năng ZZ0003ZZ. [#f2]_

.. [#f1]
   It would be desirable if applications could depend on drivers
   supporting all I/O interfaces, but as much as the complex memory
   mapping I/O can be inadequate for some devices we have no reason to
   require this interface, which is most useful for simple applications
   capturing still images.

.. [#f2]
   At the driver level :c:func:`select()` and :c:func:`poll()` are
   the same, and :c:func:`select()` is too important to be optional.