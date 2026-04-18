.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/arch/arm/tcm.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

======================================================
Xử lý ARM TCM (Bộ nhớ được ghép chặt chẽ) trong Linux
==================================================

Viết bởi Linus Walleij <linus.walleij@stericsson.com>

Một số SoC ARM có cái gọi là TCM (Bộ nhớ được ghép chặt chẽ).
Đây thường chỉ là một vài (4-64) KiB của RAM bên trong ARM
bộ xử lý.

Do được nhúng bên trong CPU nên TCM có
Kiến trúc Harvard nên có ITCM (hướng dẫn TCM)
và DTCM (dữ liệu TCM). DTCM không thể chứa bất kỳ
hướng dẫn, nhưng ITCM thực sự có thể chứa dữ liệu.
Kích thước của DTCM hoặc ITCM tối thiểu là 4KiB nên thông thường
cấu hình tối thiểu là 4KiB ITCM và 4KiB DTCM.

CPU ARM có các thanh ghi đặc biệt để đọc trạng thái, vật lý
vị trí và kích thước của bộ nhớ TCM. Arch/arm/include/asm/cputype.h
định nghĩa một thanh ghi CPUID_TCM mà bạn có thể đọc từ
bộ đồng xử lý điều khiển hệ thống. Có thể tìm thấy tài liệu từ ARM
tại ZZ0000ZZ tìm kiếm "Đăng ký trạng thái TCM"
để xem tài liệu cho tất cả các CPU. Đọc đăng ký này bạn có thể
xác định xem có tồn tại ITCM (bit 1-0) và/hoặc DTCM (bit 17-16) hay không
trong máy.

Ngoài ra còn có một thanh ghi vùng TCM (tìm kiếm "TCM Region
Đăng ký" tại trang ARM) có thể báo cáo và sửa đổi vị trí
kích thước của bộ nhớ TCM khi chạy. Điều này được sử dụng để đọc và sửa đổi
Vị trí và kích thước của TCM. Lưu ý rằng đây không phải là bảng MMU: bạn
thực sự di chuyển vị trí vật lý của TCM xung quanh. Tại
nơi bạn đặt nó, nó sẽ che giấu mọi RAM cơ bản khỏi
CPU vì vậy thông thường không nên chồng chéo bất kỳ RAM vật lý nào với
TCM.

Bộ nhớ TCM sau đó có thể được ánh xạ lại tới một địa chỉ khác bằng cách sử dụng
MMU, nhưng lưu ý rằng TCM thường được sử dụng trong các tình huống
MMU bị tắt. Để tránh nhầm lẫn Linux hiện tại
việc triển khai sẽ ánh xạ TCM 1 thành 1 từ vật lý sang ảo
bộ nhớ ở vị trí được chỉ định bởi kernel. Hiện nay Linux
sẽ ánh xạ ITCM thành 0xfffe0000 trở đi và DTCM thành 0xfffe8000 và
bật, hỗ trợ tối đa 32KiB của ITCM và 32KiB của DTCM.

Các phiên bản mới hơn của thanh ghi vùng cũng hỗ trợ việc phân chia chúng
TCM ở hai ngân hàng riêng biệt, ví dụ như 8KiB ITCM được chia
thành hai ngân hàng 4KiB với các thanh ghi kiểm soát riêng. Ý tưởng là để
có thể khóa và ẩn một trong các ngân hàng để sử dụng an toàn
thế giới (TrustZone).

TCM được sử dụng cho một số mục đích:

- FIQ và các trình xử lý ngắt khác cần tính xác định
  thời gian và không thể đợi lỗi bộ đệm.

- Vòng lặp nhàn rỗi trong đó tất cả RAM bên ngoài được đặt thành tự làm mới
  chế độ lưu giữ, do đó chỉ RAM trên chip mới có thể truy cập được bằng
  CPU và sau đó chúng tôi treo bên trong ITCM để chờ
  ngắt lời.

- Các hoạt động khác liên quan đến việc tắt hoặc cấu hình lại
  bộ điều khiển RAM bên ngoài.

Có giao diện để sử dụng TCM trên kiến trúc ARM
trong <asm/tcm.h>. Sử dụng giao diện này có thể:

- Xác định địa chỉ vật lý và kích thước của ITCM và DTCM.

- Chức năng thẻ được biên dịch thành ITCM.

- Dữ liệu thẻ và hằng số được phân bổ cho DTCM và ITCM.

- Thêm TCM RAM còn lại vào gói đặc biệt
  nhóm phân bổ với gen_pool_create() và gen_pool_add()
  và cung cấp tcm_alloc() và tcm_free() cho việc này
  trí nhớ. Một đống như vậy thật tuyệt vời cho những việc như tiết kiệm
  trạng thái thiết bị khi tắt miền nguồn của thiết bị.

Máy có bộ nhớ TCM sẽ chọn HAVE_TCM từ
Arch/arm/Kconfig cho chính nó. Mã cần sử dụng TCM thì
#include <asm/tcm.h>

Các hàm đi vào itcm có thể được gắn thẻ như thế này:
int __tcmfunc foo(int bar);

Vì chúng được đánh dấu để trở thành long_calls và bạn có thể muốn
để có các hàm được gọi cục bộ bên trong TCM mà không cần
lãng phí dung lượng, còn có tiền tố __tcmlocalfunc
sẽ làm cho cuộc gọi tương đối.

Các biến đi vào dtcm có thể được gắn thẻ như thế này ::

int __tcmdata foo;

Các hằng số có thể được gắn thẻ như thế này::

int __tcmconst foo;

Để đặt trình biên dịch mã vào TCM, chỉ cần sử dụng ::

.section ".tcm.text" hoặc .section ".tcm.data"

tương ứng.

Mã ví dụ::

#include <asm/tcm.h>

/*Dữ liệu chưa được khởi tạo */
  u32 tĩnh __tcmdata tcmvar;
  /*Dữ liệu được khởi tạo */
  u32 tĩnh __tcmdata tcm được gán = 0x2BADBABEU;
  /* Hằng số */
  const tĩnh u32 __tcmconst tcmconst = 0xCAFEBABEU;

khoảng trống tĩnh __tcmlocalfunc tcm_to_tcm(void)
  {
	int tôi;
	cho (i = 0; tôi < 100; i++)
		tcmvar++;
  }

khoảng trống tĩnh __tcmfunc hello_tcm(void)
  {
	/* Một số mã trừu tượng chạy trong ITCM */
	int tôi;
	vì (i = 0; i < 100; i++) {
		tcmvar++;
	}
	tcm_to_tcm();
  }

khoảng trống tĩnh __init test_tcm(void)
  {
	u32 *tcmem;
	int tôi;

xin chào_tcm();
	printk("Xin chào TCM được thực thi từ ITCM RAM\n");

printk("Biến TCM từ lần chạy thử: %u @ %p\n", tcmvar, &tcmvar);
	tcmvar = 0xDEADBEEFU;
	printk("Biến TCM: 0x%x @ %p\n", tcmvar, &tcmvar);

printk("Biến được gán TCM: 0x%x @ %p\n", tcm được gán, &tcm được gán);

printk("Hằng số TCM: 0x%x @ %p\n", tcmconst, &tcmconst);

/* Phân bổ một số bộ nhớ TCM từ nhóm */
	tcmem = tcm_alloc(20);
	nếu (tcmem) {
		printk("TCM Đã phân bổ 20 byte của TCM @ %p\n", tcmem);
		tcmem[0] = 0xDEADBEEFU;
		tcmem[1] = 0x2BADBABEU;
		tcmem[2] = 0xCAFEBABEU;
		tcmem[3] = 0xDEADBEEFU;
		tcmem[4] = 0x2BADBABEU;
		vì (i = 0; i < 5; i++)
			printk("TCM tcmem[%d] = %08x\n", i, tcmem[i]);
		tcm_free(tcmem, 20);
	}
  }
