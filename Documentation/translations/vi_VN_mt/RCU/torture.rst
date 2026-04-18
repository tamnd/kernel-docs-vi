.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/RCU/torture.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

================================
Hoạt động thử nghiệm tra tấn RCU
================================


CONFIG_RCU_TORTURE_TEST
=======================

Tùy chọn cấu hình CONFIG_RCU_TORTURE_TEST có sẵn cho tất cả RCU
triển khai.  Nó tạo ra một mô-đun hạt nhân rcitorture có thể
được tải để chạy thử nghiệm tra tấn.  Kiểm tra định kỳ đầu ra
thông báo trạng thái qua printk(), có thể được kiểm tra qua dmesg
lệnh (có lẽ là "tra tấn").  Bài kiểm tra được bắt đầu
khi mô-đun được tải và dừng khi mô-đun được dỡ tải.

Các tham số mô-đun có tiền tố là "rcitorture." trong
Tài liệu/admin-guide/kernel-parameters.txt.

đầu ra
======

Kết quả thống kê như sau::

rcu-torture:--- Bắt đầu kiểm tra: nreaders=16 nfakewriters=4 stat_interval=30 Verbose=0 test_no_idle_hz=1 shuffle_interval=3 stutter=5 irqreader=1 fqs_duration=0 fqs_holdoff=0 fqs_stutter=3 test_boost=1/0 test_boost_interval=7 test_boost_duration=4
	rcu-tra tấn: rtc: (null) ver: 155441 tfle: 0 rta: 155441 rtaf: 8884 rtf: 155440 rtmbe: 0 rtbe: 0 rtbke: 0 rtbre: 0 rtbf: 0 rtb: 0 nt: 3055767
	rcu-tra tấn: Ống đọc: 727860534 34213 0 0 0 0 0 0 0 0 0
	rcu-tra tấn: Reader Lô: 727877838 17003 0 0 0 0 0 0 0 0 0
	rcu-tra tấn: Lưu thông khối tự do: 155440 155440 155440 155440 155440 155440 155440 155440 155440 155440 0
	rcu-torture:--- Kết thúc bài kiểm tra: SUCCESS: nreaders=16 nfakewriters=4 stat_interval=30verbose=0 test_no_idle_hz=1 shuffle_interval=3 stutter=5 irqreader=1 fqs_duration=0 fqs_holdoff=0 fqs_stutter=3 test_boost=1/0 test_boost_interval=7 test_boost_duration=4

Lệnh "dmesg | grep tra tấn:" sẽ trích xuất thông tin này trên
hầu hết các hệ thống.  Trên các cấu hình bí truyền hơn, có thể cần phải
sử dụng các lệnh khác để truy cập đầu ra của printk()s được sử dụng bởi
thử nghiệm tra tấn RCU.  Các printk() sử dụng KERN_ALERT, vì vậy chúng nên
trở nên hiển nhiên.  ;-)

Dòng đầu tiên và cuối cùng hiển thị các tham số mô-đun rcitorture và
dòng cuối cùng hiển thị "SUCCESS" hoặc "FAILURE", dựa trên rcutorture's
tự động xác định xem RCU có hoạt động chính xác hay không.

Các mục như sau:

* "rtc": Địa chỉ thập lục phân của cấu trúc hiện được hiển thị
	tới độc giả.

* "ver": Số lần thực hiện tác vụ ghi RCU kể từ khi khởi động
	đã thay đổi cấu trúc hiển thị cho người đọc.

* "tfle": Nếu khác 0, biểu thị rằng "danh sách tra tấn tự do"
	chứa các cấu trúc được đặt vào vùng "rtc" trống.
	Điều kiện này rất quan trọng vì nó có thể đánh lừa bạn suy nghĩ
	RCU đang hoạt động nhưng không.  :-/

* "rta": Số lượng công trình được phân bổ khỏi danh sách tự do tra tấn.

* "rtaf": Số lượng phân bổ từ danh sách tự do tra tấn có
	không thành công do danh sách trống.  Chuyện này không có gì lạ
	khác 0, nhưng thật tệ nếu nó chiếm một phần lớn của
	giá trị được chỉ định bởi "rta".

* "rtf": Số người được tự do vào danh sách tự do tra tấn.

* "rtmbe": Giá trị khác 0 cho biết rcutorture tin rằng
	rcu_sign_pointer() và rcu_dereference() không hoạt động
	một cách chính xác.  Giá trị này phải bằng 0.

* "rtbe": Giá trị khác 0 cho biết rằng một trong các rcu_barrier()
	Nhóm chức năng không hoạt động chính xác.

* "rtbke": rcutorture không thể tạo kthread thời gian thực
	được sử dụng để buộc đảo ngược mức độ ưu tiên của RCU.  Giá trị này phải bằng 0.

* "rtbre": Mặc dù rcutorture đã tạo kthread thành công
	được sử dụng để buộc đảo ngược mức độ ưu tiên của RCU, nó không thể thiết lập chúng
	đến mức độ ưu tiên thời gian thực là 1. Giá trị này phải bằng 0.

* "rtbf": Số lần tăng ưu tiên RCU không thành công
	để giải quyết đảo ngược ưu tiên RCU.

* "rtb": Số lần rcutorture cố gắng ép buộc
	điều kiện đảo ngược ưu tiên RCU.  Nếu bạn đang thử nghiệm RCU
	tăng mức độ ưu tiên thông qua tham số mô-đun "test_boost", điều này
	giá trị phải khác không.

* "nt": Số lần rcutorture chạy mã read-side RCU từ
	trong một bộ xử lý hẹn giờ.  Giá trị này chỉ được khác 0
	nếu bạn đã chỉ định tham số mô-đun "irqreader".

* "Reader Pipe": Biểu đồ về "độ tuổi" của các cấu trúc mà độc giả nhìn thấy.
	Nếu bất kỳ mục nào sau hai mục đầu tiên khác 0, RCU sẽ bị hỏng.
	Và rctorture in chuỗi cờ lỗi "!!!" để đảm bảo
	bạn để ý.  Tuổi của cấu trúc mới được phân bổ là bằng không,
	nó sẽ trở thành một khi bị xóa khỏi tầm nhìn của người đọc và
	tăng lên một lần trong mỗi thời gian gia hạn sau đó -- và được giải phóng
	sau khi trải qua thời gian gia hạn (RCU_TORTURE_PIPE_LEN-2).

Đầu ra hiển thị ở trên được lấy từ một thiết bị hoạt động chính xác
	RCU.  Nếu bạn muốn xem nó trông như thế nào khi bị vỡ, hãy phá vỡ
	chính nó.  ;-)

* "Reader Batch": Một biểu đồ khác về "độ tuổi" của các cấu trúc được nhìn thấy
	bởi độc giả, nhưng xét về mặt lật ngược (hoặc theo đợt) thì đúng hơn
	hơn về thời gian ân hạn.  Số pháp lý khác 0
	các mục lại là hai.  Sở dĩ có quan điểm riêng biệt này là vì
	đôi khi việc để mục thứ ba xuất hiện trong
	Danh sách "Reader Batch" hơn trong danh sách "Reader Pipe".

* "Lưu thông khối miễn phí": Hiển thị số lượng cấu trúc tra tấn
	đã đạt đến một điểm nhất định trong đường ống.  Yếu tố đầu tiên
	phải tương ứng chặt chẽ với số lượng cấu trúc được phân bổ,
	số thứ hai sau số đã bị xóa khỏi chế độ xem của người đọc,
	và tất cả trừ phần cuối cùng còn lại với số lượng tương ứng
	trải qua thời gian ân hạn.  Mục cuối cùng phải bằng 0,
	vì nó chỉ tăng lên nếu bộ đếm của cấu trúc tra tấn
	bằng cách nào đó được tăng lên xa hơn mức cần thiết.

Việc triển khai khác nhau của RCU có thể cung cấp các cách triển khai cụ thể
thông tin bổ sung.  Ví dụ: Tree SRCU cung cấp những thông tin sau
dòng bổ sung::

tra tấn srcud: Cây SRCU per-CPU(idx=0): 0(35,-21) 1(-4,24) 2(1,1) 3(-26,20) 4(28,-47) 5(-9,4) 6(-10,14) 7(-14,11) T(1,6)

Dòng này hiển thị trạng thái bộ đếm trên mỗi CPU, trong trường hợp này là cho Tree SRCU
sử dụng srcu_struct được phân bổ động (do đó "srcud-" thay vì
"srcu-").  Các số trong ngoặc là giá trị của "cũ" và
bộ đếm "hiện tại" cho CPU tương ứng.  Giá trị "idx" ánh xạ
các giá trị "cũ" và "hiện tại" vào mảng cơ bản và rất hữu ích cho
gỡ lỗi.  Mục "T" cuối cùng chứa tổng số bộ đếm.

Sử dụng trên các bản dựng hạt nhân cụ thể
===============================

Đôi khi, bạn nên tra tấn RCU trên một bản dựng kernel cụ thể,
ví dụ: khi chuẩn bị đưa bản dựng kernel đó vào sản xuất.
Trong trường hợp đó, kernel phải được xây dựng với CONFIG_RCU_TORTURE_TEST=m
để thử nghiệm có thể được bắt đầu bằng modprobe và kết thúc bằng rmmod.

Ví dụ: đoạn mã sau có thể được sử dụng để tra tấn RCU::

#!/bin/sh

kết cấu modprobe
	ngủ 3600
	câu chuyện rmmod
	dmesg | tra tấn grep:

Đầu ra có thể được kiểm tra thủ công để tìm cờ lỗi "!!!".
Tất nhiên người ta có thể tạo ra một tập lệnh phức tạp hơn để tự động
đã kiểm tra các lỗi như vậy.  Lệnh "rmmod" buộc "SUCCESS",
Chỉ báo "FAILURE" hoặc "RCU_HOTPLUG" sẽ được printk()ed.  đầu tiên
hai là tự giải thích, trong khi cái cuối cùng chỉ ra rằng mặc dù có
không có lỗi RCU nào, các vấn đề về cắm nóng CPU đã được phát hiện.


Cách sử dụng trên hạt nhân chính
=========================

Khi sử dụng rcutorture để kiểm tra các thay đổi đối với chính RCU, thường
cần thiết để xây dựng một số hạt nhân để kiểm tra sự thay đổi đó
trên một loạt các kết hợp của các tùy chọn Kconfig có liên quan
và các tham số khởi động kernel có liên quan.  Trong tình huống này, hãy sử dụng
modprobe và rmmod có thể khá tốn thời gian và dễ xảy ra lỗi.

Do đó, các công cụ/kiểm tra/selftests/rcutorture/bin/kvm.sh
tập lệnh có sẵn để thử nghiệm dòng chính cho x86, arm64 và
powerpc.  Theo mặc định, nó sẽ chạy một loạt các thử nghiệm được chỉ định bởi
công cụ/kiểm tra/selftests/rcutorture/configs/rcu/CFLIST, với mỗi bài kiểm tra
chạy trong 30 phút trong hệ điều hành khách sử dụng không gian người dùng tối thiểu
được cung cấp bởi initrd được tạo tự động.  Sau khi các bài kiểm tra được
hoàn tất, các sản phẩm xây dựng và kết quả đầu ra của bảng điều khiển sẽ được phân tích
để tìm lỗi và kết quả của các lần chạy được tóm tắt.

Trên các hệ thống lớn hơn, việc kiểm tra kết cấu có thể được tăng tốc bằng cách vượt qua
--cpus đối số với kvm.sh.  Ví dụ: trên hệ thống 64-CPU, "--cpus 43"
sẽ sử dụng tối đa 43 CPU để chạy thử nghiệm đồng thời, điều này kể từ phiên bản 5.4 sẽ
hoàn thành tất cả các kịch bản trong hai đợt, giảm thời gian hoàn thành
từ khoảng tám giờ đến khoảng một giờ (không tính thời gian xây dựng
mười sáu hạt nhân).  Đối số "--dryrun sched" sẽ không chạy thử nghiệm,
mà thay vào đó hãy cho bạn biết các bài kiểm tra sẽ được sắp xếp thành từng đợt như thế nào.  Cái này
có thể hữu ích khi tính toán số lượng CPU cần chỉ định trong --cpus
lý lẽ.

Không phải tất cả các thay đổi đều yêu cầu phải chạy tất cả các kịch bản.  Ví dụ, một sự thay đổi
tới Tree SRCU chỉ có thể chạy các kịch bản SRCU-N và SRCU-P bằng cách sử dụng
--configs đối số với kvm.sh như sau: "--configs 'SRCU-N SRCU-P'".
Các hệ thống lớn có thể chạy nhiều bản sao của toàn bộ các kịch bản,
ví dụ: một hệ thống có 448 luồng phần cứng có thể chạy năm phiên bản
của toàn bộ đồng thời.  Để thực hiện được điều này::

kvm.sh --cpus 448 --configs '5*CFLIST'

Ngoài ra, một hệ thống như vậy có thể chạy đồng thời 56 phiên bản của một
kịch bản tám-CPU::

kvm.sh --cpus 448 --configs '56*TREE04'

Hoặc 28 phiên bản đồng thời của mỗi kịch bản trong số tám kịch bản CPU::

kvm.sh --cpus 448 --configs '28*TREE03 28*TREE04'

Tất nhiên, mỗi phiên bản đồng thời sẽ sử dụng bộ nhớ, có thể
bị giới hạn bằng cách sử dụng đối số --memory, mặc định là 512M.  nhỏ
các giá trị cho bộ nhớ có thể yêu cầu vô hiệu hóa các thử nghiệm tràn ngập cuộc gọi lại
sử dụng tham số --bootargs được thảo luận bên dưới.

Đôi khi việc gỡ lỗi bổ sung rất hữu ích và trong những trường hợp như vậy --kconfig
tham số cho kvm.sh có thể được sử dụng, ví dụ: ZZ0000ZZ.
Ngoài ra, còn có các tham số --gdb, --kasan và --kcsan.
Lưu ý rằng --gdb giới hạn bạn ở một kịch bản cho mỗi lần chạy kvm.sh và yêu cầu
rằng bạn có một cửa sổ khác đang mở để chạy ZZ0001ZZ theo hướng dẫn
theo kịch bản.

Các đối số khởi động hạt nhân cũng có thể được cung cấp, ví dụ, để kiểm soát
các tham số mô-đun của rcutorture.  Ví dụ: để kiểm tra thay đổi đối với RCU
Mã cảnh báo ngừng hoạt động CPU, sử dụng "--bootargs 'rcutorture.stall_cpu=30'".
Tất nhiên điều này sẽ dẫn đến việc kịch bản báo cáo lỗi, cụ thể là
kết quả là cảnh báo ngừng hoạt động của RCU CPU.  Như đã lưu ý ở trên, việc giảm trí nhớ có thể
yêu cầu vô hiệu hóa các bài kiểm tra tràn ngập cuộc gọi lại của rcutorture ::

kvm.sh --cpus 448 --configs '56*TREE04' --bộ nhớ 128M \
		--bootargs 'rcitorture.fwd_progress=0'

Đôi khi tất cả những gì cần thiết là một bộ đầy đủ các bản dựng kernel.  Đây là
tham số --buildonly làm gì.

Tham số --duration có thể ghi đè thời gian chạy mặc định là 30 phút.
Ví dụ: ZZ0000ZZ sẽ chạy trong hai ngày, ZZ0001ZZ
sẽ chạy trong ba giờ, ZZ0002ZZ sẽ chạy trong năm phút,
và ZZ0003ZZ sẽ chạy trong 45 giây.  Điều cuối cùng này có thể hữu ích
để theo dõi các lỗi thời gian khởi động hiếm gặp.

Cuối cùng, tham số --trust-make cho phép mỗi bản dựng kernel sử dụng lại những gì
nó có thể từ bản dựng kernel trước đó.  Xin lưu ý rằng nếu không có
Tham số --trust-make, tệp thẻ của bạn có thể bị phá hủy.

Có thêm những lập luận phức tạp hơn được ghi lại trong
mã nguồn của tập lệnh kvm.sh.

Nếu một lần chạy có lỗi, số lần lỗi trong thời gian xây dựng và thời gian chạy
được liệt kê ở cuối đầu ra kvm.sh, bạn thực sự nên chuyển hướng
vào một tập tin.  Các sản phẩm xây dựng và đầu ra của bảng điều khiển của mỗi lần chạy được lưu giữ trong
tools/testing/selftests/rcitorture/res trong các thư mục có dấu thời gian.  A
thư mục đã cho có thể được cung cấp cho kvm-find-errors.sh để có
nó sẽ đưa bạn qua các bản tóm tắt lỗi và nhật ký lỗi đầy đủ.  Ví dụ::

công cụ/kiểm tra/selftests/rcutorture/bin/kvm-find-errors.sh \
		công cụ/thử nghiệm/tự kiểm tra/rcutorture/res/2020.01.20-15.54.23

Tuy nhiên, việc truy cập trực tiếp vào các tập tin thường thuận tiện hơn.
Các tệp liên quan đến tất cả các kịch bản trong một lần chạy nằm ở cấp cao nhất
thư mục (2020.01.20-15.54.23 trong ví dụ trên), trong khi mỗi kịch bản
các tệp nằm trong thư mục con được đặt tên theo kịch bản (ví dụ:
"TREE04").  Nếu một kịch bản nhất định chạy nhiều lần (như trong "--configs
'56*TREE04'" ở trên), các thư mục tương ứng với thư mục thứ hai và
các lần chạy tiếp theo của kịch bản đó bao gồm một số thứ tự, ví dụ:
"TREE04.2", "TREE04.3", v.v.

Tệp được sử dụng thường xuyên nhất trong thư mục cấp cao nhất là testid.txt.
Nếu thử nghiệm chạy trong kho git thì tệp này chứa cam kết
đã được kiểm tra và mọi thay đổi chưa được cam kết ở định dạng khác.

Các tệp được sử dụng thường xuyên nhất trong mỗi thư mục theo kịch bản là:

.config:
	Tệp này chứa các tùy chọn Kconfig.

Make.out:
	Điều này chứa đầu ra bản dựng cho một kịch bản cụ thể.

console.log:
	Điều này chứa đầu ra của bàn điều khiển cho một kịch bản cụ thể.
	Tập tin này có thể được kiểm tra khi kernel đã khởi động, nhưng
	nó có thể không tồn tại nếu quá trình xây dựng thất bại.

vmlinux:
	Phần này chứa kernel, có thể hữu ích với các công cụ như
	objdump và gdb.

Một số tệp bổ sung có sẵn nhưng ít được sử dụng hơn.
Nhiều phần mềm được thiết kế để gỡ lỗi chính rcutorture hoặc tập lệnh của nó.

Kể từ v5.4, quá trình chạy thành công với tập hợp kịch bản mặc định sẽ tạo ra
phần tóm tắt sau đây khi kết thúc quá trình chạy trên hệ thống 12-CPU::

SRCU-N ------- 804233 GP (148,932/s) [srcu: g10008272 f0x0 ]
    SRCU-P ------- 202320 GP (37,4667/s) [srcud: g1809476 f0x0 ]
    SRCU-t ------- 1122086 GP (207,794/s) [srcu: g0 f0x0 ]
    SRCU-u ------- 1111285 GP (205,794/s) [srcud: g1 f0x0 ]
    TASKS01 ------- 19666 GP (3,64185/s) [nhiệm vụ: g0 f0x0 ]
    TASKS02 ------- 20541 GP (3,80389/s) [nhiệm vụ: g0 f0x0 ]
    TASKS03 ------- 19416 GP (3,59556/s) [nhiệm vụ: g0 f0x0 ]
    TINY01 ------- 836134 GP (154,84/s) [rcu: g0 f0x0 ] n_max_cbs: 34198
    TINY02 ------- 850371 GP (157,476/s) [rcu: g0 f0x0 ] n_max_cbs: 2631
    TREE01 ------- 162625 GP (30,1157/s) [rcu: g1124169 f0x0 ]
    TREE02 ------- 333003 GP (61,6672/s) [rcu: g2647753 f0x0 ] n_max_cbs: 35844
    TREE03 ------- 306623 GP (56,782/s) [rcu: g2975325 f0x0 ] n_max_cbs: 1496497
    Số lượng CPU bị giới hạn từ 16 đến 12
    TREE04 ------- 246149 GP (45,5831/s) [rcu: g1695737 f0x0 ] n_max_cbs: 434961
    TREE05 ------- 314603 GP (58.2598/s) [rcu: g2257741 f0x2 ] n_max_cbs: 193997
    TREE07 ------- 167347 GP (30,9902/s) [rcu: g1079021 f0x0 ] n_max_cbs: 478732
    Số lượng CPU bị giới hạn từ 16 đến 12
    TREE09 ------- 752238 GP (139.303/s) [rcu: g13075057 f0x0 ] n_max_cbs: 99011


Chạy lặp đi lặp lại
=============

Giả sử bạn đang tìm kiếm một lỗi hiếm gặp khi khởi động.  Mặc dù bạn
có thể sử dụng kvm.sh, làm như vậy sẽ xây dựng lại kernel sau mỗi lần chạy.  Nếu bạn
cần (giả sử) 1.000 lần chạy để tin rằng bạn đã sửa lỗi,
việc xây dựng lại vô nghĩa này có thể trở nên cực kỳ khó chịu.

Đây là lý do tại sao kvm-again.sh tồn tại.

Giả sử rằng lần chạy kvm.sh trước đó đã để lại đầu ra của nó trong thư mục này ::

công cụ/thử nghiệm/tự kiểm tra/rcutorture/res/2022.11.03-11.26.28

Sau đó, lần chạy này có thể được chạy lại mà không cần xây dựng lại như sau ::

công cụ kvm-again.sh/thử nghiệm/selftests/rcutorture/res/2022.11.03-11.26.28

Có lẽ một số tham số kvm.sh của lần chạy ban đầu có thể bị ghi đè
đáng chú ý nhất --duration và --bootargs.  Ví dụ::

công cụ kvm-again.sh/testing/selftests/rcitorture/res/2022.11.03-11.26.28 \
		--thời gian 45s

sẽ chạy lại bài kiểm tra trước đó nhưng chỉ trong 45 giây, do đó tạo điều kiện thuận lợi
theo dõi lỗi thời gian khởi động hiếm gặp nói trên.


Chạy phân phối
================

Mặc dù kvm.sh khá hữu ích nhưng việc thử nghiệm nó chỉ giới hạn ở một
hệ thống.  Không quá khó để sử dụng khuôn khổ yêu thích của bạn để tạo ra
(giả sử) 5 phiên bản kvm.sh sẽ chạy trên 5 hệ thống của bạn, nhưng điều này sẽ rất
có khả năng xây dựng lại hạt nhân một cách không cần thiết.  Ngoài ra, việc phân phối thủ công
các kịch bản điều khiển mong muốn trên các hệ thống có sẵn có thể được
siêng năng và dễ mắc lỗi.

Và đây là lý do tại sao tập lệnh kvm-remote.sh tồn tại.

Nếu lệnh sau hoạt động ::

ngày hệ thống ssh0

và nếu nó cũng hoạt động với system1, system2, system3, system4 và system5,
và tất cả các hệ thống này đều có 64 CPU, bạn có thể gõ::

kvm-remote.sh "system0 system1 system2 system3 system4 system5" \
		--cpus 64 --duration 8h --configs "5*CFLIST"

Điều này sẽ xây dựng kernel của từng kịch bản mặc định trên hệ thống cục bộ, sau đó
trải rộng từng trường hợp trong số năm trường hợp của từng kịch bản trên các hệ thống được liệt kê,
chạy mỗi kịch bản trong tám giờ.  Vào cuối cuộc chạy,
kết quả sẽ được thu thập, ghi lại và in.  Hầu hết các thông số
kvm.sh sẽ chấp nhận có thể được chuyển tới kvm-remote.sh, nhưng danh sách
hệ thống phải đến trước.

Đối số kvm.sh ZZ0000ZZ rất hữu ích cho việc giải quyết
có bao nhiêu kịch bản có thể được chạy trong một đợt trên một nhóm hệ thống.

Bạn cũng có thể chạy lại lần chạy từ xa trước đó theo cách tương tự như kvm.sh::

kvm-remote.sh "system0 system1 system2 system3 system4 system5" \
		công cụ/thử nghiệm/selftests/rcutorture/res/2022.11.03-11.26.28-remote \
		--thời gian 24h

Trong trường hợp này, hầu hết các tham số kvm-again.sh có thể được cung cấp như sau
tên đường dẫn của thư mục kết quả chạy cũ.