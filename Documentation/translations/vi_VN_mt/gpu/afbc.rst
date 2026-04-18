.. SPDX-License-Identifier: GPL-2.0+

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/gpu/afbc.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

======================================
 Nén bộ đệm khung cánh tay (AFBC)
===================================

AFBC là giao thức và định dạng nén ảnh không mất dữ liệu độc quyền.
Nó cung cấp quyền truy cập ngẫu nhiên chi tiết và giảm thiểu số lượng
dữ liệu được truyền giữa các khối IP.

AFBC có thể được kích hoạt trên các trình điều khiển hỗ trợ nó thông qua việc sử dụng AFBC
công cụ sửa đổi định dạng được xác định trong drm_fourcc.h. Xem DRM_FORMAT_MOD_ARM_AFBC(*).

Tất cả người dùng công cụ sửa đổi AFBC phải tuân theo các nguyên tắc sử dụng đã đặt ra
ra trong tài liệu này, để đảm bảo khả năng tương thích trên các AFBC khác nhau
người sản xuất và người tiêu dùng.

Thành phần và thứ tự
=======================

Các luồng AFBC có thể chứa một số thành phần - trong đó một thành phần
tương ứng với một kênh màu (tức là R, G, B, X, A, Y, Cb, Cr).
Việc gán các kênh màu đầu vào/đầu ra phải nhất quán
giữa bộ mã hóa và bộ giải mã để hoạt động chính xác, nếu không
người tiêu dùng sẽ giải thích dữ liệu được giải mã không chính xác.

Hơn nữa, khi sử dụng phép biến đổi không gian màu không mất dữ liệu
(AFBC_FORMAT_MOD_YTR, cần được bật cho bộ đệm RGB cho
hiệu suất nén tối đa), thứ tự thành phần phải là:

* Thành phần 0: R
 * Thành phần 1: G
 * Hợp phần 2: B

Thứ tự thành phần được truyền đạt thông qua mã bốncc trong
bốncc: cặp sửa đổi. Nói chung, thành phần '0' được coi là
nằm trong các bit có ý nghĩa nhỏ nhất của tuyến tính tương ứng
định dạng. Ví dụ: COMP(bit):

* DRM_FORMAT_ABGR8888

* Thành phần 0: R(8)
   * Thành phần 1: G(8)
   * Hợp phần 2: B(8)
   * Hợp phần 3: A(8)

* DRM_FORMAT_BGR888

* Thành phần 0: R(8)
   * Thành phần 1: G(8)
   * Hợp phần 2: B(8)

* DRM_FORMAT_YUYV

* Thành phần 0: Y(8)
   * Thành phần 1: Cb(8, 2x1 mẫu phụ)
   * Thành phần 2: Cr(8, 2x1 mẫu phụ)

Trong AFBC, các thành phần 'X' không được xử lý khác biệt với bất kỳ thành phần nào khác
thành phần. Do đó, bộ đệm AFBC với bốncc DRM_FORMAT_XBGR8888
mã hóa với 4 thành phần, như vậy:

* DRM_FORMAT_XBGR8888

* Thành phần 0: R(8)
   * Thành phần 1: G(8)
   * Hợp phần 2: B(8)
   * Thành phần 3: X(8)

Tuy nhiên, xin lưu ý rằng việc đưa vào kênh 'X' "lãng phí" là
không tốt cho hiệu quả nén và do đó nên tránh
định dạng chứa bit 'X'. Nếu thành phần thứ tư là
được yêu cầu/mong đợi bởi bộ mã hóa/bộ giải mã thì nên
thay vào đó hãy sử dụng định dạng tương đương với alpha, đặt tất cả các bit alpha thành
'1'. Nếu không có yêu cầu về thành phần thứ tư thì định dạng
không bao gồm alpha có thể được sử dụng, ví dụ: DRM_FORMAT_BGR888.

Số lượng máy bay
================

Các định dạng thường có nhiều mặt phẳng trong bố cục tuyến tính (ví dụ: YUV
420), có thể được mã hóa thành một hoặc nhiều mặt phẳng AFBC. Như với
thứ tự thành phần thì bộ mã hóa và bộ giải mã phải thống nhất về số lượng
của các mặt phẳng để giải mã chính xác bộ đệm. Mã bốncc là
được sử dụng để xác định số lượng mặt phẳng được mã hóa trong bộ đệm AFBC,
khớp với số lượng mặt phẳng cho định dạng tuyến tính (không sửa đổi).
Trong mỗi mặt phẳng, thứ tự thành phần cũng tuân theo bốncc
mã:

Ví dụ:

* DRM_FORMAT_YUYV: nplanes = 1

* Mặt phẳng 0:

* Thành phần 0: Y(8)
     * Thành phần 1: Cb(8, 2x1 mẫu phụ)
     * Thành phần 2: Cr(8, 2x1 mẫu phụ)

* DRM_FORMAT_NV12: nplanes = 2

* Mặt phẳng 0:

* Thành phần 0: Y(8)

* Mặt phẳng 1:

* Thành phần 0: Cb(8, 2x1 mẫu phụ)
     * Thành phần 1: Cr(8, 2x1 mẫu phụ)

Khả năng tương tác đa thiết bị
=============================

Để có khả năng tương thích tối đa trên các thiết bị, bảng bên dưới xác định
định dạng chuẩn để sử dụng giữa các thiết bị hỗ trợ AFBC. Các định dạng mà
được liệt kê ở đây phải được sử dụng chính xác như được chỉ định khi sử dụng AFBC
sửa đổi. Nên tránh các định dạng không được liệt kê.

.. flat-table:: AFBC formats

   * - Fourcc code
     - Description
     - Planes/Components

   * - DRM_FORMAT_ABGR2101010
     - 10-bit per component RGB, with 2-bit alpha
     - Plane 0: 4 components
              * Component 0: R(10)
              * Component 1: G(10)
              * Component 2: B(10)
              * Component 3: A(2)

   * - DRM_FORMAT_ABGR8888
     - 8-bit per component RGB, with 8-bit alpha
     - Plane 0: 4 components
              * Component 0: R(8)
              * Component 1: G(8)
              * Component 2: B(8)
              * Component 3: A(8)

   * - DRM_FORMAT_BGR888
     - 8-bit per component RGB
     - Plane 0: 3 components
              * Component 0: R(8)
              * Component 1: G(8)
              * Component 2: B(8)

   * - DRM_FORMAT_BGR565
     - 5/6-bit per component RGB
     - Plane 0: 3 components
              * Component 0: R(5)
              * Component 1: G(6)
              * Component 2: B(5)

   * - DRM_FORMAT_ABGR1555
     - 5-bit per component RGB, with 1-bit alpha
     - Plane 0: 4 components
              * Component 0: R(5)
              * Component 1: G(5)
              * Component 2: B(5)
              * Component 3: A(1)

   * - DRM_FORMAT_VUY888
     - 8-bit per component YCbCr 444, single plane
     - Plane 0: 3 components
              * Component 0: Y(8)
              * Component 1: Cb(8)
              * Component 2: Cr(8)

   * - DRM_FORMAT_VUY101010
     - 10-bit per component YCbCr 444, single plane
     - Plane 0: 3 components
              * Component 0: Y(10)
              * Component 1: Cb(10)
              * Component 2: Cr(10)

   * - DRM_FORMAT_YUYV
     - 8-bit per component YCbCr 422, single plane
     - Plane 0: 3 components
              * Component 0: Y(8)
              * Component 1: Cb(8, 2x1 subsampled)
              * Component 2: Cr(8, 2x1 subsampled)

   * - DRM_FORMAT_NV16
     - 8-bit per component YCbCr 422, two plane
     - Plane 0: 1 component
              * Component 0: Y(8)
       Plane 1: 2 components
              * Component 0: Cb(8, 2x1 subsampled)
              * Component 1: Cr(8, 2x1 subsampled)

   * - DRM_FORMAT_Y210
     - 10-bit per component YCbCr 422, single plane
     - Plane 0: 3 components
              * Component 0: Y(10)
              * Component 1: Cb(10, 2x1 subsampled)
              * Component 2: Cr(10, 2x1 subsampled)

   * - DRM_FORMAT_P210
     - 10-bit per component YCbCr 422, two plane
     - Plane 0: 1 component
              * Component 0: Y(10)
       Plane 1: 2 components
              * Component 0: Cb(10, 2x1 subsampled)
              * Component 1: Cr(10, 2x1 subsampled)

   * - DRM_FORMAT_YUV420_8BIT
     - 8-bit per component YCbCr 420, single plane
     - Plane 0: 3 components
              * Component 0: Y(8)
              * Component 1: Cb(8, 2x2 subsampled)
              * Component 2: Cr(8, 2x2 subsampled)

   * - DRM_FORMAT_YUV420_10BIT
     - 10-bit per component YCbCr 420, single plane
     - Plane 0: 3 components
              * Component 0: Y(10)
              * Component 1: Cb(10, 2x2 subsampled)
              * Component 2: Cr(10, 2x2 subsampled)

   * - DRM_FORMAT_NV12
     - 8-bit per component YCbCr 420, two plane
     - Plane 0: 1 component
              * Component 0: Y(8)
       Plane 1: 2 components
              * Component 0: Cb(8, 2x2 subsampled)
              * Component 1: Cr(8, 2x2 subsampled)

   * - DRM_FORMAT_P010
     - 10-bit per component YCbCr 420, two plane
     - Plane 0: 1 component
              * Component 0: Y(10)
       Plane 1: 2 components
              * Component 0: Cb(10, 2x2 subsampled)
              * Component 1: Cr(10, 2x2 subsampled)