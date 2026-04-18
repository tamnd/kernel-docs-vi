.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/arch/arm64/cpu-feature-registers.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

==============================
Thanh ghi tính năng ARM64 CPU
==============================

Tác giả: Suzuki K Poulose <suzuki.poulose@arm.com>


Tệp này mô tả ABI để xuất ID/tính năng AArch64 CPU
đăng ký vào không gian người dùng. Tính khả dụng của ABI này đã được quảng cáo
thông qua HWCAP_CPUID trong HWCAP.

1. Động lực
-------------

Kiến trúc ARM xác định một tập hợp các thanh ghi tính năng, mô tả
khả năng của CPU/hệ thống. Việc truy cập vào các thanh ghi hệ thống này là
bị hạn chế từ EL0 và không có cách nào đáng tin cậy để ứng dụng truy cập
trích xuất thông tin này để đưa ra quyết định tốt hơn trong thời gian chạy. có
Tuy nhiên, thông tin hạn chế có sẵn cho ứng dụng thông qua HWCAP
có một số vấn đề với việc sử dụng của họ.

a) Mọi thay đổi đối với HWCAP đều yêu cầu cập nhật không gian người dùng (ví dụ: libc)
    để phát hiện những thay đổi mới, có thể mất nhiều thời gian mới xuất hiện trong
    phân phối. Việc hiển thị các thanh ghi cho phép các ứng dụng có được
    thông tin mà không yêu cầu cập nhật các chuỗi công cụ.

b) Quyền truy cập vào HWCAP đôi khi bị hạn chế (ví dụ: trước libc hoặc
    khi ld được khởi tạo lúc khởi động).

c) HWCAP không thể biểu diễn thông tin không phải boolean một cách hiệu quả. các
    kiến trúc xác định một định dạng chuẩn để biểu diễn các tính năng
    trong sổ đăng ký ID; điều này được xác định rõ ràng và có khả năng
    đại diện cho tất cả các biến thể kiến trúc hợp lệ.


2. Yêu cầu
---------------

a) An toàn:

Các ứng dụng có thể sử dụng thông tin được cung cấp bởi
    cơ sở hạ tầng để chạy an toàn trên toàn hệ thống. Điều này có lớn hơn
    tác động lên một hệ thống có CPU không đồng nhất.
    Cơ sở hạ tầng xuất khẩu một giá trị an toàn trên tất cả các
    CPU có sẵn trên hệ thống.

ví dụ: Nếu ít nhất một CPU không thực hiện các lệnh CRC32, trong khi
    những người khác làm như vậy, chúng tôi nên báo cáo rằng CRC32 không được triển khai.
    Nếu không, ứng dụng có thể gặp sự cố khi được lên lịch trên CPU
    không hỗ trợ CRC32.

b) An ninh:

Các ứng dụng chỉ có thể nhận được thông tin
    liên quan đến hoạt động bình thường trong không gian người dùng. Do đó, một số
    các trường được che dấu (tức là ẩn) và giá trị của chúng được đặt thành
    cho biết tính năng này 'không được hỗ trợ'. Xem Phần 4 để biết danh sách
    của các đặc điểm có thể nhìn thấy được. Ngoài ra, kernel có thể thao tác các trường
    dựa trên những gì nó hỗ trợ. ví dụ: Nếu FP không được hỗ trợ bởi
    kernel, các giá trị có thể chỉ ra rằng FP không có sẵn
    (ngay cả khi CPU cung cấp nó).

c) Các tính năng được xác định thực hiện

Cơ sở hạ tầng không để lộ bất kỳ đăng ký nào
    IMPLEMENTATION DEFINED theo Kiến trúc ARMv8-A.

d) Nhận dạng CPU:

MIDR_EL1 được hiển thị để giúp xác định bộ xử lý. Trên một
    hệ thống không đồng nhất, điều này có thể không phù hợp (giống như getcpu()). các
    quá trình có thể được di chuyển sang CPU khác vào thời điểm nó sử dụng
    giá trị đăng ký, trừ khi mối quan hệ CPU được đặt. Do đó, không có
    đảm bảo rằng giá trị phản ánh bộ xử lý rằng nó
    hiện đang thực hiện. REVIDR và AIDR không bị lộ do điều này
    hạn chế, vì các thanh ghi này chỉ có ý nghĩa khi kết hợp với
    MIDR. Ngoài ra, MIDR_EL1, REVIDR_EL1 và AIDR_EL1 cũng bị lộ
    thông qua sysfs tại::

/sys/devices/system/cpu/cpu$ID/regs/identification/
	                                              \- midr_el1
	                                              \- revidr_el1
	                                              \- viện trợ_el1

3. Thực hiện
--------------------

Cơ sở hạ tầng được xây dựng dựa trên mô phỏng lệnh 'MRS'.
Việc truy cập vào thanh ghi hệ thống bị hạn chế từ một ứng dụng sẽ tạo ra một
ngoại lệ và kết thúc bằng việc SIGILL được chuyển đến quy trình.
Cơ sở hạ tầng nối vào trình xử lý ngoại lệ và mô phỏng
hoạt động nếu nguồn thuộc về không gian đăng ký hệ thống được hỗ trợ.

Cơ sở hạ tầng chỉ mô phỏng không gian đăng ký hệ thống sau::

Op0=3, Op1=0, CRn=0, CRm=0,2,3,4,5,6,7

(Xem Bảng C5-6 'Mã hóa hướng dẫn hệ thống cho Hệ thống không gỡ lỗi
đăng ký quyền truy cập' trong ARMv8 ARM DDI 0487A.h, để biết danh sách
sổ đăng ký).

Các quy tắc sau đây được áp dụng cho giá trị được trả về bởi
cơ sở hạ tầng:

a) Giá trị của trường 'IMPLEMENTATION DEFINED' được đặt thành 0.
 b) Giá trị của trường dành riêng được điền bằng giá trị dành riêng
    giá trị được xác định bởi kiến trúc.
 c) Giá trị của trường 'hiển thị' giữ giá trị an toàn trên toàn hệ thống
    để biết tính năng cụ thể (ngoại trừ MIDR_EL1, xem phần 4).
 d) Tất cả các trường khác (tức là các trường vô hình) được đặt để biểu thị
    tính năng bị thiếu (như được xác định bởi kiến trúc).

4. Danh sách các thanh ghi có tính năng hiển thị
------------------------------------------------

1) ID_AA64ISAR0_EL1 - Thanh ghi thuộc tính tập lệnh 0

+------------------------------+----------+----------+
     Các bit ZZ0000ZZ ZZ0001ZZ
     +------------------------------+----------+----------+
     ZZ0002ZZ [63-60] ZZ0003ZZ
     +------------------------------+----------+----------+
     ZZ0004ZZ [55-52] ZZ0005ZZ
     +------------------------------+----------+----------+
     ZZ0006ZZ [51-48] ZZ0007ZZ
     +------------------------------+----------+----------+
     ZZ0008ZZ [47-44] ZZ0009ZZ
     +------------------------------+----------+----------+
     ZZ0010ZZ [43-40] ZZ0011ZZ
     +------------------------------+----------+----------+
     ZZ0012ZZ [39-36] ZZ0013ZZ
     +------------------------------+----------+----------+
     ZZ0014ZZ [35-32] ZZ0015ZZ
     +------------------------------+----------+----------+
     ZZ0016ZZ [31-28] ZZ0017ZZ
     +------------------------------+----------+----------+
     ZZ0018ZZ [23-20] ZZ0019ZZ
     +------------------------------+----------+----------+
     ZZ0020ZZ [19-16] ZZ0021ZZ
     +------------------------------+----------+----------+
     ZZ0022ZZ [15-12] ZZ0023ZZ
     +------------------------------+----------+----------+
     ZZ0024ZZ [11-8] ZZ0025ZZ
     +------------------------------+----------+----------+
     ZZ0026ZZ [7-4] ZZ0027ZZ
     +------------------------------+----------+----------+


2) ID_AA64PFR0_EL1 - Đăng ký tính năng bộ xử lý 0

+------------------------------+----------+----------+
     Các bit ZZ0000ZZ ZZ0001ZZ
     +------------------------------+----------+----------+
     ZZ0002ZZ [51-48] ZZ0003ZZ
     +------------------------------+----------+----------+
     ZZ0004ZZ [43-40] ZZ0005ZZ
     +------------------------------+----------+----------+
     ZZ0006ZZ [35-32] ZZ0007ZZ
     +------------------------------+----------+----------+
     ZZ0008ZZ [27-24] ZZ0009ZZ
     +------------------------------+----------+----------+
     ZZ0010ZZ [23-20] ZZ0011ZZ
     +------------------------------+----------+----------+
     ZZ0012ZZ [19-16] ZZ0013ZZ
     +------------------------------+----------+----------+
     ZZ0014ZZ [15-12] ZZ0015ZZ
     +------------------------------+----------+----------+
     ZZ0016ZZ [11-8] ZZ0017ZZ
     +------------------------------+----------+----------+
     ZZ0018ZZ [7-4] ZZ0019ZZ
     +------------------------------+----------+----------+
     ZZ0020ZZ [3-0] ZZ0021ZZ
     +------------------------------+----------+----------+


3) ID_AA64PFR1_EL1 - Đăng ký tính năng bộ xử lý 1

+------------------------------+----------+----------+
     Các bit ZZ0000ZZ ZZ0001ZZ
     +------------------------------+----------+----------+
     ZZ0002ZZ [27-24] ZZ0003ZZ
     +------------------------------+----------+----------+
     ZZ0004ZZ [11-8] ZZ0005ZZ
     +------------------------------+----------+----------+
     ZZ0006ZZ [7-4] ZZ0007ZZ
     +------------------------------+----------+----------+
     ZZ0008ZZ [3-0] ZZ0009ZZ
     +------------------------------+----------+----------+


4) MIDR_EL1 - Đăng ký ID chính

+------------------------------+----------+----------+
     Các bit ZZ0000ZZ ZZ0001ZZ
     +------------------------------+----------+----------+
     ZZ0002ZZ [31-24] ZZ0003ZZ
     +------------------------------+----------+----------+
     ZZ0004ZZ [23-20] ZZ0005ZZ
     +------------------------------+----------+----------+
     ZZ0006ZZ [19-16] ZZ0007ZZ
     +------------------------------+----------+----------+
     ZZ0008ZZ [15-4] ZZ0009ZZ
     +------------------------------+----------+----------+
     ZZ0010ZZ [3-0] ZZ0011ZZ
     +------------------------------+----------+----------+

NOTE: Các trường 'hiển thị' của MIDR_EL1 sẽ chứa giá trị
   có sẵn trên CPU nơi nó được tìm nạp và không phải là một hệ thống
   giá trị an toàn rộng.

5) ID_AA64ISAR1_EL1 - Thanh ghi thuộc tính tập lệnh 1

+------------------------------+----------+----------+
     Các bit ZZ0000ZZ ZZ0001ZZ
     +------------------------------+----------+----------+
     ZZ0002ZZ [55-52] ZZ0003ZZ
     +------------------------------+----------+----------+
     ZZ0004ZZ [51-48] ZZ0005ZZ
     +------------------------------+----------+----------+
     ZZ0006ZZ [47-44] ZZ0007ZZ
     +------------------------------+----------+----------+
     ZZ0008ZZ [39-36] ZZ0009ZZ
     +------------------------------+----------+----------+
     ZZ0010ZZ [35-32] ZZ0011ZZ
     +------------------------------+----------+----------+
     ZZ0012ZZ [31-28] ZZ0013ZZ
     +------------------------------+----------+----------+
     ZZ0014ZZ [27-24] ZZ0015ZZ
     +------------------------------+----------+----------+
     ZZ0016ZZ [23-20] ZZ0017ZZ
     +------------------------------+----------+----------+
     ZZ0018ZZ [19-16] ZZ0019ZZ
     +------------------------------+----------+----------+
     ZZ0020ZZ [15-12] ZZ0021ZZ
     +------------------------------+----------+----------+
     ZZ0022ZZ [11-8] ZZ0023ZZ
     +------------------------------+----------+----------+
     ZZ0024ZZ [7-4] ZZ0025ZZ
     +------------------------------+----------+----------+
     ZZ0026ZZ [3-0] ZZ0027ZZ
     +------------------------------+----------+----------+

6) ID_AA64MMFR0_EL1 - Thanh ghi tính năng mô hình bộ nhớ 0

+------------------------------+----------+----------+
     Các bit ZZ0000ZZ ZZ0001ZZ
     +------------------------------+----------+----------+
     ZZ0002ZZ [63-60] ZZ0003ZZ
     +------------------------------+----------+----------+

7) ID_AA64MMFR2_EL1 - Thanh ghi tính năng mô hình bộ nhớ 2

+------------------------------+----------+----------+
     Các bit ZZ0000ZZ ZZ0001ZZ
     +------------------------------+----------+----------+
     ZZ0002ZZ [35-32] ZZ0003ZZ
     +------------------------------+----------+----------+

8) ID_AA64ZFR0_EL1 - Thanh ghi ID tính năng SVE 0

+------------------------------+----------+----------+
     Các bit ZZ0000ZZ ZZ0001ZZ
     +------------------------------+----------+----------+
     ZZ0002ZZ [59-56] ZZ0003ZZ
     +------------------------------+----------+----------+
     ZZ0004ZZ [55-52] ZZ0005ZZ
     +------------------------------+----------+----------+
     ZZ0006ZZ [47-44] ZZ0007ZZ
     +------------------------------+----------+----------+
     ZZ0008ZZ [43-40] ZZ0009ZZ
     +------------------------------+----------+----------+
     ZZ0010ZZ [35-32] ZZ0011ZZ
     +------------------------------+----------+----------+
     ZZ0012ZZ [27-24] ZZ0013ZZ
     +------------------------------+----------+----------+
     ZZ0014ZZ [23-20] ZZ0015ZZ
     +------------------------------+----------+----------+
     ZZ0016ZZ [19-16] ZZ0017ZZ
     +------------------------------+----------+----------+
     ZZ0018ZZ [7-4] ZZ0019ZZ
     +------------------------------+----------+----------+
     ZZ0020ZZ [3-0] ZZ0021ZZ
     +------------------------------+----------+----------+

8) ID_AA64MMFR1_EL1 - Thanh ghi tính năng mô hình bộ nhớ 1

+------------------------------+----------+----------+
     Các bit ZZ0000ZZ ZZ0001ZZ
     +------------------------------+----------+----------+
     ZZ0002ZZ [47-44] ZZ0003ZZ
     +------------------------------+----------+----------+

9) ID_AA64ISAR2_EL1 - Thanh ghi thuộc tính tập lệnh 2

+------------------------------+----------+----------+
     Các bit ZZ0000ZZ ZZ0001ZZ
     +------------------------------+----------+----------+
     ZZ0002ZZ [55-52] ZZ0003ZZ
     +------------------------------+----------+----------+
     ZZ0004ZZ [51-48] ZZ0005ZZ
     +------------------------------+----------+----------+
     ZZ0006ZZ [23-20] ZZ0007ZZ
     +------------------------------+----------+----------+
     ZZ0008ZZ [19-16] ZZ0009ZZ
     +------------------------------+----------+----------+
     ZZ0010ZZ [15-12] ZZ0011ZZ
     +------------------------------+----------+----------+
     ZZ0012ZZ [11-8] ZZ0013ZZ
     +------------------------------+----------+----------+
     ZZ0014ZZ [7-4] ZZ0015ZZ
     +------------------------------+----------+----------+
     ZZ0016ZZ [3-0] ZZ0017ZZ
     +------------------------------+----------+----------+

10) MVFR0_EL1 - AArch32 Media và Đăng ký tính năng VFP 0

+------------------------------+----------+----------+
     Các bit ZZ0000ZZ ZZ0001ZZ
     +------------------------------+----------+----------+
     ZZ0002ZZ [11-8] ZZ0003ZZ
     +------------------------------+----------+----------+

11) MVFR1_EL1 - AArch32 Media và Đăng ký tính năng VFP 1

+------------------------------+----------+----------+
     Các bit ZZ0000ZZ ZZ0001ZZ
     +------------------------------+----------+----------+
     ZZ0002ZZ [31-28] ZZ0003ZZ
     +------------------------------+----------+----------+
     ZZ0004ZZ [19-16] ZZ0005ZZ
     +------------------------------+----------+----------+
     ZZ0006ZZ [15-12] ZZ0007ZZ
     +------------------------------+----------+----------+
     ZZ0008ZZ [11-8] ZZ0009ZZ
     +------------------------------+----------+----------+

12) ID_ISAR5_EL1 - Thanh ghi thuộc tính tập lệnh AArch32 5

+------------------------------+----------+----------+
     Các bit ZZ0000ZZ ZZ0001ZZ
     +------------------------------+----------+----------+
     ZZ0002ZZ [19-16] ZZ0003ZZ
     +------------------------------+----------+----------+
     ZZ0004ZZ [15-12] ZZ0005ZZ
     +------------------------------+----------+----------+
     ZZ0006ZZ [11-8] ZZ0007ZZ
     +------------------------------+----------+----------+
     ZZ0008ZZ [7-4] ZZ0009ZZ
     +------------------------------+----------+----------+


Phụ lục I: Ví dụ
-------------------

::

/*
   * Chương trình mẫu để chứng minh mô phỏng MRS ABI.
   *
   * Bản quyền (C) 2015-2016, ARM Ltd
   *
   * Tác giả: Suzuki K Poulose <suzuki.poulose@arm.com>
   *
   * Chương trình này là phần mềm miễn phí; bạn có thể phân phối lại nó và/hoặc sửa đổi
   * nó theo các điều khoản của Giấy phép Công cộng GNU phiên bản 2 như
   * được xuất bản bởi Tổ chức Phần mềm Tự do.
   *
   * Chương trình này được phân phối với hy vọng nó sẽ hữu ích,
   * nhưng WITHOUT ANY WARRANTY; thậm chí không có sự bảo đảm ngụ ý của
   * MERCHANTABILITY hoặc FITNESS FOR A PARTICULAR PURPOSE.  Xem
   * Giấy phép Công cộng GNU để biết thêm chi tiết.
   * Chương trình này là phần mềm miễn phí; bạn có thể phân phối lại nó và/hoặc sửa đổi
   * nó theo các điều khoản của Giấy phép Công cộng GNU phiên bản 2 như
   * được xuất bản bởi Tổ chức Phần mềm Tự do.
   *
   * Chương trình này được phân phối với hy vọng nó sẽ hữu ích,
   * nhưng WITHOUT ANY WARRANTY; thậm chí không có sự bảo đảm ngụ ý của
   * MERCHANTABILITY hoặc FITNESS FOR A PARTICULAR PURPOSE.  Xem
   * Giấy phép Công cộng GNU để biết thêm chi tiết.
   */

#include <asm/hwcap.h>
  #include <stdio.h>
  #include <sys/auxv.h>

#define get_cpu_ftr(id) ({ \
		__val dài không dấu;				\
		asm("mrs %0, "#id : "=r" (__val));		\
		printf("%-20s: 0x%016lx\n", #id, __val);	\
	})

int chính(void)
  {

if (!(getauxval(AT_HWCAP) & HWCAP_CPUID)) {
		fputs("Không có thanh ghi CPUID\n", stderr);
		trả về 1;
	}

get_cpu_ftr(ID_AA64ISAR0_EL1);
	get_cpu_ftr(ID_AA64ISAR1_EL1);
	get_cpu_ftr(ID_AA64MMFR0_EL1);
	get_cpu_ftr(ID_AA64MMFR1_EL1);
	get_cpu_ftr(ID_AA64PFR0_EL1);
	get_cpu_ftr(ID_AA64PFR1_EL1);
	get_cpu_ftr(ID_AA64DFR0_EL1);
	get_cpu_ftr(ID_AA64DFR1_EL1);

get_cpu_ftr(MIDR_EL1);
	get_cpu_ftr(MPIDR_EL1);
	get_cpu_ftr(REVIDR_EL1);

#if 0
	/* Truy cập đăng ký không được tiếp xúc gây ra SIGILL */
	get_cpu_ftr(ID_MMFR0_EL1);
  #endif

trả về 0;
  }
