.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/drivers/npcm-video.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

.. include:: <isonum.txt>

Trình điều khiển video NPCM
=================

Trình điều khiển này được sử dụng để điều khiển công cụ Quay video/Phân biệt video (VCD)
và Công cụ nén mã hóa (ECE) có trên SoC Nuvoton NPCM. VCD có thể
chụp một khung hình từ đầu vào video kỹ thuật số và so sánh hai khung hình trong bộ nhớ và
ECE có thể nén dữ liệu khung thành định dạng HEXTILE.

Điều khiển dành riêng cho người lái xe
------------------------

V4L2_CID_NPCM_CAPTURE_MODE
~~~~~~~~~~~~~~~~~~~~~~~~~~

Động cơ VCD hỗ trợ hai chế độ:

- Chế độ COMPLETE:

Chụp khung hình hoàn chỉnh tiếp theo vào bộ nhớ.

- Chế độ DIFF:

So sánh khung hình đến với khung được lưu trong bộ nhớ và cập nhật khung
  khung phân biệt trong bộ nhớ.

Ứng dụng có thể sử dụng điều khiển ZZ0000ZZ để đặt chế độ VCD
với các giá trị điều khiển khác nhau (enum v4l2_npcm_capture_mode):

- ZZ0000ZZ: sẽ đặt VCD ở chế độ COMPLETE.
- ZZ0001ZZ: sẽ đặt VCD ở chế độ DIFF.

V4L2_CID_NPCM_RECT_COUNT
~~~~~~~~~~~~~~~~~~~~~~~~

Nếu sử dụng định dạng V4L2_PIX_FMT_HEXTILE, VCD sẽ thu thập dữ liệu khung và sau đó là ECE
sẽ nén dữ liệu thành hình chữ nhật HEXTILE và lưu trữ chúng trong video V4L2
bộ đệm với bố cục được xác định trong Giao thức bộ đệm khung từ xa:
::

(RFC 6143, ZZ0000ZZ

+--------------+--------------+-------------------+
           ZZ0000ZZ Loại [Giá trị] ZZ0001ZZ
           +--------------+--------------+-------------------+
           ZZ0002ZZ U16 ZZ0003ZZ
           ZZ0004ZZ U16 ZZ0005ZZ
           ZZ0006ZZ U16 ZZ0007ZZ
           ZZ0008ZZ U16 ZZ0009ZZ
           ZZ0010ZZ S32 ZZ0011ZZ
           +--------------+--------------+-------------------+
           ZZ0012ZZ
           +--------------------------------------------------- +

Ứng dụng có thể lấy bộ đệm video thông qua VIDIOC_DQBUF và tiếp theo là
gọi control ZZ0000ZZ để lấy số HEXTILE
hình chữ nhật trong bộ đệm này.

Tài liệu tham khảo
----------
bao gồm/uapi/linux/npcm-video.h

ZZ0000ZZ ZZ0001ZZ 2022 Công nghệ Nuvoton