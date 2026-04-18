.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/arch/riscv/vector.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

=============================================
Hỗ trợ mở rộng vectơ cho RISC-V Linux
=========================================

Tài liệu này phác thảo ngắn gọn giao diện được Linux cung cấp cho không gian người dùng trong
để hỗ trợ việc sử dụng Phần mở rộng Vector RISC-V.

1. Giao diện prctl()
---------------------

Hai lệnh gọi prctl() mới được thêm vào để cho phép các chương trình quản lý khả năng hỗ trợ
trạng thái sử dụng Vector trong không gian người dùng. Hướng dẫn sử dụng dự kiến dành cho
các giao diện này nhằm cung cấp cho các hệ thống init một cách để sửa đổi tính khả dụng của V
cho các tiến trình đang chạy trong miền của nó. Việc gọi những giao diện này không
được đề xuất trong quy trình thư viện vì thư viện không nên ghi đè chính sách
được cấu hình từ tiến trình gốc. Ngoài ra, người dùng phải lưu ý rằng các giao diện này
không thể di chuyển sang môi trường không phải Linux hoặc không phải RISC-V, vì vậy không khuyến khích
để sử dụng trong một mã di động. Để có được tính khả dụng của V trong chương trình ELF,
vui lòng đọc bit ZZ0000ZZ của ZZ0001ZZ trong
vectơ phụ trợ.

* prctl(PR_RISCV_V_SET_CONTROL, đối số dài không dấu)

Đặt trạng thái hỗ trợ Vector của luồng đang gọi, trong đó điều khiển
    đối số bao gồm hai trạng thái kích hoạt 2 bit và một bit dành cho kế thừa
    chế độ. Các luồng khác của quá trình gọi không bị ảnh hưởng.

Trạng thái kích hoạt là một giá trị ba trạng thái, mỗi trạng thái chiếm 2 bit không gian trong
    đối số điều khiển:

* ZZ0000ZZ: Sử dụng mặc định toàn hệ thống
      trạng thái kích hoạt trên execve(). Cài đặt mặc định trên toàn hệ thống có thể là
      được điều khiển thông qua giao diện sysctl (xem phần sysctl bên dưới).

* ZZ0000ZZ: Cho phép chạy Vector
      chủ đề.

* ZZ0000ZZ: Không cho phép Vector. Vectơ thực thi
      hướng dẫn trong điều kiện như vậy sẽ bẫy và gây ra sự chấm dứt của luồng.

arg: Đối số điều khiển là giá trị 5 bit gồm 3 phần và
    được truy cập bởi 3 mặt nạ tương ứng.

3 chiếc mặt nạ PR_RISCV_V_VSTATE_CTRL_CUR_MASK,
    PR_RISCV_V_VSTATE_CTRL_NEXT_MASK và PR_RISCV_V_VSTATE_CTRL_INHERIT
    đại diện cho bit[1:0], bit[3:2] và bit[4]. bit[1:0] chiếm
    trạng thái kích hoạt của luồng hiện tại và cài đặt ở bit[3:2] diễn ra
    ở lần thực hiện tiếp theo(). bit[4] xác định chế độ kế thừa của cài đặt trong
    bit[3:2].

* ZZ0000ZZ: bit[1:0]: Tài khoản cho
          Trạng thái hỗ trợ vectơ cho chuỗi cuộc gọi. Chủ đề gọi là
          không thể tắt Vector khi nó đã được bật. Cuộc gọi prctl()
          không thành công với EPERM nếu giá trị trong mặt nạ này là PR_RISCV_V_VSTATE_CTRL_OFF
          nhưng trạng thái kích hoạt hiện tại không tắt. Cài đặt
          PR_RISCV_V_VSTATE_CTRL_DEFAULT ở đây không có tác dụng gì ngoài việc thiết lập lại
          trạng thái kích hoạt ban đầu.

* ZZ0000ZZ: bit[3:2]: Tài khoản cho
          Cài đặt hỗ trợ vectơ cho chuỗi cuộc gọi tại execve() tiếp theo
          cuộc gọi hệ thống. Nếu PR_RISCV_V_VSTATE_CTRL_DEFAULT được sử dụng trong mặt nạ này,
          thì trạng thái kích hoạt sẽ do toàn hệ thống quyết định
          trạng thái hỗ trợ khi execve() xảy ra.

* ZZ0000ZZ: bit[4]: phần kế thừa
          chế độ cài đặt tại PR_RISCV_V_VSTATE_CTRL_NEXT_MASK. Nếu chút
          được đặt thì lệnh execve() sau đây sẽ không xóa cài đặt trong cả hai
          PR_RISCV_V_VSTATE_CTRL_NEXT_MASK và PR_RISCV_V_VSTATE_CTRL_INHERIT.
          Cài đặt này vẫn tồn tại khi có những thay đổi về giá trị mặc định trên toàn hệ thống.

Giá trị trả về:
        * 0 khi thành công;
        * EINVAL: Vector không được hỗ trợ, trạng thái kích hoạt không hợp lệ cho hiện tại hoặc
          mặt nạ tiếp theo;
        * EPERM: Tắt Vector trong PR_RISCV_V_VSTATE_CTRL_CUR_MASK nếu Vector
          đã được kích hoạt cho chuỗi cuộc gọi.

Về thành công:
        * Cài đặt hợp lệ cho PR_RISCV_V_VSTATE_CTRL_CUR_MASK diễn ra
          ngay lập tức. Trạng thái kích hoạt được chỉ định trong
          PR_RISCV_V_VSTATE_CTRL_NEXT_MASK xảy ra ở lệnh gọi execve() tiếp theo hoặc
          tất cả các lệnh gọi execve() sau đây nếu bit PR_RISCV_V_VSTATE_CTRL_INHERIT là
          thiết lập.
        * Mỗi cuộc gọi thành công sẽ ghi đè cài đặt trước đó cho cuộc gọi
          chủ đề.

* prctl(PR_RISCV_V_GET_CONTROL)

Nhận trạng thái hỗ trợ Vector tương tự cho chuỗi cuộc gọi. Cài đặt cho
    lệnh gọi execve() tiếp theo và bit kế thừa đều là OR-ed cùng nhau.

Lưu ý rằng các chương trình ELF có thể có được sự sẵn có của V bằng cách
    đọc bit ZZ0000ZZ của ZZ0001ZZ trong
    vectơ phụ trợ.

Giá trị trả về:
        * giá trị không âm về thành công;
        * EINVAL: Vector không được hỗ trợ.

2. Cấu hình thời gian chạy hệ thống (sysctl)
-----------------------------------------

Để giảm thiểu tác động của ABI khi mở rộng ngăn xếp tín hiệu,
cơ chế chính sách được cung cấp cho quản trị viên, người duy trì bản phân phối và
nhà phát triển kiểm soát trạng thái bật Vector mặc định cho không gian người dùng
các quy trình ở dạng núm sysctl:

* /proc/sys/abi/riscv_v_default_allow

Viết biểu diễn văn bản 0 hoặc 1 vào tệp này sẽ đặt mặc định
    trạng thái kích hoạt hệ thống cho các chương trình không gian người dùng mới bắt đầu. Giá trị hợp lệ
    là:

* 0: Không cho phép mã Vector được thực thi làm mặc định cho các tiến trình mới.
    * 1: Cho phép mã Vector được thực thi làm mặc định cho các tiến trình mới.

Việc đọc tệp này sẽ trả về trạng thái kích hoạt mặc định hiện tại của hệ thống.

Tại mỗi lệnh gọi execve(), trạng thái kích hoạt mới của quy trình mới được đặt thành
    mặc định của hệ thống, trừ khi:

* PR_RISCV_V_VSTATE_CTRL_INHERIT được thiết lập cho quá trình gọi và
        cài đặt trong PR_RISCV_V_VSTATE_CTRL_NEXT_MASK thì không
        PR_RISCV_V_VSTATE_CTRL_DEFAULT. Hoặc,

* Cài đặt trong PR_RISCV_V_VSTATE_CTRL_NEXT_MASK không
        PR_RISCV_V_VSTATE_CTRL_DEFAULT.

Sửa đổi trạng thái kích hoạt mặc định của hệ thống không ảnh hưởng đến kích hoạt
    trạng thái của bất kỳ quy trình luồng hiện có nào không thực hiện lệnh gọi execve().

3. Trạng thái đăng ký vectơ trên các lệnh gọi hệ thống
---------------------------------------------

Như được chỉ ra trong phiên bản 1.0 của phần mở rộng V [1], các thanh ghi vectơ là
bị chặn bởi các cuộc gọi hệ thống.

1: ZZ0000ZZ