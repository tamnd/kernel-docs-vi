.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/arch/arm64/tagged-pointers.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

=============================================
Được gắn thẻ địa chỉ ảo trong AArch64 Linux
=========================================

Tác giả: Will Deacon <will.deacon@arm.com>

Ngày: 12 tháng 6 năm 2013

Tài liệu này mô tả ngắn gọn việc cung cấp dịch vụ ảo được gắn thẻ
địa chỉ trong hệ thống dịch thuật AArch64 và khả năng sử dụng của chúng
trong AArch64 Linux.

Hạt nhân cấu hình các bảng dịch để các bản dịch được thực hiện
thông qua TTBR0 (tức là ánh xạ không gian người dùng) có byte trên cùng (bit 63:56) của
địa chỉ ảo bị phần cứng dịch thuật bỏ qua. Điều này giải phóng
byte này để sử dụng cho ứng dụng.


Truyền địa chỉ được gắn thẻ vào kernel
--------------------------------------

Tất cả việc diễn giải địa chỉ bộ nhớ không gian người dùng của kernel đều giả định
thẻ địa chỉ 0x00, trừ khi ứng dụng kích hoạt AArch64
Được gắn thẻ Địa chỉ ABI một cách rõ ràng
(Tài liệu/arch/arm64/tagged-address-abi.rst).

Điều này bao gồm nhưng không giới hạn ở các địa chỉ được tìm thấy trong:

- đối số con trỏ cho các cuộc gọi hệ thống, bao gồm cả con trỏ trong cấu trúc
   được chuyển tới các cuộc gọi hệ thống,

- con trỏ ngăn xếp (sp), ví dụ: khi diễn giải nó để cung cấp một
   tín hiệu,

- con trỏ khung (x29) và các bản ghi khung, ví dụ: khi phiên dịch
   chúng để tạo ra một đồ thị quay lại hoặc gọi.

Sử dụng thẻ địa chỉ khác 0 ở bất kỳ vị trí nào trong số này khi
ứng dụng không gian người dùng không kích hoạt Địa chỉ được gắn thẻ AArch64 ABI có thể
dẫn đến mã lỗi được trả về, tín hiệu (nghiêm trọng) được nâng lên,
hoặc các dạng hư hỏng khác.

Vì những lý do này, khi Địa chỉ ABI được gắn thẻ AArch64 bị tắt,
chuyển các thẻ địa chỉ khác 0 tới kernel thông qua các cuộc gọi hệ thống là
bị cấm và việc sử dụng thẻ địa chỉ khác 0 cho sp là điều cực kỳ nghiêm trọng.
chán nản.

Các chương trình duy trì con trỏ khung và bản ghi khung sử dụng giá trị khác 0
thẻ địa chỉ có thể bị lỗi hoặc không chính xác khi gỡ lỗi và lập hồ sơ
khả năng hiển thị.


Bảo quản thẻ
---------------

Khi truyền tín hiệu, các thẻ khác 0 không được giữ nguyên trong
siginfo.si_addr trừ khi cờ SA_EXPOSE_TAGBITS được đặt trong
sigaction.sa_flags khi bộ xử lý tín hiệu được cài đặt. Điều này có nghĩa
bộ xử lý tín hiệu trong các ứng dụng sử dụng thẻ không thể dựa vào
trên thông tin thẻ cho địa chỉ ảo của người dùng đang được duy trì
trong các trường này trừ khi cờ được đặt.

Nếu FEAT_MTE_TAGGED_FAR (Armv8.9) được hỗ trợ, bit 63:60 của địa chỉ lỗi
được bảo toàn để phản hồi các lỗi kiểm tra thẻ đồng bộ (SEGV_MTESERR)
nếu không thì không được bảo tồn ngay cả khi SA_EXPOSE_TAGBITS được đặt.
Các ứng dụng sẽ diễn giải giá trị của các bit này dựa trên
sự hỗ trợ cho HWCAP3_MTE_FAR. Nếu không có sự hỗ trợ,
các giá trị của các bit này phải được coi là không xác định nếu không thì hợp lệ.

Đối với các tín hiệu được đưa ra để phản hồi các ngoại lệ gỡ lỗi điểm theo dõi,
thông tin thẻ sẽ được giữ nguyên bất kể SA_EXPOSE_TAGBITS
thiết lập cờ.

Các thẻ khác 0 không bao giờ được giữ nguyên trong sigcontext.fault_address
bất kể cài đặt cờ SA_EXPOSE_TAGBITS.

Kiến trúc ngăn chặn việc sử dụng PC được gắn thẻ, do đó byte trên sẽ
được đặt thành phần mở rộng dấu của bit 55 khi trả về ngoại lệ.

Hành vi này được duy trì khi Địa chỉ ABI được gắn thẻ AArch64 được
đã bật.


Những cân nhắc khác
--------------------

Cần đặc biệt cẩn thận khi sử dụng con trỏ được gắn thẻ, vì nó
có khả năng là trình biên dịch C sẽ không gây nguy hiểm cho hai địa chỉ ảo khác nhau
chỉ ở byte trên.
