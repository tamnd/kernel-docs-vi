.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/filesystems/resctrl.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

.. include:: <isonum.txt>

==========================================================
Giao diện người dùng cho tính năng Kiểm soát tài nguyên (resctrl)
=====================================================

:Bản quyền: ZZ0000ZZ 2016 Tập đoàn Intel
:Tác giả: - Fenghua Yu <fenghua.yu@intel.com>
          - Tony Luck <tony.luck@intel.com>
          - Vikas Shivappa <vikas.shivappa@intel.com>


Intel gọi tính năng này là Công nghệ Giám đốc Tài nguyên Intel(Intel(R) RDT).
AMD gọi tính năng này là Chất lượng dịch vụ của nền tảng AMD (AMD QoS).

Tính năng này được kích hoạt bởi CONFIG_X86_CPU_RESCTRL và x86 /proc/cpuinfo
bit cờ:

=======================================================================================================
RDT (Công nghệ giám đốc tài nguyên) Phân bổ "rdt_a"
CAT (Công nghệ phân bổ bộ đệm) "cat_l3", "cat_l2"
CDP (Ưu tiên mã và dữ liệu) "cdp_l3", "cdp_l2"
CQM (Giám sát QoS bộ đệm) "cqm_llc", "cqm_occup_llc"
MBM (Giám sát băng thông bộ nhớ) "cqm_mbm_total", "cqm_mbm_local"
MBA (Phân bổ băng thông bộ nhớ) "mba"
SMBA (Phân bổ băng thông bộ nhớ chậm) ""
BMEC (Cấu hình sự kiện giám sát băng thông) ""
ABMC (Bộ đếm giám sát băng thông có thể gán) ""
SDCIAE (Thực thi phân bổ chèn bộ đệm dữ liệu thông minh) ""
=======================================================================================================

Về mặt lịch sử, các tính năng mới được hiển thị theo mặc định trong /proc/cpuinfo. Cái này
dẫn đến việc các cờ tính năng trở nên khó phân tích bởi con người. Thêm một cái mới
Nên tránh gắn cờ cho /proc/cpuinfo nếu không gian người dùng có thể lấy được thông tin
về tính năng này từ thư mục thông tin của resctrl.

Để sử dụng tính năng này, hãy gắn hệ thống tệp::

# mount -t resctrl resctrl [-o cdp[,cdpl2][,mba_MBps][,debug]] /sys/fs/resctrl

tùy chọn gắn kết là:

"cdp":
	Bật ưu tiên mã/dữ liệu trong phân bổ bộ đệm L3.
"cdpl2":
	Bật ưu tiên mã/dữ liệu trong phân bổ bộ đệm L2.
"mba_MBps":
	Kích hoạt Bộ điều khiển phần mềm MBA(mba_sc) để chỉ định MBA
	băng thông tính bằng MiBps
"gỡ lỗi":
	Làm cho các tập tin gỡ lỗi có thể truy cập được. Các tệp gỡ lỗi có sẵn được chú thích bằng
	"Chỉ khả dụng với tùy chọn gỡ lỗi".

L2 và L3 CDP được điều khiển riêng.

Các tính năng của RDT là trực giao. Một hệ thống cụ thể chỉ có thể hỗ trợ
giám sát, chỉ kiểm soát hoặc cả giám sát và kiểm soát.  Bộ nhớ đệm
khóa giả là một cách độc đáo để sử dụng điều khiển bộ đệm để "ghim" hoặc
"khóa" dữ liệu trong bộ đệm. Chi tiết có thể được tìm thấy trong
"Khóa giả bộ đệm".


Quá trình gắn kết thành công nếu có sự phân bổ hoặc giám sát, nhưng
chỉ những tập tin và thư mục được hệ thống hỗ trợ mới được tạo.
Để biết thêm chi tiết về hoạt động của giao diện trong quá trình giám sát
và phân bổ, hãy xem phần "Nhóm phân bổ và giám sát tài nguyên".

Thư mục thông tin
==============

Thư mục 'thông tin' chứa thông tin về kích hoạt
tài nguyên. Mỗi tài nguyên có thư mục con riêng. Thư mục con
tên phản ánh tên tài nguyên.

Hầu hết các tệp trong thư mục con của tài nguyên đều ở dạng chỉ đọc và
mô tả các thuộc tính của tài nguyên Các tài nguyên hỗ trợ toàn cầu
các tùy chọn cấu hình cũng bao gồm các tập tin có thể ghi được và có thể được sử dụng
để sửa đổi các cài đặt đó.

Mỗi thư mục con chứa các tệp sau đây liên quan đến
phân bổ:

Thư mục con tài nguyên bộ đệm (L3/L2) chứa các tệp sau
liên quan đến phân bổ:

"num_closids":
		Số lượng CLOSID hợp lệ cho việc này
		tài nguyên. Hạt nhân sử dụng số lượng nhỏ nhất
		CLOSID của tất cả các tài nguyên được kích hoạt là giới hạn.
"cbm_mask":
		Bitmask hợp lệ cho tài nguyên này.
		Mặt nạ này tương đương 100%.
"min_cbm_bits":
		Số bit liên tiếp tối thiểu
		phải được đặt khi viết mặt nạ.

"shareable_bits":
		Bitmask của tài nguyên có thể chia sẻ với các thực thể thực thi khác
		(ví dụ: I/O). Áp dụng cho tất cả các phiên bản của tài nguyên này. người dùng
		có thể sử dụng điều này khi thiết lập phân vùng bộ đệm riêng.
		Lưu ý rằng một số nền tảng hỗ trợ các thiết bị có
		cài đặt riêng để sử dụng bộ đệm có thể ghi đè các bit này.

Khi "io_alloc" được bật, một phần của mỗi phiên bản bộ đệm có thể
		được cấu hình để sử dụng chung giữa phần cứng và phần mềm.
		"bit_usage" nên được sử dụng để xem phần nào của mỗi bộ đệm
		instance được cấu hình để sử dụng phần cứng thông qua tính năng "io_alloc"
		bởi vì mọi phiên bản bộ đệm đều có thể có bitmask "io_alloc"
		được định cấu hình độc lập thông qua "io_alloc_cbm".

"bit_usage":
		Mặt nạ bit dung lượng được chú thích hiển thị tất cả
		trường hợp của tài nguyên được sử dụng. Truyền thuyết là:

"0":
			      Vùng tương ứng không được sử dụng. Khi hệ thống
			      tài nguyên đã được phân bổ và tìm thấy số "0"
			      trong "bit_usage" đó là dấu hiệu cho thấy tài nguyên
			      lãng phí.

"H":
			      Vùng tương ứng chỉ được sử dụng bởi phần cứng
			      nhưng có sẵn để sử dụng phần mềm. Nếu một tài nguyên
			      có các bit được đặt trong "shareable_bits" hoặc "io_alloc_cbm"
			      nhưng không phải tất cả các bit này đều xuất hiện trong tài nguyên
			      lược đồ của nhóm thì các bit xuất hiện trong
			      "shareable_bits" hoặc "io_alloc_cbm" nhưng không
			      nhóm tài nguyên sẽ được đánh dấu là "H".
			"X":
			      Vùng tương ứng có sẵn để chia sẻ và
			      được sử dụng bởi phần cứng và phần mềm. Đây là những bit
			      xuất hiện trong "shareable_bits" hoặc "io_alloc_cbm"
			      cũng như sự phân bổ của một nhóm nguồn lực.
			"S":
			      Vùng tương ứng được phần mềm sử dụng
			      và có sẵn để chia sẻ.
			"Đ":
			      Vùng tương ứng được sử dụng độc quyền bởi
			      một nhóm tài nguyên. Không được phép chia sẻ.
			"P":
			      Vùng tương ứng bị khóa giả. Không
			      được phép chia sẻ.
"sparse_masks":
		Cho biết liệu giá trị 1s không liền kề trong CBM có được hỗ trợ hay không.

"0":
			      Chỉ hỗ trợ giá trị 1s liền kề trong CBM.
			"1":
			      Giá trị 1s không liền kề trong CBM được hỗ trợ.

"io_alloc":
		"io_alloc" cho phép phần mềm hệ thống định cấu hình phần
		bộ đệm được phân bổ cho lưu lượng I/O. Tệp chỉ có thể tồn tại nếu
		hệ thống hỗ trợ tính năng này trên một số tài nguyên bộ đệm của nó.

"bị vô hiệu hóa":
			      Tài nguyên hỗ trợ "io_alloc" nhưng tính năng này bị tắt.
			      Các phần bộ đệm được sử dụng để phân bổ lưu lượng I/O không thể
			      được cấu hình.
			"đã bật":
			      Các phần bộ đệm được sử dụng để phân bổ lưu lượng I/O
			      có thể được cấu hình bằng "io_alloc_cbm".
			"không được hỗ trợ":
			      Hỗ trợ không có sẵn cho tài nguyên này.

Tính năng này có thể được sửa đổi bằng cách ghi vào giao diện, ví dụ:

Để kích hoạt::

# echo 1 > /sys/fs/resctrl/info/L3/io_alloc

Để vô hiệu hóa::

# echo 0 > /sys/fs/resctrl/info/L3/io_alloc

Việc triển khai cơ bản có thể làm giảm tài nguyên sẵn có cho
		phân bổ bộ đệm chung (CPU). Xem ghi chú cụ thể về kiến trúc
		bên dưới. Tùy thuộc vào yêu cầu sử dụng, tính năng này có thể được kích hoạt
		hoặc bị khuyết tật.

Trên các hệ thống AMD, tính năng io_alloc được L3 Smart hỗ trợ
		Thực thi phân bổ chèn bộ đệm dữ liệu (SDCIAE). CLOSID dành cho
		io_alloc là CLOSID cao nhất được tài nguyên hỗ trợ. Khi nào
		io_alloc được bật, CLOSID cao nhất được dành riêng cho io_alloc và
		không còn có sẵn để phân bổ bộ đệm chung (CPU). Khi CDP là
		được bật, io_alloc định tuyến lưu lượng I/O bằng CLOSID được phân bổ cao nhất
		cho bộ đệm lệnh (CDP_CODE), làm cho CLOSID này không còn
		có sẵn để phân bổ bộ đệm chung (CPU) cho cả CDP_CODE
		và tài nguyên CDP_DATA.

"io_alloc_cbm":
		Mặt nạ bit dung lượng mô tả các phần của phiên bản bộ đệm để
		lưu lượng I/O nào từ các thiết bị I/O được hỗ trợ sẽ được định tuyến khi "io_alloc"
		được kích hoạt.

CBM được hiển thị ở định dạng sau:

<cache_id0>=<cbm>;<cache_id1>=<cbm>;...

Ví dụ::

# cat /sys/fs/resctrl/info/L3/io_alloc_cbm
			0=ffff;1=ffff

CBM có thể được cấu hình bằng cách ghi vào giao diện.

Ví dụ::

# echo 1=ff > /sys/fs/resctrl/info/L3/io_alloc_cbm
			# cat /sys/fs/resctrl/info/L3/io_alloc_cbm
			0=ffff;1=00ff

# echo "0=ff;1=f" > /sys/fs/resctrl/info/L3/io_alloc_cbm
			# cat /sys/fs/resctrl/info/L3/io_alloc_cbm
			0=00ff;1=000f

ID "*" định cấu hình tất cả các miền có CBM được cung cấp.

Ví dụ về hệ thống không yêu cầu số bit liên tiếp tối thiểu trong mặt nạ::

# echo "*=0" > /sys/fs/resctrl/info/L3/io_alloc_cbm
			# cat /sys/fs/resctrl/info/L3/io_alloc_cbm
			0=0;1=0

Khi CDP được bật "io_alloc_cbm" được liên kết với CDP_DATA và CDP_CODE
		tài nguyên có thể phản ánh các giá trị tương tự. Ví dụ: các giá trị được đọc từ và
		được ghi vào /sys/fs/resctrl/info/L3DATA/io_alloc_cbm có thể được phản ánh bởi
		/sys/fs/resctrl/info/L3CODE/io_alloc_cbm và ngược lại.

Thư mục con băng thông bộ nhớ (MB) chứa các tệp sau
Về phân bổ:

"min_bandwidth":
		Phần trăm băng thông bộ nhớ tối thiểu
		người dùng có thể yêu cầu.

"băng thông_gran":
		Độ chi tiết trong đó băng thông bộ nhớ
		phần trăm được phân bổ. Việc phân bổ
		tỷ lệ b/w được làm tròn tới số tiếp theo
		bước điều khiển có sẵn trên phần cứng. các
		các bước kiểm soát băng thông có sẵn là:
		băng thông tối thiểu + N * băng thông_gran.

"độ trễ_tuyến tính":
		Cho biết thang độ trễ là tuyến tính hay
		phi tuyến tính. Lĩnh vực này hoàn toàn là thông tin
		chỉ.

"thread_throttle_mode":
		Chỉ báo trên hệ thống Intel về cách các tác vụ chạy trên luồng
		của lõi vật lý bị hạn chế trong trường hợp chúng
		yêu cầu phần trăm băng thông bộ nhớ khác nhau:

"tối đa":
			tỷ lệ phần trăm nhỏ nhất được áp dụng
			tới tất cả các chủ đề
		"mỗi chủ đề":
			phần trăm băng thông được áp dụng trực tiếp cho
			các luồng chạy trên lõi

Nếu có sẵn chức năng giám sát L3 thì sẽ có thư mục "L3_MON"
với các tập tin sau:

"num_rmids":
		Số lượng RMID được phần cứng hỗ trợ cho
		Sự kiện giám sát L3.

"mon_features":
		Liệt kê các sự kiện giám sát nếu
		giám sát được kích hoạt cho tài nguyên.
		Ví dụ::

# cat /sys/fs/resctrl/info/L3_MON/mon_features
			llc_occupancy
			mbm_total_bytes
			mbm_local_bytes

Nếu hệ thống hỗ trợ Sự kiện giám sát băng thông
		Cấu hình (BMEC), thì các sự kiện băng thông sẽ
		có thể cấu hình được. Đầu ra sẽ là::

# cat /sys/fs/resctrl/info/L3_MON/mon_features
			llc_occupancy
			mbm_total_bytes
			mbm_total_bytes_config
			mbm_local_bytes
			mbm_local_bytes_config

"mbm_total_bytes_config", "mbm_local_bytes_config":
	Đọc/ghi tệp chứa cấu hình cho mbm_total_bytes
	và các sự kiện mbm_local_bytes tương ứng khi Băng thông
	Tính năng Cấu hình sự kiện giám sát (BMEC) được hỗ trợ.
	Cài đặt cấu hình sự kiện là miền cụ thể và ảnh hưởng đến
	tất cả các CPU trong miền. Khi một trong hai cấu hình sự kiện được
	đã thay đổi, bộ đếm băng thông cho tất cả RMID của cả hai sự kiện
	(mbm_total_bytes cũng như mbm_local_bytes) sẽ bị xóa vì điều đó
	miền. Lần đọc tiếp theo cho mỗi RMID sẽ báo cáo "Không khả dụng"
	và các lần đọc tiếp theo sẽ báo cáo giá trị hợp lệ.

Sau đây là các loại sự kiện được hỗ trợ:

==== =============================================================
	Mô tả bit
	==== =============================================================
	6 nạn nhân bẩn từ miền QOS đến mọi loại bộ nhớ
	5 Đọc để làm chậm bộ nhớ trong miền NUMA không cục bộ
	4 Đọc để làm chậm bộ nhớ trong miền NUMA cục bộ
	3 Ghi không theo thời gian vào miền NUMA không cục bộ
	2 Ghi không theo thời gian vào miền NUMA cục bộ
	1 Đọc vào bộ nhớ trong miền NUMA không cục bộ
	0 Đọc vào bộ nhớ trong miền NUMA cục bộ
	==== =============================================================

Theo mặc định, cấu hình mbm_total_bytes được đặt thành 0x7f để đếm
	tất cả các loại sự kiện và cấu hình mbm_local_bytes được đặt thành
	0x15 để đếm tất cả các sự kiện bộ nhớ cục bộ.

Ví dụ:

* Để xem cấu hình hiện tại::
	  ::

# cat /sys/fs/resctrl/info/L3_MON/mbm_total_bytes_config
	    0=0x7f;1=0x7f;2=0x7f;3=0x7f

# cat /sys/fs/resctrl/info/L3_MON/mbm_local_bytes_config
	    0=0x15;1=0x15;3=0x15;4=0x15

* Để thay đổi mbm_total_bytes thành chỉ đếm số lần đọc trên miền 0,
	  các bit 0, 1, 4 và 5 cần được đặt, tức là 110011b ở dạng nhị phân
	  (ở dạng thập lục phân 0x33):
	  ::

# echo "0=0x33" > /sys/fs/resctrl/info/L3_MON/mbm_total_bytes_config

# cat /sys/fs/resctrl/info/L3_MON/mbm_total_bytes_config
	    0=0x33;1=0x7f;2=0x7f;3=0x7f

* Để thay đổi mbm_local_bytes để đếm tất cả các lần đọc bộ nhớ chậm
	  miền 0 và 1, bit 4 và 5 cần được đặt là 110000b
	  ở dạng nhị phân (ở dạng thập lục phân 0x30):
	  ::

# echo "0=0x30;1=0x30" > /sys/fs/resctrl/info/L3_MON/mbm_local_bytes_config

# cat /sys/fs/resctrl/info/L3_MON/mbm_local_bytes_config
	    0=0x30;1=0x30;3=0x15;4=0x15

"mbm_sign_mode":
	Các chế độ gán bộ đếm được hỗ trợ. Dấu ngoặc kèm theo cho biết chế độ nào
	được kích hoạt. Các sự kiện MBM liên quan đến bộ đếm có thể được đặt lại khi "mbm_sign_mode"
	được thay đổi.
	::

# cat /sys/fs/resctrl/info/L3_MON/mbm_sign_mode
	  [mbm_event]
	  mặc định

"mbm_event":

Chế độ mbm_event cho phép người dùng gán bộ đếm phần cứng cho sự kiện RMID
	ghép nối và giám sát việc sử dụng băng thông miễn là nó được chỉ định. Phần cứng
	tiếp tục theo dõi bộ đếm được chỉ định cho đến khi nó được bỏ gán rõ ràng bởi
	người dùng. Mỗi sự kiện trong nhóm resctrl có thể được chỉ định độc lập.

Ở chế độ này, sự kiện giám sát chỉ có thể tích lũy dữ liệu khi nó được sao lưu
	bằng bộ đếm phần cứng. Sử dụng "mbm_L3_signments" được tìm thấy trong mỗi CTRL_MON và MON
	nhóm để chỉ định sự kiện nào sẽ được chỉ định bộ đếm. số
	số bộ đếm có sẵn được mô tả trong tệp "num_mbm_cntrs". Thay đổi
	chế độ có thể khiến tất cả các bộ đếm trên tài nguyên được đặt lại.

Việc chuyển sang chế độ gán bộ đếm mbm_event yêu cầu người dùng phải gán bộ đếm
	đến các sự kiện. Nếu không, bộ đếm sự kiện MBM sẽ trả về 'Chưa được gán' khi đọc.

Chế độ này có lợi cho các nền tảng AMD hỗ trợ nhiều CTRL_MON hơn
	và nhóm MON so với các bộ đếm phần cứng hiện có. Theo mặc định, điều này
	tính năng này được kích hoạt trên nền tảng AMD với ABMC (Băng thông có thể gán
	Khả năng giám sát bộ đếm), đảm bảo bộ đếm vẫn được chỉ định ngay cả khi
	khi RMID tương ứng không được bất kỳ bộ xử lý nào sử dụng tích cực.

"mặc định":

Trong chế độ mặc định, resctrl giả sử có một bộ đếm phần cứng cho mỗi
	sự kiện trong mỗi nhóm CTRL_MON và MON. Trên nền tảng AMD, nó là
	nên sử dụng chế độ mbm_event, nếu được hỗ trợ, để ngăn việc thiết lập lại MBM
	các sự kiện giữa các lần đọc do các bộ đếm phân bổ lại phần cứng. Điều này có thể
	dẫn đến các giá trị sai lệch hoặc hiển thị "Không khả dụng" nếu không có bộ đếm nào được chỉ định
	đến sự kiện.

* Để bật chế độ gán bộ đếm "mbm_event":
	  ::

# echo "mbm_event" > /sys/fs/resctrl/info/L3_MON/mbm_sign_mode

* Để bật chế độ giám sát "mặc định":
	  ::

# echo "mặc định" > /sys/fs/resctrl/info/L3_MON/mbm_sign_mode

"num_mbm_ctrs":
	Số lượng bộ đếm tối đa (tổng số bộ đếm có sẵn và được chỉ định) trong
	từng miền khi hệ thống hỗ trợ chế độ mbm_event.

Ví dụ: trên hệ thống có giám sát băng thông bộ nhớ tối đa 32
	bộ đếm trong mỗi miền L3 của nó:
	::

# cat /sys/fs/resctrl/info/L3_MON/num_mbm_cntrs
	  0=32;1=32

"available_mbm_cntrs":
	Số lượng bộ đếm có sẵn để gán trong mỗi miền khi mbm_event
	chế độ được kích hoạt trên hệ thống.

Ví dụ: trên một hệ thống có sẵn 30 bộ đếm [phần cứng] có sẵn
	trong mỗi miền L3 của nó:
	::

# cat /sys/fs/resctrl/info/L3_MON/available_mbm_cntrs
	  0=30;1=30

"event_configs":
	Thư mục tồn tại khi chế độ gán bộ đếm "mbm_event" được hỗ trợ.
	Chứa thư mục con cho mỗi sự kiện MBM có thể được gán cho bộ đếm.

Hai sự kiện MBM được hỗ trợ theo mặc định: mbm_local_bytes và mbm_total_bytes.
	Mỗi thư mục con của sự kiện MBM chứa một tệp có tên "event_filter"
	được sử dụng để xem và sửa đổi các giao dịch bộ nhớ mà sự kiện MBM được định cấu hình
	với. Chỉ có thể truy cập tệp khi chế độ gán bộ đếm "mbm_event" được bật
	đã bật.

Danh sách các loại giao dịch bộ nhớ được hỗ trợ:

========================================================================================
	Tên Mô tả
	========================================================================================
	dirty_victim_writes_all Nạn nhân bẩn từ miền QOS đến tất cả các loại bộ nhớ
	remote_reads_slow_memory Đọc để làm chậm bộ nhớ trong miền NUMA không cục bộ
	local_reads_slow_memory Đọc để làm chậm bộ nhớ trong miền NUMA cục bộ
	remote_non_temporal_writes Ghi không theo thời gian vào miền NUMA không cục bộ
	local_non_temporal_writes Ghi không theo thời gian vào miền NUMA cục bộ
	remote_reads Đọc vào bộ nhớ trong miền NUMA không cục bộ
	local_reads Đọc vào bộ nhớ trong miền NUMA cục bộ
	========================================================================================

Ví dụ::

# cat/sys/fs/resctrl/info/L3_MON/event_configs/mbm_total_bytes/event_filter
	  local_reads,remote_reads,local_non_temporal_writes,remote_non_temporal_writes,
	  local_reads_slow_memory,remote_reads_slow_memory,dirty_victim_writes_all

# cat/sys/fs/resctrl/info/L3_MON/event_configs/mbm_local_bytes/event_filter
	  local_reads,local_non_temporal_writes,local_reads_slow_memory

Sửa đổi cấu hình sự kiện bằng cách ghi vào tệp "event_filter" bên trong
	thư mục "event_configs". Tệp "event_filter" đọc/ghi chứa
	cấu hình của sự kiện phản ánh những giao dịch bộ nhớ nào được nó tính.

Ví dụ::

# echo "local_reads, local_non_temporal_writes" >
	    /sys/fs/resctrl/info/L3_MON/event_configs/mbm_total_bytes/event_filter

# cat/sys/fs/resctrl/info/L3_MON/event_configs/mbm_total_bytes/event_filter
	   local_reads,local_non_temporal_writes

"mbm_sign_on_mkdir":
	Tồn tại khi chế độ gán bộ đếm "mbm_event" được hỗ trợ. Có thể truy cập
	chỉ khi chế độ gán bộ đếm "mbm_event" được bật.

Xác định xem bộ đếm có tự động được gán cho sự kiện RMID, MBM hay không
	ghép nối khi nhóm màn hình liên kết của nó được tạo thông qua mkdir. Được bật theo mặc định
	khi khởi động, cũng như khi chuyển từ chế độ "mặc định" sang gán bộ đếm "mbm_event"
	chế độ. Người dùng có thể vô hiệu hóa khả năng này bằng cách ghi vào giao diện.

"0":
		Tự động gán bị vô hiệu hóa.
	"1":
		Tự động gán được kích hoạt.

Ví dụ::

# echo 0 > /sys/fs/resctrl/info/L3_MON/mbm_sign_on_mkdir
	  # cat /sys/fs/resctrl/info/L3_MON/mbm_sign_on_mkdir
	  0

"max_threshold_occupancy":
		Tệp đọc/ghi cung cấp giá trị lớn nhất (trong
		byte) mà tại đó LLC_occupancy được sử dụng trước đó
		bộ đếm có thể được xem xét để tái sử dụng.

Nếu có sẵn chức năng giám sát từ xa thì sẽ có thư mục "PERF_PKG_MON"
với các tập tin sau:

"num_rmids":
		Số lượng RMID cho các sự kiện giám sát từ xa.

Trên Intel resctrl sẽ không kích hoạt các sự kiện đo từ xa nếu số lượng
		RMID có thể được theo dõi đồng thời thấp hơn tổng số
		RMID được hỗ trợ. Các sự kiện đo từ xa có thể được kích hoạt bắt buộc bằng
		tham số kernel "rdt=", nhưng điều này có thể làm giảm số lượng
		các nhóm giám sát có thể được tạo ra.

"mon_features":
		Liệt kê các sự kiện giám sát đo từ xa được kích hoạt trên hệ thống này.

Giới hạn trên cho số lượng "CTRL_MON" + "MON" có thể được tạo
là giá trị nhỏ hơn trong số các giá trị "num_rmids" của L3_MON và PERF_PKG_MON.

Cuối cùng, ở cấp cao nhất của thư mục "thông tin" có một tệp
được đặt tên là "last_cmd_status". Điều này được thiết lập lại với mỗi "lệnh" được ban hành
thông qua hệ thống tập tin (tạo thư mục mới hoặc ghi vào bất kỳ
tập tin điều khiển). Nếu lệnh thành công, nó sẽ đọc là "ok".
Nếu lệnh không thành công, nó sẽ cung cấp thêm thông tin có thể
được truyền tải trong lỗi trả về từ các thao tác trên tệp. Ví dụ.
::

# echo L3:0=f7 > sơ đồ
	bash: echo: lỗi ghi: Đối số không hợp lệ
	Thông tin # cat/last_cmd_status
	mặt nạ f7 có 1 bit không liên tiếp

Nhóm phân bổ và giám sát tài nguyên
=================================

Các nhóm tài nguyên được biểu diễn dưới dạng thư mục trong tệp resctrl
hệ thống.  Nhóm mặc định là thư mục gốc, ngay lập tức
sau khi cài đặt, sở hữu tất cả các tác vụ và cpu trong hệ thống và có thể thực hiện
sử dụng đầy đủ mọi nguồn lực.

Trên hệ thống có tính năng điều khiển RDT, các thư mục bổ sung có thể được
được tạo trong thư mục gốc chỉ định số lượng khác nhau của mỗi loại
tài nguyên (xem "lược đồ" bên dưới). Gốc và các cấp cao nhất bổ sung này
các thư mục được gọi là nhóm "CTRL_MON" bên dưới.

Trên hệ thống có RDT giám sát thư mục gốc và cấp cao nhất khác
thư mục chứa một thư mục có tên "mon_groups" trong đó bổ sung
các thư mục có thể được tạo để giám sát các tập hợp con các tác vụ trong CTRL_MON
nhóm đó là tổ tiên của họ. Những nhóm còn lại được gọi là "MON"
của tài liệu này.

Xóa một thư mục sẽ di chuyển tất cả các tác vụ và CPU thuộc sở hữu của nhóm nó
đại diện cho cha mẹ. Xóa một trong các nhóm CTRL_MON đã tạo
sẽ tự động xóa tất cả các nhóm MON bên dưới nó.

Hỗ trợ di chuyển các thư mục nhóm MON sang nhóm CTRL_MON gốc mới
nhằm mục đích thay đổi việc phân bổ tài nguyên của nhóm MON
mà không ảnh hưởng đến dữ liệu giám sát hoặc nhiệm vụ được giao. Hoạt động này
không được phép đối với các nhóm MON giám sát CPU. Không có động thái nào khác
hoạt động hiện được cho phép ngoài việc đổi tên đơn giản CTRL_MON hoặc
Nhóm MON.

Tất cả các nhóm đều chứa các tệp sau:

"nhiệm vụ":
	Đọc tập tin này sẽ hiển thị danh sách tất cả các nhiệm vụ thuộc về
	nhóm này. Viết id tác vụ vào tệp sẽ thêm tác vụ vào
	nhóm. Có thể thêm nhiều nhiệm vụ bằng cách tách các id nhiệm vụ
	bằng dấu phẩy. Nhiệm vụ sẽ được phân công tuần tự. Nhiều
	lỗi không được hỗ trợ. Một lỗi duy nhất gặp phải trong khi
	cố gắng phân công một nhiệm vụ sẽ khiến thao tác bị hủy bỏ và
	các nhiệm vụ đã được thêm trước khi thất bại sẽ vẫn còn trong nhóm.
	Các lỗi sẽ được ghi vào /sys/fs/resctrl/info/last_cmd_status.

Nếu nhóm là nhóm CTRL_MON thì nhiệm vụ sẽ bị xóa khỏi
	bất kỳ nhóm CTRL_MON nào trước đó sở hữu nhiệm vụ và cả từ
	bất kỳ nhóm MON nào sở hữu nhiệm vụ. Nếu nhóm là nhóm MON,
	thì nhiệm vụ này phải thuộc về CTRL_MON cha mẹ của nhiệm vụ này
	nhóm. Tác vụ sẽ bị xóa khỏi mọi nhóm MON trước đó.


"cpu":
	Đọc tệp này sẽ hiển thị bitmask của các CPU logic thuộc sở hữu của
	nhóm này. Viết mặt nạ vào tập tin này sẽ thêm và xóa
	CPU đến/từ nhóm này. Giống như tệp nhiệm vụ, hệ thống phân cấp được
	được duy trì ở nơi các nhóm MON chỉ có thể bao gồm các CPU thuộc sở hữu của
	nhóm CTRL_MON gốc.
	Khi nhóm tài nguyên ở chế độ khóa giả, tệp này sẽ
	chỉ có thể đọc được, phản ánh các CPU được liên kết với
	vùng giả khóa.


"danh sách cpu":
	Giống như "cpus", chỉ sử dụng phạm vi CPU thay vì bitmask.


Khi điều khiển được bật, tất cả các nhóm CTRL_MON cũng sẽ chứa:

"lược đồ":
	Danh sách tất cả các tài nguyên có sẵn cho nhóm này.
	Mỗi tài nguyên có dòng và định dạng riêng - xem bên dưới để biết chi tiết.

"kích thước":
	Phản chiếu việc hiển thị tệp "lược đồ" để hiển thị kích thước trong
	byte của mỗi lần phân bổ thay vì các bit đại diện cho
	phân bổ.

"chế độ":
	"Chế độ" của nhóm tài nguyên quyết định việc chia sẻ tài nguyên của nó
	phân bổ. Nhóm tài nguyên "có thể chia sẻ" cho phép chia sẻ tài nguyên của nó
	phân bổ trong khi nhóm tài nguyên "độc quyền" thì không. A
	vùng khóa giả bộ đệm được tạo bằng cách ghi đầu tiên
	"pseudo-locksetup" vào tệp "mode" trước khi ghi bộ đệm
	lược đồ của vùng bị khóa giả vào "lược đồ" của nhóm tài nguyên
	tập tin. Khi tạo vùng giả khóa thành công, chế độ sẽ
	tự động thay đổi thành "giả khóa".

"ctrl_hw_id":
	Chỉ có sẵn với tùy chọn gỡ lỗi. Mã định danh được sử dụng bởi phần cứng
	cho nhóm kiểm soát. Trên x86 đây là CLOSID.

Khi tính năng giám sát được bật, tất cả các nhóm MON cũng sẽ chứa:

"mon_data":
	Điều này chứa các thư mục cho từng miền màn hình.

Nếu chức năng giám sát L3 được bật, sẽ có thư mục "mon_L3_XX" dành cho
	mỗi phiên bản của bộ đệm L3. Mỗi thư mục chứa các tập tin cho phép
	Sự kiện L3 (ví dụ: "llc_occupancy", "mbm_total_bytes" và "mbm_local_bytes").

Nếu tính năng giám sát đo từ xa được bật, sẽ có "mon_PERF_PKG_YY"
	thư mục cho mỗi gói bộ xử lý vật lý. Mỗi thư mục chứa
	các tệp cho các sự kiện đo từ xa đã bật (ví dụ: "core_energy". "activity",
	"uops_retired", v.v.)

Các tệp info/ZZ0000ZZ/mon_features cung cấp danh sách đầy đủ các tính năng được bật
	tên sự kiện/tệp.

"năng lượng cốt lõi" báo cáo số dấu phẩy động cho năng lượng (tính bằng Joules)
	được tiêu thụ bởi các lõi (thanh ghi, đơn vị số học, bộ đệm TLB và L1/L2)
	trong quá trình thực hiện các lệnh được tổng hợp trên tất cả các CPU logic trên một
	gói dành cho nhóm giám sát hiện tại.

"hoạt động" cũng báo cáo giá trị dấu phẩy động (trong Farads).  Điều này cung cấp
	ước tính công việc được thực hiện độc lập với tần số mà CPU sử dụng
	để thi hành.

Lưu ý rằng "năng lượng cốt lõi" và "hoạt động" chỉ đo năng lượng/hoạt động trong
	"lõi" của CPU (đơn vị số học, bộ đệm TLB, L1 và L2, v.v.). Họ
	không bao gồm bộ đệm L3, bộ nhớ, thiết bị I/O, v.v.

Tất cả các sự kiện khác báo cáo giá trị số nguyên thập phân.

Trong nhóm MON, các tệp này cung cấp khả năng đọc giá trị hiện tại của
	sự kiện cho tất cả các nhiệm vụ trong nhóm. Trong CTRL_MON nhóm các tệp này
	cung cấp tổng cho tất cả các nhiệm vụ trong nhóm CTRL_MON và tất cả các nhiệm vụ trong
	Nhóm MON. Vui lòng xem phần ví dụ để biết thêm chi tiết về cách sử dụng.

Trên các hệ thống đã bật Cụm Sub-NUMA (SNC), có thêm
	thư mục cho mỗi nút (nằm trong thư mục "mon_L3_XX"
	đối với bộ đệm L3 mà chúng chiếm giữ). Chúng được đặt tên là "mon_sub_L3_YY"
	trong đó "YY" là số nút.

Khi chế độ gán bộ đếm 'mbm_event' được bật, việc đọc
	sự kiện MBM của nhóm MON trả về 'Chưa được gán' nếu không có phần cứng
	bộ đếm được gán cho nó. Đối với các nhóm CTRL_MON, 'Chưa được chỉ định' là
	được trả về nếu sự kiện MBM không có bộ đếm được chỉ định trong
	Nhóm CTRL_MON cũng như trong bất kỳ nhóm MON nào được liên kết với nó.

"mon_hw_id":
	Chỉ có sẵn với tùy chọn gỡ lỗi. Mã định danh được sử dụng bởi phần cứng
	cho nhóm giám sát. Trên x86 đây là RMID.

Khi bật tính năng giám sát, tất cả các nhóm MON cũng có thể chứa:

"mbm_L3_chuyển nhượng":
	Tồn tại khi chế độ gán bộ đếm "mbm_event" được hỗ trợ và liệt kê
	trạng thái chuyển nhượng ngược lại của nhóm.

Danh sách bài tập được hiển thị theo định dạng sau:

<Sự kiện>:<ID miền>=<Trạng thái chuyển nhượng>;<ID miền>=<Trạng thái chuyển nhượng>

Sự kiện: Một sự kiện MBM hợp lệ trong
	       Thư mục /sys/fs/resctrl/info/L3_MON/event_configs.

ID miền: ID miền hợp lệ. Khi viết, '*' áp dụng các thay đổi
		   tới tất cả các miền.

Bài tập nêu rõ:

_ : Không có bộ đếm nào được chỉ định.

e : Bộ đếm được chỉ định riêng.

Ví dụ:

Để hiển thị trạng thái gán bộ đếm cho nhóm mặc định.
	::

# cd /sys/fs/resctrl
	 # cat /sys/fs/resctrl/mbm_L3_signments
	   mbm_total_bytes:0=e;1=e
	   mbm_local_bytes:0=e;1=e

Bài tập có thể được sửa đổi bằng cách viết vào giao diện.

Ví dụ:

Để bỏ gán bộ đếm liên quan đến sự kiện mbm_total_bytes trên miền 0:
	::

# echo "mbm_total_bytes:0=_" > /sys/fs/resctrl/mbm_L3_signments
	 # cat /sys/fs/resctrl/mbm_L3_signments
	   mbm_total_bytes:0=_;1=e
	   mbm_local_bytes:0=e;1=e

Để bỏ chỉ định bộ đếm liên quan đến sự kiện mbm_total_bytes trên tất cả các miền:
	::

# echo "mbm_total_bytes:*=_" > /sys/fs/resctrl/mbm_L3_signments
	 # cat /sys/fs/resctrl/mbm_L3_signments
	   mbm_total_bytes:0=_;1=_
	   mbm_local_bytes:0=e;1=e

Để chỉ định bộ đếm được liên kết với sự kiện mbm_total_bytes trên tất cả các miền trong
	chế độ độc quyền:
	::

# echo "mbm_total_bytes:*=e" > /sys/fs/resctrl/mbm_L3_signments
	 # cat /sys/fs/resctrl/mbm_L3_signments
	   mbm_total_bytes:0=e;1=e
	   mbm_local_bytes:0=e;1=e

Khi tùy chọn gắn kết "mba_MBps" được sử dụng, tất cả các nhóm CTRL_MON cũng sẽ chứa:

"mba_MBps_event":
	Đọc tệp này cho biết sự kiện băng thông bộ nhớ nào được sử dụng
	làm đầu vào cho vòng phản hồi phần mềm nhằm duy trì băng thông bộ nhớ
	dưới giá trị được chỉ định trong tệp lược đồ. Viết
	tên của một trong những sự kiện băng thông bộ nhớ được hỗ trợ được tìm thấy trong
	/sys/fs/resctrl/info/L3_MON/mon_features thay đổi đầu vào
	sự kiện.

Quy tắc phân bổ nguồn lực
-------------------------

Khi một tác vụ đang chạy, các quy tắc sau sẽ xác định tài nguyên nào được sử dụng
có sẵn cho nó:

1) Nếu tác vụ là thành viên của nhóm không mặc định thì lược đồ
   cho nhóm đó được sử dụng.

2) Ngược lại nếu tác vụ thuộc nhóm mặc định nhưng đang chạy trên một
   CPU được gán cho một số nhóm cụ thể, sau đó là lược đồ cho
   Nhóm của CPU được sử dụng.

3) Nếu không thì sơ đồ cho nhóm mặc định sẽ được sử dụng.

Quy tắc giám sát tài nguyên
-------------------------
1) Nếu tác vụ là thành viên của nhóm MON hoặc nhóm CTRL_MON không mặc định
   thì các sự kiện RDT cho tác vụ sẽ được báo cáo trong nhóm đó.

2) Nếu một tác vụ là thành viên của nhóm CTRL_MON mặc định nhưng đang chạy
   trên CPU được gán cho một số nhóm cụ thể, sau đó là các sự kiện RDT
   cho nhiệm vụ sẽ được báo cáo trong nhóm đó.

3) Nếu không, các sự kiện RDT cho tác vụ sẽ được báo cáo ở cấp cơ sở
   Nhóm "mon_data".


Lưu ý về giám sát và kiểm soát chiếm dụng bộ đệm
===============================================
Khi chuyển nhiệm vụ từ nhóm này sang nhóm khác bạn nên nhớ rằng
điều này chỉ ảnh hưởng đến việc phân bổ bộ đệm ZZ0000ZZ theo tác vụ. Ví dụ. bạn có thể có
một tác vụ trong nhóm giám sát hiển thị 3 MB dung lượng bộ nhớ đệm. Nếu bạn di chuyển
sang một nhóm mới và ngay lập tức kiểm tra sự chiếm chỗ của nhóm cũ và mới
nhóm bạn có thể sẽ thấy rằng nhóm cũ vẫn hiển thị 3 MB và
nhóm mới số không. Khi tác vụ truy cập vào các vị trí vẫn còn trong bộ đệm từ
trước khi di chuyển, h/w không cập nhật bất kỳ bộ đếm nào. Trên một hệ thống bận rộn
bạn có thể sẽ thấy tỷ lệ chiếm chỗ trong nhóm cũ giảm xuống dưới dạng các dòng bộ nhớ đệm
bị trục xuất và tái sử dụng trong khi tỷ lệ lấp đầy trong nhóm mới tăng lên khi
tác vụ truy cập bộ nhớ và tải vào bộ đệm được tính dựa trên
thành viên trong nhóm mới.

Điều tương tự cũng áp dụng cho việc kiểm soát phân bổ bộ đệm. Di chuyển một nhiệm vụ vào một nhóm
với phân vùng bộ đệm nhỏ hơn sẽ không loại bỏ bất kỳ dòng bộ đệm nào. các
quá trình có thể tiếp tục sử dụng chúng từ phân vùng cũ.

Phần cứng sử dụng CLOSid(Lớp dịch vụ ID) và RMID(ID giám sát tài nguyên)
để xác định nhóm kiểm soát và nhóm giám sát tương ứng. Mỗi trong số
các nhóm tài nguyên được ánh xạ tới các ID này dựa trên loại nhóm. các
số lượng CLOSid và RMID bị giới hạn bởi phần cứng và do đó việc tạo ra
thư mục "CTRL_MON" có thể bị lỗi nếu chúng tôi dùng hết CLOSID hoặc RMID
và việc tạo nhóm "MON" có thể không thành công nếu chúng tôi hết RMID.

max_threshold_occupancy - khái niệm chung
------------------------------------------

Lưu ý rằng RMID sau khi được giải phóng có thể không có sẵn ngay lập tức để sử dụng dưới dạng
RMID vẫn được gắn thẻ dòng bộ đệm của người dùng RMID trước đó.
Do đó các RMID như vậy được đặt vào danh sách lấp lửng và được kiểm tra lại nếu bộ đệm
công suất thuê đã giảm. Nếu có lúc hệ thống có nhiều
các RMID lấp lửng nhưng chưa sẵn sàng để sử dụng, người dùng có thể thấy -EBUSY
trong mkdir.

max_threshold_occupancy là giá trị người dùng có thể định cấu hình để xác định
sức chứa mà RMID có thể được giải phóng.

Điểm theo dõi mon_llc_occupancy_limbo cung cấp tỷ lệ chiếm chỗ chính xác tính bằng byte
đối với một tập hợp con của RMID không có sẵn để phân bổ ngay lập tức.
Không thể dựa vào điều này để tạo ra sản lượng mỗi giây, nó có thể cần thiết
để cố gắng tạo một nhóm giám sát trống để buộc cập nhật. Đầu ra có thể
chỉ được tạo nếu việc tạo nhóm điều khiển hoặc giám sát không thành công.

Tệp lược đồ - khái niệm chung
---------------------------------
Mỗi dòng trong tệp mô tả một tài nguyên. Dòng bắt đầu bằng
tên của tài nguyên, theo sau là các giá trị cụ thể sẽ được áp dụng
trong mỗi trường hợp của tài nguyên đó trên hệ thống.

ID bộ nhớ đệm
---------
Trên các hệ thống thế hệ hiện tại có một bộ đệm L3 trên mỗi ổ cắm và L2
bộ nhớ đệm thường chỉ được chia sẻ bởi các siêu phân luồng trên lõi, nhưng điều này
không phải là một yêu cầu kiến trúc. Chúng ta có thể có nhiều L3 riêng biệt
bộ đệm trên một ổ cắm, nhiều lõi có thể chia sẻ bộ đệm L2. Vì vậy thay vào đó
sử dụng "socket" hoặc "core" để xác định tập hợp chia sẻ CPU logic
một tài nguyên mà chúng tôi sử dụng "ID bộ đệm". Ở mức bộ đệm nhất định, đây sẽ là một
số duy nhất trên toàn bộ hệ thống (nhưng nó không được đảm bảo là số
dãy liền kề nhau, có thể có khoảng trống).  Để tìm ID cho mỗi logic
CPU tìm trong /sys/devices/system/cpu/cpu*/cache/index*/id

Mặt nạ bit bộ đệm (CBM)
---------------------
Đối với tài nguyên bộ đệm, chúng tôi mô tả phần bộ đệm có sẵn
để phân bổ bằng cách sử dụng bitmask. Giá trị tối đa của mặt nạ được xác định
theo từng model CPU (và có thể khác nhau đối với các cấp độ bộ đệm khác nhau). Nó
được tìm thấy bằng CPUID, nhưng cũng được cung cấp trong thư mục "thông tin" của
hệ thống tệp resctrl trong "info/{resource}/cbm_mask". Một số phần cứng Intel
yêu cầu các mặt nạ này phải có tất cả các bit '1' trong một khối liền kề. Vì vậy
0x3, 0x6 và 0xC là mặt nạ 4 bit hợp pháp với hai bit được đặt, nhưng 0x5, 0x9
và 0xA thì không. Kiểm tra /sys/fs/resctrl/info/{resource}/sparse_masks
nếu giá trị 1s không liền kề được hỗ trợ. Trên hệ thống có mặt nạ 20 bit
mỗi bit đại diện cho 5% dung lượng của bộ đệm. Bạn có thể phân vùng
bộ đệm thành bốn phần bằng nhau với các mặt nạ: 0x1f, 0x3e0, 0x7c00, 0xf8000.

Những lưu ý về chế độ Cụm Sub-NUMA
==============================
Khi chế độ SNC được bật, Linux có thể tải các tác vụ cân bằng giữa Sub-NUMA
các nút dễ dàng hơn nhiều so với giữa các nút NUMA thông thường vì CPU
trên các nút Sub-NUMA chia sẻ cùng bộ đệm L3 và hệ thống có thể báo cáo
khoảng cách NUMA giữa các nút Sub-NUMA có giá trị thấp hơn mức sử dụng
cho các nút NUMA thông thường.

Các tệp giám sát cấp cao nhất trong mỗi thư mục "mon_L3_XX" cung cấp
tổng dữ liệu trên tất cả các nút SNC chia sẻ phiên bản bộ đệm L3.
Người dùng liên kết các tác vụ với CPU của nút Sub-NUMA cụ thể có thể đọc
"llc_occupancy", "mbm_total_bytes" và "mbm_local_bytes" trong
Thư mục "mon_sub_L3_YY" để lấy dữ liệu cục bộ của nút.

Việc phân bổ băng thông bộ nhớ vẫn được thực hiện ở bộ đệm L3
cấp độ. tức là điều khiển điều chỉnh được áp dụng cho tất cả các nút SNC.

Bitmap phân bổ bộ đệm L3 cũng áp dụng cho tất cả các nút SNC. Nhưng lưu ý rằng
số lượng bộ đệm L3 được biểu thị bằng mỗi bit được chia cho số
số nút SNC trên mỗi bộ đệm L3. Ví dụ. với bộ đệm 100 MB trên hệ thống có 10 bit
mặt nạ phân bổ mỗi bit thường đại diện cho 10MB. Khi bật chế độ SNC
với hai nút SNC trên mỗi bộ đệm L3, mỗi bit chỉ đại diện cho 5MB.

Phân bổ và giám sát băng thông bộ nhớ
==========================================

Đối với tài nguyên băng thông bộ nhớ, theo mặc định người dùng kiểm soát tài nguyên
bằng cách chỉ ra tỷ lệ phần trăm của tổng băng thông bộ nhớ.

Giá trị phần trăm băng thông tối thiểu cho mỗi model CPU được xác định trước
và có thể tra cứu thông qua "info/MB/min_bandwidth". Băng thông
mức độ chi tiết được phân bổ cũng phụ thuộc vào mô hình CPU và có thể
được tra cứu tại "thông tin/MB/băng thông_gran". Băng thông có sẵn
các bước kiểm soát là: min_bw + N * bw_gran. Giá trị trung gian được làm tròn
sang bước điều khiển tiếp theo có sẵn trên phần cứng.

Điều chỉnh băng thông là một cơ chế cụ thể cốt lõi trên một số chip Intel
SKU. Sử dụng cài đặt băng thông cao và băng thông thấp trên hai luồng
việc chia sẻ lõi có thể dẫn đến việc cả hai luồng bị hạn chế sử dụng
băng thông thấp (xem "thread_throttle_mode").

Thực tế là việc phân bổ băng thông bộ nhớ (MBA) có thể là cốt lõi
cơ chế cụ thể trong đó việc giám sát băng thông bộ nhớ (MBM) được thực hiện tại
cấp độ gói có thể dẫn đến nhầm lẫn khi người dùng cố gắng áp dụng điều khiển
thông qua MBA và sau đó theo dõi băng thông để xem các điều khiển có
hiệu quả. Dưới đây là những tình huống như vậy:

1. Người dùng ZZ0000ZZ có thể thấy băng thông thực tế tăng khi tỷ lệ phần trăm
   giá trị tăng lên:

Điều này có thể xảy ra khi băng thông bên ngoài L2 tổng hợp lớn hơn L3
băng thông bên ngoài. Hãy xem xét một SKL SKU với 24 lõi trên một gói và
trong đó L2 bên ngoài là 10Gbps (do đó tổng băng thông bên ngoài L2 là
240GBps) và băng thông ngoài L3 là 100Gbps. Bây giờ là khối lượng công việc với '20
luồng, có băng thông 50%, mỗi luồng tiêu thụ 5Gbps' sẽ tiêu tốn L3 tối đa
băng thông 100GBps mặc dù giá trị phần trăm được chỉ định chỉ là 50%
<< 100%. Do đó việc tăng phần trăm băng thông sẽ không mang lại bất kỳ
nhiều băng thông hơn. Điều này là do mặc dù băng thông bên ngoài L2 vẫn
có dung lượng, băng thông bên ngoài L3 được sử dụng đầy đủ. Cũng lưu ý rằng
điều này sẽ phụ thuộc vào số lượng lõi mà điểm chuẩn được chạy trên đó.

2. Tỷ lệ phần trăm băng thông giống nhau có thể có nghĩa là băng thông thực tế khác nhau
   tùy thuộc vào chủ đề # of:

Đối với cùng một SKU trong #1, một 'luồng đơn, với băng thông 10%' và '4
luồng, với băng thông 10%' có thể tiêu thụ tới 10GBps và 40GBps mặc dù
chúng có cùng băng thông phần trăm là 10%. Điều này đơn giản là vì như
các luồng bắt đầu sử dụng nhiều lõi hơn trong một nhóm thứ rdt, băng thông thực tế có thể
tăng hoặc thay đổi mặc dù phần trăm băng thông do người dùng chỉ định là như nhau.

Để giảm thiểu điều này và làm cho giao diện thân thiện hơn với người dùng,
resctrl cũng đã thêm hỗ trợ để chỉ định băng thông trong MiBps.  các
kernel bên dưới sẽ sử dụng cơ chế phản hồi phần mềm hoặc "Phần mềm
Controller(mba_sc)" đọc băng thông thực tế bằng bộ đếm MBM
và điều chỉnh phần trăm băng thông bộ nhớ để đảm bảo::

"băng thông thực tế < băng thông do người dùng chỉ định".

Theo mặc định, lược đồ sẽ lấy các giá trị phần trăm băng thông
trong đó người dùng có thể chuyển sang chế độ "Bộ điều khiển phần mềm MBA" bằng cách sử dụng
tùy chọn gắn kết 'mba_MBps'. Định dạng lược đồ được chỉ định ở bên dưới
phần.

Chi tiết tệp lược đồ L3 (mã và ưu tiên dữ liệu bị vô hiệu hóa)
----------------------------------------------------------------
Khi CDP bị vô hiệu hóa, định dạng lược đồ L3 là::

L3:<cache_id0>=<cbm>;<cache_id1>=<cbm>;...

Chi tiết tệp lược đồ L3 (CDP được bật thông qua tùy chọn gắn kết vào resctrl)
------------------------------------------------------------------
Khi bật CDP, điều khiển L3 được chia thành hai tài nguyên riêng biệt
vì vậy bạn có thể chỉ định các mặt nạ độc lập cho mã và dữ liệu như thế này ::

L3DATA:<cache_id0>=<cbm>;<cache_id1>=<cbm>;...
	L3CODE:<cache_id0>=<cbm>;<cache_id1>=<cbm>;...

Chi tiết tệp lược đồ L2
------------------------
CDP được hỗ trợ tại L2 bằng tùy chọn gắn 'cdpl2'. Lược đồ
định dạng là::

L2:<cache_id0>=<cbm>;<cache_id1>=<cbm>;...

hoặc

L2DATA:<cache_id0>=<cbm>;<cache_id1>=<cbm>;...
	L2CODE:<cache_id0>=<cbm>;<cache_id1>=<cbm>;...


Phân bổ băng thông bộ nhớ (chế độ mặc định)
------------------------------------------

Miền bộ nhớ b/w là bộ đệm L3.
::

MB:<cache_id0>=băng thông0;<cache_id1>=băng thông1;...

Phân bổ băng thông bộ nhớ được chỉ định trong MiBps
----------------------------------------------

Miền băng thông bộ nhớ là bộ đệm L3.
::

MB:<cache_id0>=bw_MiBps0;<cache_id1>=bw_MiBps1;...

Phân bổ băng thông bộ nhớ chậm (SMBA)
---------------------------------------
Phần cứng AMD hỗ trợ Phân bổ băng thông bộ nhớ chậm (SMBA).
CXL.memory là thiết bị bộ nhớ "chậm" duy nhất được hỗ trợ. Với
hỗ trợ SMBA, phần cứng cho phép phân bổ băng thông trên
các thiết bị bộ nhớ chậm. Nếu có nhiều thiết bị như vậy trong
hệ thống, logic điều chỉnh nhóm tất cả các nguồn chậm
với nhau và áp dụng giới hạn cho chúng một cách tổng thể.

Sự hiện diện của SMBA (với CXL.memory) không phụ thuộc vào bộ nhớ chậm
sự hiện diện của thiết bị. Nếu không có thiết bị như vậy trên hệ thống thì
cấu hình SMBA sẽ không ảnh hưởng đến hiệu suất của hệ thống.

Miền băng thông cho bộ nhớ chậm là bộ đệm L3. Tệp lược đồ của nó
được định dạng là:
::

SMBA:<cache_id0>=băng thông0;<cache_id1>=băng thông1;...

Đọc/ghi tệp lược đồ
---------------------------------
Đọc tệp lược đồ sẽ hiển thị trạng thái của tất cả các tài nguyên
trên tất cả các miền. Khi viết bạn chỉ cần xác định những giá trị đó
mà bạn muốn thay đổi.  Ví dụ.
::

Sơ đồ # cat
  L3DATA:0=fffff;1=fffff;2=fffff;3=fffff
  L3CODE:0=fffff;1=fffff;2=fffff;3=fffff
  # echo "L3DATA:2=3c0;" > sơ đồ
  Sơ đồ # cat
  L3DATA:0=fffff;1=fffff;2=3c0;3=fffff
  L3CODE:0=fffff;1=fffff;2=fffff;3=fffff

Đọc/ghi tệp lược đồ (trên hệ thống AMD)
--------------------------------------------------
Đọc tệp lược đồ sẽ hiển thị giới hạn băng thông hiện tại trên tất cả
tên miền. Các tài nguyên được phân bổ là bội số của một phần tám GB/s.
Khi ghi vào tệp, bạn cần chỉ định id bộ đệm nào bạn muốn
cấu hình giới hạn băng thông.

Ví dụ: để phân bổ giới hạn 2GB/s cho id bộ đệm đầu tiên:

::

Sơ đồ # cat
    MB:0=2048;1=2048;2=2048;3=2048
    L3:0=ffff;1=ffff;2=ffff;3=ffff

# echo "MB:1=16" > sơ đồ
  Sơ đồ # cat
    MB:0=2048;1= 16;2=2048;3=2048
    L3:0=ffff;1=ffff;2=ffff;3=ffff

Đọc/ghi tệp lược đồ (trên hệ thống AMD) với tính năng SMBA
--------------------------------------------------------------------
Đọc và ghi tệp lược đồ giống như không có SMBA trong
phần trên.

Ví dụ: để phân bổ giới hạn 8GB/giây cho id bộ đệm đầu tiên:

::

Sơ đồ # cat
    SMBA:0=2048;1=2048;2=2048;3=2048
      MB:0=2048;1=2048;2=2048;3=2048
      L3:0=ffff;1=ffff;2=ffff;3=ffff

# echo "SMBA:1=64" > sơ đồ
  Sơ đồ # cat
    SMBA:0=2048;1= 64;2=2048;3=2048
      MB:0=2048;1=2048;2=2048;3=2048
      L3:0=ffff;1=ffff;2=ffff;3=ffff

Khóa giả bộ đệm
====================
CAT cho phép người dùng chỉ định dung lượng bộ đệm mà một
ứng dụng có thể điền vào. Khóa giả bộ đệm được xây dựng trên thực tế là một
CPU vẫn có thể đọc và ghi dữ liệu được phân bổ trước bên ngoài hiện tại
khu vực được phân bổ khi truy cập bộ đệm. Với tính năng giả khóa bộ đệm, dữ liệu có thể được
được tải trước vào một phần bộ đệm dành riêng mà không ứng dụng nào có thể
điền vào và từ thời điểm đó trở đi sẽ chỉ phục vụ các lần truy cập bộ đệm. Bộ đệm
bộ nhớ giả bị khóa có thể truy cập được vào không gian người dùng nơi
ứng dụng có thể ánh xạ nó vào không gian địa chỉ ảo của nó và do đó có
vùng bộ nhớ có độ trễ đọc trung bình giảm.

Việc tạo vùng khóa giả bộ đệm được kích hoạt bởi một yêu cầu
từ người dùng để làm như vậy được kèm theo một sơ đồ của khu vực
bị khóa giả. Vùng giả khóa bộ đệm được tạo như sau:

- Tạo phân bổ CAT CLOSNEW với CBM khớp với sơ đồ
  từ người dùng vùng bộ đệm sẽ chứa khóa giả
  trí nhớ. Vùng này không được trùng lặp với bất kỳ phân bổ CAT/CLOS hiện tại nào
  trên hệ thống và không được phép trùng lặp trong tương lai với vùng bộ đệm này
  trong khi vùng giả khóa tồn tại.
- Tạo vùng bộ nhớ liền kề có cùng kích thước với bộ đệm
  khu vực.
- Xóa bộ nhớ đệm, tắt trình tìm nạp trước phần cứng, tắt tính năng ưu tiên.
- Biến CLOSNEW thành CLOS đang hoạt động và chạm vào bộ nhớ được phân bổ để tải
  nó vào bộ nhớ đệm.
- Đặt CLOS trước đó làm hoạt động.
- Tại thời điểm này, CLOSNEW đóng có thể được giải phóng - bộ đệm
  vùng giả khóa được bảo vệ miễn là CBM của nó không xuất hiện trong
  bất kỳ phân bổ CAT nào. Mặc dù vùng giả bộ đệm sẽ bị khóa từ
  điểm này không xuất hiện trong bất kỳ CBM nào của bất kỳ CLOS nào có ứng dụng chạy với
  bất kỳ CLOS nào cũng có thể truy cập bộ nhớ trong vùng bị khóa giả vì
  khu vực tiếp tục phân phát các lần truy cập bộ nhớ đệm.
- Vùng bộ nhớ liền kề được tải vào bộ đệm sẽ bị lộ
  không gian người dùng như một thiết bị ký tự.

Khóa giả bộ đệm làm tăng khả năng dữ liệu sẽ được giữ lại
trong bộ đệm thông qua việc định cấu hình cẩn thận tính năng CAT và kiểm soát
hành vi ứng dụng. Không có gì đảm bảo rằng dữ liệu được đặt trong
bộ đệm. Các hướng dẫn như INVD, WBINVD, CLFLUSH, v.v. vẫn có thể trục xuất
dữ liệu "bị khóa" từ bộ đệm. Quản lý nguồn điện Trạng thái C có thể co lại hoặc
tắt nguồn bộ nhớ đệm. Các trạng thái C sâu hơn sẽ tự động bị hạn chế trên
tạo vùng giả khóa.

Yêu cầu ứng dụng sử dụng vùng khóa giả phải chạy
có ái lực với lõi (hoặc một tập hợp con của lõi) được liên kết
với bộ đệm chứa vùng giả khóa. Kiểm tra vệ sinh
trong mã sẽ không cho phép ứng dụng ánh xạ bộ nhớ bị khóa giả
trừ khi nó chạy có ái lực với các lõi được liên kết với bộ đệm mà trên đó
khu vực giả khóa cư trú. Việc kiểm tra độ tỉnh táo chỉ được thực hiện trong thời gian
xử lý mmap() ban đầu, không có sự thực thi nào sau đó và
Bản thân ứng dụng cần đảm bảo nó vẫn phù hợp với lõi chính xác.

Khóa giả được thực hiện theo hai giai đoạn:

1) Trong giai đoạn đầu tiên người quản trị hệ thống phân bổ một phần
   bộ đệm nên được dành riêng cho khóa giả. Tại thời điểm này một
   phần bộ nhớ tương đương được cấp phát, được nạp vào
   phần bộ đệm và được hiển thị dưới dạng thiết bị ký tự.
2) Trong giai đoạn thứ hai, ứng dụng không gian người dùng ánh xạ (mmap())
   bộ nhớ giả khóa vào không gian địa chỉ của nó.

Giao diện khóa giả bộ đệm
------------------------------
Vùng giả khóa được tạo bằng giao diện resctrl như sau:

1) Tạo nhóm tài nguyên mới bằng cách tạo thư mục mới trong /sys/fs/resctrl.
2) Thay đổi chế độ của nhóm tài nguyên mới thành "pseudo-locksetup" bằng cách viết
   "pseudo-locksetup" vào tệp "mode".
3) Ghi sơ đồ của vùng bị khóa giả vào tệp "lược đồ". Tất cả
   các bit trong lược đồ phải được "không sử dụng" theo "bit_usage"
   tập tin.

Khi tạo vùng giả khóa thành công, tệp "chế độ" sẽ chứa
"bị khóa giả" và một thiết bị ký tự mới có cùng tên với tài nguyên
nhóm sẽ tồn tại trong/dev/pseudo_lock. Thiết bị ký tự này có thể được mmap()'ed
theo không gian của người dùng để có được quyền truy cập vào vùng bộ nhớ bị khóa giả.

Bạn có thể tìm thấy một ví dụ về việc tạo và sử dụng vùng giả khóa bộ nhớ đệm bên dưới.

Giao diện gỡ lỗi khóa giả bộ đệm
----------------------------------------
Giao diện gỡ lỗi khóa giả được bật theo mặc định (nếu
CONFIG_DEBUG_FS được bật) và có thể tìm thấy trong /sys/kernel/debug/resctrl.

Không có cách rõ ràng nào để kernel kiểm tra xem bộ nhớ được cung cấp có
vị trí có trong bộ đệm. Giao diện gỡ lỗi giả khóa sử dụng
cơ sở hạ tầng theo dõi để cung cấp hai cách để đo vị trí bộ nhớ đệm của
vùng giả khóa:

1) Độ trễ truy cập bộ nhớ bằng cách sử dụng điểm theo dõi pseudo_lock_mem_latency. dữ liệu
   từ các phép đo này được hiển thị tốt nhất bằng cách sử dụng trình kích hoạt lịch sử (xem
   ví dụ dưới đây). Trong thử nghiệm này, vùng giả khóa được đi qua tại
   một bước dài 32 byte trong khi tìm nạp trước phần cứng và ưu tiên
   bị vô hiệu hóa. Điều này cũng cung cấp một hình ảnh thay thế của bộ đệm
   đánh và trượt.
2) Đo lường số lần truy cập và bỏ lỡ bộ nhớ đệm bằng cách sử dụng bộ đếm chính xác dành riêng cho từng kiểu máy nếu
   có sẵn. Tùy thuộc vào mức độ bộ nhớ đệm trên hệ thống mà pseudo_lock_l2
   và các dấu vết pseudo_lock_l3 có sẵn.

Khi một vùng bị khóa giả được tạo, một thư mục debugfs mới sẽ được tạo cho
nó trong các bản gỡ lỗi dưới dạng /sys/kernel/debug/resctrl/<newdir>. Một đĩa đơn
tệp chỉ ghi, pseudo_lock_measure, có trong thư mục này. các
phép đo vùng giả khóa phụ thuộc vào số được ghi vào vùng này
tập tin gỡ lỗi:

1:
     ghi "1" vào tệp pseudo_lock_measure sẽ kích hoạt độ trễ
     phép đo được ghi lại trong điểm theo dõi pseudo_lock_mem_latency. Xem
     ví dụ dưới đây.
2:
     ghi "2" vào tệp pseudo_lock_measure sẽ kích hoạt bộ đệm L2
     đo lường nơi cư trú (lượt truy cập và bỏ lỡ bộ nhớ cache) được ghi lại trong
     điểm theo dõi pseudo_lock_l2. Xem ví dụ dưới đây.
3:
     ghi "3" vào tệp pseudo_lock_measure sẽ kích hoạt bộ đệm L3
     đo lường nơi cư trú (lượt truy cập và bỏ lỡ bộ nhớ cache) được ghi lại trong
     điểm theo dõi pseudo_lock_l3.

Tất cả các phép đo được ghi lại bằng cơ sở hạ tầng theo dõi. Điều này đòi hỏi
các điểm theo dõi liên quan sẽ được kích hoạt trước khi phép đo được kích hoạt.

Ví dụ về giao diện gỡ lỗi độ trễ
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Trong ví dụ này, vùng khóa giả có tên "newlock" đã được tạo. Đây là
cách chúng tôi có thể đo độ trễ trong chu kỳ đọc từ khu vực này và
trực quan hóa dữ liệu này bằng biểu đồ có sẵn nếu CONFIG_HIST_TRIGGERS
được đặt::

# :> /sys/kernel/tracing/trace
  # echo 'hist:keys=latency' > /sys/kernel/tracing/events/resctrl/pseudo_lock_mem_latency/trigger
  # echo 1 > /sys/kernel/tracing/events/resctrl/pseudo_lock_mem_latency/bật
  # echo 1 > /sys/kernel/debug/resctrl/newlock/pseudo_lock_measure
  # echo 0 > /sys/kernel/tracing/events/resctrl/pseudo_lock_mem_latency/bật
  # cat/sys/kernel/tracing/events/resctrl/pseudo_lock_mem_latency/hist

Biểu đồ # event
  #
  Thông tin về # trigger: hist:keys=latency:vals=hitcount:sort=hitcount:size=2048 [hoạt động]
  #

{ độ trễ: 456 } số lần truy cập: 1
  { độ trễ: 50 } số lần truy cập: 83
  { độ trễ: 36 } số lần truy cập: 96
  { độ trễ: 44 } số lần truy cập: 174
  { độ trễ: 48 } số lần truy cập: 195
  { độ trễ: 46 } số lần truy cập: 262
  { độ trễ: 42 } số lần truy cập: 693
  { độ trễ: 40 } số lần truy cập: 3204
  { độ trễ: 38 } số lần truy cập: 3484

Tổng số:
      Lượt truy cập: 8192
      Bài dự thi: 9
    Đã đánh rơi: 0

Ví dụ về gỡ lỗi truy cập/lỡ bộ nhớ đệm
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Trong ví dụ này, vùng giả khóa có tên "newlock" đã được tạo trên L2
bộ đệm của một nền tảng. Đây là cách chúng tôi có thể lấy thông tin chi tiết về các lần truy cập bộ đệm
và bỏ lỡ việc sử dụng bộ đếm chính xác của nền tảng.
::

# :> /sys/kernel/tracing/trace
  # echo 1 > /sys/kernel/tracing/events/resctrl/pseudo_lock_l2/enable
  # echo 2 > /sys/kernel/debug/resctrl/newlock/pseudo_lock_measure
  # echo 0 > /sys/kernel/tracing/events/resctrl/pseudo_lock_l2/enable
  # cat /sys/kernel/truy tìm/dấu vết

# tracer: không
  #
  #                              _-----=> tắt irqs
  # / _---=> cần được chỉnh sửa lại
  # | / _---=> hardirq/softirq
  # || / _--=> ưu tiên độ sâu
  # ||| / trì hoãn
  #           ZZ0003ZZ-ZZ0004ZZ CPU# ||||    TIMESTAMP FUNCTION
  #              ZZ0008ZZ ZZ0001ZZ||ZZ0002ZZ |
  pseudo_lock_mea-1672 [002] .... 3132.860500: pseudo_lock_l2: lượt truy cập=4097 miss=0


Ví dụ về cách sử dụng phân bổ RDT
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

1) Ví dụ 1

Trên máy có hai ổ cắm (một bộ đệm L3 cho mỗi ổ cắm) chỉ có bốn bit
đối với mặt nạ bit bộ đệm, b/w tối thiểu là 10% với băng thông bộ nhớ
độ chi tiết 10%.
::

# mount -t resctrl resctrl /sys/fs/resctrl
  # cd /sys/fs/resctrl
  # mkdir p0 p1
  # echo "L3:0=3;1=c\nMB:0=50;1=50" > /sys/fs/resctrl/p0/schemata
  # echo "L3:0=3;1=3\nMB:0=50;1=50" > /sys/fs/resctrl/p1/schemata

Nhóm tài nguyên mặc định không được sửa đổi nên chúng ta có quyền truy cập vào tất cả các phần
của tất cả các bộ đệm (tệp lược đồ của nó ghi "L3:0=f;1=f").

Các tác vụ nằm dưới sự kiểm soát của nhóm "p0" chỉ có thể phân bổ từ
50% "thấp hơn" trên ID bộ đệm 0 và 50% "trên" của ID bộ đệm 1.
Các tác vụ trong nhóm "p1" sử dụng 50% bộ đệm "thấp hơn" trên cả hai ổ cắm.

Tương tự, các tác vụ nằm dưới sự kiểm soát của nhóm "p0" có thể sử dụng
bộ nhớ tối đa b/w là 50% trên socket0 và 50% trên socket 1.
Các tác vụ trong nhóm "p1" cũng có thể sử dụng 50% bộ nhớ b/w trên cả hai ổ cắm.
Lưu ý rằng không giống như mặt nạ bộ đệm, b/w bộ nhớ không thể chỉ định liệu những mặt nạ này có
phân bổ có thể chồng chéo hoặc không. Việc phân bổ chỉ định mức tối đa
b/w mà nhóm có thể sử dụng và quản trị viên hệ thống có thể định cấu hình
b/w tương ứng.

Nếu resctrl đang sử dụng bộ điều khiển phần mềm (mba_sc) thì người dùng có thể nhập
b/w tối đa tính bằng MB thay vì giá trị phần trăm.
::

# echo "L3:0=3;1=c\nMB:0=1024;1=500" > /sys/fs/resctrl/p0/schemata
  # echo "L3:0=3;1=3\nMB:0=1024;1=500" > /sys/fs/resctrl/p1/schemata

Trong ví dụ trên, các tác vụ trong "p1" và "p0" trên socket 0 sẽ sử dụng b/w tối đa
là 1024 MB trong đó trên socket 1 họ sẽ sử dụng 500 MB.

2) Ví dụ 2

Lại có hai ổ cắm, nhưng lần này có mặt nạ 20 bit thực tế hơn.

Hai tác vụ thời gian thực pid=1234 chạy trên bộ xử lý 0 và pid=5678 chạy trên bộ xử lý
bộ xử lý 1 trên socket 0 trên máy 2 socket và lõi kép. Để tránh ồn ào
hàng xóm, mỗi nhiệm vụ trong số hai nhiệm vụ thời gian thực chỉ chiếm một phần tư
của bộ đệm L3 trên ổ cắm 0.
::

# mount -t resctrl resctrl /sys/fs/resctrl
  # cd /sys/fs/resctrl

Đầu tiên chúng ta đặt lại sơ đồ cho nhóm mặc định sao cho nhóm "trên"
50% bộ đệm L3 trên socket 0 và 50% bộ nhớ b/w không thể được sử dụng bởi
công việc thông thường::

# echo "L3:0=3ff;1=fffff\nMB:0=50;1=100" > sơ đồ

Tiếp theo, chúng tôi tạo một nhóm tài nguyên cho nhiệm vụ thời gian thực đầu tiên của mình và đưa ra
nó truy cập vào 25% bộ đệm "trên cùng" trên ổ cắm 0.
::

# mkdir p0
  # echo "L3:0=f8000;1=fffff" > p0/sơ đồ

Cuối cùng, chúng tôi chuyển nhiệm vụ thời gian thực đầu tiên của mình vào nhóm tài nguyên này. Chúng tôi
cũng sử dụng tasket(1) để đảm bảo tác vụ luôn chạy trên CPU chuyên dụng
trên socket 0. Hầu hết việc sử dụng các nhóm tài nguyên cũng sẽ hạn chế
các tác vụ của bộ xử lý đang chạy.
::

# echo 1234 > p0/nhiệm vụ
  # taskset -cp 1 1234

Tương tự cho tác vụ thời gian thực thứ hai (với 25% bộ đệm còn lại)::

# mkdir p1
  # echo "L3:0=7c00;1=fffff" > p1/sơ đồ
  # echo 5678 > p1/nhiệm vụ
  # taskset -cp 2 5678

Đối với cùng một hệ thống 2 socket có tài nguyên b/w bộ nhớ và CAT L3,
lược đồ sẽ trông như thế nào (Giả sử min_bandwidth 10 và Bandwidth_gran là
10):

Đối với tác vụ thời gian thực đầu tiên của chúng tôi, tác vụ này sẽ yêu cầu 20% bộ nhớ b/w trên socket 0.
::

# echo -e "L3:0=f8000;1=fffff\nMB:0=20;1=100" > p0/schemata

Đối với tác vụ thời gian thực thứ hai của chúng tôi, tác vụ này sẽ yêu cầu thêm 20% bộ nhớ b/w
trên ổ cắm 0.
::

# echo -e "L3:0=f8000;1=fffff\nMB:0=20;1=100" > p0/schemata

3) Ví dụ 3

Một hệ thống socket duy nhất có các tác vụ thời gian thực chạy trên lõi 4-7 và
khối lượng công việc không theo thời gian thực được gán cho lõi 0-3. Văn bản chia sẻ nhiệm vụ thời gian thực
và dữ liệu, do đó không cần phải có liên kết cho mỗi nhiệm vụ và do sự tương tác
với kernel, điều mong muốn là kernel trên các lõi này chia sẻ L3 với
các nhiệm vụ.
::

# mount -t resctrl resctrl /sys/fs/resctrl
  # cd /sys/fs/resctrl

Đầu tiên chúng ta đặt lại sơ đồ cho nhóm mặc định sao cho nhóm "trên"
50% bộ đệm L3 trên socket 0 và 50% băng thông bộ nhớ trên socket 0
không thể được sử dụng bởi các tác vụ thông thường::

# echo "L3:0=3ff\nMB:0=50" > sơ đồ

Tiếp theo, chúng tôi tạo một nhóm tài nguyên cho lõi thời gian thực của mình và cấp cho nó quyền truy cập
tới 50% bộ đệm "trên cùng" trên ổ cắm 0 và 50% băng thông bộ nhớ trên
ổ cắm 0.
::

# mkdir p0
  # echo "L3:0=ffc00\nMB:0=50" > p0/sơ đồ

Cuối cùng, chúng tôi chuyển lõi 4-7 sang nhóm mới và đảm bảo rằng
kernel và các tác vụ đang chạy ở đó nhận được 50% bộ đệm. Họ nên
cũng nhận được 50% băng thông bộ nhớ giả sử rằng các lõi 4-7 là SMT
anh chị em và chỉ các luồng thời gian thực được lên lịch trên các lõi 4-7.
::

# echo F0 > p0/cpus

4) Ví dụ 4

Các nhóm tài nguyên trong các ví dụ trước đều ở chế độ "có thể chia sẻ" mặc định
chế độ cho phép chia sẻ phân bổ bộ đệm của họ. Nếu một nhóm tài nguyên
định cấu hình phân bổ bộ đệm thì không có gì ngăn cản nhóm tài nguyên khác
trùng lặp với sự phân bổ đó.

Trong ví dụ này, một nhóm tài nguyên độc quyền mới sẽ được tạo trên L2 CAT
hệ thống có hai phiên bản bộ đệm L2 có thể được cấu hình bằng 8 bit
mặt nạ bit công suất. Nhóm tài nguyên độc quyền mới sẽ được cấu hình để sử dụng
25% cho mỗi phiên bản bộ đệm.
::

# mount -t resctrl resctrl /sys/fs/resctrl/
  # cd /sys/fs/resctrl

Đầu tiên, chúng tôi quan sát thấy nhóm mặc định được cấu hình để phân bổ cho tất cả L2
bộ đệm::

Sơ đồ # cat
  L2:0=ff;1=ff

Chúng ta có thể cố gắng tạo nhóm tài nguyên mới vào thời điểm này, nhưng nó sẽ
thất bại do trùng lặp với sơ đồ của nhóm mặc định::

# mkdir p0
  # echo 'L2:0=0x3;1=0x3' > p0/sơ đồ
  # cat p0/chế độ
  có thể chia sẻ
  # echo độc quyền > p0/chế độ
  -sh: echo: lỗi ghi: Đối số không hợp lệ
  Thông tin # cat/last_cmd_status
  chồng chéo lược đồ

Để đảm bảo rằng không có sự trùng lặp với nhóm tài nguyên khác, mặc định
lược đồ của nhóm tài nguyên phải thay đổi, tạo điều kiện cho lược đồ mới
nhóm tài nguyên trở thành độc quyền.
::

# echo 'L2:0=0xfc;1=0xfc' > sơ đồ
  # echo độc quyền > p0/chế độ
  # grep. p0/*
  p0/cpu:0
  p0/chế độ:độc quyền
  p0/lược đồ:L2:0=03;1=03
  p0/kích thước:L2:0=262144;1=262144

Một nhóm tài nguyên mới khi tạo sẽ không trùng lặp với một tài nguyên độc quyền
nhóm::

# mkdir p1
  # grep. p1/*
  p1/cpu:0
  p1/chế độ:có thể chia sẻ
  p1/sơ đồ:L2:0=fc;1=fc
  p1/kích thước:L2:0=786432;1=786432

Bit_usage sẽ phản ánh cách sử dụng bộ đệm ::

Thông tin # cat/L2/bit_usage
  0=SSSSSSEE;1=SSSSSSEE

Một nhóm tài nguyên không thể bị buộc phải chồng chéo với một nhóm tài nguyên độc quyền::

# echo 'L2:0=0x1;1=0x1' > p1/sơ đồ
  -sh: echo: lỗi ghi: Đối số không hợp lệ
  Thông tin # cat/last_cmd_status
  trùng lặp với nhóm độc quyền

Ví dụ về khóa giả bộ đệm
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Khóa phần bộ đệm L2 khỏi bộ đệm id 1 bằng CBM 0x3. giả bị khóa
vùng được hiển thị tại /dev/pseudo_lock/newlock có thể được cung cấp cho
ứng dụng để tranh luận với mmap().
::

# mount -t resctrl resctrl /sys/fs/resctrl/
  # cd /sys/fs/resctrl

Đảm bảo rằng có sẵn các bit có thể được khóa giả, vì chỉ
Các bit không sử dụng có thể được khóa giả. Các bit được khóa giả cần phải được khóa giả.
đã bị xóa khỏi lược đồ của nhóm tài nguyên mặc định ::

Thông tin # cat/L2/bit_usage
  0=SSSSSSSS;1=SSSSSSSS
  # echo 'L2:1=0xfc' > sơ đồ
  Thông tin # cat/L2/bit_usage
  0=SSSSSSSS;1=SSSSSS00

Tạo một nhóm tài nguyên mới sẽ được liên kết với khóa giả
vùng, chỉ ra rằng nó sẽ được sử dụng cho vùng giả khóa và
định cấu hình bitmask dung lượng vùng giả khóa được yêu cầu::

# mkdir khóa mới
  Thiết lập khóa giả # echo > khóa/chế độ mới
  # echo 'L2:1=0x3' > khóa mới/sơ đồ

Khi thành công, chế độ của nhóm tài nguyên sẽ chuyển sang chế độ giả khóa,
bit_usage sẽ phản ánh vùng bị khóa giả và thiết bị ký tự
để lộ vùng bị khóa giả sẽ tồn tại ::

Chế độ/khóa mới # cat
  giả khóa
  Thông tin # cat/L2/bit_usage
  0=SSSSSSSS;1=SSSSSSPP
  # ls -l /dev/pseudo_lock/newlock
  crw------- 1 gốc gốc 243, 0 ngày 3 tháng 4 05:01 /dev/pseudo_lock/newlock

::

/*
  * Mã ví dụ để truy cập một trang của vùng bộ đệm giả bị khóa
  * từ không gian người dùng.
  */
  #define _GNU_SOURCE
  #include <fcntl.h>
  #include <lịch trình.h>
  #include <stdio.h>
  #include <stdlib.h>
  #include <unistd.h>
  #include <sys/mman.h>

/*
  * Ứng dụng được yêu cầu chỉ chạy với mối quan hệ
  * lõi được liên kết với vùng bị khóa giả. CPU đây
  * được mã hóa cứng để thuận tiện cho ví dụ.
  */
  int cpuid tĩnh = 2;

int main(int argc, char *argv[])
  {
    cpu_set_t cpuset;
    trang_size dài;
    void * ánh xạ;
    int dev_fd;
    int ret;

page_size = sysconf(_SC_PAGESIZE);

CPU_ZERO(&cpuset);
    CPU_SET(cpuid, &cpuset);
    ret = sched_setaffinity(0, sizeof(cpuset), &cpuset);
    nếu (ret < 0) {
      perror("sched_setaffinity");
      thoát (EXIT_FAILURE);
    }

dev_fd = open("/dev/pseudo_lock/newlock", O_RDWR);
    nếu (dev_fd < 0) {
      lỗi ("mở");
      thoát (EXIT_FAILURE);
    }

ánh xạ = mmap(0, page_size, PROT_READ | PROT_WRITE, MAP_SHARED,
            dev_fd, 0);
    if (ánh xạ == MAP_FAILED) {
      lỗi ("mmap");
      đóng(dev_fd);
      thoát (EXIT_FAILURE);
    }

/* Ứng dụng tương tác với bộ nhớ giả khóa @mapping */

ret = munmap(ánh xạ, page_size);
    nếu (ret < 0) {
      perror("munmap");
      đóng(dev_fd);
      thoát (EXIT_FAILURE);
    }

đóng(dev_fd);
    thoát (EXIT_SUCCESS);
  }

Khóa giữa các ứng dụng
----------------------------

Một số thao tác nhất định trên hệ thống tập tin resctrl, bao gồm đọc/ghi
đến/từ nhiều tệp, phải là nguyên tử.

Ví dụ, việc phân bổ một vùng dành riêng cho bộ nhớ đệm L3
liên quan đến:

1. Đọc cbmmasks từ mỗi thư mục hoặc "bit_usage" trên mỗi tài nguyên
  2. Tìm tập hợp các bit liền kề trong mặt nạ bit CBM toàn cầu rõ ràng
     trong bất kỳ thư mục cbmmasks
  3. Tạo một thư mục mới
  4. Đặt các bit tìm thấy ở bước 2 vào tệp "lược đồ" thư mục mới

Nếu hai ứng dụng cố gắng phân bổ không gian đồng thời thì chúng có thể
cuối cùng phải phân bổ các bit giống nhau để việc đặt chỗ được chia sẻ thay vì
độc quyền.

Để phối hợp các hoạt động nguyên tử trên các resctrlfs và để tránh sự cố
ở trên, quy trình khóa sau được khuyến nghị:

Khóa dựa trên đàn, có sẵn trong libc và cũng như shell
lệnh kịch bản

Viết khóa:

A) Lấy đàn (LOCK_EX) trên /sys/fs/resctrl
 B) Đọc/ghi cấu trúc thư mục.
 C) khóa vui vẻ

Đọc khóa:

A) Lấy đàn (LOCK_SH) trên /sys/fs/resctrl
 B) Nếu thành công hãy đọc cấu trúc thư mục.
 C) khóa vui vẻ

Ví dụ với bash::

Cấu trúc thư mục đọc # Atomically
  $ đàn -s /sys/fs/resctrl/ tìm /sys/fs/resctrl

Nội dung thư mục # Read và tạo thư mục con mới

$ cat create-dir.sh
  tìm /sys/fs/resctrl/ > out.txt
  mặt nạ = hàm-of(output.txt)
  mkdir /sys/fs/resctrl/newres/
  mặt nạ tiếng vang>/sys/fs/resctrl/newres/schemata

$ đàn /sys/fs/resctrl/ ./create-dir.sh

Ví dụ với C::

/*
  * Mã ví dụ có khóa tư vấn
  * trước khi truy cập hệ thống tập tin resctrl
  */
  #include <sys/file.h>
  #include <stdlib.h>

void resctrl_take_shared_lock(int fd)
  {
    int ret;

/* lấy khóa chia sẻ trên hệ thống tập tin resctrl */
    ret = đàn(fd, LOCK_SH);
    nếu (ret) {
      perror("đàn");
      thoát (-1);
    }
  }

void resctrl_take_exclusive_lock(int fd)
  {
    int ret;

/* nhả khóa trên hệ thống tập tin resctrl */
    ret = đàn(fd, LOCK_EX);
    nếu (ret) {
      perror("đàn");
      thoát (-1);
    }
  }

void resctrl_release_lock(int fd)
  {
    int ret;

/* lấy khóa chia sẻ trên hệ thống tập tin resctrl */
    ret = đàn(fd, LOCK_UN);
    nếu (ret) {
      perror("đàn");
      thoát (-1);
    }
  }

khoảng trống chính(void)
  {
    int fd, ret;

fd = open("/sys/fs/resctrl", O_DIRECTORY);
    nếu (fd == -1) {
      lỗi ("mở");
      thoát (-1);
    }
    resctrl_take_shared_lock(fd);
    /*code đọc nội dung thư mục */
    resctrl_release_lock(fd);

resctrl_take_exclusive_lock(fd);
    /*code đọc và ghi nội dung thư mục */
    resctrl_release_lock(fd);
  }

Ví dụ về Giám sát RDT cùng với việc sử dụng phân bổ
=======================================================
Đọc dữ liệu được giám sát
----------------------
Việc đọc tệp sự kiện (ví dụ: mon_data/mon_L3_00/llc_occupancy) sẽ
hiển thị ảnh chụp nhanh hiện tại về tỷ lệ sử dụng LLC của MON tương ứng
nhóm hoặc nhóm CTRL_MON.


Ví dụ 1 (Giám sát nhóm CTRL_MON và tập hợp con các tác vụ trong nhóm CTRL_MON)
------------------------------------------------------------------------
Trên máy có hai ổ cắm (một bộ đệm L3 cho mỗi ổ cắm) chỉ có bốn bit
cho mặt nạ bit bộ đệm::

# mount -t resctrl resctrl /sys/fs/resctrl
  # cd /sys/fs/resctrl
  # mkdir p0 p1
  # echo "L3:0=3;1=c" > /sys/fs/resctrl/p0/schemata
  # echo "L3:0=3;1=3" > /sys/fs/resctrl/p1/schemata
  # echo 5678 > p1/nhiệm vụ
  # echo 5679 > p1/nhiệm vụ

Nhóm tài nguyên mặc định không được sửa đổi nên chúng ta có quyền truy cập vào tất cả các phần
của tất cả các bộ đệm (tệp lược đồ của nó ghi "L3:0=f;1=f").

Các tác vụ nằm dưới sự kiểm soát của nhóm "p0" chỉ có thể phân bổ từ
50% "thấp hơn" trên ID bộ đệm 0 và 50% "trên" của ID bộ đệm 1.
Các tác vụ trong nhóm "p1" sử dụng 50% bộ đệm "thấp hơn" trên cả hai ổ cắm.

Tạo các nhóm giám sát và chỉ định một tập hợp con nhiệm vụ cho mỗi nhóm giám sát.
::

# cd /sys/fs/resctrl/p1/mon_groups
  # mkdir m11 m12
  # echo 5678 > m11/nhiệm vụ
  # echo 5679 > m12/nhiệm vụ

tìm nạp dữ liệu (dữ liệu được hiển thị theo byte)
::

# cat m11/mon_data/mon_L3_00/llc_occupancy
  16234000
  # cat m11/mon_data/mon_L3_01/llc_occupancy
  14789000
  # cat m12/mon_data/mon_L3_00/llc_occupancy
  16789000

Nhóm ctrl_mon gốc hiển thị dữ liệu tổng hợp.
::

# cat /sys/fs/resctrl/p1/mon_data/mon_l3_00/llc_occupancy
  31234000

Ví dụ 2 (Giám sát một nhiệm vụ từ khi tạo ra nó)
--------------------------------------------
Trên máy có hai ổ cắm (một bộ đệm L3 cho mỗi ổ cắm)::

# mount -t resctrl resctrl /sys/fs/resctrl
  # cd /sys/fs/resctrl
  # mkdir p0 p1

RMID được phân bổ cho nhóm sau khi được tạo và do đó <cmd>
bên dưới được giám sát từ khi tạo ra nó.
::

# echo $$ > /sys/fs/resctrl/p1/tác vụ
  # <cmd>

Lấy dữ liệu::

# cat /sys/fs/resctrl/p1/mon_data/mon_l3_00/llc_occupancy
  31789000

Ví dụ 3 (Màn hình không hỗ trợ CAT hoặc trước khi tạo nhóm CAT)
---------------------------------------------------------------------

Giả sử một hệ thống như HSW chỉ có CQM và không hỗ trợ CAT. Trong trường hợp này
resctrl vẫn sẽ gắn kết nhưng không thể tạo thư mục CTRL_MON.
Nhưng người dùng có thể tạo các nhóm MON khác nhau trong nhóm gốc
có thể giám sát tất cả các tác vụ bao gồm cả các luồng kernel.

Điều này cũng có thể được sử dụng để lập hồ sơ kích thước bộ đệm của công việc trước khi được thực hiện.
có thể phân bổ chúng vào các nhóm phân bổ khác nhau.
::

# mount -t resctrl resctrl /sys/fs/resctrl
  # cd /sys/fs/resctrl
  # mkdir mon_groups/m01
  # mkdir mon_groups/m02

# echo 3478 > /sys/fs/resctrl/mon_groups/m01/tác vụ
  # echo 2467 > /sys/fs/resctrl/mon_groups/m02/tasks

Giám sát các nhóm riêng biệt và cũng có thể nhận dữ liệu theo từng miền. Từ
bên dưới rõ ràng là các nhiệm vụ chủ yếu được thực hiện trên
tên miền (ổ cắm) 0.
::

# cat /sys/fs/resctrl/mon_groups/m01/mon_L3_00/llc_occupancy
  31234000
  # cat /sys/fs/resctrl/mon_groups/m01/mon_L3_01/llc_occupancy
  34555
  # cat /sys/fs/resctrl/mon_groups/m02/mon_L3_00/llc_occupancy
  31234000
  # cat /sys/fs/resctrl/mon_groups/m02/mon_L3_01/llc_occupancy
  32789


Ví dụ 4 (Giám sát các tác vụ theo thời gian thực)
-----------------------------------

Một hệ thống socket duy nhất có các tác vụ thời gian thực chạy trên lõi 4-7
và các tác vụ không theo thời gian thực trên các CPU khác. Chúng tôi muốn theo dõi bộ đệm
chiếm chỗ của các luồng thời gian thực trên các lõi này.
::

# mount -t resctrl resctrl /sys/fs/resctrl
  # cd /sys/fs/resctrl
  # mkdir p1

Di chuyển cpu 4-7 sang p1::

# echo f0 > p1/cpus

Xem ảnh chụp nhanh về tỷ lệ sử dụng phòng của LLC::

# cat /sys/fs/resctrl/p1/mon_data/mon_L3_00/llc_occupancy
  11234000


Ví dụ về cách làm việc với mbm_sign_mode
========================================

Một. Kiểm tra xem chế độ gán bộ đếm MBM có được hỗ trợ hay không.
::

# mount -t resctrl resctrl /sys/fs/resctrl/

# cat /sys/fs/resctrl/info/L3_MON/mbm_sign_mode
  [mbm_event]
  mặc định

Chế độ "mbm_event" được phát hiện và kích hoạt.

b. Kiểm tra xem có bao nhiêu bộ đếm có thể gán được hỗ trợ.
::

# cat /sys/fs/resctrl/info/L3_MON/num_mbm_cntrs
  0=32;1=32

c. Kiểm tra xem có bao nhiêu bộ đếm có thể gán để gán trong mỗi miền.
::

# cat /sys/fs/resctrl/info/L3_MON/available_mbm_cntrs
  0=30;1=30

d. Để liệt kê các trạng thái chỉ định của nhóm mặc định.
::

# cat /sys/fs/resctrl/mbm_L3_signments
  mbm_total_bytes:0=e;1=e
  mbm_local_bytes:0=e;1=e

đ.  Để bỏ gán bộ đếm liên quan đến sự kiện mbm_total_bytes trên miền 0.
::

# echo "mbm_total_bytes:0=_" > /sys/fs/resctrl/mbm_L3_signments
  # cat /sys/fs/resctrl/mbm_L3_signments
  mbm_total_bytes:0=_;1=e
  mbm_local_bytes:0=e;1=e

f. Để bỏ chỉ định bộ đếm liên quan đến sự kiện mbm_total_bytes trên tất cả các miền.
::

# echo "mbm_total_bytes:*=_" > /sys/fs/resctrl/mbm_L3_signments
  # cat /sys/fs/resctrl/mbm_L3_signment
  mbm_total_bytes:0=_;1=_
  mbm_local_bytes:0=e;1=e

g. Để chỉ định bộ đếm được liên kết với sự kiện mbm_total_bytes trên tất cả các miền trong
chế độ độc quyền.
::

# echo "mbm_total_bytes:*=e" > /sys/fs/resctrl/mbm_L3_signments
  # cat /sys/fs/resctrl/mbm_L3_signments
  mbm_total_bytes:0=e;1=e
  mbm_local_bytes:0=e;1=e

h. Đọc các sự kiện mbm_total_bytes và mbm_local_bytes của nhóm mặc định. có
không có thay đổi trong việc đọc các sự kiện với bài tập.
::

# cat /sys/fs/resctrl/mon_data/mon_L3_00/mbm_total_bytes
  779247936
  # cat /sys/fs/resctrl/mon_data/mon_L3_01/mbm_total_bytes
  562324232
  # cat/sys/fs/resctrl/mon_data/mon_L3_00/mbm_local_bytes
  212122123
  # cat/sys/fs/resctrl/mon_data/mon_L3_01/mbm_local_bytes
  121212144

Tôi. Kiểm tra cấu hình sự kiện.
::

# cat/sys/fs/resctrl/info/L3_MON/event_configs/mbm_total_bytes/event_filter
  local_reads,remote_reads,local_non_temporal_writes,remote_non_temporal_writes,
  local_reads_slow_memory,remote_reads_slow_memory,dirty_victim_writes_all

# cat/sys/fs/resctrl/info/L3_MON/event_configs/mbm_local_bytes/event_filter
  local_reads,local_non_temporal_writes,local_reads_slow_memory

j. Thay đổi cấu hình sự kiện cho mbm_local_bytes.
::

# echo "local_reads, local_non_temporal_writes, local_reads_slow_memory, remote_reads" >
  /sys/fs/resctrl/info/L3_MON/event_configs/mbm_local_bytes/event_filter

# cat/sys/fs/resctrl/info/L3_MON/event_configs/mbm_local_bytes/event_filter
  local_reads,local_non_temporal_writes,local_reads_slow_memory,remote_reads

k. Bây giờ hãy đọc lại các sự kiện địa phương. Lần đọc đầu tiên có thể quay lại với "Không khả dụng"
trạng thái. Lần đọc mbm_local_bytes tiếp theo sẽ hiển thị giá trị hiện tại.
::

# cat/sys/fs/resctrl/mon_data/mon_L3_00/mbm_local_bytes
  Không có sẵn
  # cat/sys/fs/resctrl/mon_data/mon_L3_00/mbm_local_bytes
  2252323
  # cat/sys/fs/resctrl/mon_data/mon_L3_01/mbm_local_bytes
  Không có sẵn
  # cat/sys/fs/resctrl/mon_data/mon_L3_01/mbm_local_bytes
  1566565

tôi. Người dùng có tùy chọn quay lại 'mặc định' mbm_sign_mode nếu được yêu cầu. Đây có thể là
được thực hiện bằng lệnh sau. Lưu ý rằng việc chuyển đổi mbm_sign_mode có thể đặt lại tất cả
bộ đếm MBM (và do đó là tất cả các sự kiện MBM) của tất cả các nhóm resctrl.
::

# echo "mặc định" > /sys/fs/resctrl/info/L3_MON/mbm_sign_mode
  # cat /sys/fs/resctrl/info/L3_MON/mbm_sign_mode
  mbm_event
  [mặc định]

m. Ngắt kết nối hệ thống tập tin resctrl.
::

# umount /sys/fs/resctrl/

Lỗi Intel RDT
================

Bộ đếm Intel MBM có thể báo cáo băng thông bộ nhớ hệ thống không chính xác
-----------------------------------------------------------------

Errata SKX99 cho máy chủ Skylake và BDF102 cho máy chủ Broadwell.

Sự cố: Bộ đếm theo dõi số liệu theo dõi băng thông bộ nhớ Intel (MBM)
theo ID giám sát tài nguyên được chỉ định (RMID) cho logic đó
cốt lõi. Thanh ghi IA32_QM_CTR (MSR 0xC8E), được sử dụng để báo cáo những điều này
số liệu, có thể báo cáo băng thông hệ thống không chính xác đối với các giá trị RMID nhất định.

Ý nghĩa: Do lỗi, băng thông bộ nhớ hệ thống có thể không khớp
những gì được báo cáo.

Cách giải quyết: Các số đọc tổng và cục bộ của MBM được sửa theo
bảng hệ số hiệu chỉnh sau:

+--------------+--------------+---------------+--------+
|core count	|rmid số |rmid threshold	|hệ số hiệu chỉnh|
+--------------+--------------+---------------+--------+
ZZ0002ZZ8 ZZ0003ZZ1.000000 |
+--------------+--------------+---------------+--------+
ZZ0004ZZ16 ZZ0005ZZ1.000000 |
+--------------+--------------+---------------+--------+
ZZ0006ZZ24 ZZ0007ZZ0.969650 |
+--------------+--------------+---------------+--------+
ZZ0008ZZ32 ZZ0009ZZ1.000000 |
+--------------+--------------+---------------+--------+
ZZ0010ZZ48 ZZ0011ZZ0.969650 |
+--------------+--------------+---------------+--------+
ZZ0012ZZ56 ZZ0013ZZ1.142857 |
+--------------+--------------+---------------+--------+
ZZ0014ZZ64 ZZ0015ZZ1.000000 |
+--------------+--------------+---------------+--------+
ZZ0016ZZ72 ZZ0017ZZ1.185115 |
+--------------+--------------+---------------+--------+
ZZ0018ZZ80 ZZ0019ZZ1.066553 |
+--------------+--------------+---------------+--------+
ZZ0020ZZ88 ZZ0021ZZ1.454545 |
+--------------+--------------+---------------+--------+
ZZ0022ZZ96 ZZ0023ZZ1.000000 |
+--------------+--------------+---------------+--------+
ZZ0024ZZ104 ZZ0025ZZ1.230769 |
+--------------+--------------+---------------+--------+
ZZ0026ZZ112 ZZ0027ZZ1.142857 |
+--------------+--------------+---------------+--------+
ZZ0028ZZ120 ZZ0029ZZ1.066667 |
+--------------+--------------+---------------+--------+
ZZ0030ZZ128 ZZ0031ZZ1.000000 |
+--------------+--------------+---------------+--------+
ZZ0032ZZ136 ZZ0033ZZ1.254863 |
+--------------+--------------+---------------+--------+
ZZ0034ZZ144 ZZ0035ZZ1.185255 |
+--------------+--------------+---------------+--------+
ZZ0036ZZ152 ZZ0037ZZ1.000000 |
+--------------+--------------+---------------+--------+
ZZ0038ZZ160 ZZ0039ZZ1.066667 |
+--------------+--------------+---------------+--------+
ZZ0040ZZ168 ZZ0041ZZ1.000000 |
+--------------+--------------+---------------+--------+
ZZ0042ZZ176 ZZ0043ZZ1.454334 |
+--------------+--------------+---------------+--------+
ZZ0044ZZ184 ZZ0045ZZ1.000000 |
+--------------+--------------+---------------+--------+
ZZ0046ZZ192 ZZ0047ZZ0.969744 |
+--------------+--------------+---------------+--------+
ZZ0048ZZ200 ZZ0049ZZ1.280246 |
+--------------+--------------+---------------+--------+
ZZ0050ZZ208 ZZ0051ZZ1.230921 |
+--------------+--------------+---------------+--------+
ZZ0052ZZ216 ZZ0053ZZ1.000000 |
+--------------+--------------+---------------+--------+
ZZ0054ZZ224 ZZ0055ZZ1.143118 |
+--------------+--------------+---------------+--------+

Nếu rmid > ngưỡng rmid, giá trị tổng và cục bộ của MBM sẽ được nhân lên
bằng hệ số hiệu chỉnh.

Nhìn thấy:

1. Lỗi lỗi SKX99 trong Cập nhật thông số kỹ thuật dòng bộ xử lý Intel Xeon có thể mở rộng:
ZZ0000ZZ

2. Lỗi lỗi BDF102 trong Cập nhật thông số kỹ thuật dòng sản phẩm bộ xử lý Intel Xeon E5-2600 v4:
ZZ0000ZZ

3. Lỗi trong Công nghệ Giám đốc Tài nguyên Intel (Intel RDT) trên Tài liệu tham khảo Bộ xử lý có khả năng mở rộng Intel Xeon thế hệ thứ 2:
ZZ0000ZZ

để biết thêm thông tin.