.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/virt/kvm/devices/vm.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

======================
Giao diện vm chung
====================

"Thiết bị" máy ảo cũng chấp nhận ioctls KVM_SET_DEVICE_ATTR,
KVM_GET_DEVICE_ATTR và KVM_HAS_DEVICE_ATTR. Giao diện sử dụng tương tự
struct kvm_device_attr như các thiết bị khác, nhưng nhắm mục tiêu cài đặt trên toàn VM
và điều khiển.

Các nhóm và thuộc tính của mỗi máy ảo, nếu có, là kiến trúc
cụ thể.

1. GROUP: KVM_S390_VM_MEM_CTRL
==============================

:Kiến trúc: s390

1.1. ATTRIBUTE: KVM_S390_VM_MEM_ENABLE_CMMA
-------------------------------------------

:Thông số: không có
:Trả về: -EBUSY nếu vcpu đã được xác định, nếu không thì 0

Bật Hỗ trợ quản lý bộ nhớ cộng tác (CMMA) cho máy ảo.

1.2. ATTRIBUTE: KVM_S390_VM_MEM_CLR_CMMA
----------------------------------------

:Thông số: không có
:Trả về: -EINVAL nếu CMMA không được bật;
	  0 nếu không

Xóa trạng thái CMMA cho tất cả các trang khách, để bất kỳ trang nào khách đánh dấu
vì không được sử dụng lại nên máy chủ có thể không lấy lại được.

1.3. ATTRIBUTE KVM_S390_VM_MEM_LIMIT_SIZE
-----------------------------------------

:Thông số: trong attr->addr địa chỉ cho giới hạn mới của bộ nhớ khách
:Trả về: -EFAULT nếu địa chỉ đã cho không thể truy cập được;
	  -EINVAL nếu máy ảo thuộc loại UCONTROL;
	  -E2BIG nếu bộ nhớ khách nhất định quá lớn đối với máy đó;
	  -EBUSY nếu vcpu đã được xác định;
	  -ENOMEM nếu không có đủ bộ nhớ cho bản đồ bóng khách mới;
	  0 nếu không.

Cho phép không gian người dùng truy vấn giới hạn thực tế và đặt giới hạn mới cho
kích thước bộ nhớ khách tối đa. Giới hạn sẽ được làm tròn thành
lần lượt là 2048 MB, 4096 GB, 8192 TB vì giới hạn này được điều chỉnh bởi
số cấp độ của bảng trang. Trong trường hợp không có giới hạn chúng tôi sẽ đặt
giới hạn đối với KVM_S390_NO_MEM_LIMIT (U64_MAX).

2. GROUP: KVM_S390_VM_CPU_MODEL
===============================

:Kiến trúc: s390

2.1. ATTRIBUTE: KVM_S390_VM_CPU_MACHINE (r/o)
---------------------------------------------

Cho phép không gian người dùng truy xuất thông tin liên quan đến CPU cụ thể của máy và kvm ::

cấu trúc kvm_s390_vm_cpu_machine {
       __u64 cpuid;           # ZZ0000ZZ của máy chủ
       __u32 ibc;             Phạm vi cấp độ # ZZ0001ZZ do máy chủ cung cấp
       __u8 đệm[4];
       __u64 fac_mask[256];   # set của các cơ sở cpu được kích hoạt bởi KVM
       __u64 fac_list[256];   # set của các cơ sở cpu được cung cấp bởi máy chủ
  }

:Thông số: địa chỉ của bộ đệm để lưu trữ dữ liệu cpu liên quan đến máy
	     thuộc loại struct kvm_s390_vm_cpu_machine*
:Trả về: -EFAULT nếu địa chỉ đã cho không thể truy cập được từ không gian kernel;
	    -ENOMEM nếu không đủ bộ nhớ để xử lý ioctl;
	    0 trong trường hợp thành công.

2.2. ATTRIBUTE: KVM_S390_VM_CPU_PROCESSOR (r/w)
===============================================

Cho phép không gian người dùng truy xuất hoặc yêu cầu thay đổi thông tin liên quan đến cpu cho vcpu ::

cấu trúc kvm_s390_vm_cpu_processor {
       __u64 cpuid;           # ZZ0000ZZ hiện đang được vcpu này sử dụng
       __u16 ibc;             Cấp độ # ZZ0001ZZ hiện (sẽ được) sử dụng bởi vcpu này
       __u8 đệm[6];
       __u64 fac_list[256];   # set của các cơ sở cpu hiện đang được sử dụng
			      # by vcpu này
  }

KVM không thực thi hoặc giới hạn dữ liệu mô hình CPU dưới mọi hình thức. Lấy thông tin
được truy xuất bằng KVM_S390_VM_CPU_MACHINE dưới dạng gợi ý cho cấu hình hợp lý
thiết lập. Việc chặn lệnh được kích hoạt bằng cách thiết lập thêm các bit cơ sở
không được xử lý bởi KVM cần được triển khai trong mã trình điều khiển VM.

:Thông số: địa chỉ của bộ đệm để lưu trữ/đặt CPU liên quan đến bộ xử lý
	     dữ liệu kiểu struct kvm_s390_vm_cpu_processor*.
:Trả về: -EBUSY trong trường hợp 1 hoặc nhiều vcpus đã được kích hoạt (chỉ trong trường hợp ghi);
	   -EFAULT nếu địa chỉ đã cho không thể truy cập được từ không gian kernel;
	   -ENOMEM nếu không đủ bộ nhớ để xử lý ioctl;
	   0 trong trường hợp thành công.

.. _KVM_S390_VM_CPU_MACHINE_FEAT:

2.3. ATTRIBUTE: KVM_S390_VM_CPU_MACHINE_FEAT (r/o)
--------------------------------------------------

Cho phép không gian người dùng truy xuất các tính năng CPU có sẵn. Một tính năng có sẵn nếu
được cung cấp bởi phần cứng và được hỗ trợ bởi kvm. Về lý thuyết, các tính năng của CPU có thể
thậm chí được mô phỏng hoàn toàn bởi kvm.

::

cấu trúc kvm_s390_vm_cpu_feat {
	__u64 feat[16]; # Bitmap (1 = tính năng khả dụng), đánh số MSB 0 bit
  };

:Thông số: địa chỉ của bộ đệm để tải danh sách tính năng từ đó.
:Trả về: -EFAULT nếu địa chỉ đã cho không thể truy cập được từ không gian kernel;
	   0 trong trường hợp thành công.

2.4. ATTRIBUTE: KVM_S390_VM_CPU_PROCESSOR_FEAT (r/w)
----------------------------------------------------

Cho phép không gian người dùng truy xuất hoặc thay đổi các tính năng CPU được kích hoạt cho tất cả các VCPU của một
VM. Không thể kích hoạt các tính năng không có sẵn.

Xem ZZ0000ZZ để biết
mô tả cấu trúc tham số

:Thông số: địa chỉ của bộ đệm để lưu trữ/tải danh sách tính năng từ đó.
:Trả về: -EFAULT nếu địa chỉ đã cho không thể truy cập được từ không gian kernel;
	    -EINVAL nếu tính năng cpu không khả dụng sẽ được bật;
	    -EBUSY nếu ít nhất một VCPU đã được xác định;
	    0 trong trường hợp thành công.

.. _KVM_S390_VM_CPU_MACHINE_SUBFUNC:

2.5. ATTRIBUTE: KVM_S390_VM_CPU_MACHINE_SUBFUNC (r/o)
-----------------------------------------------------

Cho phép không gian người dùng truy xuất các chức năng con cpu có sẵn mà không cần lọc
được thực hiện bởi bộ IBC. Các chức năng phụ này được chỉ định cho khách VCPU thông qua
truy vấn hoặc các hàm con "bit kiểm tra" và được sử dụng, ví dụ: bằng các hàm cpacf, plo và ptff.

Khối chức năng con chỉ hợp lệ nếu KVM_S390_VM_CPU_MACHINE chứa
Bit STFL(E) giới thiệu lệnh bị ảnh hưởng. Nếu hướng dẫn bị ảnh hưởng
chỉ ra các chức năng con thông qua "chức năng con truy vấn", khối phản hồi là
chứa trong cấu trúc được trả về. Nếu hướng dẫn bị ảnh hưởng
biểu thị các chức năng phụ thông qua cơ chế "bit kiểm tra", mã chức năng phụ được
chứa trong cấu trúc được trả về trong đánh số 0 bit MSB.

::

cấu trúc kvm_s390_vm_cpu_subfunc {
       u8 plo[32];           # always hợp lệ (tính năng ESA/390)
       u8 ptff[16];          # valid với đồng hồ lái TOD
       u8 kmac[16];          # valid với tính năng Hỗ trợ bảo mật tin nhắn
       u8 kmc[16];           # valid với tính năng Hỗ trợ bảo mật tin nhắn
       u8 km[16];            # valid với tính năng Hỗ trợ bảo mật tin nhắn
       u8 kimd[16];          # valid với tính năng Hỗ trợ bảo mật tin nhắn
       u8 klmd[16];          # valid với tính năng Hỗ trợ bảo mật tin nhắn
       u8 pckmo[16];         # valid với Tiện ích mở rộng Hỗ trợ Bảo mật Tin nhắn 3
       u8 kmctr[16];         # valid với Tiện ích mở rộng hỗ trợ-bảo mật-tin nhắn 4
       u8 kmf[16];           # valid với Tiện ích mở rộng Hỗ trợ-Bảo mật-Thông báo 4
       u8 kmo[16];           # valid với Tiện ích mở rộng hỗ trợ-bảo mật-tin nhắn 4
       u8 pcc[16];           # valid với Tiện ích mở rộng hỗ trợ-bảo mật-tin nhắn 4
       u8 ppno[16];          # valid với Tiện ích mở rộng Hỗ trợ-Bảo mật-Thông báo 5
       u8 kma[16];           # valid với Tiện ích mở rộng Hỗ trợ-Bảo mật-Thông báo 8
       u8 kdsa[16];          # valid với Tiện ích mở rộng hỗ trợ-bảo mật tin nhắn 9
       u8 dành riêng[1792];    # reserved để được hướng dẫn trong tương lai
  };

:Thông số: địa chỉ của bộ đệm để tải các khối chức năng con từ đó.
:Trả về: -EFAULT nếu địa chỉ đã cho không thể truy cập được từ không gian kernel;
	    0 trong trường hợp thành công.

2.6. ATTRIBUTE: KVM_S390_VM_CPU_PROCESSOR_SUBFUNC (r/w)
-------------------------------------------------------

Cho phép không gian người dùng truy xuất hoặc thay đổi các chức năng con của CPU được chỉ định cho
tất cả các VCPU của VM. Thuộc tính này sẽ chỉ khả dụng nếu kernel và
hỗ trợ phần cứng được đưa ra.

Hạt nhân sử dụng các khối chức năng con được cấu hình để chỉ ra
vị khách. Khối chức năng con sẽ chỉ được sử dụng nếu bit STFL(E) liên quan
chưa bị không gian người dùng vô hiệu hóa (vì vậy lệnh được truy vấn là
thực sự có sẵn cho khách).

Miễn là không có dữ liệu nào được ghi, việc đọc sẽ thất bại. IBC sẽ được sử dụng
để xác định các hàm con có sẵn trong trường hợp này, điều này sẽ đảm bảo ngược lại
khả năng tương thích.

Xem ZZ0000ZZ để biết
mô tả cấu trúc tham số

:Tham số: địa chỉ của bộ đệm để lưu trữ/tải các khối chức năng phụ từ đó.
:Trả về: -EFAULT nếu địa chỉ đã cho không thể truy cập được từ không gian kernel;
	    -EINVAL khi đọc, nếu chưa ghi;
	    -EBUSY nếu ít nhất một VCPU đã được xác định;
	    0 trong trường hợp thành công.

3. GROUP: KVM_S390_VM_TOD
=========================

:Kiến trúc: s390

3.1. ATTRIBUTE: KVM_S390_VM_TOD_HIGH
------------------------------------

Cho phép không gian người dùng thiết lập/nhận tiện ích mở rộng đồng hồ TOD (u8) (được thay thế bởi
KVM_S390_VM_TOD_EXT).

:Thông số: địa chỉ của bộ đệm trong không gian người dùng để lưu trữ dữ liệu (u8) vào
:Trả về: -EFAULT nếu địa chỉ đã cho không thể truy cập được từ không gian kernel;
	    -EINVAL nếu cài đặt tiện ích mở rộng đồng hồ TOD thành != 0 không được hỗ trợ
	    -EOPNOTSUPP dành cho khách PV (TOD do người giám sát quản lý)

3.2. ATTRIBUTE: KVM_S390_VM_TOD_LOW
-----------------------------------

Cho phép không gian người dùng đặt/nhận các bit 0-63 của thanh ghi đồng hồ TOD như được xác định trong
POP (u64).

:Thông số: địa chỉ của bộ đệm trong không gian người dùng để lưu trữ dữ liệu (u64) vào
:Trả về: -EFAULT nếu địa chỉ đã cho không thể truy cập được từ không gian kernel
	     -EOPNOTSUPP dành cho khách PV (TOD do người giám sát quản lý)

3.3. ATTRIBUTE: KVM_S390_VM_TOD_EXT
-----------------------------------

Cho phép không gian người dùng đặt/nhận các bit 0-63 của thanh ghi đồng hồ TOD như được xác định trong
POP (u64). Nếu mẫu CPU khách hỗ trợ phần mở rộng đồng hồ TOD (u8), thì nó
cũng cho phép không gian người dùng lấy/đặt nó. Nếu mẫu CPU của khách không hỗ trợ
nó, nó được lưu trữ dưới dạng 0 và không được phép đặt thành giá trị != 0.

:Parameters: địa chỉ của bộ đệm trong không gian người dùng để lưu trữ dữ liệu
	     (kvm_s390_vm_tod_clock) tới
:Trả về: -EFAULT nếu địa chỉ đã cho không thể truy cập được từ không gian kernel;
	    -EINVAL nếu cài đặt tiện ích mở rộng đồng hồ TOD thành != 0 không được hỗ trợ
	    -EOPNOTSUPP dành cho khách PV (TOD do người giám sát quản lý)

4. GROUP: KVM_S390_VM_CRYPTO
============================

:Kiến trúc: s390

4.1. ATTRIBUTE: KVM_S390_VM_CRYPTO_ENABLE_AES_KW (không có)
------------------------------------------------------

Cho phép không gian người dùng kích hoạt tính năng gói khóa aes, bao gồm cả việc tạo khóa mới
chìa khóa gói.

:Thông số: không có
:Trả về: 0

4.2. ATTRIBUTE: KVM_S390_VM_CRYPTO_ENABLE_DEA_KW (không có)
------------------------------------------------------

Cho phép không gian người dùng để kích hoạt tính năng gói khóa, bao gồm cả việc tạo một khóa mới
chìa khóa gói.

:Thông số: không có
:Trả về: 0

4.3. ATTRIBUTE: KVM_S390_VM_CRYPTO_DISABLE_AES_KW (không có)
-------------------------------------------------------

Cho phép không gian người dùng tắt tính năng gói khóa aes, xóa khóa gói.

:Thông số: không có
:Trả về: 0

4.4. ATTRIBUTE: KVM_S390_VM_CRYPTO_DISABLE_DEA_KW (không có)
-------------------------------------------------------

Cho phép không gian người dùng tắt tính năng gói khóa, xóa khóa gói.

:Thông số: không có
:Trả về: 0

5. GROUP: KVM_S390_VM_MIGRATION
===============================

:Kiến trúc: s390

5.1. ATTRIBUTE: KVM_S390_VM_MIGRATION_STOP (không có)
------------------------------------------------

Cho phép không gian người dùng dừng chế độ di chuyển, cần thiết để di chuyển PGSTE.
Đặt thuộc tính này khi chế độ di chuyển không hoạt động sẽ không có tác dụng
hiệu ứng.

:Thông số: không có
:Trả về: 0

5.2. ATTRIBUTE: KVM_S390_VM_MIGRATION_START (không có)
-------------------------------------------------

Cho phép không gian người dùng bắt đầu chế độ di chuyển, cần thiết để di chuyển PGSTE.
Đặt thuộc tính này khi chế độ di chuyển đã hoạt động sẽ có
không có hiệu ứng.

Theo dõi bẩn phải được bật trên tất cả các khe nhớ, nếu không -EINVAL sẽ được trả về. Khi nào
tính năng theo dõi bẩn bị tắt trên mọi khe nhớ, chế độ di chuyển sẽ tự động
dừng lại.

:Thông số: không có
:Trả về: -ENOMEM nếu không có đủ bộ nhớ trống để bắt đầu chế độ di chuyển;
	    -EINVAL nếu trạng thái của VM không hợp lệ (ví dụ: không xác định bộ nhớ);
	    0 trong trường hợp thành công.

5.3. ATTRIBUTE: KVM_S390_VM_MIGRATION_STATUS (r/o)
--------------------------------------------------

Cho phép không gian người dùng truy vấn trạng thái của chế độ di chuyển.

:Thông số: địa chỉ của bộ đệm trong không gian người dùng để lưu trữ dữ liệu (u64);
	     bản thân dữ liệu là 0 nếu chế độ di chuyển bị tắt hoặc 1
	     nếu nó được kích hoạt
:Trả về: -EFAULT nếu địa chỉ đã cho không thể truy cập được từ không gian kernel;
	    0 trong trường hợp thành công.

6. GROUP: KVM_ARM_VM_SMCCC_CTRL
===============================

:Kiến trúc: arm64

6.1. ATTRIBUTE: KVM_ARM_VM_SMCCC_FILTER (không có)
---------------------------------------------

:Thông số: Con trỏ tới ZZ0000ZZ

:Trả về:

=====================================================
        Phạm vi EEXIST giao với phạm vi được chèn trước đó
                hoặc phạm vi dành riêng
        EBUSY Một vCPU trong VM đã chạy
        EINVAL Cấu hình bộ lọc không hợp lệ
        ENOMEM Không thể phân bổ bộ nhớ cho hạt nhân
                đại diện của bộ lọc SMCCC
        =====================================================

Yêu cầu cài đặt bộ lọc cuộc gọi SMCCC được mô tả như sau::

enum kvm_smccc_filter_action {
            KVM_SMCCC_FILTER_HANDLE = 0,
            KVM_SMCCC_FILTER_DENY,
            KVM_SMCCC_FILTER_FWD_TO_USER,
    };

cấu trúc kvm_smccc_filter {
            __u32 căn cứ;
            __u32 nr_functions;
            __u8 hành động;
            __u8 đệm[15];
    };

Bộ lọc được định nghĩa là một tập hợp các phạm vi không chồng chéo. Mỗi
phạm vi xác định một hành động được áp dụng cho các lệnh gọi SMCCC trong phạm vi.
Không gian người dùng có thể chèn nhiều phạm vi vào bộ lọc bằng cách sử dụng
các cuộc gọi liên tiếp đến thuộc tính này.

Cấu hình mặc định của KVM sao cho tất cả SMCCC được triển khai
cuộc gọi được cho phép. Do đó, bộ lọc SMCCC có thể được xác định một cách thưa thớt
theo không gian người dùng, chỉ mô tả các phạm vi sửa đổi hành vi mặc định.

Phạm vi được thể hiện bởi ZZ0000ZZ là
[ZZ0001ZZ, ZZ0002ZZ). Phạm vi không được phép bao bọc,
tức là không gian người dùng không thể dựa vào tình trạng tràn ZZ0003ZZ.

Bộ lọc SMCCC áp dụng cho cả cuộc gọi SMC và HVC được khởi tạo bởi
khách. Bộ lọc SMCCC kiểm soát việc mô phỏng trong kernel của các lệnh gọi SMCCC
và như vậy có hiệu lực trước các giao diện khác tương tác với
Cuộc gọi SMCCC (ví dụ: thanh ghi bitmap hypercall).

hành động:

- ZZ0000ZZ: Cho phép khách gọi SMCCC
   được xử lý trong kernel. Chúng tôi đặc biệt khuyến nghị không gian người dùng ZZ0001ZZ
   mô tả rõ ràng phạm vi cuộc gọi SMCCC được phép.

- ZZ0000ZZ: Từ chối cuộc gọi SMCCC của khách trong kernel
   và trả lại cho khách.

- ZZ0000ZZ: Cuộc gọi SMCCC của khách được chuyển tiếp
   vào không gian người dùng với lý do thoát là ZZ0001ZZ.

Trường ZZ0000ZZ được dành riêng để sử dụng trong tương lai và phải bằng 0. KVM có thể
trả về ZZ0001ZZ nếu trường khác 0.

KVM bảo lưu phạm vi ID chức năng 'Cuộc gọi kiến trúc cánh tay' và
sẽ từ chối các nỗ lực xác định bộ lọc cho bất kỳ phần nào trong các phạm vi này:

=========== =================
        Bắt đầu Kết thúc (bao gồm)
        =========== =================
        0x8000_0000 0x8000_FFFF
        0xC000_0000 0xC000_FFFF
        =========== =================