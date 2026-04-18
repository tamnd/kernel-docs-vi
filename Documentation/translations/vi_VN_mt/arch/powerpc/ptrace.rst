.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/arch/powerpc/ptrace.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

======
Ptrace
======

GDB dự định hỗ trợ các tính năng gỡ lỗi phần cứng sau của BookE
bộ vi xử lý:

4 điểm dừng phần cứng (IAC)
2 điểm quan sát phần cứng (đọc, ghi và đọc-ghi) (DAC)
2 điều kiện giá trị cho điểm theo dõi phần cứng (DVC)

Để làm được điều đó, chúng ta cần mở rộng ptrace để GDB có thể truy vấn và thiết lập những
tài nguyên. Vì chúng tôi đang mở rộng nên chúng tôi đang cố gắng tạo một giao diện
có thể mở rộng và bao gồm cả bộ xử lý BookE và máy chủ, vì vậy
GDB không cần phải phân biệt chữ hoa chữ thường cho từng trường hợp đó. Chúng tôi đã thêm
theo sau 3 yêu cầu ptrace mới.

1. PPC_PTRACE_GETHWDBGINFO
============================

Truy vấn GDB để khám phá các tính năng gỡ lỗi phần cứng. Thông tin chính để
được trả lại ở đây là sự căn chỉnh tối thiểu cho các điểm theo dõi phần cứng.
Bộ xử lý BookE không có hạn chế ở đây, nhưng bộ xử lý máy chủ có
hạn chế căn chỉnh 8 byte cho các điểm theo dõi phần cứng. Chúng tôi muốn tránh
thêm các trường hợp đặc biệt vào GDB dựa trên những gì nó thấy trong AUXV.

Vì đã hoàn thành việc đó nên chúng tôi đã thêm thông tin hữu ích khác mà kernel có thể quay lại
GDB: truy vấn này sẽ trả về số điểm dừng phần cứng, phần cứng
điểm quan sát và liệu nó có hỗ trợ một loạt địa chỉ và một điều kiện hay không.
Truy vấn sẽ điền vào cấu trúc sau được cung cấp bởi quy trình yêu cầu::

cấu trúc ppc_debug_info {
       phiên bản unit32_t;
       unit32_t num_instruction_bps;
       unit32_t num_data_bps;
       unit32_t num_condition_regs;
       unit32_t data_bp_alignment;
       unit32_t sizeof_condition; /* kích thước của thanh ghi DVC */
       tính năng uint64_t; /* bitmask của từng cờ */
  };

các tính năng sẽ có các bit cho biết liệu có hỗ trợ cho ::

#define PPC_DEBUG_FEATURE_INSN_BP_RANGE 0x1
  #define PPC_DEBUG_FEATURE_INSN_BP_MASK 0x2
  #define PPC_DEBUG_FEATURE_DATA_BP_RANGE 0x4
  #define PPC_DEBUG_FEATURE_DATA_BP_MASK 0x8
  #define PPC_DEBUG_FEATURE_DATA_BP_DAWR 0x10
  #define PPC_DEBUG_FEATURE_DATA_BP_ARCH_31 0x20

2. PPC_PTRACE_SETHWDEBUG

Đặt điểm dừng hoặc điểm theo dõi phần cứng, theo cấu trúc được cung cấp::

cấu trúc ppc_hw_breakpoint {
        phiên bản uint32_t;
  #define PPC_BREAKPOINT_TRIGGER_EXECUTE 0x1
  #define PPC_BREAKPOINT_TRIGGER_READ 0x2
 #define PPC_BREAKPOINT_TRIGGER_WRITE 0x4
        uint32_t trigger_type;       /*chỉ cho phép một số kết hợp */
  #define PPC_BREAKPOINT_MODE_EXACT 0x0
  #define PPC_BREAKPOINT_MODE_RANGE_INCLUSIVE 0x1
  #define PPC_BREAKPOINT_MODE_RANGE_EXCLUSIVE 0x2
  #define PPC_BREAKPOINT_MODE_MASK 0x3
        uint32_t addr_mode;          /*Chế độ khớp địa chỉ*/

#define PPC_BREAKPOINT_CONDITION_MODE 0x3
  #define PPC_BREAKPOINT_CONDITION_NONE 0x0
  #define PPC_BREAKPOINT_CONDITION_AND 0x1
  #define PPC_BREAKPOINT_CONDITION_EXACT 0x1 /* tên khác cho cùng một thứ như trên */
  #define PPC_BREAKPOINT_CONDITION_OR 0x2
  #define PPC_BREAKPOINT_CONDITION_AND_OR 0x3
  #define PPC_BREAKPOINT_CONDITION_BE_ALL 0x00ff0000 /* bit kích hoạt byte */
  #define PPC_BREAKPOINT_CONDITION_BE(n) (1<<((n)+16))
        uint32_t condition_mode;     /* ngắt/cờ điều kiện điểm quan sát */

địa chỉ uint64_t;
        uint64_t addr2;
        uint64_t condition_value;
  };

Một yêu cầu chỉ định một sự kiện, không nhất thiết chỉ cần đặt một đăng ký.
Ví dụ: nếu yêu cầu dành cho một điểm giám sát có điều kiện, thì cả
Các thanh ghi DAC và DVC sẽ được đặt trong cùng một yêu cầu.

Với GDB này có thể yêu cầu tất cả các loại điểm dừng và điểm quan sát phần cứng
mà BookE hỗ trợ. Điểm dừng COMEFROM có sẵn trong bộ xử lý máy chủ
không được dự tính, nhưng điều đó nằm ngoài phạm vi của tác phẩm này.

ptrace sẽ trả về một số nguyên (xử lý) xác định duy nhất điểm dừng hoặc
điểm quan sát vừa được tạo. Số nguyên này sẽ được sử dụng trong PPC_PTRACE_DELHWDEBUG
yêu cầu gỡ bỏ nó. Trả về -ENOSPC nếu điểm dừng được yêu cầu
không thể được phân bổ trên sổ đăng ký.

Một số ví dụ về việc sử dụng cấu trúc để:

- đặt điểm dừng trong thanh ghi điểm dừng đầu tiên::

p.version = PPC_DEBUG_CURRENT_VERSION;
    p.trigger_type = PPC_BREAKPOINT_TRIGGER_EXECUTE;
    p.addr_mode = PPC_BREAKPOINT_MODE_EXACT;
    p.condition_mode = PPC_BREAKPOINT_CONDITION_NONE;
    p.addr = địa chỉ (uint64_t);
    p.addr2 = 0;
    p.condition_value = 0;

- đặt điểm theo dõi kích hoạt các lần đọc trong thanh ghi điểm theo dõi thứ hai::

p.version = PPC_DEBUG_CURRENT_VERSION;
    p.trigger_type = PPC_BREAKPOINT_TRIGGER_READ;
    p.addr_mode = PPC_BREAKPOINT_MODE_EXACT;
    p.condition_mode = PPC_BREAKPOINT_CONDITION_NONE;
    p.addr = địa chỉ (uint64_t);
    p.addr2 = 0;
    p.condition_value = 0;

- đặt điểm theo dõi chỉ kích hoạt với một giá trị cụ thể::

p.version = PPC_DEBUG_CURRENT_VERSION;
    p.trigger_type = PPC_BREAKPOINT_TRIGGER_READ;
    p.addr_mode = PPC_BREAKPOINT_MODE_EXACT;
    p.condition_mode = PPC_BREAKPOINT_CONDITION_AND | PPC_BREAKPOINT_CONDITION_BE_ALL;
    p.addr = địa chỉ (uint64_t);
    p.addr2 = 0;
    p.condition_value = (uint64_t) điều kiện;

- đặt điểm dừng phần cứng phạm vi::

p.version = PPC_DEBUG_CURRENT_VERSION;
    p.trigger_type = PPC_BREAKPOINT_TRIGGER_EXECUTE;
    p.addr_mode = PPC_BREAKPOINT_MODE_RANGE_INCLUSIVE;
    p.condition_mode = PPC_BREAKPOINT_CONDITION_NONE;
    p.addr = (uint64_t) Begin_range;
    p.addr2 = (uint64_t) end_range;
    p.condition_value = 0;

- đặt điểm theo dõi trong bộ xử lý máy chủ (BookS)::

p.version = 1;
    p.trigger_type = PPC_BREAKPOINT_TRIGGER_RW;
    p.addr_mode = PPC_BREAKPOINT_MODE_RANGE_INCLUSIVE;
    hoặc
    p.addr_mode = PPC_BREAKPOINT_MODE_EXACT;

p.condition_mode = PPC_BREAKPOINT_CONDITION_NONE;
    p.addr = (uint64_t) Begin_range;
    /* Đối với PPC_BREAKPOINT_MODE_RANGE_INCLUSIVE addr2 cần được chỉ định, trong đó
     * addr2 - addr <= 8 Byte.
     */
    p.addr2 = (uint64_t) end_range;
    p.condition_value = 0;

3. PPC_PTRACE_DELHWDEBUG

Lấy một số nguyên xác định điểm dừng hoặc điểm theo dõi hiện có
(tức là giá trị được trả về từ PTRACE_SETHWDEBUG) và xóa
điểm dừng hoặc điểm quan sát tương ứng ..
