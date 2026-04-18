.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/admin-guide/pm/strategies.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

.. include:: <isonum.txt>

==============================
Chiến lược quản lý năng lượng
===========================

:Bản quyền: ZZ0000ZZ 2017 Tập đoàn Intel

:Tác giả: Rafael J. Wysocki <rafael.j.wysocki@intel.com>


Nhân Linux hỗ trợ hai chiến lược quản lý năng lượng cấp cao chính.

Một trong số đó dựa trên việc sử dụng các trạng thái năng lượng thấp toàn cầu của toàn bộ hệ thống trong
mã không gian người dùng nào không thể được thực thi và hoạt động tổng thể của hệ thống được
giảm đáng kể, được gọi là ZZ0000ZZ.  các
kernel đặt hệ thống vào một trong những trạng thái này khi được không gian người dùng yêu cầu
và hệ thống vẫn ở trong đó cho đến khi nhận được tín hiệu đặc biệt từ một trong các
thiết bị được chỉ định, kích hoạt quá trình chuyển đổi sang ZZ0002ZZ trong đó
mã không gian người dùng có thể chạy.  Bởi vì trạng thái ngủ là toàn cầu và toàn bộ hệ thống
bị ảnh hưởng bởi những thay đổi trạng thái, chiến lược này được gọi là
ZZ0001ZZ.

Chiến lược khác, được gọi là ZZ0000ZZ, dựa trên việc điều chỉnh trạng thái nguồn của từng phần cứng
các thành phần của hệ thống, khi cần thiết, ở trạng thái làm việc.  Hậu quả là, nếu
chiến lược này đang được sử dụng, trạng thái làm việc của hệ thống thường không
tương ứng với bất kỳ cấu hình vật lý cụ thể nào của nó, nhưng có thể được coi là
một di căn bao gồm một loạt các trạng thái năng lượng khác nhau của hệ thống, trong đó
các thành phần riêng lẻ của nó có thể là ZZ0001ZZ (đang sử dụng) hoặc
ZZ0002ZZ (nhàn rỗi).  Nếu chúng đang hoạt động, chúng phải ở trạng thái mạnh mẽ
cho phép họ xử lý dữ liệu và được truy cập bằng phần mềm.  Đổi lại, nếu họ
không hoạt động, lý tưởng nhất là chúng phải ở trạng thái năng lượng thấp, trong đó chúng có thể không
có thể truy cập được.

Nếu tất cả các thành phần của hệ thống đều hoạt động thì toàn bộ hệ thống được coi là
"thời gian chạy đang hoạt động" và tình huống đó thường tương ứng với công suất tối đa
rút ra (hoặc sử dụng năng lượng tối đa) của nó.  Nếu tất cả chúng đều không hoạt động, hệ thống
nói chung được coi là "thời gian chạy không hoạt động" và có thể rất gần với trạng thái ngủ
trạng thái từ cấu hình hệ thống vật lý và phối cảnh tiêu thụ điện năng, nhưng
thì sẽ mất ít thời gian và công sức hơn để bắt đầu thực thi mã không gian người dùng so với
cho cùng một hệ thống ở trạng thái ngủ.  Tuy nhiên, sự chuyển đổi từ trạng thái ngủ
việc quay lại trạng thái làm việc chỉ có thể được bắt đầu bởi một bộ thiết bị giới hạn, vì vậy
thông thường hệ thống có thể dành nhiều thời gian ở trạng thái ngủ hơn mức có thể
thời gian chạy nhàn rỗi trong một lần.  Vì lý do này, các hệ thống thường sử dụng ít năng lượng hơn trong
trạng thái ngủ hơn là khi chúng ở trạng thái không hoạt động trong hầu hết thời gian.

Hơn nữa, hai chiến lược quản lý năng lượng này còn giải quyết các tình huống sử dụng khác nhau.
Cụ thể là, nếu người dùng cho biết rằng hệ thống sẽ không được sử dụng trong tương lai,
ví dụ bằng cách đóng nắp của nó (nếu hệ thống là máy tính xách tay), có lẽ nó nên
đi vào trạng thái ngủ vào thời điểm đó.  Mặt khác, nếu người dùng chỉ cần truy cập
cách xa bàn phím máy tính xách tay, có lẽ nó sẽ ở trạng thái hoạt động và
sử dụng quản lý năng lượng ở trạng thái làm việc trong trường hợp nó không hoạt động, vì người dùng
có thể quay lại với nó bất kỳ lúc nào và sau đó có thể muốn hệ thống hoạt động ngay lập tức
có thể truy cập được.