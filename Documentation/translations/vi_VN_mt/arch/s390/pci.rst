.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/arch/s390/pci.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

==========
S/390 PCI
=========

tác giả:
        - Pierre Morel

Bản quyền, IBM Corp. 2020


Các tham số dòng lệnh và các mục gỡ lỗi
===========================================

Tham số dòng lệnh
-----------------------

* danh nghĩa

Không sử dụng các lệnh I/O được ánh xạ PCI (MIO).

* norid

Bỏ qua trường RID và buộc sử dụng một miền PCI cho mỗi hàm PCI.

mục gỡ lỗi
---------------

Tính năng gỡ lỗi S/390 (s390dbf) tạo ra các khung nhìn để chứa các kết quả gỡ lỗi khác nhau trong các thư mục sysfs có dạng:

* /sys/kernel/debug/s390dbf/pci_*/

Ví dụ:

- /sys/kernel/debug/s390dbf/pci_msg/sprintf
    Giữ các thông báo từ quá trình xử lý các sự kiện PCI, như xử lý kiểm tra máy
    và cài đặt chức năng chung, như kiểm tra UID.

Thay đổi mức độ ghi nhật ký thành chi tiết hơn hoặc ít hơn bằng đường ống
  một số từ 0 đến 6 đến /sys/kernel/debug/s390dbf/pci_*/level. cho
  chi tiết, xem tài liệu về tính năng gỡ lỗi S/390 tại
  Tài liệu/arch/s390/s390dbf.rst.

Mục nhập hệ thống
=============

Các mục nhập cụ thể cho các chức năng zPCI và các mục nhập chứa thông tin zPCI.

* /sys/bus/pci/khe/XXXXXXXX

Các mục vị trí được thiết lập bằng cách sử dụng mã định danh chức năng (FID) của
  Chức năng PCI. Định dạng được mô tả là XXXXXXXX ở trên là 8 chữ số thập lục phân
  với phần đệm 0 và chữ số thập lục phân viết thường.

- /sys/bus/pci/slots/XXXXXXXX/nguồn

Không thể sử dụng chức năng vật lý hiện đang hỗ trợ chức năng ảo
  tắt nguồn cho đến khi tất cả các chức năng ảo được xóa bằng:
  echo 0 > /sys/bus/pci/devices/XXXX:XX:XX.X/sriov_numvf

* /sys/bus/pci/devices/XXXX:XX:XX.X/

- hàm_id
    Mã định danh chức năng zPCI xác định duy nhất chức năng trong máy chủ Z.

- hàm_handle
    Mã định danh cấp thấp được sử dụng cho chức năng PCI được định cấu hình.
    Nó có thể hữu ích cho việc gỡ lỗi.

- pchid
    Vị trí phụ thuộc vào mô hình của bộ điều hợp I/O.

- pfgid
    ID nhóm chức năng PCI, các chức năng có chung chức năng
    sử dụng một định danh chung.
    Nhóm PCI xác định các ngắt, IOMMU, IOTLB và DMA.

- vfn
    Số chức năng ảo, từ 1 đến N cho các chức năng ảo,
    0 cho các chức năng vật lý.

- pft
    Loại chức năng PCI

- cổng
    Cổng tương ứng với cổng vật lý mà chức năng được gắn vào.
    Nó cũng đưa ra dấu hiệu về chức năng vật lý và chức năng ảo
    được gắn vào.

- uid
    Mã định danh người dùng (UID) có thể được xác định là một phần của máy
    cấu hình hoặc cấu hình khách z/VM hoặc KVM. Nếu đi kèm
    Thuộc tính uid_is_unique là 1 nền tảng đảm bảo rằng UID là duy nhất
    trong trường hợp đó và không có thiết bị nào có cùng UID có thể được gắn vào
    trong suốt thời gian tồn tại của hệ thống.

- uid_is_unique
    Cho biết liệu mã định danh người dùng (UID) có được đảm bảo tồn tại và duy trì hay không
    duy nhất trong phiên bản Linux này.

- pfip/đoạnX
    Các phân đoạn xác định sự cô lập của một chức năng.
    Chúng tương ứng với đường dẫn vật lý đến hàm.
    Các phân đoạn càng khác nhau thì các chức năng càng bị cô lập.

Liệt kê và cắm nóng
=======================

Địa chỉ PCI bao gồm bốn phần: miền, bus, thiết bị và chức năng,
và có dạng này: DDDD:BB:dd.f

* Khi không sử dụng đa chức năng (norid được đặt hoặc phần sụn không
  hỗ trợ đa chức năng):

- Mỗi miền chỉ có một chức năng.

- Miền được đặt từ UID của hàm zPCI như được xác định trong quá trình
    Tạo LPAR.

* Khi sử dụng đa chức năng (tham số norid không được đặt),
  Các chức năng zPCI được giải quyết khác nhau:

- Vẫn chỉ có một bus cho mỗi miền.

- Có thể có tới 256 chức năng trên mỗi xe buýt.

- Phần miền của địa chỉ của tất cả các hàm dành cho
    một thiết bị đa chức năng được đặt từ UID của chức năng zPCI như được xác định
    trong quá trình tạo LPAR cho hàm số 0.

- Các chức năng mới sẽ chỉ sẵn sàng để sử dụng sau chức năng số 0
    (hàm có devfn 0) đã được liệt kê.