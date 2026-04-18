.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/driver-api/nvdimm/nvdimm.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

==================================
LIBNVDIMM: Thiết bị không bay hơi
===============================

libnvdimm - kernel/libndctl - thư viện trợ giúp không gian người dùng

nvdimm@lists.linux.dev

Phiên bản 13

.. contents:

	Glossary
	Overview
	    Supporting Documents
	    Git Trees
	LIBNVDIMM PMEM
	    PMEM-REGIONs, Atomic Sectors, and DAX
	Example NVDIMM Platform
	LIBNVDIMM Kernel Device Model and LIBNDCTL Userspace API
	    LIBNDCTL: Context
	        libndctl: instantiate a new library context example
	    LIBNVDIMM/LIBNDCTL: Bus
	        libnvdimm: control class device in /sys/class
	        libnvdimm: bus
	        libndctl: bus enumeration example
	    LIBNVDIMM/LIBNDCTL: DIMM (NMEM)
	        libnvdimm: DIMM (NMEM)
	        libndctl: DIMM enumeration example
	    LIBNVDIMM/LIBNDCTL: Region
	        libnvdimm: region
	        libndctl: region enumeration example
	        Why Not Encode the Region Type into the Region Name?
	        How Do I Determine the Major Type of a Region?
	    LIBNVDIMM/LIBNDCTL: Namespace
	        libnvdimm: namespace
	        libndctl: namespace enumeration example
	        libndctl: namespace creation example
	        Why the Term "namespace"?
	    LIBNVDIMM/LIBNDCTL: Block Translation Table "btt"
	        libnvdimm: btt layout
	        libndctl: btt creation example
	Summary LIBNDCTL Diagram


Thuật ngữ
========

PMEM:
  Phạm vi địa chỉ vật lý hệ thống trong đó việc ghi được diễn ra liên tục.  A
  thiết bị khối bao gồm PMEM có khả năng DAX.  Dải địa chỉ PMEM
  có thể trải rộng trên một số DIMM xen kẽ.

DPA:
  Địa chỉ vật lý DIMM, là giá trị bù tương đối với DIMM.  Với một DIMM trong
  hệ thống sẽ có liên kết 1:1 system-physical-address:DPA.
  Sau khi thêm các DIMM nữa, phải thực hiện xen kẽ bộ điều khiển bộ nhớ
  được giải mã để xác định DPA được liên kết với một
  địa chỉ vật lý hệ thống.

DAX:
  Phần mở rộng hệ thống tệp để bỏ qua bộ đệm trang và lớp chặn để
  bộ nhớ liên tục mmap, từ thiết bị khối PMEM, trực tiếp vào
  không gian địa chỉ tiến trình.

DSM:
  Phương pháp cụ thể của thiết bị: Phương pháp ACPI để kiểm soát cụ thể
  thiết bị - trong trường hợp này là phần sụn.

DCR:
  Cấu trúc vùng điều khiển NVDIMM được xác định trong ACPI 6 Mục 5.2.25.5.
  Nó xác định định dạng id nhà cung cấp, id thiết bị và giao diện cho DIMM nhất định.

BTT:
  Bảng dịch khối: Bộ nhớ liên tục có thể định địa chỉ theo byte.
  Phần mềm hiện tại có thể kỳ vọng rằng tính nguyên tử của sự cố mất điện
  số lần ghi ít nhất là một cung, 512 byte.  BTT là một hướng
  bảng với ngữ nghĩa cập nhật nguyên tử ở phía trước thiết bị khối PMEM
  điều khiển và trình bày kích thước khu vực nguyên tử tùy ý.

LABEL:
  Siêu dữ liệu được lưu trữ trên thiết bị DIMM có chức năng phân vùng và xác định
  (tên liên tục) dung lượng được phân bổ cho các không gian tên PMEM khác nhau. Nó
  cũng cho biết liệu việc trừu tượng hóa địa chỉ như BTT có được áp dụng cho
  không gian tên.  Lưu ý rằng các bảng phân vùng truyền thống, GPT/MBR,
  được xếp chồng lên trên không gian tên PMEM hoặc trừu tượng hóa địa chỉ như BTT
  nếu có, nhưng tính năng hỗ trợ phân vùng sẽ không còn được dùng nữa trong tương lai.


Tổng quan
========

Hệ thống con LIBNVDIMM cung cấp hỗ trợ cho PMEM được mô tả bởi nền tảng
chương trình cơ sở hoặc trình điều khiển thiết bị. Trên các hệ thống dựa trên ACPI, phần sụn nền tảng
truyền tài nguyên bộ nhớ liên tục thông qua ACPI NFIT "NVDIMM Firmware
Bảng giao diện" trong ACPI 6. Trong khi triển khai hệ thống con LIBNVDIMM
là chung và hỗ trợ các nền tảng trước NFIT, nó được hướng dẫn bởi
siêu khả năng cần hỗ trợ định nghĩa ACPI 6 này cho
Tài nguyên NVDIMM. Việc triển khai ban đầu đã hỗ trợ
khả năng khẩu độ khối cửa sổ được mô tả trong NFIT, nhưng hỗ trợ đó
kể từ đó đã bị bỏ rơi và không bao giờ được vận chuyển trong một sản phẩm.

Tài liệu hỗ trợ
--------------------

ACPI 6:
	ZZ0000ZZ
Không gian tên NVDIMM:
	ZZ0001ZZ
Ví dụ về giao diện DSM:
	ZZ0002ZZ
Hướng dẫn viết tài xế:
	ZZ0003ZZ

Cây Git
---------

LIBNVDIMM:
	ZZ0000ZZ
LIBNDCTL:
	ZZ0001ZZ


LIBNVDIMM PMEM
==============

Trước khi NFIT xuất hiện, bộ nhớ bất biến được mô tả là
hệ thống theo nhiều cách đặc biệt khác nhau.  Thông thường chỉ có mức tối thiểu là
được cung cấp, cụ thể là, một dải địa chỉ vật lý hệ thống duy nhất nơi ghi
dự kiến sẽ bền sau khi mất điện hệ thống.  Bây giờ, NFIT
đặc điểm kỹ thuật tiêu chuẩn hóa không chỉ mô tả của PMEM mà còn
điểm truy nhập thông điệp nền tảng để kiểm soát và cấu hình.

PMEM (nd_pmem.ko): Điều khiển dải địa chỉ vật lý hệ thống.  Phạm vi này là
liền kề trong bộ nhớ hệ thống và có thể được xen kẽ (bộ điều khiển bộ nhớ phần cứng
sọc) trên nhiều DIMM.  Khi xen kẽ nền tảng có thể tùy chọn
cung cấp thông tin chi tiết về DIMM nào đang tham gia vào quá trình xen kẽ.

Điều đáng lưu ý là khi phát hiện khả năng ghi nhãn (EFI
tìm thấy khối chỉ mục nhãn không gian tên), thì không có thiết bị khối nào được tạo
theo mặc định vì không gian người dùng cần thực hiện ít nhất một lần phân bổ DPA cho
phạm vi PMEM.  Ngược lại, phạm vi ND_NAMESPACE_IO, sau khi được đăng ký,
có thể được gắn ngay vào nd_pmem. Chế độ sau này được gọi là
không có nhãn hoặc "di sản".

PMEM-REGION, Lĩnh vực nguyên tử và DAX
-------------------------------------

Đối với trường hợp ứng dụng hoặc hệ thống tập tin vẫn cần khu vực nguyên tử
bản cập nhật đảm bảo nó có thể đăng ký BTT trên thiết bị hoặc phân vùng PMEM.  Xem
LIBNVDIMM/NDCTL: Bảng dịch khối "btt"


Ví dụ về nền tảng NVDIMM
=======================

Trong phần còn lại của tài liệu này, sơ đồ sau sẽ là
được tham chiếu cho bất kỳ ví dụ nào về bố cục sysfs ::


(a) (b) DIMM
            +----------+--------+--------+--------+
  +------+ ZZ0000ZZ miễn phí ZZ0001ZZ miễn phí |    0
  | imc0 +--+- - - vùng0- - - +-------------- + +--------+
  +---+---+ ZZ0002ZZ miễn phí ZZ0003ZZ miễn phí |    1
     |      +-------------------+--------v v--------+
  +--+---+ ZZ0004ZZ
  ZZ0005ZZ khu vực1
  +--+---+ ZZ0006ZZ
     |      +------------------------------------------^ ^--------+
  +--+---+ ZZ0007ZZ chiều1.0 ZZ0008ZZ 2
  ZZ0009ZZ +--------+
  +------+ ZZ0010ZZ chiều1.0 ZZ0011ZZ 3
            +-----------------------------+--------+--------+

Trong nền tảng này, chúng tôi có bốn DIMM và hai bộ điều khiển bộ nhớ trong một
ổ cắm.  Mỗi bộ xen kẽ PMEM được xác định bởi một thiết bị vùng có
một id được gán động.

1. Phần đầu tiên của DIMM0 và DIMM1 được xen kẽ thành REGION0. A
       không gian tên PMEM duy nhất được tạo trong phạm vi REGION0-SPA trải rộng nhất
       của DIMM0 và DIMM1 với tên do người dùng chỉ định là "pm0.0". Một số trong số đó
       phạm vi địa chỉ vật lý hệ thống xen kẽ được để trống cho
       một không gian tên PMEM khác sẽ được xác định.

2. Trong phần cuối cùng của DIMM0 và DIMM1, chúng ta có một phần xen kẽ
       dải địa chỉ vật lý hệ thống, REGION1, trải rộng trên hai DIMM đó như
       cũng như DIMM2 và DIMM3.  Một số REGION1 được phân bổ cho không gian tên PMEM
       được đặt tên là "pm1.0".

Bus này được cung cấp bởi kernel bên dưới thiết bị
    /sys/devices/platform/nfit_test.0 khi mô-đun nfit_test.ko từ
    tools/testing/nvdimm đã được tải. Mô-đun này là một bài kiểm tra đơn vị cho
    LIBNVDIMM và trình điều khiển acpi_nfit.ko.


Mô hình thiết bị hạt nhân LIBNVDIMM và không gian người dùng LIBNDCTL API
========================================================

Phần sau đây là mô tả về bố cục hệ thống LIBNVDIMM và một
sơ đồ phân cấp đối tượng tương ứng khi được xem qua LIBNDCTL
API.  Các đường dẫn và sơ đồ sysfs mẫu có liên quan đến Ví dụ
Nền tảng NVDIMM cũng là bus LIBNVDIMM được sử dụng trong thiết bị LIBNDCTL
kiểm tra.

LIBNDCTL: Bối cảnh
-----------------

Mỗi lệnh gọi API trong thư viện LIBNDCTL đều yêu cầu một ngữ cảnh chứa
tham số ghi nhật ký và trạng thái phiên bản thư viện khác.  Thư viện là
dựa trên mẫu libabc:

ZZ0000ZZ

LIBNDCTL: khởi tạo một ví dụ ngữ cảnh thư viện mới
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

::

cấu trúc ndctl_ctx *ctx;

if (ndctl_new(&ctx) == 0)
		trả lại ctx;
	khác
		trả lại NULL;

LIBNVDIMM/LIBNDCTL: Xe buýt
-----------------------

Xe buýt có mối quan hệ 1:1 với NFIT.  Kỳ vọng hiện tại đối với
Các hệ thống dựa trên ACPI là chỉ có một NFIT toàn cầu.
Điều đó nói rằng, việc đăng ký nhiều NFIT là chuyện nhỏ, thông số kỹ thuật
không loại trừ nó.  Cơ sở hạ tầng hỗ trợ nhiều xe buýt và
chúng tôi sử dụng khả năng này để kiểm tra nhiều cấu hình NFIT trong thiết bị
kiểm tra.

LIBNVDIMM: thiết bị lớp điều khiển trong /sys/class
---------------------------------------------

Thiết bị ký tự này chấp nhận tin nhắn DSM để chuyển đến DIMM
được xác định bởi tay cầm NFIT của nó::

/sys/class/nd/ndctl0
	|-- nhà phát triển
	|-- thiết bị -> ../../../ndbus0
	|-- hệ thống con -> ../../../../../../class/nd



LIBNVDIMM: xe buýt
--------------

::

cấu trúc nvdimm_bus *nvdimm_bus_register(struct device *parent,
	       cấu trúc nvdimm_bus_descriptor *nfit_desc);

::

/sys/devices/platform/nfit_test.0/ndbus0
	|-- lệnh
	|-- nd
	|-- nfit
	|-- nmem0
	|-- nmem1
	|-- nmem2
	|-- nmem3
	|-- quyền lực
	|-- nhà cung cấp
	|-- vùng0
	|-- khu vực1
	|-- khu vực2
	|-- khu vực3
	|-- khu vực4
	|-- khu vực5
	|-- sự kiện
	`-- chờ_thăm dò

LIBNDCTL: ví dụ về liệt kê xe buýt
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Tìm tay cầm xe buýt mô tả xe buýt từ Nền tảng NVDIMM mẫu::

cấu trúc tĩnh ndctl_bus *get_bus_by_provider(struct ndctl_ctx *ctx,
			const char *nhà cung cấp)
	{
		cấu trúc ndctl_bus *bus;

ndctl_bus_foreach(ctx, xe buýt)
			if (strcmp(nhà cung cấp, ndctl_bus_get_provider(bus)) == 0)
				xe buýt trở về;

trả lại NULL;
	}

xe buýt = get_bus_by_provider(ctx, "nfit_test.0");


LIBNVDIMM/LIBNDCTL: DIMM (NMEM)
-------------------------------

Thiết bị DIMM cung cấp một thiết bị ký tự để gửi lệnh tới
phần cứng và nó là nơi chứa LABEL.  Nếu DIMM được xác định bởi
NFIT thì có sẵn thư mục con thuộc tính 'nfit' tùy chọn để thêm
Thông số cụ thể của NFIT.

Lưu ý rằng tên thiết bị hạt nhân cho "DIMM" là "nmemX".  NFIT
mô tả các thiết bị này thông qua "Thiết bị bộ nhớ tới Địa chỉ vật lý của hệ thống
Cấu trúc ánh xạ phạm vi" và không có yêu cầu nào về việc chúng thực sự
là DIMM vật lý nên chúng tôi sử dụng tên chung hơn.

LIBNVDIMM: DIMM (NMEM)
^^^^^^^^^^^^^^^^^^^^^^

::

cấu trúc nvdimm *nvdimm_create(struct nvdimm_bus *nvdimm_bus, void *provider_data,
			const struct attribute_group **nhóm, cờ dài không dấu,
			dài không dấu *dsm_mask);

::

/sys/devices/platform/nfit_test.0/ndbus0
	|-- nmem0
	ZZ0001ZZ-- có sẵn_slots
	ZZ0002ZZ-- lệnh
	ZZ0003ZZ-- nhà phát triển
	ZZ0004ZZ-- devtype
	ZZ0005ZZ-- trình điều khiển -> ../../../../bus/nd/drivers/nvdimm
	ZZ0006ZZ-- phương thức
	ZZ0007ZZ-- nfit
	ZZ0008ZZ |-- thiết bị
	ZZ0009ZZ |-- định dạng
	ZZ0010ZZ |-- tay cầm
	ZZ0011ZZ |-- Phys_id
	ZZ0012ZZ |-- rev_id
	ZZ0013ZZ |-- nối tiếp
	ZZ0014ZZ ZZ0000ZZ-- sự kiện
	|-- nmem1
	[..]


LIBNDCTL: Ví dụ về liệt kê DIMM
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Lưu ý, trong ví dụ này, chúng tôi giả sử các DIMM do NFIT xác định là
được xác định bằng "nfit_handle" giá trị 32 bit trong đó:

- Số bit 3:0 DIMM trong kênh bộ nhớ
   - Số kênh nhớ bit 7:4
   - ID bộ điều khiển bộ nhớ Bit 11:8
   - Bit 15:12 ID ổ cắm (trong phạm vi của Bộ điều khiển nút nếu nút
     có bộ điều khiển)
   - Bit 27:16 ID bộ điều khiển nút
   - Bit 31:28 Dành riêng

::

cấu trúc tĩnh ndctl_dimm *get_dimm_by_handle(struct ndctl_bus *bus,
	       tay cầm int không dấu)
	{
		struct ndctl_dimm *dimm;

ndctl_dimm_foreach(bus, dimm)
			if (ndctl_dimm_get_handle(dimm) == xử lý)
				trở lại mờ;

trả lại NULL;
	}

#define DIMM_HANDLE(n, s, i, c, d) \
		(((n & 0xfff) << 16) ZZ0000ZZ ((i & 0xf) << 8) \
		 ZZ0001ZZ (d & 0xf))

dimm = get_dimm_by_handle(bus, DIMM_HANDLE(0, 0, 0, 0, 0));

LIBNVDIMM/LIBNDCTL: Khu vực
--------------------------

Một thiết bị REGION chung được đăng ký cho mỗi bộ xen kẽ PMEM /
phạm vi. Theo ví dụ, có 2 vùng PMEM trên "nfit_test.0"
xe buýt. Vai trò chính của các khu vực là trở thành nơi chứa "bản đồ".  A
ánh xạ là một bộ dữ liệu <DIMM, DPA-start-offset, length>.

LIBNVDIMM cung cấp trình điều khiển tích hợp cho các thiết bị REGION.  Người lái xe này
chịu trách nhiệm phân tích tất cả LABEL, nếu có, sau đó phát ra NAMESPACE
thiết bị để trình điều khiển nd_pmem sử dụng.

Ngoài các thuộc tính chung của "ánh xạ", "interleave_ways"
và "kích thước" thiết bị REGION cũng xuất ra một số thuộc tính tiện lợi.
"nstype" cho biết loại số nguyên của namespace-device vùng này
phát ra, "devtype" sao chép biến DEVTYPE được udev lưu trữ tại
sự kiện 'thêm', "modalias" sao chép biến MODALIAS được lưu trữ bởi udev
tại sự kiện 'thêm' và cuối cùng, "spa_index" tùy chọn được cung cấp trong
trường hợp vùng được xác định bởi SPA.

LIBNVDIMM: vùng::

cấu trúc nd_khu vực *nvdimm_pmem_region_create(struct nvdimm_bus *nvdimm_bus,
			cấu trúc nd_khu vực_desc *ndr_desc);

::

/sys/devices/platform/nfit_test.0/ndbus0
	|-- vùng0
	ZZ0001ZZ-- có sẵn_size
	ZZ0002ZZ-- btt0
	ZZ0003ZZ-- btt_seed
	ZZ0004ZZ-- devtype
	ZZ0005ZZ-- trình điều khiển -> ../../../../bus/nd/drivers/nd_zone
	ZZ0006ZZ-- init_namespaces
	ZZ0007ZZ-- ánh xạ0
	ZZ0008ZZ-- ánh xạ1
	ZZ0009ZZ-- ánh xạ
	ZZ0010ZZ-- phương thức
	ZZ0011ZZ-- không gian tên0.0
	ZZ0012ZZ-- không gian tên_seed
	ZZ0013ZZ-- numa_node
	ZZ0014ZZ-- nfit
	ZZ0015ZZ ZZ0000ZZ-- sự kiện
	|-- khu vực1
	[..]

LIBNDCTL: ví dụ về liệt kê vùng
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Các quy trình truy xuất vùng mẫu dựa trên dữ liệu duy nhất NFIT như
"spa_index" (id tập hợp xen kẽ).

::

cấu trúc tĩnh ndctl_khu vực *get_pmem_region_by_spa_index(struct ndctl_bus *bus,
			int không dấu spa_index)
	{
		struct ndctl_khu vực *khu vực;

ndctl_khu vực_foreach(xe buýt, khu vực) {
			if (ndctl_khu vực_get_type(khu vực) != ND_DEVICE_REGION_PMEM)
				tiếp tục;
			if (ndctl_khu vực_get_spa_index(vùng) == spa_index)
				vùng trở về;
		}
		trả lại NULL;
	}


LIBNVDIMM/LIBNDCTL: Không gian tên
-----------------------------

Một REGION, sau khi giải quyết các ranh giới, bề mặt được chỉ định của DPA và LABEL
một hoặc nhiều thiết bị "không gian tên".  Sự xuất hiện của một thiết bị "không gian tên" hiện nay
kích hoạt trình điều khiển nd_pmem tải và đăng ký thiết bị đĩa/khối.

LIBNVDIMM: không gian tên
^^^^^^^^^^^^^^^^^^^^

Đây là bố cục mẫu từ 2 loại NAMESPACE chính trong đó namespace0.0
đại diện cho DIMM được hỗ trợ bởi thông tin PMEM (lưu ý rằng nó có thuộc tính 'uuid') và
namespace1.0 đại diện cho một không gian tên PMEM ẩn danh (lưu ý rằng không có 'uuid'
thuộc tính do không hỗ trợ LABEL)

::

/sys/devices/platform/nfit_test.0/ndbus0/khu vực0/namespace0.0
	|-- alt_name
	|-- devtype
	|-- dpa_extents
	|-- ép_raw
	|-- phương thức
	|-- num_node
	|-- tài nguyên
	|-- kích thước
	|-- hệ thống con -> ../../../../../bus/nd
	|-- gõ
	|-- sự kiện
	ZZ0000ZZ-- pmem0
	|-- devtype
	|-- lái xe -> ../../../../../bus/nd/drivers/pmem
	|-- ép_raw
	|-- phương thức
	|-- num_node
	|-- tài nguyên
	|-- kích thước
	|-- hệ thống con -> ../../../../../bus/nd
	|-- gõ
	`-- sự kiện

LIBNDCTL: ví dụ về liệt kê không gian tên
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Các không gian tên được lập chỉ mục tương ứng với vùng cha của chúng, ví dụ bên dưới.
Các chỉ mục này chủ yếu là tĩnh từ lúc khởi động này sang lần khởi động khác, nhưng hệ thống con tạo ra
không có sự đảm bảo nào về vấn đề này.  Đối với một mã định danh không gian tên tĩnh, hãy sử dụng nó
thuộc tính 'uuid'.

::

cấu trúc tĩnh ndctl_namespace
  Vùng *get_namespace_by_id(struct ndctl_region *, id int không dấu)
  {
          struct ndctl_namespace *ndns;

ndctl_namespace_foreach(vùng, ndns)
                  if (ndctl_namespace_get_id(ndns) == id)
                          trả lại ndns;

trả lại NULL;
  }

LIBNDCTL: ví dụ về tạo không gian tên
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Các không gian tên nhàn rỗi được kernel tự động tạo nếu một
khu vực có đủ dung lượng khả dụng để tạo một không gian tên mới.
Việc khởi tạo không gian tên bao gồm việc tìm kiếm một không gian tên nhàn rỗi và
đang cấu hình nó.  Phần lớn việc thiết lập các thuộc tính không gian tên
có thể xảy ra theo bất kỳ thứ tự nào, hạn chế duy nhất là phải đặt 'uuid'
trước 'kích thước'.  Điều này cho phép kernel theo dõi phân bổ DPA
nội bộ với một mã định danh tĩnh::

int tĩnh configure_namespace(struct ndctl_khu vực *khu vực,
                  struct ndctl_namespace *ndns,
                  struct namespace_parameters *tham số)
  {
          char devname[50];

snprintf(devname, sizeof(devname), "namespace%d.%d",
                          ndctl_khu vực_get_id(vùng), tham số->id);

ndctl_namespace_set_alt_name(ndns, tên nhà phát triển);
          /* 'uuid' phải được đặt trước khi đặt kích thước! */
          ndctl_namespace_set_uuid(ndns, tham số->uuid);
          ndctl_namespace_set_size(ndns, tham số->kích thước);
          /* Không giống như không gian tên pmem, không gian tên blk có kích thước cung */
          if (tham số->lbasize)
                  ndctl_namespace_set_sector_size(ndns, tham số->lbasize);
          ndctl_namespace_enable(ndns);
  }


Tại sao thuật ngữ "không gian tên"?
^^^^^^^^^^^^^^^^^^^^^^^^^

1. Tại sao không dùng "âm lượng" chẳng hạn?  "khối lượng" có nguy cơ gây nhầm lẫn
       ND (hệ thống con libnvdimm) cho trình quản lý âm lượng như trình ánh xạ thiết bị.

2. Thuật ngữ này ra đời để mô tả các thiết bị phụ có thể được tạo ra
       trong bộ điều khiển NVME (xem thông số kỹ thuật của nvme:
       Không gian tên ZZ0000ZZ và NFIT là
       nhằm song song khả năng và khả năng cấu hình của
       Không gian tên NVME.


LIBNVDIMM/LIBNDCTL: Bảng dịch khối "btt"
-------------------------------------------------

BTT (tài liệu thiết kế: ZZ0000ZZ là một
trình điều khiển cá tính cho một không gian tên phía trước toàn bộ không gian tên dưới dạng
'trừu tượng hóa địa chỉ'.

LIBNVDIMM: bố cục btt
^^^^^^^^^^^^^^^^^^^^^

Mỗi khu vực sẽ bắt đầu với ít nhất một thiết bị BTT.
thiết bị hạt giống.  Để kích hoạt nó, hãy đặt "không gian tên", "uuid" và
thuộc tính "sector_size" và sau đó liên kết thiết bị với nd_pmem hoặc
Trình điều khiển nd_blk tùy thuộc vào loại khu vực::

/sys/devices/platform/nfit_test.1/ndbus0/khu vực0/btt0/
	|-- không gian tên
	|-- xóa
	|-- devtype
	|-- phương thức
	|-- num_node
	|-- kích thước ngành
	|-- hệ thống con -> ../../../../bus/nd
	|-- sự kiện
	`-- uuid

LIBNDCTL: ví dụ tạo btt
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Tương tự như không gian tên, một thiết bị BTT nhàn rỗi sẽ tự động được tạo mỗi
khu vực.  Mỗi lần thiết bị btt "hạt giống" này được định cấu hình và kích hoạt một thiết bị btt mới
hạt giống được tạo ra.  Tạo cấu hình BTT bao gồm hai bước
tìm và giải phóng BTT và gán nó để sử dụng một không gian tên.

::

cấu trúc tĩnh ndctl_btt *get_idle_btt(struct ndctl_region *zone)
	{
		struct ndctl_btt *btt;

ndctl_btt_foreach(vùng, btt)
			if (!ndctl_btt_is_enabled(btt)
					&& !ndctl_btt_is_configured(btt))
				trả lại btt;

trả lại NULL;
	}

int tĩnh configure_btt(struct ndctl_khu vực *khu vực,
			struct btt_parameters *tham số)
	{
		btt = get_idle_btt(khu vực);

ndctl_btt_set_uuid(btt, tham số->uuid);
		ndctl_btt_set_sector_size(btt, tham số->sector_size);
		ndctl_btt_set_namespace(btt, tham số->ndns);
		/*tắt thiết bị ở chế độ thô */
		ndctl_namespace_disable(tham số->ndns);
		/*bật quyền truy cập btt */
		ndctl_btt_enable(btt);
	}

Sau khi được khởi tạo, một thiết bị hạt giống btt không hoạt động mới sẽ xuất hiện bên dưới
khu vực.

Khi "không gian tên" bị xóa khỏi BTT, phiên bản đó của thiết bị BTT
sẽ bị xóa hoặc đặt lại về giá trị mặc định.  Việc xóa này là
chỉ ở cấp mẫu thiết bị.  Để tiêu diệt BTT, "thông tin
block" cần phải bị phá hủy.  Lưu ý rằng để tiêu diệt một BTT phương tiện truyền thông
cần phải được viết ở chế độ thô.  Theo mặc định, kernel sẽ tự động phát hiện
sự hiện diện của BTT và tắt chế độ thô.  Hành vi tự động phát hiện này
có thể bị chặn bằng cách bật chế độ thô cho không gian tên thông qua
ndctl_namespace_set_raw_mode() API.


Sơ đồ LIBNDCTL tóm tắt
------------------------

Đối với ví dụ đã cho ở trên, đây là khung nhìn của các đối tượng được nhìn thấy bởi
LIBNDCTL API::

+---+
              ZZ0000ZZ
              +-+-+
                |
  +-------+ |
  ZZ0001ZZ +----------+ +--------------+ +--------------+
  +-------+ ZZ0002ZZ +-> REGION0 +---> NAMESPACE0.0 +--> PMEM8 "pm0.0" |
  ZZ0003ZZ +----------+ +--------------+ +--------------+
  +-------+ +-+BUS0+-| +----------+ +--------------+ +----------------------+
  ZZ0004ZZ BTT1 |
  +-------+ ZZ0005ZZ +----------+ +--------------+ +--------------+------+
  | DIMM3 <-+
  +-------+
