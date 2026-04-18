.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/core-api/errseq.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=======================
Kiểu dữ liệu errseq_t
=======================

Errseq_t là một cách ghi lại lỗi ở một nơi và cho phép mọi lỗi xảy ra.
số lượng "người đăng ký" để biết liệu nó có thay đổi so với lần trước không
điểm nơi nó được lấy mẫu.

Trường hợp sử dụng ban đầu cho việc này là theo dõi lỗi cho tệp
các cuộc gọi tổng hợp đồng bộ hóa (fsync, fdatasync, msync và sync_file_range),
nhưng nó có thể được sử dụng trong các tình huống khác.

Nó được triển khai dưới dạng giá trị 32 bit không dấu.  Các bit thứ tự thấp là
được chỉ định để giữ mã lỗi (từ 1 đến MAX_ERRNO).  Các bit trên
được sử dụng như một bộ đếm.  Việc này được thực hiện bằng nguyên tử thay vì khóa để
các hàm này có thể được gọi từ bất kỳ ngữ cảnh nào.

Lưu ý rằng có nguy cơ xung đột nếu lỗi mới được ghi lại
thường xuyên, vì chúng ta có quá ít bit để sử dụng làm bộ đếm.

Để giảm thiểu điều này, bit giữa giá trị lỗi và bộ đếm được sử dụng làm
một lá cờ để biết giá trị đã được lấy mẫu hay chưa kể từ khi giá trị mới được tạo ra
được ghi lại.  Điều đó cho phép chúng ta tránh va chạm vào quầy nếu không có ai có
đã lấy mẫu nó kể từ lần cuối cùng một lỗi được ghi lại.

Vì vậy, chúng tôi kết thúc với một giá trị trông giống như thế này:

+--------------------------------------+----+---------------+
ZZ0000ZZ 12 ZZ0001ZZ
+--------------------------------------+----+---------------+
ZZ0002ZZ SF ZZ0003ZZ
+--------------------------------------+----+---------------+

Ý tưởng chung là để "người theo dõi" lấy mẫu giá trị errseq_t và giữ
nó như một con trỏ đang chạy.  Giá trị đó sau này có thể được sử dụng để cho biết liệu
bất kỳ lỗi mới nào đã xảy ra kể từ khi việc lấy mẫu đó được thực hiện và về mặt nguyên tử
ghi lại trạng thái tại thời điểm nó được kiểm tra.  Điều này cho phép chúng tôi
ghi lại các lỗi ở một nơi và sau đó có một số "người theo dõi"
có thể biết liệu giá trị có thay đổi kể từ lần cuối họ kiểm tra nó hay không.

Một errseq_t mới phải luôn được loại bỏ.  Giá trị errseq_t của tất cả các số 0
là trường hợp đặc biệt (nhưng phổ biến) chưa từng xảy ra lỗi. Tất cả
do đó giá trị 0 đóng vai trò là "kỷ nguyên" nếu người ta muốn biết liệu có
đã từng là một lỗi được đặt ra kể từ lần đầu tiên nó được khởi tạo.

Cách sử dụng API
================

Để tôi kể cho bạn nghe câu chuyện về chiếc máy bay không người lái của công nhân.  Bây giờ anh ấy là một công nhân tốt
nhìn chung, nhưng công ty hơi...nặng về quản lý.  Anh ấy phải
Hôm nay báo cáo 77 cấp trên, ngày mai "sếp lớn" tới
từ ngoài thị trấn và chắc chắn anh ta cũng sẽ kiểm tra anh chàng tội nghiệp đó.

Tất cả họ đều giao cho anh ấy công việc phải làm -- nhiều đến mức anh ấy không thể theo dõi được ai là người
đưa cho anh ta cái gì, nhưng đó không thực sự là một vấn đề lớn.  Những người giám sát
chỉ muốn biết khi nào anh ấy làm xong tất cả công việc họ giao cho anh ấy
xa và liệu anh ấy có phạm sai lầm nào kể từ lần cuối họ hỏi hay không.

Có thể anh ấy đã phạm sai lầm trong công việc mà họ không thực sự giao cho anh ấy,
nhưng anh ấy không thể theo dõi mọi thứ ở mức độ chi tiết đó, tất cả những gì anh ấy có thể
hãy nhớ là sai lầm gần đây nhất mà anh ấy đã mắc phải.

Đây là đại diện worker_drone của chúng tôi::

cấu trúc worker_drone {
                errseq_t wd_err; /* cho lỗi ghi */
        };

Mỗi ngày, worker_drone bắt đầu với một bảng trống::

struct worker_drone wd;

wd.wd_err = (errseq_t)0;

Những người giám sát đến và đọc kết quả đầu tiên trong ngày.  Họ
không quan tâm đến bất cứ điều gì xảy ra trước khi phiên trực của họ bắt đầu::

người giám sát cấu trúc {
                errseq_t s_wd_err; /* "con trỏ" riêng cho wd_err */
                spinlock_t s_wd_err_lock; /* bảo vệ s_wd_err */
        }

giám sát cấu trúc su;

su.s_wd_err = errseq_sample(&wd.wd_err);
        spin_lock_init(&su.s_wd_err_lock);

Bây giờ họ bắt đầu giao nhiệm vụ cho anh ta làm.  Cứ sau vài phút họ lại yêu cầu anh ta
hoàn thành tất cả công việc họ đã giao cho anh ấy cho đến nay.  Sau đó họ hỏi anh ta
liệu anh ấy có mắc lỗi nào trong số đó không::

spin_lock(&su.su_wd_err_lock);
        err = errseq_check_and_advance(&wd.wd_err, &su.s_wd_err);
        spin_unlock(&su.su_wd_err_lock);

Cho đến thời điểm này, nó vẫn tiếp tục trả về 0.

Giờ đây, những người chủ của công ty này khá keo kiệt và đã cho anh ta
thiết bị không đạt tiêu chuẩn để thực hiện công việc của mình. Thỉnh thoảng nó
trục trặc và anh ấy mắc sai lầm.  Anh thở dài nặng nề và đánh dấu nó
xuống::

errseq_set(&wd.wd_err, -EIO);

...and then gets back to work.  The supervisors eventually poll again
và mỗi người đều gặp lỗi khi kiểm tra lần tiếp theo.  Các cuộc gọi tiếp theo sẽ
trả về 0, cho đến khi một lỗi khác được ghi lại, tại thời điểm đó nó được báo cáo
cho mỗi người trong số họ một lần.

Lưu ý rằng người giám sát không thể biết anh ta đã mắc bao nhiêu sai lầm, chỉ
liệu cái này có được tạo kể từ lần cuối họ kiểm tra hay không và giá trị mới nhất
được ghi lại.

Thỉnh thoảng sếp lớn vào kiểm tra tại chỗ và hỏi nhân viên
để làm một công việc duy nhất cho anh ta. Anh ấy không thực sự quan sát người công nhân
toàn thời gian như những người giám sát, nhưng anh ta cần biết liệu một
đã xảy ra lỗi trong khi công việc của anh ấy đang được xử lý.

Anh ta chỉ có thể lấy mẫu lỗi hiện tại trong công nhân và sau đó sử dụng nó
để biết sau này có xảy ra lỗi hay không::

errseq_t vì = errseq_sample(&wd.wd_err);
        /*Gửi một số công việc và đợi nó hoàn thành */
        err = errseq_check(&wd.wd_err, vì);

Vì anh ấy sẽ loại bỏ "since" sau thời điểm đó nên anh ấy không
cần phải thúc đẩy nó ở đây. Anh ấy cũng không cần bất kỳ khóa nào vì nó
không ai khác có thể sử dụng được.

Đang nối tiếp các cập nhật con trỏ errseq_t
===========================================

Lưu ý rằng errseq_t API không bảo vệ con trỏ errseq_t trong khi
check_and_advance_Operation. Chỉ xử lý mã lỗi chuẩn
về mặt nguyên tử.  Trong trường hợp có nhiều hơn một tác vụ có thể sử dụng
cùng một con trỏ errseq_t cùng một lúc, điều quan trọng là phải tuần tự hóa
cập nhật cho con trỏ đó.

Nếu điều đó không được thực hiện thì con trỏ có thể bị lùi lại
trong trường hợp đó, cùng một lỗi có thể được báo cáo nhiều lần.

Vì lý do này, việc thực hiện errseq_check trước tiên thường có lợi
xem có gì thay đổi không và chỉ sau này mới thực hiện
errseq_check_and_advance sau khi lấy khóa. ví dụ.::

if (errseq_check(&wd.wd_err, READ_ONCE(su.s_wd_err)) {
                /* su.s_wd_err được bảo vệ bởi s_wd_err_lock */
                spin_lock(&su.s_wd_err_lock);
                err = errseq_check_and_advance(&wd.wd_err, &su.s_wd_err);
                spin_unlock(&su.s_wd_err_lock);
        }

Điều đó tránh được tình trạng khóa xoay trong trường hợp phổ biến khi không có gì thay đổi
kể từ lần cuối nó được kiểm tra.

Chức năng
=========

.. kernel-doc:: lib/errseq.c
