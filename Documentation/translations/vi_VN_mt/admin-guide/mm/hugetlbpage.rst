.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/admin-guide/mm/hugetlbpage.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=================
Các trang TLB lớn
=================

Tổng quan
=========

Mục đích của tập tin này là đưa ra một bản tóm tắt ngắn gọn về hỗ trợ Hugetlbpage trong
nhân Linux.  Hỗ trợ này được xây dựng dựa trên hỗ trợ nhiều kích thước trang
được cung cấp bởi hầu hết các kiến trúc hiện đại.  Ví dụ, CPU x86 thường
hỗ trợ kích thước trang 4K và 2M (1G nếu được hỗ trợ về mặt kiến trúc), ia64
kiến trúc hỗ trợ nhiều kích thước trang 4K, 8K, 64K, 256K, 1M, 4M, 16M,
256M và ppc64 hỗ trợ 4K và 16M.  TLB là bộ đệm của kết nối ảo-vật lý
các bản dịch.  Thông thường đây là nguồn tài nguyên rất khan hiếm trên bộ xử lý.
Các hệ điều hành cố gắng tận dụng tối đa số lượng tài nguyên TLB có giới hạn.
Việc tối ưu hóa này hiện nay quan trọng hơn khi bộ nhớ vật lý ngày càng lớn hơn.
(vài GB) sẵn có hơn.

Người dùng có thể sử dụng hỗ trợ trang khổng lồ trong nhân Linux bằng cách sử dụng mmap
cuộc gọi hệ thống hoặc cuộc gọi hệ thống bộ nhớ dùng chung SYSV tiêu chuẩn (shmget, shmat).

Đầu tiên nhân Linux cần được xây dựng bằng CONFIG_HUGETLBFS
(hiện trong phần "Hệ thống tệp") và CONFIG_HUGETLB_PAGE (được chọn
tự động khi chọn cấu hình CONFIG_HUGETLBFS)
tùy chọn.

Tệp ZZ0000ZZ cung cấp thông tin về tổng số
các trang lớn liên tục trong nhóm trang khổng lồ của kernel.  Nó cũng hiển thị
kích thước trang lớn mặc định và thông tin về số lượng trang miễn phí, dành riêng
và các trang khổng lồ dư thừa trong nhóm các trang khổng lồ có kích thước mặc định.
Kích thước trang lớn là cần thiết để tạo ra sự liên kết phù hợp và
kích thước của các đối số cho các lệnh gọi hệ thống ánh xạ các vùng trang lớn.

Đầu ra của ZZ0000ZZ sẽ bao gồm các dòng như::

HugePages_Total: uu
	HugePages_Free: vvv
	HugePages_Rsvd: www
	HugePages_Surp: xxx
	Kích thước trang lớn: yyy kB
	Hugetlb: zzz kB

Ở đâu:

HugePages_Total
	là kích thước của nhóm các trang khổng lồ.
HugePages_Free
	là số lượng trang lớn trong nhóm chưa
        được phân bổ.
HugePages_Rsvd
	là viết tắt của "dành riêng" và là số lượng trang khổng lồ cho
        cam kết phân bổ từ quỹ đã được thực hiện,
        nhưng vẫn chưa có sự phân bổ nào được thực hiện.  Các trang lớn dành riêng
        đảm bảo rằng một ứng dụng sẽ có thể phân bổ một
        trang lớn từ nhóm các trang lớn vào thời điểm có lỗi.
HugePages_Surp
	là viết tắt của "thặng dư" và là số lượng trang lớn trong
        nhóm trên giá trị trong ZZ0000ZZ. các
        số lượng trang lớn dư thừa tối đa được kiểm soát bởi
        ZZ0001ZZ.
	Lưu ý: Khi tính năng giải phóng các trang vmemmap không dùng đến được liên kết
	với mỗi trang Hugetlb được kích hoạt, số lượng trang lớn dư thừa
	có thể tạm thời lớn hơn số lượng thặng dư tối đa rất lớn
	trang khi hệ thống đang chịu áp lực bộ nhớ.
trang lớn
	là kích thước trang lớn mặc định (tính bằng kB).
lớn
        là tổng dung lượng bộ nhớ (tính bằng kB), được tiêu thụ bởi lượng lớn
        trang ở mọi kích cỡ.
        Nếu sử dụng các trang lớn có kích thước khác nhau thì con số này
        sẽ vượt quá HugePages_Total \* Hugepagesize. Để có được nhiều hơn
        thông tin chi tiết vui lòng tham khảo
        ZZ0002ZZ (được mô tả bên dưới).


ZZ0000ZZ cũng sẽ hiển thị hệ thống tệp thuộc loại "hugetlbfs"
được cấu hình trong kernel.

ZZ0000ZZ biểu thị số lượng "liên tục" khổng lồ hiện nay
các trang trong nhóm trang khổng lồ của kernel.  Các trang lớn sẽ "liên tục"
quay trở lại nhóm trang khổng lồ khi được giải phóng bởi một tác vụ.  Người dùng có quyền root
đặc quyền có thể tự động phân bổ nhiều hơn hoặc giải phóng một số trang lớn liên tục
bằng cách tăng hoặc giảm giá trị của ZZ0001ZZ.

Lưu ý: Khi tính năng giải phóng các trang vmemmap không sử dụng liên kết với mỗi trang
trang Hugetlb được bật, chúng tôi có thể không giải phóng được các trang lớn được kích hoạt bởi
người dùng khi hệ thống đang chịu áp lực về bộ nhớ.  Vui lòng thử lại sau.

Các trang được sử dụng làm trang lớn được dành riêng bên trong kernel và không thể
được sử dụng vào mục đích khác.  Các trang lớn không thể được hoán đổi trong
áp lực trí nhớ

Khi một số trang lớn đã được phân bổ trước cho trang lớn kernel
pool, người dùng có đặc quyền thích hợp có thể sử dụng lệnh gọi hệ thống mmap
hoặc lệnh gọi hệ thống bộ nhớ dùng chung để sử dụng các trang lớn.  Xem phần thảo luận của
ZZ0000ZZ, bên dưới.

Quản trị viên có thể phân bổ các trang lớn liên tục khi khởi động kernel
dòng lệnh bằng cách chỉ định tham số "hugepages=N", trong đó 'N' =
số lượng lớn các trang được yêu cầu.  Đây là phương pháp đáng tin cậy nhất
phân bổ các trang lớn vì bộ nhớ vẫn chưa bị phân mảnh.

Một số nền tảng hỗ trợ nhiều kích thước trang lớn.  Để phân bổ các trang lớn
có kích thước cụ thể, người ta phải đặt trước các tham số lệnh khởi động trang lớn
với tham số lựa chọn kích thước trang lớn "hugepagesz=<size>".  <kích thước> phải
được chỉ định theo byte với hậu tố tỷ lệ tùy chọn [kKmMgG].  Mặc định rất lớn
kích thước trang có thể được chọn bằng tham số khởi động "default_hugepagesz=<size>".

Ngữ nghĩa tham số dòng lệnh khởi động Hugetlb

khổng lồ
	Chỉ định kích thước trang lớn.  Được sử dụng cùng với các trang lớn
	tham số để phân bổ trước một số trang lớn của trang được chỉ định
	kích thước.  Do đó, Hugepagesz và Hugepages thường được chỉ định trong
	các cặp như::

Hugepagesz=2M Hugepages=512

Hugepagesz chỉ có thể được chỉ định một lần trên dòng lệnh cho một
	kích thước trang lớn cụ thể.  Kích thước trang lớn hợp lệ là kiến trúc
	phụ thuộc.
trang lớn
	Chỉ định số lượng trang lớn để phân bổ trước.  Điều này thường
	tuân theo thông số Hugepagesz hoặc default_hugepagesz hợp lệ.  Tuy nhiên,
	nếu Hugepages là tham số dòng lệnh Hugetlb đầu tiên hoặc duy nhất thì nó
	ngầm chỉ định số lượng trang lớn có kích thước mặc định
	phân bổ.  Nếu số lượng trang lớn có kích thước mặc định được ngầm định
	được chỉ định, nó không thể bị ghi đè bởi Hugepagesz, Hugepages
	cặp tham số cho kích thước mặc định.  Thông số này cũng có
	định dạng nút.  Định dạng nút chỉ định số lượng trang lớn
	để phân bổ trên các nút cụ thể.

Ví dụ: trên kiến ​​trúc có kích thước trang lớn mặc định là 2M::

Hugepages=256 Hugepagesz=2M Hugepages=512

sẽ dẫn đến 256 trang lớn 2M được phân bổ và một thông báo cảnh báo
	chỉ ra rằng tham số Hugepages=512 bị bỏ qua.  Nếu một trang lớn
	trước tham số Hugepagesz không hợp lệ, nó sẽ
	bị bỏ qua.

Ví dụ về định dạng nút::

Hugepagesz=2M Hugepages=0:1,1:2

Nó sẽ phân bổ 1 trang lớn 2M trên nút0 và 2 trang lớn 2M trên nút1.
	Nếu số nút không hợp lệ, tham số sẽ bị bỏ qua.
Hugepage_alloc_threads
	Chỉ định số lượng chủ đề sẽ được sử dụng để phân bổ các trang lớn
	trong quá trình khởi động. Tham số này có thể được sử dụng để cải thiện thời gian khởi động hệ thống
	khi phân bổ một lượng lớn các trang lớn.

Giá trị mặc định là 25% số luồng phần cứng có sẵn.
	Ví dụ sử dụng 8 luồng phân bổ::

Hugepage_alloc_threads=8

Lưu ý rằng tham số này chỉ áp dụng cho các trang lớn không lớn.
mặc định_hugepagesz
	Chỉ định kích thước trang lớn mặc định.  Thông số này có thể
	chỉ được chỉ định một lần trên dòng lệnh.  default_hugepagesz có thể
	tùy chọn được theo sau bởi tham số Hugepages để phân bổ trước một
	số lượng trang lớn có kích thước mặc định cụ thể.  Số mặc định
	các trang lớn có kích thước để phân bổ trước cũng có thể được chỉ định ngầm là
	được đề cập trong phần Hugepages ở trên.  Vì vậy, trên một
	kiến trúc có kích thước trang lớn mặc định là 2M::

trang lớn=256
		default_hugepagesz=2M Hugepages=256
		Hugepages=256 default_hugepagesz=2M

tất cả sẽ dẫn đến 256 trang lớn 2 triệu được phân bổ.  Mặc định hợp lệ
	kích thước trang lớn phụ thuộc vào kiến trúc.
Hugetlb_free_vmemmap
	Khi CONFIG_HUGETLB_PAGE_OPTIMIZE_VMEMMAP được đặt, điều này sẽ kích hoạt HugeTLB
	Tối ưu hóa Vmemmap (HVO).

Khi hỗ trợ nhiều kích thước trang lớn, ZZ0000ZZ
cho biết số lượng trang lớn được phân bổ trước hiện tại có kích thước mặc định.
Vì vậy, người ta có thể sử dụng lệnh sau để phân bổ/giải phóng động
các trang lớn liên tục có kích thước mặc định::

echo 20 > /proc/sys/vm/nr_hugepages

Lệnh này sẽ cố gắng điều chỉnh số lượng trang lớn có kích thước mặc định trong
nhóm trang khổng lồ lên tới 20, phân bổ hoặc giải phóng các trang lớn theo yêu cầu.

Trên nền tảng NUMA, kernel sẽ cố gắng phân phối nhóm trang khổng lồ
trên tất cả tập hợp các nút được phép được chỉ định bởi chính sách bộ nhớ NUMA của
nhiệm vụ sửa đổi ZZ0001ZZ. Giá trị mặc định cho các nút được phép--khi
tác vụ có chính sách bộ nhớ mặc định--là tất cả các nút trực tuyến có bộ nhớ.  Được phép
các nút không có đủ bộ nhớ liền kề, sẵn có cho một trang lớn sẽ
âm thầm bỏ qua khi phân bổ các trang lớn liên tục.  Xem
ZZ0000ZZ
về sự tương tác của chính sách bộ nhớ tác vụ, bộ xử lý và thuộc tính mỗi nút
với việc phân bổ và giải phóng các trang lớn liên tục.

Sự thành công hay thất bại của việc phân bổ trang lớn phụ thuộc vào số lượng
bộ nhớ liền kề về mặt vật lý hiện có trong hệ thống tại thời điểm
nỗ lực phân bổ  Nếu kernel không thể phân bổ các trang lớn từ
một số nút trong hệ thống NUMA, nó sẽ cố gắng tạo ra sự khác biệt bằng cách
phân bổ các trang bổ sung trên các nút khác với đủ các trang liền kề có sẵn
bộ nhớ, nếu có.

Quản trị viên hệ thống có thể muốn đặt lệnh này vào một trong các RC cục bộ
các tập tin init.  Điều này sẽ cho phép kernel phân bổ sớm các trang lớn trong
quá trình khởi động khi có khả năng nhận được các trang vật lý liền kề
vẫn còn rất cao.  Quản trị viên có thể xác minh số lượng trang lớn
thực sự được phân bổ bằng cách kiểm tra sysctl hoặc meminfo.  Để kiểm tra mỗi nút
phân phối các trang lớn trong hệ thống NUMA, sử dụng::

cat /sys/devices/system/node/node*/meminfo | fgrep Rất lớn

ZZ0000ZZ chỉ định mức độ lớn của nhóm
các trang lớn có thể phát triển nếu có nhiều trang lớn hơn ZZ0001ZZ
được yêu cầu bởi các ứng dụng.  Viết bất kỳ giá trị nào khác 0 vào tệp này
chỉ ra rằng hệ thống con Hugetlb được phép cố gắng đạt được điều đó
số trang lớn "dư thừa" từ nhóm trang bình thường của hạt nhân, khi
nhóm trang lớn liên tục đã cạn kiệt. Khi những trang khổng lồ dư thừa này trở thành
không được sử dụng, chúng sẽ được giải phóng trở lại nhóm trang bình thường của kernel.

Khi tăng kích thước nhóm trang khổng lồ thông qua ZZ0000ZZ, mọi
các trang dư thừa trước tiên sẽ được thăng cấp lên các trang lớn liên tục.  Sau đó, bổ sung
các trang lớn sẽ được phân bổ, nếu cần thiết và nếu có thể, để đáp ứng
kích thước nhóm trang khổng lồ liên tục mới.

Quản trị viên có thể thu nhỏ nhóm các trang lớn liên tục cho
kích thước trang lớn mặc định bằng cách đặt sysctl ZZ0000ZZ thành
giá trị nhỏ hơn.  Hạt nhân sẽ cố gắng cân bằng việc giải phóng các trang lớn
trên tất cả các nút trong chính sách bộ nhớ của tác vụ sửa đổi ZZ0001ZZ.
Bất kỳ trang lớn miễn phí nào trên các nút đã chọn sẽ được giải phóng trở lại kernel
nhóm trang bình thường.

Hãy cẩn thận: Thu hẹp nhóm trang khổng lồ liên tục thông qua ZZ0000ZZ sao cho
nó trở nên ít hơn số lượng trang lớn đang sử dụng sẽ chuyển đổi số dư
từ các trang lớn đang được sử dụng sang các trang lớn dư thừa.  Điều này sẽ xảy ra ngay cả khi
số trang thừa sẽ vượt quá giá trị cam kết vượt mức.  Miễn là
điều kiện này được duy trì--nghĩa là cho đến khi ZZ0001ZZ
tăng đủ, hoặc các trang khổng lồ dư thừa không còn được sử dụng và được giải phóng--
không còn các trang lớn dư thừa sẽ được phép phân bổ.

Với sự hỗ trợ cho nhiều nhóm trang lớn trong thời gian chạy, phần lớn
giao diện không gian người dùng trang lớn trong ZZ0000ZZ đã được sao chép trong
sysfs.
Các giao diện ZZ0001ZZ được thảo luận ở trên đã được giữ lại cho các phiên bản ngược
khả năng tương thích. Thư mục kiểm soát trang lớn gốc trong sysfs là::

/sys/kernel/mm/hugepages

Đối với mỗi kích thước trang lớn được hỗ trợ bởi kernel đang chạy, một thư mục con
sẽ tồn tại, có dạng::

Hugepages-${size}kB

Bên trong mỗi thư mục này, tập hợp các tệp có trong ZZ0000ZZ
sẽ tồn tại.  Ngoài ra, hai giao diện bổ sung để hạ cấp rất lớn
các trang có thể tồn tại::

giáng chức
        hạ cấp_size
	nr_hugepages
	nr_hugepages_mempolicy
	nr_overcommit_hugepages
	free_hugepages
	resv_hugepages
	thặng dư_hugepages

Giao diện hạ cấp cung cấp khả năng chia một trang lớn thành
các trang lớn nhỏ hơn.  Ví dụ: kiến trúc x86 hỗ trợ cả
Kích thước trang lớn 1GB và 2MB.  Một trang lớn 1GB có thể được chia thành 512
Trang lớn 2 MB.  Giao diện hạ cấp không có sẵn cho nhỏ nhất
kích thước trang rất lớn.  Các giao diện hạ cấp là:

hạ cấp_size
        là kích thước của các trang bị giảm hạng.  Khi một trang bị hạ hạng tương ứng
        số lượng lớn các trang demote_size sẽ được tạo.  Theo mặc định,
        demote_size được đặt thành kích thước trang lớn nhỏ hơn tiếp theo.  Nếu có
        nhiều kích thước trang lớn nhỏ hơn, demote_size có thể được đặt thành bất kỳ kích thước nào
        những kích thước nhỏ hơn này.  Chỉ có kích thước trang khổng lồ nhỏ hơn kích thước trang khổng lồ hiện tại
        kích thước trang được cho phép.

giáng chức
        được sử dụng để hạ hạng một số trang lớn.  Người dùng có quyền root
        có thể ghi vào tập tin này.  Có thể không thể hạ cấp
        yêu cầu số lượng trang lớn.  Để xác định có bao nhiêu trang
        thực sự bị giáng cấp, so sánh giá trị của nr_hugepages trước và sau
        ghi vào giao diện hạ cấp.  demote là giao diện chỉ ghi.

Các giao diện giống như trong ZZ0000ZZ (tất cả ngoại trừ hạ cấp và
demote_size) như được mô tả ở trên cho trường hợp có kích thước trang lớn mặc định.

.. _mem_policy_and_hp_alloc:

Tương tác của chính sách bộ nhớ tác vụ với việc phân bổ/giải phóng trang lớn
============================================================================

Cho dù các trang lớn được phân bổ và giải phóng thông qua giao diện ZZ0000ZZ hay
giao diện ZZ0001ZZ sử dụng thuộc tính ZZ0002ZZ,
Các nút NUMA mà từ đó các trang lớn được phân bổ hoặc giải phóng được kiểm soát bởi
Chính sách bộ nhớ NUMA của tác vụ sửa đổi ZZ0003ZZ
sysctl hoặc thuộc tính.  Khi thuộc tính ZZ0004ZZ được sử dụng, chính sách ghi nhớ
bị bỏ qua.

Phương pháp được đề xuất để phân bổ hoặc giải phóng các trang lớn đến/từ kernel
Nhóm trang khổng lồ, sử dụng ví dụ ZZ0000ZZ ở trên, là::

numactl --interleave <node-list> echo 20 \
				>/proc/sys/vm/nr_hugepages_mempolicy

hoặc, ngắn gọn hơn::

numactl -m <node-list> echo 20 >/proc/sys/vm/nr_hugepages_mempolicy

Điều này sẽ phân bổ hoặc giải phóng ZZ0000ZZ đến hoặc từ các nút
được chỉ định trong <danh sách nút>, tùy thuộc vào số lượng trang lớn liên tục
ban đầu tương ứng nhỏ hơn hoặc lớn hơn 20.  Sẽ không có trang lớn nào
được phân bổ hoặc giải phóng trên bất kỳ nút nào không có trong <danh sách nút> được chỉ định.

Khi điều chỉnh số lượng trang khổng lồ liên tục thông qua ZZ0000ZZ, bất kỳ
chế độ chính sách bộ nhớ - liên kết, ưu tiên, cục bộ hoặc xen kẽ - có thể được sử dụng.  các
kết quả ảnh hưởng đến việc phân bổ trang lớn liên tục như sau:

#. Bất kể chế độ ghi nhớ [xem
   Tài liệu/admin-guide/mm/numa_memory_policy.rst],
   các trang lớn liên tục sẽ được phân phối trên nút hoặc các nút
   được chỉ định trong mempolicy như thể "xen kẽ" đã được chỉ định.
   Tuy nhiên, nếu một nút trong chính sách không chứa đủ các vùng liền kề
   bộ nhớ cho một trang lớn, việc phân bổ sẽ không "dự phòng" về trang gần nhất
   nút lân cận có đủ bộ nhớ liền kề.  Để làm điều này sẽ gây ra
   sự mất cân bằng không mong muốn trong việc phân phối nhóm trang lớn, hoặc
   có thể, việc phân bổ các trang lớn liên tục trên các nút không được phép bởi
   chính sách bộ nhớ của nhiệm vụ.

#. Một hoặc nhiều nút có thể được chỉ định bằng chính sách liên kết hoặc xen kẽ.
   Nếu có nhiều hơn một nút được chỉ định với chính sách ưu tiên thì chỉ có nút
   id số thấp nhất sẽ được sử dụng.  Chính sách cục bộ sẽ chọn nút nơi
   tác vụ đang chạy tại thời điểm mặt nạ node_allowed được tạo.
   Để chính sách cục bộ có tính xác định, tác vụ phải được liên kết với CPU hoặc
   cpu trong một nút duy nhất.  Nếu không, tác vụ có thể được di chuyển sang một số
   nút khác bất kỳ lúc nào sau khi khởi chạy và nút kết quả sẽ được
   không xác định.  Vì vậy, chính sách địa phương không hữu ích lắm cho mục đích này.
   Bất kỳ chế độ ghi nhớ nào khác có thể được sử dụng để chỉ định một nút.

#. Mặt nạ được phép của các nút sẽ được lấy từ bất kỳ chính sách ghi nhớ tác vụ không mặc định nào,
   liệu chính sách này được thiết lập rõ ràng bởi chính tác vụ đó hay một trong các tác vụ đó
   tổ tiên, chẳng hạn như numactl.  Điều này có nghĩa là nếu tác vụ được gọi từ một
   shell có chính sách không mặc định thì chính sách đó sẽ được sử dụng.  Người ta có thể chỉ định một
   danh sách nút của "tất cả" với numactl --interleave hoặc --membind [-m] để đạt được
   xen kẽ trên tất cả các nút trong hệ thống hoặc cpuset.

#. Bất kỳ chính sách ghi nhớ tác vụ nào được chỉ định--ví dụ: sử dụng numactl--sẽ bị hạn chế bởi
   giới hạn tài nguyên của bất kỳ bộ xử lý nào mà tác vụ chạy trong đó.  Như vậy sẽ có
   không có cách nào cho một tác vụ có chính sách không mặc định chạy trong bộ xử lý có
   tập hợp con của các nút hệ thống để phân bổ các trang lớn bên ngoài bộ xử lý
   mà không cần chuyển sang bộ xử lý có chứa tất cả các nút mong muốn trước tiên.

#. Phân bổ trang lớn trong thời gian khởi động cố gắng phân phối số lượng được yêu cầu
   của các trang lớn trên tất cả các nút trực tuyến có bộ nhớ.

Thuộc tính Hugepages trên mỗi nút
=================================

Một tập hợp con nội dung của thư mục kiểm soát trang lớn gốc trong sysfs,
được mô tả ở trên, sẽ được sao chép theo từng thiết bị hệ thống của mỗi
Nút NUMA có bộ nhớ trong::

/sys/devices/system/node/node[0-9]*/hugepages/

Trong thư mục này, thư mục con cho mỗi kích thước trang lớn được hỗ trợ
chứa các tệp thuộc tính sau::

nr_hugepages
	free_hugepages
	thặng dư_hugepages

Các tệp thuộc tính free\_' và thặng dư\_' ở dạng chỉ đọc.  Họ trả lại số
các trang lớn miễn phí và dư thừa [đã cam kết quá mức] tương ứng trên trang gốc
nút.

Thuộc tính ZZ0000ZZ trả về tổng số trang lớn trên
nút được chỉ định.  Khi thuộc tính này được viết, số lượng lớn liên tục
các trang trên nút cha sẽ được điều chỉnh theo giá trị đã chỉ định, nếu đủ
tài nguyên tồn tại, bất kể các ràng buộc về bộ nhớ hoặc bộ xử lý của tác vụ.

Lưu ý rằng số lượng trang dự trữ và cam kết vượt mức vẫn là số lượng toàn cầu,
như chúng ta không biết cho đến khi xảy ra lỗi, khi chính sách ghi nhớ của tác vụ bị lỗi được thực hiện
được áp dụng, từ nút nào việc phân bổ trang lớn sẽ được thử.

Hugetlb có thể được di chuyển giữa nhóm trang lớn trên mỗi nút theo cách sau
các tình huống: bộ nhớ ngoại tuyến, lỗi bộ nhớ, ghim dài hạn, các cuộc gọi hệ thống (mbind,
di chuyển_pages và di chuyển_pages), alloc_contig_range() và alloc_contig_pages().
Bây giờ chỉ có bộ nhớ ngoại tuyến, lỗi bộ nhớ và các cuộc gọi tổng hợp cho phép phân bổ dự phòng
một Hugetlb mới trên một nút khác nếu nút hiện tại không thể phân bổ trong thời gian
di chuyển Hugetlb, điều đó có nghĩa là 3 trường hợp này có thể phá vỡ nhóm trang lớn trên mỗi nút.

.. _using_huge_pages:

Sử dụng các trang lớn
=====================

Nếu ứng dụng người dùng yêu cầu các trang lớn bằng hệ thống mmap
thì người quản trị hệ thống phải gắn một hệ thống tệp của
gõ Hugetlbfs::

mount -t Hugetlbfs \
	-o uid=<value>,gid=<value>,mode=<value>,pagesize=<value>,size=<value>,\
	min_size=<value>,nr_inodes=<value> không /mnt/huge

Lệnh này gắn một hệ thống tập tin (giả) loại Hugetlbfs vào thư mục
ZZ0000ZZ.  Bất kỳ tệp nào được tạo trên ZZ0001ZZ đều sử dụng các trang lớn.

Các tùy chọn ZZ0000ZZ và ZZ0001ZZ đặt chủ sở hữu và nhóm gốc của
hệ thống tập tin.  Theo mặc định, ZZ0002ZZ và ZZ0003ZZ của quy trình hiện tại
được lấy.

Tùy chọn ZZ0000ZZ đặt chế độ gốc của hệ thống tệp thành giá trị & 01777.
Giá trị này được đưa ra dưới dạng bát phân. Theo mặc định, giá trị 0755 được chọn.

Nếu nền tảng hỗ trợ nhiều kích thước trang lớn, tùy chọn ZZ0000ZZ có thể
được sử dụng để chỉ định kích thước trang lớn và nhóm liên quan. ZZ0001ZZ
được chỉ định bằng byte. Nếu ZZ0002ZZ không được chỉ định thì nền tảng
kích thước trang lớn mặc định và nhóm liên quan sẽ được sử dụng.

Tùy chọn ZZ0000ZZ đặt giá trị bộ nhớ tối đa (trang lớn) được phép
cho hệ thống tập tin đó (ZZ0001ZZ). Tùy chọn ZZ0002ZZ có thể được chỉ định
tính bằng byte hoặc dưới dạng phần trăm của nhóm trang lớn được chỉ định (ZZ0003ZZ).
Kích thước được làm tròn xuống ranh giới HPAGE_SIZE.

Tùy chọn ZZ0000ZZ đặt giá trị bộ nhớ tối thiểu (trang lớn) được phép
cho hệ thống tập tin. ZZ0001ZZ có thể được chỉ định theo cách tương tự như ZZ0002ZZ,
byte hoặc phần trăm của nhóm trang lớn.
Tại thời điểm gắn kết, số lượng trang lớn do ZZ0003ZZ chỉ định sẽ được bảo lưu
để sử dụng bởi hệ thống tập tin.
Nếu không có đủ các trang lớn miễn phí, quá trình gắn kết sẽ không thành công.
Khi các trang lớn được phân bổ vào hệ thống tập tin và được giải phóng, số lượng dự trữ
được điều chỉnh sao cho tổng số trang lớn được phân bổ và dành riêng luôn bằng
ít nhất là ZZ0004ZZ.

Tùy chọn ZZ0000ZZ đặt số lượng nút tối đa mà ZZ0001ZZ
có thể sử dụng.

Nếu tùy chọn ZZ0000ZZ, ZZ0001ZZ hoặc ZZ0002ZZ không được cung cấp trên
dòng lệnh thì không có giới hạn nào được đặt.

Đối với các tùy chọn ZZ0000ZZ, ZZ0001ZZ, ZZ0002ZZ và ZZ0003ZZ, bạn có thể
sử dụng [G|g]/[M|m]/[K|k] để biểu thị giga/mega/kilo.
Ví dụ: size=2K có cùng ý nghĩa với size=2048.

Mặc dù lệnh gọi hệ thống đọc được hỗ trợ trên các tệp nằm trên Hugetlb
hệ thống tập tin, ghi các cuộc gọi hệ thống thì không.

Các lệnh chown, chgrp và chmod thông thường (có quyền phù hợp) có thể
được sử dụng để thay đổi thuộc tính tệp trên Hugetlbfs.

Ngoài ra, điều quan trọng cần lưu ý là không cần lệnh mount như vậy nếu
các ứng dụng sẽ chỉ sử dụng lệnh gọi hệ thống shmat/shmget hoặc mmap với
MAP_HUGETLB.  Để biết ví dụ về cách sử dụng mmap với MAP_HUGETLB, hãy xem
ZZ0000ZZ bên dưới.

Người dùng muốn sử dụng bộ nhớ Hugetlb thông qua phân đoạn bộ nhớ dùng chung phải
các thành viên của nhóm bổ sung và quản trị viên hệ thống cần định cấu hình gid đó
vào ZZ0000ZZ.  Có thể giống hoặc khác
các ứng dụng sử dụng bất kỳ sự kết hợp nào của lệnh gọi mmaps và shm*, mặc dù việc gắn kết
hệ thống tập tin sẽ được yêu cầu để sử dụng lệnh gọi mmap mà không cần MAP_HUGETLB.

Các tòa nhà hoạt động trên bộ nhớ được hỗ trợ bởi các trang Hugetlb chỉ có độ dài của chúng
căn chỉnh theo kích thước trang gốc của bộ xử lý; họ thường sẽ thất bại với
errno được đặt thành EINVAL hoặc loại trừ các trang lớn vượt quá độ dài nếu
không được căn chỉnh trang lớn.  Ví dụ: munmap(2) sẽ thất bại nếu bộ nhớ được hỗ trợ bởi
một trang lớn và có độ dài nhỏ hơn kích thước trang lớn.


Ví dụ
========

.. _map_hugetlb:

ZZ0000ZZ
	xem công cụ/thử nghiệm/selftests/mm/map_hugetlb.c

ZZ0000ZZ
	xem công cụ/kiểm tra/selftests/mm/hugepage-shm.c

ZZ0000ZZ
	xem công cụ/kiểm tra/selftests/mm/hugepage-mmap.c

Thư viện ZZ0000ZZ cung cấp nhiều công cụ không gian người dùng
để hỗ trợ khả năng sử dụng trang lớn, thiết lập môi trường và kiểm soát.

.. _libhugetlbfs: https://github.com/libhugetlbfs/libhugetlbfs
