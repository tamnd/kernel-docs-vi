.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/driver-api/cxl/allocation/reclaim.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=======
Đòi lại
=======
Một cách khác có thể sử dụng bộ nhớ CXL ZZ0002ZZ là thông qua hệ thống thu hồi
trong ZZ0000ZZ.  Reclaim được kích hoạt khi dung lượng bộ nhớ trên hệ thống
trở nên bị áp lực dựa trên cài đặt ZZ0001ZZ toàn cầu và nhóm cục bộ.

Trong phần này chúng ta sẽ không thảo luận về cấu hình ZZ0000ZZ mà chỉ thảo luận về cách CXL
bộ nhớ có thể được sử dụng bởi nhiều phần khác nhau của hệ thống thu hồi.

giáng chức
==========
Theo mặc định, hệ thống lấy lại sẽ ưu tiên trao đổi (hoặc zswap) khi lấy lại
trí nhớ.  Kích hoạt ZZ0000ZZ sẽ gây ra vmscan
có cơ hội thích các nút NUMA ở xa để trao đổi hoặc zswap, nếu dung lượng
có sẵn.

Việc hạ cấp tham gia vào thành phần ZZ0000ZZ để xác định
nút giáng chức tiếp theo.  Nút giáng chức tiếp theo dựa trên ZZ0001ZZ
hoặc dữ liệu hiệu suất ZZ0002ZZ.

cpusets.mems_allowed không đúng
-------------------------------
Trong Linux v6.15 trở xuống, việc giáng chức không tôn trọng ZZ0000ZZ
khi di chuyển các trang.  Kết quả là nếu kích hoạt chức năng giáng cấp, vmscan không thể
đảm bảo cách ly bộ nhớ của vùng chứa khỏi các nút không được đặt trong mems_allowed.

Trong Linux v6.XX trở lên, việc giáng chức cố gắng tôn trọng
ZZ0000ZZ; tuy nhiên, một số loại bộ nhớ dùng chung nhất định
ban đầu được khởi tạo bởi một nhóm khác (chẳng hạn như các thư viện chung - ví dụ:
libc) vẫn có thể bị giáng cấp.  Kết quả là giao diện mems_allowed vẫn
không thể cung cấp sự cách ly hoàn hảo với các nút từ xa.

Tùy chọn ZSwap và nút
=========================
Trong Linux v6.15 trở xuống, ZSwap phân bổ bộ nhớ từ nút cục bộ của
bộ xử lý cho các trang mới được nén.  Vì các trang được nén
thường lạnh, kết quả là một trang lạnh sẽ được thăng cấp - chỉ để
sau đó sẽ bị giáng chức khi nó già đi so với LRU.

Trong Linux v6.XX, ZSwap cố gắng ưu tiên nút của trang được nén hơn
làm mục tiêu phân bổ cho trang nén.  Điều này giúp ngăn ngừa
đập phá.

Hạ chức với ZSwap
===================
Khi kích hoạt cả Demotion và ZSwap, bạn sẽ tạo ra một tình huống trong đó ZSwap
theo mặc định sẽ thích dạng bộ nhớ CXL chậm nhất cho đến khi cấp bộ nhớ đó
bộ nhớ đã cạn kiệt.