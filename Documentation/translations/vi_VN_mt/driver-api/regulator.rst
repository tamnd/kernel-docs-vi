.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/driver-api/regulator.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. Copyright 2007-2008 Wolfson Microelectronics

..   This documentation is free software; you can redistribute
..   it and/or modify it under the terms of the GNU General Public
..   License version 2 as published by the Free Software Foundation.

======================================
Bộ điều chỉnh điện áp và dòng điện API
======================================

:Tác giả: Liam Girdwood
:Tác giả: Mark Brown

Giới thiệu
============

Khung công tác này được thiết kế để cung cấp một giao diện kernel chuẩn cho
điều khiển điện áp và điều chỉnh dòng điện.

Mục đích là cho phép các hệ thống điều khiển linh hoạt nguồn điện của bộ điều chỉnh
đầu ra để tiết kiệm điện năng và kéo dài tuổi thọ pin. Điều này áp dụng cho
cả bộ điều chỉnh điện áp (nơi có thể điều khiển được điện áp đầu ra) và
mức chìm hiện tại (nơi có thể kiểm soát được giới hạn hiện tại).

Lưu ý rằng tài liệu bổ sung (và hiện tại đầy đủ hơn) là
có sẵn trong nguồn nhân Linux dưới
ZZ0000ZZ.

Thuật ngữ
---------

Bộ điều chỉnh API sử dụng một số thuật ngữ có thể không quen thuộc:

Bộ điều chỉnh

Thiết bị điện tử cung cấp năng lượng cho các thiết bị khác. Hầu hết các cơ quan quản lý
    có thể kích hoạt và vô hiệu hóa đầu ra của họ và một số cũng có thể kiểm soát
    điện áp hoặc dòng điện đầu ra.

Người tiêu dùng

Thiết bị điện tử tiêu thụ năng lượng được cung cấp bởi bộ điều chỉnh. Những cái này
    có thể là tĩnh, chỉ yêu cầu nguồn cung cấp cố định hoặc động,
    yêu cầu quản lý tích cực bộ điều chỉnh trong thời gian chạy.

Miền quyền lực

Mạch điện tử được cung cấp bởi bộ điều chỉnh nhất định, bao gồm cả
    bộ điều chỉnh và tất cả các thiết bị tiêu dùng. Cấu hình của bộ điều chỉnh
    được chia sẻ giữa tất cả các thành phần trong mạch.

Mạch tích hợp quản lý nguồn (PMIC)

Một IC chứa nhiều bộ điều chỉnh và thường có các bộ điều chỉnh khác
    các hệ thống con. Trong một hệ thống nhúng, PMIC chính thường tương đương
    đến sự kết hợp giữa PSU và cầu nam trong hệ thống máy tính để bàn.

Giao diện trình điều khiển tiêu dùng
====================================

Điều này cung cấp một API tương tự cho khung đồng hồ hạt nhân. Người tiêu dùng
trình điều khiển sử dụng ZZ0000ZZ và
Hoạt động ZZ0001ZZ để thu thập và phát hành
cơ quan quản lý. Các chức năng được cung cấp cho ZZ0002ZZ
và ZZ0003ZZ bộ điều chỉnh và để có được và
thiết lập các thông số thời gian chạy của bộ điều chỉnh.

Khi yêu cầu cơ quan quản lý, người tiêu dùng sử dụng tên tượng trưng cho
nguồn cung cấp, chẳng hạn như "Vcc", được ánh xạ vào các thiết bị điều chỉnh thực tế
bằng giao diện máy.

Phiên bản sơ khai của API này được cung cấp khi khung điều chỉnh được
không được sử dụng để giảm thiểu nhu cầu sử dụng ifdefs.

Kích hoạt và vô hiệu hóa
------------------------

Bộ điều chỉnh API cung cấp tính năng tham chiếu cho phép và vô hiệu hóa
cơ quan quản lý. Các thiết bị tiêu dùng sử dụng ZZ0000ZZ và
ZZ0001ZZ có chức năng bật và tắt
cơ quan quản lý. Các cuộc gọi đến hai chức năng phải được cân bằng.

Lưu ý rằng vì nhiều người tiêu dùng có thể đang sử dụng bộ điều chỉnh và máy
các ràng buộc có thể không cho phép bộ điều chỉnh bị vô hiệu hóa, không có
đảm bảo rằng việc gọi ZZ0000ZZ sẽ thực sự
làm cho nguồn cung cấp bởi cơ quan quản lý bị vô hiệu hóa. Người tiêu dùng
người lái xe nên cho rằng bộ điều chỉnh có thể được bật mọi lúc.

Cấu hình
-------------

Một số thiết bị tiêu dùng có thể cần có khả năng tự động cấu hình
nguồn cung cấp. Ví dụ: trình điều khiển MMC có thể cần chọn đúng
điện áp hoạt động cho thẻ của họ. Điều này có thể được thực hiện trong khi cơ quan quản lý
được kích hoạt hoặc vô hiệu hóa.

ZZ0000ZZ và
Các chức năng ZZ0001ZZ cung cấp chức năng chính
giao diện cho việc này. Cả hai đều có phạm vi điện áp và dòng điện, hỗ trợ
trình điều khiển không yêu cầu giá trị cụ thể (ví dụ: thang đo tần số CPU
thường cho phép CPU sử dụng phạm vi điện áp cung cấp rộng hơn ở mức thấp hơn
tần số nhưng không yêu cầu hạ điện áp nguồn). Ở đâu
cần phải có một giá trị chính xác, cả giá trị tối thiểu và tối đa phải là
giống hệt nhau.

Cuộc gọi lại
------------

Cuộc gọi lại cũng có thể được đăng ký cho các sự kiện như lỗi quy định.

Giao diện điều khiển bộ điều chỉnh
==================================

Trình điều khiển cho chip điều chỉnh đăng ký bộ điều chỉnh với bộ điều chỉnh
cốt lõi, cung cấp các cấu trúc hoạt động cho cốt lõi. Giao diện thông báo
cho phép các điều kiện lỗi được báo cáo đến lõi.

Việc đăng ký phải được kích hoạt bằng cách thiết lập rõ ràng được thực hiện bởi nền tảng,
cung cấp cấu trúc điều chỉnh_init_data cho bộ điều chỉnh
chứa các ràng buộc và cung cấp thông tin.

Giao diện máy
=================

Giao diện này cung cấp một cách để xác định cách các bộ điều chỉnh được kết nối với
người tiêu dùng trên một hệ thống nhất định và các thông số vận hành hợp lệ là gì
cho hệ thống.

Quân nhu
--------

Nguồn cung cấp bộ điều chỉnh được chỉ định bằng cách sử dụng struct
ZZ0000ZZ. Việc này được thực hiện khi đăng ký lái xe
thời gian như một phần của các ràng buộc của máy.

Hạn chế
-----------

Ngoài việc xác định các kết nối, giao diện máy còn cung cấp
các ràng buộc xác định các hoạt động mà khách hàng được phép thực hiện
và các thông số có thể được thiết lập. Điều này là cần thiết vì nhìn chung
các thiết bị điều chỉnh sẽ mang lại sự linh hoạt hơn mức an toàn khi sử dụng trên
một hệ thống nhất định, ví dụ như hỗ trợ điện áp cung cấp cao hơn
người tiêu dùng được đánh giá.

Việc này được thực hiện tại thời điểm đăng ký lái xe` bằng cách cung cấp
cấu trúc quy định_ràng buộc.

Các ràng buộc cũng có thể chỉ định cấu hình ban đầu cho
bộ điều chỉnh trong các ràng buộc, điều này đặc biệt hữu ích khi sử dụng với
người tiêu dùng tĩnh.

Tham khảo API
=============

Do những hạn chế của khung tài liệu hạt nhân và
bố cục hiện tại của mã nguồn toàn bộ bộ điều chỉnh API là
được ghi lại ở đây.

.. kernel-doc:: include/linux/regulator/consumer.h
   :internal:

.. kernel-doc:: include/linux/regulator/machine.h
   :internal:

.. kernel-doc:: include/linux/regulator/driver.h
   :internal:

.. kernel-doc:: drivers/regulator/core.c
   :export:
