.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/arch/powerpc/dawr-power9.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

=======================
Sự cố DAWR trên POWER9
=====================

Trên các bộ xử lý POWER9 cũ hơn, Thanh ghi điểm theo dõi địa chỉ dữ liệu (DAWR) có thể
gây ra lệnh dừng kiểm tra nếu nó trỏ đến bộ nhớ bị ức chế bộ đệm (CI). Hiện nay Linux
không có cách nào để phân biệt bộ nhớ CI khi định cấu hình DAWR, do đó bị ảnh hưởng
hệ thống, DAWR bị vô hiệu hóa.

Bản sửa đổi bộ xử lý bị ảnh hưởng
============================

Sự cố này chỉ xuất hiện trên các bộ xử lý trước v2.3. Việc sửa đổi có thể được
được tìm thấy trong /proc/cpuinfo::

bộ xử lý: 0
    CPU: POWER9, hỗ trợ altivec
    đồng hồ: 3800.000000 MHz
    bản sửa đổi: 2.3 (pvr 004e 1203)

Trên hệ thống gặp sự cố, DAWR bị tắt như chi tiết bên dưới.

Chi tiết kỹ thuật:
==================

DAWR có 6 cách cài đặt khác nhau.
1) ptrace
2) h_set_mode(DAWR)
3) h_set_dabr()
4) kvmppc_set_one_reg()
5) xmon

Đối với ptrace, hiện tại chúng tôi quảng cáo điểm dừng bằng 0 trên POWER9 thông qua
Cuộc gọi PPC_PTRACE_GETHWDBGINFO. Điều này dẫn đến việc GDB quay trở lại
mô phỏng phần mềm của điểm quan sát (chậm).

h_set_mode(DAWR) và h_set_dabr() bây giờ sẽ trả về lỗi cho
khách trên máy chủ POWER9. Khách Linux hiện tại bỏ qua lỗi này, vì vậy
họ sẽ âm thầm không nhận được DAWR.

kvmppc_set_one_reg() sẽ lưu trữ giá trị trong vcpu nhưng không
thực sự đã đặt nó trên phần cứng POWER9. Điều này được thực hiện để chúng tôi không phá vỡ
di chuyển từ POWER8 sang POWER9, với cái giá là âm thầm mất đi
DAWR trong quá trình di chuyển.

Đối với xmon, lệnh 'bd' sẽ trả về lỗi trên P9.

Hậu quả đối với người dùng
======================

Đối với điểm theo dõi GDB (tức là lệnh 'xem') trên kim loại trần POWER9, GDB
sẽ chấp nhận mệnh lệnh. Thật không may vì không có phần cứng
hỗ trợ cho điểm quan sát, GDB sẽ phần mềm mô phỏng điểm quan sát
làm cho nó chạy rất chậm.

Điều này cũng đúng với bất kỳ khách nào bắt đầu trên POWER9
chủ nhà. Watchpoint sẽ bị lỗi và GDB sẽ quay lại phần mềm
thi đua.

Nếu khách được bắt đầu trên máy chủ POWER8, GDB sẽ chấp nhận điểm theo dõi
và cấu hình phần cứng để sử dụng DAWR. Điều này sẽ chạy đầy đủ
tốc độ vì nó có thể sử dụng mô phỏng phần cứng. Thật không may nếu điều này
khách được di chuyển sang máy chủ POWER9, điểm quan sát sẽ bị mất trên
POWER9. Việc tải và lưu trữ đến các vị trí điểm quan sát sẽ không được thực hiện
bị mắc kẹt trong GDB. Điểm quan sát được ghi nhớ, vì vậy nếu khách
đã di chuyển trở lại máy chủ POWER8, nó sẽ bắt đầu hoạt động trở lại.

Buộc kích hoạt DAWR
=======================
Hạt nhân (kể từ ~v5.2) có tùy chọn buộc kích hoạt DAWR thông qua ::

echo Y > /sys/kernel/debug/powerpc/dawr_enable_dangeous

Điều này cho phép DAWR ngay cả trên POWER9.

Đây là một cài đặt nguy hiểm, USE AT YOUR OWN RISK.

Một số người dùng có thể không quan tâm đến việc người dùng xấu làm hỏng hộp của họ
(tức là hệ thống một người dùng/máy tính để bàn) và thực sự muốn có DAWR.  Cái này
cho phép họ buộc kích hoạt DAWR.

Cờ này cũng có thể được sử dụng để vô hiệu hóa quyền truy cập DAWR. Một khi đây là
bị xóa, tất cả quyền truy cập DAWR sẽ bị xóa ngay lập tức và
máy một lần nữa an toàn không bị rơi.

Không gian người dùng có thể bị nhầm lẫn khi chuyển đổi tùy chọn này. Nếu DAWR là lực
được bật/tắt giữa việc lấy số lượng điểm dừng (thông qua
PTRACE_GETHWDBGINFO) và đặt điểm dừng, không gian người dùng sẽ nhận được
cái nhìn không nhất quán về những gì có sẵn. Tương tự đối với khách

Để kích hoạt DAWR trong KVM khách, DAWR cần phải được kích hoạt
được kích hoạt trong máy chủ AND dành cho khách. Vì lý do này, điều này sẽ không hoạt động trên
POWERVM vì nó không cho phép HCALL hoạt động. Viết 'Y' vào
Tệp dawr_enable_dangeous sẽ không thành công nếu trình ảo hóa không hỗ trợ
viết DAWR.

Để kiểm tra kỹ DAWR có hoạt động hay không, hãy chạy kernel selftest này:

công cụ/thử nghiệm/selftests/powerpc/ptrace/ptrace-hwbreak.c

Bất kỳ lỗi/thất bại/bỏ qua nào đều có nghĩa là có gì đó không ổn.
