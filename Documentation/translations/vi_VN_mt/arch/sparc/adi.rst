.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/arch/sparc/adi.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

====================================
Tính toàn vẹn dữ liệu ứng dụng (ADI)
====================================

Bộ xử lý SPARC M7 bổ sung tính năng Toàn vẹn dữ liệu ứng dụng (ADI).
ADI cho phép tác vụ đặt thẻ phiên bản trên bất kỳ tập hợp con nào của địa chỉ của nó
không gian. Khi ADI được bật và thẻ phiên bản được đặt cho phạm vi
không gian địa chỉ của một tác vụ, bộ xử lý sẽ so sánh thẻ trong con trỏ
vào bộ nhớ trong các phạm vi này vào phiên bản do ứng dụng đặt
trước đó. Quyền truy cập vào bộ nhớ chỉ được cấp nếu thẻ trong con trỏ đã cho
khớp với thẻ do ứng dụng đặt. Trong trường hợp không khớp, bộ xử lý
đưa ra một ngoại lệ.

Tác vụ phải thực hiện các bước sau để kích hoạt đầy đủ ADI:

1. Đặt bit PSTATE.mcde ở chế độ người dùng. Điều này hoạt động như công tắc chính cho
   toàn bộ không gian địa chỉ của tác vụ để bật/tắt ADI cho tác vụ.

2. Đặt bit TTE.mcd trên bất kỳ mục TLB nào tương ứng với phạm vi
   địa chỉ ADI đang được kích hoạt. MMU chỉ kiểm tra thẻ phiên bản
   trên các trang có tập bit TTE.mcd.

3. Đặt thẻ phiên bản cho địa chỉ ảo bằng lệnh stxa
   và một trong những ASI dành riêng cho MCD. Mỗi lệnh stxa thiết lập
   thẻ đã cho cho một số byte kích thước khối ADI. Bước này phải
   được lặp lại cho toàn bộ trang để đặt thẻ cho toàn bộ trang.

Kích thước khối ADI cho nền tảng được cung cấp bởi bộ ảo hóa cho kernel
trong bảng mô tả máy. Hypervisor cũng cung cấp số lượng
các bit trên cùng trong địa chỉ ảo chỉ định thẻ phiên bản.  Một lần
thẻ phiên bản đã được đặt cho một vị trí bộ nhớ, thẻ được lưu trữ trong
bộ nhớ vật lý và cùng một thẻ phải có trong thẻ phiên bản ADI
các bit của địa chỉ ảo được đưa tới MMU. Ví dụ trên
Bộ xử lý SPARC M7, MMU sử dụng bit 63-60 cho thẻ phiên bản và khối ADI
kích thước tương tự như kích thước bộ đệm là 64 byte. Nhiệm vụ đặt ADI
phiên bản, chẳng hạn như 10, trên một phạm vi bộ nhớ, phải truy cập bộ nhớ đó bằng cách sử dụng
địa chỉ ảo chứa 0xa ở bit 63-60.

ADI được bật trên một nhóm trang sử dụng mprotect() với cờ PROT_ADI.
Khi ADI được bật trên một tập hợp các trang bởi một tác vụ lần đầu tiên,
kernel đặt bit PSTATE.mcde cho tác vụ. Thẻ phiên bản cho bộ nhớ
địa chỉ được đặt bằng lệnh stxa trên các địa chỉ bằng cách sử dụng
ASI_MCD_PRIMARY hoặc ASI_MCD_ST_BLKINIT_PRIMARY. Kích thước khối ADI là
được cung cấp bởi hypervisor cho kernel.  Kernel trả về giá trị của
Kích thước khối ADI cho không gian người dùng sử dụng vectơ phụ trợ cùng với ADI khác
thông tin. Các vectơ phụ trợ sau đây được cung cấp bởi kernel:

============================================================
	Kích thước khối AT_ADI_BLKSZ ADI. Đây là mức độ chi tiết và
			căn chỉnh, tính bằng byte, của phiên bản ADI.
	AT_ADI_NBITS Số bit phiên bản ADI trong VA
	============================================================


IMPORTANT NOTES
===============

- Giá trị thẻ phiên bản 0x0 và 0xf được bảo lưu. Những giá trị này phù hợp với bất kỳ
  trong địa chỉ ảo và không bao giờ tạo ra ngoại lệ không khớp.

- Thẻ phiên bản được đặt trên địa chỉ ảo từ không gian người dùng mặc dù
  các thẻ được lưu trữ trong bộ nhớ vật lý. Thẻ được đặt trên một trang vật lý
  sau khi nó được phân bổ cho một nhiệm vụ và một pte đã được tạo cho
  nó.

- Khi một tác vụ giải phóng một trang bộ nhớ, nó đã đặt các thẻ phiên bản trên đó, trang đó
  quay trở lại nhóm trang miễn phí. Khi trang này được phân bổ lại cho một tác vụ,
  kernel xóa trang bằng cách sử dụng khởi tạo khối ASI để xóa trang
  thẻ phiên bản cho trang đó. Nếu một trang được phân bổ cho một tác vụ
  được giải phóng và phân bổ trở lại nhiệm vụ tương tự, các thẻ phiên bản cũ được thiết lập bởi
  nhiệm vụ trên trang đó sẽ không còn nữa.

- Không phát hiện được sự không khớp của thẻ ADI đối với các tải không bị lỗi.

- Kernel không đặt bất kỳ thẻ nào cho trang người dùng và nó hoàn toàn là một
  trách nhiệm của nhiệm vụ là đặt bất kỳ thẻ phiên bản nào. Hạt nhân đảm bảo
  thẻ phiên bản được giữ nguyên nếu một trang được hoán đổi vào đĩa và
  được hoán đổi trở lại. Nó cũng giữ nguyên các thẻ phiên bản đó nếu một trang được
  đã di cư.

- ADI hoạt động với mọi kích thước trang. Một tác vụ không gian người dùng không cần phải biết
  kích thước trang khi sử dụng ADI. Nó có thể chỉ cần chọn một địa chỉ ảo
  phạm vi, bật ADI trên phạm vi bằng mprotect() và đặt thẻ phiên bản
  cho toàn bộ phạm vi. mprotect() đảm bảo phạm vi được căn chỉnh theo kích thước trang
  và là bội số của kích thước trang.

- Thẻ ADI chỉ có thể được đặt trên bộ nhớ có thể ghi. Ví dụ: thẻ ADI có thể
  không được đặt trên ánh xạ chỉ đọc.



Bẫy liên quan đến ADI
=====================

Khi bật ADI, các bẫy mới sau có thể xảy ra:

Phá vỡ tham nhũng bộ nhớ
----------------------------

Khi một cửa hàng truy cập vào vị trí bộ nhớ có TTE.mcd=1,
	tác vụ đang chạy với ADI được bật (PSTATE.mcde=1) và ADI
	thẻ trong địa chỉ được sử dụng (bit 63:60) không khớp với thẻ được đặt trên
	cacheline tương ứng, bẫy hỏng bộ nhớ sẽ xảy ra. Bởi
	mặc định, đó là một cái bẫy gây gián đoạn và được gửi đến bộ ảo hóa
	đầu tiên. Hypervisor tạo báo cáo lỗi sun4v và gửi
	bẫy lỗi có thể tiếp tục (TT=0x7e) vào kernel. Hạt nhân gửi
	SIGSEGV vào nhiệm vụ dẫn đến cái bẫy này với nội dung sau
	thông tin::

siginfo.si_signo = SIGSEGV;
		siginfo.errno = 0;
		siginfo.si_code = SEGV_ADIDERR;
		siginfo.si_addr = addr; /* PC nơi xảy ra sự không khớp đầu tiên */
		siginfo.si_trapno = 0;


Lỗi bộ nhớ chính xác
-------------------------

Khi một cửa hàng truy cập vào vị trí bộ nhớ có TTE.mcd=1,
	tác vụ đang chạy với ADI được bật (PSTATE.mcde=1) và ADI
	thẻ trong địa chỉ được sử dụng (bit 63:60) không khớp với thẻ được đặt trên
	cacheline tương ứng, bẫy hỏng bộ nhớ sẽ xảy ra. Nếu
	Ngoại lệ chính xác MCD được bật (MCDPERR=1), một ngoại lệ chính xác
	ngoại lệ được gửi tới kernel với TT=0x1a. Hạt nhân gửi
	SIGSEGV vào nhiệm vụ dẫn đến cái bẫy này với nội dung sau
	thông tin::

siginfo.si_signo = SIGSEGV;
		siginfo.errno = 0;
		siginfo.si_code = SEGV_ADIPERR;
		siginfo.si_addr = addr;	/*địa chỉ gây ra bẫy */
		siginfo.si_trapno = 0;

NOTE:
		Thẻ ADI không khớp trên tải luôn dẫn đến bẫy chính xác.


MCD bị vô hiệu hóa
------------------

Khi tác vụ chưa kích hoạt ADI và cố gắng đặt phiên bản ADI
	trên địa chỉ bộ nhớ, bộ xử lý sẽ gửi bẫy bị vô hiệu hóa MCD. Cái này
	bẫy được xử lý bởi hypervisor trước tiên và các vectơ hypervisor này
	bẫy xuyên qua kernel dưới dạng bẫy ngoại lệ truy cập dữ liệu với
	loại lỗi được đặt thành 0xa (ASI không hợp lệ). Khi điều này xảy ra, hạt nhân
	gửi tín hiệu SIGSEGV nhiệm vụ với thông tin sau::

siginfo.si_signo = SIGSEGV;
		siginfo.errno = 0;
		siginfo.si_code = SEGV_ACCADI;
		siginfo.si_addr = addr;	/*địa chỉ gây ra bẫy */
		siginfo.si_trapno = 0;


Chương trình mẫu để sử dụng ADI
-------------------------------

Chương trình mẫu sau đây nhằm minh họa cách sử dụng ADI
chức năng::

#include <unistd.h>
  #include <stdio.h>
  #include <stdlib.h>
  #include <elf.h>
  #include <sys/ipc.h>
  #include <sys/shm.h>
  #include <sys/mman.h>
  #include <asm/asi.h>

#ifndef AT_ADI_BLKSZ
  #define AT_ADI_BLKSZ 48
  #endif
  #ifndef AT_ADI_NBITS
  #define AT_ADI_NBITS 49
  #endif

#ifndef PROT_ADI
  #define PROT_ADI 0x10
  #endif

#define BUFFER_SIZE 32*1024*1024UL

main(int argc, char* argv[], char* envp[])
  {
          không dấu dài i, mcde, adi_blksz, adi_nbits;
          char *shmaddr, *tmp_addr, *end, *veraddr, *clraddr;
          int shmid, phiên bản;
	Elf64_auxv_t *auxv;

adi_blksz = 0;

while(*envp++ != NULL);
	cho (auxv = (Elf64_auxv_t *)envp; auxv->a_type != AT_NULL; auxv++) {
		chuyển đổi (auxv->a_type) {
		vỏ AT_ADI_BLKSZ:
			adi_blksz = auxv->a_un.a_val;
			phá vỡ;
		vỏ AT_ADI_NBITS:
			adi_nbits = auxv->a_un.a_val;
			phá vỡ;
		}
	}
	nếu (adi_blksz == 0) {
		fprintf(stderr, "Rất tiếc! ADI không được hỗ trợ\n");
		thoát (1);
	}

printf("Khả năng của ADI:\n");
	printf("\tKích thước khối = %ld\n", adi_blksz);
	printf("\tSố bit = %ld\n", adi_nbits);

if ((shmid = shmget(2, BUFFER_SIZE,
                                  IPC_CREAT ZZ0000ZZ SHM_W)) < 0) {
                  perror("shmget thất bại");
                  thoát (1);
          }

shmaddr = shmat(shmid, NULL, 0);
          if (shmaddr == (char *)-1) {
                  perror("shm đính kèm không thành công");
                  shmctl(shmid, IPC_RMID, NULL);
                  thoát (1);
          }

if (mprotect(shmaddr, BUFFER_SIZE, PROT_READZZ0000ZZPROT_ADI)) {
		perror("mprotect thất bại");
		đi đến err_out;
	}

/* Đặt thẻ phiên bản ADI trên phân đoạn shm
           */
          phiên bản = 10;
          tmp_addr = shmaddr;
          kết thúc = shmaddr + BUFFER_SIZE;
          trong khi (tmp_addr < kết thúc) {
                  asm dễ bay hơi(
                          "stxa %1, [%0]0x90\n\t"
                          :
                          : "r" (tmp_addr), "r" (phiên bản));
                  tmp_addr += adi_blksz;
          }
	asm dễ bay hơi ("thành viên #Sync\n\t");

/* Tạo một địa chỉ được phiên bản từ địa chỉ bình thường bằng cách đặt
	 * thẻ phiên bản ở bit adi_nbits phía trên
           */
          tmp_addr = (void *) ((unsigned long)shmaddr << adi_nbits);
          tmp_addr = (void *) ((unsigned long)tmp_addr >> adi_nbits);
          veraddr = (void *) (((unsigned long)version << (64-adi_nbits))
                          | (dài không dấu)tmp_addr);

printf("Bắt đầu ghi:\n");
          cho (i = 0; tôi < BUFFER_SIZE; i++) {
                  veraddr[i] = (char)(i);
                  nếu (!(i % (1024 * 1024)))
                          printf(".");
          }
          printf("\n");

printf("Đang xác minh dữ liệu...");
	fflush(stdout);
          với (i = 0; tôi < BUFFER_SIZE; i++)
                  if (veraddr[i] != (char)i)
                          printf("\nChỉ số %lu không khớp\n", i);
          printf("Xong.\n");

/* Tắt ADI và dọn dẹp
           */
	if (mprotect(shmaddr, BUFFER_SIZE, PROT_READ|PROT_WRITE)) {
		perror("mprotect thất bại");
		đi đến err_out;
	}

if (shmdt((const void *)shmaddr) != 0)
                  perror("Tháo lỗi");
          shmctl(shmid, IPC_RMID, NULL);

thoát (0);

err_out:
          if (shmdt((const void *)shmaddr) != 0)
                  perror("Tháo lỗi");
          shmctl(shmid, IPC_RMID, NULL);
          thoát (1);
  }
