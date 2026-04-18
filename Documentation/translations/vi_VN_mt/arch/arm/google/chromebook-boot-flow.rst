.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/arch/arm/google/chromebook-boot-flow.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=========================================
Luồng khởi động Chromebook
=========================================

Hầu hết các Chromebook gần đây sử dụng cây thiết bị đều đang sử dụng mã nguồn mở
bộ nạp khởi động deepcharge_. Depthcharge_ dự kiến ​​HĐH sẽ được đóng gói dưới dạng ZZ0000ZZ chứa hình ảnh HĐH cũng như bộ sưu tập cây thiết bị. Nó
tùy thuộc vào độ sâu_ để chọn cây thiết bị phù hợp từ ZZ0001ZZ và
cung cấp nó cho hệ điều hành.

Sơ đồ mà deepcharge_ sử dụng để chọn cây thiết bị sẽ tính đến
ba biến:

- Tên bảng, được chỉ định tại thời điểm biên dịch deepcharge_. Đây là $(BOARD) bên dưới.
- Số sửa đổi bảng, được xác định khi chạy (có thể bằng cách đọc GPIO
  dây đai, có thể thông qua một số phương pháp khác). Đây là $(REV) bên dưới.
- Số SKU, đọc từ dây đai GPIO khi khởi động. Đây là $(SKU) bên dưới.

Đối với các Chromebook gần đây, deepcharge_ tạo một danh sách phù hợp trông như thế này:

- google,$(BOARD)-rev$(REV)-sku$(SKU)
- google,$(BOARD)-rev$(REV)
- google,$(BOARD)-sku$(SKU)
- google,$(BOARD)

Lưu ý rằng một số Chromebook cũ hơn sử dụng danh sách hơi khác một chút có thể
không bao gồm kết hợp SKU hoặc có thể ưu tiên SKU/vòng quay khác nhau.

Lưu ý rằng đối với một số bảng, có thể có thêm logic dành riêng cho bảng để đưa vào.
tương thích bổ sung vào danh sách, nhưng điều này không phổ biến.

Depthcharge_ sẽ xem qua tất cả các cây thiết bị trong ZZ0000ZZ đang cố gắng
tìm một cái phù hợp với sự tương thích cụ thể nhất. Sau đó nó sẽ nhìn
thông qua tất cả các cây thiết bị trong ZZ0001ZZ để cố gắng tìm ra cây
phù hợp với ZZ0002ZZ tương thích cụ thể, v.v.

Khi tìm kiếm cây thiết bị, deepcharge_ không quan tâm vị trí của
chuỗi tương thích nằm trong mảng chuỗi tương thích gốc của cây thiết bị.
Ví dụ: nếu chúng ta đang sử dụng "lazor", rev 4, SKU 0 và chúng ta có hai thiết bị
cây cối:

- "google,lazor-rev5-sku0", "google,lazor-rev4-sku0", "qcom,sc7180"
- "google,lazor", "qcom,sc7180"

Sau đó, deepcharge_ sẽ chọn cây thiết bị đầu tiên mặc dù
"google,lazor-rev4-sku0" là thiết bị tương thích thứ hai được liệt kê trong cây thiết bị đó.
Điều này là do nó tương thích cụ thể hơn "google,lazor".

Cần lưu ý rằng deepcharge_ không có bất kỳ tính năng thông minh nào để thử
bảng diêm hoặc các bản sửa đổi SKU đang "gần kề". Tức là nói rằng
nếu deepcharge_ biết nó ở "rev4" của bảng nhưng không có "rev4"
cây thiết bị thì deepcharge_ ZZ0000ZZ tìm cây thiết bị "rev3".

Nói chung khi có bất kỳ thay đổi đáng kể nào được thực hiện đối với một bảng
số sửa đổi được tăng lên ngay cả khi không có thay đổi nào cần
được phản ánh trong cây thiết bị. Vì vậy, khá phổ biến khi thấy thiết bị
cây có nhiều phiên bản.

Cần lưu ý rằng, có tính đến hệ thống trên
deepcharge_ có, độ linh hoạt cao nhất sẽ đạt được nếu cây thiết bị
hỗ trợ (các) bản sửa đổi mới nhất của bảng bỏ qua "-rev{REV}"
các chuỗi tương thích. Khi việc này hoàn tất thì nếu bạn có một bảng mới
sửa đổi và thử chạy phần mềm cũ trên đó, sau đó chúng tôi sẽ chọn
cây thiết bị mới nhất mà chúng tôi biết.

.. _depthcharge: https://source.chromium.org/chromiumos/chromiumos/codesearch/+/main:src/platform/depthcharge/
.. _`FIT Image`: https://doc.coreboot.org/lib/payloads/fit.html