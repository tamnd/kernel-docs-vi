.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/accounting/cgroupstats.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

===============================
Kiểm soát số liệu thống kê nhóm
===============================

Control Groupstats được lấy cảm hứng từ cuộc thảo luận tại
ZZ0000ZZ và thực hiện thống kê trên mỗi nhóm như
được đề xuất bởi Andrew Morton trong ZZ0001ZZ

Cơ sở hạ tầng thống kê của mỗi nhóm sử dụng lại mã từ taskstats
giao diện. Một tập hợp các hoạt động cgroup mới được đăng ký bằng các lệnh
và các thuộc tính cụ thể cho các nhóm. Sẽ rất dễ dàng để
mở rộng số liệu thống kê trên mỗi nhóm, bằng cách thêm thành viên vào cgroupstats
cấu trúc.

Mô hình hiện tại của cgroupstats là mô hình kéo, mô hình đẩy (để đăng
số liệu thống kê về các sự kiện thú vị), nên rất dễ dàng để thêm vào. Hiện tại
yêu cầu không gian người dùng để thống kê bằng cách chuyển đường dẫn cgroup.
Thống kê về trạng thái của tất cả các tác vụ trong nhóm được trả về
không gian người dùng.

NOTE: Hiện tại chúng tôi dựa vào tính toán độ trễ để trích xuất thông tin
về các tác vụ bị chặn trên I/O. Nếu CONFIG_TASK_DELAY_ACCT bị tắt, điều này
thông tin sẽ không có sẵn.

Để trích xuất số liệu thống kê của nhóm, một tiện ích rất giống với getdelays.c
đã được phát triển, đầu ra mẫu của tiện ích này được hiển thị bên dưới::

~/balbir/cgroupstats # ./getdelays -C "/sys/fs/cgroup/a"
  đang ngủ 1, bị chặn 0, đang chạy 1, đã dừng 0, không bị gián đoạn 0
  ~/balbir/cgroupstats # ./getdelays -C "/sys/fs/cgroup"
  ngủ 155, chặn 0, chạy 1, dừng 0, liên tục 2
