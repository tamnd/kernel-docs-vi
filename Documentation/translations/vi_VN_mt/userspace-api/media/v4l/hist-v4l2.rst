.. SPDX-License-Identifier: GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/v4l/hist-v4l2.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. c:namespace:: V4L

.. _hist-v4l2:

***************************
Những thay đổi của V4L2 API
***************************

Ngay sau khi V4L API được thêm vào kernel, nó cũng bị chỉ trích
không linh hoạt. Vào tháng 8 năm 1998 Bill Dirks đề xuất một số cải tiến
và bắt đầu làm việc về tài liệu, trình điều khiển mẫu và ứng dụng.
Với sự giúp đỡ của các tình nguyện viên khác, chiếc máy này cuối cùng đã trở thành V4L2 API,
không chỉ là phần mở rộng mà còn là sự thay thế cho V4L API. Tuy nhiên phải mất
bốn năm nữa và hai bản phát hành kernel ổn định cho đến khi API mới được phát hành
cuối cùng đã được chấp nhận để đưa vào kernel ở dạng hiện tại.

Phiên bản đầu
==============

20-08-1998: Phiên bản đầu tiên.

27-08-1998: Chức năng ZZ0000ZZ được giới thiệu.

10-09-1998: Giao diện chuẩn video mới.

18-09-1998: ZZ0001ZZ ioctl được thay thế bằng loại khác
cờ ZZ0002ZZ ZZ0000ZZ vô nghĩa và
bí danh ZZ0003ZZ và ZZ0004ZZ đã được xác định. Ứng dụng có thể thiết lập
cờ này nếu họ có ý định chỉ truy cập các điều khiển, thay vì chụp
các ứng dụng cần quyền truy cập độc quyền. ZZ0005ZZ
số nhận dạng bây giờ là số thứ tự thay vì cờ và
Hàm trợ giúp ZZ0006ZZ lấy id và
các đối số truyền tải.

28-09-1998: Tiêu chuẩn video được cải tiến. Thực hiện điều khiển video riêng lẻ
đếm được.

02-10-1998: Trường ZZ0004ZZ bị xóa khỏi
struct ZZ0005ZZ và các trường sóng mang con màu là
được đổi tên. ZZ0000ZZ ioctl là
đổi tên thành ZZ0001ZZ,
ZZ0002ZZ tới
ZZ0003ZZ. Bản thảo đầu tiên của
Codec API đã được phát hành.

08-11-1998: Nhiều thay đổi nhỏ. Hầu hết các biểu tượng đã được đổi tên. Một số
thay đổi vật chất đối với struct v4l2_capability.

12-11-1998: Hướng đọc/ghi của một số ioctls bị xác định sai.

14-11-1998: ZZ0002ZZ đổi thành ZZ0003ZZ,
và ZZ0004ZZ đổi thành ZZ0005ZZ. Âm thanh
các điều khiển hiện có thể truy cập được bằng
ZZ0000ZZ và
ZZ0001ZZ ioctls dưới tên bắt đầu
với ZZ0006ZZ. Định nghĩa ZZ0007ZZ đã bị xóa khỏi
ZZ0008ZZ vì nó chỉ được sử dụng một lần trong kernel ZZ0009ZZ
mô-đun. Các định dạng hình ảnh phẳng ZZ0010ZZ và ZZ0011ZZ đã được thêm vào.

28-11-1998: Một vài ký hiệu ioctl đã thay đổi. Giao diện cho codec và video
thiết bị đầu ra đã được thêm vào.

14-01-1999: Giao diện chụp VBI thô đã được thêm vào.

1999-01-19: ZZ0000ZZ ioctl đã bị xóa.

V4L2 Phiên bản 0.16 1999-01-31
============================

27-01-1999: Hiện tại có một QBUF ioctl, VIDIOC_QWBUF và VIDIOC_QRBUF
đã biến mất. VIDIOC_QBUF lấy v4l2_buffer làm tham số. Đã thêm
điều khiển thu phóng (cắt) kỹ thuật số.

V4L2 Phiên bản 0.18 1999-03-16
============================

Đã thêm lớp tương thích v4l vào V4L2 ioctl vào videodev.c. Người lái xe
người viết, điều này sẽ thay đổi cách bạn triển khai trình xử lý ioctl của mình. Xem
Hướng dẫn viết tài xế. Đã thêm một số mã id kiểm soát.

V4L2 Phiên bản 0.19 1999-06-05
============================

18-03-1999: Điền vào trường danh mục và tên mèo của v4l2_queryctrl
đồ vật trước khi chuyển chúng cho người lái xe. Yêu cầu một sự thay đổi nhỏ đối với
trình xử lý VIDIOC_QUERYCTRL trong trình điều khiển mẫu.

31-03-1999: Khả năng tương thích tốt hơn cho ioctls thu thập bộ nhớ v4l. Yêu cầu
thay đổi trình điều khiển để hỗ trợ đầy đủ các tính năng tương thích mới, xem
Hướng dẫn dành cho người viết trình điều khiển và v4l2cap.c. Đã thêm ID kiểm soát mới:
V4L2_CID_HFLIP, _VFLIP. Đã đổi V4L2_PIX_FMT_YUV422P thành _YUV422P,
và _YUV411P đến _YUV411P.

04-04-1999: Đã thêm một số ID kiểm soát.

07-04-1999: Đã thêm loại điều khiển nút.

02-05-1999: Sửa lỗi đánh máy trong videodev.h và thêm
Cờ V4L2_CTRL_FLAG_GRAYED (sau này là V4L2_CTRL_FLAG_GRABBED).

20-05-1999: Định nghĩa VIDIOC_G_CTRL sai gây ra
sự cố của ioctl này.

05-06-1999: Thay đổi giá trị của V4L2_CID_WHITENESS.

V4L2 Phiên bản 0.20 (1999-09-10)
==============================

Phiên bản 0.20 đã giới thiệu một số thay đổi *không lạc hậu
tương thích* với phiên bản 0.19 và cũ hơn. Mục đích của những thay đổi này là
để đơn giản hóa API, đồng thời làm cho nó có khả năng mở rộng hơn và tuân theo
các quy ước API trình điều khiển Linux phổ biến.

1. Một số lỗi chính tả trong biểu tượng ZZ0000ZZ đã được sửa. cấu trúc v4l2_clip
   đã được thay đổi để tương thích với v4l. (1999-08-30)

2. ZZ0000ZZ đã được thêm vào. (1999-09-05)

3. Bây giờ tất cả các lệnh ioctl() sử dụng đối số nguyên đều lấy một con trỏ
   đến một số nguyên. Khi có ý nghĩa, ioctls sẽ trả về giá trị thực tế
   giá trị mới trong số nguyên được chỉ ra bởi đối số, một giá trị chung
   quy ước trong V4L2 API. Các ioctls bị ảnh hưởng là: VIDIOC_PREVIEW,
   VIDIOC_STREAMON, VIDIOC_STREAMOFF, VIDIOC_S_FREQ,
   VIDIOC_S_INPUT, VIDIOC_S_OUTPUT, VIDIOC_S_EFFECT. Ví dụ

   .. code-block:: c

       err = ioctl (fd, VIDIOC_XXX, V4L2_XXX);

trở thành

   .. code-block:: c

       int a = V4L2_XXX; err = ioctl(fd, VIDIOC_XXX, &a);

4. Tất cả các lệnh định dạng get và set khác nhau được gộp thành một
   ZZ0000ZZ và
   ZZ0001ZZ ioctl tham gia một liên minh và một
   trường loại chọn thành viên công đoàn làm tham số. Mục đích là để
   đơn giản hóa API bằng cách loại bỏ một số ioctls và cho phép các phiên bản mới và
   điều khiển luồng dữ liệu riêng tư mà không cần thêm ioctls mới.

Thay đổi này làm lỗi thời các ioctls sau: ZZ0000ZZ,
   ZZ0001ZZ, ZZ0002ZZ, ZZ0003ZZ,
   ZZ0004ZZ và ZZ0005ZZ. Định dạng hình ảnh
   struct v4l2_format được đổi tên thành struct v4l2_pix_format, trong khi
   struct v4l2_format hiện là cấu trúc bao bọc
   cho tất cả các cuộc đàm phán về định dạng.

5. Tương tự như những thay đổi ở trên, ZZ0000ZZ và
   ZZ0001ZZ ioctls đã được hợp nhất với ZZ0002ZZ và
   ZZ0003ZZ. Trường ZZ0004ZZ trong cấu trúc v4l2_streamparm mới
   chọn thành viên công đoàn tương ứng.

Thay đổi này đã lỗi thời ZZ0000ZZ và
   ZZ0001ZZ ioctls.

6. Việc liệt kê điều khiển đã được đơn giản hóa và có hai cờ điều khiển mới
   được giới thiệu và một người bị loại. Trường ZZ0000ZZ đã được thay thế bằng
   Trường ZZ0001ZZ.

Trình điều khiển hiện có thể gắn cờ các điều khiển không được hỗ trợ và tạm thời không khả dụng
   với ZZ0000ZZ và ZZ0001ZZ
   tương ứng. Tên ZZ0002ZZ cho thấy phạm vi có thể hẹp hơn
   phân loại hơn ZZ0003ZZ. Nói cách khác, có thể có
   nhiều nhóm trong một danh mục. Kiểm soát trong một nhóm sẽ
   thường được rút ra trong một hộp nhóm. Điều khiển ở các dạng khác nhau
   các danh mục có thể có sự tách biệt lớn hơn hoặc thậm chí có thể xuất hiện ở
   cửa sổ riêng biệt.

7. Cấu trúc v4l2_buffer ZZ0000ZZ là
   đã thay đổi thành số nguyên 64 bit, chứa thời gian lấy mẫu hoặc đầu ra
   của khung tính bằng nano giây. Ngoài ra dấu thời gian sẽ ở
   thời gian tuyệt đối của hệ thống, không bắt đầu từ số 0 khi bắt đầu
   suối. Tên kiểu dữ liệu cho dấu thời gian là stamp_t, được định nghĩa là
   số nguyên 64 bit có dấu. Thiết bị đầu ra không được gửi bộ đệm ra ngoài
   cho đến khi thời gian trong trường dấu thời gian đã đến. tôi muốn
   làm theo sự dẫn dắt của SGI và áp dụng hệ thống đánh dấu thời gian đa phương tiện như
   UST (Thời gian hệ thống chưa điều chỉnh) của họ. Xem
   ZZ0001ZZ
   /cpirazzi_engr/lg/time/intro.html. UST sử dụng dấu thời gian
   Số nguyên có dấu 64 bit (không phải cấu trúc thời gian) và được tính bằng nano giây
   đơn vị. Đồng hồ UST bắt đầu ở mức 0 khi hệ thống được khởi động và
   chạy liên tục và thống nhất. Phải mất hơn 292 năm một chút để
   UST bị tràn. Không có cách nào để đặt đồng hồ UST. thường xuyên
   Đồng hồ thời gian trong ngày của Linux có thể được thay đổi định kỳ, điều này sẽ
   gây ra lỗi nếu nó được sử dụng để đánh dấu thời gian cho một chương trình đa phương tiện
   suối. Đồng hồ kiểu UST thực sự sẽ cần một số hỗ trợ trong
   kernel vẫn chưa có. Nhưng để dự đoán, tôi sẽ thay đổi
   trường dấu thời gian thành số nguyên 64 bit và tôi sẽ thay đổi
   hàm v4l2_masterclock_gettime() (chỉ được sử dụng bởi trình điều khiển) để
   trả về số nguyên 64 bit.

8. Trường ZZ0000ZZ đã được thêm vào struct v4l2_buffer. ZZ0001ZZ
   trường đếm các khung hình đã chụp, nó sẽ bị các thiết bị đầu ra bỏ qua. Khi một
   trình điều khiển chụp ảnh sẽ bỏ một khung hình, số thứ tự của khung hình đó sẽ bị bỏ qua.

V4L2 Phiên bản 0.20 thay đổi gia tăng
=====================================

23-12-1999: Trong cấu trúc v4l2_vbi_format,
Trường ZZ0000ZZ trở thành ZZ0001ZZ. Cần có trình điều khiển trước đây
để xóa trường ZZ0002ZZ.

13-01-2000: Cờ ZZ0000ZZ đã được thêm vào.

31-07-2000: Tiêu đề ZZ0000ZZ hiện được bao gồm bởi
ZZ0001ZZ để tương thích với tệp ZZ0002ZZ gốc.

20-11-2000: ZZ0000ZZ và ZZ0001ZZ đã được
đã thêm vào.

25-11-2000: ZZ0000ZZ đã được thêm vào.

04-12-2000: Một vài lỗi chính tả trong tên biểu tượng đã được sửa.

18-01-2001: Để tránh xung đột không gian tên, macro ZZ0000ZZ được xác định trong
tệp tiêu đề ZZ0001ZZ đã được đổi tên thành ZZ0002ZZ.

25-01-2001: Có thể xảy ra sự cố tương thích ở cấp độ trình điều khiển giữa
Tệp ZZ0000ZZ trong Linux 2.4.0 và bao gồm tệp ZZ0001ZZ
trong bản vá ZZ0002ZZ đã được sửa. Người dùng phiên bản cũ hơn của
ZZ0003ZZ trên Linux 2.4.0 nên biên dịch lại V4L và V4L2 của họ
trình điều khiển.

26-01-2001: Có thể có sự không tương thích ở cấp độ hạt nhân giữa
Tệp ZZ0000ZZ trong bản vá ZZ0001ZZ và ZZ0002ZZ
trong Linux 2.2.x có áp dụng các bản vá lỗi devfs đã được sửa.

2001-03-02: Một số ioctl V4L nhất định truyền dữ liệu theo cả hai hướng
mặc dù chúng được xác định bằng tham số chỉ đọc nhưng không hoạt động
một cách chính xác thông qua lớp tương thích ngược. [Giải pháp?]

13-04-2001: Các định dạng RGB 16-bit lớn cuối cùng đã được thêm vào.

17-09-2001: Các định dạng YUV mới và
ZZ0000ZZ và
ZZ0001ZZ ioctls đã được thêm vào.
(Các ioctls ZZ0002ZZ và ZZ0003ZZ cũ không sử dụng
nhiều bộ điều chỉnh vào tài khoản.)

18-09-2000: ZZ0002ZZ đã được thêm vào. Điều này có thể *bị hỏng
khả năng tương thích* như ZZ0000ZZ và
ZZ0001ZZ ioctls bây giờ có thể bị lỗi nếu
Trường struct ZZ0003ZZ ZZ0004ZZ không chứa
ZZ0005ZZ. Trong tài liệu của struct v4l2_vbi_format`,
trường ZZ0006ZZ, cụm từ mơ hồ "cạnh đang lên" đã được đổi thành
“lợi thế dẫn đầu”.

V4L2 Phiên bản 0.20 2000-11-23
============================

Một số thay đổi đã được thực hiện đối với giao diện VBI thô.

1. Các số liệu làm rõ sơ đồ đánh số dòng đã được thêm vào V4L2
   Thông số kỹ thuật API. Các trường ZZ0000ZZ\ [0] và ZZ0001ZZ\ [1] không
   số dòng đếm dài hơn bắt đầu từ số 0. Lý do: a) Các
   định nghĩa trước đây không rõ ràng. b) Các giá trị ZZ0002ZZ\ [] là
   số thứ tự. c) Chẳng ích gì khi phát minh ra một dòng sản phẩm mới
   sơ đồ đánh số. Bây giờ chúng tôi sử dụng số dòng được xác định bởi ITU-R, dấu chấm.
   Khả năng tương thích: Thêm một vào giá trị bắt đầu. Ứng dụng tùy theo
   ngữ nghĩa trước đó có thể không hoạt động chính xác.

2. Hạn chế "count[0] > 0 và count[1] > 0" đã được nới lỏng thành
   "(đếm[0] + đếm[1]) > 0". Lý do: Trình điều khiển có thể phân bổ
   tài nguyên ở mức độ chi tiết của dòng quét và một số dịch vụ dữ liệu
   chỉ được truyền ở trường đầu tiên. Nhận xét cho rằng cả ZZ0000ZZ
   các giá trị thường bằng nhau là sai lầm và vô nghĩa và đã được
   bị loại bỏ. Sự thay đổi này của ZZ0002ZZ với các phiên bản trước đó:
   Trình điều khiển có thể trả về ZZ0001ZZ, ứng dụng có thể không hoạt động chính xác.

3. Trình điều khiển lại được phép trả về giá trị bắt đầu âm (không xác định)
   như đã đề xuất trước đó. Tại sao tính năng này bị loại bỏ vẫn chưa rõ ràng. Cái này
   ZZ0006ZZ có thể thay đổi với các ứng dụng tùy thuộc vào
   giá trị bắt đầu là dương. Việc sử dụng ZZ0001ZZ và ZZ0002ZZ
   mã lỗi với ZZ0000ZZ ioctl là
   được làm rõ. Mã lỗi ZZ0003ZZ cuối cùng đã được ghi lại và
   Trường ZZ0004ZZ trước đây chỉ được đề cập trong
   Tệp tiêu đề ZZ0005ZZ.

4. Các loại bộ đệm mới ZZ0000ZZ và ZZ0001ZZ
   đã được thêm vào. Cái trước là bí danh của ZZ0002ZZ cũ,
   cái sau bị thiếu trong tệp ZZ0003ZZ.

V4L2 Phiên bản 0.20 2002-07-25
============================

Đã thêm đề xuất giao diện VBI được cắt lát.

V4L2 trong Linux 2.5.46, 2002-10
=============================

Khoảng tháng 10 đến tháng 11 năm 2002, trước khi có thông báo đóng băng tính năng của
Linux 2.5, API đã được sửa đổi, rút ​​ra từ kinh nghiệm với V4L2 0.20.
Phiên bản chưa được đặt tên này cuối cùng đã được sáp nhập vào Linux 2.5.46.

1. Như được chỉ định trong ZZ0000ZZ, trình điều khiển phải tạo ra thiết bị liên quan
    các chức năng có sẵn theo tất cả các số thiết bị nhỏ.

2. Chức năng ZZ0000ZZ yêu cầu chế độ truy cập
    ZZ0002ZZ bất kể loại thiết bị. Tất cả trình điều khiển V4L2
    trao đổi dữ liệu với các ứng dụng phải hỗ trợ ZZ0003ZZ
    cờ. Cờ ZZ0004ZZ, biểu tượng V4L2 có bí danh là
    ZZ0005ZZ vô nghĩa để biểu thị các quyền truy cập mà không cần trao đổi dữ liệu
    (ứng dụng bảng điều khiển) đã bị loại bỏ. Trình điều khiển phải ở "chế độ bảng điều khiển"
    cho đến khi ứng dụng cố gắng bắt đầu trao đổi dữ liệu, xem
    ZZ0001ZZ.

3. Cấu trúc v4l2_capability đã thay đổi
    một cách đáng kinh ngạc. Lưu ý rằng kích thước của cấu trúc cũng thay đổi,
    được mã hóa bằng mã yêu cầu ioctl, do đó các thiết bị V4L2 cũ hơn
    sẽ phản hồi bằng mã lỗi ZZ0001ZZ cho phiên bản mới
    ZZ0000ZZ ioctl.

Có các trường mới để nhận dạng trình điều khiển, thiết bị RDS mới
    chức năng ZZ0000ZZ, cờ ZZ0001ZZ
    cho biết thiết bị có bất kỳ đầu nối âm thanh nào hay không, một I/O khác
    khả năng V4L2_CAP_ASYNCIO có thể được gắn cờ. Để đáp lại những điều này
    thay đổi, trường ZZ0002ZZ đã được thiết lập bit và được hợp nhất vào
    Trường ZZ0003ZZ. ZZ0004ZZ được đổi tên thành
    ZZ0005ZZ, ZZ0006ZZ đã thay thế
    ZZ0007ZZ và ZZ0008ZZ và
    ZZ0009ZZ thay thế ZZ0010ZZ.
    ZZ0011ZZ và ZZ0012ZZ đã được hợp nhất thành
    ZZ0013ZZ.

Các trường dự phòng ZZ0002ZZ, ZZ0003ZZ và ZZ0004ZZ là
    bị loại bỏ. Những tính chất này có thể được xác định như mô tả trong
    ZZ0000ZZ và ZZ0001ZZ.

Các trường hơi dễ biến động và do đó hầu như không hữu ích
    ZZ0002ZZ, ZZ0003ZZ, ZZ0004ZZ, ZZ0005ZZ,
    ZZ0006ZZ đã bị xóa. Thông tin này có sẵn dưới dạng
    được mô tả trong ZZ0000ZZ và ZZ0001ZZ.

ZZ0001ZZ đã bị xóa. Chúng tôi tin rằng hàm select()
    đủ quan trọng để yêu cầu hỗ trợ nó trong tất cả các trình điều khiển V4L2
    trao đổi dữ liệu với các ứng dụng. Sự dư thừa
    Cờ ZZ0002ZZ đã bị xóa, thông tin này là
    có sẵn như được mô tả trong ZZ0000ZZ.

4. Trong struct v4l2_input ZZ0000ZZ
    trường và trường ZZ0001ZZ và cờ duy nhất của nó
    ZZ0002ZZ đã được thay thế bằng trường ZZ0003ZZ mới.
    Thay vì liên kết một đầu vào video với một đầu vào âm thanh, trường này
    báo cáo tất cả đầu vào âm thanh mà đầu vào video này kết hợp với.

Các trường mới là ZZ0000ZZ (đảo ngược liên kết cũ từ bộ dò sang
    đầu vào video), ZZ0001ZZ và ZZ0002ZZ.

Theo đó struct v4l2_output bị mất
    Các trường ZZ0000ZZ và ZZ0001ZZ. ZZ0002ZZ,
    Thay vào đó, ZZ0003ZZ và ZZ0004ZZ đã được thêm vào.

5. Trường struct v4l2_audio ZZ0000ZZ là
    được đổi tên thành ZZ0001ZZ để thống nhất với các cấu trúc khác. Một cái mới
    cờ khả năng ZZ0002ZZ đã được thêm vào để chỉ ra nếu
    đầu vào âm thanh được đề cập có hỗ trợ âm thanh nổi.
    ZZ0003ZZ và cờ ZZ0004ZZ tương ứng
    gỡ bỏ đâu. Điều này có thể được thực hiện dễ dàng bằng cách sử dụng các điều khiển.
    (Tuy nhiên, điều tương tự cũng áp dụng cho AVL vẫn còn đó.)

Một lần nữa để đảm bảo tính nhất quán, trường struct v4l2_audioout ZZ0000ZZ đã được đổi tên
    tới ZZ0001ZZ.

6. Trường struct v4l2_tuner ZZ0000ZZ là
    được thay thế bằng trường ZZ0001ZZ, cho phép các thiết bị có nhiều
    bộ chỉnh âm. Liên kết giữa đầu vào video và bộ điều chỉnh hiện đã bị đảo ngược,
    đầu vào trỏ đến bộ chỉnh của chúng. Cấu trúc con ZZ0002ZZ đã trở thành một
    bộ đơn giản (thông tin thêm về điều này bên dưới) và chuyển vào struct v4l2_input.
    Trường ZZ0003ZZ đã được thêm vào.

Theo đó trong struct v4l2_modulator
    ZZ0000ZZ đã được thay thế bằng trường ZZ0001ZZ.

Trong cấu trúc v4l2_ần số ZZ0000ZZ
    trường được thay thế bằng trường ZZ0001ZZ chứa thông tin tương ứng
    số chỉ mục của bộ điều chỉnh hoặc bộ điều biến. Trường ZZ0002ZZ của bộ điều chỉnh đã được thêm vào
    và trường ZZ0003ZZ trở nên lớn hơn cho các tiện ích mở rộng trong tương lai
    (đặc biệt là bộ điều chỉnh vệ tinh).

7. Ý tưởng về tiêu chuẩn video hoàn toàn minh bạch đã bị loại bỏ.
    Kinh nghiệm cho thấy các ứng dụng phải có khả năng làm việc với video
    tiêu chuẩn ngoài việc hiển thị cho người dùng một menu. Thay vì liệt kê
    các tiêu chuẩn được hỗ trợ với ứng dụng ioctl hiện có thể tham khảo
    tiêu chuẩn của ZZ0000ZZ và các ký hiệu
    được xác định trong tệp tiêu đề ZZ0007ZZ. Để biết chi tiết xem
    ZZ0001ZZ. ZZ0002ZZ và
    ZZ0003ZZ bây giờ lấy một con trỏ tới đây
    gõ làm đối số. ZZ0004ZZ là
    được thêm vào để tự động phát hiện tiêu chuẩn nhận được, nếu phần cứng có điều này
    khả năng. Trong struct v4l2_standard an
    Trường ZZ0008ZZ đã được thêm vào cho
    ZZ0005ZZ. A
    Trường ZZ0006ZZ có tên ZZ0009ZZ đã được thêm làm
    mã định danh có thể đọc được bằng máy, đồng thời thay thế ZZ0010ZZ
    lĩnh vực. Trường ZZ0011ZZ gây hiểu lầm đã được đổi tên thành
    ZZ0012ZZ. Thông tin ZZ0013ZZ hiện đã lỗi thời,
    ban đầu cần thiết để phân biệt giữa các biến thể của tiêu chuẩn,
    bị loại bỏ.

Cấu trúc ZZ0001ZZ đã không còn tồn tại.
    ZZ0000ZZ hiện đưa con trỏ tới một
    struct v4l2_standard trực tiếp. các
    thông tin về những tiêu chuẩn được hỗ trợ bởi một video cụ thể
    đầu vào hoặc đầu ra được chuyển vào struct v4l2_input
    và các trường struct v4l2_output có tên ZZ0002ZZ,
    tương ứng.

8. Các trường cấu trúc ZZ0000ZZ
    ZZ0001ZZ và ZZ0002ZZ không bắt kịp và/hoặc không
    được thực hiện như mong đợi và do đó bị loại bỏ.

9. ZZ0000ZZ ioctl đã được thêm vào
    đàm phán các định dạng dữ liệu như với
    ZZ0001ZZ, nhưng không có chi phí hoạt động
    lập trình phần cứng và bất kể I/O đang diễn ra.

Trong struct v4l2_format, liên kết ZZ0000ZZ là
    được mở rộng để chứa struct v4l2_window. Tất cả
    Hiện có thể đàm phán định dạng hình ảnh với ZZ0001ZZ,
    ZZ0002ZZ và ZZ0003ZZ; ioctl. ZZ0004ZZ
    và ZZ0005ZZ ioctls để chuẩn bị cho lớp phủ video
    bị loại bỏ. Trường ZZ0006ZZ đã thay đổi thành loại enum v4l2_buf_type và
    tên loại bộ đệm đã thay đổi như sau.


    .. flat-table::
:hàng tiêu đề: 1
	:cột sơ khai: 0

* - Định nghĩa cũ
	  - enum v4l2_buf_type
	* - ZZ0000ZZ
	  -ZZ0001ZZ
	* - ZZ0002ZZ
	  - Tạm thời bỏ qua
	* - ZZ0003ZZ
	  - Tạm thời bỏ qua
	* - ZZ0004ZZ
	  - Tạm thời bỏ qua
	* - ZZ0005ZZ
	  - Tạm thời bỏ qua
	* - ZZ0006ZZ
	  - Tạm thời bỏ qua
	* - ZZ0007ZZ
	  - ZZ0008ZZ
	* - ZZ0009ZZ
	  -ZZ0010ZZ
	* - ZZ0011ZZ
	  -ZZ0012ZZ
	* - ZZ0013ZZ
	  -ZZ0014ZZ
	* - ZZ0015ZZ
	  -ZZ0016ZZ
	* - ZZ0017ZZ
	  -ZZ0018ZZ
	* - ZZ0019ZZ
	  - ZZ0020ZZ (nhưng điều này không được dùng nữa)

10. Trong struct v4l2_fmtdesc, trường enum v4l2_buf_type có tên ZZ0001ZZ là
    được thêm vào như trong struct v4l2_format. ZZ0002ZZ ioctl là không
    cần thiết lâu hơn và đã bị loại bỏ. Những cuộc gọi này có thể được thay thế bằng
    ZZ0000ZZ với loại ZZ0003ZZ.

11. Trong struct v4l2_pix_format ZZ0000ZZ
    trường đã bị xóa, giả sử các ứng dụng nhận dạng được định dạng
    bởi mã bốn ký tự của nó đã biết độ sâu màu và các mã khác
    đừng quan tâm đến nó. Lý do tương tự dẫn đến việc loại bỏ
    Cờ ZZ0001ZZ. các
    Cờ ZZ0002ZZ đã bị xóa vì trình điều khiển
    không được phép chuyển đổi hình ảnh trong không gian kernel. Thư viện người dùng
    thay vào đó, các chức năng chuyển đổi nên được cung cấp. các
    Cờ ZZ0003ZZ là dư thừa. Ứng dụng có thể
    đặt trường ZZ0004ZZ về 0 để có giá trị mặc định hợp lý.
    Vì các cờ còn lại cũng được thay thế nên trường ZZ0005ZZ
    chính nó đã bị loại bỏ.

Các cờ xen kẽ đã được thay thế bằng giá trị enum v4l2_field trong
    trường ZZ0000ZZ mới được thêm vào.

    .. flat-table::
:hàng tiêu đề: 1
	:cột sơ khai: 0

* - Cờ cũ
	  - enum v4l2_field
	* - ZZ0000ZZ
	  - ?
	* - ZZ0001ZZ = ZZ0002ZZ
	  -ZZ0003ZZ
	* - ZZ0004ZZ = ZZ0005ZZ
	  -ZZ0006ZZ
	* - ZZ0007ZZ = ZZ0008ZZ
	  -ZZ0009ZZ
	* - ZZ0010ZZ
	  -ZZ0011ZZ
	* - ZZ0012ZZ
	  - ZZ0013ZZ
	* - ZZ0014ZZ
	  -ZZ0015ZZ

Các cờ không gian màu đã được thay thế bằng giá trị enum v4l2_colorspace trong
    trường ZZ0000ZZ mới được thêm vào, trong đó một trong
    ZZ0001ZZ, ZZ0002ZZ,
    ZZ0003ZZ hoặc
    ZZ0004ZZ thay thế ZZ0005ZZ.

12. Trong struct v4l2_requestbuffers
    Trường ZZ0001ZZ được xác định chính xác là enum v4l2_buf_type. Các loại bộ đệm
    đã thay đổi như đã đề cập ở trên. Loại trường ZZ0002ZZ mới
    enum v4l2_memory đã được thêm vào để phân biệt giữa
    Các phương thức I/O sử dụng bộ đệm được cấp phát bởi trình điều khiển hoặc
    ứng dụng. Xem ZZ0000ZZ để biết chi tiết.

13. Trong struct v4l2_buffer, trường ZZ0001ZZ là
    được xác định chính xác là enum v4l2_buf_type.
    Các loại bộ đệm đã thay đổi như đã đề cập ở trên. Trường thuộc loại ZZ0002ZZ
    enum v4l2_field đã được thêm vào để cho biết liệu
    bộ đệm chứa trường trên cùng hoặc dưới cùng. Những lá cờ dã chiến cũ đã
    bị loại bỏ. Vì không có đồng hồ thời gian hệ thống chưa được điều chỉnh nào được thêm vào
    kernel theo kế hoạch, trường ZZ0003ZZ đã thay đổi từ loại
    stamp_t, số nguyên 64 bit không dấu biểu thị thời gian mẫu trong
    nano giây, để cấu trúc thời gian. Với việc bổ sung
    của phương pháp ánh xạ bộ nhớ thứ hai, trường ZZ0004ZZ được chuyển vào
    union ZZ0005ZZ và trường ZZ0006ZZ mới thuộc loại enum v4l2_memory
    đã được thêm vào để phân biệt giữa
    Các phương pháp vào/ra. Xem ZZ0000ZZ để biết chi tiết.

Cờ ZZ0000ZZ được sử dụng bởi khả năng tương thích V4L
    lớp, sau khi thay đổi mã này, nó không còn cần thiết nữa. các
    Cờ ZZ0001ZZ sẽ cho biết bộ đệm có
    thực sự được phân bổ trong bộ nhớ thiết bị chứ không phải hệ thống có khả năng DMA
    trí nhớ. Nó hầu như không hữu ích và vì vậy đã bị loại bỏ.

14. Trong struct v4l2_framebuffer
    Mảng ZZ0000ZZ dự đoán bộ đệm đôi và ba trong
    tuy nhiên, bộ nhớ video ngoài màn hình không xác định đồng bộ hóa
    cơ chế, đã được thay thế bằng một con trỏ duy nhất. các
    Cờ ZZ0001ZZ và ZZ0002ZZ đã được
    bị loại bỏ. Các ứng dụng có thể xác định khả năng này chính xác hơn
    sử dụng giao diện cắt xén và chia tỷ lệ mới. các
    Cờ ZZ0003ZZ đã được thay thế bằng
    ZZ0004ZZ và
    ZZ0005ZZ.

15. Trong struct v4l2_clip ZZ0000ZZ, ZZ0001ZZ,
    Trường ZZ0002ZZ và ZZ0003ZZ được chuyển vào cấu trúc con ZZ0004ZZ của
    gõ struct v4l2_orth. ZZ0005ZZ và ZZ0006ZZ
    các trường được đổi tên thành ZZ0007ZZ và ZZ0008ZZ, i. đ. bù đắp cho một
    nguồn gốc phụ thuộc vào ngữ cảnh.

16. Trong struct v4l2_window ZZ0000ZZ, ZZ0001ZZ,
    Trường ZZ0002ZZ và ZZ0003ZZ được chuyển vào cấu trúc con ZZ0004ZZ như
    ở trên. Trường ZZ0005ZZ thuộc loại enum v4l2_field đã được thêm vào
    phân biệt giữa lớp phủ trường và khung (xen kẽ).

17. Giao diện zoom kỹ thuật số, bao gồm cấu trúc ZZ0001ZZ,
    cấu trúc ZZ0002ZZ, ZZ0003ZZ và
    ZZ0004ZZ đã được thay thế bằng kiểu cắt xén mới và
    giao diện mở rộng quy mô. Trước đây chưa sử dụng
    cấu trúc v4l2_cropcap và cấu trúc v4l2_crop
    nơi được xác định lại cho mục đích này. Xem ZZ0000ZZ để biết chi tiết.

18. Trong cấu trúc v4l2_vbi_format,
    Trường ZZ0000ZZ hiện chứa mã gồm bốn ký tự như được sử dụng
    để xác định các định dạng hình ảnh video và thay thế ZZ0001ZZ
    định nghĩa ZZ0002ZZ. Trường ZZ0003ZZ là
    mở rộng.

19. Trong struct v4l2_captureparm loại
    trường ZZ0000ZZ đã thay đổi từ dài không dấu thành
    cấu trúc v4l2_fract. Điều này cho phép tính chính xác
    biểu thức bội số của tốc độ khung hình NTSC-M 30000/1001. Một cái mới
    trường ZZ0001ZZ đã được thêm vào để kiểm soát hành vi của trình điều khiển trong
    đọc chế độ I/O.

Những thay đổi tương tự cũng được thực hiện đối với struct v4l2_outputparm.

20. Cấu trúc ZZ0001ZZ và
    ZZ0002ZZ ioctl đã bị loại bỏ. Ngoại trừ khi sử dụng
    ZZ0000ZZ, dù sao cũng bị giới hạn, cái này
    thông tin đã có sẵn cho các ứng dụng.

21. Ví dụ chuyển đổi từ không gian màu RGB sang YCbCr cũ
    Tài liệu V4L2 không chính xác, điều này đã được sửa trong
    ZZ0000ZZ.

V4L2 2003-06-19
===============

1. Cờ khả năng mới ZZ0000ZZ đã được thêm cho các thiết bị vô tuyến.
   Trước sự thay đổi này, các thiết bị vô tuyến sẽ chỉ nhận dạng bằng cách có
   chính xác một bộ chỉnh có trường loại ghi ZZ0001ZZ.

2. Cơ chế ưu tiên truy cập trình điều khiển tùy chọn đã được thêm vào, xem
   ZZ0000ZZ để biết chi tiết.

3. Giao diện đầu vào và đầu ra âm thanh được phát hiện là không đầy đủ.

Trước đây ZZ0000ZZ ioctl sẽ
   liệt kê các đầu vào âm thanh có sẵn. Một ioctl để xác định
   đầu vào âm thanh hiện tại, nếu có nhiều đầu vào kết hợp với video hiện tại
   đầu vào, không tồn tại. Vì vậy ZZ0003ZZ đã được đổi tên thành
   ZZ0004ZZ, ioctl này đã bị xóa trên Kernel 2.6.39. các
   ZZ0001ZZ ioctl đã được thêm vào
   liệt kê đầu vào âm thanh, trong khi
   ZZ0002ZZ hiện báo cáo hiện tại
   đầu vào âm thanh.

Những thay đổi tương tự đã được thực hiện đối với
   ZZ0000ZZ và
   ZZ0001ZZ.

Cho đến khi mô-đun "videodev" sẽ tự động dịch
   giữa ioctls cũ và mới, nhưng trình điều khiển và ứng dụng phải
   được cập nhật để biên dịch lại thành công.

4. Ioctl ZZ0000ZZ không chính xác
   được xác định bằng tham số ghi-đọc. Nó đã được thay đổi thành chỉ viết,
   trong khi phiên bản ghi-đọc được đổi tên thành ZZ0001ZZ.
   Ioctl cũ đã bị xóa trên Kernel 2.6.39. Cho đến khi xa hơn nữa
   mô-đun hạt nhân "videodev" sẽ tự động dịch sang mô-đun hạt nhân mới
   phiên bản, vì vậy trình điều khiển phải được biên dịch lại chứ không phải ứng dụng.

5. ZZ0000ZZ đã phát biểu không chính xác rằng việc cắt hình chữ nhật xác định
   những vùng có thể xem được video. Đoạn cắt đó đúng đấy
   hình chữ nhật xác định các vùng nơi video ZZ0001ZZ sẽ được hiển thị, v.v.
   bề mặt đồ họa có thể được nhìn thấy.

6. ZZ0000ZZ và
   ZZ0001ZZ ioctls được xác định bằng
   tham số chỉ ghi, không nhất quán với các ioctls khác đang sửa đổi chúng
   lý lẽ. Chúng được đổi thành ghi-đọc, trong khi hậu tố ZZ0002ZZ
   đã được thêm vào các phiên bản chỉ ghi. Các ioctls cũ đã bị xóa trên
   Hạt nhân 2.6.39. Trình điều khiển và ứng dụng giả sử tham số không đổi
   cần một bản cập nhật

V4L2 2003-11-05
===============

1. Trong ZZ0000ZZ, các định dạng pixel sau không chính xác
   được chuyển từ thông số kỹ thuật V4L2 của Bill Dirks. Mô tả bên dưới
   tham chiếu đến byte trong bộ nhớ, theo thứ tự địa chỉ tăng dần.


   .. flat-table::
       :header-rows:  1
       :stub-columns: 0

       * - Symbol
- Trong tài liệu này trước khi sửa đổi 0,5
	 - Đã sửa
       * - ZZ0000ZZ
	 - B, G, R
	 - R, G, B
       * - ZZ0001ZZ
	 - R, G, B
	 - B, G, R
       * - ZZ0002ZZ
	 - B, G, R, X
	 - R, G, B, X
       * - ZZ0003ZZ
	 - R, G, B, X
	 - B, G, R, X

Ví dụ ZZ0000ZZ luôn đúng.

Trong ZZ0000ZZ ánh xạ của V4L
   Định dạng ZZ0001ZZ và ZZ0002ZZ sang V4L2
   định dạng pixel đã được sửa cho phù hợp.

2. Không liên quan đến các bản sửa lỗi ở trên, trình điều khiển vẫn có thể hiểu một số V4L2
   Định dạng pixel RGB khác nhau. Những vấn đề này vẫn chưa được giải quyết,
   để biết chi tiết, xem ZZ0000ZZ.

V4L2 trong Linux 2.6.6, 2004-05-09
===============================

1. Ioctl ZZ0000ZZ không chính xác
   được xác định bằng tham số chỉ đọc. Bây giờ nó được định nghĩa là ghi-đọc
   ioctl, trong khi phiên bản chỉ đọc được đổi tên thành
   ZZ0001ZZ. Ioctl cũ đã bị xóa trên Kernel 2.6.39.

V4L2 trong Linux 2.6.8
===================

1. Một trường mới ZZ0000ZZ (ZZ0001ZZ cũ) đã được thêm vào
   cấu trúc v4l2_buffer. Mục đích của việc này
   trường là luân phiên giữa các đầu vào video (ví dụ: camera) trong bước
   với quá trình quay video. Chức năng này phải được kích hoạt với
   cờ ZZ0002ZZ mới. Trường ZZ0003ZZ là không
   chỉ đọc dài hơn.

Lỗi thông số V4L2 2004-08-01
============================

1. Giá trị trả về của hàm ZZ0000ZZ không chính xác
   được ghi lại.

2. ioctls đầu ra âm thanh kết thúc bằng -AUDOUT, không phải -AUDIOOUT.

3. Trong ví dụ về Đầu vào âm thanh hiện tại, ZZ0000ZZ ioctl đã sử dụng
   lập luận sai lầm.

4. Tài liệu của ZZ0000ZZ và
   ZZ0001ZZ ioctls đã không đề cập đến
   trường struct v4l2_buffer ZZ0002ZZ. Đó là
   cũng bị thiếu trong các ví dụ. Ngoài ra trên trang ZZ0003ZZ, ZZ0004ZZ
   mã lỗi không được ghi lại.

V4L2 trong Linux 2.6.14
====================

1. Giao diện VBI được cắt lát mới đã được thêm vào. Nó được ghi lại trong
   ZZ0000ZZ và thay thế giao diện được đề xuất lần đầu tiên trong V4L2
   đặc điểm kỹ thuật 0.8.

V4L2 trong Linux 2.6.15
====================

1. ZZ0000ZZ ioctl đã được thêm vào.

2. Chuẩn video mới ZZ0001ZZ, ZZ0002ZZ,
   ZZ0003ZZ (một bộ SECAM D, K và K1) và
   ZZ0004ZZ (một bộ ZZ0005ZZ và
   ZZ0006ZZ) đã được xác định. Lưu ý ZZ0007ZZ
   bộ hiện bao gồm ZZ0008ZZ. Xem thêm
   ZZ0000ZZ.

3. ZZ0000ZZ và ZZ0001ZZ ioctl được đổi tên thành
   ZZ0002ZZ và ZZ0003ZZ tương ứng. của họ
   đối số đã được thay thế bằng một cấu trúc
   Con trỏ ZZ0004ZZ. (Các
   ZZ0005ZZ và ZZ0006ZZ ioctls đã bị xóa
   trong Linux 2.6.25.)

Thông số kỹ thuật của V4L2 bị lỗi 27-11-2005
============================

Ví dụ chụp trong ZZ0000ZZ được gọi là
ZZ0001ZZ ioctl mà không kiểm tra xem
cắt xén được hỗ trợ. Trong ví dụ lựa chọn chuẩn video ở
ZZ0002ZZ cuộc gọi ZZ0003ZZ được sử dụng
loại đối số sai.

Lỗi thông số V4L2 2006-01-10
============================

1. Cờ ZZ0000ZZ trong struct v4l2_input không chỉ
   cho biết liệu bộ khử màu có được bật hay không và nó có hoạt động hay không.
   (Bộ diệt màu sẽ vô hiệu hóa giải mã màu khi phát hiện không có màu
   trong tín hiệu video để cải thiện chất lượng hình ảnh.)

2. ZZ0000ZZ là ioctl ghi-đọc, không phải
   chỉ ghi như đã nêu trên trang tham khảo của nó. Ioctl đã thay đổi vào năm 2003
   như đã lưu ý ở trên.

Lỗi thông số V4L2 2006-02-03
============================

1. Trong struct v4l2_captureparm và struct v4l2_outputparm ZZ0000ZZ
   trường cho thời gian tính bằng giây chứ không phải micro giây.

Lỗi thông số V4L2 2006-02-04
============================

1. Trường ZZ0000ZZ trong struct v4l2_window
   phải trỏ tới mảng struct v4l2_clip chứ không phải
   một danh sách liên kết, bởi vì trình điều khiển bỏ qua
   cấu trúc v4l2_clip. Con trỏ ZZ0001ZZ.

V4L2 trong Linux 2.6.17
====================

1. Đã thêm macro tiêu chuẩn video mới: ZZ0000ZZ (NTSC M
   Hàn Quốc) và các bộ ZZ0001ZZ, ZZ0002ZZ,
   ZZ0003ZZ và ZZ0004ZZ. ZZ0005ZZ và
   Bộ ZZ0006ZZ hiện bao gồm ZZ0007ZZ và
   ZZ0008ZZ tương ứng.

2. Một ZZ0001ZZ mới đã được xác định để ghi lại cả hai
   ngôn ngữ của một chương trình song ngữ. Việc sử dụng
   ZZ0002ZZ cho mục đích này hiện không được dùng nữa. Xem
   phần ZZ0000ZZ để biết chi tiết.

Thông số kỹ thuật của V4L2 lỗi 23-09-2006 (Bản nháp 0.15)
=========================================

1. Ở nhiều nơi ZZ0000ZZ và
   ZZ0001ZZ của giao diện VBI được cắt lát là
   không được đề cập cùng với các loại bộ đệm khác.

2. Trong ZZ0000ZZ đã làm rõ rằng
   Trường struct v4l2_audio ZZ0001ZZ là trường cờ.

3. ZZ0000ZZ không đề cập đến VBI được cắt lát và radio
   cờ khả năng

4. Trong ZZ0000ZZ đã làm rõ rằng
   các ứng dụng phải khởi tạo trường ZZ0002ZZ của bộ điều chỉnh
   struct v4l2_ Frequency trước khi gọi
   ZZ0001ZZ.

5. Mảng ZZ0000ZZ trong struct v4l2_requestbuffers có 2 phần tử,
   không phải 32.

6. Trong ZZ0000ZZ và ZZ0001ZZ tên tệp thiết bị
   ZZ0002ZZ chưa bao giờ được sử dụng đã được thay thế bằng ZZ0003ZZ.

7. Với Linux 2.6.15, phạm vi có thể có của các số phụ của thiết bị VBI là
   mở rộng từ 224-239 lên 224-255. Theo đó tên tập tin thiết bị
   Hiện đã có thể sử dụng ZZ0000ZZ đến ZZ0001ZZ.

V4L2 trong Linux 2.6.18
====================

1. Ioctls ZZ0000ZZ mới,
   ZZ0001ZZ và
   ZZ0002ZZ đã được thêm vào, một
   gắn cờ để bỏ qua các điều khiển không được hỗ trợ với
   ZZ0003ZZ, loại điều khiển mới
   ZZ0006ZZ và ZZ0007ZZ
   (enum v4l2_ctrl_type) và các cờ điều khiển mới
   ZZ0008ZZ, ZZ0009ZZ,
   ZZ0010ZZ và ZZ0011ZZ
   (ZZ0004ZZ). Xem ZZ0005ZZ để biết chi tiết.

V4L2 trong Linux 2.6.19
====================

1. Trong struct v4l2_sliced_vbi_cap a
   trường loại bộ đệm đã được thêm vào thay thế trường dành riêng. Lưu ý trên
   các kiến trúc có kích thước của kiểu enum khác với kiểu int
   kích thước của cấu trúc thay đổi. các
   ZZ0000ZZ ioctl
   đã được xác định lại từ chỉ đọc sang viết-đọc. Các ứng dụng phải
   khởi tạo trường loại và xóa các trường dành riêng ngay bây giờ. Những cái này
   ZZ0001ZZ có thể thay đổi với trình điều khiển cũ hơn và
   ứng dụng.

2. Các ioctls ZZ0000ZZ
   và
   ZZ0001ZZ
   đã được thêm vào.

3. Định dạng pixel mới ZZ0001ZZ (ZZ0000ZZ) đã có
   đã thêm vào.

Thông số kỹ thuật của V4L2 lỗi 12-10-2006 (Bản nháp 0.17)
=========================================

1. ZZ0001ZZ (ZZ0000ZZ) là YUV 4:2:0, không phải
   định dạng 4:2:2.

V4L2 trong Linux 2.6.21
====================

1. Tệp tiêu đề ZZ0000ZZ hiện được cấp phép kép theo GNU
   Giấy phép Công cộng Chung phiên bản hai hoặc mới hơn và theo điều khoản 3
   Giấy phép kiểu BSD.

V4L2 trong Linux 2.6.22
====================

1. Hai đơn hàng mới ZZ0000ZZ và
   ZZ0001ZZ đã được thêm vào. Xem enum v4l2_field để biết
   chi tiết.

2. Ba phương pháp cắt/pha trộn mới với toàn cục hoặc thẳng hoặc
   giá trị alpha cục bộ đảo ngược đã được thêm vào giao diện lớp phủ video.
   Xem mô tả của ZZ0000ZZ
   và ZZ0001ZZ ioctls để biết chi tiết.

Trường ZZ0001ZZ mới đã được thêm vào struct v4l2_window,
   mở rộng cấu trúc. Điều này có thể ZZ0002ZZ với
   các ứng dụng sử dụng trực tiếp struct v4l2_window. Tuy nhiên
   ZZ0000ZZ ioctls, mất một
   con trỏ tới cấu trúc cha struct v4l2_format
   với byte đệm ở cuối, không bị ảnh hưởng.

3. Định dạng của trường ZZ0000ZZ trong struct v4l2_window đã thay đổi từ
   "thứ tự máy chủ RGB32" thành giá trị pixel có cùng định dạng với bộ đệm khung.
   Điều này có thể là ZZ0001ZZ với các ứng dụng hiện có. Trình điều khiển
   hỗ trợ định dạng "thứ tự máy chủ RGB32" chưa được biết đến.

V4L2 trong Linux 2.6.24
====================

1. Các định dạng pixel ZZ0000ZZ, ZZ0001ZZ,
   ZZ0002ZZ, ZZ0003ZZ và
   ZZ0004ZZ đã được thêm vào.

V4L2 trong Linux 2.6.25
====================

1. Các định dạng pixel ZZ0000ZZ và
   ZZ0001ZZ đã được thêm vào.

2. ZZ0000ZZ ZZ0001ZZ mới,
   ZZ0002ZZ, ZZ0003ZZ,
   ZZ0004ZZ và ZZ0005ZZ là
   đã thêm vào. Bộ điều khiển ZZ0006ZZ, ZZ0007ZZ,
   ZZ0008ZZ và ZZ0009ZZ không còn được dùng nữa.

3. Một ZZ0000ZZ đã được thêm vào, với
   bộ điều khiển mới ZZ0001ZZ,
   ZZ0002ZZ, ZZ0003ZZ,
   ZZ0004ZZ, ZZ0005ZZ,
   ZZ0006ZZ, ZZ0007ZZ,
   ZZ0008ZZ, ZZ0009ZZ,
   ZZ0010ZZ, ZZ0011ZZ và
   ZZ0012ZZ.

4. Các ioctls ZZ0001ZZ và ZZ0002ZZ,
   đã được thay thế bởi ZZ0000ZZ
   giao diện trong Linux 2.6.18, nơi cuối cùng đã bị xóa khỏi
   Tệp tiêu đề ZZ0003ZZ.

V4L2 trong Linux 2.6.26
====================

1. Các định dạng pixel ZZ0000ZZ và ZZ0001ZZ
   đã được thêm vào.

2. Đã thêm điều khiển người dùng ZZ0000ZZ và
   ZZ0001ZZ.

V4L2 trong Linux 2.6.27
====================

1. ZZ0000ZZ ioctl
   và khả năng ZZ0001ZZ đã được thêm vào.

2. Các định dạng pixel ZZ0000ZZ, ZZ0001ZZ,
   ZZ0002ZZ, ZZ0003ZZ,
   ZZ0004ZZ, ZZ0005ZZ,
   ZZ0006ZZ và ZZ0007ZZ đã được thêm vào.

V4L2 trong Linux 2.6.28
====================

1. Đã thêm ZZ0000ZZ và
   Mã hóa âm thanh ZZ0001ZZ MPEG.

2. Đã thêm mã hóa video ZZ0000ZZ MPEG.

3. Các định dạng pixel ZZ0000ZZ và
   ZZ0001ZZ đã được thêm vào.

V4L2 trong Linux 2.6.29
====================

1. ZZ0000ZZ ioctl được đổi tên thành
   ZZ0001ZZ và ZZ0002ZZ là
   được giới thiệu ở vị trí của nó. Cấu trúc ZZ0003ZZ cũ được đổi tên thành
   cấu trúc ZZ0004ZZ.

2. Các định dạng pixel ZZ0000ZZ, ZZ0001ZZ và
   ZZ0002ZZ đã được thêm vào.

3. Đã thêm điều khiển camera ZZ0000ZZ,
   ZZ0001ZZ, ZZ0002ZZ và
   ZZ0003ZZ.

V4L2 trong Linux 2.6.30
====================

1. Cờ kiểm soát mới ZZ0000ZZ đã được thêm vào.

2. Điều khiển mới ZZ0000ZZ đã được thêm vào.

V4L2 trong Linux 2.6.32
====================

1. Để dễ dàng so sánh V4L2 API và phiên bản kernel, bây giờ
   V4L2 API được đánh số bằng cách đánh số phiên bản Linux Kernel.

2. Hoàn thiện việc chụp RDS API. Xem ZZ0000ZZ để biết thêm thông tin.

3. Đã thêm các khả năng mới cho bộ điều biến và bộ mã hóa RDS.

4. Thêm mô tả cho libv4l API.

5. Đã thêm hỗ trợ cho điều khiển chuỗi thông qua loại mới
   ZZ0000ZZ.

6. Đã thêm tài liệu ZZ0000ZZ.

7. Đã thêm Lớp điều khiển mở rộng Bộ điều chế FM (FM TX):
   ZZ0000ZZ và ID kiểm soát của chúng.

8. Đã thêm Lớp điều khiển mở rộng của Bộ thu FM (FM RX):
   ZZ0000ZZ và ID kiểm soát của chúng.

9. Đã thêm chương Điều khiển từ xa, mô tả Điều khiển từ xa mặc định
   Ánh xạ bộ điều khiển cho các thiết bị đa phương tiện.

V4L2 trong Linux 2.6.33
====================

1. Đã thêm hỗ trợ cho thời gian Video Kỹ thuật số để hỗ trợ HDTV
   máy thu và máy phát.

V4L2 trong Linux 2.6.34
====================

1. Đã thêm ZZ0001ZZ và ZZ0002ZZ
   điều khiển tới ZZ0000ZZ.

V4L2 trong Linux 2.6.37
====================

1. Xóa vtx (videotext/teletext) API. API này không còn được sử dụng
   và không có phần cứng nào tồn tại để xác minh API. Cũng không có không gian người dùng nào
   các ứng dụng được tìm thấy đã sử dụng nó. Ban đầu nó được lên kế hoạch cho
   loại bỏ trong 2.6.35.

V4L2 trong Linux 2.6.39
====================

1. Các ký hiệu VIDIOC_*_OLD cũ và hỗ trợ V4L1 đã bị xóa.

2. Đã thêm API đa mặt phẳng. Không ảnh hưởng đến khả năng tương thích của hiện tại
   trình điều khiển và ứng dụng. Xem ZZ0000ZZ
   để biết chi tiết.

V4L2 trong Linux 3.1
=================

1. VIDIOC_QUERYCAP hiện trả về phiên bản trên mỗi hệ thống con thay vì phiên bản
   mỗi người lái xe một.

Chuẩn hóa mã lỗi cho ioctl không hợp lệ.

Đã thêm V4L2_CTRL_TYPE_BITMASK.

V4L2 trong Linux 3.2
=================

1. V4L2_CTRL_FLAG_VOLATILE đã được thêm vào để báo hiệu các điều khiển dễ bay hơi
   không gian người dùng.

2. Thêm lựa chọn API để mở rộng khả năng kiểm soát cắt xén và soạn thảo.
   Không ảnh hưởng đến khả năng tương thích của trình điều khiển hiện tại và
   ứng dụng. Xem ZZ0000ZZ để biết chi tiết.

V4L2 trong Linux 3.3
=================

1. Đã thêm điều khiển ZZ0001ZZ vào
   ZZ0000ZZ.

2. Đã thêm trường device_caps vào struct v4l2_capabilities và thêm
   khả năng V4L2_CAP_DEVICE_CAPS mới.

V4L2 trong Linux 3.4
=================

1. Đã thêm ZZ0000ZZ.

2. Mở rộng Thời gian DV API:
   ZZ0000ZZ,
   ZZ0001ZZ và
   ZZ0002ZZ.

V4L2 trong Linux 3.5
=================

1. Đã thêm menu số nguyên, loại mới sẽ là
   V4L2_CTRL_TYPE_INTEGER_MENU.

2. Đã thêm lựa chọn API cho giao diện subdev V4L2:
   ZZ0000ZZ và
   ZZ0001ZZ.

3. Đã thêm ZZ0000ZZ, ZZ0001ZZ,
   ZZ0002ZZ, ZZ0003ZZ,
   ZZ0004ZZ, ZZ0005ZZ và
   Các mục menu ZZ0006ZZ cho
   Điều khiển ZZ0007ZZ.

4. Đã thêm điều khiển ZZ0000ZZ.

5. Đã thêm điều khiển camera ZZ0000ZZ,
   ZZ0001ZZ,
   ZZ0002ZZ, ZZ0003ZZ,
   ZZ0004ZZ, ZZ0005ZZ,
   ZZ0006ZZ, ZZ0007ZZ,
   ZZ0008ZZ, ZZ0009ZZ,
   ZZ0010ZZ và ZZ0011ZZ.

V4L2 trong Linux 3.6
=================

1. Thay thế ZZ0000ZZ trong struct v4l2_buffer bằng
   ZZ0001ZZ và loại bỏ ZZ0002ZZ.

2. Đã thêm V4L2_CAP_VIDEO_M2M và V4L2_CAP_VIDEO_M2M_MPLANE
   khả năng.

3. Đã thêm hỗ trợ cho việc liệt kê băng tần:
   ZZ0000ZZ.

V4L2 trong Linux 3.9
=================

1. Đã thêm các loại dấu thời gian vào trường ZZ0001ZZ trong
   cấu trúc v4l2_buffer. Xem ZZ0000ZZ.

2. Đã thêm cờ thay đổi sự kiện điều khiển ZZ0001ZZ. Xem
   ZZ0000ZZ.

V4L2 trong Linux 3.10
==================

1. Đã xóa DV_PRESET ioctls VIDIOC_G_DV_PRESET lỗi thời và không sử dụng,
   VIDIOC_S_DV_PRESET, VIDIOC_QUERY_DV_PRESET và
   VIDIOC_ENUM_DV_PRESET. Xóa v4l2_input/output có liên quan
   cờ khả năng V4L2_IN_CAP_PRESETS và V4L2_OUT_CAP_PRESETS.

2. Đã thêm ioctl gỡ lỗi mới
   ZZ0000ZZ.

V4L2 trong Linux 3.11
==================

1. Loại bỏ ioctl ZZ0000ZZ lỗi thời.

V4L2 trong Linux 3.14
==================

1. Trong struct v4l2_orth, loại ZZ0000ZZ và
   Các trường ZZ0001ZZ đã thay đổi từ _s32 thành _u32.

V4L2 trong Linux 3.15
==================

1. Đã thêm Giao diện Radio được xác định bằng phần mềm (SDR).

V4L2 trong Linux 3.16
==================

1. Đã thêm sự kiện V4L2_EVENT_SOURCE_CHANGE.

V4L2 trong Linux 3.17
==================

1. Cấu trúc v4l2_pix_format mở rộng. Đã thêm
   cờ định dạng.

2. Đã thêm các loại điều khiển kết hợp và
   ZZ0000ZZ.

V4L2 trong Linux 3.18
==================

1. Đã thêm máy ảnh ZZ0000ZZ và ZZ0001ZZ
   điều khiển.

V4L2 trong Linux 3.19
==================

1. Viết lại chương Colorspace, thêm enum v4l2_ycbcr_encoding mới
   và các trường enum v4l2_quantization thành struct v4l2_pix_format,
   cấu trúc v4l2_pix_format_mplane và cấu trúc v4l2_mbus_framefmt.

V4L2 trong Linux 4.4
=================

1. Đổi tên ZZ0000ZZ thành ZZ0001ZZ. Việc sử dụng
   ZZ0002ZZ hiện không được dùng nữa.

2. Đã thêm điều khiển Bộ điều chỉnh RF ZZ0000ZZ.

3. Đã thêm hỗ trợ máy phát cho Giao diện vô tuyến được xác định bằng phần mềm (SDR).

.. _other:

Mối quan hệ của V4L2 với các API đa phương tiện Linux khác
===============================================

.. _xvideo:

Phần mở rộng video X
-----------------

Phần mở rộng Video X (viết tắt XVideo hoặc chỉ Xv) là phần mở rộng của
hệ thống X Window, ví dụ được triển khai bởi dự án XFree86. của nó
phạm vi tương tự như V4L2, API cho các thiết bị quay và xuất video cho
khách hàng X. Xv cho phép các ứng dụng hiển thị video trực tiếp trong một cửa sổ,
gửi nội dung cửa sổ tới đầu ra TV và chụp hoặc xuất hình ảnh tĩnh
trong bản đồ XPix [#f1]_. Với việc triển khai XFree86 của họ sẽ tạo ra phần mở rộng
có sẵn trên nhiều hệ điều hành và kiến trúc.

Vì trình điều khiển được nhúng vào máy chủ X nên Xv có một số
lợi thế hơn V4L2 ZZ0000ZZ. các
trình điều khiển có thể dễ dàng xác định mục tiêu lớp phủ, tức là. đ. đồ họa có thể nhìn thấy
bộ nhớ hoặc bộ đệm ngoài màn hình để tạo lớp phủ phá hoại. Nó có thể lập trình
RAMDAC để có lớp phủ không phá hủy, chia tỷ lệ hoặc khóa màu hoặc
các chức năng cắt của phần cứng quay video luôn đồng bộ
với các thao tác vẽ hoặc cửa sổ di chuyển hoặc thay đổi cách xếp chồng của chúng
đặt hàng.

Để kết hợp các ưu điểm của Xv và V4L, có sẵn trình điều khiển Xv đặc biệt trong
XFree86 và XOrg, chỉ lập trình bất kỳ Video4Linux nào có khả năng phủ lớp
thiết bị nó tìm thấy. Để kích hoạt nó ZZ0000ZZ phải chứa những thứ này
dòng:

::

Phần "Mô-đun"
	Tải "v4l"
    Phần cuối

Kể từ XFree86 4.2, trình điều khiển này vẫn chỉ hỗ trợ ioctls V4L, tuy nhiên nó
sẽ hoạt động tốt với tất cả các thiết bị V4L2 thông qua V4L2
lớp tương thích ngược. Vì V4L2 cho phép mở nhiều lần nên
có thể (nếu được trình điều khiển V4L2 hỗ trợ) để quay video trong khi X
lớp phủ video được khách hàng yêu cầu. Hạn chế chụp đồng thời
và lớp phủ được thảo luận trong ứng dụng ZZ0000ZZ.

Chỉ liên quan nhẹ đến V4L2, XFree86 mở rộng Xv để hỗ trợ phần cứng
Chuyển đổi và chia tỷ lệ YUV sang RGB để phát lại video nhanh hơn và được thêm vào
giao diện với phần cứng giải mã MPEG-2. API này rất hữu ích để hiển thị
hình ảnh được chụp bằng thiết bị V4L2.

Video kỹ thuật số
-------------

V4L2 không hỗ trợ phát sóng kỹ thuật số mặt đất, cáp hoặc vệ tinh.
Có một dự án riêng nhằm vào máy thu kỹ thuật số. Bạn có thể tìm thấy nó
trang chủ tại ZZ0000ZZ. Linux
DVB API không có kết nối với V4L2 API ngoại trừ trình điều khiển dành cho hybrid
phần cứng có thể hỗ trợ cả hai.

Giao diện âm thanh
----------------

[việc cần làm - OSS/ALSA]

.. _experimental:

Các phần tử API thử nghiệm
=========================

Các phần tử V4L2 API sau đây hiện đang được thử nghiệm và có thể
thay đổi trong tương lai.

- ZZ0000ZZ và
   ZZ0001ZZ ioctls.

- ZZ0000ZZ ioctl.

.. _obsolete:

Các phần tử API lỗi thời
=====================

Các phần tử V4L2 API sau đây đã được thay thế bằng giao diện mới và
không nên được thực hiện trong trình điều khiển mới.

- ZZ0001ZZ và ZZ0002ZZ ioctls. Sử dụng mở rộng
   Bộ điều khiển, ZZ0000ZZ.

- VIDIOC_G_DV_PRESET, VIDIOC_S_DV_PRESET,
   VIDIOC_ENUM_DV_PRESETS và VIDIOC_QUERY_DV_PRESET ioctls. sử dụng
   Định giờ DV API (ZZ0000ZZ).

- ZZ0001ZZ và ZZ0002ZZ ioctls. sử dụng
   ZZ0003ZZ và ZZ0004ZZ,
   ZZ0000ZZ.

.. [#f1]
   This is not implemented in XFree86.