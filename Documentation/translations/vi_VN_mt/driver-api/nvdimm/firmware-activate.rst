.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/driver-api/nvdimm/firmware-activate.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

=====================================
Kích hoạt chương trình cơ sở thời gian chạy NVDIMM
==================================

Một số thiết bị bộ nhớ liên tục chạy chương trình cơ sở cục bộ trên thiết bị /
"DIMM" để thực hiện các nhiệm vụ như quản lý phương tiện, cung cấp năng lực,
và theo dõi sức khỏe. Quá trình cập nhật chương trình cơ sở đó thường
liên quan đến việc khởi động lại vì nó có ý nghĩa đối với bộ nhớ trong chuyến bay
giao dịch. Tuy nhiên, việc khởi động lại sẽ gây gián đoạn và ít nhất Intel
triển khai nền tảng bộ nhớ liên tục, được mô tả bởi Intel ACPI
Thông số kỹ thuật DSM [1], đã thêm hỗ trợ kích hoạt chương trình cơ sở tại
thời gian chạy.

Giao diện sysfs gốc được triển khai trong libnvdimm để cho phép nền tảng
để quảng cáo và kiểm soát việc kích hoạt chương trình cơ sở thời gian chạy cục bộ của họ
khả năng.

Đối tượng bus libnvdimm, ndbusX, triển khai ndbusX/firmware/activate
thuộc tính hiển thị trạng thái kích hoạt chương trình cơ sở là trạng thái 'không hoạt động',
'có vũ trang', 'tràn' và 'bận rộn'.

- nhàn rỗi:
  Không có thiết bị nào được thiết lập/trang bị để kích hoạt chương trình cơ sở

- vũ trang:
  Ít nhất một thiết bị được trang bị

- bận:
  Trong trạng thái bận rộn, các thiết bị vũ trang đang trong quá trình chuyển đổi
  trở lại trạng thái rảnh và hoàn thành chu trình kích hoạt.

- tràn:
  Nếu nền tảng có khái niệm về công việc gia tăng cần thiết để thực hiện
  việc kích hoạt có thể xảy ra trường hợp có quá nhiều DIMM được trang bị cho
  kích hoạt. Trong trường hợp đó, khả năng kích hoạt phần sụn sẽ
  thời gian chờ được biểu thị bằng trạng thái 'tràn'.

Thuộc tính 'ndbusX/firmware/activate' có thể được viết với giá trị là
hoặc 'sống' hoặc 'im lặng'. Giá trị 'quiesce' sẽ kích hoạt kernel
chạy kích hoạt chương trình cơ sở từ bên trong tương đương với chế độ ngủ đông
Trạng thái 'đóng băng' nơi trình điều khiển và ứng dụng được thông báo dừng hoạt động
sửa đổi bộ nhớ hệ thống. Giá trị của những lần thử 'sống'
kích hoạt chương trình cơ sở mà không có chu kỳ ngủ đông này. các
Thuộc tính 'ndbusX/firmware/activate' sẽ bị loại bỏ hoàn toàn nếu không
khả năng kích hoạt firmware được phát hiện.

Một thuộc tính khác 'ndbusX/firmware/capability' biểu thị giá trị của
'sống' hoặc 'không hoạt động', trong đó 'sống' chỉ ra rằng phần sụn
không yêu cầu hoặc gây ra bất kỳ khoảng thời gian ngừng hoạt động nào trên hệ thống để cập nhật
phần sụn. Giá trị khả năng 'quiesce' cho biết phần sụn không
mong đợi và đưa vào một khoảng thời gian yên tĩnh cho bộ điều khiển bộ nhớ, nhưng 'sống'
vẫn có thể được ghi vào 'ndbusX/firmware/activate' dưới dạng ghi đè lên
chấp nhận rủi ro khi cập nhật chương trình cơ sở đua với thiết bị trên chuyến bay và
hoạt động ứng dụng. Thuộc tính 'ndbusX/firmware/capability' sẽ là
bỏ qua hoàn toàn nếu không phát hiện thấy khả năng kích hoạt phần sụn.

Đối tượng thiết bị bộ nhớ libnvdimm/DIMM, nmemX, thực hiện
Thuộc tính 'nmemX/firmware/activate' và 'nmemX/firmware/result' cho
truyền đạt trạng thái kích hoạt chương trình cơ sở trên mỗi thiết bị. Tương tự với
Thuộc tính 'ndbusX/firmware/activate', 'nmemX/firmware/activate'
thuộc tính biểu thị 'nhàn rỗi', 'có vũ trang' hoặc 'bận'. Các chuyển đổi trạng thái
từ 'được trang bị' đến 'không hoạt động' khi hệ thống sẵn sàng kích hoạt chương trình cơ sở,
firmware được tổ chức + trạng thái được đặt thành vũ trang và 'ndbusX/firmware/activate' là
được kích hoạt. Sau sự kiện kích hoạt đó, nmemX/firmware/kết quả
thuộc tính phản ánh trạng thái kích hoạt cuối cùng là một trong:

- không:
  Không có kích hoạt thời gian chạy nào được kích hoạt kể từ lần cuối cùng thiết bị được đặt lại

- thành công:
  Lần kích hoạt thời gian chạy cuối cùng đã hoàn tất thành công.

- thất bại:
  Lần kích hoạt thời gian chạy cuối cùng không thành công vì lý do cụ thể của thiết bị.

- not_staged:
  Lần kích hoạt thời gian chạy cuối cùng không thành công do lỗi trình tự của
  hình ảnh phần sụn không được dàn dựng.

- cần_reset:
  Kích hoạt chương trình cơ sở trong thời gian chạy không thành công, nhưng chương trình cơ sở vẫn có thể
  được kích hoạt thông qua phương pháp truyền lực cũ của hệ thống.

[1]: ZZ0000ZZ