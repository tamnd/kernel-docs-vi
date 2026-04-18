.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/arch/arm/nwfpe/notes.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

Ghi chú
=======

Có vẻ như có vấn đề với exp(double) và trình giả lập của chúng tôi.  Tôi chưa
vẫn có thể theo dõi nó.  Điều này không xảy ra với trình giả lập
được cung cấp bởi Russell King.

Tôi cũng tìm thấy một điều kỳ lạ trong trình giả lập.  Tôi không nghĩ nó nghiêm trọng nhưng
sẽ chỉ ra nó.  Quy ước gọi ARM yêu cầu dấu phẩy động
đăng ký f4-f7 để được bảo toàn qua lệnh gọi hàm.  Trình biên dịch khá
thường sử dụng lệnh stfe để lưu f4 vào ngăn xếp khi truy cập vào một
và một lệnh ldfe để khôi phục nó trước khi quay trở lại.

Tôi đang xem một số mã, tính toán kết quả gấp đôi, lưu nó trong f4
sau đó thực hiện một cuộc gọi chức năng. Khi trở về từ hàm, hãy gọi số trong
f4 đã được chuyển đổi thành giá trị mở rộng trong trình mô phỏng.

Đây là một tác dụng phụ của hướng dẫn stfe.  Nhân đôi trong f4 phải là
được chuyển đổi thành mở rộng, sau đó được lưu trữ.  Nếu sử dụng kết hợp lfm/sfm,
thì sẽ không có chuyển đổi nào xảy ra.  Điều này có những cân nhắc về hiệu suất.  các
kết quả từ lệnh gọi hàm và f4 được sử dụng trong phép nhân.  Nếu
trình mô phỏng nhìn thấy bội số của một gấp đôi và được mở rộng, nó thúc đẩy gấp đôi thành
được mở rộng, sau đó nhân lên với độ chính xác mở rộng.

Mã này sẽ gây ra vấn đề này:

nhân đôi x, y, z;
z = log(x)/log(y);

Kết quả của log(x) (a double) sẽ được tính toán, trả về f0, sau đó
đã chuyển sang f4 để duy trì nó qua lệnh gọi log(y).  Việc chia sẽ được thực hiện
với độ chính xác mở rộng, do lệnh stfe được sử dụng để lưu f4 vào log(y).
