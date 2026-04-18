.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/userspace-api/rseq.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

=======================
Trình tự có thể khởi động lại
=====================

Trình tự có thể khởi động lại cho phép đăng ký một vùng bộ nhớ không gian người dùng trên mỗi luồng
được sử dụng làm ABI giữa kernel và không gian người dùng cho ba mục đích:

* trình tự khởi động lại không gian người dùng

* truy cập nhanh để đọc số CPU hiện tại, ID nút từ không gian người dùng

* phần mở rộng lát thời gian lập lịch

Trình tự có thể khởi động lại (nguyên tử trên mỗi CPU)
---------------------------------------

Trình tự có thể khởi động lại cho phép không gian người dùng thực hiện các thao tác cập nhật trên
dữ liệu trên mỗi CPU mà không yêu cầu các hoạt động nguyên tử hạng nặng. thực tế
Rất tiếc, ABI chỉ có sẵn ở dạng mã và bản tự kiểm tra.

Truy cập nhanh vào số CPU, ID nút
-----------------------------------

Cho phép triển khai trên mỗi dữ liệu CPU một cách hiệu quả. Tài liệu ở dạng mã và
tự kiểm tra. :(

Phần mở rộng lát thời gian của bộ lập lịch
-------------------------------

Điều này cho phép một luồng yêu cầu một phần mở rộng lát thời gian khi nó đi vào một
phần quan trọng để tránh tranh chấp tài nguyên khi luồng được
được lên kế hoạch bên trong phần quan trọng.

Điều kiện tiên quyết cho chức năng này là:

* Đã bật trong Kconfig

* Kích hoạt lúc khởi động (mặc định là kích hoạt)

* Một con trỏ vùng người dùng rseq đã được đăng ký cho chủ đề

Chủ đề phải kích hoạt chức năng thông qua prctl(2)::

prctl(PR_RSEQ_SLICE_EXTENSION, PR_RSEQ_SLICE_EXTENSION_SET,
          PR_RSEQ_SLICE_EXT_ENABLE, 0, 0);

prctl() trả về 0 nếu thành công hoặc trả về các mã lỗi sau:

=============================================================================
Ý nghĩa mã lỗi
=============================================================================
EINVAL Chức năng không khả dụng hoặc đối số hàm không hợp lệ.
          Lưu ý: arg4 và arg5 phải bằng 0
Chức năng ENOTSUPP đã bị tắt trên dòng lệnh kernel
ENXIO Có sẵn, nhưng chưa đăng ký cấu trúc người dùng rseq
=============================================================================

Trạng thái cũng có thể được truy vấn thông qua prctl(2)::

prctl(PR_RSEQ_SLICE_EXTENSION, PR_RSEQ_SLICE_EXTENSION_GET, 0, 0, 0);

prctl() trả về ZZ0000ZZ khi nó được bật hoặc 0 nếu
bị vô hiệu hóa. Nếu không nó sẽ trả về với các mã lỗi sau:

=============================================================================
Ý nghĩa mã lỗi
=============================================================================
EINVAL Chức năng không khả dụng hoặc đối số hàm không hợp lệ.
          Lưu ý: arg3 và arg4 và arg5 phải bằng 0
=============================================================================

Tính khả dụng và trạng thái cũng được hiển thị thông qua cờ cấu trúc rseq ABI
trường thông qua ZZ0000ZZ và
ZZ0001ZZ. Các bit này ở chế độ chỉ đọc đối với người dùng
không gian và chỉ dành cho mục đích thông tin.

Nếu cơ chế được kích hoạt thông qua prctl(), luồng có thể yêu cầu thời gian
cắt phần mở rộng bằng cách đặt rseq::slice_ctrl::request thành 1. Nếu chuỗi
bị gián đoạn và kết quả gián đoạn là yêu cầu lập lịch lại trong
kernel, thì kernel có thể cấp phần mở rộng lát thời gian và quay lại
không gian người dùng thay vì lên lịch. Độ dài của phần mở rộng là
được xác định bởi debugfs:rseq/slice_ext_nsec. Giá trị mặc định là 5 usec; cái nào
là giá trị tối thiểu. Nó có thể tăng lên 50 usecs, tuy nhiên làm như vậy
có thể/sẽ ảnh hưởng đến độ trễ lập kế hoạch tối thiểu.

Mọi thay đổi được đề xuất đối với mặc định này sẽ phải đi kèm với bản tự kiểm tra và
Đầu ra rseq-slice-hist.py hiển thị giá trị mới có giá trị.

Hạt nhân biểu thị mức cấp phép bằng cách xóa rseq::slice_ctrl::request và
cài đặt rseq::slice_ctrl::grant thành 1. Nếu có lịch trình lại của
luồng sau khi cấp phần mở rộng, kernel sẽ xóa bit đã cấp cho
chỉ ra điều đó cho không gian người dùng.

Nếu bit yêu cầu vẫn được đặt khi rời khỏi phần quan trọng,
không gian người dùng có thể xóa nó và tiếp tục.

Nếu bit được cấp được đặt thì không gian người dùng sẽ gọi rseq_slice_yield(2) khi
rời khỏi phần quan trọng để từ bỏ CPU. Hạt nhân thực thi
điều này bằng cách kích hoạt bộ hẹn giờ để ngăn chặn không gian người dùng hoạt động sai trái lạm dụng điều này
cơ chế.

Nếu cả bit yêu cầu và bit được cấp đều sai khi rời khỏi
phần quan trọng thì điều này cho thấy rằng khoản trợ cấp đã bị thu hồi và không có
không gian người dùng yêu cầu hành động tiếp theo.

Luồng mã được yêu cầu như sau::

rseq->slice_ctrl.request = 1;
    rào cản();  // Ngăn chặn việc sắp xếp lại trình biên dịch
    quan trọng_section();
    rào cản();  // Ngăn chặn việc sắp xếp lại trình biên dịch
    rseq->slice_ctrl.request = 0;
    if (rseq->slice_ctrl.grant)
        rseq_slice_yield();

Vì tất cả những điều này hoàn toàn là CPU cục bộ nên không có yêu cầu về tính nguyên tử.
Việc kiểm tra trạng thái được cấp là không phù hợp, nhưng điều đó không thể tránh khỏi::

if (rseq->slice_ctrl.grant)
      -> Làm gián đoạn kết quả theo lịch trình và thu hồi cấp phép
        rseq_slice_yield();

Vì vậy, chẳng ích gì khi giả vờ rằng vấn đề này có thể được giải quyết bằng một hạt nhân nguyên tử.
hoạt động.

Nếu luồng phát hành một cuộc gọi tòa nhà khác với rseq_slice_yield(2) trong
được gia hạn thời gian, khoản trợ cấp cũng bị thu hồi và CPU được
từ bỏ ngay lập tức khi vào kernel. Điều này là bắt buộc vì
các cuộc gọi tổng hợp có thể tiêu tốn thời gian CPU tùy ý cho đến khi chúng đạt được lịch trình
điểm khi mô hình ưu tiên là NONE hoặc VOLUNTARY và do đó
có thể vượt quá mức trợ cấp cho đến nay.

Giải pháp ưu tiên cho không gian người dùng là sử dụng rseq_slice_yield(2)
là không có tác dụng phụ. Cần có sự hỗ trợ cho các cuộc gọi hệ thống tùy ý để
hỗ trợ các ứng dụng có kiến trúc lớp củ hành, trong đó mã xử lý
phần quan trọng và yêu cầu gia hạn lát thời gian không có quyền kiểm soát
qua mã trong phần quan trọng.

Hạt nhân thực thi tính nhất quán của cờ và chấm dứt luồng bằng SIGSEGV
nếu phát hiện vi phạm.
