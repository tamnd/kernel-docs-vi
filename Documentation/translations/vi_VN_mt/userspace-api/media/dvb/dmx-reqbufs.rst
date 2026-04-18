.. SPDX-License-Identifier: GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/dvb/dmx-reqbufs.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. c:namespace:: DTV.dmx

.. _DMX_REQBUFS:

*****************
ioctl DMX_REQBUFS
*****************

Tên
====

DMX_REQBUFS - Khởi tạo ánh xạ bộ nhớ và/hoặc I/O bộ đệm DMA

.. warning:: this API is still experimental

Tóm tắt
========

.. c:macro:: DMX_REQBUFS

ZZ0000ZZ

Đối số
=========

ZZ0001ZZ
    Bộ mô tả tệp được trả về bởi ZZ0000ZZ.

ZZ0001ZZ
    Con trỏ tới cấu trúc ZZ0000ZZ.

Sự miêu tả
===========

Ioctl này được sử dụng để khởi tạo I/O demux được ánh xạ bộ nhớ hoặc DMABUF.

Bộ đệm được ánh xạ bộ nhớ được đặt trong bộ nhớ thiết bị và phải được phân bổ
với ioctl này trước khi chúng có thể được ánh xạ vào địa chỉ của ứng dụng
không gian. Bộ đệm người dùng được phân bổ bởi chính ứng dụng và điều này
ioctl chỉ được sử dụng để chuyển trình điều khiển sang chế độ I/O con trỏ người dùng và
để thiết lập một số cấu trúc bên trong. Tương tự, bộ đệm DMABUF là
được phân bổ bởi các ứng dụng thông qua trình điều khiển thiết bị và chỉ ioctl này
định cấu hình trình điều khiển sang chế độ I/O DMABUF mà không thực hiện bất kỳ thao tác trực tiếp nào
phân bổ.

Để phân bổ bộ đệm thiết bị, các ứng dụng hãy khởi tạo tất cả các trường của
cấu trúc ZZ0000ZZ. Họ đặt trường ZZ0001ZZ
theo số lượng bộ đệm mong muốn và ZZ0002ZZ theo kích thước của mỗi bộ đệm
bộ đệm.

Khi ioctl được gọi với một con trỏ tới cấu trúc này, trình điều khiển sẽ
cố gắng phân bổ số lượng bộ đệm được yêu cầu và nó lưu trữ số lượng thực tế
số được phân bổ trong trường ZZ0000ZZ. ZZ0001ZZ có thể nhỏ hơn số lượng được yêu cầu, thậm chí bằng 0, khi trình điều khiển hết bộ nhớ trống. Một cái lớn hơn
số này cũng có thể thực hiện được khi trình điều khiển yêu cầu nhiều bộ đệm hơn để
hoạt động chính xác. Kích thước bộ đệm được phân bổ thực tế có thể được trả về
tại ZZ0002ZZ và có thể nhỏ hơn mức được yêu cầu.

Khi phương thức I/O này không được hỗ trợ, ioctl trả về ZZ0000ZZ
mã lỗi.

Các ứng dụng có thể gọi lại ZZ0000ZZ để thay đổi số lượng
bộ đệm, tuy nhiên điều này không thể thành công khi bất kỳ bộ đệm nào vẫn được ánh xạ.
Giá trị ZZ0001ZZ bằng 0 sẽ giải phóng tất cả bộ đệm sau khi hủy bỏ hoặc kết thúc
bất kỳ DMA nào đang được xử lý.

Giá trị trả về
==============

Khi thành công, trả về 0, lỗi -1 và biến ZZ0001ZZ được đặt
một cách thích hợp. Các mã lỗi chung được mô tả tại
Chương ZZ0000ZZ.

EOPNOTSUPP
    Phương thức I/O được yêu cầu không được hỗ trợ.