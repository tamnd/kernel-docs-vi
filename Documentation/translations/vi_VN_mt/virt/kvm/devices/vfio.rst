.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/virt/kvm/devices/vfio.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=====================
Thiết bị ảo VFIO
=====================

Các loại thiết bị được hỗ trợ:

-KVM_DEV_TYPE_VFIO

Chỉ có thể tạo một phiên bản VFIO cho mỗi VM.  Thiết bị đã tạo
theo dõi các tệp VFIO (nhóm hoặc thiết bị) được VM sử dụng và các tính năng
của những nhóm/thiết bị quan trọng đối với tính chính xác và khả năng tăng tốc
của VM.  Khi các nhóm/thiết bị được bật và tắt để người dùng sử dụng
VM, KVM cần được cập nhật về sự hiện diện của chúng.  Khi đăng ký với
KVM, tham chiếu đến tệp VFIO được giữ bởi KVM.

Nhóm:
  KVM_DEV_VFIO_FILE
	bí danh: KVM_DEV_VFIO_GROUP

Thuộc tính KVM_DEV_VFIO_FILE:
  KVM_DEV_VFIO_FILE_ADD: Thêm tệp VFIO (nhóm/thiết bị) vào thiết bị VFIO-KVM
	theo dõi

kvm_device_attr.addr trỏ đến bộ mô tả tệp int32_t cho
	Tệp VFIO.

KVM_DEV_VFIO_FILE_DEL: Xóa tệp VFIO (nhóm/thiết bị) khỏi VFIO-KVM
	theo dõi thiết bị

kvm_device_attr.addr trỏ đến bộ mô tả tệp int32_t cho
	Tệp VFIO.

KVM_DEV_VFIO_GROUP (nhóm thiết bị kvm cũ bị hạn chế xử lý nhóm VFIO fd):
  KVM_DEV_VFIO_GROUP_ADD: giống như KVM_DEV_VFIO_FILE_ADD chỉ dành cho nhóm fd

KVM_DEV_VFIO_GROUP_DEL: giống như KVM_DEV_VFIO_FILE_DEL chỉ dành cho nhóm fd

KVM_DEV_VFIO_GROUP_SET_SPAPR_TCE: đính kèm bảng TCE hiển thị cho khách
	được phân bổ bởi sPAPR KVM.
	kvm_device_attr.addr trỏ tới một cấu trúc::

cấu trúc kvm_vfio_spapr_tce {
			__s32 nhómfd;
			__s32 bảngfd;
		};

Ở đâu:

- @groupfd là bộ mô tả tệp cho nhóm VFIO;
	- @tablefd là bộ mô tả tệp cho bảng TCE được phân bổ thông qua
	  KVM_CREATE_SPAPR_TCE.

Hoạt động FILE/GROUP_ADD ở trên phải được gọi trước khi truy cập
mô tả tập tin thiết bị thông qua VFIO_GROUP_GET_DEVICE_FD để hỗ trợ
trình điều khiển yêu cầu đặt con trỏ kvm trong .open_device() của chúng
gọi lại.  Điều này cũng tương tự đối với bộ mô tả tệp thiết bị thông qua thiết bị ký tự
open để có quyền truy cập thiết bị qua VFIO_DEVICE_BIND_IOMMUFD.  Đối với tập tin như vậy
bộ mô tả, FILE_ADD nên được gọi trước VFIO_DEVICE_BIND_IOMMUFD
để hỗ trợ các trình điều khiển được đề cập trong câu trước.