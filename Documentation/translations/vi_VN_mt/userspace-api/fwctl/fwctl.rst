.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/fwctl/fwctl.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

==================
hệ thống con fwctl
==================

:Tác giả: Jason Gunthorpe

Tổng quan
=========

Các thiết bị hiện đại chứa một lượng lớn FW, và trong nhiều trường hợp, phần lớn là
phần cứng được xác định bằng phần mềm. Sự phát triển của phương pháp này phần lớn là do
phản ứng với Định luật Moore khi mà băng chip hiện nay rất đắt tiền và
thiết kế chip cực kỳ lớn. Thay thế logic CTNH cố định bằng logic linh hoạt và
Sự kết hợp FW/HW được kết hợp chặt chẽ là một biện pháp giảm thiểu rủi ro hiệu quả chống lại chip
quay lại. Các vấn đề trong thiết kế CTNH có thể được giải quyết trong thiết bị FW. Đây là
đặc biệt đúng đối với các thiết bị có giao diện ổn định và tương thích ngược
giao diện với trình điều khiển hệ điều hành (chẳng hạn như NVMe).

Lớp FW trong các thiết bị đã phát triển đến kích thước đáng kinh ngạc và các thiết bị thường xuyên phát triển
tích hợp các cụm bộ xử lý nhanh để chạy nó. Ví dụ: thiết bị mlx5 có
hơn 30 MB mã FW và các cấu hình lớn hoạt động với hơn 1GB FW được quản lý
trạng thái thời gian chạy.

Sự sẵn có của một lớp linh hoạt như vậy đã tạo ra sự đa dạng trong
ngành công nghiệp nơi các mảnh silicon đơn lẻ hiện có thể được định cấu hình bằng phần mềm
các thiết bị và có thể hoạt động theo những cách khác nhau tùy theo nhu cầu.
Hơn nữa, chúng tôi thường thấy các trường hợp các trang web cụ thể muốn vận hành thiết bị theo cách
có tính chuyên môn cao và yêu cầu các ứng dụng được thiết kế riêng cho
cấu hình độc đáo của họ.

Hơn nữa, các thiết bị đã trở nên đa chức năng và tích hợp đến mức chúng
không còn phù hợp với sự phân chia các hệ thống con của kernel nữa. hiện đại
các thiết bị đa chức năng có trình điều khiển, chẳng hạn như bnxt/ice/mlx5/pds, trải rộng trên nhiều
các hệ thống con trong khi chia sẻ phần cứng cơ bản bằng thiết bị phụ trợ
hệ thống.

Tất cả điều này cùng nhau tạo ra một thách thức cho hệ điều hành, nơi các thiết bị
có môi trường FW mở rộng cần gỡ lỗi mạnh mẽ dành riêng cho thiết bị
hỗ trợ và chức năng dựa trên FW không phù hợp với "chung"
giao diện. fwctl tìm cách cho phép truy cập vào chức năng đầy đủ của thiết bị từ
không gian người dùng trong các lĩnh vực có khả năng sửa lỗi, quản lý và khởi động lần đầu/khởi động thứ n
cung cấp.

fwctl nhắm đến mẫu thiết kế thiết bị phổ biến trong đó hệ điều hành và FW
giao tiếp thông qua lớp tin nhắn RPC được xây dựng bằng sơ đồ hàng đợi hoặc hộp thư.
Trong trường hợp này, trình điều khiển thường sẽ có một số lớp để gửi tin nhắn RPC
và thu thập phản hồi RPC từ FW của thiết bị. Trình điều khiển hệ thống con trong kernel
vận hành thiết bị cho các mục đích chính của nó sẽ sử dụng các RPC này để xây dựng
trình điều khiển, nhưng các thiết bị cũng thường có một bộ RPC phụ trợ không thực sự
phù hợp với bất kỳ hệ thống con cụ thể nào. Ví dụ: bộ điều khiển HW RAID chủ yếu
được vận hành bởi lớp khối nhưng cũng đi kèm với một bộ RPC để quản lý
xây dựng các bộ truyền động trong HW RAID.

Trước đây khi các thiết bị có nhiều chức năng đơn lẻ hơn, các hệ thống con riêng lẻ sẽ
phát triển các cách tiếp cận khác nhau để giải quyết một số vấn đề chung này. Ví dụ,
theo dõi tình trạng thiết bị, thao tác FLASH của nó, gỡ lỗi FW,
cung cấp, tất cả đều có nhiều giao diện độc đáo khác nhau trên kernel.

Mục đích của fwctl là xác định một bộ quy tắc giới hạn chung, được mô tả bên dưới,
cho phép không gian người dùng xây dựng và thực thi RPC một cách an toàn bên trong thiết bị FW.
Các quy tắc đóng vai trò như một thỏa thuận giữa hệ điều hành và FW về cách
thiết kế chính xác giao diện RPC. Là một uAPI, hệ thống con cung cấp một
lớp khám phá và uAPI chung để phân phối RPC và thu thập
phản hồi. Nó hỗ trợ một hệ thống các thư viện và công cụ không gian người dùng sẽ
sử dụng giao diện này để điều khiển thiết bị bằng các giao thức gốc của thiết bị.

Phạm vi hành động
-----------------

Trình điều khiển fwctl bị hạn chế nghiêm ngặt để trở thành một cách để vận hành thiết bị FW.
Đây không phải là cách để truy cập vào phần bên trong hạt nhân ngẫu nhiên hoặc hệ điều hành khác
trạng thái SW.

Các phiên bản fwctl phải hoạt động trên một chức năng thiết bị được xác định rõ ràng và thiết bị
cần có một mô hình bảo mật được xác định rõ ràng cho phạm vi nào trong môi trường vật lý
thiết bị mà chức năng được phép truy cập. Ví dụ, PCIe phức tạp nhất
thiết bị ngày nay có thể có một số phạm vi cấp độ chức năng:

1. Chức năng đặc quyền có toàn quyền truy cập vào trạng thái toàn cầu trên thiết bị và
    cấu hình

2. Nhiều chức năng ảo hóa có khả năng kiểm soát chính nó và các chức năng con
    được sử dụng với VM

3. Nhiều chức năng VM nằm trong phạm vi chặt chẽ của VM

Thiết bị có thể tạo mối quan hệ cha/con hợp lý giữa các phạm vi này.
Ví dụ: FW của máy ảo con có thể nằm trong phạm vi của FW ảo hóa. Đó là
khá phổ biến trong thế giới VFIO rằng môi trường ảo hóa có một cấu trúc phức tạp
trách nhiệm cung cấp/lập hồ sơ/cấu hình cho chức năng VFIO
gán cho VM.

Hơn nữa, trong chức năng, các thiết bị thường có các lệnh RPC nằm trong
một số phạm vi hành động chung (xem enum fwctl_rpc_scope):

1. Truy cập vào chức năng & cấu hình con, FLASH, v.v. sẽ hoạt động tại
    thiết lập lại chức năng. Quyền truy cập vào chức năng và cấu hình thời gian chạy con
    minh bạch hoặc không gây gián đoạn cho bất kỳ trình điều khiển hoặc VM nào.

2. Quyền truy cập chỉ đọc vào thông tin gỡ lỗi chức năng có thể báo cáo về các đối tượng FW
    trong hàm & con, bao gồm các đối tượng FW thuộc sở hữu của kernel khác
    các hệ thống con.

3. Viết quyền truy cập vào chức năng và thông tin gỡ lỗi con tương thích hoàn toàn với
    các nguyên tắc khóa kernel và bảo vệ tính toàn vẹn của kernel. Trình kích hoạt
    một vết bẩn hạt nhân.

4. Truy cập thiết bị gỡ lỗi đầy đủ. Kích hoạt lỗi kernel, yêu cầu CAP_SYS_RAWIO.

Không gian người dùng sẽ cung cấp nhãn phạm vi trên mỗi RPC và kernel phải thực thi
trên CAP và vết bẩn dựa trên phạm vi đó. Sự kết hợp giữa kernel và FW có thể
thực thi rằng RPC được đặt trong phạm vi chính xác theo không gian người dùng.

Hành vi không được phép
-----------------------

Có nhiều thứ mà giao diện này không cho phép không gian người dùng thực hiện (không có
taint hoặc CAP), có nguồn gốc rộng rãi từ các nguyên tắc khóa kernel. Một số
ví dụ:

1. DMA đến/từ bộ nhớ tùy ý, treo hệ thống, xâm phạm tính toàn vẹn của FW với
    mã không đáng tin cậy hoặc làm tổn hại đến bảo mật của thiết bị hoặc hệ thống và
    tính chính trực.

2. Cung cấp một “cửa sau” bất thường cho trình điều khiển kernel. Không có thao tác với kernel
    các đối tượng thuộc sở hữu của trình điều khiển kernel.

3. Trực tiếp cấu hình hoặc kiểm soát trình điều khiển hạt nhân. Hạt nhân hệ thống con
    trình điều khiển có thể phản ứng với cấu hình thiết bị khi thiết lập lại chức năng/tải trình điều khiển
    time, nhưng nếu không thì không được ghép nối với fwctl.

4. Vận hành CTNH theo cách trùng lặp với mục đích cốt lõi của người khác
    hệ thống con hạt nhân chính, chẳng hạn như đọc/ghi vào LBA, gửi/nhận
    gói mạng hoặc vận hành mặt phẳng dữ liệu của máy gia tốc.

fwctl không phải là sự thay thế cho các hệ thống con truy cập trực tiếp của thiết bị như uacce hoặc
VFIO.

Các hoạt động được thực hiện thông qua các giao diện không bị hoen ố của fwctl phải được thực hiện đầy đủ
có thể chia sẻ với những người dùng khác của thiết bị. Ví dụ: hiển thị RPC thông qua
fwctl không bao giờ nên ngăn hệ thống con kernel đồng thời sử dụng nó
cùng một RPC hoặc đơn vị phần cứng sắp ra mắt. Trong những trường hợp như vậy fwctl sẽ ít hơn
quan trọng hơn các hệ thống con hạt nhân thích hợp cuối cùng xuất hiện. Những sai lầm trong việc này
khu vực dẫn đến xung đột sẽ được giải quyết theo hướng triển khai kernel.

fwctl Người dùng API
====================

.. kernel-doc:: include/uapi/fwctl/bnxt.h
.. kernel-doc:: include/uapi/fwctl/fwctl.h
.. kernel-doc:: include/uapi/fwctl/mlx5.h
.. kernel-doc:: include/uapi/fwctl/pds.h

Lớp sysfs
-----------

fwctl có một lớp sysfs (/sys/class/fwctl/fwctlNN/) và các thiết bị ký tự
(/dev/fwctl/fwctlNN) với sơ đồ đánh số đơn giản. Thiết bị nhân vật
vận hành iotcl uAPI được mô tả ở trên.

Các thiết bị fwctl có thể liên quan đến các thành phần trình điều khiển trong các hệ thống con khác thông qua
sysfs::

$ ls /sys/class/fwctl/fwctl0/device/infiniband/
    ibp0s10f0

$ ls /sys/class/infiniband/ibp0s10f0/device/fwctl/
    fwctl0/

$ ls /sys/devices/pci0000:00/0000:00:0a.0/fwctl/fwctl0
    sự kiện hệ thống con nguồn của thiết bị dev

Không gian người dùng
---------------------

Lấy cảm hứng từ nvme-cli, tham gia bên kernel thì phải tới
với không gian người dùng trong cây git TBD chung, ở mức tối thiểu để vận hành một cách hữu ích
trình điều khiển hạt nhân. Việc cung cấp cách triển khai như vậy là điều kiện tiên quyết để hợp nhất một
trình điều khiển hạt nhân.

Mục tiêu là xây dựng cộng đồng không gian người dùng xung quanh một số vấn đề được chia sẻ
tất cả chúng ta đều có, và lý tưởng nhất là phát triển một số chương trình không gian người dùng chung với một số
chủ đề bắt đầu của:

- Gỡ lỗi tại hiện trường của thiết bị

- Cung cấp CTNH

- Cấu hình thiết bị con VFIO trước khi khởi động VM

- Chủ đề Điện toán bí mật (chứng thực, cung cấp an toàn)

trải dài trên tất cả các hệ thống con trong kernel. fwupd là một ví dụ tuyệt vời về
cách trải nghiệm không gian người dùng tuyệt vời có thể xuất hiện nhờ sự đa dạng phía hạt nhân.

hạt nhân fwctl API
==================

.. kernel-doc:: drivers/fwctl/main.c
   :export:
.. kernel-doc:: include/linux/fwctl.h

fwctl Thiết kế trình điều khiển
-------------------------------

Trong nhiều trường hợp, trình điều khiển fwctl sẽ là một phần của hệ thống con chéo lớn hơn
thiết bị có thể sử dụng cơ chế phụ trợ_thiết bị. Trong trường hợp đó một số
các hệ thống con sẽ chia sẻ cùng một thiết bị và lớp giao diện FW nên
thiết kế thiết bị phải cung cấp sự cách ly và hợp tác giữa kernel
các hệ thống con. fwctl phải phù hợp với mô hình tương tự.

Một phần của trình điều khiển phải bao gồm mô tả về cách hạn chế phạm vi của nó
và mô hình bảo mật hoạt động. Người lái xe và FW cùng nhau phải đảm bảo rằng RPC
được cung cấp bởi không gian người dùng được ánh xạ tới phạm vi thích hợp. Nếu việc xác nhận là
được thực hiện trong trình điều khiển thì quá trình xác thực có thể đọc báo cáo 'hiệu ứng lệnh' từ
thiết bị hoặc buộc chặt việc thực thi. Nếu việc xác thực được thực hiện trong FW,
thì trình điều khiển sẽ chuyển fwctl_rpc_scope cho FW cùng với lệnh.

Người lái xe và FW phải hợp tác để đảm bảo rằng fwctl không thể phân bổ
mọi tài nguyên FW hoặc bất kỳ tài nguyên nào nó phân bổ đều được giải phóng khi đóng FD.  A
trình điều khiển được xây dựng chủ yếu xung quanh FW RPC có thể thấy rằng chức năng PCI cốt lõi của nó
và lớp RPC thuộc fwctl với các thiết bị phụ trợ kết nối với các thiết bị khác
các hệ thống con.

Mỗi loại thiết bị phải lưu tâm đến triết lý của Linux về ABI ổn định. FW
Giao diện RPC không nhất thiết phải đáp ứng ABI ổn định nghiêm ngặt, nhưng nó cần phải
đáp ứng kỳ vọng rằng các công cụ không gian người dùng được triển khai và có tác dụng đáng kể
sử dụng không cần thiết phải phá vỡ. Nâng cấp FW và nâng cấp kernel nên giữ rộng rãi
công cụ được triển khai làm việc.

Việc phát triển và gỡ lỗi các RPC tập trung trong phạm vi dễ dàng hơn có thể có
kém ổn định hơn nếu các công cụ sử dụng chúng chỉ được chạy trong điều kiện đặc biệt
hoàn cảnh chứ không phải cho việc sử dụng thiết bị hàng ngày. Công cụ gỡ lỗi thậm chí có thể
yêu cầu khớp phiên bản chính xác vì chúng có thể yêu cầu thứ gì đó tương tự như DWARF
thông tin gỡ lỗi từ nhị phân FW.

Phản hồi bảo mật
=================

Kernel vẫn là người gác cổng cho giao diện này. Nếu vi phạm các
phạm vi, nguyên tắc bảo mật hoặc cách ly được tìm thấy, chúng tôi có các tùy chọn để cho phép
các thiết bị sửa chúng bằng bản cập nhật FW, đẩy bản vá kernel để phân tích và chặn RPC
lệnh hoặc đẩy bản vá kernel để chặn toàn bộ phiên bản/thiết bị phần sụn.

Mặc dù hạt nhân luôn có thể phân tích cú pháp trực tiếp và hạn chế RPC, nhưng điều đó được mong đợi
rằng mẫu hạt nhân hiện tại cho phép trình điều khiển ủy quyền xác thực cho
FW là một thiết kế hữu ích.

Các ví dụ tương tự hiện có
==========================

Cách tiếp cận được mô tả trong tài liệu này không phải là một ý tưởng mới. Trực tiếp hoặc gần
quyền truy cập thiết bị trực tiếp đã được hạt nhân cung cấp ở các khu vực khác nhau cho
thập kỷ. Với nhiều thiết bị muốn đi theo mẫu thiết kế này, nó đang trở thành
rõ ràng là nó chưa được hiểu rõ hoàn toàn và quan trọng hơn là
những cân nhắc về an ninh không được xác định hoặc thống nhất rõ ràng.

Một số ví dụ:

- Bộ điều khiển HW RAID. Điều này bao gồm các RPC để thực hiện những việc như soạn ổ đĩa vào
   ổ RAID, định cấu hình các tham số RAID, giám sát CTNH và hơn thế nữa.

- Người quản lý ván chân tường. RPC để định cấu hình cài đặt trong thiết bị và hơn thế nữa.

- Viên nang lệnh của nhà cung cấp NVMe. nvme-cli cung cấp quyền truy cập vào một số giám sát
   các chức năng mà các sản phẩm khác nhau đã xác định, nhưng vẫn tồn tại nhiều chức năng hơn.

- CXL cũng có hệ thống lệnh của nhà cung cấp giống NVMe.

- DRM cho phép trình điều khiển không gian người dùng gửi lệnh đến thiết bị thông qua kernel
   hòa giải.

- RDMA cho phép trình điều khiển không gian người dùng đẩy lệnh trực tiếp đến thiết bị
   không có sự tham gia của kernel.

- Nhiều API “thô”, HID thô (SDL2), USB thô, Giao diện chung NVMe, v.v.

4 lĩnh vực đầu tiên là ví dụ về các lĩnh vực mà fwctl dự định đảm nhiệm. Ba cái sau
là ví dụ về hành vi không được phép vì chúng hoàn toàn trùng lặp với mục đích chính
của một hệ thống con hạt nhân.

Một số bài học quan trọng rút ra từ những nỗ lực trong quá khứ là tầm quan trọng của việc có một
dự án không gian người dùng chung để sử dụng làm điều kiện tiên quyết để lấy kernel
người lái xe. Phát triển cộng đồng tốt xung quanh phần mềm hữu ích trong không gian người dùng là chìa khóa để
kêu gọi các công ty tài trợ cho sự tham gia để kích hoạt sản phẩm của họ.