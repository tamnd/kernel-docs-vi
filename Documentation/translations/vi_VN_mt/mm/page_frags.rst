.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/mm/page_frags.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

================
mảnh trang
================

Một đoạn trang là một vùng bộ nhớ có độ dài tùy ý
nằm trong một trang phức hợp bậc 0 hoặc cao hơn.  Nhiều
các đoạn trong trang đó được tính lại riêng lẻ, trong phần của trang
bộ đếm tham khảo

Các hàm page_frag, page_frag_alloc và page_frag_free, cung cấp một
khung phân bổ đơn giản cho các đoạn trang.  Điều này được sử dụng bởi
ngăn xếp mạng và trình điều khiển thiết bị mạng để cung cấp vùng hỗ trợ
bộ nhớ để sử dụng làm đầu sk_buff-> hoặc được sử dụng trong "đoạn"
một phần của skb_shared_info.

Để sử dụng các API phân đoạn trang, một phân đoạn trang hỗ trợ
bộ đệm là cần thiết.  Điều này cung cấp một điểm trung tâm cho việc phân bổ đoạn
và các bản nhạc cho phép nhiều cuộc gọi sử dụng một trang được lưu trong bộ nhớ đệm.  các
Ưu điểm của việc này là có thể tránh được nhiều cuộc gọi tới get_page
có thể tốn kém tại thời điểm phân bổ.  Tuy nhiên do tính chất của
bộ nhớ đệm này, mọi lệnh gọi tới bộ nhớ đệm đều phải được bảo vệ bởi
giới hạn trên mỗi CPU hoặc giới hạn trên mỗi CPU và buộc ngắt
bị vô hiệu hóa khi thực hiện phân bổ đoạn.

Ngăn xếp mạng sử dụng hai bộ đệm riêng biệt cho mỗi CPU để xử lý phân đoạn
phân bổ.  Netdev_alloc_cache được người gọi sử dụng bằng cách sử dụng
các cuộc gọi netdev_alloc_frag và __netdev_alloc_skb.  napi_alloc_cache là
được sử dụng bởi người gọi các cuộc gọi __napi_alloc_frag và napi_alloc_skb.  các
sự khác biệt chính giữa hai cách gọi này là bối cảnh mà chúng có thể
được gọi.  Các hàm có tiền tố "netdev" có thể sử dụng được trong bất kỳ ngữ cảnh nào vì chúng
các chức năng sẽ vô hiệu hóa các ngắt, trong khi các chức năng có tiền tố "napi" là
chỉ có thể sử dụng được trong bối cảnh softirq.

Nhiều trình điều khiển thiết bị mạng sử dụng phương pháp tương tự để phân bổ trang
các mảnh, nhưng các mảnh trang được lưu trữ trong vòng hoặc bộ mô tả
cấp độ.  Để kích hoạt những trường hợp này, cần phải cung cấp một thông tin chung
cách phá bỏ bộ đệm trang.  Vì lý do này __page_frag_cache_drain
đã được thực hiện.  Nó cho phép giải phóng nhiều tài liệu tham khảo từ một
trang thông qua một cuộc gọi duy nhất.  Lợi ích của việc làm này là nó cho phép
dọn dẹp nhiều tài liệu tham khảo đã được thêm vào một trang để
tránh gọi get_page cho mỗi lần phân bổ.

Alexander Duyck, ngày 29 tháng 11 năm 2016.
