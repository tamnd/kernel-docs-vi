.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/userspace-api/tee.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. tee:

================================================================
TEE (Môi trường thực thi đáng tin cậy) Không gian người dùng API
================================================================

include/uapi/linux/tee.h xác định giao diện chung cho TEE.

Không gian người dùng (máy khách) kết nối với trình điều khiển bằng cách mở /dev/tee[0-9]* hoặc
/dev/teepriv[0-9]*.

- TEE_IOC_SHM_ALLOC phân bổ bộ nhớ dùng chung và trả về bộ mô tả tệp
  không gian người dùng nào có thể mmap. Khi không gian người dùng không cần tệp
  mô tả nữa, nó sẽ bị đóng lại. Khi không cần bộ nhớ dùng chung
  nữa, nó sẽ không được ánh xạ bằng munmap() để cho phép sử dụng lại
  trí nhớ.

- TEE_IOC_VERSION cho phép không gian người dùng biết TEE mà trình điều khiển này xử lý và
  khả năng của nó.

- TEE_IOC_OPEN_SESSION mở phiên mới cho Ứng dụng đáng tin cậy.

- TEE_IOC_INVOKE gọi một chức năng trong Ứng dụng đáng tin cậy.

- TEE_IOC_CANCEL có thể hủy TEE_IOC_OPEN_SESSION hoặc TEE_IOC_INVOKE đang diễn ra.

- TEE_IOC_CLOSE_SESSION đóng phiên đối với Ứng dụng đáng tin cậy.

Có hai loại khách hàng, khách hàng bình thường và khách hàng. Cái sau là
một quy trình trợ giúp để TEE truy cập các tài nguyên trong Linux, ví dụ như tệp
truy cập hệ thống. Một máy khách bình thường mở /dev/tee[0-9]* và một máy khách mở ra
/dev/teepriv[0-9].

Phần lớn giao tiếp giữa máy khách và TEE không rõ ràng đối với
người lái xe. Công việc chính của người lái xe là nhận yêu cầu từ phía
khách hàng, chuyển tiếp chúng tới TEE và gửi lại kết quả. Trong trường hợp của
yêu cầu giao tiếp đi theo hướng khác, TEE sẽ gửi
yêu cầu người cầu xin sau đó gửi lại kết quả.