.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/arch/riscv/patch-acceptance.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

hướng dẫn bảo trì Arch/riscv dành cho nhà phát triển
================================================

Tổng quan
--------
Kiến trúc tập lệnh RISC-V được phát triển mở:
bản nháp đang thực hiện có sẵn để tất cả mọi người xem xét và thử nghiệm
với việc triển khai.  Bản dự thảo mô-đun hoặc tiện ích mở rộng mới có thể thay đổi
trong quá trình phát triển - đôi khi theo những cách
không phù hợp với các dự thảo trước đó.  Sự linh hoạt này có thể mang lại một
thách thức đối với việc bảo trì RISC-V Linux.  Các nhà bảo trì Linux không chấp thuận
của sự gián đoạn và quá trình phát triển Linux ưu tiên được xem xét kỹ lưỡng và
mã được thử nghiệm trên mã thử nghiệm.  Chúng tôi mong muốn mở rộng những điều tương tự
nguyên tắc của mã liên quan đến RISC-V sẽ được chấp nhận cho
đưa vào kernel.

Chắp vá
---------

RISC-V có một phiên bản chắp vá, trong đó có thể kiểm tra trạng thái của các bản vá:

ZZ0000ZZ

Nếu bản vá của bạn không xuất hiện trong chế độ xem mặc định, người bảo trì RISC-V có
có thể đã yêu cầu thay đổi hoặc mong muốn nó được áp dụng cho cây khác.

Tự động hóa chạy dựa trên phiên bản chắp vá này, xây dựng/thử nghiệm các bản vá khi
họ đến. Tự động hóa áp dụng các bản vá cho HEAD hiện tại của
Các nhánh RISC-V ZZ0000ZZ và ZZ0001ZZ, tùy thuộc vào việc bản vá đã được cập nhật chưa
được phát hiện là một bản sửa lỗi. Nếu không thành công, nó sẽ sử dụng nhánh RISC-V ZZ0002ZZ.
Cam kết chính xác mà một loạt đã được áp dụng sẽ được ghi chú trên bản chắp vá.
Các bản vá mà bất kỳ bước kiểm tra nào không thành công đều khó có thể được áp dụng và trong hầu hết
trường hợp sẽ cần phải được gửi lại.

Gửi phụ lục danh sách kiểm tra
-------------------------
Chúng tôi sẽ chỉ chấp nhận các bản vá cho mô-đun hoặc tiện ích mở rộng mới nếu
thông số kỹ thuật cho các mô-đun hoặc phần mở rộng đó được liệt kê dưới dạng
khó có thể bị thay đổi không tương thích trong tương lai.  cho
thông số kỹ thuật từ nền tảng RISC-V, điều này có nghĩa là "Đông lạnh" hoặc
"Đã phê chuẩn", đối với thông số kỹ thuật của diễn đàn UEFI, điều này có nghĩa là một thông số đã được xuất bản
ECR.  (Tất nhiên, các nhà phát triển có thể duy trì cây nhân Linux của riêng họ
có chứa mã cho bất kỳ tiện ích mở rộng dự thảo nào mà họ muốn.)

Ngoài ra, đặc tả RISC-V cho phép người triển khai tạo
phần mở rộng tùy chỉnh của riêng họ.  Các tiện ích mở rộng tùy chỉnh này không bắt buộc
để trải qua bất kỳ quá trình xem xét hoặc phê chuẩn nào của RISC-V
Nền tảng.  Để tránh sự phức tạp và tiềm năng bảo trì
tác động hiệu suất của việc thêm mã hạt nhân cho người triển khai cụ thể
RISC-V, chúng tôi sẽ chỉ xem xét các bản vá cho các tiện ích mở rộng:

- Đã chính thức bị đóng băng hoặc phê chuẩn bởi RISC-V Foundation, hoặc
- Đã được triển khai trên phần cứng có sẵn rộng rãi, theo tiêu chuẩn
  Thực hành Linux.

(Tất nhiên, những người triển khai có thể duy trì cây nhân Linux của riêng họ có chứa
mã cho bất kỳ tiện ích mở rộng tùy chỉnh nào mà họ muốn.)