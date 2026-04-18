.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/hwmon/k10temp.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

Trình điều khiển hạt nhân k10temp
=====================

Chip được hỗ trợ:

* Bộ xử lý AMD Gia đình 10h:

Ổ cắm F: Opteron lõi tứ/Sáu lõi/nhúng (nhưng xem bên dưới)

Ổ cắm AM2+: Opteron lõi tứ, Phenom (II) X3/X4, Athlon X2 (nhưng xem bên dưới)

Ổ cắm AM3: Opteron lõi tứ, Athlon/Phenom II X2/X3/X4, Sempron II

Ổ cắm S1G3: Athlon II, Sempron, Turion II

* Bộ xử lý AMD Gia đình 11h:

Ổ cắm S1G2: Athlon (X2), Sempron (X2), Turion X2 (Ultra)

* Bộ xử lý AMD Family 12h: "Llano" (E2/A4/A6/A8-Series)

* Bộ xử lý AMD dòng 14h: "Brazos" (C/E/G/Z-Series)

* Bộ xử lý AMD Family 15h: "Bulldozer" (FX-Series), "Trinity", "Kaveri",
  "Carrizo", "Stoney Ridge", "Bristol Ridge"

* Bộ xử lý AMD Gia đình 16h: "Kabini", "Mullins"

* Bộ xử lý AMD Gia đình 17h: "Zen", "Zen 2"

* Bộ xử lý AMD Gia đình 18h: "Hygon Dhyana"

* Bộ xử lý AMD Gia đình 19h: "Zen 3"

Tiền tố: 'k10temp'

Địa chỉ được quét: không gian PCI

Bảng dữ liệu:

Hướng dẫn dành cho nhà phát triển hạt nhân và BIOS (BKDG) dành cho bộ xử lý 10h dòng AMD:

ZZ0000ZZ

Hướng dẫn dành cho nhà phát triển hạt nhân và BIOS (BKDG) dành cho Bộ xử lý dòng AMD 11h:

ZZ0000ZZ

Hướng dẫn dành cho nhà phát triển hạt nhân và BIOS (BKDG) dành cho Bộ xử lý 12h dòng AMD:

ZZ0000ZZ

Hướng dẫn dành cho nhà phát triển hạt nhân và BIOS (BKDG) dành cho dòng AMD Model 14h Bộ xử lý 00h-0Fh:

ZZ0000ZZ

Hướng dẫn sửa đổi dành cho Bộ xử lý dòng AMD 10h:

ZZ0000ZZ

Hướng dẫn sửa đổi dành cho Bộ xử lý dòng AMD 11h:

ZZ0000ZZ

Hướng dẫn sửa đổi dành cho Bộ xử lý dòng AMD 12h:

ZZ0000ZZ

Hướng dẫn sửa đổi dành cho Bộ xử lý dòng 14h dòng AMD 00h-0Fh:

ZZ0000ZZ

Bảng dữ liệu nhiệt và nguồn bộ xử lý dòng AMD 11h dành cho máy tính xách tay:

ZZ0000ZZ

Bảng dữ liệu nhiệt và nguồn của bộ xử lý máy chủ và máy trạm dòng AMD 10h:

ZZ0000ZZ

Bảng dữ liệu nhiệt và nguồn của bộ xử lý máy tính để bàn AMD Family 10h:

ZZ0000ZZ

Tác giả: Clemens Ladisch <clemens@ladisch.de>

Sự miêu tả
-----------

Trình điều khiển này cho phép đọc cảm biến nhiệt độ bên trong của AMD
Bộ xử lý gia đình 10h/11h/12h/14h/15h/16h.

Tất cả các bộ xử lý này đều có cảm biến, nhưng trên các bộ xử lý dành cho Ổ cắm F hoặc AM2+,
cảm biến có thể trả về các giá trị không nhất quán (lỗi 319).  Người lái xe
sẽ từ chối tải các bản sửa đổi này trừ khi bạn chỉ định "force=1"
tham số mô-đun.

Vì lý do kỹ thuật, trình điều khiển chỉ có thể phát hiện được bo mạch chính.
loại ổ cắm, không phải khả năng thực tế của bộ xử lý.  Vì vậy, nếu bạn
đang sử dụng bộ xử lý AM3 trên bo mạch chính AM2+, bạn có thể sử dụng bộ xử lý này một cách an toàn
tham số "lực = 1".

Đối với các CPU cũ hơn Family 17h, có một giá trị đo nhiệt độ,
có sẵn dưới dạng temp1_input trong sysfs. Nó được đo bằng độ C với
độ phân giải 1/8 độ.  Xin lưu ý rằng nó được định nghĩa là họ hàng
giá trị; để trích dẫn hướng dẫn sử dụng AMD ::

Tctl là giá trị kiểm soát nhiệt độ bộ xử lý, được nền tảng sử dụng để
  điều khiển hệ thống làm mát. Tctl là nhiệt độ phi vật lý trên một
  thang đo tùy ý được đo bằng độ. Nó _not_ đại diện cho một thực tế
  nhiệt độ vật lý như nhiệt độ khuôn hoặc trường hợp. Thay vào đó, nó chỉ định
  nhiệt độ của bộ xử lý so với điểm mà hệ thống phải
  cung cấp khả năng làm mát tối đa cho trường hợp tối đa được chỉ định của bộ xử lý
  nhiệt độ và tản nhiệt tối đa.

Giá trị tối đa cho Tctl có sẵn trong tệp temp1_max.

Nếu BIOS đã bật điều khiển nhiệt độ phần cứng thì ngưỡng ở
mà bộ xử lý sẽ tự điều chỉnh để tránh hư hỏng có sẵn trong
temp1_crit và temp1_crit_hyst.

Trên một số CPU AMD, có sự khác biệt giữa nhiệt độ khuôn (Tdie) và
nhiệt độ được báo cáo (Tctl). Tdie là nhiệt độ thực đo được, và
Tctl được sử dụng để điều khiển quạt. Trong khi Tctl luôn có sẵn dưới dạng temp1_input,
trình điều khiển xuất nhiệt độ Tdie dưới dạng temp2_input cho những CPU hỗ trợ
nó.

Các mẫu xe thuộc dòng 17h báo cáo nhiệt độ tương đối, tài xế hướng tới
bù đắp và báo cáo nhiệt độ thực tế.

Trên CPU Family 17h và Family 18h, các cảm biến nhiệt độ bổ sung có thể báo cáo
Nhiệt độ lõi phức hợp (CCD). Lên đến 8 nhiệt độ như vậy được báo cáo
dưới dạng tạm thời{3..10__input, được gắn nhãn Tccd{1..8}. Hỗ trợ thực tế phụ thuộc vào CPU
biến thể.
