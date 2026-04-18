.. SPDX-License-Identifier: (GPL-2.0+ OR CC-BY-4.0)

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/admin-guide/workload-tracing.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

======================================================================
Khám phá các hệ thống con nhân Linux được khối lượng công việc sử dụng
======================================================================

:Tác giả: - Shuah Khan <skhan@linuxfoundation.org>
          - Shefali Sharma <sshefali021@gmail.com>
:được duy trì bởi: Shuah Khan <skhan@linuxfoundation.org>

Những điểm chính
==========

* Hiểu các tài nguyên hệ thống cần thiết để xây dựng và chạy khối lượng công việc
   là quan trọng.
 * Truy tìm và theo dõi Linux có thể được sử dụng để khám phá tài nguyên hệ thống
   được sử dụng bởi một khối lượng công việc. Tính đầy đủ của thông tin sử dụng hệ thống
   phụ thuộc vào mức độ bao phủ đầy đủ của khối lượng công việc.
 * Hiệu suất và tính bảo mật của hệ điều hành có thể được phân tích bằng
   sự trợ giúp của các công cụ như:
   ZZ0000ZZ,
   ZZ0001ZZ,
   ZZ0002ZZ.
 * Sau khi khám phá và hiểu được nhu cầu của khối lượng công việc, chúng tôi có thể tập trung vào chúng
   để tránh sự hồi quy và sử dụng nó để đánh giá các cân nhắc về an toàn.

Phương pháp luận
===========

ZZ0000ZZ là một
công cụ chẩn đoán, hướng dẫn và gỡ lỗi và có thể được sử dụng để khám phá
tài nguyên hệ thống được sử dụng bởi khối lượng công việc. Một khi chúng ta khám phá và hiểu
khối lượng công việc cần, chúng ta có thể tập trung vào chúng để tránh hồi quy và sử dụng nó
để đánh giá các cân nhắc về an toàn. Chúng tôi sử dụng công cụ strace để theo dõi khối lượng công việc.

Phương pháp truy tìm này bằng cách sử dụng strace cho chúng ta biết các lệnh gọi hệ thống được gọi bởi
khối lượng công việc và không bao gồm tất cả các cuộc gọi hệ thống có thể được gọi
bởi nó. Ngoài ra, phương pháp theo dõi này chỉ cho chúng ta biết các đường dẫn mã bên trong
các cuộc gọi hệ thống được gọi này. Ví dụ: nếu một khối lượng công việc mở ra một
tập tin và đọc từ nó thành công thì đường dẫn thành công là đường dẫn
được truy tìm. Mọi đường dẫn lỗi trong cuộc gọi hệ thống đó sẽ không được theo dõi. Nếu có
là khối lượng công việc cung cấp phạm vi bao phủ đầy đủ của khối lượng công việc thì phương pháp
được nêu ở đây sẽ theo dõi và tìm thấy tất cả các đường dẫn mã có thể. Sự đầy đủ
của thông tin sử dụng hệ thống phụ thuộc vào mức độ bao phủ đầy đủ của một
khối lượng công việc.

Mục tiêu là theo dõi khối lượng công việc trên hệ thống chạy kernel mặc định mà không có
yêu cầu cài đặt kernel tùy chỉnh.

Làm cách nào để chúng tôi thu thập thông tin hệ thống chi tiết?
=================================================

công cụ strace có thể được sử dụng để theo dõi các cuộc gọi hệ thống được thực hiện bởi một quy trình và tín hiệu
nó nhận được. Cuộc gọi hệ thống là giao diện cơ bản giữa một
ứng dụng và nhân hệ điều hành. Chúng cho phép một chương trình có thể
yêu cầu dịch vụ từ kernel. Ví dụ: lệnh gọi hệ thống open()
Linux được sử dụng để cung cấp quyền truy cập vào một tệp trong hệ thống tệp. strace cho phép
chúng tôi để theo dõi tất cả các cuộc gọi hệ thống được thực hiện bởi một ứng dụng. Nó liệt kê tất cả các
các cuộc gọi hệ thống được thực hiện bởi một quá trình và kết quả đầu ra của chúng.

Bạn có thể tạo dữ liệu lược tả bằng cách kết hợp các công cụ ghi lại strace và perf để
ghi lại các sự kiện và thông tin liên quan đến một quá trình. Điều này cung cấp
cái nhìn sâu sắc về quá trình này. Công cụ "chú thích hoàn hảo" tạo ra số liệu thống kê về
từng lệnh của chương trình. Tài liệu này trình bày chi tiết về cách
để thu thập thông tin chi tiết về việc sử dụng tài nguyên hệ thống của khối lượng công việc.

Chúng tôi đã sử dụng strace để theo dõi khối lượng công việc hoàn hảo, stress-ng, paxtest để minh họa
phương pháp của chúng tôi để khám phá các tài nguyên được khối lượng công việc sử dụng. Quá trình này có thể
được áp dụng để theo dõi khối lượng công việc khác.

Chuẩn bị hệ thống sẵn sàng để truy tìm
====================================

Trước khi bắt đầu, chúng tôi sẽ chỉ cho bạn cách chuẩn bị sẵn sàng hệ thống của bạn.
Chúng tôi giả định rằng bạn có bản phân phối Linux chạy trên hệ thống vật lý
hoặc một máy ảo. Hầu hết các bản phân phối sẽ bao gồm lệnh strace. Hãy
cài đặt các công cụ khác thường không có để xây dựng nhân Linux.
Xin lưu ý rằng phần sau hoạt động trên các bản phân phối dựa trên Debian. bạn
có thể phải tìm các gói tương đương trên các bản phân phối Linux khác.

Cài đặt các công cụ để xây dựng kernel Linux và các công cụ trong kho kernel.
scripts/ver_linux là một cách hay để kiểm tra xem hệ thống của bạn đã có chưa
các công cụ cần thiết::

sudo apt-get cài đặt build-essential flex bison yacc
  sudo apt cài đặt libelf-dev systemtap-sdt-dev libslang2-dev libperl-dev libdw-dev

cscope là một công cụ tốt để duyệt các nguồn kernel. Hãy cài đặt nó ngay bây giờ::

sudo apt-get cài đặt cscope

Cài đặt stress-ng và paxtest::

cài đặt apt-get căng thẳng-ng
  apt-get cài đặt paxtest

Tổng quan về khối lượng công việc
=================

Như đã đề cập trước đó, chúng tôi đã sử dụng strace để theo dõi perf bench, stress-ng và
khối lượng công việc paxtest để hiển thị cách phân tích khối lượng công việc và xác định Linux
các hệ thống con được sử dụng bởi các khối lượng công việc này. Hãy bắt đầu với cái nhìn tổng quan về những điều này
ba khối lượng công việc để hiểu rõ hơn về những gì họ làm và cách thực hiện
sử dụng chúng.

khối lượng công việc hoàn thiện (tất cả)
-------------------------

Lệnh băng ghế dự bị hoàn hảo chứa nhiều hạt nhân đa luồng
điểm chuẩn để thực thi các hệ thống con khác nhau trong nhân Linux và
các cuộc gọi hệ thống. Điều này cho phép chúng ta dễ dàng đo lường tác động của những thay đổi,
có thể giúp giảm thiểu hiện tượng hồi quy hiệu suất. Nó cũng hoạt động như một điểm chung
khung điểm chuẩn, cho phép các nhà phát triển dễ dàng tạo các trường hợp thử nghiệm,
tích hợp một cách minh bạch và sử dụng các hệ thống con công cụ giàu hiệu suất.

Khối lượng công việc gây căng thẳng của Netdev Netdev
----------------------------------

stress-ng được sử dụng để thực hiện stress test trên kernel. Nó cho phép
bạn sử dụng các hệ thống con vật lý khác nhau của máy tính, cũng như
giao diện của nhân hệ điều hành, sử dụng "stressor-s". Chúng có sẵn cho
CPU, CPU bộ đệm, thiết bị, I/O, ngắt, hệ thống tệp, bộ nhớ, mạng,
hệ điều hành, đường ống, bộ lập lịch và máy ảo. Hãy tham khảo
tới ZZ0000ZZ để
tìm mô tả của tất cả các yếu tố gây căng thẳng có sẵn. Yếu tố gây căng thẳng netdev
bắt đầu số lượng công nhân được chỉ định (N) thực hiện các thiết bị mạng khác nhau
lệnh ioctl trên tất cả các thiết bị mạng có sẵn.

khối lượng công việc dành cho trẻ em của paxtest
-----------------------

paxtest là chương trình kiểm tra lỗi tràn bộ đệm trong kernel. Nó kiểm tra
thực thi kernel đối với việc sử dụng bộ nhớ. Nói chung, việc thực thi trong một số bộ nhớ
phân đoạn có thể làm tràn bộ đệm. Nó chạy một tập hợp các chương trình
cố gắng phá hoại việc sử dụng bộ nhớ. Nó được sử dụng như một bộ kiểm tra hồi quy cho
PaX, nhưng có thể hữu ích để kiểm tra các bản vá bảo vệ bộ nhớ khác cho
hạt nhân. Chúng tôi đã sử dụng chế độ paxtest kiddie để tìm kiếm các lỗ hổng đơn giản.

Strace là gì và chúng ta sử dụng nó như thế nào?
====================================

Như đã đề cập trước đó, strace là một công cụ chẩn đoán, hướng dẫn,
và công cụ gỡ lỗi và có thể được sử dụng để khám phá các tài nguyên hệ thống đang được sử dụng
bởi một khối lượng công việc. Nó có thể được sử dụng:

* Để xem một tiến trình tương tác với kernel như thế nào.
 * Để biết tại sao một tiến trình bị lỗi hoặc bị treo.
 * Đối với kỹ thuật đảo ngược một quy trình.
 * Để tìm các tập tin mà chương trình phụ thuộc vào.
 * Để phân tích hiệu suất của một ứng dụng.
 * Để khắc phục các sự cố khác nhau liên quan đến hệ điều hành.

Ngoài ra, strace có thể tạo số liệu thống kê thời gian chạy về thời gian, cuộc gọi và
lỗi cho mỗi lệnh gọi hệ thống và báo cáo tóm tắt khi thoát khỏi chương trình,
ngăn chặn sản lượng thường xuyên. Điều này cố gắng hiển thị thời gian hệ thống (thời gian CPU
dành cho việc chạy trong kernel) không phụ thuộc vào thời gian của đồng hồ treo tường. Chúng tôi dự định sử dụng
các tính năng này để nhận thông tin về việc sử dụng hệ thống khối lượng công việc.

Lệnh strace hỗ trợ các chế độ cơ bản, dài dòng và thống kê. lệnh strace khi
chạy ở chế độ dài dòng cung cấp thông tin chi tiết hơn về các cuộc gọi hệ thống
được gọi bởi một tiến trình.

Chạy strace -c tạo ra một báo cáo về phần trăm thời gian dành cho mỗi
cuộc gọi hệ thống, tổng thời gian tính bằng giây, micro giây cho mỗi cuộc gọi, tổng thời gian
số lượng cuộc gọi, số lượng mỗi cuộc gọi hệ thống không thành công do có lỗi
và loại cuộc gọi hệ thống được thực hiện.

* Cách sử dụng: strace <lệnh chúng ta muốn theo dõi>
 * Cách sử dụng chế độ dài dòng: strace -v <command>
 * Thu thập số liệu thống kê: strace -c <command>

Chúng tôi đã sử dụng tùy chọn “-c” để thu thập số liệu thống kê chi tiết về thời gian chạy đang được sử dụng
theo ba khối lượng công việc mà chúng tôi đã chọn cho phân tích này.

* hoàn hảo
 * căng thẳng-ng
 * paxtest

cscope là gì và chúng ta sử dụng nó như thế nào?
====================================

Bây giờ hãy xem ZZ0000ZZ, một lệnh
công cụ dòng để duyệt các cơ sở mã C, C++ hoặc Java. Chúng ta có thể sử dụng nó để tìm
tất cả các tham chiếu tới một ký hiệu, các định nghĩa chung, các hàm được gọi bởi một
hàm, hàm gọi hàm, chuỗi văn bản, biểu thức chính quy
mẫu, tập tin bao gồm một tập tin.

Chúng ta có thể sử dụng cscope để tìm cuộc gọi hệ thống nào thuộc về hệ thống con nào.
Bằng cách này, chúng ta có thể tìm thấy các hệ thống con kernel được một tiến trình sử dụng khi nó
bị xử tử.

Hãy kiểm tra kho lưu trữ Linux mới nhất và xây dựng cơ sở dữ liệu cscope ::

git clone git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git linux
  cd linux
  cscope -R -p10 # builds cơ sở dữ liệu cscope.out trước khi bắt đầu phiên duyệt
  Phiên duyệt cscope -d -p10 # starts trên cơ sở dữ liệu cscope.out

Lưu ý: Chạy "cscope -R -p10" để xây dựng cơ sở dữ liệu và "cscope -d -p10" để
tham gia vào phiên duyệt web. cscope theo mặc định sử dụng cscope.out
cơ sở dữ liệu. Để thoát khỏi chế độ này nhấn ctrl+d. Tùy chọn -p được sử dụng để
chỉ định số lượng thành phần đường dẫn tệp sẽ hiển thị. -p10 là tối ưu
để duyệt các nguồn kernel.

Sự hoàn hảo là gì và chúng ta sử dụng nó như thế nào?
==================================

Perf là một công cụ phân tích dựa trên hệ thống Linux 2.6+, tóm tắt
Sự khác biệt về phần cứng của CPU trong đo lường hiệu suất trong Linux và cung cấp
một giao diện dòng lệnh đơn giản. Perf dựa trên giao diện perf_events
được xuất khẩu bởi kernel. Nó rất hữu ích cho việc lập hồ sơ hệ thống và
tìm ra các tắc nghẽn về hiệu suất trong một ứng dụng.

Nếu bạn chưa kiểm tra kho lưu trữ dòng chính của Linux, bạn có thể làm
sau đó xây dựng kernel và công cụ hoàn thiện ::

git clone git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git linux
  cd linux
  tạo -j3 tất cả
  công cụ cd/hoàn hảo
  làm

Lưu ý: Lệnh perf có thể được xây dựng mà không cần xây dựng kernel trong
kho lưu trữ và có thể chạy trên các hạt nhân cũ hơn. Tuy nhiên phù hợp với kernel
và các bản sửa đổi hoàn hảo cung cấp thông tin chính xác hơn về việc sử dụng hệ thống con.

Chúng tôi đã sử dụng các tùy chọn "chỉ số hoàn hảo" và "băng ghế hoàn hảo". Để biết thông tin chi tiết về
công cụ hoàn hảo, hãy chạy "perf -h".

chỉ số hoàn hảo
---------
Lệnh perf stat tạo báo cáo về nhiều phần cứng và phần mềm khác nhau
sự kiện. Nó làm như vậy với sự trợ giúp của các thanh ghi bộ đếm phần cứng được tìm thấy trong
CPU hiện đại lưu giữ số lượng các hoạt động này. "chỉ số hoàn hảo" hiển thị
số liệu thống kê cho lệnh cal.

Băng ghế hoàn hảo
----------
Lệnh băng ghế dự bị hoàn hảo chứa nhiều hạt nhân đa luồng
điểm chuẩn để thực thi các hệ thống con khác nhau trong nhân Linux và
các cuộc gọi hệ thống. Điều này cho phép chúng ta dễ dàng đo lường tác động của những thay đổi,
có thể giúp giảm thiểu hiện tượng hồi quy hiệu suất. Nó cũng hoạt động như một điểm chung
khung điểm chuẩn, cho phép các nhà phát triển dễ dàng tạo các trường hợp thử nghiệm,
tích hợp một cách minh bạch và sử dụng công cụ giàu hiệu suất.

Lệnh "perf bench all" chạy các điểm chuẩn sau:

* lên lịch/nhắn tin
 * lịch trình/ống
 * syscall/cơ bản
 * mem/memcpy
 * bộ nhớ/bộ nhớ

Căng thẳng-ng là gì và chúng ta sử dụng nó như thế nào?
=======================================

Như đã đề cập trước đó, stress-ng được sử dụng để thực hiện kiểm tra sức chịu đựng trên
hạt nhân. Nó cho phép bạn thực hiện các hệ thống con vật lý khác nhau của
máy tính, cũng như các giao diện của nhân hệ điều hành, sử dụng bộ căng thẳng. Họ
có sẵn cho bộ đệm CPU, CPU, thiết bị, I/O, ngắt, hệ thống tệp,
bộ nhớ, mạng, hệ điều hành, đường ống, bộ lập lịch và ảo
máy móc.

Yếu tố gây căng thẳng netdev khởi động N công nhân thực hiện các ioctl netdevice khác nhau
lệnh trên tất cả các thiết bị mạng có sẵn. Các ioctls sau đây là
thực hiện:

* SIOCGIFCONF, SIOCGIFINDEX, SIOCGIFNAME, SIOCGIFFLAGS
 * SIOCGIFADDR, SIOCGIFNETMASK, SIOCGIFMETRIC, SIOCGIFMTU
 * SIOCGIFHWADDR, SIOCGIFMAP, SIOCGIFTXQLEN

Lệnh sau chạy bộ căng thẳng ::

lệnh stress-ng --netdev 1 -t 60 --metrics.

Chúng ta có thể sử dụng lệnh perf record để ghi lại các sự kiện và thông tin
liên quan đến một quá trình. Lệnh này ghi lại dữ liệu lược tả trong
tệp perf.data trong cùng thư mục.

Sử dụng các lệnh sau, bạn có thể ghi lại các sự kiện liên quan đến
yếu tố căng thẳng netdev, hãy xem báo cáo perf.data được tạo và chú thích vào
xem số liệu thống kê của từng hướng dẫn của chương trình::

lệnh hoàn hảo record stress-ng --netdev 1 -t 60 --metrics.
  báo cáo hoàn hảo
  chú thích hoàn hảo

Paxtest là gì và chúng ta sử dụng nó như thế nào?
=====================================

paxtest là chương trình kiểm tra lỗi tràn bộ đệm trong kernel. Nó kiểm tra
thực thi kernel đối với việc sử dụng bộ nhớ. Nói chung, việc thực thi trong một số bộ nhớ
phân đoạn có thể làm tràn bộ đệm. Nó chạy một tập hợp các chương trình
cố gắng phá hoại việc sử dụng bộ nhớ. Nó được sử dụng như một bộ kiểm tra hồi quy cho
PaX và sẽ hữu ích để kiểm tra các bản vá bảo vệ bộ nhớ khác cho
hạt nhân.

paxtest cung cấp chế độ dành cho trẻ em và mũ đen. Chế độ trẻ em paxtest chạy
ở chế độ bình thường, trong khi chế độ mũ đen cố gắng vượt qua sự bảo vệ
kiểm tra hạt nhân để tìm lỗ hổng. Chúng tôi tập trung vào chế độ trẻ con ở đây
và kết hợp hoạt động chạy "paxtest kiddie" với "perf record" để thu thập ngăn xếp CPU
dấu vết cho cuộc chạy paxtest kiddie để xem chức năng nào đang gọi khác
chức năng trong hồ sơ hiệu suất. Sau đó là "người lùn" (Khung cuộc gọi của DWARF
Chế độ Information) có thể được sử dụng để giải phóng ngăn xếp.

Lệnh sau có thể được sử dụng để xem báo cáo kết quả trong biểu đồ cuộc gọi
định dạng::

bản ghi hoàn hảo --call-graph lùn paxtest kiddie
  báo cáo hoàn hảo --stdio

Theo dõi khối lượng công việc
=================

Bây giờ chúng ta đã hiểu khối lượng công việc, hãy bắt đầu truy tìm chúng.

Truy tìm băng ghế dự bị hoàn hảo tất cả khối lượng công việc
-------------------------------

Chạy lệnh sau để theo dõi toàn bộ khối lượng công việc::

strace -c perf băng ghế dự bị tất cả

ZZ0000ZZ

Bảng dưới đây hiển thị các lệnh gọi hệ thống được gọi theo khối lượng công việc, số lượng
số lần mỗi lệnh gọi hệ thống được gọi và hệ thống con Linux tương ứng.

+-------------------+-----------+-----------------+-------------------------+
| System Call       | # calls   | Linux Subsystem | System Call (API)       |
+===================+===========+=================+=========================+
| getppid           | 10000001  | Process Mgmt    | sys_getpid()            |
+-------------------+-----------+-----------------+-------------------------+
| clone             | 1077      | Process Mgmt.   | sys_clone()             |
+-------------------+-----------+-----------------+-------------------------+
| prctl             | 23        | Process Mgmt.   | sys_prctl()             |
+-------------------+-----------+-----------------+-------------------------+
| prlimit64         | 7         | Process Mgmt.   | sys_prlimit64()         |
+-------------------+-----------+-----------------+-------------------------+
| getpid            | 10        | Process Mgmt.   | sys_getpid()            |
+-------------------+-----------+-----------------+-------------------------+
| uname             | 3         | Process Mgmt.   | sys_uname()             |
+-------------------+-----------+-----------------+-------------------------+
| sysinfo           | 1         | Process Mgmt.   | sys_sysinfo()           |
+-------------------+-----------+-----------------+-------------------------+
| getuid            | 1         | Process Mgmt.   | sys_getuid()            |
+-------------------+-----------+-----------------+-------------------------+
| getgid            | 1         | Process Mgmt.   | sys_getgid()            |
+-------------------+-----------+-----------------+-------------------------+
| geteuid           | 1         | Process Mgmt.   | sys_geteuid()           |
+-------------------+-----------+-----------------+-------------------------+
| getegid           | 1         | Process Mgmt.   | sys_getegid             |
+-------------------+-----------+-----------------+-------------------------+
| close             | 49951     | Filesystem      | sys_close()             |
+-------------------+-----------+-----------------+-------------------------+
| pipe              | 604       | Filesystem      | sys_pipe()              |
+-------------------+-----------+-----------------+-------------------------+
| openat            | 48560     | Filesystem      | sys_opennat()           |
+-------------------+-----------+-----------------+-------------------------+
| fstat             | 8338      | Filesystem      | sys_fstat()             |
+-------------------+-----------+-----------------+-------------------------+
| stat              | 1573      | Filesystem      | sys_stat()              |
+-------------------+-----------+-----------------+-------------------------+
| pread64           | 9646      | Filesystem      | sys_pread64()           |
+-------------------+-----------+-----------------+-------------------------+
| getdents64        | 1873      | Filesystem      | sys_getdents64()        |
+-------------------+-----------+-----------------+-------------------------+
| access            | 3         | Filesystem      | sys_access()            |
+-------------------+-----------+-----------------+-------------------------+
| lstat             | 1880      | Filesystem      | sys_lstat()             |
+-------------------+-----------+-----------------+-------------------------+
| lseek             | 6         | Filesystem      | sys_lseek()             |
+-------------------+-----------+-----------------+-------------------------+
| ioctl             | 3         | Filesystem      | sys_ioctl()             |
+-------------------+-----------+-----------------+-------------------------+
| dup2              | 1         | Filesystem      | sys_dup2()              |
+-------------------+-----------+-----------------+-------------------------+
| execve            | 2         | Filesystem      | sys_execve()            |
+-------------------+-----------+-----------------+-------------------------+
| fcntl             | 8779      | Filesystem      | sys_fcntl()             |
+-------------------+-----------+-----------------+-------------------------+
| statfs            | 1         | Filesystem      | sys_statfs()            |
+-------------------+-----------+-----------------+-------------------------+
| epoll_create      | 2         | Filesystem      | sys_epoll_create()      |
+-------------------+-----------+-----------------+-------------------------+
| epoll_ctl         | 64        | Filesystem      | sys_epoll_ctl()         |
+-------------------+-----------+-----------------+-------------------------+
| newfstatat        | 8318      | Filesystem      | sys_newfstatat()        |
+-------------------+-----------+-----------------+-------------------------+
| eventfd2          | 192       | Filesystem      | sys_eventfd2()          |
+-------------------+-----------+-----------------+-------------------------+
| mmap              | 243       | Memory Mgmt.    | sys_mmap()              |
+-------------------+-----------+-----------------+-------------------------+
| mprotect          | 32        | Memory Mgmt.    | sys_mprotect()          |
+-------------------+-----------+-----------------+-------------------------+
| brk               | 21        | Memory Mgmt.    | sys_brk()               |
+-------------------+-----------+-----------------+-------------------------+
| munmap            | 128       | Memory Mgmt.    | sys_munmap()            |
+-------------------+-----------+-----------------+-------------------------+
| set_mempolicy     | 156       | Memory Mgmt.    | sys_set_mempolicy()     |
+-------------------+-----------+-----------------+-------------------------+
| set_tid_address   | 1         | Process Mgmt.   | sys_set_tid_address()   |
+-------------------+-----------+-----------------+-------------------------+
| set_robust_list   | 1         | Futex           | sys_set_robust_list()   |
+-------------------+-----------+-----------------+-------------------------+
| futex             | 341       | Futex           | sys_futex()             |
+-------------------+-----------+-----------------+-------------------------+
| sched_getaffinity | 79        | Scheduler       | sys_sched_getaffinity() |
+-------------------+-----------+-----------------+-------------------------+
| sched_setaffinity | 223       | Scheduler       | sys_sched_setaffinity() |
+-------------------+-----------+-----------------+-------------------------+
| socketpair        | 202       | Network         | sys_socketpair()        |
+-------------------+-----------+-----------------+-------------------------+
| rt_sigprocmask    | 21        | Signal          | sys_rt_sigprocmask()    |
+-------------------+-----------+-----------------+-------------------------+
| rt_sigaction      | 36        | Signal          | sys_rt_sigaction()      |
+-------------------+-----------+-----------------+-------------------------+
| rt_sigreturn      | 2         | Signal          | sys_rt_sigreturn()      |
+-------------------+-----------+-----------------+-------------------------+
| wait4             | 889       | Time            | sys_wait4()             |
+-------------------+-----------+-----------------+-------------------------+
| clock_nanosleep   | 37        | Time            | sys_clock_nanosleep()   |
+-------------------+-----------+-----------------+-------------------------+
| capget            | 4         | Capability      | sys_capget()            |
+-------------------+-----------+-----------------+-------------------------+

Theo dõi khối lượng công việc gây căng thẳng của netdev
------------------------------------------

Chạy lệnh sau để theo dõi khối lượng công việc gây căng thẳng của netdev stress-ng::

strace -c stress-ng --netdev 1 -t 60 --metrics

ZZ0000ZZ

Bảng dưới đây hiển thị các lệnh gọi hệ thống được gọi theo khối lượng công việc, số lượng
số lần mỗi lệnh gọi hệ thống được gọi và hệ thống con Linux tương ứng.

+-------------------+-----------+-----------------+-------------------------+
| System Call       | # calls   | Linux Subsystem | System Call (API)       |
+===================+===========+=================+=========================+
| openat            | 74        | Filesystem      | sys_openat()            |
+-------------------+-----------+-----------------+-------------------------+
| close             | 75        | Filesystem      | sys_close()             |
+-------------------+-----------+-----------------+-------------------------+
| read              | 58        | Filesystem      | sys_read()              |
+-------------------+-----------+-----------------+-------------------------+
| fstat             | 20        | Filesystem      | sys_fstat()             |
+-------------------+-----------+-----------------+-------------------------+
| flock             | 10        | Filesystem      | sys_flock()             |
+-------------------+-----------+-----------------+-------------------------+
| write             | 7         | Filesystem      | sys_write()             |
+-------------------+-----------+-----------------+-------------------------+
| getdents64        | 8         | Filesystem      | sys_getdents64()        |
+-------------------+-----------+-----------------+-------------------------+
| pread64           | 8         | Filesystem      | sys_pread64()           |
+-------------------+-----------+-----------------+-------------------------+
| lseek             | 1         | Filesystem      | sys_lseek()             |
+-------------------+-----------+-----------------+-------------------------+
| access            | 2         | Filesystem      | sys_access()            |
+-------------------+-----------+-----------------+-------------------------+
| getcwd            | 1         | Filesystem      | sys_getcwd()            |
+-------------------+-----------+-----------------+-------------------------+
| execve            | 1         | Filesystem      | sys_execve()            |
+-------------------+-----------+-----------------+-------------------------+
| mmap              | 61        | Memory Mgmt.    | sys_mmap()              |
+-------------------+-----------+-----------------+-------------------------+
| munmap            | 3         | Memory Mgmt.    | sys_munmap()            |
+-------------------+-----------+-----------------+-------------------------+
| mprotect          | 20        | Memory Mgmt.    | sys_mprotect()          |
+-------------------+-----------+-----------------+-------------------------+
| mlock             | 2         | Memory Mgmt.    | sys_mlock()             |
+-------------------+-----------+-----------------+-------------------------+
| brk               | 3         | Memory Mgmt.    | sys_brk()               |
+-------------------+-----------+-----------------+-------------------------+
| rt_sigaction      | 21        | Signal          | sys_rt_sigaction()      |
+-------------------+-----------+-----------------+-------------------------+
| rt_sigprocmask    | 1         | Signal          | sys_rt_sigprocmask()    |
+-------------------+-----------+-----------------+-------------------------+
| sigaltstack       | 1         | Signal          | sys_sigaltstack()       |
+-------------------+-----------+-----------------+-------------------------+
| rt_sigreturn      | 1         | Signal          | sys_rt_sigreturn()      |
+-------------------+-----------+-----------------+-------------------------+
| getpid            | 8         | Process Mgmt.   | sys_getpid()            |
+-------------------+-----------+-----------------+-------------------------+
| prlimit64         | 5         | Process Mgmt.   | sys_prlimit64()         |
+-------------------+-----------+-----------------+-------------------------+
| arch_prctl        | 2         | Process Mgmt.   | sys_arch_prctl()        |
+-------------------+-----------+-----------------+-------------------------+
| sysinfo           | 2         | Process Mgmt.   | sys_sysinfo()           |
+-------------------+-----------+-----------------+-------------------------+
| getuid            | 2         | Process Mgmt.   | sys_getuid()            |
+-------------------+-----------+-----------------+-------------------------+
| uname             | 1         | Process Mgmt.   | sys_uname()             |
+-------------------+-----------+-----------------+-------------------------+
| setpgid           | 1         | Process Mgmt.   | sys_setpgid()           |
+-------------------+-----------+-----------------+-------------------------+
| getrusage         | 1         | Process Mgmt.   | sys_getrusage()         |
+-------------------+-----------+-----------------+-------------------------+
| geteuid           | 1         | Process Mgmt.   | sys_geteuid()           |
+-------------------+-----------+-----------------+-------------------------+
| getppid           | 1         | Process Mgmt.   | sys_getppid()           |
+-------------------+-----------+-----------------+-------------------------+
| sendto            | 3         | Network         | sys_sendto()            |
+-------------------+-----------+-----------------+-------------------------+
| connect           | 1         | Network         | sys_connect()           |
+-------------------+-----------+-----------------+-------------------------+
| socket            | 1         | Network         | sys_socket()            |
+-------------------+-----------+-----------------+-------------------------+
| clone             | 1         | Process Mgmt.   | sys_clone()             |
+-------------------+-----------+-----------------+-------------------------+
| set_tid_address   | 1         | Process Mgmt.   | sys_set_tid_address()   |
+-------------------+-----------+-----------------+-------------------------+
| wait4             | 2         | Time            | sys_wait4()             |
+-------------------+-----------+-----------------+-------------------------+
| alarm             | 1         | Time            | sys_alarm()             |
+-------------------+-----------+-----------------+-------------------------+
| set_robust_list   | 1         | Futex           | sys_set_robust_list()   |
+-------------------+-----------+-----------------+-------------------------+

Theo dõi khối lượng công việc dành cho trẻ em của paxtest
-------------------------------

Chạy lệnh sau để theo dõi khối lượng công việc của paxtest kiddie::

strace -c paxtest kiddie

ZZ0000ZZ

Bảng dưới đây hiển thị các lệnh gọi hệ thống được gọi theo khối lượng công việc, số lượng
số lần mỗi lệnh gọi hệ thống được gọi và hệ thống con Linux tương ứng.

+-------------------+-------------+-----------------+----------------------+
ZZ0000ZZ # calls ZZ0001ZZ Cuộc gọi hệ thống (API) |
+====================+======================================================================================================================================
ZZ0002ZZ 3 ZZ0003ZZ sys_read() |
+-------------------+-------------+-----------------+----------------------+
ZZ0004ZZ 11 ZZ0005ZZ sys_write() |
+-------------------+-------------+-----------------+----------------------+
ZZ0006ZZ 41 ZZ0007ZZ sys_close() |
+-------------------+-------------+-----------------+----------------------+
ZZ0008ZZ 24 ZZ0009ZZ sys_stat() |
+-------------------+-------------+-----------------+----------------------+
ZZ0010ZZ 2 ZZ0011ZZ sys_fstat() |
+-------------------+-------------+-----------------+----------------------+
ZZ0012ZZ 6 ZZ0013ZZ sys_pread64() |
+-------------------+-------------+-----------------+----------------------+
ZZ0014ZZ 1 ZZ0015ZZ sys_access() |
+-------------------+-------------+-----------------+----------------------+
ZZ0016ZZ 1 ZZ0017ZZ sys_pipe() |
+-------------------+-------------+-----------------+----------------------+
ZZ0018ZZ 24 ZZ0019ZZ sys_dup2() |
+-------------------+-------------+-----------------+----------------------+
ZZ0020ZZ 1 ZZ0021ZZ sys_execve() |
+-------------------+-------------+-----------------+----------------------+
ZZ0022ZZ 26 ZZ0023ZZ sys_fcntl() |
+-------------------+-------------+-----------------+----------------------+
ZZ0024ZZ 14 ZZ0025ZZ sys_openat() |
+-------------------+-------------+-----------------+----------------------+
ZZ0026ZZ 7 ZZ0027ZZ sys_rt_sigaction() |
+-------------------+-------------+-----------------+----------------------+
ZZ0028ZZ 38 ZZ0029ZZ sys_rt_sigreturn() |
+-------------------+-------------+-----------------+----------------------+
ZZ0030ZZ 38 ZZ0031ZZ sys_clone() |
+-------------------+-------------+-----------------+----------------------+
ZZ0032ZZ 44 ZZ0033ZZ sys_wait4() |
+-------------------+-------------+-----------------+----------------------+
ZZ0034ZZ 7 ZZ0035ZZ sys_mmap() |
+-------------------+-------------+-----------------+----------------------+
ZZ0036ZZ 3 ZZ0037ZZ sys_mprotect() |
+-------------------+-------------+-----------------+----------------------+
ZZ0038ZZ 1 ZZ0039ZZ sys_munmap() |
+-------------------+-------------+-----------------+----------------------+
ZZ0040ZZ 3 ZZ0041ZZ sys_brk() |
+-------------------+-------------+-----------------+----------------------+
ZZ0042ZZ 1 ZZ0043ZZ sys_getpid() |
+-------------------+-------------+-----------------+----------------------+
ZZ0044ZZ 1 ZZ0045ZZ sys_getuid() |
+-------------------+-------------+-----------------+----------------------+
ZZ0046ZZ 1 ZZ0047ZZ sys_getgid() |
+-------------------+-------------+-----------------+----------------------+
ZZ0048ZZ 2 ZZ0049ZZ sys_geteuid() |
+-------------------+-------------+-----------------+----------------------+
ZZ0050ZZ 1 ZZ0051ZZ sys_getegid() |
+-------------------+-------------+-----------------+----------------------+
ZZ0052ZZ 1 ZZ0053ZZ sys_getppid() |
+-------------------+-------------+-----------------+----------------------+
ZZ0054ZZ 2 ZZ0055ZZ sys_arch_prctl() |
+-------------------+-------------+-----------------+----------------------+

Phần kết luận
==========

Tài liệu này nhằm mục đích sử dụng như một hướng dẫn về cách thu thập thông tin chi tiết
thông tin về các tài nguyên được sử dụng theo khối lượng công việc bằng cách sử dụng strace.

Tài liệu tham khảo
==========

* ZZ0000ZZ
 * ZZ0001ZZ
 * ZZ0002ZZ
 * ZZ0003ZZ
 * ZZ0004ZZ
 * ZZ0005ZZ
 * ZZ0006ZZ