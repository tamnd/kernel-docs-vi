.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/filesystems/gfs2/glocks.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

===============================
Quy tắc khóa nội bộ của Glock
============================

Tài liệu này ghi lại các nguyên tắc cơ bản của máy trạng thái glock
nội bộ. Mỗi glock (struct gfs2_glock trong fs/gfs2/incore.h)
có hai khóa chính (nội bộ):

1. Một spinlock (gl_lockref.lock) bảo vệ trạng thái bên trong như
    dưới dạng gl_state, gl_target và danh sách chủ sở hữu (gl_holders)
 2. Khóa bit không chặn, GLF_LOCK, được sử dụng để ngăn chặn các hoạt động khác
    chủ đề từ việc thực hiện cuộc gọi đến DLM, v.v. cùng một lúc. Nếu một
    thread nhận khóa này, sau đó nó phải gọi run_queue (thường thông qua
    Workqueue) khi nó phát hành nó để đảm bảo mọi tác vụ đang chờ xử lý
    được hoàn thành.

Danh sách gl_holders chứa tất cả các yêu cầu khóa được xếp hàng đợi (không phải
chỉ những người nắm giữ) được liên kết với glock. Nếu có bất kỳ
các khóa được giữ thì chúng sẽ là các mục liền kề ở đầu
của danh sách. Các khóa được cấp theo đúng thứ tự mà chúng
đang xếp hàng.

Có ba trạng thái khóa mà người dùng lớp glock có thể yêu cầu,
cụ thể là chia sẻ (SH), trả chậm (DF) và độc quyền (EX). Những người dịch
sang các chế độ khóa DLM sau:

=========== ====== ==========================================================
Chế độ Glock Chế độ khóa DLM
=========== ====== ==========================================================
    Đã mở khóa UN IV/NL (không có khóa DLM liên quan đến glock) hoặc NL
    SH PR (Đọc được bảo vệ)
    DF CW (Ghi đồng thời)
    EX EX (Độc quyền)
=========== ====== ==========================================================

Do đó, DF về cơ bản là một chế độ chia sẻ không tương thích với chế độ "bình thường"
chế độ khóa chia sẻ, SH. Trong GFS2, chế độ DF được sử dụng riêng cho I/O trực tiếp
hoạt động. Glocks về cơ bản là một khóa cộng với một số quy trình xử lý
với quản lý bộ đệm. Các quy tắc sau áp dụng cho bộ đệm:

========================= ====================== ================
Chế độ Glock Siêu dữ liệu bộ đệm Dữ liệu bộ đệm Dữ liệu bẩn Siêu dữ liệu bẩn
========================= ====================== ================
    LHQ Không Không Không Không
    DF Có Không Không Không
    SH Có Có Không Không
    EX Có Có Có Có
========================= ====================== ================

Các quy tắc này được thực hiện bằng cách sử dụng các thao tác glock khác nhau.
được xác định cho từng loại glock. Không phải tất cả các loại glock đều sử dụng
tất cả các chế độ. Ví dụ: chỉ các glock inode mới sử dụng chế độ DF.

Bảng hoạt động của glock và hằng số loại:

==================================================================================
Mục đích trường
==================================================================================
go_sync Được gọi trước khi thay đổi trạng thái từ xa (ví dụ: để đồng bộ hóa dữ liệu bẩn)
go_xmote_bh Được gọi sau khi thay đổi trạng thái từ xa (ví dụ: để nạp lại bộ đệm)
go_inval Được gọi nếu thay đổi trạng thái từ xa yêu cầu vô hiệu hóa bộ đệm
go_instantiate Được gọi khi đã lấy được glock
go_held Được gọi mỗi khi có được hộp đựng glock
go_dump Được gọi để in nội dung của đối tượng cho tệp debugfs hoặc trên
                   lỗi đổ glock vào nhật ký.
go_callback Được gọi nếu DLM gửi lệnh gọi lại để hủy khóa này
go_unlocked Được gọi khi glock được mở khóa (dlm_unlock())
go_type Loại súng, ZZ0000ZZ
go_flags GLOF_ASPACE được đặt nếu glock có không gian địa chỉ
                   liên kết với nó
==================================================================================

Thời gian giữ tối thiểu cho mỗi khóa là thời gian sau khi khóa remote
cấp mà chúng tôi bỏ qua các yêu cầu hạ cấp từ xa. Điều này là để
ngăn chặn tình trạng ổ khóa bị bật xung quanh cụm
từ nút này sang nút khác mà không có nút nào tiến triển. Cái này
có xu hướng hiển thị nhiều nhất với các tệp được chia sẻ được chia sẻ đang được viết
tới nhiều nút. Bằng cách trì hoãn việc giáng chức để đáp lại một
gọi lại từ xa, điều đó giúp chương trình không gian người dùng có thời gian để thực hiện
một số tiến bộ trước khi các trang được lập bản đồ.

Cuối cùng, chúng tôi hy vọng có thể chia sẻ chế độ "EX" của súng glock cục bộ sao cho mọi
khóa cục bộ sẽ được thực hiện với i_mutex theo yêu cầu thay vì thông qua
glock.

Quy tắc khóa cho hoạt động glock:

=======================================================================
Hoạt động khóa bit GLF_LOCK được giữ gl_lockref.lock spinlock được giữ
=======================================================================
go_sync Có Không
go_xmote_bh Có Không
go_inval Có Không
go_instantiate Không Không
go_held Không Không
go_dump Đôi khi Có
go_callback Đôi khi (Không áp dụng) Có
go_unlocked Có Không
=======================================================================

.. Note::

   Operations must not drop either the bit lock or the spinlock
   if its held on entry. go_dump and do_demote_ok must never block.
   Note that go_dump will only be called if the glock's state
   indicates that it is caching up-to-date data.

Thứ tự khóa Glock trong GFS2:

1. i_rwsem (nếu cần)
 2. Đổi tên glock (chỉ để đổi tên)
 3. Glock Inode
    (Cha mẹ trước con cái, inode ở "cùng cấp độ" với cùng cha mẹ trong
    thứ tự khóa số)
 4. Rgrp glock(s) (cho các hoạt động phân bổ (de))
 5. Glock giao dịch (thông qua gfs2_trans_begin) cho các hoạt động không đọc
 6. i_rw_mutex (nếu cần)
 7. Khóa trang (luôn luôn cuối cùng, rất quan trọng!)

Có hai glock trên mỗi inode. Một giao dịch với quyền truy cập vào inode
chính nó (thứ tự khóa như trên) và cái còn lại, được gọi là iopen
glock được sử dụng cùng với trường i_nlink trong inode để
xác định thời gian tồn tại của inode được đề cập. Khóa inode
dựa trên cơ sở mỗi inode. Việc khóa rgrps được thực hiện trên cơ sở mỗi rgrp.
Nói chung, chúng tôi ưu tiên khóa các khóa cục bộ trước các khóa cụm.

Thống kê Glock
----------------

Số liệu thống kê được chia thành hai bộ: những bộ liên quan đến
siêu khối và những khối liên quan đến một glock riêng lẻ. các
số liệu thống kê siêu khối được thực hiện trên cơ sở mỗi CPU để
hãy thử và giảm chi phí thu thập chúng. Họ cũng vậy
chia tiếp theo loại glock. Tất cả thời gian đều tính bằng nano giây.

Trong trường hợp thống kê cả siêu khối và glock,
cùng một thông tin được thu thập trong mỗi trường hợp. siêu
thống kê thời gian khối được sử dụng để cung cấp các giá trị mặc định cho
số liệu thống kê về thời gian của glock, để các glock mới được tạo
nên có, trong chừng mực có thể, một điểm khởi đầu hợp lý.
Bộ đếm trên mỗi glock được khởi tạo về 0 khi
glock được tạo ra. Số liệu thống kê trên mỗi glock bị mất khi
Glock được đẩy ra khỏi bộ nhớ.

Số liệu thống kê được chia thành ba cặp giá trị trung bình và
phương sai, cộng với hai quầy. Các cặp trung bình/phương sai là
ước tính hàm mũ được làm mịn và thuật toán được sử dụng là
một thứ sẽ rất quen thuộc với những người quen tính toán
về thời gian khứ hồi trong mã mạng. Xem "TCP/IP được minh họa,
Tập 1", W. Richard Stevens, phần 21.3, "Đo thời gian khứ hồi",
trang. 299 trở đi. Ngoài ra, Tập 2, Mục. 25.10, tr. 838 trở đi.
Không giống như trường hợp minh họa TCP/IP, giá trị trung bình và phương sai là
không được chia tỷ lệ mà được tính bằng đơn vị số nguyên nano giây.

Ba cặp giá trị trung bình/phương sai đo lường như sau
mọi thứ:

1. Thời gian khóa DLM (yêu cầu không chặn)
 2. Thời gian khóa DLM (chặn yêu cầu)
 3. Thời gian liên yêu cầu (lại tới DLM)

Yêu cầu không chặn là yêu cầu sẽ hoàn thành đúng
đi, bất kể trạng thái của khóa DLM đang được đề cập là gì. Đó
hiện tại có nghĩa là bất kỳ yêu cầu nào khi (a) trạng thái hiện tại của
khóa là độc quyền, tức là hạ cấp khóa (b) yêu cầu
trạng thái là vô hiệu hoặc được mở khóa (một lần nữa, bị giáng chức) hoặc (c) trạng thái
Cờ "thử khóa" được đặt. Yêu cầu chặn bao gồm tất cả các yêu cầu khác
khóa yêu cầu.

Có hai quầy. Đầu tiên là ở đó chủ yếu để hiển thị
có bao nhiêu yêu cầu khóa đã được thực hiện và do đó có bao nhiêu dữ liệu
đã đi vào tính toán giá trị trung bình/phương sai. Quầy khác
đang đếm số người xếp hàng ở lớp trên cùng của khẩu súng
mã. Hy vọng con số đó sẽ lớn hơn rất nhiều so với con số
của các yêu cầu khóa dlm được đưa ra.

Vậy tại sao lại thu thập những số liệu thống kê này? Có một số lý do
chúng tôi muốn hiểu rõ hơn về những khoảng thời gian này:

1. Để có thể thiết lập tốt hơn "thời gian giữ tối thiểu" của glock
2. Để phát hiện các vấn đề về hiệu suất dễ dàng hơn
3. Cải thiện thuật toán chọn nhóm tài nguyên cho
   phân bổ (dựa trên thời gian chờ khóa, thay vì mù quáng
   sử dụng "thử khóa")

Do hoạt động làm mượt của các bản cập nhật, một bước thay đổi trong
một số lượng đầu vào được lấy mẫu sẽ chỉ được lấy đầy đủ
được tính đến sau 8 mẫu (hoặc 4 mẫu đối với phương sai) và điều này
cần phải cân nhắc kỹ lưỡng khi giải thích
kết quả.

Biết cả thời gian cần thiết để hoàn thành một yêu cầu khóa và
thời gian trung bình giữa các lần yêu cầu khóa một khẩu súng lục có nghĩa là chúng tôi
có thể tính toán tổng số phần trăm thời gian mà
nút có thể sử dụng glock so với thời gian mà phần còn lại của
cụm có phần của nó. Điều đó sẽ rất hữu ích khi thiết lập
thời gian giữ khóa tối thiểu.

Chúng tôi đã hết sức cẩn thận để đảm bảo rằng chúng tôi
đo lường chính xác số lượng mà chúng ta muốn, một cách chính xác
càng tốt. Luôn có sự thiếu chính xác trong bất kỳ
hệ thống đo lường, nhưng tôi hy vọng nó chính xác như chúng ta
có thể làm được điều đó một cách hợp lý.

Số liệu thống kê của mỗi sb có thể được tìm thấy ở đây::

/sys/kernel/debug/gfs2/<fsname>/sbstats

Số liệu thống kê của mỗi glock có thể được tìm thấy ở đây ::

/sys/kernel/debug/gfs2/<fsname>/glstats

Giả sử rằng debugfs được gắn trên /sys/kernel/debug và cả
<fsname> đó được thay thế bằng tên của hệ thống tập tin gfs2
trong câu hỏi.

Các chữ viết tắt được sử dụng trong đầu ra như sau:

==============================================================================
srtt Thời gian khứ hồi được làm mượt cho các yêu cầu dlm không chặn
srttvar Ước tính phương sai cho srtt
srttb Thời gian khứ hồi được làm mượt để (có khả năng) chặn các yêu cầu dlm
srttvarb Ước tính phương sai cho srttb
sirt Thời gian yêu cầu liên kết được làm mịn (đối với yêu cầu dlm)
sirtvar Ước tính phương sai cho sirt
dlm Số lượng yêu cầu dlm được thực hiện (dcnt trong tệp glstats)
hàng đợi Số lượng yêu cầu glock được xếp hàng đợi (qcnt trong tệp glstats)
==============================================================================

Tệp sbstats chứa một tập hợp các số liệu thống kê này cho từng loại glock (vì vậy 8 dòng
cho từng loại) và cho mỗi CPU (một cột cho mỗi CPU). Tệp glstats chứa
một tập hợp các số liệu thống kê này cho mỗi khẩu glock ở định dạng tương tự như tệp glock, nhưng
sử dụng định dạng trung bình/phương sai cho từng thống kê thời gian.

Điểm theo dõi gfs2_glock_lock_time in ra các giá trị hiện tại của số liệu thống kê
cho khẩu súng đang được đề cập, cùng với một số thông tin bổ sung về mỗi dlm
trả lời nhận được:

====== ===========================================
trạng thái Trạng thái của yêu cầu dlm
cờ Cờ yêu cầu dlm
tdiff Thời gian thực hiện theo yêu cầu cụ thể này
====== ===========================================

(các trường còn lại theo danh sách trên)

