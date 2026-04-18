.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/arch/x86/buslock.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. include:: <isonum.txt>

==================================
Phát hiện và xử lý khóa xe buýt
==================================

:Bản quyền: ZZ0000ZZ 2021 Tập đoàn Intel
:Tác giả: - Fenghua Yu <fenghua.yu@intel.com>
          - Tony Luck <tony.luck@intel.com>

Vấn đề
=======

Khóa phân chia là bất kỳ hoạt động nguyên tử nào có toán hạng vượt qua hai dòng bộ đệm.
Vì toán hạng kéo dài hai dòng bộ đệm và hoạt động phải là nguyên tử,
hệ thống khóa bus trong khi CPU truy cập vào hai dòng bộ đệm.

Khóa xe buýt có được thông qua quyền truy cập bị khóa phân chia để ghi lại (WB)
bộ nhớ hoặc bất kỳ quyền truy cập bị khóa nào vào bộ nhớ không phải WB. Thông thường con số này là hàng nghìn
chu kỳ chậm hơn so với hoạt động nguyên tử trong dòng bộ đệm. Nó cũng làm gián đoạn
hiệu suất trên các lõi khác và khiến toàn bộ hệ thống phải hoạt động hết công suất.

Phát hiện
=========

Bộ xử lý Intel có thể hỗ trợ một hoặc cả hai phần cứng sau
cơ chế phát hiện khóa chia và khóa xe buýt. Một số bộ xử lý AMD cũng
hỗ trợ phát hiện khóa xe buýt.

Ngoại lệ #AC để phát hiện khóa phân chia
--------------------------------------

Bắt đầu với hoạt động khóa chia đôi Tremont Atom CPU có thể gây ra
Ngoại lệ Kiểm tra căn chỉnh (#AC) khi thực hiện thao tác khóa phân tách.

Ngoại lệ #DB để phát hiện khóa xe buýt
------------------------------------

Một số CPU có khả năng thông báo kernel bằng bẫy #DB sau khi người dùng
lệnh yêu cầu khóa bus và được thực thi. Điều này cho phép hạt nhân
chấm dứt ứng dụng hoặc thực thi điều chỉnh.

Xử lý phần mềm
=================

Trình xử lý kernel #AC và #DB xử lý khóa bus dựa trên kernel
tham số "split_lock_Detect". Dưới đây là tóm tắt các tùy chọn khác nhau:

+-------------------+-----------------------------+--------------+
ZZ0000ZZ#AC cho khóa chia ZZ0001ZZ
+-------------------+-----------------------------+--------------+
|off	  	   |Không làm gì cả ZZ0003ZZ
+-------------------+-----------------------------+--------------+
|warn		   |Kernel OOP ZZ0005ZZ
|(default)	   |Warn một lần cho mỗi nhiệm vụ, thêm ZZ0007ZZ
|		   |delay, thêm đồng bộ hóa ZZ0009ZZ
|		   |để ngăn chặn nhiều hơn một ZZ0011ZZ
|		   |core khi thực thi ZZ0013ZZ
|		   |chia khóa song song.	ZZ0015ZZ
|		   |sysctl chia_lock_giảm nhẹ ZZ0017ZZ
|		   |có thể được sử dụng để tránh ZZ0019ZZ
|		   |delay và đồng bộ hóa ZZ0021ZZ
|		   |Khi cả hai tính năng đều là ZZ0023ZZ
Hỗ trợ |		   |, cảnh báo trong #AC ZZ0025ZZ
+-------------------+-----------------------------+--------------+
|fatal		   |Kernel OOP ZZ0027ZZ
|		   |Gửi SIGBUS tới người dùng ZZ0029ZZ
|		   |Khi cả hai tính năng đều là ZZ0031ZZ
|		   | được hỗ trợ, gây tử vong trong #AC ZZ0033ZZ
+-------------------+-----------------------------+--------------+
|ratelimit:N	   |Không làm gì cả ZZ0035ZZ
ZZ0036ZZ ZZ0037ZZ
ZZ0038ZZ ZZ0039ZZ
ZZ0040ZZ ZZ0041ZZ
+-------------------+-----------------------------+--------------+

Công dụng
======

Việc phát hiện và xử lý khóa xe buýt có thể được sử dụng trong nhiều lĩnh vực khác nhau:

Điều này rất quan trọng đối với các nhà thiết kế hệ thống thời gian thực, những người xây dựng hệ thống thực tế hợp nhất.
các hệ thống thời gian. Các hệ thống này chạy mã thời gian thực cứng trên một số lõi và chạy
quy trình người dùng "không đáng tin cậy" trên các lõi khác. Thời gian thực khó khăn không đủ khả năng
có bất kỳ khóa xe buýt nào từ các quy trình không đáng tin cậy để làm tổn hại đến thời gian thực
hiệu suất. Cho đến nay các nhà thiết kế đã không thể triển khai những
giải pháp vì chúng không có cách nào để ngăn chặn mã người dùng "không đáng tin cậy" khỏi
tạo khóa phân chia và khóa bus để chặn mã thời gian thực cứng
truy cập bộ nhớ trong quá trình khóa xe buýt.

Nó cũng hữu ích cho máy tính nói chung để ngăn chặn khách hoặc người dùng
các ứng dụng làm chậm toàn bộ hệ thống bằng cách thực hiện các hướng dẫn
với khóa xe buýt.


hướng dẫn
========
tắt
---

Vô hiệu hóa việc kiểm tra khóa chia và khóa xe buýt. Tùy chọn này có thể hữu ích nếu
có những ứng dụng cũ kích hoạt những sự kiện này với tỷ lệ thấp nên
việc giảm thiểu đó là không cần thiết.

cảnh báo
----

Một cảnh báo được phát ra khi phát hiện khóa xe buýt cho phép xác định
ứng dụng vi phạm. Đây là hành vi mặc định.

gây tử vong
-----

Trong trường hợp này, khóa xe buýt không được chấp nhận và quá trình này sẽ bị hủy.

giới hạn tỷ lệ
---------

Giới hạn tốc độ khóa bus toàn hệ thống N được chỉ định trong đó 0 < N <= 1000. Điều này
cho phép tốc độ khóa bus lên tới N khóa bus mỗi giây. Khi tốc độ khóa xe buýt
bị vượt quá thì bất kỳ tác vụ nào được thực hiện thông qua ngoại lệ #DB của buslock đều bị
được điều tiết bởi các giấc ngủ bắt buộc cho đến khi tốc độ lại giảm xuống dưới giới hạn.

Đây là biện pháp giảm nhẹ hiệu quả trong những trường hợp có thể gây ra tác động tối thiểu
được chấp nhận, nhưng một cuộc tấn công từ chối dịch vụ cuối cùng phải được ngăn chặn. Nó
cho phép xác định các quy trình vi phạm và phân tích xem chúng có
độc hại hoặc chỉ được viết xấu.

Việc chọn giới hạn tốc độ là 1000 cho phép xe buýt bị khóa trong khoảng
bảy triệu chu kỳ mỗi giây (giả sử 7000 chu kỳ cho mỗi xe buýt
khóa). Trên bộ xử lý 2 GHz, hệ thống sẽ bị chậm khoảng 0,35%.