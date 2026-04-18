.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/admin-guide/device-mapper/dm-io.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=====
dm-io
=====

Dm-io cung cấp dịch vụ I/O đồng bộ và không đồng bộ. Có ba
loại dịch vụ I/O có sẵn và mỗi loại có dịch vụ đồng bộ và không đồng bộ
phiên bản.

Người dùng phải thiết lập cấu trúc io_zone để mô tả vị trí mong muốn
của I/O. Mỗi io_zone biểu thị một thiết bị khối cùng với điểm bắt đầu
ngành và quy mô của vùng::

cấu trúc io_khu vực {
      struct block_device *bdev;
      ngành_t ngành;
      số lượng ngành_t;
   };

Dm-io có thể đọc từ một io_khu vực hoặc ghi vào một hoặc nhiều io_khu vực. viết
tới nhiều vùng được chỉ định bởi một mảng cấu trúc io_khu vực.

Loại dịch vụ I/O đầu tiên lấy danh sách các trang bộ nhớ làm bộ đệm dữ liệu cho
I/O, cùng với phần bù vào trang đầu tiên::

cấu trúc trang_list {
      struct page_list *next;
      trang cấu trúc *trang;
   };

int dm_io_sync(unsigned int num_khu vực, struct io_khu vực *where, int rw,
                  struct page_list *pl, unsigned int offset,
                  dài không dấu *error_bits);
   int dm_io_async(unsigned int num_khu vực, struct io_khu vực *where, int rw,
                   struct page_list *pl, unsigned int offset,
                   io_notify_fn fn, void *bối cảnh);

Loại dịch vụ I/O thứ hai lấy một mảng vectơ sinh học làm bộ đệm dữ liệu
cho I/O. Dịch vụ này có thể hữu ích nếu người gọi có tiểu sử được tập hợp sẵn,
nhưng muốn hướng các phần khác nhau của tiểu sử đến các thiết bị khác nhau::

int dm_io_sync_bvec(unsigned int num_khu vực, struct io_khu vực *ở đâu,
                       int rw, struct bio_vec *bvec,
                       dài không dấu *error_bits);
   int dm_io_async_bvec(unsigned int num_khu vực, struct io_khu vực *ở đâu,
                        int rw, struct bio_vec *bvec,
                        io_notify_fn fn, void *bối cảnh);

Loại dịch vụ I/O thứ ba lấy một con trỏ tới bộ đệm bộ nhớ vmalloc'd làm
đệm dữ liệu cho I/O. Dịch vụ này có thể hữu ích nếu người gọi cần thực hiện
I/O cho một khu vực rộng lớn nhưng không muốn phân bổ một số lượng lớn cá nhân
trang ký ức::

int dm_io_sync_vm(unsigned int num_khu vực, struct io_khu vực *where, int rw,
                     khoảng trống *data, unsigned long *error_bits);
   int dm_io_async_vm(unsigned int num_khu vực, struct io_khu vực *where, int rw,
                      void *data, io_notify_fn fn, void *context);

Người gọi dịch vụ I/O không đồng bộ phải bao gồm tên hoàn thành
thủ tục gọi lại và một con trỏ tới một số dữ liệu ngữ cảnh cho I/O::

khoảng trống typedef (*io_notify_fn)(unsigned long error, void *context);

Tham số "lỗi" trong lệnh gọi lại này, cũng như tham số ZZ0000ZZ trong
tất cả các phiên bản đồng bộ đều là một bitset (thay vì một giá trị lỗi đơn giản).
Trong trường hợp ghi-I/O vào nhiều vùng, bitset này cho phép dm-io
cho biết sự thành công hay thất bại trên từng khu vực riêng lẻ.

Trước khi sử dụng bất kỳ dịch vụ dm-io nào, người dùng nên gọi dm_io_get()
và chỉ định số lượng trang họ mong đợi thực hiện I/O đồng thời.
Dm-io sẽ cố gắng thay đổi kích thước mempool của nó để đảm bảo có đủ trang
luôn sẵn sàng để tránh phải chờ đợi không cần thiết trong khi thực hiện I/O.

Khi người dùng sử dụng xong dịch vụ dm-io, họ nên gọi
dm_io_put() và chỉ định cùng số lượng trang được cung cấp trên
cuộc gọi dm_io_get().
