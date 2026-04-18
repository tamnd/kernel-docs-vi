.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/nvdimm/maintainer-entry-profile.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

Hồ sơ đăng nhập của người bảo trì LIBNVDIMM
==================================

Tổng quan
--------
Hệ thống con libnvdimm quản lý bộ nhớ liên tục trên nhiều
kiến trúc. Danh sách gửi thư được theo dõi bằng cách chắp vá tại đây:
ZZ0000ZZ
...and that instance is configured to give feedback to submitters on
chấp nhận bản vá và hợp nhất ngược dòng. Các bản vá được hợp nhất thành
nhánh 'libnvdimm-fixes' hoặc 'libnvdimm-for-next'. Những nhánh đó là
có sẵn ở đây:
ZZ0000ZZ

Nói chung, các bản vá có thể được gửi dựa trên -rc mới nhất; tuy nhiên, nếu
thay đổi mã đến phụ thuộc vào các thay đổi đang chờ xử lý khác thì
bản vá phải dựa trên nhánh libnvdimm-for-next. Tuy nhiên, kể từ khi
bộ nhớ liên tục nằm ở giao điểm của bộ nhớ và bộ nhớ ở đó
là những trường hợp các bản vá phù hợp hơn để được hợp nhất thông qua một
Hệ thống tập tin hoặc cây quản lý bộ nhớ. Khi nghi ngờ hãy sao chép nvdimm
list và những người bảo trì sẽ giúp định tuyến.

Các bài nộp sẽ được hiển thị với robot kbuild để biên dịch hồi quy
thử nghiệm. Nó giúp nhận được thông báo thành công từ cơ sở hạ tầng đó
trước khi gửi nhưng không bắt buộc.


Gửi phụ lục danh sách kiểm tra
-------------------------
Có các bài kiểm tra đơn vị cho hệ thống con thông qua tiện ích ndctl:
ZZ0000ZZ
Những thử nghiệm đó cần phải được thông qua trước khi các bản vá được đưa lên thượng nguồn, nhưng không phải
nhất thiết phải trước khi đăng bài đầu tiên. Liên hệ với danh sách nếu bạn cần trợ giúp
thiết lập môi trường thử nghiệm.

Phương pháp cụ thể của thiết bị ACPI (_DSM)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Trước khi xem xét các bản vá cho phép dòng _DSM mới, nó phải
được gán mã giao diện định dạng từ Nhóm phụ NVDIMM của ACPI
Nhóm làm việc đặc điểm kỹ thuật. Nhìn chung, lập trường của hệ thống con là
để đẩy lùi sự phổ biến của các bộ lệnh NVDIMM, hãy làm mạnh mẽ
xem xét triển khai hỗ trợ cho bộ lệnh hiện có. Xem
driver/acpi/nfit/nfit.h để biết tập hợp các bộ lệnh được hỗ trợ.


Ngày chu kỳ chính
---------------
Các bài nộp mới có thể được gửi bất cứ lúc nào, nhưng nếu chúng có ý định đạt được
cửa sổ hợp nhất tiếp theo, chúng sẽ được gửi trước -rc4 và lý tưởng nhất là
được ổn định trong nhánh libnvdimm-for-next bởi -rc6. Tất nhiên nếu một
bộ bản vá yêu cầu hơn 2 tuần xem xét, -rc4 đã quá muộn
và một số bản vá có thể yêu cầu nhiều chu kỳ phát triển để xem xét.


Xem lại nhịp
--------------
Nói chung, vui lòng đợi tối đa một tuần trước khi gửi phản hồi. A
lời nhắc thư riêng được ưu tiên. Hoặc yêu cầu khác
các nhà phát triển có thẻ Người đánh giá để thay đổi libnvdimm cần thực hiện
nhìn và đưa ra ý kiến của mình.
