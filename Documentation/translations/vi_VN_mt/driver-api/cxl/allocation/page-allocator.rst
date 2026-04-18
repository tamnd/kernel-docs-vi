.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/driver-api/cxl/allocation/page-allocator.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

====================
Bộ cấp phát trang
====================

Bộ cấp phát trang kernel phục vụ tất cả các yêu cầu cấp phát trang chung, chẳng hạn như
như ZZ0000ZZ.  Các bước cấu hình CXL ảnh hưởng đến hoạt động của trang
bộ cấp phát dựa trên ZZ0001ZZ và ZZ0002ZZ đã chọn, dung lượng là
được đặt vào.

Phần này chủ yếu tập trung vào cách các cấu hình này ảnh hưởng đến trang
bộ cấp phát (kể từ Linux v6.15) thay vì hành vi cấp phát trang tổng thể.

Các nút và chính sách ghi nhớ NUMA
========================
Trừ khi một tác vụ đăng ký rõ ràng một chính sách ghi nhớ, chính sách bộ nhớ mặc định
của nhân linux là phân bổ bộ nhớ từ ZZ0000ZZ trước tiên,
và chỉ quay trở lại các nút khác nếu nút cục bộ bị áp lực.

Nói chung, chúng tôi mong đợi sẽ thấy bộ nhớ DRAM và CXL cục bộ trên các nút NUMA riêng biệt,
với bộ nhớ CXL không cục bộ.  Tuy nhiên, về mặt kỹ thuật, có thể
để một nút điện toán không có DRAM cục bộ và để bộ nhớ CXL là
Dung lượng ZZ0000ZZ cho nút điện toán đó.


Vùng bộ nhớ
============
Dung lượng CXL có thể được trực tuyến trong ZZ0000ZZ hoặc ZZ0001ZZ.

Kể từ v6.15, bộ cấp phát trang cố gắng phân bổ từ mức cao nhất
ZONE có sẵn và tương thích để phân bổ từ nút cục bộ trước tiên.

Một ví dụ về ZZ0003ZZ đang cố gắng phục vụ phân bổ
được đánh dấu ZZ0000ZZ từ ZZ0001ZZ.  Phân bổ hạt nhân là
thường không thể di chuyển được và do đó chỉ có thể được phục vụ từ
ZZ0002ZZ hoặc thấp hơn.

Để đơn giản hóa việc này, bộ cấp phát trang sẽ ưu tiên ZZ0000ZZ hơn
ZZ0001ZZ theo mặc định, nhưng nếu ZZ0002ZZ cạn kiệt, nó
sẽ dự phòng để phân bổ từ ZZ0003ZZ.


CGroup và CPUSets
===================
Cuối cùng, giả sử bộ nhớ CXL có thể truy cập được thông qua phân bổ trang (tức là trực tuyến
trong ZZ0000ZZ), ZZ0001ZZ có thể được sử dụng bởi
vùng chứa để hạn chế khả năng truy cập của một số nút NUMA nhất định cho các tác vụ trong đó
thùng chứa.  Người dùng có thể muốn sử dụng điều này trong các hệ thống nhiều người thuê, nơi một số
nhiệm vụ không muốn sử dụng bộ nhớ chậm hơn.

Trong phần lấy lại chúng ta sẽ thảo luận về một số hạn chế của giao diện này đối với
ngăn chặn việc giảm hạng dữ liệu được chia sẻ vào bộ nhớ CXL (nếu bật giảm hạng).
