.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/process/contribution-maturity-model.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

============================================
Mô hình trưởng thành đóng góp hạt nhân Linux
============================================


Lý lịch
==========

Là một phần của Hội nghị thượng đỉnh dành cho những người bảo trì hạt nhân Linux năm 2021, đã có một
ZZ0000ZZ về những thách thức trong
tuyển dụng người bảo trì kernel cũng như người kế nhiệm người bảo trì.  Một số
kết luận từ cuộc thảo luận đó bao gồm rằng các công ty là một
một phần của cộng đồng Linux Kernel cần cho phép các kỹ sư
người bảo trì như một phần công việc của họ, để họ có thể phát triển thành
những nhà lãnh đạo được kính trọng và cuối cùng là những người duy trì kernel.  Để hỗ trợ một
nguồn nhân tài mạnh mẽ, các nhà phát triển nên được phép và khuyến khích
đảm nhận những đóng góp ngược dòng như xem xét các bản vá của người khác,
tái cấu trúc cơ sở hạ tầng hạt nhân và viết tài liệu.

Để đạt được mục tiêu đó, Ban Cố vấn Kỹ thuật của Quỹ Linux (TAB)
đề xuất Mô hình trưởng thành đóng góp hạt nhân Linux này. Những điểm chung này
mong đợi về sự tham gia của cộng đồng ở thượng nguồn nhằm mục đích tăng cường
ảnh hưởng của các nhà phát triển cá nhân, tăng cường sự hợp tác của
các tổ chức và cải thiện tình trạng chung của Hạt nhân Linux
hệ sinh thái.

TAB kêu gọi các tổ chức liên tục đánh giá Nguồn mở của họ
mô hình trưởng thành và cam kết cải tiến để phù hợp với mô hình này.  Đến
hiệu quả, việc đánh giá này nên kết hợp phản hồi từ khắp nơi
tổ chức, bao gồm cả quản lý và nhà phát triển ở mọi cấp độ thâm niên
cấp độ.  Theo tinh thần Nguồn Mở, chúng tôi khuyến khích các tổ chức
công bố các đánh giá và kế hoạch của họ để cải thiện sự tham gia của họ với
cộng đồng thượng nguồn.

Cấp 0
=======

* Kỹ sư phần mềm không được phép đóng góp các bản vá cho Linux
  hạt nhân.


Cấp 1
=======

* Kỹ sư phần mềm được phép đóng góp các bản vá cho Linux
  kernel, như một phần trách nhiệm công việc của họ hoặc theo cách riêng của họ
  thời gian.

Cấp 2
=======

* Các kỹ sư phần mềm được kỳ vọng sẽ đóng góp cho Hạt nhân Linux như
  một phần trách nhiệm công việc của họ.
* Kỹ sư phần mềm sẽ được hỗ trợ tham dự các khóa học liên quan đến Linux
  hội nghị như một phần công việc của họ.
* Những đóng góp về mã ngược dòng của Kỹ sư phần mềm sẽ được xem xét
  trong việc thăng tiến và đánh giá hiệu suất.

Cấp 3
=======

* Kỹ sư phần mềm phải xem xét các bản vá (bao gồm cả các bản vá
  được soạn thảo bởi các kỹ sư từ các công ty khác) như một phần công việc của họ
  trách nhiệm
* Đóng góp các bài thuyết trình hoặc bài viết liên quan đến Linux hoặc học thuật
  các hội nghị (chẳng hạn như các hội nghị được tổ chức bởi Linux Foundation, Usenix,
  ACM, v.v.), được coi là một phần công việc của kỹ sư.
* Đóng góp cho cộng đồng của Kỹ sư phần mềm sẽ được xem xét trong
  đánh giá thăng tiến và hiệu suất.
* Các tổ chức sẽ thường xuyên báo cáo các số liệu về nguồn mở của họ
  đóng góp và theo dõi các số liệu này theo thời gian.  Những thước đo này có thể
  chỉ được công bố trong nội bộ tổ chức hoặc tại
  theo quyết định riêng của tổ chức, một số hoặc tất cả có thể được công bố ra bên ngoài.
  Các số liệu được đề xuất mạnh mẽ bao gồm:

* Số lượng đóng góp kernel ngược dòng của nhóm hoặc tổ chức
    (ví dụ: tất cả mọi người báo cáo với người quản lý, giám đốc hoặc VP).
  * Tỷ lệ phần trăm các nhà phát triển kernel đã thực hiện ngược dòng
    đóng góp so với tổng số nhà phát triển hạt nhân trong
    tổ chức.
  * Khoảng thời gian giữa các hạt nhân được sử dụng trong máy chủ của tổ chức
    và/hoặc sản phẩm và ngày xuất bản của hạt nhân ngược dòng
    dựa trên đó hạt nhân nội bộ được dựa trên.
  * Số lượng cam kết ngoài cây có trong các hạt nhân bên trong.

Cấp 4
=======

* Kỹ sư phần mềm được khuyến khích dành một phần công việc của mình
  thời gian tập trung vào Công việc thượng nguồn, được định nghĩa là xem xét các bản vá,
  phục vụ trong các ủy ban chương trình, cải thiện cơ sở hạ tầng dự án cốt lõi
  chẳng hạn như viết hoặc duy trì các bài kiểm tra, giảm nợ công nghệ ngược dòng,
  viết tài liệu, v.v.
* Kỹ sư phần mềm được hỗ trợ trong việc giúp tổ chức các công việc liên quan đến Linux
  hội nghị.
* Các tổ chức sẽ xem xét phản hồi chính thức của thành viên cộng đồng
  đánh giá hiệu suất.

Cấp 5
=======

* Phát triển hạt nhân ngược dòng được coi là một vị trí công việc chính thức, với
  ít nhất một phần ba thời gian của kỹ sư dành cho Công việc thượng nguồn.
* Các tổ chức sẽ tích cực tìm kiếm phản hồi của thành viên cộng đồng như một
  yếu tố đánh giá hiệu suất chính thức.
* Các tổ chức sẽ thường xuyên báo cáo nội bộ về tỷ lệ
  Upstream Work to Work tập trung vào việc trực tiếp theo đuổi các mục tiêu kinh doanh.