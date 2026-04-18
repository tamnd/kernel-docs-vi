.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/arch/arm/firmware.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

================================================================================
Giao diện đăng ký và gọi các hoạt động dành riêng cho phần sụn cho ARM
================================================================================

Viết bởi Tomasz Figa <t.figa@samsung.com>

Một số bo mạch đang chạy với phần mềm bảo mật chạy trong TrustZone Secure
world, điều này thay đổi cách khởi tạo một số thứ. Điều này làm cho
nhu cầu cung cấp giao diện cho các nền tảng như vậy để chỉ định chương trình cơ sở có sẵn
hoạt động và gọi cho họ khi cần thiết.

Các hoạt động của phần sụn có thể được chỉ định bằng cách điền vào cấu trúc firmware_ops
với các cuộc gọi lại thích hợp và sau đó đăng ký nó với register_firmware_ops()
chức năng::

void register_firmware_ops(const struct firmware_ops *ops)

Con trỏ ops phải không phải là NULL. Thông tin thêm về struct firmware_ops
và các thành viên của nó có thể được tìm thấy trong tiêu đề Arch/arm/include/asm/firmware.h.

Có một tập hợp các thao tác trống, mặc định được cung cấp, do đó không cần phải
đặt bất cứ điều gì nếu nền tảng không yêu cầu hoạt động phần sụn.

Để gọi một thao tác phần sụn, macro trợ giúp được cung cấp ::

#define call_firmware_op(op, ...) \
		((firmware_ops->op) ? firmware_ops->op(__VA_ARGS__) : (-ENOSYS))

macro kiểm tra xem thao tác có được cung cấp hay không và gọi nó hoặc trả về
-ENOSYS để báo hiệu rằng thao tác đã cho không khả dụng (ví dụ: để cho phép
dự phòng cho hoạt động cũ).

Ví dụ về đăng ký hoạt động phần sụn::

/* tập tin bảng */

nền tảng int tĩnhX_do_idle(void)
	{
		/* yêu cầu firmware platformX chuyển sang chế độ chờ */
		trả về 0;
	}

nền tảng int tĩnhX_cpu_boot(int i)
	{
		/* yêu cầu firmware platformX khởi động CPU i */
		trả về 0;
	}

static const struct firmware_ops platformX_firmware_ops = {
		.do_idle = exynos_do_idle,
		.cpu_boot = exynos_cpu_boot,
		/* các thao tác khác không có trên platformX */
	};

/* init_early gọi lại bộ mô tả máy */
	khoảng trống tĩnh __init board_init_early(void)
	{
		register_firmware_ops(&platformX_firmware_ops);
	}

Ví dụ về sử dụng thao tác phần sụn::

/* một số mã nền tảng, ví dụ: Khởi tạo SMP */

__raw_writel(__pa_symbol(exynos4_secondary_startup),
		CPU1_BOOT_REG);

/* Gọi cuộc gọi smc cụ thể của Exynos */
	if (call_firmware_op(cpu_boot, cpu) == -ENOSYS)
		cpu_boot_legacy(...); /* Thử cách cũ */

gic_raise_softirq(cpumask_of(cpu), 1);
