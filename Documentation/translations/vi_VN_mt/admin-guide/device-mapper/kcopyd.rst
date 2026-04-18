.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/admin-guide/device-mapper/kcopyd.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=============
được sao chép
=============

Kcopyd cung cấp khả năng sao chép một loạt các lĩnh vực từ một thiết bị khối
tới một hoặc nhiều thiết bị khối khác, với quá trình hoàn thành không đồng bộ
thông báo. Nó được sử dụng bởi dm-snapshot và dm-mirror.

Người dùng kcopyd trước tiên phải tạo một ứng dụng khách và cho biết có bao nhiêu trang bộ nhớ
để dành cho công việc sao chép của họ. Điều này được thực hiện bằng cách gọi tới
kcopyd_client_create()::

int kcopyd_client_create(unsigned int num_pages,
                            struct kcopyd_client **kết quả);

Để bắt đầu công việc sao chép, người dùng phải thiết lập cấu trúc io_zone để mô tả
nguồn và đích của bản sao. Mỗi io_khu vực biểu thị một
block-device cùng với khu vực bắt đầu và kích thước của khu vực. nguồn
của bản sao được đưa ra dưới dạng một cấu trúc io_zone và đích đến của
bản sao được đưa ra dưới dạng một mảng cấu trúc io_khu vực ::

cấu trúc io_khu vực {
      struct block_device *bdev;
      ngành_t ngành;
      số lượng ngành_t;
   };

Để bắt đầu sao chép, người dùng gọi kcopyd_copy(), chuyển vào ứng dụng khách
con trỏ, con trỏ tới io_khu vực nguồn và đích, tên của một
thói quen gọi lại hoàn thành và một con trỏ tới một số dữ liệu ngữ cảnh cho bản sao ::

int kcopyd_copy(struct kcopyd_client *kc, struct io_region *from,
                   unsigned int num_dests, struct io_khu vực *đích,
                   cờ int không dấu, kcopyd_notify_fn fn, void *bối cảnh);

typedef void (*kcopyd_notify_fn)(int read_err, unsigned int write_err,
				    void *bối cảnh);

Khi bản sao hoàn tất, kcopyd sẽ gọi quy trình hoàn thành của người dùng,
trả lại con trỏ ngữ cảnh của người dùng. Nó cũng sẽ cho biết nếu đọc hoặc
xảy ra lỗi ghi trong quá trình sao chép.

Khi người dùng hoàn thành tất cả công việc sao chép của mình, họ nên gọi
kcopyd_client_destroy() để xóa ứng dụng kcopyd, việc này sẽ giải phóng
trang bộ nhớ liên quan::

void kcopyd_client_destroy(struct kcopyd_client *kc);
