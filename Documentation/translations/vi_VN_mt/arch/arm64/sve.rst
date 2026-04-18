.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/arch/arm64/sve.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

========================================================
Hỗ trợ tiện ích mở rộng Vector có thể mở rộng cho AArch64 Linux
===================================================

Tác giả: Dave Martin <Dave.Martin@arm.com>

Ngày: 4 tháng 8 năm 2017

Tài liệu này phác thảo ngắn gọn giao diện được cung cấp cho không gian người dùng bởi Linux trong
để hỗ trợ việc sử dụng Phần mở rộng vectơ có thể mở rộng ARM (SVE), bao gồm
tương tác với chế độ Truyền phát SVE được thêm bởi Tiện ích mở rộng ma trận có thể mở rộng
(SME).

Đây chỉ là bản tóm tắt các tính năng và vấn đề quan trọng nhất chứ không phải
nhằm mục đích đầy đủ.

Tài liệu này không nhằm mục đích mô tả kiến trúc SVE hoặc lập trình viên
mô hình.  Để hỗ trợ sự hiểu biết, một mô tả tối thiểu về lập trình viên có liên quan
các tính năng mô hình cho SVE được bao gồm trong Phụ lục A.


1. Chung
-----------

* SVE đăng ký Z0..Z31, P0..P15 và FFR và chiều dài vectơ hiện tại VL, là
  được theo dõi trên mỗi luồng.

* Ở chế độ phát trực tuyến, FFR không thể truy cập được trừ khi có HWCAP2_SME_FA64
  trong hệ thống, khi nó không được hỗ trợ và các giao diện này được sử dụng để
  truy cập chế độ phát trực tuyến FFR được đọc và ghi bằng 0.

* Sự hiện diện của SVE được báo cáo tới không gian người dùng thông qua HWCAP_SVE trong vectơ phụ trợ
  Mục nhập AT_HWCAP.  Sự hiện diện của cờ này ngụ ý sự hiện diện của SVE
  hướng dẫn và thanh ghi cũng như các giao diện hệ thống dành riêng cho Linux
  được mô tả trong tài liệu này.  SVE được báo cáo trong /proc/cpuinfo là "sve".

* Cũng có thể hỗ trợ thực hiện các lệnh SVE trong không gian người dùng
  được phát hiện bằng cách đọc thanh ghi ID CPU ID_AA64PFR0_EL1 bằng MRS
  lệnh và kiểm tra xem giá trị của trường SVE có khác không hay không. [3]

Nó không đảm bảo sự hiện diện của các giao diện hệ thống được mô tả trong
  các phần sau: phần mềm cần xác minh rằng các giao diện đó là
  thay vào đó, người có mặt phải kiểm tra HWCAP_SVE.

* Trên phần cứng hỗ trợ phần mở rộng SVE2, HWCAP2_SVE2 cũng sẽ
  được báo cáo trong mục nhập vectơ phụ trợ AT_HWCAP2.  Thêm vào đó,
  các phần mở rộng tùy chọn cho SVE2 có thể được báo cáo bởi sự hiện diện của:

HWCAP2_SVE2
	HWCAP2_SVEAES
	HWCAP2_SVEPMULL
	HWCAP2_SVEBITPERM
	HWCAP2_SVESHA3
	HWCAP2_SVESM4
	HWCAP2_SVE2P1

Danh sách này có thể được mở rộng theo thời gian khi kiến ​​trúc SVE phát triển.

Các tiện ích mở rộng này cũng được báo cáo thông qua thanh ghi ID CPU ID_AA64ZFR0_EL1,
  không gian người dùng nào có thể đọc bằng lệnh MRS.  Xem elf_hwcaps.txt và
  cpu-feature-registers.txt để biết chi tiết.

* Trên phần cứng hỗ trợ phần mở rộng SME, HWCAP2_SME cũng sẽ
  được báo cáo trong mục vectơ phụ trợ AT_HWCAP2.  Trong số những thứ khác SME bổ sung
  chế độ phát trực tuyến cung cấp một tập hợp con của bộ tính năng SVE bằng cách sử dụng
  chiều dài vectơ SME riêng biệt và các thanh ghi Z/V giống nhau.  Xem sme.rst
  để biết thêm chi tiết.

* Người gỡ lỗi nên hạn chế tương tác với mục tiêu thông qua
  Đặt lại NT_ARM_SVE.  Cách được đề xuất để phát hiện hỗ trợ cho regset này
  là kết nối với một quy trình đích trước tiên và sau đó thử
  ptrace(PTRACE_GETREGSET, pid, NT_ARM_SVE, &iov).  Lưu ý rằng khi SME
  hiện tại và phát trực tuyến chế độ SVE đang được sử dụng tập hợp con các thanh ghi FPSIMD
  sẽ được đọc qua NT_ARM_SVE và ghi NT_ARM_SVE sẽ thoát khỏi chế độ phát trực tuyến
  trong mục tiêu.

* Bất cứ khi nào các giá trị thanh ghi có thể mở rộng SVE (Zn, Pn, FFR) được trao đổi trong bộ nhớ
  giữa không gian người dùng và kernel, giá trị thanh ghi được mã hóa trong bộ nhớ theo dạng
  bố cục bất biến về cuối, với các bit [(8 * i + 7) : (8 * i)] được mã hóa tại
  byte offset i từ đầu biểu diễn bộ nhớ.  Điều này ảnh hưởng đến
  ví dụ khung tín hiệu (struct sve_context) và giao diện ptrace
  (struct user_sve_header) và dữ liệu liên quan.

Xin lưu ý rằng trên các hệ thống lớn, điều này dẫn đến thứ tự byte khác với
  đối với các thanh ghi V FPSIMD, được lưu trữ dưới dạng 128-bit cuối máy chủ duy nhất
  các giá trị, với các bit [(127 - 8 * i) : (120 - 8 * i)] của thanh ghi được mã hóa tại
  độ lệch byte thứ i.  (cấu trúc fpsimd_context, cấu trúc user_fpsimd_state).


2. Thuật ngữ độ dài vectơ
-----------------------------

Kích thước của thanh ghi vectơ SVE (Z) được gọi là "độ dài vectơ".

Để tránh nhầm lẫn về đơn vị dùng để biểu diễn độ dài vectơ, kernel
thông qua các quy ước sau:

* Độ dài vectơ (VL) = kích thước của thanh ghi Z tính bằng byte

* Vector tứ giác (VQ) = kích thước của thanh ghi Z tính theo đơn vị 128 bit

(Vì vậy, VL = 16 * VQ.)

Quy ước VQ được sử dụng khi mức độ chi tiết cơ bản là quan trọng, chẳng hạn như
như trong định nghĩa cấu trúc dữ liệu.  Trong hầu hết các tình huống khác, quy ước VL
được sử dụng.  Điều này phù hợp với ý nghĩa của thanh ghi giả "VL" trong
kiến trúc tập lệnh SVE.


3. Hành vi gọi hệ thống
-------------------------

* Trên syscall, V0..V31 được giữ nguyên (như không có SVE).  Do đó, bit [127:0] của
  Z0..Z31 được giữ nguyên.  Tất cả các bit khác của Z0..Z31 và tất cả các bit của P0..P15 và FFR
  trở thành số 0 khi trở về từ một cuộc gọi hệ thống.

* Các thanh ghi SVE không được sử dụng để truyền đối số hoặc nhận kết quả từ
  bất kỳ cuộc gọi chung nào.

* Tất cả trạng thái SVE khác của một luồng, bao gồm cả vectơ được cấu hình hiện tại
  độ dài, trạng thái của cờ PR_SVE_VL_INHERIT và vectơ trì hoãn
  chiều dài (nếu có), được giữ nguyên trên tất cả các tòa nhà cao tầng, tùy thuộc vào quy định cụ thể
  ngoại lệ cho execve() được mô tả trong phần 6.

Cụ thể, khi trở về từ một fork() hoặc clone(), cha mẹ và con mới
  tiến trình hoặc luồng chia sẻ cấu hình SVE giống hệt nhau, khớp với cấu hình của
  cha mẹ trước cuộc gọi.


4. Xử lý tín hiệu
-------------------

* Bản ghi khung tín hiệu mới sve_context mã hóa các thanh ghi SVE trên tín hiệu
  giao hàng. [1]

* Bản ghi này bổ sung cho fpsimd_context.  Các thanh ghi FPSR và FPCR
  chỉ hiện diện trong fpsimd_context.  Để thuận tiện, nội dung của V0..V31
  được nhân đôi giữa sve_context và fpsimd_context.

* Bản ghi chứa trường cờ bao gồm cờ SVE_SIG_FLAG_SM
  nếu được đặt cho biết luồng đang ở chế độ phát trực tuyến và độ dài vectơ
  và đăng ký dữ liệu (nếu có) mô tả vectơ và dữ liệu SVE truyền trực tuyến
  chiều dài.

* Bản ghi khung tín hiệu cho SVE luôn chứa siêu dữ liệu cơ bản, đặc biệt
  chiều dài vectơ của luồng (trong sve_context.vl).

* Các thanh ghi SVE có thể được đưa vào bản ghi hoặc không, tùy thuộc vào
  liệu các thanh ghi có hoạt động cho luồng hay không.  Các thanh ghi có mặt nếu
  và chỉ khi:
  sve_context.head.size >= SVE_SIG_CONTEXT_SIZE(sve_vq_from_vl(sve_context.vl)).

* Nếu có các thanh ghi, phần còn lại của bản ghi có giá trị phụ thuộc vl
  kích thước và bố cục.  Macro SVE_SIG_* được xác định [1] để tạo điều kiện truy cập vào
  các thành viên.

* Mỗi thanh ghi có thể mở rộng (Zn, Pn, FFR) được lưu trữ dưới dạng bất biến endianness
  bố cục, với các bit [(8 * i + 7) : (8 * i)] được lưu trữ ở byte offset i từ
  bắt đầu biểu diễn của thanh ghi trong bộ nhớ.

* Nếu ngữ cảnh SVE quá lớn để vừa với sigcontext.__reserved[], thì thêm
  không gian được phân bổ trên ngăn xếp, bản ghi extra_context được ghi vào
  __reserved[] tham chiếu không gian này.  sve_context sau đó được viết trong
  thêm không gian.  Tham khảo [1] để biết thêm chi tiết về cơ chế này.


5. Tín hiệu trở lại
-----------------

Khi trở về từ bộ xử lý tín hiệu:

* Nếu không có bản ghi sve_context trong khung tín hiệu hoặc nếu bản ghi
  hiện tại nhưng không chứa dữ liệu đăng ký như được mô tả trong phần trước,
  khi đó các thanh ghi/bit SVE sẽ không hoạt động và nhận các giá trị không xác định.

* Nếu sve_context có trong khung tín hiệu và chứa thanh ghi đầy đủ
  dữ liệu, các thanh ghi SVE sẽ hoạt động và được điền với các thông số được chỉ định
  dữ liệu.  Tuy nhiên, vì lý do tương thích ngược, các bit [127:0] của Z0..Z31
  luôn được khôi phục từ các thành viên tương ứng của fpsimd_context.vregs[]
  chứ không phải từ sve_context.  Các bit còn lại được khôi phục từ sve_context.

* Việc đưa fpsimd_context vào khung tín hiệu vẫn là bắt buộc,
  bất kể sve_context có hiện diện hay không.

* Độ dài vectơ không thể thay đổi thông qua tín hiệu trở lại.  Nếu sve_context.vl trong
  khung tín hiệu không khớp với độ dài vectơ hiện tại, tín hiệu sẽ quay trở lại
  nỗ lực được coi là bất hợp pháp, dẫn đến SIGSEGV bị ép buộc.

* Được phép vào hoặc rời khỏi chế độ phát trực tuyến bằng cách cài đặt hoặc xóa
  cờ SVE_SIG_FLAG_SM nhưng các ứng dụng cần cẩn thận để đảm bảo rằng
  khi làm như vậy sve_context.vl và mọi dữ liệu đăng ký đều phù hợp với
  chiều dài vectơ trong chế độ mới.


6. phần mở rộng pctl
--------------------

Một số lệnh gọi prctl() mới được thêm vào để cho phép các chương trình quản lý vectơ SVE
chiều dài:

prctl(PR_SVE_SET_VL, đối số dài không dấu)

Đặt độ dài vectơ của luồng gọi và các cờ liên quan, trong đó
    đối số == vl | cờ.  Các luồng khác của quá trình gọi không bị ảnh hưởng.

vl là độ dài vectơ mong muốn, trong đó sve_vl_valid(vl) phải đúng.

cờ:

PR_SVE_VL_INHERIT

Kế thừa độ dài vectơ hiện tại trên execve().  Nếu không,
	    độ dài vectơ được đặt lại về mặc định của hệ thống tại execve().  (Xem
	    Phần 9.)

PR_SVE_SET_VL_ONEXEC

Trì hoãn việc thay đổi độ dài vectơ được yêu cầu cho đến lần execve() tiếp theo
	    được thực hiện bởi chủ đề này.

Hiệu quả tương đương với việc thực hiện ngầm các thao tác sau
	    gọi ngay sau lệnh execve() tiếp theo (nếu có) theo luồng:

prctl(PR_SVE_SET_VL, arg & ~PR_SVE_SET_VL_ONEXEC)

Điều này cho phép khởi chạy một chương trình mới với một vectơ khác
	    dài, đồng thời tránh các tác dụng phụ trong thời gian chạy ở trình gọi.


Nếu không có PR_SVE_SET_VL_ONEXEC, thay đổi được yêu cầu sẽ có hiệu lực
	    ngay lập tức.


Giá trị trả về: không âm nếu thành công hoặc giá trị âm nếu có lỗi:
	EINVAL: SVE không được hỗ trợ, yêu cầu độ dài vectơ không hợp lệ hoặc
	    cờ không hợp lệ.


Về thành công:

* Độ dài vectơ của luồng đang gọi hoặc độ dài vectơ trì hoãn
      được áp dụng ở lần execve() tiếp theo theo luồng (phụ thuộc vào việc
      PR_SVE_SET_VL_ONEXEC có trong arg), được đặt thành giá trị lớn nhất
      được hỗ trợ bởi hệ thống nhỏ hơn hoặc bằng vl.  Nếu vl ==
      SVE_VL_MAX, giá trị được đặt sẽ là giá trị lớn nhất được hỗ trợ bởi
      hệ thống.

* Bất kỳ thay đổi độ dài véc tơ hoãn lại nào chưa được xử lý trước đây trong lệnh gọi
      chủ đề bị hủy bỏ.

* Giá trị trả về mô tả cấu hình kết quả, được mã hóa như đối với
      PR_SVE_GET_VL.  Độ dài vectơ được báo cáo trong giá trị này là độ dài mới
      độ dài vectơ hiện tại cho luồng này nếu không có PR_SVE_SET_VL_ONEXEC
      hiện diện trong arg; mặt khác, độ dài vectơ được báo cáo là độ dài bị trì hoãn
      độ dài vectơ sẽ được áp dụng ở lần execve() tiếp theo bằng cách gọi
      chủ đề.

* Thay đổi độ dài vectơ gây ra tất cả P0..P15, FFR và tất cả các bit của
      Z0..Z31 ngoại trừ các bit Z0 [127:0] .. Các bit Z31 [127:0] sẽ trở thành
      không xác định.  Gọi PR_SVE_SET_VL với vl bằng hiện tại của luồng
      chiều dài vectơ hoặc gọi PR_SVE_SET_VL bằng PR_SVE_SET_VL_ONEXEC
      cờ, không cấu thành sự thay đổi độ dài vectơ cho mục đích này.


prctl(PR_SVE_GET_VL)

Lấy chiều dài vectơ của luồng đang gọi.

Cờ sau đây có thể được OR-ed vào kết quả:

PR_SVE_VL_INHERIT

Độ dài vectơ sẽ được kế thừa qua execve().

Không có cách nào để xác định liệu có khoản nợ hoãn lại chưa thanh toán hay không
    thay đổi độ dài vectơ (thường chỉ xảy ra giữa một
    fork() hoặc vfork() và execve() tương ứng trong cách sử dụng thông thường).

Để trích xuất độ dài vectơ từ kết quả, theo bit và nó với
    PR_SVE_VL_LEN_MASK.

Giá trị trả về: giá trị không âm nếu thành công hoặc giá trị âm nếu có lỗi:
	EINVAL: SVE không được hỗ trợ.


7. phần mở rộng ptrace
---------------------

* Các regset mới NT_ARM_SVE và NT_ARM_SSVE được xác định để sử dụng với
  PTRACE_GETREGSET và PTRACE_SETREGSET. NT_ARM_SSVE mô tả
  chế độ phát trực tuyến SVE đăng ký và NT_ARM_SVE mô tả
  thanh ghi SVE ở chế độ không phát trực tuyến.

Trong mô tả này, một bộ thanh ghi được gọi là "trực tiếp" khi
  mục tiêu đang ở chế độ phát trực tuyến hoặc không phát trực tuyến thích hợp và
  sử dụng dữ liệu ngoài tập hợp con được chia sẻ với các thanh ghi FPSIMD Vn.

Tham khảo [2] để biết định nghĩa.

Dữ liệu regset bắt đầu bằng struct user_sve_header, chứa:

kích cỡ

Kích thước của regset hoàn chỉnh, tính bằng byte.
	Điều này phụ thuộc vào vl và có thể vào những thứ khác trong tương lai.

Nếu cuộc gọi đến PTRACE_GETREGSET yêu cầu ít dữ liệu hơn giá trị của
	kích thước, người gọi có thể phân bổ bộ đệm lớn hơn và thử lại để
	đọc regset hoàn chỉnh.

kích thước tối đa

Kích thước tối đa tính bằng byte mà regset có thể tăng lên cho mục tiêu
	chủ đề.  Regset sẽ không lớn hơn thế này ngay cả khi mục tiêu
	thread thay đổi độ dài vectơ của nó, v.v.

vl

Độ dài vectơ hiện tại của luồng mục tiêu, tính bằng byte.

max_vl

Độ dài vectơ tối đa có thể có của luồng đích.

cờ

nhiều nhất là một trong

SVE_PT_REGS_FPSIMD

Các thanh ghi SVE không hoạt động (GETREGSET) hoặc sẽ được tạo
		không tồn tại (SETREGSET).

Tải trọng có kiểu cấu trúc user_fpsimd_state, có cùng
		nghĩa như đối với NT_PRFPREG, bắt đầu từ offset
		SVE_PT_FPSIMD_OFFSET từ đầu user_sve_header.

Dữ liệu bổ sung có thể được thêm vào trong tương lai: kích thước của
		tải trọng phải được lấy bằng SVE_PT_FPSIMD_SIZE(vq, flags).

vq phải được lấy bằng cách sử dụng sve_vq_from_vl(vl).

hoặc

SVE_PT_REGS_SVE

Các thanh ghi SVE đang hoạt động (GETREGSET) hoặc sẽ được thực hiện trực tiếp
		(SETREGSET).

Tải trọng chứa dữ liệu thanh ghi SVE, bắt đầu từ offset
		SVE_PT_SVE_OFFSET từ đầu user_sve_header và với
		kích thước SVE_PT_SVE_SIZE(vq, cờ);

	... OR-ed with zero or more of the following flags, which have the same
ý nghĩa và hành vi như các cờ PR_SET_VL_* tương ứng:

SVE_PT_VL_INHERIT

SVE_PT_VL_ONEXEC (chỉ SETREGSET).

Nếu cả cờ FPSIMD và SVE đều không được cung cấp thì không có đăng ký
	tải trọng có sẵn, điều này chỉ có thể thực hiện được khi SME được triển khai.


* Tác động của việc thay đổi độ dài vectơ và/hoặc cờ tương đương với
  những tài liệu được ghi lại cho PR_SVE_SET_VL.

Người gọi phải thực hiện thêm cuộc gọi GETREGSET nếu cần biết VL là gì
  thực sự được thiết lập bởi SETREGSET, trừ khi được biết trước rằng yêu cầu
  VL được hỗ trợ.

* Trong trường hợp SVE_PT_REGS_SVE, kích thước và cách bố trí của tải trọng phụ thuộc vào
  các trường tiêu đề.  Các macro SVE_PT_SVE_*() được cung cấp để hỗ trợ
  tiếp cận các thành viên.

* Trong cả hai trường hợp, đối với SETREGSET, được phép bỏ qua tải trọng, trong đó
  trường hợp chỉ có độ dài vectơ và cờ được thay đổi (cùng với bất kỳ
  hậu quả của những thay đổi đó).

* Trong các hệ thống hỗ trợ SME khi ở chế độ phát trực tuyến, GETREGSET dành cho
  NT_REG_SVE sẽ chỉ trả về user_sve_header không có dữ liệu đăng ký,
  tương tự, GETREGSET cho NT_REG_SSVE sẽ không trả về bất kỳ dữ liệu đăng ký nào
  khi không ở chế độ phát trực tuyến.

* GETREGSET cho NT_ARM_SSVE sẽ không bao giờ trả lại SVE_PT_REGS_FPSIMD.

* Đối với SETREGSET, nếu có tải trọng SVE_PT_REGS_SVE và
  VL được yêu cầu không được hỗ trợ, hiệu ứng sẽ giống như khi
  tải trọng đã bị bỏ qua, ngoại trừ lỗi EIO được báo cáo.  Không
  nỗ lực được thực hiện để dịch dữ liệu tải trọng sang bố cục chính xác
  cho độ dài vectơ thực sự được thiết lập.  Trạng thái FPSIMD của luồng là
  được giữ nguyên, nhưng các bit còn lại của thanh ghi SVE sẽ trở thành
  không xác định.  Người gọi có thể dịch bố cục tải trọng
  cho VL thực tế và thử lại.

* Khi SME được triển khai thì GETREGSET không thể đăng ký
  trạng thái cho SVE bình thường khi ở chế độ phát trực tuyến cũng như chế độ phát trực tuyến
  trạng thái đăng ký khi ở chế độ bình thường, bất kể việc triển khai được xác định
  hoạt động của phần cứng để chia sẻ dữ liệu giữa hai chế độ.

* Bất kỳ SETREGSET nào của NT_ARM_SVE sẽ thoát khỏi chế độ phát trực tuyến nếu mục tiêu ở trong
  chế độ phát trực tuyến và mọi SETREGSET của NT_ARM_SSVE sẽ chuyển sang chế độ phát trực tuyến
  nếu mục tiêu không ở chế độ phát trực tuyến.

* Trên các hệ thống không hỗ trợ SVE, được phép sử dụng SETREGSET để
  ghi dữ liệu có định dạng SVE_PT_REGS_FPSIMD qua NT_ARM_SVE, trong trường hợp này là
  độ dài vectơ phải được chỉ định là 0. Điều này cho phép chế độ phát trực tuyến được
  bị vô hiệu hóa trên các hệ thống có SME chứ không phải SVE.

* Nếu bất kỳ dữ liệu đăng ký nào được cung cấp cùng với SVE_PT_VL_ONEXEC thì
  dữ liệu đăng ký sẽ được diễn giải với độ dài vectơ hiện tại, không phải
  độ dài vectơ được định cấu hình để sử dụng trên exec.

* Tác động của việc ghi một phần tải trọng không đầy đủ là không xác định.


8. Tiện ích mở rộng lõi của ELF
---------------------------

* Ghi chú NT_ARM_SVE và NT_ARM_SSVE sẽ được thêm vào mỗi kết xuất lõi cho
  mỗi luồng của quá trình kết xuất.  Nội dung sẽ tương đương với
  dữ liệu sẽ được đọc nếu PTRACE_GETREGSET tương ứng
  type đã được thực thi cho mỗi luồng khi coredump được tạo.

9. Cấu hình thời gian chạy hệ thống
--------------------------------

* Để giảm thiểu tác động của ABI khi mở rộng khung tín hiệu, một chính sách
  cơ chế được cung cấp cho quản trị viên, người bảo trì và phát triển bản phân phối
  để đặt độ dài vectơ mặc định cho các quy trình không gian người dùng:

/proc/sys/abi/sve_default_vector_length

Viết biểu diễn văn bản của một số nguyên vào tệp này sẽ thiết lập hệ thống
    độ dài vectơ mặc định thành giá trị đã chỉ định được làm tròn thành giá trị được hỗ trợ
    sử dụng các quy tắc tương tự như để thiết lập độ dài vectơ thông qua PR_SVE_SET_VL.

Kết quả có thể được xác định bằng cách mở lại tệp và đọc nó
    nội dung.

Khi khởi động, độ dài vectơ mặc định ban đầu được đặt thành 64 hoặc tối đa
    độ dài vectơ được hỗ trợ, tùy theo giá trị nào nhỏ hơn.  Điều này quyết định ban đầu
    chiều dài vectơ của quá trình init (PID 1).

Việc đọc tệp này sẽ trả về độ dài vectơ mặc định của hệ thống hiện tại.

* Tại mỗi lệnh gọi execve(), độ dài vectơ mới của quy trình mới được đặt thành
  độ dài vectơ mặc định của hệ thống, trừ khi

* PR_SVE_VL_INHERIT (hoặc tương đương SVE_PT_VL_INHERIT) được đặt cho
      gọi chủ đề, hoặc

* một sự thay đổi độ dài vectơ hoãn lại đang chờ xử lý, được thiết lập thông qua
      Cờ PR_SVE_SET_VL_ONEXEC (hoặc SVE_PT_VL_ONEXEC).

* Sửa đổi độ dài vectơ mặc định của hệ thống không ảnh hưởng đến độ dài vectơ
  của bất kỳ tiến trình hoặc luồng hiện có nào không thực hiện lệnh gọi execve().

10. Tiện ích mở rộng hoàn hảo
--------------------------------

* Tiêu chuẩn DWARF dành riêng cho arm64 [5] đã thêm thanh ghi VG (Vector Granule)
  ở chỉ số 46. Thanh ghi này được sử dụng để giải nén DWARF khi độ dài thay đổi
  Các thanh ghi SVE được đẩy vào ngăn xếp.

* Giá trị của nó tương đương với độ dài vectơ SVE (VL) hiện tại tính bằng bit được chia
  bằng 64.

* Giá trị được bao gồm trong các mẫu Perf trong trường regs[46] nếu
  PERF_SAMPLE_REGS_USER được đặt và mặt nạ sample_regs_user có bit 46 được đặt.

* Giá trị này là giá trị hiện tại tại thời điểm lấy mẫu và nó có thể
  thay đổi theo thời gian.

* Nếu hệ thống không hỗ trợ SVE khi perf_event_open được gọi với những thứ này
  cài đặt, sự kiện sẽ không mở được.

Phụ lục A. Mô hình lập trình viên SVE (tham khảo)
=================================================

Phần này cung cấp mô tả tối thiểu về các bổ sung được thực hiện bởi SVE cho
Mô hình lập trình viên ARMv8-A có liên quan đến tài liệu này.

Lưu ý: Phần này chỉ mang tính chất cung cấp thông tin và không nhằm mục đích cung cấp đầy đủ hoặc
để thay thế bất kỳ đặc điểm kỹ thuật kiến trúc nào.

A.1.  Đăng ký
---------------

Ở trạng thái A64, SVE bổ sung thêm các mục sau:

* 32 thanh ghi vector 8VL-bit Z0..Z31
  Đối với mỗi bit Zn, Zn [127:0] bí danh vectơ ARMv8-A đăng ký Vn.

Một thanh ghi ghi sử dụng tên thanh ghi Vn sẽ đánh số 0 tất cả các bit tương ứng
  Zn ngoại trừ bit [127:0].

* 16 thanh ghi vị ngữ VL-bit P0..P15

* 1 thanh ghi vị từ có mục đích đặc biệt VL-bit FFR ("thanh ghi lỗi đầu tiên")

* một "thanh ghi giả" VL xác định kích thước của mỗi thanh ghi vectơ

Kiến trúc tập lệnh SVE không cung cấp cách nào để ghi VL trực tiếp.
  Thay vào đó, nó chỉ có thể được sửa đổi bởi EL1 trở lên bằng cách viết thích hợp
  các thanh ghi hệ thống.

* Giá trị của VL có thể được cấu hình trong thời gian chạy bởi EL1 trở lên:
  16 <= VL <= VLmax, trong đó VL phải là bội số của 16.

* Độ dài vectơ tối đa được xác định bởi phần cứng:
  16 <= VLmax <= 256.

(Kiến trúc SVE chỉ định 256, nhưng cho phép kiến trúc trong tương lai
  sửa đổi để nâng cao giới hạn này.)

* FPSR và FPCR được giữ lại từ ARMv8-A và tương tác với dấu phẩy động SVE
  hoạt động theo cách tương tự như cách chúng tương tác với ARMv8
  các phép toán dấu phẩy động::

Chỉ số 8VL-1 128 0 bit
        +---- //// -----------------+
     Z0 ZZ0000ZZ
      : :
     Z7 ZZ0001ZZ
     Z8 ZZ0002ZZ
      : : :
    Z15 ZZ0003ZZ
    Z16 ZZ0004ZZ
      : :
    Z31 ZZ0005ZZ
        +---- //// -----------------+
                                                 31 0
         VL-1 0 +-------+
        +---- //// ---+ FPSR ZZ0006ZZ
     P0 ZZ0007ZZ +-------+
      : ZZ0008ZZ *FPCR ZZ0009ZZ
    P15 ZZ0010ZZ +-------+
        +---- //// --+
    FFR ZZ0011ZZ +------+
        +---- //// ---+ VL ZZ0012ZZ
                                                +------+

(*) callee-save:
    Điều này chỉ áp dụng cho các bit [63:0] của thanh ghi Z-/V.
    FPCR chứa các bit lưu cuộc gọi và lưu cuộc gọi.  Xem [4] để biết chi tiết.


A.2.  Tiêu chuẩn gọi thủ tục
-----------------------------

Tiêu chuẩn gọi thủ tục cơ bản ARMv8-A được mở rộng như sau đối với
trạng thái đăng ký SVE bổ sung:

* Tất cả các bit thanh ghi SVE không được chia sẻ với FP/SIMD đều được lưu vào người gọi.

* Các bit Z8 [63:0] .. Các bit Z15 [63:0] là các bit lưu callee.

Điều này diễn ra từ cách các bit này được ánh xạ tới V8..V15, là người gọi-
  lưu trong tiêu chuẩn cuộc gọi thủ tục cơ sở.


Phụ lục B. Model lập trình viên ARMv8-A FP/SIMD
===============================================

Lưu ý: Phần này chỉ mang tính chất cung cấp thông tin và không nhằm mục đích cung cấp đầy đủ hoặc
để thay thế bất kỳ đặc điểm kỹ thuật kiến trúc nào.

Tham khảo [4] để biết thêm thông tin.

ARMv8-A xác định trạng thái thanh ghi dấu phẩy động/SIMD sau:

* 32 thanh ghi vectơ 128 bit V0..V31
* 2 thanh ghi trạng thái/điều khiển 32-bit FPSR, FPCR

::

Chỉ số 127 0 bit
        +--------------+
     V0 ZZ0000ZZ
      : : :
     V7 ZZ0001ZZ
   * V8 ZZ0002ZZ
   : : : :
   *V15 ZZ0003ZZ
    V16 ZZ0004ZZ
      : : :
    V31 ZZ0005ZZ
        +--------------+

31 0
                +-------+
           FPSR ZZ0000ZZ
                +-------+
          *FPCR ZZ0001ZZ
                +-------+

(*) callee-save:
    Điều này chỉ áp dụng cho các bit [63:0] của thanh ghi V.
    FPCR chứa hỗn hợp các bit lưu cuộc gọi và lưu cuộc gọi.


Tài liệu tham khảo
==========

[1] Arch/arm64/include/uapi/asm/sigcontext.h
    Định nghĩa ABI tín hiệu AArch64 Linux

[2] Arch/arm64/include/uapi/asm/ptrace.h
    Định nghĩa AArch64 Linux ptrace ABI

[3] Tài liệu/arch/arm64/cpu-feature-registers.rst

[4] ARM IHI0055C
    ZZ0000ZZ
    ZZ0001ZZ
    Tiêu chuẩn cuộc gọi thủ tục cho Kiến trúc 64-bit ARM (AArch64)

[5] ZZ0000ZZ
