.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/bpf/bpf_iterators.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

==============
Bộ lặp BPF
=============

--------
Tổng quan
--------

BPF hỗ trợ hai thực thể riêng biệt được gọi chung là "BPF iterators": BPF
trình lặp ZZ0000ZZ và trình lặp ZZ0001ZZ BPF. Cái trước là
một loại chương trình BPF độc lập, khi được người dùng đính kèm và kích hoạt,
sẽ được gọi một lần cho mỗi thực thể (task_struct, cgroup, v.v.) đang được thực hiện
lặp đi lặp lại. Cái sau là một tập hợp các API triển khai trình vòng lặp phía BPF
chức năng và có sẵn trên nhiều loại chương trình BPF. Mã hóa mở
các trình vòng lặp cung cấp chức năng tương tự như các chương trình vòng lặp BPF, nhưng cung cấp
linh hoạt hơn và kiểm soát tất cả các loại chương trình BPF khác. Trình lặp BPF
mặt khác, các chương trình có thể được sử dụng để triển khai ẩn danh hoặc BPF
Các tệp đặc biệt được gắn trên FS, có nội dung được tạo bởi trình vòng lặp BPF đính kèm
chương trình, được hỗ trợ bởi chức năng seq_file. Cả hai đều hữu ích tùy thuộc vào
nhu cầu cụ thể.

Khi thêm chương trình lặp BPF mới, dự kiến sẽ có điều tương tự
chức năng sẽ được thêm vào dưới dạng trình vòng lặp được mã hóa mở để có độ linh hoạt tối đa.
Người ta cũng kỳ vọng rằng logic và mã lặp sẽ được chia sẻ tối đa và
được tái sử dụng giữa hai bề mặt API của iterator.

---------------
Bộ lặp BPF được mã hóa mở
------------------------

Các trình vòng lặp BPF được mã hóa mở được triển khai dưới dạng bộ ba kfuncs được liên kết chặt chẽ
(hàm tạo, tìm nạp phần tử tiếp theo, hàm hủy) và kiểu dành riêng cho trình vòng lặp
mô tả trạng thái của trình vòng lặp trên ngăn xếp, được đảm bảo bởi BPF
trình xác minh không bị giả mạo bên ngoài tương ứng
hàm tạo/hàm hủy/API tiếp theo.

Mỗi loại trình vòng lặp BPF được mã hóa mở đều có liên kết riêng
struct bpf_iter_<type>, trong đó <type> biểu thị một loại trình vòng lặp cụ thể.
Trạng thái bpf_iter_<type> cần tồn tại trên ngăn xếp chương trình BPF, vì vậy hãy đảm bảo rằng trạng thái đó
đủ nhỏ để vừa trên ngăn xếp BPF. Vì lý do hiệu suất, tốt nhất nên tránh
cấp phát bộ nhớ động cho trạng thái lặp và kích thước cấu trúc trạng thái lớn
đủ để phù hợp với mọi thứ cần thiết. Nhưng nếu cần thiết, bộ nhớ động
phân bổ là một cách để vượt qua các giới hạn ngăn xếp BPF. Lưu ý, kích thước cấu trúc trạng thái
là một phần của API mà người dùng có thể nhìn thấy của iterator, vì vậy việc thay đổi nó sẽ bị hỏng ngược
khả năng tương thích, vì vậy hãy cân nhắc khi thiết kế nó.

Tất cả kfuncs (hàm tạo, tiếp theo, hàm hủy) phải được đặt tên nhất quán là
bpf_iter_<type>_{new,next,destroy}() tương ứng. <type> đại diện cho trình vòng lặp
loại và trạng thái lặp phải được biểu diễn dưới dạng khớp
Loại trạng thái ZZ0000ZZ. Ngoài ra, tất cả iter kfuncs nên có
một con trỏ tới ZZ0001ZZ này làm đối số đầu tiên.

Ngoài ra:
  - Trình xây dựng, tức là ZZ0000ZZ, có thể có phần bổ sung tùy ý
    số lượng đối số. Kiểu trả về cũng không được thực thi.
  - Phương thức tiếp theo, tức là ZZ0001ZZ, phải trả về một con trỏ
    gõ và phải có chính xác một đối số: ZZ0002ZZ
    (const/volatile/restrict và typedefs bị bỏ qua).
  - Hàm hủy, tức là ZZ0003ZZ, sẽ trả về khoảng trống và
    phải có chính xác một đối số, tương tự như phương pháp tiếp theo.
  - Kích thước ZZ0004ZZ được thực thi ở mức dương và
    bội số của 8 byte (để khớp chính xác các khe ngăn xếp).

Sự chặt chẽ và nhất quán như vậy cho phép xây dựng sự trừu tượng hóa các trợ giúp chung
các chi tiết quan trọng nhưng được soạn sẵn để có thể sử dụng các trình vòng lặp được mã hóa mở
hiệu quả và tiện lợi (xem macro bpf_for_each() của libbpf). Đây là
được thực thi tại điểm đăng ký kfunc bởi kernel.

Hợp đồng thực hiện hàm tạo/tiếp theo/ hàm hủy như sau:
  - hàm tạo, ZZ0000ZZ, luôn khởi tạo trạng thái lặp trên
    ngăn xếp. Nếu bất kỳ đối số đầu vào nào không hợp lệ, hàm tạo sẽ
    đảm bảo vẫn khởi tạo nó sao cho các lệnh gọi next() tiếp theo sẽ
    trả lại NULL. Tức là có lỗi, ZZ0001ZZ.
    Trình xây dựng kfunc được đánh dấu bằng cờ KF_ITER_NEW.

- phương thức tiếp theo, ZZ0000ZZ, chấp nhận con trỏ tới trạng thái lặp
    và tạo ra một phần tử. Phương thức tiếp theo phải luôn trả về một con trỏ. các
    hợp đồng giữa trình xác minh BPF là phương pháp tiếp theo ZZ0001ZZ mà nó
    cuối cùng sẽ trả về NULL khi các phần tử đã cạn kiệt. Khi NULL được
    được trả về, các cuộc gọi tiếp theo ZZ0002ZZ. Phương pháp tiếp theo
    được đánh dấu bằng KF_ITER_NEXT (và cũng nên có KF_RET_NULL làm
    Tất nhiên là NULL-trả lại kfunc).

- hàm hủy, ZZ0000ZZ, luôn được gọi một lần. Kể cả nếu
    hàm tạo không thành công hoặc lần tiếp theo không trả về gì.  Destructor giải phóng mọi thứ
    tài nguyên và đánh dấu không gian ngăn xếp được ZZ0001ZZ sử dụng là có thể sử dụng được
    cho một cái gì đó khác. Hàm hủy được đánh dấu bằng cờ KF_ITER_DESTROY.

Bất kỳ triển khai trình vòng lặp BPF mã hóa mở nào đều phải triển khai ít nhất những điều này
ba phương pháp. Nó được thực thi rằng chỉ dành cho bất kỳ loại trình lặp nhất định nào
hàm tạo/hàm hủy/tiếp theo có thể áp dụng được. Tức là người xác minh đảm bảo
bạn không thể chuyển trạng thái của trình vòng lặp số sang phương thức tiếp theo của cgroup iterator.

Từ quan điểm xác minh BPF ở độ cao 10.000 feet, các phương pháp tiếp theo là điểm
về việc tạo ra một trạng thái xác minh, có khái niệm tương tự như những gì
trình xác minh đang thực hiện khi xác thực các bước nhảy có điều kiện. Trình xác minh đang phân nhánh
Hướng dẫn ZZ0000ZZ và mô phỏng hai kết quả: NULL
(việc lặp lại hoàn tất) và không phải NULL (phần tử mới được trả về). NULL được mô phỏng
đầu tiên và được cho là sẽ đến lối ra mà không cần lặp lại. Sau đó là trường hợp không phải NULL
được xác thực và nó đạt đến lối thoát (đối với các ví dụ tầm thường không có thực tế
vòng lặp), hoặc đạt tới lệnh ZZ0001ZZ khác bằng lệnh
trạng thái tương đương với trạng thái đã được xác thực (một phần). trạng thái tương đương tại
thời điểm đó có nghĩa là về mặt kỹ thuật chúng ta sẽ lặp lại mãi mãi mà không có
"thoát ra" khỏi "vỏ trạng thái" đã được thiết lập (tức là, tiếp theo
các lần lặp lại không thêm bất kỳ kiến thức hoặc ràng buộc mới nào vào trạng thái xác minh,
vì vậy việc chạy 1, 2, 10 hoặc một triệu trong số chúng không thành vấn đề). Nhưng tính đến
tài khoản hợp đồng nêu rõ phương thức lặp tiếp theo ZZ0002ZZ trả về NULL
cuối cùng, chúng ta có thể kết luận rằng phần thân vòng lặp là an toàn và cuối cùng sẽ
chấm dứt. Do chúng tôi đã xác thực logic bên ngoài vòng lặp (trường hợp NULL) và
kết luận rằng nội dung vòng lặp là an toàn (mặc dù có khả năng lặp lại nhiều lần),
người xác minh có thể yêu cầu sự an toàn của logic chương trình tổng thể.

---------------
Động lực của bộ lặp BPF
------------------------

Có một số cách hiện có để chuyển dữ liệu kernel vào không gian người dùng. nhất
phổ biến nhất là hệ thống ZZ0000ZZ. Ví dụ: ZZ0001ZZ kết xuất
tất cả các ổ cắm tcp6 trong hệ thống và ZZ0002ZZ loại bỏ tất cả các liên kết mạng
các socket trong hệ thống. Tuy nhiên, định dạng đầu ra của chúng có xu hướng cố định và nếu
người dùng muốn biết thêm thông tin về các socket này, họ phải vá kernel,
thường mất thời gian để xuất bản ngược dòng và phát hành. Điều này cũng đúng đối với sự phổ biến
các công cụ như ZZ0003ZZ nếu có
thông tin bổ sung cần một bản vá kernel.

Để giải quyết vấn đề này người ta thường sử dụng công cụ ZZ0000ZZ để
khai thác dữ liệu kernel mà không thay đổi kernel. Tuy nhiên, nhược điểm chính đối với
drgn là hiệu suất, vì nó không thể thực hiện dò tìm con trỏ bên trong kernel. trong
Ngoài ra, drgn không thể xác thực giá trị con trỏ và có thể đọc dữ liệu không hợp lệ nếu
con trỏ trở nên không hợp lệ bên trong kernel.

Trình lặp BPF giải quyết vấn đề trên bằng cách cung cấp tính linh hoạt trên dữ liệu nào
(ví dụ: tác vụ, bpf_maps, v.v.) để thu thập bằng cách gọi các chương trình BPF cho mỗi hạt nhân
đối tượng dữ liệu.

----------------------
Trình lặp BPF hoạt động như thế nào
----------------------

Trình lặp BPF là một loại chương trình BPF cho phép người dùng lặp lại
các loại đối tượng kernel cụ thể. Không giống như các chương trình truy tìm BPF truyền thống
cho phép người dùng xác định các cuộc gọi lại được gọi tại các điểm cụ thể của
thực thi trong kernel, các trình vòng lặp BPF cho phép người dùng xác định các lệnh gọi lại
nên được thực thi cho mọi mục trong nhiều cấu trúc dữ liệu hạt nhân.

Ví dụ: người dùng có thể xác định trình vòng lặp BPF lặp lại mọi tác vụ trên
hệ thống và loại bỏ tổng thời lượng thời gian chạy CPU hiện đang được sử dụng bởi mỗi hệ thống.
họ. Thay vào đó, một trình lặp tác vụ BPF khác có thể kết xuất thông tin nhóm cho mỗi
nhiệm vụ. Tính linh hoạt như vậy là giá trị cốt lõi của các trình vòng lặp BPF.

Chương trình BPF luôn được tải vào kernel theo yêu cầu của không gian người dùng
quá trình. Quá trình không gian người dùng tải chương trình BPF bằng cách mở và khởi tạo
khung chương trình theo yêu cầu và sau đó gọi một syscall để có BPF
chương trình được xác minh và tải bởi kernel.

Trong các chương trình theo dõi truyền thống, một chương trình được kích hoạt bằng cách có không gian người dùng
lấy ZZ0000ZZ cho chương trình với ZZ0001ZZ. Một lần
được kích hoạt, lệnh gọi lại chương trình sẽ được gọi bất cứ khi nào điểm theo dõi được
được kích hoạt trong kernel chính. Đối với các chương trình vòng lặp BPF, ZZ0002ZZ cho
chương trình được lấy bằng ZZ0003ZZ và lệnh gọi lại chương trình được thực hiện
được gọi bằng cách thực hiện các cuộc gọi hệ thống từ không gian người dùng.

Tiếp theo, chúng ta hãy xem cách bạn có thể sử dụng các trình vòng lặp để lặp trên các đối tượng kernel và
đọc dữ liệu.

---------------
Cách sử dụng vòng lặp BPF
------------------------

Các bài tự kiểm tra của BPF là một nguồn tài nguyên tuyệt vời để minh họa cách sử dụng các trình vòng lặp. trong
phần này, chúng ta sẽ hướng dẫn cách tự kiểm tra BPF, hướng dẫn cách tải và sử dụng
một chương trình lặp BPF.   Để bắt đầu, chúng ta sẽ xem xét ZZ0000ZZ,
minh họa cách tải và kích hoạt các trình vòng lặp BPF ở phía không gian người dùng.
Sau này, chúng ta sẽ xem xét chương trình BPF chạy trong không gian kernel.

Tải trình vòng lặp BPF trong kernel từ không gian người dùng thường liên quan đến
các bước sau:

* Chương trình BPF được tải vào kernel thông qua ZZ0000ZZ. Một khi hạt nhân
  đã xác minh và tải chương trình, nó sẽ trả về bộ mô tả tệp (fd) cho người dùng
  không gian.
* Nhận ZZ0001ZZ cho chương trình BPF bằng cách gọi ZZ0002ZZ
  được chỉ định bằng bộ mô tả tệp chương trình BPF nhận được từ kernel.
* Tiếp theo, lấy bộ mô tả tệp lặp BPF (ZZ0003ZZ) bằng cách gọi
  ZZ0004ZZ được chỉ định bằng ZZ0005ZZ nhận được từ Bước 2.
* Kích hoạt vòng lặp bằng cách gọi ZZ0006ZZ cho đến khi không còn dữ liệu
  có sẵn.
* Đóng fd iterator bằng ZZ0007ZZ.
* Nếu cần đọc lại dữ liệu, hãy lấy ZZ0008ZZ mới và đọc lại.

Sau đây là một số ví dụ về chương trình lặp BPF tự kiểm tra:

* ZZ0000ZZ
* ZZ0001ZZ
* ZZ0002ZZ

Chúng ta hãy xem ZZ0000ZZ, chạy trong không gian kernel:

Đây là định nghĩa của ZZ0000ZZ trong ZZ0004ZZ.
Bất kỳ tên cấu trúc nào trong ZZ0001ZZ ở định dạng ZZ0002ZZ
đại diện cho một trình vòng lặp BPF. Hậu tố ZZ0003ZZ đại diện cho loại
iterator.

::

cấu trúc bpf_iter__task_file {
            công đoàn {
                cấu trúc bpf_iter_meta *meta;
            };
            công đoàn {
                struct task_struct *task;
            };
            u32 fd;
            công đoàn {
                tệp cấu trúc *tệp;
            };
    };

Trong đoạn mã trên, trường 'meta' chứa siêu dữ liệu giống với siêu dữ liệu
tất cả các chương trình lặp BPF. Các trường còn lại dành riêng cho các trường khác nhau
các vòng lặp. Ví dụ, đối với các trình vòng lặp task_file, lớp kernel cung cấp
giá trị trường 'task', 'fd' và 'file'. 'Tác vụ' và 'tệp' là ZZ0000ZZ,
nên chúng sẽ không biến mất khi chương trình BPF chạy.

Đây là đoạn trích từ tệp ZZ0000ZZ:

::

SEC("iter/task_file")
  int dump_task_file(struct bpf_iter__task_file *ctx)
  {
    struct seq_file *seq = ctx->meta->seq;
    struct task_struct *task = ctx->task;
    tập tin cấu trúc *file = ctx->file;
    __u32 fd = ctx->fd;

nếu (tác vụ == NULL || tệp == NULL)
      trả về 0;

if (ctx->meta->seq_num == 0) {
      đếm = 0;
      BPF_SEQ_PRINTF(seq, " tgid gid fd file\n");
    }

if (tgid == task->tgid && task->tgid != task->pid)
      đếm++;

if (last_tgid != task->tgid) {
      Last_tgid = task->tgid;
      Unique_tgid_count++;
    }

BPF_SEQ_PRINTF(seq, "%8d %8d %8d %lx\n", task->tgid, task->pid, fd,
            (dài)tệp->f_op);
    trả về 0;
  }

Trong ví dụ trên, tên phần ZZ0000ZZ, chỉ ra rằng
chương trình này là một chương trình lặp BPF để lặp lại tất cả các tệp từ tất cả các tác vụ. các
bối cảnh của chương trình là cấu trúc ZZ0001ZZ.

Chương trình không gian người dùng gọi chương trình lặp BPF đang chạy trong kernel
bằng cách phát hành một tòa nhà ZZ0000ZZ. Sau khi được gọi, BPF
chương trình có thể xuất dữ liệu sang không gian người dùng bằng nhiều chức năng trợ giúp BPF.
Bạn có thể sử dụng ZZ0001ZZ (và macro trợ giúp BPF_SEQ_PRINTF) hoặc
Chức năng ZZ0002ZZ dựa trên việc bạn cần định dạng đầu ra hay chỉ
dữ liệu nhị phân tương ứng. Đối với dữ liệu được mã hóa nhị phân, các ứng dụng không gian người dùng
có thể xử lý dữ liệu từ ZZ0003ZZ khi cần. Đối với dữ liệu được định dạng,
bạn có thể sử dụng ZZ0004ZZ để in kết quả tương tự như ZZ0005ZZ sau khi ghim trình vòng lặp BPF vào giá đỡ bpffs. Sau đó,
sử dụng ZZ0006ZZ để loại bỏ trình vòng lặp được ghim.

Ví dụ: bạn có thể sử dụng lệnh sau để tạo trình vòng lặp BPF từ
Tệp đối tượng ZZ0000ZZ và ghim nó vào ZZ0001ZZ
đường dẫn:

::

$ bpftool iter pin ./bpf_iter_ipv6_route.o /sys/fs/bpf/my_route

Và sau đó in ra kết quả bằng lệnh sau:

::

$ cat /sys/fs/bpf/my_route


----------------------------------------------
Triển khai hỗ trợ hạt nhân cho các loại chương trình vòng lặp BPF
-------------------------------------------------------

Để triển khai trình vòng lặp BPF trong kernel, nhà phát triển phải tạo một lần
thay đổi cấu trúc dữ liệu chính sau được xác định trong ZZ0000ZZ
tập tin.

::

cấu trúc bpf_iter_reg {
            const char *đích;
            bpf_iter_attach_target_t đính kèm_target;
            bpf_iter_detach_target_t tách_target;
            bpf_iter_show_fdinfo_t show_fdinfo;
            bpf_iter_fill_link_info_t fill_link_info;
            bpf_iter_get_func_proto_t get_func_proto;
            u32 ctx_arg_info_size;
            tính năng u32;
            cấu trúc bpf_ctx_arg_aux ctx_arg_info[BPF_ITER_CTX_ARG_MAX];
            const struct bpf_iter_seq_info *seq_info;
  };

Sau khi điền vào các trường cấu trúc dữ liệu, hãy gọi ZZ0000ZZ để
đăng ký trình vòng lặp vào hệ thống con trình vòng lặp BPF chính.

Sau đây là bảng phân tích cho từng trường trong cấu trúc ZZ0000ZZ.

.. list-table::
   :widths: 25 50
   :header-rows: 1

   * - Fields
     - Description
   * - target
     - Specifies the name of the BPF iterator. For example: ``bpf_map``,
       ``bpf_map_elem``. The name should be different from other ``bpf_iter`` target names in the kernel.
   * - attach_target and detach_target
     - Allows for target specific ``link_create`` action since some targets
       may need special processing. Called during the user space link_create stage.
   * - show_fdinfo and fill_link_info
     - Called to fill target specific information when user tries to get link
       info associated with the iterator.
   * - get_func_proto
     - Permits a BPF iterator to access BPF helpers specific to the iterator.
   * - ctx_arg_info_size and ctx_arg_info
     - Specifies the verifier states for BPF program arguments associated with
       the bpf iterator.
   * - feature
     - Specifies certain action requests in the kernel BPF iterator
       infrastructure. Currently, only BPF_ITER_RESCHED is supported. This means
       that the kernel function cond_resched() is called to avoid other kernel
       subsystem (e.g., rcu) misbehaving.
   * - seq_info
     - Specifies the set of seq operations for the BPF iterator and helpers to
       initialize/free the private data for the corresponding ``seq_file``.

ZZ0001ZZ
để xem cách triển khai trình vòng lặp ZZ0000ZZ BPF trong kernel.

----------------------------------
Tham số hóa Trình lặp tác vụ BPF
---------------------------------

Theo mặc định, các trình vòng lặp BPF duyệt qua tất cả các đối tượng thuộc các loại được chỉ định
(quy trình, nhóm, bản đồ, v.v.) trên toàn bộ hệ thống để đọc các thông tin liên quan
dữ liệu hạt nhân. Nhưng thông thường, có những trường hợp chúng ta chỉ quan tâm đến một vấn đề nhỏ hơn nhiều
tập hợp con của các đối tượng hạt nhân có thể lặp lại, chẳng hạn như chỉ lặp lại các tác vụ trong một
quá trình cụ thể. Vì vậy, các chương trình lặp BPF hỗ trợ lọc ra các đối tượng
từ việc lặp lại bằng cách cho phép không gian người dùng định cấu hình chương trình lặp khi nó
được đính kèm.

-----------------
Chương trình lặp tác vụ BPF
--------------------------

Đoạn mã sau là chương trình lặp BPF để in các tập tin và thông tin tác vụ
thông qua ZZ0000ZZ của trình vòng lặp. Đây là chương trình lặp BPF tiêu chuẩn
truy cập mọi tập tin của một trình vòng lặp. Chúng tôi sẽ sử dụng chương trình BPF này trong
ví dụ sau này.

::

#include <vmlinux.h>
  #include <bpf/bpf_helpers.h>

char _license[] SEC("giấy phép") = "GPL";

SEC("iter/task_file")
  int dump_task_file(struct bpf_iter__task_file *ctx)
  {
        struct seq_file *seq = ctx->meta->seq;
        struct task_struct *task = ctx->task;
        tập tin cấu trúc *file = ctx->file;
        __u32 fd = ctx->fd;
        nếu (tác vụ == NULL || tệp == NULL)
                trả về 0;
        if (ctx->meta->seq_num == 0) {
                BPF_SEQ_PRINTF(seq, " tgid pid fd file\n");
        }
        BPF_SEQ_PRINTF(seq, "%8d %8d %8d %lx\n", task->tgid, task->pid, fd,
                        (dài)tệp->f_op);
        trả về 0;
  }

----------------------------------------
Tạo một File Iterator với các tham số
----------------------------------------

Bây giờ, chúng ta hãy xem cách tạo một trình vòng lặp chỉ bao gồm các tệp của một
quá trình.

Đầu tiên, điền vào cấu trúc ZZ0000ZZ như dưới đây:

::

LIBBPF_OPTS(bpf_iter_attach_opts, opts);
  liên minh bpf_iter_link_info linfo;
  bộ nhớ(&linfo, 0, sizeof(linfo));
  linfo.task.pid = getpid();
  opts.link_info = &linfo;
  opts.link_info_len = sizeof(linfo);

ZZ0000ZZ, nếu nó khác 0, sẽ hướng dẫn kernel tạo một iterator
chỉ bao gồm các tệp đã mở cho quy trình với ZZ0001ZZ được chỉ định. trong
Trong ví dụ này, chúng tôi sẽ chỉ lặp lại các tệp cho quy trình của mình. Nếu
ZZ0002ZZ bằng 0, trình vòng lặp sẽ truy cập mọi tệp đã mở của mỗi
quá trình. Tương tự, ZZ0003ZZ chỉ đạo kernel tạo một iterator
truy cập các tệp đã mở của một chuỗi cụ thể chứ không phải một quy trình. Trong ví dụ này,
ZZ0004ZZ chỉ khác với ZZ0005ZZ nếu luồng có
bảng mô tả tập tin riêng biệt. Trong hầu hết các trường hợp, tất cả các luồng tiến trình đều chia sẻ
một bảng mô tả tập tin duy nhất.

Bây giờ, trong chương trình không gian người dùng, chuyển con trỏ của struct tới
ZZ0000ZZ.

::

liên kết = bpf_program__attach_iter(prog, &opts);
  iter_fd = bpf_iter_create(bpf_link__fd(link));

Nếu cả ZZ0002ZZ và ZZ0003ZZ đều bằng 0, thì một trình vòng lặp được tạo từ cấu trúc này
ZZ0000ZZ sẽ bao gồm mọi tệp đã mở của mọi tác vụ trong
system (thực tế là trong không gian tên.) Nó giống như việc chuyển NULL làm
đối số thứ hai cho ZZ0001ZZ.

Toàn bộ chương trình trông giống như đoạn mã sau:

::

#include <stdio.h>
  #include <unistd.h>
  #include <bpf/bpf.h>
  #include <bpf/libbpf.h>
  #include "bpf_iter_task_ex.skel.h"

int tĩnh do_read_opts(struct bpf_program *prog, struct bpf_iter_attach_opts *opts)
  {
        cấu trúc bpf_link *liên kết;
        char buf[16] = {};
        int iter_fd = -1, len;
        int ret = 0;

link = bpf_program__attach_iter(prog, opts);
        nếu (! liên kết) {
                fprintf(stderr, "bpf_program__attach_iter() bị lỗi\n");
                trả về -1;
        }
        iter_fd = bpf_iter_create(bpf_link__fd(link));
        nếu (iter_fd < 0) {
                fprintf(stderr, "bpf_iter_create() bị lỗi\n");
                ret = -1;
                đi tới free_link;
        }
        /* không kiểm tra nội dung nhưng đảm bảo kết thúc read() không có lỗi */
        while ((len = read(iter_fd, buf, sizeof(buf) - 1)) > 0) {
                buf[len] = 0;
                printf("%s", buf);
        }
        printf("\n");
  free_link:
        nếu (iter_fd >= 0)
                đóng(iter_fd);
        bpf_link__destroy(liên kết);
        trả về 0;
  }

tĩnh void test_task_file(void)
  {
        LIBBPF_OPTS(bpf_iter_attach_opts, opts);
        cấu trúc bpf_iter_task_ex *skel;
        liên minh bpf_iter_link_info linfo;
        skel = bpf_iter_task_ex__open_and_load();
        nếu (skel == NULL)
                trở lại;
        bộ nhớ(&linfo, 0, sizeof(linfo));
        linfo.task.pid = getpid();
        opts.link_info = &linfo;
        opts.link_info_len = sizeof(linfo);
        printf("PID %d\n", getpid());
        do_read_opts(skel->progs.dump_task_file, &opts);
        bpf_iter_task_ex__destroy(skel);
  }

int main(int argc, const char * const * argv)
  {
        test_task_file();
        trả về 0;
  }

Các dòng sau đây là đầu ra của chương trình.
::

PID 1859

tập tin fd tgid pid
     1859 1859 0 ffffffff82270aa0
     1859 1859 1 ffffffff82270aa0
     1859 1859 2 ffffffff82270aa0
     1859 1859 3 ffffffff82272980
     1859 1859 4 ffffffff8225e120
     1859 1859 5 ffffffff82255120
     1859 1859 6 ffffffff82254f00
     1859 1859 7 ffffffff82254d80
     1859 1859 8 ffffffff8225abe0

------------------
Không có thông số
------------------

Chúng ta hãy xem cách một trình vòng lặp BPF không có tham số bỏ qua các tệp của các tệp khác
các tiến trình trong hệ thống. Trong trường hợp này, chương trình BPF phải kiểm tra pid hoặc
các nhiệm vụ hoặc nó sẽ nhận mọi tập tin đã mở trong hệ thống (trong
thực tế là không gian tên ZZ0000ZZ hiện tại). Vì vậy, chúng ta thường thêm một biến toàn cục vào
Chương trình BPF để chuyển ZZ0001ZZ sang chương trình BPF.

Chương trình BPF sẽ trông giống như khối sau.

  ::

    ......
int target_pid = 0;

SEC("iter/task_file")
    int dump_task_file(struct bpf_iter__task_file *ctx)
    {
          ......
if (task->tgid != target_pid) /* Thay vào đó hãy kiểm tra task->pid để kiểm tra ID luồng */
                  trả về 0;
          BPF_SEQ_PRINTF(seq, "%8d %8d %8d %lx\n", task->tgid, task->pid, fd,
                          (dài)tệp->f_op);
          trả về 0;
    }

Chương trình không gian người dùng sẽ trông giống như khối sau:

  ::

    ......
tĩnh void test_task_file(void)
    {
          ......
skel = bpf_iter_task_ex__open_and_load();
          nếu (skel == NULL)
                  trở lại;
          skel->bss->target_pid = getpid(); /* ID tiến trình.  Đối với id chủ đề, hãy sử dụng gettid() */
          bộ nhớ(&linfo, 0, sizeof(linfo));
          linfo.task.pid = getpid();
          opts.link_info = &linfo;
          opts.link_info_len = sizeof(linfo);
          ......
    }

ZZ0000ZZ là biến toàn cục trong chương trình BPF. Chương trình không gian người dùng
nên khởi tạo biến bằng ID tiến trình để bỏ qua các tệp đã mở của người khác
các quy trình trong chương trình BPF. Khi bạn tham số hóa một trình vòng lặp BPF, trình vòng lặp
gọi chương trình BPF ít lần hơn, điều này có thể tiết kiệm tài nguyên đáng kể.

--------------------------
Tham số hóa bộ lặp VMA
---------------------------

Theo mặc định, trình vòng lặp BPF VMA bao gồm mọi VMA trong mọi quy trình.  Tuy nhiên,
bạn vẫn có thể chỉ định một tiến trình hoặc một luồng để chỉ bao gồm các VMA của nó. Không giống
các tệp, một luồng không thể có một không gian địa chỉ riêng (kể từ Linux 2.6.0-test6).
Ở đây, việc sử dụng ZZ0000ZZ không có gì khác biệt so với việc sử dụng ZZ0001ZZ.

----------------------------
Trình lặp tác vụ tham số hóa
----------------------------

Trình lặp tác vụ BPF với ZZ0000ZZ bao gồm tất cả các tác vụ (luồng) của một quy trình. các
Chương trình BPF lần lượt nhận các tác vụ này. Bạn có thể chỉ định tác vụ BPF
iterator với tham số ZZ0001ZZ để chỉ bao gồm các tác vụ phù hợp với tham số đã cho
ZZ0002ZZ.
