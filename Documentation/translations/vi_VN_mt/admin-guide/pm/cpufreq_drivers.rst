.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/admin-guide/pm/cpufreq_drivers.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=============================================================
Tài liệu kế thừa về Trình điều khiển mở rộng hiệu suất CPU
=============================================================

Bao gồm dưới đây là các tài liệu lịch sử mô tả các loại
Trình điều khiển ZZ0000ZZ.  Chúng được sao chép nguyên văn,
với định dạng khoảng trắng ban đầu và thụt lề được giữ nguyên, ngoại trừ
ký tự khoảng trắng được thêm vào ở đầu mỗi dòng văn bản.


AMD PowerNow! Trình điều khiển
==============================

::

PowerNow! và Cool'n'Quiet là tên AMD cho tần số
 khả năng quản lý trong bộ xử lý AMD. Là phần cứng
 những thay đổi thực hiện trong các thế hệ bộ xử lý mới,
 có một trình điều khiển tần số CPU khác nhau cho mỗi thế hệ.

Lưu ý rằng trình điều khiển sẽ không tải phần cứng "nhầm",
 vì vậy sẽ an toàn khi thử lần lượt từng tài xế khi nghi ngờ về
 đó là trình điều khiển chính xác.

Lưu ý rằng chức năng thay đổi tần số (và điện áp)
 không có sẵn trong tất cả các bộ xử lý. Tài xế sẽ từ chối
 để tải lên bộ xử lý không có khả năng này. khả năng
 được phát hiện với lệnh cpuid.

Trình điều khiển sử dụng các bảng được cung cấp bởi BIOS để thu được tần số và
 thông tin điện áp phù hợp cho một nền tảng cụ thể.
 Chuyển đổi tần số sẽ không khả dụng nếu BIOS thực hiện
 không cung cấp các bảng này.

Thế hệ thứ 6: powernow-k6

Thế hệ thứ 7: powernow-k7: Athlon, Duron, Geode.

Thế hệ thứ 8: powernow-k8: Athlon, Athlon 64, Opteron, Sempron.
 Tài liệu về chức năng này trong bộ xử lý thế hệ thứ 8
 có sẵn trong ấn phẩm "Hướng dẫn dành cho nhà phát triển hạt nhân và BIOS"
 26094, trong chương 9, có thể tải xuống từ www.amd.com.

Dữ liệu được cung cấp bởi BIOS, cho powernow-k7 và cho powernow-k8, có thể là
 từ bảng PSB hoặc từ các đối tượng ACPI. Hỗ trợ ACPI
 chỉ khả dụng nếu cấu hình kernel đặt CONFIG_ACPI_PROCESSOR.
 Trình điều khiển powernow-k8 sẽ cố gắng sử dụng ACPI nếu được định cấu hình như vậy,
 và quay lại PST nếu thất bại.
 Trình điều khiển powernow-k7 sẽ cố gắng sử dụng hỗ trợ PSB trước tiên và
 quay lại ACPI nếu hỗ trợ PSB không thành công. Một tham số mô-đun,
 acpi_force, được cung cấp để buộc sử dụng hỗ trợ ACPI thay thế
 hỗ trợ PSB.


ZZ0000ZZ
===================

::

Trình điều khiển cpufreq-nforce2 thay đổi FSB trên nền tảng nVidia nForce2.

Tính năng này hoạt động tốt hơn so với các nền tảng khác vì FSB của CPU
 có thể được điều khiển độc lập với đồng hồ PCI/AGP.

Mô-đun này có hai tùy chọn:

fid: số nhân * 10 (ví dụ 8,5 = 85)
 	min_fsb: FSB tối thiểu

Nếu không được đặt, fid được tính từ tốc độ CPU hiện tại và FSB.
 min_fsb mặc định là FSB khi khởi động - 50 MHz.

IMPORTANT: Phạm vi khả dụng bị giới hạn trở xuống!
            Ngoài ra, FSB tối thiểu có sẵn có thể khác nhau đối với các hệ thống
            khởi động với 200 MHz, 150 sẽ luôn hoạt động.


ZZ0000ZZ
===============

::

/*
  * pcc-cpufreq.txt - Tài liệu giao diện PCC
  *
  * Bản quyền (C) 2009 Red Hat, Matthew Garrett <mjg@redhat.com>
  * Bản quyền (C) 2009 Công ty Phát triển Hewlett-Packard, L.P.
  * Nagananda Chumbalkar <nagananda.chumbalkar@hp.com>
  */


Trình điều khiển điều khiển xung nhịp bộ xử lý
 			----------------------------------

Nội dung:
 ---------
 1. Giới thiệu
 1.1 Giao diện PCC
 1.1.1 Lấy tần suất trung bình
 1.1.2 Đặt tần số mong muốn
 1.2 Nền tảng bị ảnh hưởng
 2. Chi tiết về trình điều khiển và/hệ thống
 2.1 tỷ lệ_có sẵn_tần số
 2.2 cpuinfo_transition_latency
 2.3 cpuinfo_cur_freq
 2.4 liên quan_cpus
 3. Hãy cẩn thận

1. Giới thiệu:
 ----------------
 Kiểm soát xung nhịp bộ xử lý (PCC) là giao diện giữa nền tảng
 phần sụn và OSPM. Nó là một cơ chế phối hợp bộ xử lý
 hiệu suất (tức là: tần số) giữa phần sụn nền tảng và HĐH.

Trình điều khiển PCC (pcc-cpufreq) cho phép OSPM tận dụng PCC
 giao diện.

Hệ điều hành sử dụng giao diện PCC để thông báo cho phần mềm nền tảng tần số
 Hệ điều hành muốn có bộ xử lý logic. Phần sụn nền tảng cố gắng đạt được
 tần số được yêu cầu. Nếu không thể yêu cầu tần số mục tiêu
 được hài lòng bởi phần sụn nền tảng, thì điều đó thường có nghĩa là ngân sách điện năng
 các điều kiện đã sẵn sàng và "giới hạn quyền lực" đang diễn ra.

1.1 Giao diện PCC:
 ------------------
 Thông số kỹ thuật PCC đầy đủ có sẵn tại đây:
 ZZ0000ZZ

PCC dựa vào vùng bộ nhớ dùng chung cung cấp kênh liên lạc
 giữa hệ điều hành và phần mềm nền tảng. PCC cũng thực hiện một "chuông cửa"
 được hệ điều hành sử dụng để thông báo cho phần sụn nền tảng rằng một lệnh đã được thực hiện
 đã gửi.

Phương thức ACPI PCCH() được sử dụng để khám phá vị trí của PCC được chia sẻ
 vùng bộ nhớ. Tiêu đề vùng bộ nhớ dùng chung chứa "lệnh" và
 Giao diện "trạng thái". PCCH() cũng chứa thông tin chi tiết về cách truy cập nền tảng
 chuông cửa.

Các lệnh sau được hỗ trợ bởi giao diện PCC:
 * Nhận tần suất trung bình
 * Đặt tần số mong muốn

Phương thức ACPI PCCP() được triển khai cho mỗi bộ xử lý logic và được
 được sử dụng để khám phá các offset cho bộ đệm đầu vào và đầu ra trong vùng chia sẻ
 vùng bộ nhớ.

Khi chế độ PCC được bật, nền tảng sẽ không hiển thị hiệu suất của bộ xử lý
 hoặc trạng thái ga (_PSS, _TSS và các đối tượng ACPI liên quan) đến OSPM. Vì vậy,
 trình điều khiển trạng thái P gốc (chẳng hạn như acpi-cpufreq cho Intel, powernow-k8 cho
 AMD) sẽ không tải.

Tuy nhiên, OSPM vẫn nắm quyền kiểm soát chính sách. Thống đốc (ví dụ: "theo yêu cầu")
 tính toán hiệu suất cần thiết cho mỗi bộ xử lý dựa trên khối lượng công việc của máy chủ.
 Trình điều khiển PCC điền vào giao diện lệnh, bộ đệm đầu vào và
 truyền đạt yêu cầu đến phần sụn nền tảng. Phần sụn nền tảng là
 chịu trách nhiệm cung cấp hiệu suất được yêu cầu.

Mỗi lệnh PCC có phạm vi "toàn cầu" và có thể ảnh hưởng đến tất cả các CPU logic trong
 hệ thống. Do đó, PCC có khả năng thực hiện cập nhật "nhóm". Với PCC
 HĐH có khả năng nhận/cài đặt tần số của tất cả các CPU logic trong
 hệ thống chỉ bằng một cuộc gọi tới BIOS.

1.1.1 Lấy tần suất trung bình:
 ----------------------------
 Lệnh này được OSPM sử dụng để truy vấn tần số chạy của
 bộ xử lý kể từ lần cuối cùng lệnh này được hoàn thành. Bộ đệm đầu ra
 biểu thị tần số trung bình không ngừng của bộ xử lý logic được biểu thị bằng
 tỷ lệ phần trăm của tần số CPU danh nghĩa (tức là: tối đa). Bộ đệm đầu ra
 cũng biểu thị liệu tần số CPU có bị giới hạn bởi điều kiện nguồn điện hay không.

1.1.2 Đặt tần số mong muốn:
 ----------------------------
 Lệnh này được OSPM sử dụng để giao tiếp với phần sụn nền tảng
 tần số mong muốn cho bộ xử lý logic. Bộ đệm đầu ra hiện tại là
 bị OSPM bỏ qua. Lời gọi tiếp theo của "Nhận tần suất trung bình" sẽ thông báo
 OSPM có đạt được tần số mong muốn hay không.

1.2 Nền tảng bị ảnh hưởng:
 --------------
 Trình điều khiển PCC sẽ tải trên bất kỳ hệ thống nào có chương trình cơ sở nền tảng:
 * hỗ trợ giao diện PCC và các phương thức PCCH() và PCCP() được liên kết
 * chịu trách nhiệm quản lý các điều khiển xung nhịp phần cứng theo thứ tự
 để cung cấp hiệu suất xử lý được yêu cầu

Hiện tại, một số nền tảng HP ProLiant nhất định triển khai giao diện PCC. Trên những cái đó
 nền tảng PCC là lựa chọn "mặc định".

Tuy nhiên, có thể tắt giao diện này thông qua cài đặt BIOS. trong
 một ví dụ như vậy, cũng như trường hợp trên các nền tảng có giao diện PCC
 không được triển khai, trình điều khiển PCC sẽ không tải được một cách im lặng.

2. Chi tiết về trình điều khiển và/hệ thống:
 --------------------------
 Khi tải trình điều khiển, nó chỉ in CPU thấp nhất và cao nhất
 tần số được hỗ trợ bởi phần mềm nền tảng.

Trình điều khiển PCC tải với thông báo như:
 trình điều khiển pcc-cpufreq: (v1.00.00) được tải với giới hạn tần số: 1600 MHz, 2933
 MHz

Điều này có nghĩa là OPSM có thể yêu cầu CPU chạy ở bất kỳ tần số nào trong
 giữa các giới hạn (1600 MHz và 2933 MHz) được chỉ định trong tin nhắn.

Bên trong, trình điều khiển không cần chuyển đổi tần số "mục tiêu"
 sang trạng thái P tương ứng.

Số VERSION cho trình điều khiển sẽ có định dạng v.xy.ab.
 ví dụ: 1,00,02
    ----- --
     ZZ0000ZZ
     |    -- điều này sẽ tăng lên khi sửa lỗi/cải tiến trình điều khiển
     |-- đây là phiên bản đặc tả PCC mà trình điều khiển tuân thủ


Sau đây là phần thảo luận ngắn gọn về một số trường được xuất thông qua
 /sys hệ thống tập tin và giá trị của chúng bị ảnh hưởng bởi trình điều khiển PCC:

2.1 tỷ lệ_có sẵn_tần số:
 ----------------------------------
 Scaling_available_frequency không được tạo trong /sys. Không có trung gian
 tần số cần phải được liệt kê vì BIOS sẽ cố gắng đạt được bất kỳ tần số nào
 tần suất, trong giới hạn, do thống đốc yêu cầu. Tần số không có
 được liên kết chặt chẽ với trạng thái P.

2.2 cpuinfo_transition_latency:
 -------------------------------
 Trường cpuinfo_transition_latency là 0. Đặc tả PCC có
 hiện tại không bao gồm trường để hiển thị giá trị này.

2.3 cpuinfo_cur_freq:
 ---------------------
 A) Thường cpuinfo_cur_freq sẽ hiển thị giá trị khác với giá trị được khai báo
 trong tỷ lệ có sẵn_tần số hoặc tỷ lệ_cur_freq hoặc tỷ lệ_max_freq.
 Điều này là do tính năng "tăng tốc" có sẵn trên các bộ xử lý Intel gần đây. Nếu nhất định
 đáp ứng các điều kiện BIOS có thể đạt được tốc độ cao hơn một chút so với yêu cầu
 bởi OSPM. Một ví dụ:

tỉ lệ_cur_freq: 2933000
 cpuinfo_cur_freq : 3196000

B) Có lỗi làm tròn liên quan đến giá trị cpuinfo_cur_freq.
 Vì trình điều khiển lấy tần số hiện tại dưới dạng "phần trăm" (%) của
 tần số danh định từ BIOS, đôi khi, các giá trị được hiển thị bởi
 Scaling_cur_freq và cpuinfo_cur_freq có thể không khớp. Một ví dụ:

tỷ lệ_cur_freq: 1600000
 cpuinfo_cur_freq: 1583000

Trong ví dụ này, tần số danh định là 2933 MHz. Người lái xe nhận được
 tần số hiện tại, cpuinfo_cur_freq, bằng 54% tần số danh định:

54% của 2933 MHz = 1583 MHz

Tần số danh nghĩa là tần số tối đa của bộ xử lý và nó thường
 tương ứng với tần số của trạng thái P0.

2.4 liên quan_cpus:
 ------------------
 Trường liên quan_cpus giống hệt với trường_cpus bị ảnh hưởng.

bị ảnh hưởng_cpus : 4
 liên quan_cpus : 4

Hiện tại, trình điều khiển PCC không đánh giá _PSD. Các nền tảng hỗ trợ
 PCC không triển khai SW_ALL. Vì vậy OSPM không cần thực hiện bất kỳ sự phối hợp nào
 để đảm bảo rằng tất cả các CPU phụ thuộc đều được yêu cầu cùng tần số.

3. Hãy cẩn thận:
 -----------
 Không thể tải mô-đun "cpufreq_stats" ở dạng hiện tại và
 dự kiến sẽ hoạt động với trình điều khiển PCC. Vì mô-đun "cpufreq_stats"
 cung cấp thông tin ghi từng trạng thái P, nó không áp dụng được cho trình điều khiển PCC.