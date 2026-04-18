.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/sound/hd-audio/realtek-pc-beep.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

==================================
Realtek PC Beep Đăng ký ẩn
===============================

Tệp này ghi lại "Thanh ghi ẩn tiếng bíp của PC", hiện có trong một số
Bộ giải mã Realtek HDA và điều khiển bộ trộn và cặp bộ trộn chuyển tiếp có thể
định tuyến âm thanh giữa các chân nhưng bản thân chúng không được hiển thị dưới dạng tiện ích HDA. xa như vậy
như tôi có thể nói, những tuyến đường ẩn này được thiết kế để cho phép phát ra tiếng bíp PC linh hoạt
dành cho các codec không có tiện ích bộ trộn trong đường dẫn đầu ra của chúng. Tại sao nó dễ dàng hơn
để ẩn một máy trộn đằng sau một sổ đăng ký nhà cung cấp không có giấy tờ hơn là chỉ để lộ nó
như một vật dụng, tôi không biết.

Đăng ký mô tả
====================

Thanh ghi được truy cập thông qua hệ số xử lý 0x36 trên NID 20h. Bit không
được xác định bên dưới không có ảnh hưởng rõ rệt đến máy của tôi, Dell XPS 13 9350::

MSB LSB
  +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
  ZZ0000Zh|S|L|         | B ZZ0003ZZ | Bit đã biết
  +=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+
  ZZ0004ZZ0ZZ0005ZZ1ZZ0006ZZ0ZZ0007ZZ1ZZ0008ZZ Giá trị đặt lại
  +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+

Chọn đầu vào 1Ah (B): 2 bit
  Khi bằng 0, hãy hiển thị dòng Bíp PC (từ bộ tạo tiếng bíp bên trong, khi
  được bật bằng động từ Đặt thế hệ tiếng bíp trên NID 01h hoặc nếu không thì từ
  chân PCBEEP bên ngoài) trên nút chân 1Ah. Khi khác 0, hãy để lộ tai nghe
  thay vào đó, hãy nhập jack (hoặc có thể là Line In trên một số máy). Nếu có tiếng bíp PC
  được chọn, điều khiển tăng cường 1Ah không có hiệu lực.

Khuếch đại 1Ah loopback, trái (L): 1 bit
  Khuếch đại kênh trái 1Ah trước khi trộn vào các đầu ra theo quy định
  bởi các bit h và S. Không ảnh hưởng đến mức 1Ah tiếp xúc với các vật dụng khác.

Khuếch đại 1Ah loopback, phải (R): 1 bit
  Khuếch đại kênh bên phải 1Ah trước khi trộn vào các đầu ra theo quy định
  bởi các bit h và S. Không ảnh hưởng đến mức 1Ah tiếp xúc với các vật dụng khác.

Vòng lặp ngược 1Ah đến 21h [hoạt động thấp] (h): 1 bit
  Khi bằng 0, trộn 1Ah (có thể khuếch đại, tùy thuộc vào bit L và R)
  đến 21h (giắc cắm tai nghe trên máy của tôi). Tín hiệu hỗn hợp tôn trọng việc tắt tiếng
  thiết lập vào 21h.

Vòng lặp ngược 1Ah đến 14h (S): 1 bit
  Khi một, trộn 1Ah (có thể khuếch đại, tùy thuộc vào bit L và R)
  thành 14h (loa bên trong trên máy của tôi). Tín hiệu hỗn hợp ZZ0000ZZ tắt tiếng
  cài đặt vào 14h và xuất hiện bất cứ khi nào 14h được định cấu hình làm đầu ra.

Sơ đồ đường dẫn
=============

Lựa chọn đầu vào 1Ah (DIV là bộ chia tiếng bíp PC được đặt trên NID 01h)::

<Bộ tạo tiếng bíp> <Chân PCBEEP> <Giắc cắm tai nghe>
          ZZ0000ZZ |
          +--DIV--+--!DIV--+ {1Ah điều khiển tăng cường}
                  ZZ0001ZZ
                  +--(b == 0)--+--(b != 0)--+
                               |
               >1Ah (Tiếng bíp/Micrô tai nghe/Đầu vào)<

Vòng lặp ngược từ 1Ah đến 21h/14h::

<1Ah (Tiếng bíp/Micrô tai nghe/Đầu vào)>
                               |
                        {khuếch đại nếu L/R}
                               |
                  +------!h-------+-------S-----+
                  ZZ0000ZZ
          {Điều khiển tắt tiếng 21h} |
                  ZZ0001ZZ
          >21h (Tai nghe)< >14h (Loa trong)<

Lý lịch
==========

Tất cả các codec Realtek HDA đều có tiện ích do nhà cung cấp xác định với nút ID 20h.
cung cấp quyền truy cập vào ngân hàng các thanh ghi kiểm soát các chức năng codec khác nhau.
Các thanh ghi được đọc và ghi thông qua hệ số xử lý HDA tiêu chuẩn
động từ (Đặt/Nhận chỉ mục hệ số, Đặt/Nhận hệ số xử lý). Nút là
được đặt tên là "Đăng ký nhà cung cấp Realtek" trong danh sách động từ của bảng dữ liệu công cộng và,
Ngoài ra, hoàn toàn không có giấy tờ.

Thanh ghi cụ thể này, được hiển thị ở hệ số 0x36 và được đặt tên trong các cam kết từ
Realtek, cần lưu ý: không giống như hầu hết các thanh ghi, dường như kiểm soát chi tiết
các thông số bộ khuếch đại không nằm trong phạm vi thông số kỹ thuật của HDA, nó điều khiển âm thanh
định tuyến có thể được xác định dễ dàng bằng bộ trộn HDA tiêu chuẩn
và các vật dụng chọn lọc.

Cụ thể là nó chọn giữa hai nguồn cho widget pin đầu vào bằng Node
ID (NID) 1Ah: tín hiệu của tiện ích có thể đến từ giắc âm thanh (trên thiết bị của tôi
máy tính xách tay, Dell XPS 13 9350, đó là giắc cắm tai nghe, nhưng nhận xét trong Realtek
các cam kết chỉ ra rằng đó có thể là Đường vào trên một số máy) hoặc từ PC
Dòng bíp (được ghép kênh giữa tiếng bíp bên trong của codec
bộ tạo tiếng bíp và chân PCBEEP bên ngoài, tùy thuộc vào việc bộ tạo tiếng bíp có
được kích hoạt thông qua động từ trên NID 01h). Ngoài ra, nó có thể trộn (với tùy chọn
khuếch đại) truyền tín hiệu đến các chân đầu ra 21h và/hoặc 14h.

Giá trị reset của thanh ghi là 0x3717, tương ứng với PC Beep trên 1Ah tức là
sau đó khuếch đại và trộn vào cả tai nghe và loa. Không chỉ
điều này có vi phạm đặc tả HDA không, trong đó nói rằng "[một nhà cung cấp đã xác định
pin đầu vào tiếng bíp] kết nối có thể được duy trì ZZ0001ZZ trong khi thiết lập lại Liên kết
(ZZ0000ZZ) được khẳng định", điều đó có nghĩa là chúng tôi không thể bỏ qua việc đăng ký nếu chúng tôi quan tâm
về đầu vào mà nếu không thì 1Ah sẽ lộ ra hoặc nếu dấu vết PCBEEP bị
được che chắn kém và gây ra tiếng ồn khung gầm (cả hai đều xảy ra trên máy của tôi
máy).

Thật không may, có rất nhiều cách để làm sai cấu hình thanh ghi này.
Có vẻ như Linux đã trải qua hầu hết những điều đó. Đầu tiên, việc đặt lại sổ đăng ký
sau khi S3 tạm dừng: xét theo mã hiện có, điều này không xảy ra với tất cả nhà cung cấp
đăng ký và điều đó đã dẫn đến một số bản sửa lỗi giúp cải thiện hoạt động khi khởi động nguội nhưng
không kéo dài sau khi đình chỉ. Các bản sửa lỗi khác đã chuyển thành công đầu vào 1Ah
tránh xa PC Beep nhưng không tắt được cả hai đường dẫn vòng lặp. Trên của tôi
máy, điều này có nghĩa là đầu vào tai nghe được khuếch đại và lặp lại thành
đầu ra tai nghe, sử dụng các chân giống hệt nhau! Như bạn có thể mong đợi, điều này
gây ra tiếng ồn tai nghe khủng khiếp, đặc tính của nó được điều khiển bởi
Kiểm soát tăng cường 1Ah. (Nếu bạn đã xem hướng dẫn trực tuyến cách sửa tai nghe XPS 13
tiếng ồn bằng cách thay đổi "Headphone Mic Boost" trong ALSA, bây giờ bạn đã biết lý do.)

Thông tin ở đây được lấy thông qua kỹ thuật đảo ngược hộp đen của
hoạt động của codec ALC256 và không được đảm bảo là chính xác. Có khả năng
cũng áp dụng cho ALC255, ALC257, ALC235 và ALC236, vì các codec đó
dường như là họ hàng gần của ALC256. (Tất cả đều có chung một khởi tạo
.) Ngoài ra, các codec khác như ALC225 và ALC285 cũng có chức năng này
đăng ký, đánh giá bằng các bản sửa lỗi hiện có trong ZZ0000ZZ, nhưng cụ thể
dữ liệu (ví dụ: ID nút, vị trí bit, ánh xạ chân) cho các codec đó có thể khác nhau
từ những gì tôi đã mô tả ở đây.
