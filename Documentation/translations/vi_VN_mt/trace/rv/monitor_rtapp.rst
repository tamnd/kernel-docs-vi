.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/trace/rv/monitor_rtapp.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

Màn hình ứng dụng thời gian thực
================================

- Tên: rtapp
- Loại: hộp đựng nhiều màn hình
- Tác giả: Nam Cao <namcao@linutronix.de>

Sự miêu tả
-----------

Các ứng dụng thời gian thực có thể có các lỗi thiết kế mà chúng gặp phải
độ trễ bất ngờ và không đáp ứng được yêu cầu về thời gian của họ. Thông thường, những sai sót này
làm theo một số mẫu:

- Lỗi trang: Một luồng thời gian thực có thể truy cập vào bộ nhớ không có
    sao lưu vật lý được ánh xạ hoặc trước tiên phải được sao chép (chẳng hạn như sao chép khi ghi).
    Do đó, lỗi trang sẽ xuất hiện và hạt nhân trước tiên phải thực hiện công việc đắt tiền.
    hành động. Điều này gây ra sự chậm trễ đáng kể cho luồng thời gian thực
  - Đảo ngược mức độ ưu tiên: Khối luồng thời gian thực đang chờ mức ưu tiên thấp hơn
    chủ đề. Điều này làm cho luồng thời gian thực đảm nhiệm một cách hiệu quả
    lập lịch ưu tiên của luồng có mức độ ưu tiên thấp hơn. Ví dụ, thời gian thực
    luồng cần truy cập vào tài nguyên được chia sẻ được bảo vệ bởi một
    không phải pi-mutex, nhưng mutex hiện được sở hữu bởi một luồng không theo thời gian thực.

Màn hình ZZ0000ZZ phát hiện các mẫu này. Nó hỗ trợ các nhà phát triển xác định
lý do gây ra độ trễ không mong muốn với các ứng dụng thời gian thực. Nó là một thùng chứa
nhiều màn hình phụ được mô tả trong các phần sau.

Theo dõi lỗi trang
++++++++++++++++++

Màn hình ZZ0000ZZ báo cáo các lỗi trang gây ra tác vụ theo thời gian thực. của nó
đặc điểm kỹ thuật là::

RULE = luôn luôn (RT ngụ ý không phải PAGEFAULT)

Để khắc phục các cảnh báo do màn hình này báo cáo, có thể sử dụng ZZ0000ZZ hoặc ZZ0001ZZ
để đảm bảo hỗ trợ vật lý cho bộ nhớ.

Màn hình này có thể có kết quả âm tính giả vì các trang được trang thời gian thực sử dụng
các chủ đề có thể có sẵn trực tiếp trong quá trình thử nghiệm.  Để giảm thiểu
điều này, hệ thống có thể bị đặt dưới áp lực bộ nhớ (ví dụ: gọi trình diệt OOM
sử dụng chương trình thực hiện ZZ0000ZZ) để hạt nhân thực thi các chiến lược tích cực để tái chế như
nhiều bộ nhớ vật lý nhất có thể.

Theo dõi giấc ngủ
+++++++++++++++++

Màn hình ZZ0000ZZ báo cáo các luồng thời gian thực đang ngủ theo cách có thể
gây ra độ trễ không mong muốn. Các ứng dụng thời gian thực chỉ nên đặt thời gian thực
thread chuyển sang chế độ ngủ vì một trong những lý do sau:

- Công việc theo chu kỳ: luồng thời gian thực ngủ chờ chu kỳ tiếp theo. Vì điều này
    trong trường hợp này, chỉ nên sử dụng tòa nhà ZZ0000ZZ với ZZ0001ZZ
    (để tránh trôi thời gian) và ZZ0002ZZ (để tránh đồng hồ bị lệch
    đã thay đổi). Không có phương pháp nào khác an toàn cho thời gian thực. Ví dụ, chủ đề
    chờ đợi timerfd có thể được đánh thức bởi softirq không cung cấp thời gian thực
    đảm bảo.
  - Chuỗi thời gian thực đang chờ điều gì đó xảy ra (ví dụ: một chuỗi khác
    giải phóng tài nguyên được chia sẻ hoặc tín hiệu hoàn thành từ một luồng khác). trong
    trường hợp này, chỉ futex (FUTEX_LOCK_PI, FUTEX_LOCK_PI2 hoặc một trong
    FUTEX_WAIT_*) nên được sử dụng.  Các ứng dụng thường không sử dụng futexes
    trực tiếp, nhưng sử dụng các biến điều kiện PI và các biến điều kiện PI được xây dựng trên
    đầu của futexes. Xin lưu ý rằng thư viện C có thể không triển khai các điều kiện
    các biến an toàn cho thời gian thực. Thay vào đó, thư viện librtpi
    tồn tại để cung cấp cách triển khai biến có điều kiện đúng cho
    các ứng dụng thời gian thực trên Linux.

Bên cạnh lý do ngủ, người thức giấc cuối cùng cũng nên
thời gian thực an toàn. Cụ thể, một trong:

- Một luồng có mức độ ưu tiên bằng hoặc cao hơn
  - Xử lý ngắt cứng
  - Trình xử lý ngắt không thể che dấu

Cảnh báo của màn hình này thường có nghĩa là một trong những điều sau:

- Chuỗi thời gian thực bị chặn bởi một chuỗi không phải thời gian thực (ví dụ: do
    tranh chấp trên một mutex mà không có sự kế thừa ưu tiên). Đây là ưu tiên
    đảo ngược.
  - Công việc quan trọng về thời gian chờ đợi thứ gì đó không an toàn trong thời gian thực (ví dụ:
    hẹn giờ).
  - Công việc được thực thi bởi luồng thời gian thực không cần phải chạy ở thời gian thực
    ưu tiên gì cả.  Đây không phải là vấn đề đối với chính luồng thời gian thực, nhưng
    nó có khả năng khiến CPU mất đi công việc quan trọng khác trong thời gian thực.

Các nhà phát triển ứng dụng có thể cố tình chọn để có ứng dụng thời gian thực của họ
ngủ theo cách không an toàn trong thời gian thực. Người ta đang tranh cãi liệu đó có phải là một
vấn đề. Các nhà phát triển ứng dụng phải phân tích các cảnh báo để đưa ra quyết định phù hợp
đánh giá.

Thông số kỹ thuật của màn hình là::

RULE = luôn luôn ((RT và SLEEP) ngụ ý (RT_FRIENDLY_SLEEP hoặc ALLOWLIST))

RT_FRIENDLY_SLEEP = (RT_VALID_SLEEP_REASON hoặc KERNEL_THREAD)
                  và ((không phải WAKE) cho đến RT_FRIENDLY_WAKE)

RT_VALID_SLEEP_REASON = FUTEX_WAIT
                       hoặc RT_FRIENDLY_NANOSLEEP

RT_FRIENDLY_NANOSLEEP = CLOCK_NANOSLEEP
                      và NANOSLEEP_TIMER_ABSTIME
                      và NANOSLEEP_CLOCK_MONOTONIC

RT_FRIENDLY_WAKE = WOKEN_BY_EQUAL_OR_HIGHER_PRIO
                  hoặc WOKEN_BY_HARDIRQ
                  hoặc WOKEN_BY_NMI
                  hoặc KTHREAD_SHOULD_STOP

ALLOWLIST = BLOCK_ON_RT_MUTEX
           hoặc FUTEX_LOCK_PI
           hoặc TASK_IS_RCU
           hoặc TASK_IS_MIGRATION

Ngoài các tình huống được mô tả ở trên, đặc tả này còn xử lý một số
trường hợp đặc biệt:

- ZZ0000ZZ: tác vụ kernel không có bất kỳ mẫu nào có thể nhận dạng được
    như lý do ngủ hợp lệ theo thời gian thực. Vì thế lý do ngủ không phải là
    đã kiểm tra các tác vụ kernel.
  - ZZ0001ZZ: một luồng không phải thời gian thực có thể dừng kernel thời gian thực
    thread bằng cách đánh thức nó và đợi nó thoát ra (ZZ0002ZZ). Cái này
    Wakeup là an toàn cho thời gian thực.
  - ZZ0003ZZ: để xử lý các kết quả dương tính giả đã biết với kernel.
  - ZZ0004ZZ được đưa vào danh sách cho phép do việc triển khai nó.
    Trong đường dẫn phát hành của rt_mutex, tác vụ được tăng cường sẽ bị hủy tăng cường trước khi thức dậy
    người phục vụ của rt_mutex. Do đó, màn hình có thể nhìn thấy thông tin không an toàn trong thời gian thực
    đánh thức (ví dụ: tác vụ không theo thời gian thực đánh thức tác vụ theo thời gian thực). Đây thực sự là
    an toàn theo thời gian thực vì quyền ưu tiên bị vô hiệu hóa trong suốt thời gian.
  - ZZ0005ZZ được đưa vào danh sách cho phép với lý do tương tự như
    ZZ0006ZZ.
