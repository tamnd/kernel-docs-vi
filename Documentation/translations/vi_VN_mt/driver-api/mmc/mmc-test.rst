.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/driver-api/mmc/mmc-test.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

===========================
Khung kiểm tra MMC
========================

Tổng quan
========

Khung ZZ0000ZZ được thiết kế để kiểm tra hiệu suất và độ tin cậy của trình điều khiển bộ điều khiển máy chủ và tất cả các thiết bị được xử lý bởi hệ thống con MMC. Điều này không chỉ bao gồm các thiết bị MMC mà còn bao gồm thẻ SD và các thiết bị khác được hệ thống con hỗ trợ.

Khung này cung cấp nhiều thử nghiệm khác nhau để đánh giá các khía cạnh khác nhau của bộ điều khiển máy chủ và tương tác của thiết bị, chẳng hạn như hiệu suất đọc và ghi, tính toàn vẹn dữ liệu và xử lý lỗi. Những thử nghiệm này giúp đảm bảo rằng trình điều khiển và thiết bị của bộ điều khiển máy chủ hoạt động chính xác trong nhiều điều kiện khác nhau.

Khung ZZ0000ZZ đặc biệt hữu ích cho:

- Xác minh chức năng và hiệu suất của trình điều khiển bộ điều khiển máy chủ MMC và SD.
- Đảm bảo khả năng tương thích và độ tin cậy của thiết bị MMC và SD.
- Xác định và chẩn đoán các sự cố trong hệ thống con MMC.

Kết quả kiểm tra được ghi vào nhật ký kernel, cung cấp thông tin chi tiết về kết quả kiểm tra và mọi vấn đề gặp phải.

Lưu ý: mọi nội dung trên thẻ của bạn sẽ bị ghi đè bởi các bài kiểm tra này.

Khởi tạo
==============

Để sử dụng khung ZZ0000ZZ, hãy làm theo các bước sau:

1. ZZ0000ZZ:

Đảm bảo rằng tùy chọn cấu hình kernel ZZ0000ZZ được bật. Điều này có thể được thực hiện bằng cách cấu hình kernel:

   .. code-block:: none

      make menuconfig

Điều hướng đến:

Trình điều khiển thiết bị --->
     <*> Hỗ trợ thẻ MMC/SD/SDIO --->
       [*] Trình điều khiển kiểm tra máy chủ MMC

Ngoài ra, bạn có thể kích hoạt nó trực tiếp trong tệp cấu hình kernel:

   .. code-block:: none

      echo "CONFIG_MMC_TEST=y" >> .config

Xây dựng lại và cài đặt kernel nếu cần thiết.

2. ZZ0000ZZ:

Nếu khung ZZ0000ZZ được xây dựng dưới dạng mô-đun, bạn cần tải nó bằng ZZ0001ZZ:

   .. code-block:: none

      modprobe mmc_test

Ràng buộc thẻ MMC để kiểm tra
================================

Để bật kiểm tra MMC, bạn cần hủy liên kết thẻ MMC khỏi trình điều khiển ZZ0000ZZ và liên kết nó với trình điều khiển ZZ0001ZZ. Điều này cho phép khung ZZ0002ZZ kiểm soát thẻ MMC cho mục đích thử nghiệm.

1. Nhận dạng thẻ MMC:

   .. code-block:: sh

      ls /sys/bus/mmc/devices/

Điều này sẽ liệt kê các thiết bị MMC, chẳng hạn như ZZ0000ZZ.

2. Hủy liên kết thẻ MMC khỏi trình điều khiển ZZ0000ZZ:

   .. code-block:: sh

      echo 'mmc0:0001' > /sys/bus/mmc/drivers/mmcblk/unbind

3. Liên kết thẻ MMC với trình điều khiển ZZ0000ZZ:

   .. code-block:: sh

      echo 'mmc0:0001' > /sys/bus/mmc/drivers/mmc_test/bind

Sau khi liên kết, bạn sẽ thấy một dòng trong nhật ký kernel cho biết thẻ đã được xác nhận để kiểm tra:

.. code-block:: none

   mmc_test mmc0:0001: Card claimed for testing.


Cách sử dụng - Mục gỡ lỗi
=======================

Khi khung ZZ0000ZZ được bật, bạn có thể tương tác với các mục gỡ lỗi sau nằm trong ZZ0001ZZ:

1. ZZ0000ZZ:

Tập tin này được sử dụng để chạy thử nghiệm cụ thể. Viết số kiểm tra vào tập tin này để thực hiện kiểm tra.

   .. code-block:: sh

      echo <test_number> > /sys/kernel/debug/mmc0/mmc0:0001/test

Kết quả kiểm tra được chỉ định trong thông tin nhật ký kernel. Bạn có thể xem nhật ký kernel bằng lệnh ZZ0000ZZ hoặc bằng cách kiểm tra tệp nhật ký trong ZZ0001ZZ.

   .. code-block:: sh

      dmesg | grep mmc0

Ví dụ:

Để chạy bài kiểm tra số 4 (Đọc cơ bản với xác minh dữ liệu):

   .. code-block:: sh

      echo 4 > /sys/kernel/debug/mmc0/mmc0:0001/test

Kiểm tra nhật ký kernel để biết kết quả:

   .. code-block:: sh

      dmesg | grep mmc0

2. ZZ0000ZZ:

Tập tin này liệt kê tất cả các bài kiểm tra có sẵn. Bạn có thể đọc tệp này để xem danh sách các bài kiểm tra và số tương ứng của chúng.

   .. code-block:: sh

      cat /sys/kernel/debug/mmc0/mmc0:0001/testlist

Các thử nghiệm có sẵn được liệt kê trong bảng dưới đây:

+------+--------------------------------+---------------------------------------------+
| Test | Test Name                      | Test Description                            |
+======+================================+=============================================+
| 0    | Run all tests                  | Runs all available tests                    |
+------+--------------------------------+---------------------------------------------+
| 1    | Basic write                    | Performs a basic write operation of a       |
|      |                                | single 512-Byte block to the MMC card       |
|      |                                | without data verification.                  |
+------+--------------------------------+---------------------------------------------+
| 2    | Basic read                     | Same for read                               |
+------+--------------------------------+---------------------------------------------+
| 3    | Basic write                    | Performs a basic write operation of a       |
|      | (with data verification)       | single 512-Byte block to the MMC card       |
|      |                                | with data verification by reading back      |
|      |                                | the written data and comparing it.          |
+------+--------------------------------+---------------------------------------------+
| 4    | Basic read                     | Same for read                               |
|      | (with data verification)       |                                             |
+------+--------------------------------+---------------------------------------------+
| 5    | Multi-block write              | Performs a multi-block write operation of   |
|      |                                | 8 blocks (each 512 bytes) to the MMC card.  |
+------+--------------------------------+---------------------------------------------+
| 6    | Multi-block read               | Same for read                               |
+------+--------------------------------+---------------------------------------------+
| 7    | Power of two block writes      | Performs write operations with block sizes  |
|      |                                | that are powers of two, starting from 1     |
|      |                                | byte up to 256 bytes, to the MMC card.      |
+------+--------------------------------+---------------------------------------------+
| 8    | Power of two block reads       | Same for read                               |
+------+--------------------------------+---------------------------------------------+
| 9    | Weird sized block writes       | Performs write operations with varying      |
|      |                                | block sizes starting from 3 bytes and       |
|      |                                | increasing by 7 bytes each iteration, up    |
|      |                                | to 511 bytes, to the MMC card.              |
+------+--------------------------------+---------------------------------------------+
| 10   | Weird sized block reads        | same for read                               |
+------+--------------------------------+---------------------------------------------+
| 11   | Badly aligned write            | Performs write operations with buffers      |
|      |                                | starting at different alignments (0 to 7    |
|      |                                | bytes offset) to test how the MMC card      |
|      |                                | handles unaligned data transfers.           |
+------+--------------------------------+---------------------------------------------+
| 12   | Badly aligned read             | same for read                               |
+------+--------------------------------+---------------------------------------------+
| 13   | Badly aligned multi-block write| same for multi-write                        |
+------+--------------------------------+---------------------------------------------+
| 14   | Badly aligned multi-block read | same for multi-read                         |
+------+--------------------------------+---------------------------------------------+
| 15   | Proper xfer_size at write      | intentionally create a broken transfer by   |
|      | (Start failure)   		| modifying the MMC request in a way that it  |
|      |				| will not perform as expected, e.g. use      |
|      |				| MMC_WRITE_BLOCK  for a multi-block transfer |
+------+--------------------------------+---------------------------------------------+
| 16   | Proper xfer_size at read       | same for read                               |
|      | (Start failure)		|					      |
+------+--------------------------------+---------------------------------------------+
| 17   | Proper xfer_size at write	| same for 2 blocks			      |
|      | (Midway failure)               |					      |
+------+--------------------------------+---------------------------------------------+
| 18   | Proper xfer_size at read       | same for read				      |
|      | (Midway failure)		|				              |
+------+--------------------------------+---------------------------------------------+
| 19   | Highmem write                  | use a high memory page                      |
+------+--------------------------------+---------------------------------------------+
| 20   | Highmem read                   | same for read                               |
+------+--------------------------------+---------------------------------------------+
| 21   | Multi-block highmem write      | same for multi-write                        |
+------+--------------------------------+---------------------------------------------+
| 22   | Multi-block highmem read       | same for mult-read                          |
+------+--------------------------------+---------------------------------------------+
| 23   | Best-case read performance     | Performs 512K sequential read (non sg)      |
+------+--------------------------------+---------------------------------------------+
| 24   | Best-case write performance    | same for write                              |
+------+--------------------------------+---------------------------------------------+
| 25   | Best-case read performance     | Same using sg				      |
|      | (Into scattered pages)         |					      |
+------+--------------------------------+---------------------------------------------+
| 26   | Best-case write performance    | same for write                              |
|      | (From scattered pages)         |					      |
+------+--------------------------------+---------------------------------------------+
| 27   | Single read performance        | By transfer size                            |
+------+--------------------------------+---------------------------------------------+
| 28   | Single write performance       | By transfer size                            |
+------+--------------------------------+---------------------------------------------+
| 29   | Single trim performance        | By transfer size                            |
+------+--------------------------------+---------------------------------------------+
| 30   | Consecutive read performance   | By transfer size                            |
+------+--------------------------------+---------------------------------------------+
| 31   | Consecutive write performance  | By transfer size                            |
+------+--------------------------------+---------------------------------------------+
| 32   | Consecutive trim performance   | By transfer size                            |
+------+--------------------------------+---------------------------------------------+
| 33   | Random read performance        | By transfer size                            |
+------+--------------------------------+---------------------------------------------+
| 34   | Random write performance       | By transfer size                            |
+------+--------------------------------+---------------------------------------------+
| 35   | Large sequential read          | Into scattered pages                        |
+------+--------------------------------+---------------------------------------------+
| 36   | Large sequential write         | From scattered pages                        |
+------+--------------------------------+---------------------------------------------+
| 37   | Write performance              | With blocking req 4k to 4MB                 |
+------+--------------------------------+---------------------------------------------+
| 38   | Write performance              | With non-blocking req 4k to 4MB             |
+------+--------------------------------+---------------------------------------------+
| 39   | Read performance               | With blocking req 4k to 4MB                 |
+------+--------------------------------+---------------------------------------------+
| 40   | Read performance               | With non-blocking req 4k to 4MB             |
+------+--------------------------------+---------------------------------------------+
| 41   | Write performance              | Blocking req 1 to 512 sg elems              |
+------+--------------------------------+---------------------------------------------+
| 42   | Write performance              | Non-blocking req 1 to 512 sg elems          |
+------+--------------------------------+---------------------------------------------+
| 43   | Read performance               | Blocking req 1 to 512 sg elems              |
+------+--------------------------------+---------------------------------------------+
| 44   | Read performance               | Non-blocking req 1 to 512 sg elems          |
+------+--------------------------------+---------------------------------------------+
| 45   | Reset test                     |                                             |
+------+--------------------------------+---------------------------------------------+
| 46   | Commands during read           | No Set Block Count (CMD23)                  |
+------+--------------------------------+---------------------------------------------+
| 47   | Commands during write          | No Set Block Count (CMD23)                  |
+------+--------------------------------+---------------------------------------------+
| 48   | Commands during read           | Use Set Block Count (CMD23)                 |
+------+--------------------------------+---------------------------------------------+
| 49   | Commands during write          | Use Set Block Count (CMD23)                 |
+------+--------------------------------+---------------------------------------------+
| 50   | Commands during non-blocking   | Read - use Set Block Count (CMD23)          |
+------+--------------------------------+---------------------------------------------+
| 51   | Commands during non-blocking   | Write - use Set Block Count (CMD23)         |
+------+--------------------------------+---------------------------------------------+

Kết quả kiểm tra
============

Kết quả kiểm tra được ghi vào nhật ký kernel. Mỗi bài kiểm tra ghi lại thời điểm bắt đầu, kết thúc và kết quả của bài kiểm tra. Các kết quả có thể là:

- ZZ0000ZZ: Quá trình kiểm tra đã hoàn tất thành công.
- ZZ0001ZZ: Thử nghiệm thất bại.
- ZZ0002ZZ: Bài kiểm tra không được máy chủ hỗ trợ.
- ZZ0003ZZ: Bài test không được hỗ trợ bởi thẻ.
- ZZ0004ZZ: Đã xảy ra lỗi trong quá trình kiểm tra.

Ví dụ đầu ra nhật ký hạt nhân
=========================

Khi chạy thử nghiệm, bạn sẽ thấy các mục nhật ký tương tự như sau trong nhật ký kernel:

.. code-block:: none

   [ 1234.567890] mmc0: Starting tests of card mmc0:0001...
   [ 1234.567891] mmc0: Test case 4. Basic read (with data verification)...
   [ 1234.567892] mmc0: Result: OK
   [ 1234.567893] mmc0: Tests completed.

Trong ví dụ này, trường hợp kiểm thử 4 (Đọc cơ bản với xác minh dữ liệu) đã được thực thi và kết quả là ổn.


Đóng góp
============

Những đóng góp cho khung ZZ0000ZZ đều được hoan nghênh. Vui lòng làm theo các nguyên tắc đóng góp nhân Linux tiêu chuẩn và gửi các bản vá cho nhà bảo trì thích hợp.

Liên hệ
=======

Để biết thêm thông tin hoặc báo cáo sự cố, vui lòng liên hệ với người bảo trì hệ thống con MMC.