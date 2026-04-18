.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/driver-api/firmware/fw_upload.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=====================
Tải lên chương trình cơ sở API
===================

Trình điều khiển thiết bị đăng ký với trình tải chương trình cơ sở sẽ hiển thị
các nút sysfs liên tục để cho phép người dùng bắt đầu cập nhật chương trình cơ sở cho
thiết bị đó.  Đó là trách nhiệm của người điều khiển thiết bị và/hoặc
chính thiết bị để thực hiện bất kỳ xác nhận nào trên dữ liệu nhận được. Phần sụn
tải lên sử dụng cùng các tệp sysfs ZZ0000ZZ và ZZ0001ZZ được mô tả trong
tài liệu về dự phòng phần sụn. Nó cũng bổ sung thêm các tập tin sysfs
để cung cấp trạng thái chuyển hình ảnh chương trình cơ sở sang thiết bị.

Đăng ký tải lên chương trình cơ sở
============================

Trình điều khiển thiết bị đăng ký tải lên chương trình cơ sở bằng cách gọi
firmware_upload_register(). Trong danh sách tham số có tên
xác định thiết bị trong/sys/class/firmware. Người dùng có thể bắt đầu một
tải lên chương trình cơ sở bằng cách lặp lại 1 vào tệp sysfs ZZ0000ZZ cho mục tiêu
thiết bị. Tiếp theo, người dùng ghi image firmware vào sysfs ZZ0001ZZ
tập tin. Sau khi ghi dữ liệu phần sụn, người dùng lặp lại 0 đến ZZ0002ZZ
sysfs để báo hiệu hoàn thành. Echoing 0 tới ZZ0003ZZ cũng kích hoạt
chuyển phần sụn sang trình điều khiển thiết bị đòn bẩy thấp hơn trong ngữ cảnh
của một luồng công nhân hạt nhân.

Để sử dụng phần mềm tải lên chương trình cơ sở API, hãy viết trình điều khiển triển khai một bộ
ôi.  Hàm thăm dò gọi firmware_upload_register() và xóa
gọi hàm firmware_upload_unregister() chẳng hạn như ::

cấu trúc const tĩnh fw_upload_ops m10bmc_ops = {
		.prepare = m10bmc_sec_prepare,
		.write = m10bmc_sec_write,
		.poll_complete = m10bmc_sec_poll_complete,
		.cancel = m10bmc_sec_cancel,
		.cleanup = m10bmc_sec_cleanup,
	};

int tĩnh m10bmc_sec_probe(struct platform_device *pdev)
	{
		const char *fw_name, *truncate;
		cấu trúc m10bmc_sec *giây;
		struct fw_upload *fwl;
		int len ​​không dấu;

giây = devm_kzalloc(&pdev->dev, sizeof(*sec), GFP_KERNEL);
		nếu (! giây)
			trả về -ENOMEM;

giây->dev = &pdev->dev;
		giây->m10bmc = dev_get_drvdata(pdev->dev.parent);
		dev_set_drvdata(&pdev->dev, giây);

fw_name = dev_name(giây->dev);
		cắt ngắn = strstr(fw_name, ".auto");
		len = (cắt ngắn) ? cắt ngắn - fw_name : strlen(fw_name);
		giây->fw_name = kmemdup_nul(fw_name, len, GFP_KERNEL);

fwl = firmware_upload_register(THIS_MODULE, giây->dev, giây->fw_name,
					       &m10bmc_ops, giây);
		nếu (IS_ERR(fwl)) {
			dev_err(sec->dev, "Trình điều khiển tải lên chương trình cơ sở không khởi động được\n");
			kfree(giây->fw_name);
			trả về PTR_ERR(fwl);
		}

giây->fwl = fwl;
		trả về 0;
	}

int tĩnh m10bmc_sec_remove(struct platform_device *pdev)
	{
		struct m10bmc_sec *sec = dev_get_drvdata(&pdev->dev);

firmware_upload_unregister(giây->fwl);
		kfree(giây->fw_name);
		trả về 0;
	}

firmware_upload_register
------------------------
.. kernel-doc:: drivers/base/firmware_loader/sysfs_upload.c
   :identifiers: firmware_upload_register

firmware_upload_unregister
--------------------------
.. kernel-doc:: drivers/base/firmware_loader/sysfs_upload.c
   :identifiers: firmware_upload_unregister

Hoạt động tải lên chương trình cơ sở
-------------------
.. kernel-doc:: include/linux/firmware.h
   :identifiers: fw_upload_ops

Mã tiến trình tải lên chương trình cơ sở
------------------------------
Các mã tiến trình sau đây được trình tải chương trình cơ sở sử dụng nội bộ.
Các chuỗi tương ứng được báo cáo thông qua nút sysfs trạng thái
được mô tả bên dưới và được ghi lại trong tài liệu ABI.

.. kernel-doc:: drivers/base/firmware_loader/sysfs_upload.h
   :identifiers: fw_upload_prog

Mã lỗi tải lên chương trình cơ sở
---------------------------
Các mã lỗi sau đây có thể được trình điều khiển trả về trong trường hợp
thất bại:

.. kernel-doc:: include/linux/firmware.h
   :identifiers: fw_upload_err

Thuộc tính Sysfs
================

Ngoài các tệp sysfs ZZ0000ZZ và ZZ0001ZZ, còn có các tệp bổ sung
sysfs để theo dõi trạng thái truyền dữ liệu đến mục tiêu
thiết bị và để xác định trạng thái đạt/không đạt cuối cùng của quá trình truyền.
Tùy thuộc vào thiết bị và kích thước của hình ảnh phần sụn, phần sụn
cập nhật có thể mất vài mili giây hoặc vài phút.

Các tệp sysfs bổ sung là:

* trạng thái - cung cấp dấu hiệu về tiến trình cập nhật chương trình cơ sở
* lỗi - cung cấp thông tin lỗi cho bản cập nhật chương trình cơ sở không thành công
* kích thước còn lại - theo dõi phần truyền dữ liệu của bản cập nhật
* cancel - echo 1 tới file này để hủy cập nhật