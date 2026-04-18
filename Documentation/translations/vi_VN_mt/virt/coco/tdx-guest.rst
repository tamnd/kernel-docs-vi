.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/virt/coco/tdx-guest.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

========================================================================
Tài liệu TDX Khách API
===================================================================

1. Mô tả chung
======================

Trình điều khiển khách TDX hiển thị các giao diện IOCTL thông qua /dev/tdx-guest misc
thiết bị để cho phép không gian người dùng nhận được một số thông tin chi tiết nhất định dành riêng cho khách của TDX.

2. Mô tả API
==================

Trong phần này, đối với mỗi IOCTL được hỗ trợ, thông tin sau đây là
được cung cấp cùng với mô tả chung.

:Tham số đầu vào: Tham số được truyền tới IOCTL và các chi tiết liên quan.
:Output: Chi tiết về dữ liệu đầu ra và giá trị trả về (với chi tiết về
         các giá trị lỗi không phổ biến).

2.1 TDX_CMD_GET_REPORT0
-----------------------

:Tham số đầu vào: struct tdx_report_req
:Đầu ra: Sau khi thực hiện thành công, dữ liệu TDREPORT sẽ được sao chép vào
         tdx_report_req.tdreport và trả về 0. Trả về -EINVAL cho trường hợp không hợp lệ
         toán hạng, -EIO trên TDCALL bị lỗi hoặc số lỗi tiêu chuẩn trên các máy khác
         những thất bại thông thường.

Phần mềm chứng thực có thể sử dụng TDX_CMD_GET_REPORT0 IOCTL để nhận
TDREPORT0 (còn gọi là TDREPORT subtype 0) từ mô-đun TDX sử dụng
TDCALL[TDG.MR.REPORT].

Một chỉ mục kiểu con được thêm vào cuối IOCTL CMD này để nhận dạng duy nhất
yêu cầu TDREPORT dành riêng cho từng loại phụ. Mặc dù tùy chọn loại phụ được đề cập trong
thông số kỹ thuật của Mô-đun TDX v1.0, phần có tiêu đề "TDG.MR.REPORT", nó không phải là
hiện đang được sử dụng và dự kiến giá trị này là 0. Vì vậy, để giữ IOCTL
triển khai đơn giản, tùy chọn loại phụ không được đưa vào như một phần của đầu vào
ABI. Tuy nhiên, trong tương lai, nếu Mô-đun TDX hỗ trợ nhiều loại phụ,
một IOCTL CMD mới sẽ được tạo để xử lý nó. Để giữ tên IOCTL
nhất quán, một chỉ mục kiểu con được thêm vào như một phần của IOCTL CMD.

Thẩm quyền giải quyết
---------

Tài liệu tham khảo TDX được thu thập tại đây:

ZZ0000ZZ

Trình điều khiển dựa trên thông số kỹ thuật mô-đun TDX v1.0 và thông số kỹ thuật TDX GHCI v1.0.