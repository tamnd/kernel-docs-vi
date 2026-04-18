.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/gpu/drm-usage-stats.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. _drm-client-usage-stats:

======================================
Số liệu thống kê sử dụng máy khách DRM
======================================

Trình điều khiển DRM có thể chọn xuất văn bản được chuẩn hóa một phần thông qua
ZZ0000ZZ là một phần của hoạt động tệp cụ thể của trình điều khiển đã được đăng ký
trong đối tượng ZZ0001ZZ được đăng ký với lõi DRM.

Một mục đích của kết quả đầu ra này là cho phép viết một cách chung chung nhất có thể trong thực tế.
khả thi ZZ0000ZZ giống như các công cụ giám sát không gian người dùng.

Do sự khác biệt giữa các trình điều khiển DRM khác nhau, thông số kỹ thuật của
đầu ra được phân chia giữa các phần chung và trình điều khiển cụ thể. Nói xong,
dù có thể, vẫn nên nỗ lực để tiêu chuẩn hóa càng nhiều càng tốt.
có thể.

Đặc tả định dạng tệp
=========================

- Tệp phải chứa một cặp giá trị khóa trên một dòng văn bản.
- Ký tự dấu hai chấm (ZZ0000ZZ) phải được sử dụng để phân cách các khóa và giá trị.
- Tất cả các khóa được tiêu chuẩn hóa sẽ có tiền tố ZZ0001ZZ.
- Các khóa dành riêng cho trình điều khiển phải có tiền tố ZZ0002ZZ, trong đó
  driver_name lý tưởng nhất phải giống với trường ZZ0003ZZ trong
  ZZ0004ZZ, mặc dù điều này không bắt buộc.
- Khoảng trắng giữa dấu phân cách và ký tự không phải khoảng trắng đầu tiên sẽ là
  bị bỏ qua khi phân tích cú pháp.
- Key không được phép chứa ký tự khoảng trắng.
- Cặp giá trị khóa số có thể kết thúc bằng chuỗi đơn vị tùy chọn.
- Kiểu dữ liệu của giá trị được cố định như được xác định trong đặc tả.

Các loại khóa
---------

1. Bắt buộc, được chuẩn hóa đầy đủ.
2. Tùy chọn, tiêu chuẩn hóa đầy đủ.
3. Trình điều khiển cụ thể.

Các kiểu dữ liệu
----------

- <uint> - Số nguyên không dấu mà không xác định giá trị tối đa.
- <keystr> - Chuỗi không bao gồm bất kỳ ký tự dành riêng hoặc khoảng trắng nào được xác định ở trên.
- <valstr> - Chuỗi.

Các khóa được tiêu chuẩn hóa đầy đủ bắt buộc
---------------------------------

- trình điều khiển drm: <valstr>

Chuỗi sẽ chứa tên trình điều khiển này đã đăng ký thông qua tương ứng
Cấu trúc dữ liệu ZZ0000ZZ.

Các phím được chuẩn hóa đầy đủ tùy chọn
--------------------------------

Nhận dạng
^^^^^^^^^^^^^^

- drm-pdev: <aaaa:bb.cc.d>

Đối với các thiết bị PCI, phần này phải chứa địa chỉ khe PCI của thiết bị trong
câu hỏi.

- drm-client-id: <uint>

Giá trị duy nhất liên quan đến bộ mô tả tệp DRM đang mở được sử dụng để phân biệt
mô tả tập tin trùng lặp và chia sẻ. Về mặt khái niệm, giá trị sẽ ánh xạ 1:1
đến biểu diễn kernel của các phiên bản ZZ0000ZZ.

Tính duy nhất của giá trị phải là duy nhất trên toàn cầu hoặc duy nhất trong phạm vi
phạm vi của từng thiết bị, trong trường hợp đó ZZ0000ZZ cũng sẽ xuất hiện.

Vùng người dùng phải đảm bảo không tính gấp đôi bất kỳ số liệu thống kê sử dụng nào bằng cách sử dụng
các tiêu chí được mô tả ở trên để liên kết dữ liệu với từng khách hàng.

- drm-tên khách hàng: <valstr>

Chuỗi tùy chọn được đặt theo không gian người dùng bằng DRM_IOCTL_SET_CLIENT_NAME.


Sử dụng
^^^^^^^^^^^

- drm-engine-<keystr>: <uint> ns

GPU thường chứa nhiều công cụ thực thi. Mỗi người sẽ được cấp một nơi ổn định
và tên duy nhất (keystr), với các giá trị có thể được ghi trong trình điều khiển cụ thể
tài liệu.

Giá trị phải tính bằng đơn vị thời gian được chỉ định mà động cơ GPU tương ứng đã sử dụng
bận thực hiện khối lượng công việc thuộc về khách hàng này.

Các giá trị không nhất thiết phải đơn điệu liên tục nếu nó làm cho trình điều khiển
thực hiện dễ dàng hơn nhưng phải bắt kịp với các báo cáo trước đó
giá trị lớn hơn trong một khoảng thời gian hợp lý. Khi quan sát một giá trị thấp hơn những gì
đã được đọc trước đó, không gian người dùng dự kiến sẽ vẫn ở mức lớn hơn trước đó
giá trị cho đến khi nhìn thấy một bản cập nhật đơn điệu.

- drm-engine-capacity-<keystr>: <uint>

Chuỗi định danh công cụ phải giống với chuỗi được chỉ định trong
thẻ drm-engine-<keystr> và phải chứa số lớn hơn 0 trong trường hợp
công cụ được xuất tương ứng với một nhóm các công cụ phần cứng giống hệt nhau.

Trong trường hợp không có trình phân tích cú pháp thẻ này sẽ đảm nhận khả năng là một. Không có công suất
không được phép.

- drm-cycles-<keystr>: <uint>

Chuỗi định danh công cụ phải giống với chuỗi được chỉ định trong
thẻ drm-engine-<keystr> và sẽ chứa số lượng chu kỳ bận cho thời gian nhất định
động cơ.

Các giá trị không nhất thiết phải đơn điệu liên tục nếu nó làm cho trình điều khiển
thực hiện dễ dàng hơn nhưng phải bắt kịp với các báo cáo trước đó
giá trị lớn hơn trong một khoảng thời gian hợp lý. Khi quan sát một giá trị thấp hơn những gì
đã được đọc trước đó, không gian người dùng dự kiến sẽ vẫn ở mức lớn hơn trước đó
giá trị cho đến khi nhìn thấy một bản cập nhật đơn điệu.

- drm-total-cycles-<keystr>: <uint>

Chuỗi định danh công cụ phải giống với chuỗi được chỉ định trong
thẻ drm-cycles-<keystr> và sẽ chứa tổng số chu kỳ cho chuỗi đã cho
động cơ.

Đây là dấu thời gian trong đơn vị không xác định GPU phù hợp với tốc độ cập nhật
của drm-cycles-<keystr>. Đối với các trình điều khiển triển khai giao diện này, công cụ
việc sử dụng có thể được tính toán hoàn toàn trên miền đồng hồ GPU mà không cần
xem xét thời gian ngủ của CPU giữa 2 mẫu.

Trình điều khiển có thể triển khai khóa này hoặc drm-maxfreq-<keystr>, nhưng không được triển khai cả hai.

- drm-maxfreq-<keystr>: <uint> [Hz|MHz|KHz]

Chuỗi định danh công cụ phải giống với chuỗi được chỉ định trong
thẻ drm-engine-<keystr> và sẽ chứa tần số tối đa cho khoảng thời gian nhất định
động cơ.  Được kết hợp với drm-cycles-<keystr>, điều này có thể được sử dụng để tính toán
tỷ lệ sử dụng động cơ, trong khi drm-engine-<keystr> chỉ phản ánh
thời gian hoạt động mà không cần quan tâm đến tần số hoạt động của động cơ
phần trăm tần số cực đại của nó.

Trình điều khiển có thể triển khai khóa này hoặc drm-total-cycles-<keystr>, nhưng không
cả hai.

Ký ức
^^^^^^

Mỗi loại bộ nhớ có thể được GPU sử dụng để lưu trữ các đối tượng bộ đệm
được đề cập sẽ được cấp một tên ổn định và duy nhất để sử dụng làm "<khu vực>"
chuỗi.

Tên vùng "bộ nhớ" được dành riêng để chỉ bộ nhớ hệ thống thông thường.

Giá trị sẽ phản ánh dung lượng lưu trữ hiện được sử dụng bởi bộ đệm
các đối tượng thuộc về máy khách này, trong vùng bộ nhớ tương ứng.

Đơn vị mặc định phải là byte với các chỉ định đơn vị tùy chọn là 'KiB' hoặc 'MiB'
biểu thị kibi- hoặc mebi-byte.

- drm-total-<khu vực>: <uint> [KiB|MiB]

Tổng kích thước của tất cả các bộ đệm được yêu cầu, bao gồm cả bộ đệm dùng chung và riêng tư
trí nhớ. Kho lưu trữ hỗ trợ cho bộ đệm hiện không cần phải có
được khởi tạo để tính theo danh mục này. Để tránh việc đếm hai lần, nếu một bộ đệm
có nhiều vùng có thể được phân bổ, việc triển khai nên
luôn chọn một khu vực duy nhất cho mục đích kế toán.

- drm-shared-<khu vực>: <uint> [KiB|MiB]

Tổng kích thước của bộ đệm được chia sẻ với một tệp khác (nghĩa là có nhiều hơn
hơn một tay cầm). Yêu cầu tương tự để tránh tính hai lần áp dụng cho
drm-total-<khu vực> cũng được áp dụng ở đây.

- drm-cư dân-<khu vực>: <uint> [KiB|MiB]

Tổng kích thước của bộ đệm thường trú (tức là có kho lưu trữ dự phòng của chúng
hiện tại hoặc được khởi tạo) trong vùng được chỉ định.

- drm-memory-<khu vực>: <uint> [KiB|MiB]

Khóa này không được dùng nữa và chỉ được amdgpu in; nó là bí danh của
drm-cư dân-<khu vực>.

- drm-purgeable-<khu vực>: <uint> [KiB|MiB]

Tổng kích thước của bộ đệm thường trú và có thể xóa được.

Ví dụ: trình điều khiển triển khai chức năng tương tự như 'madvise' có thể được tính
bộ đệm có kho lưu trữ sao lưu được khởi tạo nhưng đã được đánh dấu bằng
tương đương với MADV_DONTNEED.

- drm-active-<khu vực>: <uint> [KiB|MiB]

Tổng kích thước của bộ đệm đang hoạt động trên một hoặc nhiều công cụ.

Một ví dụ thực tế về điều này có thể là sự hiện diện của hàng rào không có tín hiệu ở một khu vực
Đối tượng đặt trước bộ đệm GEM. Do đó, danh mục hoạt động là một tập hợp con của
hạng thường trú.

Chi tiết triển khai
======================

Trình điều khiển nên sử dụng drm_show_fdinfo() trong ZZ0000ZZ của họ và
triển khai &drm_driver.show_fdinfo nếu họ muốn cung cấp bất kỳ số liệu thống kê nào
không được cung cấp bởi drm_show_fdinfo().  Nhưng ngay cả số liệu thống kê cụ thể về trình điều khiển cũng nên
được ghi lại ở trên và nếu có thể, hãy căn chỉnh với các trình điều khiển khác.

Triển khai cụ thể của trình điều khiển
-------------------------------

* ZZ0000ZZ
* ZZ0001ZZ
* ZZ0002ZZ
* ZZ0003ZZ
