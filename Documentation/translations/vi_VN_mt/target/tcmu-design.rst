.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/target/tcmu-design.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

==================================
Thiết kế không gian người dùng TCM
==================================


.. Contents:

   1) Design
     a) Background
     b) Benefits
     c) Design constraints
     d) Implementation overview
        i. Mailbox
        ii. Command ring
        iii. Data Area
     e) Device discovery
     f) Device events
     g) Other contingencies
   2) Writing a user pass-through handler
     a) Discovering and configuring TCMU uio devices
     b) Waiting for events on the device(s)
     c) Managing the command ring
   3) A final note


Thiết kế
========

TCM là tên gọi khác của LIO, mục tiêu (máy chủ) iSCSI trong kernel.
Các mục tiêu TCM hiện có chạy trong kernel.  TCMU (TCM trong không gian người dùng)
cho phép các chương trình không gian người dùng được viết hoạt động như mục tiêu iSCSI.
Tài liệu này mô tả thiết kế.

Hạt nhân hiện có cung cấp các mô-đun cho việc vận chuyển SCSI khác nhau
giao thức.  TCM cũng mô-đun hóa việc lưu trữ dữ liệu.  Hiện có
mô-đun cho tập tin, khối thiết bị, RAM hoặc sử dụng thiết bị SCSI khác làm
lưu trữ.  Chúng được gọi là "cửa sau" hoặc "công cụ lưu trữ".  Những cái này
các mô-đun tích hợp được triển khai hoàn toàn dưới dạng mã hạt nhân.

Lý lịch
----------

Ngoài việc mô-đun hóa giao thức truyền tải được sử dụng để mang
Các lệnh SCSI ("fabrics"), mục tiêu nhân Linux, LIO, cũng mô-đun hóa
việc lưu trữ dữ liệu thực tế là tốt. Chúng được gọi là "backstore"
hoặc "động cơ lưu trữ". Mục tiêu đi kèm với các cửa hàng ngược cho phép
tập tin, một thiết bị khối, RAM hoặc một thiết bị SCSI khác sẽ được sử dụng cho
bộ nhớ cục bộ cần thiết cho SCSI LUN đã xuất. Giống như phần còn lại của LIO,
chúng được triển khai hoàn toàn dưới dạng mã hạt nhân.

Những backstore này bao gồm các trường hợp sử dụng phổ biến nhất, nhưng không phải tất cả. Một cái mới
trường hợp sử dụng mà các giải pháp mục tiêu phi hạt nhân khác, chẳng hạn như tgt, có thể
để hỗ trợ đang sử dụng GLFS của Gluster hoặc RBD của Ceph làm kho lưu trữ. các
mục tiêu sau đó đóng vai trò là người dịch, cho phép người khởi tạo lưu trữ dữ liệu
trong các hệ thống lưu trữ nối mạng phi truyền thống này, trong khi vẫn chỉ
sử dụng chính các giao thức chuẩn.

Nếu mục tiêu là một quy trình không gian người dùng, việc hỗ trợ những quy trình này thật dễ dàng. tgt,
ví dụ: chỉ cần một mô-đun bộ điều hợp nhỏ cho mỗi mô-đun, bởi vì
các mô-đun chỉ sử dụng thư viện không gian người dùng có sẵn cho RBD và GLFS.

Việc thêm hỗ trợ cho các kho lưu trữ này trong LIO sẽ hiệu quả hơn đáng kể
khó khăn, vì LIO hoàn toàn là mã hạt nhân. Thay vì đảm nhận
công việc quan trọng là chuyển các API và giao thức GLFS hoặc RBD sang
kernel, một cách tiếp cận khác là tạo một đường truyền qua không gian người dùng
kho ngược cho LIO, "TCMU".


Những lợi ích
-------------

Ngoài việc cho phép hỗ trợ tương đối dễ dàng cho RBD và GLFS, TCMU
cũng sẽ cho phép phát triển các cửa hàng mới dễ dàng hơn. TCMU kết hợp
với vải loopback LIO để trở thành một thứ tương tự như FUSE
(Hệ thống tệp trong Không gian người dùng), nhưng ở lớp SCSI thay vì
lớp hệ thống tập tin. Một chiếc SUSE, nếu bạn muốn.

Điểm bất lợi là có nhiều thành phần riêng biệt hơn để cấu hình và
có khả năng gặp trục trặc. Điều này là không thể tránh khỏi, nhưng hy vọng là không
gây tử vong nếu chúng ta cẩn thận giữ mọi thứ đơn giản nhất có thể.

Hạn chế thiết kế
------------------

- Hiệu suất tốt: thông lượng cao, độ trễ thấp
- Xử lý rõ ràng nếu không gian người dùng:

1) không bao giờ gắn bó
   2) bị treo
   3) chết
   4) cư xử sai trái

- Cho phép sự linh hoạt trong tương lai trong việc triển khai người dùng và kernel
- Sử dụng bộ nhớ hợp lý
- Cấu hình và chạy đơn giản
- Đơn giản để viết phần phụ trợ không gian người dùng


Tổng quan triển khai
-----------------------

Cốt lõi của giao diện TCMU là vùng bộ nhớ được chia sẻ
giữa kernel và không gian người dùng. Trong khu vực này là: khu vực kiểm soát
(hộp thư); bộ đệm tròn của nhà sản xuất/người tiêu dùng không khóa cho các lệnh
được chuyển giao và trạng thái được trả lại; và vùng đệm dữ liệu vào/ra.

TCMU sử dụng hệ thống con UIO có sẵn. UIO cho phép trình điều khiển thiết bị
phát triển trong không gian người dùng và về mặt khái niệm, điều này rất gần với
Trường hợp sử dụng TCMU, ngoại trừ thay vì một thiết bị vật lý, TCMU thực hiện một
bố cục ánh xạ bộ nhớ được thiết kế cho các lệnh SCSI. Cũng đang sử dụng UIO
mang lại lợi ích cho TCMU bằng cách xử lý việc xem xét nội tâm của thiết bị (ví dụ: một cách để
không gian người dùng để xác định vùng được chia sẻ lớn đến mức nào) và báo hiệu
cơ chế theo cả hai hướng.

Không có con trỏ nhúng trong vùng bộ nhớ. Mọi thứ đều
được biểu thị dưới dạng phần bù từ địa chỉ bắt đầu của vùng. Điều này cho phép
vòng vẫn hoạt động nếu quá trình người dùng chết và được khởi động lại với
vùng được ánh xạ tại một địa chỉ ảo khác.

Xem target_core_user.h để biết định nghĩa cấu trúc.

Hộp thư
-----------

Hộp thư luôn ở đầu vùng bộ nhớ dùng chung và
chứa một phiên bản, chi tiết về phần bù bắt đầu và kích thước của
vòng lệnh, các con trỏ đầu và đuôi được hạt nhân sử dụng và
không gian người dùng (tương ứng) để đặt lệnh trên vòng và cho biết
khi các lệnh được hoàn thành.

phiên bản - 1 (không gian người dùng nên hủy bỏ nếu không)

cờ:
    -TCMU_MAILBOX_FLAG_CAP_OOOC:
	cho biết việc hoàn thành không theo thứ tự được hỗ trợ.
	Xem "Vòng lệnh" để biết chi tiết.

cmdr_off
	Độ lệch của điểm bắt đầu vòng lệnh so với điểm bắt đầu
	của vùng bộ nhớ để tính đến kích thước hộp thư.
cmdr_size
	Kích thước của vòng lệnh. Điều này có nghĩa là ZZ0000ZZ phải là một
	sức mạnh của hai.
cmd_head
	Được sửa đổi bởi kernel để cho biết khi nào một lệnh được thực hiện
	đặt trên chiếc nhẫn.
đuôi cmd
	Được sửa đổi bởi không gian người dùng để cho biết khi nào nó đã hoàn thành
	xử lý một lệnh.

Vòng lệnh
----------------

Các lệnh được đặt trên vòng bằng cách tăng dần kernel
hộp thư.cmd_head theo kích thước của lệnh, modulo cmdr_size và
sau đó báo hiệu không gian người dùng thông qua uio_event_notify(). Một khi lệnh được
hoàn tất, không gian người dùng cập nhật hộp thư.cmd_tail theo cách tương tự và
báo hiệu cho kernel thông qua lệnh ghi 4 byte(). Khi cmd_head bằng
cmd_tail, vòng trống -- hiện không có lệnh nào đang chờ
được xử lý bởi không gian người dùng.

Các lệnh TCMU được căn chỉnh 8 byte. Họ bắt đầu bằng một tiêu đề chung
chứa "len_op", giá trị 32 bit lưu trữ độ dài, cũng như
opcode ở các bit chưa được sử dụng thấp nhất. Nó cũng chứa cmd_id và
các trường cờ để cài đặt theo kernel (kflags) và không gian người dùng
(uflag).

Hiện tại chỉ có hai opcode được xác định là TCMU_OP_CMD và TCMU_OP_PAD.

Khi mã hoạt động là CMD, mục nhập trong vòng lệnh là một cấu trúc
tcmu_cmd_entry. Không gian người dùng tìm thấy SCSI CDB (Khối dữ liệu lệnh) thông qua
tcmu_cmd_entry.req.cdb_off. Đây là khoản bù đắp từ đầu
vùng bộ nhớ chia sẻ tổng thể, không phải mục nhập. Bộ đệm vào/ra dữ liệu
có thể truy cập được thông qua mảng req.iov[] . iov_cnt chứa số lượng
các mục trong iov[] cần để mô tả Dữ liệu vào hoặc Dữ liệu ra
bộ đệm. Đối với các lệnh hai chiều, iov_cnt chỉ định số lượng iovec
các mục nhập bao gồm khu vực Dữ liệu ra và iov_bidi_cnt chỉ định số lượng
các mục iovec ngay sau đó trong iov[] bao gồm Data-In
khu vực. Cũng giống như các trường khác, iov.iov_base là phần bù ngay từ đầu
của khu vực.

Khi hoàn thành một lệnh, không gian người dùng sẽ đặt rsp.scsi_status và
rsp.sense_buffer nếu cần thiết. Không gian người dùng sau đó tăng lên
hòm thư.cmd_tail bằng entry.hdr.length (mod cmdr_size) và báo hiệu
kernel thông qua phương thức UIO, ghi 4 byte vào bộ mô tả tệp.

Nếu TCMU_MAILBOX_FLAG_CAP_OOOC được đặt cho hộp thư->cờ, kernel sẽ
có khả năng xử lý các công việc hoàn thành không theo thứ tự. Trong trường hợp này, không gian người dùng có thể
xử lý lệnh theo thứ tự khác với bản gốc. Vì kernel sẽ
vẫn xử lý các lệnh theo thứ tự như trong lệnh
đổ chuông, không gian người dùng cần cập nhật cmd->id khi hoàn tất
lệnh (hay còn gọi là đánh cắp mục nhập của lệnh gốc).

Khi mã hoạt động là PAD, không gian người dùng chỉ cập nhật cmd_tail như trên --
đó là điều không nên làm. (Hạt nhân chèn các mục nhập PAD để đảm bảo mỗi mục nhập CMD
tiếp giáp trong vòng lệnh.)

Nhiều opcodes có thể được thêm vào trong tương lai. Nếu không gian người dùng gặp phải một
opcode nó không xử lý được, nó phải đặt bit UNKNOWN_OP (bit 0) vào
hdr.uflags, cập nhật cmd_tail và tiến hành xử lý bổ sung
lệnh nếu có.

Vùng dữ liệu
-------------

Đây là không gian bộ nhớ dùng chung sau vòng lệnh. Tổ chức
của khu vực này không được xác định trong giao diện TCMU và không gian người dùng
chỉ nên truy cập những phần được tham chiếu bởi các iov đang chờ xử lý.


Khám phá thiết bị
-----------------

Các thiết bị khác có thể đang sử dụng UIO ngoài TCMU. Quy trình người dùng không liên quan
cũng có thể đang xử lý các bộ thiết bị TCMU khác nhau. Không gian người dùng TCMU
các tiến trình phải tìm thiết bị của chúng bằng cách quét sysfs
lớp/uio/uio*/tên. Đối với các thiết bị TCMU, những tên này sẽ thuộc loại
định dạng::

tcm-user/<hba_num>/<device_name>/<subtype>/<path>

trong đó "tcm-user" là chung cho tất cả các thiết bị UIO được hỗ trợ bởi TCMU. <hba_num>
và <device_name> cho phép không gian người dùng tìm đường dẫn của thiết bị trong
cây configfs của mục tiêu kernel. Giả sử điểm gắn kết thông thường, đó là
được tìm thấy tại::

/sys/kernel/config/target/core/user_<hba_num>/<device_name>

Vị trí này chứa các thuộc tính như "hw_block_size",
không gian người dùng cần biết để hoạt động chính xác.

<subtype> sẽ là một chuỗi duy nhất trong không gian người dùng để xác định
Thiết bị TCMU dự kiến sẽ được hỗ trợ bởi một trình xử lý nhất định và <path>
sẽ là một chuỗi bổ sung dành riêng cho trình xử lý để quá trình người dùng thực hiện
cấu hình thiết bị, nếu cần. Tên không thể chứa ':', do
Những hạn chế của LIO.

Đối với tất cả các thiết bị được phát hiện, trình xử lý người dùng sẽ mở /dev/uioX và
gọi mmap()::

mmap(NULL, kích thước, PROT_READ|PROT_WRITE, MAP_SHARED, fd, 0)

trong đó kích thước phải bằng giá trị được đọc từ
/sys/class/uio/uioX/maps/map0/size.


Sự kiện thiết bị
----------------

Nếu một thiết bị mới được thêm hoặc xóa, một thông báo sẽ được phát đi
qua liên kết mạng, sử dụng tên họ liên kết mạng chung là "TCM-USER" và một
nhóm multicast có tên là "config". Điều này sẽ bao gồm tên UIO như
được mô tả ở phần trước, cũng như âm thứ UIO
số. Điều này sẽ cho phép không gian người dùng xác định cả thiết bị UIO và
thiết bị LIO, để sau khi xác định thiết bị được hỗ trợ
(dựa trên loại phụ) nó có thể thực hiện hành động thích hợp.


Các trường hợp dự phòng khác
----------------------------

Quá trình xử lý không gian người dùng không bao giờ đính kèm:

- TCMU sẽ đăng lệnh và sau đó hủy chúng sau một khoảng thời gian chờ
  (30 giây.)

Quá trình xử lý không gian người dùng bị hủy:

- Vẫn có thể khởi động lại và kết nối lại với TCMU
  thiết bị. Vòng lệnh được bảo tồn. Tuy nhiên, sau khoảng thời gian chờ,
  kernel sẽ hủy bỏ các tác vụ đang chờ xử lý.

Quá trình xử lý không gian người dùng bị treo:

- Kernel sẽ hủy bỏ các tác vụ đang chờ xử lý sau một khoảng thời gian chờ.

Quá trình xử lý không gian người dùng độc hại:

- Quá trình này có thể phá vỡ một cách tầm thường việc xử lý các thiết bị mà nó điều khiển,
  nhưng không thể truy cập bộ nhớ kernel bên ngoài bộ nhớ được chia sẻ của nó
  các vùng nhớ.


Viết trình xử lý chuyển tiếp người dùng (có mã ví dụ)
=======================================================

Quá trình người dùng bàn giao thiết bị TCMU phải hỗ trợ những điều sau:

a) Khám phá và cấu hình các thiết bị uio TCMU
b) Đang chờ sự kiện trên (các) thiết bị
c) Quản lý vòng lệnh: Phân tích các thao tác và lệnh,
   thực hiện công việc khi cần thiết, thiết lập các trường phản hồi (scsi_status và
   có thể là sense_buffer), cập nhật cmd_tail và thông báo kernel
   công việc đó đã hoàn thành

Trước tiên, hãy cân nhắc việc viết một plugin cho tcmu-runner. tcmu-runner
thực hiện tất cả những điều này và cung cấp API cấp cao hơn cho plugin
các tác giả.

TCMU được thiết kế để nhiều quy trình không liên quan có thể quản lý TCMU
các thiết bị riêng biệt. Tất cả những người xử lý phải đảm bảo chỉ mở
các thiết bị, dựa trên một chuỗi kiểu con đã biết.

a) Khám phá và cấu hình các thiết bị TCMU UIO::

/* bỏ qua việc kiểm tra lỗi cho ngắn gọn */

int fd, dev_fd;
      char buf[256];
      bản đồ dài dài không dấu_len;
      void *bản đồ;

fd = open("/sys/class/uio/uio0/name", O_RDONLY);
      ret = read(fd, buf, sizeof(buf));
      đóng(fd);
      buf[ret-1] = '\0'; /* kết thúc null và cắt bỏ \n */

/* chúng tôi chỉ muốn các thiết bị uio có tên theo định dạng mà chúng tôi mong đợi */
      if (strncmp(buf, "tcm-user", 8))
	thoát (-1);

/* Ở đây cũng cần kiểm tra thêm về kiểu con */

fd = open(/sys/class/uio/%s/maps/map0/size, O_RDONLY);
      ret = read(fd, buf, sizeof(buf));
      đóng(fd);
      str_buf[ret-1] = '\0'; /* kết thúc null và cắt bỏ \n */

map_len = strtoull(buf, NULL, 0);

dev_fd = open("/dev/uio0", O_RDWR);
      bản đồ = mmap(NULL, map_len, PROT_READ|PROT_WRITE, MAP_SHARED, dev_fd, 0);


b) Đang chờ sự kiện trên (các) thiết bị

trong khi (1) {
        char buf[4];

int ret = read(dev_fd, buf, 4); /* sẽ chặn */

xử lý_device_events(dev_fd, bản đồ);
      }


c) Quản lý vòng lệnh::

#include <linux/target_core_user.h>

int hand_device_events(int fd, void *map)
      {
        struct tcmu_mailbox *mb = map;
        struct tcmu_cmd_entry ZZ0000ZZ) mb + mb->cmdr_off + mb->cmd_tail;
        int did_some_work = 0;

/* Xử lý các sự kiện từ vòng cmd cho đến khi chúng ta bắt kịp cmd_head */
        while (ent != (void *)mb + mb->cmdr_off + mb->cmd_head) {

if (tcmu_hdr_get_op(ent->hdr.len_op) == TCMU_OP_CMD) {
            uint8_t ZZ0000ZZ)mb + ent->req.cdb_off;
            bool thành công = đúng;

/* Xử lý lệnh ở đây. */
            printf("Mã hoạt động SCSI: 0x%x\n", cdb[0]);

/* Đặt trường phản hồi */
            nếu (thành công)
              ent->rsp.scsi_status = SCSI_NO_SENSE;
            khác {
              /* Đồng thời điền rsp->sense_buffer vào đây */
              ent->rsp.scsi_status = SCSI_CHECK_CONDITION;
            }
          }
          khác nếu (tcmu_hdr_get_op(ent->hdr.len_op) != TCMU_OP_PAD) {
            /* Nói với kernel rằng chúng ta không xử lý các opcode không xác định */
            ent->hdr.uflags |= TCMU_UFLAG_UNKNOWN_OP;
          }
          khác {
            /* Không làm gì cho các mục PAD ngoại trừ cập nhật cmd_tail */
          }

/* cập nhật cmd_tail */
          mb->cmd_tail = (mb->cmd_tail + tcmu_hdr_get_len(&ent->hdr)) % mb->cmdr_size;
          ent = (void *) mb + mb->cmdr_off + mb->cmd_tail;
          did_some_work = 1;
        }

/* Thông báo cho kernel rằng công việc đã hoàn tất */
        nếu (did_some_work) {
          uint32_t buf = 0;

write(fd, &buf, 4);
        }

trả về 0;
      }


Một lưu ý cuối cùng
===================

Hãy cẩn thận khi trả lại mã theo quy định của SCSI
thông số kỹ thuật. Những giá trị này khác với một số giá trị được xác định trong
scsi/scsi.h bao gồm tệp. Ví dụ: mã trạng thái của CHECK CONDITION
là 2 chứ không phải 1
