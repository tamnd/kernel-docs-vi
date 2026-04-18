.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/RCU/UP.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. _up_doc:

RCU trên hệ thống bộ xử lý đơn
===========================

Một quan niệm sai lầm phổ biến là, trên các hệ thống UP, hàm nguyên thủy call_rcu()
có thể ngay lập tức gọi chức năng của nó.  Cơ sở của quan niệm sai lầm này
là vì chỉ có một CPU nên không cần thiết phải
đợi mọi việc khác được thực hiện vì không có CPU nào khác để thực hiện
bất cứ điều gì khác đang xảy ra.  Mặc dù cách tiếp cận này sẽ ZZ0000ZZ
làm việc trong một khoảng thời gian đáng ngạc nhiên, nói chung đó là một ý tưởng rất tồi.
Tài liệu này trình bày ba ví dụ chứng minh chính xác mức độ tồi tệ của
đây là một ý tưởng

Ví dụ 1: softirq Tự sát
--------------------------

Giả sử thuật toán dựa trên RCU quét danh sách liên kết có chứa
các phần tử A, B và C trong ngữ cảnh quy trình và có thể xóa các phần tử khỏi
danh sách tương tự này trong bối cảnh softirq.  Giả sử rằng việc quét bối cảnh quy trình
đang tham chiếu phần tử B khi nó bị gián đoạn bởi quá trình xử lý softirq,
xóa phần tử B và sau đó gọi call_rcu() để giải phóng phần tử B
sau một thời gian ân hạn.

Bây giờ, nếu call_rcu() gọi trực tiếp các đối số của nó thì khi quay lại
từ softirq, quá trình quét danh sách sẽ tự tham chiếu đến một thư mục mới được giải phóng
yếu tố B. Tình trạng này có thể làm giảm đáng kể tuổi thọ của
hạt nhân của bạn.

Vấn đề tương tự này có thể xảy ra nếu call_rcu() được gọi từ phần cứng
trình xử lý ngắt.

Ví dụ 2: Lỗi gọi hàm
---------------------------------

Tất nhiên, người ta có thể ngăn chặn vụ tự tử được mô tả trong ví dụ trước
bằng cách gọi call_rcu() trực tiếp chỉ khi nó được gọi
từ bối cảnh quá trình.  Tuy nhiên, điều này có thể thất bại theo cách tương tự.

Giả sử thuật toán dựa trên RCU quét lại danh sách liên kết có chứa
các phần tử A, B và C trong ngữ cảnh tiến trình, nhưng nó gọi một hàm
trên mỗi phần tử khi nó được quét.  Giả sử thêm rằng hàm này
xóa phần tử B khỏi danh sách, sau đó chuyển nó tới call_rcu() để trì hoãn
giải phóng.  Điều này có thể hơi khác thường nhưng nó hoàn toàn hợp pháp
Việc sử dụng RCU, vì call_rcu() phải đợi thời gian gia hạn trôi qua.
Vì vậy, trong trường hợp này, cho phép call_rcu() gọi ngay lập tức
lập luận của nó sẽ khiến nó không thể đưa ra sự đảm bảo cơ bản
RCU cơ bản, cụ thể là call_rcu() trì hoãn việc gọi các đối số của nó cho đến khi
tất cả các phần quan trọng phía đọc RCU hiện đang thực thi đã hoàn thành.

Câu đố nhanh #1:
	Tại sao ZZ0000ZZ gọi đồng bộ hóa_rcu() trong trường hợp này là hợp pháp?

ZZ0000ZZ

Ví dụ 3: Chết do bế tắc
----------------------------

Giả sử rằng call_rcu() được gọi trong khi đang giữ một khóa và
hàm gọi lại phải có cùng khóa này.  Trong trường hợp này, nếu
call_rcu() gọi trực tiếp lệnh gọi lại, kết quả sẽ
tự bế tắc ZZ0000ZZ lời gọi này xảy ra sau đó
call_rcu() gọi thời gian gia hạn đầy đủ sau đó.

Trong một số trường hợp, có thể cơ cấu lại mã để
call_rcu() bị trì hoãn cho đến khi khóa được giải phóng.  Tuy nhiên,
có những trường hợp điều này có thể khá xấu:

1. Nếu một số mục cần được chuyển tới call_rcu() trong
	cùng một phần quan trọng thì mã sẽ cần phải tạo
	một danh sách chúng, sau đó duyệt qua danh sách sau khi khóa được
	được thả ra.

2. Trong một số trường hợp, khóa sẽ được giữ trên một số kernel API,
	do đó việc trì hoãn call_rcu() cho đến khi khóa được giải phóng
	yêu cầu mục dữ liệu phải được chuyển qua API chung.
	Sẽ tốt hơn nhiều nếu đảm bảo rằng các cuộc gọi lại được gọi
	không có khóa nào ngoài việc phải sửa đổi các API đó để cho phép
	các mục dữ liệu tùy ý được truyền ngược lại qua chúng.

Nếu call_rcu() gọi trực tiếp lệnh gọi lại, các hạn chế về khóa sẽ gặp khó khăn
hoặc thay đổi API sẽ được yêu cầu.

Câu đố nhanh #2:
	Lệnh gọi lại RCU phải tôn trọng hạn chế khóa nào?

ZZ0000ZZ

Điều quan trọng cần lưu ý là không gian người dùng RCU triển khai ZZ0000ZZ
cho phép call_rcu() gọi trực tiếp các cuộc gọi lại, nhưng chỉ khi đầy đủ
thời gian gia hạn đã trôi qua kể từ khi những cuộc gọi lại đó được xếp hàng đợi.  Đây là
trường hợp này vì một số môi trường không gian người dùng cực kỳ hạn chế.
Tuy nhiên, những người viết triển khai RCU cho không gian người dùng rất quan tâm
được khuyến khích tránh gọi lại từ call_rcu(), do đó có được
những lợi ích tránh bế tắc đã nêu ở trên.

Bản tóm tắt
-------

Việc cho phép call_rcu() gọi ngay lập tức các đối số của nó sẽ phá vỡ RCU,
ngay cả trên hệ thống UP.  Vì vậy đừng làm điều đó!  Ngay cả trên hệ thống UP, RCU
cơ sở hạ tầng ZZ0000ZZ tôn trọng thời gian gia hạn và ZZ0001ZZ gọi lại lệnh gọi lại
từ một môi trường đã biết trong đó không có khóa nào được giữ.

Lưu ý rằng ZZ0000ZZ an toàn để đồng bộ hóa_rcu() quay trở lại ngay lập tức
Các hệ thống UP, bao gồm các bản dựng PREEMPT SMP chạy trên hệ thống UP.

Câu đố nhanh #3:
	Tại sao không thể sync_rcu() quay lại ngay trên hệ thống UP đang chạy
	RCU được ưu tiên trước?

.. _answer_quick_quiz_up:

Trả lời Câu đố nhanh #1:
	Tại sao ZZ0000ZZ gọi đồng bộ hóa_rcu() trong trường hợp này là hợp pháp?

Bởi vì chức năng gọi đang quét một liên kết được bảo vệ RCU
	danh sách và do đó nằm trong phần quan trọng bên đọc RCU.
	Do đó, hàm được gọi đã được gọi trong RCU
	phần quan trọng phía đọc và không được phép chặn.

Trả lời Câu đố nhanh #2:
	Lệnh gọi lại RCU phải tôn trọng hạn chế khóa nào?

Bất kỳ khóa nào có được trong lệnh gọi lại RCU đều phải được lấy
	ở nơi khác bằng cách sử dụng biến thể _bh của nguyên hàm spinlock.
	Ví dụ: nếu lệnh gọi lại RCU thu được "mylock" thì
	việc mua lại bối cảnh quy trình của khóa này phải sử dụng thứ gì đó
	như spin_lock_bh() để lấy khóa.  Xin lưu ý rằng
	Ví dụ: bạn cũng có thể sử dụng các biến thể _irq của spinlocks
	spin_lock_irqsave().

Nếu mã ngữ cảnh quy trình chỉ đơn giản là sử dụng spin_lock(),
	sau đó, vì lệnh gọi lại RCU có thể được gọi từ ngữ cảnh softirq,
	cuộc gọi lại có thể được gọi từ một softirq bị gián đoạn
	phần quan trọng của bối cảnh-quy trình.  Điều này sẽ dẫn đến
	tự bế tắc.

Hạn chế này có vẻ vô cớ vì rất ít RCU
	cuộc gọi lại có được khóa trực tiếp.  Tuy nhiên, rất nhiều RCU
	các cuộc gọi lại có được các khóa ZZ0000ZZ, chẳng hạn như thông qua
	nguyên thủy kfree().

Trả lời Câu đố nhanh #3:
	Tại sao không thể sync_rcu() quay lại ngay trên hệ thống UP
	chạy RCU ưu tiên?

Bởi vì một số nhiệm vụ khác có thể đã được ưu tiên ở giữa
	của phần quan trọng phía đọc RCU.  Nếu đồng bộ hóa_rcu()
	chỉ cần quay trở lại ngay lập tức, nó sẽ sớm báo hiệu
	kết thúc thời gian ân hạn, điều này sẽ là một cú sốc khó chịu đối với
	chủ đề khác đó khi nó bắt đầu chạy lại.
