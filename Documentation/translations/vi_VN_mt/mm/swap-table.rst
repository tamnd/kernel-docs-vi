.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/mm/swap-table.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

:Tác giả: Chris Li <chrisl@kernel.org>, Kairui Song <kasong@tencent.com>

=============
Bảng hoán đổi
=============

Bảng hoán đổi triển khai bộ đệm trao đổi dưới dạng mảng giá trị bộ đệm trao đổi trên mỗi cụm.

Trao đổi mục nhập
-----------------

Mục trao đổi chứa thông tin cần thiết để phục vụ trang ẩn danh
lỗi.

Mục nhập hoán đổi được mã hóa thành hai phần: loại hoán đổi và phần bù hoán đổi.

Loại trao đổi cho biết thiết bị trao đổi nào sẽ được sử dụng.
Phần bù hoán đổi là phần bù của tệp hoán đổi để đọc dữ liệu trang từ đó.

Hoán đổi bộ đệm
---------------

Bộ đệm trao đổi là một bản đồ để tra cứu các folio bằng cách sử dụng mục nhập trao đổi làm khóa. kết quả
giá trị có thể có ba loại tùy thuộc vào giai đoạn nào của mục hoán đổi này
đã ở trong.

1. NULL: Mục hoán đổi này không được sử dụng.

2. folio: Một folio đã được phân bổ và ràng buộc với mục hoán đổi này. Đây là
   trạng thái tạm thời của trao đổi ra hoặc trao đổi vào. Dữ liệu folio có thể ở
   tập tin folio hoặc tập tin hoán đổi, hoặc cả hai.

3. bóng: Bóng chứa thông tin tập làm việc của người được hoán đổi
   ra tờ giấy. Đây là trạng thái bình thường đối với một trang bị tráo đổi.

Hoán đổi nội bộ bảng
--------------------

Bộ đệm trao đổi trước đó được XArray triển khai. XArray là một cái cây
cấu trúc. Mỗi lần tra cứu sẽ đi qua nhiều nút. Chúng ta có thể làm tốt hơn không?

Lưu ý rằng hầu hết khi chúng tôi tra cứu bộ đệm trao đổi, chúng tôi đều
trong một đường dẫn trao đổi vào hoặc trao đổi. Chúng ta đã có cụm trao đổi,
trong đó có mục trao đổi.

Nếu chúng ta có một mảng trên mỗi cụm để lưu trữ giá trị bộ đệm trao đổi trong cụm.
Tra cứu bộ đệm hoán đổi trong cụm có thể là tra cứu mảng rất đơn giản.

Chúng tôi đặt tên cho mảng giá trị bộ đệm trao đổi trên mỗi cụm như vậy: bảng hoán đổi.

Bảng hoán đổi là một mảng các con trỏ. Mỗi con trỏ có cùng kích thước với một
PTE. Kích thước của bảng trao đổi cho một cụm trao đổi thường khớp với PTE
bảng trang, là một trang trên hệ thống 64-bit hiện đại.

Với bảng trao đổi, việc tra cứu bộ đệm trao đổi có thể đạt được vị trí tuyệt vời, đơn giản hơn,
và nhanh hơn.

Khóa
-------

Sửa đổi bảng hoán đổi yêu cầu lấy khóa cụm. Nếu một tờ giấy
đang được thêm vào hoặc xóa khỏi bảng hoán đổi, folio phải được
bị khóa trước khóa cụm. Sau khi thêm hoặc bớt xong,
folio sẽ được mở khóa.

Tra cứu bảng hoán đổi được bảo vệ bởi RCU và đọc nguyên tử. Nếu tra cứu
trả về một folio, người dùng phải khóa folio trước khi sử dụng.