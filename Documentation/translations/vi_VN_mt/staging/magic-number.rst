.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/staging/magic-number.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. _magicnumbers:

Những con số ma thuật của Linux
===============================

Tệp này là sổ đăng ký các số ma thuật đang được sử dụng.  Khi bạn
thêm một số ma thuật vào cấu trúc, bạn cũng nên thêm nó vào cấu trúc này
tập tin, vì tốt nhất là các số ma thuật được sử dụng bởi các cấu trúc khác nhau
là duy nhất.

Đó là một ý tưởng hay của ZZ0000ZZ để bảo vệ cấu trúc dữ liệu hạt nhân bằng phép thuật
những con số.  Điều này cho phép bạn kiểm tra trong thời gian chạy xem (a) một cấu trúc
đã bị ghi đè hoặc (b) bạn đã chuyển sai cấu trúc cho một
thường lệ.  Điều cuối cùng này đặc biệt hữu ích --- đặc biệt khi bạn
chuyển con trỏ tới các cấu trúc thông qua con trỏ void *.  Mã tty,
ví dụ: điều này có thường xuyên để vượt qua trình điều khiển cụ thể và dòng
cấu trúc kỷ luật cụ thể qua lại.

Cách sử dụng số ma thuật là khai báo chúng ở đầu
cấu trúc, như vậy::

cấu trúc tty_ldisc {
		ma thuật int;
		...
	};

Hãy tuân theo kỷ luật này khi bạn thêm các cải tiến trong tương lai
đến hạt nhân!  Nó đã giúp tôi tiết kiệm vô số giờ gỡ lỗi,
đặc biệt là trong những trường hợp rắc rối khi một mảng bị tràn và
các cấu trúc theo sau mảng đã bị ghi đè.  Sử dụng cái này
kỷ luật, những trường hợp này được phát hiện nhanh chóng và an toàn.

Nhật ký thay đổi::

Theodore Ts'o
					31 tháng 3 năm 94

Bảng ma thuật hiện có trên Linux 2.1.55.

Michael Chastain
					<mailto:mec@shout.net>
					22 tháng 9 năm 1997

Bây giờ nó phải được cập nhật với Linux 2.1.112. Bởi vì
  chúng ta đang trong thời gian đóng băng tính năng, điều đó rất khó xảy ra
  một cái gì đó sẽ thay đổi trước 2.2.x. Các mục là
  sắp xếp theo trường số.

Krzysztof G. Baranowski
					<mail tới: kgb@knm.org.pl>
					29 tháng 7 năm 1998

Đã cập nhật bảng ma thuật lên Linux 2.5.45. Ngay trên tính năng đóng băng,
  nhưng có thể một số con số ma thuật mới sẽ lẻn vào
  kernel trước 2.6.x chưa.

Petr Baudis
					<pasky@ucw.cz>
					03 tháng 11 năm 2002

Đã cập nhật bảng ma thuật lên Linux 2.5.74.

Fabian Frederick
					<ffrederick@users.sourceforge.net>
					09 tháng 7 năm 2003


====================== ========================================== ====================================================
Tệp cấu trúc số tên ma thuật
====================== ========================================== ====================================================
PG_MAGIC 'P' pg_{đọc,viết__hdr ZZ0000ZZ
APM_BIOS_MAGIC 0x4101 apm_user ZZ0001ZZ
FASYNC_MAGIC 0x4601 fasync_struct ZZ0002ZZ
SLIP_MAGIC 0x5302 trượt ZZ0003ZZ
BAYCOM_MAGIC 19730510 baycom_state ZZ0004ZZ
HDLCDRV_MAGIC 0x5ac6e778 hdlcdrv_state ZZ0005ZZ
KV_MAGIC 0x5f4b565f kernel_vars_s ZZ0006ZZ
CODA_MAGIC 0xC0DAC0DA coda_file_info ZZ0007ZZ
YAM_MAGIC 0xF10A7654 yam_port ZZ0008ZZ
CCB_MAGIC 0xf2691ad2 ccb ZZ0009ZZ
QUEUE_MAGIC_FREE 0xf7e1c9a3 queue_entry ZZ0010ZZ
QUEUE_MAGIC_USED 0xf7e1cc33 queue_entry ZZ0011ZZ
NMI_MAGIC 0x48414d4d455201 nmi_s ZZ0012ZZ
====================== ========================================== ====================================================
