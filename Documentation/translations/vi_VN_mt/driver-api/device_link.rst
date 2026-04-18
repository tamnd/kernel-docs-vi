.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/driver-api/device_link.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. _device_link:

=================
Liên kết thiết bị
=================

Theo mặc định, lõi trình điều khiển chỉ thực thi sự phụ thuộc giữa các thiết bị
được sinh ra từ mối quan hệ cha mẹ/con cái trong thiết bị
phân cấp: Khi tạm dừng, tiếp tục hoặc tắt hệ thống, các thiết bị
được sắp xếp dựa trên mối quan hệ này, tức là trẻ em luôn bị đình chỉ
trước cha mẹ của chúng và cha mẹ luôn được nối lại trước con cái của nó.

Đôi khi cần phải thể hiện sự phụ thuộc của thiết bị ngoài phạm vi
mối quan hệ cha mẹ/con cái đơn thuần, ví dụ: giữa anh chị em ruột và có
lõi trình điều khiển tự động chăm sóc chúng.

Thứ hai, lõi trình điều khiển theo mặc định không thực thi bất kỳ sự hiện diện của trình điều khiển nào
phụ thuộc, tức là một thiết bị phải được liên kết với trình điều khiển trước
một cái khác có thể thăm dò hoặc hoạt động chính xác.

Thông thường hai loại phụ thuộc này kết hợp với nhau nên một thiết bị phụ thuộc vào
một cái khác liên quan đến sự hiện diện của người lái xe ZZ0000ZZ liên quan đến
đặt hàng tạm dừng/tiếp tục và tắt máy.

Liên kết thiết bị cho phép thể hiện các phần phụ thuộc như vậy trong lõi trình điều khiển.

Ở dạng tiêu chuẩn hoặc ZZ0000ZZ, liên kết thiết bị kết hợp sự phụ thuộc ZZ0001ZZ
các loại: Nó đảm bảo thứ tự tạm dừng/tiếp tục và tắt máy chính xác giữa một
thiết bị "nhà cung cấp" và thiết bị "người tiêu dùng" của nó, đồng thời nó đảm bảo cho người lái xe
sự hiện diện của nhà cung cấp.  Các thiết bị tiêu dùng không được thăm dò trước khi
nhà cung cấp bị ràng buộc với một trình điều khiển và họ không bị ràng buộc trước nhà cung cấp
không bị ràng buộc.

Khi sự hiện diện của tài xế tại nhà cung cấp là không liên quan và chỉ đúng
cần tạm dừng/tiếp tục và tắt máy, liên kết thiết bị có thể
chỉ cần thiết lập với cờ ZZ0000ZZ.  Nói cách khác,
việc thực thi sự hiện diện của người lái xe đối với nhà cung cấp là tùy chọn.

Một tính năng tùy chọn khác là tích hợp PM thời gian chạy: Bằng cách thiết lập
Cờ ZZ0000ZZ khi bổ sung liên kết thiết bị, lõi PM
được hướng dẫn để tiếp tục thời gian chạy của nhà cung cấp và giữ cho nó hoạt động
bất cứ khi nào và miễn là thời gian chạy của người tiêu dùng được tiếp tục.

Cách sử dụng
============

Thời điểm sớm nhất mà các liên kết thiết bị có thể được thêm vào là sau
ZZ0000ZZ đã được kêu gọi cho nhà cung cấp và
ZZ0001ZZ đã được kêu gọi dành cho người tiêu dùng.

Việc thêm chúng sau này là hợp pháp, nhưng phải cẩn thận để hệ thống
vẫn ở trạng thái nhất quán: Ví dụ: không thể thêm liên kết thiết bị vào
giữa quá trình chuyển đổi tạm dừng/tiếp tục, do đó, việc bắt đầu
quá trình chuyển đổi như vậy cần phải được ngăn chặn bằng ZZ0000ZZ,
hoặc liên kết thiết bị cần được thêm từ một chức năng được đảm bảo
không chạy song song với quá trình chuyển đổi tạm dừng/tiếp tục, chẳng hạn như từ một
gọi lại thiết bị ZZ0001ZZ hoặc lỗi PCI khi khởi động.

Một ví dụ khác về trạng thái không nhất quán là liên kết thiết bị
đại diện cho sự phụ thuộc hiện diện của người lái xe, nhưng được thêm vào từ người tiêu dùng
ZZ0000ZZ gọi lại trong khi nhà cung cấp chưa bắt đầu thăm dò: Đã có
lõi trình điều khiển đã biết về liên kết thiết bị trước đó, nó sẽ không thăm dò được
người tiêu dùng ngay từ đầu.  Do đó, trách nhiệm của người tiêu dùng là kiểm tra
sự hiện diện của nhà cung cấp sau khi thêm liên kết và trì hoãn việc thăm dò
sự không hiện diện.  [Lưu ý rằng việc tạo liên kết từ trang web của người tiêu dùng là hợp lệ
ZZ0001ZZ gọi lại trong khi nhà cung cấp vẫn đang thăm dò, nhưng người tiêu dùng phải
biết rằng nhà cung cấp đã hoạt động vào thời điểm tạo liên kết (nghĩa là
trong trường hợp, ví dụ: nếu người tiêu dùng vừa mua được một số tài nguyên
sẽ không có sẵn nếu lúc đó nhà cung cấp không hoạt động).]

Nếu liên kết thiết bị với ZZ0000ZZ được đặt (tức là liên kết thiết bị không trạng thái)
được thêm vào trong lệnh gọi lại ZZ0001ZZ của nhà cung cấp hoặc trình điều khiển người tiêu dùng, đó là
thường bị xóa trong lệnh gọi lại ZZ0002ZZ để đảm bảo tính đối xứng.  Bằng cách đó, nếu
trình điều khiển được biên dịch thành một mô-đun, liên kết thiết bị sẽ được thêm vào khi tải mô-đun và
có trật tự bị xóa khi dỡ hàng.  Các hạn chế tương tự áp dụng cho liên kết thiết bị
bổ sung (ví dụ: loại trừ quá trình chuyển đổi tạm dừng/tiếp tục song song) được áp dụng như nhau
để xóa.  Liên kết thiết bị do lõi trình điều khiển quản lý sẽ tự động bị xóa
bởi nó.

Một số cờ có thể được chỉ định khi bổ sung liên kết thiết bị, hai trong số đó
đã được đề cập ở trên: ZZ0000ZZ để bày tỏ rằng không
cần có sự phụ thuộc vào sự hiện diện của trình điều khiển (nhưng chỉ cần tạm dừng/tiếp tục chính xác và
thứ tự tắt máy) và ZZ0001ZZ để thể hiện PM thời gian chạy đó
mong muốn được tích hợp.

Hai cờ khác được nhắm mục tiêu cụ thể vào các trường hợp sử dụng trong đó thiết bị
liên kết được thêm từ lệnh gọi lại ZZ0000ZZ của người tiêu dùng: ZZ0001ZZ
có thể được chỉ định để tiếp tục thời gian chạy của nhà cung cấp và ngăn không cho nhà cung cấp tạm dừng
trước khi người tiêu dùng bị đình chỉ thời gian chạy.  ZZ0002ZZ
khiến liên kết thiết bị tự động bị xóa khi người tiêu dùng không thực hiện được
thăm dò hoặc sau đó hủy liên kết.

Tương tự, khi liên kết thiết bị được thêm từ lệnh gọi lại ZZ0000ZZ của nhà cung cấp,
ZZ0001ZZ khiến liên kết thiết bị được tự động
bị thanh lọc khi nhà cung cấp không thăm dò hoặc sau đó hủy bỏ ràng buộc.

Nếu không phải ZZ0000ZZ hay ZZ0001ZZ
được thiết lập, ZZ0002ZZ có thể được sử dụng để yêu cầu lõi trình điều khiển
để tự động thăm dò trình điều khiển cho trình điều khiển dành cho người tiêu dùng trên liên kết sau
một trình điều khiển đã được liên kết với thiết bị của nhà cung cấp.

Tuy nhiên, lưu ý rằng bất kỳ sự kết hợp nào của ZZ0000ZZ,
ZZ0001ZZ hoặc ZZ0002ZZ có
ZZ0003ZZ không hợp lệ và không thể sử dụng được.

Hạn chế
===========

Tác giả trình điều khiển nên biết rằng sự phụ thuộc hiện diện của trình điều khiển cho được quản lý
liên kết thiết bị (tức là khi ZZ0000ZZ không được chỉ định khi bổ sung liên kết)
có thể khiến việc thăm dò người tiêu dùng bị trì hoãn vô thời hạn.  Điều này có thể trở thành
một vấn đề nếu người tiêu dùng được yêu cầu thăm dò trước một mức initcall nhất định
đã đạt được.  Tệ hơn nữa, nếu trình điều khiển của nhà cung cấp bị liệt vào danh sách đen hoặc bị thiếu,
người tiêu dùng sẽ không bao giờ bị thăm dò.

Hơn nữa, không thể xóa trực tiếp các liên kết thiết bị được quản lý.  Chúng bị xóa
bởi lõi trình điều khiển khi chúng không còn cần thiết nữa theo quy định
Cờ ZZ0003ZZ và ZZ0004ZZ.
Tuy nhiên, các liên kết thiết bị không trạng thái (tức là các liên kết thiết bị với ZZ0005ZZ
set) dự kiến sẽ bị xóa bởi bất kỳ ai có tên ZZ0000ZZ
để thêm chúng với sự trợ giúp của ZZ0001ZZ hoặc
ZZ0002ZZ.

Chuyển ZZ0008ZZ cùng với ZZ0009ZZ tới
ZZ0000ZZ có thể gây ra bộ đếm mức sử dụng thời gian chạy PM của
thiết bị của nhà cung cấp vẫn khác 0 sau lần gọi tiếp theo của một trong hai
ZZ0001ZZ hoặc ZZ0002ZZ để loại bỏ
liên kết thiết bị được nó trả về.  Điều này xảy ra nếu ZZ0003ZZ
được gọi hai lần liên tiếp cho cùng một cặp người tiêu dùng-nhà cung cấp mà không loại bỏ
liên kết giữa các cuộc gọi này, trong trường hợp đó cho phép bộ đếm mức sử dụng thời gian chạy PM
của nhà cung cấp khi cố gắng loại bỏ liên kết có thể khiến nó bị hỏng
bị đình chỉ trong khi người tiêu dùng vẫn đang hoạt động trong thời gian chạy PM và điều đó phải được thực hiện
tránh được.  [Để khắc phục hạn chế này, chỉ cần cho phép người tiêu dùng
tạm dừng thời gian chạy ít nhất một lần hoặc gọi ZZ0004ZZ để biết
nó bị vô hiệu hóa thời gian chạy PM, giữa ZZ0005ZZ và
Cuộc gọi ZZ0006ZZ hoặc ZZ0007ZZ.]

Đôi khi trình điều khiển phụ thuộc vào tài nguyên tùy chọn.  Họ có thể hoạt động
ở chế độ xuống cấp (bộ tính năng hoặc hiệu suất bị giảm) khi các tài nguyên đó
không có mặt.  Một ví dụ là bộ điều khiển SPI có thể sử dụng động cơ DMA
hoặc làm việc ở chế độ PIO.  Bộ điều khiển có thể xác định sự hiện diện của tùy chọn
tài nguyên tại thời điểm thăm dò nhưng không có mặt thì không có cách nào để biết liệu
chúng sẽ có sẵn trong tương lai gần (do trình điều khiển nhà cung cấp
thăm dò) hoặc không bao giờ.  Do đó không thể xác định liệu có nên trì hoãn
thăm dò hay không.  Có thể thông báo cho người lái xe khi tùy chọn
tài nguyên sẽ có sẵn sau khi thăm dò, nhưng nó sẽ có chi phí cao
cho các trình điều khiển khi chuyển đổi giữa các chế độ hoạt động trong thời gian chạy dựa trên
sự sẵn có của các nguồn lực như vậy sẽ phức tạp hơn nhiều so với cơ chế
dựa trên việc trì hoãn thăm dò.  Trong mọi trường hợp, các tài nguyên tùy chọn đều vượt quá khả năng
phạm vi liên kết thiết bị.

Ví dụ
========

* Một thiết bị MMU tồn tại cùng với thiết bị busmaster, cả hai đều giống nhau
  miền quyền lực.  MMU thực hiện dịch địa chỉ DMA cho busmaster
  thiết bị và sẽ được tiếp tục thời gian chạy và duy trì hoạt động bất cứ khi nào và trong thời gian dài
  khi thiết bị busmaster đang hoạt động.  Trình điều khiển của thiết bị busmaster sẽ
  không liên kết trước khi MMU bị ràng buộc.  Để đạt được điều này, một liên kết thiết bị với
  Tích hợp PM thời gian chạy được thêm từ thiết bị busmaster (người tiêu dùng)
  đến thiết bị MMU (nhà cung cấp).  Hiệu ứng liên quan đến thời gian chạy PM
  giống như khi MMU là thiết bị gốc của thiết bị chính.

Thực tế là cả hai thiết bị đều có chung một miền năng lượng.
  đề xuất sử dụng cấu trúc dev_pm_domain hoặc struct generic_pm_domain,
  tuy nhiên đây không phải là những thiết bị độc lập dùng chung nguồn điện
  chuyển đổi, mà đúng hơn là thiết bị MMU phục vụ thiết bị busmaster và
  vô ích nếu không có nó.  Liên kết thiết bị tạo ra một hệ thống phân cấp tổng hợp
  mối quan hệ giữa các thiết bị và do đó thích hợp hơn.

* Bộ điều khiển máy chủ Thunderbolt bao gồm một số cổng cắm nóng PCIe
  và một thiết bị NHI để quản lý bộ chuyển mạch PCIe.  Khi tiếp tục từ chế độ ngủ của hệ thống,
  thiết bị NHI cần thiết lập lại đường hầm PCI cho các thiết bị được đính kèm
  trước khi các cổng cắm nóng có thể hoạt động trở lại.  Nếu các cổng cắm nóng là cổng con
  của NHI, lệnh tiếp tục này sẽ tự động được thi hành bởi
  PM lõi, nhưng tiếc là họ lại là dì.  Giải pháp là thêm
  liên kết thiết bị từ cổng cắm nóng (người tiêu dùng) đến thiết bị NHI
  (nhà cung cấp).  Sự phụ thuộc hiện diện của trình điều khiển là không cần thiết cho việc này
  trường hợp sử dụng.

* GPU rời trong laptop đồ họa lai thường có bộ điều khiển HDA
  cho âm thanh HDMI/DP.  Trong hệ thống phân cấp thiết bị, bộ điều khiển HDA là anh chị em
  của thiết bị VGA, nhưng cả hai đều có chung miền nguồn và HDA
  bộ điều khiển chỉ cần thiết khi màn hình HDMI/DP được gắn vào
  Thiết bị VGA.  Liên kết thiết bị từ bộ điều khiển HDA (người tiêu dùng) đến
  Thiết bị VGA (nhà cung cấp) thể hiện chính xác mối quan hệ này.

* ACPI cho phép xác định thứ tự khởi động thiết bị bằng các đối tượng _DEP.
  Một ví dụ cổ điển là khi các phương thức quản lý nguồn ACPI trên một thiết bị
  được triển khai dưới dạng truy cập I\ ZZ0000ZZ\ C và yêu cầu một quyền truy cập cụ thể
  Bộ điều khiển I\ ZZ0001ZZ\ C hiện diện và hoạt động để cấp nguồn
  quản lý thiết bị được đề cập để hoạt động.

* Trong một số SoC, sự phụ thuộc chức năng tồn tại từ màn hình, codec video và
  lõi IP xử lý video trên lõi IP truy cập bộ nhớ trong suốt xử lý
  truy cập hàng loạt và nén/giải nén.

Lựa chọn thay thế
=================

* Cấu trúc dev_pm_domain có thể được sử dụng để ghi đè bus,
  cuộc gọi lại loại hoặc loại thiết bị.  Nó được thiết kế để chia sẻ thiết bị
  một công tắc bật/tắt duy nhất, tuy nhiên nó không đảm bảo một công tắc cụ thể
  tạm dừng/tiếp tục đặt hàng, việc này cần được thực hiện riêng.
  Bản thân nó cũng không theo dõi trạng thái PM thời gian chạy của các bên liên quan.
  thiết bị và chỉ tắt công tắc nguồn khi tất cả chúng đều đang chạy
  bị đình chỉ.  Hơn nữa, nó không thể được sử dụng để thực thi việc tắt máy cụ thể
  đặt hàng hoặc phụ thuộc vào sự hiện diện của tài xế.

* Cấu trúc generic_pm_domain nặng hơn nhiều so với cấu trúc
  liên kết thiết bị và không cho phép ra lệnh tắt máy hoặc hiện diện trình điều khiển
  sự phụ thuộc.  Nó cũng không thể được sử dụng trên các hệ thống ACPI.

Thực hiện
==============

Hệ thống phân cấp thiết bị -- như tên gọi của nó -- là một cái cây,
trở thành biểu đồ chu kỳ có hướng sau khi liên kết thiết bị được thêm vào.

Thứ tự của các thiết bị này trong quá trình tạm dừng/tiếp tục được xác định bởi
dpm_list.  Trong quá trình tắt máy, nó được xác định bởi devices_kset.  Với
không có liên kết thiết bị nào, hai danh sách này là một danh sách phẳng, một chiều
biểu diễn của cây thiết bị sao cho thiết bị được đặt phía sau
tất cả tổ tiên của nó.  Điều đó đạt được bằng cách duyệt qua không gian tên ACPI
hoặc cây thiết bị OpenFirmware từ trên xuống và nối các thiết bị vào danh sách
khi chúng được phát hiện.

Khi liên kết thiết bị được thêm vào, danh sách cần phải đáp ứng các yêu cầu bổ sung
ràng buộc rằng một thiết bị được đặt phía sau tất cả các nhà cung cấp của nó, theo cách đệ quy.
Để đảm bảo điều này, khi bổ sung thiết bị sẽ liên kết người tiêu dùng và
toàn bộ biểu đồ con bên dưới nó (tất cả trẻ em và người tiêu dùng của người tiêu dùng)
được chuyển đến cuối danh sách.  (Gọi tới ZZ0000ZZ
từ ZZ0001ZZ.)

Để ngăn chặn việc đưa các vòng lặp phụ thuộc vào biểu đồ, cần
được xác minh khi bổ sung liên kết thiết bị rằng nhà cung cấp không phụ thuộc
lên người tiêu dùng hoặc bất kỳ trẻ em hoặc người tiêu dùng nào của người tiêu dùng.
(Gọi tới ZZ0000ZZ từ ZZ0001ZZ.)
Nếu ràng buộc đó bị vi phạm, ZZ0002ZZ sẽ trả về
ZZ0003ZZ và ZZ0004ZZ sẽ được ghi lại.

Đáng chú ý điều này cũng ngăn cản việc bổ sung liên kết thiết bị từ phụ huynh
thiết bị cho một đứa trẻ.  Tuy nhiên, điều ngược lại được cho phép, tức là liên kết thiết bị
từ đứa trẻ đến cha mẹ.  Vì lõi trình điều khiển đã đảm bảo
đúng thứ tự tạm dừng/tiếp tục và tắt máy giữa cha mẹ và con cái,
liên kết thiết bị như vậy chỉ có ý nghĩa nếu sự phụ thuộc hiện diện của trình điều khiển là
cần thiết trên hết.  Trong trường hợp này tác giả trình điều khiển nên cân nhắc
cẩn thận xem liên kết thiết bị có phải là công cụ phù hợp cho mục đích này hay không.
Một cách tiếp cận phù hợp hơn có thể chỉ đơn giản là sử dụng việc thăm dò trì hoãn hoặc
thêm cờ thiết bị khiến trình điều khiển chính bị thăm dò trước
đứa trẻ một.

Máy trạng thái
==============

.. kernel-doc:: include/linux/device.h
   :functions: device_link_state

::

================================.
                 ZZ0000ZZ
                 v |
 DORMANT <=> AVAILABLE <=> CONSUMER_PROBE => ACTIVE
    ^ |
    ZZ0001ZZ
    '============= SUPPLIER_UNBIND <============='

* Trạng thái ban đầu của liên kết thiết bị được xác định tự động bởi
  ZZ0000ZZ dựa trên sự hiện diện của trình điều khiển trên nhà cung cấp
  và người tiêu dùng.  Nếu liên kết được tạo trước khi bất kỳ thiết bị nào được thăm dò, nó
  được đặt thành ZZ0001ZZ.

* Khi thiết bị của nhà cung cấp được liên kết với trình điều khiển, hãy liên kết với người tiêu dùng của nó
  tiến tới ZZ0002ZZ.
  (Gọi tới ZZ0000ZZ từ
  ZZ0001ZZ.)

* Trước khi thiết bị tiêu dùng được thăm dò, sự hiện diện của trình điều khiển của nhà cung cấp là
  được xác minh bằng cách kiểm tra xem thiết bị tiêu dùng không có trong wait_for_suppliers
  danh sách và bằng cách kiểm tra xem các liên kết đến nhà cung cấp có trong ZZ0004ZZ không
  trạng thái.  Trạng thái của các liên kết được cập nhật thành ZZ0005ZZ.
  (Gọi tới ZZ0000ZZ từ
  ZZ0001ZZ.)
  Điều này ngăn cản nhà cung cấp hủy bỏ ràng buộc.
  (Gọi tới ZZ0002ZZ từ
  ZZ0003ZZ.)

* Nếu thăm dò không thành công, các liên kết đến nhà cung cấp sẽ quay trở lại ZZ0002ZZ.
  (Gọi tới ZZ0000ZZ từ ZZ0001ZZ.)

* Nếu cuộc thăm dò thành công, các liên kết tới nhà cung cấp sẽ tiến tới ZZ0002ZZ.
  (Gọi tới ZZ0000ZZ từ ZZ0001ZZ.)

* Sau đó, khi trình điều khiển của người tiêu dùng bị xóa, các liên kết đến nhà cung cấp sẽ hoàn nguyên
  quay lại ZZ0003ZZ.
  (Gọi tới ZZ0000ZZ từ
  ZZ0001ZZ, lần lượt được gọi từ
  ZZ0002ZZ.)

* Trước khi trình điều khiển của nhà cung cấp bị loại bỏ, hãy liên kết đến người tiêu dùng không
  liên kết với trình điều khiển được cập nhật lên ZZ0008ZZ.
  (Gọi tới ZZ0000ZZ từ
  ZZ0001ZZ.)
  Điều này ngăn cản sự ràng buộc của người tiêu dùng.
  (Gọi tới ZZ0002ZZ từ
  ZZ0003ZZ.)
  Người tiêu dùng bị ràng buộc sẽ được giải phóng khỏi trình điều khiển của họ; người tiêu dùng đang
  việc thăm dò được chờ đợi cho đến khi chúng được thực hiện.
  (Gọi tới ZZ0004ZZ từ
  ZZ0005ZZ.)
  Khi tất cả các liên kết đến người tiêu dùng ở trạng thái ZZ0009ZZ,
  trình điều khiển của nhà cung cấp được giải phóng và các liên kết trở lại ZZ0010ZZ.
  (Gọi tới ZZ0006ZZ từ
  ZZ0007ZZ.)

API
===

Xem device_link_add(), device_link_del() và device_link_remove().
