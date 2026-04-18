.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/driver-api/soundwire/bra_cadence.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

Hỗ trợ nhịp IP BRA
----------------------

Yêu cầu về định dạng
~~~~~~~~~~~~~~~~~~~

IP Cadence dựa trên PDI0 cho TX và PDI1 cho RX. Các nhu cầu dữ liệu
được định dạng theo các quy ước sau:

(1) tất cả Dữ liệu được lưu trữ ở bit 15..0 của FIFO PDI 32 bit.

(2) điểm bắt đầu của gói là BIT(31).

(3) phần cuối của gói là BIT(30).

(4) ID gói được lưu trữ ở bit 19..16. ID gói này là
      được xác định bằng phần mềm và thường là một bộ đếm lăn.

(5) Phần đệm sẽ được chèn vào khi cần thiết sao cho Tiêu đề CRC,
      Phản hồi tiêu đề, Chân trang CRC, Phản hồi chân trang luôn ở trạng thái
      Byte0. Phần đệm được phần mềm chèn vào để ghi và đọc
      phần mềm sẽ loại bỏ phần đệm được phần cứng thêm vào.

Định dạng ví dụ
~~~~~~~~~~~~~~

Bảng sau thể hiện trình tự được cung cấp cho PDI0 cho một
lệnh ghi theo sau là lệnh đọc.

::

+---+---+--------+---------------+--------------+
	+ 1 ID ZZ0000ZZ = 0 ZZ0001ZZ WR HDR[0] |
	+ ZZ0002ZZ ZZ0003ZZ WR HDR[2] |
	+ ZZ0004ZZ ZZ0005ZZ WR HDR[4] |
	+ ZZ0006ZZ ZZ0007ZZ WR HDR CRC |
	+ Dữ liệu ZZ0008ZZ ZZ0009ZZ WR[0] |
	+ Dữ liệu ZZ0010ZZ ZZ0011ZZ WR[2] |
	+ Dữ liệu ZZ0012ZZ ZZ0013ZZ WR[n-3] |
	+ Dữ liệu ZZ0014ZZ ZZ0015ZZ WR[n-1] |
	+ 0 ZZ0016ZZ ZZ0017ZZ Dữ liệu WR CRC |
	+---+---+--------+---------------+--------------+
	+ 1 ID ZZ0018ZZ = 1 ZZ0019ZZ RD HDR[0] |
	+ ZZ0020ZZ ZZ0021ZZ RD HDR[2] |
	+ ZZ0022ZZ ZZ0023ZZ RD HDR[4] |
	+ 0 ZZ0024ZZ ZZ0025ZZ RD HDR CRC |
	+---+---+--------+---------------+--------------+


Bảng bên dưới thể hiện dữ liệu nhận được trên PDI1 cho cùng một
lệnh ghi theo sau là lệnh đọc.

::

+---+---+--------+---------------+--------------+
	+ 1 ID ZZ0000ZZ = 0 ZZ0001ZZ WR Hdr Rsp |
	+ 0 ZZ0002ZZ ZZ0003ZZ WR Ftr Rsp |
	+---+---+--------+---------------+--------------+
	+ 1 ID ZZ0004ZZ = 0 ZZ0005ZZ Rd Hdr Rsp |
	+ Dữ liệu ZZ0006ZZ ZZ0007ZZ RD[0] |
	+ Dữ liệu ZZ0008ZZ ZZ0009ZZ RD[2] |
	+ Dữ liệu ZZ0010ZZ ZZ0011ZZ RD[n-3] |
	+ Dữ liệu ZZ0012ZZ ZZ0013ZZ RD[n-1] |
	+ ZZ0014ZZ ZZ0015ZZ Dữ liệu RD CRC |
	+ 0 ZZ0016ZZ ZZ0017ZZ RD Ftr Rsp |
	+---+---+--------+---------------+--------------+
