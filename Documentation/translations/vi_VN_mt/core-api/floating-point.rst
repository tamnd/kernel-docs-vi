.. SPDX-License-Identifier: GPL-2.0+

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/core-api/floating-point.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

Dấu phẩy động API
==================

Mã hạt nhân thường bị cấm sử dụng các thanh ghi dấu phẩy động (FP) hoặc
hướng dẫn, bao gồm cả kiểu dữ liệu C float và double. Quy định này làm giảm
chi phí cuộc gọi hệ thống, vì kernel không cần lưu và khôi phục
trạng thái đăng ký dấu phẩy động của không gian người dùng.

Tuy nhiên, đôi khi trình điều khiển hoặc chức năng thư viện có thể cần bao gồm mã FP.
Điều này được hỗ trợ bằng cách tách các hàm chứa mã FP thành một phần riêng biệt
đơn vị dịch (một tệp nguồn riêng biệt) và lưu/khôi phục thanh ghi FP
trạng thái xung quanh các cuộc gọi đến các chức năng đó. Điều này tạo ra "các phần quan trọng" của
cách sử dụng dấu phẩy động.

Lý do cho sự cô lập này là để ngăn trình biên dịch tạo mã
chạm vào các thanh ghi FP bên ngoài các phần quan trọng này. Trình biên dịch đôi khi
sử dụng các thanh ghi FP để tối ưu hóa ZZ0000ZZ nội tuyến hoặc gán biến, như
các thanh ghi dấu phẩy động có thể rộng hơn các thanh ghi đa năng.

Khả năng sử dụng mã dấu phẩy động trong kernel tùy thuộc vào kiến ​​trúc cụ thể.
Ngoài ra, do một hạt nhân có thể được cấu hình để hỗ trợ các nền tảng
cả có và không có đơn vị dấu phẩy động, phải kiểm tra tính khả dụng của FPU
cả vào thời gian xây dựng và thời gian chạy.

Một số kiến trúc triển khai dấu phẩy động hạt nhân chung API từ
ZZ0000ZZ, như được mô tả bên dưới. Một số kiến trúc khác triển khai
các API riêng biệt, được ghi lại riêng biệt.

Thời gian xây dựng API
--------------

Mã dấu phẩy động có thể được xây dựng nếu tùy chọn ZZ0000ZZ
được kích hoạt. Đối với mã C, mã đó phải được đặt trong một tệp riêng và
tệp phải được điều chỉnh cờ biên dịch bằng cách sử dụng mẫu sau ::

CFLAGS_foo.o += $(CC_FLAGS_FPU)
    CFLAGS_REMOVE_foo.o += $(CC_FLAGS_NO_FPU)

Kiến trúc dự kiến sẽ xác định một hoặc cả hai biến này trong
Makefile cấp cao nhất nếu cần. Ví dụ::

CC_FLAGS_FPU := -mhard-float

hoặc::

CC_FLAGS_NO_FPU := -msoft-float

Mã hạt nhân thông thường được coi là sử dụng tương đương với ZZ0000ZZ.

Thời gian chạy API
-----------

Thời gian chạy API được cung cấp trong ZZ0000ZZ. Không thể bao gồm tiêu đề này
từ các tệp triển khai mã FP (những tệp có cờ biên dịch được điều chỉnh thành
ở trên). Thay vào đó, nó phải được đưa vào khi xác định các phần quan trọng của FP.

.. c:function:: bool kernel_fpu_available( void )

        This function reports if floating-point code can be used on this CPU or
        platform. The value returned by this function is not expected to change
        at runtime, so it only needs to be called once, not before every
        critical section.

.. c:function:: void kernel_fpu_begin( void )
                void kernel_fpu_end( void )

        These functions create a floating-point critical section. It is only
        valid to call ``kernel_fpu_begin()`` after a previous call to
        ``kernel_fpu_available()`` returned ``true``. These functions are only
        guaranteed to be callable from (preemptible or non-preemptible) process
        context.

        Preemption may be disabled inside critical sections, so their size
        should be minimized. They are *not* required to be reentrant. If the
        caller expects to nest critical sections, it must implement its own
        reference counting.