.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/virt/kvm/arm/ptp_kvm.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

Hỗ trợ PTP_KVM cho cánh tay/cánh tay64
======================================

PTP_KVM được sử dụng để đồng bộ hóa thời gian có độ chính xác cao giữa máy chủ và khách.
Nó dựa vào việc chuyển đồng hồ treo tường và giá trị bộ đếm từ
lưu trữ cho khách bằng cách sử dụng hypercall dành riêng cho KVM.

ZZ0000ZZ
----------------------------------------

Truy xuất thông tin thời gian hiện tại cho bộ đếm cụ thể. không có
hạn chế về độ bền.

+----------------------+-------------------------------------------------------+
ZZ0003ZZ Tùy chọn |
+----------------------+-------------------------------------------------------+
ZZ0004ZZ HVC32 |
+----------------------+----------+------------------------------------------+
ZZ0005ZZ (uint32) ZZ0006ZZ
+-------------+----------+------+---------------------------------------+
ZZ0007ZZ (uint32) ZZ0008ZZ ZZ0000ZZ |
ZZ0009ZZ |    +---------------------------------------+
ZZ0010ZZ ZZ0011ZZ ZZ0001ZZ |
+-------------+----------+------+---------------------------------------+
ZZ0012ZZ (int32) ZZ0013ZZ ZZ0002ZZ bị lỗi, khác |
ZZ0014ZZ ZZ0015ZZ trên 32 bit của đồng hồ treo tường thời gian |
|                     +----------+----+---------------------------------------+
ZZ0016ZZ (uint32) ZZ0017ZZ Thời gian đồng hồ treo tường thấp hơn 32 bit |
|                     +----------+----+---------------------------------------+
ZZ0018ZZ (uint32) ZZ0019ZZ 32 bit trên của bộ đếm |
|                     +----------+----+---------------------------------------+
ZZ0020ZZ (uint32) ZZ0021ZZ Bộ đếm thấp hơn 32 bit |
+-------------+----------+------+---------------------------------------+