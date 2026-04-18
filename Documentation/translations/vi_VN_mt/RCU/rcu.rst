.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/RCU/rcu.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. _rcu_doc:

Khái niệm RCU
=============

Ý tưởng cơ bản đằng sau RCU (cập nhật đọc-sao chép) là phân chia các dữ liệu phá hoại
hoạt động thành hai phần, một phần ngăn không cho bất kỳ ai nhìn thấy dữ liệu
vật phẩm đang bị phá hủy và một vật phẩm thực sự thực hiện việc tiêu hủy.
Một "thời gian gia hạn" phải trôi qua giữa hai phần và thời gian gia hạn này
phải đủ dài để bất kỳ người đọc nào truy cập vào mục bị xóa đều có
kể từ khi bỏ tài liệu tham khảo của họ.  Ví dụ: thao tác xóa được bảo vệ bằng RCU
từ danh sách liên kết trước tiên sẽ xóa mục khỏi danh sách, đợi
một khoảng thời gian gia hạn sẽ trôi qua, sau đó giải phóng phần tử.  Xem danh sáchRCU.rst để biết thêm
thông tin về cách sử dụng RCU với danh sách liên kết.

Câu hỏi thường gặp
--------------------------

- Tại sao mọi người lại muốn sử dụng RCU?

Ưu điểm của cách tiếp cận hai phần của RCU là độc giả RCU cần
  không có được bất kỳ khóa nào, thực hiện bất kỳ hướng dẫn nguyên tử nào, viết thư cho
  bộ nhớ dùng chung hoặc (trên các CPU không phải Alpha) thực thi bất kỳ bộ nhớ nào
  rào cản.  Thực tế là những hoạt động này khá tốn kém
  trên các CPU hiện đại là điều mang lại cho RCU lợi thế về hiệu năng
  trong các tình huống chủ yếu đọc.  Thực tế là độc giả RCU không cần
  có được khóa cũng có thể đơn giản hóa rất nhiều mã tránh bế tắc.

- Làm cách nào trình cập nhật có thể biết khi nào thời gian gia hạn đã hoàn tất
  nếu đầu đọc RCU không đưa ra dấu hiệu nào khi chúng hoàn tất?

Cũng giống như với spinlocks, đầu đọc RCU không được phép
  chặn, chuyển sang thực thi ở chế độ người dùng hoặc vào vòng lặp nhàn rỗi.
  Do đó, ngay khi người ta nhìn thấy CPU đi qua bất kỳ nơi nào trong số này
  ba trạng thái, chúng ta biết rằng CPU đã thoát khỏi mọi RCU trước đó
  phần quan trọng bên đọc.  Vì vậy, nếu chúng ta xóa một mục khỏi một
  danh sách liên kết, sau đó đợi cho đến khi tất cả CPU đã chuyển ngữ cảnh,
  được thực thi ở chế độ người dùng hoặc được thực hiện trong vòng lặp nhàn rỗi, chúng ta có thể
  giải phóng mặt hàng đó một cách an toàn.

Các biến thể ưu tiên của RCU (CONFIG_PREEMPT_RCU) có được
  tác dụng tương tự, nhưng yêu cầu người đọc thao tác CPU-local
  quầy.  Các bộ đếm này cho phép các loại chặn hạn chế trong
  RCU phần quan trọng phía đọc.  SRCU cũng sử dụng CPU-local
  bộ đếm và cho phép chặn chung trong RCU phía đọc
  các phần quan trọng.  Các biến thể này của RCU phát hiện thời gian gia hạn
  bằng cách lấy mẫu các quầy này.

- Nếu tôi đang chạy trên kernel đơn bộ xử lý thì chỉ có thể thực hiện một
  tại một thời điểm, tại sao tôi phải chờ thời gian gia hạn?

Xem UP.rst để biết thêm thông tin.

- Làm cách nào tôi có thể biết RCU hiện đang được sử dụng ở đâu trong nhân Linux?

Tìm kiếm "rcu_read_lock", "rcu_read_unlock", "call_rcu",
  "rcu_read_lock_bh", "rcu_read_unlock_bh", "srcu_read_lock",
  "srcu_read_unlock", "synchronize_rcu", "synchronize_net",
  "synchronize_srcu" và các nguyên hàm RCU khác.  Hoặc lấy một cái
  của cơ sở dữ liệu cscope từ:

(ZZ0000ZZ

- Tôi nên tuân theo những nguyên tắc nào khi viết mã sử dụng RCU?

Xem danh sách kiểm tra.rst.

- Tại sao lại có tên "RCU"?

"RCU" là viết tắt của "cập nhật đọc-sao chép".
  listRCU.rst có thêm thông tin về nguồn gốc của tên này, hãy tìm kiếm
  cho "cập nhật đọc-sao chép" để tìm thấy nó.

- Tôi nghe nói RCU đã được cấp bằng sáng chế?  Có chuyện gì vậy?

Vâng, đúng vậy.  Có một số bằng sáng chế được biết đến liên quan đến RCU,
  tìm kiếm chuỗi "Patent" trong Documentation/RCU/RTFP.txt để tìm chúng.
  Trong số này, một người được người chuyển nhượng cho phép hủy bỏ, và
  một số khác đã được đóng góp cho nhân Linux theo GPL.
  Nhiều (nhưng không phải tất cả) đã hết hạn từ lâu.
  Hiện tại cũng có triển khai LGPL ở cấp độ người dùng RCU
  có sẵn (ZZ0000ZZ

- Tôi nghe nói rằng RCU cần hoạt động để hỗ trợ hạt nhân thời gian thực?

RCU thân thiện với thời gian thực được kích hoạt thông qua CONFIG_PREEMPTION
  tham số cấu hình hạt nhân.

- Tôi có thể tìm thêm thông tin về RCU ở đâu?

Xem tệp Tài liệu/RCU/RTFP.txt.
  Hoặc trỏ trình duyệt của bạn vào (ZZ0000ZZ
  hoặc (ZZ0001ZZ
