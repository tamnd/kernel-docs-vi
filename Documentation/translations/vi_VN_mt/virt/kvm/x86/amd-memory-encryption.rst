.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/virt/kvm/x86/amd-memory-encryption.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

=========================================
Ảo hóa được mã hóa an toàn (SEV)
======================================

Tổng quan
========

Ảo hóa được mã hóa an toàn (SEV) là một tính năng có trên bộ xử lý AMD.

SEV là phần mở rộng của kiến trúc AMD-V hỗ trợ chạy
máy ảo (VM) dưới sự điều khiển của bộ ảo hóa. Khi được kích hoạt,
nội dung bộ nhớ của VM sẽ được mã hóa trong suốt bằng khóa
duy nhất cho VM đó.

Trình ảo hóa có thể xác định hỗ trợ SEV thông qua CPUID
hướng dẫn. Hàm CPUID 0x8000001f báo cáo thông tin liên quan
tới SEV::

0x8000001f[eax]:
			Bit[1] biểu thị sự hỗ trợ cho SEV
	    ...
[ecx]:
			Bits[31:0] Số lượng khách được mã hóa được hỗ trợ đồng thời

Nếu có hỗ trợ cho SEV, MSR 0xc001_0010 (MSR_AMD64_SYSCFG) và MSR 0xc001_0015
(MSR_K7_HWCR) có thể được sử dụng để xác định xem nó có thể được bật hay không::

0xc001_0010:
		Bit[23] 1 = có thể bật mã hóa bộ nhớ
			   0 = không thể bật mã hóa bộ nhớ

0xc001_0015:
		Bit[0] 1 = có thể bật mã hóa bộ nhớ
			   0 = không thể bật mã hóa bộ nhớ

Khi có hỗ trợ SEV, nó có thể được bật trong một VM cụ thể bằng cách
thiết lập bit SEV trước khi thực hiện VMRUN.::

VMCB[0x90]:
		Bit[1] 1 = SEV được bật
			    0 = SEV bị tắt

Phần cứng SEV sử dụng ASID để liên kết khóa mã hóa bộ nhớ với VM.
Do đó, ASID dành cho khách kích hoạt SEV phải từ 1 đến giá trị tối đa
được xác định trong trường CPUID 0x8000001f[ecx].

KVM_MEMORY_ENCRYPT_OP ioctl
===============================

Ioctl chính để truy cập SEV là KVM_MEMORY_ENCRYPT_OP, hoạt động trên
bộ mô tả tập tin VM.  Nếu đối số của KVM_MEMORY_ENCRYPT_OP là NULL,
ioctl trả về 0 nếu SEV được bật và ZZ0000ZZ nếu nó bị tắt
(trên một số phiên bản Linux cũ hơn, ioctl cố gắng chạy bình thường ngay cả khi
với đối số NULL và do đó có thể sẽ trả về ZZ0001ZZ thay thế
bằng 0 nếu SEV được bật).  Nếu không phải là NULL, đối số của
KVM_MEMORY_ENCRYPT_OP phải là cấu trúc kvm_sev_cmd::

cấu trúc kvm_sev_cmd {
               __u32 id;
               __u64 dữ liệu;
               __u32 lỗi;
               __u32 thứ bảy_fd;
       };


Trường ZZ0000ZZ chứa lệnh phụ và trường ZZ0001ZZ trỏ đến
một cấu trúc khác chứa các đối số cụ thể cho lệnh.  ZZ0002ZZ
phải trỏ đến bộ mô tả tệp được mở trên ZZ0003ZZ
thiết bị, nếu cần (xem các lệnh riêng lẻ).

Ở đầu ra, ZZ0000ZZ có kết quả là không thành công hoặc có mã lỗi.  Mã lỗi
được định nghĩa trong ZZ0001ZZ.

KVM triển khai các lệnh sau để hỗ trợ các sự kiện chung trong vòng đời của SEV
khách, chẳng hạn như khởi chạy, chạy, chụp nhanh, di chuyển và ngừng hoạt động.

1. KVM_SEV_INIT2
----------------

Lệnh KVM_SEV_INIT2 được hypervisor sử dụng để khởi tạo nền tảng SEV
bối cảnh. Trong quy trình làm việc điển hình, lệnh này phải là lệnh đầu tiên được đưa ra.

Để lệnh này được chấp nhận, KVM_X86_SEV_VM hoặc KVM_X86_SEV_ES_VM
phải được chuyển tới KVM_CREATE_VM ioctl.  Một máy ảo được tạo
lần lượt với các loại máy đó không thể chạy được cho đến khi KVM_SEV_INIT2 được gọi.

Tham số: struct kvm_sev_init (trong)

Trả về: 0 nếu thành công, -âm tính nếu có lỗi

::

cấu trúc kvm_sev_init {
                __u64 vmsa_features;  /* giá trị ban đầu của trường tính năng trong VMSA */
                __u32 cờ;          /* phải là 0 */
                __u16 ghcb_version;   /* Phiên bản GHCB dành cho khách tối đa được phép */
                __u16 pad1;
                __u32 pad2[8];
        };

Sẽ là lỗi nếu bộ ảo hóa không hỗ trợ bất kỳ bit nào
được đặt trong ZZ0000ZZ hoặc ZZ0001ZZ.  ZZ0002ZZ phải
0 cho máy ảo SEV vì chúng không có VMSA.

ZZ0000ZZ phải bằng 0 đối với máy ảo SEV, vì chúng không phát hành GHCB
yêu cầu. Nếu ZZ0001ZZ là 0 đối với bất kỳ loại khách nào khác thì số tiền tối đa
giao thức GHCB khách được phép sẽ mặc định là phiên bản 2.

Lệnh này thay thế các lệnh KVM_SEV_INIT và KVM_SEV_ES_INIT không được dùng nữa.
Các lệnh không có bất kỳ tham số nào (trường ZZ0001ZZ không được sử dụng) và
chỉ hoạt động với loại máy KVM_X86_DEFAULT_VM (0).

Họ cư xử như thể:

* loại VM là KVM_X86_SEV_VM cho KVM_SEV_INIT hoặc KVM_X86_SEV_ES_VM cho
  KVM_SEV_ES_INIT

* các trường ZZ0000ZZ và ZZ0001ZZ của ZZ0002ZZ là
  được đặt thành 0 và ZZ0003ZZ được đặt thành 0 cho KVM_SEV_INIT và 1 cho
  KVM_SEV_ES_INIT.

Nếu thuộc tính ZZ0000ZZ không tồn tại, thì trình ảo hóa chỉ
hỗ trợ KVM_SEV_INIT và KVM_SEV_ES_INIT.  Trong trường hợp đó, hãy lưu ý rằng KVM_SEV_ES_INIT
có thể đặt tính năng hoán đổi gỡ lỗi VMSA (bit 5) tùy thuộc vào giá trị của
Thông số ZZ0001ZZ của ZZ0002ZZ.

2. KVM_SEV_LAUNCH_START
-----------------------

Lệnh KVM_SEV_LAUNCH_START được sử dụng để tạo mã hóa bộ nhớ
bối cảnh. Để tạo bối cảnh mã hóa, người dùng phải cung cấp chính sách khách,
thông tin phiên và khóa Diffie-Hellman (PDH) công khai của chủ sở hữu.

Tham số: struct kvm_sev_launch_start (vào/ra)

Trả về: 0 nếu thành công, -âm tính nếu có lỗi

::

cấu trúc kvm_sev_launch_start {
                __u32 tay cầm;           /* nếu bằng 0 thì phần sụn sẽ tạo một mã điều khiển mới */
                __u32 chính sách;           /*chính sách dành cho khách */

__u64 dh_uaddr;         /* địa chỉ vùng người dùng trỏ tới khóa PDH của chủ sở hữu khách */
                __u32 dh_len;

__u64 phiên_addr;     /* địa chỉ vùng người dùng trỏ đến thông tin phiên khách */
                __u32 phiên_len;
        };

Nếu thành công, trường 'xử lý' chứa một địa chỉ xử lý mới và nếu có lỗi, sẽ có giá trị âm.

KVM_SEV_LAUNCH_START yêu cầu trường ZZ0000ZZ phải hợp lệ.

Để biết thêm chi tiết, xem thông số SEV Phần 6.2.

3. KVM_SEV_LAUNCH_UPDATE_DATA
-----------------------------

KVM_SEV_LAUNCH_UPDATE_DATA được sử dụng để mã hóa vùng bộ nhớ. Nó cũng
tính toán số đo nội dung bộ nhớ. Phép đo là một chữ ký
nội dung bộ nhớ có thể được gửi đến chủ sở hữu khách dưới dạng chứng thực
rằng bộ nhớ đã được mã hóa chính xác bởi phần sụn.

Tham số (trong): struct kvm_sev_launch_update_data

Trả về: 0 nếu thành công, -âm tính nếu có lỗi

::

cấu trúc kvm_sev_launch_update {
                __u64 uaddr;    /* địa chỉ vùng người dùng cần được mã hóa (phải căn chỉnh 16 byte) */
                __u32 len;      /* độ dài của dữ liệu được mã hóa (phải được căn chỉnh 16 byte) */
        };

Để biết thêm chi tiết, xem thông số SEV Phần 6.3.

4. KVM_SEV_LAUNCH_MEASURE
-------------------------

Lệnh KVM_SEV_LAUNCH_MEASURE được sử dụng để truy xuất số đo của
dữ liệu được mã hóa bằng lệnh KVM_SEV_LAUNCH_UPDATE_DATA. Chủ khách có thể
chờ cung cấp cho khách thông tin bí mật cho đến khi có thể xác minh được
đo lường. Vì chủ khách biết nội dung ban đầu của khách tại
khởi động, phép đo có thể được xác minh bằng cách so sánh nó với những gì chủ sở hữu khách
mong đợi.

Nếu len bằng 0 khi nhập, độ dài blob đo được ghi vào len và
uaddr không được sử dụng.

Tham số (trong): struct kvm_sev_launch_measure

Trả về: 0 nếu thành công, -âm tính nếu có lỗi

::

cấu trúc kvm_sev_launch_measure {
                __u64 uaddr;    /* nơi sao chép số đo */
                __u32 len;      /* chiều dài của blob đo */
        };

Để biết thêm chi tiết về quy trình xác minh phép đo, hãy xem thông số SEV Phần 6.4.

5. KVM_SEV_LAUNCH_FINISH
------------------------

Sau khi hoàn thành luồng khởi chạy, lệnh KVM_SEV_LAUNCH_FINISH có thể được
được ban hành để chuẩn bị hành quyết cho khách.

Trả về: 0 nếu thành công, -âm tính nếu có lỗi

6. KVM_SEV_GUEST_STATUS
-----------------------

Lệnh KVM_SEV_GUEST_STATUS được sử dụng để lấy thông tin trạng thái về một
Khách kích hoạt SEV.

Tham số (out): struct kvm_sev_guest_status

Trả về: 0 nếu thành công, -âm tính nếu có lỗi

::

cấu trúc kvm_sev_guest_status {
                __u32 tay cầm;   /* địa chỉ khách */
                __u32 chính sách;   /*chính sách dành cho khách */
                trạng thái __u8;     /* trạng thái khách (xem enum bên dưới) */
        };

Trạng thái khách SEV:

::

liệt kê {
        SEV_STATE_INVALID = 0;
        SEV_STATE_LAUNCHING, /* khách hiện đang được ra mắt */
        SEV_STATE_SECRET, /* khách đang được khởi chạy và sẵn sàng chấp nhận dữ liệu bản mã */
        SEV_STATE_RUNNING, /* khách đã được khởi chạy và chạy hoàn toàn */
        SEV_STATE_RECEIVING, /* khách đang được di chuyển từ máy SEV khác */
        SEV_STATE_SENDING /* khách đang được di chuyển sang máy SEV khác */
        };

7. KVM_SEV_DBG_DECRYPT
----------------------

Lệnh KVM_SEV_DEBUG_DECRYPT có thể được sử dụng bởi hypervisor để yêu cầu
phần sụn để giải mã dữ liệu tại vùng bộ nhớ nhất định.

Tham số (trong): struct kvm_sev_dbg

Trả về: 0 nếu thành công, -âm tính nếu có lỗi

::

cấu trúc kvm_sev_dbg {
                __u64 src_uaddr;        /*địa chỉ vùng người dùng của dữ liệu cần giải mã */
                __u64 dst_uaddr;        /*địa chỉ đích của vùng người dùng */
                __u32 len;              /*độ dài vùng nhớ cần giải mã */
        };

Lệnh trả về lỗi nếu chính sách khách không cho phép gỡ lỗi.

8. KVM_SEV_DBG_ENCRYPT
----------------------

Lệnh KVM_SEV_DEBUG_ENCRYPT có thể được sử dụng bởi hypervisor để yêu cầu
phần sụn để mã hóa dữ liệu tại vùng bộ nhớ nhất định.

Tham số (trong): struct kvm_sev_dbg

Trả về: 0 nếu thành công, -âm tính nếu có lỗi

::

cấu trúc kvm_sev_dbg {
                __u64 src_uaddr;        /*địa chỉ vùng người dùng của dữ liệu cần mã hóa */
                __u64 dst_uaddr;        /*địa chỉ đích của vùng người dùng */
                __u32 len;              /*độ dài vùng nhớ cần mã hóa */
        };

Lệnh trả về lỗi nếu chính sách khách không cho phép gỡ lỗi.

9. KVM_SEV_LAUNCH_SECRET
------------------------

Lệnh KVM_SEV_LAUNCH_SECRET có thể được hypervisor sử dụng để đưa thông tin bí mật vào
dữ liệu sau khi phép đo đã được chủ khách xác nhận.

Tham số (trong): struct kvm_sev_launch_secret

Trả về: 0 nếu thành công, -âm tính nếu có lỗi

::

cấu trúc kvm_sev_launch_secret {
                __u64 hdr_uaddr;        /*địa chỉ vùng người dùng chứa tiêu đề gói */
                __u32 hdr_len;

__u64 guest_uaddr;      /* vùng bộ nhớ khách nơi bí mật sẽ được đưa vào */
                __u32 khách_len;

__u64 trans_uaddr;      /* vùng bộ nhớ ảo hóa chứa bí mật */
                __u32 xuyên_len;
        };

10. KVM_SEV_GET_ATTESTATION_REPORT
----------------------------------

Lệnh KVM_SEV_GET_ATTESTATION_REPORT có thể được trình ảo hóa sử dụng để truy vấn chứng thực
báo cáo chứa bản tóm tắt SHA-256 của bộ nhớ khách và VMSA được chuyển qua KVM_SEV_LAUNCH
lệnh và ký bằng PEK. Thông báo được trả về bởi lệnh phải khớp với thông báo
được chủ khách sử dụng với KVM_SEV_LAUNCH_MEASURE.

Nếu len bằng 0 khi nhập, độ dài blob đo được ghi vào len và
uaddr không được sử dụng.

Tham số (trong): struct kvm_sev_attestation

Trả về: 0 nếu thành công, -âm tính nếu có lỗi

::

cấu trúc kvm_sev_attestation_report {
                __u8 phút[16];        /* Một đoạn ngẫu nhiên sẽ được đưa vào báo cáo */

__u64 uaddr;            /* địa chỉ vùng người dùng nơi báo cáo sẽ được sao chép */
                __u32 len;
        };

11. KVM_SEV_SEND_START
----------------------

Lệnh KVM_SEV_SEND_START có thể được sử dụng bởi hypervisor để tạo một
bối cảnh mã hóa khách gửi đi.

Nếu session_len bằng 0 khi nhập thì độ dài của thông tin phiên khách là
được ghi vào session_len và tất cả các trường khác không được sử dụng.

Tham số (trong): struct kvm_sev_send_start

Trả về: 0 nếu thành công, -âm tính nếu có lỗi

::

cấu trúc kvm_sev_send_start {
                __u32 chính sách;                 /*chính sách dành cho khách */

__u64 pdh_cert_uaddr;         /* Chứng chỉ Diffie-Hellman của nền tảng */
                __u32 pdh_cert_len;

__u64 plat_certs_uaddr;        /*chuỗi chứng chỉ nền tảng */
                __u32 plat_certs_len;

__u64 amd_certs_uaddr;        /* Chứng chỉ AMD */
                __u32 amd_certs_len;

__u64 phiên_uaddr;          /*Thông tin phiên khách */
                __u32 phiên_len;
        };

12. KVM_SEV_SEND_UPDATE_DATA
----------------------------

Lệnh KVM_SEV_SEND_UPDATE_DATA có thể được sử dụng bởi hypervisor để mã hóa
vùng bộ nhớ khách gửi đi với bối cảnh mã hóa được tạo bằng cách sử dụng
KVM_SEV_SEND_START.

Nếu hdr_len hoặc trans_len bằng 0 khi nhập, độ dài của tiêu đề gói và
vùng vận chuyển được ghi tương ứng vào hdr_len và trans_len, và tất cả
các trường khác không được sử dụng.

Tham số (trong): struct kvm_sev_send_update_data

Trả về: 0 nếu thành công, -âm tính nếu có lỗi

::

cấu trúc kvm_sev_launch_send_update_data {
                __u64 hdr_uaddr;        /*địa chỉ vùng người dùng chứa tiêu đề gói */
                __u32 hdr_len;

__u64 guest_uaddr;      /* vùng bộ nhớ nguồn được mã hóa */
                __u32 khách_len;

__u64 trans_uaddr;      /* vùng nhớ đích */
                __u32 xuyên_len;
        };

13. KVM_SEV_SEND_FINISH
------------------------

Sau khi hoàn thành luồng di chuyển, lệnh KVM_SEV_SEND_FINISH có thể được
do hypervisor phát hành để xóa bối cảnh mã hóa.

Trả về: 0 nếu thành công, -âm tính nếu có lỗi

14. KVM_SEV_SEND_CANCEL
------------------------

Sau khi hoàn thành SEND_START, nhưng trước SEND_FINISH, VMM nguồn có thể phát hành
Lệnh SEND_CANCEL để dừng di chuyển. Điều này là cần thiết để hủy bỏ
quá trình di chuyển có thể bắt đầu lại với mục tiêu mới sau.

Trả về: 0 nếu thành công, -âm tính nếu có lỗi

15. KVM_SEV_RECEIVE_START
-------------------------

Lệnh KVM_SEV_RECEIVE_START được sử dụng để tạo mã hóa bộ nhớ
bối cảnh cho một khách SEV đến. Để tạo bối cảnh mã hóa, người dùng phải
cung cấp chính sách khách, khóa và phiên công khai Diffie-Hellman (PDH) của nền tảng
thông tin.

Tham số: struct kvm_sev_receive_start (vào/ra)

Trả về: 0 nếu thành công, -âm tính nếu có lỗi

::

cấu trúc kvm_sev_receive_start {
                __u32 tay cầm;           /* nếu bằng 0 thì phần sụn sẽ tạo một mã điều khiển mới */
                __u32 chính sách;           /*chính sách dành cho khách */

__u64 pdh_uaddr;        /* địa chỉ vùng người dùng trỏ tới khóa PDH */
                __u32 pdh_len;

__u64 phiên_uaddr;    /* địa chỉ vùng người dùng trỏ đến thông tin phiên khách */
                __u32 phiên_len;
        };

Nếu thành công, trường 'xử lý' chứa một địa chỉ xử lý mới và nếu có lỗi, sẽ có giá trị âm.

Để biết thêm chi tiết, hãy xem thông số SEV Phần 6.12.

16. KVM_SEV_RECEIVE_UPDATE_DATA
-------------------------------

Lệnh KVM_SEV_RECEIVE_UPDATE_DATA có thể được trình ảo hóa sử dụng để sao chép
bộ đệm đến vào vùng bộ nhớ khách với bối cảnh mã hóa
được tạo trong KVM_SEV_RECEIVE_START.

Tham số (trong): struct kvm_sev_receive_update_data

Trả về: 0 nếu thành công, -âm tính nếu có lỗi

::

cấu trúc kvm_sev_launch_receive_update_data {
                __u64 hdr_uaddr;        /*địa chỉ vùng người dùng chứa tiêu đề gói */
                __u32 hdr_len;

__u64 guest_uaddr;      /* vùng bộ nhớ đích của khách */
                __u32 khách_len;

__u64 trans_uaddr;      /* vùng bộ nhớ đệm đến */
                __u32 xuyên_len;
        };

17. KVM_SEV_RECEIVE_FINISH
--------------------------

Sau khi hoàn thành luồng di chuyển, lệnh KVM_SEV_RECEIVE_FINISH có thể được
do hypervisor đưa ra để giúp khách sẵn sàng thực thi.

Trả về: 0 nếu thành công, -âm tính nếu có lỗi

18. KVM_SEV_SNP_LAUNCH_START
----------------------------

Lệnh KVM_SNP_LAUNCH_START được sử dụng để tạo mã hóa bộ nhớ
bối cảnh cho khách SEV-SNP. Nó phải được gọi trước khi phát hành
KVM_SEV_SNP_LAUNCH_UPDATE hoặc KVM_SEV_SNP_LAUNCH_FINISH;

Tham số (trong): struct kvm_sev_snp_launch_start

Trả về: 0 nếu thành công, -âm tính nếu có lỗi

::

cấu trúc kvm_sev_snp_launch_start {
                __u64 chính sách;           /* Chính sách dành cho khách sử dụng. */
                __u8 gosvw[16];         /* Cách giải quyết hiển thị của Hệ điều hành khách. */
                __u16 lá cờ;            /* Phải bằng 0. */
                __u8 pad0[6];
                __u64 pad1[4];
        };

Xem SNP_LAUNCH_START trong thông số kỹ thuật SEV-SNP [snp-fw-abi]_ để biết thêm
chi tiết về các tham số đầu vào trong ZZ0000ZZ.

19. KVM_SEV_SNP_LAUNCH_UPDATE
-----------------------------

Lệnh KVM_SEV_SNP_LAUNCH_UPDATE được sử dụng để tải các tệp do không gian người dùng cung cấp
dữ liệu vào phạm vi GPA khách, đo lường nội dung trong ngữ cảnh khách SNP
được tạo bởi KVM_SEV_SNP_LAUNCH_START, sau đó mã hóa/xác thực GPA đó
phạm vi để có thể đọc được ngay lập tức bằng khóa mã hóa
được liên kết với ngữ cảnh khách khi nó được khởi động, sau thời điểm đó nó có thể
chứng thực phép đo liên quan đến ngữ cảnh của nó trước khi mở khóa bất kỳ
bí mật.

Yêu cầu các phạm vi GPA được khởi tạo bằng lệnh này phải có
Thuộc tính KVM_MEMORY_ATTRIBUTE_PRIVATE được đặt trước. Xem tài liệu
cho KVM_SET_MEMORY_ATTRIBUTES để biết thêm chi tiết về khía cạnh này.

Khi thành công, lệnh này không đảm bảo đã xử lý toàn bộ
phạm vi được yêu cầu. Thay vào đó, các trường ZZ0000ZZ, ZZ0001ZZ và ZZ0002ZZ của
ZZ0003ZZ sẽ được cập nhật để tương ứng với
phạm vi còn lại chưa được xử lý. Người gọi nên tiếp tục
gọi lệnh này cho đến khi các trường đó cho biết toàn bộ phạm vi đã được
được xử lý, ví dụ: ZZ0004ZZ là 0, ZZ0005ZZ bằng GFN cuối cùng trong
phạm vi cộng 1 và ZZ0006ZZ là byte cuối cùng của nguồn do không gian người dùng cung cấp
địa chỉ bộ đệm cộng 1. Trong trường hợp ZZ0007ZZ là KVM_SEV_SNP_PAGE_TYPE_ZERO,
ZZ0008ZZ sẽ bị bỏ qua hoàn toàn.

Tham số (trong): struct kvm_sev_snp_launch_update

Trả về: 0 nếu thành công, < 0 nếu lỗi, -EAGAIN nếu người gọi thử lại

::

cấu trúc kvm_sev_snp_launch_update {
                __u64 gfn_start;        /* Số trang khách để tải/mã hóa dữ liệu vào. */
                __u64 uaddr;            /* Địa chỉ dữ liệu được căn chỉnh 4k sẽ được tải/mã hóa. */
                __u64 len;              /* Độ dài được căn chỉnh 4k tính bằng byte để sao chép vào bộ nhớ khách.*/
                __u8 loại;              /* Loại trang khách đang được khởi tạo. */
                __u8 pad0;
                __u16 lá cờ;            /* Phải bằng 0. */
                __u32 pad1;
                __u64 pad2[4];

        };

trong đó các giá trị được phép cho page_type là #define'd như::

KVM_SEV_SNP_PAGE_TYPE_NORMAL
        KVM_SEV_SNP_PAGE_TYPE_ZERO
        KVM_SEV_SNP_PAGE_TYPE_UNMEASURED
        KVM_SEV_SNP_PAGE_TYPE_SECRETS
        KVM_SEV_SNP_PAGE_TYPE_CPUID

Xem thông số SEV-SNP [snp-fw-abi]_ để biết thêm chi tiết về cách hoạt động của từng loại trang
được sử dụng/đo lường.

20. KVM_SEV_SNP_LAUNCH_FINISH
-----------------------------

Sau khi hoàn thành quy trình ra mắt khách SNP, KVM_SEV_SNP_LAUNCH_FINISH
lệnh có thể được ban hành để làm cho khách sẵn sàng thực hiện.

Tham số (trong): struct kvm_sev_snp_launch_finish

Trả về: 0 nếu thành công, -âm tính nếu có lỗi

::

cấu trúc kvm_sev_snp_launch_finish {
                __u64 id_block_uaddr;
                __u64 id_auth_uaddr;
                __u8 id_block_en;
                __u8 auth_key_en;
                __u8 vcek_disabled;
                __u8 Host_data[32];
                __u8 pad0[3];
                __u16 lá cờ;                    /* Phải bằng 0 */
                __u64 pad1[4];
        };


Xem SNP_LAUNCH_FINISH trong thông số kỹ thuật SEV-SNP [snp-fw-abi]_ để biết thêm
chi tiết về các tham số đầu vào trong ZZ0000ZZ.

21. KVM_SEV_SNP_ENABLE_REQ_CERTS
--------------------------------

Lệnh KVM_SEV_SNP_ENABLE_REQ_CERTS sẽ cấu hình KVM để thoát ra
không gian người dùng với loại thoát ZZ0000ZZ như một phần của quá trình xử lý
một báo cáo chứng thực của khách, sẽ cho phép không gian người dùng cung cấp
chứng chỉ tương ứng với khóa chứng thực được phần mềm cơ sở sử dụng để ký
báo cáo chứng thực đó.

Trả về: 0 nếu thành công, -âm tính nếu có lỗi

NOTE: Khóa xác nhận được sử dụng bởi chương trình cơ sở có thể thay đổi do
các hoạt động quản lý như cập nhật chương trình cơ sở SEV-SNP hoặc tải phần mềm mới
các khóa chứng thực, vì vậy cần cẩn thận để giữ lại các khóa được trả lại
dữ liệu chứng chỉ đồng bộ với khóa chứng thực thực tế được sử dụng bởi
chương trình cơ sở tại thời điểm yêu cầu chứng thực được gửi tới chương trình cơ sở SNP. các
Đề án được đề xuất để thực hiện việc này là sử dụng khóa tệp (ví dụ: thông qua fcntl()'s
F_OFD_SETLK) theo cách sau:

- Trước khi lấy/cung cấp dữ liệu chứng chỉ như một phần của dịch vụ
    loại thoát của ZZ0000ZZ, VMM sẽ có được
    khóa chia sẻ/đọc hoặc độc quyền/ghi trên tệp blob chứng chỉ trước đó
    đọc nó và gửi lại cho KVM, đồng thời tiếp tục giữ khóa cho đến khi
    yêu cầu chứng thực thực sự được gửi đến phần sụn. Để tạo điều kiện thuận lợi
    này, VMM có thể đặt cờ ZZ0001ZZ của kvm_run ngay sau
    cung cấp dữ liệu chứng chỉ và ngay trước khi tiếp tục vCPU.
    Điều này sẽ đảm bảo vCPU sẽ thoát trở lại không gian người dùng với ZZ0002ZZ
    sau khi hoàn tất việc tìm nạp yêu cầu chứng thực từ chương trình cơ sở, lúc
    điểm nào VMM có thể thả khóa tập tin một cách an toàn.

- Các công cụ/thư viện thực hiện cập nhật các giá trị TCB của phần mềm SNP hoặc
    khóa xác nhận (ví dụ: thông qua giao diện /dev/sev như ZZ0000ZZ,
    ZZ0001ZZ, hoặc ZZ0002ZZ, xem
    Documentation/virt/coco/sev-guest.rst để biết thêm chi tiết) theo cách như vậy
    rằng blob chứng chỉ cần được cập nhật, tương tự như vậy nên thực hiện
    khóa độc quyền trên blob chứng chỉ trong suốt thời gian cập nhật
    vào các khóa chứng thực hoặc nội dung blob chứng chỉ để đảm bảo rằng
    VMM sử dụng sơ đồ trên sẽ không trả về dữ liệu blob chứng chỉ
    không đồng bộ với khóa xác nhận được sử dụng bởi chương trình cơ sở tại thời điểm đó
    yêu cầu chứng thực thực sự được ban hành.

Sơ đồ này được khuyến nghị để các công cụ có thể sử dụng một cách khá chung chung/tự nhiên
phương pháp đồng bộ hóa các bản cập nhật chương trình cơ sở/chứng chỉ thông qua khóa tập tin,
điều này sẽ làm cho việc duy trì khả năng tương tác giữa các
công cụ/VMM/nhà cung cấp.

Thuộc tính thiết bị API
====================

Các thuộc tính của việc triển khai SEV có thể được truy xuất thông qua
ZZ0000ZZ và ZZ0001ZZ ioctls trên ZZ0002ZZ
nút thiết bị, sử dụng nhóm ZZ0003ZZ.

Các thuộc tính sau hiện đang được triển khai:

* ZZ0000ZZ: trả về tập hợp tất cả các bit
  được chấp nhận trong ZZ0001ZZ của ZZ0002ZZ.

* ZZ0000ZZ: trả về giá trị 1 nếu kernel hỗ trợ
  Lối ra ZZ0001ZZ, cho phép tìm nạp khóa chứng thực
  chứng chỉ từ không gian người dùng cho mỗi yêu cầu chứng thực SNP do khách cấp.

Quản lý phần mềm
===================

Việc quản lý khóa khách SEV được xử lý bởi bộ xử lý riêng có tên AMD
Bộ xử lý an toàn (AMD-SP). Phần sụn chạy bên trong AMD-SP cung cấp sự bảo mật
giao diện quản lý khóa để thực hiện các hoạt động ảo hóa phổ biến như
mã hóa mã bootstrap, ảnh chụp nhanh, di chuyển và gỡ lỗi khách. Để biết thêm
thông tin, hãy xem thông số Quản lý khóa SEV [api-spec]_

Phần sụn AMD-SP có thể được khởi tạo bằng cách sử dụng phần sụn không bay hơi của chính nó
lưu trữ hoặc hệ điều hành có thể quản lý bộ lưu trữ NV cho phần sụn bằng cách sử dụng
tham số ZZ0000ZZ của mô-đun ZZ0001ZZ. Nếu tập tin được chỉ định
bởi ZZ0002ZZ không tồn tại hoặc không hợp lệ, hệ điều hành sẽ tạo hoặc
ghi đè tệp bằng bộ lưu trữ cố định PSP.

Tài liệu tham khảo
==========


Xem [white-paper]_, [api-spec]_, [amd-apm]_, [kvm-forum]_, và [snp-fw-abi]_
để biết thêm thông tin.

.. [white-paper] https://developer.amd.com/wordpress/media/2013/12/AMD_Memory_Encryption_Whitepaper_v7-Public.pdf
.. [api-spec] https://support.amd.com/TechDocs/55766_SEV-KM_API_Specification.pdf
.. [amd-apm] https://support.amd.com/TechDocs/24593.pdf (section 15.34)
.. [kvm-forum]  https://www.linux-kvm.org/images/7/74/02x08A-Thomas_Lendacky-AMDs_Virtualizatoin_Memory_Encryption_Technology.pdf
.. [snp-fw-abi] https://www.amd.com/system/files/TechDocs/56860.pdf