.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/admin-guide/perf/arm-cmn.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

================================
Mạng lưới kết hợp cánh tay PMU
================================

CMN-600 là kết nối lưới có thể định cấu hình bao gồm một hình chữ nhật
lưới các điểm giao nhau (XP), với mỗi điểm giao nhau hỗ trợ tối đa hai
các cổng thiết bị mà các tác nhân AMBA CHI khác nhau được gắn vào.

CMN triển khai thiết kế PMU phân tán như một phần của quá trình gỡ lỗi và theo dõi
chức năng. Điều này bao gồm một màn hình cục bộ (DTM) ở mọi XP,
đếm tối đa 4 tín hiệu sự kiện từ các nút thiết bị được kết nối và/hoặc
Bản thân XP. Tràn từ các bộ đếm cục bộ này được tích lũy lên tới 8
bộ đếm toàn cầu được thực hiện bởi bộ điều khiển chính (DTC), cung cấp
điều khiển tổng thể PMU và ngắt khi tràn bộ đếm toàn cầu.

Sự kiện PMU
-----------

Trình điều khiển PMU đăng ký một thiết bị PMU duy nhất cho toàn bộ kết nối,
xem /sys/bus/event_source/devices/arm_cmn_0. Hệ thống nhiều chip có thể liên kết
nhiều hơn một CMN cùng nhau thông qua các liên kết CCIX bên ngoài - trong tình huống này,
mỗi lưới đếm các sự kiện riêng của nó hoàn toàn độc lập và bổ sung
Các thiết bị PMU sẽ được đặt tên là arm_cmn_{1..n}.

Hầu hết các sự kiện được chỉ định theo định dạng dựa trực tiếp trên TRM
định nghĩa - "type" chọn loại nút tương ứng và "eventid"
số sự kiện. Một số sự kiện yêu cầu ID sức chứa bổ sung, đó là
được chỉ định bởi "chiếm".

* Vì các nút RN-D không có bất kỳ sự kiện riêng biệt nào với các nút RN-I nên chúng
  được coi là cùng loại (0xa) và các mẫu sự kiện chung là
  có tên là "rnid_*".

* Bộ đếm chu kỳ được coi là sự kiện tổng hợp thuộc về DTC
  nút ("loại" == 0x3, "eventid" bị bỏ qua).

* Sự kiện XP cũng mã hóa cổng và kênh trong trường "eventid" để
  khớp với mã hóa pmu_event0_id cơ bản cho pmu_event_sel
  đăng ký. Các mẫu sự kiện được đặt tên bằng tiền tố để bao gồm tất cả
  hoán vị.

Theo mặc định, mỗi sự kiện cung cấp số lượng tổng hợp trên tất cả các nút của
loại đã cho. Để nhắm mục tiêu một nút cụ thể, "bynodeid" phải được đặt thành 1 và
"nodeid" thành giá trị thích hợp bắt nguồn từ cấu hình CMN
(như được xác định trong phần "Ánh xạ ID nút" của TRM).

Điểm quan sát
-------------

PMU cũng có thể đếm các sự kiện theo dõi để theo dõi chuyến bay cụ thể
giao thông. Điểm quan sát được coi là loại sự kiện tổng hợp và giống như PMU
các sự kiện có thể mang tính toàn cầu hoặc được nhắm mục tiêu với giá trị "nodeid" của XP cụ thể.
Vì hướng của điểm quan sát được ngầm định trong cơ bản
lựa chọn đăng ký, các sự kiện riêng biệt được cung cấp cho việc tải lên và
lượt tải xuống.

Giá trị và mặt nạ khớp flit được chuyển vào config1 và config2 ("val"
và "mặt nạ" tương ứng). "wp_dev_sel", "wp_chn_sel", "wp_grp" và
"wp_exclusive" được chỉ định theo định nghĩa TRM cho dtm_wp_config0.
Trường hợp điểm quan sát cần khớp các trường từ cả hai nhóm đối sánh trên
Kênh REQ hoặc SNP, nó có thể được chỉ định thành hai sự kiện - một cho mỗi sự kiện
nhóm - có cùng giá trị "kết hợp" khác 0. Số lượng cho một như vậy
cặp sự kiện kết hợp sẽ được tính cho trận đấu chính.
Các sự kiện điểm quan sát có giá trị "kết hợp" bằng 0 được coi là độc lập
và sẽ được tính riêng lẻ.
