.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/arch/x86/x86_64/5level-paging.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

================
phân trang 5 cấp
==============

Tổng quan
========
X86-64 ban đầu bị giới hạn bởi phân trang 4 cấp ở 256 TiB địa chỉ ảo
không gian và 64 TiB không gian địa chỉ vật lý. Chúng tôi đã va vào rồi
giới hạn này: hiện nay một số nhà cung cấp cung cấp máy chủ có bộ nhớ 64 TiB.

Để khắc phục hạn chế phần cứng sắp tới sẽ giới thiệu hỗ trợ cho
Phân trang 5 cấp độ. Đây là phần mở rộng đơn giản của trang hiện tại
cấu trúc bảng thêm một lớp dịch nữa.

Nó vượt quá giới hạn 128 PiB của không gian địa chỉ ảo và 4 PiB của
không gian địa chỉ vật lý. Điều này "có lẽ là đủ cho bất cứ ai" ©.

QEMU 2.9 trở lên hỗ trợ phân trang 5 cấp độ.

Bố cục bộ nhớ ảo cho phân trang 5 cấp được mô tả trong
Tài liệu/arch/x86/x86_64/mm.rst

Không gian người dùng và không gian địa chỉ ảo lớn
==========================================
Trên x86, phân trang 5 cấp cho phép không gian địa chỉ ảo của không gian người dùng 56 bit.
Không phải tất cả không gian người dùng đều sẵn sàng để xử lý các địa chỉ rộng. Người ta biết rằng
ít nhất một số trình biên dịch JIT sử dụng các bit cao hơn trong con trỏ để mã hóa chúng
thông tin. Nó va chạm với các con trỏ hợp lệ với phân trang 5 cấp và
dẫn đến sự cố.

Để giảm thiểu điều này, chúng tôi sẽ không phân bổ không gian địa chỉ ảo
trên 47-bit theo mặc định.

Nhưng không gian người dùng có thể yêu cầu phân bổ từ không gian địa chỉ đầy đủ bằng cách
chỉ định địa chỉ gợi ý (có hoặc không có MAP_FIXED) trên 47 bit.

Nếu địa chỉ gợi ý được đặt trên 47 bit nhưng MAP_FIXED không được chỉ định, chúng tôi sẽ thử
để tìm kiếm khu vực chưa được ánh xạ theo địa chỉ được chỉ định. Nếu nó đã rồi
bị chiếm đóng, chúng tôi tìm kiếm khu vực chưa được ánh xạ trong không gian địa chỉ ZZ0000ZZ, thay vì
từ cửa sổ 47 bit.

Địa chỉ gợi ý cao sẽ chỉ ảnh hưởng đến việc phân bổ được đề cập, chứ không ảnh hưởng đến
bất kỳ mmap() nào trong tương lai.

Chỉ định địa chỉ gợi ý cao trên kernel cũ hơn hoặc trên máy không có 5 cấp
hỗ trợ phân trang là an toàn. Gợi ý sẽ bị bỏ qua và kernel sẽ quay trở lại
để phân bổ từ không gian địa chỉ 47 bit.

Cách tiếp cận này giúp dễ dàng nhận biết bộ cấp phát bộ nhớ của ứng dụng
về không gian địa chỉ lớn mà không cần theo dõi thủ công các địa chỉ ảo được phân bổ
không gian địa chỉ.

Một trường hợp quan trọng chúng ta cần xử lý ở đây là tương tác với MPX.
MPX (không có phần mở rộng MAWA) không thể xử lý các địa chỉ trên 47-bit, vì vậy chúng tôi
cần đảm bảo rằng MPX không thể được kích hoạt, chúng tôi đã có VMA ở trên
ranh giới và cấm tạo các VMA như vậy khi MPX được bật.