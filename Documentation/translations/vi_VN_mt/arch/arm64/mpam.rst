.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/arch/arm64/mpam.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

====
MPAM
====

MPAM là gì
============
MPAM (Phân vùng và giám sát bộ nhớ) là một tính năng trong CPU và bộ nhớ
các thành phần hệ thống như bộ nhớ đệm hoặc bộ điều khiển bộ nhớ cho phép bộ nhớ
lưu lượng truy cập được dán nhãn, phân vùng và giám sát.

Lưu lượng truy cập được gắn nhãn bởi CPU, dựa trên nhóm điều khiển hoặc giám sát
nhiệm vụ hiện tại được giao cho việc sử dụng resctrl.  Chính sách phân vùng có thể được thiết lập
sử dụng tệp lược đồ trong resctrl và theo dõi các giá trị được đọc qua resctrl.
Xem Tài liệu/hệ thống tập tin/resctrl.rst để biết thêm chi tiết.

Điều này cho phép các tác vụ chia sẻ tài nguyên hệ thống bộ nhớ, chẳng hạn như bộ đệm, được thực hiện
cách ly với nhau theo chính sách phân vùng (gọi là ồn ào
hàng xóm).

Nền tảng được hỗ trợ
===================
Việc sử dụng tính năng này cần có sự hỗ trợ của CPU, hỗ trợ trong hệ thống bộ nhớ
các thành phần và mô tả từ chương trình cơ sở về nơi điều khiển thiết bị MPAM
nằm trong không gian địa chỉ MMIO. (ví dụ: bảng 'MPAM' ACPI).

Thiết bị MMIO cung cấp bộ điều khiển/giám sát MPAM cho hệ thống bộ nhớ
thành phần này được gọi là thành phần hệ thống bộ nhớ. (MSC).

Vì giao diện người dùng của MPAM là thông qua resctrl nên chỉ có các tính năng của MPAM là được
tương thích với resctrl có thể được hiển thị trong không gian người dùng.

MSC được coi là một nhóm dựa trên cấu trúc liên kết. MSC tương ứng với
bộ đệm L3 được xem xét cùng nhau, không thể trộn MSC giữa L2
và L3 để 'che' lược đồ resctrl.

Các tính năng được hỗ trợ là:

* Điều khiển bitmap phần bộ đệm (CPOR) trên bộ đệm L2 hoặc L3.  Để lộ
  CPOR ở L2 hoặc L3, mỗi CPU phải có bộ nhớ đệm CPU tương ứng lúc này
  cấp độ cũng hỗ trợ tính năng này.  Nền tảng lớn/nhỏ không khớp nhau
  không được hỗ trợ vì các điều khiển của resctrl sau đó cũng sẽ phụ thuộc vào tác vụ
  vị trí.

* Điều khiển tối đa băng thông bộ nhớ (MBW_MAX) trên hoặc sau bộ đệm L3.
  resctrl sử dụng L3 cache-id để xác định vị trí băng thông bộ nhớ
  điều khiển được áp dụng. Vì lý do này, nền tảng phải có bộ đệm L3
  với cache-id được cung cấp bởi phần sụn. (Không cần hỗ trợ MPAM.)

Để được xuất dưới dạng lược đồ 'MB', cấu trúc liên kết của nhóm MSC đã được chọn
  phải phù hợp với cấu trúc liên kết của bộ đệm L3 để có thể sử dụng id bộ đệm
  sơn lại. Ví dụ: Nền tảng có điều khiển tối đa băng thông bộ nhớ
  trên các nút NUMA không có CPU không thể hiển thị lược đồ 'MB' thành resctrl như sau
  các nút không có bộ đệm L3 tương ứng. Nếu băng thông bộ nhớ
  điều khiển nằm trên bộ nhớ chứ không phải L3 thì phải có một
  L3 toàn cầu nếu không thì không biết lưu lượng truy cập đến từ L3 nào. Ở đó
  không được có bộ đệm giữa L3 và bộ nhớ để hai đầu của
  đường dẫn có lưu lượng truy cập tương đương.

Khi trình điều khiển MPAM tìm thấy nhiều nhóm MSC, nó có thể sử dụng cho 'MB'
  lược đồ, nó ưu tiên nhóm gần nhất với bộ đệm L3.

* Bộ đếm Mức sử dụng bộ nhớ đệm (CSU) có thể hiển thị 'llc_occupancy' được cung cấp
  có ít nhất một màn hình CSU trên mỗi MSC tạo nên nhóm L3.
  Không hỗ trợ hiển thị bộ đếm CSU từ bộ nhớ đệm hoặc thiết bị khác.

Báo cáo lỗi
==============
Nếu bạn không nhìn thấy bộ đếm hoặc bộ điều khiển mà bạn mong đợi, vui lòng chia sẻ
thông báo gỡ lỗi được tạo khi bật gỡ lỗi động và khởi động với:
dyndbg="file mpam_resctrl.c +pl"