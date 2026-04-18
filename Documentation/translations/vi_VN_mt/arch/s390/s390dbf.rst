.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/arch/s390/s390dbf.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

====================
Tính năng gỡ lỗi S390
==================

tập tin:
      - Arch/s390/kernel/debug.c
      - Arch/s390/include/asm/debug.h

Sự miêu tả:
------------
Mục tiêu của tính năng này là cung cấp ghi nhật ký gỡ lỗi kernel API
nơi các bản ghi nhật ký có thể được lưu trữ hiệu quả trong bộ nhớ, nơi mỗi thành phần
(ví dụ: trình điều khiển thiết bị) có thể có một nhật ký gỡ lỗi riêng.
Một mục đích của việc này là kiểm tra nhật ký gỡ lỗi sau khi hệ thống sản xuất gặp sự cố
để phân tích nguyên nhân vụ tai nạn.

Nếu hệ thống vẫn chạy nhưng chỉ có một thành phần con sử dụng dbf bị lỗi,
có thể xem nhật ký gỡ lỗi trên hệ thống trực tiếp thông qua Linux
hệ thống tập tin debugfs.

Tính năng gỡ lỗi cũng có thể rất hữu ích cho việc phát triển kernel và trình điều khiển.

Thiết kế:
-------
Các thành phần hạt nhân (ví dụ: trình điều khiển thiết bị) có thể tự đăng ký khi gỡ lỗi
tính năng với chức năng gọi ZZ0000ZZ.
Hàm này khởi tạo một
nhật ký gỡ lỗi cho người gọi. Đối với mỗi nhật ký gỡ lỗi tồn tại một số khu vực gỡ lỗi
nơi chính xác một người đang hoạt động tại một thời điểm.  Mỗi khu vực gỡ lỗi bao gồm các khu vực liền kề
trang trong bộ nhớ. Trong khu vực gỡ lỗi có các mục gỡ lỗi được lưu trữ (bản ghi nhật ký)
được viết bởi các cuộc gọi sự kiện và ngoại lệ.

Một cuộc gọi sự kiện ghi mục gỡ lỗi đã chỉ định vào phần gỡ lỗi đang hoạt động
khu vực và cập nhật con trỏ nhật ký cho khu vực hoạt động. Nếu cuối cùng
của khu vực gỡ lỗi đang hoạt động, việc bao bọc được thực hiện (bộ đệm vòng)
và mục gỡ lỗi tiếp theo sẽ được viết ở đầu hoạt động
khu vực gỡ lỗi.

Một lệnh gọi ngoại lệ ghi mục gỡ lỗi đã chỉ định vào nhật ký và
chuyển sang khu vực gỡ lỗi tiếp theo. Điều này được thực hiện để chắc chắn
rằng các hồ sơ mô tả nguồn gốc của ngoại lệ không
được ghi đè khi xảy ra sự bao bọc xung quanh khu vực hiện tại.

Bản thân các khu vực gỡ lỗi cũng được sắp xếp dưới dạng bộ đệm vòng.
Khi một ngoại lệ được đưa ra trong vùng gỡ lỗi cuối cùng, phần gỡ lỗi sau
các mục sau đó được viết lại trong khu vực đầu tiên.

Có bốn phiên bản cho lệnh gọi sự kiện và ngoại lệ: Một cho
ghi dữ liệu thô, một cho văn bản, một cho số (không dấu int và long),
và một cho các chuỗi được định dạng giống như sprintf.

Mỗi mục gỡ lỗi chứa dữ liệu sau:

- Dấu thời gian
- Cpu-Số tác vụ gọi
- Mức độ nhập lỗi (0...6)
- Trả lại địa chỉ cho người gọi
- Gắn cờ nếu mục nhập có phải là ngoại lệ hay không

Nhật ký gỡ lỗi có thể được kiểm tra trong hệ thống trực tiếp thông qua các mục trong
hệ thống tập tin debugfs. Trong thư mục cấp cao nhất "ZZ0000ZZ" có
một thư mục cho mỗi thành phần đã đăng ký, được đặt tên giống như
thành phần tương ứng. Các debugf thường được gắn vào
ZZ0001ZZ do đó tính năng gỡ lỗi có thể được truy cập trong
ZZ0002ZZ.

Nội dung của các thư mục là các tệp đại diện cho các chế độ xem khác nhau
vào nhật ký gỡ lỗi. Mỗi thành phần có thể quyết định chế độ xem nào sẽ được
được sử dụng thông qua việc đăng ký chúng với chức năng ZZ0000ZZ.
Các chế độ xem được xác định trước cho dữ liệu hex/ascii và sprintf được cung cấp.
Cũng có thể xác định các quan điểm khác. Nội dung của
một khung nhìn có thể được kiểm tra đơn giản bằng cách đọc tệp debugfs tương ứng.

Tất cả nhật ký gỡ lỗi đều có mức gỡ lỗi thực tế (trong phạm vi từ 0 đến 6).
Mức mặc định là 3. Các hàm Sự kiện và Ngoại lệ có ZZ0000ZZ
tham số. Chỉ gỡ lỗi các mục có mức thấp hơn hoặc bằng
hơn mức thực tế được ghi vào nhật ký. Điều này có nghĩa là, khi
ghi sự kiện, các mục nhật ký có mức độ ưu tiên cao phải có mức độ thấp
giá trị trong khi các mục có mức độ ưu tiên thấp phải có giá trị cao.
Mức gỡ lỗi thực tế có thể được thay đổi với sự trợ giúp của hệ thống tệp debugfs
thông qua việc ghi một chuỗi số "x" vào tệp gỡ lỗi ZZ0001ZZ.
được cung cấp cho mọi nhật ký gỡ lỗi. Gỡ lỗi có thể được tắt hoàn toàn
bằng cách sử dụng "-" trên tệp gỡ lỗi ZZ0002ZZ.

Ví dụ::

> echo "-" > /sys/kernel/debug/s390dbf/dasd/level

Cũng có thể tắt tính năng gỡ lỗi trên toàn cầu cho mọi
nhật ký gỡ lỗi. Bạn có thể thay đổi hành vi bằng 2 tham số sysctl trong
ZZ0000ZZ:

Hiện tại có 2 trình kích hoạt có thể làm dừng tính năng gỡ lỗi
trên toàn cầu. Khả năng đầu tiên là sử dụng sysctl ZZ0000ZZ. Nếu
được đặt thành 1 thì tính năng gỡ lỗi đang chạy. Nếu ZZ0001ZZ được đặt thành 0 thì
tính năng gỡ lỗi bị tắt.

Trình kích hoạt thứ hai dừng tính năng gỡ lỗi là rất tiếc kernel.
Điều đó ngăn tính năng gỡ lỗi ghi đè thông tin gỡ lỗi
đã xảy ra trước khi rất tiếc. Sau một thời gian rất tiếc, bạn có thể kích hoạt lại tính năng gỡ lỗi
bằng đường ống 1 đến ZZ0000ZZ. Tuy nhiên, nó không phải
đề xuất sử dụng hạt nhân bị lỗi trong môi trường sản xuất.

Nếu bạn muốn không cho phép tắt tính năng gỡ lỗi, bạn có thể sử dụng
hệ thống ZZ0000ZZ. Nếu bạn đặt ZZ0001ZZ thành 0 thì quá trình gỡ lỗi
tính năng không thể dừng lại. Nếu tính năng gỡ lỗi đã bị dừng, nó
sẽ tiếp tục bị vô hiệu hóa.

Giao diện hạt nhân:
------------------

.. kernel-doc:: arch/s390/kernel/debug.c
.. kernel-doc:: arch/s390/include/asm/debug.h

Chế độ xem được xác định trước:
-----------------

.. code-block:: c

  extern struct debug_view debug_hex_ascii_view;

  extern struct debug_view debug_sprintf_view;

Ví dụ
--------

.. code-block:: c

  /*
   * hex_ascii-view Example
   */

  #include <linux/init.h>
  #include <asm/debug.h>

  static debug_info_t *debug_info;

  static int init(void)
  {
      /* register 4 debug areas with one page each and 4 byte data field */

      debug_info = debug_register("test", 1, 4, 4 );
      debug_register_view(debug_info, &debug_hex_ascii_view);

      debug_text_event(debug_info, 4 , "one ");
      debug_int_exception(debug_info, 4, 4711);
      debug_event(debug_info, 3, &debug_info, 4);

      return 0;
  }

  static void cleanup(void)
  {
      debug_unregister(debug_info);
  }

  module_init(init);
  module_exit(cleanup);

.. code-block:: c

  /*
   * sprintf-view Example
   */

  #include <linux/init.h>
  #include <asm/debug.h>

  static debug_info_t *debug_info;

  static int init(void)
  {
      /* register 4 debug areas with one page each and data field for */
      /* format string pointer + 2 varargs (= 3 * sizeof(long))       */

      debug_info = debug_register("test", 1, 4, sizeof(long) * 3);
      debug_register_view(debug_info, &debug_sprintf_view);

      debug_sprintf_event(debug_info, 2 , "first event in %s:%i\n",__FILE__,__LINE__);
      debug_sprintf_exception(debug_info, 1, "pointer to debug info: %p\n",&debug_info);

      return 0;
  }

  static void cleanup(void)
  {
      debug_unregister(debug_info);
  }

  module_init(init);
  module_exit(cleanup);

Giao diện gỡ lỗi
-----------------
Chế độ xem nhật ký gỡ lỗi có thể được điều tra thông qua việc đọc tương ứng
tập tin debugfs:

Ví dụ::

> ls /sys/kernel/debug/s390dbf/dasd
  xóa các trang cấp hex_ascii
  > cat /sys/kernel/debug/s390dbf/dasd/hex_ascii | sắp xếp -k2,2 -s
  00 00974733272:680099 2 - 02 0006ad7e 07 ea 4a 90 | ....
  00 00974733272:682210 2 - 02 0006ade6 46 52 45 45 | FREE
  00 00974733272:682213 2 - 02 0006adf6 07 ea 4a 90 | ....
  00 00974733272:682281 1 * 02 0006ab08 41 4c 4c 43 | EXCP
  01 00974733272:682284 2 - 02 0006ab16 45 43 4b 44 | ECKD
  01 00974733272:682287 2 - 02 0006ab28 00 00 00 04 | ....
  01 00974733272:682289 2 - 02 0006ab3e 00 00 00 20 | ...
  01 00974733272:682297 2 - 02 0006ad7e 07 ea 4a 90 | ....
  01 00974733272:684384 2 - 00 0006ade6 46 52 45 45 | FREE
  01 00974733272:684388 2 - 00 0006adf6 07 ea 4a 90 | ....

Xem phần về các chế độ xem được xác định trước để biết giải thích về kết quả đầu ra ở trên!

Thay đổi mức độ gỡ lỗi
------------------------

Ví dụ::


> cat /sys/kernel/debug/s390dbf/dasd/level
  3
  > echo "5" > /sys/kernel/debug/s390dbf/dasd/level
  > cat /sys/kernel/debug/s390dbf/dasd/level
  5

Xóa các khu vực gỡ lỗi
--------------------
Các khu vực gỡ lỗi có thể được xóa bằng đường ống theo số lượng mong muốn
vùng (0...n) vào tệp debugfs "tuôn ra". Khi sử dụng "-" tất cả các khu vực gỡ lỗi
đang đỏ bừng.

Ví dụ:

1. Xóa vùng gỡ lỗi 0::

> echo "0" > /sys/kernel/debug/s390dbf/dasd/flush

2. Xóa tất cả các khu vực gỡ lỗi::

> echo "-" > /sys/kernel/debug/s390dbf/dasd/flush

Thay đổi kích thước của khu vực gỡ lỗi
------------------------------------
Để thay đổi kích thước vùng gỡ lỗi, hãy ghi số trang mong muốn vào tệp "trang".
Dữ liệu hiện có được bảo tồn nếu phù hợp; nếu không, các mục cũ nhất sẽ bị loại bỏ.

Ví dụ:

Xác định 4 trang cho vùng gỡ lỗi của tính năng gỡ lỗi "dasd"::

> echo "4" > /sys/kernel/debug/s390dbf/dasd/pages

Dừng tính năng gỡ lỗi
--------------------------
Ví dụ:

1. Kiểm tra xem có được phép dừng hay không::

> mèo /proc/sys/s390dbf/debug_stoppable

2. Dừng tính năng gỡ lỗi::

> echo 0 > /proc/sys/s390dbf/debug_active

Giao diện sự cố
----------------
Công cụ ZZ0000ZZ kể từ v5.1.0 có lệnh tích hợp
ZZ0001ZZ để hiển thị tất cả nhật ký gỡ lỗi hoặc xuất chúng sang hệ thống tệp.
Với công cụ này có thể
để điều tra nhật ký gỡ lỗi trên hệ thống trực tiếp và kết xuất bộ nhớ sau
một sự cố hệ thống.

Điều tra bộ nhớ thô
------------------------
Một khả năng cuối cùng để điều tra nhật ký gỡ lỗi trực tiếp
hệ thống và sau khi hệ thống gặp sự cố là xem xét bộ nhớ thô
trong VM hoặc tại Phần tử dịch vụ.
Có thể tìm thấy điểm neo của nhật ký gỡ lỗi thông qua
biểu tượng ZZ0000ZZ trong bản đồ Hệ thống. Sau đó người ta có
để tuân theo các con trỏ chính xác của cấu trúc dữ liệu được xác định
trong debug.h và tìm vùng gỡ lỗi trong bộ nhớ.
Thông thường các mô-đun sử dụng tính năng gỡ lỗi cũng sẽ có
một biến toàn cục có con trỏ tới nhật ký gỡ lỗi. Đang theo dõi
con trỏ này cũng có thể tìm thấy nhật ký gỡ lỗi trong
trí nhớ.

Đối với phương pháp này, nên sử dụng byte '16 * x + 4' (x = 0..n)
về độ dài của trường dữ liệu trong ZZ0000ZZ trong
để xem các mục gỡ lỗi được định dạng tốt.


Chế độ xem được xác định trước
----------------

Có hai chế độ xem được xác định trước: hex_ascii và sprintf.
Chế độ xem hex_ascii hiển thị trường dữ liệu ở dạng biểu diễn hex và ascii
(ví dụ: ZZ0000ZZ).

Chế độ xem sprintf định dạng các mục gỡ lỗi theo cách tương tự như sprintf
chức năng sẽ làm. Các hàm sự kiện/ngoại lệ của sprintf ghi vào
gỡ lỗi nhập một con trỏ tới chuỗi định dạng (size = sizeof(long))
và với mỗi vararg một giá trị dài. Vì vậy, ví dụ. cho một mục gỡ lỗi có định dạng
chuỗi cộng với hai biến thể người ta sẽ cần phân bổ a (3 * sizeof(long))
vùng dữ liệu byte trong hàm debug_register().

IMPORTANT:
  Sử dụng "%s" trong các hàm sự kiện sprintf là nguy hiểm. Bạn chỉ có thể
  sử dụng "%s" trong các hàm sự kiện sprintf, nếu bộ nhớ cho chuỗi đã truyền
  có sẵn miễn là tính năng gỡ lỗi tồn tại. Lý do đằng sau điều này là
  do cân nhắc về hiệu suất nên chỉ có một con trỏ tới chuỗi được lưu trữ
  trong tính năng gỡ lỗi. Nếu bạn đăng nhập một chuỗi được giải phóng sau đó, bạn sẽ
  nhận được OOPS khi kiểm tra tính năng gỡ lỗi, vì khi đó tính năng gỡ lỗi
  sẽ truy cập vào bộ nhớ đã được giải phóng.

NOTE:
  Nếu sử dụng chế độ xem sprintf, NOT có sử dụng các chức năng sự kiện/ngoại lệ khác không
  hơn các hàm sprintf-event và -Exception.

Định dạng của chế độ xem hex_ascii và sprintf như sau:

- Số diện tích
- Dấu thời gian (được định dạng là giây và micro giây kể từ 00:00:00 Phối hợp
  Giờ thế giới (UTC), ngày 1 tháng 1 năm 1970)
- mức độ gỡ lỗi
- Cờ ngoại lệ (* = Ngoại lệ)
- Cpu-Số tác vụ gọi
- Trả lại địa chỉ cho người gọi
- trường dữ liệu

Một dòng điển hình của chế độ xem hex_ascii sẽ trông giống như sau (dòng đầu tiên
chỉ mang tính chất giải thích và sẽ không được hiển thị khi 'đánh giá' chế độ xem)::

dữ liệu người gọi cpu ngoại lệ cấp độ thời gian khu vực (hex + ascii)
  --------------------------------------------------------------------------
  00 00964419409:440690 1 - 00 88023fe


Xác định quan điểm
--------------

Chế độ xem được chỉ định bằng cấu trúc 'debug_view'. Có xác định
các hàm gọi lại được sử dụng để đọc và ghi các tệp debugfs:

.. code-block:: c

  struct debug_view {
	char name[DEBUG_MAX_PROCF_LEN];
	debug_prolog_proc_t* prolog_proc;
	debug_header_proc_t* header_proc;
	debug_format_proc_t* format_proc;
	debug_input_proc_t*  input_proc;
	void*                private_data;
  };

Ở đâu:

.. code-block:: c

  typedef int (debug_header_proc_t) (debug_info_t* id,
				     struct debug_view* view,
				     int area,
				     debug_entry_t* entry,
				     char* out_buf);

  typedef int (debug_format_proc_t) (debug_info_t* id,
				     struct debug_view* view, char* out_buf,
				     const char* in_buf);
  typedef int (debug_prolog_proc_t) (debug_info_t* id,
				     struct debug_view* view,
				     char* out_buf);
  typedef int (debug_input_proc_t) (debug_info_t* id,
				    struct debug_view* view,
				    struct file* file, const char* user_buf,
				    size_t in_buf_size, loff_t* offset);


Thành viên "private_data" có thể được sử dụng làm con trỏ để xem dữ liệu cụ thể.
Bản thân tính năng gỡ lỗi không sử dụng nó.

Đầu ra khi đọc tệp debugfs có cấu trúc như thế này ::

"đầu ra prolog_proc"

"đầu ra header_proc 1" "đầu ra format_proc 1"
  "đầu ra header_proc 2" "đầu ra format_proc 2"
  "đầu ra header_proc 3" "đầu ra format_proc 3"
  ...

Khi một khung nhìn được đọc từ các bản gỡ lỗi, Tính năng gỡ lỗi sẽ gọi
'prolog_proc' một lần để viết prolog.
Sau đó, 'header_proc' và 'format_proc' được gọi cho mỗi
mục gỡ lỗi hiện có.

input_proc có thể được sử dụng để triển khai chức năng khi nó được ghi vào
chế độ xem (ví dụ như với ZZ0000ZZ).

Đối với header_proc có thể sử dụng chức năng mặc định
ZZ0000ZZ được định nghĩa trong debug.h.
và tạo ra đầu ra tiêu đề giống như các chế độ xem được xác định trước.
Ví dụ::

00 00964419409:440761 2 - 00 88023ec

Để biết cách sử dụng các chức năng gọi lại, hãy kiểm tra việc triển khai
trong số các chế độ xem mặc định!

Ví dụ:

.. code-block:: c

  #include <asm/debug.h>

  #define UNKNOWNSTR "data: %08x"

  const char* messages[] =
  {"This error...........\n",
   "That error...........\n",
   "Problem..............\n",
   "Something went wrong.\n",
   "Everything ok........\n",
   NULL
  };

  static int debug_test_format_fn(
     debug_info_t *id, struct debug_view *view,
     char *out_buf, const char *in_buf
  )
  {
    int i, rc = 0;

    if (id->buf_size >= 4) {
       int msg_nr = *((int*)in_buf);
       if (msg_nr < sizeof(messages) / sizeof(char*) - 1)
	  rc += sprintf(out_buf, "%s", messages[msg_nr]);
       else
	  rc += sprintf(out_buf, UNKNOWNSTR, msg_nr);
    }
    return rc;
  }

  struct debug_view debug_test_view = {
    "myview",                 /* name of view */
    NULL,                     /* no prolog */
    &debug_dflt_header_fn,    /* default header for each entry */
    &debug_test_format_fn,    /* our own format function */
    NULL,                     /* no input function */
    NULL                      /* no private data */
  };

Bài kiểm tra:
=====

.. code-block:: c

  debug_info_t *debug_info;
  int i;
  ...
  debug_info = debug_register("test", 0, 4, 4);
  debug_register_view(debug_info, &debug_test_view);
  for (i = 0; i < 10; i ++)
    debug_int_event(debug_info, 1, i);

::

> mèo /sys/kernel/debug/s390dbf/test/myview
  00 00964419734:611402 1 - 00 88042ca Lỗi này............
  00 00964419734:611405 1 - 00 88042ca Lỗi đó............
  00 00964419734:611408 1 - 00 88042ca Vấn đề............
  00 00964419734:611411 1 - 00 88042ca Đã xảy ra lỗi.
  00 00964419734:611414 1 - 00 88042ca Mọi thứ đều ổn........
  00 00964419734:611417 1 - 00 88042ca dữ liệu: 00000005
  00 00964419734:611419 1 - 00 88042ca dữ liệu: 00000006
  00 00964419734:611422 1 - 00 88042ca dữ liệu: 00000007
  00 00964419734:611425 1 - 00 88042ca dữ liệu: 00000008
  00 00964419734:611428 1 - 00 88042ca dữ liệu: 00000009
