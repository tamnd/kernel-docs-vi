.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/networking/alias.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

============
Bí danh IP
===========

Bí danh IP là một cách lỗi thời để quản lý nhiều địa chỉ/mặt nạ IP
mỗi giao diện. Các công cụ mới hơn như iproute2 hỗ trợ nhiều
địa chỉ/tiền tố trên mỗi giao diện, nhưng bí danh vẫn được hỗ trợ
để có khả năng tương thích ngược.

Bí danh được hình thành bằng cách thêm dấu hai chấm và chuỗi khi chạy ifconfig.
Chuỗi này thường là số, nhưng đây không phải là điều bắt buộc.


Tạo bí danh
==============

Việc tạo bí danh được thực hiện bằng cách đặt tên giao diện 'ma thuật': vd. để tạo ra một
Bí danh 200.1.1.1 cho eth0 ...
::

# ifconfig eth0:0 200.1.1.1, v.v....
	~~ -> yêu cầu tạo bí danh #0 (nếu chưa tồn tại) cho eth0

Tuyến đường tương ứng cũng được thiết lập bằng lệnh này.  Xin lưu ý:
Tuyến đường luôn trỏ đến giao diện cơ sở.


Xóa bí danh
==============

Bí danh được xóa bằng cách tắt bí danh ::

# ifconfig eth0:0 giảm
	~~~~~~~~~~ -> sẽ xóa bí danh


Cấu hình bí danh (lại)
======================

Bí danh không phải là thiết bị thực, nhưng các chương trình có thể định cấu hình
và đề cập đến chúng như bình thường (ifconfig, tuyến đường, v.v.).


Mối quan hệ với thiết bị chính
=============================

Nếu thiết bị cơ sở bị tắt, các bí danh đã thêm cũng sẽ bị xóa.