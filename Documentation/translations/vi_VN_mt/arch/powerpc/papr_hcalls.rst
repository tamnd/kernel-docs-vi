.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/arch/powerpc/papr_hcalls.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

==============================
Mã hoạt động siêu cuộc gọi (hcalls)
===========================

Tổng quan
=========

Ảo hóa trên Nền tảng Power Book3S 64-bit dựa trên PAPR
đặc tả [1]_ mô tả môi trường thời gian chạy cho khách
hệ điều hành và cách nó tương tác với bộ ảo hóa để
hoạt động đặc quyền. Hiện tại có hai trình ảo hóa tương thích PAPR:

- ZZ0000ZZ: Trình ảo hóa độc quyền của IBM hỗ trợ AIX,
  IBM-i và Linux là khách được hỗ trợ (được gọi là Phân vùng logic
  hoặc LPARS). Nó hỗ trợ đặc điểm kỹ thuật PAPR đầy đủ.

- ZZ0000ZZ: Hỗ trợ khách linux PPC64 chạy trên máy chủ linux PPC64.
  Mặc dù nó chỉ triển khai một tập hợp con của đặc tả PAPR có tên LoPAPR [2]_.

Trên PPC64 Arch, kernel khách chạy trên bộ ảo hóa PAPR được gọi
một chiếc ZZ0000ZZ. Một khách pseries chạy ở chế độ giám sát (HV=0) và phải
đưa ra các siêu giám sát cho bộ ảo hóa bất cứ khi nào nó cần thực hiện một hành động
đó là đặc quyền của hypervisor [3]_ hoặc cho các dịch vụ khác được quản lý bởi
siêu giám sát.

Do đó, Hypercall (hcall) về cơ bản là một yêu cầu của khách pseries
yêu cầu hypervisor thực hiện một thao tác đặc quyền thay mặt cho khách. các
khách đưa ra a với các toán hạng đầu vào cần thiết. Trình ảo hóa sau khi thực hiện
hoạt động đặc quyền trả về mã trạng thái và các toán hạng đầu ra trở lại
khách.

HCALL ABI
=========
Thông số kỹ thuật ABI cho cuộc gọi giữa máy khách pseries và trình ảo hóa PAPR
được đề cập trong phần 14.5.3 của ref [2]_. Chuyển sang bối cảnh Hypervisor là
được thực hiện thông qua lệnh ZZ0000ZZ dự kiến Opcode cho hcall được đặt trong ZZ0001ZZ
và mọi đối số trong hcall đều được cung cấp trong các thanh ghi ZZ0002ZZ. Nếu giá trị
phải được truyền qua bộ đệm bộ nhớ, dữ liệu được lưu trữ trong bộ đệm đó phải được
theo thứ tự byte Big-endian.

Sau khi quyền kiểm soát được trả lại cho khách sau khi hypervisor đã phục vụ xong
Lệnh 'HVCS' giá trị trả về của hcall có sẵn trong ZZ0000ZZ và bất kỳ lệnh nào
giá trị out được trả về trong thanh ghi ZZ0001ZZ. Một lần nữa giống như trong trường hợp tranh luận,
mọi giá trị out được lưu trữ trong bộ nhớ đệm sẽ theo thứ tự byte Big-endian.

Mã vòm Powerpc cung cấp các trình bao bọc tiện lợi có tên ZZ0000ZZ được xác định
trong một tiêu đề cụ thể của Arch [4]_ để phát hành các cuộc gọi từ hạt nhân linux
chạy với tư cách là khách pseries.

Đăng ký quy ước
====================

Bất kỳ hcall nào cũng phải tuân theo quy ước đăng ký tương tự như được mô tả trong phần 2.2.1.1
trong số "Thông số kỹ thuật 64-Bit ELF V2 ABI: Kiến trúc nguồn"[5]_. Bảng dưới đây
tóm tắt các quy ước này:

+----------+----------+---------------------------------------------+
| Register | Dễ bay hơi ZZ0001ZZ
ZZ0002ZZ(Y/N) ZZ0003ZZ
+===========+================================================================================================================================
ZZ0004ZZ và ZZ0005ZZ
+----------+----------+---------------------------------------------+
ZZ0006ZZ và ZZ0007ZZ
+----------+----------+---------------------------------------------+
ZZ0008ZZ và ZZ0009ZZ
+----------+----------+---------------------------------------------+
ZZ0010ZZ và ZZ0011ZZ
+----------+----------+---------------------------------------------+
ZZ0012ZZ và ZZ0013ZZ
+----------+----------+---------------------------------------------+
ZZ0014ZZ và ZZ0015ZZ
+----------+----------+---------------------------------------------+
ZZ0016ZZ và ZZ0017ZZ
ZZ0018ZZ ZZ0019ZZ
+----------+----------+---------------------------------------------+
ZZ0020ZZ và ZZ0021ZZ
+----------+----------+---------------------------------------------+
ZZ0022ZZ và ZZ0023ZZ
+----------+----------+---------------------------------------------+
ZZ0024ZZ và ZZ0025ZZ
+----------+----------+---------------------------------------------+
ZZ0026ZZ và ZZ0027ZZ
+----------+----------+---------------------------------------------+
ZZ0028ZZ và ZZ0029ZZ
+----------+----------+---------------------------------------------+
ZZ0030ZZ và ZZ0031ZZ
+----------+----------+---------------------------------------------+
ZZ0032ZZ và ZZ0033ZZ
+----------+----------+---------------------------------------------+
ZZ0034ZZ và ZZ0035ZZ
+----------+----------+---------------------------------------------+
ZZ0036ZZ và ZZ0037ZZ
+----------+----------+---------------------------------------------+

Chỉ số DRC & DRC
=================
::

DR1 Khách
     +--+ +-------------+ +----------+
     ZZ0000ZZ <----> ZZ0001ZZ ZZ0002ZZ
     +--+ DRC1 ZZ0003ZZ DRC ZZ0004ZZ
                 Chỉ số ZZ0005ZZ +----------+
     DR2 ZZ0006ZZ ZZ0007ZZ
     +--+ ZZ0008ZZ <-----> ZZ0009ZZ
     ZZ0010ZZ <----> ZZ0011ZZ Hcall ZZ0012ZZ
     +---+ DRC2 +-------------+ +----------+

Thuật ngữ ảo hóa PAPR được chia sẻ tài nguyên phần cứng như thiết bị PCI, NVDIMM, v.v.
có sẵn để LPAR sử dụng dưới dạng Tài nguyên động (DR). Khi một DR được phân bổ cho
LPAR, PHYP tạo cấu trúc dữ liệu được gọi là Trình kết nối tài nguyên động (DRC)
để quản lý quyền truy cập LPAR. LPAR đề cập đến DRC thông qua số 32 bit mờ
được gọi là DRC-Index. Giá trị chỉ mục DRC được cung cấp cho LPAR thông qua cây thiết bị
nơi nó hiện diện như một thuộc tính trong nút cây thiết bị được liên kết với
DR.

HCALL Giá trị trả về
===================

Sau khi phục vụ hcall, trình ảo hóa sẽ đặt giá trị trả về trong ZZ0000ZZ cho biết
hcall thành công hay thất bại. Trong trường hợp có lỗi, mã lỗi sẽ chỉ ra
nguyên nhân gây ra lỗi. Các mã này được xác định và ghi lại trong Arch cụ thể
tiêu đề [4]_.

Trong một số trường hợp, một hcall có thể mất nhiều thời gian và cần được cấp
nhiều lần để được phục vụ hoàn toàn. Những cuộc gọi này thường sẽ
chấp nhận một giá trị mờ ZZ0000ZZ trong danh sách đối số đó và một
giá trị trả về của ZZ0001ZZ cho biết trình ảo hóa vẫn chưa kết thúc
phục vụ hcall chưa.

Để thực hiện các cuộc gọi như vậy, khách cần đặt ZZ0000ZZ cho
cuộc gọi ban đầu và sử dụng giá trị trả về của bộ ảo hóa của ZZ0001ZZ
cho mỗi cuộc gọi tiếp theo cho đến khi trình ảo hóa trả về một ZZ0002ZZ không phải
giá trị trả về.

Mã hoạt động HCALL
==============

Dưới đây là danh sách một phần HCALL được PHYP hỗ trợ. Đối với
giá trị opcode tương ứng vui lòng xem xét tiêu đề cụ thể của vòm [4]_:

ZZ0000ZZ

| Đầu vào: ZZ0000ZZ
| Ra: ZZ0001ZZ
| Giá trị trả về: ZZ0002ZZ

Cho Chỉ mục DRC của NVDIMM, đọc N-byte từ vùng siêu dữ liệu
được liên kết với nó, tại một khoảng bù được chỉ định và sao chép nó vào bộ đệm được cung cấp.
Vùng siêu dữ liệu lưu trữ thông tin cấu hình như thông tin nhãn,
khối xấu, v.v. Khu vực siêu dữ liệu nằm ngoài băng tần của bộ lưu trữ NVDIMM
do đó một ngữ nghĩa truy cập riêng biệt được cung cấp.

ZZ0000ZZ

| Đầu vào: ZZ0000ZZ
| Ra: ZZ0001ZZ
| Giá trị trả về: ZZ0002ZZ

Cho Chỉ mục DRC của NVDIMM, ghi N byte vào vùng siêu dữ liệu
được liên kết với nó, tại offset được chỉ định và từ bộ đệm được cung cấp.

ZZ0000ZZ

| Đầu vào: ZZ0000ZZ
| ZZ0001ZZ
| Ra: ZZ0002ZZ
| Giá trị trả về: ZZ0003ZZ
| ZZ0004ZZ

Cho DRC-Index của NVDIMM, ánh xạ phạm vi khối SCM liên tục
ZZ0000ZZ cho khách
tại ZZ0001ZZ trong không gian địa chỉ vật lý của khách. trong
trường hợp ZZ0002ZZ sau đó là trình ảo hóa
gán một địa chỉ đích cho khách. HCALL có thể bị lỗi nếu Khách có
một mục nhập PTE đang hoạt động vào khối SCM đang bị ràng buộc.

ZZ0000ZZ
| Đầu vào: drcIndex, startedScmLogicalMemoryAddress, numScmBlocksToUnbind
| Ra: numScmBlocksUnbound
| Giá trị trả về: ZZ0001ZZ
| ZZ0002ZZ

Với DRC-Index của NVDimm, hãy bỏ ánh xạ các khối ZZ0000ZZ SCM bắt đầu
tại ZZ0001ZZ từ không gian địa chỉ vật lý của khách. các
HCALL có thể thất bại nếu Khách có mục nhập PTE đang hoạt động vào khối SCM
không bị ràng buộc.

ZZ0000ZZ

| Đầu vào: ZZ0000ZZ
| Ra: ZZ0001ZZ
| Giá trị trả về: ZZ0002ZZ

Cho một DRC-Index và một chỉ mục Khối SCM trả về địa chỉ vật lý của khách cho
mà khối SCM được ánh xạ tới.

ZZ0000ZZ

| Đầu vào: ZZ0000ZZ
| Ra: ZZ0001ZZ
| Giá trị trả về: ZZ0002ZZ

Trả về địa chỉ vật lý của khách mà khối DRC Index và SCM được ánh xạ
đến địa chỉ đó.

ZZ0000ZZ

| Đầu vào: ZZ0000ZZ
| Ra: ZZ0001ZZ
| Giá trị trả về: ZZ0002ZZ
| ZZ0003ZZ

Tùy thuộc vào phạm vi Mục tiêu, hủy ánh xạ tất cả các khối SCM thuộc tất cả NVDIMM
hoặc tất cả các khối SCM thuộc về một NVDIMM duy nhất được xác định bởi drcIndex của nó
từ bộ nhớ LPAR.

ZZ0000ZZ

| Đầu vào: drcIndex
| Ra: ZZ0000ZZ
| Giá trị trả về: ZZ0001ZZ

Đưa ra Chỉ số DRC, trả về thông tin về lỗi dự đoán và tình trạng tổng thể của
thiết bị PMEM. Các bit được xác nhận trong bản đồ bit sức khỏe biểu thị một hoặc nhiều trạng thái
(được mô tả trong bảng bên dưới) của thiết bị PMEM và bitmap sức khỏe-bit-hợp lệ cho biết
bit nào trong health-bitmap là hợp lệ. Các bit được báo cáo trong
thứ tự bit đảo ngược, ví dụ giá trị 0xC400000000000000
cho biết các bit 0, 1 và 5 là hợp lệ.

Cờ Bitmap sức khỏe:

+------+-----------------------------------------------------------------------+
Định nghĩa ZZ0000ZZ |
+=======+=====================================================================================================================
ZZ0001ZZ Thiết bị PMEM không thể lưu giữ nội dung bộ nhớ.                     |
ZZ0002ZZ Nếu hệ thống bị tắt nguồn, sẽ không có gì được lưu lại.                 |
+------+-----------------------------------------------------------------------+
ZZ0003ZZ Thiết bị PMEM không thể lưu giữ nội dung bộ nhớ. Nội dung là |
ZZ0004ZZ không được lưu thành công khi tắt nguồn hoặc không được khôi phục đúng cách trên |
ZZ0005ZZ bật nguồn.                                                             |
+------+-----------------------------------------------------------------------+
Nội dung thiết bị ZZ0006ZZ PMEM được giữ nguyên từ IPL trước đó. Dữ liệu từ |
ZZ0007ZZ lần khởi động cuối cùng đã được khôi phục thành công.                             |
+------+-----------------------------------------------------------------------+
Nội dung thiết bị ZZ0008ZZ PMEM không được lưu giữ từ IPL trước đó. Không có |
Dữ liệu ZZ0009ZZ để khôi phục từ lần khởi động cuối cùng.                                   |
+------+-----------------------------------------------------------------------+
Thời lượng bộ nhớ còn lại của thiết bị ZZ0010ZZ PMEM cực kỳ thấp |
+------+-----------------------------------------------------------------------+
ZZ0011ZZ Thiết bị PMEM sẽ bị loại khỏi IPL tiếp theo do lỗi |
+------+-----------------------------------------------------------------------+
Nội dung thiết bị ZZ0012ZZ PMEM không thể tồn tại do tình trạng nền tảng hiện tại |
Trạng thái ZZ0013ZZ. Lỗi phần cứng có thể khiến dữ liệu không được lưu hoặc |
ZZ0014ZZ đã được khôi phục.                                                             |
+------+-----------------------------------------------------------------------+
ZZ0015ZZ Thiết bị PMEM không thể duy trì nội dung bộ nhớ trong một số điều kiện nhất định|
+------+-----------------------------------------------------------------------+
ZZ0016ZZ Thiết bị PMEM được mã hóa |
+------+-----------------------------------------------------------------------+
ZZ0017ZZ Thiết bị PMEM đã hoàn tất thành công việc xóa hoặc bảo mật được yêu cầu |
Quy trình xóa ZZ0018ZZ.                                                      |
+------+-----------------------------------------------------------------------+
ZZ0019ZZ Dành riêng / Chưa sử dụng |
+------+-----------------------------------------------------------------------+

ZZ0000ZZ

| Đầu vào: drcIndex, resultBuffer Addr
| Ra ngoài: Không có
| Giá trị trả về: ZZ0000ZZ

Đưa ra Chỉ số DRC, hãy thu thập số liệu thống kê hiệu suất cho NVDIMM và sao chép chúng
vào bộ đệm kết quả.

ZZ0000ZZ

| Đầu vào: ZZ0000ZZ
| Ra: ZZ0001ZZ
| Giá trị trả về: ZZ0002ZZ

Đưa ra Chỉ mục DRC Xóa dữ liệu vào thiết bị NVDIMM phụ trợ.

hcall trả về H_BUSY khi quá trình xóa mất nhiều thời gian hơn và hcall cần
được phát hành nhiều lần để được phục vụ đầy đủ. các
ZZ0000ZZ từ đầu ra được chuyển vào danh sách đối số của
các cuộc gọi tiếp theo tới hypervisor cho đến khi hcall được bảo trì hoàn toàn
tại thời điểm đó H_SUCCESS hoặc lỗi khác được trình ảo hóa trả về.

ZZ0000ZZ

| Đầu vào: cờ, mục tiêu, thao tác (op), op-param1, op-param2, op-param3
| Ra: ZZ0000ZZ
| Giá trị trả về: *H_Success,H_Busy,H_LongBusyOrder,H_Partial,H_Parameter,
		 H_P2,H_P3,H_P4,H_P5,H_P6,H_State,H_Not_Available,H_Authority*

H_HTM hỗ trợ thiết lập, cấu hình, kiểm soát và loại bỏ dấu vết phần cứng
Chức năng macro (HTM) và dữ liệu của nó. Bộ đệm HTM lưu trữ dữ liệu theo dõi cho các chức năng
như hướng dẫn lõi, lõi LLAT và tổ.

ZZ0000ZZ

| Đầu vào: ủy quyền, nhãn đối tượng, nhãn đối tượng, chính sách, out, outlen
| Ra: ZZ0000ZZ
| Giá trị trả về: *H_SUCCESS, H_Function, H_State, H_R_State, H_Parameter, H_P2,
                H_P3, H_P4, H_P5, H_P6, H_Authority, H_Nomem, H_Busy, H_Resource,
                H_Đã hủy bỏ*

H_PKS_GEN_KEY được sử dụng để bộ ảo hóa tạo khóa ngẫu nhiên mới.
Khóa này được lưu trữ dưới dạng một đối tượng trong Kho khóa nền tảng Power LPAR với
nhãn đối tượng được cung cấp. Với chính sách khóa gói được đặt, khóa chỉ
trình ảo hóa sẽ hiển thị, trong khi nhãn của khóa vẫn hiển thị với
người dùng. Việc tạo khóa gói chỉ được hỗ trợ cho kích thước khóa là
32 byte.

ZZ0000ZZ

| Đầu vào: ủy quyền, Wrapkeylabel, Wrapkeylabellen, objectwrapflags, in,
|        inlen, out, outlen, tiếp tục mã thông báo
| Ra: ZZ0000ZZ
| Giá trị trả về: *H_SUCCESS, H_Function, H_State, H_R_State, H_Parameter, H_P2,
                H_P3, H_P4, H_P5, H_P6, H_P7, H_P8, H_P9, H_Authority, H_Invalid_Key,
                H_NOT_FOUND, H_Busy, H_LongBusy, H_Aborted*

H_PKS_WRAP_OBJECT được sử dụng để bọc một đối tượng bằng cách sử dụng khóa gói được lưu trong
Power LPAR Platform KeyStore và trả lại đối tượng được bao bọc cho người gọi. các
người gọi cung cấp nhãn cho khóa gói với bộ chính sách 'khóa gói',
phải được tạo trước đó bằng H_PKS_GEN_KEY. Đối tượng được cung cấp
sau đó được mã hóa bằng khóa gói và siêu dữ liệu bổ sung và kết quả
được trả lại cho người gọi.


ZZ0000ZZ

| Đầu vào: ủy quyền, objectwrapflags, in, inlen, out, outlen, continue-token
| Ra: ZZ0000ZZ
| Giá trị trả về: *H_SUCCESS, H_Function, H_State, H_R_State, H_Parameter, H_P2,
                H_P3, H_P4, H_P5, H_P6, H_P7, H_Authority, H_Không được hỗ trợ, H_Bad_Data,
                H_NOT_FOUND, H_Invalid_Key, H_Busy, H_LongBusy, H_Aborted*

H_PKS_UNWRAP_OBJECT được sử dụng để mở một đối tượng đã bị biến dạng trước đó
H_PKS_WRAP_OBJECT.

Tài liệu tham khảo
==========
.. [1] "Power Architecture Platform Reference"
       https://en.wikipedia.org/wiki/Power_Architecture_Platform_Reference
.. [2] "Linux on Power Architecture Platform Reference"
       https://members.openpowerfoundation.org/document/dl/469
.. [3] "Definitions and Notation" Book III-Section 14.5.3
       https://openpowerfoundation.org/?resource_lib=power-isa-version-3-0
.. [4] arch/powerpc/include/asm/hvcall.h
.. [5] "64-Bit ELF V2 ABI Specification: Power Architecture"
       https://openpowerfoundation.org/?resource_lib=64-bit-elf-v2-abi-specification-power-architecture