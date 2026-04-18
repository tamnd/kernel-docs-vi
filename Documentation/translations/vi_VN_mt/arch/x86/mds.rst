.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/arch/x86/mds.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

Giảm thiểu lấy mẫu dữ liệu vi kiến ​​trúc (MDS)
=================================================

.. _mds:

Tổng quan
--------

Lấy mẫu dữ liệu vi kiến trúc (MDS) là một nhóm các cuộc tấn công kênh bên
trên bộ đệm bên trong trong CPU Intel. Các biến thể là:

- Lấy mẫu dữ liệu bộ đệm cửa hàng vi kiến trúc (MSBDS) (CVE-2018-12126)
 - Lấy mẫu dữ liệu bộ đệm điền vi kiến trúc (MFBDS) (CVE-2018-12130)
 - Lấy mẫu dữ liệu cổng tải vi kiến trúc (MLPDS) (CVE-2018-12127)
 - Lấy mẫu dữ liệu vi kiến trúc Bộ nhớ không thể lưu vào bộ nhớ đệm (MDSUM) (CVE-2019-11091)

MSBDS rò rỉ các mục nhập bộ đệm lưu trữ có thể được chuyển tiếp theo suy đoán tới một
tải phụ thuộc (chuyển tiếp từ cửa hàng sang tải) dưới dạng tối ưu hóa. Tiền đạo
cũng có thể xảy ra do lỗi hoặc hỗ trợ hoạt động tải cho một thiết bị khác
địa chỉ bộ nhớ, có thể bị khai thác trong những điều kiện nhất định. cửa hàng
bộ đệm được phân vùng giữa các Siêu luồng để việc chuyển tiếp luồng chéo được thực hiện
không thể được. Nhưng nếu một luồng đi vào hoặc thoát khỏi trạng thái ngủ thì cửa hàng
bộ đệm được phân vùng lại có thể hiển thị dữ liệu từ luồng này sang luồng khác.

MFBDS rò rỉ các mục điền vào bộ đệm. Bộ đệm điền được sử dụng nội bộ để quản lý
L1 bỏ lỡ các tình huống và giữ dữ liệu được trả về hoặc gửi để phản hồi
vào bộ nhớ hoặc thao tác I/O. Bộ đệm điền có thể chuyển tiếp dữ liệu tới một tải
hoạt động và cũng ghi dữ liệu vào bộ nhớ đệm. Khi bộ đệm điền được
bị hủy phân bổ, nó có thể giữ lại dữ liệu cũ của các hoạt động trước đó
sau đó có thể được chuyển tiếp đến hoạt động tải bị lỗi hoặc hỗ trợ, có thể
được khai thác trong những điều kiện nhất định. Bộ đệm điền được chia sẻ giữa
Siêu luồng nên có thể xảy ra rò rỉ luồng chéo.

MLPDS rò rỉ dữ liệu cổng tải. Cổng tải được sử dụng để thực hiện các hoạt động tải
từ bộ nhớ hoặc I/O. Dữ liệu nhận được sau đó được chuyển tiếp đến thanh ghi
tập tin hoặc một hoạt động tiếp theo. Trong một số triển khai, Cổng tải có thể
chứa dữ liệu cũ từ hoạt động trước đó có thể được chuyển tiếp tới
sự cố hoặc hỗ trợ tải trong các điều kiện nhất định, một lần nữa có thể
cuối cùng bị lợi dụng. Các cổng tải được chia sẻ giữa các Siêu luồng nên
có thể xảy ra rò rỉ ren.

MDSUM là trường hợp đặc biệt của MSBDS, MFBDS và MLPDS. Tải không thể lưu vào bộ nhớ đệm từ
bộ nhớ gặp lỗi hoặc hỗ trợ có thể để lại dữ liệu ở dạng vi kiến trúc
cấu trúc mà sau này có thể được quan sát bằng cách sử dụng một trong những phương pháp tương tự được sử dụng bởi
MSBDS, MFBDS hoặc MLPDS.

Giả định phơi nhiễm
--------------------

Giả định rằng mã tấn công nằm trong không gian người dùng hoặc trong khách có một
ngoại lệ. Cơ sở lý luận đằng sau giả định này là cấu trúc mã
cần thiết để khai thác MDS yêu cầu:

- để kiểm soát tải để kích hoạt lỗi hoặc hỗ trợ

- để có một tiện ích tiết lộ giúp hiển thị thông tin được truy cập theo suy đoán
   dữ liệu để tiêu thụ thông qua một kênh bên.

- để điều khiển con trỏ qua đó tiện ích tiết lộ hiển thị thông tin
   dữ liệu

Sự tồn tại của cấu trúc như vậy trong kernel không thể bị loại trừ bằng
Chắc chắn 100%, nhưng sự phức tạp liên quan khiến điều đó cực kỳ khó xảy ra.

Có một ngoại lệ, đó là BPF không đáng tin cậy. Chức năng của
BPF không đáng tin cậy có hạn chế nhưng cần được điều tra kỹ lưỡng
liệu nó có thể được sử dụng để tạo ra một cấu trúc như vậy hay không.


Chiến lược giảm thiểu
-------------------

Tất cả các biến thể đều có cùng một chiến lược giảm thiểu ít nhất là cho một chiếc CPU
trường hợp luồng (tắt SMT): Buộc CPU xóa bộ đệm bị ảnh hưởng.

Điều này đạt được bằng cách sử dụng VERW chưa được sử dụng và lỗi thời
hướng dẫn kết hợp với cập nhật vi mã. Vi mã xóa
bộ đệm CPU bị ảnh hưởng khi lệnh VERW được thực thi.

Để ảo hóa, có hai cách để đạt được bộ đệm CPU
thanh toán bù trừ. Lệnh VERW đã sửa đổi hoặc thông qua L1D Flush
lệnh. Cái sau được phát hành khi kích hoạt giảm thiểu L1TF để bổ sung
VERW có thể tránh được. Nếu CPU không bị ảnh hưởng bởi L1TF thì VERW cần phải
được ban hành.

Nếu lệnh VERW với đối số bộ chọn phân đoạn được cung cấp là
được thực thi trên CPU mà không cập nhật vi mã, không có tác dụng phụ
ngoại trừ một số lượng nhỏ các chu trình CPU bị lãng phí một cách vô nghĩa.

Điều này không bảo vệ chống lại các cuộc tấn công Hyper-Thread chéo ngoại trừ MSBDS
chỉ có thể khai thác được qua Siêu luồng khi một trong các Siêu luồng
đi vào trạng thái C.

Hạt nhân cung cấp một chức năng để gọi việc xóa bộ đệm:

x86_clear_cpu_buffers()

Ngoài ra, macro CLEAR_CPU_BUFFERS có thể được sử dụng trong ASM muộn trong đường dẫn thoát tới người dùng.
Ngoài CFLAGS.ZF, macro này không ghi đè bất kỳ thanh ghi nào.

Việc giảm nhẹ được thực hiện trên kernel/userspace, hypervisor/guest và C-state
(nhàn rỗi) chuyển tiếp.

Là một cách giải quyết đặc biệt để giải quyết các tình huống ảo hóa trong đó máy chủ có
vi mã đã được cập nhật, nhưng trình ảo hóa không (chưa) hiển thị
MD_CLEAR CPUID bit cho khách, kernel đưa ra lệnh VERW trong
hy vọng rằng nó thực sự có thể xóa bộ đệm. Trạng thái được phản ánh
tương ứng.

Theo kiến thức hiện tại, các biện pháp giảm thiểu bổ sung bên trong kernel
bản thân nó không bắt buộc vì các tiện ích cần thiết để lộ thông tin bị rò rỉ
dữ liệu không thể được kiểm soát theo cách cho phép khai thác từ các phần mềm độc hại
không gian người dùng hoặc khách VM.

Các chế độ giảm thiểu nội bộ hạt nhân
--------------------------------

======= =================================================================
 tắt Giảm thiểu bị vô hiệu hóa. CPU không bị ảnh hưởng hoặc
          mds=off được cung cấp trên dòng lệnh kernel

Giảm thiểu đầy đủ được kích hoạt. CPU bị ảnh hưởng và MD_CLEAR
          được quảng cáo trong CPUID.

Giảm thiểu vmwerv được kích hoạt. CPU bị ảnh hưởng còn MD_CLEAR thì không
	  được quảng cáo trong CPUID. Cái đó chủ yếu dành cho ảo hóa
	  các tình huống trong đó máy chủ có vi mã được cập nhật nhưng
	  trình ảo hóa không hiển thị MD_CLEAR trong CPUID. Đó là điều tốt nhất
	  cách tiếp cận nỗ lực mà không có sự đảm bảo.
 ======= =================================================================

Nếu CPU bị ảnh hưởng và mds=off không được cung cấp trong lệnh kernel
thì kernel sẽ chọn chế độ giảm thiểu thích hợp tùy thuộc vào
sự sẵn có của bit MD_CLEAR CPUID.

Điểm giảm nhẹ
-----------------

1. Quay lại không gian người dùng
^^^^^^^^^^^^^^^^^^^^^^^

Khi chuyển từ kernel sang không gian người dùng, bộ đệm CPU sẽ bị xóa
   trên các CPU bị ảnh hưởng khi tính năng giảm thiểu không bị tắt trên kernel
   dòng lệnh. Việc giảm thiểu được kích hoạt thông qua cờ tính năng
   X86_FEATURE_CLEAR_CPU_BUF.

Việc giảm thiểu được thực hiện ngay trước khi chuyển sang không gian người dùng sau
   đăng ký người dùng được khôi phục. Điều này được thực hiện để thu nhỏ cửa sổ trong
   dữ liệu kernel nào có thể được truy cập sau VERW, ví dụ: thông qua NMI sau
   VERW.

ZZ0000ZZ
   Các ngắt quay trở lại kernel không xóa bộ đệm CPU vì
   đường dẫn thoát tới người dùng dự kiến ​​sẽ làm điều đó. Nhưng, có thể có
   trường hợp NMI được tạo trong kernel sau đường dẫn thoát tới người dùng
   đã xóa bộ đệm. Trường hợp này không được xử lý và NMI quay trở lại
   kernel không xóa bộ đệm CPU vì:

1. Rất hiếm khi nhận được NMI sau VERW nhưng trước khi quay lại không gian người dùng.
   2. Đối với người dùng không có đặc quyền, không có cách nào để tạo ra NMI đó
      ít hiếm hơn hoặc nhắm mục tiêu nó.
   3. Sẽ cần một số lượng lớn NMI được tính thời gian chính xác này để gắn kết
      một cuộc tấn công thực sự.  Có lẽ không đủ băng thông.
   4. NMI được đề cập xảy ra sau VERW, tức là khi trạng thái người dùng là
      được khôi phục và dữ liệu thú vị nhất đã bị xóa. Những gì còn lại
      chỉ là dữ liệu mà NMI chạm vào và dữ liệu đó có thể thuộc hoặc không thuộc về
      bất kỳ sự quan tâm nào.


2. Chuyển trạng thái C
^^^^^^^^^^^^^^^^^^^^^

Khi CPU không hoạt động và chuyển sang Trạng thái C, bộ đệm CPU cần phải được
   bị xóa trên các CPU bị ảnh hưởng khi SMT hoạt động. Điều này giải quyết các
   phân vùng lại bộ đệm lưu trữ khi một trong các Siêu luồng đi vào
   một trạng thái C.

Khi SMT không hoạt động, tức là CPU không hỗ trợ nó hoặc tất cả
   Các luồng anh chị em đang ngoại tuyến Không cần phải xóa bộ đệm CPU.

Tính năng xóa không hoạt động được bật trên các CPU chỉ bị ảnh hưởng bởi MSBDS
   chứ không phải bởi bất kỳ biến thể MDS nào khác. Các biến thể MDS khác không thể
   được bảo vệ chống lại các cuộc tấn công Siêu luồng chéo vì Bộ đệm điền và
   các cổng tải được chia sẻ. Vì vậy, trên các CPU bị ảnh hưởng bởi các biến thể khác,
   việc dọn dẹp nhàn rỗi sẽ là một bài tập trang trí cửa sổ và do đó không
   được kích hoạt.

Lệnh gọi được điều khiển bởi khóa tĩnh cpu_buf_idle_clear.
   được chuyển đổi tùy thuộc vào chế độ giảm thiểu đã chọn và trạng thái SMT của
   hệ thống.

Việc xóa bộ đệm chỉ được thực hiện trước khi vào Trạng thái C để ngăn chặn
   dữ liệu cũ từ CPU đang chạy không tải tràn sang Hyper-Thread
   anh chị em sau khi bộ đệm cửa hàng được phân vùng lại và tất cả các mục được
   có sẵn cho anh chị em không nhàn rỗi.

Khi thoát khỏi trạng thái rảnh, bộ đệm lưu trữ được phân vùng lại để mỗi
   anh chị em có sẵn một nửa số đó. Sự trở lại từ CPU nhàn rỗi có thể là sau đó
   suy đoán tiếp xúc với nội dung của anh chị em. Các bộ đệm là
   bị xóa khi thoát vào không gian người dùng hoặc trên VMENTER nên mã độc
   trong không gian người dùng hoặc khách không thể truy cập chúng theo suy đoán.

Việc giảm nhẹ được nối vào tất cả các biến thể của lệnh dừng()/mwait(), nhưng không
   không bao gồm cơ chế IO-Port ACPI kế thừa vì trình điều khiển nhàn rỗi ACPI
   đã được thay thế bởi trình điều khiển intel_idle vào khoảng năm 2010 và được
   được ưu tiên trên tất cả các CPU bị ảnh hưởng dự kiến sẽ đạt được MD_CLEAR
   chức năng trong microcode. Ngoài ra, cơ chế IO-Port là một
   giao diện kế thừa chỉ được sử dụng trên các hệ thống cũ hơn
   không bị ảnh hưởng hoặc không nhận được cập nhật vi mã nữa.
