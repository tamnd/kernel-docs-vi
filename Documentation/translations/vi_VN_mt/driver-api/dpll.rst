.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/driver-api/dpll.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

==================================
Hệ thống con dpll nhân Linux
==================================

DPLL
====

PLL - Phase Locked Loop là mạch điện tử tổng hợp đồng hồ
tín hiệu của thiết bị với tín hiệu đồng hồ bên ngoài. Kích hoạt hiệu quả
thiết bị chạy trên cùng nhịp tín hiệu đồng hồ như được cung cấp trên đầu vào PLL.

DPLL - Vòng khóa pha kỹ thuật số là một mạch tích hợp trong đó
Ngoài hành vi PLL đơn giản còn kết hợp với bộ dò pha kỹ thuật số
và có thể có bộ chia kỹ thuật số trong vòng lặp. Kết quả là tần số trên
Đầu vào và đầu ra của DPLL có thể được cấu hình.

Hệ thống con
=========

Mục đích chính của hệ thống con dpll là cung cấp giao diện chung
để định cấu hình các thiết bị sử dụng bất kỳ loại PLL kỹ thuật số nào và có thể sử dụng
các nguồn tín hiệu đầu vào khác nhau để đồng bộ hóa, cũng như
các loại đầu ra khác nhau.
Giao diện chính là giao thức dựa trên NETLINK_GENERIC với một sự kiện
nhóm multicast giám sát được xác định.

Đối tượng thiết bị
=============

Đối tượng thiết bị dpll đơn có nghĩa là mạch PLL kỹ thuật số đơn và một loạt
các chân được kết nối.
Nó báo cáo các chế độ hoạt động được hỗ trợ và trạng thái hiện tại cho
người dùng đáp lại yêu cầu ZZ0005ZZ của lệnh netlink
ZZ0000ZZ và danh sách dplls được đăng ký trong hệ thống con
với yêu cầu liên kết mạng ZZ0006ZZ của cùng một lệnh.
Việc thay đổi cấu hình của thiết bị dpll được thực hiện với yêu cầu ZZ0007ZZ của
lệnh netlink ZZ0001ZZ.
Tay cầm thiết bị là ZZ0002ZZ, nó sẽ được cung cấp để lấy hoặc đặt
cấu hình của thiết bị cụ thể trong hệ thống. Nó có thể được lấy
với yêu cầu ZZ0003ZZ ZZ0008ZZ hoặc
yêu cầu ZZ0004ZZ ZZ0009ZZ, trong đó yêu cầu phải cung cấp
các thuộc tính dẫn đến kết quả khớp với một thiết bị.

Ghim đối tượng
==========

Chân là một đối tượng vô định hình đại diện cho đầu vào hoặc đầu ra, nó
có thể là thành phần bên trong của thiết bị, cũng như bên ngoài
được kết nối.
Số lượng chân trên mỗi dpll khác nhau, nhưng thông thường sẽ có nhiều chân
được cung cấp cho một thiết bị dpll duy nhất.
Các thuộc tính, khả năng và trạng thái của Ghim được cung cấp cho người dùng theo
đáp ứng yêu cầu ZZ0006ZZ của lệnh netlink ZZ0000ZZ.
Cũng có thể liệt kê tất cả các chân đã được đăng ký trong
hệ thống có ZZ0007ZZ yêu cầu lệnh ZZ0001ZZ.
Cấu hình của một pin có thể được thay đổi theo yêu cầu ZZ0008ZZ của netlink
Lệnh ZZ0002ZZ.
Tay cầm chốt là ZZ0003ZZ, nó sẽ được cung cấp để lấy hoặc đặt
cấu hình của pin cụ thể trong hệ thống. Nó có thể thu được với
ZZ0004ZZ ZZ0009ZZ yêu cầu hoặc ZZ0005ZZ ZZ0010ZZ
yêu cầu, trong đó người dùng cung cấp các thuộc tính dẫn đến kết quả khớp một mã pin.

Lựa chọn ghim
=============

Nói chung, chân được chọn (chân có tín hiệu điều khiển dpll
thiết bị) có thể được lấy từ thuộc tính ZZ0000ZZ và chỉ
một pin sẽ ở trạng thái ZZ0001ZZ cho bất kỳ dpll nào
thiết bị.

Việc lựa chọn chốt có thể được thực hiện thủ công hoặc tự động, tùy thuộc vào
về khả năng phần cứng và chế độ làm việc của thiết bị dpll đang hoạt động
(Thuộc tính ZZ0000ZZ). Hậu quả là có
sự khác biệt cho từng chế độ về trạng thái chân sẵn có, cũng như
đối với các trạng thái mà người dùng có thể yêu cầu đối với thiết bị dpll.

Ở chế độ thủ công (ZZ0000ZZ), người dùng có thể yêu cầu hoặc nhận
một trong các trạng thái pin sau:

- ZZ0000ZZ - chân dùng để điều khiển thiết bị dpll
- ZZ0001ZZ - chân không dùng để điều khiển dpll
  thiết bị

Ở chế độ tự động (ZZ0000ZZ), người dùng có thể yêu cầu hoặc
nhận được một trong các trạng thái pin sau:

- ZZ0000ZZ - mã pin được coi là hợp lệ
  đầu vào cho thuật toán lựa chọn tự động
- ZZ0001ZZ - chốt sẽ không được coi là
  đầu vào hợp lệ cho thuật toán lựa chọn tự động

Ở chế độ tự động (ZZ0000ZZ), người dùng chỉ có thể nhận
trạng thái pin ZZ0001ZZ một lần lựa chọn tự động
thuật toán khóa thiết bị dpll bằng một trong các đầu vào.

Ghim được chia sẻ
===========

Một đối tượng ghim có thể được gắn vào nhiều thiết bị dpll.
Sau đó có hai nhóm nút cấu hình:

1) Đặt trên một mã pin - cấu hình ảnh hưởng đến tất cả các mã pin của thiết bị dpll
   đã đăng ký (tức là ZZ0000ZZ),
2) Đặt trên bộ pin-dpll - cấu hình chỉ ảnh hưởng đến việc chọn
   thiết bị dpll (ví dụ: ZZ0001ZZ, ZZ0002ZZ,
   ZZ0003ZZ).

Chân loại MUX
=============

Một chân có thể là loại MUX, nó tập hợp các chân con và đóng vai trò như một chân
bộ ghép kênh. Một hoặc nhiều chân được đăng ký với loại MUX thay vì
được đăng ký trực tiếp vào thiết bị dpll.
Các chân được đăng ký với chân loại MUX cung cấp cho người dùng các chân bổ sung được lồng vào nhau.
thuộc tính ZZ0000ZZ cho mỗi phụ huynh mà họ đã đăng ký
với.
Nếu một mã pin được đăng ký với nhiều mã pin gốc, chúng sẽ hoạt động giống như một
bộ ghép kênh nhiều đầu ra. Trong trường hợp này đầu ra của một
ZZ0001ZZ sẽ chứa nhiều pin-parent lồng nhau
các thuộc tính có trạng thái hiện tại liên quan đến từng phụ huynh, như ::

'pin': [{{
          'đồng hồ-id': 282574471561216,
          'tên mô-đun': 'băng',
          'khả năng': 4,
          'id': 13,
          'pin gốc': [
          {'parent-id': 2, 'state': 'connected'},
          {'parent-id': 3, 'state': 'đã ngắt kết nối'}
          ],
          'loại': 'synce-eth-port'
          }}]

Chỉ một chân con có thể cung cấp tín hiệu của nó cho chân loại MUX gốc tại
tại một thời điểm, việc lựa chọn được thực hiện bằng cách yêu cầu thay đổi trạng thái mã pin con
trên cha mẹ mong muốn, với việc sử dụng ZZ0000ZZ lồng nhau
thuộc tính. Ví dụ về định dạng tin nhắn netlink ZZ0001ZZ:

=============================================================================
  Id pin con ZZ0000ZZ
  Thuộc tính lồng nhau ZZ0001ZZ để yêu cầu cấu hình
                             liên quan đến pin gốc
    Id pin gốc ZZ0002ZZ
    ZZ0003ZZ đã yêu cầu trạng thái pin trên cha mẹ
  =============================================================================

Ưu tiên ghim
============

Một số thiết bị có thể cung cấp khả năng chọn chế độ ghim tự động
(giá trị enum ZZ0000ZZ của thuộc tính ZZ0001ZZ).
Thông thường, việc lựa chọn tự động được thực hiện ở cấp độ phần cứng,
có nghĩa là chỉ các chân được kết nối trực tiếp với dpll mới có thể được sử dụng để tự động
lựa chọn chân đầu vào.
Ở chế độ chọn tự động, người dùng không thể chọn đầu vào theo cách thủ công
ghim cho thiết bị, thay vào đó người dùng sẽ cung cấp tất cả trực tiếp
các chân được kết nối với mức ưu tiên ZZ0002ZZ, thiết bị sẽ
chọn tín hiệu hợp lệ có mức ưu tiên cao nhất và sử dụng nó để điều khiển DPLL
thiết bị. Ví dụ về định dạng tin nhắn netlink ZZ0003ZZ:

===============================================================================
  Id pin được cấu hình ZZ0000ZZ
  Thuộc tính lồng nhau ZZ0001ZZ để yêu cầu cấu hình
                               liên quan đến thiết bị dpll gốc
    Id thiết bị dpll gốc ZZ0002ZZ
    ZZ0003ZZ đã yêu cầu pin ưu tiên trên dpll gốc
  ===============================================================================

Chân con của chân loại MUX không có khả năng tự động chọn chân đầu vào,
để định cấu hình đầu vào hoạt động của chân loại MUX, người dùng cần phải
yêu cầu trạng thái chân mong muốn của chân con trên chân mẹ,
như được mô tả trong chương ZZ0000ZZ.

Đo và điều chỉnh độ lệch pha
========================================

Thiết bị có thể cung cấp khả năng đo độ lệch pha giữa các tín hiệu
trên một mã pin và thiết bị dpll gốc của nó. Nếu đo độ lệch pha pin-dpll
được hỗ trợ, nó sẽ được cung cấp ZZ0000ZZ
thuộc tính cho mỗi thiết bị dpll gốc. Độ lệch pha được báo cáo có thể là
được tính bằng giá trị trung bình của các giá trị trước đó và phép đo hiện tại, sử dụng
công thức sau:

.. math::
   curr\_avg = prev\_avg * \frac{2^N-1}{2^N} + new\_val * \frac{1}{2^N}

trong đó ZZ0002ZZ là độ lệch pha được báo cáo hiện tại, ZZ0003ZZ là
giá trị được báo cáo trước đó, ZZ0004ZZ là số đo hiện tại và ZZ0005ZZ là
hệ số trung bình. Giá trị hệ số trung bình được cấu hình được cung cấp với
Thuộc tính ZZ0000ZZ của thiết bị và thay đổi giá trị có thể
được yêu cầu với cùng thuộc tính bằng lệnh ZZ0001ZZ.

=============================================================================
  Giá trị cấu hình ZZ0000ZZ attr của độ lệch pha
                                     hệ số trung bình
  =============================================================================

Thiết bị cũng có thể cung cấp khả năng điều chỉnh pha tín hiệu trên chân.
Nếu điều chỉnh pha pin được hỗ trợ, các giá trị tối thiểu và tối đa và
mức độ chi tiết mà chốt ghim sẽ được cung cấp cho người dùng trên
ZZ0000ZZ phản hồi bằng ZZ0001ZZ,
ZZ0002ZZ và ZZ0003ZZ
thuộc tính. Giá trị điều chỉnh pha được cấu hình được cung cấp cùng với
Thuộc tính ZZ0004ZZ của một mã pin và việc thay đổi giá trị có thể được thực hiện
được yêu cầu với cùng thuộc tính bằng lệnh ZZ0005ZZ.

================================================================================
  Id pin được cấu hình ZZ0000ZZ
  ZZ0001ZZ attr độ chi tiết của giá trị điều chỉnh pha
  ZZ0002ZZ attr giá trị điều chỉnh pha tối thiểu
  ZZ0003ZZ attr giá trị điều chỉnh pha tối đa
  Giá trị cấu hình của pha ZZ0004ZZ attr
                                   điều chỉnh trên thiết bị dpll gốc
  Thuộc tính lồng nhau ZZ0005ZZ để yêu cầu
                                   cấu hình trên dpll gốc đã cho
                                   thiết bị
    Id thiết bị dpll gốc ZZ0006ZZ
    ZZ0007ZZ attr đo độ lệch pha
                                   giữa pin và thiết bị dpll gốc
  ================================================================================

Tất cả các giá trị liên quan đến pha được cung cấp tính bằng pico giây, đại diện cho
chênh lệch thời gian giữa các pha tín hiệu. Giá trị âm có nghĩa là
pha của tín hiệu trên chân sớm hơn tín hiệu của dpll. tích cực
giá trị có nghĩa là pha của tín hiệu trên chân muộn hơn so với tín hiệu của
một dpll.

Các giá trị điều chỉnh pha (cả tối thiểu và tối đa) là số nguyên, nhưng pha được đo
giá trị offset là phân số với 3 chữ số thập phân và shell là
chia cho ZZ0000ZZ để lấy phần nguyên và
modulo chia để có được phần phân số.

Màn hình bù pha
====================

Phép đo độ lệch pha thường được thực hiện dựa trên dòng điện hoạt động
nguồn. Tuy nhiên, một số thiết bị DPLL (Vòng khóa pha kỹ thuật số) có thể cung cấp
khả năng giám sát độ lệch pha trên tất cả các đầu vào có sẵn.
Thuộc tính và trạng thái tính năng hiện tại sẽ được đưa vào phản hồi
thông báo của lệnh ZZ0000ZZ cho các thiết bị DPLL được hỗ trợ.
Trong những trường hợp như vậy, người dùng cũng có thể điều khiển tính năng này bằng cách sử dụng
Lệnh ZZ0001ZZ bằng cách đặt ZZ0002ZZ
các giá trị cho thuộc tính.
Sau khi được bật, các phép đo độ lệch pha cho đầu vào sẽ được trả về
trong thuộc tính ZZ0003ZZ.

===========================================================
  ZZ0000ZZ trạng thái attr của một tính năng
  ===========================================================

Máy đo tần số
=================

Một số thiết bị DPLL có thể cung cấp khả năng đo thực tế
tần số của tất cả các chân đầu vào có sẵn. Thuộc tính và trạng thái tính năng hiện tại
sẽ được bao gồm trong tin nhắn phản hồi của ZZ0000ZZ
lệnh cho các thiết bị DPLL được hỗ trợ. Trong những trường hợp như vậy, người dùng cũng có thể kiểm soát
tính năng này bằng lệnh ZZ0001ZZ bằng cách cài đặt
Giá trị ZZ0002ZZ cho thuộc tính.
Sau khi được bật, tần số đầu vào đo được cho mỗi chân đầu vào sẽ là
được trả về trong thuộc tính ZZ0003ZZ. giá trị
tính bằng millihertz (mHz), sử dụng ZZ0004ZZ
như bộ chia.

===========================================================
  ZZ0000ZZ trạng thái attr của một tính năng
  ===========================================================

SYNC nhúng
=============

Thiết bị có thể cung cấp khả năng sử dụng tính năng SYNC nhúng. Nó cho phép
để nhúng tín hiệu SYNC bổ sung vào tần số cơ bản của pin - một
xung đặc biệt của tín hiệu tần số cơ sở mỗi lần xung tín hiệu SYNC
xảy ra. Người dùng có thể định cấu hình tần số của SYNC nhúng.
Khả năng SYNC nhúng luôn liên quan đến tần số cơ bản nhất định
và khả năng CTNH. Người dùng được cung cấp một loạt SYNC nhúng
tần số được hỗ trợ, tùy thuộc vào tần số cơ sở hiện tại được định cấu hình cho
cái đinh ghim.

================================================================================
  ZZ0000ZZ hiện tại Tần số SYNC nhúng
  ZZ0001ZZ tổ có sẵn SYNC nhúng
                                            dải tần số
    ZZ0002ZZ attr giá trị tần số tối thiểu
    ZZ0003ZZ attr giá trị tối đa của tần số
  Loại xung ZZ0004ZZ của SYNC nhúng
  ================================================================================

Tham khảo SYNC
==============

Thiết bị có thể hỗ trợ tính năng Reference SYNC, cho phép kết hợp
của hai đầu vào thành một cặp đầu vào. Trong cấu hình này, tín hiệu đồng hồ
từ cả hai đầu vào được sử dụng để đồng bộ hóa thiết bị DPLL. Tần số cao hơn
tín hiệu được sử dụng cho băng thông vòng lặp của DPLL, trong khi tần số thấp hơn
tín hiệu được sử dụng để tổng hợp tín hiệu đầu ra của thiết bị DPLL. Tính năng này
cho phép cung cấp tín hiệu băng thông vòng lặp chất lượng cao từ bên ngoài
nguồn.

Đầu vào có khả năng cung cấp danh sách các đầu vào có thể được liên kết để tạo
Tham khảo SYNC. Để kiểm soát tính năng này, người dùng phải yêu cầu một
trạng thái cho pin mục tiêu: sử dụng ZZ0000ZZ để bật hoặc
ZZ0001ZZ để tắt tính năng này. Một chân đầu vào có thể
chỉ bị ràng buộc với một pin khác tại bất kỳ thời điểm nào.

=============================================================================
  Thuộc tính lồng nhau ZZ0000ZZ để cung cấp thông tin hoặc
                                 yêu cầu cấu hình của Tài liệu tham khảo
                                 Tính năng SYNC
    Id pin mục tiêu ZZ0001ZZ cho tính năng Tham khảo SYNC
    Trạng thái ZZ0002ZZ của kết nối Tham chiếu SYNC
  =============================================================================

Nhóm lệnh cấu hình
============================

Lệnh cấu hình được sử dụng để lấy thông tin về đăng ký
thiết bị dpll (và chân), cũng như đặt cấu hình của thiết bị hoặc chân.
Vì các thiết bị dpll phải được trừu tượng hóa và phản ánh phần cứng thực,
không có cách nào để thêm thiết bị dpll mới qua liên kết mạng từ không gian người dùng và
mỗi thiết bị phải được đăng ký bởi trình điều khiển của nó.

Tất cả các lệnh liên kết mạng đều yêu cầu ZZ0000ZZ. Điều này là để ngăn chặn
bất kỳ hoạt động gửi thư rác/DoS nào từ các ứng dụng không gian người dùng trái phép.

Danh sách các lệnh netlink với các thuộc tính có thể có
=================================================

Các hằng số xác định loại lệnh cho thiết bị dpll sử dụng một
Tiền tố và hậu tố ZZ0000ZZ theo mục đích lệnh.
Các thuộc tính liên quan đến thiết bị dpll sử dụng tiền tố ZZ0001ZZ và
hậu tố theo mục đích thuộc tính.

==========================================================================
  Lệnh ZZ0000ZZ để lấy ID thiết bị
    Tên mô-đun attr ZZ0001ZZ của người đăng ký
    ZZ0002ZZ attr Mã định danh đồng hồ độc đáo
                                       (EUI-64), như được định nghĩa bởi
                                       Tiêu chuẩn IEEE 1588
    ZZ0003ZZ attr loại thiết bị dpll
  ==========================================================================

==========================================================================
  Lệnh ZZ0000ZZ để lấy thông tin thiết bị hoặc
                                       danh sách kết xuất các thiết bị có sẵn
    ZZ0001ZZ attr ID thiết bị dpll duy nhất
    Tên mô-đun attr ZZ0002ZZ của người đăng ký
    ZZ0003ZZ attr Mã định danh đồng hồ độc đáo
                                       (EUI-64), như được định nghĩa bởi
                                       Tiêu chuẩn IEEE 1588
    Chế độ chọn attr ZZ0004ZZ
    ZZ0005ZZ attr có sẵn các chế độ lựa chọn
    ZZ0006ZZ attr trạng thái khóa thiết bị dpll
    Thông tin nhiệt độ thiết bị attr ZZ0007ZZ
    ZZ0008ZZ attr loại thiết bị dpll
  ==========================================================================

==========================================================================
  Lệnh ZZ0000ZZ để đặt cấu hình thiết bị dpll
    ZZ0001ZZ attr chỉ mục thiết bị dpll nội bộ
    Chế độ chọn attr ZZ0002ZZ để cấu hình
  ==========================================================================

Các hằng số xác định loại lệnh cho các chân sử dụng một
Tiền tố và hậu tố ZZ0000ZZ theo mục đích lệnh.
Các thuộc tính liên quan đến mã pin sử dụng tiền tố và hậu tố ZZ0001ZZ
theo mục đích thuộc tính.

==========================================================================
  Lệnh ZZ0000ZZ để lấy ID pin
    Tên mô-đun attr ZZ0001ZZ của người đăng ký
    ZZ0002ZZ attr Mã định danh đồng hồ độc đáo
                                       (EUI-64), như được định nghĩa bởi
                                       Tiêu chuẩn IEEE 1588
    Nhãn bảng pin attr ZZ0003ZZ được cung cấp
                                       bởi người đăng ký
    Nhãn bảng pin attr ZZ0004ZZ được cung cấp
                                       bởi người đăng ký
    Nhãn gói pin attr ZZ0005ZZ được cung cấp
                                       bởi người đăng ký
    ZZ0006ZZ attr loại pin
  ==========================================================================

============================================================================
  Lệnh ZZ0000ZZ để lấy thông tin pin hoặc kết xuất
                                       danh sách các chân có sẵn
    ZZ0001ZZ có ID mã pin duy nhất
    Tên mô-đun attr ZZ0002ZZ của người đăng ký
    ZZ0003ZZ attr Mã định danh đồng hồ độc đáo
                                       (EUI-64), như được định nghĩa bởi
                                       Tiêu chuẩn IEEE 1588
    Nhãn bảng pin attr ZZ0004ZZ được cung cấp
                                       bởi người đăng ký
    Nhãn bảng pin attr ZZ0005ZZ được cung cấp
                                       bởi người đăng ký
    Nhãn gói pin attr ZZ0006ZZ được cung cấp
                                       bởi người đăng ký
    ZZ0007ZZ attr loại pin
    ZZ0008ZZ attr tần số hiện tại của pin
    ZZ0009ZZ attr lồng nhau cung cấp hỗ trợ
                                       tần số
      ZZ0010ZZ attr giá trị tần số tối thiểu
      ZZ0011ZZ attr giá trị tần số tối đa
    Độ chi tiết của pha ZZ0012ZZ attr
                                       giá trị điều chỉnh
    ZZ0013ZZ attr giá trị tối thiểu của pha
                                       điều chỉnh
    ZZ0014ZZ attr giá trị tối đa của pha
                                       điều chỉnh
    Giá trị cấu hình của pha ZZ0015ZZ attr
                                       điều chỉnh trên thiết bị mẹ
    ZZ0016ZZ attr lồng nhau cho từng thiết bị gốc
                                       pin được kết nối với
      ZZ0017ZZ attr id thiết bị dpll gốc
      ZZ0018ZZ chú ý mức độ ưu tiên của pin trên
                                       thiết bị dpll
      ZZ0019ZZ attr trạng thái pin trên cha mẹ
                                       thiết bị dpll
      ZZ0020ZZ attr hướng của chốt trên
                                       thiết bị dpll gốc
      ZZ0021ZZ attr đo độ lệch pha
                                       giữa mã pin và dpll gốc
    ZZ0022ZZ attr lồng nhau cho mỗi mã pin gốc
                                       pin được kết nối với
      ZZ0023ZZ attr id pin gốc
      ZZ0024ZZ attr trạng thái pin trên cha mẹ
                                       ghim
    ZZ0025ZZ attr bitmask về khả năng của pin
    ZZ0026ZZ attr đo tần số của
                                       chân đầu vào tính bằng MHz
  ============================================================================

==========================================================================
  Lệnh ZZ0000ZZ để thiết lập cấu hình chân
    ZZ0001ZZ có ID mã pin duy nhất
    ZZ0002ZZ attr tần số yêu cầu của pin
    ZZ0003ZZ attr giá trị được yêu cầu của pha
                                       điều chỉnh trên thiết bị mẹ
    ZZ0004ZZ attr lồng nhau cho mỗi dpll gốc
                                       yêu cầu cấu hình thiết bị
      ZZ0005ZZ attr id thiết bị dpll gốc
      ZZ0006ZZ attr đã yêu cầu hướng ghim
      ZZ0007ZZ attr đã yêu cầu bật mức độ ưu tiên của mã pin
                                       thiết bị dpll
      ZZ0008ZZ attr đã yêu cầu trạng thái pin bật
                                       thiết bị dpll
    ZZ0009ZZ attr lồng nhau cho mỗi mã pin gốc
                                       yêu cầu cấu hình
      ZZ0010ZZ attr id pin gốc
      ZZ0011ZZ attr đã yêu cầu trạng thái pin bật
                                       ghim cha mẹ
  ==========================================================================

Yêu cầu kết xuất Netlink
=====================

Các lệnh ZZ0000ZZ và ZZ0001ZZ là
có khả năng kết xuất các yêu cầu liên kết mạng loại, trong trường hợp đó phản hồi ở dạng
định dạng tương tự như đối với yêu cầu ZZ0002ZZ của họ, nhưng mọi thiết bị hoặc mã pin
đã đăng ký trong hệ thống sẽ được trả về.

Định dạng lệnh SET
===================

ZZ0000ZZ - để nhắm mục tiêu thiết bị dpll, người dùng cung cấp
ZZ0001ZZ, mã định danh duy nhất của thiết bị dpll trong hệ thống,
cũng như tham số đang được cấu hình (ZZ0002ZZ).

ZZ0000ZZ - để nhắm mục tiêu mã pin, người dùng phải cung cấp
ZZ0001ZZ, mã định danh duy nhất của một mã pin trong hệ thống.
Ngoài ra các tham số pin được cấu hình phải được thêm vào.
Nếu ZZ0002ZZ được định cấu hình, điều này sẽ ảnh hưởng đến tất cả dpll
các thiết bị được kết nối với pin, đó là lý do tại sao thuộc tính tần số
sẽ không được đặt trong ZZ0003ZZ.
Các thuộc tính khác: ZZ0004ZZ, ZZ0005ZZ hoặc
ZZ0006ZZ phải được đặt trong
ZZ0007ZZ vì cấu hình của chúng chỉ liên quan đến một
của các dpll gốc, được nhắm mục tiêu bởi thuộc tính ZZ0008ZZ
cũng được yêu cầu bên trong tổ đó.
Đối với các chân loại MUX, thuộc tính ZZ0009ZZ được cấu hình trong
theo cách tương tự, bằng cách đặt trạng thái bắt buộc trong ZZ0010ZZ
thuộc tính lồng nhau và id pin gốc được nhắm mục tiêu trong ZZ0011ZZ.

Nói chung, có thể cấu hình nhiều tham số cùng một lúc, nhưng
bên trong mỗi thay đổi tham số sẽ được gọi riêng biệt, trong đó thứ tự
cấu hình không được đảm bảo dưới bất kỳ hình thức nào.

Cấu hình enum được xác định trước
===============================

.. kernel-doc:: include/uapi/linux/dpll.h

Thông báo
=============

thiết bị dpll có thể cung cấp thông báo về các thay đổi trạng thái của
thiết bị, tức là thay đổi trạng thái khóa, thay đổi đầu vào/đầu ra hoặc các cảnh báo khác.
Có một nhóm phát đa hướng được sử dụng để thông báo cho các ứng dụng trong không gian người dùng thông qua
ổ cắm liên kết mạng: ZZ0000ZZ

Tin nhắn thông báo:

========================================================================
  Thiết bị dpll ZZ0000ZZ đã được tạo
  Thiết bị dpll ZZ0001ZZ đã bị xóa
  Thiết bị dpll ZZ0002ZZ đã thay đổi
  Pin dpll ZZ0003ZZ đã được tạo
  Pin dpll ZZ0004ZZ đã bị xóa
  Pin dpll ZZ0005ZZ đã thay đổi
  ========================================================================

Định dạng sự kiện giống như đối với lệnh get tương ứng.
Định dạng của các sự kiện ZZ0000ZZ giống như phản hồi của
ZZ0001ZZ.
Định dạng của các sự kiện ZZ0002ZZ giống như phản hồi của
ZZ0003ZZ.

Triển khai trình điều khiển thiết bị
============================

Thiết bị được phân bổ theo lệnh gọi dpll_device_get(). Cuộc gọi thứ hai với
các đối số tương tự sẽ không tạo đối tượng mới nhưng cung cấp con trỏ tới
thiết bị được tạo trước đó cho các đối số đã cho, nó cũng tăng
sự hoàn lại của đối tượng đó.
Thiết bị được giải phóng bằng lệnh gọi dpll_device_put(), trước tiên
giảm số lần hoàn tiền, sau khi số tiền hoàn lại bị xóa, đối tượng sẽ
bị phá hủy.

Thiết bị nên thực hiện tập hợp các thao tác và đăng ký thiết bị thông qua
dpll_device_register() tại thời điểm đó nó sẽ có sẵn cho
người dùng. Nhiều phiên bản trình điều khiển có thể lấy tham chiếu đến nó bằng
dpll_device_get(), cũng như đăng ký thiết bị dpll bằng thiết bị riêng của họ
hoạt động và riêng tư.

Các chân được phân bổ riêng bằng dpll_pin_get(), nó hoạt động
tương tự như dpll_device_get(). Đầu tiên, hàm tạo đối tượng và sau đó
đối với mỗi cuộc gọi có cùng đối số, chỉ tính lại đối tượng
tăng lên. Ngoài ra dpll_pin_put() hoạt động tương tự như dpll_device_put().

Một mã pin có thể được đăng ký với thiết bị dpll gốc hoặc mã pin gốc, tùy thuộc vào
về nhu cầu phần cứng. Mỗi lần đăng ký yêu cầu người đăng ký cung cấp bộ
về các lệnh gọi lại mã pin và con trỏ dữ liệu riêng tư để gọi chúng:

- dpll_pin_register() - đăng ký mã pin với thiết bị dpll,
- dpll_pin_on_pin_register() - đăng ký mã pin với mã pin loại MUX khác.

Thông báo về việc thêm hoặc xóa thiết bị dpll được tạo trong
chính hệ thống con.
Thông báo về việc đăng ký/hủy đăng ký các chân cũng được gọi bởi
hệ thống con.
Thông báo về các thay đổi trạng thái của thiết bị dpll hoặc mã pin được
được gọi theo hai cách:

- sau khi yêu cầu thay đổi thành công trên hệ thống con dpll, hệ thống con
  gọi thông báo tương ứng,
- được yêu cầu bởi trình điều khiển thiết bị với dpll_device_change_ntf() hoặc
  dpll_pin_change_ntf() khi trình điều khiển thông báo về việc thay đổi trạng thái.

Trình điều khiển thiết bị sử dụng giao diện dpll không bắt buộc phải thực hiện tất cả
hoạt động gọi lại. Tuy nhiên, có rất ít yêu cầu phải có
được thực hiện.
Các hoạt động gọi lại cấp thiết bị dpll bắt buộc:

-ZZ0000ZZ,
-ZZ0001ZZ.

Hoạt động gọi lại cấp pin bắt buộc:

- ZZ0000ZZ (chân đăng ký với thiết bị dpll),
- ZZ0001ZZ (chân được đăng ký với chân chính),
-ZZ0002ZZ.

Mọi trình xử lý hoạt động khác đều được kiểm tra sự tồn tại và
ZZ0000ZZ được trả về trong trường hợp không có trình xử lý cụ thể.

Việc triển khai đơn giản nhất là trong trình điều khiển TimeCard OCP. hoạt động
cấu trúc được định nghĩa như thế này:

.. code-block:: c

	static const struct dpll_device_ops dpll_ops = {
		.lock_status_get = ptp_ocp_dpll_lock_status_get,
		.mode_get = ptp_ocp_dpll_mode_get,
		.mode_supported = ptp_ocp_dpll_mode_supported,
	};

	static const struct dpll_pin_ops dpll_pins_ops = {
		.frequency_get = ptp_ocp_dpll_frequency_get,
		.frequency_set = ptp_ocp_dpll_frequency_set,
		.direction_get = ptp_ocp_dpll_direction_get,
		.direction_set = ptp_ocp_dpll_direction_set,
		.state_on_dpll_get = ptp_ocp_dpll_state_get,
	};

Phần đăng ký thì trông giống như phần này:

.. code-block:: c

        clkid = pci_get_dsn(pdev);
        bp->dpll = dpll_device_get(clkid, 0, THIS_MODULE);
        if (IS_ERR(bp->dpll)) {
                err = PTR_ERR(bp->dpll);
                dev_err(&pdev->dev, "dpll_device_alloc failed\n");
                goto out;
        }

        err = dpll_device_register(bp->dpll, DPLL_TYPE_PPS, &dpll_ops, bp);
        if (err)
                goto out;

        for (i = 0; i < OCP_SMA_NUM; i++) {
                bp->sma[i].dpll_pin = dpll_pin_get(clkid, i, THIS_MODULE, &bp->sma[i].dpll_prop);
                if (IS_ERR(bp->sma[i].dpll_pin)) {
                        err = PTR_ERR(bp->dpll);
                        goto out_dpll;
                }

                err = dpll_pin_register(bp->dpll, bp->sma[i].dpll_pin, &dpll_pins_ops,
                                        &bp->sma[i]);
                if (err) {
                        dpll_pin_put(bp->sma[i].dpll_pin);
                        goto out_dpll;
                }
        }

Trong đường dẫn lỗi, chúng ta phải tua lại mọi phân bổ theo thứ tự ngược lại:

.. code-block:: c

        while (i) {
                --i;
                dpll_pin_unregister(bp->dpll, bp->sma[i].dpll_pin, &dpll_pins_ops, &bp->sma[i]);
                dpll_pin_put(bp->sma[i].dpll_pin);
        }
        dpll_device_put(bp->dpll);

Ví dụ phức tạp hơn có thể được tìm thấy trong trình điều khiển ICE của Intel hoặc trình điều khiển mlx5 của nVidia.

Kích hoạt SyncE
================
Để kích hoạt SyncE, cần phải cho phép kiểm soát thiết bị dpll
cho một ứng dụng phần mềm giám sát và cấu hình đầu vào của
thiết bị dpll để phản hồi trạng thái hiện tại của thiết bị dpll và
đầu vào.
Trong trường hợp như vậy, tín hiệu đầu vào của thiết bị dpll cũng phải được cấu hình
để điều khiển dpll với tín hiệu được khôi phục từ thiết bị mạng PHY.
Điều này được thực hiện bằng cách để một chốt vào thiết bị mạng - gắn một chốt vào
chính thiết bị mạng với
ZZ0000ZZ.
Sau đó, người dùng có thể nhận dạng mã pin id ZZ0001ZZ được hiển thị
vì nó được gắn vào rtnetlink phản hồi để nhận lệnh ZZ0002ZZ trong
thuộc tính lồng nhau ZZ0003ZZ.