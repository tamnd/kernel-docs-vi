.. SPDX-License-Identifier: GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/v4l/dev-mem2mem.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. c:namespace:: V4L

.. _mem2mem:

*********************************
Giao diện bộ nhớ video với bộ nhớ
*********************************

Thiết bị chuyển đổi bộ nhớ sang bộ nhớ V4L2 có thể nén, giải nén, chuyển đổi hoặc
nếu không thì chuyển đổi dữ liệu video từ định dạng này sang định dạng khác trong bộ nhớ.
Các thiết bị chuyển bộ nhớ này sang bộ nhớ khác đặt ZZ0000ZZ hoặc
Khả năng ZZ0001ZZ. Ví dụ về bộ nhớ đến bộ nhớ
các thiết bị là codec, bộ chia tỷ lệ, bộ khử xen kẽ hoặc bộ chuyển đổi định dạng (tức là
chuyển đổi từ YUV sang RGB).

Nút video từ bộ nhớ tới bộ nhớ hoạt động giống như nút video bình thường, nhưng nó
hỗ trợ cả đầu ra (gửi khung từ bộ nhớ đến phần cứng)
và chụp (nhận các khung đã xử lý từ phần cứng vào
bộ nhớ) luồng I/O. Một ứng dụng sẽ phải thiết lập luồng I/O cho
cả hai bên và cuối cùng gọi ZZ0000ZZ
cho cả chụp và xuất để khởi động phần cứng.

Các thiết bị bộ nhớ nối với bộ nhớ hoạt động như một tài nguyên được chia sẻ: bạn có thể
mở nút video nhiều lần, mỗi ứng dụng sẽ thiết lập
các thuộc tính riêng cục bộ của phần xử lý tệp và mỗi thuộc tính có thể sử dụng
nó độc lập với những cái khác. Người lái xe sẽ phân xử quyền truy cập vào
phần cứng và lập trình lại nó bất cứ khi nào một trình xử lý tệp khác có quyền truy cập.
Điều này khác với hoạt động của nút video thông thường trong đó video
các thuộc tính mang tính toàn cục đối với thiết bị (tức là thay đổi thứ gì đó thông qua một
trình xử lý tệp được hiển thị thông qua một trình xử lý tệp khác).

Một trong những thiết bị chuyển bộ nhớ sang bộ nhớ phổ biến nhất là codec. Codec
phức tạp hơn hầu hết và yêu cầu thiết lập bổ sung cho
thông số codec của họ. Điều này được thực hiện thông qua điều khiển codec.
Xem ZZ0000ZZ. Thêm chi tiết về cách sử dụng codec bộ nhớ-to-bộ nhớ
các thiết bị được đưa ra trong các phần sau.

.. toctree::
    :maxdepth: 1

    dev-decoder
    dev-encoder
    dev-stateless-decoder