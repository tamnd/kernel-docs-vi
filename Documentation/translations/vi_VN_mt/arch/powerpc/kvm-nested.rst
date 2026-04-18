.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/arch/powerpc/kvm-nested.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

========================================
KVM lồng nhau trên POWER
========================================

Giới thiệu
============

Tài liệu này giải thích cách một hệ điều hành khách có thể hoạt động như một
hypervisor và chạy các máy khách lồng nhau thông qua việc sử dụng hypercalls, nếu
hypervisor đã triển khai chúng. Các thuật ngữ L0, L1 và L2 được sử dụng để
đề cập đến các thực thể phần mềm khác nhau. L0 là thực thể chế độ ảo hóa
thường được gọi là "máy chủ" hoặc "máy ảo hóa". L1 là một
máy ảo khách được chạy trực tiếp dưới L0 và được khởi tạo
và được điều khiển bởi L0. L2 là một máy ảo khách được khởi tạo
và được điều khiển bởi L1 hoạt động như một bộ ảo hóa.

API hiện có
============

Linux/KVM đã hỗ trợ Nesting dưới dạng L0 hoặc L1 kể từ năm 2018

Mã L0 đã được thêm vào::

cam kết 8e3f5fc1045dc49fd175b978c5457f5f51e7a2ce
   Tác giả: Paul Mackerras <paulus@ozlabs.org>
   Ngày: Thứ Hai ngày 8 tháng 10 16:31:03 2018 +1100
   KVM: PPC: Book3S HV: Sơ khai khung và hcall cho ảo hóa lồng nhau

Mã L1 đã được thêm vào::

cam kết 360cae313702cdd0b90f82c261a8302fecef030a
   Tác giả: Paul Mackerras <paulus@ozlabs.org>
   Ngày: Thứ Hai ngày 8 tháng 10 16:31:04 2018 +1100
   KVM: PPC: Book3S HV: Mục nhập của khách lồng nhau thông qua hypercall

API này hoạt động chủ yếu bằng cách sử dụng một hcall h_enter_nested(). Cái này
lệnh gọi do L1 thực hiện để báo cho L0 khởi động vCPU L2 với thông số đã cho
trạng thái. L0 sau đó khởi động L2 này và chạy cho đến khi có điều kiện thoát L2
đã đạt được. Khi L2 thoát ra, trạng thái của L2 được trả lại cho
L1 bằng L0. Trạng thái vCPU L2 đầy đủ luôn được chuyển từ
và tới L1 khi L2 được chạy. L0 không giữ bất kỳ trạng thái nào trên L2
vCPU (ngoại trừ dãy ngắn ở L0 trên L1 -> L2 entry và L2
-> Lối ra L1).

Trạng thái duy nhất được L0 giữ là bảng phân vùng. Các thanh ghi L1
đó là bảng phân vùng sử dụng hcall h_set_partition_table(). Tất cả
trạng thái khác do L0 nắm giữ về L2 là trạng thái được lưu trong bộ nhớ đệm (chẳng hạn như
bảng trang bóng).

L1 có thể chạy bất kỳ L2 hoặc vCPU nào mà không cần thông báo trước cho L0. Nó
chỉ cần khởi động vCPU bằng h_enter_nested(). Việc tạo ra L2 và
vCPU được thực hiện ngầm bất cứ khi nào h_enter_nested() được gọi.

Trong tài liệu này, chúng tôi gọi API hiện có này là API v1.

PAPR API mới
===============

PAPR API mới thay đổi từ v1 API sao cho việc tạo L2 và
vCPU liên quan là rõ ràng. Trong tài liệu này, chúng tôi gọi đây là v2
API.

h_enter_nested() được thay thế bằng H_GUEST_VCPU_RUN().  Trước khi điều này có thể
được gọi là L1 phải tạo L2 một cách rõ ràng bằng cách sử dụng h_guest_create()
và mọi vCPU() liên quan được tạo bằng h_guest_create_vCPU(). Bắt
và việc thiết lập trạng thái vCPU cũng có thể được thực hiện bằng cách sử dụng h_guest_{g|s}et
hcall.

Luồng thực thi cơ bản là để L1 tạo L2, chạy nó và
xóa nó là:

- Khả năng đàm phán L1 và L0 với H_GUEST_{G,S}ET_CAPABILITIES()
  (thông thường ở thời điểm khởi động L1).

- L1 yêu cầu L0 tạo L2 với H_GUEST_CREATE() và nhận mã thông báo

- L1 yêu cầu L0 tạo vCPU L2 với H_GUEST_CREATE_VCPU()

- L1 và L0 truyền đạt trạng thái vCPU bằng cách sử dụng hcall H_GUEST_{G,S}ET()

- L1 yêu cầu L0 chạy vCPU chạy H_GUEST_VCPU_RUN() hcall

- L1 xóa L2 bằng H_GUEST_DELETE()

Thông tin chi tiết về các hcalls riêng lẻ như sau:

Chi tiết HCALL
=============

Tài liệu này được cung cấp để cung cấp một cách hiểu tổng thể về
API. Nó không nhằm mục đích cung cấp tất cả các chi tiết cần thiết để thực hiện
L1 hoặc L0. Phiên bản mới nhất của PAPR có thể tham khảo để biết thêm chi tiết.

Tất cả các HCALL này được tạo bởi L1 đến L0.

H_GUEST_GET_CAPABILITIES()
--------------------------

Điều này được gọi để có được khả năng của L0 lồng nhau
siêu giám sát. Điều này bao gồm các khả năng như phiên bản CPU (ví dụ:
POWER9, POWER10) được hỗ trợ dưới dạng L2::

H_GUEST_GET_CAPABILITIES(cờ uint64)

Thông số:
    đầu vào:
      cờ: Dành riêng
    Đầu ra:
      R3: Mã trả về
      R4: Bitmap khả năng được hỗ trợ của Hypervisor 1

H_GUEST_SET_CAPABILITIES()
--------------------------

Điều này được gọi để thông báo cho L0 về khả năng của L1
siêu giám sát. Bộ cờ được truyền ở đây giống như
H_GUEST_GET_CAPABILITIES()

Thông thường, GET sẽ được gọi đầu tiên và sau đó SET sẽ được gọi với
tập hợp con của các cờ được trả về từ GET. Quá trình này cho phép L0 và
L1 để đàm phán một tập hợp các khả năng đã được thống nhất::

H_GUEST_SET_CAPABILITIES(cờ uint64,
                           khả năng của uint64Bitmap1)
  Thông số:
    đầu vào:
      cờ: Dành riêng
      khả năngBitmap1: Chỉ các khả năng được quảng cáo thông qua
                           H_GUEST_GET_CAPABILITIES
    Đầu ra:
      R3: Mã trả về
      R4: Nếu R3 = H_P2: Số lượng bitmap không hợp lệ
      R5: Nếu R3 = H_P2: Chỉ số của bitmap không hợp lệ đầu tiên

H_GUEST_CREATE()
----------------

Điều này được gọi để tạo L2. Một ID duy nhất của L2 đã được tạo
(tương tự như LPID) được trả về, có thể được sử dụng trên các HCALL tiếp theo để
xác định L2::

H_GUEST_CREATE(cờ uint64,
                 uint64 continueToken);
  Thông số:
    đầu vào:
      cờ: Dành riêng
      continueToken: Cuộc gọi ban đầu được đặt thành -1. Những cuộc gọi tiếp theo,
                     sau khi H_Busy hoặc H_LongBusyOrder đã được
                     được trả về, giá trị được trả về trong R4.
    Đầu ra:
      R3: Mã trả về. Đáng chú ý:
        H_Not_Enough_Resources: Không thể tạo Khách VCPU do không
        đủ bộ nhớ Hypervisor. Xem H_GUEST_CREATE_GET_STATE(cờ =
        takeOwnershipOfVcpuState)
      R4: Nếu R3 = H_Busy hoặc_H_LongBusyOrder -> continueToken

H_GUEST_CREATE_VCPU()
---------------------

Lệnh này được gọi để tạo vCPU được liên kết với L2. Mã L2
(được trả về từ H_GUEST_CREATE()) nên được thông qua. Cũng đã đậu vào
là một vCPUid duy nhất (cho L2 này). vCPUid này được phân bổ bởi
L1::

H_GUEST_CREATE_VCPU(cờ uint64,
                      id khách uint64,
                      uint64 vcpuId);
  Thông số:
    đầu vào:
      cờ: Dành riêng
      guestId: ID thu được từ H_GUEST_CREATE
      vcpuId: ID của vCPU cần tạo. Điều này phải nằm trong
              phạm vi từ 0 đến 2047
    Đầu ra:
      R3: Mã trả về. Đáng chú ý:
        H_Not_Enough_Resources: Không thể tạo Khách VCPU do không
        đủ bộ nhớ Hypervisor. Xem H_GUEST_CREATE_GET_STATE(cờ =
        takeOwnershipOfVcpuState)

H_GUEST_GET_STATE()
-------------------

Lệnh này được gọi để lấy trạng thái liên kết với L2 (Dành riêng cho khách hoặc vCPU).
Thông tin này được truyền qua Bộ đệm trạng thái khách (GSB), một định dạng chuẩn như
được giải thích sau trong tài liệu này, các chi tiết cần thiết bên dưới:

Điều này có thể nhận được thông tin cụ thể về L2 hoặc vcpu. Ví dụ về
Chiều rộng L2 là phần bù cơ sở thời gian hoặc bảng trang trong phạm vi quy trình
thông tin. Ví dụ về vCPU cụ thể là GPR hoặc VSR. Một chút trong những lá cờ
tham số chỉ định lệnh gọi này có phạm vi rộng L2 hay vCPU cụ thể và
ID trong GSB phải khớp với điều này.

L1 cung cấp một con trỏ tới GSB làm tham số cho lệnh gọi này. Ngoài ra
được cung cấp là ID L2 và vCPU được liên kết với trạng thái cần đặt.

L1 chỉ ghi ID và kích thước trong GSB.  L0 viết
các giá trị liên quan cho mỗi ID trong GSB::

H_GUEST_GET_STATE(cờ uint64,
                           id khách uint64,
                           uint64 vcpuId,
                           Bộ đệm dữ liệu uint64,
                           uint64 dataBufferSizeInBytes);
  Thông số:
    đầu vào:
      cờ:
         Bit 0: getGuestWideState: Thay vào đó yêu cầu trạng thái của Khách
           của một cá nhân VCPU.
         Bit 1: getHostWideState: Yêu cầu số liệu thống kê của Host. Điều này gây ra
           các tham số guestId và vcpuId bị bỏ qua và đang cố gắng
           để có trạng thái VCPU/Khách sẽ gây ra lỗi.
         Bit 2-63: Dành riêng
      guestId: ID thu được từ H_GUEST_CREATE
      vcpuId: ID của vCPU chuyển tới H_GUEST_CREATE_VCPU
      dataBuffer: Địa chỉ thực L1 của GSB.
        Nếu takeOwnershipOfVcpuState, kích thước tối thiểu phải bằng kích thước
        được trả về bởi ID=0x0001
      dataBufferSizeInBytes: Kích thước của dataBuffer
    Đầu ra:
      R3: Mã trả về
      R4: Nếu R3 = H_Invalid_Element_Id: Chỉ số mảng của lỗi
            ID phần tử.
          Nếu R3 = H_Invalid_Element_Size: Chỉ số mảng của lỗi
             kích thước phần tử.
          Nếu R3 = H_Invalid_Element_Value: Chỉ số mảng của lỗi
             giá trị phần tử.

H_GUEST_SET_STATE()
-------------------

Lệnh này được gọi để đặt trạng thái L2 rộng của L2 hoặc trạng thái L2 cụ thể của vCPU. Thông tin này là
được chuyển qua Bộ đệm trạng thái khách (GSB), các chi tiết cần thiết bên dưới:

Điều này có thể đặt thông tin cụ thể về L2 hoặc vcpu. Ví dụ về
Chiều rộng L2 là phần bù cơ sở thời gian hoặc bảng trang trong phạm vi quy trình
thông tin. Ví dụ về vCPU cụ thể là GPR hoặc VSR. Một chút trong những lá cờ
tham số chỉ định lệnh gọi này có phạm vi rộng L2 hay vCPU cụ thể và
ID trong GSB phải khớp với điều này.

L1 cung cấp một con trỏ tới GSB làm tham số cho lệnh gọi này. Ngoài ra
được cung cấp là ID L2 và vCPU được liên kết với trạng thái cần đặt.

L1 ghi tất cả các giá trị trong GSB và L0 chỉ đọc GSB cho
cuộc gọi này::

H_GUEST_SET_STATE(cờ uint64,
                    id khách uint64,
                    uint64 vcpuId,
                    Bộ đệm dữ liệu uint64,
                    uint64 dataBufferSizeInBytes);
  Thông số:
    đầu vào:
      cờ:
         Bit 0: getGuestWideState: Thay vào đó yêu cầu trạng thái của Khách
           của một cá nhân VCPU.
         Bit 1: returnOwnershipOfVcpuState Trả về trạng thái Guest VCPU. Xem
           GET_STATE takeOwnershipOfVcpuState
         Bit 2-63: Dành riêng
      guestId: ID thu được từ H_GUEST_CREATE
      vcpuId: ID của vCPU chuyển tới H_GUEST_CREATE_VCPU
      dataBuffer: Địa chỉ thực L1 của GSB.
        Nếu takeOwnershipOfVcpuState, kích thước tối thiểu phải bằng kích thước
        được trả về bởi ID=0x0001
      dataBufferSizeInBytes: Kích thước của dataBuffer
    Đầu ra:
      R3: Mã trả về
      R4: Nếu R3 = H_Invalid_Element_Id: Chỉ số mảng của lỗi
            ID phần tử.
          Nếu R3 = H_Invalid_Element_Size: Chỉ số mảng của lỗi
             kích thước phần tử.
          Nếu R3 = H_Invalid_Element_Value: Chỉ số mảng của lỗi
             giá trị phần tử.

H_GUEST_RUN_VCPU()
------------------

Lệnh này được gọi để chạy vCPU L2. ID L2 và vCPU được chuyển vào dưới dạng
các thông số. vCPU chạy với trạng thái được đặt trước đó bằng cách sử dụng
H_GUEST_SET_STATE(). Khi L2 thoát ra, L1 sẽ tiếp tục từ đây
hcall.

hcall này cũng có GSB đầu vào và đầu ra liên quan. Không giống
H_GUEST_{S,G}ET_STATE(), các con trỏ GSB này không được truyền vào dưới dạng
tham số cho hcall (Điều này được thực hiện vì lợi ích của
hiệu suất). Vị trí của các GSB này phải được đăng ký trước bằng cách sử dụng
cuộc gọi H_GUEST_SET_STATE() với ID 0x0c00 và 0x0c01 (xem bảng
bên dưới).

Đầu vào GSB chỉ có thể chứa các phần tử cụ thể VCPU cần được đặt. Cái này
GSB cũng có thể chứa các phần tử bằng 0 (tức là 0 trong 4 byte đầu tiên của
GSB) nếu không cần thiết lập gì.

Khi thoát khỏi hcall, bộ đệm đầu ra chứa đầy các phần tử
được xác định bởi L0. Lý do thoát được chứa trong GPR4 (tức là
NIP được đặt trong GPR4).  Các phần tử được trả về phụ thuộc vào lối ra
loại. Ví dụ: nếu lý do thoát là L2 đang thực hiện hcall (GPR4 =
0xc00), thì GPR3-12 được cung cấp trong đầu ra GSB vì đây là
trạng thái có thể cần thiết để phục vụ hcall. Nếu trạng thái bổ sung là
cần thiết, H_GUEST_GET_STATE() có thể được gọi bởi L1.

Để tổng hợp các ngắt trong L2, khi gọi H_GUEST_RUN_VCPU()
L1 có thể đặt cờ (dưới dạng tham số hcall) và L0 sẽ
tổng hợp ngắt trong L2. Ngoài ra, L1 có thể
tự tổng hợp ngắt bằng cách sử dụng H_GUEST_SET_STATE() hoặc
H_GUEST_RUN_VCPU() nhập GSB để đặt trạng thái phù hợp::

H_GUEST_RUN_VCPU(cờ uint64,
                   id khách uint64,
                   uint64 vcpuId,
                   Bộ đệm dữ liệu uint64,
                   uint64 dataBufferSizeInBytes);
  Thông số:
    đầu vào:
      cờ:
         Bit 0: generateExternalInterrupt: Tạo ngắt ngoài
         Bit 1: generatePrivilegedDoorbell: Tạo chuông cửa đặc quyền
         Bit 2: sendToSystemReset”: Tạo ngắt thiết lập lại hệ thống
         Bit 3-63: Dành riêng
      guestId: ID thu được từ H_GUEST_CREATE
      vcpuId: ID của vCPU chuyển tới H_GUEST_CREATE_VCPU
    Đầu ra:
      R3: Mã trả về
      R4: Nếu R3 = H_Success: Lý do L1 VCPU thoát (tức là NIA)
            0x000: VCPU ngừng chạy vì lý do không xác định. Một
              ví dụ về điều này là Hypervisor dừng VCPU đang chạy
              do sự gián đoạn chưa xảy ra đối với Phân vùng máy chủ.
            0x980: HDEC
            0xC00: HCALL
            0xE00: HDSI
            0xE20: HISI
            0xE40: HEA
            0xF80: Mặt HV không có sẵn
          Nếu R3 = H_Invalid_Element_Id, H_Invalid_Element_Size, hoặc
            H_Invalid_Element_Value: R4 là phần bù của phần tử không hợp lệ
            trong bộ đệm đầu vào.

H_GUEST_DELETE()
----------------

Lệnh này được gọi để xóa L2. Tất cả các vCPU liên quan cũng
đã xóa. Không có lệnh gọi xóa vCPU cụ thể nào được cung cấp.

Một lá cờ có thể được cung cấp để xóa tất cả khách. Điều này được sử dụng để thiết lập lại
L0 trong trường hợp kdump/kexec::

H_GUEST_DELETE(cờ uint64,
                 uint64 guestId)
  Thông số:
    đầu vào:
      cờ:
         Bit 0: deleteAllGuests: xóa tất cả khách
         Bit 1-63: Dành riêng
      guestId: ID thu được từ H_GUEST_CREATE
    Đầu ra:
      R3: Mã trả về

Bộ đệm trạng thái khách
==================

Bộ đệm trạng thái khách (GSB) là phương thức chính để truyền đạt trạng thái
về L2 giữa L1 và L0 thông qua H_GUEST_{G,S}ET() và
Cuộc gọi H_GUEST_VCPU_RUN().

Trạng thái có thể được liên kết với toàn bộ L2 (ví dụ: phần bù cơ sở thời gian) hoặc một
vCPU L2 cụ thể (ví dụ: trạng thái GPR). Chỉ trạng thái L2 VCPU có thể được đặt bởi
H_GUEST_VCPU_RUN().

Tất cả dữ liệu trong GSB đều ở dạng big endian (như tiêu chuẩn trong PAPR)

Bộ đệm trạng thái Khách có tiêu đề cung cấp số lượng
các phần tử, theo sau là các phần tử GSB.

Tiêu đề GSB:

+----------+----------+---------------------------------------------+
ZZ0000ZZ Kích thước ZZ0001ZZ
ZZ0002ZZ Byte ZZ0003ZZ
+===========+================================================================================================================================
ZZ0004ZZ 4 ZZ0005ZZ
+----------+----------+---------------------------------------------+
ZZ0006ZZ ZZ0007ZZ
+----------+----------+---------------------------------------------+

Phần tử GSB:

+----------+----------+---------------------------------------------+
ZZ0000ZZ Kích thước ZZ0001ZZ
ZZ0002ZZ Byte ZZ0003ZZ
+===========+================================================================================================================================
ZZ0004ZZ 2 ZZ0005ZZ
+----------+----------+---------------------------------------------+
ZZ0006ZZ 2 ZZ0007ZZ
+----------+----------+---------------------------------------------+
ZZ0008ZZ Như trên ZZ0009ZZ
+----------+----------+---------------------------------------------+

ID trong phần tử GSB chỉ định những gì sẽ được đặt. Điều này bao gồm
trạng thái được kiến trúc như GPR, VSR, SPR, cùng với một số siêu dữ liệu về
phân vùng giống như trang bù trừ cơ sở dữ liệu thời gian và trang có phạm vi phân vùng
thông tin bảng.

+--------+-------+----+--------+----------------------------------+
|   ID   | Size  | RW |(H)ost  | Details                          |
|        | Bytes |    |(G)uest |                                  |
|        |       |    |(T)hread|                                  |
|        |       |    |Scope   |                                  |
+========+=======+====+========+==================================+
| 0x0000 |       | RW |   TG   | NOP element                      |
+--------+-------+----+--------+----------------------------------+
| 0x0001 | 0x08  | R  |   G    | Size of L0 vCPU state. See:      |
|        |       |    |        | H_GUEST_GET_STATE:               |
|        |       |    |        | flags = takeOwnershipOfVcpuState |
+--------+-------+----+--------+----------------------------------+
| 0x0002 | 0x08  | R  |   G    | Size Run vCPU out buffer         |
+--------+-------+----+--------+----------------------------------+
| 0x0003 | 0x04  | RW |   G    | Logical PVR                      |
+--------+-------+----+--------+----------------------------------+
| 0x0004 | 0x08  | RW |   G    | TB Offset (L1 relative)          |
+--------+-------+----+--------+----------------------------------+
| 0x0005 | 0x18  | RW |   G    |Partition scoped page tbl info:   |
|        |       |    |        |                                  |
|        |       |    |        |- 0x00 Addr part scope table      |
|        |       |    |        |- 0x08 Num addr bits              |
|        |       |    |        |- 0x10 Size root dir              |
+--------+-------+----+--------+----------------------------------+
| 0x0006 | 0x10  | RW |   G    |Process Table Information:        |
|        |       |    |        |                                  |
|        |       |    |        |- 0x0 Addr proc scope table       |
|        |       |    |        |- 0x8 Table size.                 |
+--------+-------+----+--------+----------------------------------+
| 0x0007-|       |    |        | Reserved                         |
| 0x07FF |       |    |        |                                  |
+--------+-------+----+--------+----------------------------------+
| 0x0800 | 0x08  | R  |   H    | Current usage in bytes of the    |
|        |       |    |        | L0's Guest Management Space      |
|        |       |    |        | for an L1-Lpar.                  |
+--------+-------+----+--------+----------------------------------+
| 0x0801 | 0x08  | R  |   H    | Max bytes available in the       |
|        |       |    |        | L0's Guest Management Space for  |
|        |       |    |        | an L1-Lpar                       |
+--------+-------+----+--------+----------------------------------+
| 0x0802 | 0x08  | R  |   H    | Current usage in bytes of the    |
|        |       |    |        | L0's Guest Page Table Management |
|        |       |    |        | Space for an L1-Lpar             |
+--------+-------+----+--------+----------------------------------+
| 0x0803 | 0x08  | R  |   H    | Max bytes available in the L0's  |
|        |       |    |        | Guest Page Table Management      |
|        |       |    |        | Space for an L1-Lpar             |
+--------+-------+----+--------+----------------------------------+
| 0x0804 | 0x08  | R  |   H    | Cumulative Reclaimed bytes from  |
|        |       |    |        | L0 Guest's Page Table Management |
|        |       |    |        | Space due to overcommit          |
+--------+-------+----+--------+----------------------------------+
| 0x0805-|       |    |        | Reserved                         |
| 0x0BFF |       |    |        |                                  |
+--------+-------+----+--------+----------------------------------+
| 0x0C00 | 0x10  | RW |   T    |Run vCPU Input Buffer:            |
|        |       |    |        |                                  |
|        |       |    |        |- 0x0 Addr of buffer              |
|        |       |    |        |- 0x8 Buffer Size.                |
+--------+-------+----+--------+----------------------------------+
| 0x0C01 | 0x10  | RW |   T    |Run vCPU Output Buffer:           |
|        |       |    |        |                                  |
|        |       |    |        |- 0x0 Addr of buffer              |
|        |       |    |        |- 0x8 Buffer Size.                |
+--------+-------+----+--------+----------------------------------+
| 0x0C02 | 0x08  | RW |   T    | vCPU VPA Address                 |
+--------+-------+----+--------+----------------------------------+
| 0x0C03-|       |    |        | Reserved                         |
| 0x0FFF |       |    |        |                                  |
+--------+-------+----+--------+----------------------------------+
| 0x1000-| 0x08  | RW |   T    | GPR 0-31                         |
| 0x101F |       |    |        |                                  |
+--------+-------+----+--------+----------------------------------+
| 0x1020 |  0x08 | T  |   T    | HDEC expiry TB                   |
+--------+-------+----+--------+----------------------------------+
| 0x1021 | 0x08  | RW |   T    | NIA                              |
+--------+-------+----+--------+----------------------------------+
| 0x1022 | 0x08  | RW |   T    | MSR                              |
+--------+-------+----+--------+----------------------------------+
| 0x1023 | 0x08  | RW |   T    | LR                               |
+--------+-------+----+--------+----------------------------------+
| 0x1024 | 0x08  | RW |   T    | XER                              |
+--------+-------+----+--------+----------------------------------+
| 0x1025 | 0x08  | RW |   T    | CTR                              |
+--------+-------+----+--------+----------------------------------+
| 0x1026 | 0x08  | RW |   T    | CFAR                             |
+--------+-------+----+--------+----------------------------------+
| 0x1027 | 0x08  | RW |   T    | SRR0                             |
+--------+-------+----+--------+----------------------------------+
| 0x1028 | 0x08  | RW |   T    | SRR1                             |
+--------+-------+----+--------+----------------------------------+
| 0x1029 | 0x08  | RW |   T    | DAR                              |
+--------+-------+----+--------+----------------------------------+
| 0x102A | 0x08  | RW |   T    | DEC expiry TB                    |
+--------+-------+----+--------+----------------------------------+
| 0x102B | 0x08  | RW |   T    | VTB                              |
+--------+-------+----+--------+----------------------------------+
| 0x102C | 0x08  | RW |   T    | LPCR                             |
+--------+-------+----+--------+----------------------------------+
| 0x102D | 0x08  | RW |   T    | HFSCR                            |
+--------+-------+----+--------+----------------------------------+
| 0x102E | 0x08  | RW |   T    | FSCR                             |
+--------+-------+----+--------+----------------------------------+
| 0x102F | 0x08  | RW |   T    | FPSCR                            |
+--------+-------+----+--------+----------------------------------+
| 0x1030 | 0x08  | RW |   T    | DAWR0                            |
+--------+-------+----+--------+----------------------------------+
| 0x1031 | 0x08  | RW |   T    | DAWR1                            |
+--------+-------+----+--------+----------------------------------+
| 0x1032 | 0x08  | RW |   T    | CIABR                            |
+--------+-------+----+--------+----------------------------------+
| 0x1033 | 0x08  | RW |   T    | PURR                             |
+--------+-------+----+--------+----------------------------------+
| 0x1034 | 0x08  | RW |   T    | SPURR                            |
+--------+-------+----+--------+----------------------------------+
| 0x1035 | 0x08  | RW |   T    | IC                               |
+--------+-------+----+--------+----------------------------------+
| 0x1036-| 0x08  | RW |   T    | SPRG 0-3                         |
| 0x1039 |       |    |        |                                  |
+--------+-------+----+--------+----------------------------------+
| 0x103A | 0x08  | W  |   T    | PPR                              |
+--------+-------+----+--------+----------------------------------+
| 0x103B | 0x08  | RW |   T    | MMCR 0-3                         |
| 0x103E |       |    |        |                                  |
+--------+-------+----+--------+----------------------------------+
| 0x103F | 0x08  | RW |   T    | MMCRA                            |
+--------+-------+----+--------+----------------------------------+
| 0x1040 | 0x08  | RW |   T    | SIER                             |
+--------+-------+----+--------+----------------------------------+
| 0x1041 | 0x08  | RW |   T    | SIER 2                           |
+--------+-------+----+--------+----------------------------------+
| 0x1042 | 0x08  | RW |   T    | SIER 3                           |
+--------+-------+----+--------+----------------------------------+
| 0x1043 | 0x08  | RW |   T    | BESCR                            |
+--------+-------+----+--------+----------------------------------+
| 0x1044 | 0x08  | RW |   T    | EBBHR                            |
+--------+-------+----+--------+----------------------------------+
| 0x1045 | 0x08  | RW |   T    | EBBRR                            |
+--------+-------+----+--------+----------------------------------+
| 0x1046 | 0x08  | RW |   T    | AMR                              |
+--------+-------+----+--------+----------------------------------+
| 0x1047 | 0x08  | RW |   T    | IAMR                             |
+--------+-------+----+--------+----------------------------------+
| 0x1048 | 0x08  | RW |   T    | AMOR                             |
+--------+-------+----+--------+----------------------------------+
| 0x1049 | 0x08  | RW |   T    | UAMOR                            |
+--------+-------+----+--------+----------------------------------+
| 0x104A | 0x08  | RW |   T    | SDAR                             |
+--------+-------+----+--------+----------------------------------+
| 0x104B | 0x08  | RW |   T    | SIAR                             |
+--------+-------+----+--------+----------------------------------+
| 0x104C | 0x08  | RW |   T    | DSCR                             |
+--------+-------+----+--------+----------------------------------+
| 0x104D | 0x08  | RW |   T    | TAR                              |
+--------+-------+----+--------+----------------------------------+
| 0x104E | 0x08  | RW |   T    | DEXCR                            |
+--------+-------+----+--------+----------------------------------+
| 0x104F | 0x08  | RW |   T    | HDEXCR                           |
+--------+-------+----+--------+----------------------------------+
| 0x1050 | 0x08  | RW |   T    | HASHKEYR                         |
+--------+-------+----+--------+----------------------------------+
| 0x1051 | 0x08  | RW |   T    | HASHPKEYR                        |
+--------+-------+----+--------+----------------------------------+
| 0x1052 | 0x08  | RW |   T    | CTRL                             |
+--------+-------+----+--------+----------------------------------+
| 0x1053 | 0x08  | RW |   T    | DPDES                            |
+--------+-------+----+--------+----------------------------------+
| 0x1054-|       |    |        | Reserved                         |
| 0x1FFF |       |    |        |                                  |
+--------+-------+----+--------+----------------------------------+
| 0x2000 | 0x04  | RW |   T    | CR                               |
+--------+-------+----+--------+----------------------------------+
| 0x2001 | 0x04  | RW |   T    | PIDR                             |
+--------+-------+----+--------+----------------------------------+
| 0x2002 | 0x04  | RW |   T    | DSISR                            |
+--------+-------+----+--------+----------------------------------+
| 0x2003 | 0x04  | RW |   T    | VSCR                             |
+--------+-------+----+--------+----------------------------------+
| 0x2004 | 0x04  | RW |   T    | VRSAVE                           |
+--------+-------+----+--------+----------------------------------+
| 0x2005 | 0x04  | RW |   T    | DAWRX0                           |
+--------+-------+----+--------+----------------------------------+
| 0x2006 | 0x04  | RW |   T    | DAWRX1                           |
+--------+-------+----+--------+----------------------------------+
| 0x2007-| 0x04  | RW |   T    | PMC 1-6                          |
| 0x200c |       |    |        |                                  |
+--------+-------+----+--------+----------------------------------+
| 0x200D | 0x04  | RW |   T    | WORT                             |
+--------+-------+----+--------+----------------------------------+
| 0x200E | 0x04  | RW |   T    | PSPB                             |
+--------+-------+----+--------+----------------------------------+
| 0x200F-|       |    |        | Reserved                         |
| 0x2FFF |       |    |        |                                  |
+--------+-------+----+--------+----------------------------------+
| 0x3000-| 0x10  | RW |   T    | VSR 0-63                         |
| 0x303F |       |    |        |                                  |
+--------+-------+----+--------+----------------------------------+
| 0x3040-|       |    |        | Reserved                         |
| 0xEFFF |       |    |        |                                  |
+--------+-------+----+--------+----------------------------------+
| 0xF000 | 0x08  | R  |   T    | HDAR                             |
+--------+-------+----+--------+----------------------------------+
| 0xF001 | 0x04  | R  |   T    | HDSISR                           |
+--------+-------+----+--------+----------------------------------+
| 0xF002 | 0x04  | R  |   T    | HEIR                             |
+--------+-------+----+--------+----------------------------------+
| 0xF003 | 0x08  | R  |   T    | ASDR                             |
+--------+-------+----+--------+----------------------------------+


Thông tin khác
==================

Trạng thái không có trong ptregs/hvregs
--------------------------

Trong v1 API, một số trạng thái không có trong ptregs/hvstate. Điều này bao gồm
thanh ghi vector và một số SPR. Để L1 thiết lập trạng thái này cho
L2, L1 tải các thanh ghi phần cứng này trước
h_enter_nested() và L0 đảm bảo chúng kết thúc ở trạng thái L2
(bằng cách không chạm vào chúng).

Phiên bản v2 API loại bỏ điều này và đặt trạng thái này một cách rõ ràng thông qua GSB.

Chi tiết triển khai L1: Trạng thái bộ nhớ đệm
----------------------------------------

Trong v1 API, tất cả trạng thái được gửi từ L1 đến L0 và ngược lại
trên mỗi h_enter_nested() hcall. Nếu L0 hiện không chạy
bất kỳ L2 nào, L0 không có thông tin trạng thái về chúng. duy nhất
ngoại lệ ở đây là vị trí của bảng phân vùng, đã đăng ký
thông qua h_set_partition_table().

v2 API thay đổi điều này để L0 giữ lại trạng thái L2 ngay cả khi
đó là vCPU không còn chạy nữa. Điều này có nghĩa là L1 chỉ cần
liên lạc với L0 về trạng thái L2 khi cần sửa đổi L2
trạng thái hoặc khi giá trị của nó đã lỗi thời. Điều này tạo cơ hội
để tối ưu hóa hiệu suất.

Khi vCPU thoát khỏi lệnh gọi H_GUEST_RUN_VCPU(), L1 bên trong
đánh dấu tất cả trạng thái L2 là không hợp lệ. Điều này có nghĩa là nếu L1 muốn biết
trạng thái L2 (giả sử thông qua lệnh gọi kvm_get_one_reg()), nó cần gọi
H_GUEST_GET_STATE() để có được trạng thái đó. Sau khi đọc xong, nó được đánh dấu là
hợp lệ trong L1 cho đến khi L2 được chạy lại.

Ngoài ra, khi L1 sửa đổi trạng thái L2 vcpu, nó không cần phải ghi nó
đến L0 cho đến khi vcpu L2 đó chạy lại. Do đó khi L1 cập nhật
trạng thái (giả sử thông qua lệnh gọi kvm_set_one_reg()), nó ghi vào L1 nội bộ
sao chép và chỉ xóa bản sao này vào L0 khi L2 chạy lại thông qua
bộ đệm đầu vào H_GUEST_VCPU_RUN().

Việc cập nhật trạng thái lười biếng này của L1 sẽ tránh được những
Cuộc gọi H_GUEST_{G|S}ET_STATE().