.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/arch/powerpc/vas-api.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. _VAS-API:

========================================================
Không gian người dùng Tổng đài tăng tốc ảo (VAS) API
========================================================

Giới thiệu
============

Bộ xử lý Power9 đã giới thiệu Tổng đài tăng tốc ảo (VAS)
cho phép cả không gian người dùng và kernel giao tiếp với bộ đồng xử lý
(bộ tăng tốc phần cứng) được gọi là Bộ tăng tốc Nest (NX). NX
đơn vị bao gồm một hoặc nhiều động cơ phần cứng hoặc các loại bộ đồng xử lý
chẳng hạn như nén 842, nén và mã hóa GZIP. Trên nguồn9,
các ứng dụng không gian người dùng sẽ chỉ có quyền truy cập vào công cụ nén GZIP
hỗ trợ thuật toán nén ZLIB và GZIP trong phần cứng.

Để giao tiếp với NX, kernel phải thiết lập một kênh hoặc cửa sổ và
sau đó các yêu cầu có thể được gửi trực tiếp mà không cần sự tham gia của kernel.
Các yêu cầu tới công cụ GZIP phải được định dạng dưới dạng Yêu cầu đồng xử lý
Khối (CRB) và các CRB này phải được gửi tới NX bằng COPY/PASTE
hướng dẫn dán CRB vào địa chỉ phần cứng được liên kết với
hàng đợi yêu cầu của động cơ.

Công cụ GZIP cung cấp hai mức độ ưu tiên của yêu cầu: Bình thường và
Cao. Hiện tại, chỉ các yêu cầu Thông thường mới được hỗ trợ từ không gian người dùng.

Tài liệu này giải thích không gian người dùng API được sử dụng để tương tác với
kernel để thiết lập kênh/cửa sổ có thể được sử dụng để gửi nén
yêu cầu trực tiếp tới máy gia tốc NX.


Tổng quan
=========

Quyền truy cập ứng dụng vào công cụ GZIP được cung cấp thông qua
Nút thiết bị /dev/crypto/nx-gzip được triển khai bởi trình điều khiển thiết bị VAS/NX.
Ứng dụng phải mở thiết bị /dev/crypto/nx-gzip để lấy tệp
mô tả (fd). Sau đó nên phát hành VAS_TX_WIN_OPEN ioctl với fd này để
thiết lập kết nối với động cơ. Nó có nghĩa là cửa sổ gửi được mở trên GZIP
động cơ cho quá trình này. Sau khi kết nối được thiết lập, ứng dụng sẽ
nên sử dụng lệnh gọi hệ thống mmap() để ánh xạ địa chỉ phần cứng của động cơ
hàng đợi yêu cầu vào không gian địa chỉ ảo của ứng dụng.

Sau đó, ứng dụng có thể gửi một hoặc nhiều yêu cầu tới công cụ bằng cách
sử dụng hướng dẫn sao chép/dán và dán CRB vào địa chỉ ảo
(còn gọi là dán_address) được trả về bởi mmap(). Không gian người dùng có thể đóng
kết nối được thiết lập hoặc cửa sổ gửi bằng cách đóng bộ mô tả tệp
(đóng(fd)) hoặc khi thoát khỏi quá trình.

Lưu ý rằng các ứng dụng có thể gửi nhiều yêu cầu trong cùng một cửa sổ hoặc
có thể thiết lập nhiều cửa sổ, nhưng một cửa sổ cho mỗi bộ mô tả tệp.

Các phần sau đây cung cấp thêm chi tiết và tài liệu tham khảo về
các bước riêng lẻ.

Nút thiết bị NX-GZIP
====================

Có một nút /dev/crypto/nx-gzip trong hệ thống và nó cung cấp
truy cập vào tất cả các động cơ GZIP trong hệ thống. Các hoạt động hợp lệ duy nhất trên
/dev/crypto/nx-gzip là:

* open() thiết bị để đọc và ghi.
	* phát hành VAS_TX_WIN_OPEN ioctl
	* mmap() hàng đợi yêu cầu của công cụ vào ứng dụng ảo
	  không gian địa chỉ (tức là lấy Paste_address cho bộ đồng xử lý
	  động cơ).
	* đóng nút thiết bị.

Các thao tác tệp khác trên nút thiết bị này không được xác định.

Lưu ý rằng các thao tác sao chép và dán sẽ trực tiếp đến phần cứng và
không đi qua thiết bị này. Tham khảo tài liệu COPY/PASTE để biết thêm
chi tiết.

Mặc dù một hệ thống có thể có một số phiên bản của bộ đồng xử lý NX
động cơ (thông thường, một cho mỗi chip P9) chỉ có một
Nút thiết bị /dev/crypto/nx-gzip trong hệ thống. Khi thiết bị nx-gzip
nút được mở, Kernel sẽ mở cửa sổ gửi trên phiên bản NX phù hợp
máy gia tốc. Nó tìm thấy CPU mà tiến trình người dùng đang thực thi và
xác định phiên bản NX cho chip tương ứng mà CPU này sử dụng
thuộc về.

Các ứng dụng có thể chọn một phiên bản cụ thể của bộ đồng xử lý NX bằng cách sử dụng
trường vas_id trong VAS_TX_WIN_OPEN ioctl như chi tiết bên dưới.

Thư viện không gian người dùng libnxz có sẵn ở đây nhưng vẫn đang được phát triển:

ZZ0000ZZ

Các ứng dụng sử dụng lệnh gọi inflate/deflate có thể liên kết với libnxz
thay vì libz và sử dụng tính năng nén NX GZIP mà không cần sửa đổi gì.

Mở /dev/crypto/nx-gzip
========================

Thiết bị nx-gzip phải được mở để đọc và ghi. Không có gì đặc biệt
cần có đặc quyền để mở thiết bị. Mỗi cửa sổ tương ứng với một
bộ mô tả tập tin. Vì vậy, nếu quá trình không gian người dùng cần nhiều cửa sổ,
một số cuộc gọi mở phải được thực hiện.

Xem các trang hướng dẫn gọi hệ thống open(2) để biết các chi tiết khác như giá trị trả về,
mã lỗi và hạn chế.

VAS_TX_WIN_OPEN ioctl
=====================

Các ứng dụng nên sử dụng VAS_TX_WIN_OPEN ioctl như sau để thiết lập
kết nối với công cụ đồng xử lý NX:

	::

cấu trúc vas_tx_win_open_attr {
			__u32 phiên bản;
			__s16 vas_id; /* trường hợp cụ thể của vas hoặc -1
						mặc định */
			__u16 dành riêng1;
			__u64 cờ;	/* Để sử dụng sau này */
			__u64 dành riêng2[6];
		};

phiên bản:
		Trường phiên bản hiện phải được đặt thành 1.
	vas_id:
		Nếu '-1' được thông qua, kernel sẽ nỗ lực hết sức
		để chỉ định một phiên bản NX tối ưu cho quy trình. Đến
		chọn phiên bản VAS cụ thể, tham khảo
		Phần "Khám phá các động cơ VAS có sẵn" bên dưới.

các trường cờ, dành riêng1 và dành riêng2 [6] dành cho phần mở rộng trong tương lai
	và phải được đặt thành 0.

Các thuộc tính attr cho VAS_TX_WIN_OPEN ioctl được định nghĩa là
	sau::

#define VAS_MAGIC 'v'
		#define VAS_TX_WIN_OPEN _IOW(VAS_MAGIC, 1,
						cấu trúc vas_tx_win_open_attr)

struct vas_tx_win_open_attr attr;
		rc = ioctl(fd, VAS_TX_WIN_OPEN, &attr);

VAS_TX_WIN_OPEN ioctl trả về 0 khi thành công. Về lỗi, nó
	trả về -1 và đặt biến errno để chỉ ra lỗi.

Điều kiện lỗi:

====== =====================================================
		EINVAL fd không đề cập đến thiết bị VAS hợp lệ.
		EINVAL ID vas không hợp lệ
		Phiên bản EINVAL không được đặt giá trị phù hợp
		Cửa sổ EEXIST đã được mở cho fd đã cho
		ENOMEM Bộ nhớ không có sẵn để phân bổ cửa sổ
		Hệ thống ENOSPC có quá nhiều cửa sổ (kết nối) đang hoạt động
			đã mở
		Các trường dành riêng EINVAL không được đặt thành 0.
		====== =====================================================

Xem trang man ioctl(2) để biết thêm chi tiết, mã lỗi và
	hạn chế.

thiết bị mmap() NX-GZIP
=======================

Lệnh gọi hệ thống mmap() cho thiết bị NX-GZIP fd trả về Paste_address
mà ứng dụng có thể sử dụng để sao chép/dán CRB của nó vào công cụ phần cứng.

	::

dán_addr = mmap(addr, size, prot, flags, fd, offset);

Chỉ những hạn chế về mmap đối với fd thiết bị NX-GZIP là:

* kích thước phải là PAGE_SIZE
		* tham số offset phải là 0ULL

Tham khảo trang man mmap(2) để biết thêm chi tiết/hạn chế.
	Ngoài các điều kiện lỗi được liệt kê trên man mmap(2)
	trang, cũng có thể bị lỗi với một trong các mã lỗi sau:

====== =================================================
		EINVAL fd không được liên kết với cửa sổ đang mở
			(tức là mmap() không thực hiện cuộc gọi thành công
			đến VAS_TX_WIN_OPEN ioctl).
		Trường offset EINVAL không phải là 0ULL.
		====== =================================================

Khám phá các động cơ VAS có sẵn
==================================

Mỗi phiên bản VAS có sẵn trong hệ thống sẽ có một nút cây thiết bị
như /proc/device-tree/vas@* hoặc /proc/device-tree/xscom@ZZ0000ZZ.
Xác định chip hoặc phiên bản VAS và sử dụng ibm,vas-id tương ứng
giá trị thuộc tính trong nút này để chọn phiên bản VAS cụ thể.

Thao tác sao chép/dán
=====================

Các ứng dụng nên sử dụng hướng dẫn sao chép và dán để gửi CRB tới NX.
Tham khảo phần 4.4 trong PowerISA để biết hướng dẫn Sao chép/Dán:
ZZ0000ZZ

Thông số kỹ thuật và sử dụng CRB NX
===================================

Các ứng dụng nên định dạng các yêu cầu tới bộ đồng xử lý bằng cách sử dụng
Khối yêu cầu đồng xử lý (CRB). Tham khảo hướng dẫn sử dụng NX-GZIP để biết định dạng
của CRB và sử dụng NX từ không gian người dùng như gửi yêu cầu và kiểm tra
trạng thái yêu cầu.

Xử lý lỗi NX
=================

Các ứng dụng gửi yêu cầu tới NX và chờ trạng thái bằng cách bỏ phiếu trên
cờ trạng thái khối đồng xử lý (CSB). NX cập nhật trạng thái trong CSB sau mỗi lần
yêu cầu được xử lý. Tham khảo hướng dẫn sử dụng NX-GZIP để biết định dạng của CSB và
các cờ trạng thái

Trường hợp nếu NX gặp lỗi dịch thuật (gọi là lỗi trang NX) trên CSB
địa chỉ hoặc bất kỳ bộ đệm yêu cầu nào, sẽ tạo ra một ngắt trên CPU để xử lý
lỗi. Lỗi trang có thể xảy ra nếu một ứng dụng chuyển các địa chỉ không hợp lệ hoặc
bộ đệm yêu cầu không có trong bộ nhớ. Hệ điều hành xử lý lỗi bằng cách
đang cập nhật CSB với dữ liệu sau::

csb.flags = CSB_V;
	csb.cc = CSB_CC_FAULT_ADDRESS;
	csb.ce = CSB_CE_TERMINATION;
	csb.address = error_address;

Khi một ứng dụng nhận được lỗi dịch thuật, nó có thể chạm hoặc truy cập
trang có địa chỉ lỗi để trang này nằm trong bộ nhớ. Sau đó
ứng dụng có thể gửi lại yêu cầu này tới NX.

Nếu HĐH không thể cập nhật CSB do địa chỉ CSB không hợp lệ, hãy gửi tín hiệu SEGV
to the process who opened the send window on which the original request was
ban hành. Tín hiệu này trả về với cấu trúc siginfo sau::

siginfo.si_signo = SIGSEGV;
	siginfo.si_errno = EFAULT;
	siginfo.si_code = SEGV_MAPERR;
	siginfo.si_addr = địa chỉ CSB;

Trong trường hợp ứng dụng đa luồng, NX gửi windows có thể được chia sẻ
trên tất cả các chủ đề. Ví dụ, một thread con có thể mở một cửa sổ gửi,
nhưng các luồng khác có thể gửi yêu cầu tới NX bằng cửa sổ này. Những cái này
các yêu cầu sẽ thành công ngay cả trong trường hợp lỗi xử lý hệ điều hành miễn là
vì địa chỉ CSB là hợp lệ. Nếu yêu cầu NX chứa địa chỉ CSB không hợp lệ,
tín hiệu sẽ được gửi đến chuỗi con đã mở cửa sổ. Nhưng nếu
luồng được thoát mà không đóng cửa sổ và yêu cầu được đưa ra
sử dụng cửa sổ này. tín hiệu sẽ được cấp cho người đứng đầu nhóm chủ đề
(tgid). Việc bỏ qua hay xử lý những điều này là tùy thuộc vào ứng dụng.
tín hiệu.

Hướng dẫn sử dụng NX-GZIP:
ZZ0000ZZ

Ví dụ đơn giản
==============

	::

int use_nx_gzip()
		{
			int rc, fd;
			void *addr;
			struct vas_setup_attr txattr;

fd = open("/dev/crypto/nx-gzip", O_RDWR);
			nếu (fd < 0) {
				fprintf(stderr, "mở nx-gzip không thành công\n");
				trả về -1;
			}
			bộ nhớ(&txattr, 0, sizeof(txattr));
			txtattr.version = 1;
			txattr.vas_id = -1
			rc = ioctl(fd, VAS_TX_WIN_OPEN,
					(dài không dấu)&txattr);
			nếu (rc < 0) {
				fprintf(stderr, "ioctl() n %d, lỗi %d\n",
						rc, lỗi);
				trả lại rc;
			}
			addr = mmap(NULL, 4096, PROT_READ|PROT_WRITE,
					MAP_SHARED, fd, 0ULL);
			nếu (addr == MAP_FAILED) {
				fprintf(stderr, "mmap() không thành công, errno %d\n",
						không có);
				return -errno;
			}
			làm {
				// Định dạng yêu cầu CRB có nén hoặc
				// giải nén
				// Tham khảo bài kiểm tra vas_copy/vas_paste
				vas_copy((&crb, 0, 1);
				vas_paste(addr, 0, 1);
				// Thăm dò ý kiến trên csb.flags khi hết thời gian chờ
				// địa chỉ csb được liệt kê trong CRB
			} trong khi (đúng)
			close(fd) hoặc cửa sổ có thể được đóng khi thoát quá trình
		}

Tham khảo ZZ0000ZZ để kiểm tra hoặc hơn thế nữa
	trường hợp sử dụng.