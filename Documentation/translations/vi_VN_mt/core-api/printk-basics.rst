.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/core-api/printk-basics.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

==============================
Ghi nhật ký tin nhắn bằng printk
===========================

printk() là một trong những hàm được biết đến rộng rãi nhất trong nhân Linux. Đó là
công cụ tiêu chuẩn mà chúng tôi có để in tin nhắn và thường là cách cơ bản nhất để
truy tìm và gỡ lỗi. Nếu bạn quen thuộc với printf(3), bạn có thể nói với printk()
dựa trên nó, mặc dù nó có một số khác biệt về chức năng:

- thông báo printk() có thể chỉ định cấp độ nhật ký.

- chuỗi định dạng, mặc dù phần lớn tương thích với C99, nhưng không tuân theo
    chính xác cùng một đặc điểm kỹ thuật. Nó có một số phần mở rộng và một số hạn chế
    (không có ZZ0001ZZ hoặc công cụ xác định chuyển đổi dấu phẩy động). Xem ZZ0000ZZ.

Tất cả các thông báo printk() được in vào bộ đệm nhật ký kernel, đó là một vòng
bộ đệm được xuất sang không gian người dùng thông qua /dev/kmsg. Cách đọc thông thường là
sử dụng ZZ0000ZZ.

printk() thường được sử dụng như thế này::

printk(KERN_INFO "Thông báo: %s\n", arg);

trong đó ZZ0000ZZ là cấp độ nhật ký (lưu ý rằng nó được nối với định dạng
chuỗi, cấp độ nhật ký không phải là một đối số riêng biệt). Các cấp độ nhật ký có sẵn là:

++---------------+--------------------------------------------------------+
Dây ZZ0000ZZ ZZ0001ZZ
+=================+=============================================================================================
ZZ0002ZZ "0" ZZ0003ZZ
++---------------+--------------------------------------------------------+
ZZ0004ZZ "1" ZZ0005ZZ
++---------------+--------------------------------------------------------+
ZZ0006ZZ "2" ZZ0007ZZ
++---------------+--------------------------------------------------------+
ZZ0008ZZ "3" ZZ0009ZZ
++---------------+--------------------------------------------------------+
ZZ0010ZZ "4" ZZ0011ZZ
++---------------+--------------------------------------------------------+
ZZ0012ZZ "5" ZZ0013ZZ
++---------------+--------------------------------------------------------+
ZZ0014ZZ "6" ZZ0015ZZ
++---------------+--------------------------------------------------------+
ZZ0016ZZ "7" ZZ0017ZZ
++---------------+--------------------------------------------------------+
ZZ0018ZZ "" ZZ0019ZZ
++---------------+--------------------------------------------------------+
ZZ0020ZZ "c" ZZ0021ZZ
++---------------+--------------------------------------------------------+


Cấp độ nhật ký chỉ định tầm quan trọng của tin nhắn. Hạt nhân quyết định liệu
để hiển thị thông báo ngay lập tức (in nó ra bảng điều khiển hiện tại) tùy thuộc vào
ở cấp độ nhật ký của nó và ZZ0000ZZ hiện tại (một biến kernel). Nếu
mức độ ưu tiên của tin nhắn cao hơn (giá trị mức nhật ký thấp hơn) so với ZZ0001ZZ
tin nhắn sẽ được in ra bàn điều khiển.

Nếu mức nhật ký bị bỏ qua, thông báo sẽ được in bằng ZZ0000ZZ
cấp độ.

Bạn có thể kiểm tra ZZ0000ZZ hiện tại bằng::

$ cat /proc/sys/kernel/printk
  4 4 1 7

Kết quả hiển thị nhật ký ZZ0000ZZ, ZZ0001ZZ, ZZ0002ZZ và ZZ0003ZZ
cấp độ.

Để thay đổi console_loglevel hiện tại, chỉ cần viết mức mong muốn vào
ZZ0000ZZ. Ví dụ: để in tất cả tin nhắn ra bàn điều khiển ::

# echo 8 > /proc/sys/kernel/printk

Một cách khác, sử dụng ZZ0000ZZ::

# dmesg-n 5

đặt console_loglevel để in các thông báo KERN_WARNING (4) hoặc nghiêm trọng hơn tới
bảng điều khiển. Xem ZZ0000ZZ để biết thêm thông tin.

Để thay thế cho printk() bạn có thể sử dụng bí danh ZZ0000ZZ cho
khai thác gỗ. Họ macro này nhúng cấp độ nhật ký vào tên macro. Ví dụ::

pr_info("Thông tin tin nhắn số %d\n", msg_num);

in thông báo ZZ0000ZZ.

Bên cạnh việc ngắn gọn hơn các lệnh gọi printk() tương đương, chúng có thể sử dụng một
định nghĩa chung cho chuỗi định dạng thông qua macro pr_fmt(). cho
chẳng hạn, xác định điều này ở đầu tệp nguồn (trước bất kỳ ZZ0000ZZ nào
chỉ thị)::

#define pr_fmt(fmt) "%s:%s: " fmt, KBUILD_MODNAME, __func__

sẽ thêm tiền tố vào mỗi thông báo pr_*() trong tệp đó với tên mô-đun và hàm
đó là nguồn gốc của tin nhắn.

Đối với mục đích gỡ lỗi, cũng có hai macro được biên dịch có điều kiện:
pr_debug() và pr_devel(), được biên dịch ra trừ khi ZZ0000ZZ (hoặc
ZZ0001ZZ trong trường hợp pr_debug()) cũng được xác định.

Tránh bị khóa do sử dụng quá nhiều printk()
============================================

.. note::

   This section is relevant only for legacy console drivers (those not
   using the nbcon API) and !PREEMPT_RT kernels. Once all console drivers
   are updated to nbcon, this documentation can be removed.

Sử dụng ZZ0000ZZ trong các đường dẫn nóng (như bộ xử lý ngắt, bộ đếm thời gian
cuộc gọi lại hoặc mạng tần số cao nhận các thói quen) với kế thừa
bảng điều khiển (ví dụ: ZZ0001ZZ) có thể gây ra tình trạng khóa. Bảng điều khiển kế thừa
thu thập đồng bộ ZZ0002ZZ và chặn trong khi xóa tin nhắn,
có khả năng vô hiệu hóa các ngắt đủ lâu để kích hoạt cứng hoặc mềm
máy dò khóa.

Để tránh điều này:

- Sử dụng các biến thể có giới hạn tỷ lệ (ví dụ: ZZ0000ZZ) hoặc một lần
  macro (ví dụ: ZZ0001ZZ) để giảm tần suất tin nhắn.
- Chỉ định mức nhật ký thấp hơn (ví dụ: ZZ0002ZZ) cho các tin nhắn không cần thiết
  và lọc đầu ra của bảng điều khiển thông qua ZZ0003ZZ.
- Sử dụng ZZ0004ZZ để ghi tin nhắn ngay vào bộ đệm chuông
  và trì hoãn việc in bảng điều khiển. Đây là giải pháp thay thế cho bảng điều khiển cũ.
- Chuyển trình điều khiển bảng điều khiển kế thừa sang ZZ0005ZZ API không chặn (được chỉ định
  bởi ZZ0006ZZ). Đây là giải pháp ưa thích, vì bảng điều khiển nbcon
  giảm tải việc in thông báo sang một luồng hạt nhân chuyên dụng.

Để gỡ lỗi tạm thời, có thể sử dụng ZZ0000ZZ, nhưng không được
xuất hiện trong mã dòng chính. Xem ZZ0001ZZ để biết
thêm thông tin.

Nếu cần đầu ra lâu dài hơn trong đường dẫn nóng, có thể sử dụng các sự kiện theo dõi.
Xem ZZ0000ZZ và
ZZ0001ZZ.


Tham khảo chức năng
==================

.. kernel-doc:: include/linux/printk.h
   :functions: printk pr_emerg pr_alert pr_crit pr_err pr_warn pr_notice pr_info
      pr_fmt pr_debug pr_devel pr_cont