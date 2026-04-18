.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/admin-guide/mm/userfaultfd.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

==============
lỗi người dùng
==============

Khách quan
=========

Lỗi người dùng cho phép thực hiện phân trang theo yêu cầu từ vùng người dùng
và nói chung hơn là chúng cho phép người dùng kiểm soát nhiều thứ khác nhau
lỗi trang bộ nhớ, điều mà chỉ có mã hạt nhân mới có thể làm được.

Ví dụ: lỗi do người dùng cho phép triển khai đúng cách và tối ưu hơn
của thủ thuật ZZ0000ZZ.

Thiết kế
======

Không gian người dùng tạo một userfaultfd mới, khởi tạo nó và đăng ký một hoặc nhiều
vùng bộ nhớ ảo với nó. Sau đó, bất kỳ lỗi trang nào xảy ra trong
(các) khu vực dẫn đến một thông báo được gửi tới userfaultfd, thông báo
không gian người dùng của lỗi.

ZZ0000ZZ (ngoài việc đăng ký và hủy đăng ký ảo
phạm vi bộ nhớ) cung cấp hai chức năng chính:

1) Giao thức ZZ0000ZZ để thông báo lỗi cho chuỗi người dùng
   xảy ra

2) các ioctls ZZ0000ZZ khác nhau có thể quản lý các vùng bộ nhớ ảo
   đã đăng ký trong ZZ0001ZZ cho phép người dùng sử dụng hiệu quả
   giải quyết các lỗi người dùng mà nó nhận được thông qua 1) hoặc để quản lý ảo
   bộ nhớ ở chế độ nền

Ưu điểm thực sự của lỗi người dùng nếu so sánh với bộ nhớ ảo thông thường
quản lý mremap/mprotect là lỗi của người dùng trong tất cả các
hoạt động không bao giờ liên quan đến các cấu trúc nặng như vmas (trên thực tế
Tải thời gian chạy ZZ0000ZZ không bao giờ lấy mmap_lock để ghi).
Vmas không phù hợp để theo dõi lỗi chi tiết của trang (hoặc trang lớn)
khi xử lý các không gian địa chỉ ảo có thể mở rộng
Terabyte. Sẽ cần quá nhiều vmas cho việc đó.

ZZ0000ZZ, sau khi được tạo, cũng có thể được
được chuyển bằng cách sử dụng ổ cắm miền unix tới quy trình quản lý, do đó, tương tự
quy trình quản lý có thể xử lý lỗi người dùng của vô số
các quá trình khác nhau mà họ không nhận thức được điều gì đang xảy ra
(tất nhiên trừ khi sau này họ thử sử dụng ZZ0001ZZ
trên cùng khu vực mà người quản lý đang theo dõi, điều này
là trường hợp góc hiện sẽ trả về ZZ0002ZZ).

API
===

Tạo một userfaultfd
----------------------

Có hai cách để tạo một userfaultfd mới, mỗi cách đều cung cấp các cách để
hạn chế quyền truy cập vào chức năng này (vì trong lịch sử userfaultfds
xử lý các lỗi trang kernel đã là một công cụ hữu ích để khai thác kernel).

Cách đầu tiên, được hỗ trợ kể từ khi userfaultfd được giới thiệu, là
cuộc gọi tòa nhà userfaultfd(2). Quyền truy cập vào phần này được kiểm soát theo nhiều cách:

- Bất kỳ người dùng nào cũng có thể tạo một userfaultfd để bẫy các lỗi trang không gian người dùng
  chỉ. Một userfaultfd như vậy có thể được tạo bằng cách sử dụng lệnh gọi tòa nhà userfaultfd(2)
  với lá cờ UFFD_USER_MODE_ONLY.

- Để bẫy các lỗi trang kernel cho không gian địa chỉ,
  quá trình cần khả năng CAP_SYS_PTRACE hoặc hệ thống phải có
  vm.unprivileged_userfaultfd được đặt thành 1. Theo mặc định, vm.unprivileged_userfaultfd
  được đặt thành 0.

Cách thứ hai, được thêm vào kernel gần đây hơn, là mở
/dev/userfaultfd và cấp USERFAULTFD_IOC_NEW ioctl cho nó. Phương pháp này
mang lại userfaultfds tương đương cho tòa nhà userfaultfd(2).

Không giống như userfaultfd(2), quyền truy cập vào/dev/userfaultfd được kiểm soát thông qua thông thường
quyền hệ thống tập tin (người dùng/nhóm/chế độ), cho phép truy cập chi tiết vào
userfaultfd cụ thể mà không cấp các đặc quyền không liên quan khác tại
cùng lúc (ví dụ: cấp CAP_SYS_PTRACE sẽ làm được). Người dùng có quyền truy cập
tới /dev/userfaultfd luôn có thể tạo userfaultfds để bẫy các lỗi trang kernel;
vm.unprivileged_userfaultfd không được xem xét.

Đang khởi tạo userfaultfd
--------------------------

Khi mở lần đầu tiên, ZZ0000ZZ phải được kích hoạt để gọi
ZZ0001ZZ ioctl chỉ định giá trị ZZ0002ZZ được đặt thành ZZ0003ZZ (hoặc
phiên bản API mới hơn) sẽ chỉ định giao thức ZZ0004ZZ
userland dự định nói chuyện về ZZ0005ZZ và ZZ0006ZZ
vùng đất người dùng yêu cầu. ZZ0007ZZ ioctl nếu thành công (tức là nếu
ZZ0008ZZ được yêu cầu cũng được đọc bởi kernel đang chạy và
các tính năng được yêu cầu sẽ được kích hoạt) sẽ trở lại
ZZ0009ZZ và ZZ0010ZZ hai bitmask 64bit của
tương ứng tất cả các tính năng có sẵn của giao thức read(2) và
ioctl chung có sẵn.

Mặt nạ bit ZZ0000ZZ được trả về bởi ZZ0001ZZ ioctl
xác định loại bộ nhớ nào được ZZ0002ZZ hỗ trợ và loại nào
các sự kiện, ngoại trừ thông báo lỗi trang, có thể được tạo:

- Cờ ZZ0000ZZ cho biết nhiều sự kiện khác
  khác với lỗi trang được hỗ trợ. Những sự kiện này được mô tả chi tiết hơn
  chi tiết bên dưới trong phần ZZ0001ZZ.

- ZZ0000ZZ và ZZ0001ZZ
  chỉ ra rằng kernel hỗ trợ ZZ0002ZZ
  đăng ký cho Hugetlbfs và bộ nhớ dùng chung (bao gồm tất cả các API shmem,
  tức là tmpfs, ZZ0003ZZ, ZZ0004ZZ, ZZ0005ZZ, ZZ0006ZZ,
  v.v.) vùng nhớ ảo tương ứng.

- ZZ0000ZZ chỉ ra rằng kernel hỗ trợ
  Đăng ký ZZ0001ZZ cho bộ nhớ ảo Hugetlbfs
  các khu vực. ZZ0002ZZ là tính năng tương tự cho biết
  hỗ trợ vùng nhớ ảo shmem.

- ZZ0000ZZ chỉ ra rằng kernel hỗ trợ di chuyển một
  nội dung trang hiện có từ không gian người dùng.

Ứng dụng vùng người dùng phải đặt các cờ tính năng mà nó dự định sử dụng
khi gọi ZZ0000ZZ ioctl, để yêu cầu các tính năng đó được
được kích hoạt nếu được hỗ trợ.

Khi ZZ0000ZZ API đã được kích hoạt, ZZ0001ZZ
ioctl nên được gọi (nếu có trong ZZ0002ZZ được trả về
bitmask) để đăng ký phạm vi bộ nhớ trong ZZ0003ZZ bằng cách đặt
cấu trúc uffdio_register tương ứng. ZZ0004ZZ
bitmask sẽ chỉ định cho kernel loại lỗi nào cần theo dõi
phạm vi. ZZ0005ZZ ioctl sẽ trả về
Bitmask ZZ0006ZZ của ioctls phù hợp để giải quyết
lỗi người dùng trên phạm vi đã đăng ký. Không phải tất cả ioctls đều nhất thiết phải như vậy
được hỗ trợ cho tất cả các loại bộ nhớ (ví dụ: bộ nhớ ẩn danh so với shmem so với bộ nhớ ẩn danh).
Hugetlbfs) hoặc tất cả các loại lỗi bị chặn.

Userland có thể sử dụng ZZ0000ZZ để quản lý ảo
không gian địa chỉ ở chế độ nền (để thêm hoặc có thể xóa
bộ nhớ từ phạm vi đã đăng ký ZZ0001ZZ). Điều này có nghĩa là lỗi người dùng
có thể được kích hoạt ngay trước khi bản đồ vùng người dùng ở chế độ nền
trang bị lỗi do người dùng.

Giải quyết lỗi người dùng
--------------------

Có ba cách cơ bản để giải quyết lỗi do người dùng:

- ZZ0000ZZ sao chép nguyên tử một số nội dung trang hiện có từ
  không gian người dùng.

- ZZ0000ZZ về nguyên tử số 0 trên trang mới.

- ZZ0000ZZ ánh xạ một trang hiện có, được điền trước đó.

Những hoạt động này mang tính nguyên tử theo nghĩa là chúng đảm bảo không gì có thể
thấy một trang được điền một nửa, vì người đọc sẽ tiếp tục mắc lỗi do người dùng cho đến khi
hoạt động đã kết thúc.

Theo mặc định, những lỗi này đánh thức các lỗi người dùng bị chặn trên phạm vi được đề cập.
Chúng hỗ trợ cờ ZZ0000ZZ ZZ0001ZZ, biểu thị
việc thức dậy đó sẽ được thực hiện riêng biệt vào một thời điểm sau đó.

Việc chọn ioctl nào tùy thuộc vào loại lỗi trang và những gì chúng tôi sẽ làm.
muốn làm gì để giải quyết nó:

- Đối với các lỗi ZZ0000ZZ, lỗi cần được
  được giải quyết bằng cách cung cấp một trang mới (ZZ0001ZZ) hoặc ánh xạ
  trang số 0 (ZZ0002ZZ). Theo mặc định, kernel sẽ ánh xạ
  trang 0 cho một lỗi bị thiếu. Với userfaultfd, không gian người dùng có thể
  quyết định nội dung nào cần cung cấp trước khi chuỗi lỗi tiếp tục.

- Đối với các lỗi ZZ0000ZZ, có một trang hiện có (trong
  bộ đệm trang). Không gian người dùng có tùy chọn sửa đổi trang
  nội dung trước khi giải quyết lỗi. Khi nội dung đã chính xác
  (có sửa đổi hay không), không gian người dùng yêu cầu kernel ánh xạ trang và để
  luồng lỗi tiếp tục với ZZ0001ZZ.

Ghi chú:

- Bạn có thể biết loại lỗi nào xảy ra bằng cách kiểm tra
  ZZ0000ZZ trong ZZ0001ZZ, đang kiểm tra
  Cờ ZZ0002ZZ.

- Không có ioctls phân phối trang nào mặc định trong phạm vi mà bạn
  đã đăng ký với.  Bạn phải điền vào tất cả các trường thích hợp
  cấu trúc ioctl bao gồm phạm vi.

- Bạn nhận được địa chỉ truy cập đã kích hoạt trang bị thiếu
  sự kiện ra khỏi cấu trúc uffd_msg mà bạn đã đọc trong chuỗi từ
  uffd.  Bạn có thể cung cấp bao nhiêu trang tùy thích với các IOCTL này.
  Hãy nhớ rằng trừ khi bạn sử dụng DONTWAKE thì đây là lựa chọn đầu tiên trong số
  những IOCTL đó đánh thức luồng bị lỗi.

- Hãy chắc chắn kiểm tra tất cả các lỗi bao gồm
  (ZZ0000ZZ).  Điều này có thể xảy ra, ví dụ. khi phạm vi
  được cung cấp không chính xác.

Viết thông báo bảo vệ
---------------------------

Điều này tương đương với (nhưng nhanh hơn) khi sử dụng mprotect và SIGSEGV
bộ xử lý tín hiệu.

Trước tiên, bạn cần đăng ký một phạm vi với ZZ0000ZZ.
Thay vì sử dụng mprotect(2) bạn sử dụng
ZZ0001ZZ
trong khi ZZ0002ZZ
trong cấu trúc được truyền vào. Phạm vi không mặc định và không
phải giống với phạm vi bạn đã đăng ký.  Bạn có thể viết
bảo vệ bao nhiêu phạm vi tùy thích (trong phạm vi đã đăng ký).
Sau đó, trong luồng đọc từ uffd, cấu trúc sẽ có
Bộ ZZ0003ZZ. Bây giờ bạn gửi
ZZ0004ZZ
một lần nữa trong khi ZZ0005ZZ không có ZZ0006ZZ
thiết lập. Điều này đánh thức luồng sẽ tiếp tục chạy bằng cách ghi. Cái này
cho phép bạn thực hiện việc ghi chép về việc viết trong bài đọc uffd
chủ đề trước ioctl.

Nếu bạn đã đăng ký với cả ZZ0000ZZ và
ZZ0001ZZ thì bạn cần suy nghĩ về trình tự trong
mà bạn cung cấp một trang và hoàn tác bảo vệ ghi.  Lưu ý rằng có một
sự khác biệt giữa việc ghi vào vùng WP và vào vùng !WP.  các
cái trước sẽ có bộ ZZ0002ZZ, cái sau
ZZ0003ZZ.  Cái sau không thất bại trong việc bảo vệ nhưng
bạn vẫn cần cung cấp một trang khi ZZ0004ZZ được
đã sử dụng.

Chế độ bảo vệ ghi Userfaultfd hiện hoạt động khác nhau trên không có điểm nào
(ví dụ: khi thiếu trang) trên các loại ký ức khác nhau.

Đối với bộ nhớ ẩn danh, ZZ0000ZZ sẽ không bỏ qua bất kỳ điểm nào
(ví dụ: khi các trang bị thiếu và không được điền).  Đối với những kỷ niệm được sao lưu bằng tập tin
như shmem và Hugetlbfs, không có ptes nào được bảo vệ chống ghi giống như
hiện tại  Nói cách khác sẽ xảy ra lỗi ghi userfaultfd
thông báo được tạo khi ghi vào một trang bị thiếu trên ký ức đã nhập tệp,
miễn là phạm vi trang được bảo vệ chống ghi trước đó.  Một tin nhắn như vậy sẽ
theo mặc định không được tạo trên bộ nhớ ẩn danh.

Nếu ứng dụng muốn có thể viết bảo vệ không có điểm nào trên ẩn danh
bộ nhớ, người ta có thể điền trước bộ nhớ bằng ví dụ: MADV_POPULATE_READ.  Bật
hạt nhân mới hơn, người ta cũng có thể phát hiện tính năng UFFD_FEATURE_WP_UNPOPULATED
và đặt trước bit tính năng để đảm bảo không có điểm nào cũng sẽ được
ghi được bảo vệ ngay cả trên bộ nhớ ẩn danh.

Khi sử dụng ZZ0000ZZ kết hợp với một trong hai
ZZ0001ZZ hoặc ZZ0002ZZ, khi
giải quyết các lỗi thiếu / lỗi nhỏ với ZZ0003ZZ hoặc ZZ0004ZZ
tương ứng, có thể mong muốn trang/ánh xạ mới được
được bảo vệ chống ghi (vì vậy việc ghi trong tương lai cũng sẽ dẫn đến lỗi WP). Những ioctl này
hỗ trợ cờ chế độ (ZZ0005ZZ hoặc ZZ0006ZZ
tương ứng) để định cấu hình ánh xạ theo cách này.

Nếu bối cảnh userfaultfd có bộ bit tính năng ZZ0000ZZ,
bất kỳ vma nào được đăng ký với tính năng chống ghi sẽ hoạt động ở chế độ không đồng bộ
hơn chế độ đồng bộ mặc định.

Ở chế độ không đồng bộ, sẽ không có thông báo nào được tạo khi thao tác ghi
xảy ra, trong khi đó việc bảo vệ ghi sẽ được giải quyết tự động bằng cách
hạt nhân.  Nó có thể được coi là một phiên bản chính xác hơn của soft-dirty
theo dõi và nó có thể khác nhau theo một số cách:

- Kết quả bẩn sẽ không bị ảnh hưởng bởi những thay đổi của vma (ví dụ: vma
    sáp nhập) vì dirty chỉ được theo dõi bởi pte.

- Nó hỗ trợ các hoạt động phạm vi theo mặc định, vì vậy người ta có thể bật theo dõi
    bất kỳ phạm vi bộ nhớ nào miễn là trang được căn chỉnh.

- Thông tin bẩn sẽ không bị mất nếu pte bị hạ gục do
    nhiều lý do khác nhau (ví dụ: trong quá trình chia tách một trang lớn trong suốt shmem).

- Do đảo ngược nghĩa soft-dirty (trang sẽ sạch khi uffd-wp bit
    thiết lập; bẩn khi xóa bit uffd-wp), nó có ngữ nghĩa khác nhau trên
    một số thao tác bộ nhớ.  Ví dụ: ZZ0000ZZ bật
    ẩn danh (hoặc ZZ0001ZZ trên ánh xạ tệp) sẽ được coi là
    làm bẩn bộ nhớ bằng cách bỏ bit uffd-wp trong quá trình thực hiện.

Ứng dụng người dùng có thể thu thập trạng thái "đã viết/bẩn" bằng cách tra cứu
uffd-wp cho các trang đang quan tâm đến /proc/pagemap.

Trang sẽ không được theo dõi ở chế độ không đồng bộ uffd-wp cho đến khi trang được
được bảo vệ chống ghi rõ ràng bởi ZZ0000ZZ với chế độ
bộ cờ ZZ0001ZZ.  Đang cố gắng giải quyết lỗi trang
được theo dõi bởi chế độ không đồng bộ userfaultfd-wp không hợp lệ.

Khi chế độ không đồng bộ userfaultfd-wp được sử dụng một mình, nó có thể được áp dụng cho tất cả
các loại trí nhớ.

Mô phỏng ngộ độc bộ nhớ
---------------------------

Để phản hồi một lỗi (thiếu hoặc lỗi nhỏ), không gian người dùng hành động có thể
thực hiện để "giải quyết" đó là cấp ZZ0000ZZ. Điều này sẽ gây ra bất kỳ
những người mắc lỗi trong tương lai sẽ nhận được SIGBUS hoặc trong trường hợp của KVM, khách sẽ
nhận được MCE như thể bị ngộ độc bộ nhớ phần cứng.

Điều này được sử dụng để mô phỏng ngộ độc bộ nhớ phần cứng. Hãy tưởng tượng một máy ảo chạy trên một
máy gặp lỗi bộ nhớ phần cứng thực sự. Sau này chúng tôi sống di cư
VM sang một máy vật lý khác. Vì chúng tôi muốn quá trình di chuyển diễn ra
minh bạch đối với khách, chúng tôi muốn dải địa chỉ đó hoạt động như thể nó được
vẫn bị nhiễm độc, mặc dù nó nằm trên một vật chủ vật lý mới mà bề ngoài có vẻ như
không có lỗi bộ nhớ ở cùng một chỗ.

QEMU/KVM
========

QEMU/KVM đang sử dụng tòa nhà ZZ0000ZZ để triển khai sao chép trực tiếp
di cư. Di chuyển trực tiếp sau sao chép là một dạng bộ nhớ
ngoại hóa bao gồm một máy ảo chạy với một phần hoặc
tất cả bộ nhớ của nó nằm trên một nút khác trên đám mây. các
Sự trừu tượng hóa ZZ0001ZZ đủ chung chung để không một dòng nào
Mã hạt nhân KVM phải được sửa đổi để thêm bản sao trực tiếp
di chuyển sang QEMU.

Lỗi trang không đồng bộ của khách, ZZ0000ZZ và tất cả các tính năng ZZ0001ZZ khác đều hoạt động
chỉ tốt khi kết hợp với lỗi người dùng. Lỗi người dùng kích hoạt không đồng bộ
lỗi trang trong bộ lập lịch của khách nên những quy trình khách đó
không chờ lỗi người dùng (tức là mạng bị ràng buộc) có thể tiếp tục chạy trong
khách vcpus.

Nhìn chung sẽ có lợi khi chạy một lượt di chuyển trực tiếp trước bản sao
ngay trước khi bắt đầu di chuyển trực tiếp sau sao chép, để tránh
tạo ra lỗi người dùng cho các vùng khách chỉ đọc.

Việc triển khai di chuyển trực tiếp qua postcopy hiện đang sử dụng một
ổ cắm hai chiều duy nhất nhưng trong tương lai có hai ổ cắm khác nhau
sẽ được sử dụng (để giảm độ trễ của lỗi người dùng xuống mức tối thiểu
có thể mà không cần phải giảm ZZ0000ZZ).

QEMU trong nút nguồn ghi tất cả các trang mà nó biết là bị thiếu
trong nút đích, vào ổ cắm và luồng di chuyển của
QEMU đang chạy trong nút đích chạy ZZ0000ZZ
ioctls trên ZZ0001ZZ để ánh xạ các trang đã nhận vào
khách (ZZ0002ZZ được sử dụng nếu trang nguồn là trang số 0).

Một luồng postcopy khác trong nút đích lắng nghe với
poll() song song với ZZ0000ZZ. Khi xảy ra sự kiện ZZ0001ZZ
được tạo sau khi kích hoạt lỗi người dùng, luồng postcopy read() từ
ZZ0002ZZ và nhận địa chỉ lỗi (hoặc ZZ0003ZZ trong trường hợp
lỗi người dùng đã được giải quyết và được đánh thức bằng lần chạy ZZ0004ZZ
bởi luồng di chuyển QEMU song song).

Sau khi luồng postcopy QEMU (chạy ở nút đích) được
địa chỉ lỗi người dùng nó ghi thông tin về trang bị thiếu
vào ổ cắm. Nút nguồn QEMU nhận thông tin và
đại khái "tìm kiếm" địa chỉ trang đó và tiếp tục gửi tất cả
các trang bị thiếu còn lại từ phần bù trang mới đó. Ngay sau đó
(đúng lúc để đẩy hàng đợi tcp_wmem qua mạng)
luồng di chuyển trong QEMU đang chạy ở nút đích sẽ
nhận trang đã kích hoạt lỗi người dùng và nó sẽ ánh xạ nó dưới dạng
thông thường với ZZ0000ZZ (mà không thực sự biết liệu nó có
được gửi tự phát bởi nguồn hoặc nếu đó là một trang khẩn cấp
được yêu cầu thông qua lỗi người dùng).

Vào thời điểm lỗi người dùng bắt đầu, QEMU ở nút đích
không cần giữ bất kỳ bitmap trạng thái trên mỗi trang nào so với trực tiếp
di chuyển xung quanh và một bitmap mỗi trang phải được duy trì trong
QEMU đang chạy trong nút nguồn để biết trang nào vẫn còn
thiếu ở nút đích. Bitmap trong nút nguồn là
đã kiểm tra để tìm những trang bị thiếu để gửi đi và chúng tôi tìm kiếm
qua nó khi nhận được lỗi người dùng gửi đến. Sau khi gửi từng trang của
Tất nhiên bitmap được cập nhật tương ứng. Nó cũng hữu ích để tránh
gửi cùng một trang hai lần (trong trường hợp lỗi người dùng được đọc bởi
luồng postcopy ngay trước khi ZZ0000ZZ chạy trong quá trình di chuyển
chủ đề).

userfaultfd không hợp tác
===========================

Khi ZZ0000ZZ được giám sát bởi người quản lý bên ngoài, người quản lý
phải có khả năng theo dõi những thay đổi trong quá trình bộ nhớ ảo
bố cục. Userfaultfd có thể thông báo cho người quản lý về những thay đổi đó bằng cách sử dụng
giao thức đọc (2) tương tự như đối với thông báo lỗi trang. các
người quản lý phải kích hoạt rõ ràng những sự kiện này bằng cách thiết lập thích hợp
các bit trong ZZ0001ZZ được chuyển tới ZZ0002ZZ ioctl:

ZZ0000ZZ
	bật móc ZZ0001ZZ cho fork(). Khi tính năng này được
	được bật, bối cảnh ZZ0002ZZ của tiến trình gốc là
	được sao chép vào quy trình mới được tạo. Người quản lý
	nhận ZZ0003ZZ với bộ mô tả tệp mới
	Bối cảnh ZZ0004ZZ trong ZZ0005ZZ.

ZZ0000ZZ
	bật thông báo về cuộc gọi mremap(). Khi
	quá trình không hợp tác sẽ di chuyển một vùng bộ nhớ ảo tới một
	địa điểm khác, người quản lý sẽ nhận được
	ZZ0001ZZ. ZZ0002ZZ sẽ chứa cái cũ và
	địa chỉ mới của khu vực và chiều dài ban đầu của nó.

ZZ0000ZZ
	bật thông báo về madvise(MADV_REMOVE) và
	cuộc gọi madvise(MADV_DONTNEED). Sự kiện ZZ0001ZZ sẽ
	được tạo ra dựa trên các lệnh gọi tới madvise() này. ZZ0002ZZ
	sẽ chứa địa chỉ bắt đầu và kết thúc của khu vực bị xóa.

ZZ0000ZZ
	bật thông báo về việc hủy ánh xạ bộ nhớ. Người quản lý sẽ
	nhận ZZ0001ZZ với ZZ0002ZZ chứa phần bắt đầu và
	địa chỉ cuối của khu vực chưa được ánh xạ.

Mặc dù ZZ0000ZZ và ZZ0001ZZ
khá giống nhau, chúng khá khác nhau về hành động được mong đợi từ
Người quản lý ZZ0002ZZ. Trong trường hợp trước, bộ nhớ ảo được
bị loại bỏ, nhưng khu vực đó thì không, khu vực đó vẫn được giám sát bởi
ZZ0003ZZ và nếu xảy ra lỗi trang ở khu vực đó thì đó sẽ là
giao cho người quản lý. Độ phân giải thích hợp cho lỗi trang đó là
để zeromap địa chỉ lỗi. Tuy nhiên, trong trường hợp sau, khi một
khu vực chưa được ánh xạ, rõ ràng (với lệnh gọi hệ thống munmap()) hoặc
ngầm (ví dụ: trong mremap()), khu vực này sẽ bị xóa và đến lượt
Bối cảnh ZZ0004ZZ cho khu vực đó cũng biến mất và người quản lý sẽ
không nhận thêm lỗi trang người dùng từ khu vực đã xóa. Tuy nhiên,
cần phải thông báo để ngăn người quản lý sử dụng
ZZ0005ZZ trên khu vực chưa được lập bản đồ.

Không giống như các lỗi trang người dùng phải đồng bộ và yêu cầu
đánh thức rõ ràng hoặc ngầm định, tất cả các sự kiện được phân phối
không đồng bộ và quá trình không hợp tác tiếp tục thực hiện như
ngay khi người quản lý thực hiện read(). Người quản lý ZZ0000ZZ nên
đồng bộ hóa cẩn thận các cuộc gọi đến ZZ0001ZZ với các sự kiện
xử lý. Để hỗ trợ đồng bộ hóa, ZZ0002ZZ ioctl sẽ
trả về ZZ0003ZZ khi quá trình được giám sát thoát tại thời điểm
ZZ0004ZZ và ZZ0005ZZ, khi quy trình không hợp tác đã thay đổi
bố trí bộ nhớ ảo của nó đồng thời với ZZ0006ZZ nổi bật
hoạt động.

Mô hình phân phối sự kiện không đồng bộ hiện tại là tối ưu cho
triển khai trình quản lý ZZ0000ZZ không hợp tác theo luồng đơn. A
mô hình phân phối sự kiện đồng bộ có thể được thêm vào sau dưới dạng mô hình mới
Tính năng ZZ0001ZZ để hỗ trợ cải tiến đa luồng của
người quản lý không hợp tác, ví dụ như cho phép ZZ0002ZZ ioctls
chạy song song với việc tiếp nhận sự kiện. Sợi đơn
việc triển khai nên tiếp tục sử dụng sự kiện không đồng bộ hiện tại
thay vào đó là mô hình giao hàng.
