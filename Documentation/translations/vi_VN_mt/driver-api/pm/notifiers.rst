.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/driver-api/pm/notifiers.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

.. include:: <isonum.txt>

================================
Trình thông báo tạm dừng/ngủ đông
=============================

:Bản quyền: ZZ0000ZZ 2016 Tập đoàn Intel

:Tác giả: Rafael J. Wysocki <rafael.j.wysocki@intel.com>


Có một số hoạt động mà hệ thống con hoặc trình điều khiển có thể muốn thực hiện
trước khi ngủ đông/tạm dừng hoặc sau khi khôi phục/tiếp tục, nhưng chúng yêu cầu hệ thống
có đầy đủ chức năng, vì vậy ZZ0000ZZ và ZZ0000ZZ của trình điều khiển và hệ thống con
Các cuộc gọi lại ZZ0001ZZ hoặc thậm chí ZZ0002ZZ và ZZ0003ZZ thì không
thích hợp cho mục đích này.

Ví dụ: trình điều khiển thiết bị có thể muốn tải chương trình cơ sở lên thiết bị của họ sau
tiếp tục/khôi phục, nhưng họ không thể làm điều đó bằng cách gọi ZZ0000ZZ
từ quy trình gọi lại ZZ0001ZZ hoặc ZZ0002ZZ của họ (vùng đất của người dùng
quá trình bị đóng băng tại những điểm này).  Giải pháp có thể là tải firmware
vào bộ nhớ trước khi các tiến trình bị đóng băng và tải nó lên từ đó trong
Quy trình ZZ0003ZZ.  Trình thông báo tạm dừng/ngủ đông có thể được sử dụng cho việc đó.

Các hệ thống con hoặc trình điều khiển có nhu cầu như vậy có thể đăng ký các thông báo tạm dừng
sẽ được lõi PM kêu gọi các sự kiện sau:

ZZ0000ZZ
	Hệ thống sắp chuyển sang chế độ ngủ đông, các tác vụ sẽ bị đóng băng ngay lập tức. Cái này
	khác với ZZ0001ZZ bên dưới, vì trong trường hợp này
	công việc bổ sung được thực hiện giữa người thông báo và lệnh gọi PM
	cuộc gọi lại cho quá trình chuyển đổi "đóng băng".

ZZ0000ZZ
	Trạng thái bộ nhớ hệ thống đã được khôi phục từ hình ảnh ngủ đông hoặc hình ảnh
	lỗi xảy ra trong quá trình ngủ đông.  Lệnh gọi lại khôi phục thiết bị đã được
	được thực hiện và nhiệm vụ đã được tan băng.

ZZ0000ZZ
	Hệ thống sẽ khôi phục hình ảnh ngủ đông.  Nếu mọi việc suôn sẻ,
	hạt nhân hình ảnh được khôi phục sẽ phát hành ZZ0001ZZ
	thông báo.

ZZ0000ZZ
	Đã xảy ra lỗi trong quá trình khôi phục từ chế độ ngủ đông.  Khôi phục thiết bị
	các cuộc gọi lại đã được thực hiện và các nhiệm vụ đã được giải quyết.

ZZ0000ZZ
	Hệ thống đang chuẩn bị tạm dừng.

ZZ0000ZZ
	Hệ thống vừa hoạt động trở lại hoặc xảy ra lỗi trong quá trình tạm dừng.  Thiết bị
	các cuộc gọi lại tiếp tục đã được thực hiện và các nhiệm vụ đã được giải quyết.

Người ta thường cho rằng bất cứ điều gì người thông báo làm cho
ZZ0000ZZ, nên được hoàn tác cho ZZ0001ZZ.
Tương tự, các hoạt động được thực hiện cho ZZ0002ZZ phải là
đảo ngược cho ZZ0003ZZ.

Hơn nữa, nếu một trong các trình thông báo không thành công đối với ZZ0000ZZ hoặc
Sự kiện ZZ0001ZZ, những người thông báo đã thành công cho sự kiện đó
sự kiện sẽ được gọi cho ZZ0002ZZ hoặc ZZ0003ZZ,
tương ứng.

Trình thông báo ngủ đông và tạm dừng được gọi khi ZZ0000ZZ được giữ.
Chúng được định nghĩa theo cách thông thường, nhưng đối số cuối cùng của chúng là vô nghĩa (đó là
luôn là NULL).

Để đăng ký và/hoặc hủy đăng ký, hãy sử dụng trình thông báo tạm dừng
ZZ0000ZZ và ZZ0001ZZ,
tương ứng (cả hai đều được xác định trong ZZ0002ZZ).  Nếu bạn không
cần hủy đăng ký trình thông báo, bạn cũng có thể sử dụng ZZ0003ZZ
macro được xác định trong ZZ0004ZZ.