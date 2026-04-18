.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/driver-api/hw-recoverable-errors.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=======================================================
Theo dõi lỗi phần cứng có thể phục hồi trong vmcoreinfo
=======================================================

Tổng quan
--------

Tính năng này cung cấp cơ sở hạ tầng chung trong nhân Linux để theo dõi
và ghi lại các lỗi phần cứng có thể phục hồi được. Đây là những lỗi phần cứng có thể phục hồi được
có thể nhìn thấy được nhưng có thể không gây hoảng loạn ngay lập tức nhưng có thể ảnh hưởng đến sức khỏe, chủ yếu là
vì đường dẫn mã mới sẽ được thực thi trong kernel.

Bằng cách ghi lại số lượng và dấu thời gian của các lỗi có thể phục hồi vào vmcoreinfo
ghi chú kết xuất sự cố, cơ sở hạ tầng này hỗ trợ các công cụ phân tích sự cố sau khi chết trong
tương quan các sự kiện phần cứng với lỗi kernel. Điều này cho phép phân loại nhanh hơn
và hiểu rõ hơn về nguyên nhân gốc rễ, đặc biệt là trong đám mây quy mô lớn
môi trường thường gặp các vấn đề về phần cứng.

Những lợi ích
--------

- Tạo điều kiện thuận lợi cho mối tương quan giữa các lỗi có thể phục hồi được phần cứng với lỗi kernel hoặc
  đường dẫn mã bất thường dẫn đến sự cố hệ thống.
- Cung cấp thông tin chi tiết nhanh chóng cho các nhà khai thác và nhà cung cấp đám mây, cải thiện độ tin cậy
  và giảm thời gian xử lý sự cố.
- Bổ sung chẩn đoán phần cứng đầy đủ hiện có mà không cần thay thế chúng.

Tiếp xúc và tiêu thụ dữ liệu
-----------------------------

- Dữ liệu lỗi được theo dõi bao gồm số lượng mỗi loại lỗi và dấu thời gian của
  lần xuất hiện cuối cùng.
- Dữ liệu này được lưu trữ trong mảng ZZ0000ZZ, được phân loại theo nguồn lỗi
  các loại như CPU, bộ nhớ, PCI, CXL và các loại khác.
- Nó được hiển thị thông qua ghi chú kết xuất sự cố vmcoreinfo và có thể được đọc bằng các công cụ
  như ZZ0001ZZ, ZZ0002ZZ hoặc các tiện ích phân tích sự cố hạt nhân khác.
- Không có cách nào khác để đọc những dữ liệu này ngoài việc từ các bãi chứa sự cố.
- Các lỗi này được chia theo khu vực, bao gồm CPU, Memory, PCI, CXL và
  những người khác.

Ví dụ sử dụng điển hình (trong drgn REPL):

.. code-block:: python

    >>> prog['hwerror_data']
    (struct hwerror_info[HWERR_RECOV_MAX]){
        {
            .count = (int)844,
            .timestamp = (time64_t)1752852018,
        },
        ...
    }

Kích hoạt
--------

- Tính năng này được kích hoạt khi cài đặt CONFIG_VMCORE_INFO.
