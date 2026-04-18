.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/arch/riscv/uabi.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

Người dùng Linux RISC-V ABI
===========================

Thứ tự chuỗi ISA trong /proc/cpuinfo
------------------------------------

Thứ tự chuẩn của tên phần mở rộng ISA trong chuỗi ISA được xác định trong
Chương 27 của Hướng dẫn sử dụng bộ hướng dẫn RISC-V Tập I ISA không có đặc quyền
(Phiên bản tài liệu 20191213).

Đặc tả sử dụng từ ngữ mơ hồ, chẳng hạn như nên, khi nói đến việc đặt hàng,
vì vậy, vì mục đích của chúng tôi, các quy tắc sau sẽ được áp dụng:

#. Phần mở rộng gồm một chữ cái xuất hiện trước, theo thứ tự chuẩn.
   Thứ tự chuẩn là "IMAFDQLCBKJTPVH".

#. Tất cả các phần mở rộng có nhiều chữ cái sẽ được phân tách khỏi các phần mở rộng khác bằng một dấu
   gạch dưới.

#. Các tiện ích mở rộng tiêu chuẩn bổ sung (bắt đầu bằng 'Z') sẽ được sắp xếp sau
   phần mở rộng một chữ cái và trước bất kỳ phần mở rộng có đặc quyền cao hơn nào.

#. Đối với các phần mở rộng tiêu chuẩn bổ sung, chữ cái đầu tiên sau chữ 'Z'
   theo quy ước chỉ ra bảng chữ cái có liên quan chặt chẽ nhất
   hạng mục mở rộng. Nếu nhiều tiện ích mở rộng 'Z' được đặt tên, chúng sẽ
   được sắp xếp trước theo danh mục, theo thứ tự chuẩn, như được liệt kê ở trên, sau đó
   theo thứ tự bảng chữ cái trong một danh mục.

#. Các tiện ích mở rộng cấp giám sát tiêu chuẩn (bắt đầu bằng 'S') sẽ được liệt kê
   sau các tiện ích mở rộng không có đặc quyền tiêu chuẩn.  Nếu có nhiều cấp giám sát
   các phần mở rộng được liệt kê, chúng sẽ được sắp xếp theo thứ tự bảng chữ cái.

#. Các tiện ích mở rộng cấp máy tiêu chuẩn (bắt đầu bằng 'Zxm') sẽ được liệt kê
   sau bất kỳ tiện ích mở rộng tiêu chuẩn, có đặc quyền thấp hơn nào. Nếu nhiều cấp độ máy
   các phần mở rộng được liệt kê, chúng sẽ được sắp xếp theo thứ tự bảng chữ cái.

#. Các tiện ích mở rộng không chuẩn (bắt đầu bằng 'X') sẽ được liệt kê sau tất cả các tiện ích mở rộng tiêu chuẩn
   phần mở rộng. Nếu nhiều tiện ích mở rộng không chuẩn được liệt kê, chúng sẽ
   được sắp xếp theo thứ tự bảng chữ cái.

Một chuỗi ví dụ theo thứ tự là::

rv64imadc_zifoo_zigoo_zafoo_sbar_scar_zxmbaz_xqux_xrux

Dòng "isa" và "hart isa" trong /proc/cpuinfo
--------------------------------------------

Dòng "isa" trong /proc/cpuinfo mô tả mẫu số chung thấp nhất của
Các phần mở rộng RISC-V ISA được kernel nhận dạng và triển khai trên tất cả các trái tim. các
Ngược lại, dòng "hart isa" mô tả tập hợp các phần mở rộng được nhận dạng bởi
kernel trên hart cụ thể đang được mô tả, ngay cả khi những phần mở rộng đó có thể không
có mặt trên tất cả các điểm trong hệ thống.

Trong cả hai dòng, sự hiện diện của phần mở rộng chỉ đảm bảo rằng phần cứng
có khả năng được mô tả. Hỗ trợ kernel bổ sung hoặc thay đổi chính sách có thể
được yêu cầu trước khi khả năng của tiện ích mở rộng có thể được sử dụng hoàn toàn bởi các chương trình không gian người dùng.
Tương tự, đối với các tiện ích mở rộng chế độ S, sự hiện diện ở một trong các dòng này không
đảm bảo rằng kernel đang tận dụng tiện ích mở rộng hoặc
tính năng này sẽ hiển thị trong các máy ảo khách do kernel này quản lý.

Ngược lại, việc không có phần mở rộng ở những dòng này không nhất thiết có nghĩa là
phần cứng không hỗ trợ tính năng đó. Kernel đang chạy có thể không nhận ra
tiện ích mở rộng hoặc có thể đã cố tình xóa nó khỏi danh sách.

Truy cập sai
-------------------

Các truy cập vô hướng không được căn chỉnh được hỗ trợ trong không gian người dùng, nhưng chúng có thể thực hiện
kém.  Truy cập vectơ không thẳng hàng chỉ được hỗ trợ nếu tiện ích mở rộng Zicclsm
được hỗ trợ.

Mặt nạ con trỏ
---------------

Hỗ trợ che dấu con trỏ trong không gian người dùng (phần mở rộng Supm) được cung cấp thông qua
ZZ0000ZZ và ZZ0001ZZ ZZ0002ZZ
hoạt động. Mặt nạ con trỏ bị tắt theo mặc định. Để kích hoạt nó, không gian người dùng
phải gọi ZZ0003ZZ với trường ZZ0004ZZ được đặt thành
số bit mặt nạ/thẻ mà ứng dụng cần. ZZ0005ZZ được giải thích
như một giới hạn dưới; nếu hạt nhân không thể đáp ứng yêu cầu,
Hoạt động ZZ0006ZZ sẽ thất bại. Số bit thẻ thực tế
được trả về trong ZZ0007ZZ bằng thao tác ZZ0008ZZ.

Ngoài ra, khi mặt nạ con trỏ được bật (ZZ0000ZZ lớn hơn 0),
địa chỉ được gắn thẻ ABI được hỗ trợ, có cùng giao diện và hoạt động như
được ghi lại cho AArch64 (Documentation/arch/arm64/tagged-address-abi.rst).