.. SPDX-License-Identifier: GPL-2.0-only

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/driver-api/vfio-mediated-device.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. include:: <isonum.txt>

========================
Thiết bị trung gian VFIO
========================

:Bản quyền: ZZ0000ZZ 2016, NVIDIA CORPORATION. Mọi quyền được bảo lưu.
:Tác giả: Neo Jia <cjia@nvidia.com>
:Tác giả: Kirti Wankhede <kwankhede@nvidia.com>



Các thiết bị trung gian I/O chức năng ảo (VFIO)[1]
===============================================

Số trường hợp sử dụng để ảo hóa các thiết bị DMA không được tích hợp sẵn
Khả năng của SR_IOV ngày càng tăng. Trước đây, để ảo hóa các thiết bị như vậy,
các nhà phát triển phải tạo giao diện quản lý và API của riêng họ, sau đó
tích hợp chúng với phần mềm không gian người dùng. Để đơn giản hóa việc tích hợp với không gian người dùng
phần mềm, chúng tôi đã xác định được những yêu cầu chung và một cơ chế quản lý thống nhất
giao diện cho các thiết bị như vậy.

Khung trình điều khiển VFIO cung cấp các API hợp nhất để truy cập trực tiếp vào thiết bị. Đó là
khung IOMMU/bất khả tri của thiết bị để hiển thị quyền truy cập thiết bị trực tiếp cho người dùng
không gian trong môi trường an toàn, được bảo vệ bởi IOMMU. Khung này được sử dụng cho
nhiều thiết bị, chẳng hạn như GPU, bộ điều hợp mạng và bộ tăng tốc tính toán. Với
truy cập trực tiếp vào thiết bị, máy ảo hoặc ứng dụng không gian người dùng có quyền truy cập trực tiếp
truy cập vào thiết bị vật lý. Khung này được tái sử dụng cho các thiết bị qua trung gian.

Trình điều khiển lõi trung gian cung cấp giao diện chung cho thiết bị trung gian
quản lý có thể được sử dụng bởi trình điều khiển của các thiết bị khác nhau. mô-đun này
cung cấp một giao diện chung để thực hiện các hoạt động này:

* Tạo và phá hủy một thiết bị trung gian
* Thêm thiết bị trung gian vào và xóa thiết bị đó khỏi trình điều khiển xe buýt trung gian
* Thêm thiết bị trung gian vào và xóa thiết bị đó khỏi nhóm IOMMU

Trình điều khiển lõi trung gian cũng cung cấp giao diện để đăng ký trình điều khiển xe buýt.
Ví dụ: trình điều khiển mdev VFIO qua trung gian được thiết kế cho các thiết bị được trung gian và
hỗ trợ API VFIO. Trình điều khiển bus trung gian thêm một thiết bị trung gian vào và
xóa nó khỏi nhóm VFIO.

Sơ đồ khối cấp cao sau đây thể hiện các thành phần và giao diện chính
trong khung trình điều khiển qua trung gian VFIO. Sơ đồ hiển thị NVIDIA, Intel và IBM
thiết bị làm ví dụ, vì các thiết bị này là thiết bị đầu tiên sử dụng mô-đun này::

+--------------+
     ZZ0000ZZ
     ZZ0001ZZ mdev_register_driver() +--------------+
     ZZ0002ZZ ZZ0003ZZ
     ZZ0004ZZ mdev ZZ0005ZZ ZZ0006ZZ
     Xe buýt ZZ0007ZZ ZZ0008ZZ<-> Người dùng VFIO
     Trình điều khiển ZZ0009ZZ Đầu dò ZZ0010ZZ()/remove() API ZZ0011ZZ
     ZZ0012ZZ ZZ0013ZZ +--------------+
     ZZ0014ZZ
     ZZ0015ZZ
     ZZ0016ZZ
     ZZ0017ZZ
     ZZ0018ZZ
     ZZ0019ZZ mdev_register_parent() +--------------+
     ZZ0020ZZ ZZ0021ZZ
     ZZ0022ZZ ZZ0023ZZ ZZ0024ZZ<-> vật lý
     Thiết bị ZZ0025ZZ ZZ0026ZZ
     ZZ0027ZZ ZZ0028ZZ gọi lại +--------------+
     ZZ0029ZZ Vật lý ZZ0030ZZ
     Thiết bị ZZ0031ZZ ZZ0032ZZ mdev_register_parent() +--------------+
     Giao diện ZZ0033ZZ ZZ0034ZZ<-----------+ |
     ZZ0035ZZ ZZ0036ZZ ZZ0037ZZ<-> vật lý
     Thiết bị ZZ0038ZZ ZZ0039ZZ
     ZZ0040ZZ ZZ0041ZZ gọi lại +--------------+
     ZZ0042ZZ
     +--------------+


Giao diện đăng ký
=======================

Trình điều khiển lõi trung gian cung cấp các loại đăng ký sau
giao diện:

* Giao diện đăng ký tài xế xe buýt qua trung gian
* Giao diện trình điều khiển thiết bị vật lý

Giao diện đăng ký cho trình điều khiển xe buýt qua trung gian
------------------------------------------------

Giao diện đăng ký cho trình điều khiển thiết bị qua trung gian cung cấp các thông tin sau
cấu trúc đại diện cho trình điều khiển của thiết bị được trung gian::

/*
      * struct mdev_driver [2] - Driver của thiết bị đã qua trung gian
      * @probe: được gọi khi thiết bị mới được tạo
      * @remove: được gọi khi gỡ bỏ thiết bị
      * @driver: cấu trúc driver thiết bị
      */
     cấu trúc mdev_driver {
	     int (*probe)  (struct mdev_device *dev);
	     khoảng trống (*remove) (struct mdev_device *dev);
	     int không dấu (*get_available)(struct mdev_type *mtype);
	     ssize_t (*show_description)(struct mdev_type *mtype, char *buf);
	     trình điều khiển struct device_driver;
     };

Trình điều khiển bus trung gian cho mdev nên sử dụng cấu trúc này trong các lệnh gọi hàm
để đăng ký và hủy đăng ký với trình điều khiển cốt lõi:

* Đăng ký::

int mdev_register_driver(struct mdev_driver *drv);

* Hủy đăng ký::

void mdev_unregister_driver(struct mdev_driver *drv);

Chức năng thăm dò của trình điều khiển xe buýt được trung gian sẽ tạo một vfio_device ở trên
mdev_device và kết nối nó với cách triển khai thích hợp của
vfio_device_ops.

Khi trình điều khiển muốn thêm hệ thống tạo GUID vào thiết bị hiện có, nó có
thăm dò thì nó sẽ gọi ::

int mdev_register_parent(struct mdev_parent *parent, struct device *dev,
			cấu trúc mdev_driver *mdev_driver);

Điều này sẽ cung cấp các tệp 'mdev_supported_types/XX/create' mà sau đó có thể được
được sử dụng để kích hoạt việc tạo mdev_device. Mdev_device được tạo sẽ là
gắn liền với trình điều khiển được chỉ định.

Khi trình điều khiển cần tự xóa nó sẽ gọi ::

void mdev_unregister_parent(struct mdev_parent *parent);

Việc này sẽ hủy liên kết và hủy tất cả các mdev đã tạo và xóa các tệp sysfs.

Giao diện quản lý thiết bị qua trung gian thông qua sysfs
==================================================

Giao diện quản lý thông qua sysfs cho phép phần mềm không gian người dùng, chẳng hạn như
libvirt, để truy vấn và định cấu hình các thiết bị trung gian theo kiểu bất khả tri về phần cứng.
Giao diện quản lý này cung cấp tính linh hoạt cho cơ sở vật lý cơ bản
trình điều khiển của thiết bị để hỗ trợ các tính năng như:

* Cắm nóng thiết bị qua trung gian
* Nhiều thiết bị trung gian trong một máy ảo
* Nhiều thiết bị trung gian từ các thiết bị vật lý khác nhau

Các liên kết trong Thư mục lớp mdev_bus
-------------------------------------
Thư mục /sys/class/mdev_bus/ chứa các liên kết đến các thiết bị đã được đăng ký
với trình điều khiển lõi mdev.

Các thư mục và tệp trong sysfs cho từng thiết bị vật lý
--------------------------------------------------------------

::

|- [thiết bị vật lý gốc]
  |--- Thuộc tính dành riêng cho nhà cung cấp [tùy chọn]
  |--- [mdev_supported_types]
  ZZ0000ZZ--- [<type-id>]
  ZZ0001ZZ |--- tạo
  ZZ0002ZZ |--- tên
  ZZ0003ZZ |--- có sẵn_instances
  ZZ0004ZZ |--- thiết bị_api
  ZZ0005ZZ |--- mô tả
  ZZ0006ZZ |--- [thiết bị]
  ZZ0007ZZ--- [<type-id>]
  ZZ0008ZZ |--- tạo
  ZZ0009ZZ |--- tên
  ZZ0010ZZ |--- có sẵn_instances
  ZZ0011ZZ |--- thiết bị_api
  ZZ0012ZZ |--- mô tả
  ZZ0013ZZ |--- [thiết bị]
  ZZ0014ZZ--- [<type-id>]
  ZZ0015ZZ--- tạo
  ZZ0016ZZ--- tên
  ZZ0017ZZ--- có sẵn_instances
  ZZ0018ZZ--- thiết bị_api
  ZZ0019ZZ--- mô tả
  ZZ0020ZZ--- [thiết bị]

* [mdev_supported_types]

Danh sách các loại thiết bị được dàn xếp hiện được hỗ trợ và thông tin chi tiết về chúng.

[<type-id>], device_api và available_instances là các thuộc tính bắt buộc
  điều đó cần được cung cấp bởi trình điều khiển nhà cung cấp.

* [<loại-id>]

Tên [<type-id>] được tạo bằng cách thêm chuỗi trình điều khiển thiết bị làm tiền tố
  vào chuỗi được cung cấp bởi trình điều khiển của nhà cung cấp. Định dạng của tên này là như
  sau::

sprintf(buf, "%s-%s", dev_driver_string(parent->dev), nhóm->name);

* thiết bị_api

Thuộc tính này hiển thị thiết bị API nào đang được tạo, ví dụ:
  "vfio-pci" cho thiết bị PCI.

* có sẵn_phiên bản

Thuộc tính này hiển thị số lượng thiết bị thuộc loại <type-id> có thể
  được tạo ra.

* [thiết bị]

Thư mục này chứa các liên kết đến các thiết bị thuộc loại <type-id> đã được
  được tạo ra.

* tên

Thuộc tính này hiển thị tên mà con người có thể đọc được.

* Sự miêu tả

Thuộc tính này có thể hiển thị các tính năng/mô tả ngắn gọn về loại. Đây là một
  thuộc tính tùy chọn.

Thư mục và tập tin trong sysfs cho mỗi thiết bị mdev
----------------------------------------------------------

::

|- [thiết bị phy gốc]
  |--- [$MDEV_UUID]
         |--- xóa
         |--- mdev_type {liên kết đến loại của nó}
         |--- thuộc tính dành riêng cho nhà cung cấp [tùy chọn]

* xóa (chỉ viết)

Việc ghi '1' vào tệp 'xóa' sẽ phá hủy thiết bị mdev. Trình điều khiển của nhà cung cấp có thể
không thực hiện được lệnh gọi lại Remove() nếu thiết bị đó đang hoạt động và trình điều khiển của nhà cung cấp
không hỗ trợ rút phích cắm nóng.

Ví dụ::

# echo 1 > /sys/bus/mdev/devices/$mdev_UUID/remove

Thiết bị trung gian Phích cắm nóng
------------------------

Các thiết bị trung gian có thể được tạo và chỉ định trong thời gian chạy. Quy trình làm nóng
cắm thiết bị trung gian cũng giống như quy trình cắm nóng thiết bị PCI.

API dịch cho thiết bị trung gian
=====================================

Các API sau được cung cấp để dịch pfn của người dùng sang pfn lưu trữ trong VFIO
tài xế::

int vfio_pin_pages(struct vfio_device *device, dma_addr_t iova,
				  int npage, int prot, struct trang **trang);

void vfio_unpin_pages(struct vfio_device *device, dma_addr_t iova,
				    int npage);

Các hàm này gọi lại mô-đun IOMMU phía sau bằng cách sử dụng pin_pages
và các lệnh gọi lại unpin_pages của struct vfio_iommu_driver_ops[4]. Hiện tại
những lệnh gọi lại này được hỗ trợ trong mô-đun TYPE1 IOMMU. Để kích hoạt chúng cho
các mô-đun phụ trợ IOMMU khác, chẳng hạn như mô-đun PPC64 sPAPR, chúng cần cung cấp
hai hàm gọi lại này.

Tài liệu tham khảo
==========

1. Xem Tài liệu/driver-api/vfio.rst để biết thêm thông tin về VFIO.
2. struct mdev_driver trong include/linux/mdev.h
3. struct mdev_parent_ops trong include/linux/mdev.h
4. struct vfio_iommu_driver_ops trong include/linux/vfio.h