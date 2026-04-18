.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/networking/pse-pd/introduction.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

Thiết bị cấp nguồn (PSE) theo tiêu chuẩn IEEE 802.3
=====================================================

Tổng quan
--------

Thiết bị cung cấp điện (PSE) rất cần thiết trong các mạng để cung cấp điện
cùng với dữ liệu qua cáp Ethernet. Nó thường đề cập đến các thiết bị như
thiết bị chuyển mạch và trung tâm cung cấp điện cho Thiết bị được cấp nguồn (PD) như IP
máy ảnh, điện thoại VoIP và các điểm truy cập không dây.

PSE so với PoDL PSE
----------------

PSE trong tiêu chuẩn IEEE 802.3 thường đề cập đến thiết bị cung cấp
cấp nguồn cùng với dữ liệu qua cáp Ethernet, thường được liên kết với Cấp nguồn qua
Ethernet (PoE).

PoDL PSE, hoặc Power over Data Lines PSE, biểu thị cụ thể các PSE hoạt động
với PHY cặp xoắn cân bằng đơn, theo Điều 104 của IEEE 802.3. PoDL
rất có ý nghĩa trong các bối cảnh như điều khiển ô tô và công nghiệp, nơi nguồn điện
và việc phân phối dữ liệu qua một cặp là thuận lợi.

Phụ lục IEEE 802.3-2018 và các điều khoản liên quan
---------------------------------------------

Phụ lục chính của tiêu chuẩn IEEE 802.3-2018 liên quan đến việc cung cấp điện qua
Ethernet như sau:

- ZZ0000ZZ: Được biết đến là PoE trên thị trường, được trình bày chi tiết trong
  Điều 33, cung cấp công suất lên tới 15,4W.
- ZZ0001ZZ: Được bán trên thị trường dưới dạng PoE+, nâng cao khả năng PoE
  được đề cập trong Điều 33, tăng công suất cung cấp lên tới 30W.
- ZZ0002ZZ: Được biết đến với cái tên 4PPoE trên thị trường, được nêu tên
  tại Điều 33. Loại 3 cung cấp công suất lên tới 60W và Loại 4 cung cấp công suất lên tới 100W.
- ZZ0003ZZ: Trước đây gọi là PoDL, chi tiết
  trong Điều 104. Giới thiệu Lớp 0 - 9. PoDL PSE Lớp 9 cung cấp công suất lên tới ~65W

Khuyến nghị quy ước đặt tên hạt nhân
----------------------------------------

Để rõ ràng và nhất quán trong hệ thống con mạng của nhân Linux,
quy ước đặt tên sau đây được khuyến khích:

- Đối với mã PSE (PoE) thông thường sử dụng từ khóa “c33_pse”. Ví dụ:
  ZZ0000ZZ.
  Điều này phù hợp với Điều 33, bao gồm nhiều dạng PoE khác nhau.

- Đối với PoDL PSE - mã cụ thể, sử dụng "podl_pse". Ví dụ:
  ZZ0000ZZ để phân biệt
  Cài đặt PoDL PSE theo Điều 104.

Tóm tắt Điều 33: Cấp nguồn cho Thiết bị đầu cuối dữ liệu (DTE) qua Giao diện phụ thuộc phương tiện (MDI)
---------------------------------------------------------------------------------------------

Điều 33 của tiêu chuẩn IEEE 802.3 xác định chức năng và điện
đặc điểm của Thiết bị cấp nguồn (PD) và Thiết bị cấp nguồn (PSE).
Các thực thể này cho phép phân phối điện bằng cách sử dụng cùng một hệ thống cáp chung như đối với dữ liệu.
truyền tải, tích hợp năng lượng với truyền dữ liệu cho các thiết bị như
10BASE-T, 100BASE-TX hoặc 1000BASE-T.

Tóm tắt Điều 104: Cấp nguồn qua đường dữ liệu (PoDL) của Ethernet xoắn đôi cân bằng đơn
--------------------------------------------------------------------------------------------

Điều 104 của tiêu chuẩn IEEE 802.3 mô tả chức năng và điện
đặc điểm của Thiết bị cấp nguồn PoDL (PD) và Thiết bị cấp nguồn PoDL
(PSE). Chúng được thiết kế để sử dụng với Ethernet cặp xoắn cân bằng đơn
Các lớp vật lý Trong điều khoản này, 'PSE' đề cập cụ thể đến PoDL PSE và
'PD' tới PoDL PD. Mục đích chính là cung cấp cho các thiết bị một giao diện thống nhất
cho cả dữ liệu và năng lượng cần thiết để xử lý dữ liệu này qua một lần
kết nối Ethernet xoắn đôi cân bằng.