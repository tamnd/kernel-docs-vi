.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/driver-api/gpio/consumer.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

=====================================
Giao diện người dùng mô tả GPIO
==================================

Tài liệu này mô tả giao diện người tiêu dùng của khung GPIO.


Hướng dẫn dành cho người tiêu dùng GPIO
==============================

Trình điều khiển không thể hoạt động nếu không có lệnh gọi GPIO tiêu chuẩn phải có mục Kconfig
phụ thuộc vào GPIOLIB hoặc chọn GPIOLIB. Các chức năng cho phép người lái xe
lấy và sử dụng GPIO có sẵn bằng cách bao gồm tệp sau::

#include <linux/gpio/consumer.h>

Có các nhánh nội tuyến tĩnh cho tất cả các hàm trong tệp tiêu đề trong trường hợp
nơi GPIOLIB bị vô hiệu hóa. Khi những cuống này được gọi, chúng sẽ phát ra
cảnh báo. Những sơ khai này được sử dụng cho hai trường hợp sử dụng:

- Phạm vi biên dịch đơn giản với ví dụ: COMPILE_TEST - điều đó không thành vấn đề
  nền tảng hiện tại không kích hoạt hoặc chọn GPIOLIB vì chúng tôi không
  Dù sao thì cũng sẽ thực thi hệ thống.

- Hỗ trợ GPIOLIB thực sự tùy chọn - nơi trình điều khiển không thực sự sử dụng
  của GPIO trên các cấu hình thời gian biên dịch nhất định cho một số hệ thống nhất định, nhưng
  sẽ sử dụng nó trong các cấu hình thời gian biên dịch khác. Trong trường hợp này
  người tiêu dùng phải đảm bảo không gọi vào các chức năng này, nếu không người dùng sẽ
  gặp phải các cảnh báo trên bảng điều khiển có thể được coi là đáng sợ.
  Kết hợp việc sử dụng GPIOLIB thực sự tùy chọn với các cuộc gọi đến
  ZZ0000ZZ là ZZ0001ZZ và sẽ mang lại kết quả kỳ lạ
  thông báo lỗi. Sử dụng các hàm getter thông thường với GPIOLIB tùy chọn:
  bạn nên dự kiến một số mã mở về xử lý lỗi khi thực hiện việc này.

Tất cả các chức năng hoạt động với giao diện GPIO dựa trên mô tả đều có
có tiền tố ZZ0000ZZ. Tiền tố ZZ0001ZZ được sử dụng cho di sản
giao diện. Không có chức năng nào khác trong kernel nên sử dụng các tiền tố này. Việc sử dụng
của các hàm cũ không được khuyến khích, nên sử dụng mã mới
<linux/gpio/consumer.h> và các bộ mô tả riêng.


Thu thập và xử lý GPIO
=============================

Với giao diện dựa trên bộ mô tả, GPIO được xác định bằng một mã mờ,
trình xử lý không thể tha thứ phải được thực hiện thông qua lệnh gọi tới một trong các
các hàm gpiod_get(). Giống như nhiều hệ thống con kernel khác, gpiod_get() lấy
thiết bị sẽ sử dụng GPIO và chức năng mà GPIO được yêu cầu phải có
đáp ứng::

cấu trúc gpio_desc *gpiod_get(struct device *dev, const char *con_id,
				    cờ enum gpiod_flags)

Nếu một chức năng được triển khai bằng cách sử dụng nhiều GPIO cùng nhau (ví dụ: LED đơn giản
thiết bị hiển thị chữ số), một đối số chỉ mục bổ sung có thể được chỉ định ::

cấu trúc gpio_desc *gpiod_get_index(struct device *dev,
					  const char *con_id, unsigned int idx,
					  cờ enum gpiod_flags)

Để biết mô tả chi tiết hơn về tham số con_id trong trường hợp DeviceTree
xem Tài liệu/driver-api/gpio/board.rst

Tham số flags được sử dụng để tùy ý chỉ định hướng và giá trị ban đầu
dành cho GPIO. Các giá trị có thể là:

* GPIOD_ASIS hoặc 0 để hoàn toàn không khởi tạo GPIO. Phải xác định hướng
  sau này với một trong những chức năng chuyên dụng.
* GPIOD_IN để khởi tạo GPIO làm đầu vào.
* GPIOD_OUT_LOW để khởi tạo GPIO làm đầu ra với giá trị 0.
* GPIOD_OUT_HIGH để khởi tạo GPIO làm đầu ra với giá trị là 1.
* GPIOD_OUT_LOW_OPEN_DRAIN giống như GPIOD_OUT_LOW nhưng cũng thực thi dòng
  được sử dụng bằng điện với cống mở.
* GPIOD_OUT_HIGH_OPEN_DRAIN giống như GPIOD_OUT_HIGH nhưng cũng thực thi dòng
  được sử dụng bằng điện với cống mở.

Lưu ý rằng giá trị ban đầu là ZZ0001ZZ và mức dòng vật lý phụ thuộc vào
đường dây được cấu hình ở mức hoạt động cao hay mức hoạt động thấp (xem
ZZ0000ZZ).

Hai cờ cuối cùng được sử dụng cho các trường hợp sử dụng trong đó bắt buộc phải có cống mở, chẳng hạn như
dưới dạng I2C: nếu đường dây chưa được định cấu hình là cống mở trong ánh xạ
(xem board.rst), thì cống mở vẫn sẽ được thực thi và cảnh báo sẽ được đưa ra
in ra rằng cấu hình bo mạch cần được cập nhật để phù hợp với trường hợp sử dụng.

Cả hai hàm đều trả về bộ mô tả GPIO hợp lệ hoặc mã lỗi có thể kiểm tra được
với IS_ERR() (chúng sẽ không bao giờ trả về con trỏ NULL). -ENOENT sẽ được trả lại
nếu và chỉ khi không có GPIO nào được gán cho bộ ba thiết bị/chức năng/chỉ mục,
các mã lỗi khác được sử dụng cho trường hợp GPIO đã được gán nhưng bị lỗi
xảy ra trong khi cố gắng để có được nó. Điều này rất hữu ích để phân biệt giữa
lỗi và thiếu GPIO cho các tham số GPIO tùy chọn. Đối với cái chung
mẫu trong đó GPIO là tùy chọn, gpiod_get_Optional() và
Có thể sử dụng các hàm gpiod_get_index_Optional(). Các hàm này trả về NULL
thay vì -ENOENT nếu không có GPIO nào được gán cho chức năng được yêu cầu::

cấu trúc gpio_desc *gpiod_get_optional(struct device *dev,
					     const char *con_id,
					     cờ enum gpiod_flags)

cấu trúc gpio_desc *gpiod_get_index_optional(struct device *dev,
						   const char *con_id,
						   chỉ số int không dấu,
						   cờ enum gpiod_flags)

Lưu ý rằng các hàm gpio_get*_Optional() (và các biến thể được quản lý của chúng), không giống như
phần còn lại của gpiolib API, cũng trả về NULL khi hỗ trợ gpiolib bị tắt.
Điều này rất hữu ích cho các tác giả trình điều khiển, vì họ không cần viết hoa chữ thường
-ENOSYS trả lại mã.  Tuy nhiên, các nhà tích hợp hệ thống nên cẩn thận để kích hoạt
gpiolib trên các hệ thống cần nó.

Đối với một hàm sử dụng nhiều GPIO, tất cả những GPIO đó có thể được lấy bằng một lệnh gọi ::

cấu trúc gpio_descs *gpiod_get_array(struct device *dev,
					   const char *con_id,
					   cờ enum gpiod_flags)

Hàm này trả về một cấu trúc gpio_descs chứa một mảng
những người mô tả.  Nó cũng chứa một con trỏ tới cấu trúc riêng tư gpiolib,
nếu được truyền trở lại để lấy/đặt các hàm mảng, có thể tăng tốc độ xử lý I/O ::

cấu trúc gpio_descs {
		struct gpio_array *thông tin;
		unsigned int ndescs;
		struct gpio_desc *desc[];
	}

Hàm sau trả về NULL thay vì -ENOENT nếu không có GPIO nào
được gán cho chức năng được yêu cầu::

cấu trúc gpio_descs *gpiod_get_array_optional(struct device *dev,
						    const char *con_id,
						    cờ enum gpiod_flags)

Các biến thể do thiết bị quản lý của các chức năng này cũng được xác định::

cấu trúc gpio_desc *devm_gpiod_get(struct device *dev, const char *con_id,
					 cờ enum gpiod_flags)

cấu trúc gpio_desc *devm_gpiod_get_index(struct device *dev,
					       const char *con_id,
					       idx không dấu,
					       cờ enum gpiod_flags)

cấu trúc gpio_desc *devm_gpiod_get_optional(struct device *dev,
						  const char *con_id,
						  cờ enum gpiod_flags)

cấu trúc gpio_desc *devm_gpiod_get_index_optional(struct device *dev,
							const char *con_id,
							chỉ số int không dấu,
							cờ enum gpiod_flags)

cấu trúc gpio_descs *devm_gpiod_get_array(struct device *dev,
						const char *con_id,
						cờ enum gpiod_flags)

cấu trúc gpio_descs *devm_gpiod_get_array_optional(struct device *dev,
							 const char *con_id,
							 cờ enum gpiod_flags)

Bộ mô tả GPIO có thể được loại bỏ bằng cách sử dụng hàm gpiod_put() ::

void gpiod_put(struct gpio_desc *desc)

Đối với một mảng GPIO, chức năng này có thể được sử dụng ::

void gpiod_put_array(struct gpio_descs *descs)

Nghiêm cấm sử dụng bộ mô tả sau khi gọi các hàm này.
Nó cũng không được phép phát hành các bộ mô tả riêng lẻ (sử dụng gpiod_put())
từ một mảng thu được bằng gpiod_get_array().

Không có gì đáng ngạc nhiên khi các biến thể do thiết bị quản lý là::

void devm_gpiod_put(thiết bị cấu trúc *dev, struct gpio_desc *desc)

void devm_gpiod_put_array(thiết bị cấu trúc *dev, struct gpio_descs *descs)


Sử dụng GPIO
===========

Hướng thiết lập
-----------------
Điều đầu tiên người lái xe phải làm với GPIO là xác định hướng đi của nó. Nếu không
cờ thiết lập hướng đã được cấp cho gpiod_get*(), việc này được thực hiện bởi
gọi một trong các hàm gpiod_direction_*() ::

int gpiod_direction_input(struct gpio_desc *desc)
	int gpiod_direction_output(struct gpio_desc *desc, giá trị int)

Giá trị trả về bằng 0 nếu thành công, nếu không thì là lỗi âm. Nó nên như vậy
đã kiểm tra, vì lệnh gọi get/set không trả về lỗi và do cấu hình sai
là có thể. Thông thường, bạn nên thực hiện các cuộc gọi này từ ngữ cảnh nhiệm vụ. Tuy nhiên,
đối với các GPIO an toàn với spinlock, bạn có thể sử dụng chúng trước khi tác vụ được bật, như một phần
thiết lập bảng sớm.

Đối với GPIO đầu ra, giá trị được cung cấp sẽ trở thành giá trị đầu ra ban đầu. Cái này
giúp tránh hiện tượng nhiễu tín hiệu trong quá trình khởi động hệ thống.

Trình điều khiển cũng có thể truy vấn hướng hiện tại của GPIO::

int gpiod_get_direction(const struct gpio_desc *desc)

Hàm này trả về 0 cho đầu ra, 1 cho đầu vào hoặc mã lỗi trong trường hợp có lỗi.

Xin lưu ý rằng không có hướng mặc định cho GPIO. Vì vậy, **sử dụng GPIO
không thiết lập hướng đi trước là bất hợp pháp và sẽ dẫn đến kết quả không xác định
hành vi!**


Truy cập GPIO an toàn Spinlock
-------------------------
Hầu hết các bộ điều khiển GPIO có thể được truy cập bằng hướng dẫn đọc/ghi bộ nhớ. Những cái đó
không cần phải ngủ và có thể được thực hiện một cách an toàn từ bên trong IRQ cứng (không có luồng)
trình xử lý và bối cảnh tương tự.

Sử dụng các lệnh gọi sau để truy cập GPIO từ ngữ cảnh nguyên tử ::

int gpiod_get_value(const struct gpio_desc *desc);
	void gpiod_set_value(struct gpio_desc *desc, giá trị int);

Các giá trị là boolean, 0 cho không hoạt động, khác 0 cho hoạt động. Khi đọc
giá trị của chân đầu ra, giá trị được trả về phải là giá trị nhìn thấy trên chân.
Giá trị đó không phải lúc nào cũng khớp với giá trị đầu ra được chỉ định do các vấn đề bao gồm
tín hiệu cống mở và độ trễ đầu ra.

Lệnh gọi get/set không trả về lỗi vì "GPIO không hợp lệ" lẽ ra phải là
được báo cáo trước đó từ gpiod_direction_*(). Tuy nhiên, lưu ý rằng không phải tất cả các nền tảng
có thể đọc giá trị của chân đầu ra; những cái không thể luôn luôn trả về số 0.
Ngoài ra, sử dụng các lệnh gọi này cho các GPIO không thể truy cập an toàn nếu không ngủ
(xem bên dưới) là một lỗi.


Truy cập GPIO có thể ngủ
--------------------------
Một số bộ điều khiển GPIO phải được truy cập bằng các bus dựa trên thông báo như I2C hoặc
SPI. Các lệnh để đọc hoặc ghi các giá trị GPIO đó yêu cầu phải chờ để truy cập
đầu hàng đợi để truyền lệnh và nhận phản hồi. Điều này đòi hỏi
đang ngủ, điều này không thể thực hiện được từ bên trong trình xử lý IRQ.

Các nền tảng hỗ trợ loại GPIO này phân biệt chúng với các GPIO khác bằng cách
trả về giá trị khác 0 từ lệnh gọi này::

int gpiod_cansleep(const struct gpio_desc *desc)

Để truy cập các GPIO như vậy, một bộ trình truy cập khác được xác định ::

int gpiod_get_value_cansleep(const struct gpio_desc *desc)
	void gpiod_set_value_cansleep(struct gpio_desc *desc, giá trị int)

Việc truy cập các GPIO như vậy yêu cầu một ngữ cảnh có thể ngủ, ví dụ như một luồng
Trình xử lý IRQ và các trình truy cập đó phải được sử dụng thay vì an toàn spinlock
các trình truy cập không có hậu tố tên cansleep().

Ngoài thực tế là những trình truy cập này có thể ở chế độ ngủ và sẽ hoạt động trên GPIO
không thể truy cập được từ trình xử lý hardIRQ, các cuộc gọi này hoạt động giống như
cuộc gọi an toàn spinlock.


.. _active_low_semantics:

Ngữ nghĩa cống thấp và mở đang hoạt động
---------------------------------------
Là người tiêu dùng không cần phải quan tâm đến cấp độ vật lý, tất cả
Các hàm gpiod_set_value_xxx() hoặc gpiod_set_array_value_xxx() hoạt động với
giá trị ZZ0000ZZ. Với điều này, họ tính đến thuộc tính hoạt động thấp.
Điều này có nghĩa là họ kiểm tra xem GPIO có được cấu hình ở mức hoạt động thấp hay không,
và nếu vậy, họ thao tác giá trị được truyền trước khi mức dòng vật lý được
điều khiển.

Điều tương tự cũng được áp dụng cho các đường dây đầu ra nguồn mở hoặc nguồn mở: những đường dây này không
chủ động điều khiển đầu ra của họ ở mức cao (cống mở) hoặc thấp (nguồn mở), họ chỉ
chuyển đầu ra của chúng sang giá trị trở kháng cao. Người tiêu dùng không cần phải
quan tâm. (Để biết chi tiết, hãy đọc về cống mở trong driver.rst.)

Với điều này, tất cả các hàm gpiod_set_(array)_value_xxx() đều diễn giải
tham số "giá trị" là "hoạt động" ("1") hoặc "không hoạt động" ("0"). Dòng vật lý
mức độ sẽ được định hướng tương ứng.

Ví dụ: nếu thuộc tính hoạt động mức thấp cho GPIO chuyên dụng được đặt và
gpiod_set_(array)_value_xxx() chuyển "active" ("1"), cấp độ dòng vật lý
sẽ bị đẩy xuống thấp.

Tóm lại::

Thuộc tính dòng hàm (ví dụ) dòng vật lý
  gpiod_set_raw_value(desc, 0);      đừng quan tâm
  gpiod_set_raw_value(desc, 1);      không quan tâm cao
  gpiod_set_value(desc, 0);          mặc định (hoạt động cao) thấp
  gpiod_set_value(desc, 1);          mặc định (hoạt động cao) cao
  gpiod_set_value(desc, 0);          hoạt động thấp cao
  gpiod_set_value(desc, 1);          hoạt động thấp thấp
  gpiod_set_value(desc, 0);          cống mở thấp
  gpiod_set_value(desc, 1);          cống mở trở kháng cao
  gpiod_set_value(desc, 0);          nguồn mở trở kháng cao
  gpiod_set_value(desc, 1);          mã nguồn mở cao

Có thể ghi đè các ngữ nghĩa này bằng cách sử dụng các hàm set_raw/get_raw
nhưng nên tránh càng nhiều càng tốt, đặc biệt là bởi các trình điều khiển bất khả tri về hệ thống
không cần quan tâm đến cấp độ vật lý thực tế và lo lắng về
thay vào đó là giá trị logic.


Truy cập các giá trị GPIO thô
-------------------------
Người tiêu dùng tồn tại cần quản lý trạng thái logic của dòng GPIO, tức là giá trị
thiết bị của họ sẽ thực sự nhận được, bất kể điều gì nằm giữa nó và GPIO
dòng.

Nhóm lệnh gọi sau đây bỏ qua thuộc tính cống đang hoạt động ở mức thấp hoặc mở của GPIO và
làm việc trên giá trị dòng thô::

int gpiod_get_raw_value(const struct gpio_desc *desc)
	void gpiod_set_raw_value(struct gpio_desc *desc, giá trị int)
	int gpiod_get_raw_value_cansleep(const struct gpio_desc *desc)
	void gpiod_set_raw_value_cansleep(struct gpio_desc *desc, giá trị int)
	int gpiod_direction_output_raw(struct gpio_desc *desc, giá trị int)

Trạng thái hoạt động thấp của GPIO cũng có thể được truy vấn và chuyển đổi bằng cách sử dụng
các cuộc gọi sau::

int gpiod_is_active_low(const struct gpio_desc *desc)
	void gpiod_toggle_active_low(struct gpio_desc *desc)

Lưu ý rằng chỉ nên sử dụng các chức năng này một cách có chừng mực; một người lái xe
không cần phải quan tâm đến mức độ vật lý hoặc ngữ nghĩa cống mở.


Truy cập nhiều GPIO bằng một lệnh gọi hàm duy nhất
-------------------------------------------------
Các hàm sau nhận hoặc đặt giá trị của một mảng GPIO::

int gpiod_get_array_value(unsigned int array_size,
				  cấu trúc gpio_desc **desc_array,
				  cấu trúc gpio_array *mảng_info,
				  dài không dấu *value_bitmap);
	int gpiod_get_raw_array_value(unsigned int array_size,
				      cấu trúc gpio_desc **desc_array,
				      cấu trúc gpio_array *mảng_info,
				      dài không dấu *value_bitmap);
	int gpiod_get_array_value_cansleep(unsign int array_size,
					   cấu trúc gpio_desc **desc_array,
					   cấu trúc gpio_array *mảng_info,
					   dài không dấu *value_bitmap);
	int gpiod_get_raw_array_value_cansleep(unsigned int array_size,
					   cấu trúc gpio_desc **desc_array,
					   cấu trúc gpio_array *mảng_info,
					   dài không dấu *value_bitmap);

int gpiod_set_array_value(unsigned int array_size,
				  cấu trúc gpio_desc **desc_array,
				  cấu trúc gpio_array *mảng_info,
				  dài không dấu *value_bitmap)
	int gpiod_set_raw_array_value(unsigned int array_size,
				      cấu trúc gpio_desc **desc_array,
				      cấu trúc gpio_array *mảng_info,
				      dài không dấu *value_bitmap)
	int gpiod_set_array_value_cansleep(unsign int array_size,
					   cấu trúc gpio_desc **desc_array,
					   cấu trúc gpio_array *mảng_info,
					   dài không dấu *value_bitmap)
	int gpiod_set_raw_array_value_cansleep(unsigned int array_size,
					       cấu trúc gpio_desc **desc_array,
					       cấu trúc gpio_array *mảng_info,
					       dài không dấu *value_bitmap)

Mảng có thể là một tập hợp GPIO tùy ý. Các chức năng sẽ cố gắng truy cập
GPIO thuộc cùng một ngân hàng hoặc chip đồng thời nếu được hỗ trợ bởi
trình điều khiển chip tương ứng. Trong trường hợp đó, hiệu suất được cải thiện đáng kể
có thể được mong đợi. Nếu không thể truy cập đồng thời thì GPIO sẽ
truy cập tuần tự.

Các hàm có bốn đối số:

* array_size - số phần tử mảng
	* desc_array - một mảng các bộ mô tả GPIO
	* array_info - thông tin tùy chọn thu được từ gpiod_get_array()
	* value_bitmap - một bitmap để lưu trữ các giá trị GPIO (get) hoặc
          một bitmap các giá trị để gán cho (bộ) GPIO

Mảng mô tả có thể được lấy bằng hàm gpiod_get_array()
hoặc một trong các biến thể của nó. Nếu nhóm mô tả được hàm đó trả về
phù hợp với nhóm GPIO mong muốn, những GPIO đó có thể được truy cập bằng cách sử dụng
cấu trúc gpio_descs được trả về bởi gpiod_get_array()::

struct gpio_descs *my_gpio_descs = gpiod_get_array(...);
	gpiod_set_array_value(my_gpio_descs->ndescs, my_gpio_descs->desc,
			      my_gpio_descs->thông tin, my_gpio_value_bitmap);

Cũng có thể truy cập một mảng mô tả hoàn toàn tùy ý. các
các bộ mô tả có thể thu được bằng cách sử dụng bất kỳ sự kết hợp nào của gpiod_get() và
gpiod_get_array(). Sau đó, mảng mô tả phải được thiết lập
theo cách thủ công trước khi nó có thể được chuyển đến một trong các chức năng trên.  Trong trường hợp đó,
array_info phải được đặt thành NULL.

Lưu ý rằng để có hiệu suất tối ưu, các GPIO thuộc cùng một chip phải được
tiếp giáp trong mảng mô tả.

Vẫn có thể đạt được hiệu suất tốt hơn nếu chỉ mục mảng của bộ mô tả
khớp với số chân phần cứng của một con chip.  Nếu một mảng được truyền tới get/set
hàm mảng khớp với hàm thu được từ gpiod_get_array() và array_info
liên kết với mảng cũng được truyền, hàm có thể lấy bitmap nhanh
đường dẫn xử lý, chuyển đối số value_bitmap trực tiếp tới đối số tương ứng
Lệnh gọi lại .get/set_multiple() của chip.  Điều đó cho phép sử dụng GPIO
ngân hàng dưới dạng cổng I/O dữ liệu mà không làm giảm hiệu suất nhiều.

Giá trị trả về của gpiod_get_array_value() và các biến thể của nó là 0 nếu thành công
hoặc tiêu cực do lỗi. Lưu ý sự khác biệt với gpiod_get_value(), kết quả trả về
0 hoặc 1 khi truyền thành công giá trị GPIO. Với các chức năng mảng, GPIO
các giá trị được lưu trữ trong value_array thay vì được trả về dưới dạng giá trị trả về.


GPIO được ánh xạ tới IRQ
--------------------
Các dòng GPIO thường có thể được sử dụng làm IRQ. Bạn có thể lấy số IRQ
tương ứng với GPIO nhất định bằng cách sử dụng lệnh gọi sau ::

int gpiod_to_irq(const struct gpio_desc *desc)

Nó sẽ trả về số IRQ hoặc mã âm nếu không thể ánh xạ
đã hoàn tất (rất có thể vì GPIO cụ thể đó không thể được sử dụng làm IRQ). Nó là một
lỗi không được kiểm tra khi sử dụng GPIO không được thiết lập làm đầu vào bằng cách sử dụng
gpiod_direction_input() hoặc sử dụng số IRQ mà ban đầu không có
từ gpiod_to_irq(). gpiod_to_irq() không được phép ngủ.

Các giá trị không có lỗi được trả về từ gpiod_to_irq() có thể được chuyển tới request_irq() hoặc
free_irq(). Chúng thường sẽ được lưu trữ vào tài nguyên IRQ cho các thiết bị nền tảng,
bởi mã khởi tạo dành riêng cho bảng. Lưu ý rằng các tùy chọn kích hoạt IRQ là
một phần của giao diện IRQ, ví dụ: IRQF_TRIGGER_FALLING, cũng như đánh thức hệ thống
khả năng.


GPIO và ACPI
==============

Trên các hệ thống ACPI, GPIO được mô tả bởi các tài nguyên GpioIo()/GpioInt() được liệt kê bởi
đối tượng cấu hình _CRS của thiết bị.  Những nguồn lực đó không cung cấp
ID (tên) kết nối cho GPIO nên cần sử dụng thêm
cơ chế cho mục đích này.

Các hệ thống tuân thủ ACPI 5.1 hoặc mới hơn có thể cung cấp đối tượng cấu hình _DSD
trong số những thứ khác, có thể được sử dụng để cung cấp ID kết nối cho các
GPIO được mô tả bởi tài nguyên GpioIo()/GpioInt() trong _CRS.  Nếu đó là
trường hợp này, nó sẽ được hệ thống con GPIO xử lý tự động.  Tuy nhiên, nếu
_DSD không có mặt, ánh xạ giữa tài nguyên GpioIo()/GpioInt() và GPIO
ID kết nối cần được cung cấp bởi trình điều khiển thiết bị.

Để biết chi tiết, hãy tham khảo Tài liệu/firmware-guide/acpi/gpio-properties.rst


Tương tác với hệ thống con GPIO kế thừa
==========================================
Nhiều hệ thống con và trình điều khiển kernel vẫn xử lý GPIO bằng cách sử dụng phiên bản cũ
giao diện dựa trên số nguyên. Chúng tôi thực sự khuyên bạn nên cập nhật những thứ này lên phiên bản mới
giao diện gpiod. Đối với trường hợp cần sử dụng cả hai giao diện, hãy làm như sau
hai hàm cho phép chuyển đổi bộ mô tả GPIO thành không gian tên số nguyên GPIO
và ngược lại::

int desc_to_gpio(const struct gpio_desc *desc)
	struct gpio_desc *gpio_to_desc(gpio không dấu)

Số GPIO được trả về bởi desc_to_gpio() có thể được sử dụng một cách an toàn làm tham số của
các chức năng gpio\_*() miễn là bộ mô tả GPIO ZZ0000ZZ không được giải phóng.
Tương tự như vậy, số GPIO được truyền tới gpio_to_desc() trước tiên phải chính xác
có được bằng cách sử dụng ví dụ: gpio_request_one() và bộ mô tả GPIO được trả về chỉ
được coi là hợp lệ cho đến khi số GPIO đó được phát hành bằng gpio_free().

Việc giải phóng GPIO thu được bởi một API bằng API khác đều bị cấm và một
lỗi không được kiểm tra.
