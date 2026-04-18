.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/arch/riscv/zicfilp.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

:Tác giả: Deepak Gupta <debug@rivosinc.com>
:Ngày: 12 tháng 1 năm 2024

===========================================================
Theo dõi chuyển giao điều khiển gián tiếp trên RISC-V Linux
===========================================================

Tài liệu này mô tả ngắn gọn giao diện do Linux cung cấp cho không gian người dùng
để bật theo dõi nhánh gián tiếp cho các ứng dụng ở chế độ người dùng trên RISC-V.

1. Tổng quan về tính năng
--------------------

Các vấn đề hỏng bộ nhớ thường dẫn đến sự cố.  Tuy nhiên, trong
bàn tay của một kẻ thù sáng tạo, những điều này có thể dẫn đến nhiều loại
vấn đề an ninh.

Một số vấn đề bảo mật có thể là các cuộc tấn công sử dụng lại mã, trong đó một
Đối thủ có thể sử dụng các con trỏ hàm bị hỏng, xâu chuỗi chúng lại với nhau để
thực hiện lập trình hướng nhảy (JOP) hoặc lập trình hướng cuộc gọi
(COP) và do đó làm tổn hại đến tính toàn vẹn của luồng điều khiển (CFI) của chương trình.

Con trỏ hàm sống trong bộ nhớ đọc-ghi và do đó dễ bị tấn công
đến tham nhũng.  Điều này có thể cho phép kẻ thù kiểm soát chương trình
giá trị bộ đếm (PC).  Trên RISC-V, tiện ích mở rộng zicfilp thực thi một
hạn chế đối với việc chuyển giao quyền kiểm soát gián tiếp như vậy:

- Việc truyền điều khiển gián tiếp phải đáp xuống bãi đáp hướng dẫn ZZ0000ZZ.
  Có hai trường hợp ngoại lệ cho quy tắc này:

- rs1 = x1 hoặc rs1 = x5, tức là kết quả trả về từ một hàm và kết quả trả về là
    được bảo vệ bằng ngăn xếp bóng (xem zicfiss.rst)

-rs1=x7. Trên RISC-V, trình biên dịch thường thực hiện các thao tác sau để đạt được
    chức năng vượt quá độ lệch của lệnh loại J có thể có::

auipc x7, <imm>
      jalr (x7)

Hình thức chuyển giao quyền kiểm soát gián tiếp này là bất biến và không
    dựa vào trí nhớ.  Do đó rs1=x7 được miễn theo dõi và
    đây được coi là bước nhảy được bảo vệ bằng phần mềm.

Lệnh ZZ0000ZZ là một lệnh giả của ZZ0001ZZ
với ZZ0002ZZ.  Đây là một sản phẩm HINT.  Lệnh ZZ0003ZZ phải được
căn chỉnh trên ranh giới 4 byte.  Nó so sánh 20 bit ngay lập tức với
x7. Nếu ZZ0004ZZ == 0 thì CPU không thực hiện bất kỳ so sánh nào với
ZZ0005ZZ. Nếu ZZ0006ZZ != 0 thì ZZ0007ZZ phải khớp với ZZ0008ZZ
nếu không CPU sẽ huy động ZZ0009ZZ (ZZ0010ZZ) với
ZZ0011ZZ.

Trình biên dịch có thể tạo ra một hàm băm trên các chữ ký hàm và thiết lập chúng
lên (cắt ngắn còn 20 bit) trong x7 tại các điểm gọi.  Lời mở đầu chức năng có thể
có các lệnh ZZ0000ZZ được mã hóa với hàm băm tương tự. Cái này
tiếp tục giảm số lượng địa chỉ bộ đếm chương trình hợp lệ cho một cuộc gọi
trang web có thể tiếp cận.

2. ELF và psABI
-----------------

Chuỗi công cụ thiết lập ZZ0000ZZ cho
thuộc tính ZZ0001ZZ trong ghi chú
phần của tập tin đối tượng.

3. Kích hoạt Linux
------------------

Các chương trình không gian người dùng có thể có nhiều đối tượng dùng chung được tải trong
các không gian địa chỉ.  Đó là một nhiệm vụ khó khăn để đảm bảo tất cả
các phần phụ thuộc đã được biên soạn với sự hỗ trợ gián tiếp của chi nhánh. Như vậy
việc này được giao cho trình tải động kích hoạt theo dõi nhánh gián tiếp cho
chương trình.

4. bật prctl()
--------------------

Trạng thái theo dõi nhánh gián tiếp trên mỗi nhiệm vụ có thể được theo dõi và
được điều khiển thông qua ZZ0000ZZ và ZZ0001ZZ
Các đối số `ZZ0003ZZ (tương ứng), bằng cách cung cấp
ZZ0002ZZ làm đối số thứ hai.  Những cái này
là bất khả tri về kiến trúc và sẽ trả về -EINVAL nếu cơ sở
chức năng không được hỗ trợ.

* prctl(ZZ0000ZZ, ZZ0001ZZ, đối số dài không dấu)

arg là một mặt nạ bit.

Nếu ZZ0000ZZ được đặt trong arg và CPU hỗ trợ
ZZ0001ZZ, thì kernel sẽ cho phép theo dõi nhánh gián tiếp cho
nhiệm vụ.  Trình tải động có thể phát hành ZZ0002ZZ này sau khi nó có
xác định rằng tất cả các đối tượng được tải trong không gian địa chỉ đều hỗ trợ
theo dõi chi nhánh gián tiếp.

Trạng thái theo dõi nhánh gián tiếp cũng có thể bị khóa sau khi được bật.  Cái này
ngăn tác vụ vô hiệu hóa nó sau đó.  Việc này được thực hiện bởi
thiết lập bit ZZ0000ZZ trong arg.  Hoặc nhánh gián tiếp
tính năng theo dõi phải được bật cho tác vụ hoặc bit
ZZ0001ZZ cũng phải được đặt trong arg.  Điều này được dự định
dành cho những môi trường muốn chạy với chế độ bảo mật nghiêm ngặt
không muốn tải các đối tượng mà không có sự hỗ trợ của ZZ0002ZZ.

Theo dõi chi nhánh gián tiếp cũng có thể bị vô hiệu hóa cho nhiệm vụ, giả sử
rằng nó chưa được kích hoạt và khóa trước đó.  Nếu có một
ZZ0001ZZ sang một đối tượng không được biên dịch bằng ZZ0002ZZ,
trình tải động có thể phát hành ZZ0003ZZ này với arg được đặt thành
ZZ0000ZZ.  Vô hiệu hóa theo dõi chi nhánh gián tiếp cho
nhiệm vụ không thể thực hiện được nếu nó đã được kích hoạt và khóa trước đó.


* prctl(ZZ0000ZZ, ZZ0001ZZ, dài không dấu * arg)

Trả về trạng thái hiện tại của việc theo dõi nhánh gián tiếp vào mặt nạ bit
được lưu trữ vào vị trí bộ nhớ được chỉ ra bởi arg.  Mặt nạ bit sẽ
đặt bit ZZ0000ZZ nếu theo dõi nhánh gián tiếp
hiện được kích hoạt cho tác vụ và nếu nó bị khóa, sẽ
Ngoài ra còn có bộ bit ZZ0001ZZ.  Nếu gián tiếp
theo dõi chi nhánh hiện bị vô hiệu hóa cho nhiệm vụ,
Bit ZZ0002ZZ sẽ được thiết lập.


5. vi phạm liên quan đến theo dõi chi nhánh gián tiếp
--------------------------------------------------

Liên quan đến theo dõi chi nhánh gián tiếp, CPU đưa ra một phần mềm
kiểm tra ngoại lệ trong các điều kiện sau:

- thiếu ZZ0000ZZ sau cuộc gọi gián tiếp/jmp
- ZZ0001ZZ không nằm trên ranh giới 4 byte
- ZZ0002ZZ được nhúng trong lệnh ZZ0003ZZ không khớp với ZZ0004ZZ

Trong cả 3 trường hợp, ZZ0000ZZ đều bị bắt và ngoại lệ kiểm tra phần mềm là
nâng lên (ZZ0001ZZ).

Hạt nhân sẽ coi đây là ZZ0000ZZ với mã =
ZZ0001ZZ và tuân theo quy trình truyền tín hiệu thông thường.