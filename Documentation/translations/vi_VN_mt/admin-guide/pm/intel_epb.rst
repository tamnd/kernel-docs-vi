.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/admin-guide/pm/intel_epb.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

.. include:: <isonum.txt>

=========================================
Gợi ý xu hướng năng lượng và hiệu suất của Intel
======================================

:Bản quyền: ZZ0000ZZ 2019 Tập đoàn Intel

:Tác giả: Rafael J. Wysocki <rafael.j.wysocki@intel.com>


.. kernel-doc:: arch/x86/kernel/cpu/intel_epb.c
   :doc: overview

Thuộc tính thiên vị năng lượng và hiệu suất Intel trong ZZ0000ZZ
========================================================

Giá trị Gợi ý Xu hướng Năng lượng và Hiệu suất Intel (EPB) cho CPU (logic) nhất định
có thể được kiểm tra hoặc cập nhật thông qua thuộc tính (tệp) ZZ0001ZZ trong
ZZ0000ZZ, trong đó CPU số ZZ0002ZZ
được phân bổ tại thời điểm khởi tạo hệ thống:

ZZ0000ZZ
	Hiển thị giá trị EPB hiện tại cho CPU theo thang trượt 0 - 15, trong đó
	giá trị 0 tương ứng với tùy chọn gợi ý để có hiệu suất cao nhất
	và giá trị 15 tương ứng với mức tiết kiệm năng lượng tối đa.

Để cập nhật giá trị EPB cho CPU, thuộc tính này có thể
	được ghi vào, bằng một số trong thang trượt từ 0 - 15 ở trên, hoặc
	bằng một trong các chuỗi: "hiệu suất", "cân bằng hiệu suất", "bình thường",
	"cân bằng quyền lực", "quyền lực" đại diện cho các giá trị được phản ánh bởi
	ý nghĩa.

Thuộc tính này hiện diện cho tất cả các CPU trực tuyến hỗ trợ EPB
	tính năng.

Lưu ý rằng mặc dù giao diện EPB với bộ xử lý được xác định ở CPU logic
cấp độ, thanh ghi vật lý sao lưu nó có thể được chia sẻ bởi nhiều CPU (đối với
ví dụ: SMT anh chị em hoặc lõi trong một gói).  Vì lý do này, việc cập nhật
Giá trị EPB cho một CPU có thể khiến giá trị EPB cho các CPU khác thay đổi.