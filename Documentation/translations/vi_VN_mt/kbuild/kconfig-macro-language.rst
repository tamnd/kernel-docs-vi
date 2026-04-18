.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/kbuild/kconfig-macro-language.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

========================
Ngôn ngữ macro Kconfig
======================

Ý tưởng
-------

Ý tưởng cơ bản được lấy cảm hứng từ Make. Khi chúng tôi nhìn vào Make, chúng tôi nhận thấy loại
hai ngôn ngữ trong một. Một ngôn ngữ mô tả các biểu đồ phụ thuộc bao gồm
mục tiêu và điều kiện tiên quyết. Ngôn ngữ còn lại là ngôn ngữ macro để thực hiện văn bản
sự thay thế.

Có sự phân biệt rõ ràng giữa hai giai đoạn ngôn ngữ. Ví dụ, bạn
có thể viết một makefile như sau::

APP := foo
    SRC := foo.c
    CC := gcc

$(APP): $(SRC)
            $(CC) -o $(APP) $(SRC)

Ngôn ngữ macro thay thế các tham chiếu biến bằng dạng mở rộng của chúng,
và xử lý như thể tệp nguồn được nhập như sau ::

foo: foo.c
            gcc -o foo foo.c

Sau đó, Make phân tích biểu đồ phụ thuộc và xác định các mục tiêu cần đạt được
được cập nhật.

Ý tưởng khá giống trong Kconfig - có thể mô tả một Kconfig
tập tin như thế này::

CC := gcc

cấu hình CC_HAS_FOO
            def_bool $(shell, $(srctree)/scripts/gcc-check-foo.sh $(CC))

Ngôn ngữ macro trong Kconfig xử lý tệp nguồn thành như sau
trung gian::

cấu hình CC_HAS_FOO
            def_bool y

Sau đó, Kconfig chuyển sang giai đoạn đánh giá để giải quyết vấn đề liên ký hiệu
sự phụ thuộc như được giải thích trong kconfig-lingu.rst.


Biến
---------

Giống như trong Make, một biến trong Kconfig hoạt động như một biến macro.  Một vĩ mô
biến được mở rộng "tại chỗ" để tạo ra một chuỗi văn bản mà sau đó có thể
được mở rộng hơn nữa. Để lấy giá trị của một biến, hãy đặt tên biến vào
$( ). Dấu ngoặc đơn được yêu cầu ngay cả đối với tên biến có một chữ cái; $X là
một lỗi cú pháp. Dạng dấu ngoặc nhọn như trong ${CC} cũng không được hỗ trợ.

Có hai loại biến: biến đơn giản mở rộng và biến đệ quy
các biến mở rộng

Một biến mở rộng đơn giản được xác định bằng toán tử gán :=. của nó
phía bên phải được mở rộng ngay lập tức khi đọc dòng từ Kconfig
tập tin.

Một biến mở rộng đệ quy được xác định bằng toán tử gán =.
Vế phải của nó được lưu đơn giản dưới dạng giá trị của biến mà không cần
mở rộng nó theo bất kỳ cách nào. Thay vào đó, việc mở rộng được thực hiện khi biến
được sử dụng.

Có một loại toán tử gán khác; += được sử dụng để nối văn bản vào một
biến. Vế phải của += được mở rộng ngay lập tức nếu vế trái
side ban đầu được định nghĩa là một biến đơn giản. Mặt khác, đánh giá của nó là
hoãn lại.

Tham chiếu biến có thể lấy các tham số, ở dạng sau::

$(tên,arg1,arg2,arg3)

Bạn có thể coi tham chiếu được tham số hóa như một hàm. (chính xác hơn là
"hàm do người dùng xác định" trái ngược với "hàm tích hợp" được liệt kê bên dưới).

Các chức năng hữu ích phải được mở rộng khi chúng được sử dụng vì chức năng tương tự
được mở rộng khác nhau nếu các tham số khác nhau được truyền. Do đó, một người dùng định nghĩa
hàm được xác định bằng toán tử gán =. Các thông số là
được tham chiếu trong định nghĩa phần thân với $(1), $(2), v.v.

Trong thực tế, các biến mở rộng đệ quy và các hàm do người dùng định nghĩa đều giống nhau
nội bộ. (Nói cách khác, "biến" là "hàm có đối số bằng 0".)
Khi chúng ta nói "biến" theo nghĩa rộng, nó bao gồm "hàm do người dùng xác định".


Các chức năng tích hợp
------------------

Giống như Make, Kconfig cung cấp một số chức năng tích hợp sẵn. Mỗi chức năng đều có một
số lượng đối số cụ thể.

Trong Make, mọi hàm dựng sẵn đều có ít nhất một đối số. Kconfig cho phép
đối số bằng 0 cho các hàm dựng sẵn, chẳng hạn như $(filename), $(lineno). Bạn có thể
coi chúng là "biến tích hợp", nhưng đó chỉ là vấn đề cách chúng ta gọi
rốt cuộc thì nó. Giả sử "chức năng tích hợp" ở đây để chỉ được hỗ trợ nguyên bản
chức năng.

Kconfig hiện hỗ trợ các chức năng tích hợp sau.

- $(vỏ, lệnh)

Hàm "shell" chấp nhận một đối số duy nhất được mở rộng và truyền
  vào một shell con để thực thi. Đầu ra tiêu chuẩn của lệnh sau đó được đọc
  và trả về dưới dạng giá trị của hàm. Mỗi dòng mới trong đầu ra là
  được thay thế bằng một khoảng trắng. Mọi dòng mới ở cuối sẽ bị xóa. Lỗi tiêu chuẩn
  không được trả về cũng như không có bất kỳ trạng thái thoát chương trình nào.

- $(thông tin, văn bản)

Hàm "thông tin" lấy một đối số duy nhất và in nó ra thiết bị xuất chuẩn.
  Nó đánh giá thành một chuỗi trống.

- $(cảnh báo-nếu,điều kiện,văn bản)

Hàm "cảnh báo-nếu" nhận hai đối số. Nếu phần điều kiện là "y",
  phần văn bản được gửi tới stderr. Văn bản được đặt trước tên của
  tập tin Kconfig hiện tại và số dòng hiện tại.

- $(lỗi-nếu,điều kiện,văn bản)

Chức năng "error-if" tương tự như "warning-if", nhưng nó kết thúc quá trình
  phân tích cú pháp ngay lập tức nếu phần điều kiện là "y".

- $(tên tệp)

'Tên tệp' không có đối số và $(filename) được mở rộng thành tệp
  tên đang được phân tích cú pháp.

- $(lineno)

'lineno' không có đối số và $(lineno) được mở rộng thành số dòng
  đang được phân tích cú pháp.


Tạo vs Kconfig
---------------

Kconfig sử dụng ngôn ngữ macro Make-like, nhưng cú pháp gọi hàm là
hơi khác một chút.

Lệnh gọi hàm trong Make trông như thế này::

$(tên func arg1,arg2,arg3)

Tên hàm và đối số đầu tiên cách nhau ít nhất một
khoảng trắng. Sau đó, các khoảng trắng ở đầu được cắt bớt khỏi đối số đầu tiên,
trong khi các khoảng trắng trong các đối số khác được giữ nguyên. Bạn cần sử dụng một loại
mẹo để bắt đầu tham số đầu tiên bằng dấu cách. Ví dụ, nếu bạn muốn
để tạo chức năng "thông tin" in "xin chào", bạn có thể viết như sau ::

trống rỗng :=
  dấu cách := $(trống) $(trống)
  $(thông tin $(dấu cách)$(dấu cách)xin chào)

Kconfig chỉ sử dụng dấu phẩy cho dấu phân cách và giữ tất cả khoảng trắng trong
lời gọi hàm. Một số người thích đặt dấu cách sau mỗi dấu phân cách bằng dấu phẩy::

$(tên func, arg1, arg2, arg3)

Trong trường hợp này, "func-name" sẽ nhận được " arg1", " arg2", " arg3". Sự hiện diện
số khoảng trống ở đầu có thể quan trọng tùy thuộc vào chức năng. Điều tương tự cũng áp dụng cho
Thực hiện - ví dụ: $(subst .c, .o, $(sources)) là một lỗi điển hình; nó
thay thế ".c" bằng ".o".

Trong Make, hàm do người dùng xác định được tham chiếu bằng cách sử dụng hàm tích hợp,
'gọi', như thế này::

$(gọi my-func,arg1,arg2,arg3)

Kconfig gọi các hàm do người dùng định nghĩa và các hàm dựng sẵn theo cách tương tự.
Việc bỏ qua 'cuộc gọi' làm cho cú pháp ngắn hơn.

Trong Make, một số hàm xử lý nguyên văn dấu phẩy thay vì dấu phân cách đối số.
Ví dụ: $(shell echo hello, world) chạy lệnh "echo hello, world".
Tương tự, $(info hello, world) in "hello, world" ra thiết bị xuất chuẩn. Bạn có thể nói
đây là sự không nhất quán _hữu ích_.

Trong Kconfig, để triển khai đơn giản hơn và thống nhất về mặt ngữ pháp, hãy dùng dấu phẩy
xuất hiện trong ngữ cảnh $( ) luôn là dấu phân cách. Nó có nghĩa là::

$(shell, echo xin chào, thế giới)

là một lỗi vì nó đang truyền hai tham số trong đó hàm 'shell'
chỉ chấp nhận một. Để chuyển dấu phẩy trong đối số, bạn có thể sử dụng thủ thuật sau ::

dấu phẩy := ,
  $(shell, echo hello$(dấu phẩy) thế giới)


Hãy cẩn thận
-------

Không thể mở rộng một biến (hoặc hàm) trên các mã thông báo. Vì vậy, bạn không thể sử dụng
một biến làm cách viết tắt của một biểu thức bao gồm nhiều mã thông báo.
Các công việc sau::

RANGE_MIN := 1
    RANGE_MAX := 3

cấu hình FOO
            int "foo"
            phạm vi $(RANGE_MIN) $(RANGE_MAX)

Tuy nhiên, những điều sau đây không hoạt động ::

RANGES := 1 3

cấu hình FOO
            int "foo"
            phạm vi $(RANGES)

Một biến không thể được mở rộng thành bất kỳ từ khóa nào trong Kconfig.  Sau đây không
không hoạt động::

MY_TYPE := tristate

cấu hình FOO
            $(MY_TYPE) "foo"
            mặc định y

Rõ ràng từ thiết kế, $(shell command) được mở rộng trong văn bản
giai đoạn thay thế Bạn không thể chuyển ký hiệu cho hàm 'shell'.

Phần sau không hoạt động như mong đợi::

cấu hình ENDIAN_FLAG
            chuỗi
            mặc định "-mbig-endian" nếu CPU_BIG_ENDIAN
            mặc định "-mlittle-endian" nếu CPU_LITTLE_ENDIAN

cấu hình CC_HAS_ENDIAN_FLAG
            def_bool $(shell $(srctree)/scripts/gcc-check-flag ENDIAN_FLAG)

Thay vào đó, bạn có thể thực hiện như sau để mọi lệnh gọi hàm đều ở trạng thái tĩnh
mở rộng::

cấu hình CC_HAS_ENDIAN_FLAG
            bool
            mặc định $(shell $(srctree)/scripts/gcc-check-flag -mbig-endian) nếu CPU_BIG_ENDIAN
            mặc định $(shell $(srctree)/scripts/gcc-check-flag -mlittle-endian) nếu CPU_LITTLE_ENDIAN
