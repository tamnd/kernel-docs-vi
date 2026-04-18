.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/sound/soc/pops-clicks.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

==============================
Âm thanh bật lên và nhấp chuột
==============================

Tiếng bật và tiếng click là các tạo tác âm thanh không mong muốn do việc tăng và giảm nguồn điện
của các thành phần trong hệ thống con âm thanh. Điều này dễ nhận thấy trên PC khi một
mô-đun âm thanh được tải hoặc không được tải (tại thời điểm tải mô-đun, card âm thanh sẽ được
bật nguồn và gây ra tiếng kêu bốp trên loa).

Tiếng bật và tiếng nhấp chuột có thể xảy ra thường xuyên hơn trên các hệ thống di động có DAPM. Đây là
bởi vì các thành phần trong hệ thống con đang được cung cấp năng lượng động
tùy thuộc vào cách sử dụng âm thanh và điều này sau đó có thể gây ra tiếng bật nhỏ hoặc
nhấp chuột mỗi khi trạng thái nguồn thành phần được thay đổi.


Giảm thiểu số lần nhấp và nhấp chuột phát lại
===================================

Không thể loại bỏ hoàn toàn hiện tượng phát lại trong hệ thống con âm thanh di động
Tuy nhiên, hiện tại, phần cứng codec âm thanh trong tương lai sẽ có tính năng bật và nhấp tốt hơn
đàn áp.  Có thể giảm tiếng pop khi phát lại bằng cách cấp nguồn cho âm thanh
thành phần theo một thứ tự cụ thể. Thứ tự này khác nhau khi khởi động và
tắt máy và tuân theo một số quy tắc cơ bản: -
::

Thứ tự khởi động: - DAC --> Bộ trộn --> Đầu ra PGA --> Bật tiếng kỹ thuật số
  
Thứ tự tắt máy:- Tắt tiếng kỹ thuật số --> Đầu ra PGA --> Bộ trộn --> DAC

Điều này giả định rằng đường dẫn đầu ra codec PCM từ DAC được thông qua một bộ trộn và sau đó
PGA (bộ khuếch đại khuếch đại có thể lập trình) trước khi xuất ra loa.


Giảm thiểu số lần chụp và nhấp chuột
==================================

Việc loại bỏ các hiện vật bị bắt giữ có phần dễ dàng hơn vì chúng ta có thể trì hoãn việc kích hoạt
ADC cho đến khi tất cả các cửa sổ bật lên xuất hiện. Điều này tuân theo các quy tắc quyền lực tương tự như
phát lại trong các thành phần đó được cấp nguồn theo trình tự tùy thuộc vào luồng
khởi động hoặc tắt máy.
::

Thứ tự khởi động - Đầu vào PGA --> Bộ trộn --> ADC
  
Lệnh tắt máy - ADC --> Bộ trộn --> Đầu vào PGA


Tiếng ồn của dây kéo
============
Tiếng ồn dây kéo không mong muốn có thể xảy ra trong quá trình phát lại hoặc ghi âm thanh
khi điều khiển âm lượng được thay đổi gần giá trị khuếch đại tối đa của nó. Tiếng ồn của dây kéo
được nghe thấy khi mức tăng hoặc giảm mức tăng làm thay đổi tín hiệu âm thanh trung bình
biên độ quá nhanh. Nó có thể được giảm thiểu bằng cách bật cài đặt chéo bằng 0
cho mỗi điều khiển âm lượng. ZC buộc sự thay đổi độ lợi xảy ra khi tín hiệu
đi qua đường biên độ bằng không.
