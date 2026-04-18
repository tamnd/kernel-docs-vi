.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/driver-api/generic_pt.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

===========================
Bảng trang cơ số chung
===========================

.. kernel-doc:: include/linux/generic_pt/common.h
	:doc: Generic Radix Page Table

.. kernel-doc:: drivers/iommu/generic_pt/pt_defs.h
	:doc: Generic Page Table Language

Cách sử dụng
=====

PT chung được cấu trúc như một hệ thống đa biên dịch. Vì mỗi định dạng
cung cấp API bằng cách sử dụng một nhóm tên chung, chỉ có thể có một định dạng hoạt động
trong một đơn vị biên dịch. Thiết kế này tránh các con trỏ hàm xung quanh mức thấp
cấp độ API.

Thay vào đó, con trỏ hàm có thể kết thúc ở mức API cao hơn (tức là
map/unmap, v.v.) và mã theo định dạng có thể được nội tuyến trực tiếp vào
đơn vị biên dịch theo định dạng. Đối với những thứ như IOMMU, mỗi định dạng sẽ là
được biên dịch thành mô-đun hạt nhân hoạt động IOMMU theo định dạng.

Để làm việc này, tệp .c cho mỗi đơn vị biên dịch sẽ bao gồm cả
tiêu đề định dạng và mã chung để triển khai. Ví dụ như trong một
đơn vị biên dịch triển khai, các tiêu đề thường được bao gồm dưới dạng
sau:

generic_pt/fmt/iommu_amdv1.c::

#include <linux/generic_pt/common.h>
	#include "defs_amdv1.h"
	#include "../pt_defs.h"
	#include "amdv1.h"
	#include "../pt_common.h"
	#include "../pt_iter.h"
	#include "../iommu_pt.h" /* Triển khai IOMMU */

iommu_pt.h bao gồm các định nghĩa sẽ tạo ra các hàm hoạt động cho
bản đồ/unmap/v.v. sử dụng các định nghĩa do AMDv1 cung cấp. Mô-đun kết quả
sẽ có các biểu tượng được xuất có tên như pt_iommu_amdv1_init().

Tham khảo driver/iommu/generic_pt/fmt/iommu_template.h để biết ví dụ về cách
Việc triển khai IOMMU sử dụng tính năng biên dịch đa dạng để tạo các cấu trúc hoạt động theo định dạng
con trỏ.

Mã định dạng được viết sao cho các tên phổ biến phát sinh từ #defines đến
tên cụ thể định dạng riêng biệt. Điều này nhằm mục đích hỗ trợ khả năng gỡ lỗi bằng cách
tránh xung đột biểu tượng trên tất cả các định dạng khác nhau.

Các ký hiệu đã xuất và các tên chung khác được đọc sai bằng chuỗi theo định dạng
thông qua macro trợ giúp NS().

Định dạng này sử dụng struct pt_common làm cấu trúc cấp cao nhất cho bảng,
và mỗi định dạng sẽ có cấu trúc pt_xxx riêng để nhúng nó vào lưu trữ
thông tin có định dạng cụ thể.

Việc triển khai sẽ tiếp tục bao bọc struct pt_common ở cấp cao nhất của chính nó
cấu trúc, chẳng hạn như cấu trúc pt_iommu_amdv1.

Định dạng hàm ở cấp độ cấu trúc pt_common
----------------------------------------------

.. kernel-doc:: include/linux/generic_pt/common.h
	:identifiers:
.. kernel-doc:: drivers/iommu/generic_pt/pt_common.h

Người trợ giúp lặp lại
-----------------

.. kernel-doc:: drivers/iommu/generic_pt/pt_iter.h

Viết một định dạng
----------------

Tốt nhất là bắt đầu từ một định dạng đơn giản tương tự như mục tiêu. x86_64
thường là một tài liệu tham khảo tốt cho một cái gì đó đơn giản và AMDv1 là một cái gì đó khá
hoàn thành.

Các hàm nội tuyến cần thiết cần được triển khai trong tiêu đề định dạng.
Tất cả những điều này phải tuân theo mẫu tiêu chuẩn của ::

nội tuyến tĩnh pt_oaddr_t amdv1pt_entry_oa(const struct pt_state *pts)
 {
	[..]
 }
 #define pt_entry_oa amdv1pt_entry_oa

trong đó hàm nội tuyến cho mỗi định dạng được đặt tên duy nhất cung cấp việc triển khai
và một định nghĩa ánh xạ nó tới tên chung. Điều này nhằm mục đích tạo các biểu tượng gỡ lỗi
làm việc tốt hơn. các hàm nội tuyến phải luôn được sử dụng làm nguyên mẫu trong
pt_common.h sẽ khiến trình biên dịch xác thực chữ ký hàm để
ngăn ngừa sai sót.

Xem lại pt_fmt_defaults.h để hiểu một số dòng nội tuyến tùy chọn.

Khi định dạng được biên dịch thì nó sẽ được chạy qua bảng trang chung
kiểm tra kunit trong kunit_generic_pt.h bằng kunit. Ví dụ::

$ tools/testing/kunit/kunit.py run --build_dir build_kunit_x86_64 --arch x86_64 --kunitconfig ./drivers/iommu/generic_pt/.kunitconfig amdv1_fmt_test.*
   […]
   [11:15:08] Quá trình kiểm tra đã hoàn tất. Đã thực hiện 9 bài kiểm tra: đạt: 9
   [11:15:09] Thời gian đã trôi qua: tổng cộng 3,137 giây, cấu hình 0,001 giây, xây dựng 2,368 giây, chạy 0,311 giây

Các bài kiểm tra chung nhằm mục đích chứng minh các chức năng định dạng và đưa ra
những thất bại rõ ràng hơn để tăng tốc độ tìm ra vấn đề. Một khi những điều đó trôi qua thì
toàn bộ bộ kunit nên được chạy.

Tính năng vô hiệu hóa IOMMU
---------------------------

Sự vô hiệu là cách các thuật toán bảng trang đồng bộ hóa với bộ đệm CTNH của
bộ nhớ bảng trang, thường được gọi là TLB (hoặc IOTLB cho các trường hợp IOMMU).

TLB có thể lưu trữ các PTE hiện tại, các PTE không hiện diện và các con trỏ bảng, tùy thuộc vào
trên thiết kế của nó. Mỗi CTNH có cách tiếp cận riêng về cách mô tả những gì đã thay đổi
đã xóa các mục đã thay đổi khỏi TLB.

PT_FEAT_FLUSH_RANGE
~~~~~~~~~~~~~~~~~~~

PT_FEAT_FLUSH_RANGE là sơ đồ dễ hiểu nhất. Nó cố gắng tạo ra một
vô hiệu hóa phạm vi đơn cho mỗi thao tác, vô hiệu hóa quá mức nếu có
những khoảng trống của VA không cần vô hiệu. Điều này đánh đổi VA bị ảnh hưởng để lấy số
của các hoạt động vô hiệu. Nó không theo dõi những gì đang bị vô hiệu;
tuy nhiên, nếu các trang phải được giải phóng thì các con trỏ bảng trang phải được làm sạch
từ bộ đệm đi bộ. Phạm vi có thể bắt đầu/kết thúc ở bất kỳ ranh giới trang nào.

PT_FEAT_FLUSH_RANGE_NO_GAPS
~~~~~~~~~~~~~~~~~~~~~~~~~~~

PT_FEAT_FLUSH_RANGE_NO_GAPS tương tự như PT_FEAT_FLUSH_RANGE; tuy nhiên, nó cố gắng
để giảm thiểu lượng VA bị ảnh hưởng bằng cách thực hiện thêm các hoạt động xả. Đây là
hữu ích nếu chi phí xử lý VA rất cao, chẳng hạn vì một
trình ảo hóa đang xử lý bảng trang bằng thuật toán tạo bóng.