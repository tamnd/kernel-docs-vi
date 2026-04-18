.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/sound/designs/compress-offload.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

===========================
ALSA Nén-giảm tải API
=========================

Pierre-Louis.Bossart <pierre-louis.bossart@linux.intel.com>

Vinod Koul <vinod.koul@linux.intel.com>


Tổng quan
========
Kể từ những ngày đầu, ALSA API đã được xác định với sự hỗ trợ của PCM hoặc
lưu ý đến tải trọng tốc độ bit không đổi như IEC61937. Lập luận và
các giá trị được trả về trong khung là tiêu chuẩn, khiến nó trở thành một thách thức đối với
mở rộng API hiện có sang luồng dữ liệu nén.

Trong những năm gần đây, bộ xử lý tín hiệu âm thanh số (DSP) đã được tích hợp
trong các thiết kế hệ thống trên chip và DSP cũng được tích hợp trong âm thanh
codec. Việc xử lý dữ liệu nén trên các DSP như vậy mang lại kết quả rất ấn tượng.
giảm mức tiêu thụ điện năng so với dựa trên máy chủ
xử lý. Hỗ trợ cho phần cứng như vậy chưa được tốt lắm trong Linux,
chủ yếu là do thiếu API chung có sẵn trong dòng chính
hạt nhân.

Thay vì yêu cầu ngừng tương thích với thay đổi API của
Giao diện ALSA PCM, 'Dữ liệu nén' API mới được giới thiệu cho
cung cấp giao diện điều khiển và truyền dữ liệu cho DSP âm thanh.

Thiết kế của chiếc API này được lấy cảm hứng từ trải nghiệm 2 năm với
Intel Moorestown SOC, với nhiều chỉnh sửa cần thiết để upstream
API trong kernel dòng chính thay vì cây dàn và tạo nó
người khác có thể sử dụng được.


Yêu cầu
============
Các yêu cầu chính là:

- tách biệt giữa số byte và thời gian. Các định dạng nén có thể có
  một tiêu đề cho mỗi tệp, mỗi khung hoặc không có tiêu đề nào cả. Kích thước tải trọng
  có thể thay đổi tùy theo từng khung hình. Kết quả là, không thể
  ước tính một cách đáng tin cậy thời lượng của bộ đệm âm thanh khi xử lý
  dữ liệu nén. Cần có cơ chế chuyên dụng để cho phép
  đồng bộ hóa âm thanh-video đáng tin cậy, đòi hỏi độ chính xác
  báo cáo số lượng mẫu được thực hiện tại bất kỳ thời điểm nào.

- Xử lý nhiều định dạng. Dữ liệu PCM chỉ yêu cầu thông số kỹ thuật
  về tốc độ lấy mẫu, số lượng kênh và bit trên mỗi mẫu. trong
  Ngược lại, dữ liệu nén có nhiều định dạng khác nhau. DSP âm thanh
  cũng có thể cung cấp hỗ trợ cho một số bộ mã hóa âm thanh và
  bộ giải mã được nhúng trong phần sụn hoặc có thể hỗ trợ nhiều lựa chọn hơn thông qua
  tải xuống động của các thư viện.

- Tập trung vào các hình thức chính. API này cung cấp hỗ trợ nhiều nhất
  các định dạng phổ biến được sử dụng để thu và phát lại âm thanh và video. Đó là
  có thể là khi công nghệ nén âm thanh tiến bộ, các định dạng mới
  sẽ được thêm vào.

- Xử lý nhiều cấu hình. Ngay cả đối với một định dạng nhất định như
  AAC, một số triển khai có thể hỗ trợ đa kênh AAC nhưng HE-AAC
  âm thanh nổi. Tương tự như vậy WMA10 cấp M3 có thể yêu cầu quá nhiều bộ nhớ và CPU
  chu kỳ. API mới cần cung cấp một cách chung để liệt kê những
  các định dạng.

- Chỉ hiển thị/lấy. API này không cung cấp bất kỳ phương tiện nào
  tăng tốc phần cứng, trong đó các mẫu PCM được cung cấp lại cho
  không gian người dùng để xử lý bổ sung. Thay vào đó, API này tập trung vào
  truyền dữ liệu nén tới DSP, với giả định rằng
  các mẫu được giải mã được định tuyến đến đầu ra vật lý hoặc back-end logic.

- Ẩn giấu sự phức tạp Tất cả các khung đa phương tiện trong không gian người dùng hiện có
  có các enum/cấu trúc hiện có cho từng định dạng nén. Cái mới này
  API giả định sự tồn tại của lớp tương thích dành riêng cho nền tảng
  để hiển thị, dịch và tận dụng khả năng của âm thanh
  DSP, ví dụ. Chìm Android HAL hoặc PulseAudio. Bằng cách xây dựng, thường xuyên
  các ứng dụng không được phép sử dụng API này.


Thiết kế
======
API mới chia sẻ một số khái niệm với PCM API về dòng chảy
kiểm soát. Các lệnh bắt đầu, tạm dừng, tiếp tục, thoát và dừng đều giống nhau
ngữ nghĩa bất kể nội dung là gì.

Khái niệm vùng đệm vòng bộ nhớ được chia thành một tập hợp các đoạn là
mượn từ ALSA PCM API. Tuy nhiên, chỉ có kích thước tính bằng byte mới có thể được
được chỉ định.

Chế độ tìm kiếm/lừa được cho là do máy chủ xử lý.

Khái niệm tua lại/tiến không được hỗ trợ. Dữ liệu cam kết với
Bộ đệm vòng không thể bị vô hiệu hóa, ngoại trừ khi loại bỏ tất cả bộ đệm.

Dữ liệu nén API không đưa ra bất kỳ giả định nào về cách dữ liệu
được truyền tới âm thanh DSP. DMA chuyển từ bộ nhớ chính sang
cụm âm thanh nhúng hoặc giao diện SPI cho DSP bên ngoài đều được
có thể. Như trong trường hợp ALSA PCM, một tập hợp các quy trình cốt lõi được hiển thị;
mỗi người triển khai trình điều khiển sẽ phải viết hỗ trợ cho một bộ
những thói quen bắt buộc và có thể sử dụng những thói quen tùy chọn.

Các bổ sung chính là

get_caps
  Quy trình này trả về danh sách các định dạng âm thanh được hỗ trợ. Truy vấn
  codec trên luồng chụp sẽ trả về bộ mã hóa, bộ giải mã sẽ
  được liệt kê cho các luồng phát lại.

get_codec_caps
  Đối với mỗi codec, thủ tục này trả về một danh sách
  khả năng. Mục đích là để đảm bảo tất cả các khả năng
  tương ứng với các cài đặt hợp lệ và để giảm thiểu rủi ro
  lỗi cấu hình. Ví dụ: đối với một codec phức tạp như AAC,
  số lượng kênh được hỗ trợ có thể phụ thuộc vào cấu hình cụ thể. Nếu
  các khả năng được bộc lộ bằng một bộ mô tả duy nhất, điều đó có thể xảy ra
  rằng sự kết hợp cụ thể của các cấu hình/kênh/định dạng có thể không phù hợp
  được hỗ trợ. Tương tự như vậy, DSP nhúng có chu kỳ bộ nhớ và CPU hạn chế,
  có khả năng một số triển khai sẽ đưa vào danh sách các khả năng
  năng động và phụ thuộc vào khối lượng công việc hiện có. Ngoài mã hóa
  cài đặt, thủ tục này trả về kích thước bộ đệm tối thiểu được xử lý bởi
  thực hiện. Thông tin này có thể là một chức năng của bộ đệm DMA
  kích thước, số byte cần thiết để đồng bộ hóa, v.v. và có thể
  được sử dụng bởi không gian người dùng để xác định số lượng cần ghi vào vòng
  đệm trước khi quá trình phát lại có thể bắt đầu.

set_params
  Quy trình này đặt cấu hình được chọn cho một codec cụ thể. các
  trường quan trọng nhất trong các tham số là loại codec; trong hầu hết
  bộ giải mã trường hợp sẽ bỏ qua các trường khác, trong khi bộ mã hóa sẽ nghiêm ngặt
  tuân thủ các cài đặt

get_params
  Quy trình này trả về các cài đặt thực tế được DSP sử dụng. Thay đổi về
  các cài đặt sẽ vẫn là ngoại lệ.

get_timestamp
  Dấu thời gian trở thành cấu trúc nhiều trường. Nó liệt kê số
  số byte được truyền, số lượng mẫu được xử lý và số lượng
  của các mẫu được kết xuất/lấy. Tất cả những giá trị này có thể được sử dụng để xác định
  tốc độ bit trung bình, hãy tìm hiểu xem có cần phải có bộ đệm vòng không
  được nạp lại hoặc độ trễ do giải mã/mã hóa/io trên DSP.

Lưu ý rằng danh sách codec/cấu hình/chế độ được lấy từ
Đặc điểm kỹ thuật OpenMAX AL thay vì phát minh lại bánh xe.
Các sửa đổi bao gồm:
- Bổ sung các định dạng FLAC và IEC
- Hợp nhất các khả năng mã hóa/giải mã
- Cấu hình/chế độ được liệt kê dưới dạng bitmask để làm cho bộ mô tả nhỏ gọn hơn
- Bổ sung set_params cho bộ giải mã (thiếu trong OpenMAX AL)
- Bổ sung các chế độ mã hóa AMR/AMR-WB (thiếu trong OpenMAX AL)
- Bổ sung thông tin định dạng cho WMA
- Bổ sung các tùy chọn mã hóa khi được yêu cầu (bắt nguồn từ OpenMAX IL)
- Bổ sung rateControlSupported (thiếu trong OpenMAX AL)

Máy trạng thái
=============

Máy trạng thái luồng âm thanh nén được mô tả bên dưới ::

+----------+
                                        ZZ0000ZZ
                                        ZZ0001ZZ
                                        ZZ0002ZZ
                                        +----------+
                                             |
                                             |
                                             | compr_set_params()
                                             |
                                             v
         compr_free() +----------+
  +-----------------------------------ZZ0003ZZ
  ZZ0004ZZ SETUP |
  ZZ0005ZZ |<--------------------------+
  ZZ0006ZZ compr_write() +----------+ |
  ZZ0007ZZ ^ |
  ZZ0008ZZ ZZ0009ZZ
  ZZ0010ZZ ZZ0011ZZ
  ZZ0012ZZ ZZ0013ZZ
  ZZ0014ZZ ZZ0015ZZ
  ZZ0016ZZ +----------+ |
  ZZ0017ZZ ZZ0018ZZ |
  ZZ0019ZZ ZZ0020ZZ |
  ZZ0021ZZ ZZ0022ZZ |
  ZZ0023ZZ +----------+ |
  ZZ0024ZZ ^ |
  ZZ0025ZZ ZZ0026ZZ
  ZZ0027ZZ ZZ0028ZZ
  ZZ0029ZZ ZZ0030ZZ
  ZZ0031ZZ |
  ZZ0032ZZ
  ZZ0033ZZ ZZ0034ZZ ZZ0035ZZ
  ZZ0036ZZ PREPARE ZZ0037ZZ RUNNING |--------------------------+
  ZZ0038ZZ ZZ0039ZZ ZZ0040ZZ
  ZZ0041ZZ
  ZZ0042ZZ ZZ0043ZZ
  |          |compr_free() ZZ0045ZZ |
  ZZ0046ZZ compr_pause() ZZ0047ZZ compr_resume() |
  ZZ0048ZZ ZZ0049ZZ |
  ZZ0050ZZ |
  ZZ0051ZZ
  ZZ0052ZZ ZZ0053ZZ ZZ0054ZZ
  +--->ZZ0055ZZ ZZ0056ZZ--------------------------+
       ZZ0057ZZ ZZ0058ZZ
       +----------+ +----------+


Phát lại không khoảng cách
================
Khi phát qua album, bộ giải mã có khả năng bỏ qua bộ mã hóa
độ trễ và phần đệm và chuyển trực tiếp từ nội dung bản nhạc này sang nội dung bản nhạc khác. Sự kết thúc
người dùng có thể coi đây là chế độ phát lại không có khoảng cách vì chúng tôi không có chế độ im lặng trong khi
chuyển từ bài hát này sang bài hát khác

Ngoài ra, có thể có tiếng ồn cường độ thấp do mã hóa. Hoàn hảo không có khoảng cách là
khó tiếp cận với tất cả các loại dữ liệu nén nhưng hoạt động tốt với hầu hết
nội dung âm nhạc. Bộ giải mã cần biết độ trễ của bộ mã hóa và phần đệm của bộ mã hóa.
Vì vậy chúng ta cần chuyển cái này tới DSP. Siêu dữ liệu này được trích xuất từ các tiêu đề ID3/MP4
và không có mặt theo mặc định trong dòng bit, do đó cần có một
giao diện để chuyển thông tin này đến DSP. Ngoài ra DSP và không gian người dùng cần phải
chuyển từ bản nhạc này sang bản nhạc khác và bắt đầu sử dụng dữ liệu cho bản nhạc thứ hai.

Các bổ sung chính là:

set_metadata
  Quy trình này đặt độ trễ của bộ mã hóa và phần đệm của bộ mã hóa. Điều này có thể được sử dụng bởi
  bộ giải mã để loại bỏ sự im lặng. Điều này cần được đặt trước dữ liệu trong bản nhạc
  được viết.

set_next_track
  Quy trình này cho DSP biết rằng siêu dữ liệu và thao tác ghi được gửi sau đó sẽ
  tương ứng với bài hát tiếp theo

cống một phần
  Điều này được gọi khi đạt đến cuối tập tin. Không gian người dùng có thể thông báo cho DSP rằng
  Đã đạt đến EOF và bây giờ DSP có thể bắt đầu bỏ qua độ trễ đệm. Ngoài ra viết tiếp theo
  dữ liệu sẽ thuộc về bài hát tiếp theo

Luồng trình tự cho Gapless sẽ là:
- Mở
- Nhận mũ / mũ codec
- Đặt thông số
- Đặt siêu dữ liệu của bản nhạc đầu tiên
- Điền dữ liệu của track đầu tiên
- Khởi động kích hoạt
- Không gian người dùng đã gửi xong tất cả,
- Cho biết dữ liệu bản nhạc tiếp theo bằng cách gửi set_next_track
- Đặt siêu dữ liệu của bản nhạc tiếp theo
- sau đó gọi một phần_drain để xóa phần lớn bộ đệm trong DSP
- Điền dữ liệu của bài hát tiếp theo
- DSP chuyển sang bài hát thứ hai

(lưu ý: thứ tự cho một phần_drain và viết cho bài hát tiếp theo cũng có thể được đảo ngược)

Phát lại không giới hạn SM
===================

Đối với Gapless, chúng tôi chuyển từ trạng thái chạy sang thoát một phần và ngược lại, cùng
với cài đặt meta_data và báo hiệu cho bản nhạc tiếp theo ::


+----------+
                compr_drain_notify() ZZ0000ZZ
              +------------------------>ZZ0001ZZ
              ZZ0002ZZ |
              |                         +----------+
              ZZ0003ZZ
              ZZ0004ZZ
              ZZ0005ZZ compr_next_track()
              ZZ0006ZZ
              |                              V.
              |                         +----------+
              ZZ0007ZZ |
              ZZ0008ZZNEXT_TRACK|
              ZZ0009ZZ ZZ0010ZZ
              ZZ0011ZZ +--+-------+
              ZZ0012ZZ ZZ0013ZZ
              ZZ0014ZZ
              ZZ0015ZZ
              ZZ0016ZZ compr_partial_drain()
              ZZ0017ZZ
              |                              V.
              |                         +----------+
              ZZ0018ZZ |
              +------------------------ ZZ0019ZZ
                                        ZZ0020ZZ
                                        +----------+

Không được hỗ trợ
=============
- Hỗ trợ các cuộc gọi VoIP/chuyển mạch kênh không phải là mục tiêu của việc này
  API. Hỗ trợ thay đổi tốc độ bit động sẽ yêu cầu chặt chẽ
  ghép nối giữa DSP và ngăn xếp máy chủ, hạn chế tiết kiệm điện năng.

- Việc che giấu mất gói không được hỗ trợ. Điều này sẽ yêu cầu một
  giao diện bổ sung để cho bộ giải mã tổng hợp dữ liệu khi khung
  bị mất trong quá trình truyền. Điều này có thể được thêm vào trong tương lai.

- Điều khiển âm lượng/định tuyến không được xử lý bởi API này. Thiết bị hiển thị một
  giao diện dữ liệu nén sẽ được coi là thiết bị ALSA thông thường;
  thay đổi khối lượng và thông tin định tuyến sẽ được cung cấp thường xuyên
  Bộ điều khiển ALSA.

- Hiệu ứng âm thanh nhúng. Những hiệu ứng như vậy phải được kích hoạt trong cùng một
  theo cách nào, bất kể đầu vào là PCM hay được nén.

- mã hóa đa kênh IEC. Không rõ liệu điều này có cần thiết hay không.

- Tăng tốc mã hóa/giải mã không được hỗ trợ như đã đề cập
  ở trên. Có thể định tuyến đầu ra của bộ giải mã tới bộ thu
  phát trực tuyến hoặc thậm chí triển khai khả năng chuyển mã. Định tuyến này
  sẽ được kích hoạt bằng kcontrols ALSA.

- Chính sách âm thanh/quản lý tài nguyên. API này không cung cấp bất kỳ
  móc để truy vấn việc sử dụng âm thanh DSP, cũng như bất kỳ quyền ưu tiên nào
  cơ chế.

- Không có khái niệm thiếu/tràn. Vì các byte được ghi được nén
  về bản chất và dữ liệu được ghi/đọc không dịch trực tiếp sang
  kết quả đầu ra được hiển thị kịp thời, điều này không giải quyết được vấn đề chạy thiếu/tràn và
  có thể xử lý trong thư viện người dùng


Tín dụng
=======
- Mark Brown và Liam Girdwood để thảo luận về sự cần thiết của chiếc API này
- Harsha Priya vì công trình nghiên cứu về bản nén intel_sst API
- Rakesh Ughreja vì những phản hồi có giá trị
- Hát Nallasellan, Sikkandar Madar và Prasanna Samaga cho
  chứng minh và định lượng lợi ích của việc giảm tải âm thanh trên một
  nền tảng thực sự.
