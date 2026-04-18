.. SPDX-License-Identifier: GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/v4l/colorspaces.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. c:namespace:: V4L

.. _colorspaces:

*************
Không gian màu
***********

'Màu sắc' là một khái niệm rất phức tạp và phụ thuộc vào vật lý, hóa học và
sinh học. Chỉ vì bạn có ba con số mô tả 'màu đỏ',
Các thành phần 'xanh lục' và 'xanh lam' của màu của pixel không có nghĩa là
bạn có thể hiển thị chính xác màu đó. Một không gian màu xác định những gì nó
trên thực tế ZZ0000ZZ có giá trị RGB, ví dụ: (255, 0, 0). Đó là,
màu nào sẽ được tái tạo trên màn hình ở chế độ được hiệu chỉnh hoàn hảo
môi trường.

Để làm được điều đó trước tiên chúng ta cần có định nghĩa tốt về màu sắc,
tức là một số cách để xác định một màu một cách duy nhất và rõ ràng sao cho
người khác có thể tái tạo nó. Tầm nhìn màu sắc của con người là ba màu vì
Mắt người có cơ quan cảm nhận màu sắc nhạy cảm với ba loại khác nhau
bước sóng của ánh sáng. Do đó cần phải sử dụng ba con số để mô tả
màu sắc. Hãy vui mừng vì bạn không phải là tôm bọ ngựa vì chúng rất nhạy cảm với 12
các bước sóng khác nhau, vì vậy thay vì RGB, chúng tôi sẽ sử dụng
Không gian màu ABCDEFGHIJKL...

Màu sắc chỉ tồn tại ở mắt và não và là kết quả của
thụ thể màu được kích thích. Điều này dựa trên sức mạnh quang phổ
Phân phối (SPD) là biểu đồ hiển thị cường độ (bức xạ
công suất) của ánh sáng ở các bước sóng bao phủ quang phổ khả kiến vì nó
đi vào mắt. Khoa học đo màu là về mối quan hệ
giữa SPD và màu sắc mà não người cảm nhận được.

Vì mắt người chỉ có ba cơ quan cảm nhận màu sắc nên nó hoàn toàn có thể
có thể các SPD khác nhau sẽ dẫn đến sự kích thích giống nhau
những thụ thể đó và được coi là có cùng màu, mặc dù SPD
của ánh sáng là khác nhau.

Vào những năm 1920, các thí nghiệm đã được đưa ra để xác định mối quan hệ
giữa SPD và màu sắc cảm nhận được và điều đó dẫn đến CIE 1931
tiêu chuẩn xác định các hàm trọng số quang phổ mô hình hóa
nhận thức về màu sắc. Cụ thể là tiêu chuẩn đó xác định các chức năng
có thể lấy SPD và tính toán kích thích cho từng thụ thể màu.
Sau một số biến đổi toán học hơn nữa, những kích thích này được gọi là
các giá trị ZZ0000ZZ và các giá trị X, Y và Z này mô tả một
màu sắc được con người cảm nhận một cách rõ ràng. Các giá trị X, Y và Z này là
tất cả đều nằm trong khoảng [0…1].

Giá trị Y trong không gian màu CIE XYZ tương ứng với độ chói. Thường xuyên
không gian màu CIE XYZ được chuyển đổi thành CIE xyY được chuẩn hóa
không gian màu:

x = X / (X + Y + Z)

y = Y / (X + Y + Z)

Giá trị x và y là tọa độ màu sắc và có thể được sử dụng để
xác định màu mà không có thành phần độ sáng Y. Điều này rất khó hiểu
để có những cái tên tương tự như vậy cho những không gian màu này. Chỉ cần lưu ý rằng nếu
màu sắc được chỉ định bằng chữ thường 'x' và 'y', sau đó là CIE xyY
không gian màu được sử dụng. Chữ hoa 'X' và 'Y' ám chỉ CIE XYZ
không gian màu. Ngoài ra, y không liên quan gì đến độ chói. Cùng x và y
chỉ định một màu và Y độ chói. Đó thực sự là tất cả những gì bạn cần
nhớ từ quan điểm thực tế. Ở cuối phần này bạn
sẽ tìm thấy các tài nguyên đọc chi tiết hơn nhiều nếu bạn
quan tâm.

Màn hình hoặc TV sẽ tái tạo màu sắc bằng cách phát ra ánh sáng ở mức ba
các bước sóng khác nhau, sự kết hợp của chúng sẽ kích thích màu sắc
thụ thể trong mắt và do đó gây ra nhận thức về màu sắc.
Trong lịch sử, các bước sóng này được xác định bởi màu đỏ, lục và lam
phốt pho được sử dụng trong màn hình. Những chiếc ZZ0000ZZ này là một phần của
xác định một không gian màu.

Các thiết bị hiển thị khác nhau sẽ có các kết quả bầu cử sơ bộ khác nhau và một số
bầu cử sơ bộ phù hợp hơn với một số công nghệ hiển thị so với các công nghệ khác.
Điều này đã dẫn đến nhiều không gian màu khác nhau được sử dụng cho
công nghệ hiển thị hoặc cách sử dụng khác nhau. Để xác định một không gian màu bạn cần
để xác định ba màu cơ bản (chúng thường được xác định là x, y
tọa độ màu từ không gian màu CIE xyY) mà cả màu trắng
tham chiếu: đó là màu thu được khi cả ba màu gốc đều ở mức
công suất tối đa. Điều này xác định công suất hoặc năng lượng tương đối của
bầu cử sơ bộ. Điều này thường được chọn là gần với ánh sáng ban ngày đã được
được định nghĩa là Đèn chiếu sáng CIE D65.

Tóm tắt lại: không gian màu CIE XYZ xác định màu sắc duy nhất.
Các không gian màu khác được xác định bởi ba tọa độ màu được xác định
trong không gian màu CIE xyY. Dựa trên những điều đó, ma trận 3x3 có thể được
được xây dựng để chuyển đổi màu CIE XYZ thành màu mới
không gian màu.

Cả không gian màu CIE XYZ và RGB đều có nguồn gốc từ
các màu cơ bản cụ thể là các không gian màu tuyến tính. Nhưng cả
mắt, công nghệ hiển thị cũng không tuyến tính. Nhân đôi giá trị của tất cả
các thành phần trong không gian màu tuyến tính sẽ không được cảm nhận gấp đôi
cường độ của màu sắc. Vì vậy, mỗi không gian màu cũng xác định một sự chuyển giao
hàm lấy giá trị thành phần màu tuyến tính và biến đổi nó thành
giá trị thành phần phi tuyến tính, gần khớp hơn với giá trị
hiệu suất phi tuyến tính của cả mắt và màn hình. Thành phần tuyến tính
các giá trị được ký hiệu là RGB, phi tuyến tính được ký hiệu là R'G'B'. Nói chung
màu sắc được sử dụng trong đồ họa đều là R'G'B', ngoại trừ trong openGL sử dụng
tuyến tính RGB. Cần đặc biệt cẩn thận khi xử lý openGL để
cung cấp màu RGB tuyến tính hoặc sử dụng hỗ trợ openGL tích hợp để áp dụng
hàm truyền nghịch đảo.

Phần cuối cùng xác định không gian màu là một hàm biến đổi
R'G'B' phi tuyến tính đến Y'CbCr phi tuyến tính. Hàm này được xác định bởi
cái gọi là hệ số luma. Có thể có nhiều Y'CbCr
mã hóa được phép cho cùng một không gian màu. Nhiều mã hóa màu sắc
thích sử dụng độ sáng (Y') và sắc độ (CbCr) thay vì R'G'B'. Kể từ khi
Mắt người nhạy cảm hơn với sự khác biệt về độ chói so với màu sắc
mã hóa này cho phép người ta giảm lượng thông tin màu sắc
so với dữ liệu luma. Lưu ý rằng độ sáng (Y') không liên quan đến Y
trong không gian màu CIE XYZ. Cũng lưu ý rằng Y'CbCr thường được gọi là YCbCr
hoặc YUV mặc dù những điều này hoàn toàn sai.

Đôi khi mọi người nhầm lẫn Y'CbCr là một không gian màu. Đây không phải là
đúng rồi, nó chỉ là mã hóa màu R'G'B' thành độ sáng và sắc độ
các giá trị. Không gian màu cơ bản được liên kết với R'G'B'
màu sắc cũng được liên kết với màu Y'CbCr.

Bước cuối cùng là cách lượng tử hóa các giá trị RGB, R'G'B' hoặc Y'CbCr.
Không gian màu CIE XYZ trong đó X, Y và Z nằm trong phạm vi [0…1] mô tả
tất cả các màu sắc mà con người có thể cảm nhận được nhưng chuyển sang màu khác
không gian màu sẽ tạo ra các màu nằm ngoài phạm vi [0…1]. Một lần
được kẹp trong phạm vi [0…1], những màu đó không thể được tái tạo trong
không gian màu đó. Sự kẹp chặt này là cái làm giảm mức độ hoặc gam màu của
không gian màu. Cách chuyển phạm vi [0…1] sang giá trị số nguyên
trong phạm vi [0…255] (hoặc cao hơn, tùy thuộc vào độ sâu màu) là
gọi là lượng tử hóa. Đây là một phần ZZ0000ZZ của không gian màu
định nghĩa. Trong thực tế, các giá trị RGB hoặc R'G'B' là đầy đủ, tức là chúng
sử dụng toàn bộ phạm vi [0…255]. Mặt khác, giá trị Y'CbCr bị hạn chế
phạm vi với Y' sử dụng [16…235] và Cb và Cr sử dụng [16…240].

Thật không may, trong một số trường hợp, RGB có phạm vi giới hạn cũng được sử dụng khi
các thành phần sử dụng phạm vi [16…235]. Và đầy đủ Y'CbCr cũng tồn tại
sử dụng phạm vi [0…255].

Để diễn giải chính xác một màu sắc, bạn cần biết
phạm vi lượng tử hóa, cho dù đó là R'G'B' hay Y'CbCr, Y'CbCr được sử dụng
mã hóa và không gian màu. Từ thông tin đó bạn có thể tính toán
màu CIE XYZ tương ứng và ánh xạ lại màu đó vào bất kỳ không gian màu nào
thiết bị hiển thị của bạn sử dụng.

Bản thân định nghĩa không gian màu bao gồm ba màu sắc
màu cơ bản, màu sắc tham chiếu màu trắng, hàm truyền và
hệ số luma cần thiết để biến đổi R'G'B' thành Y'CbCr. Trong khi một số
Các tiêu chuẩn không gian màu xác định chính xác cả bốn, khá thường xuyên
Tiêu chuẩn không gian màu chỉ xác định một số và bạn phải dựa vào tiêu chuẩn khác
tiêu chuẩn cho những phần còn thiếu. Thực tế là không gian màu thường là một
sự kết hợp của các tiêu chuẩn khác nhau cũng dẫn đến các quy ước đặt tên rất khó hiểu
trong đó tên của một tiêu chuẩn được sử dụng để đặt tên cho một không gian màu trong khi trên thực tế
tiêu chuẩn đó cũng là một phần của nhiều không gian màu khác.

Nếu bạn muốn đọc thêm về màu sắc và không gian màu, thì
các tài nguyên sau rất hữu ích: ZZ0000ZZ là một tài liệu thực tế tốt
sách dành cho kỹ sư video, ZZ0001ZZ có phạm vi rộng hơn nhiều và
mô tả nhiều khía cạnh hơn của màu sắc (vật lý, hóa học, sinh học,
v.v.). các
ZZ0002ZZ
trang web là một nguồn tài nguyên tuyệt vời, đặc biệt đối với
toán học đằng sau chuyển đổi không gian màu. Wikipedia
ZZ0003ZZ
bài viết cũng rất hữu ích.