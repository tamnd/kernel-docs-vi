.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/core-api/real-time/hardware.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

======================
Xem xét phần cứng
====================

:Tác giả: Sebastian Andrzej Siewior <bigeasy@linutronix.de>

Cách xử lý khối lượng công việc có thể bị ảnh hưởng bởi phần cứng chạy trên đó.
Các thành phần chính bao gồm CPU, bộ nhớ và các bus kết nối chúng.
Những tài nguyên này được chia sẻ giữa tất cả các ứng dụng trên hệ thống.
Kết quả là, việc sử dụng nhiều tài nguyên của một ứng dụng
có thể ảnh hưởng đến việc xử lý xác định khối lượng công việc trong các ứng dụng khác.

Dưới đây là một tổng quan ngắn gọn.

Bộ nhớ hệ thống và bộ đệm
-----------------------

Bộ nhớ chính và các bộ nhớ đệm liên quan là những tài nguyên được chia sẻ phổ biến nhất trong số
nhiệm vụ trong một hệ thống. Một tác vụ có thể thống trị bộ nhớ đệm sẵn có, buộc một tác vụ khác
nhiệm vụ đợi cho đến khi một dòng bộ đệm được ghi trở lại bộ nhớ chính trước khi nó có thể
tiến hành. Tác động của sự tranh chấp này thay đổi dựa trên kiểu viết và
kích thước của bộ nhớ đệm có sẵn. Bộ đệm lớn hơn có thể làm giảm tình trạng ngừng hoạt động vì có nhiều dòng hơn
có thể được đệm trước khi được viết lại. Ngược lại, một số mẫu viết nhất định
có thể kích hoạt bộ điều khiển bộ đệm để xóa nhiều dòng cùng một lúc, gây ra
các ứng dụng bị đình trệ cho đến khi hoạt động hoàn tất.

Vấn đề này có thể được giảm thiểu một phần nếu các ứng dụng không dùng chung CPU
bộ đệm. Hạt nhân nhận thức được cấu trúc liên kết bộ đệm và xuất thông tin này sang
không gian người dùng. Các công cụ như ZZ0000ZZ từ Portable Hardware Locality (hwloc)
dự án (ZZ0001ZZ có thể trực quan hóa hệ thống phân cấp.

Việc tránh các bộ đệm L2 hoặc L3 được chia sẻ không phải lúc nào cũng có thể thực hiện được. Ngay cả khi chia sẻ bộ nhớ đệm
được giảm thiểu, tình trạng tắc nghẽn vẫn có thể xảy ra khi truy cập bộ nhớ hệ thống. Bộ nhớ
được sử dụng không chỉ bởi CPU mà còn bởi các thiết bị ngoại vi thông qua DMA, chẳng hạn như
card đồ họa hoặc bộ điều hợp mạng.

Trong một số trường hợp, tắc nghẽn bộ nhớ đệm và bộ nhớ có thể được kiểm soát nếu phần cứng
cung cấp sự hỗ trợ cần thiết. Trên hệ thống x86, Intel cung cấp Phân bổ bộ đệm
Công nghệ (CAT), cho phép phân vùng bộ đệm giữa các ứng dụng và
cung cấp khả năng kiểm soát kết nối. AMD cung cấp chức năng tương tự trong
Chất lượng dịch vụ nền tảng (PQoS). Trên Arm64, tương đương là Memory
Giám sát và phân vùng tài nguyên hệ thống (MPAM).

Các tính năng này có thể được cấu hình thông qua giao diện Kiểm soát tài nguyên Linux.
Để biết chi tiết, hãy xem Tài liệu/hệ thống tập tin/resctrl.rst.

Công cụ hoàn hảo có thể được sử dụng để theo dõi hành vi của bộ đệm. Nó có thể phân tích
bộ nhớ đệm của một ứng dụng bị thiếu và so sánh chúng thay đổi như thế nào trong
khối lượng công việc khác nhau trên CPU lân cận. Thậm chí còn mạnh mẽ hơn nữa, sự hoàn hảo
Công cụ c2c có thể giúp xác định các sự cố chuyển bộ nhớ đệm sang bộ đệm, trong đó có nhiều CPU
các lõi liên tục truy cập và sửa đổi dữ liệu trên cùng một dòng bộ đệm.

Xe buýt phần cứng
--------------

Các hệ thống thời gian thực thường cần truy cập trực tiếp vào phần cứng để thực hiện công việc của chúng.
Bất kỳ độ trễ nào trong quá trình này đều là điều không mong muốn vì nó có thể ảnh hưởng đến kết quả của
nhiệm vụ. Ví dụ: trên bus I/O, đầu ra đã thay đổi có thể không trở thành ngay lập tức.
hiển thị nhưng thay vào đó xuất hiện với độ trễ thay đổi tùy thuộc vào độ trễ của
xe buýt dùng để liên lạc.

Một bus như PCI tương đối đơn giản vì các truy cập đăng ký được định tuyến
trực tiếp tới thiết bị được kết nối. Trong trường hợp xấu nhất, thao tác đọc sẽ dừng hoạt động
CPU cho đến khi thiết bị phản hồi.

Một bus như USB phức tạp hơn, bao gồm nhiều lớp. Một đăng ký đã đọc
hoặc ghi được gói trong Khối yêu cầu USB (URB), sau đó được gửi bởi
Bộ điều khiển máy chủ USB cho thiết bị. Thời gian và độ trễ bị ảnh hưởng bởi
xe buýt USB bên dưới. Yêu cầu không thể được gửi ngay lập tức; họ phải phù hợp với
ranh giới khung tiếp theo theo loại điểm cuối và bộ điều khiển máy chủ
quy định về lịch trình. Điều này có thể gây ra sự chậm trễ và độ trễ bổ sung. Ví dụ,
một thiết bị mạng được kết nối qua USB vẫn có thể cung cấp đủ thông lượng, nhưng
độ trễ tăng thêm khi gửi hoặc nhận gói có thể không đáp ứng được
yêu cầu của một số trường hợp sử dụng thời gian thực.

Những hạn chế bổ sung về độ trễ của bus có thể phát sinh từ việc quản lý nguồn điện. cho
chẳng hạn, PCIe có bật Quản lý năng lượng trạng thái hoạt động (ASPM) có thể tạm dừng
liên kết giữa thiết bị và máy chủ. Mặc dù hành vi này có lợi cho
tiết kiệm năng lượng, nó làm trì hoãn việc truy cập thiết bị và tăng thêm độ trễ cho các phản hồi. Vấn đề này
không giới hạn ở PCIe; các bus nội bộ trong Hệ thống trên chip (SoC) cũng có thể
bị ảnh hưởng bởi cơ chế quản lý năng lượng.

Ảo hóa
--------------

Trong môi trường ảo hóa như KVM, mỗi khách CPU được biểu diễn dưới dạng
chủ đề trên máy chủ. Nếu một luồng như vậy chạy với mức độ ưu tiên theo thời gian thực, hệ thống sẽ
nên được kiểm tra để xác nhận nó có thể duy trì hành vi này trong thời gian dài.
Do mức độ ưu tiên của nó, luồng sẽ không bị ưu tiên thấp hơn
các luồng (chẳng hạn như SCHED_OTHER), sau đó có thể không nhận được thời gian CPU. Điều này có thể
gây ra sự cố nếu một luồng có mức độ ưu tiên thấp hơn được ghim vào CPU đã bị chiếm bởi
một nhiệm vụ thời gian thực và không thể đạt được tiến bộ. Ngay cả khi CPU đã bị cô lập,
hệ thống có thể vẫn (vô tình) khởi động một luồng trên mỗi CPU trên CPU đó.
Việc đảm bảo rằng CPU khách không hoạt động là rất khó vì nó đòi hỏi phải tránh cả hai
lập kế hoạch nhiệm vụ và xử lý gián đoạn. Hơn nữa, nếu khách CPU đi
không hoạt động nhưng hệ thống khách được khởi động với tùy chọn ZZ0000ZZ, hệ thống khách
CPU sẽ không bao giờ chuyển sang trạng thái không hoạt động và thay vào đó sẽ quay cho đến khi có sự kiện
đến.

Việc xử lý thiết bị đưa ra những cân nhắc bổ sung. Các thiết bị PCI mô phỏng hoặc
Các thiết bị VirtIO yêu cầu một bản sao trên máy chủ để hoàn thành các yêu cầu. Cái này
thêm độ trễ vì máy chủ phải chặn và xử lý yêu cầu
trực tiếp hoặc lên lịch cho một chủ đề để hoàn thành. Những sự chậm trễ này có thể tránh được nếu
thiết bị PCI được yêu cầu sẽ được chuyển trực tiếp tới khách. Một số thiết bị,
chẳng hạn như bộ điều khiển mạng hoặc lưu trữ, hỗ trợ tính năng PCIe SR-IOV.
SR-IOV cho phép chia một thiết bị PCIe thành nhiều chức năng ảo,
sau đó có thể được chỉ định cho các khách khác nhau.

Mạng
----------

Đối với mạng có độ trễ thấp, ngăn xếp mạng đầy đủ có thể là điều không mong muốn, vì nó
có thể đưa ra các nguồn bổ sung gây chậm trễ. Trong bối cảnh này, XDP có thể được sử dụng
như một lối tắt để bỏ qua phần lớn ngăn xếp trong khi vẫn dựa vào kernel
trình điều khiển mạng.

Yêu cầu là trình điều khiển mạng phải hỗ trợ XDP- tốt nhất là sử dụng
một "skb pool" và ứng dụng phải sử dụng ổ cắm XDP. bổ sung
cấu hình có thể liên quan đến bộ lọc BPF, điều chỉnh hàng đợi mạng hoặc định cấu hình
qdiscs để truyền tải dựa trên thời gian. Những kỹ thuật này thường
được áp dụng trong môi trường Mạng nhạy cảm với thời gian (TSN).

Việc ghi lại tất cả các bước cần thiết vượt quá phạm vi của văn bản này. Để biết chi tiết
hướng dẫn, xem tài liệu TSN tại ZZ0000ZZ

Một tài nguyên hữu ích khác là Điểm kiểm tra giao tiếp thời gian thực của Linux
ZZ0000ZZ
Mục tiêu của dự án này là xác nhận giao tiếp mạng thời gian thực. Nó có thể
được coi là "kiểm tra chu kỳ" cho kết nối mạng và cũng đóng vai trò là bước khởi đầu
điểm phát triển ứng dụng.