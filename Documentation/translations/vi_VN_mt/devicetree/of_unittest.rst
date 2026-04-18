.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/devicetree/of_unittest.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

====================================
Mở Firmware Devicetree Unittest
====================================

Tác giả: Gaurav Minocha <gaurav.minocha.os@gmail.com>

1. Giới thiệu
===============

Tài liệu này giải thích cách dữ liệu thử nghiệm cần thiết để thực hiện OF unittest
được gắn vào cây sống một cách linh hoạt, độc lập với hoạt động của máy.
kiến trúc.

Bạn nên đọc các tài liệu sau trước khi tiếp tục.

(1) Tài liệu/devicetree/usage-model.rst
(2) ZZ0000ZZ

OF Selftest được thiết kế để kiểm tra giao diện (include/linux/of.h)
được cung cấp cho các nhà phát triển trình điều khiển thiết bị để lấy thông tin thiết bị..v.v.
từ cấu trúc dữ liệu cây thiết bị chưa được làm phẳng. Giao diện này được sử dụng bởi
hầu hết các trình điều khiển thiết bị trong các trường hợp sử dụng khác nhau.


2. Đầu ra dài dòng (EXPECT)
===========================

Nếu unittest phát hiện vấn đề, nó sẽ in cảnh báo hoặc thông báo lỗi tới
bảng điều khiển.  Unittest cũng kích hoạt các thông báo cảnh báo và lỗi từ các
mã hạt nhân do cố tình làm xấu dữ liệu unittest.  Điều này đã dẫn
gây nhầm lẫn về việc liệu các thông báo được kích hoạt có phải là kết quả mong đợi hay không
của một bài kiểm tra hoặc liệu có một vấn đề thực sự độc lập với unittest hay không.

Các thông báo 'EXPECT \ : text' (bắt đầu) và 'EXPECT / : text' (kết thúc) đã được
được thêm vào unittest để báo cáo rằng có thể xảy ra cảnh báo hoặc lỗi.  các
phần bắt đầu được in trước khi kích hoạt cảnh báo hoặc lỗi và phần cuối được in
được in sau khi kích hoạt cảnh báo hoặc lỗi.

Thông báo EXPECT dẫn đến thông báo trên bảng điều khiển rất ồn ào, khó thực hiện
để đọc.  Tập lệnh scripts/dtc/of_unittest_expect đã được tạo để lọc
tính chi tiết này và làm nổi bật sự không khớp giữa các cảnh báo được kích hoạt và
lỗi so với cảnh báo và lỗi dự kiến.  Thêm thông tin có sẵn
từ 'scripts/dtc/of_unittest_expect --help'.


3. Dữ liệu thử nghiệm
=====================

Tệp Nguồn cây thiết bị (drivers/of/unittest-data/testcases.dtso) chứa
dữ liệu kiểm tra cần thiết để thực hiện các bài kiểm tra đơn vị tự động trong
trình điều khiển/của/unittest.c. Xem nội dung của thư mục::

trình điều khiển/of/unittest-data/tests-*.dtsi

đối với các tệp Bao gồm nguồn cây thiết bị (.dtsi) có trong testcase.dtso.

Khi kernel được xây dựng với CONFIG_OF_UNITTEST được kích hoạt, thì cách thực hiện sau đây
quy tắc::

$(obj)/%.dtbo: $(src)/%.dtso $(DTC) FORCE
	    $(gọi if_changed_dep,dtc)

được sử dụng để biên dịch tệp nguồn DT (testcases.dtso) thành blob nhị phân
(testcases.dtbo), còn được gọi là DT phẳng.

Sau đó, bằng cách sử dụng quy tắc sau, đốm màu nhị phân ở trên được bao bọc dưới dạng
tập tin lắp ráp (testcase.dtbo.S)::

$(obj)/%.dtbo.S: $(obj)/%.dtbo FORCE
	    $(gọi if_changed,wrap_S_dtb)

Tệp hợp ngữ được biên dịch thành tệp đối tượng (testcases.dtbo.o) và được
liên kết vào hình ảnh hạt nhân.


3.1. Thêm dữ liệu thử nghiệm
----------------------------

Cấu trúc cây thiết bị không phẳng:

Cây thiết bị chưa được làm phẳng bao gồm (các) thiết bị được kết nối dưới dạng cây
cấu trúc được mô tả dưới đây::

// các thành viên struct sau đây được sử dụng để xây dựng cây
    cấu trúc device_node {
	...
struct device_node *parent;
	struct device_node *con;
	struct device_node *anh chị em;
	...
    };

Hình 1, mô tả cấu trúc chung của cây thiết bị không phẳng của máy
chỉ xem xét các con trỏ con và anh chị em. Tồn tại một con trỏ khác,
ZZ0000ZZ, được sử dụng để duyệt cây theo hướng ngược lại. Vì vậy, tại
một cấp độ cụ thể, nút con và tất cả các nút anh em sẽ có nút cha
con trỏ trỏ đến một nút chung (ví dụ: child1, anh chị em2, anh chị em3, anh chị em4
cha trỏ đến nút gốc)::

gốc ('/')
    |
    child1 -> sibling2 -> sibling3 -> sibling4 -> null
    ZZ0000ZZ ZZ0001ZZ
    ZZ0002ZZ |          vô giá trị
    ZZ0003ZZ |
    ZZ0004ZZ con31 -> anh chị em32 -> null
    ZZ0005ZZ ZZ0006ZZ
    ZZ0007ZZ null null
    ZZ0008ZZ
    |      con21 -> anh chị em22 -> anh chị em23 -> null
    ZZ0009ZZ ZZ0010ZZ
    |        vô giá trị vô giá trị
    |
    con11 -> anh chị em12 -> anh chị em13 -> anh chị em14 -> null
    ZZ0011ZZ ZZ0012ZZ
    ZZ0013ZZ |           vô giá trị
    ZZ0014ZZ |
    null null child131 -> null
			    |
			    vô giá trị

Hình 1: Cấu trúc chung của cây thiết bị không phẳng


Trước khi thực hiện OF unittest, cần phải đính kèm dữ liệu thử nghiệm vào
cây thiết bị của máy (nếu có). Vì vậy, khi selftest_data_add() được gọi,
đầu tiên nó đọc dữ liệu cây thiết bị dẹt được liên kết vào ảnh hạt nhân
thông qua các ký hiệu kernel sau::

__dtb_testcases_begin - địa chỉ đánh dấu sự bắt đầu của blob dữ liệu thử nghiệm
    __dtb_testcases_end - địa chỉ đánh dấu sự kết thúc của blob dữ liệu thử nghiệm

Thứ hai, nó gọi of_fdt_unflatten_tree() để làm phẳng phần bị làm phẳng
đốm màu. Và cuối cùng, nếu có cây thiết bị của máy (tức là cây sống),
sau đó nó gắn cây dữ liệu thử nghiệm chưa được làm phẳng vào cây sống, nếu không thì nó
tự gắn vào như một cây thiết bị sống.

Attach_node_and_children() sử dụng of_attach_node() để gắn các nút vào
cây sống như được giải thích dưới đây. Để giải thích tương tự, cây dữ liệu thử nghiệm được mô tả
trong Hình 2 được gắn vào cây sống được mô tả trong Hình 1::

gốc ('/')
	|
    dữ liệu testcase
	|
    test-child0 -> test-sibling1 -> test-sibling2 -> test-sibling3 -> null
	ZZ0000ZZ ZZ0001ZZ
    test-child01 null null null


Hình 2: Ví dụ về cây dữ liệu thử nghiệm được gắn vào cây đang hoạt động.

Theo kịch bản trên, cây sống đã có sẵn nên không
cần thiết để đính kèm nút gốc ('/'). Tất cả các nút khác được đính kèm bằng cách gọi
of_attach_node() trên mỗi nút.

Trong hàm_attach_node(), nút mới được đính kèm dưới dạng nút con của
bố mẹ được trao trong cây sống. Tuy nhiên, nếu cha mẹ đã có con thì nút mới
thay thế đứa trẻ hiện tại và biến nó thành anh chị em của nó. Vì vậy, khi trường hợp thử nghiệm
nút dữ liệu được gắn vào cây trực tiếp ở trên (Hình 1), cấu trúc cuối cùng là
như trong Hình 3::

gốc ('/')
    |
    dữ liệu testcase -> child1 -> anh chị em2 -> anh chị em3 -> anh chị em4 -> null
    ZZ0000ZZ ZZ0001ZZ |
    (...) ZZ0002ZZ |          vô giá trị
		    ZZ0003ZZ con31 -> anh chị em32 -> null
		    ZZ0004ZZ ZZ0005ZZ
		    ZZ0006ZZ null null
		    ZZ0007ZZ
		    |        con21 -> anh chị em22 -> anh chị em23 -> null
		    ZZ0008ZZ ZZ0009ZZ
		    |         vô giá trị vô giá trị
		    |
		    con11 -> anh chị em12 -> anh chị em13 -> anh chị em14 -> null
		    ZZ0010ZZ ZZ0011ZZ
		    không có giá trị |           vô giá trị
					    |
					    con131 -> null
					    |
					    vô giá trị
    -----------------------------------------------------------------------

gốc ('/')
    |
    dữ liệu testcase -> child1 -> anh chị em2 -> anh chị em3 -> anh chị em4 -> null
    ZZ0000ZZ ZZ0001ZZ |
    |             (...) (...) (...) vô giá trị
    |
    test-sibling3 -> test-sibling2 -> test-sibling1 -> test-child0 -> null
    ZZ0002ZZ ZZ0003ZZ
    null null null test-child01


Hình 3: Cấu trúc cây thiết bị trực tiếp sau khi đính kèm dữ liệu testcase.


Những độc giả thông minh sẽ nhận thấy rằng nút test-child0 trở thành nút cuối cùng
anh chị em so với cấu trúc trước đó (Hình 2). Sau khi gắn đầu tiên
test-child0 test-sibling1 được đính kèm để đẩy nút con
(tức là test-child0) trở thành anh chị em và tự biến mình thành nút con,
như đã đề cập ở trên.

Nếu tìm thấy một nút trùng lặp (tức là nếu một nút có cùng thuộc tính full_name được tìm thấy
đã có trong cây trực tiếp), thì nút đó không được gắn vào thay vào đó
các thuộc tính được cập nhật vào nút của cây trực tiếp bằng cách gọi hàm
update_node_properties().


3.2. Xóa dữ liệu thử nghiệm
---------------------------

Khi quá trình thực hiện trường hợp kiểm thử hoàn tất, selftest_data_remove sẽ được gọi vào
để loại bỏ các nút thiết bị được gắn ban đầu (đầu tiên các nút lá được
được tách ra và sau đó di chuyển lên trên, các nút cha sẽ bị loại bỏ và cuối cùng
cả cây). selftest_data_remove() gọi tách_node_and_children() sử dụng
of_detach_node() để tách các nút khỏi cây thiết bị trực tiếp.

Để tách một nút, of_detach_node() hoặc cập nhật con trỏ con của nút đã cho
nút cha của nút đó với nút anh chị em của nó hoặc gắn nút anh chị em trước đó với nút đã cho
anh chị em của nút, nếu thích hợp. Thế đấy :)