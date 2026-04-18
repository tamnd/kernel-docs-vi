.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/dev-tools/kcov.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

KCOV: phạm vi mã cho việc làm mờ
================================

KCOV thu thập và hiển thị thông tin phạm vi mã hạt nhân ở dạng phù hợp
để làm mờ theo hướng dẫn vùng phủ sóng. Dữ liệu bảo hiểm của kernel đang chạy được xuất qua
tệp gỡ lỗi ZZ0000ZZ. Việc thu thập phạm vi bảo hiểm được kích hoạt trên cơ sở nhiệm vụ và
do đó KCOV có thể nắm bắt chính xác phạm vi phủ sóng của một cuộc gọi hệ thống.

Lưu ý rằng KCOV không nhằm mục đích thu thập càng nhiều phạm vi phủ sóng càng tốt. Nó nhằm mục đích
để thu thập phạm vi phủ sóng ổn định ít nhiều, đó là chức năng của đầu vào hệ thống.
Để đạt được mục tiêu này, nó không thu thập vùng phủ sóng trong các ngắt mềm/cứng
(trừ khi tính năng xóa bộ sưu tập bảo hiểm được bật, xem bên dưới) và từ một số
vốn là các phần không xác định của hạt nhân (ví dụ: bộ lập lịch, khóa).

Bên cạnh việc thu thập phạm vi mã, KCOV còn có thể thu thập các toán hạng so sánh.
Xem phần "Bộ sưu tập toán hạng so sánh" để biết chi tiết.

Bên cạnh việc thu thập dữ liệu về vùng phủ sóng từ trình xử lý cuộc gọi chung, KCOV cũng có thể thu thập
phạm vi bảo hiểm cho các phần được chú thích của kernel thực thi trong kernel nền
nhiệm vụ hoặc ngắt mềm. Xem phần "Thu thập phạm vi phủ sóng từ xa" để biết
chi tiết.

Điều kiện tiên quyết
--------------------

KCOV dựa vào công cụ biên dịch và yêu cầu GCC 6.1.0 trở lên
hoặc bất kỳ phiên bản Clang nào được kernel hỗ trợ.

Việc thu thập các toán hạng so sánh được hỗ trợ với GCC 8+ hoặc với Clang.

Để bật KCOV, hãy định cấu hình kernel bằng::

CONFIG_KCOV=y

Để bật bộ sưu tập toán hạng so sánh, hãy đặt::

CONFIG_KCOV_ENABLE_COMPARISONS=y

Dữ liệu phạm vi bảo hiểm chỉ có thể truy cập được sau khi gỡ lỗi đã được gắn kết ::

mount -t debugfs none /sys/kernel/debug

Thu thập bảo hiểm
-------------------

Chương trình sau đây trình bày cách sử dụng KCOV để thu thập phạm vi bảo hiểm cho một
một cuộc gọi chung từ bên trong một chương trình thử nghiệm:

.. code-block:: c

    #include <stdio.h>
    #include <stddef.h>
    #include <stdint.h>
    #include <stdlib.h>
    #include <sys/types.h>
    #include <sys/stat.h>
    #include <sys/ioctl.h>
    #include <sys/mman.h>
    #include <unistd.h>
    #include <fcntl.h>
    #include <linux/types.h>

    #define KCOV_INIT_TRACE			_IOR('c', 1, unsigned long)
    #define KCOV_ENABLE			_IO('c', 100)
    #define KCOV_DISABLE			_IO('c', 101)
    #define COVER_SIZE			(64<<10)

    #define KCOV_TRACE_PC  0
    #define KCOV_TRACE_CMP 1

    int main(int argc, char **argv)
    {
	int fd;
	unsigned long *cover, n, i;

	/* A single fd descriptor allows coverage collection on a single
	 * thread.
	 */
	fd = open("/sys/kernel/debug/kcov", O_RDWR);
	if (fd == -1)
		perror("open"), exit(1);
	/* Setup trace mode and trace size. */
	if (ioctl(fd, KCOV_INIT_TRACE, COVER_SIZE))
		perror("ioctl"), exit(1);
	/* Mmap buffer shared between kernel- and user-space. */
	cover = (unsigned long*)mmap(NULL, COVER_SIZE * sizeof(unsigned long),
				     PROT_READ | PROT_WRITE, MAP_SHARED, fd, 0);
	if ((void*)cover == MAP_FAILED)
		perror("mmap"), exit(1);
	/* Enable coverage collection on the current thread. */
	if (ioctl(fd, KCOV_ENABLE, KCOV_TRACE_PC))
		perror("ioctl"), exit(1);
	/* Reset coverage from the tail of the ioctl() call. */
	__atomic_store_n(&cover[0], 0, __ATOMIC_RELAXED);
	/* Call the target syscall call. */
	read(-1, NULL, 0);
	/* Read number of PCs collected. */
	n = __atomic_load_n(&cover[0], __ATOMIC_RELAXED);
	for (i = 0; i < n; i++)
		printf("0x%lx\n", cover[i + 1]);
	/* Disable coverage collection for the current thread. After this call
	 * coverage can be enabled for a different thread.
	 */
	if (ioctl(fd, KCOV_DISABLE, 0))
		perror("ioctl"), exit(1);
	/* Free resources. */
	if (munmap(cover, COVER_SIZE * sizeof(unsigned long)))
		perror("munmap"), exit(1);
	if (close(fd))
		perror("close"), exit(1);
	return 0;
    }

Sau khi chuyển qua ZZ0000ZZ, đầu ra của chương trình trông như sau::

SyS_read
    fs/read_write.c:562
    __fdget_pos
    fs/file.c:774
    __fget_light
    fs/file.c:746
    __fget_light
    fs/file.c:750
    __fget_light
    fs/file.c:760
    __fdget_pos
    fs/file.c:784
    SyS_read
    fs/read_write.c:562

Nếu một chương trình cần thu thập phạm vi bảo hiểm từ một số luồng (độc lập),
nó cần mở ZZ0000ZZ trong từng luồng riêng biệt.

Giao diện được thiết kế tinh tế để cho phép phân nhánh hiệu quả các quy trình thử nghiệm.
Nghĩa là, quy trình gốc sẽ mở ZZ0000ZZ, bật chế độ theo dõi,
vùng đệm bao phủ mmaps, sau đó phân nhánh các tiến trình con trong một vòng lặp. đứa trẻ
các quy trình chỉ cần kích hoạt phạm vi bảo hiểm (nó sẽ tự động bị tắt khi
một luồng thoát ra).

Bộ sưu tập toán hạng so sánh
------------------------------

Bộ sưu tập toán hạng so sánh tương tự như bộ sưu tập bao phủ:

.. code-block:: c

    /* Same includes and defines as above. */

    /* Number of 64-bit words per record. */
    #define KCOV_WORDS_PER_CMP 4

    /*
     * The format for the types of collected comparisons.
     *
     * Bit 0 shows whether one of the arguments is a compile-time constant.
     * Bits 1 & 2 contain log2 of the argument size, up to 8 bytes.
     */

    #define KCOV_CMP_CONST          (1 << 0)
    #define KCOV_CMP_SIZE(n)        ((n) << 1)
    #define KCOV_CMP_MASK           KCOV_CMP_SIZE(3)

    int main(int argc, char **argv)
    {
	int fd;
	uint64_t *cover, type, arg1, arg2, is_const, size;
	unsigned long n, i;

	fd = open("/sys/kernel/debug/kcov", O_RDWR);
	if (fd == -1)
		perror("open"), exit(1);
	if (ioctl(fd, KCOV_INIT_TRACE, COVER_SIZE))
		perror("ioctl"), exit(1);
	/*
	* Note that the buffer pointer is of type uint64_t*, because all
	* the comparison operands are promoted to uint64_t.
	*/
	cover = (uint64_t *)mmap(NULL, COVER_SIZE * sizeof(unsigned long),
				     PROT_READ | PROT_WRITE, MAP_SHARED, fd, 0);
	if ((void*)cover == MAP_FAILED)
		perror("mmap"), exit(1);
	/* Note KCOV_TRACE_CMP instead of KCOV_TRACE_PC. */
	if (ioctl(fd, KCOV_ENABLE, KCOV_TRACE_CMP))
		perror("ioctl"), exit(1);
	__atomic_store_n(&cover[0], 0, __ATOMIC_RELAXED);
	read(-1, NULL, 0);
	/* Read number of comparisons collected. */
	n = __atomic_load_n(&cover[0], __ATOMIC_RELAXED);
	for (i = 0; i < n; i++) {
		uint64_t ip;

		type = cover[i * KCOV_WORDS_PER_CMP + 1];
		/* arg1 and arg2 - operands of the comparison. */
		arg1 = cover[i * KCOV_WORDS_PER_CMP + 2];
		arg2 = cover[i * KCOV_WORDS_PER_CMP + 3];
		/* ip - caller address. */
		ip = cover[i * KCOV_WORDS_PER_CMP + 4];
		/* size of the operands. */
		size = 1 << ((type & KCOV_CMP_MASK) >> 1);
		/* is_const - true if either operand is a compile-time constant.*/
		is_const = type & KCOV_CMP_CONST;
		printf("ip: 0x%lx type: 0x%lx, arg1: 0x%lx, arg2: 0x%lx, "
			"size: %lu, %s\n",
			ip, type, arg1, arg2, size,
		is_const ? "const" : "non-const");
	}
	if (ioctl(fd, KCOV_DISABLE, 0))
		perror("ioctl"), exit(1);
	/* Free resources. */
	if (munmap(cover, COVER_SIZE * sizeof(unsigned long)))
		perror("munmap"), exit(1);
	if (close(fd))
		perror("close"), exit(1);
	return 0;
    }

Lưu ý rằng các chế độ KCOV (tập hợp phạm vi mã hoặc toán hạng so sánh)
là loại trừ lẫn nhau.

Thu thập vùng phủ sóng từ xa
----------------------------

Bên cạnh việc thu thập dữ liệu về vùng phủ sóng từ những người xử lý các cuộc gọi tòa nhà được phát hành từ một
quá trình không gian người dùng, KCOV cũng có thể thu thập phạm vi bảo hiểm cho các phần của kernel
thực thi trong các bối cảnh khác - cái gọi là phạm vi bảo hiểm "từ xa".

Sử dụng KCOV để thu thập vùng phủ sóng từ xa yêu cầu:

1. Sửa đổi mã kernel để chú thích phần mã từ vùng phủ sóng
   nên được thu thập bằng ZZ0000ZZ và ZZ0001ZZ.

2. Sử dụng ZZ0000ZZ thay vì ZZ0001ZZ trong không gian người dùng
   quá trình thu thập bảo hiểm.

Cả chú thích ZZ0000ZZ và ZZ0001ZZ và
ZZ0002ZZ ioctl chấp nhận các thẻ điều khiển xác định phạm vi bảo hiểm cụ thể
các phần sưu tầm. Cách sử dụng tay cầm phụ thuộc vào ngữ cảnh nơi mà tay cầm được sử dụng.
phần mã phù hợp sẽ được thực thi.

KCOV hỗ trợ thu thập phạm vi phủ sóng từ xa từ các bối cảnh sau:

1. Nhiệm vụ nền kernel toàn cầu. Đây là những nhiệm vụ được sinh ra trong quá trình
   khởi động kernel trong một số trường hợp giới hạn (ví dụ: một USB ZZ0000ZZ
   công nhân được sinh ra trên một USB HCD).

2. Các tác vụ nền hạt nhân cục bộ. Chúng được sinh ra khi một quá trình không gian người dùng
   tương tác với một số giao diện kernel và thường bị hủy khi quá trình
   lối thoát (ví dụ: công nhân vhost).

3. Ngắt nhẹ.

Đối với #1 và #3, một tay cầm toàn cầu duy nhất phải được chọn và chuyển cho
cuộc gọi ZZ0000ZZ tương ứng. Sau đó, quá trình không gian người dùng phải vượt qua
bộ điều khiển này tới ZZ0001ZZ trong trường mảng ZZ0002ZZ của
Cấu trúc ZZ0003ZZ. Thao tác này sẽ đính kèm thiết bị KCOV đã sử dụng vào mã
phần được tham chiếu bởi phần điều khiển này. Nhiều tay cầm toàn cầu xác định
các phần mã khác nhau có thể được chuyển cùng một lúc.

Đối với #2, thay vào đó, quy trình không gian người dùng phải chuyển một thẻ điều khiển khác 0 thông qua
Trường ZZ0000ZZ của cấu trúc ZZ0001ZZ. Tay cầm chung này
được lưu vào trường ZZ0002ZZ trong ZZ0003ZZ hiện tại và
cần được chuyển đến các tác vụ cục bộ mới được sinh ra thông qua mã hạt nhân tùy chỉnh
sửa đổi. Những tác vụ đó sẽ lần lượt sử dụng thẻ điều khiển đã được truyền trong
Chú thích ZZ0004ZZ và ZZ0005ZZ.

KCOV tuân theo định dạng được xác định trước cho cả bộ điều khiển chung và bộ điều khiển chung. Mỗi
tay cầm là số nguyên ZZ0000ZZ. Hiện tại, chỉ có 4 byte trên và 4 byte dưới
được sử dụng. Byte 4-7 được dành riêng và phải bằng 0.

Đối với các thẻ điều khiển chung, byte trên cùng của thẻ điều khiển biểu thị id của hệ thống con
tay cầm này thuộc về. Ví dụ: KCOV sử dụng ZZ0000ZZ làm id hệ thống con USB.
4 byte thấp hơn của một thẻ điều khiển chung biểu thị id của một phiên bản tác vụ bên trong
hệ thống con đó. Ví dụ: mỗi nhân viên ZZ0001ZZ sử dụng số bus USB
làm id phiên bản nhiệm vụ.

Đối với các thẻ điều khiển thông thường, giá trị dành riêng ZZ0000ZZ được sử dụng làm id hệ thống con, chẳng hạn như
tay cầm không thuộc về một hệ thống con cụ thể. 4 byte thấp hơn của chung
xử lý xác định một trường hợp tập thể của tất cả các nhiệm vụ cục bộ được sinh ra bởi
quy trình không gian người dùng đã chuyển một mã điều khiển chung cho ZZ0001ZZ.

Trong thực tế, bất kỳ giá trị nào cũng có thể được sử dụng cho id phiên bản xử lý chung nếu mức độ bao phủ
chỉ được thu thập từ một quy trình không gian người dùng duy nhất trên hệ thống. Tuy nhiên, nếu
các thẻ điều khiển chung được sử dụng bởi nhiều quy trình, các id phiên bản duy nhất phải được
sử dụng cho mỗi quá trình. Một tùy chọn là sử dụng id tiến trình làm ID chung
xử lý id cá thể.

Chương trình sau đây trình bày cách sử dụng KCOV để thu thập mức độ phù hợp từ cả hai
các tác vụ cục bộ được sinh ra bởi quy trình và tác vụ toàn cục xử lý bus USB #1:

.. code-block:: c

    /* Same includes and defines as above. */

    struct kcov_remote_arg {
	__u32		trace_mode;
	__u32		area_size;
	__u32		num_handles;
	__aligned_u64	common_handle;
	__aligned_u64	handles[0];
    };

    #define KCOV_INIT_TRACE			_IOR('c', 1, unsigned long)
    #define KCOV_DISABLE			_IO('c', 101)
    #define KCOV_REMOTE_ENABLE		_IOW('c', 102, struct kcov_remote_arg)

    #define COVER_SIZE	(64 << 10)

    #define KCOV_TRACE_PC	0

    #define KCOV_SUBSYSTEM_COMMON	(0x00ull << 56)
    #define KCOV_SUBSYSTEM_USB	(0x01ull << 56)

    #define KCOV_SUBSYSTEM_MASK	(0xffull << 56)
    #define KCOV_INSTANCE_MASK	(0xffffffffull)

    static inline __u64 kcov_remote_handle(__u64 subsys, __u64 inst)
    {
	if (subsys & ~KCOV_SUBSYSTEM_MASK || inst & ~KCOV_INSTANCE_MASK)
		return 0;
	return subsys | inst;
    }

    #define KCOV_COMMON_ID	0x42
    #define KCOV_USB_BUS_NUM	1

    int main(int argc, char **argv)
    {
	int fd;
	unsigned long *cover, n, i;
	struct kcov_remote_arg *arg;

	fd = open("/sys/kernel/debug/kcov", O_RDWR);
	if (fd == -1)
		perror("open"), exit(1);
	if (ioctl(fd, KCOV_INIT_TRACE, COVER_SIZE))
		perror("ioctl"), exit(1);
	cover = (unsigned long*)mmap(NULL, COVER_SIZE * sizeof(unsigned long),
				     PROT_READ | PROT_WRITE, MAP_SHARED, fd, 0);
	if ((void*)cover == MAP_FAILED)
		perror("mmap"), exit(1);

	/* Enable coverage collection via common handle and from USB bus #1. */
	arg = calloc(1, sizeof(*arg) + sizeof(uint64_t));
	if (!arg)
		perror("calloc"), exit(1);
	arg->trace_mode = KCOV_TRACE_PC;
	arg->area_size = COVER_SIZE;
	arg->num_handles = 1;
	arg->common_handle = kcov_remote_handle(KCOV_SUBSYSTEM_COMMON,
							KCOV_COMMON_ID);
	arg->handles[0] = kcov_remote_handle(KCOV_SUBSYSTEM_USB,
						KCOV_USB_BUS_NUM);
	if (ioctl(fd, KCOV_REMOTE_ENABLE, arg))
		perror("ioctl"), free(arg), exit(1);
	free(arg);

	/*
	 * Here the user needs to trigger execution of a kernel code section
	 * that is either annotated with the common handle, or to trigger some
	 * activity on USB bus #1.
	 */
	sleep(2);

        /*
         * The load to the coverage count should be an acquire to pair with
         * pair with the corresponding write memory barrier (smp_wmb()) on
         * the kernel-side in kcov_move_area().
         */
	n = __atomic_load_n(&cover[0], __ATOMIC_ACQUIRE);
	for (i = 0; i < n; i++)
		printf("0x%lx\n", cover[i + 1]);
	if (ioctl(fd, KCOV_DISABLE, 0))
		perror("ioctl"), exit(1);
	if (munmap(cover, COVER_SIZE * sizeof(unsigned long)))
		perror("munmap"), exit(1);
	if (close(fd))
		perror("close"), exit(1);
	return 0;
    }
