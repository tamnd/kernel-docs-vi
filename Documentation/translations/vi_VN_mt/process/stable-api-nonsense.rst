.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/process/stable-api-nonsense.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

.. _stable_api_nonsense:

Giao diện trình điều khiển hạt nhân Linux
==================================

(tất cả các câu hỏi của bạn đã được trả lời và sau đó là một số)

Greg Kroah-Hartman <greg@kroah.com>

Điều này được viết để giải thích tại sao Linux **không có hệ nhị phân
giao diện kernel và cũng không có giao diện kernel ổn định**.

.. note::

  Please realize that this article describes the **in kernel** interfaces, not
  the kernel to userspace interfaces.

  The kernel to userspace interface is the one that application programs use,
  the syscall interface.  That interface is **very** stable over time, and
  will not break.  I have old programs that were built on a pre 0.9something
  kernel that still work just fine on the latest 2.6 kernel release.
  That interface is the one that users and application programmers can count
  on being stable.


Tóm tắt điều hành
-----------------
Bạn nghĩ rằng bạn muốn có một giao diện kernel ổn định, nhưng thực sự thì không, và
bạn thậm chí không biết nó.  Điều bạn muốn là một trình điều khiển chạy ổn định và
bạn chỉ nhận được điều đó nếu trình điều khiển của bạn nằm trong cây hạt nhân chính.  Bạn cũng vậy
nhận được nhiều lợi ích tốt khác nếu trình điều khiển của bạn nằm trong kernel chính
cây, tất cả những điều đó đã làm cho Linux trở thành một hệ thống mạnh mẽ, ổn định và trưởng thành như vậy.
hệ điều hành đó là lý do bạn sử dụng nó trong lần đầu tiên
nơi.


giới thiệu
-----

Chỉ có người kỳ quặc muốn viết trình điều khiển hạt nhân mới cần
phải lo lắng về việc thay đổi giao diện trong kernel.  Đối với phần lớn
thế giới, họ không nhìn thấy giao diện này và cũng không quan tâm đến nó
tất cả.

Trước hết, tôi sẽ không giải quyết các vấn đề pháp lý của ZZ0000ZZ về việc đóng cửa
nguồn, nguồn ẩn, đốm màu nhị phân, trình bao bọc nguồn hoặc bất kỳ thuật ngữ nào khác
mô tả trình điều khiển hạt nhân không có mã nguồn của chúng
được phát hành dưới tên GPL.  Hãy tham khảo ý kiến luật sư nếu bạn có bất kỳ vấn đề pháp lý nào
câu hỏi, tôi là một lập trình viên và do đó tôi sẽ mô tả
các vấn đề kỹ thuật ở đây (không phải để làm sáng tỏ các vấn đề pháp lý, chúng
là có thật và bạn cần phải luôn nhận thức được chúng.)

Vì vậy, có hai chủ đề chính ở đây, giao diện hạt nhân nhị phân và tính ổn định.
giao diện nguồn kernel.  Cả hai đều phụ thuộc vào nhau, nhưng chúng ta sẽ
trước tiên hãy thảo luận về nội dung nhị phân để giải quyết vấn đề đó.


Giao diện hạt nhân nhị phân
-----------------------
Giả sử rằng chúng ta có giao diện nguồn kernel ổn định cho kernel,
giao diện nhị phân cũng sẽ xảy ra một cách tự nhiên phải không?  Sai.  làm ơn
hãy xem xét các sự thật sau đây về nhân Linux:

- Tùy thuộc vào phiên bản trình biên dịch C bạn sử dụng mà kernel khác nhau
    cấu trúc dữ liệu sẽ chứa các cấu trúc liên kết khác nhau và
    có thể bao gồm các chức năng khác nhau theo những cách khác nhau (đặt
    có chức năng nội tuyến hay không.) Tổ chức chức năng riêng lẻ
    điều đó không quan trọng lắm, nhưng phần đệm cấu trúc dữ liệu khác nhau thì
    rất quan trọng.

- Tùy thuộc vào các tùy chọn xây dựng hạt nhân mà bạn chọn, một loạt các
    những thứ khác nhau có thể được giả định bởi kernel:

- các cấu trúc khác nhau có thể chứa các trường khác nhau
      - Một số chức năng có thể không được triển khai (ví dụ: một số khóa
	biên dịch thành không có gì đối với các bản dựng không phải SMP.)
      - Bộ nhớ trong kernel có thể được căn chỉnh theo nhiều cách khác nhau,
	tùy thuộc vào các tùy chọn xây dựng.

- Linux chạy trên nhiều kiến ​​trúc bộ xử lý khác nhau.
    Không có cách nào các trình điều khiển nhị phân từ một kiến trúc sẽ chạy
    trên một kiến trúc khác một cách chính xác.

Bây giờ một số vấn đề này có thể được giải quyết bằng cách biên soạn
mô-đun để biết cấu hình hạt nhân cụ thể chính xác, sử dụng cùng một mô-đun chính xác
Trình biên dịch C mà kernel được xây dựng cùng.  Điều này là đủ nếu bạn
muốn cung cấp một mô-đun cho một phiên bản phát hành cụ thể của một phiên bản cụ thể
Phân phối Linux.  Nhưng hãy nhân bản dựng đơn lẻ đó với số lượng
các bản phân phối Linux khác nhau và số lượng các bản phân phối được hỗ trợ khác nhau
bản phân phối Linux và bạn sẽ nhanh chóng gặp ác mộng về
các tùy chọn xây dựng khác nhau trên các bản phát hành khác nhau.  Cũng nhận ra rằng mỗi
Bản phát hành bản phân phối Linux chứa một số hạt nhân khác nhau, tất cả
được điều chỉnh theo các loại phần cứng khác nhau (các loại bộ xử lý khác nhau và
các tùy chọn khác nhau), vì vậy, ngay cả với một bản phát hành duy nhất, bạn sẽ cần phải tạo
nhiều phiên bản của mô-đun của bạn.

Tin tôi đi, bạn sẽ phát điên theo thời gian nếu cố gắng ủng hộ loại hình này
phát hành, tôi đã học được điều này một cách khó khăn từ lâu rồi...


Giao diện nguồn hạt nhân ổn định
-------------------------------

Đây là một chủ đề "không ổn định" hơn nhiều nếu bạn nói chuyện với những người cố gắng
giữ trình điều khiển hạt nhân Linux không có trong cây hạt nhân chính tối đa
ngày theo thời gian.

Quá trình phát triển nhân Linux diễn ra liên tục và với tốc độ nhanh chóng, không bao giờ
dừng lại để giảm tốc độ.  Như vậy, các nhà phát triển kernel tìm thấy lỗi trong
giao diện hiện tại hoặc tìm ra cách tốt hơn để thực hiện mọi việc.  Nếu họ làm
đó, sau đó họ sửa các giao diện hiện tại để hoạt động tốt hơn.  Khi họ làm
vì vậy, tên hàm có thể thay đổi, cấu trúc có thể tăng hoặc giảm và
các tham số chức năng có thể được làm lại.  Nếu điều này xảy ra, tất cả các
các trường hợp giao diện này được sử dụng trong kernel đã được sửa
đồng thời, đảm bảo rằng mọi thứ tiếp tục hoạt động bình thường.

Là một ví dụ cụ thể về điều này, các giao diện USB trong kernel có
trải qua ít nhất ba lần làm lại khác nhau trong suốt vòng đời của nó
hệ thống con.  Những công việc làm lại này được thực hiện để giải quyết một số vấn đề khác nhau
vấn đề:

- Thay đổi từ mô hình luồng dữ liệu đồng bộ sang mô hình không đồng bộ
    một.  Điều này làm giảm sự phức tạp của một số trình điều khiển và
    tăng thông lượng của tất cả trình điều khiển USB như chúng tôi hiện nay
    chạy hầu hết tất cả các thiết bị USB ở tốc độ tối đa có thể.
  - Một sự thay đổi đã được thực hiện trong cách các gói dữ liệu được phân bổ từ
    Lõi USB của trình điều khiển USB để tất cả các trình điều khiển hiện cần cung cấp
    thêm thông tin về lõi USB để sửa một số tài liệu
    bế tắc.

Điều này hoàn toàn trái ngược với một số hệ điều hành nguồn đóng
đã phải duy trì giao diện USB cũ hơn theo thời gian.  Cái này
cung cấp khả năng cho các nhà phát triển mới vô tình sử dụng cái cũ
giao diện và thực hiện mọi việc theo những cách không thích hợp, gây ra sự ổn định của
hệ điều hành phải chịu đựng.

Trong cả hai trường hợp này, tất cả các nhà phát triển đều đồng ý rằng đây là
những thay đổi quan trọng cần được thực hiện và chúng đã được thực hiện với
tương đối ít đau.  Nếu Linux phải đảm bảo rằng nó sẽ duy trì một
giao diện nguồn ổn định, một giao diện mới sẽ được tạo và
cái cũ hơn, bị hỏng sẽ phải được bảo trì theo thời gian, dẫn đến
làm thêm việc cho các nhà phát triển USB.  Vì tất cả các nhà phát triển Linux USB đều làm như vậy
công việc của họ theo thời gian riêng của họ, yêu cầu các lập trình viên làm thêm công việc mà không mất phí
đạt được, miễn phí, không phải là một khả năng.

Vấn đề bảo mật cũng rất quan trọng đối với Linux.  Khi một
vấn đề bảo mật được tìm thấy, nó sẽ được khắc phục trong một khoảng thời gian rất ngắn.  A
nhiều lần điều này đã khiến cho các giao diện kernel bên trong bị lỗi
được làm lại để ngăn chặn sự cố bảo mật xảy ra.  Khi điều này
xảy ra, tất cả các trình điều khiển sử dụng giao diện cũng đã được sửa tại
đồng thời, đảm bảo rằng vấn đề bảo mật đã được khắc phục và không thể
vô tình quay lại vào một thời điểm nào đó trong tương lai.  Nếu các giao diện bên trong
không được phép thay đổi, khắc phục loại sự cố bảo mật này và
đảm bảo rằng điều đó không thể xảy ra lần nữa là không thể.

Giao diện hạt nhân được làm sạch theo thời gian.  Nếu không có ai sử dụng
giao diện hiện tại, nó sẽ bị xóa.  Điều này đảm bảo rằng hạt nhân vẫn còn
càng nhỏ càng tốt và tất cả các giao diện tiềm năng đều được kiểm tra dưới dạng
tốt nhất có thể (các giao diện không được sử dụng gần như không thể
kiểm tra tính hợp lệ.)


phải làm gì
----------

Vì vậy, nếu bạn có trình điều khiển hạt nhân Linux không có trong hạt nhân chính
tree, bạn, một nhà phát triển, phải làm gì?  Phát hành nhị phân
trình điều khiển cho mọi phiên bản hạt nhân khác nhau cho mỗi bản phân phối là một
cơn ác mộng và cố gắng theo kịp giao diện kernel luôn thay đổi
cũng là một công việc vất vả.

Đơn giản, hãy đưa trình điều khiển hạt nhân của bạn vào cây hạt nhân chính (hãy nhớ rằng chúng ta
nói về các trình điều khiển được phát hành theo giấy phép tương thích với GPL tại đây, nếu
mã không thuộc danh mục này, chúc may mắn, bạn ở đây một mình,
đồ đỉa).  Nếu trình điều khiển của bạn ở dạng cây và giao diện kernel thay đổi,
nó sẽ được sửa bởi người thực hiện thay đổi kernel đầu tiên
nơi.  Điều này đảm bảo rằng trình điều khiển của bạn luôn có thể được xây dựng và hoạt động trên
thời gian mà không tốn nhiều công sức.

Tác dụng phụ rất tốt của việc có trình điều khiển của bạn trong cây hạt nhân chính
là:

- Chất lượng của người lái xe sẽ tăng lên khi chi phí bảo trì (đối với
    nhà phát triển ban đầu) sẽ giảm.
  - Các nhà phát triển khác sẽ thêm tính năng vào driver của bạn.
  - Người khác sẽ tìm và sửa lỗi trong driver của bạn.
  - Những người khác sẽ tìm thấy cơ hội điều chỉnh trong trình điều khiển của bạn.
  - Người khác sẽ cập nhật driver cho bạn khi có giao diện bên ngoài
    những thay đổi đòi hỏi nó.
  - Trình điều khiển tự động được cài sẵn trong tất cả các bản phân phối Linux
    mà không cần phải yêu cầu các nhà phân phối thêm nó.

Vì Linux hỗ trợ một số lượng lớn hơn các thiết bị khác nhau "ngay lập tức"
hơn bất kỳ hệ điều hành nào khác và nó hỗ trợ các thiết bị này trên nhiều
kiến trúc bộ xử lý khác với bất kỳ hệ điều hành nào khác, điều này
loại mô hình phát triển đã được chứng minh phải làm điều gì đó đúng :)



------

Cảm ơn Randy Dunlap, Andrew Morton, David Brownell, Hanna Linder,
Robert Love và Nishanth Aravamudan vì những đánh giá và nhận xét của họ về
những bản thảo đầu tiên của bài viết này.
