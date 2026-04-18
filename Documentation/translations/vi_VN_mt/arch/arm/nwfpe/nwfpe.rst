.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/arch/arm/nwfpe/nwfpe.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

Giới thiệu
============

Thư mục này chứa phiên bản thử nghiệm 0.92 của NetWinder
Trình mô phỏng dấu phẩy động.

Phần lớn mã được viết bởi tôi, Scott Bambrough.
được viết bằng C, với một số ít thủ tục trong trình biên dịch nội tuyến
nơi cần thiết.  Nó được viết nhanh chóng, với mục tiêu thực hiện một
phiên bản làm việc của tất cả các lệnh dấu phẩy động của trình biên dịch
phát ra làm mục tiêu đầu tiên.  Tôi đã cố gắng tối ưu nhất có thể
có thể, nhưng vẫn còn nhiều chỗ để cải thiện.

Tôi đã cố gắng làm cho trình mô phỏng di động nhất có thể.  Một trong
vấn đề là ở dấu gạch dưới hàng đầu trên các ký hiệu hạt nhân.  yêu tinh
hạt nhân không có dấu gạch dưới ở đầu, hạt nhân được biên dịch a.out thì có.  tôi
đã cố gắng sử dụng macro C_SYMBOL_NAME bất cứ nơi nào có thể
quan trọng.

Một lựa chọn khác mà tôi đã thực hiện là ở cấu trúc tệp.  Tôi đã cố gắng
chứa tất cả mã cụ thể của hệ điều hành trong một mô-đun (fpmodule.*).
Tất cả các tệp khác đều chứa mã cụ thể của trình mô phỏng.  Điều này sẽ cho phép
những người khác chuyển trình giả lập sang NetBSD chẳng hạn tương đối dễ dàng.

Các phép toán dấu phẩy động dựa trên SoftFloat Release 2, bởi
John Hauser.  SoftFloat là một phần mềm triển khai dấu phẩy động
phù hợp với Tiêu chuẩn IEC/IEEE cho Dấu phẩy động nhị phân
Số học.  Có tới bốn định dạng được hỗ trợ: độ chính xác đơn,
độ chính xác gấp đôi, độ chính xác gấp đôi mở rộng và độ chính xác gấp bốn lần.
Tất cả các hoạt động theo yêu cầu của tiêu chuẩn đều được thực hiện, ngoại trừ
chuyển đổi sang và từ số thập phân.  Chúng tôi chỉ sử dụng độ chính xác duy nhất,
độ chính xác kép và các định dạng có độ chính xác kép mở rộng.  Cảng của
SoftFloat cho ARM được thực hiện bởi Phil Blundell, dựa trên một phiên bản trước đó
cổng SoftFloat phiên bản 1 của Neil Carson cho NetBSD/arm32.

Tệp README.FPE chứa mô tả về những gì đã được triển khai
cho đến nay trong trình mô phỏng.  Tệp TODO chứa thông tin về những gì
vẫn còn phải làm và các ý tưởng khác cho trình mô phỏng.

Báo cáo lỗi, nhận xét, đề xuất nên được chuyển trực tiếp đến tôi tại
<scottb@netwinder.org>.  Báo cáo chung về "chương trình này không
hoạt động chính xác khi trình giả lập của bạn được cài đặt" rất hữu ích cho
xác định rằng lỗi vẫn tồn tại; nhưng hầu như vô dụng khi
cố gắng cô lập vấn đề.  Hãy báo cáo chúng, nhưng đừng
mong đợi hành động nhanh chóng.  Lỗi vẫn tồn tại.  Vấn đề vẫn ở chỗ cách ly
hướng dẫn nào có lỗi.  Các chương trình nhỏ minh họa một vấn đề cụ thể
vấn đề là một ơn trời.

Thông báo pháp lý
-------------

Trình giả lập dấu phẩy động NetWinder là phần mềm miễn phí.  Mọi thứ Rebel.com
đã viết được cung cấp theo GNU GPL.  Xem file COPYING để sao chép
điều kiện.  Mã SoftFloat bị loại trừ ở trên.  của John Hauser
thông báo pháp lý cho SoftFloat được bao gồm bên dưới.

-------------------------------------------------------------------------------

Thông báo pháp lý SoftFloat

SoftFloat được viết bởi John R. Hauser.  Công việc này đã được thực hiện trong
một phần của Viện Khoa học Máy tính Quốc tế, tọa lạc tại Suite 600,
1947 Center Street, Berkeley, California 94704. Tài trợ một phần
được cung cấp bởi Quỹ khoa học quốc gia dưới sự cấp phép MIP-9311980.  các
phiên bản gốc của mã này được viết như một phần của dự án xây dựng
bộ xử lý vectơ điểm cố định phối hợp với Đại học
California tại Berkeley, được giám sát bởi Giáo sư. Nelson Morgan và John Wawrzynek.

THIS SOFTWARE LÀ DISTRIBUTED NHƯ VẬY, FOR FREE.  Mặc dù nỗ lực hợp lý
đã được thực hiện để tránh điều đó, THIS SOFTWARE MAY CONTAIN FAULTS THAT WILL AT
TIMES RESULT TRONG INCORRECT BEHAVIOR.  USE CỦA THIS SOFTWARE LÀ RESTRICTED ĐẾN
PERSONS AND ORGANIZATIONS WHO CAN AND WILL TAKE FULL RESPONSIBILITY FOR ANY
AND ALL LOSSES, COSTS, HOẶC OTHER PROBLEMS ARISING FROM ITS USE.
-------------------------------------------------------------------------------
