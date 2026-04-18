.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/mm/active_mm.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

==========
MM đang hoạt động
=========

Lưu ý, số lần đếm mm_count có thể không còn bao gồm những người dùng "lười biếng" nữa
(chạy các tác vụ với ->active_mm == mm && ->mm == NULL) trên hạt nhân
với CONFIG_MMU_LAZY_TLB_REFCOUNT=n. Bắt và thả những kẻ lười biếng
tài liệu tham khảo phải được thực hiện với mmgrab_lazy_tlb() và mmdrop_lazy_tlb()
người trợ giúp, trừu tượng hóa tùy chọn cấu hình này.

::

Danh sách: hạt nhân linux
 Chủ đề: Re: active_mm
 Từ: Linus Torvalds <torvalds () transmeta ! com>
 Ngày: 1999-07-30 21:36:24

Cc vào linux-kernel, vì tôi không thường xuyên viết lời giải thích,
 và khi làm vậy tôi cảm thấy dễ chịu hơn khi có nhiều người đọc chúng hơn.

Vào thứ Sáu, ngày 30 tháng 7 năm 1999, David Mosberger đã viết:
 >
 > Có mô tả ngắn gọn nào đó về cách "mm" so với "active_mm" trong
 > task_struct được cho là sẽ được sử dụng?  (Tôi xin lỗi nếu đây là
 > thảo luận về danh sách gửi thư---Tôi vừa trở về từ kỳ nghỉ và
 > không thể theo dõi linux-kernel trong một thời gian).

Về cơ bản, thiết lập mới là:

- chúng tôi có "không gian địa chỉ thực" và "không gian địa chỉ ẩn danh". các
    điểm khác biệt là không gian địa chỉ ẩn danh không quan tâm đến
    bảng trang ở cấp độ người dùng, vì vậy khi chúng tôi thực hiện chuyển ngữ cảnh sang
    không gian địa chỉ ẩn danh chúng tôi chỉ để lại không gian địa chỉ trước đó
    hoạt động.

Việc sử dụng rõ ràng "không gian địa chỉ ẩn danh" là bất kỳ luồng nào
    không cần bất kỳ ánh xạ người dùng nào - về cơ bản tất cả các luồng nhân đều rơi vào
    thể loại này, nhưng ngay cả những chủ đề "thực sự" cũng có thể tạm thời nói điều đó đối với
    trong một khoảng thời gian nào đó họ sẽ không quan tâm đến không gian người dùng,
    và người lập lịch cũng có thể cố gắng tránh lãng phí thời gian vào
    chuyển đổi trạng thái VM xung quanh. Hiện tại chỉ có bdflush kiểu cũ
    đồng bộ hóa làm điều đó.

- "tsk->mm" trỏ đến "không gian địa chỉ thực". Đối với một quá trình ẩn danh,
    tsk->mm sẽ là NULL, vì lý do hợp lý là một quy trình ẩn danh
    thực sự không có một không gian địa chỉ thực nào cả.

- tuy nhiên, rõ ràng là chúng tôi cần theo dõi không gian địa chỉ mà chúng tôi
    "đánh cắp" đối với một người dùng ẩn danh như vậy. Để làm được điều đó, chúng ta có "tsk->active_mm",
    trong đó cho thấy không gian địa chỉ hiện đang hoạt động là gì.

Quy tắc là đối với một quy trình có không gian địa chỉ thực (tức là tsk->mm là
    không phải NULL) thì active_mm rõ ràng phải luôn giống với số thực
    một.

Đối với quy trình ẩn danh, tsk->mm == NULL và tsk->active_mm là
    "mượn" mm trong khi quá trình ẩn danh đang chạy. Khi
    quá trình ẩn danh được lên lịch, không gian địa chỉ mượn được
    trở lại và xóa.

Để hỗ trợ tất cả những điều đó, "struct mm_struct" hiện có hai bộ đếm: a
 Bộ đếm "mm_users" cho biết có bao nhiêu "người dùng trong không gian địa chỉ thực",
 và bộ đếm "mm_count" là số lượng người dùng "lười biếng" (tức là ẩn danh
 người dùng) cộng với một nếu có bất kỳ người dùng thực sự nào.

Thông thường có ít nhất một người dùng thực, nhưng cũng có thể đó là người dùng thực.
 người dùng đã thoát trên một CPU khác trong khi người dùng lười biếng vẫn hoạt động, vì vậy bạn làm như vậy
 thực sự gặp phải trường hợp bạn có một không gian địa chỉ _chỉ_ được sử dụng bởi
 người dùng lười biếng. Đó thường là một trạng thái tồn tại trong thời gian ngắn, bởi vì một khi sợi dây đó
 được lên lịch để thay thế cho một chủ đề thực sự, mm "thây ma" sẽ
 được phát hành vì "mm_count" trở thành số 0.

Ngoài ra, một quy tắc mới là _nobody_ từng có "init_mm" là MM thực sự
 nhiều hơn nữa. "init_mm" nên được coi chỉ là một "bối cảnh lười biếng khi không có bối cảnh nào khác
 ngữ cảnh có sẵn" và trên thực tế, nó chủ yếu được sử dụng khi khởi động khi
 chưa có VM thực sự nào được tạo. Vì vậy, mã được sử dụng để kiểm tra

if (hiện tại->mm == &init_mm)

nói chung chỉ nên làm

nếu (! Hiện tại-> mm)

thay vào đó (dù sao thì điều này cũng hợp lý hơn - bài kiểm tra về cơ bản là một trong những kiểu "làm
 chúng tôi có bối cảnh người dùng" và thường được thực hiện bởi trình xử lý lỗi trang
 và những thứ tương tự).

Dù sao, tôi đã đặt bản vá trước-2.3.13-1 trên ftp.kernel.org chỉ một lúc trước,
 bởi vì nó thay đổi một chút các giao diện để phù hợp với alpha (ai
 lẽ ra đã nghĩ như vậy, nhưng thực ra alpha cuối cùng lại có một trong những
 mã chuyển đổi ngữ cảnh xấu nhất - không giống như các kiến trúc khác có MM
 và trạng thái đăng ký là riêng biệt, mã alpha PAL kết hợp cả hai và bạn
 cần phải chuyển đổi cả hai cùng nhau).

(Từ ZZ0000ZZ
