.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/infiniband/core_locking.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

==============================
Khóa lớp giữa InfiniBand
===========================

Hướng dẫn này là một nỗ lực để làm rõ các giả định khóa
  được thực hiện bởi lớp giữa của InfiniBand.  Nó mô tả các yêu cầu về
  cả trình điều khiển cấp thấp nằm bên dưới lớp giữa và lớp trên
  các giao thức sử dụng lớp giữa.

Bối cảnh ngủ và gián đoạn
==============================

Với các ngoại lệ sau đây, việc triển khai trình điều khiển cấp thấp của
  tất cả các phương thức trong struct ib_device có thể ở chế độ ngủ.  Những ngoại lệ
  có bất kỳ phương pháp nào trong danh sách:

- tạo_ah
    - sửa đổi_ah
    - truy vấn_ah
    - tiêu diệt_ah
    - gửi_gửi
    - post_recv
    - thăm dò ý kiến_cq
    - req_notify_cq

có thể không ngủ và phải có thể gọi được từ bất kỳ ngữ cảnh nào.

Các chức năng tương ứng được xuất sang giao thức cấp trên
  người tiêu dùng:

- rdma_create_ah
    -rdma_modify_ah
    -rdma_query_ah
    - rdma_destroy_ah
    - ib_post_send
    - ib_post_recv
    - ib_req_notify_cq

do đó an toàn để gọi từ bất kỳ bối cảnh nào.

Ngoài ra, chức năng

- ib_dispatch_event

được sử dụng bởi trình điều khiển cấp thấp để gửi các sự kiện không đồng bộ thông qua
  lớp giữa cũng an toàn để gọi từ bất kỳ bối cảnh nào.

Tái nhập
----------

Tất cả các phương thức trong struct ib_device được xuất bởi cấp độ thấp
  người lái xe phải được quay lại đầy đủ.  Trình điều khiển cấp thấp được yêu cầu
  thực hiện tất cả sự đồng bộ hóa cần thiết để duy trì tính nhất quán, thậm chí
  nếu nhiều lệnh gọi hàm sử dụng cùng một đối tượng được chạy
  đồng thời.

Lớp giữa IB không thực hiện bất kỳ việc tuần tự hóa các lệnh gọi hàm nào.

Bởi vì trình điều khiển cấp thấp được cấp lại, giao thức cấp cao hơn
  người tiêu dùng không bắt buộc phải thực hiện bất kỳ việc xê-ri hóa nào.  Tuy nhiên,
  một số tuần tự hóa có thể được yêu cầu để có được kết quả hợp lý.  cho
  ví dụ: người tiêu dùng có thể gọi ib_poll_cq() một cách an toàn trên nhiều CPU
  đồng thời.  Tuy nhiên, thứ tự hoàn thành công việc
  thông tin giữa các cuộc gọi khác nhau của ib_poll_cq() không được xác định.

Cuộc gọi lại
---------

Trình điều khiển cấp thấp không được thực hiện lệnh gọi lại trực tiếp từ
  chuỗi cuộc gọi giống như lệnh gọi phương thức ib_device.  Ví dụ, nó không phải là
  được phép trình điều khiển cấp thấp gọi sự kiện hoàn thành của người tiêu dùng
  xử lý trực tiếp từ phương thức post_send của nó.  Thay vào đó, cấp độ thấp
  người lái xe nên trì hoãn cuộc gọi lại này bằng cách, ví dụ: lên lịch
  tasklet để thực hiện gọi lại.

Trình điều khiển cấp thấp có trách nhiệm đảm bảo rằng nhiều
  trình xử lý sự kiện hoàn thành cho cùng một CQ không được gọi
  đồng thời.  Người lái xe phải đảm bảo chỉ có một sự kiện CQ
  trình xử lý cho một CQ nhất định đang chạy tại một thời điểm.  Nói cách khác, sự
  tình huống sau đây không được phép::

CPU1 CPU2

trình điều khiển cấp thấp ->
      gọi lại sự kiện CQ của người tiêu dùng:
        /* ... */
        ib_req_notify_cq(cq, ...);
                                          trình điều khiển cấp thấp ->
        /* ... */ gọi lại sự kiện CQ của người tiêu dùng:
                                              /* ... */
        trả về từ trình xử lý sự kiện CQ

Bối cảnh trong đó sự kiện hoàn thành và sự kiện không đồng bộ
  cuộc gọi lại chạy không được xác định.  Tùy thuộc vào trình điều khiển cấp thấp, nó
  có thể là bối cảnh quá trình, bối cảnh softirq hoặc bối cảnh ngắt.
  Người tiêu dùng giao thức cấp cao hơn có thể không ngủ trong cuộc gọi lại.

Cắm nóng
--------

Trình điều khiển cấp thấp thông báo rằng thiết bị đã sẵn sàng để sử dụng bởi
  người tiêu dùng khi nó gọi ib_register_device(), tất cả khởi tạo
  phải hoàn tất trước cuộc gọi này.  Thiết bị phải vẫn có thể sử dụng được
  cho đến khi lệnh gọi tới ib_unregister_device() của trình điều khiển được trả về.

Trình điều khiển cấp thấp phải gọi ib_register_device() và
  ib_unregister_device() từ ngữ cảnh quá trình.  Nó không được giữ bất kỳ
  các ngữ nghĩa có thể gây ra bế tắc nếu người tiêu dùng gọi lại
  người lái xe thực hiện các cuộc gọi này.

Người tiêu dùng giao thức cấp cao hơn có thể bắt đầu sử dụng thiết bị IB như
  ngay sau khi phương thức add của struct ib_client của nó được gọi cho điều đó
  thiết bị.  Người tiêu dùng phải hoàn thành tất cả việc dọn dẹp và giải phóng tất cả tài nguyên
  liên quan đến một thiết bị trước khi quay lại từ phương thức xóa.

Người tiêu dùng được phép ngủ trong các phương thức thêm và xóa của nó.
