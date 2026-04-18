.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/trace/coresight/coresight-perf.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

====================
CoreSight - Hoàn hảo
====================

:Tác giả: Carsten Haitzler <carsten.haitzler@arm.com>
    :Ngày: 29 tháng 6 năm 2022

Perf có thể truy cập cục bộ dữ liệu theo dõi CoreSight và lưu trữ nó vào
xuất ra các tập tin dữ liệu perf. Dữ liệu này sau đó có thể được giải mã để cung cấp
hướng dẫn được truy tìm cho mục đích gỡ lỗi hoặc lập hồ sơ. bạn
có thể ghi nhật ký dữ liệu đó bằng lệnh ghi hoàn hảo như ::

bản ghi hoàn hảo -e cs_etm//u testbinary

Điều này sẽ chạy một số nhị phân thử nghiệm (testbinary) cho đến khi nó thoát và ghi lại
một tệp theo dõi perf.data. Tệp đó sẽ có các phần AUX nếu CoreSight
đang hoạt động chính xác. Bạn có thể kết xuất nội dung của tập tin này dưới dạng
văn bản có thể đọc được bằng lệnh như::

báo cáo hoàn hảo --stdio --dump -i perf.data

Bạn sẽ thấy một số phần của tệp này có khối dữ liệu AUX như ::

0x1e78 [0x30]: Kích thước PERF_RECORD_AUXTRACE: 0x11dd0 offset: 0 ref: 0x1b614fc1061b0ad1 idx: 0 tid: 531230 cpu: -1

. ... Dữ liệu theo dõi CoreSight ETM: kích thước 73168 byte
           Mã số:0; Mã số:10;   I_ASYNC : Đồng bộ hóa căn chỉnh.
             Mã số:12; Mã số:10;  I_TRACE_INFO : Thông tin dấu vết.; INFO=0x0 { CC.0 }
             Mã số:17; Mã số:10;  I_ADDR_L_64IS0 : Địa chỉ, Dài, 64 bit, IS0.; Địa chỉ=0x00000000000000000;
             Mã số:26; Mã số:10;  I_TRACE_ON : Theo dõi.
             Mã số:27; Mã số:10;  I_ADDR_CTXT_L_64IS0 : Địa chỉ & Ngữ cảnh, Dài, 64 bit, IS0.; Địa chỉ=0x0000FFFFB6069140; Ctxt: AArch64,EL0, NS;
             Mã số:38; Mã số:10;  I_ATOM_F6 : Định dạng nguyên tử 6.; EEEEEEEEEEEEEEEEEEEEEEEE
             Mã số:39; Mã số:10;  I_ATOM_F6 : Định dạng nguyên tử 6.; EEEEEEEEEEEEEEEEEEEEEEEE
             Mã số:40; Mã số:10;  I_ATOM_F6 : Định dạng nguyên tử 6.; EEEEEEEEEEEEEEEEEEEEEEEE
             Mã số:41; Mã số:10;  I_ATOM_F6 : Định dạng nguyên tử 6.; EEEEEEEEEEEN
             ...

Nếu bạn thấy những điều này ở trên thì hệ thống của bạn đang truy tìm dữ liệu CoreSight
một cách chính xác.

Để biên dịch sự hoàn hảo với sự hỗ trợ của CoreSight trong thư mục tools/perf, hãy làm::

làm cho CORESIGHT=1

Điều này yêu cầu OpenCSD để xây dựng. Bạn có thể cài đặt các gói phân phối
để được hỗ trợ như libopencsd và libopencsd-dev hoặc tải xuống
và xây dựng chính mình. OpenCSD ngược dòng được đặt tại:

ZZ0000ZZ

Để biết thông tin đầy đủ về việc xây dựng sự hoàn hảo với sự hỗ trợ của CoreSight và
cách sử dụng rộng rãi hơn hãy xem:

ZZ0000ZZ


Hỗ trợ Kernel CoreSight
------------------------

Bạn cũng sẽ muốn hỗ trợ CoreSight được kích hoạt trong cấu hình kernel của mình.
Đảm bảo nó được kích hoạt với::

CONFIG_CORESIGHT=y

Có nhiều tùy chọn CoreSight khác mà bạn có thể muốn
được kích hoạt như::

CONFIG_CORESIGHT_LINKS_AND_SINKS=y
   CONFIG_CORESIGHT_LINK_AND_SINK_TMC=y
   CONFIG_CORESIGHT_CATU=y
   CONFIG_CORESIGHT_SINK_TPIU=y
   CONFIG_CORESIGHT_SINK_ETBV10=y
   CONFIG_CORESIGHT_SOURCE_ETM4X=y
   CONFIG_CORESIGHT_CTI=y
   CONFIG_CORESIGHT_CTI_INTEGRATION_REGS=y

Vui lòng tham khảo trợ giúp cấu hình kernel để biết thêm thông tin.

Theo dõi chi tiết với tính năng tạm dừng và tiếp tục AUX
----------------------------------------------

Arm CoreSight có thể tạo ra một lượng lớn dữ liệu theo dõi phần cứng,
sẽ dẫn đến tốn kém trong việc ghi lại và khiến người dùng mất tập trung khi xem lại
kết quả hồ sơ. Để giảm thiểu vấn đề dữ liệu theo dõi quá mức, Perf
cung cấp chức năng tạm dừng và tiếp tục AUX để theo dõi chi tiết.

Việc tạm dừng và tiếp tục AUX có thể được kích hoạt bởi các sự kiện liên quan. Những cái này
các sự kiện có thể là các điểm theo dõi ftrace (bao gồm cả tĩnh và động
dấu vết) hoặc sự kiện PMU (ví dụ: sự kiện chu kỳ CPU PMU). Để tạo ra sự hoàn hảo
phiên với tạm dừng / tiếp tục AUX, ba thuật ngữ cấu hình là
đã giới thiệu:

- "aux-action=start-paused": nó được chỉ định cho sự kiện cs_etm PMU để
  khởi động ở trạng thái tạm dừng.
- "aux-action=pause": một sự kiện liên quan được chỉ định bằng thuật ngữ này
  để tạm dừng dấu vết AUX.
- "aux-action=resume": một sự kiện liên quan được chỉ định bằng thuật ngữ này
  để tiếp tục theo dõi AUX.

Ví dụ về kích hoạt tạm dừng và tiếp tục AUX với dấu vết ftrace::

bản ghi hoàn hảo -e cs_etm/aux-action=start-paused/k,syscalls:sys_enter_openat/aux-action=resume/,syscalls:sys_exit_openat/aux-action=pause/ ls

Ví dụ về kích hoạt tạm dừng và tiếp tục AUX với sự kiện PMU::

bản ghi hoàn hảo -a -e cs_etm/aux-action=start-pause/k \
        -e chu kỳ/aux-action=tạm dừng,thời gian=10000000/ \
        -e chu kỳ/aux-action=sơ yếu lý lịch, chu kỳ=1050000/ -- ngủ 1

Kiểm tra hoàn hảo - Xác minh hoạt động hoàn hảo của kernel và không gian người dùng CoreSight
-----------------------------------------------------------

Khi bạn chạy thử nghiệm hoàn hảo, nó sẽ tự thực hiện rất nhiều thử nghiệm. Một số trong số đó
các bài kiểm tra sẽ bao gồm CoreSight (chỉ khi được bật và trên ARM64). bạn
thường sẽ chạy thử nghiệm độ hoàn hảo từ thư mục tools/perf trong
cây hạt nhân. Một số thử nghiệm sẽ kiểm tra một số hỗ trợ hoàn thiện nội bộ như:

Kiểm tra các mẫu ghi và tổng hợp dữ liệu theo dõi Arm CoreSight
   Kiểm tra các mẫu ghi và tổng hợp dữ liệu theo dõi Arm SPE

Một số người khác thực sự sẽ sử dụng bản ghi hoàn hảo và một số tệp nhị phân thử nghiệm
đang trong quá trình kiểm tra/shell/coresight và sẽ thu thập dấu vết để đảm bảo
mức độ chức năng tối thiểu được đáp ứng. Các tập lệnh khởi chạy chúng
các bài kiểm tra nằm trong cùng một thư mục. Tất cả những thứ này sẽ trông giống như:

Vòng lặp thuần CoreSight / ASM
   CoreSight / Memcpy 16k 10 Chủ đề
   CoreSight / Thread Loop 10 Thread - Kiểm tra TID
   v.v.

Các thử nghiệm bản ghi hoàn hảo này sẽ không chạy nếu tệp nhị phân của công cụ không tồn tại
trong test/shell/coresight/\*/ và sẽ bị bỏ qua. Nếu bạn không có
Hỗ trợ CoreSight trong phần cứng thì không xây dựng được sự hoàn hảo với
CoreSight hỗ trợ hoặc loại bỏ các tệp nhị phân này để không có các tệp nhị phân này
các bài kiểm tra thất bại và thay vào đó họ bỏ qua.

Những thử nghiệm này sẽ ghi lại kết quả lịch sử trong hoạt động hiện tại
thư mục (ví dụ: tools/perf) và sẽ được đặt tên là stats-\*.csv như:

stats-asm_pure_loop-out.csv
   stats-memcpy_thread-16k_10.csv
   ...

Các tệp thống kê này ghi lại một số khía cạnh của phần dữ liệu AUX trong
đầu ra dữ liệu hoàn hảo đếm một số số lượng mã hóa nhất định (a
cách tốt để biết rằng nó hoạt động theo cách rất đơn giản). Một vấn đề
với CoreSight là khi cần một lượng dữ liệu đủ lớn
được ghi lại, một số có thể bị mất do bộ xử lý không hoạt động
kịp thời để đọc tất cả dữ liệu từ bộ đệm, v.v.. Bạn sẽ nhận thấy
rằng lượng dữ liệu được thu thập có thể thay đổi rất nhiều trong mỗi lần chạy thử nghiệm độ hoàn hảo.
Nếu bạn muốn xem điều này thay đổi như thế nào theo thời gian, chỉ cần chạy thử nghiệm hoàn hảo
nhiều lần và tất cả các tệp csv này sẽ ngày càng có nhiều dữ liệu hơn
được thêm vào đó để sau này bạn có thể kiểm tra, vẽ biểu đồ và sử dụng để
tìm hiểu xem mọi thứ đã trở nên tồi tệ hơn hay tốt hơn.

Điều này có nghĩa là đôi khi những thử nghiệm này thất bại vì chúng không nắm bắt được tất cả các thông tin
dữ liệu cần thiết. Đây là về việc theo dõi chất lượng và số lượng dữ liệu
được tạo ra theo thời gian và để xem khi nào những thay đổi đối với nhân Linux được cải thiện
chất lượng của dấu vết.

Xin lưu ý rằng một số thử nghiệm này mất khá nhiều thời gian để chạy, cụ thể là
trong việc xử lý tệp dữ liệu hoàn hảo và kết xuất nội dung để kiểm tra những gì
đang ở bên trong.

Bạn có thể thay đổi nơi lưu trữ các nhật ký csv này bằng cách đặt
Biến môi trường PERF_TEST_CORESIGHT_STATDIR trước khi chạy perf
kiểm tra như::

xuất PERF_TEST_CORESIGHT_STATDIR=/var/tmp
   kiểm tra hoàn hảo

Họ cũng sẽ lưu trữ dữ liệu đầu ra về hiệu suất trong hiện tại
thư mục để kiểm tra sau này như::

perf-asm_pure_loop-out.data
   perf-memcpy_thread-16k_10.data
   ...

Bạn có thể thay đổi nơi lưu trữ các tệp dữ liệu hoàn hảo bằng cách đặt
Biến môi trường PERF_TEST_CORESIGHT_DATADIR như::

PERF_TEST_CORESIGHT_DATADIR=/var/tmp
   kiểm tra hoàn hảo

Bạn có thể muốn đặt các biến môi trường trên nếu bạn muốn
giữ đầu ra của các bài kiểm tra bên ngoài thư mục làm việc hiện tại
lưu trữ và kiểm tra lâu dài hơn.