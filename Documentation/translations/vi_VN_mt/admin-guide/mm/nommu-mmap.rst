.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/admin-guide/mm/nommu-mmap.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

================================
Hỗ trợ ánh xạ bộ nhớ No-MMU
================================

Hạt nhân có hỗ trợ hạn chế cho việc ánh xạ bộ nhớ trong các điều kiện không có MMU, chẳng hạn như
như được sử dụng trong môi trường uClinux. Từ quan điểm không gian người dùng, bộ nhớ
ánh xạ được sử dụng cùng với lệnh gọi hệ thống mmap(), shmat()
call và lệnh gọi hệ thống execve(). Từ quan điểm của kernel, execve()
ánh xạ thực sự được thực hiện bởi trình điều khiển binfmt, gọi lại vào
mmap() để thực hiện công việc thực tế.

Hành vi ánh xạ bộ nhớ cũng liên quan đến cách thức fork(), vfork(), clone() và
ptrace() hoạt động. Trong uClinux không có fork() và phải được cung cấp clone()
cờ CLONE_VM.

Hành vi tương tự giữa các trường hợp MMU và no-MMU, nhưng không giống nhau;
và nó cũng bị hạn chế hơn nhiều trong trường hợp sau:

(#) Ánh xạ ẩn danh, MAP_PRIVATE

Trong trường hợp MMU: Các vùng VM được hỗ trợ bởi các trang tùy ý; sao chép khi ghi
	qua ngã ba.

Trong trường hợp không có MMU: Các vùng VM được hỗ trợ bởi các hoạt động liền kề tùy ý
	trang.

(#) Ánh xạ ẩn danh, MAP_SHARED

Chúng hoạt động rất giống với ánh xạ riêng tư, ngoại trừ việc chúng
	được chia sẻ trên fork() hoặc clone() mà không có CLONE_VM trong trường hợp MMU. Kể từ khi
	trường hợp no-MMU không hỗ trợ những điều này, hành vi giống hệt với
	MAP_PRIVATE đấy.

(#) Tệp, MAP_PRIVATE, PROT_READ / PROT_EXEC, !PROT_WRITE

Trong trường hợp MMU: Các vùng VM được hỗ trợ bởi các trang được đọc từ tệp; thay đổi thành
	tệp cơ bản được phản ánh trong ánh xạ; được sao chép qua ngã ba.

Trong trường hợp không có MMU:

- Nếu có, kernel sẽ sử dụng lại ánh xạ hiện có tới
           cùng một phân đoạn của cùng một tệp nếu có quyền tương thích,
           ngay cả khi điều này được tạo ra bởi một quá trình khác.

- Nếu có thể, việc ánh xạ tập tin sẽ được thực hiện trực tiếp trên thiết bị sao lưu
           nếu thiết bị hỗ trợ có khả năng NOMMU_MAP_DIRECT và
           khả năng bảo vệ bản đồ thích hợp. Ramf, romf, cramf
           và mtd đều có thể cho phép điều này.

- Nếu thiết bị sao lưu không thể hoặc không cho phép chia sẻ trực tiếp,
           nhưng có khả năng NOMMU_MAP_COPY thì một bản sao của
           bit thích hợp của tập tin sẽ được đọc thành một bit liền kề của
           bộ nhớ và mọi không gian không liên quan ngoài EOF sẽ bị xóa

- Ghi vào tập tin không ảnh hưởng đến ánh xạ; ghi vào bản đồ
	   có thể nhìn thấy trong các quy trình khác (không có bảo vệ MMU), nhưng không nên
	   xảy ra.

(#) Tệp, MAP_PRIVATE, PROT_READ / PROT_EXEC, PROT_WRITE

Trong trường hợp MMU: giống như trường hợp không phải PROT_WRITE, ngoại trừ các trang trong
	câu hỏi được sao chép trước khi việc viết thực sự xảy ra. Từ thời điểm đó
	khi ghi vào tệp bên dưới trang đó không còn được phản ánh vào
	các trang hỗ trợ của bản đồ. Thay vào đó, trang này được hỗ trợ bằng trao đổi.

Trong trường hợp không có MMU: hoạt động giống như trường hợp không phải PROT_WRITE, ngoại trừ
	rằng một bản sao luôn được lấy và không bao giờ được chia sẻ.

(#) Tệp thông thường / blockdev, MAP_SHARED, PROT_READ / PROT_EXEC / PROT_WRITE

Trong trường hợp MMU: Các vùng VM được hỗ trợ bởi các trang được đọc từ tệp; thay đổi thành
	các trang được ghi lại vào tập tin; ghi vào tập tin phản ánh vào trang sao lưu
	lập bản đồ; được chia sẻ qua ngã ba.

Trong trường hợp no-MMU: không được hỗ trợ.

(#) Tệp thông thường được hỗ trợ bộ nhớ, MAP_SHARED, PROT_READ / PROT_EXEC / PROT_WRITE

Trong trường hợp MMU: Như đối với các file thông thường.

Trong trường hợp no-MMU: Hệ thống tệp cung cấp tệp được hỗ trợ bởi bộ nhớ
	(chẳng hạn như ramfs hoặc tmpfs) có thể chọn tôn vinh một mở, cắt ngắn, mmap
	bằng cách cung cấp một chuỗi các trang liền kề để ánh xạ. Trong đó
	trong trường hợp này, có thể thực hiện ánh xạ bộ nhớ có thể ghi chung. Nó sẽ hoạt động
	đối với trường hợp MMU. Nếu hệ thống tập tin không cung cấp bất kỳ điều gì như vậy
	hỗ trợ thì yêu cầu ánh xạ sẽ bị từ chối.

(#) Blockdev được hỗ trợ bộ nhớ, MAP_SHARED, PROT_READ / PROT_EXEC / PROT_WRITE

Trong trường hợp MMU: Như đối với các file thông thường.

Trong trường hợp no-MMU: Đối với các tệp thông thường được hỗ trợ bằng bộ nhớ, nhưng
	blockdev phải có khả năng cung cấp một loạt trang liền kề mà không cần
	cắt ngắn được gọi. Trình điều khiển ramdisk có thể làm điều này nếu nó được phân bổ
	tất cả bộ nhớ của nó dưới dạng một mảng liền kề trả trước.

(#) Chardev được hỗ trợ bộ nhớ, MAP_SHARED, PROT_READ / PROT_EXEC / PROT_WRITE

Trong trường hợp MMU: Như đối với các file thông thường.

Trong trường hợp no-MMU: Trình điều khiển thiết bị nhân vật có thể chọn vinh danh
	mmap() bằng cách cung cấp quyền truy cập trực tiếp vào thiết bị cơ bản nếu nó
	cung cấp bộ nhớ hoặc bộ nhớ gần như có thể được truy cập trực tiếp. Ví dụ
	trong số đó có bộ đệm khung và thiết bị flash. Nếu người lái xe không
	cung cấp bất kỳ hỗ trợ nào như vậy thì yêu cầu ánh xạ sẽ bị từ chối.


Ghi chú thêm về no-MMU MMAP
============================

(#) Yêu cầu ánh xạ riêng tư của tệp có thể trả về bộ đệm không
     căn chỉnh theo trang.  Điều này là do XIP có thể xảy ra và dữ liệu có thể không được
     phân trang được căn chỉnh trong cửa hàng hỗ trợ.

(#) Yêu cầu ánh xạ ẩn danh sẽ luôn được căn chỉnh theo trang.  Nếu
     có thể kích thước của yêu cầu phải là lũy thừa của hai nếu không thì một số
     không gian có thể bị lãng phí vì hạt nhân phải phân bổ lũy thừa 2
     dạng hạt nhưng sẽ chỉ loại bỏ phần dư thừa nếu được cấu hình phù hợp như
     điều này có ảnh hưởng đến sự phân mảnh.

(#) Bộ nhớ được phân bổ theo yêu cầu ánh xạ ẩn danh thường sẽ
     được xóa bởi kernel trước khi được trả về theo quy định
     Trang man Linux (phiên bản 2.22 trở lên).

Trong trường hợp MMU, điều này có thể đạt được với hiệu suất hợp lý như
     các vùng được hỗ trợ bởi các trang ảo, với nội dung chỉ được ánh xạ
     để xóa các trang vật lý khi việc ghi xảy ra trên trang cụ thể đó
     (trước đó, các trang được ánh xạ một cách hiệu quả tới trang số 0 toàn cầu
     từ đó việc đọc có thể diễn ra).  Điều này trải rộng thời gian cần thiết để
     khởi tạo nội dung của một trang - tùy thuộc vào cách sử dụng ghi của
     lập bản đồ.

Tuy nhiên, trong trường hợp no-MMU, ánh xạ ẩn danh được hỗ trợ bởi vật lý
     các trang và toàn bộ bản đồ sẽ bị xóa vào thời điểm phân bổ.  Điều này có thể gây ra
     độ trễ đáng kể trong không gian người dùng malloc() khi thư viện C thực hiện
     ánh xạ ẩn danh và hạt nhân sau đó thực hiện một bộ nhớ cho toàn bộ bản đồ.

Tuy nhiên, đối với bộ nhớ không cần phải xóa trước - chẳng hạn như
     được trả về bởi malloc() - mmap() có thể lấy cờ MAP_UNINITIALIZED để
     chỉ báo cho kernel rằng nó không nên bận tâm đến việc xóa bộ nhớ trước đó
     trả lại nó.  Lưu ý rằng CONFIG_MMAP_ALLOW_UNINITIALIZED phải được kích hoạt
     cho phép điều này, nếu không cờ sẽ bị bỏ qua.

uClibc sử dụng điều này để tăng tốc malloc() và ELF-FDPIC binfmt sử dụng điều này
     để phân bổ vùng brk và ngăn xếp.

(#) Danh sách tất cả các bản sao riêng tư và ánh xạ ẩn danh trên hệ thống là
     hiển thị qua /proc/maps ở chế độ no-MMU.

(#) Danh sách tất cả các ánh xạ được sử dụng bởi một quy trình được hiển thị thông qua
     /proc/<pid>/maps ở chế độ no-MMU.

(#) Việc cung cấp MAP_FIXED hoặc yêu cầu một địa chỉ ánh xạ cụ thể sẽ
     dẫn đến một lỗi.

(#) Các tệp được ánh xạ riêng tư thường phải có phương thức đọc được cung cấp bởi
     trình điều khiển hoặc hệ thống tập tin để nội dung có thể được đọc vào bộ nhớ
     được phân bổ nếu mmap() chọn không ánh xạ trực tiếp thiết bị sao lưu. Một
     sẽ xảy ra lỗi nếu không. Điều này rất có thể gặp phải
     với các tập tin thiết bị ký tự, đường ống, fifos và ổ cắm.


Bộ nhớ chia sẻ giữa các quá trình
=================================

Cả bộ nhớ chia sẻ SYSV IPC SHM và bộ nhớ chia sẻ POSIX đều được hỗ trợ trong NOMMU
chế độ.  Cái trước thông qua cơ chế thông thường, cái sau thông qua các tập tin được tạo
trên các khung ramfs hoặc tmpfs.


Futexes
=======

Futexes được hỗ trợ ở chế độ NOMMU nếu vòm hỗ trợ chúng.  Một lỗi sẽ
được cung cấp nếu một địa chỉ được truyền tới lệnh gọi hệ thống futex nằm bên ngoài
ánh xạ được thực hiện bởi một quy trình hoặc nếu ánh xạ chứa địa chỉ không
hỗ trợ futexes (chẳng hạn như ánh xạ chardev I/O).


Sơ đồ bản đồ No-MMU
===================

Hàm mremap() được hỗ trợ một phần.  Nó có thể thay đổi kích thước của một
ánh xạ và có thể di chuyển nó [#]_ nếu MREMAP_MAYMOVE được chỉ định và nếu kích thước mới
của ánh xạ vượt quá kích thước của đối tượng bản sàn hiện đang bị chiếm giữ bởi
bộ nhớ mà ánh xạ tham chiếu tới hoặc liệu có thể sử dụng một đối tượng bản sàn nhỏ hơn hay không.

MREMAP_FIXED không được hỗ trợ, tuy nhiên nó sẽ bị bỏ qua nếu không có thay đổi nào về
địa chỉ và đối tượng không cần phải di chuyển.

Ánh xạ được chia sẻ có thể không được di chuyển.  Các ánh xạ có thể chia sẻ cũng không thể được di chuyển,
ngay cả khi chúng hiện không được chia sẻ.

Hàm mremap() phải khớp chính xác với địa chỉ cơ sở và kích thước của
một đối tượng được ánh xạ trước đó.  Nó có thể không được sử dụng để tạo ra các lỗ hổng trong
ánh xạ, di chuyển các phần của ánh xạ hiện có hoặc thay đổi kích thước các phần của ánh xạ.  Nó phải
hành động trên một bản đồ hoàn chỉnh.

.. [#] Not currently supported.


Cung cấp hỗ trợ thiết bị nhân vật có thể chia sẻ
================================================

Để cung cấp hỗ trợ thiết bị ký tự có thể chia sẻ, trình điều khiển phải cung cấp một
hoạt động file->f_op->get_unmapped_area(). Các thói quen mmap() sẽ gọi cái này
để có được địa chỉ được đề xuất cho bản đồ. Điều này có thể trả về lỗi nếu nó
không muốn tôn vinh bản đồ vì nó quá dài, ở một độ lệch kỳ lạ,
dưới một số sự kết hợp cờ không được hỗ trợ hoặc bất cứ điều gì.

Người lái xe cũng phải cung cấp thông tin thiết bị hỗ trợ với các khả năng được thiết lập
để chỉ ra các loại ánh xạ được phép trên các thiết bị đó. Mặc định là
được coi là có thể đọc và ghi được, không thể thực thi được và chỉ có thể chia sẻ được
trực tiếp (không thể sao chép).

Thao tác file->f_op->mmap() sẽ được gọi để thực sự bắt đầu
lập bản đồ. Nó có thể bị từ chối vào thời điểm đó. Việc trả lại lỗi ENOSYS sẽ
thay vào đó, hãy sao chép ánh xạ nếu NOMMU_MAP_COPY được chỉ định.

Thói quen vm_ops->close() sẽ được gọi khi ánh xạ cuối cùng trên chardev
được gỡ bỏ. Bản đồ hiện có sẽ được chia sẻ, một phần hoặc không, nếu có thể
mà không thông báo cho tài xế.

Thao tác file->f_op->get_unmapped_area() cũng được phép thực hiện
trả về -ENOSYS. Điều này sẽ được hiểu là hoạt động này không
muốn xử lý nó, mặc dù thực tế là nó đang được phẫu thuật. Ví dụ, nó
có thể thử chuyển hướng cuộc gọi đến trình điều khiển phụ nhưng hóa ra lại không
thực hiện nó. Đó là trường hợp của trình điều khiển bộ đệm khung cố gắng
chuyển cuộc gọi đến trình điều khiển dành riêng cho thiết bị. Trong hoàn cảnh như vậy, việc
yêu cầu ánh xạ sẽ bị từ chối nếu NOMMU_MAP_COPY không được chỉ định và
sao chép ánh xạ khác.

.. important::

	Some types of device may present a different appearance to anyone
	looking at them in certain modes. Flash chips can be like this; for
	instance if they're in programming or erase mode, you might see the
	status reflected in the mapping, instead of the data.

	In such a case, care must be taken lest userspace see a shared or a
	private mapping showing such information when the driver is busy
	controlling the device. Remember especially: private executable
	mappings may still be mapped directly off the device under some
	circumstances!


Cung cấp hỗ trợ tập tin dựa trên bộ nhớ có thể chia sẻ
======================================================

Việc cung cấp ánh xạ chia sẻ trên các tệp được hỗ trợ bằng bộ nhớ tương tự như việc cung cấp
hỗ trợ cho các thiết bị ký tự được ánh xạ chung. Sự khác biệt chính là
hệ thống tập tin cung cấp dịch vụ có thể sẽ phân bổ một bộ sưu tập liền kề
của các trang và cho phép ánh xạ được thực hiện trên đó.

Chúng tôi khuyên bạn nên áp dụng thao tác cắt ngắn cho một tệp như vậy
tăng kích thước tệp, nếu tệp đó trống, được coi là yêu cầu thu thập
đủ trang để tôn vinh một bản đồ. Điều này là cần thiết để hỗ trợ chia sẻ POSIX
trí nhớ.

Các thiết bị hỗ trợ bộ nhớ được biểu thị bằng thông tin thiết bị sao lưu của ánh xạ có
cờ bộ nhớ được đặt.


Cung cấp hỗ trợ thiết bị khối có thể chia sẻ
============================================

Việc cung cấp ánh xạ chia sẻ trên các tệp thiết bị khối hoàn toàn giống như đối với
thiết bị nhân vật. Nếu bên dưới không có thiết bị thật thì driver
nên phân bổ đủ bộ nhớ liền kề để tôn vinh mọi ánh xạ được hỗ trợ.


Điều chỉnh hành vi cắt trang
=================================

NOMMU mmap tự động làm tròn số trang có lũy thừa 2 gần nhất
khi thực hiện phân bổ.  Điều này có thể gây ảnh hưởng xấu tới trí nhớ
phân mảnh, và do đó, có thể cấu hình được.  Hành vi mặc định là
tích cực cắt bớt phân bổ và loại bỏ mọi trang thừa trở lại trang
người cấp phát.  Để duy trì khả năng kiểm soát chi tiết hơn đối với sự phân mảnh, điều này
hành vi có thể bị vô hiệu hóa hoàn toàn hoặc được đưa lên trang cao hơn
hình mờ nơi bắt đầu cắt tỉa.

Hành vi cắt trang có thể được cấu hình thông qua sysctl ZZ0000ZZ.
