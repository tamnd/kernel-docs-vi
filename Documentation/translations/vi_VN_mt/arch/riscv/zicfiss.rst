.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/arch/riscv/zicfiss.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

:Tác giả: Deepak Gupta <debug@rivosinc.com>
:Ngày: 12 tháng 1 năm 2024

==============================================================
Ngăn xếp bóng để bảo vệ chức năng trả về trên RISC-V Linux
=========================================================

Tài liệu này mô tả ngắn gọn giao diện do Linux cung cấp cho không gian người dùng
để bật ngăn xếp bóng cho các ứng dụng chế độ người dùng trên RISC-V.

1. Tổng quan về tính năng
--------------------

Các vấn đề hỏng bộ nhớ thường dẫn đến sự cố.  Tuy nhiên, trong
dưới bàn tay của một kẻ thù sáng tạo, những vấn đề này có thể dẫn đến nhiều hậu quả khác nhau.
vấn đề an ninh.

Một số vấn đề bảo mật đó có thể là các cuộc tấn công sử dụng lại mã vào các chương trình
nơi kẻ thù có thể sử dụng các địa chỉ trả lại bị hỏng có trên
ngăn xếp. xâu chuỗi chúng lại với nhau để thực hiện lập trình hướng trở lại
(ROP) và do đó ảnh hưởng đến tính toàn vẹn của luồng điều khiển (CFI) của
chương trình.

Địa chỉ trả về nằm trên ngăn xếp trong bộ nhớ đọc-ghi.  Vì thế
họ dễ bị tham nhũng, điều này cho phép kẻ thù
điều khiển bộ đếm chương trình. Trên RISC-V, tiện ích mở rộng ZZ0000ZZ
cung cấp một ngăn xếp thay thế ("ngăn xếp bóng") để trả về
địa chỉ có thể được đặt một cách an toàn trong phần mở đầu của hàm và
lấy lại trong phần kết.  Tiện ích mở rộng ZZ0001ZZ giúp
những thay đổi sau:

- Mã hóa PTE cho bộ nhớ ảo ngăn xếp bóng
  Mã hóa dành riêng trước đó trong bản dịch giai đoạn đầu tiên, tức là.
  PTE.R=0, PTE.W=1, PTE.X=0 trở thành mã hóa PTE cho các trang ngăn xếp bóng.

- Lệnh ZZ0000ZZ đẩy (lưu trữ) ZZ0001ZZ vào ngăn xếp bóng.

- Lệnh ZZ0000ZZ bật (tải) từ ngăn xếp bóng và so sánh
  với ZZ0001ZZ và nếu không bằng, CPU sẽ tăng ZZ0002ZZ
  với ZZ0003ZZ

Chuỗi công cụ trình biên dịch đảm bảo rằng phần mở đầu hàm có ZZ0000ZZ để lưu địa chỉ trả về trên ngăn xếp bóng bên cạnh địa chỉ
ngăn xếp thông thường.  Tương tự, phần kết của hàm có ZZ0001ZZ theo sau là ZZ0002ZZ để đảm bảo rằng giá trị được bật lên
từ ngăn xếp thông thường khớp với giá trị được bật ra từ bóng
ngăn xếp.

2. Bảo vệ ngăn xếp bóng và trình quản lý bộ nhớ linux
-----------------------------------------------------

Như đã đề cập trước đó, ngăn xếp bóng nhận được mã hóa bảng trang mới
có một số thuộc tính đặc biệt được gán cho chúng, cùng với hướng dẫn
hoạt động trên ngăn xếp bóng:

- Các cửa hàng thường xuyên để ngăn xếp bộ nhớ làm tăng lỗi truy cập cửa hàng. Cái này
  bảo vệ bộ nhớ ngăn xếp bóng khỏi việc ghi đi lạc.

- Cho phép tải thường xuyên từ bộ nhớ ngăn xếp bóng. Điều này cho phép
  tiện ích theo dõi ngăn xếp hoặc chức năng quay lui để đọc lệnh gọi thực sự
  xếp chồng lên nhau và đảm bảo rằng nó không bị giả mạo.

- Chỉ các hướng dẫn ngăn xếp bóng mới có thể tạo tải ngăn xếp bóng hoặc
  cửa hàng ngăn xếp bóng tối.

- Shadow stack tải và lưu trữ trên bộ nhớ chỉ đọc tăng AMO/store
  lỗi trang. Do đó cả ZZ0000ZZ và ZZ0001ZZ sẽ
  nêu lỗi AMO/trang cửa hàng. Điều này đơn giản hóa việc xử lý COW trong kernel
  trong khi rẽ nhánh(). Hạt nhân có thể chuyển đổi các trang ngăn xếp bóng thành
  bộ nhớ chỉ đọc (giống như bộ nhớ đọc-ghi thông thường).  Như
  ngay sau các lệnh ZZ0002ZZ hoặc ZZ0003ZZ tiếp theo trong
  gặp phải không gian người dùng, kernel có thể thực hiện COW.

- Shadow stack tải và lưu trữ khi đọc-ghi hoặc đọc-ghi-thực thi
  bộ nhớ gây ra lỗi truy cập. Đây là một tình trạng nguy hiểm vì
  các tải và cửa hàng ngăn xếp bóng không bao giờ được phép hoạt động trên
  bộ nhớ đọc-ghi hoặc đọc-ghi-thực thi.

3. ELF và psABI
-----------------

Chuỗi công cụ thiết lập ZZ0000ZZ cho
thuộc tính ZZ0001ZZ trong ghi chú
phần của tập tin đối tượng.

4. Kích hoạt Linux
------------------

Các chương trình không gian người dùng có thể có nhiều đối tượng dùng chung được tải trong
không gian địa chỉ.  Đó là một nhiệm vụ khó khăn để đảm bảo tất cả
các phần phụ thuộc đã được biên dịch với sự hỗ trợ của ngăn xếp bóng.  Như vậy
việc đó được giao cho trình tải động kích hoạt ngăn xếp bóng cho
chương trình.

5. bật prctl()
--------------------

ZZ0000ZZ / ZZ0001ZZ /
ZZ0002ZZ là ba công cụ được thêm vào để quản lý bóng
ngăn xếp cho phép thực hiện các nhiệm vụ.  Những vấn đề này là bất khả tri về kiến trúc và trả về
-EINVAL nếu không được triển khai.

* prctl(PR_SET_SHADOW_STACK_STATUS, đối số dài không dấu)

Nếu arg = ZZ0000ZZ và nếu CPU hỗ trợ
ZZ0004ZZ thì kernel sẽ kích hoạt ngăn xếp bóng cho tác vụ.
Trình tải động có thể phát hành ZZ0001ZZ này sau khi nó có
xác định rằng tất cả các đối tượng được tải trong không gian địa chỉ đều có hỗ trợ
cho ngăn xếp bóng.  Ngoài ra, nếu có ZZ0002ZZ để
một đối tượng không được biên dịch bằng ZZ0005ZZ, trình tải động
có thể đưa ra prctl này với arg được đặt thành 0 (tức là
ZZ0003ZZ rõ ràng)

* prctl(PR_GET_SHADOW_STACK_STATUS, dài không dấu * arg)

Trả về trạng thái hiện tại của việc theo dõi chi nhánh gián tiếp. Nếu được bật
nó sẽ trả về ZZ0000ZZ.

* prctl(PR_LOCK_SHADOW_STACK_STATUS, đối số dài không dấu)

Khóa trạng thái hiện tại của ngăn xếp bóng đang bật trên
nhiệm vụ. Không gian người dùng có thể muốn chạy với chế độ bảo mật nghiêm ngặt và
sẽ không muốn tải các đối tượng mà không có sự hỗ trợ của ZZ0000ZZ.  Trong này
trường hợp không gian người dùng có thể sử dụng prctl này để không cho phép tắt bóng
ngăn xếp trên nhiệm vụ hiện tại.

5. vi phạm liên quan đến trả lại khi bật ngăn xếp bóng
-----------------------------------------------------------

Liên quan đến ngăn xếp bóng, CPU tăng ZZ0000ZZ khi thực hiện ZZ0001ZZ nếu ZZ0002ZZ không
khớp với đỉnh của ngăn xếp bóng.  Nếu xảy ra sự không khớp thì CPU
đặt ZZ0003ZZ và đưa ra ngoại lệ.

Nhân Linux sẽ coi đây là ZZ0000ZZ với mã =
ZZ0001ZZ và tuân theo quy trình truyền tín hiệu thông thường.

6. Mã thông báo ngăn xếp bóng
-----------------------

Không được phép lưu trữ thông thường trên ngăn xếp bóng tối và do đó không thể
bị giả mạo thông qua việc viết đi lạc tùy ý.  Tuy nhiên, một phương pháp
xoay vòng/chuyển sang ngăn xếp bóng chỉ đơn giản là ghi vào CSR
ZZ0000ZZ.  Điều này sẽ thay đổi ngăn xếp bóng hoạt động cho
chương trình.  Việc ghi vào ZZ0001ZZ trong chương trình chủ yếu là
giới hạn ở các chuyển đổi ngữ cảnh, thư giãn ngăn xếp hoặc longjmp hoặc tương tự
các cơ chế (như chuyển ngữ cảnh của Chủ đề Xanh) trong các ngôn ngữ như
Đi và Rust. Việc ghi CSR_SSP có thể gặp vấn đề vì kẻ tấn công có thể
sử dụng các lỗi hỏng bộ nhớ và tận dụng thói quen chuyển ngữ cảnh để
xoay vòng đến bất kỳ ngăn xếp bóng nào. Mã thông báo ngăn xếp bóng có thể giúp giảm thiểu điều này
vấn đề bằng cách đảm bảo rằng:

- Khi phần mềm chuyển khỏi ngăn xếp bóng, bóng
  con trỏ ngăn xếp nên được lưu trên chính ngăn xếp bóng (đây là
  được gọi là ZZ0000ZZ).

- Khi phần mềm chuyển sang ngăn xếp bóng, nó sẽ đọc
  ZZ0000ZZ từ con trỏ ngăn xếp bóng và xác minh rằng
  bản thân ZZ0001ZZ là một con trỏ tới ngăn xếp bóng
  chính nó.

- Khi quá trình xác minh mã thông báo hoàn tất, phần mềm có thể thực hiện việc ghi
  sang ZZ0000ZZ để chuyển đổi ngăn xếp bóng.

Ở đây "phần mềm" có thể đề cập đến chính thời gian chạy tác vụ ở chế độ người dùng,
quản lý các bối cảnh khác nhau như một phần của một luồng duy nhất.  Hay "phần mềm"
có thể đề cập đến kernel, khi kernel phải gửi tín hiệu tới
một tác vụ của người dùng và phải lưu con trỏ ngăn xếp bóng.  Hạt nhân có thể
tự thực hiện quy trình tương tự bằng cách lưu mã thông báo ở chế độ người dùng
ngăn xếp bóng của nhiệm vụ.  Bằng cách này, bất cứ khi nào ZZ0000ZZ xảy ra,
hạt nhân có thể đọc và xác minh mã thông báo rồi chuyển sang bóng
ngăn xếp. Sử dụng cơ chế này, kernel giúp người dùng thực hiện nhiệm vụ sao cho
bất kỳ vấn đề tham nhũng nào trong tác vụ của người dùng đều không bị kẻ thù khai thác
tùy ý sử dụng ZZ0001ZZ. Đối thủ sẽ phải thực hiện
chắc chắn rằng có một ZZ0003ZZ hợp lệ ngoài
gọi ZZ0002ZZ.

7. Ngăn xếp bóng tín hiệu
-----------------------
Cấu trúc sau đã được thêm vào sigcontext cho RISC-V::

cấu trúc __sc_riscv_cfi_state {
        ss_ptr dài không dấu;
    };

Là một phần của quá trình phân phối tín hiệu, mã thông báo ngăn xếp bóng được lưu trên
ngăn xếp bóng hiện tại của chính nó.  Con trỏ cập nhật được lưu vào
Trường ZZ0000ZZ trong ZZ0001ZZ bên dưới
ZZ0002ZZ. Phân bổ ngăn xếp bóng hiện có được sử dụng
để truyền tín hiệu.  Trong ZZ0003ZZ, kernel sẽ nhận được
ZZ0004ZZ từ ZZ0005ZZ, hãy xác minh dữ liệu đã lưu
mã thông báo trên ngăn xếp bóng và chuyển đổi ngăn xếp bóng.