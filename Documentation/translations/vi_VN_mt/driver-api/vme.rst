.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/driver-api/vme.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

Trình điều khiển thiết bị VME
==================

Đăng ký lái xe
-------------------

Giống như các hệ thống con khác trong nhân Linux, trình điều khiển thiết bị VME đăng ký
với hệ thống con VME, thường được gọi từ quy trình khởi tạo thiết bị.  Đây là
đạt được thông qua cuộc gọi tới ZZ0000ZZ.

Một con trỏ tới cấu trúc kiểu ZZ0000ZZ phải
được cung cấp cho chức năng đăng ký. Cùng với số lượng tối đa
các thiết bị mà trình điều khiển của bạn có thể hỗ trợ.

Ở mức tối thiểu, các phần tử '.name', '.match' và '.probe' của
ZZ0000ZZ phải được đặt chính xác. '.tên'
phần tử là một con trỏ tới một chuỗi chứa tên trình điều khiển thiết bị.

Chức năng '.match' cho phép kiểm soát thiết bị VME nào sẽ được đăng ký
với người lái xe. Hàm so khớp sẽ trả về 1 nếu một thiết bị được
được thăm dò và 0 nếu không. Ví dụ này khớp với giới hạn hàm (từ vme_user.c)
số lượng thiết bị được thăm dò tới một:

.. code-block:: c

	#define USER_BUS_MAX	1
	...
	static int vme_user_match(struct vme_dev *vdev)
	{
		if (vdev->id.num >= USER_BUS_MAX)
			return 0;
		return 1;
	}

Phần tử '.probe' phải chứa một con trỏ tới thủ tục thăm dò. các
thủ tục thăm dò được chuyển qua một con trỏ ZZ0000ZZ như một
lý lẽ.

Ở đây, trường 'num' đề cập đến ID thiết bị tuần tự cho cụ thể này
người lái xe. Số cầu (hoặc số xe buýt) có thể được truy cập bằng cách sử dụng
dev->cầu->num.

Một chức năng cũng được cung cấp để hủy đăng ký trình điều khiển khỏi lõi VME được gọi là
ZZ0000ZZ và thường được gọi từ thiết bị
quy trình thoát hiểm của người lái xe.


Quản lý tài nguyên
-------------------

Khi trình điều khiển đã đăng ký với lõi VME, quy trình khớp được cung cấp sẽ
được gọi là số lần được chỉ định trong quá trình đăng ký. Nếu một trận đấu
thành công, giá trị khác 0 sẽ được trả về. Giá trị trả về bằng 0 cho biết
thất bại. Đối với tất cả các kết quả khớp thành công, quy trình thăm dò của tương ứng
tài xế được gọi. Quy trình thăm dò được chuyển một con trỏ tới các thiết bị
cấu trúc thiết bị. Con trỏ này cần được lưu lại, nó sẽ được yêu cầu cho
yêu cầu tài nguyên VME.

Người lái xe có thể yêu cầu quyền sở hữu một hoặc nhiều cửa sổ chính
(ZZ0000ZZ), cửa sổ phụ (ZZ0001ZZ)
và/hoặc kênh DMA (ZZ0002ZZ). Thay vì cho phép thiết bị
trình điều khiển để yêu cầu một cửa sổ cụ thể hoặc kênh DMA (có thể được sử dụng bởi một
trình điều khiển khác nhau) API cho phép chỉ định tài nguyên dựa trên yêu cầu
thuộc tính của người lái xe được đề cập. Đối với cửa sổ nô lệ, các thuộc tính này là
chia thành các không gian địa chỉ VME cần được truy cập trong 'aspace' và VME
các loại chu kỳ xe buýt được yêu cầu trong 'chu kỳ'. Cửa sổ chính thêm một bộ nữa
thuộc tính trong 'width' chỉ định độ rộng truyền dữ liệu cần thiết. Những cái này
các thuộc tính được định nghĩa là mặt nạ bit và như vậy bất kỳ sự kết hợp nào của
các thuộc tính có thể được yêu cầu cho một cửa sổ, lõi sẽ chỉ định một cửa sổ
đáp ứng yêu cầu, trả về một con trỏ kiểu vme_resource
nên được sử dụng để xác định tài nguyên được phân bổ khi nó được sử dụng. Dành cho DMA
bộ điều khiển, chức năng yêu cầu yêu cầu hướng tiềm năng của bất kỳ
chuyển giao sẽ được cung cấp trong các thuộc tính tuyến đường. Đây thường là VME-to-MEM
và/hoặc MEM-to-VME, mặc dù một số phần cứng có thể hỗ trợ VME-to-VME và MEM-to-MEM
chuyển giao cũng như tạo mẫu thử nghiệm. Nếu lắp cửa sổ chưa được phân bổ
không thể tìm thấy các yêu cầu, con trỏ NULL sẽ được trả về.

Các chức năng cũng được cung cấp để phân bổ cửa sổ miễn phí khi chúng không còn nữa.
được yêu cầu. Các chức năng này (ZZ0000ZZ, ZZ0001ZZ
và ZZ0002ZZ) phải được chuyển con trỏ tới tài nguyên
được cung cấp trong quá trình phân bổ nguồn lực.


Cửa sổ chính
--------------

Cửa sổ chính cung cấp quyền truy cập từ [các] bộ xử lý cục bộ lên bus VME.
Số lượng cửa sổ khả dụng và các chế độ truy cập khả dụng tùy thuộc vào
chipset cơ bản. Một cửa sổ phải được cấu hình trước khi có thể sử dụng nó.


Cấu hình cửa sổ chính
~~~~~~~~~~~~~~~~~~~~~~~~~~~

Khi cửa sổ chính đã được gán, ZZ0000ZZ có thể được sử dụng để
cấu hình nó và ZZ0001ZZ để truy xuất các cài đặt hiện tại. các
không gian địa chỉ, độ rộng truyền và loại chu kỳ giống như mô tả
dưới sự quản lý tài nguyên, tuy nhiên một số tùy chọn loại trừ lẫn nhau.
Ví dụ: chỉ có thể chỉ định một không gian địa chỉ.


Truy cập cửa sổ chính
~~~~~~~~~~~~~~~~~~~~

Hàm ZZ0000ZZ có thể được sử dụng để đọc và
ZZ0001ZZ được sử dụng để ghi vào các cửa sổ chính đã được cấu hình.

Ngoài việc đọc và ghi đơn giản, ZZ0000ZZ còn được cung cấp cho
thực hiện giao dịch đọc-sửa-ghi. Các phần của cửa sổ VME cũng có thể được ánh xạ
vào bộ nhớ không gian người dùng bằng ZZ0001ZZ.


Cửa sổ phụ
-------------

Cửa sổ phụ cung cấp cho các thiết bị trên bus VME quyền truy cập vào các phần được ánh xạ của
bộ nhớ cục bộ. Số lượng cửa sổ có sẵn và các chế độ truy cập có thể được
được sử dụng phụ thuộc vào chipset cơ bản. Một cửa sổ phải được cấu hình trước
nó có thể được sử dụng.


Cấu hình cửa sổ phụ
~~~~~~~~~~~~~~~~~~~~~~~~~~

Khi cửa sổ phụ đã được gán, ZZ0000ZZ có thể được sử dụng để
cấu hình nó và ZZ0001ZZ để truy xuất các cài đặt hiện tại.

Không gian địa chỉ, độ rộng truyền và loại chu kỳ giống như mô tả
dưới sự quản lý tài nguyên, tuy nhiên một số tùy chọn loại trừ lẫn nhau.
Ví dụ: chỉ có thể chỉ định một không gian địa chỉ.


Phân bổ bộ đệm cửa sổ phụ
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Các chức năng được cung cấp để cho phép người dùng phân bổ
(ZZ0000ZZ) và miễn phí (ZZ0001ZZ)
bộ đệm liền kề có thể truy cập được bằng cầu VME. Những chức năng này
không nhất thiết phải sử dụng, tuy nhiên, các phương pháp khác có thể được sử dụng để phân bổ bộ đệm
phải cẩn thận để đảm bảo rằng chúng liền kề và có thể truy cập được bởi VME
cầu.


Truy cập cửa sổ phụ
~~~~~~~~~~~~~~~~~~~

Cửa sổ phụ ánh xạ bộ nhớ cục bộ lên bus VME, các phương pháp tiêu chuẩn cho
truy cập bộ nhớ nên được sử dụng.


kênh DMA
------------

Chuyển VME DMA cung cấp khả năng chạy chuyển DMA danh sách liên kết. các
API giới thiệu khái niệm về danh sách DMA. Mỗi danh sách DMA là một danh sách liên kết có thể
được chuyển tới bộ điều khiển DMA. Nhiều danh sách có thể được tạo, mở rộng,
thực hiện, tái sử dụng và phá hủy.


Quản lý danh sách
~~~~~~~~~~~~~~~

Chức năng ZZ0000ZZ được cung cấp để tạo và
ZZ0001ZZ để hủy danh sách DMA. Việc thực hiện một danh sách sẽ không
tự động hủy danh sách, do đó cho phép danh sách được sử dụng lại cho các mục đích lặp đi lặp lại
nhiệm vụ.


Danh sách dân số
~~~~~~~~~~~~~~~

Một mục có thể được thêm vào danh sách bằng cách sử dụng ZZ0000ZZ (nguồn và
thuộc tính đích cần được tạo trước khi gọi hàm này, đây là
được đề cập trong "Thuộc tính chuyển giao").

.. note::

	The detailed attributes of the transfers source and destination
	are not checked until an entry is added to a DMA list, the request
	for a DMA channel purely checks the directions in which the
	controller is expected to transfer data. As a result it is
	possible for this call to return an error, for example if the
	source or destination is in an unsupported VME address space.

Chuyển thuộc tính
~~~~~~~~~~~~~~~~~~~

Các thuộc tính cho nguồn và đích được xử lý riêng biệt với việc thêm
một mục vào một danh sách. Điều này là do các thuộc tính đa dạng cần thiết cho từng loại
của nguồn và đích. Có chức năng tạo thuộc tính cho PCI, VME
và các nguồn và đích mẫu (nếu thích hợp):

- Nguồn hoặc đích PCI: ZZ0000ZZ
 - Nguồn hoặc đích VME: ZZ0001ZZ
 - Nguồn mẫu: ZZ0002ZZ

Nên sử dụng chức năng ZZ0000ZZ để giải phóng một
thuộc tính.


Thực thi danh sách
~~~~~~~~~~~~~~

Hàm ZZ0000ZZ xếp hàng một danh sách để thực thi và sẽ
trả về khi danh sách đã được thực thi.


Ngắt
----------

VME API cung cấp các chức năng để đính kèm và tách các lệnh gọi lại cho VME cụ thể
kết hợp ID cấp độ và trạng thái và để tạo các ngắt VME với
ID trạng thái và cấp độ VME cụ thể.


Đính kèm trình xử lý ngắt
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Chức năng ZZ0000ZZ có thể được sử dụng để gắn và
ZZ0001ZZ để giải phóng tổ hợp ID trạng thái và cấp độ VME cụ thể.
Bất kỳ sự kết hợp nào cũng chỉ có thể được gán một chức năng gọi lại duy nhất. Một khoảng trống
tham số con trỏ được cung cấp, giá trị của nó được chuyển đến lệnh gọi lại
chức năng, việc sử dụng con trỏ này là người dùng không xác định. Các tham số gọi lại là
như sau. Phải cẩn thận khi viết hàm gọi lại, gọi lại
các hàm chạy trong ngữ cảnh ngắt:

.. code-block:: c

	void callback(int level, int statid, void *priv);


Tạo ngắt
~~~~~~~~~~~~~~~~~~~~

Hàm ZZ0000ZZ có thể được sử dụng để tạo ngắt VME
ở cấp độ VME nhất định và ID trạng thái VME.


Giám sát vị trí
-----------------

VME API cung cấp chức năng sau để định cấu hình vị trí
màn hình.


Quản lý giám sát vị trí
~~~~~~~~~~~~~~~~~~~~~~~~~~~

Chức năng ZZ0000ZZ được cung cấp để yêu cầu sử dụng khối
của màn hình vị trí và ZZ0001ZZ để giải phóng chúng sau khi không còn
cần thiết lâu hơn. Mỗi khối có thể cung cấp một số màn hình vị trí,
giám sát các vị trí lân cận. Có thể sử dụng chức năng ZZ0002ZZ
để xác định có bao nhiêu địa điểm được cung cấp.


Cấu hình giám sát vị trí
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Khi một dãy giám sát vị trí đã được phân bổ, chức năng
ZZ0000ZZ được cung cấp để định cấu hình vị trí và chế độ của
giám sát vị trí. Chức năng ZZ0001ZZ có thể được sử dụng để truy xuất
các cài đặt hiện có.


Sử dụng giám sát vị trí
~~~~~~~~~~~~~~~~~~~~

Hàm ZZ0000ZZ cho phép đính kèm một lệnh gọi lại và
ZZ0001ZZ cho phép tách rời khỏi mỗi màn hình vị trí
vị trí. Mỗi màn hình vị trí có thể giám sát một số vị trí lân cận. các
hàm gọi lại được khai báo như sau.

.. code-block:: c

	void callback(void *data);


Phát hiện khe
--------------

Hàm ZZ0000ZZ trả về ID vị trí của cầu nối được cung cấp.


Phát hiện xe buýt
-------------

Hàm ZZ0000ZZ trả về ID bus của cầu được cung cấp.


VME API
-------

.. kernel-doc:: drivers/staging/vme_user/vme.h
   :internal:

.. kernel-doc:: drivers/staging/vme_user/vme.c
   :export:
