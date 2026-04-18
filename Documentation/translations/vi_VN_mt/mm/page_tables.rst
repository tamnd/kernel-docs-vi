.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/mm/page_tables.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

============
Bảng trang
===========

Bộ nhớ ảo phân trang được phát minh cùng với bộ nhớ ảo như một khái niệm trong
1962 trên Máy tính Ferranti Atlas, máy tính đầu tiên có khả năng phân trang
bộ nhớ ảo. Tính năng này đã được di chuyển sang các máy tính mới hơn và trở thành một tính năng thực tế
tính năng của tất cả các hệ thống tương tự Unix theo thời gian. Vào năm 1985 tính năng này là
có trong Intel 80386, CPU Linux 1.0 được phát triển trên đó.

Bảng trang ánh xạ các địa chỉ ảo mà CPU nhìn thấy thành các địa chỉ vật lý
như đã thấy trên bus bộ nhớ ngoài.

Linux định nghĩa các bảng trang như một hệ thống phân cấp hiện có năm cấp độ trong
chiều cao. Mã kiến trúc cho mỗi kiến trúc được hỗ trợ sau đó sẽ
ánh xạ điều này với các hạn chế của phần cứng.

Địa chỉ vật lý tương ứng với địa chỉ ảo thường được tham chiếu
bởi khung trang vật lý cơ bản. ZZ0001ZZ hoặc ZZ0002ZZ
là địa chỉ vật lý của trang (như được thấy trên bus bộ nhớ ngoài)
chia cho ZZ0000ZZ.

Địa chỉ bộ nhớ vật lý 0 sẽ là ZZ0000ZZ và pfn cao nhất sẽ là
trang cuối cùng của bộ nhớ vật lý, bus địa chỉ bên ngoài của CPU có thể
địa chỉ.

Với độ chi tiết của trang là 4KB và dải địa chỉ 32 bit, pfn 0 ở mức
địa chỉ 0x00000000, pfn 1 ở địa chỉ 0x00001000, pfn 2 ở 0x00002000
v.v. cho đến khi chúng ta đạt pfn 0xfffff ở 0xfffff000. Với các trang 16KB, pfns là
tại 0x00004000, 0x00008000 ... 0xffffc000 và pfn chuyển từ 0 đến 0x3ffff.

Như bạn có thể thấy, với các trang 4KB, địa chỉ cơ sở của trang sử dụng các bit 12-31 của
địa chỉ và đây là lý do tại sao ZZ0000ZZ trong trường hợp này được xác định là 12 và
ZZ0001ZZ thường được xác định theo nghĩa dịch chuyển trang là ZZ0002ZZ

Theo thời gian, một hệ thống phân cấp sâu hơn đã được phát triển để đáp ứng nhu cầu về trí nhớ ngày càng tăng.
kích thước. Khi Linux được tạo ra, các trang 4KB và một bảng trang duy nhất được gọi là
ZZ0000ZZ với 1024 mục đã được sử dụng, bao gồm 4 MB trùng với
thực tế là chiếc máy tính đầu tiên của Torvalds có bộ nhớ vật lý 4 MB. Bài viết trong
bảng đơn này được gọi là ZZ0001ZZ - các mục trong bảng trang.

Hệ thống phân cấp bảng trang phần mềm phản ánh thực tế là phần cứng của bảng trang có
trở nên có thứ bậc và điều đó được thực hiện để tiết kiệm bộ nhớ bảng trang và
tăng tốc độ lập bản đồ.

Tất nhiên người ta có thể tưởng tượng một bảng trang tuyến tính duy nhất với số lượng khổng lồ
các mục, chia nhỏ toàn bộ bộ nhớ thành các trang đơn. Một bảng trang như vậy
sẽ rất thưa thớt vì phần lớn bộ nhớ ảo thường
vẫn chưa được sử dụng. Bằng cách sử dụng các bảng trang phân cấp, các lỗ hổng lớn trong môi trường ảo
không gian địa chỉ không lãng phí bộ nhớ bảng trang có giá trị vì nó đủ
để đánh dấu các khu vực lớn là chưa được ánh xạ ở cấp độ cao hơn trong hệ thống phân cấp bảng trang.

Ngoài ra, trên các CPU hiện đại, mục trong bảng trang cấp cao hơn có thể trỏ trực tiếp
tới một phạm vi bộ nhớ vật lý, cho phép ánh xạ một phạm vi liền kề của một số
megabyte hoặc thậm chí gigabyte trong một mục bảng trang cấp cao duy nhất, lấy
các phím tắt trong việc ánh xạ bộ nhớ ảo vào bộ nhớ vật lý: không cần
duyệt sâu hơn trong hệ thống phân cấp khi bạn tìm thấy một phạm vi được ánh xạ lớn như thế này.

Hệ thống phân cấp bảng trang hiện đã phát triển thành::

+------+
  ZZ0000ZZ
  +------+
     |
     |   +------+
     +-->ZZ0001ZZ
         +------+
            |
            |   +------+
            +-->ZZ0002ZZ
                +------+
                   |
                   |   +------+
                   +-->ZZ0003ZZ
                       +------+
                          |
                          |   +------+
                          +-->ZZ0004ZZ
                              +------+


Các ký hiệu ở các cấp độ khác nhau của hệ thống phân cấp bảng trang có các ký hiệu sau:
nghĩa là bắt đầu từ dưới lên:

- ZZ0005ZZ, ZZ0000ZZ, ZZ0001ZZ = ZZ0006ZZ - đã đề cập trước đó.
  ZZ0007ZZ là một mảng các phần tử ZZ0002ZZ thuộc loại ZZ0003ZZ, mỗi phần tử
  ánh xạ một trang bộ nhớ ảo tới một trang bộ nhớ vật lý.
  Kiến trúc xác định kích thước và nội dung của ZZ0004ZZ.

Một ví dụ điển hình là ZZ0000ZZ có giá trị 32 hoặc 64 bit với
  các bit trên là ZZ0001ZZ (số khung trang) và các bit dưới là một số
  các bit dành riêng cho kiến trúc như bảo vệ bộ nhớ.

Phần ZZ0000ZZ trong tên hơi khó hiểu vì trong Linux 1.0
  điều này đã đề cập đến một mục trong bảng trang duy nhất trong một trang cấp cao nhất
  bảng, nó đã được trang bị thêm để trở thành một mảng các phần tử ánh xạ khi hai cấp độ
  bảng trang được giới thiệu lần đầu tiên nên ZZ0001ZZ là trang thấp nhất
  ZZ0002ZZ, không phải bảng trang ZZ0003ZZ.

- ZZ0003ZZ, ZZ0000ZZ, ZZ0001ZZ = ZZ0004ZZ, phân cấp bên phải
  phía trên ZZ0005ZZ, với ZZ0002ZZ tham chiếu đến ZZ0006ZZ:s.

- ZZ0002ZZ, ZZ0000ZZ, ZZ0001ZZ = ZZ0003ZZ được giới thiệu sau
  các cấp độ khác để xử lý bảng trang 4 cấp. Nó có khả năng không được sử dụng,
  hoặc ZZ0004ZZ như chúng ta sẽ thảo luận sau.

- ZZ0002ZZ, ZZ0000ZZ, ZZ0001ZZ = ZZ0003ZZ đã được giới thiệu
  xử lý bảng trang 5 cấp sau khi ZZ0004ZZ được giới thiệu. Bây giờ mọi chuyện đã rõ ràng
  rằng chúng ta cần thay thế ZZ0005ZZ, ZZ0006ZZ, ZZ0007ZZ, v.v. bằng một hình biểu thị
  cấp thư mục và chúng tôi không thể tiếp tục với các tên đặc biệt nữa. Cái này
  chỉ được sử dụng trên các hệ thống thực sự có 5 cấp độ bảng trang, nếu không thì
  nó được gấp lại.

- ZZ0007ZZ, ZZ0000ZZ, ZZ0001ZZ = ZZ0008ZZ - nhân Linux
  bảng trang chính xử lý PGD cho bộ nhớ kernel vẫn được tìm thấy trong
  ZZ0002ZZ, nhưng mỗi quy trình không gian người dùng trong hệ thống cũng có quy trình riêng
  bối cảnh bộ nhớ và do đó ZZ0009ZZ của riêng nó, được tìm thấy trong ZZ0003ZZ
  lần lượt được tham chiếu đến trong mỗi ZZ0004ZZ. Vậy nhiệm vụ có bộ nhớ
  bối cảnh ở dạng ZZ0005ZZ và điều này lần lượt có một
  Con trỏ ZZ0006ZZ tới thư mục chung của trang tương ứng.

Xin nhắc lại: mỗi cấp độ trong hệ thống phân cấp bảng trang là một ZZ0005ZZ, vì vậy
ZZ0002ZZ chứa con trỏ ZZ0000ZZ tới cấp độ tiếp theo bên dưới, ZZ0003ZZ
chứa các con trỏ ZZ0001ZZ tới các mục ZZ0004ZZ, v.v. Số lượng
con trỏ ở mỗi cấp độ được xác định theo kiến ​​trúc.::

PMD
  --> +------+ PTE
      ZZ0000ZZ-------> +------+
      ZZ0001ZZ- ZZ0002ZZ-------> PAGE
      ZZ0003ZZ \ ZZ0004ZZ
      ZZ0005ZZ \ ...
      ZZ0006ZZ \
      ZZ0007ZZ \ PTE
      +------+ +----> +------+
                         ZZ0008ZZ-------> PAGE
                         ZZ0009ZZ
                           ...


Gấp bảng trang
==================

Nếu kiến trúc không sử dụng tất cả các cấp độ bảng trang, chúng có thể là ZZ0000ZZ
có nghĩa là bị bỏ qua và tất cả các thao tác được thực hiện trên bảng trang sẽ bị
thời gian biên dịch được tăng cường để chỉ bỏ qua một cấp độ khi truy cập cấp độ thấp hơn tiếp theo
cấp độ.

Mã xử lý bảng trang mong muốn trung lập về kiến trúc, chẳng hạn như
trình quản lý bộ nhớ ảo, sẽ cần phải được viết sao cho nó đi qua tất cả
hiện tại có năm cấp độ. Phong cách này cũng nên được ưa thích cho
mã dành riêng cho kiến trúc, để có thể mạnh mẽ trước những thay đổi trong tương lai.


MMU, TLB và Lỗi trang
=========================

ZZ0000ZZ là thành phần phần cứng xử lý ảo
sang các bản dịch địa chỉ vật lý. Nó có thể sử dụng bộ đệm tương đối nhỏ trong phần cứng
gọi là ZZ0001ZZ và ZZ0002ZZ để tăng tốc
những bản dịch này.

Khi CPU truy cập vào một vị trí bộ nhớ, nó sẽ cung cấp một địa chỉ ảo cho MMU,
để kiểm tra xem có bản dịch hiện có trong TLB hoặc trong Trang không
Walk Caches (trên các kiến trúc hỗ trợ chúng). Nếu không tìm thấy bản dịch,
MMU sử dụng các bước đi trong trang để xác định địa chỉ vật lý và tạo bản đồ.

Bit bẩn cho một trang được đặt (tức là được bật) khi trang được ghi vào.
Mỗi trang của bộ nhớ đều có quyền liên quan và các bit bẩn. Cái sau
cho biết trang đã được sửa đổi kể từ khi nó được tải vào bộ nhớ.

Nếu không có gì ngăn cản thì cuối cùng bộ nhớ vật lý có thể được truy cập và
thao tác được yêu cầu trên khung vật lý được thực hiện.

Có một số lý do khiến MMU không thể tìm thấy một số bản dịch nhất định. Nó có thể
xảy ra do CPU đang cố truy cập vào bộ nhớ mà tác vụ hiện tại không thực hiện được
được phép, hoặc vì dữ liệu không có trong bộ nhớ vật lý.

Khi những điều kiện này xảy ra, MMU sẽ gây ra lỗi trang, đó là các loại lỗi
các ngoại lệ báo hiệu cho CPU tạm dừng quá trình thực thi hiện tại và chạy một lệnh đặc biệt
để xử lý các ngoại lệ được đề cập.

Có những nguyên nhân phổ biến và có thể xảy ra gây ra lỗi trang. Những điều này được kích hoạt bởi
kỹ thuật tối ưu hóa quản lý quy trình được gọi là "Phân bổ lười biếng" và
"Sao chép khi ghi". Lỗi trang cũng có thể xảy ra khi các khung hình bị tráo đổi
vào bộ lưu trữ liên tục (hoán đổi phân vùng hoặc tập tin) và bị loại khỏi vật lý của chúng
địa điểm.

Những kỹ thuật này cải thiện hiệu quả bộ nhớ, giảm độ trễ và giảm thiểu dung lượng
nghề nghiệp. Tài liệu này sẽ không đi sâu vào chi tiết về "Lazy Allocation"
và "Copy-on-Write" vì những chủ đề này nằm ngoài phạm vi vì chúng thuộc về
Quy trình quản lý địa chỉ.

Hoán đổi khác biệt với các kỹ thuật được đề cập khác bởi vì nó
không mong muốn vì nó được thực hiện như một phương tiện để giảm bộ nhớ dưới tác vụ nặng.
áp lực.

Hoán đổi không thể hoạt động đối với bộ nhớ được ánh xạ bởi các địa chỉ logic hạt nhân. Đây là một
tập hợp con của không gian ảo kernel ánh xạ trực tiếp một phạm vi liền kề của
bộ nhớ vật lý. Với bất kỳ địa chỉ logic nào, địa chỉ vật lý của nó được xác định
với số học đơn giản trên một offset. Truy cập vào các địa chỉ logic nhanh chóng
vì chúng tránh được nhu cầu tra cứu bảng trang phức tạp với chi phí
các khung hình không thể bị loại bỏ và có thể phân trang được.

Nếu kernel không đủ chỗ cho dữ liệu phải có trong
các khung vật lý, hạt nhân gọi trình diệt hết bộ nhớ (OOM) để nhường chỗ
bằng cách chấm dứt các quy trình có mức độ ưu tiên thấp hơn cho đến khi áp suất giảm xuống mức an toàn
ngưỡng.

Ngoài ra, lỗi trang cũng có thể do lỗi mã hoặc do cố ý
địa chỉ được tạo mà CPU được hướng dẫn truy cập. Một chủ đề của một quá trình
có thể sử dụng các hướng dẫn để đánh địa chỉ bộ nhớ (không dùng chung) không thuộc về
không gian địa chỉ của chính nó hoặc có thể thử thực hiện một lệnh muốn ghi
đến một vị trí chỉ đọc.

Nếu các điều kiện nêu trên xảy ra trong không gian người dùng, kernel sẽ gửi một
Tín hiệu ZZ0000ZZ (SIGSEGV) đến luồng hiện tại. Tín hiệu đó thường
gây ra sự kết thúc của thread và tiến trình mà nó thuộc về.

Tài liệu này sẽ đơn giản hóa và hiển thị một cái nhìn tổng thể về cách thức
Nhân Linux xử lý các lỗi trang này, tạo các bảng và mục nhập của bảng,
kiểm tra xem bộ nhớ có hiện diện hay không và nếu không, yêu cầu tải dữ liệu từ liên tục
lưu trữ hoặc từ các thiết bị khác và cập nhật MMU cũng như bộ nhớ đệm của nó.

Các bước đầu tiên phụ thuộc vào kiến ​​trúc. Hầu hết các kiến trúc đều nhảy tới
ZZ0000ZZ, trong khi trình xử lý ngắt x86 được xác định bởi
Macro ZZ0001ZZ gọi ZZ0002ZZ.

Dù đi theo con đường nào, tất cả các kiến trúc đều kết thúc bằng việc kêu gọi
ZZ0001ZZ để thực hiện công việc phân bổ trang thực tế
các bảng.

Trường hợp đáng tiếc không gọi được ZZ0000ZZ nghĩa là
rằng địa chỉ ảo đang trỏ đến các vùng bộ nhớ vật lý không
được phép truy cập (ít nhất là từ bối cảnh hiện tại). Cái này
điều kiện giải quyết để hạt nhân gửi tín hiệu SIGSEGV nêu trên
đến quá trình và dẫn đến những hậu quả đã được giải thích.

ZZ0000ZZ thực hiện công việc của mình bằng cách gọi một số hàm tới
tìm độ lệch của mục nhập của các lớp trên của bảng trang và phân bổ
các bảng mà nó có thể cần.

Các hàm tìm kiếm phần bù có tên như ZZ0000ZZ, trong đó
"*" dành cho pgd, p4d, pud, pmd, pte; thay vào đó là các chức năng phân bổ
các bảng tương ứng, từng lớp, được gọi là ZZ0001ZZ, sử dụng
quy ước nêu trên để đặt tên chúng theo các loại bảng tương ứng
trong hệ thống phân cấp.

Việc duyệt bảng trang có thể kết thúc ở một trong các lớp giữa hoặc lớp trên (PMD, PUD).

Linux hỗ trợ kích thước trang lớn hơn 4KB thông thường (tức là cái gọi là
ZZ0000ZZ). Khi sử dụng các loại trang lớn hơn này, các trang cấp cao hơn có thể
ánh xạ trực tiếp chúng mà không cần sử dụng các mục nhập trang cấp thấp hơn (PTE). Rất lớn
các trang chứa các vùng vật lý liền kề lớn thường có kích thước từ 2MB đến
1GB. Chúng được ánh xạ tương ứng bởi các mục trang PMD và PUD.

Các trang lớn mang lại một số lợi ích như giảm áp lực TLB,
giảm chi phí bảng trang, hiệu quả phân bổ bộ nhớ và hiệu suất
cải tiến cho một số khối lượng công việc nhất định. Tuy nhiên, những lợi ích này đi kèm với
sự đánh đổi, như lãng phí bộ nhớ và thách thức phân bổ.

Vào cuối quá trình phân bổ, nếu nó không trả về lỗi,
ZZ0000ZZ cuối cùng cũng gọi ZZ0001ZZ, thông qua ZZ0002ZZ
thực hiện một trong các ZZ0003ZZ, ZZ0004ZZ, ZZ0005ZZ.
"đọc", "bò", "chia sẻ" đưa ra gợi ý về lý do và loại lỗi
xử lý.

Việc triển khai thực tế quy trình làm việc rất phức tạp. Thiết kế của nó cho phép
Linux xử lý lỗi trang theo cách phù hợp với từng trường hợp cụ thể
đặc trưng của từng kiến trúc nhưng vẫn có chung một tổng thể
cấu trúc.

Để kết thúc cái nhìn toàn cảnh này về cách Linux xử lý lỗi trang, chúng ta hãy
thêm rằng trình xử lý lỗi trang có thể được tắt và bật tương ứng với
ZZ0000ZZ và ZZ0001ZZ.

Một số đường dẫn mã sử dụng hai hàm sau vì chúng cần
vô hiệu hóa bẫy vào trình xử lý lỗi trang, chủ yếu là để ngăn chặn sự bế tắc.