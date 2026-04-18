.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/sound/hd-audio/controls.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

===================================================
Điều khiển bộ trộn dành riêng cho codec âm thanh HD
===================================================


Tệp này giải thích các điều khiển bộ trộn dành riêng cho codec.

Codec Realtek
--------------

Chế độ kênh
  Đây là điều khiển enum để thay đổi thiết lập kênh vòm,
  chỉ xuất hiện khi có sẵn các kênh âm thanh vòm.
  Nó cung cấp số lượng kênh sẽ được sử dụng, "2ch", "4ch", "6ch",
  và "8ch".  Theo cấu hình, điều này cũng kiểm soát
  phân công lại giắc cắm của giắc cắm nhiều I/O.

Chế độ tự động tắt tiếng
  Đây là điều khiển enum để thay đổi hành vi tự động tắt tiếng của
  giắc cắm tai nghe và đầu ra.  Nếu loa và tai nghe tích hợp
  và/hoặc giắc cắm đầu ra có sẵn trên máy, điều khiển này
  xuất hiện.
  Khi chỉ có tai nghe hoặc giắc cắm đầu ra, nó sẽ cung cấp
  Trạng thái "Đã tắt" và "Đã bật".  Khi được bật, loa sẽ bị tắt tiếng
  tự động khi cắm jack.

Khi có cả hai giắc cắm tai nghe và đầu ra, nó sẽ mang lại
  "Đã tắt", "Chỉ loa" và "Đầu ra+Loa".  Khi nào
  chỉ chọn loa, cắm vào tai nghe hoặc giắc cắm đầu ra
  tắt tiếng loa nhưng không tắt tiếng dòng.  Khi có đầu ra+loa
  đã chọn, việc cắm vào giắc cắm tai nghe sẽ tắt tiếng cả loa và
  dòng ra.


Bộ giải mã IDT/Sigmatel
-----------------------

Vòng lặp tương tự
  Điều khiển này cho phép/vô hiệu hóa mạch vòng lặp tương tự.  Cái này
  chỉ xuất hiện khi "loopback" được đặt thành true trong gợi ý codec
  (xem HD-Audio.txt).  Lưu ý rằng trên một số codec, vòng lặp tương tự
  và tính năng phát lại PCM bình thường là độc quyền, tức là khi tính năng này được bật, bạn
  sẽ không nghe thấy bất kỳ luồng PCM nào.

Trung tâm trao đổi/LFE
  Hoán đổi thứ tự kênh trung tâm và LFE.  Thông thường, bên trái
  tương ứng với trung tâm và bên phải của LFE.  Khi đây là
  BẬT, bên trái là LFE và bên phải là chính giữa.

Tai nghe dưới dạng Line Out
  Khi điều khiển này BẬT, hãy coi giắc cắm tai nghe là đầu ra
  giắc cắm.  Nghĩa là, tai nghe sẽ không tự động tắt tiếng các đầu ra khác,
  và không có HP-amp nào được đặt vào các chân.

Chế độ Jack Mic, Chế độ Jack Line, v.v.
  Các enum này kiểm soát hướng và độ lệch của giắc đầu vào
  ghim.  Tùy thuộc vào loại giắc cắm, nó có thể được đặt thành "Mic In" và "Line" 
  In", để xác định độ lệch đầu vào hoặc có thể được đặt thành "Line Out"
  khi chân cắm là giắc cắm đa I/O cho các kênh âm thanh vòm.


Bộ giải mã VIA
--------------

Thông minh 5.1
  Một điều khiển enum để phân công lại các giắc cắm đa I/O cho đầu ra âm thanh vòm.
  Khi nó BẬT, các giắc cắm đầu vào tương ứng (thường là giắc cắm đầu vào và giắc cắm
  mic-in) được chuyển đổi thành giắc cắm âm thanh vòm và đầu ra CLFE.

HP độc lập
  Khi điều khiển enum này được bật, đầu ra tai nghe sẽ được định tuyến
  từ một luồng riêng lẻ (PCM thứ ba chẳng hạn như hw:0,2) thay vì
  luồng chính.  Trong trường hợp tai nghe DAC được chia sẻ với một
  bên cạnh hoặc DAC kênh CLFE, DAC được chuyển sang tai nghe
  tự động.

Trộn vòng lặp
  Một điều khiển enum để xác định xem tuyến đường vòng lặp tương tự có
  kích hoạt hay không.  Khi được bật, vòng lặp tương tự sẽ được trộn lẫn với
  kênh phía trước.  Ngoài ra, lộ trình tương tự được sử dụng cho tai nghe
  và đầu ra loa.  Là một tác dụng phụ, khi chế độ này được thiết lập,
  điều khiển âm lượng riêng lẻ sẽ không còn khả dụng cho
  tai nghe và loa vì chỉ có một DAC được kết nối với một
  tiện ích máy trộn.

Kiểm soát năng lượng động
  Điều khiển này xác định xem điều khiển công suất động trên mỗi giắc cắm có
  phát hiện có được kích hoạt hay không.  Khi được bật, trạng thái nguồn của tiện ích
  (D0/D3) được thay đổi linh hoạt tùy theo việc cắm giắc cắm
  trạng thái tiết kiệm điện năng tiêu thụ.  Tuy nhiên, nếu hệ thống của bạn
  không cung cấp khả năng phát hiện giắc cắm thích hợp, điều này sẽ không hoạt động; trong một
  trường hợp này, hãy xoay điều khiển này OFF.

Jack phát hiện
  Điều khiển này chỉ được cung cấp cho codec VT1708 không cung cấp
  sự kiện không được yêu cầu trên mỗi phích cắm.  Khi tính năng này được bật, người lái xe sẽ thăm dò ý kiến
  phát hiện giắc cắm để tính năng tự động tắt tiếng của tai nghe có thể hoạt động, đồng thời 
  tắt cái này đi sẽ giảm mức tiêu thụ điện năng.


Codec liên kết
---------------

Chế độ tự động tắt tiếng
  Xem codec Realtek.


Bộ giải mã tương tự
-------------------

Chế độ kênh
  Đây là điều khiển enum để thay đổi thiết lập kênh vòm,
  chỉ xuất hiện khi có sẵn các kênh âm thanh vòm.
  Nó cung cấp số lượng kênh sẽ được sử dụng, "2ch", "4ch" và "6ch".
  Theo cấu hình, điều này cũng kiểm soát
  phân công lại giắc cắm của giắc cắm nhiều I/O.

HP độc lập
  Khi điều khiển enum này được bật, đầu ra tai nghe sẽ được định tuyến
  từ một luồng riêng lẻ (PCM thứ ba chẳng hạn như hw:0,2) thay vì
  luồng chính.
