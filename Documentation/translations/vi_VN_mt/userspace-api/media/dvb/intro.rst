.. SPDX-License-Identifier: GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/dvb/intro.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

.. _dvb_introduction:

************
Giới thiệu
************


.. _requisites:

Những điều bạn cần biết
=====================

Người đọc tài liệu này cần phải có một số kiến thức về
lĩnh vực phát sóng video kỹ thuật số (Truyền hình kỹ thuật số) và nên làm quen với
phần I của thông số kỹ thuật MPEG2 ISO/IEC 13818 (còn gọi là ITU-T H.222), tức là
bạn nên biết chương trình/luồng truyền tải (PS/TS) là gì và nó là gì
có nghĩa là dòng cơ sở được đóng gói (PES) hoặc I-frame.

Nhiều tài liệu tiêu chuẩn TV kỹ thuật số khác nhau có sẵn để tải xuống tại:

- Tiêu chuẩn Châu Âu (DVB): ZZ0000ZZ và/hoặc ZZ0001ZZ
- Tiêu chuẩn Mỹ (ATSC): ZZ0002ZZ
- Tiêu chuẩn Nhật Bản (ISDB): ZZ0003ZZ

Cũng cần phải biết cách truy cập các thiết bị Linux và cách
sử dụng các cuộc gọi ioctl. Điều này cũng bao gồm kiến ​​thức về C hoặc C++.


.. _history:

Lịch sử
=======

API đầu tiên dành cho card TV kỹ thuật số mà chúng tôi sử dụng tại Convergence vào cuối năm 1999 là một
phần mở rộng của Video4Linux API được phát triển chủ yếu cho khung
thẻ cướp. Vì vậy, nó không thực sự phù hợp để sử dụng cho Kỹ thuật số
Thẻ TV và các tính năng mới của chúng như ghi và lọc luồng MPEG
một số phần và luồng dữ liệu PES cùng một lúc.

Đầu năm 2000, Nokia tiếp cận Convergence với đề xuất về một giải pháp mới
TV kỹ thuật số Linux tiêu chuẩn API. Như một cam kết cho sự phát triển của thiết bị đầu cuối
dựa trên các tiêu chuẩn mở, Nokia và Convergence đã cung cấp dịch vụ này cho tất cả mọi người.
Các nhà phát triển Linux và xuất bản nó trên ZZ0000ZZ vào tháng 9
2000. Với trình điều khiển Linux cho thẻ Siemens/Hauppauge DVB PCI,
Sự hội tụ cung cấp triển khai đầu tiên cho Linux Digital TV API.
Convergence là nhà duy trì Linux Digital TV API vào thời kỳ đầu
ngày.

Hiện tại, API được cộng đồng LinuxTV (tức là bạn, người đọc) duy trì
của tài liệu này). Linux Digital TV API liên tục được xem xét và
được cải thiện cùng với những cải tiến ở cốt lõi của hệ thống con ở
Hạt nhân.


.. _overview:

Tổng quan
========


.. _stb_components:

.. kernel-figure:: dvbstb.svg
    :alt:   dvbstb.svg
    :align: center

    Components of a Digital TV card/STB

Thẻ TV kỹ thuật số hoặc hộp giải mã tín hiệu (STB) thường bao gồm
thành phần phần cứng chính sau:

Frontend bao gồm bộ điều chỉnh và bộ giải mã TV kỹ thuật số
   Ở đây, tín hiệu thô truyền tới phần cứng TV kỹ thuật số từ đĩa vệ tinh hoặc
   ăng-ten hoặc trực tiếp từ cáp. Giao diện người dùng chuyển đổi xuống và
   giải điều chế tín hiệu này thành luồng truyền tải MPEG (TS). Trong trường hợp
   của một giao diện vệ tinh, điều này bao gồm một cơ sở cho vệ tinh
   điều khiển thiết bị (SEC), cho phép kiểm soát phân cực LNB,
   công tắc đa nguồn cấp dữ liệu hoặc rôto món ăn.

Phần cứng truy cập có điều kiện (CA) như bộ điều hợp CI và khe cắm thẻ thông minh
   TS hoàn chỉnh được chuyển qua phần cứng CA. Các chương trình mà
   người dùng có quyền truy cập (điều khiển bằng thẻ thông minh) được giải mã trong
   thời gian thực và được chèn lại vào TS.

   .. note::

      Not every digital TV hardware provides conditional access hardware.

Bộ phân kênh lọc luồng TV kỹ thuật số MPEG-TS đến
   Bộ tách kênh chia TS thành các thành phần như âm thanh và
   luồng video. Bên cạnh một số âm thanh và video như vậy
   các luồng nó cũng chứa các luồng dữ liệu với thông tin về
   các chương trình được cung cấp trong luồng này hoặc các luồng khác của cùng một nhà cung cấp.

Bộ giải mã âm thanh và video
   Mục tiêu chính của bộ tách kênh là âm thanh và video
   bộ giải mã. Sau khi giải mã, chúng truyền âm thanh không nén và
   video tới màn hình máy tính hoặc TV.

   .. note::

      Modern hardware usually doesn't have a separate decoder hardware, as
      such functionality can be provided by the main CPU, by the graphics
      adapter of the system or by a signal processing hardware embedded on
      a Systems on a Chip (SoC) integrated circuit.

      It may also not be needed for certain usages (e.g. for data-only
      uses like "internet over satellite").

ZZ0000ZZ hiển thị sơ đồ thô về điều khiển và dữ liệu
chảy giữa các thành phần đó.



.. _dvb_devices:

Thiết bị truyền hình kỹ thuật số Linux
========================

Linux Digital TV API cho phép bạn điều khiển các thành phần phần cứng này thông qua
hiện có sáu thiết bị ký tự kiểu Unix cho video, âm thanh, giao diện người dùng,
mạng demux, CA và IP-over-DVB. Các thiết bị video và âm thanh
điều khiển phần cứng bộ giải mã MPEG2, thiết bị đầu cuối, bộ điều chỉnh và
bộ giải mã TV kỹ thuật số. Thiết bị demux cho phép bạn kiểm soát PES
và các bộ lọc phần của phần cứng. Nếu phần cứng không hỗ trợ
lọc, những bộ lọc này có thể được thực hiện trong phần mềm. Cuối cùng CA
thiết bị kiểm soát tất cả các khả năng truy cập có điều kiện của phần cứng.
Nó có thể phụ thuộc vào yêu cầu bảo mật riêng của nền tảng,
nếu và có bao nhiêu chức năng CA được cung cấp cho
ứng dụng thông qua thiết bị này.

Tất cả các thiết bị có thể được tìm thấy trong cây ZZ0000ZZ bên dưới ZZ0001ZZ. các
các thiết bị riêng lẻ được gọi là:

-ZZ0000ZZ,

-ZZ0000ZZ,

-ZZ0000ZZ,

-ZZ0000ZZ,

-ZZ0000ZZ,

-ZZ0000ZZ,

-ZZ0000ZZ,

trong đó ZZ0000ZZ liệt kê các thẻ TV Kỹ thuật số trong hệ thống bắt đầu từ 0 và
ZZ0001ZZ liệt kê các thiết bị của từng loại trong mỗi bộ chuyển đổi, bắt đầu
cũng từ 0. Chúng tôi sẽ bỏ qua "ZZ0002ZZ\ " trong phần tiếp theo
thảo luận về các thiết bị này

Thông tin chi tiết hơn về cấu trúc dữ liệu và lệnh gọi hàm của tất cả các
thiết bị được mô tả trong các chương sau.


.. _include_files:

API bao gồm các tập tin
=================

Đối với mỗi thiết bị TV kỹ thuật số đều tồn tại một tệp bao gồm tương ứng. các
TV kỹ thuật số API bao gồm các tệp nên được đưa vào nguồn ứng dụng với
đường dẫn một phần như:


.. code-block:: c

	#include <linux/dvb/ca.h>

	#include <linux/dvb/dmx.h>

	#include <linux/dvb/frontend.h>

	#include <linux/dvb/net.h>


Để cho phép các ứng dụng hỗ trợ phiên bản API khác, một bổ sung
bao gồm tệp ZZ0000ZZ tồn tại, xác định hằng số
ZZ0001ZZ. Tài liệu này mô tả ZZ0002ZZ.