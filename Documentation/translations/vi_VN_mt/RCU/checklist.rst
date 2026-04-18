.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/RCU/checklist.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=============================================
Xem lại danh sách kiểm tra cho các bản vá RCU
=============================================


Tài liệu này chứa một danh sách kiểm tra để sản xuất và xem xét các bản vá
sử dụng RCU.  Vi phạm bất kỳ quy tắc nào được liệt kê dưới đây sẽ
dẫn đến các loại vấn đề tương tự như việc loại bỏ một khóa nguyên thủy
sẽ gây ra.  Danh sách này dựa trên kinh nghiệm xem xét các bản vá như vậy
trong một khoảng thời gian khá dài, nhưng những cải tiến luôn được hoan nghênh!

0. RCU có đang được áp dụng cho tình huống đọc chủ yếu không?  Nếu dữ liệu
	cấu trúc được cập nhật hơn khoảng 10% thời gian, thì bạn
	nên cân nhắc kỹ lưỡng một số cách tiếp cận khác, trừ khi được nêu chi tiết
	các phép đo hiệu suất cho thấy RCU dù sao cũng đúng
	công cụ cho công việc.  Có, RCU giảm chi phí bên đọc xuống bằng
	tăng chi phí bên ghi, đó chính xác là lý do tại sao việc sử dụng bình thường
	của RCU sẽ đọc nhiều hơn là cập nhật.

Một ngoại lệ khác là hiệu suất không phải là vấn đề và RCU
	cung cấp một thực hiện đơn giản hơn.  Một ví dụ về tình huống này
	là mã NMI động trong nhân Linux 2.6, ít nhất là trên
	kiến trúc nơi NMI rất hiếm.

Tuy nhiên, một ngoại lệ khác là độ trễ thời gian thực thấp của RCU
	nguyên thủy phía đọc là cực kỳ quan trọng.

Một ngoại lệ cuối cùng là nơi sử dụng đầu đọc RCU để ngăn chặn
	sự cố ABA (ZZ0000ZZ
	để cập nhật không khóa.  Điều này dẫn đến tình trạng nhẹ
	tình huống phản trực giác trong đó rcu_read_lock() và
	rcu_read_unlock() được sử dụng để bảo vệ các bản cập nhật, tuy nhiên, điều này
	Cách tiếp cận này có thể mang lại sự đơn giản hóa tương tự cho một số loại
	thuật toán không khóa mà người thu gom rác thực hiện.

1. Mã cập nhật có loại trừ lẫn nhau thích hợp không?

RCU cho phép ZZ0000ZZ chạy (gần như) trần, nhưng ZZ0001ZZ thì phải
	vẫn sử dụng một số loại loại trừ lẫn nhau, chẳng hạn như:

Một.	khóa,
	b.	hoạt động nguyên tử, hoặc
	c.	hạn chế cập nhật cho một nhiệm vụ duy nhất.

Nếu bạn chọn #b, hãy chuẩn bị mô tả cách bạn đã xử lý
	rào cản bộ nhớ trên các máy có thứ tự yếu (gần như tất cả
	chúng -- thậm chí x86 còn cho phép các lần tải sau được sắp xếp lại trước
	các cửa hàng trước đó) và sẵn sàng giải thích lý do tại sao điều này được thêm vào
	sự phức tạp là đáng giá.  Nếu bạn chọn #c, hãy chuẩn bị sẵn sàng
	giải thích làm thế nào nhiệm vụ đơn lẻ này không trở thành nút thắt cổ chai lớn
	trên các hệ thống lớn (ví dụ: nếu tác vụ đang cập nhật thông tin
	liên quan đến chính nó mà các tác vụ khác có thể đọc được, theo định nghĩa
	không thể có nút thắt cổ chai).	Lưu ý rằng định nghĩa của "lớn" có
	đã thay đổi đáng kể: Tám CPU là "lớn" vào năm 2000,
	nhưng một trăm CPU không có gì đáng chú ý trong năm 2017.

2. Các phần quan trọng bên đọc của RCU có sử dụng đúng cách không?
	rcu_read_lock() và bạn bè?  Những nguyên thủy này là cần thiết
	để tránh việc thời gian ân hạn kết thúc sớm, điều này
	có thể dẫn đến việc dữ liệu được giải phóng khỏi
	dưới mã phía đọc của bạn, điều này có thể làm tăng đáng kể
	rủi ro tính toán của hạt nhân của bạn.

Theo nguyên tắc chung, bất kỳ sự coi thường nào đối với thiết bị được bảo vệ RCU
	con trỏ phải được bao phủ bởi rcu_read_lock(), rcu_read_lock_bh(),
	rcu_read_lock_sched() hoặc bằng khóa bên cập nhật thích hợp.
	Vô hiệu hóa rõ ràng quyền ưu tiên (ví dụ: preempt_disable())
	có thể phục vụ như rcu_read_lock_sched(), nhưng khó đọc hơn và
	ngăn chặn lockdep phát hiện các vấn đề về khóa.  Có được một
	spinlock thô cũng đi vào phần quan trọng bên đọc RCU.

Các hàm nguyên hàm Guard(rcu)() vàscoped_guard(rcu) chỉ định
	phần còn lại của phạm vi hiện tại hoặc tuyên bố tiếp theo,
	tương ứng, là phần quan trọng phía đọc RCU.  Sử dụng
	những bộ bảo vệ này có thể ít xảy ra lỗi hơn rcu_read_lock(),
	rcu_read_unlock() và những người bạn.

Xin lưu ý rằng ZZ0000ZZ của bạn dựa vào mã đã biết được xây dựng
	chỉ trong các hạt nhân không được ưu tiên.  Mã như vậy có thể và sẽ bị hỏng,
	đặc biệt là trong các hạt nhân được xây dựng bằng CONFIG_PREEMPT_COUNT=y.

Để con trỏ được bảo vệ RCU "rò rỉ" ra khỏi mặt đọc RCU
	phần quan trọng cũng tệ như để chúng rò rỉ ra ngoài
	từ dưới ổ khóa.  Tất nhiên trừ khi bạn đã sắp xếp một số
	các phương tiện bảo vệ khác, chẳng hạn như khóa hoặc số tham chiếu
	ZZ0000ZZ cho phép họ thoát khỏi phần quan trọng bên đọc RCU.

3. Mã cập nhật có cho phép truy cập đồng thời không?

Toàn bộ quan điểm của RCU là cho phép người đọc chạy mà không cần
	bất kỳ khóa hoặc hoạt động nguyên tử.  Điều này có nghĩa là người đọc sẽ
	đang chạy trong khi cập nhật đang được tiến hành.  Có một số
	các cách để xử lý sự tương tranh này, tùy thuộc vào tình huống:

Một.	Sử dụng các biến thể RCU của danh sách và cập nhật hlist
		nguyên thủy để thêm, xóa và thay thế các phần tử trên
		danh sách được bảo vệ RCU.	Ngoài ra, hãy sử dụng cái khác
		Cấu trúc dữ liệu được bảo vệ RCU đã được thêm vào
		nhân Linux.

Đây hầu như luôn là cách tiếp cận tốt nhất.

b.	Tiến hành như trong (a) ở trên, nhưng cũng duy trì từng phần tử
		khóa (được cả người đọc và người viết mua lại)
		trạng thái bảo vệ cho mỗi phần tử đó.  Các lĩnh vực mà người đọc
		không được truy cập có thể được bảo vệ bằng một số khóa khác
		chỉ được mua bởi những người cập nhật, nếu muốn.

Điều này cũng hoạt động khá tốt.

c.	Làm cho các cập nhật xuất hiện nguyên tử đối với người đọc.	Ví dụ,
		cập nhật con trỏ tới các trường được căn chỉnh chính xác sẽ
		xuất hiện nguyên tử, cũng như các nguyên thủy nguyên tử riêng lẻ.
		Trình tự các hoạt động được thực hiện dưới một khóa sẽ ZZ0000ZZ
		dường như là nguyên tử đối với độc giả RCU, cũng như các chuỗi
		của nhiều nguyên tử nguyên thủy.	Một cách thay thế là
		di chuyển nhiều trường riêng lẻ sang một cấu trúc riêng biệt,
		do đó giải quyết vấn đề đa trường bằng cách áp đặt một
		mức độ gián tiếp bổ sung.

Việc này có thể hiệu quả nhưng đang bắt đầu gặp một chút khó khăn.

d.	Sắp xếp cẩn thận các bản cập nhật và các bài đọc để người đọc
		xem dữ liệu hợp lệ ở tất cả các giai đoạn cập nhật.  Điều này thường xuyên
		khó khăn hơn ta tưởng, đặc biệt là trong bối cảnh hiện đại
		Xu hướng sắp xếp lại các tham chiếu bộ nhớ của CPU.  Người ta phải
		thường tự do thực hiện các thao tác sắp xếp bộ nhớ
		thông qua mã, gây khó khăn cho việc hiểu và
		để kiểm tra.  Nó hoạt động ở đâu, tốt hơn là sử dụng mọi thứ
		như smp_store_release() và smp_load_acquire(), nhưng trong
		một số trường hợp cần có rào cản bộ nhớ đầy đủ smp_mb().

Như đã lưu ý trước đó, tốt hơn là nên nhóm các
		thay đổi dữ liệu thành một cấu trúc riêng biệt, do đó
		thay đổi có thể được thực hiện để xuất hiện nguyên tử bằng cách cập nhật một con trỏ
		để tham chiếu một cấu trúc mới chứa các giá trị được cập nhật.

4. CPU có thứ tự yếu đặt ra những thách thức đặc biệt.  Hầu như tất cả các CPU
	được sắp xếp yếu -- ngay cả CPU x86 cũng cho phép tải sau này
	được sắp xếp lại để đi trước các cửa hàng trước đó.  Mã RCU phải có tất cả
	các biện pháp sau đây để ngăn chặn vấn đề hỏng bộ nhớ:

Một.	Người đọc phải duy trì trật tự hợp lý của bộ nhớ của họ
		truy cập.  Nguyên hàm rcu_dereference() đảm bảo rằng
		CPU lấy con trỏ trước khi lấy dữ liệu
		mà con trỏ trỏ tới.  Điều này thực sự cần thiết
		trên CPU Alpha.

Nguyên hàm rcu_dereference() cũng là một cách tuyệt vời
		hỗ trợ tài liệu, cho phép người đọc
		mã biết chính xác con trỏ nào được RCU bảo vệ.
		Xin lưu ý rằng trình biên dịch cũng có thể sắp xếp lại mã và
		họ ngày càng trở nên hung hăng trong việc làm
		chỉ thế thôi.  Do đó, nguyên hàm rcu_dereference() cũng
		ngăn chặn tối ưu hóa trình biên dịch phá hoại.  Tuy nhiên,
		với một chút sáng tạo lệch lạc, bạn có thể
		xử lý sai giá trị trả về từ rcu_dereference().
		Vui lòng xem rcu_dereference.rst để biết thêm thông tin.

Nguyên hàm rcu_dereference() được sử dụng bởi
		các kiểu nguyên thủy truyền tải danh sách "_rcu()" khác nhau, chẳng hạn như
		dưới dạng list_for_each_entry_rcu().  Lưu ý rằng nó là
		hoàn toàn hợp pháp (nếu dư thừa) đối với mã bên cập nhật
		sử dụng rcu_dereference() và truyền tải danh sách "_rcu()"
		nguyên thủy.  Điều này đặc biệt hữu ích trong mã
		là phổ biến đối với người đọc và người cập nhật.  Tuy nhiên, lockdep
		sẽ phàn nàn nếu bạn truy cập rcu_dereference() bên ngoài
		của phần quan trọng phía đọc RCU.  Xem lockdep.rst
		để tìm hiểu phải làm gì về điều này.

Tất nhiên, cả rcu_dereference() lẫn "_rcu()" đều không
		nguyên thủy truyền tải danh sách có thể thay thế cho một điều tốt
		thiết kế đồng thời phối hợp giữa nhiều trình cập nhật.

b.	Nếu macro danh sách đang được sử dụng, list_add_tail_rcu()
		và các nguyên hàm list_add_rcu() phải được sử dụng theo thứ tự
		để ngăn chặn các máy được đặt hàng yếu không bị sắp xếp sai
		khởi tạo cấu trúc và trồng con trỏ.
		Tương tự, nếu macro hlist đang được sử dụng,
		hlist_add_head_rcu() là bắt buộc.

c.	Nếu macro danh sách đang được sử dụng, list_del_rcu()
		nguyên thủy phải được sử dụng để giữ con trỏ của list_del()
		ngộ độc do gây ra tác dụng độc hại đồng thời
		độc giả.  Tương tự, nếu macro hlist đang được sử dụng,
		bắt buộc phải có nguyên hàm hlist_del_rcu().

Các nguyên hàm list_replace_rcu() và hlist_replace_rcu()
		có thể được sử dụng để thay thế cấu trúc cũ bằng cấu trúc mới
		trong các loại danh sách được bảo vệ RCU tương ứng của chúng.

d.	Các quy tắc tương tự như (4b) và (4c) áp dụng cho "hlist_nulls"
		loại danh sách liên kết được bảo vệ bởi RCU.

đ.	Các bản cập nhật phải đảm bảo rằng việc khởi tạo một
		cấu trúc xảy ra trước các con trỏ tới cấu trúc đó
		được công bố rộng rãi.  Sử dụng nguyên hàm rcu_sign_pointer()
		khi công khai một con trỏ tới một cấu trúc có thể
		được duyệt qua phần quan trọng phía đọc RCU.

5. Nếu bất kỳ call_rcu(), call_srcu(), call_rcu_tasks(), hoặc
	call_rcu_tasks_trace() được sử dụng, chức năng gọi lại có thể
	được gọi từ bối cảnh softirq và trong mọi trường hợp có nửa dưới
	bị vô hiệu hóa.  Đặc biệt, chức năng gọi lại này không thể chặn.
	Nếu bạn cần chặn lệnh gọi lại, hãy chạy mã đó trong hàng đợi công việc
	trình xử lý được lên lịch từ cuộc gọi lại.  queue_rcu_work()
	thực hiện điều này cho bạn trong trường hợp call_rcu().

6. Vì sync_rcu() có thể chặn nên không thể gọi được
	từ bất kỳ loại bối cảnh irq nào.  Quy tắc tương tự được áp dụng
	cho đồng bộ hóa_srcu(), đồng bộ hóa_rcu_expedited(),
	đồng bộ hóa_srcu_expedited(), đồng bộ hóa_rcu_tasks(),
	đồng bộ hóa_rcu_tasks_rude() và đồng bộ hóa_rcu_tasks_trace().

Các dạng cấp tốc của những dạng nguyên thủy này có cùng ngữ nghĩa
	như các hình thức không cấp tốc, nhưng cấp tốc thì chuyên sâu hơn CPU.
	Việc sử dụng các bản gốc cấp tốc nên được hạn chế ở mức hiếm
	các hoạt động thay đổi cấu hình thường không được thực hiện
	được thực hiện trong khi khối lượng công việc thời gian thực đang chạy.  Lưu ý rằng
	Khối lượng công việc thời gian thực nhạy cảm với IPI có thể sử dụng rcupdate.rcu_normal
	tham số khởi động kernel để vô hiệu hóa hoàn toàn ân hạn nhanh
	thời gian, mặc dù điều này có thể có tác động đến hiệu suất.

Đặc biệt, nếu bạn thấy mình đang viện dẫn một trong những giải pháp cấp tốc
	nguyên thủy lặp đi lặp lại trong một vòng lặp, xin vui lòng giúp đỡ mọi người:
	Cơ cấu lại mã của bạn để nó cập nhật theo đợt, cho phép
	một nguyên thủy không cấp tốc duy nhất để bao gồm toàn bộ lô.
	Điều này rất có thể sẽ nhanh hơn vòng lặp chứa
	nhanh chóng và phần còn lại sẽ dễ dàng hơn nhiều
	của hệ thống, đặc biệt là khối lượng công việc thời gian thực chạy trên
	phần còn lại của hệ thống.  Ngoài ra, thay vào đó hãy sử dụng không đồng bộ
	nguyên thủy như call_rcu().

7. Kể từ v4.20, một hạt nhân nhất định chỉ triển khai một hương vị RCU, đó là
	là RCU được lập lịch cho PREEMPTION=n và RCU được ưu tiên cho PREEMPTION=y.
	Nếu trình cập nhật sử dụng call_rcu() hoặc sync_rcu() thì
	người đọc tương ứng có thể sử dụng: (1) rcu_read_lock() và
	rcu_read_unlock(), (2) bất kỳ cặp nguyên thủy nào vô hiệu hóa
	và kích hoạt lại softirq, ví dụ: rcu_read_lock_bh() và
	rcu_read_unlock_bh() hoặc (3) bất kỳ cặp nguyên thủy nào vô hiệu hóa
	và kích hoạt lại quyền ưu tiên, ví dụ: rcu_read_lock_sched() và
	rcu_read_unlock_sched().  Nếu trình cập nhật sử dụng sync_srcu()
	hoặc call_srcu() thì trình đọc tương ứng phải sử dụng
	srcu_read_lock() và srcu_read_unlock(), và tương tự
	srcu_struct.  Các quy tắc dành cho thời gian chờ gia hạn RCU cấp tốc
	nguyên thủy cũng giống như đối với các đối tác không cấp tốc của chúng.

Tương tự, cần sử dụng đúng các hương vị Nhiệm vụ RCU:

Một.	Nếu trình cập nhật sử dụng sync_rcu_tasks() hoặc
		call_rcu_tasks() thì người đọc phải hạn chế
		thực hiện chuyển đổi bối cảnh tự nguyện, nghĩa là từ
		chặn.

b.	Nếu trình cập nhật sử dụng call_rcu_tasks_trace()
		hoặc sync_rcu_tasks_trace(), thì
		độc giả tương ứng phải sử dụng rcu_read_lock_trace()
		và rcu_read_unlock_trace().

c.	Nếu trình cập nhật sử dụng sync_rcu_tasks_rude(),
		thì những độc giả tương ứng phải sử dụng bất cứ thứ gì
		vô hiệu hóa quyền ưu tiên, ví dụ: preempt_disable()
		và preempt_enable().

Trộn lẫn mọi thứ sẽ dẫn đến sự nhầm lẫn và hạt nhân bị hỏng, và
	thậm chí đã dẫn đến một vấn đề bảo mật có thể khai thác được.  Vì vậy,
	khi sử dụng các cặp nguyên thủy không rõ ràng, việc bình luận là
	tất nhiên là phải.  Một ví dụ về ghép đôi không rõ ràng là
	tính năng XDP trong mạng, gọi các chương trình BPF từ
	bối cảnh trình điều khiển mạng NAPI (softirq).	BPF phụ thuộc rất nhiều vào RCU
	bảo vệ cấu trúc dữ liệu của nó, nhưng vì chương trình BPF
	việc gọi xảy ra hoàn toàn trong một local_bh_disable()
	trong chu kỳ thăm dò NAPI, cách sử dụng này là an toàn.  Lý do
	rằng cách sử dụng này an toàn là người đọc có thể sử dụng bất cứ thứ gì
	tắt BH khi trình cập nhật sử dụng call_rcu() hoặc sync_rcu().

8. Mặc dù sync_rcu() chậm hơn call_rcu(),
	nó thường dẫn đến mã đơn giản hơn.  Vì vậy, trừ khi cập nhật
	hiệu suất là cực kỳ quan trọng, các trình cập nhật không thể chặn,
	hoặc độ trễ của sync_rcu() hiển thị từ không gian người dùng,
	nên sử dụng sync_rcu() thay vì call_rcu().
	Hơn nữa, kfree_rcu() và kvfree_rcu() thường cho kết quả
	trong mã thậm chí còn đơn giản hơn so với sync_rcu() mà không có
	độ trễ nhiều mili giây của sync_rcu().	Vì vậy xin vui lòng lấy
	lợi thế của "lửa và quên" của kfree_rcu() và kvfree_rcu()
	khả năng giải phóng bộ nhớ khi áp dụng.

Một thuộc tính đặc biệt quan trọng của sync_rcu()
	nguyên thủy là nó tự động tự giới hạn: nếu thời gian ân hạn
	bị trì hoãn vì bất kỳ lý do gì, thì sync_rcu()
	nguyên thủy sẽ trì hoãn cập nhật tương ứng.  Ngược lại,
	mã sử dụng call_rcu() sẽ hạn chế rõ ràng tốc độ cập nhật trong
	trường hợp thời gian ân hạn bị trì hoãn, nếu không làm như vậy có thể
	dẫn đến độ trễ thời gian thực quá mức hoặc thậm chí là tình trạng OOM.

Các cách để đạt được thuộc tính tự giới hạn này khi sử dụng call_rcu(),
	kfree_rcu() hoặc kvfree_rcu() bao gồm:

Một.	Giữ số lượng phần tử cấu trúc dữ liệu
		được sử dụng bởi cấu trúc dữ liệu được bảo vệ RCU, bao gồm
		những người đang chờ thời gian ân hạn trôi qua.  Thực thi một
		giới hạn về số lượng này, tạm dừng cập nhật khi cần thiết để cho phép
		giải phóng bị trì hoãn trước đó để hoàn thành.	Ngoài ra,
		chỉ giới hạn số lượng chờ trả chậm chứ không phải
		tổng số phần tử.

Một cách để trì hoãn các bản cập nhật là có được phía cập nhật
		mutex.	(Đừng thử điều này với khóa xoay -- các CPU khác
		quay trên khóa có thể ngăn chặn thời gian gia hạn
		không bao giờ kết thúc.) Một cách khác để trì hoãn việc cập nhật
		dành cho các bản cập nhật sử dụng chức năng bao bọc xung quanh
		bộ cấp phát bộ nhớ để chức năng bao bọc này
		mô phỏng OOM khi có quá nhiều bộ nhớ đang chờ
		Thời gian gia hạn RCU.  Tất nhiên là có nhiều thứ khác
		các biến thể về chủ đề này.

b.	Hạn chế tốc độ cập nhật.  Ví dụ: nếu cập nhật chỉ xảy ra
		một lần mỗi giờ thì không có giới hạn tốc độ rõ ràng
		được yêu cầu, trừ khi hệ thống của bạn đã bị hỏng nặng.
		Các phiên bản cũ hơn của hệ thống con dcache áp dụng phương pháp này,
		bảo vệ các bản cập nhật bằng khóa toàn cầu, hạn chế tốc độ của chúng.

c.	Cập nhật đáng tin cậy -- nếu việc cập nhật chỉ có thể được thực hiện thủ công bởi
		superuser hoặc một số người dùng đáng tin cậy khác thì có thể không
		cần thiết phải tự động giới hạn chúng.  Lý thuyết
		đây là siêu người dùng đã có rất nhiều cách để gặp sự cố
		cái máy.

d.	Định kỳ gọi rcu_barrier(), cho phép một giới hạn
		số lượng cập nhật trong mỗi thời gian gia hạn.

Các cảnh báo tương tự cũng áp dụng cho call_srcu(), call_rcu_tasks() và
	call_rcu_tasks_trace().  Đây là lý do tại sao có srcu_barrier(),
	rcu_barrier_tasks() và rcu_barrier_tasks_trace() tương ứng.

Lưu ý rằng mặc dù những người nguyên thủy này thực hiện hành động để tránh
	cạn kiệt bộ nhớ khi bất kỳ CPU nào có quá nhiều lệnh gọi lại,
	người dùng hoặc quản trị viên đã xác định vẫn có thể làm cạn kiệt bộ nhớ.
	Điều này đặc biệt xảy ra nếu một hệ thống có số lượng lớn
	CPU đã được cấu hình để giảm tải tất cả lệnh gọi lại RCU của nó lên
	một CPU duy nhất hoặc nếu hệ thống có tương đối ít bộ nhớ trống.

9. Tất cả các nguyên hàm truyền tải danh sách RCU, bao gồm
	rcu_dereference(), list_for_each_entry_rcu() và
	list_for_each_safe_rcu(), phải nằm trong RCU phía đọc
	phần quan trọng hoặc phải được bảo vệ bởi bên cập nhật thích hợp
	ổ khóa.	Các phần quan trọng phía đọc RCU được phân cách bởi
	rcu_read_lock() và rcu_read_unlock() hoặc bằng các nguyên hàm tương tự
	chẳng hạn như rcu_read_lock_bh() và rcu_read_unlock_bh(), trong đó
	trường hợp phải sử dụng nguyên hàm rcu_dereference() phù hợp trong
	để giữ cho lockdep vui vẻ, trong trường hợp này là rcu_dereference_bh().

Lý do được phép sử dụng tính năng truyền tải danh sách RCU
	nguyên thủy khi khóa bên cập nhật được giữ là làm như vậy
	có thể khá hữu ích trong việc giảm sự phình to của mã khi mã chung
	được chia sẻ giữa người đọc và người cập nhật.  Nguyên thủy bổ sung
	được cung cấp cho trường hợp này, như đã thảo luận trong lockdep.rst.

Một ngoại lệ cho quy tắc này là khi dữ liệu chỉ được thêm vào
	cấu trúc dữ liệu được liên kết và không bao giờ bị xóa trong bất kỳ
	thời gian mà độc giả có thể truy cập vào cấu trúc đó.  Trong đó
	trường hợp, READ_ONCE() có thể được sử dụng thay cho rcu_dereference()
	và các điểm đánh dấu bên đọc (rcu_read_lock() và rcu_read_unlock(),
	chẳng hạn) có thể được bỏ qua.

10. Ngược lại, nếu bạn đang ở trong phần quan trọng bên đọc RCU,
	và bạn không giữ khóa bên cập nhật thích hợp, bạn ZZ0000ZZ
	sử dụng các biến thể "_rcu()" của macro danh sách.  Không làm được như vậy
	sẽ phá vỡ Alpha, khiến các trình biên dịch phức tạp tạo ra mã xấu,
	và gây nhầm lẫn cho những người đang cố gắng hiểu mã của bạn.

11. Bất kỳ khóa nào có được bằng lệnh gọi lại RCU phải được lấy ở nơi khác
	với softirq bị vô hiệu hóa, ví dụ: thông qua spin_lock_bh().  Không thể
	vô hiệu hóa softirq khi mua lại khóa đó sẽ dẫn đến
	bế tắc ngay khi trình xử lý softirq RCU chạy
	cuộc gọi lại RCU của bạn trong khi làm gián đoạn quá trình quan trọng của hoạt động thu nạp đó
	phần.

12. Lệnh gọi lại RCU có thể và được thực thi song song.  Trong nhiều trường hợp,
	mã gọi lại chỉ đơn giản là bao bọc xung quanh kfree(), do đó
	không phải là một vấn đề (hay chính xác hơn là trong phạm vi nó
	có vấn đề thì khóa cấp phát bộ nhớ sẽ xử lý vấn đề đó).  Tuy nhiên,
	nếu các cuộc gọi lại thao tác cấu trúc dữ liệu được chia sẻ, chúng
	phải sử dụng bất kỳ khóa hoặc đồng bộ hóa nào khác được yêu cầu
	để truy cập và/hoặc sửa đổi cấu trúc dữ liệu đó một cách an toàn.

Đừng cho rằng lệnh gọi lại RCU sẽ được thực thi trên cùng một
	CPU đã thực thi call_rcu(), call_srcu() tương ứng,
	call_rcu_tasks() hoặc call_rcu_tasks_trace().  Ví dụ, nếu
	một CPU nhất định sẽ ngoại tuyến trong khi đang chờ gọi lại RCU,
	thì lệnh gọi lại RCU đó sẽ thực thi trên một số CPU còn sót lại.
	(Nếu không phải như vậy, lệnh gọi lại RCU tự sinh sản sẽ
	ngăn chặn nạn nhân CPU ngoại tuyến.) Hơn nữa,
	Các CPU được chỉ định bởi rcu_nocbs= có thể ZZ0000ZZ có
	Trên thực tế, các cuộc gọi lại RCU được thực thi trên một số CPU khác đối với một số CPU
	khối lượng công việc theo thời gian thực, đây chính là mục đích chung của việc sử dụng
	rcu_nocbs=tham số khởi động kernel.

Ngoài ra, đừng cho rằng các cuộc gọi lại được xếp hàng theo một thứ tự nhất định
	sẽ được gọi theo thứ tự đó, ngay cả khi tất cả chúng đều được xếp hàng đợi trên
	cùng CPU.  Hơn nữa, đừng cho rằng các cuộc gọi lại cùng-CPU sẽ
	được gọi một cách tuần tự.  Ví dụ, trong các kernel gần đây, CPU có thể
	chuyển đổi giữa lời gọi gọi lại đã giảm tải và đã giảm tải,
	và trong khi một CPU nhất định đang trải qua quá trình chuyển đổi như vậy, các lệnh gọi lại của nó
	có thể được gọi đồng thời bởi trình xử lý softirq của CPU đó và
	rcuo kthread của CPU đó.  Vào những lúc như vậy, lệnh gọi lại của CPU
	có thể được thực hiện đồng thời và không theo thứ tự.

13. Không giống như hầu hết các phiên bản của RCU, ZZ0000ZZ được phép chặn trong một
	Phần quan trọng phía đọc SRCU (được đánh dấu bởi srcu_read_lock()
	và srcu_read_unlock()), do đó có "SRCU": "RCU có thể ngủ được".
	Giống như RCU, các biểu mẫu Guard(srcu)() vàscoped_guard(srcu) là
	có sẵn và thường mang lại sự dễ sử dụng hơn.  Xin lưu ý
	rằng nếu bạn không cần ngủ trong các phần quan trọng bên đọc,
	bạn nên sử dụng RCU thay vì SRCU, vì RCU gần như
	luôn nhanh hơn và dễ sử dụng hơn SRCU.

Cũng không giống như các dạng RCU khác, việc khởi tạo rõ ràng
	và cần phải dọn dẹp tại thời điểm xây dựng thông qua
	DEFINE_SRCU(), DEFINE_STATIC_SRCU(), DEFINE_SRCU_FAST(),
	hoặc DEFINE_STATIC_SRCU_FAST() hoặc trong thời gian chạy thông qua một trong hai
	init_srcu_struct() hoặc init_srcu_struct_fast() và
	dọn dẹp_srcu_struct().	Ba cái cuối cùng này được thông qua một
	ZZ0000ZZ xác định phạm vi của một
	Tên miền SRCU.  Sau khi được khởi tạo, srcu_struct được chuyển
	tới srcu_read_lock(), srcu_read_unlock() đồng bộ hóa_srcu(),
	đồng bộ hóa_srcu_expedited() và call_srcu().	Một nhất định
	đồng bộ hóa_srcu() chỉ chờ SRCU quan trọng phía đọc
	các phần được quản lý bởi srcu_read_lock() và srcu_read_unlock()
	các lệnh gọi đã được chuyển qua cùng một srcu_struct.  Tài sản này
	là điều khiến các phần quan trọng ở phía đọc đang ngủ có thể chấp nhận được --
	một hệ thống con nhất định chỉ trì hoãn các cập nhật của chính nó chứ không phải các cập nhật của hệ thống con khác
	hệ thống con sử dụng SRCU.	Do đó, SRCU ít bị OOM hơn
	hệ thống hơn RCU sẽ như thế nào nếu các phần quan trọng phía đọc của RCU
	được phép ngủ.

Khả năng ngủ trong các phần quan trọng bên đọc không
	đến miễn phí.	Đầu tiên, srcu_read_lock() tương ứng và
	Các lệnh gọi srcu_read_unlock() phải được chuyển qua cùng một srcu_struct.
	Thứ hai, chi phí phát hiện thời gian gia hạn chỉ được khấu hao
	qua những cập nhật đó chia sẻ một srcu_struct nhất định, thay vì
	được khấu hao trên toàn cầu giống như các dạng RCU khác.
	Do đó, SRCU nên được ưu tiên sử dụng hơn rw_semaphore
	chỉ trong những tình huống cần đọc nhiều hoặc trong những tình huống
	yêu cầu khả năng miễn nhiễm bế tắc phía đọc của SRCU hoặc phía đọc thấp
	độ trễ thời gian thực.  Bạn cũng nên xem xét percpu_rw_semaphore
	khi bạn cần những đầu đọc nhẹ.

Nguyên thủy cấp tốc của SRCU (synchronize_srcu_expedited())
	không bao giờ gửi IPI đến các CPU khác, vì vậy việc sử dụng sẽ dễ dàng hơn
	khối lượng công việc theo thời gian thực hơn là sync_rcu_expedited().

Nó cũng được phép ngủ trong phần đọc RCU Tasks Trace
	phần quan trọng, được phân cách bởi rcu_read_lock_trace()
	và rcu_read_unlock_trace().  Tuy nhiên đây là chuyên ngành
	hương vị của RCU và bạn không nên sử dụng nó mà không kiểm tra trước
	với người dùng hiện tại của nó.  Trong hầu hết các trường hợp, thay vào đó bạn nên
	sử dụng SRCU.  Như với RCU và SRCU, Guard(rcu_tasks_trace)() và
	scoped_guard(rcu_tasks_trace) có sẵn và thường cung cấp
	dễ sử dụng hơn.

Lưu ý rằng rcu_sign_pointer() liên quan đến SRCU giống như với
	các dạng khác của RCU, nhưng thay vì rcu_dereference() bạn nên
	sử dụng srcu_dereference() để tránh các biểu tượng lockdep.

14. Toàn bộ quan điểm của call_rcu(), sync_rcu() và những người bạn
	là đợi cho đến khi tất cả người đọc có sẵn đã hoàn thành trước khi
	thực hiện một số hoạt động phá hoại khác.  Đó là
	do đó cực kỳ quan trọng đối với ZZ0000ZZ việc xóa mọi đường dẫn
	mà người đọc có thể theo dõi có thể bị ảnh hưởng bởi
	hoạt động phá hoại và ZZ0001ZZ gọi call_rcu(),
	đồng bộ hóa_rcu() hoặc bạn bè.

Bởi vì những thứ nguyên thủy này chỉ chờ đợi những độc giả có sẵn nên nó
	trách nhiệm của người gọi là đảm bảo rằng bất kỳ sự tiếp theo nào
	độc giả sẽ thực hiện một cách an toàn.

15. Các dạng nguyên thủy phía đọc RCU khác nhau làm ZZ0000ZZ nhất thiết phải chứa
	rào cản trí nhớ.  Do đó, bạn nên lập kế hoạch cho CPU
	và trình biên dịch để tự do sắp xếp lại mã vào và ra khỏi RCU
	phần quan trọng bên đọc.  Đó là trách nhiệm của
	RCU nguyên thủy bên cập nhật để giải quyết vấn đề này.

Đối với người đọc SRCU, bạn có thể sử dụng smp_mb__after_srcu_read_unlock()
	ngay sau srcu_read_unlock() để có được rào cản đầy đủ.

16. Sử dụng CONFIG_PROVE_LOCKING, CONFIG_DEBUG_OBJECTS_RCU_HEAD và
	__rcu kiểm tra thưa thớt để xác thực mã RCU của bạn.	Những điều này có thể giúp ích
	tìm vấn đề như sau:

CONFIG_PROVE_LOCKING:
		kiểm tra xem quyền truy cập vào cấu trúc dữ liệu được bảo vệ RCU
		được thực hiện theo quy trình quan trọng phía đọc RCU thích hợp
		phần, trong khi giữ tổ hợp khóa bên phải,
		hoặc bất kỳ điều kiện nào khác phù hợp.

CONFIG_DEBUG_OBJECTS_RCU_HEAD:
		kiểm tra xem bạn không chuyển cùng một đối tượng tới call_rcu()
		(hoặc bạn bè) trước khi thời gian gia hạn RCU trôi qua
		kể từ lần cuối cùng bạn chuyển vật đó cho
		call_rcu() (hoặc bạn bè).

CONFIG_RCU_STRICT_GRACE_PERIOD:
		kết hợp với KASAN để kiểm tra con trỏ có bị rò rỉ ra ngoài không
		của RCU các phần quan trọng phía đọc.  Kconfig này
		tùy chọn khó khăn về cả hiệu suất và khả năng mở rộng,
		và do đó bị giới hạn ở hệ thống 4-CPU.

__rcu kiểm tra thưa thớt:
		gắn thẻ con trỏ tới cấu trúc dữ liệu được bảo vệ RCU
		với __rcu và thưa thớt sẽ cảnh báo bạn nếu bạn truy cập vào đó
		con trỏ không có dịch vụ của một trong các biến thể
		của rcu_dereference().

Những công cụ hỗ trợ gỡ lỗi này có thể giúp bạn tìm ra các vấn đề
	nếu không thì cực kỳ khó phát hiện.

17. Nếu bạn truyền một hàm gọi lại được xác định trong một mô-đun
	tới một trong các call_rcu(), call_srcu(), call_rcu_tasks() hoặc
	call_rcu_tasks_trace() thì cần phải chờ tất cả
	các cuộc gọi lại đang chờ xử lý sẽ được gọi trước khi dỡ bỏ mô-đun đó.
	Lưu ý là ZZ0000ZZ hoàn toàn đủ để chờ ân duyên
	kỳ!  Ví dụ: triển khai sync_rcu() là ZZ0001ZZ
	đảm bảo chờ các cuộc gọi lại được đăng ký trên các CPU khác thông qua
	call_rcu().  Hoặc thậm chí trên CPU hiện tại nếu CPU đó gần đây
	đã ngoại tuyến và trở lại trực tuyến.

Thay vào đó, bạn cần sử dụng một trong các chức năng rào cản:

- call_rcu() -> rcu_barrier()
	- call_srcu() -> srcu_barrier()
	- call_rcu_tasks() -> rcu_barrier_tasks()
	- call_rcu_tasks_trace() -> rcu_barrier_tasks_trace()

Tuy nhiên, các chức năng rào cản này được ZZ0000ZZ đảm bảo tuyệt đối
	để chờ thời gian ân hạn.  Ví dụ, nếu không có
	lệnh gọi lại call_rcu() được xếp hàng đợi ở bất kỳ đâu trong hệ thống, rcu_barrier()
	có thể và sẽ quay lại ngay lập tức.

Vì vậy, nếu bạn cần đợi cả thời gian gia hạn và tất cả
	các lệnh gọi lại đã tồn tại từ trước, bạn sẽ cần gọi cả hai hàm,
	với cặp tùy theo hương vị của RCU:

- Đồng bộ hóa_rcu() hoặc đồng bộ hóa_rcu_expedited(),
		cùng với rcu_barrier()
	- Đồng bộ hóa_srcu() hoặc đồng bộ hóa_srcu_expedited(),
		cùng với và srcu_barrier()
	- đồng bộ hóa_rcu_tasks() và rcu_barrier_tasks()
	- đồng bộ hóa_tasks_trace() và rcu_barrier_tasks_trace()

Nếu cần, bạn có thể sử dụng thứ gì đó như hàng công việc để thực thi
	cặp chức năng cần thiết đồng thời.

Xem rcubarier.rst để biết thêm thông tin.