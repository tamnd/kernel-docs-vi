.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/power/shutdown-debugging.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

Gỡ lỗi tắt hạt nhân bị treo với pstore
+++++++++++++++++++++++++++++++++++++++++++

Tổng quan
========
Nếu hệ thống bị treo trong khi tắt, nhật ký kernel có thể cần phải được
được lấy ra để gỡ lỗi vấn đề.

Trên các hệ thống có sẵn UART, tốt nhất nên cấu hình kernel để sử dụng
UART này cho đầu ra bảng điều khiển kernel.

Nếu UART không có sẵn, hệ thống con ZZ0000ZZ sẽ cung cấp cơ chế để
duy trì dữ liệu này trong suốt quá trình thiết lập lại hệ thống, cho phép truy xuất dữ liệu đó vào lần tiếp theo
khởi động.

Cấu hình hạt nhân
====================
Để bật ZZ0000ZZ và bật lưu nhật ký bộ đệm vòng hạt nhân, hãy đặt
các tùy chọn cấu hình kernel sau:

* ZZ0000ZZ
* ZZ0001ZZ

Ngoài ra, hãy kích hoạt phần phụ trợ để lưu trữ dữ liệu. Tùy thuộc vào nền tảng của bạn
một số lựa chọn tiềm năng bao gồm:

* ZZ0000ZZ
* ZZ0001ZZ
* ZZ0002ZZ
* ZZ0003ZZ

Tham số dòng lệnh hạt nhân
==============================
Thêm các tham số này vào dòng lệnh kernel của bạn:

* ZZ0000ZZ
	* Buộc kernel chuyển toàn bộ bộ đệm tin nhắn vào pstore trong khi
		tắt máy
* ZZ0001ZZ
	* Đối với các hệ thống dựa trên EFI, hãy đảm bảo chương trình phụ trợ EFI đang hoạt động

Tương tác không gian người dùng và truy xuất nhật ký
=======================================
Trong lần khởi động tiếp theo sau khi bị treo, nhật ký pstore sẽ có sẵn trong pstore
hệ thống tập tin (ZZ0000ZZ) và có thể được truy xuất bởi không gian người dùng.

Trên hệ thống systemd, dịch vụ ZZ0000ZZ sẽ giúp thực hiện những việc sau:

#. Xác định vị trí dữ liệu pstore trong ZZ0000ZZ
#. Đọc và lưu nó vào ZZ0001ZZ
#. Xóa dữ liệu pstore cho sự kiện tiếp theo