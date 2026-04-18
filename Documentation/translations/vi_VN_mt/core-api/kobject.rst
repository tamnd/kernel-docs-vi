.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/core-api/kobject.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

===========================================================================
Mọi thứ bạn không bao giờ muốn biết về kobjects, ksets và ktypes
===========================================================================

:Tác giả: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
:Cập nhật lần cuối: Ngày 19 tháng 12 năm 2007

Dựa trên bài viết gốc của Jon Corbet cho lwn.net viết ngày 1 tháng 10,
2003 và đặt tại ZZ0000ZZ

Một phần khó khăn trong việc hiểu mô hình trình điều khiển - và kobject
sự trừu tượng mà nó được xây dựng trên đó - là không có sự khởi đầu rõ ràng
nơi. Xử lý kobjects đòi hỏi phải hiểu một số loại khác nhau,
tất cả đều liên quan đến nhau. Trong nỗ lực làm cho mọi thứ
dễ dàng hơn, chúng ta sẽ áp dụng phương pháp tiếp cận nhiều bước, bắt đầu bằng những thuật ngữ mơ hồ và
thêm chi tiết khi chúng tôi đi. Để đạt được mục đích đó, đây là một số định nghĩa nhanh về
một số điều khoản chúng tôi sẽ làm việc với.

- Một kobject là một đối tượng có kiểu struct kobject.  Kobjects có một tên
   và số lượng tham chiếu.  Một kobject cũng có một con trỏ cha (cho phép
   các đối tượng được sắp xếp thành các hệ thống phân cấp), một loại cụ thể, và,
   thông thường, một đại diện trong hệ thống tập tin ảo sysfs.

Kobjects nói chung không thú vị; thay vào đó, họ là
   thường được nhúng trong một số cấu trúc khác có chứa nội dung
   mã này thực sự được quan tâm.

Không có cấu trúc nào nên ZZ0000ZZ có nhiều hơn một kobject được nhúng bên trong nó.
   Nếu đúng như vậy thì việc đếm tham chiếu cho đối tượng chắc chắn sẽ bị sai lệch
   lên và không chính xác, và mã của bạn sẽ có lỗi.  Vì vậy, đừng làm điều này.

- ktype là loại đối tượng nhúng kobject.  Mỗi cấu trúc
   nhúng một kobject cần một ktype tương ứng.  Điều khiển ktype
   điều gì xảy ra với kobject khi nó được tạo và hủy.

- Kset là một nhóm kobjects.  Những kobject này có thể cùng loại ktype
   hoặc thuộc về các ktypes khác nhau.  Kset là loại thùng chứa cơ bản cho
   bộ sưu tập của kobjects. Các tập hợp chứa kobjects riêng của chúng, nhưng bạn có thể
   bỏ qua chi tiết triển khai đó một cách an toàn khi mã lõi kset xử lý
   kobject này tự động.

Khi bạn nhìn thấy một thư mục sysfs chứa đầy các thư mục khác, thông thường mỗi thư mục
   trong số các thư mục đó tương ứng với một kobject trong cùng một kset.

Chúng ta sẽ xem xét cách tạo và thao tác tất cả các loại này. Từ dưới lên
cách tiếp cận sẽ được thực hiện, vì vậy chúng ta sẽ quay lại với kobjects.


Nhúng kobjects
==================

Rất hiếm khi mã hạt nhân tạo ra một kobject độc lập, với một chính
ngoại lệ được giải thích dưới đây.  Thay vào đó, kobjects được sử dụng để kiểm soát quyền truy cập vào
một đối tượng lớn hơn, theo miền cụ thể.  Để đạt được mục đích này, kobjects sẽ được tìm thấy
nhúng trong các cấu trúc khác.  Nếu bạn đã quen với việc nghĩ về mọi thứ trong
thuật ngữ hướng đối tượng, kobjects có thể được coi là lớp trừu tượng, cấp cao nhất
từ đó các lớp khác được dẫn xuất.  Một kobject thực hiện một tập hợp
những khả năng mà bản thân chúng không đặc biệt hữu ích nhưng lại
rất vui khi có trong các đối tượng khác.  Ngôn ngữ C không cho phép
biểu hiện trực tiếp của tính kế thừa, do đó các kỹ thuật khác - chẳng hạn như cấu trúc
nhúng - phải được sử dụng.

(Bên cạnh đó, đối với những người quen với việc triển khai danh sách liên kết kernel,
điều này tương tự như việc cấu trúc "list_head" hiếm khi hữu ích trên
của riêng họ, nhưng luôn luôn được tìm thấy trong các đối tượng lớn hơn của
lãi suất.)

Vì vậy, ví dụ, mã UIO trong ZZ0000ZZ có cấu trúc
xác định vùng bộ nhớ được liên kết với thiết bị uio::

cấu trúc uio_map {
            struct kobject kobj;
            cấu trúc uio_mem *mem;
    };

Nếu bạn có cấu trúc struct uio_map, việc tìm kobject được nhúng của nó là
chỉ là vấn đề sử dụng thành viên kobj.  Mã hoạt động với kobjects sẽ
Tuy nhiên, thường có vấn đề ngược lại: với một con trỏ struct kobject,
con trỏ tới cấu trúc chứa là gì?  Bạn phải tránh những thủ đoạn
(chẳng hạn như giả sử rằng kobject nằm ở đầu cấu trúc)
và thay vào đó, hãy sử dụng macro container_of(), được tìm thấy trong ZZ0000ZZ::

container_of(ptr, loại, thành viên)

Ở đâu:

* ZZ0000ZZ là con trỏ tới kobject được nhúng,
  * ZZ0001ZZ là loại cấu trúc chứa và
  * ZZ0002ZZ là tên của trường cấu trúc mà ZZ0003ZZ trỏ tới.

Giá trị trả về từ container_of() là một con trỏ tới giá trị tương ứng
loại thùng chứa. Vì vậy, ví dụ, một con trỏ ZZ0000ZZ tới một struct kobject
được nhúng ZZ0001ZZ, cấu trúc uio_map có thể được chuyển đổi thành một con trỏ tới
Cấu trúc uio_map ZZ0002ZZ với::

struct uio_map *u_map = container_of(kp, struct uio_map, kobj);

Để thuận tiện, các lập trình viên thường định nghĩa một macro đơn giản cho ZZ0001ZZ
con trỏ kobject tới kiểu chứa.  Chính xác điều này xảy ra trong
ZZ0000ZZ trước đó, như bạn có thể thấy ở đây::

cấu trúc uio_map {
            struct kobject kobj;
            cấu trúc uio_mem *mem;
    };

#define to_map(map) container_of(map, struct uio_map, kobj)

trong đó đối số macro "map" là một con trỏ tới struct kobject trong
câu hỏi.  Macro đó sau đó được gọi bằng::

struct uio_map *map = to_map(kobj);


Khởi tạo kobjects
==========================

Tất nhiên, mã tạo ra một kobject phải khởi tạo đối tượng đó. Một số
trong số các trường nội bộ được thiết lập bằng lệnh gọi (bắt buộc) tới kobject_init()::

void kobject_init(struct kobject *kobj, const struct kobj_type *ktype);

Ktype là bắt buộc để một kobject được tạo đúng cách, vì mọi kobject
phải có kobj_type liên quan.  Sau khi gọi kobject_init(), để
đăng ký kobject với sysfs, hàm kobject_add() phải được gọi ::

int kobject_add(struct kobject *kobj, struct kobject *parent,
                    const char *fmt, ...);

Điều này thiết lập cha của kobject và tên của kobject
đúng cách.  Nếu kobject được liên kết với một kset cụ thể,
kobj->kset phải được chỉ định trước khi gọi kobject_add().  Nếu một kset là
được liên kết với một kobject thì cấp độ gốc của kobject có thể được đặt thành
NULL trong lệnh gọi kobject_add() và sau đó cấp độ gốc của kobject sẽ là
kset chính nó.

Vì tên của kobject được đặt khi nó được thêm vào kernel nên tên
của kobject không bao giờ được thao tác trực tiếp.  Nếu bạn phải thay đổi
tên của kobject, gọi kobject_rename()::

int kobject_rename(struct kobject *kobj, const char *new_name);

kobject_rename() không thực hiện bất kỳ khóa nào hoặc có khái niệm chắc chắn về
tên nào hợp lệ nên người gọi phải tự kiểm tra độ tỉnh táo của mình
và tuần tự hóa.

Có một hàm gọi là kobject_set_name() nhưng đó là hàm kế thừa và
đang được gỡ bỏ.  Nếu mã của bạn cần gọi hàm này, thì đó là
sai và cần phải sửa.

Để truy cập đúng tên của kobject, hãy sử dụng hàm
kobject_name()::

const char ZZ0000ZZ kobj);

Có một hàm trợ giúp để khởi tạo và thêm kobject vào
kernel cùng một lúc, được gọi là đủ đáng ngạc nhiên kobject_init_and_add()::

int kobject_init_and_add(struct kobject *kobj, const struct kobj_type *ktype,
                             struct kobject *parent, const char *fmt, ...);

Các đối số giống như kobject_init() riêng lẻ và
các hàm kobject_add() được mô tả ở trên.


Sự kiện
=======

Sau khi một kobject đã được đăng ký với lõi kobject, bạn cần phải
thông báo với thế giới rằng nó đã được tạo ra.  Điều này có thể được thực hiện với một
gọi tới kobject_uevent()::

int kobject_uevent(struct kobject *kobj, enum kobject_action action);

Sử dụng hành động ZZ0000ZZ khi kobject được thêm vào kernel lần đầu tiên.
Điều này chỉ nên được thực hiện sau bất kỳ thuộc tính hoặc phần tử con nào của kobject
đã được khởi tạo đúng cách, vì không gian người dùng sẽ ngay lập tức bắt đầu trông giống như
cho họ khi cuộc gọi này diễn ra.

Khi kobject bị xóa khỏi kernel (chi tiết về cách thực hiện việc đó có
bên dưới), sự kiện cho ZZ0000ZZ sẽ được tạo tự động bởi
kobject core, vì vậy người gọi không phải lo lắng về việc đó bằng cách
tay.


Số lượng tham chiếu
===================

Một trong những chức năng chính của kobject là đóng vai trò là bộ đếm tham chiếu
cho đối tượng mà nó được nhúng vào. Miễn là tham chiếu đến đối tượng
tồn tại thì đối tượng (và mã hỗ trợ nó) phải tiếp tục tồn tại.
Các hàm cấp thấp để thao tác số lượng tham chiếu của kobject là::

struct kobject *kobject_get(struct kobject *kobj);
    void kobject_put(struct kobject *kobj);

Cuộc gọi thành công tới kobject_get() sẽ tăng tham chiếu của kobject
counter và trả về con trỏ cho kobject.

Khi một tham chiếu được giải phóng, lệnh gọi kobject_put() sẽ giảm
số lượng tham chiếu và có thể giải phóng đối tượng. Lưu ý rằng kobject_init()
đặt số lượng tham chiếu thành một, do đó mã thiết lập kobject sẽ
Cuối cùng cần phải thực hiện kobject_put() để giải phóng tham chiếu đó.

Vì kobject là động nên chúng không được khai báo tĩnh hoặc trên
ngăn xếp mà thay vào đó luôn được phân bổ động.  Các phiên bản tương lai của
kernel sẽ chứa phần kiểm tra thời gian chạy cho các kobject được tạo
tĩnh và sẽ cảnh báo nhà phát triển về việc sử dụng không đúng cách này.

Nếu tất cả những gì bạn muốn sử dụng kobject là cung cấp bộ đếm tham chiếu
đối với cấu trúc của bạn, vui lòng sử dụng struct kref thay thế; một kobject sẽ là
quá mức cần thiết.  Để biết thêm thông tin về cách sử dụng struct kref, vui lòng xem
tệp Documentation/core-api/kref.rst trong cây nguồn nhân Linux.


Tạo kobjects "đơn giản"
==========================

Đôi khi tất cả những gì nhà phát triển muốn là cách tạo một thư mục đơn giản
trong hệ thống phân cấp sysfs và không phải gặp rắc rối với toàn bộ sự phức tạp của
ksets, chức năng hiển thị và lưu trữ cũng như các chi tiết khác.  Đây là một trong những
ngoại lệ trong đó một kobject sẽ được tạo.  Để tạo ra một
nhập, sử dụng chức năng::

struct kobject *kobject_create_and_add(const char *name, struct kobject *parent);

Hàm này sẽ tạo một kobject và đặt nó vào sysfs ở vị trí
bên dưới kobject cha được chỉ định.  Để tạo các thuộc tính đơn giản
được liên kết với kobject này, hãy sử dụng::

int sysfs_create_file(struct kobject *kobj, const struct attribute *attr);

hoặc::

int sysfs_create_group(struct kobject *kobj, const struct attribute_group *grp);

Cả hai loại thuộc tính được sử dụng ở đây, với một kobject đã được tạo
với kobject_create_and_add(), có thể thuộc loại kobj_attribute, vì vậy không
thuộc tính tùy chỉnh đặc biệt là cần thiết để được tạo ra.

Xem mô-đun ví dụ, ZZ0000ZZ để biết
triển khai một kobject và thuộc tính đơn giản.



ktypes và phương thức phát hành
===============================

Một điều quan trọng vẫn còn thiếu trong cuộc thảo luận là điều gì sẽ xảy ra với một
kobject khi số tham chiếu của nó đạt tới 0. Đoạn mã đã tạo ra
kobject thường không biết khi nào điều đó sẽ xảy ra; nếu có thì ở đó
sẽ chẳng ích gì khi sử dụng kobject ngay từ đầu. Thậm chí
vòng đời của đối tượng có thể dự đoán được trở nên phức tạp hơn khi sysfs được đưa vào
vì các phần khác của kernel có thể lấy tham chiếu trên bất kỳ kobject nào
được đăng ký trong hệ thống.

Kết quả cuối cùng là cấu trúc được bảo vệ bởi kobject không thể được giải phóng
trước khi số tham chiếu của nó về 0. Số lượng tham chiếu không dưới
sự kiểm soát trực tiếp của mã đã tạo ra kobject. Vì vậy mã đó phải
được thông báo không đồng bộ bất cứ khi nào tham chiếu cuối cùng đến một trong các
kobjects biến mất.

Khi bạn đã đăng ký kobject của mình qua kobject_add(), bạn không bao giờ được sử dụng
kfree() để giải phóng nó trực tiếp. Cách an toàn duy nhất là sử dụng kobject_put(). Nó
cách tốt nhất là luôn sử dụng kobject_put() sau kobject_init() để tránh
lỗi đang len lỏi vào.

Thông báo này được thực hiện thông qua phương thức Release() của kobject. Thông thường
một phương thức như vậy có dạng như ::

void my_object_release(struct kobject *kobj)
    {
            struct my_object *mine = container_of(kobj, struct my_object, kobj);

/* Thực hiện bất kỳ thao tác dọn dẹp bổ sung nào trên đối tượng này, sau đó... */
            kfree(của tôi);
    }

Một điểm quan trọng không thể nói quá: mỗi kobject phải có một
phương thức Release() và kobject phải tồn tại (ở trạng thái nhất quán)
cho đến khi phương thức đó được gọi. Nếu những ràng buộc này không được đáp ứng, mã sẽ
thiếu sót. Lưu ý rằng kernel sẽ cảnh báo bạn nếu bạn quên cung cấp
phương thức phát hành().  Đừng cố gắng loại bỏ cảnh báo này bằng cách cung cấp một
chức năng phát hành "trống".

Nếu tất cả chức năng dọn dẹp của bạn cần làm là gọi kfree() thì bạn phải
tạo một hàm bao bọc sử dụng container_of() để cập nhật chính xác
gõ (như trong ví dụ trên) và sau đó gọi kfree() trên tổng thể
cấu trúc.

Lưu ý, tên của kobject có sẵn trong hàm phát hành, nhưng nó
NOT phải được thay đổi trong lệnh gọi lại này.  Nếu không sẽ có kỷ niệm
rò rỉ trong lõi kobject, khiến mọi người không hài lòng.

Điều thú vị là phương thức phát hành() không được lưu trữ trong chính kobject;
thay vào đó, nó được liên kết với ktype. Vậy hãy để chúng tôi giới thiệu struct
kobj_type::

cấu trúc kobj_type {
            khoảng trống (*release)(struct kobject *kobj);
            const struct sysfs_ops *sysfs_ops;
            const struct attribute_group **default_groups;
            const struct kobj_ns_type_Operation *(*child_ns_type)(struct kobject *kobj);
            const void *(*namespace)(struct kobject *kobj);
            khoảng trống (*get_ownership)(struct kobject *kobj, kuid_t *uid, kgid_t *gid);
    };

Cấu trúc này được sử dụng để mô tả một loại kobject cụ thể (hoặc, hơn thế nữa,
một cách chính xác, chứa đối tượng). Mỗi kobject cần phải có một liên kết
cấu trúc kobj_type; một con trỏ tới cấu trúc đó phải được chỉ định khi bạn
gọi kobject_init() hoặc kobject_init_and_add().

Tất nhiên, trường phát hành trong struct kobj_type là một con trỏ tới
Phương thức Release() cho loại kobject này. Hai trường còn lại (sysfs_ops
và default_groups) kiểm soát cách thể hiện các đối tượng thuộc loại này trong
sysfs; chúng nằm ngoài phạm vi của tài liệu này.

Con trỏ default_groups là danh sách các thuộc tính mặc định sẽ được
được tạo tự động cho bất kỳ kobject nào được đăng ký với ktype này.


bộ kset
=======

Một kset chỉ đơn thuần là một tập hợp các kobject muốn được liên kết với
lẫn nhau.  Không có hạn chế nào về việc chúng phải cùng loại ktype, nhưng phải
rất cẩn thận nếu không.

Một kset phục vụ các chức năng sau:

- Nó phục vụ như một túi chứa một nhóm đồ vật. Một kset có thể được sử dụng bởi
   hạt nhân để theo dõi "tất cả các thiết bị khối" hoặc "tất cả trình điều khiển thiết bị PCI."

- Kset cũng là một thư mục con trong sysfs, nơi chứa các kobject liên quan
   với kset có thể xuất hiện.  Mỗi kset chứa một kobject có thể
   được thiết lập để trở thành cha mẹ của các kobjects khác; các thư mục cấp cao nhất của
   hệ thống phân cấp sysfs được xây dựng theo cách này.

- Ksets có thể hỗ trợ việc "cắm nóng" kobjects và ảnh hưởng đến cách thức
   sự kiện sự kiện được báo cáo tới không gian người dùng.

Theo thuật ngữ hướng đối tượng, "kset" là lớp chứa cấp cao nhất; bộ kset
chứa kobject riêng của họ, nhưng kobject đó được quản lý bởi mã kset và
không nên bị thao túng bởi bất kỳ người dùng nào khác.

Một kset giữ các phần tử con của nó trong danh sách liên kết kernel tiêu chuẩn.  Điểm Kobjects
quay lại kset chứa chúng thông qua trường kset của chúng. Trong hầu hết các trường hợp,
các kobject thuộc một kset có kset đó (hoặc nói đúng hơn là nó được nhúng
kobject) trong cha mẹ của chúng.

Vì một kset chứa một kobject bên trong nó nên nó phải luôn ở trạng thái động
được tạo và không bao giờ được khai báo tĩnh hoặc trên ngăn xếp.  Để tạo một cái mới
sử dụng kset::

cấu trúc kset *kset_create_and_add(const char *name,
                                   const struct kset_uevent_ops *uevent_ops,
                                   struct kobject *parent_kobj);

Khi bạn kết thúc với kset, hãy gọi::

void kset_unregister(struct kset *k);

để tiêu diệt nó.  Thao tác này sẽ xóa kset khỏi sysfs và giảm tham chiếu của nó
đếm.  Khi số tham chiếu về 0, kset sẽ được giải phóng.
Vì các tham chiếu khác đến kset có thể vẫn tồn tại nên việc phát hành có thể xảy ra
sau khi kset_unregister() trả về.

Bạn có thể xem ví dụ về việc sử dụng kset trong
Tệp ZZ0000ZZ trong cây hạt nhân.

Nếu một kset muốn kiểm soát các hoạt động sự kiện của kobjects
được liên kết với nó, nó có thể sử dụng struct kset_uevent_ops để xử lý nó ::

cấu trúc kset_uevent_ops {
          int (* bộ lọc const)(struct kobject *kobj);
          const char ZZ0000ZZ tên const)(struct kobject *kobj);
          int (* const uevent)(struct kobject *kobj, struct kobj_uevent_env *env);
  };


Chức năng lọc cho phép kset ngăn chặn sự kiện được phát tới
không gian người dùng cho một kobject cụ thể.  Nếu hàm trả về 0 thì sự kiện
sẽ không được phát ra.

Hàm name sẽ được gọi để ghi đè tên mặc định của kset
mà sự kiện gửi đến không gian người dùng.  Theo mặc định, tên sẽ giống nhau
như chính kset, nhưng hàm này, nếu có, có thể ghi đè tên đó.

Hàm uevent sẽ được gọi khi uevent sắp được gửi tới
không gian người dùng để cho phép thêm nhiều biến môi trường hơn vào sự kiện.

Người ta có thể hỏi chính xác làm thế nào một kobject được thêm vào một kset, vì không có
đã trình bày các chức năng thực hiện chức năng đó.  Câu trả lời là
rằng tác vụ này được xử lý bởi kobject_add().  Khi một kobject được truyền tới
kobject_add(), thành viên kset của nó sẽ trỏ tới kset mà
kobject sẽ thuộc về.  kobject_add() sẽ xử lý phần còn lại.

Nếu kobject thuộc một kset không có tập kobject cha thì nó sẽ là
được thêm vào thư mục của kset.  Không phải tất cả thành viên của kset đều nhất thiết phải làm như vậy
sống trong thư mục kset.  Nếu một kobject cha rõ ràng được chỉ định
trước khi thêm kobject, kobject được đăng ký với kset, nhưng
được thêm vào bên dưới kobject gốc.


Loại bỏ đối tượng
=================

Sau khi một kobject được đăng ký thành công với lõi kobject, nó
phải được dọn sạch khi mã được hoàn thành với nó.  Để làm điều đó, hãy gọi
kobject_put().  Bằng cách này, lõi kobject sẽ tự động dọn sạch
tất cả bộ nhớ được phân bổ bởi kobject này.  Nếu sự kiện ZZ0000ZZ đã xảy ra
được gửi cho đối tượng, một sự kiện ZZ0001ZZ tương ứng sẽ được gửi và
mọi công việc dọn phòng sysfs khác sẽ được xử lý đúng cách cho người gọi.

Nếu bạn cần thực hiện xóa kobject theo hai giai đoạn (giả sử bạn không
được phép ngủ khi bạn cần tiêu diệt đối tượng), sau đó gọi
kobject_del() sẽ hủy đăng ký kobject khỏi sysfs.  Điều này làm cho
kobject "vô hình", nhưng nó không được dọn sạch và số lượng tham chiếu của
đối tượng vẫn như cũ.  Sau đó gọi kobject_put() để kết thúc
việc dọn dẹp bộ nhớ liên quan đến kobject.

kobject_del() có thể được sử dụng để loại bỏ tham chiếu đến đối tượng cha, nếu
tài liệu tham khảo vòng tròn được xây dựng.  Nó có giá trị trong một số trường hợp, rằng một
đối tượng cha mẹ tham chiếu đến một đứa trẻ.  Tham chiếu vòng tròn _phải_ bị hỏng
với lệnh gọi rõ ràng tới kobject_del(), do đó hàm phát hành sẽ được
được gọi và các vật thể trong vòng tròn trước sẽ thả nhau ra.


Mã ví dụ để sao chép từ
=========================

Để biết ví dụ đầy đủ hơn về cách sử dụng ksets và kobjects đúng cách, hãy xem
chương trình ví dụ ZZ0000ZZ,
sẽ được xây dựng dưới dạng mô-đun có thể tải nếu bạn chọn ZZ0001ZZ.
