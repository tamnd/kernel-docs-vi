.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/arch/s390/vfio-ap-locking.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

========================
Tổng quan về khóa AP VFIO
======================
Tài liệu này mô tả các khóa thích hợp cho hoạt động an toàn
của trình điều khiển thiết bị vfio_ap. Trong suốt tài liệu này, các biến sau
sẽ được sử dụng để biểu thị các trường hợp của cấu trúc được mô tả ở đây:

.. code-block:: c

  struct ap_matrix_dev *matrix_dev;
  struct ap_matrix_mdev *matrix_mdev;
  struct kvm *kvm;

Khóa thiết bị ma trận (drivers/s390/crypto/vfio_ap_private.h)
---------------------------------------------------------------

.. code-block:: c

  struct ap_matrix_dev {
  	...
  	struct list_head mdev_list;
  	struct mutex mdevs_lock;
  	...
  }

Khóa thiết bị ma trận (matrix_dev->mdevs_lock) được triển khai dưới dạng toàn cầu
mutex chứa trong đối tượng duy nhất của struct ap_matrix_dev. Ổ khóa này
kiểm soát quyền truy cập vào tất cả các trường có trong mỗi ma trận_mdev
(ma trận_dev->mdev_list). Khóa này phải được giữ trong khi đọc từ, ghi vào
hoặc sử dụng dữ liệu từ một trường có trong phiên bản Matrix_mdev
đại diện cho một trong các thiết bị trung gian của trình điều khiển thiết bị vfio_ap.

Khóa KVM (bao gồm/linux/kvm_host.h)
---------------------------------------

.. code-block:: c

  struct kvm {
  	...
  	struct mutex lock;
  	...
  }

Khóa KVM (kvm->lock) kiểm soát quyền truy cập vào dữ liệu trạng thái cho khách KVM. Cái này
khóa phải được giữ bởi trình điều khiển thiết bị vfio_ap trong khi một hoặc nhiều bộ điều hợp AP,
tên miền hoặc tên miền kiểm soát đang được cắm vào hoặc rút ra khỏi máy khách.

Con trỏ KVM được lưu trữ trong phiên bản Matrix_mdev
(matrix_mdev->kvm = kvm) chứa trạng thái của thiết bị trung gian có
đã được gắn vào máy khách KVM.

Khóa khách (drivers/s390/crypto/vfio_ap_private.h)
-----------------------------------------------------------

.. code-block:: c

  struct ap_matrix_dev {
  	...
  	struct list_head mdev_list;
  	struct mutex guests_lock;
  	...
  }

Khóa khách (matrix_dev->guests_lock) kiểm soát quyền truy cập vào
phiên bản Matrix_mdev (matrix_dev->mdev_list) đại diện cho các thiết bị trung gian
giữ trạng thái cho các thiết bị trung gian đã được gắn vào một
Khách KVM. Khóa này phải được giữ:

1. Để kiểm soát quyền truy cập vào con trỏ KVM (matrix_mdev->kvm) trong khi vfio_ap
   trình điều khiển thiết bị đang sử dụng nó để cắm/rút phích cắm các thiết bị AP được truyền tới KVM
   khách.

2. Để thêm hoặc xóa các phiên bản Matrix_mdev khỏi Matrix_dev->mdev_list.
   Điều này là cần thiết để đảm bảo thứ tự khóa thích hợp khi danh sách được đọc
   để tìm một phiên bản ap_matrix_mdev nhằm mục đích cắm/rút phích cắm
   Các thiết bị AP được chuyển tới máy khách KVM.

Ví dụ: khi một thiết bị xếp hàng bị xóa khỏi trình điều khiển thiết bị vfio_ap,
   nếu bộ chuyển đổi được chuyển qua máy khách KVM, nó sẽ phải được
   đã rút phích cắm. Để tìm hiểu xem bộ chuyển đổi có được chuyển qua hay không,
   đối tượng Matrix_mdev mà hàng đợi được gán sẽ phải là
   được tìm thấy. Con trỏ KVM (matrix_mdev->kvm) sau đó có thể được sử dụng để xác định xem
   thiết bị trung gian được chuyển qua (matrix_mdev->kvm != NULL) và nếu vậy,
   để rút phích cắm bộ chuyển đổi.

Không cần thiết phải sử dụng Khóa khách để truy cập con trỏ KVM nếu
con trỏ không được sử dụng để cắm/rút phích cắm các thiết bị được truyền tới máy khách KVM;
tuy nhiên, trong trường hợp này, Khóa thiết bị ma trận (matrix_dev->mdevs_lock) phải được
được giữ để truy cập con trỏ KVM vì nó được đặt và xóa theo
bảo vệ Khóa thiết bị ma trận. Một trường hợp điển hình là hàm
xử lý việc chặn chức năng phụ lệnh PQAP(AQIC). Trình xử lý này
chỉ cần truy cập con trỏ KVM cho mục đích cài đặt hoặc xóa IRQ
tài nguyên, vì vậy chỉ cần giữ Matrix_dev->mdevs_lock.

Khóa móc PQAP (arch/s390/include/asm/kvm_host.h)
-----------------------------------------------------

.. code-block:: c

  typedef int (*crypto_hook)(struct kvm_vcpu *vcpu);

  struct kvm_s390_crypto {
  	...
  	struct rw_semaphore pqap_hook_rwsem;
  	crypto_hook *pqap_hook;
  	...
  };

Khóa móc PQAP là một semaphore r/w kiểm soát quyền truy cập vào chức năng
con trỏ của trình xử lý ZZ0000ZZ để gọi khi
Chức năng phụ lệnh PQAP(AQIC) bị máy chủ chặn. Ổ khóa phải được
được giữ ở chế độ ghi khi giá trị pqap_hook được đặt và ở chế độ đọc khi
hàm pqap_hook được gọi.