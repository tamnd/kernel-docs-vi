.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/PCI/pci-iov-howto.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

.. include:: <isonum.txt>

========================================
Cách ảo hóa I/O Express PCI
====================================

:Bản quyền: ZZ0000ZZ 2009 Tập đoàn Intel
:Tác giả: - Yu Zhao <yu.zhao@intel.com>
          - Donald Dutile <ddutile@redhat.com>

Tổng quan
========

SR-IOV là gì
--------------

Ảo hóa I/O gốc đơn (SR-IOV) là PCI Express Extended
khả năng làm cho một thiết bị vật lý xuất hiện dưới dạng nhiều thiết bị ảo
thiết bị. Thiết bị vật lý được gọi là Chức năng vật lý (PF)
trong khi các thiết bị ảo được gọi là Chức năng ảo (VF).
Việc phân bổ VF có thể được điều khiển linh hoạt bởi PF thông qua
các thanh ghi được gói gọn trong khả năng. Theo mặc định, tính năng này được
không được kích hoạt và PF hoạt động như thiết bị PCIe truyền thống. Một khi nó
được bật, không gian cấu hình PCI của mỗi VF có thể được truy cập bằng chính nó
Số Bus, thiết bị và chức năng (ID định tuyến). Và mỗi VF cũng có PCI
Không gian bộ nhớ, được sử dụng để ánh xạ bộ thanh ghi của nó. Trình điều khiển thiết bị VF
hoạt động trên bộ thanh ghi để nó có thể hoạt động và xuất hiện dưới dạng
thiết bị PCI thực sự hiện có.

Hướng dẫn sử dụng
==========

Làm cách nào tôi có thể kích hoạt khả năng SR-IOV
----------------------------------

Có nhiều phương pháp để kích hoạt SR-IOV.
Trong phương pháp đầu tiên, trình điều khiển thiết bị (trình điều khiển PF) sẽ điều khiển
bật và tắt khả năng thông qua API do lõi SR-IOV cung cấp.
Nếu phần cứng có khả năng SR-IOV, việc tải trình điều khiển PF của nó sẽ
kích hoạt nó và tất cả các VF được liên kết với PF.  Một số trình điều khiển PF yêu cầu
một tham số mô-đun được đặt để xác định số lượng VF sẽ kích hoạt.
Trong phương pháp thứ hai, việc ghi vào tệp sysfs sriov_numvfs sẽ
bật và tắt các VF được liên kết với PCIe PF.  Phương pháp này
kích hoạt các giá trị kích hoạt/vô hiệu hóa trên mỗi PF, VF so với phương thức đầu tiên,
áp dụng cho tất cả PF của cùng một thiết bị.  Ngoài ra,
Hỗ trợ lõi PCI SRIOV đảm bảo rằng các hoạt động bật/tắt được thực hiện
hợp lệ để giảm sự trùng lặp trong nhiều trình điều khiển cho cùng một
kiểm tra, ví dụ: kiểm tra numvfs == 0 nếu bật VF, đảm bảo
numvfs <= tổngvfs.
Phương pháp thứ hai là phương pháp được đề xuất cho các thiết bị VF mới/tương lai.

Làm cách nào tôi có thể sử dụng Chức năng ảo
-----------------------------------

VF được coi như thiết bị PCI được cắm nóng trong kernel, vì vậy chúng
có thể hoạt động giống như các thiết bị PCI thực. VF
yêu cầu trình điều khiển thiết bị giống như thiết bị PCI bình thường.

Hướng dẫn dành cho nhà phát triển
===============

SR-IOV API
----------

Để bật khả năng SR-IOV:

(a) Đối với phương pháp đầu tiên, trong trình điều khiển::

int pci_enable_sriov(struct pci_dev *dev, int nr_virtfn);

'nr_virtfn' là số lượng VF được kích hoạt.

(b) Đối với phương pháp thứ hai, từ sysfs::

echo 'nr_virtfn' > \
        /sys/bus/pci/devices/<DOMAIN:BUS:DEVICE.FUNCTION>/sriov_numvfs

Để tắt khả năng SR-IOV:

(a) Đối với phương pháp đầu tiên, trong trình điều khiển::

void pci_disable_sriov(struct pci_dev *dev);

(b) Đối với phương pháp thứ hai, từ sysfs::

tiếng vang 0 > \
        /sys/bus/pci/devices/<DOMAIN:BUS:DEVICE.FUNCTION>/sriov_numvfs

Để bật tự động thăm dò VF bằng trình điều khiển tương thích trên máy chủ, hãy chạy
lệnh bên dưới trước khi bật các tính năng SR-IOV. Đây là
hành vi mặc định.
::

tiếng vang 1 > \
        /sys/bus/pci/devices/<DOMAIN:BUS:DEVICE.FUNCTION>/sriov_drivers_autoprobe

Để tắt tính năng tự động thăm dò VF bằng trình điều khiển tương thích trên máy chủ, hãy chạy
lệnh bên dưới trước khi bật các tính năng SR-IOV. Đang cập nhật cái này
mục nhập sẽ không ảnh hưởng đến VF đã được thăm dò.
::

tiếng vang 0 > \
        /sys/bus/pci/devices/<DOMAIN:BUS:DEVICE.FUNCTION>/sriov_drivers_autoprobe

Ví dụ sử dụng
-------------

Đoạn mã sau minh họa cách sử dụng SR-IOV API.
::

int tĩnh dev_probe(struct pci_dev *dev, const struct pci_device_id *id)
	{
		pci_enable_sriov(dev, NR_VIRTFN);

		...

trả về 0;
	}

static void dev_remove(struct pci_dev *dev)
	{
		pci_disable_sriov(dev);

		...
	}

int tĩnh dev_suspend(thiết bị cấu trúc *dev)
	{
		...

trả về 0;
	}

int tĩnh dev_resume(thiết bị cấu trúc *dev)
	{
		...

trả về 0;
	}

static void dev_shutdown(struct pci_dev *dev)
	{
		...
	}

int tĩnh dev_sriov_configure(struct pci_dev *dev, int numvfs)
	{
		nếu (numvfs > 0) {
			...
pci_enable_sriov(dev, numvfs);
			...
trả về numvfs;
		}
		nếu (numvfs == 0) {
			....
pci_disable_sriov(dev);
			...
trả về 0;
		}
	}

cấu trúc tĩnh pci_driver dev_driver = {
		.name = "Trình điều khiển chức năng vật lý SR-IOV",
		.id_table = dev_id_table,
		.probe = dev_probe,
		.remove = dev_remove,
		.driver.pm = &dev_pm_ops,
		.shutdown = dev_shutdown,
		.sriov_configure = dev_sriov_configure,
	};