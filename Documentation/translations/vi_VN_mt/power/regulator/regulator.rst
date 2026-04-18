.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/power/regulator/regulator.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

========================================
Giao diện trình điều khiển bộ điều chỉnh
========================================

Giao diện trình điều khiển bộ điều chỉnh tương đối đơn giản và được thiết kế để cho phép
trình điều khiển để đăng ký dịch vụ của họ với khung cốt lõi.


Sự đăng ký
============

Người lái xe có thể đăng ký bộ điều chỉnh bằng cách gọi::

cấu trúc điều chỉnh_dev *regulator_register(struct regulator_desc *regulator_desc,
					   const struct điều chỉnh_config *config);

Điều này sẽ đăng ký khả năng và hoạt động của cơ quan quản lý cho cơ quan quản lý
cốt lõi.

Người quản lý có thể được hủy đăng ký bằng cách gọi::

void điều chỉnh_unregister(struct điều chỉnh_dev *rdev);


Sự kiện điều chỉnh
==================

Bộ điều chỉnh có thể gửi các sự kiện (ví dụ: quá nhiệt độ, điện áp thấp, v.v.) tới
trình điều khiển tiêu dùng bằng cách gọi::

int điều chỉnh_notifier_call_chain(struct điều chỉnh_dev *rdev,
				    sự kiện dài không dấu, void *data);
