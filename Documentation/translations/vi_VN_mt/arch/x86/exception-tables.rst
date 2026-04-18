.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/arch/x86/exception-tables.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

==================================
Xử lý ngoại lệ cấp hạt nhân
===============================

Bình luận của Joerg Pommnitz <joerg@raleigh.ibm.com>

Khi một tiến trình chạy ở chế độ kernel, nó thường phải truy cập vào người dùng
bộ nhớ chế độ có địa chỉ đã được chuyển bởi một chương trình không đáng tin cậy.
Để tự bảo vệ kernel phải xác minh địa chỉ này.

Trong các phiên bản Linux cũ hơn, việc này được thực hiện bằng
int verify_area(kiểu int, const void * addr, kích thước dài không dấu)
(đã được thay thế bằng access_ok()).

Hàm này xác minh rằng vùng bộ nhớ bắt đầu từ địa chỉ
'addr' và kích thước 'size' có thể truy cập được cho hoạt động được chỉ định
trong loại (đọc hoặc viết). Để làm điều này, verify_read phải tra cứu
vùng bộ nhớ ảo (vma) chứa địa chỉ addr. trong
trường hợp bình thường (chương trình hoạt động chính xác), thử nghiệm này đã thành công.
Nó chỉ thất bại đối với một vài chương trình có lỗi. Trong một số hồ sơ hạt nhân
các thử nghiệm, việc xác minh thông thường không cần thiết này đã sử dụng một lượng đáng kể
lượng thời gian.

Để khắc phục tình trạng này, Linus quyết định để bộ nhớ ảo
phần cứng có trong mọi CPU có khả năng Linux sẽ xử lý bài kiểm tra này.

Cái này hoạt động thế nào?

Bất cứ khi nào kernel cố gắng truy cập vào một địa chỉ hiện không được
có thể truy cập được, CPU tạo ra ngoại lệ lỗi trang và gọi
trình xử lý lỗi trang::

void exc_page_fault(struct pt_regs *regs, unsigned long error_code)

trong Arch/x86/mm/fault.c. Các tham số trên ngăn xếp được thiết lập bởi
keo lắp ráp cấp thấp trong Arch/x86/entry/entry_32.S. tham số
regs là một con trỏ tới các thanh ghi đã lưu trên ngăn xếp, error_code
chứa mã lý do cho ngoại lệ.

exec_page_fault() trước tiên lấy địa chỉ không thể truy cập từ CPU
thanh ghi điều khiển CR2. Nếu địa chỉ nằm trong địa chỉ ảo
không gian của quá trình, lỗi có thể đã xảy ra, bởi vì trang
không được hoán đổi, viết được bảo vệ hoặc điều gì đó tương tự. Tuy nhiên,
chúng tôi quan tâm đến trường hợp khác: địa chỉ không hợp lệ, có
không có vma nào chứa địa chỉ này. Trong trường hợp này, kernel nhảy
vào nhãn bad_area.

Ở đó nó sử dụng địa chỉ của lệnh gây ra ngoại lệ
(tức là regs->eip) để tìm địa chỉ nơi quá trình thực thi có thể tiếp tục
(sửa chữa). Nếu tìm kiếm này thành công, trình xử lý lỗi sẽ sửa đổi
địa chỉ trả lại (lại regs->eip) và trả về. Việc thực thi sẽ
tiếp tục tại địa chỉ trong bản sửa lỗi.

Fixup trỏ đến đâu?

Vì chúng ta chuyển sang nội dung của fixup, nên rõ ràng fixup chỉ ra
thành mã thực thi. Mã này được ẩn bên trong macro truy cập của người dùng.
Tôi đã chọn macro get_user() được xác định trong Arch/x86/include/asm/uaccess.h
như một ví dụ. Định nghĩa hơi khó theo dõi, vì vậy chúng ta hãy xem qua
mã được tạo bởi bộ tiền xử lý và trình biên dịch. tôi đã chọn
lệnh gọi get_user() trong driver/char/sysrq.c để kiểm tra chi tiết.

Mã gốc trong dòng sysrq.c 587::

get_user(c, buf);

Đầu ra của bộ tiền xử lý (được chỉnh sửa để có thể đọc được phần nào)::

(
    {
      dài __gu_err = - 14 , __gu_val = 0;
      const __typeof__(*( (  buf ) )) *__gu_addr = ((buf));
      if (((((0 + current_set[0])->tss.segment) == 0x18 ) ||
        (((sizeof(*(buf))) <= 0xC0000000UL) &&
        ((dài không dấu)(__gu_addr ) <= 0xC0000000UL - (sizeof(*(buf)))))))
        làm {
          __gu_err = 0;
          chuyển đổi ((sizeof(*(buf)))) {
            trường hợp 1:
              __asm__ __dễ bay hơi__(
                "1: di chuyển" "b" " %2,%" "b" "1\n"
                "2:\n"
                ".section .fixup,\"ax\"\n"
                "3: di chuyển %3,%0\n"
                " xor" "b" " %" "b" "1,%" "b" "1\n"
                " jmp 2b\n"
                ".section __ex_table,\"a\"\n"
                " .căn chỉnh 4\n"
                " .dài 1b,3b\n"
                ".text" : "=r"(__gu_err), "=q" (__gu_val): "m"((ZZ0001ZZ)
                              ( __gu_addr )) ), "i"(- 14 ), "0"( __gu_err )) ;
                phá vỡ;
            trường hợp 2:
              __asm__ __dễ bay hơi__(
                "1: di chuyển" "w" " %2,%" "w" "1\n"
                "2:\n"
                ".section .fixup,\"ax\"\n"
                "3: di chuyển %3,%0\n"
                " xor" "w" " %" "w" "1,%" "w" "1\n"
                " jmp 2b\n"
                ".section __ex_table,\"a\"\n"
                " .căn chỉnh 4\n"
                " .dài 1b,3b\n"
                ".text" : "=r"(__gu_err), "=r" (__gu_val) : "m"((ZZ0002ZZ)
                              ( __gu_addr )) ), "i"(- 14 ), "0"( __gu_err ));
                phá vỡ;
            trường hợp 4:
              __asm__ __dễ bay hơi__(
                "1: di chuyển" "l" " %2,%" "" "1\n"
                "2:\n"
                ".section .fixup,\"ax\"\n"
                "3: di chuyển %3,%0\n"
                " xor" "l" " %" "" "1,%" "" "1\n"
                " jmp 2b\n"
                ".section __ex_table,\"a\"\n"
                " .align 4\n" " .long 1b,3b\n"
                ".text" : "=r"(__gu_err), "=r" (__gu_val) : "m"((ZZ0003ZZ)
                              ( __gu_addr )) ), "i"(- 14 ), "0"(__gu_err));
                phá vỡ;
            mặc định:
              (__gu_val) = __get_user_bad();
          }
        } trong khi (0);
      ((c)) = (__typeof__(*((buf))))__gu_val;
      __gu_err;
    }
  );

WOW! Đen GCC/ma thuật lắp ráp. Điều này là không thể làm theo, vì vậy chúng ta hãy
xem mã gcc tạo ra ::

> xorl %edx,%edx
 > movl current_set,%eax
 > cml $24,788(%eax)
 > tôi .L1424
 > cmpl $-1073741825,64(%esp)
 > ja .L1423
 > .L1424:
 > di chuyển %edx,%eax
 > movl 64(%esp),%ebx
 > #ZZ0003ZZ
 > 1: movb (%ebx),%dl /* đây là quyền truy cập thực tế của người dùng */
 > 2:
 > .section .fixup,"ax"
 > 3: di chuyển $-14,%eax
 > xorb %dl,%dl
 > jmp 2b
 > .section __ex_table,"a"
 > .căn chỉnh 4
 > .dài 1b,3b
 > .văn bản
 > #ZZ0004ZZ
 > .L1423:
 > movzbl %dl,%esi

Trình tối ưu hóa thực hiện tốt công việc và mang lại cho chúng tôi những gì chúng tôi thực sự có thể
hiểu. Chúng ta có thể không? Quyền truy cập thực tế của người dùng là khá rõ ràng. Cảm ơn
vào không gian địa chỉ thống nhất, chúng ta chỉ có thể truy cập địa chỉ trong người dùng
trí nhớ. Nhưng công cụ .section làm gì?????

Để hiểu điều này chúng ta phải nhìn vào kernel cuối cùng::

> objdump --section-headers vmlinux
 >
 > vmlinux: định dạng tệp elf32-i386
 >
 > Phần:
 > Tên Idx Kích thước VMA LMA Tắt Algn
 > 0 .text 00098f40 c0100000 c0100000 00001000 2**4
 > CONTENTS, ALLOC, LOAD, READONLY, CODE
 > 1 .fixup 000016bc c0198f40 c0198f40 00099f40 2**0
 > CONTENTS, ALLOC, LOAD, READONLY, CODE
 > 2 .rodata 0000f127 c019a5fc c019a5fc 0009b5fc 2**2
 > CONTENTS, ALLOC, LOAD, READONLY, DATA
 > 3 __ex_table 000015c0 c01a9724 c01a9724 000aa724 2**2
 > CONTENTS, ALLOC, LOAD, READONLY, DATA
 > 4 .data 0000ea58 c01abcf0 c01abcf0 000abcf0 2**4
 > CONTENTS, ALLOC, LOAD, DATA
 > 5 .bss 00018e21 c01ba748 c01ba748 000ba748 2**2
 > ALLOC
 > 6 .comment 00000ec4 00000000 00000000 000ba748 2**0
 > CONTENTS, READONLY
 > 7 .note 00001068 00000ec4 00000ec4 000bb60c 2**0
 > CONTENTS, READONLY

Rõ ràng có 2 phần ELF không chuẩn trong đối tượng được tạo
tập tin. Nhưng trước tiên chúng tôi muốn tìm hiểu điều gì đã xảy ra với mã của chúng tôi trong
hạt nhân cuối cùng có thể thực thi được::

> objdump --disassemble --section=.text vmlinux
 >
 > c017e785 <do_con_write+c1> xorl %edx,%edx
 > c017e787 <do_con_write+c3> movl 0xc01c7bec,%eax
 > c017e78c <do_con_write+c8> cmpl $0x18,0x314(%eax)
 > c017e793 <do_con_write+cf> je c017e79f <do_con_write+db>
 > c017e795 <do_con_write+d1> cmpl $0xbfffffff,0x40(%esp,1)
 > c017e79d <do_con_write+d9> và c017e7a7 <do_con_write+e3>
 > c017e79f <do_con_write+db> movl %edx,%eax
 > c017e7a1 <do_con_write+dd> movl 0x40(%esp,1),%ebx
 > c017e7a5 <do_con_write+e1> movb (%ebx),%dl
 > c017e7a7 <do_con_write+e3> movzbl %dl,%esi

Toàn bộ quyền truy cập bộ nhớ người dùng giảm xuống còn 10 lệnh máy x86.
Các hướng dẫn trong ngoặc trong chỉ thị .section không còn nữa
trong đường dẫn thực thi thông thường. Chúng nằm ở một phần khác
của tệp thực thi::

> objdump --disassemble --section=.fixup vmlinux
 >
 > c0199ff5 <.fixup+10b5> movl $0xfffffff2,%eax
 > c0199ffa <.fixup+10ba> xorb %dl,%dl
 > c0199ffc <.fixup+10bc> jmp c017e7a7 <do_con_write+e3>

Và cuối cùng::

> objdump --full-contents --section=__ex_table vmlinux
 >
 > c01aa7c4 93c017c0 e09f19c0 97c017c0 99c017c0 ..........
 > c01aa7d4 f6c217c0 e99f19c0 a5e717c0 f59f19c0 ..........
 > c01aa7e4 080a18c0 01a019c0 0a0a18c0 04a019c0 ..........

hoặc theo thứ tự byte có thể đọc được của con người::

> c01aa7c4 c017c093 c0199fe0 c017c097 c017c099 ..........
 > c01aa7d4 c017c2f6 c0199fe9 c017e7a5 c0199ff5 ..........
                               ^^ ^^^ ^^ ^^ ^^ ^^ ^^ ^^ ^^
                               đây là phần thú vị!
 > c01aa7e4 c0180a08 c019a001 c0180a0a c019a004 ..........

Chuyện gì đã xảy ra thế? Các chỉ thị lắp ráp::

.section .fixup,"ax"
  .section __ex_table,"a"

yêu cầu trình biên dịch mã di chuyển đoạn mã sau tới vị trí đã chỉ định
các phần trong tệp đối tượng ELF. Vì vậy, hướng dẫn::

3: di chuyển $-14,%eax
          xorb %dl,%dl
          jmp 2b

đã kết thúc ở phần .fixup của tệp đối tượng và các địa chỉ ::

.dài 1b,3b

đã kết thúc ở phần __ex_table của tệp đối tượng. 1b và 3b
là nhãn địa phương. Nhãn cục bộ 1b (1b là viết tắt của nhãn tiếp theo 1
lùi) là địa chỉ của lệnh có thể bị lỗi, tức là.
trong trường hợp của chúng tôi, địa chỉ của nhãn 1 là c017e7a5:
mã lắp ráp ban đầu: > 1: movb (%ebx),%dl
và được liên kết trong vmlinux : > c017e7a5 <do_con_write+e1> movb (%ebx),%dl

Nhãn cục bộ 3 (ngược lại) là địa chỉ của mã cần xử lý
lỗi, trong trường hợp của chúng tôi giá trị thực tế là c0199ff5:
mã lắp ráp ban đầu: > 3: movl $-14,%eax
và được liên kết trong vmlinux : > c0199ff5 <.fixup+10b5> movl $0xfffffff2,%eax

Nếu bản sửa lỗi có thể xử lý ngoại lệ, luồng điều khiển có thể được trả về
theo hướng dẫn sau lệnh gây ra lỗi, tức là. nhãn địa phương 2b.

Mã lắp ráp::

> .section __ex_table,"a"
 > .căn chỉnh 4
 > .dài 1b,3b

trở thành cặp giá trị::

> c01aa7d4 c017c2f6 c0199fe9 c017e7a5 c0199ff5 ..........
                               ^đây là ^đây là
                               1b 3b

c017e7a5,c0199ff5 trong bảng ngoại lệ của kernel.

Vì vậy, điều gì thực sự xảy ra nếu một lỗi từ chế độ kernel không phù hợp
vma xảy ra?

#. truy cập vào địa chỉ không hợp lệ::

> c017e7a5 <do_con_write+e1> movb (%ebx),%dl
#. MMU tạo ngoại lệ
#. CPU gọi exec_page_fault()
#. exc_page_fault() gọi do_user_addr_fault()
#. do_user_addr_fault() gọi kernelmode_fixup_or_oops()
#. kernelmode_fixup_or_oops() gọi fixup_Exception() (regs->eip == c017e7a5);
#. fixup_Exception() gọi search_Exception_tables()
#. search_Exception_tables() tra cứu địa chỉ c017e7a5 trong
   bảng ngoại lệ (tức là nội dung của phần ELF __ex_table)
   và trả về địa chỉ của mã xử lý lỗi liên quan c0199ff5.
#. fixup_Exception() sửa đổi địa chỉ trả về của chính nó để chỉ ra lỗi
   xử lý mã và trả về.
#. việc thực thi tiếp tục trong mã xử lý lỗi.
#. a) EAX trở thành -EFAULT (== -14)
   b) DL trở thành 0 (giá trị chúng tôi "đọc" từ không gian người dùng)
   c) việc thực thi tiếp tục ở nhãn cục bộ 2 (địa chỉ của
      hướng dẫn ngay sau khi người dùng truy cập bị lỗi).

Các bước từ a đến c ở trên mô phỏng theo hướng dẫn khắc phục lỗi.

Hầu hết là thế. Nếu bạn nhìn vào ví dụ của chúng tôi, bạn có thể hỏi tại sao
chúng tôi đặt EAX thành -EFAULT trong mã xử lý ngoại lệ. Vâng, cái
macro get_user() thực sự trả về giá trị: 0, nếu quyền truy cập của người dùng là
thành công, -EFAULT thất bại. Mã ban đầu của chúng tôi đã không kiểm tra điều này
giá trị trả về, tuy nhiên mã tập hợp nội tuyến trong get_user() cố gắng
trả về -EFAULT. GCC đã chọn EAX để trả về giá trị này.

NOTE:
Do cách xây dựng bảng ngoại lệ và cần phải được sắp xếp,
chỉ sử dụng ngoại lệ cho mã trong phần .text.  Bất kỳ phần nào khác
sẽ khiến bảng ngoại lệ không được sắp xếp chính xác và
ngoại lệ sẽ thất bại.

Mọi thứ đã thay đổi khi hỗ trợ 64-bit được thêm vào x86 Linux. Thay vì
tăng gấp đôi kích thước của bảng ngoại lệ bằng cách mở rộng hai mục
từ 32 bit lên 64 bit, một thủ thuật thông minh đã được sử dụng để lưu trữ địa chỉ
như độ lệch tương đối từ chính bảng đó. Mã lắp ráp đã thay đổi
từ::

.dài 1b,3b
  đến:
          .long (từ) - .
          .long (đến) - .

và mã C sử dụng các giá trị này sẽ chuyển đổi trở lại địa chỉ tuyệt đối
như thế này::

ex_insn_addr(const struct ngoại lệ_table_entry *x)
	{
		return (dài không dấu)&x->insn + x->insn;
	}

Trong v4.6, mục nhập bảng ngoại lệ đã được mở rộng với "trình xử lý" trường mới.
Nó cũng rộng 32 bit và chứa hàm tương đối thứ ba
con trỏ trỏ đến một trong:

1) ZZ0000ZZ
     Đây là trường hợp cũ chỉ chuyển sang mã sửa lỗi

2) ZZ0000ZZ
     Trường hợp này cung cấp số lỗi của bẫy xảy ra tại
     mục->insn. Nó được sử dụng để phân biệt lỗi trang với máy
     kiểm tra.

Có thể dễ dàng thêm nhiều chức năng hơn.

CONFIG_BUILDTIME_TABLE_SORT cho phép phần __ex_table được sắp xếp bài đăng
liên kết của hình ảnh hạt nhân, thông qua tập lệnh/bảng sắp xếp tiện ích máy chủ. Nó sẽ thiết lập
ký hiệu main_extable_sort_ Need thành 0, tránh sắp xếp phần __ex_table
lúc khởi động. Với bảng ngoại lệ được sắp xếp, trong thời gian chạy khi có ngoại lệ
xảy ra, chúng ta có thể nhanh chóng tra cứu mục __ex_table thông qua tìm kiếm nhị phân.

Đây không chỉ là tối ưu hóa thời gian khởi động, một số kiến trúc yêu cầu điều này
bảng được sắp xếp để xử lý các ngoại lệ tương đối sớm khi khởi động
quá trình. Ví dụ: i386 sử dụng hình thức xử lý ngoại lệ này trước
hỗ trợ phân trang thậm chí còn được kích hoạt!