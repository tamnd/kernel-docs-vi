.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/driver-api/firmware/request_firmware.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

======================
request_firmware API
====================

Thông thường, bạn sẽ tải chương trình cơ sở và sau đó tải nó vào thiết bị của mình bằng cách nào đó.
Luồng công việc phần sụn điển hình được phản ánh bên dưới::

if(request_firmware(&fw_entry, $FIRMWARE, thiết bị) == 0)
                copy_fw_to_device(fw_entry->data, fw_entry->size);
	 phát hành_firmware(fw_entry);

Yêu cầu phần mềm đồng bộ
=============================

Các yêu cầu phần sụn đồng bộ sẽ đợi cho đến khi tìm thấy phần sụn hoặc cho đến khi
một lỗi được trả về.

request_firmware
----------------
.. kernel-doc:: drivers/base/firmware_loader/main.c
   :functions: request_firmware

firmware_request_nowarn
-----------------------
.. kernel-doc:: drivers/base/firmware_loader/main.c
   :functions: firmware_request_nowarn

firmware_request_platform
-------------------------
.. kernel-doc:: drivers/base/firmware_loader/main.c
   :functions: firmware_request_platform

request_firmware_direct
-----------------------
.. kernel-doc:: drivers/base/firmware_loader/main.c
   :functions: request_firmware_direct

request_firmware_into_buf
-------------------------
.. kernel-doc:: drivers/base/firmware_loader/main.c
   :functions: request_firmware_into_buf

Yêu cầu phần sụn không đồng bộ
==============================

Yêu cầu phần sụn không đồng bộ cho phép mã trình điều khiển không phải chờ
cho đến khi phần sụn hoặc lỗi được trả về. Gọi lại chức năng là
được cung cấp để khi tìm thấy phần sụn hoặc lỗi, trình điều khiển sẽ được
được thông báo thông qua cuộc gọi lại. request_firmware_nowait() không thể gọi được
trong bối cảnh nguyên tử.

request_firmware_nowait
-----------------------
.. kernel-doc:: drivers/base/firmware_loader/main.c
   :functions: request_firmware_nowait

Tối ưu hóa đặc biệt khi khởi động lại
===============================

Một số thiết bị có sẵn tính năng tối ưu hóa để cho phép sử dụng chương trình cơ sở
được giữ lại trong quá trình khởi động lại hệ thống. Khi sử dụng những tối ưu hóa như vậy, trình điều khiển
tác giả phải đảm bảo phần sụn vẫn có sẵn trong sơ yếu lý lịch sau khi tạm dừng,
điều này có thể được thực hiện với firmware_request_cache() thay vì yêu cầu
phần sụn cần được tải.

firmware_request_cache()
------------------------
.. kernel-doc:: drivers/base/firmware_loader/main.c
   :functions: firmware_request_cache

yêu cầu sử dụng driver firmware API dự kiến
========================================

Sau khi có cuộc gọi API trả về, bạn xử lý chương trình cơ sở và sau đó giải phóng
phần sụn. Ví dụ: nếu bạn đã sử dụng request_firmware() và nó trả về,
trình điều khiển có hình ảnh chương trình cơ sở có thể truy cập được trong fw_entry->{data,size}.
Nếu có lỗi xảy ra, request_firmware() trả về khác 0 và fw_entry
được đặt thành NULL. Sau khi trình điều khiển của bạn xử lý xong phần sụn, nó
có thể gọi Release_firmware(fw_entry) để phát hành hình ảnh phần sụn
và bất kỳ tài nguyên liên quan nào.
