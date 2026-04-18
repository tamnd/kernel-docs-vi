.. SPDX-License-Identifier: GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/dvb/dmx-expbuf.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. c:namespace:: DTV.dmx

.. _DMX_EXPBUF:

****************
ioctl DMX_EXPBUF
****************

Tên
====

DMX_EXPBUF - Xuất bộ đệm dưới dạng bộ mô tả tệp DMABUF.

.. warning:: this API is still experimental

Tóm tắt
========

.. c:macro:: DMX_EXPBUF

ZZ0000ZZ

Đối số
=========

ZZ0001ZZ
    Bộ mô tả tệp được trả về bởi ZZ0000ZZ.

ZZ0001ZZ
    Con trỏ tới cấu trúc ZZ0000ZZ.

Sự miêu tả
===========

Ioctl này là phần mở rộng của phương thức I/O ánh xạ bộ nhớ.
Nó có thể được sử dụng để xuất bộ đệm dưới dạng tệp DMABUF bất kỳ lúc nào sau đó.
bộ đệm đã được phân bổ với ZZ0000ZZ ioctl.

Để xuất bộ đệm, các ứng dụng phải điền vào cấu trúc ZZ0000ZZ.
Các ứng dụng phải đặt trường ZZ0004ZZ. Số chỉ mục hợp lệ
phạm vi từ 0 đến số lượng bộ đệm được phân bổ với ZZ0001ZZ
(struct ZZ0002ZZ ZZ0005ZZ) trừ một.
Các cờ bổ sung có thể được đăng trong trường ZZ0006ZZ. Tham khảo sách hướng dẫn
for open() để biết chi tiết. Hiện tại chỉ có O_CLOEXEC, O_RDONLY, O_WRONLY,
và O_RDWR được hỗ trợ.
Tất cả các trường khác phải được đặt thành 0. trong
trường hợp API đa mặt phẳng, mỗi mặt phẳng được xuất riêng bằng cách sử dụng
nhiều cuộc gọi ZZ0003ZZ.

Sau khi gọi ZZ0000ZZ, trường ZZ0001ZZ sẽ được đặt bởi một
lái xe, thành công. Đây là bộ mô tả tệp DMABUF. Ứng dụng có thể
chuyển nó tới các thiết bị nhận biết DMABUF khác. Nên đóng DMABUF
tập tin khi nó không còn được sử dụng để cho phép lấy lại bộ nhớ liên quan.

Ví dụ
========

.. code-block:: c

    int buffer_export(int v4lfd, enum dmx_buf_type bt, int index, int *dmafd)
    {
	struct dmx_exportbuffer expbuf;

	memset(&expbuf, 0, sizeof(expbuf));
	expbuf.type = bt;
	expbuf.index = index;
	if (ioctl(v4lfd, DMX_EXPBUF, &expbuf) == -1) {
	    perror("DMX_EXPBUF");
	    return -1;
	}

	*dmafd = expbuf.fd;

	return 0;
    }

Giá trị trả về
============

Khi thành công, trả về 0, lỗi -1 và biến ZZ0001ZZ được đặt
một cách thích hợp. Các mã lỗi chung được mô tả tại
Chương ZZ0000ZZ.

EINVAL
    Hàng đợi không ở chế độ MMAP hoặc việc xuất DMABUF không được hỗ trợ hoặc
    Các trường ZZ0000ZZ hoặc ZZ0001ZZ không hợp lệ.