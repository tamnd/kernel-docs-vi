.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/arch/arm64/sme.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

========================================================
Hỗ trợ mở rộng ma trận có thể mở rộng cho AArch64 Linux
========================================================

Tài liệu này phác thảo ngắn gọn giao diện được cung cấp cho không gian người dùng bởi Linux trong
để hỗ trợ việc sử dụng Tiện ích mở rộng ma trận có thể mở rộng ARM (SME).

Đây chỉ là bản tóm tắt các tính năng và vấn đề quan trọng nhất chứ không phải
nhằm mục đích đầy đủ.  Nó nên được đọc cùng với SVE
tài liệu trong sve.rst cung cấp thông tin chi tiết về chế độ Truyền phát SVE
có trong SME.

Tài liệu này không nhằm mục đích mô tả kiến trúc SME hoặc lập trình viên
mô hình.  Để hỗ trợ sự hiểu biết, một mô tả tối thiểu về lập trình viên có liên quan
các tính năng mô hình cho SME được bao gồm trong Phụ lục A.


1. Chung
-----------

* PSTATE.SM, PSTATE.ZA, độ dài vectơ chế độ phát trực tuyến, ZA và (khi
  hiện tại) Trạng thái đăng ký ZTn và TPIDR2_EL0 được theo dõi trên mỗi luồng.

* Sự hiện diện của SME được báo cáo tới không gian người dùng thông qua HWCAP2_SME trong vectơ phụ trợ
  Mục nhập AT_HWCAP2.  Sự hiện diện của cờ này ngụ ý sự hiện diện của SME
  hướng dẫn và thanh ghi cũng như các giao diện hệ thống dành riêng cho Linux
  được mô tả trong tài liệu này.  SME được báo cáo trong /proc/cpuinfo là "sme".

* Sự hiện diện của SME2 được báo cáo tới không gian người dùng thông qua HWCAP2_SME2 trong
  Mục nhập aux vector AT_HWCAP2.  Sự hiện diện của lá cờ này ngụ ý sự hiện diện của
  hướng dẫn SME2 và ZT0 cũng như các giao diện hệ thống dành riêng cho Linux
  được mô tả trong tài liệu này.  SME2 được báo cáo trong /proc/cpuinfo là "sme2".

* Cũng có thể hỗ trợ thực hiện các lệnh SME trong không gian người dùng
  được phát hiện bằng cách đọc thanh ghi ID CPU ID_AA64PFR1_EL1 bằng MRS
  lệnh và kiểm tra xem giá trị của trường SME có khác không hay không. [3]

Nó không đảm bảo sự hiện diện của các giao diện hệ thống được mô tả trong
  các phần sau: phần mềm cần xác minh rằng các giao diện đó là
  thay vào đó, người có mặt phải kiểm tra HWCAP2_SME.

* Có một số tính năng SME tùy chọn, sự hiện diện của những tính năng này đã được báo cáo
  thông qua AT_HWCAP2 thông qua:

HWCAP2_SME_I16I64
	HWCAP2_SME_F64F64
	HWCAP2_SME_I8I32
	HWCAP2_SME_F16F32
	HWCAP2_SME_B16F32
	HWCAP2_SME_F32F32
	HWCAP2_SME_FA64
        HWCAP2_SME2

Danh sách này có thể được mở rộng theo thời gian khi kiến ​​trúc SME phát triển.

Các tiện ích mở rộng này cũng được báo cáo thông qua thanh ghi ID CPU ID_AA64SMFR0_EL1,
  không gian người dùng nào có thể đọc bằng lệnh MRS.  Xem elf_hwcaps.txt và
  cpu-feature-registers.txt để biết chi tiết.

* Người gỡ lỗi nên hạn chế tương tác với mục tiêu thông qua
  Các bộ điều chỉnh NT_ARM_SVE, NT_ARM_SSVE, NT_ARM_ZA và NT_ARM_ZT.  Khuyến nghị
  Cách phát hiện sự hỗ trợ cho các regset này là kết nối với một quy trình đích
  đầu tiên và sau đó thử một

ptrace(PTRACE_GETREGSET, pid, NT_ARM_<regset>, &iov).

* Bất cứ khi nào giá trị thanh ghi ZA được trao đổi trong bộ nhớ giữa không gian người dùng và
  kernel, giá trị thanh ghi được mã hóa trong bộ nhớ dưới dạng một chuỗi ngang
  các vectơ từ 0 đến VL/8-1 được lưu trữ ở cùng định dạng bất biến về độ cuối như trước đây
  được sử dụng cho vectơ SVE.

* Khi tạo luồng PSTATE.ZA và TPIDR2_EL0 được giữ nguyên trừ khi CLONE_VM
  được chỉ định, trong trường hợp đó PSTATE.ZA được đặt thành 0 và TPIDR2_EL0 được đặt thành 0.

2. Độ dài vectơ
------------------

SME xác định độ dài vectơ thứ hai tương tự như độ dài vectơ SVE
kiểm soát kích thước của vectơ SVE ở chế độ phát trực tuyến và mảng ma trận ZA.
Ma trận ZA là hình vuông với mỗi cạnh có số byte bằng số luồng
vectơ chế độ SVE.


3. Hành vi gọi hệ thống
-------------------------

* Trên syscall PSTATE.ZA được giữ nguyên, nếu PSTATE.ZA==1 thì nội dung của
  Ma trận ZA và ZTn (nếu có) được giữ nguyên.

* Trên syscall PSTATE.SM sẽ bị xóa và các thanh ghi SVE sẽ được xử lý
  theo tiêu chuẩn SVE ABI.

* Không có thanh ghi SVE, ZA hoặc ZTn nào được sử dụng để truyền đối số cho
  hoặc nhận kết quả từ bất kỳ cuộc gọi hệ thống nào.

* Khi tạo quy trình (ví dụ: clone()), quy trình mới được tạo sẽ có
  PSTATE.SM đã xóa.

* Tất cả trạng thái SME khác của một luồng, bao gồm cả vectơ được cấu hình hiện tại
  độ dài, trạng thái của cờ PR_SME_VL_INHERIT và vectơ trì hoãn
  chiều dài (nếu có), được giữ nguyên trên tất cả các tòa nhà cao tầng, tùy thuộc vào quy định cụ thể
  ngoại lệ cho execve() được mô tả trong phần 6.


4. Xử lý tín hiệu
-------------------

* Trình xử lý tín hiệu được gọi với PSTATE.SM=0, PSTATE.ZA=0 và TPIDR2_EL0=0.

* Một bản ghi khung tín hiệu mới TPIDR2_MAGIC được thêm vào có định dạng dưới dạng cấu trúc
  tpidr2_context để cho phép truy cập TPIDR2_EL0 từ bộ xử lý tín hiệu.

* Bản ghi khung tín hiệu mới za_context mã hóa nội dung thanh ghi ZA trên
  truyền tín hiệu. [1]

* Bản ghi khung tín hiệu cho ZA luôn chứa siêu dữ liệu cơ bản, đặc biệt
  chiều dài vectơ của luồng (trong za_context.vl).

* Ma trận ZA có thể có hoặc không có trong bản ghi, tùy thuộc vào
  giá trị của PSTATE.ZA.  Các thanh ghi tồn tại khi và chỉ khi:
  za_context.head.size >= ZA_SIG_CONTEXT_SIZE(sve_vq_from_vl(za_context.vl))
  trong trường hợp đó PSTATE.ZA == 1.

* Nếu có dữ liệu ma trận, phần còn lại của bản ghi có giá trị phụ thuộc vl
  kích thước và bố cục.  Macro ZA_SIG_* được xác định [1] để tạo điều kiện truy cập vào
  họ.

* Ma trận được lưu trữ dưới dạng một chuỗi các vectơ ngang có cùng định dạng với
  được sử dụng cho vectơ SVE.

* Nếu ngữ cảnh ZA quá lớn để vừa với sigcontext.__reserved[], thì thêm
  không gian được phân bổ trên ngăn xếp, bản ghi extra_context được ghi vào
  __reserved[] tham chiếu không gian này.  za_context sau đó được viết trong
  thêm không gian.  Tham khảo [1] để biết thêm chi tiết về cơ chế này.

* Nếu ZTn được hỗ trợ và PSTATE.ZA==1 thì bản ghi khung tín hiệu cho ZTn sẽ
  được tạo ra.

* Bản ghi tín hiệu cho ZTn có ZT_MAGIC ma thuật (0x5a544e01) và bao gồm một
  tiêu đề khung tín hiệu tiêu chuẩn theo sau là cấu trúc zt_context chỉ định
  số lượng thanh ghi ZTn được hệ thống hỗ trợ, sau đó là zt_context.nregs
  khối 64 byte dữ liệu trên mỗi thanh ghi.


5. Tín hiệu trở lại
-----------------

Khi trở về từ bộ xử lý tín hiệu:

* Nếu không có bản ghi za_context trong khung tín hiệu hoặc nếu bản ghi
  hiện tại nhưng không chứa dữ liệu đăng ký như được mô tả trong phần trước,
  thì ZA bị vô hiệu hóa.

* Nếu za_context có trong khung tín hiệu và chứa dữ liệu ma trận thì
  PSTATE.ZA được đặt thành 1 và ZA được điền dữ liệu đã chỉ định.

* Độ dài vectơ không thể thay đổi thông qua tín hiệu trở lại.  Nếu za_context.vl trong
  khung tín hiệu không khớp với độ dài vectơ hiện tại, tín hiệu sẽ quay trở lại
  nỗ lực được coi là bất hợp pháp, dẫn đến SIGSEGV bị ép buộc.

* Nếu ZTn không được hỗ trợ hoặc PSTATE.ZA==0 thì việc sở hữu một
  bản ghi khung tín hiệu cho ZTn, dẫn đến SIGSEGV bắt buộc.


6. phần mở rộng pctl
--------------------

Một số lệnh gọi prctl() mới được thêm vào để cho phép các chương trình quản lý vectơ SME
chiều dài:

prctl(PR_SME_SET_VL, đối số dài không dấu)

Đặt độ dài vectơ của luồng gọi và các cờ liên quan, trong đó
    đối số == vl | cờ.  Các luồng khác của quá trình gọi không bị ảnh hưởng.

vl là độ dài vectơ mong muốn, trong đó sve_vl_valid(vl) phải đúng.

cờ:

PR_SME_VL_INHERIT

Kế thừa độ dài vectơ hiện tại trên execve().  Nếu không,
	    độ dài vectơ được đặt lại về mặc định của hệ thống tại execve().  (Xem
	    Phần 9.)

PR_SME_SET_VL_ONEXEC

Trì hoãn việc thay đổi độ dài vectơ được yêu cầu cho đến lần execve() tiếp theo
	    được thực hiện bởi chủ đề này.

Hiệu quả tương đương với việc thực hiện ngầm các thao tác sau
	    gọi ngay sau lệnh execve() tiếp theo (nếu có) theo luồng:

prctl(PR_SME_SET_VL, arg & ~PR_SME_SET_VL_ONEXEC)

Điều này cho phép khởi chạy một chương trình mới với một vectơ khác
	    dài, đồng thời tránh các tác dụng phụ trong thời gian chạy ở trình gọi.

Nếu không có PR_SME_SET_VL_ONEXEC, thay đổi được yêu cầu sẽ có hiệu lực
	    ngay lập tức.


Giá trị trả về: không âm nếu thành công hoặc giá trị âm nếu có lỗi:
	EINVAL: SME không được hỗ trợ, yêu cầu độ dài vectơ không hợp lệ hoặc
	    cờ không hợp lệ.


Về thành công:

* Độ dài vectơ của luồng đang gọi hoặc độ dài vectơ trì hoãn
      được áp dụng ở lần execve() tiếp theo theo luồng (phụ thuộc vào việc
      PR_SME_SET_VL_ONEXEC có trong arg), được đặt thành giá trị lớn nhất
      được hỗ trợ bởi hệ thống nhỏ hơn hoặc bằng vl.  Nếu vl ==
      SVE_VL_MAX, giá trị được đặt sẽ là giá trị lớn nhất được hỗ trợ bởi
      hệ thống.

* Bất kỳ thay đổi độ dài véc tơ hoãn lại nào chưa được xử lý trước đây trong lệnh gọi
      chủ đề bị hủy bỏ.

* Giá trị trả về mô tả cấu hình kết quả, được mã hóa như đối với
      PR_SME_GET_VL.  Độ dài vectơ được báo cáo trong giá trị này là độ dài mới
      độ dài vectơ hiện tại cho luồng này nếu không có PR_SME_SET_VL_ONEXEC
      hiện diện trong arg; mặt khác, độ dài vectơ được báo cáo là độ dài bị trì hoãn
      độ dài vectơ sẽ được áp dụng ở lần execve() tiếp theo bằng cách gọi
      chủ đề.

* Thay đổi độ dài vectơ gây ra tất cả ZA, ZTn, P0..P15, FFR và tất cả
      các bit của Z0..Z31 ngoại trừ các bit Z0 [127:0] .. Các bit Z31 [127:0] sẽ trở thành
      không xác định, bao gồm cả trạng thái SVE phát trực tuyến và không phát trực tuyến.
      Gọi PR_SME_SET_VL với vl bằng vectơ hiện tại của luồng
      length hoặc gọi PR_SME_SET_VL bằng cờ PR_SME_SET_VL_ONEXEC,
      không cấu thành sự thay đổi độ dài vectơ cho mục đích này.

* Việc thay đổi độ dài vectơ khiến PSTATE.ZA bị xóa.
      Gọi PR_SME_SET_VL với vl bằng vectơ hiện tại của luồng
      length hoặc gọi PR_SME_SET_VL bằng cờ PR_SME_SET_VL_ONEXEC,
      không cấu thành sự thay đổi độ dài vectơ cho mục đích này.


prctl(PR_SME_GET_VL)

Lấy chiều dài vectơ của luồng đang gọi.

Cờ sau đây có thể được OR-ed vào kết quả:

PR_SME_VL_INHERIT

Độ dài vectơ sẽ được kế thừa qua execve().

Không có cách nào để xác định liệu có khoản nợ hoãn lại chưa thanh toán hay không
    thay đổi độ dài vectơ (thường chỉ xảy ra giữa một
    fork() hoặc vfork() và execve() tương ứng trong cách sử dụng thông thường).

Để trích xuất độ dài vectơ từ kết quả, theo bit và nó với
    PR_SME_VL_LEN_MASK.

Giá trị trả về: giá trị không âm nếu thành công hoặc giá trị âm nếu có lỗi:
	EINVAL: SME không được hỗ trợ.


7. phần mở rộng ptrace
---------------------

* Một regset NT_ARM_SSVE mới được xác định để truy cập vào chế độ phát trực tuyến SVE
  trạng thái thông qua PTRACE_GETREGSET và PTRACE_SETREGSET, điều này được ghi lại trong
  sve.đầu tiên.

* Một regset NT_ARM_ZA mới được xác định cho trạng thái ZA để truy cập vào trạng thái ZA thông qua
  PTRACE_GETREGSET và PTRACE_SETREGSET.

Tham khảo [2] để biết định nghĩa.

Dữ liệu regset bắt đầu bằng struct user_za_header, chứa:

kích cỡ

Kích thước của regset hoàn chỉnh, tính bằng byte.
	Điều này phụ thuộc vào vl và có thể vào những thứ khác trong tương lai.

Nếu cuộc gọi tới PTRACE_GETREGSET yêu cầu ít dữ liệu hơn giá trị của
	kích thước, người gọi có thể phân bổ bộ đệm lớn hơn và thử lại để
	đọc regset hoàn chỉnh.

kích thước tối đa

Kích thước tối đa tính bằng byte mà regset có thể tăng lên cho mục tiêu
	chủ đề.  Regset sẽ không lớn hơn thế này ngay cả khi mục tiêu
	thread thay đổi độ dài vectơ của nó, v.v.

vl

Độ dài vectơ phát trực tuyến hiện tại của luồng mục tiêu, tính bằng byte.

max_vl

Độ dài vectơ phát trực tuyến tối đa có thể có cho luồng đích.

cờ

Không có hoặc nhiều cờ sau đây có cùng
	ý nghĩa và hành vi như các cờ PR_SET_VL_* tương ứng:

SME_PT_VL_INHERIT

SME_PT_VL_ONEXEC (chỉ SETREGSET).

* Tác động của việc thay đổi độ dài vectơ và/hoặc cờ tương đương với
  những tài liệu được ghi lại cho PR_SME_SET_VL.

Người gọi phải thực hiện thêm cuộc gọi GETREGSET nếu cần biết VL là gì
  thực sự được thiết lập bởi SETREGSET, trừ khi được biết trước rằng yêu cầu
  VL được hỗ trợ.

* Kích thước và cách bố trí của tải trọng phụ thuộc vào các trường tiêu đề.  các
  Các macro ZA_PT_ZA*() được cung cấp để hỗ trợ truy cập dữ liệu.

* Trong cả hai trường hợp, đối với SETREGSET, được phép bỏ qua tải trọng, trong đó
  trường hợp độ dài vectơ và cờ được thay đổi và PSTATE.ZA được đặt thành 0
  (cùng với bất kỳ hậu quả nào của những thay đổi đó).  Nếu một tải trọng được cung cấp
  thì PSTATE.ZA sẽ được đặt thành 1.

* Đối với SETREGSET, nếu VL được yêu cầu không được hỗ trợ, hiệu ứng sẽ là
  tương tự như khi tải trọng bị bỏ qua, ngoại trừ lỗi EIO được báo cáo.
  Không có nỗ lực nào được thực hiện để dịch dữ liệu tải trọng sang bố cục chính xác
  cho độ dài vectơ thực sự được thiết lập.  Người gọi có quyền dịch
  bố trí tải trọng cho VL thực tế và thử lại.

* Tác động của việc ghi một phần tải trọng không đầy đủ là không xác định.

* Một regset NT_ARM_ZT mới được xác định để truy cập vào trạng thái ZTn thông qua
  PTRACE_GETREGSET và PTRACE_SETREGSET.

* Bộ điều chỉnh NT_ARM_ZT bao gồm một thanh ghi 512 bit.

* Khi PSTATE.ZA==0 đọc NT_ARM_ZT sẽ báo cáo tất cả các bit của ZTn là 0.

* Ghi vào NT_ARM_ZT sẽ đặt PSTATE.ZA thành 1.

* Nếu bất kỳ dữ liệu đăng ký nào được cung cấp cùng với SME_PT_VL_ONEXEC thì
  dữ liệu đăng ký sẽ được diễn giải với độ dài vectơ hiện tại, không phải
  độ dài vectơ được định cấu hình để sử dụng trên exec.


8. Tiện ích mở rộng lõi của ELF
---------------------------

* Ghi chú NT_ARM_SSVE sẽ được thêm vào mỗi kết xuất lõi cho
  mỗi luồng của quá trình kết xuất.  Nội dung sẽ tương đương với
  dữ liệu sẽ được đọc nếu PTRACE_GETREGSET tương ứng
  type đã được thực thi cho mỗi luồng khi coredump được tạo.

* Một ghi chú NT_ARM_ZA sẽ được thêm vào mỗi coredump cho mỗi luồng của
  quá trình đổ thải.  Nội dung sẽ tương đương với dữ liệu sẽ có
  được đọc nếu PTRACE_GETREGSET của NT_ARM_ZA được thực thi cho mỗi luồng
  khi coredump được tạo ra.

* Một ghi chú NT_ARM_ZT sẽ được thêm vào mỗi coredump cho mỗi luồng của
  quá trình đổ thải.  Nội dung sẽ tương đương với dữ liệu sẽ có
  được đọc nếu PTRACE_GETREGSET của NT_ARM_ZT được thực thi cho mỗi luồng
  khi coredump được tạo ra.

* Ghi chú NT_ARM_TLS sẽ được mở rộng thành hai thanh ghi, thanh ghi thứ hai
  sẽ chứa TPIDR2_EL0 trên các hệ thống hỗ trợ SME và sẽ được đọc là
  bằng 0 với việc ghi bị bỏ qua nếu không.

9. Cấu hình thời gian chạy hệ thống
--------------------------------

* Để giảm thiểu tác động của ABI khi mở rộng khung tín hiệu, một chính sách
  cơ chế được cung cấp cho quản trị viên, người bảo trì và phát triển bản phân phối
  để đặt độ dài vectơ mặc định cho các quy trình không gian người dùng:

/proc/sys/abi/sme_default_vector_length

Viết biểu diễn văn bản của một số nguyên vào tệp này sẽ thiết lập hệ thống
    độ dài vectơ mặc định thành giá trị đã chỉ định được làm tròn thành giá trị được hỗ trợ
    sử dụng các quy tắc tương tự như để thiết lập độ dài vectơ thông qua PR_SME_SET_VL.

Kết quả có thể được xác định bằng cách mở lại tệp và đọc nó
    nội dung.

Khi khởi động, độ dài vectơ mặc định ban đầu được đặt thành 32 hoặc tối đa
    độ dài vectơ được hỗ trợ, tùy theo giá trị nào nhỏ hơn và được hỗ trợ.  Cái này
    xác định độ dài vectơ ban đầu của quá trình init (PID 1).

Việc đọc tệp này sẽ trả về độ dài vectơ mặc định của hệ thống hiện tại.

* Tại mỗi lệnh gọi execve(), độ dài vectơ mới của quy trình mới được đặt thành
  độ dài vectơ mặc định của hệ thống, trừ khi

* PR_SME_VL_INHERIT (hoặc tương đương SME_PT_VL_INHERIT) được đặt cho
      gọi chủ đề, hoặc

* một sự thay đổi độ dài vectơ hoãn lại đang chờ xử lý, được thiết lập thông qua
      Cờ PR_SME_SET_VL_ONEXEC (hoặc SME_PT_VL_ONEXEC).

* Sửa đổi độ dài vectơ mặc định của hệ thống không ảnh hưởng đến độ dài vectơ
  của bất kỳ tiến trình hoặc luồng hiện có nào không thực hiện lệnh gọi execve().


Phụ lục A. Mô hình lập trình viên SME (tham khảo)
=================================================

Phần này cung cấp mô tả tối thiểu về các bổ sung được thực hiện bởi SME cho
Mô hình lập trình viên ARMv8-A có liên quan đến tài liệu này.

Lưu ý: Phần này chỉ mang tính chất cung cấp thông tin và không nhằm mục đích cung cấp đầy đủ hoặc
để thay thế bất kỳ đặc điểm kỹ thuật kiến trúc nào.

A.1.  Đăng ký
---------------

Ở trạng thái A64, SME bổ sung thêm các mục sau:

* Chế độ mới, chế độ phát trực tuyến, trong đó một tập hợp con của FPSIMD và SVE bình thường
  các tính năng có sẵn.  Khi phần mềm EL0 được hỗ trợ có thể vào và ra
  chế độ phát trực tuyến bất cứ lúc nào.

Để có hiệu suất hệ thống tốt nhất, phần mềm được khuyến khích kích hoạt
  chế độ phát trực tuyến chỉ khi nó đang được sử dụng tích cực.

* Độ dài vectơ mới kiểm soát kích thước của thanh ghi ZA và Z khi ở
  chế độ phát trực tuyến, riêng biệt với độ dài vectơ được sử dụng cho SVE khi không ở chế độ
  chế độ phát trực tuyến.  Không có yêu cầu nào về việc hiện được chọn
  chiều dài vectơ hoặc tập hợp độ dài vectơ được hỗ trợ cho hai chế độ trong
  một hệ thống nhất định có bất kỳ mối quan hệ nào.  Độ dài vectơ chế độ phát trực tuyến
  được gọi là SVL.

* Một thanh ghi ma trận ZA mới.  Đây là ma trận vuông gồm các bit SVLxSVL.  Hầu hết
  các hoạt động trên ZA yêu cầu bật chế độ phát trực tuyến nhưng ZA có thể
  được bật mà không có chế độ phát trực tuyến để tải, lưu và giữ lại dữ liệu.

Để có hiệu suất hệ thống tốt nhất, phần mềm được khuyến khích kích hoạt
  ZA chỉ khi nó đang được sử dụng tích cực.

* Một thanh ghi ZT0 mới được giới thiệu khi có SME2. Đây là 512 bit
  register có thể truy cập được khi PSTATE.ZA được đặt, giống như chính ZA.

* Hai trường 1 bit mới trong PSTATE có thể được điều khiển thông qua SMSTART và
  Hướng dẫn SMSTOP hoặc bằng cách truy cập vào thanh ghi hệ thống SVCR:

* PSTATE.ZA, nếu đây là 1 thì ma trận ZA có thể truy cập được và có giá trị
    dữ liệu trong khi nếu bằng 0 thì không thể truy cập ZA.  Khi PSTATE.ZA là
    thay đổi từ 0 thành 1 tất cả các bit trong ZA đều bị xóa.

* PSTATE.SM, nếu đây là 1 thì PE đang ở chế độ phát trực tuyến.  Khi giá trị
    của PSTATE.SM bị thay đổi thì việc triển khai được xác định nếu tập hợp con
    của các bit thanh ghi dấu phẩy động hợp lệ ở cả hai chế độ có thể được giữ lại.
    Bất kỳ bit nào khác sẽ bị xóa.


Tài liệu tham khảo
==========

[1] Arch/arm64/include/uapi/asm/sigcontext.h
    Định nghĩa ABI tín hiệu AArch64 Linux

[2] Arch/arm64/include/uapi/asm/ptrace.h
    Định nghĩa AArch64 Linux ptrace ABI

[3] Tài liệu/arch/arm64/cpu-feature-registers.rst
