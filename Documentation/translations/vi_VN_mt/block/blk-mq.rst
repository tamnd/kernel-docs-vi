.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/block/blk-mq.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

====================================================
Cơ chế xếp hàng IO khối nhiều hàng đợi (blk-mq)
====================================================

Cơ chế xếp hàng IO khối nhiều hàng đợi là API để cho phép lưu trữ nhanh
thiết bị để đạt được số lượng lớn hoạt động đầu vào/đầu ra mỗi giây (IOPS)
thông qua việc xếp hàng và gửi yêu cầu IO để chặn các thiết bị cùng một lúc,
được hưởng lợi từ tính song song được cung cấp bởi các thiết bị lưu trữ hiện đại.

Giới thiệu
============

Lý lịch
----------

Đĩa cứng từ tính đã trở thành tiêu chuẩn thực tế ngay từ đầu thế kỷ 20.
sự phát triển của hạt nhân. Hệ thống con Block IO nhằm đạt được hiệu quả tốt nhất
hiệu suất có thể có cho những thiết bị đó với mức phạt cao khi thực hiện ngẫu nhiên
truy cập và nút cổ chai là các bộ phận chuyển động cơ học, chậm hơn rất nhiều so với
bất kỳ lớp nào trên ngăn xếp lưu trữ. Một ví dụ về kỹ thuật tối ưu hóa như vậy
liên quan đến việc sắp xếp các yêu cầu đọc/ghi theo vị trí hiện tại của
đầu đĩa cứng.

Tuy nhiên, với sự phát triển của Ổ đĩa thể rắn và Bộ nhớ bất biến
không có bộ phận cơ khí cũng như không bị phạt truy cập ngẫu nhiên và có khả năng thực hiện
truy cập song song cao, nút cổ chai của ngăn xếp đã được di chuyển khỏi bộ lưu trữ
thiết bị vào hệ điều hành. Để tận dụng sự song song
trong thiết kế của các thiết bị đó, cơ chế nhiều hàng đợi đã được giới thiệu.

Thiết kế trước đây có một hàng đợi duy nhất để lưu trữ các yêu cầu IO khối bằng một
khóa. Điều đó không mở rộng tốt trong các hệ thống SMP do dữ liệu bẩn trong bộ đệm và
nút thắt của việc có một khóa duy nhất cho nhiều bộ xử lý. Thiết lập này cũng
bị tắc nghẽn khi các tiến trình khác nhau (hoặc cùng một tiến trình, di chuyển
tới các CPU khác nhau) muốn thực hiện khối IO. Thay vào đó, blk-mq API
sinh ra nhiều hàng đợi với các điểm vào riêng lẻ cục bộ của CPU, loại bỏ
sự cần thiết của một ổ khóa. Giải thích sâu hơn về cách thức hoạt động của tính năng này được đề cập trong phần
phần sau (ZZ0000ZZ).

Hoạt động
---------

Khi không gian người dùng thực hiện IO tới một thiết bị khối (đọc hoặc ghi tệp,
chẳng hạn), blk-mq sẽ thực hiện hành động: nó sẽ lưu trữ và quản lý các yêu cầu IO để
thiết bị khối, đóng vai trò là phần mềm trung gian giữa không gian người dùng (và tệp
hệ thống, nếu có) và trình điều khiển thiết bị khối.

blk-mq có hai nhóm hàng đợi: hàng đợi dàn phần mềm và hàng đợi phần cứng
hàng đợi. Khi yêu cầu đến lớp khối, nó sẽ thử thời gian ngắn nhất
đường dẫn có thể: gửi trực tiếp đến hàng đợi phần cứng. Tuy nhiên, có hai
trường hợp nó có thể không làm được điều đó: nếu có bộ lập lịch IO được đính kèm tại
lớp hoặc nếu chúng tôi muốn thử hợp nhất các yêu cầu. Trong cả hai trường hợp, các yêu cầu sẽ được
gửi đến hàng đợi phần mềm.

Sau đó, sau khi các yêu cầu được xử lý bởi hàng đợi phần mềm, chúng sẽ được đặt
tại hàng đợi phần cứng, hàng đợi giai đoạn thứ hai nơi phần cứng có quyền truy cập trực tiếp
để xử lý các yêu cầu đó. Tuy nhiên, nếu phần cứng không có đủ
tài nguyên để chấp nhận nhiều yêu cầu hơn, blk-mq sẽ tạm thời đặt yêu cầu
hàng đợi, sẽ được gửi trong tương lai, khi phần cứng có thể.

Hàng đợi dàn dựng phần mềm
~~~~~~~~~~~~~~~~~~~~~~~~~~

Hệ thống con khối IO thêm các yêu cầu vào hàng đợi dàn phần mềm
(đại diện bởi struct blk_mq_ctx) trong trường hợp chúng không được gửi
trực tiếp cho tài xế. Một yêu cầu là một hoặc nhiều BIO. Họ đã đến
lớp khối thông qua cấu trúc dữ liệu struct bio. Lớp khối
sau đó sẽ xây dựng một cấu trúc mới từ nó, yêu cầu cấu trúc sẽ
be used to communicate with the device driver. Mỗi hàng đợi có khóa riêng và
số lượng hàng đợi được xác định theo cơ sở mỗi CPU hoặc mỗi nút.

Hàng đợi dàn dựng có thể được sử dụng để hợp nhất các yêu cầu cho các khu vực lân cận. cho
Ví dụ: các yêu cầu dành cho khu vực 3-6, 6-7, 7-9 có thể trở thành một yêu cầu dành cho khu vực 3-9.
Ngay cả khi truy cập ngẫu nhiên vào SSD và NVM có cùng thời gian phản hồi so với
đối với truy cập tuần tự, các yêu cầu được nhóm để truy cập tuần tự sẽ làm giảm
số yêu cầu riêng lẻ. Kỹ thuật hợp nhất các yêu cầu này được gọi là
đang cắm.

Cùng với đó, các yêu cầu có thể được sắp xếp lại để đảm bảo tính công bằng của hệ thống
tài nguyên (ví dụ: để đảm bảo rằng không có ứng dụng nào bị thiếu) và/hoặc
cải thiện hiệu suất IO bằng bộ lập lịch IO.

Bộ lập lịch IO
^^^^^^^^^^^^^^

Có một số bộ lập lịch được triển khai bởi lớp khối, mỗi bộ theo sau
một heuristic để cải thiện hiệu suất IO. Chúng "có thể cắm được" (như trong phích cắm
và chơi), theo nghĩa là chúng có thể được chọn trong thời gian chạy bằng cách sử dụng sysfs. bạn
có thể đọc thêm về bộ lập lịch IO ZZ0000ZZ của Linux. Việc lập kế hoạch
chỉ xảy ra giữa các yêu cầu trong cùng một hàng đợi, do đó không thể hợp nhất
các yêu cầu từ các hàng đợi khác nhau, nếu không sẽ có việc dọn rác bộ đệm và
cần phải có một khóa cho mỗi hàng đợi. Sau khi lập kế hoạch, các yêu cầu sẽ được
đủ điều kiện để được gửi đến phần cứng. Một trong những bộ lập lịch có thể được
được chọn là bộ lập lịch NONE, bộ lập lịch đơn giản nhất. Nó sẽ chỉ
đặt yêu cầu lên bất kỳ hàng đợi phần mềm nào mà quy trình đang chạy mà không cần
bất kỳ sự sắp xếp lại nào. Khi thiết bị bắt đầu xử lý các yêu cầu trong phần cứng
hàng đợi (còn gọi là chạy hàng đợi phần cứng), hàng đợi phần mềm được ánh xạ tới đó
hàng đợi phần cứng sẽ được thoát theo trình tự theo ánh xạ của chúng.

Hàng đợi gửi phần cứng
~~~~~~~~~~~~~~~~~~~~~~~~

Hàng đợi phần cứng (được biểu thị bằng struct blk_mq_hw_ctx) là một cấu trúc
được trình điều khiển thiết bị sử dụng để ánh xạ hàng đợi gửi thiết bị (hoặc vòng DMA của thiết bị
bộ đệm) và là bước cuối cùng của mã gửi lớp khối trước khi
trình điều khiển thiết bị cấp thấp nắm quyền sở hữu yêu cầu. Để chạy hàng đợi này,
Lớp khối loại bỏ các yêu cầu khỏi hàng đợi phần mềm liên quan và cố gắng
gửi đến phần cứng.

Nếu không thể gửi yêu cầu trực tiếp tới phần cứng, chúng sẽ
được thêm vào danh sách liên kết (ZZ0000ZZ) của các yêu cầu. Sau đó,
lần tới khi lớp khối chạy hàng đợi, nó sẽ gửi các yêu cầu đặt tại
Danh sách ZZ0001ZZ đầu tiên, để đảm bảo việc gửi đi công bằng với những người đó
các yêu cầu đã sẵn sàng để được gửi trước tiên. Số lượng hàng đợi phần cứng
phụ thuộc vào số lượng bối cảnh phần cứng được phần cứng hỗ trợ và
trình điều khiển thiết bị, nhưng nó sẽ không nhiều hơn số lõi của hệ thống.
Không có sự sắp xếp lại ở giai đoạn này và mỗi hàng đợi phần mềm có một bộ
hàng đợi phần cứng để gửi yêu cầu.

.. note::

        Neither the block layer nor the device protocols guarantee
        the order of completion of requests. This must be handled by
        higher layers, like the filesystem.

Hoàn thành dựa trên thẻ
~~~~~~~~~~~~~~~~~~~~~~~

Để chỉ ra yêu cầu nào đã được hoàn thành, mọi yêu cầu đều được
được xác định bởi một số nguyên, nằm trong khoảng từ 0 đến kích thước hàng đợi gửi đi. Thẻ này
được tạo bởi lớp khối và sau đó được trình điều khiển thiết bị sử dụng lại, loại bỏ
sự cần thiết phải tạo ra một định danh dư thừa. Khi một yêu cầu được hoàn thành trong
trình điều khiển, thẻ được gửi trở lại lớp khối để thông báo về việc hoàn thiện.
Điều này loại bỏ sự cần thiết phải thực hiện tìm kiếm tuyến tính để tìm ra IO nào đã được
hoàn thành.

Đọc thêm
---------------

-ZZ0000ZZ

-ZZ0000ZZ

-ZZ0000ZZ

Tài liệu mã nguồn
=========================

.. kernel-doc:: include/linux/blk-mq.h

.. kernel-doc:: block/blk-mq.c