.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/sound/designs/timestamping.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=======================
Dấu thời gian ALSA PCM
=====================

ALSA API có thể cung cấp hai dấu thời gian hệ thống khác nhau:

- Trigger_tstamp là ảnh chụp nhanh thời gian hệ thống được chụp khi .trigger
  gọi lại được gọi. Ảnh chụp nhanh này được chụp bởi lõi ALSA trong
  trường hợp chung, nhưng phần cứng cụ thể có thể có sự đồng bộ hóa
  khả năng hoặc ngược lại chỉ có thể cung cấp một cách chính xác
  ước tính với độ trễ. Trong hai trường hợp sau, trình điều khiển cấp thấp
  chịu trách nhiệm cập nhật trigger_tstamp một cách thích hợp nhất
  và thời điểm chính xác. Các ứng dụng không nên chỉ dựa vào lần đầu tiên
  trigger_tstamp nhưng cập nhật các tính toán nội bộ của chúng nếu trình điều khiển
  cung cấp một ước tính tinh tế với độ trễ.

- tstamp là dấu thời gian hệ thống hiện tại được cập nhật trong thời gian qua
  truy vấn sự kiện hoặc ứng dụng.
  Sự khác biệt (tstamp - trigger_tstamp) xác định thời gian đã trôi qua.

ALSA API cung cấp hai thông tin cơ bản, tận dụng
và độ trễ, kết hợp với hệ thống kích hoạt và hiện tại
dấu thời gian cho phép các ứng dụng theo dõi 'sự đầy đủ' của
bộ đệm vòng và số lượng mẫu được xếp hàng đợi.

Việc sử dụng các con trỏ và thông tin thời gian khác nhau này phụ thuộc vào
ứng dụng cần:

- ZZ0000ZZ báo cáo số lượng có thể được ghi vào bộ đệm vòng
- ZZ0001ZZ báo cáo thời gian cần thiết để nghe mẫu mới
  các mẫu xếp hàng đợi đã được phát ra.

Khi dấu thời gian được bật, thông tin lịch phát sóng/độ trễ sẽ được báo cáo
cùng với ảnh chụp nhanh về thời gian hệ thống. Ứng dụng có thể chọn từ
ZZ0000ZZ (sửa NTP bao gồm cả việc lùi lại),
ZZ0001ZZ (NTP sửa nhưng không bao giờ lùi lại),
ZZ0002ZZ (không có hiệu chỉnh NTP) và thay đổi chế độ
động với sw_params


ALSA API cũng cung cấp audio_tstamp phản ánh đoạn văn
thời gian được đo bằng các thành phần khác nhau của phần cứng âm thanh.  trong
ascii-art, điều này có thể được biểu diễn như sau (để phát lại
trường hợp):
::

--------------------------------------------------------------> thời gian
    ^ ^ ^ ^ ^
    ZZ0000ZZ ZZ0001ZZ |
   ứng dụng DMA liên kết tương tự FullBuffer
   thời gian thời gian thời gian thời gian
    ZZ0002ZZ ZZ0003ZZ |
    ZZ0004ZZ<-hw độ trễ-->ZZ0005ZZ<---có sẵn->|
    ZZ0006ZZ |
                                   ZZ0007ZZ


Thời gian tương tự được lấy ở giai đoạn phát lại cuối cùng, càng gần
nhất có thể với đầu dò thực tế

Thời gian liên kết được lấy ở đầu ra của SoC/chipset làm mẫu
được đẩy vào một liên kết. Thời gian liên kết có thể được đo trực tiếp nếu
được hỗ trợ trong phần cứng bằng bộ đếm mẫu hoặc đồng hồ treo tường (ví dụ: với
Đồng hồ HDAudio 24 MHz hoặc PTP cho các giải pháp nối mạng) hoặc gián tiếp
ước tính (ví dụ: với bộ đếm khung trong USB).

Thời gian DMA được đo bằng bộ đếm - thường là loại có độ tin cậy kém nhất
của tất cả các phép đo do tính chất bùng nổ của việc truyền DMA.

Thời gian của ứng dụng tương ứng với thời gian được ứng dụng theo dõi sau
ghi vào bộ đệm vòng.

Ứng dụng có thể truy vấn các khả năng của phần cứng, xác định những khả năng nào
thời gian âm thanh nó muốn báo cáo bằng cách chọn cài đặt có liên quan trong
các trường audio_tstamp_config, do đó có được ước tính về dấu thời gian
độ chính xác. Nó cũng có thể yêu cầu đưa độ trễ sang tương tự vào
đo lường. Truy cập trực tiếp vào thời gian liên kết rất thú vị trên
nền tảng cung cấp DSP nhúng; đo trực tiếp liên kết
thời gian với phần cứng chuyên dụng, có thể được đồng bộ hóa với thời gian hệ thống,
loại bỏ nhu cầu theo dõi thời gian xử lý DSP nội bộ và
độ trễ.

Trong trường hợp ứng dụng yêu cầu tstamp âm thanh không được hỗ trợ
trong trình điều khiển phần cứng/cấp thấp, loại này được ghi đè là DEFAULT và
dấu thời gian sẽ báo cáo thời gian DMA dựa trên giá trị hw_pointer.

Để tương thích ngược với các triển khai trước đó không
cung cấp lựa chọn dấu thời gian, với loại dấu thời gian COMPAT có giá trị bằng 0
kết quả sẽ mặc định là đồng hồ treo tường HDAudio để phát lại
luồng và đến thời gian DMA (hw_ptr) trong tất cả các trường hợp khác.

Độ chính xác của dấu thời gian âm thanh có thể được trả về không gian người dùng, do đó
đưa ra những quyết định phù hợp:

- đối với thời gian dma (mặc định), mức độ chi tiết của việc chuyển tiền có thể là
  được suy ra từ các bước giữa các lần cập nhật và lần lượt cung cấp
  thông tin về mức độ mà con trỏ ứng dụng có thể được tua lại
  một cách an toàn.

- thời gian liên kết có thể được sử dụng để theo dõi sự trôi dạt dài hạn giữa âm thanh
  và thời gian hệ thống bằng cách sử dụng (tstamp-trigger_tstamp)/audio_tstamp
  tỷ lệ, độ chính xác giúp xác định mức độ làm mịn/thông thấp
  lọc là cần thiết. Thời gian liên kết có thể được đặt lại khi khởi động
  hoặc được báo cáo nguyên trạng (cái sau rất hữu ích để so sánh tiến độ của
  các luồng khác nhau - nhưng có thể yêu cầu đồng hồ treo tường luôn
  chạy và không bị quấn quanh trong thời gian nhàn rỗi). Nếu được hỗ trợ trong
  phần cứng, thời gian liên kết tuyệt đối cũng có thể được sử dụng để xác định
  thời gian bắt đầu chính xác (bản vá WIP)

- bao gồm cả độ trễ trong dấu thời gian âm thanh có thể
  phản trực giác không làm tăng độ chính xác của dấu thời gian, ví dụ: nếu một
  codec bao gồm xử lý DSP có độ trễ thay đổi hoặc một chuỗi
  các thành phần phần cứng, độ trễ thường không được biết chính xác.

Độ chính xác được báo cáo theo đơn vị nano giây (sử dụng mã 32-bit không dấu).
từ), mang lại độ chính xác tối đa là 4,29 giây, quá đủ cho
ứng dụng âm thanh...

Do tính chất đa dạng của nhu cầu đánh dấu thời gian, ngay cả đối với một
ứng dụng, audio_tstamp_config có thể được thay đổi linh hoạt. trong
ZZ0000ZZ ioctl, các tham số ở chế độ chỉ đọc và không cho phép
bất kỳ lựa chọn ứng dụng nào. Để khắc phục hạn chế này mà không cần
tác động đến các ứng dụng cũ, một ioctl ZZ0001ZZ mới được giới thiệu
với các tham số đọc/ghi. ALSA-lib sẽ được sửa đổi để sử dụng
ZZ0002ZZ và ngừng sử dụng ZZ0003ZZ.

ALSA API chỉ cho phép báo cáo một dấu thời gian âm thanh duy nhất
tại một thời điểm. Đây là một quyết định thiết kế có ý thức, đọc âm thanh
dấu thời gian từ các thanh ghi phần cứng hoặc từ IPC càng mất nhiều thời gian
dấu thời gian được đọc càng không chính xác các phép đo kết hợp
là. Để tránh bất kỳ vấn đề giải thích nào, một (hệ thống, âm thanh)
dấu thời gian được báo cáo. Các ứng dụng cần dấu thời gian khác nhau
sẽ được yêu cầu đưa ra nhiều truy vấn và thực hiện một
nội suy của kết quả

Trong một số cấu hình dành riêng cho phần cứng, dấu thời gian của hệ thống là
được chốt bởi hệ thống con âm thanh cấp thấp và thông tin được cung cấp
quay lại với tài xế. Do có thể có sự chậm trễ trong việc liên lạc với
phần cứng, có nguy cơ sai lệch về lịch phát sóng và độ trễ
thông tin. Để đảm bảo các ứng dụng không bị nhầm lẫn, một
trường driver_timestamp được thêm vào cấu trúc snd_pcm_status; cái này
dấu thời gian hiển thị khi thông tin được người lái xe tổng hợp lại
trước khi trở về từ ZZ0000ZZ và ZZ0001ZZ ioctl. trong hầu hết các trường hợp
driver_timestamp này sẽ giống hệt với tstamp hệ thống thông thường.

Ví dụ về dấu thời gian với HDAudio:

1. Dấu thời gian DMA, không bù cho độ trễ tương tự DMA+
::

$ ./audio_time -p --ts_type=1
  phát lại: thời gian hệ thống: 341121338 nsec, thời gian âm thanh 342000000 nsec, delta thời gian hệ thống -878662
  phát lại: thời gian hệ thống: 426236663 nsec, thời gian âm thanh 427187500 nsec, delta thời gian hệ thống -950837
  phát lại: thời gian hệ thống: 597080580 nsec, thời gian âm thanh 598000000 nsec, delta thời gian hệ thống -919420
  phát lại: thời gian hệ thống: 682059782 nsec, thời gian âm thanh 683020833 nsec, delta thời gian hệ thống -961051
  phát lại: thời gian hệ thống: 852896415 nsec, thời gian âm thanh 853854166 nsec, delta thời gian hệ thống -957751
  phát lại: thời gian hệ thống: 937903344 nsec, thời gian âm thanh 938854166 nsec, delta thời gian hệ thống -950822

2. Dấu thời gian DMA, bù cho độ trễ tương tự DMA+
::

$ ./audio_time -p --ts_type=1 -d
  phát lại: thời gian hệ thống: 341053347 nsec, thời gian âm thanh 341062500 nsec, delta thời gian hệ thống -9153
  phát lại: thời gian hệ thống: 426072447 nsec, thời gian âm thanh 426062500 nsec, delta thời gian hệ thống 9947
  phát lại: thời gian hệ thống: 596899518 nsec, thời gian âm thanh 596895833 nsec, delta thời gian hệ thống 3685
  phát lại: thời gian hệ thống: 681915317 nsec, thời gian âm thanh 681916666 nsec, delta thời gian hệ thống -1349
  phát lại: thời gian hệ thống: 852741306 nsec, thời gian âm thanh 852750000 nsec, delta thời gian hệ thống -8694

3. dấu thời gian liên kết, bù cho độ trễ tương tự DMA+
::

$ ./audio_time -p --ts_type=2 -d
  phát lại: thời gian hệ thống: 341060004 nsec, thời gian âm thanh 341062791 nsec, delta thời gian hệ thống -2787
  phát lại: thời gian hệ thống: 426242074 nsec, thời gian âm thanh 426244875 nsec, delta thời gian hệ thống -2801
  phát lại: thời gian hệ thống: 597080992 nsec, thời gian âm thanh 597084583 nsec, delta thời gian hệ thống -3591
  phát lại: thời gian hệ thống: 682084512 nsec, thời gian âm thanh 682088291 nsec, delta thời gian hệ thống -3779
  phát lại: thời gian hệ thống: 852936229 nsec, thời gian âm thanh 852940916 nsec, delta thời gian hệ thống -4687
  phát lại: thời gian hệ thống: 938107562 nsec, thời gian âm thanh 938112708 nsec, delta thời gian hệ thống -5146

Ví dụ 1 cho thấy timestamp ở mức DMA gần bằng 1ms
trước thời gian phát lại thực tế (như một thời gian phụ kiểu này
phép đo có thể giúp xác định các biện pháp bảo vệ tua lại). Bồi thường cho
Độ trễ liên kết DMA trong ví dụ 2 giúp loại bỏ bộ đệm phần cứng nhưng
thông tin vẫn còn rất bấp bênh, có tới một mẫu
lỗi. Trong ví dụ 3 trong đó dấu thời gian được đo bằng liên kết
đồng hồ treo tường, dấu thời gian hiển thị hành vi đơn điệu và thấp hơn
sự phân tán.

Ví dụ 3 và 4 thuộc lớp âm thanh USB. Ví dụ 3 cho thấy mức cao
chênh lệch giữa thời gian âm thanh và thời gian hệ thống do đệm. Ví dụ 4
cho thấy việc bù cho độ trễ mang lại độ chính xác 1ms như thế nào (do
việc người lái xe sử dụng bộ đếm khung)

Ví dụ 3: Dấu thời gian DMA, không bù cho độ trễ, delta ~ 5ms
::

$ ./audio_time -p -Dhw:1 -t1
  phát lại: thời gian hệ thống: 120174019 nsec, thời gian âm thanh 125000000 nsec, delta thời gian hệ thống -4825981
  phát lại: thời gian hệ thống: 245041136 nsec, thời gian âm thanh 250000000 nsec, delta thời gian hệ thống -4958864
  phát lại: thời gian hệ thống: 370106088 nsec, thời gian âm thanh 375000000 nsec, delta thời gian hệ thống -4893912
  phát lại: thời gian hệ thống: 495040065 nsec, thời gian âm thanh 500000000 nsec, delta thời gian hệ thống -4959935
  phát lại: thời gian hệ thống: 620038179 nsec, thời gian âm thanh 625000000 nsec, delta thời gian hệ thống -4961821
  phát lại: thời gian hệ thống: 745087741 nsec, thời gian âm thanh 750000000 nsec, delta thời gian hệ thống -4912259
  phát lại: thời gian hệ thống: 870037336 nsec, thời gian âm thanh 875000000 nsec, delta thời gian hệ thống -4962664

Ví dụ 4: Dấu thời gian DMA, bù độ trễ, độ trễ ~ 1ms
::

$ ./audio_time -p -Dhw:1 -t1 -d
  phát lại: thời gian hệ thống: 120190520 nsec, thời gian âm thanh 120000000 nsec, delta thời gian hệ thống 190520
  phát lại: thời gian hệ thống: 245036740 nsec, thời gian âm thanh 244000000 nsec, delta thời gian hệ thống 1036740
  phát lại: thời gian hệ thống: 370034081 nsec, thời gian âm thanh 369000000 nsec, delta thời gian hệ thống 1034081
  phát lại: thời gian hệ thống: 495159907 nsec, thời gian âm thanh 494000000 nsec, delta thời gian hệ thống 1159907
  phát lại: thời gian hệ thống: 620098824 nsec, thời gian âm thanh 619000000 nsec, delta thời gian hệ thống 1098824
  phát lại: thời gian hệ thống: 745031847 nsec, thời gian âm thanh 744000000 nsec, delta thời gian hệ thống 1031847
