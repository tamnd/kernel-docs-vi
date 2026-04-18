.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/arch/arm/memory.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

====================================
Bố cục bộ nhớ hạt nhân trên ARM Linux
=================================

Vua Russell <rmk@arm.linux.org.uk>

17 tháng 11 năm 2005 (2.6.15)

Tài liệu này mô tả cách bố trí bộ nhớ ảo mà Linux
sử dụng kernel cho bộ xử lý ARM.  Nó chỉ ra những khu vực nào
miễn phí cho các nền tảng sử dụng và được sử dụng theo mã chung.

ARM CPU có khả năng giải quyết tối đa bộ nhớ ảo 4GB
không gian và điều này phải được chia sẻ giữa các quy trình không gian người dùng,
hạt nhân và các thiết bị phần cứng.

Khi kiến trúc ARM hoàn thiện, cần phải dự trữ
một số vùng không gian VM nhất định để sử dụng cho các cơ sở mới; do đó
tài liệu này có thể dành nhiều dung lượng VM hơn theo thời gian.

================ ===================================================================
Bắt đầu sử dụng cuối cùng
================ ===================================================================
ffff8000 ffffffff copy_user_page/clear_user_page sử dụng.
				Đối với SA11xx và Xscale, điều này được sử dụng để
				thiết lập ánh xạ minicache.

Bí danh bộ đệm ffff4000 ffffffff trên CPU ARMv6 trở lên.

ffff1000 ffff7fff Dành riêng.
				Nền tảng không được sử dụng dải địa chỉ này.

Trang vectơ ffff0000 ffff0fff CPU.
				Các vectơ CPU được ánh xạ ở đây nếu
				CPU hỗ trợ định vị lại vector (điều khiển
				đăng ký bit V.)

fffe0000 fffeffff Vùng xóa bộ đệm XScale.  Cái này được sử dụng
				trong proc-xscale.S để xóa toàn bộ dữ liệu
				bộ đệm. (XScale không có TCM.)

khu vực ánh xạ fffe8000 fffeffff DTCM dành cho các nền tảng có
				DTCM được gắn bên trong CPU.

fffe0000 fffe7fff ITCM khu vực lập bản đồ cho các nền tảng có
				ITCM được gắn bên trong CPU.

ffc80000 feffffff Bản đồ cố định vùng.  Địa chỉ được cung cấp
				bởi fix_to_virt() sẽ được đặt ở đây.

ffc00000 ffc7ffff Vùng bảo vệ

ff800000 ffbffffff Ánh xạ chỉ đọc cố định, cố định của
				phần mềm được cung cấp DT blob

charge00000 feffffff Ánh xạ không gian I/O PCI. Đây là tĩnh
				ánh xạ trong không gian vmalloc.

Không gian VMALLOC_START VMALLOC_END-1 vmalloc() / ioremap().
				Bộ nhớ được trả về bởi vmalloc/ioremap sẽ
				được đặt động trong khu vực này.
				Ánh xạ tĩnh cụ thể của máy cũng được
				nằm ở đây thông qua iotable_init().
				VMALLOC_START dựa trên giá trị
				của biến high_memory và VMALLOC_END
				bằng 0xff800000.

PAGE_OFFSET high_memory-1 Vùng RAM được ánh xạ trực tiếp hạt nhân.
				Điều này ánh xạ các nền tảng RAM và thường
				ánh xạ tất cả nền tảng RAM theo mối quan hệ 1:1.

PKMAP_BASE PAGE_OFFSET-1 Ánh xạ hạt nhân vĩnh viễn
				Một cách ánh xạ các trang HIGHMEM vào kernel
				không gian.

Không gian mô-đun hạt nhân MODULES_VADDR MODULES_END-1
				Các mô-đun hạt nhân được chèn qua insmod là
				được đặt ở đây bằng cách sử dụng ánh xạ động.

TASK_SIZE MODULES_VADDR-1 KASan bộ nhớ bóng khi KASan đang được sử dụng.
				Phạm vi từ MODULES_VADDR đến đỉnh
				của bộ nhớ bị che khuất ở đây với 1 bit
				trên mỗi byte bộ nhớ.

00001000 TASK_SIZE-1 Ánh xạ không gian người dùng
				Ánh xạ trên mỗi luồng được đặt ở đây thông qua
				cuộc gọi hệ thống mmap().

00000000 00000fff Trang vectơ CPU / bẫy con trỏ null
				CPU không hỗ trợ ánh xạ lại vector
				đặt trang vector của họ ở đây.  Con trỏ NULL
				sự hủy đăng ký của cả kernel và người dùng
				không gian cũng được nắm bắt thông qua ánh xạ này.
================ ===================================================================

Xin lưu ý rằng các bản đồ va chạm với các khu vực trên có thể dẫn đến
trong hạt nhân không khởi động được hoặc có thể khiến hạt nhân (cuối cùng) bị hoảng loạn
vào thời gian chạy.

Vì các CPU trong tương lai có thể ảnh hưởng đến bố cục ánh xạ hạt nhân, các chương trình người dùng
không được truy cập bất kỳ bộ nhớ nào không được ánh xạ bên trong 0x0001000 của họ
đến phạm vi địa chỉ TASK_SIZE.  Nếu họ muốn truy cập vào những khu vực này, họ
phải thiết lập ánh xạ của riêng mình bằng open() và mmap().
