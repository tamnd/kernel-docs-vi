.. SPDX-License-Identifier: GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/dvb/dmx-get-pes-pids.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. c:namespace:: DTV.dmx

.. _DMX_GET_PES_PIDS:

==================
DMX_GET_PES_PIDS
==================

Tên
----

DMX_GET_PES_PIDS

Tóm tắt
--------

.. c:macro:: DMX_GET_PES_PIDS

ZZ0000ZZ

Đối số
---------

ZZ0001ZZ
    Bộ mô tả tệp được trả về bởi ZZ0000ZZ.

ZZ0000ZZ
    Mảng dùng để lưu trữ 5 Program ID.

Sự miêu tả
-----------

Ioctl này cho phép truy vấn thiết bị DVB để trả về PID đầu tiên được sử dụng
bằng âm thanh, video, văn bản, phụ đề và các chương trình PCR trên một dịch vụ nhất định.
Chúng được lưu trữ dưới dạng:

===========================================================================
Nội dung vị trí phần tử PID
===========================================================================
pids[DMX_PES_AUDIO] 0 âm thanh đầu tiên PID
pids[DMX_PES_VIDEO] 1 video đầu tiên PID
pids[DMX_PES_TELETEXT] 2 teletext đầu tiên PID
pids[DMX_PES_SUBTITLE] 3 phụ đề đầu tiên PID
pids[DMX_PES_PCR] 4 Đồng hồ chương trình đầu tiên Tham khảo PID
===========================================================================

.. note::

	A value equal to 0xffff means that the PID was not filled by the
	Kernel.

Giá trị trả về
--------------

Khi thành công 0 được trả về.

Khi có lỗi -1 được trả về và biến ZZ0000ZZ được đặt
một cách thích hợp.

Các mã lỗi chung được mô tả tại
Chương ZZ0000ZZ.