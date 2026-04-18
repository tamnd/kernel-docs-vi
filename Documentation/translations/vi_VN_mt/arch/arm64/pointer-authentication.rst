.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/arch/arm64/pointer-authentication.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

==========================================
Xác thực con trỏ trong AArch64 Linux
==========================================

Tác giả: Mark Rutland <mark.rutland@arm.com>

Ngày: 2017-07-19

Tài liệu này mô tả ngắn gọn việc cung cấp xác thực con trỏ
chức năng trong AArch64 Linux.


Tổng quan về kiến ​​trúc
---------------------

Tiện ích mở rộng Xác thực con trỏ ARMv8.3 bổ sung thêm các nguyên hàm có thể
được sử dụng để giảm thiểu một số loại tấn công nhất định mà kẻ tấn công có thể làm hỏng
nội dung của một số bộ nhớ (ví dụ: ngăn xếp).

Tiện ích mở rộng sử dụng Mã xác thực con trỏ (PAC) để xác định
liệu con trỏ có bị sửa đổi bất ngờ hay không. PAC có nguồn gốc từ
một con trỏ, một giá trị khác (chẳng hạn như con trỏ ngăn xếp) và một khóa bí mật
được giữ trong các thanh ghi hệ thống.

Tiện ích mở rộng thêm hướng dẫn để chèn PAC hợp lệ vào một con trỏ,
và để xác minh/xóa PAC khỏi con trỏ. PAC chiếm một số
các bit bậc cao của con trỏ, thay đổi tùy thuộc vào
kích thước địa chỉ ảo được định cấu hình và liệu việc gắn thẻ con trỏ có được sử dụng hay không.

Một tập hợp con của các lệnh này đã được phân bổ từ HINT
không gian mã hóa. Trong trường hợp không có tiện ích mở rộng (hoặc khi bị tắt),
các hướng dẫn này hoạt động như NOP. Các ứng dụng và thư viện sử dụng
các hướng dẫn này hoạt động chính xác bất kể sự hiện diện của
phần mở rộng.

Tiện ích mở rộng cung cấp năm khóa riêng biệt để tạo PAC - hai khóa dành cho
địa chỉ lệnh (APIAKey, APIBKey), hai địa chỉ cho địa chỉ dữ liệu
(APDAKey, APDBKey) và một để xác thực chung (APGAKey).


Hỗ trợ cơ bản
-------------

Khi CONFIG_ARM64_PTR_AUTH được chọn và hỗ trợ CTNH có liên quan được
hiện tại, kernel sẽ gán các giá trị khóa ngẫu nhiên cho mỗi tiến trình tại
thời gian thực thi*(). Các khóa được chia sẻ bởi tất cả các luồng trong tiến trình và
được bảo toàn trên fork().

Sự hiện diện của chức năng xác thực địa chỉ được quảng cáo thông qua
HWCAP_PACA và chức năng xác thực chung thông qua HWCAP_PACG.

Số bit mà PAC chiếm trong một con trỏ là 55 trừ đi
kích thước địa chỉ ảo được cấu hình bởi kernel. Ví dụ, với một
kích thước địa chỉ ảo là 48, PAC rộng 7 bit.

Khi ARM64_PTR_AUTH_KERNEL được chọn, kernel sẽ được biên dịch
với hướng dẫn xác thực con trỏ khoảng trắng HINT bảo vệ
hàm trả về. Hạt nhân được xây dựng với tùy chọn này sẽ hoạt động trên phần cứng
có hoặc không có hỗ trợ xác thực con trỏ.

Ngoài exec(), các khóa cũng có thể được khởi tạo lại thành các giá trị ngẫu nhiên
sử dụng công nghệ PR_PAC_RESET_KEYS. Một mặt nạ bit của PR_PAC_APIAKEY,
PR_PAC_APIBKEY, PR_PAC_APDAKEY, PR_PAC_APDBKEY và PR_PAC_APGAKEY
chỉ định những khóa nào sẽ được khởi tạo lại; chỉ định 0 có nghĩa là "tất cả
chìa khóa".


Gỡ lỗi
---------

Khi CONFIG_ARM64_PTR_AUTH được chọn và hỗ trợ CTNH cho địa chỉ
xác thực hiện diện, kernel sẽ hiển thị vị trí của TTBR0
Các bit PAC trong regset NT_ARM_PAC_MASK (struct user_pac_mask),
không gian người dùng có thể có được thông qua PTRACE_GETREGSET.

Regset chỉ được hiển thị khi HWCAP_PACA được đặt. Mặt nạ riêng biệt được
được hiển thị cho các con trỏ dữ liệu và con trỏ lệnh, dưới dạng tập hợp PAC
bit có thể khác nhau giữa hai. Lưu ý rằng mặt nạ áp dụng cho TTBR0
địa chỉ và không hợp lệ để áp dụng cho các địa chỉ TTBR1 (ví dụ: kernel
con trỏ).

Ngoài ra, khi CONFIG_CHECKPOINT_RESTORE cũng được thiết lập, kernel
sẽ hiển thị các regset NT_ARM_PACA_KEYS và NT_ARM_PACG_KEYS (struct
user_pac_address_keys và cấu trúc user_pac_generic_keys). Đây có thể là
được sử dụng để lấy và đặt các khóa cho một luồng.


Ảo hóa
--------------

Xác thực con trỏ được bật trong máy khách KVM khi mỗi CPU ảo được
được khởi tạo bằng cách chuyển cờ KVM_ARM_VCPU_PTRAUTH_[ADDRESS/GENERIC] và
yêu cầu kích hoạt hai tính năng CPU riêng biệt này. KVM hiện tại
Việc triển khai khách hoạt động bằng cách kích hoạt cả hai tính năng cùng nhau, vì vậy cả hai
các cờ không gian người dùng này được kiểm tra trước khi bật xác thực con trỏ.
Cờ không gian người dùng riêng biệt sẽ cho phép không có thay đổi không gian người dùng ABI
nếu hỗ trợ được thêm vào trong tương lai để cho phép hai tính năng này được
được kích hoạt độc lập với nhau.

Vì Kiến trúc Arm chỉ định rằng tính năng Xác thực con trỏ là
được triển khai cùng với tính năng VHE nên mã ptrauth KVM arm64 dựa vào
ở chế độ VHE.

Ngoài ra, khi các cờ tính năng vcpu này không được đặt thì KVM sẽ
lọc ra các thanh ghi khóa hệ thống Xác thực con trỏ từ
KVM_GET/SET_REG_* ioctls và che dấu các tính năng đó khỏi ID cpufeature
đăng ký. Mọi nỗ lực sử dụng hướng dẫn Xác thực con trỏ sẽ
dẫn đến ngoại lệ UNDEFINED được đưa vào máy khách.


Kích hoạt và vô hiệu hóa các phím
---------------------------

Prctl PR_PAC_SET_ENABLED_KEYS cho phép chương trình người dùng kiểm soát những gì
Phím PAC được kích hoạt trong một tác vụ cụ thể. Phải mất hai đối số,
đầu tiên là bitmask của PR_PAC_APIAKEY, PR_PAC_APIBKEY, PR_PAC_APDAKEY
và PR_PAC_APDBKEY chỉ định phím nào sẽ bị ảnh hưởng bởi quy trình này,
và thứ hai là một mặt nạ bit có cùng bit xác định xem khóa có
nên được kích hoạt hoặc vô hiệu hóa. Ví dụ::

prctl(PR_PAC_SET_ENABLED_KEYS,
        PR_PAC_APIAKEY ZZ0000ZZ PR_PAC_APDAKEY | PR_PAC_APDBKEY,
        PR_PAC_APIBKEY, 0, 0);

vô hiệu hóa tất cả các phím ngoại trừ phím IB.

Lý do chính tại sao điều này hữu ích là để kích hoạt không gian người dùng ABI sử dụng PAC
hướng dẫn ký và xác thực con trỏ hàm và các con trỏ khác
được hiển thị bên ngoài hàm, trong khi vẫn cho phép các tệp nhị phân tuân theo
ABI để tương tác với các tệp nhị phân kế thừa không ký hoặc xác thực
con trỏ.

Ý tưởng là một trình tải động hoặc mã khởi động sớm sẽ phát hành điều này
prctl từ rất sớm sau khi thiết lập rằng một quy trình có thể tải các tệp nhị phân kế thừa,
nhưng trước khi thực hiện bất kỳ lệnh PAC nào.

Để tương thích với các phiên bản kernel trước, các tiến trình khởi động bằng IA,
IB, DA và DB được bật và được đặt lại về trạng thái này trên exec(). Các quy trình được tạo
thông qua fork() và clone() kế thừa trạng thái kích hoạt khóa từ quá trình gọi.

Nên tránh tắt khóa IA vì phím này có hiệu suất cao hơn
hơn là vô hiệu hóa bất kỳ phím nào khác.
