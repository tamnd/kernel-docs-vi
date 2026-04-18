.. SPDX-License-Identifier: GPL-2.0-only

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/dev-tools/checkuapi.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

===================
Trình kiểm tra UAPI
===================

Trình kiểm tra UAPI (ZZ0000ZZ) là một tập lệnh shell
kiểm tra các tệp tiêu đề UAPI để biết khả năng tương thích ngược của không gian người dùng trên
cây git.

Tùy chọn
========

Phần này sẽ mô tả các tùy chọn mà ZZ0000ZZ sử dụng
có thể được chạy.

Cách sử dụng::

check-uapi.sh [-b BASE_REF] [-p PAST_REF] [-j N] [-l ERROR_LOG] [-i] [-q] [-v]

Tùy chọn có sẵn::

-b BASE_REF Tham chiếu git cơ sở để sử dụng để so sánh. Nếu không được chỉ định hoặc trống,
                   sẽ sử dụng bất kỳ thay đổi xấu nào trong cây đối với các tệp UAPI. Nếu không có
                   những thay đổi không tốt, HEAD sẽ được sử dụng.
    -p PAST_REF So sánh BASE_REF với PAST_REF (ví dụ -p v6.1). Nếu không được chỉ định hoặc trống,
                   sẽ sử dụng BASE_REF^1. Phải là tổ tiên của BASE_REF. Chỉ tiêu đề
                   tồn tại trên PAST_REF sẽ được kiểm tra tính tương thích.
    -j JOBS Số lượng kiểm tra để chạy song song (mặc định: số lõi CPU).
    -l ERROR_LOG Ghi nhật ký lỗi vào tệp (mặc định: không có nhật ký lỗi nào được tạo).
    -i Bỏ qua những thay đổi mơ hồ có thể hoặc không phá vỡ tính tương thích của UAPI.
    -q Hoạt động yên tĩnh.
    -v Thao tác dài dòng (in thêm thông tin về từng tiêu đề đang được kiểm tra).

Lập luận về môi trường::

ABIDIFF Đường dẫn tùy chỉnh tới nhị phân abidiff
    Trình biên dịch CC C (mặc định là "gcc")
    ARCH Kiến trúc đích của trình biên dịch C (mặc định là Host Arch)

Mã thoát::

0) Thành công
    1) Đã phát hiện sự khác biệt ABI
    2) Điều kiện tiên quyết không được đáp ứng

Ví dụ
========

Cách sử dụng cơ bản
-------------------

Trước tiên, hãy thử thực hiện thay đổi đối với tệp tiêu đề UAPI mà rõ ràng
sẽ không phá vỡ không gian người dùng::

mèo << 'EOF' | vá -l -p1
    --- a/include/uapi/linux/acct.h
    +++ b/include/uapi/linux/acct.h
    @@ -21,7 +21,9 @@
     #include <asm/param.h>
     #include <asm/byteorder.h>

-/*
    +#define FOO
    +
    +/*
      * comp_t là số dấu phẩy động 16 bit với cơ số 8 3 bit
      * số mũ và phân số 13 bit.
      * comp2_t là 24-bit với số mũ cơ số 2 5-bit và phân số 20-bit
    khác --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
    EOF

Bây giờ, hãy sử dụng tập lệnh để xác thực ::

% ./scripts/check-uapi.sh
    Đang cài đặt các tiêu đề UAPI hướng tới người dùng từ cây bẩn... OK
    Đang cài đặt các tiêu đề UAPI hướng tới người dùng từ HEAD... OK
    Đang kiểm tra các thay đổi đối với tiêu đề UAPI giữa HEAD và cây bẩn...
    Tất cả các tiêu đề 912 UAPI tương thích với x86 dường như tương thích ngược

Hãy thêm một thay đổi khác khiến ZZ0000ZZ phá vỡ không gian người dùng::

mèo << 'EOF' | vá -l -p1
    --- a/include/uapi/linux/bpf.h
    +++ b/include/uapi/linux/bpf.h
    @@ -74,7 +74,7 @@ struct bpf_insn {
            __u8 dst_reg:4;      /*đăng ký đích */
            __u8 src_reg:4;      /*thanh ghi nguồn */
            __s16 tắt;            /* offset đã ký */
    - __s32 im;            /* hằng ký có dấu ngay lập tức */
    + __u32 im;            /* Hằng số tức thời không dấu */
     };

/* Khóa của mục nhập BPF_MAP_TYPE_LPM_TRIE */
    EOF

Kịch bản sẽ nắm bắt được điều này ::

% ./scripts/check-uapi.sh
    Đang cài đặt các tiêu đề UAPI hướng tới người dùng từ cây bẩn... OK
    Đang cài đặt các tiêu đề UAPI hướng tới người dùng từ HEAD... OK
    Đang kiểm tra các thay đổi đối với tiêu đề UAPI giữa HEAD và cây bẩn...
    ==== Sự khác biệt của ABI được phát hiện trong include/linux/bpf.h từ HEAD -> cây bẩn ====
        [C] 'struct bpf_insn' đã thay đổi:
          kích thước loại không thay đổi
          1 thành viên dữ liệu thay đổi:
            loại '__s32 imm' đã thay đổi:
              Tên typedef đã thay đổi từ __s32 thành __u32 tại int-ll64.h:27:1
              loại cơ bản 'int' đã thay đổi:
                tên loại đã thay đổi từ 'int' thành 'unsign int'
                kích thước loại không thay đổi
    =========================================================================================

lỗi - 1/912 tiêu đề UAPI tương thích với x86 có vẻ như _không_ tương thích ngược

Trong trường hợp này, tập lệnh đang báo cáo sự thay đổi kiểu vì nó có thể
phá vỡ chương trình không gian người dùng chuyển sang số âm. Bây giờ, hãy
giả sử bạn biết rằng không có chương trình không gian người dùng nào có thể sử dụng phủ định
giá trị trong ZZ0000ZZ, vì vậy việc thay đổi sang loại không dấu sẽ không gây hại gì
bất cứ điều gì. Bạn có thể chuyển cờ ZZ0001ZZ cho tập lệnh để bỏ qua các thay đổi
trong đó khả năng tương thích ngược của không gian người dùng không rõ ràng::

% ./scripts/check-uapi.sh -i
    Đang cài đặt các tiêu đề UAPI hướng tới người dùng từ cây bẩn... OK
    Đang cài đặt các tiêu đề UAPI hướng tới người dùng từ HEAD... OK
    Đang kiểm tra các thay đổi đối với tiêu đề UAPI giữa HEAD và cây bẩn...
    Tất cả các tiêu đề 912 UAPI tương thích với x86 dường như tương thích ngược

Bây giờ, hãy thực hiện một thay đổi tương tự để ZZ0000ZZ phá vỡ không gian người dùng::

mèo << 'EOF' | vá -l -p1
    --- a/include/uapi/linux/bpf.h
    +++ b/include/uapi/linux/bpf.h
    @@ -71,8 +71,8 @@ enum {

cấu trúc bpf_insn {
            __u8 mã;           /* mã lệnh */
    - __u8 dst_reg:4;      /*đăng ký đích */
            __u8 src_reg:4;      /*thanh ghi nguồn */
    + __u8 dst_reg:4;      /*đăng ký đích */
            __s16 tắt;            /* offset đã ký */
            __s32 im;            /* hằng ký có dấu ngay lập tức */
     };
    EOF

Vì chúng tôi đang sắp xếp lại một thành viên cấu trúc hiện có nên không có gì mơ hồ,
và tập lệnh sẽ báo lỗi ngay cả khi bạn vượt qua ZZ0000ZZ::

% ./scripts/check-uapi.sh -i
    Đang cài đặt các tiêu đề UAPI hướng tới người dùng từ cây bẩn... OK
    Đang cài đặt các tiêu đề UAPI hướng tới người dùng từ HEAD... OK
    Đang kiểm tra các thay đổi đối với tiêu đề UAPI giữa HEAD và cây bẩn...
    ==== Sự khác biệt của ABI được phát hiện trong include/linux/bpf.h từ HEAD -> cây bẩn ====
        [C] 'struct bpf_insn' đã thay đổi:
          kích thước loại không thay đổi
          2 thay đổi thành viên dữ liệu:
            Độ lệch '__u8 dst_reg' đã thay đổi từ 8 thành 12 (tính bằng bit) (bằng +4 bit)
            Phần bù '__u8 src_reg' đã thay đổi từ 12 thành 8 (tính bằng bit) (bằng -4 bit)
    =========================================================================================

lỗi - 1/912 tiêu đề UAPI tương thích với x86 có vẻ như _không_ tương thích ngược

Hãy thực hiện thay đổi đột phá, sau đó thực hiện thay đổi vô hại::

% git commit -m 'Phá vỡ thay đổi UAPI' bao gồm/uapi/linux/bpf.h
    [tách rời HEAD f758e574663a] Phá vỡ UAPI thay đổi
     1 tệp đã thay đổi, 1 lần chèn (+), 1 lần xóa (-)
    % git commit -m 'Thay đổi UAPI vô hại' include/uapi/linux/acct.h
    [HEAD 2e87df769081 đã tách ra] Thay đổi UAPI vô hại
     Đã thay đổi 1 tệp, 3 lần chèn (+), 1 xóa (-)

Bây giờ, hãy chạy lại tập lệnh mà không có đối số::

% ./scripts/check-uapi.sh
    Đang cài đặt các tiêu đề UAPI hướng tới người dùng từ HEAD... OK
    Đang cài đặt các tiêu đề UAPI hướng tới người dùng từ HEAD^1... OK
    Đang kiểm tra các thay đổi đối với tiêu đề UAPI giữa HEAD^1 và HEAD...
    Tất cả các tiêu đề 912 UAPI tương thích với x86 dường như tương thích ngược

Nó không bắt được bất kỳ thay đổi đột phá nào vì theo mặc định, nó chỉ
so sánh ZZ0000ZZ với ZZ0001ZZ. Thay đổi đột phá đã được thực hiện vào
ZZ0002ZZ. Nếu chúng tôi muốn phạm vi tìm kiếm quay trở lại xa hơn, chúng tôi phải
sử dụng tùy chọn ZZ0003ZZ để chuyển một tham chiếu quá khứ khác. Trong trường hợp này,
hãy chuyển ZZ0004ZZ vào tập lệnh để nó kiểm tra các thay đổi của UAPI giữa
ZZ0005ZZ và ZZ0006ZZ::

% ./scripts/check-uapi.sh -p HEAD~2
    Đang cài đặt các tiêu đề UAPI hướng tới người dùng từ HEAD... OK
    Đang cài đặt các tiêu đề UAPI hướng tới người dùng từ HEAD~2... OK
    Đang kiểm tra các thay đổi đối với tiêu đề UAPI giữa HEAD~2 và HEAD...
    ==== Sự khác biệt của ABI được phát hiện trong include/linux/bpf.h từ HEAD~2 -> HEAD ====
        [C] 'struct bpf_insn' đã thay đổi:
          kích thước loại không thay đổi
          2 thay đổi thành viên dữ liệu:
            Độ lệch '__u8 dst_reg' đã thay đổi từ 8 thành 12 (tính bằng bit) (bằng +4 bit)
            Phần bù '__u8 src_reg' đã thay đổi từ 12 thành 8 (tính bằng bit) (bằng -4 bit)
    ====================================================================================

lỗi - 1/912 tiêu đề UAPI tương thích với x86 có vẻ như _không_ tương thích ngược

Ngoài ra, chúng tôi cũng có thể chạy với ZZ0000ZZ. Điều này sẽ thiết lập
tham chiếu cơ sở đến ZZ0001ZZ để tập lệnh sẽ so sánh nó với ZZ0002ZZ.

Tiêu đề dành riêng cho kiến ​​trúc
----------------------------------

Hãy xem xét sự thay đổi này::

mèo << 'EOF' | vá -l -p1
    --- a/arch/arm64/include/uapi/asm/sigcontext.h
    +++ b/arch/arm64/include/uapi/asm/sigcontext.h
    @@ -70,6 +70,7 @@ struct sigcontext {
     cấu trúc _aarch64_ctx {
            __u32 phép thuật;
            __u32 kích thước;
    + __u32 new_var;
     };

#define FPSIMD_MAGIC 0x46508001
    EOF

Đây là một thay đổi đối với tệp tiêu đề UAPI dành riêng cho arm64. Trong ví dụ này, tôi
chạy tập lệnh từ máy x86 với trình biên dịch x86, do đó, theo mặc định,
tập lệnh chỉ kiểm tra các tệp tiêu đề UAPI tương thích x86 ::

% ./scripts/check-uapi.sh
    Đang cài đặt các tiêu đề UAPI hướng tới người dùng từ cây bẩn... OK
    Đang cài đặt các tiêu đề UAPI hướng tới người dùng từ HEAD... OK
    Không có thay đổi nào đối với tiêu đề UAPI được áp dụng giữa HEAD và cây bẩn

Với trình biên dịch x86, chúng tôi không thể kiểm tra các tệp tiêu đề trong ZZ0000ZZ, vì vậy
kịch bản thậm chí không thử.

Nếu muốn kiểm tra tệp tiêu đề, chúng ta sẽ phải sử dụng trình biên dịch arm64 và
đặt ZZ0000ZZ tương ứng::

% CC=aarch64-linux-gnu-gcc ARCH=arm64 ./scripts/check-uapi.sh
    Đang cài đặt các tiêu đề UAPI hướng tới người dùng từ cây bẩn... OK
    Đang cài đặt các tiêu đề UAPI hướng tới người dùng từ HEAD... OK
    Đang kiểm tra các thay đổi đối với tiêu đề UAPI giữa HEAD và cây bẩn...
    ==== Sự khác biệt của ABI được phát hiện trong include/asm/sigcontext.h từ HEAD -> cây bẩn ====
        [C] 'struct _aarch64_ctx' đã thay đổi:
          kích thước loại đã thay đổi từ 64 thành 96 (tính bằng bit)
          Chèn 1 thành viên dữ liệu:
            '__u32 new_var', ở độ lệch 64 (tính bằng bit) tại sigcontext.h:73:1
        -- bắn tỉa --
        [C] 'struct zt_context' đã thay đổi:
          kích thước loại đã thay đổi từ 128 thành 160 (tính bằng bit)
          2 thay đổi thành viên dữ liệu (1 đã lọc):
            Độ lệch '__u16 nregs' đã thay đổi từ 64 thành 96 (tính bằng bit) (bằng +32 bit)
            Phần bù '__u16 __reserved[3]' đã thay đổi từ 80 thành 112 (tính bằng bit) (bằng +32 bit)
    ==============================================================================================

lỗi - Các tiêu đề 1/884 UAPI tương thích với arm64 có vẻ như _not_ tương thích ngược

Chúng ta có thể thấy với ZZ0000ZZ và ZZ0001ZZ được đặt đúng cho tệp, ABI
thay đổi được báo cáo chính xác. Cũng lưu ý rằng tổng số UAPI
các tập tin tiêu đề được kiểm tra bởi những thay đổi của tập lệnh. Điều này là do số
số tiêu đề được cài đặt cho nền tảng arm64 khác với x86.

Sự cố phụ thuộc chéo
--------------------------

Hãy xem xét sự thay đổi này::

mèo << 'EOF' | vá -l -p1
    --- a/include/uapi/linux/types.h
    +++ b/include/uapi/linux/types.h
    @@ -52,7 +52,7 @@ typedef __u32 __bitwise __wsum;
     #define __aligned_be64 __be64 __attribute__((aligned(8)))
     #define __aligned_le64 __le64 __attribute__((aligned(8)))

-typedef không dấu __bitwise __poll_t;
    +typedef không dấu ngắn __bitwise __poll_t;

#endif /*__ASSEMBLY__ */
     #endif /* _UAPI_LINUX_TYPES_H */
    EOF

Ở đây, chúng tôi đang thay đổi ZZ0000ZZ thành ZZ0001ZZ. Điều này không phá vỡ
UAPI trong ZZ0002ZZ, nhưng các UAPI khác trong cây có thể bị hỏng do
sự thay đổi này::

% ./scripts/check-uapi.sh
    Đang cài đặt các tiêu đề UAPI hướng tới người dùng từ cây bẩn... OK
    Đang cài đặt các tiêu đề UAPI hướng tới người dùng từ HEAD... OK
    Đang kiểm tra các thay đổi đối với tiêu đề UAPI giữa HEAD và cây bẩn...
    ==== Sự khác biệt của ABI được phát hiện trong include/linux/eventpoll.h từ HEAD -> cây bẩn ====
        [C] 'struct epoll_event' đã thay đổi:
          kích thước loại đã thay đổi từ 96 thành 80 (tính bằng bit)
          2 thay đổi thành viên dữ liệu:
            loại '__poll_t sự kiện' đã thay đổi:
              loại cơ bản 'unsign int' đã thay đổi:
                tên loại đã thay đổi từ 'unsign int' thành 'unsign short int'
                kích thước loại đã thay đổi từ 32 thành 16 (tính bằng bit)
            Độ lệch '__u64 dữ liệu' đã thay đổi từ 32 thành 16 (tính bằng bit) (bằng -16 bit)
    =========================================================================================================
    include/linux/eventpoll.h không thay đổi giữa HEAD và cây bẩn...
    Có thể sự thay đổi đối với một trong các tiêu đề mà nó bao gồm đã gây ra lỗi này:
    #include <linux/fcntl.h>
    #include <linux/types.h>

Lưu ý rằng tập lệnh nhận thấy tệp tiêu đề bị lỗi không thay đổi,
vì vậy nó cho rằng một trong những bộ phận của nó chắc chắn đã gây ra sự cố. Thật vậy,
chúng ta có thể thấy ZZ0000ZZ được sử dụng từ ZZ0001ZZ.

Loại bỏ tiêu đề UAPI
--------------------

Hãy xem xét sự thay đổi này::

mèo << 'EOF' | vá -l -p1
    diff --git a/include/uapi/asm-generic/Kbuild b/include/uapi/asm-generic/Kbuild
    chỉ số ebb180aac74e..a9c88b0a8b3b 100644
    --- a/include/uapi/asm-generic/Kbuild
    +++ b/include/uapi/asm-generic/Kbuild
    @@ -31,6 +31,6 @@ bắt buộc-y += stat.h
     bắt buộc-y += statfs.h
     bắt buộc-y += Swap.h
     bắt buộc-y += termbits.h
    -bắt buộc-y += termios.h
    +#mandatory-y += termios.h
     bắt buộc-y += type.h
     bắt buộc-y += unistd.h
    EOF

Tập lệnh này xóa tệp tiêu đề UAPI khỏi danh sách cài đặt. Hãy chạy đi
kịch bản::

% ./scripts/check-uapi.sh
    Đang cài đặt các tiêu đề UAPI hướng tới người dùng từ cây bẩn... OK
    Đang cài đặt các tiêu đề UAPI hướng tới người dùng từ HEAD... OK
    Đang kiểm tra các thay đổi đối với tiêu đề UAPI giữa HEAD và cây bẩn...
    ==== Tiêu đề UAPI bao gồm/asm/termios.h đã bị xóa giữa HEAD và cây bẩn ====

lỗi - 1/912 tiêu đề UAPI tương thích với x86 có vẻ như _không_ tương thích ngược

Việc xóa tiêu đề UAPI được coi là một thay đổi đột phá và tập lệnh
sẽ gắn cờ nó như vậy.

Kiểm tra khả năng tương thích UAPI lịch sử
------------------------------------------

Bạn có thể sử dụng các tùy chọn ZZ0000ZZ và ZZ0001ZZ để kiểm tra các phần khác nhau của
cây git. Ví dụ: để kiểm tra tất cả các tệp tiêu đề UAPI đã thay đổi giữa các thẻ
v6.0 và v6.1, bạn sẽ chạy::

% ./scripts/check-uapi.sh -b v6.1 -p v6.0
    Đang cài đặt các tiêu đề UAPI hướng tới người dùng từ v6.1... OK
    Đang cài đặt các tiêu đề UAPI hướng tới người dùng từ v6.0... OK
    Đang kiểm tra các thay đổi đối với tiêu đề UAPI giữa v6.0 và v6.1...

--- bắn tỉa ---
    lỗi - 37/907 Tiêu đề UAPI tương thích với x86 có vẻ như _không_ tương thích ngược

Lưu ý: Trước v5.3, không có tệp tiêu đề mà tập lệnh cần,
vì vậy tập lệnh không thể kiểm tra các thay đổi trước đó.

Bạn sẽ nhận thấy rằng tập lệnh đã phát hiện nhiều thay đổi UAPI không đúng.
tương thích ngược. Biết rằng UAPI kernel được cho là ổn định
mãi mãi, đây là một kết quả đáng báo động. Điều này đưa chúng ta đến phần tiếp theo:
hãy cẩn thận.

Hãy cẩn thận
============

Trình kiểm tra UAPI không đưa ra giả định nào về ý định của tác giả, vì vậy một số
các loại thay đổi có thể bị gắn cờ ngay cả khi chúng cố tình phá vỡ UAPI.

Loại bỏ để tái cấu trúc hoặc ngừng sử dụng
------------------------------------------

Đôi khi trình điều khiển cho phần cứng rất cũ bị xóa, chẳng hạn như trong ví dụ này::

% ./scripts/check-uapi.sh -b ba47652ba655
    Đang cài đặt tiêu đề UAPI hướng tới người dùng từ ba47652ba655... OK
    Đang cài đặt tiêu đề UAPI hướng tới người dùng từ ba47652ba655^1... OK
    Đang kiểm tra các thay đổi đối với tiêu đề UAPI giữa ba47652ba655^1 và ba47652ba655...
    ==== Tiêu đề UAPI bao gồm/linux/meye.h đã bị xóa giữa ba47652ba655^1 và ba47652ba655 ====

lỗi - 1/910 tiêu đề UAPI tương thích với x86 có vẻ như _không_ tương thích ngược

Tập lệnh sẽ luôn gắn cờ các hành động xóa (ngay cả khi hành động đó là cố ý).

Mở rộng cấu trúc
-----------------

Tùy thuộc vào cách xử lý cấu trúc trong không gian kernel, một thay đổi sẽ
mở rộng một cấu trúc có thể không bị phá vỡ.

Nếu một cấu trúc được sử dụng làm đối số cho ioctl thì trình điều khiển hạt nhân
phải có khả năng xử lý các lệnh ioctl ở mọi kích thước. Ngoài ra, bạn cần
phải cẩn thận khi sao chép dữ liệu từ người dùng. Ví dụ như nói rằng
ZZ0000ZZ được thay đổi như thế này::

cấu trúc foo {
        __u64 một; /* đã thêm vào phiên bản 1 */
    +__u32b; /* đã thêm vào phiên bản 2 */
    +__u32c; /* đã thêm vào phiên bản 2 */
    }

Theo mặc định, tập lệnh sẽ gắn cờ loại thay đổi này để xem xét thêm::

[C] 'struct foo' đã thay đổi:
      kích thước loại đã thay đổi từ 64 thành 128 (tính bằng bit)
      2 lần chèn thành viên dữ liệu:
        '__u32 b', ở độ lệch 64 (tính bằng bit)
        '__u32 c', ở độ lệch 96 (tính bằng bit)

Tuy nhiên, có thể sự thay đổi này đã được thực hiện một cách an toàn.

Nếu một chương trình không gian người dùng được xây dựng bằng phiên bản 1, nó sẽ nghĩ
ZZ0000ZZ là 8. Kích thước đó sẽ được mã hóa trong
giá trị ioctl được gửi tới kernel. Nếu kernel được xây dựng
với phiên bản 2 thì sẽ tưởng ZZ0001ZZ là 16.

Hạt nhân có thể sử dụng macro ZZ0000ZZ để mã hóa kích thước
trong mã ioctl mà người dùng đã chuyển vào rồi sử dụng
ZZ0001ZZ để sao chép giá trị một cách an toàn::

int Handle_ioctl(cmd dài không dấu, arg dài không dấu)
    {
        chuyển _IOC_NR(cmd) {
        0x01: {
            struct foo my_cmd;  /* kích thước 16 trong kernel */

ret = copy_struct_from_user(&my_cmd, arg, sizeof(struct foo), _IOC_SIZE(cmd));
            ...

ZZ0000ZZ sẽ xóa cấu trúc trong kernel và sau đó sao chép
chỉ các byte được truyền vào từ người dùng (để lại các thành viên mới bằng 0).
Nếu người dùng chuyển vào một cấu trúc lớn hơn thì các thành viên bổ sung sẽ bị bỏ qua.

Nếu bạn biết tình huống này được tính đến trong mã hạt nhân, bạn có thể
chuyển ZZ0000ZZ vào tập lệnh và việc mở rộng cấu trúc như thế này sẽ bị bỏ qua.

Di chuyển mảng Flex
--------------------

Mặc dù tập lệnh xử lý việc mở rộng thành một mảng linh hoạt hiện có, nhưng nó thực hiện
vẫn gắn cờ di chuyển ban đầu sang mảng flex từ flex giả 1 phần tử
mảng. Ví dụ::

cấu trúc foo {
          __u32x;
    - __u32 flex[1]; /* uốn cong giả */
    + __u32 flex[];  /* linh hoạt thực sự */
    };

Thay đổi này sẽ được gắn cờ bởi tập lệnh::

[C] 'struct foo' đã thay đổi:
      kích thước loại đã thay đổi từ 64 thành 32 (tính bằng bit)
      1 thành viên dữ liệu thay đổi:
        loại '__u32 flex[1]' đã thay đổi:
          tên loại đã thay đổi từ '__u32[1]' thành '__u32[]'
          kích thước kiểu mảng đã thay đổi từ 32 thành 'không xác định'
          loại mảng con 1 đã thay đổi độ dài từ 1 thành 'không xác định'

Tại thời điểm này, không có cách nào để lọc những loại thay đổi này, vì vậy hãy
nhận thức được điều này có thể là dương tính giả.

Bản tóm tắt
-----------

Mặc dù nhiều loại kết quả dương tính giả được tập lệnh lọc ra,
có thể có một số trường hợp tập lệnh đánh dấu sự thay đổi
không phá vỡ UAPI. Cũng có thể là một sự thay đổi mà ZZ0000ZZ
phá vỡ không gian người dùng sẽ không bị tập lệnh này gắn cờ. Trong khi kịch bản
đã được chạy trên phần lớn lịch sử kernel, vẫn có thể có góc
những trường hợp không được tính đến.

Mục đích là để tập lệnh này được sử dụng để kiểm tra nhanh
người bảo trì hoặc công cụ tự động, không phải là người có thẩm quyền cuối cùng đối với
khả năng tương thích của bản vá. Điều tốt nhất nên nhớ: hãy sử dụng khả năng phán đoán tốt nhất của bạn
(và lý tưởng nhất là kiểm tra đơn vị trong không gian người dùng) để đảm bảo UAPI của bạn thay đổi
tương thích ngược!