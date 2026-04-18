.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/gpu/drm-internals.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=====================
Bộ phận bên trong DRM
=====================

Chương này ghi lại nội bộ DRM có liên quan đến tác giả trình điều khiển và
các nhà phát triển đang làm việc để thêm hỗ trợ cho các tính năng mới nhất cho các tính năng hiện có
trình điều khiển.

Đầu tiên, chúng ta xem xét một số yêu cầu khởi tạo trình điều khiển điển hình, như
thiết lập bộ đệm lệnh, tạo cấu hình đầu ra ban đầu,
và khởi tạo các dịch vụ cốt lõi. Các phần tiếp theo bao gồm nội bộ cốt lõi
chi tiết hơn, cung cấp các ghi chú và ví dụ thực hiện.

Lớp DRM cung cấp một số dịch vụ cho trình điều khiển đồ họa, nhiều dịch vụ
chúng được điều khiển bởi các giao diện ứng dụng mà nó cung cấp thông qua libdrm,
thư viện bao bọc hầu hết các ioctls DRM. Chúng bao gồm vblank
xử lý sự kiện, quản lý bộ nhớ, quản lý đầu ra, bộ đệm khung
quản lý, gửi lệnh và đấu kiếm, tạm dừng/tiếp tục hỗ trợ và
Dịch vụ DMA.

Khởi tạo trình điều khiển
=========================

Cốt lõi của mọi trình điều khiển DRM là cấu trúc ZZ0000ZZ. Trình điều khiển thường khởi tạo tĩnh
cấu trúc drm_driver, sau đó chuyển nó tới
drm_dev_alloc() để phân bổ phiên bản thiết bị. Sau khi
phiên bản thiết bị được khởi tạo đầy đủ, nó có thể được đăng ký (điều này làm cho
nó có thể truy cập được từ không gian người dùng) bằng cách sử dụng drm_dev_register().

Cấu trúc ZZ0000ZZ
chứa thông tin tĩnh mô tả trình điều khiển và các tính năng của nó
hỗ trợ và trỏ tới các phương thức mà lõi DRM sẽ gọi tới
triển khai DRM API. Trước tiên chúng ta sẽ đi qua các trường thông tin tĩnh ZZ0001ZZ và sẽ
sau đó mô tả chi tiết các thao tác riêng lẻ khi chúng được sử dụng sau này
phần.

Thông tin tài xế
------------------

Cấp chính, cấp phụ và cấp bản vá
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

int chính; int thứ; int patchlevel;
Lõi DRM xác định các phiên bản trình điều khiển theo phiên bản chính, phụ và bản vá
cấp ba. Thông tin được in vào nhật ký kernel tại
thời gian khởi tạo và được chuyển đến không gian người dùng thông qua
DRM_IOCTL_VERSION ioctl.

Các số chính và số phụ cũng được sử dụng để xác minh trình điều khiển được yêu cầu
Phiên bản API được chuyển sang DRM_IOCTL_SET_VERSION. Khi trình điều khiển API
thay đổi giữa các phiên bản nhỏ, ứng dụng có thể gọi
DRM_IOCTL_SET_VERSION để chọn phiên bản cụ thể của API. Nếu
chuyên ngành được yêu cầu không bằng chuyên ngành lái xe hoặc chuyên ngành phụ được yêu cầu
lớn hơn trình điều khiển phụ, lệnh gọi DRM_IOCTL_SET_VERSION sẽ
trả về một lỗi. Nếu không thì phương thức set_version() của trình điều khiển sẽ là
được gọi với phiên bản được yêu cầu.

Tên và mô tả
~~~~~~~~~~~~~~~~~~~~

char \*name; char \*desc; char \*ngày;
Tên trình điều khiển được in vào nhật ký kernel tại thời điểm khởi tạo,
được sử dụng để đăng ký IRQ và được chuyển đến không gian người dùng thông qua
DRM_IOCTL_VERSION.

Mô tả trình điều khiển là một chuỗi thông tin thuần túy được chuyển tới
không gian người dùng thông qua DRM_IOCTL_VERSION ioctl và không được sử dụng bởi
hạt nhân.

Khởi tạo mô-đun
---------------------

.. kernel-doc:: include/drm/drm_module.h
   :doc: overview

Xử lý phiên bản thiết bị và trình điều khiển
--------------------------------------------

.. kernel-doc:: drivers/gpu/drm/drm_drv.c
   :doc: driver instance overview

.. kernel-doc:: include/drm/drm_device.h
   :internal:

.. kernel-doc:: include/drm/drm_drv.h
   :internal:

.. kernel-doc:: drivers/gpu/drm/drm_drv.c
   :export:

Tải trình điều khiển
--------------------

Cách sử dụng trình trợ giúp thành phần
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. kernel-doc:: drivers/gpu/drm/drm_drv.c
   :doc: component helper usage recommendations

Khởi tạo trình quản lý bộ nhớ
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Mọi trình điều khiển DRM đều yêu cầu trình quản lý bộ nhớ phải được khởi tạo tại
thời gian tải. DRM hiện có hai trình quản lý bộ nhớ, Bản dịch
Trình quản lý bảng (TTM) và Trình quản lý thực thi đồ họa (GEM). Cái này
tài liệu mô tả việc sử dụng chỉ trình quản lý bộ nhớ GEM. Nhìn thấy ? cho
chi tiết.

Cấu hình thiết bị khác
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Một tác vụ khác có thể cần thiết cho các thiết bị PCI trong quá trình cấu hình
đang ánh xạ video BIOS. Trên nhiều thiết bị, VBIOS mô tả thiết bị
cấu hình, thời gian của bảng LCD (nếu có) và chứa các cờ cho biết
trạng thái thiết bị. Việc ánh xạ BIOS có thể được thực hiện bằng pci_map_rom()
gọi, một chức năng tiện lợi đảm nhiệm việc ánh xạ ROM thực tế,
liệu nó có bị ẩn vào bộ nhớ hay không (thường ở địa chỉ 0xc0000)
hoặc tồn tại trên thiết bị PCI trong ROM BAR. Lưu ý rằng sau khi ROM có
đã được lập bản đồ và mọi thông tin cần thiết đã được trích xuất, nó sẽ
không được lập bản đồ; trên nhiều thiết bị, bộ giải mã địa chỉ ROM được chia sẻ với
các BAR khác, do đó, việc để nó được ánh xạ có thể gây ra hành vi không mong muốn như
bị treo hoặc hỏng bộ nhớ.

Tài nguyên được quản lý
-----------------------

.. kernel-doc:: drivers/gpu/drm/drm_managed.c
   :doc: managed resources

.. kernel-doc:: drivers/gpu/drm/drm_managed.c
   :export:

.. kernel-doc:: include/drm/drm_managed.h
   :internal:

Mở/Đóng, thao tác tệp và IOCTL
======================================

.. _drm_driver_fops:

Hoạt động tập tin
-----------------

.. kernel-doc:: drivers/gpu/drm/drm_file.c
   :doc: file operations

.. kernel-doc:: include/drm/drm_file.h
   :internal:

.. kernel-doc:: drivers/gpu/drm/drm_file.c
   :export:

Tiện ích khác
==============

Máy in
-------

.. kernel-doc:: include/drm/drm_print.h
   :doc: print

.. kernel-doc:: include/drm/drm_print.h
   :internal:

.. kernel-doc:: drivers/gpu/drm/drm_print.c
   :export:

Tiện ích
---------

.. kernel-doc:: include/drm/drm_util.h
   :doc: drm utils

.. kernel-doc:: include/drm/drm_util.h
   :internal:


Kiểm tra đơn vị
===============

KUđơn vị
--------

KUnit (Khung kiểm thử đơn vị hạt nhân) cung cấp một khung chung cho các thử nghiệm đơn vị
bên trong nhân Linux.

Phần này bao gồm các chi tiết cụ thể cho hệ thống con DRM. Để biết thông tin chung
về KUnit, vui lòng tham khảo Tài liệu/dev-tools/kunit/start.rst.

Làm thế nào để chạy thử nghiệm?
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Để thuận tiện cho việc chạy bộ thử nghiệm, có một tệp cấu hình
trong ZZ0000ZZ. Nó có thể được sử dụng bởi ZZ0001ZZ như
sau:

.. code-block:: bash

	$ ./tools/testing/kunit/kunit.py run --kunitconfig=drivers/gpu/drm/tests \
		--kconfig_add CONFIG_VIRTIO_UML=y \
		--kconfig_add CONFIG_UML_PCI_OVER_VIRTIO=y

.. note::
	The configuration included in ``.kunitconfig`` should be as generic as
	possible.
	``CONFIG_VIRTIO_UML`` and ``CONFIG_UML_PCI_OVER_VIRTIO`` are not
	included in it because they are only required for User Mode Linux.

Quy tắc bảo hiểm KUnit
~~~~~~~~~~~~~~~~~~~~~~

Hỗ trợ KUnit dần dần được thêm vào khung và trình trợ giúp DRM. không có
yêu cầu chung đối với khung và người trợ giúp phải có các bài kiểm tra KUnit tại
khoảnh khắc. Tuy nhiên, các bản vá đang ảnh hưởng đến một chức năng hoặc trình trợ giúp đã
được bao phủ bởi các bài kiểm tra KUnit phải cung cấp các bài kiểm tra nếu thay đổi yêu cầu một bài kiểm tra.

Mã hỗ trợ kế thừa
===================

Phần này trình bày rất ngắn gọn một số mã hỗ trợ cũ
chỉ được sử dụng bởi trình điều khiển DRM cũ đã thực hiện cái gọi là
gắn bóng vào thiết bị cơ bản thay vì đăng ký dưới dạng thực
người lái xe. Điều này cũng bao gồm một số quản lý bộ đệm chung cũ và
mã gửi lệnh. Không sử dụng bất kỳ thứ gì trong số này trong các thiết bị mới và hiện đại
trình điều khiển.

Tạm dừng/Tiếp tục kế thừa
-------------------------

Lõi DRM cung cấp một số mã tạm dừng/tiếp tục, nhưng trình điều khiển muốn có đầy đủ
hỗ trợ tạm dừng/tiếp tục phải cung cấp các hàm save() và recovery().
Chúng được gọi vào thời điểm tạm dừng, ngủ đông hoặc tiếp tục và nên
thực hiện bất kỳ lưu hoặc khôi phục trạng thái nào theo yêu cầu của thiết bị của bạn trong quá trình tạm dừng
hoặc trạng thái ngủ đông.

int (trạng thái \ZZ0001ZZ, pm_message_t); int
(\ZZ0002ZZ);
Đó là các phương thức tạm dừng và tiếp tục cũ mà ZZ0003ZZ hoạt động với
chức năng đăng ký trình điều khiển gắn bóng kế thừa. Lái xe mới nên
sử dụng giao diện quản lý năng lượng được cung cấp bởi loại xe buýt của họ (thường là
thông qua ZZ0000ZZ
dev_pm_ops) và đặt các phương thức này thành NULL.

Dịch vụ DMA kế thừa
-------------------

Điều này sẽ bao gồm cách ánh xạ DMA, v.v. được hỗ trợ bởi lõi. Những cái này
các chức năng không được dùng nữa và không nên được sử dụng.
