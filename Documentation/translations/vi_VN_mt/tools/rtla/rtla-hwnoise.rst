.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/tools/rtla/rtla-hwnoise.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. |tool| replace:: hwnoise

=============
rtla-hwnoise
============
------------------------------------------
Phát hiện và định lượng tiếng ồn liên quan đến phần cứng
------------------------------------------

:Phần hướng dẫn sử dụng: 1

SYNOPSIS
========

ZZ0000ZZ [ZZ0001ZZ]

DESCRIPTION
===========

ZZ0000ZZ thu thập bản tóm tắt định kỳ từ công cụ theo dõi ZZ0001ZZ
chạy với ZZ0002ZZ. Bằng cách vô hiệu hóa các ngắt và lập kế hoạch
do đó, trong số các luồng, chỉ có các ngắt không thể che dấu và các ngắt liên quan đến phần cứng
tiếng ồn được cho phép.

Công cụ này cũng cho phép cấu hình bộ theo dõi ZZ0000ZZ và
bộ sưu tập đầu ra của bộ theo dõi.

OPTIONS
=======
.. include:: common_osnoise_options.txt

.. include:: common_top_options.txt

.. include:: common_options.txt

EXAMPLE
=======
Trong ví dụ bên dưới, công cụ ZZ0000ZZ được thiết lập để chạy trên CPU ZZ0001ZZ
trên hệ thống có 8 lõi/16 luồng có bật tính năng siêu phân luồng.

Công cụ này được thiết lập để phát hiện bất kỳ tiếng ồn nào cao hơn ZZ0000ZZ,
để chạy cho ZZ0001ZZ, hiển thị bản tóm tắt báo cáo tại
kết thúc phiên::

# rtla hwnoise -c 1-7 -T 1 -d 10m -q
                                          Tiếng ồn liên quan đến phần cứng
  thời lượng: 0 00:10:00 | thời gian ở trong chúng ta
  CPU Tiếng ồn thời gian chạy % CPU Tiếng ồn tối đa aval Tối đa đơn HW NMI
    1 #599 599000000 138 99.99997 3 3 4 74
    2 #599 599000000 85 99.99998 3 3 4 75
    3 #599 599000000 86 99.99998 4 3 6 75
    4 #599 599000000 81 99.99998 4 4 2 75
    5 #599 599000000 85 99.99998 2 2 2 75
    6 #599 599000000 76 99.99998 2 2 0 75
    7 #599 599000000 77 99.99998 3 3 0 75


Cột đầu tiên hiển thị ZZ0000ZZ và cột thứ hai hiển thị số lượng
ZZ0001ZZ công cụ này đã chạy trong phiên. ZZ0002ZZ là thời gian
công cụ này chạy hiệu quả trên CPU. Cột ZZ0003ZZ là tổng của
tất cả tiếng ồn mà công cụ quan sát được và ZZ0004ZZ là mối quan hệ
giữa ZZ0005ZZ và ZZ0006ZZ.

Cột ZZ0000ZZ là mức nhiễu phần cứng tối đa mà công cụ phát hiện được trong
một khoảng thời gian và ZZ0001ZZ là tiếng ồn đơn lớn nhất được nhìn thấy.

Cột ZZ0000ZZ và ZZ0001ZZ hiển thị tổng số nhiễu ZZ0002ZZ và ZZ0003ZZ
sự xuất hiện được quan sát bởi công cụ.

Ví dụ: ZZ0000ZZ chạy các giai đoạn ZZ0001ZZ của ZZ0002ZZ. CPU đã nhận được
ZZ0003ZZ có tiếng ồn trong toàn bộ quá trình thực hiện, để lại ZZ0004ZZ trong thời gian CPU
cho ứng dụng. Trong giai đoạn tồi tệ nhất, CPU đã khiến ZZ0005ZZ bị
tiếng ồn cho ứng dụng, nhưng chắc chắn nó được gây ra bởi nhiều hơn một
tiếng ồn, vì tiếng ồn của ZZ0006ZZ là của ZZ0007ZZ. CPU có ZZ0008ZZ ở mức
tỷ lệ ZZ0009ZZ/ZZ0010ZZ. CPU cũng có ZZ0011ZZ, ở mức cao hơn
tần số: khoảng ZZ0012ZZ.

Công cụ sẽ báo cáo tiếng ồn liên quan đến phần cứng ZZ0001ZZ trong tình huống lý tưởng.
Ví dụ: bằng cách tắt tính năng siêu phân luồng để loại bỏ nhiễu phần cứng,
và vô hiệu hóa cơ quan giám sát TSC để loại bỏ NMI (có thể xác định
này bằng cách sử dụng các tùy chọn theo dõi của ZZ0000ZZ), có thể tiếp cận
tình huống lý tưởng trong cùng một phần cứng::

# rtla hwnoise -c 1-7 -T 1 -d 10m -q
                                          Tiếng ồn liên quan đến phần cứng
  thời lượng: 0 00:10:00 | thời gian ở trong chúng ta
  CPU Tiếng ồn thời gian chạy % CPU Tiếng ồn tối đa aval Tối đa đơn HW NMI
    1 #599 599000000 0 100.00000 0 0 0 0
    2 #599 599000000 0 100.00000 0 0 0 0
    3 #599 599000000 0 100.00000 0 0 0 0
    4 #599 599000000 0 100.00000 0 0 0 0
    5 #599 599000000 0 100.00000 0 0 0 0
    6 #599 599000000 0 100.00000 0 0 0 0
    7 #599 599000000 0 100.00000 0 0 0 0

SEE ALSO
========

ZZ0000ZZ\(1)

ZZ0000ZZ

AUTHOR
======
Viết bởi Daniel Bristot de Oliveira <bristot@kernel.org>

.. include:: common_appendix.txt