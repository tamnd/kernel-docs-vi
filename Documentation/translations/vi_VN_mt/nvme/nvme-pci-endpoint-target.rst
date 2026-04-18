.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/nvme/nvme-pci-endpoint-target.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=====================================
Mục tiêu chức năng điểm cuối NVMe PCI
=====================================

:Tác giả: Damien Le Moal <dlemoal@kernel.org>

Trình điều khiển mục tiêu chức năng điểm cuối NVMe PCI triển khai bộ điều khiển NVMe PCIe
bằng cách sử dụng bộ điều khiển mục tiêu vải NVMe được định cấu hình với loại truyền tải PCI.

Tổng quan
========

Trình điều khiển mục tiêu chức năng điểm cuối NVMe PCI cho phép hiển thị mục tiêu NVMe
bộ điều khiển qua liên kết PCIe, do đó triển khai thiết bị NVMe PCIe tương tự như
M.2 SSD thông thường. Bộ điều khiển đích được tạo theo cách tương tự như khi
sử dụng NVMe trên vải: bộ điều khiển đại diện cho giao diện với NVMe
hệ thống con sử dụng một cổng. Kiểu chuyển cổng phải được cấu hình thành
"pci". Hệ thống con có thể được cấu hình để có các không gian tên được hỗ trợ bởi hệ thống thông thường
các tệp hoặc chặn thiết bị hoặc có thể sử dụng tính năng truyền qua NVMe để hiển thị cho máy chủ PCI một
thiết bị NVMe vật lý hiện có hoặc bộ điều khiển máy chủ kết cấu NVMe (ví dụ: NVMe
Bộ điều khiển máy chủ TCP).

Trình điều khiển mục tiêu chức năng điểm cuối NVMe PCI phụ thuộc nhiều nhất có thể vào
Mã lõi mục tiêu NVMe để phân tích và thực thi các lệnh NVMe do PCIe gửi
chủ nhà. Tuy nhiên, bằng cách sử dụng khung điểm cuối PCI API và DMA API, trình điều khiển là
cũng chịu trách nhiệm quản lý tất cả việc truyền dữ liệu qua liên kết PCIe. Cái này
ngụ ý rằng trình điều khiển mục tiêu chức năng điểm cuối NVMe PCI thực hiện một số
Quản lý cấu trúc dữ liệu NVMe và một số phân tích cú pháp lệnh NVMe.

1) Trình điều khiển quản lý việc truy xuất các lệnh NVMe trong hàng đợi gửi bằng DMA
   nếu được hỗ trợ, hoặc MMIO nếu không. Mỗi lệnh được truy xuất sau đó sẽ được thực thi
   sử dụng một mục công việc để tối đa hóa hiệu suất với việc thực hiện song song
   nhiều lệnh trên các CPU khác nhau. Người lái xe sử dụng một hạng mục công việc để
   liên tục thăm dò chuông cửa của tất cả các hàng đợi gửi để phát hiện lệnh
   đệ trình từ máy chủ PCIe.

2) Trình điều khiển chuyển các mục hàng đợi hoàn thành của các lệnh đã hoàn thành sang
   Máy chủ PCIe sử dụng bản sao MMIO của các mục trong hàng đợi hoàn thành trên máy chủ.
   Sau khi đăng các mục hoàn thành vào hàng đợi hoàn thành, trình điều khiển sử dụng
   Khung điểm cuối PCI API để gửi một ngắt tới máy chủ để báo hiệu
   hoàn thành các lệnh.

3) Đối với bất kỳ lệnh nào có bộ đệm dữ liệu, trình điều khiển đích điểm cuối NVMe PCI
   phân tích danh sách lệnh PRP hoặc SGL để tạo danh sách địa chỉ PCI
   các phân đoạn thể hiện ánh xạ của bộ đệm dữ liệu lệnh trên máy chủ.
   Bộ đệm dữ liệu lệnh được truyền qua liên kết PCIe bằng danh sách này
   Phân đoạn địa chỉ PCI sử dụng DMA, nếu được hỗ trợ. Nếu DMA không được hỗ trợ, MMIO
   được sử dụng, dẫn đến hiệu suất kém. Đối với lệnh ghi, lệnh
   Bộ đệm dữ liệu được chuyển từ máy chủ vào bộ đệm bộ nhớ cục bộ trước khi
   thực thi lệnh bằng cách sử dụng mã lõi đích. Đối với các lệnh đọc, một lệnh cục bộ
   Bộ nhớ đệm được cấp phát để thực thi lệnh và nội dung của lệnh đó
   bộ đệm được chuyển đến máy chủ sau khi lệnh hoàn thành.

Khả năng điều khiển
-----------------------

Các khả năng NVMe được hiển thị với máy chủ PCIe thông qua các thanh ghi BAR 0
gần giống với khả năng của bộ điều khiển mục tiêu NVMe
được thực hiện bởi mã lõi đích. Có một số trường hợp ngoại lệ.

1) Trình điều khiển mục tiêu điểm cuối NVMe PCI luôn đặt khả năng của bộ điều khiển
   Bit CQR để yêu cầu "Yêu cầu hàng đợi liền kề". Điều này nhằm tạo điều kiện thuận lợi cho
   ánh xạ dải địa chỉ PCI của hàng đợi tới không gian địa chỉ CPU cục bộ.

2) Bước chuông cửa (DSTRB) luôn được đặt ở mức 4B

3) Vì khung điểm cuối PCI không cung cấp cách xử lý cấp độ PCI
   đặt lại, khả năng của bộ điều khiển bit NSSR (Hỗ trợ thiết lập lại hệ thống con NVM)
   luôn luôn được xóa.

4) Hỗ trợ phân vùng khởi động (BPS), Hỗ trợ vùng bộ nhớ liên tục (PMRS)
   và các khả năng được hỗ trợ bộ đệm bộ nhớ điều khiển (CMBS) không bao giờ
   báo cáo.

Các tính năng được hỗ trợ
------------------

Trình điều khiển mục tiêu điểm cuối NVMe PCI triển khai hỗ trợ cho cả PRP và SGL.
Trình điều khiển cũng triển khai hàng đợi gửi và kết hợp vectơ IRQ
vụ nổ trọng tài.

Số lượng hàng đợi tối đa và kích thước truyền dữ liệu tối đa (MDTS) là
có thể định cấu hình thông qua configfs trước khi khởi động bộ điều khiển. Để tránh các vấn đề
với việc sử dụng bộ nhớ cục bộ quá mức để thực thi lệnh, MDTS mặc định là 512
KB và được giới hạn tối đa là 2 MB (giới hạn tùy ý).

Cần có số lượng Windows Mapping địa chỉ PCI tối thiểu
------------------------------------------------------

Hầu hết các bộ điều khiển điểm cuối PCI đều cung cấp một số cửa sổ ánh xạ hạn chế cho
ánh xạ dải địa chỉ PCI tới các địa chỉ bộ nhớ CPU cục bộ. NVMe PCI
bộ điều khiển mục tiêu điểm cuối sử dụng các cửa sổ ánh xạ cho các mục sau.

1) Một cửa sổ bộ nhớ để tăng các ngắt MSI hoặc MSI-X
2) Một cửa sổ bộ nhớ để chuyển MMIO
3) Một cửa sổ bộ nhớ cho mỗi hàng đợi hoàn thành

Do tính chất không đồng bộ cao của trình điều khiển mục tiêu điểm cuối NVMe PCI
hoạt động, các cửa sổ bộ nhớ như mô tả ở trên thường sẽ không được sử dụng
đồng thời, nhưng điều đó có thể xảy ra. Vì vậy, số lần hoàn thành tối đa an toàn
hàng đợi có thể được hỗ trợ bằng tổng số ánh xạ bộ nhớ
cửa sổ của bộ điều khiển điểm cuối PCI trừ đi hai. Ví dụ. cho điểm cuối PCI
bộ điều khiển có sẵn 32 cửa sổ bộ nhớ gửi đi, tối đa 30 cửa sổ hoàn thành
hàng đợi có thể được vận hành an toàn mà không có bất kỳ rủi ro nào về việc ánh xạ địa chỉ PCI
lỗi do thiếu cửa sổ bộ nhớ.

Số lượng cặp hàng đợi tối đa
-----------------------------

Khi liên kết trình điều khiển mục tiêu điểm cuối NVMe PCI với điểm cuối PCI
bộ điều khiển, BAR 0 được phân bổ đủ không gian để chứa hàng đợi quản trị viên
và nhiều hàng đợi I/O. Số lượng cặp hàng đợi I/O tối đa có thể được
được hỗ trợ bị giới hạn bởi một số yếu tố.

1) Mã lõi mục tiêu NVMe giới hạn số lượng hàng đợi I/O tối đa ở mức
   số lượng CPU trực tuyến.
2) Tổng số cặp hàng đợi, bao gồm cả hàng đợi quản trị viên, không được vượt quá
   số lượng vectơ MSI-X hoặc MSI có sẵn.
3) Tổng số hàng đợi hoàn thành không được vượt quá tổng số hàng đợi hoàn thành
   Cửa sổ ánh xạ PCI trừ 2 (xem ở trên).

Trình điều khiển chức năng điểm cuối NVMe cho phép định cấu hình số lượng tối đa
xếp hàng cặp thông qua configfs.

Các hạn chế và việc không tuân thủ thông số kỹ thuật NVMe
-------------------------------------------------

Tương tự như mã lõi mục tiêu NVMe, trình điều khiển mục tiêu điểm cuối NVMe PCI thực hiện
không hỗ trợ nhiều hàng đợi gửi bằng cách sử dụng cùng một hàng đợi hoàn thành. Tất cả
hàng đợi gửi phải chỉ định một hàng đợi hoàn thành duy nhất.


Hướng dẫn sử dụng
==========

Phần này mô tả các yêu cầu phần cứng và cách thiết lập NVMe PCI
thiết bị mục tiêu điểm cuối.

Yêu cầu hạt nhân
-------------------

Kernel phải được biên dịch với các tùy chọn cấu hình CONFIG_PCI_ENDPOINT,
Đã bật CONFIG_PCI_ENDPOINT_CONFIGFS và CONFIG_NVME_TARGET_PCI_EPF.
CONFIG_PCI, CONFIG_BLK_DEV_NVME và CONFIG_NVME_TARGET cũng phải được bật
(rõ ràng).

Ngoài ra, phải có ít nhất một trình điều khiển bộ điều khiển điểm cuối PCI.
có sẵn cho phần cứng điểm cuối được sử dụng.

Để thuận tiện cho việc kiểm tra, hãy bật trình điều khiển null-blk (CONFIG_BLK_DEV_NULL_BLK)
cũng được khuyến khích. Với điều này, một thiết lập đơn giản bằng thiết bị khối null_blk
như một không gian tên hệ thống con có thể được sử dụng.

Yêu cầu phần cứng
---------------------

Để sử dụng trình điều khiển mục tiêu điểm cuối NVMe PCI, ít nhất một bộ điều khiển điểm cuối
thiết bị là cần thiết.

Để tìm danh sách các thiết bị điều khiển điểm cuối trong hệ thống::

# ls /sys/class/pci_epc/
        a40000000.pcie-ep

Nếu PCI_ENDPOINT_CONFIGFS được bật::

# ls/sys/kernel/config/pci_ep/bộ điều khiển
        a40000000.pcie-ep

Bảng điểm cuối tất nhiên cũng phải được kết nối với máy chủ bằng cáp PCI
với tín hiệu RX-TX được hoán đổi. Nếu khe PCI của máy chủ được sử dụng không có
khả năng cắm và chạy, máy chủ phải tắt nguồn khi NVMe PCI
thiết bị đầu cuối được cấu hình.

Thiết bị đầu cuối NVMe
--------------------

Tạo thiết bị đầu cuối NVMe là một quá trình gồm hai bước. Đầu tiên, mục tiêu NVMe
hệ thống con và cổng phải được xác định. Thứ hai, thiết bị đầu cuối NVMe PCI phải
được thiết lập và liên kết với hệ thống con và cổng được tạo.

Tạo một hệ thống con và cổng NVMe
-----------------------------------

Thông tin chi tiết về cách định cấu hình cổng và hệ thống con đích NVMe nằm ngoài
phạm vi của tài liệu này. Sau đây chỉ cung cấp một ví dụ đơn giản về một cổng
và hệ thống con với một không gian tên duy nhất được hỗ trợ bởi thiết bị null_blk.

Trước tiên, hãy đảm bảo rằng configfs đã được bật ::

# mount -t configfs none/sys/kernel/config

Tiếp theo, tạo một thiết bị null_blk (cài đặt mặc định cho thiết bị 250 GB không có
hỗ trợ bộ nhớ). Thiết bị khối được tạo sẽ là /dev/nullb0 theo mặc định::

# modprobe null_blk
        # ls /dev/nullb0
        /dev/nullb0

Trình điều khiển mục tiêu chức năng điểm cuối NVMe PCI phải được tải::

# modprobe nvmet_pci_epf
        # lsmod | grep nvmet
        nvmet_pci_epf 32768 0
        nvmet 118784 1 nvmet_pci_epf
        nvme_core 131072 2 nvmet_pci_epf,nvmet

Bây giờ, hãy tạo một hệ thống con và một cổng mà chúng tôi sẽ sử dụng để tạo mục tiêu PCI
bộ điều khiển khi thiết lập thiết bị đích điểm cuối NVMe PCI. Trong này
ví dụ: cổng được tạo với tối đa 4 cặp hàng đợi I/O::

# cd/sys/kernel/config/nvmet/hệ thống con
        # mkdir nvmepf.0.nqn
        # echo -n "Linux-pci-epf" > nvmepf.0.nqn/attr_model
        # echo "0x1b96" > nvmepf.0.nqn/attr_vendor_id
        # echo "0x1b96" > nvmepf.0.nqn/attr_subsys_vendor_id
        # echo 1 > nvmepf.0.nqn/attr_allow_any_host
        # echo 4 > nvmepf.0.nqn/attr_qid_max

Tiếp theo, tạo và kích hoạt không gian tên hệ thống con bằng khối null_blk
thiết bị::

# mkdir nvmepf.0.nqn/namespaces/1
        # echo -n "/dev/nullb0" > nvmepf.0.nqn/namespaces/1/device_path
        # echo 1 > "nvmepf.0.nqn/namespaces/1/enable"

Cuối cùng, tạo cổng đích và liên kết nó với hệ thống con::

# cd/sys/kernel/config/nvmet/port
        # mkdir 1
        # echo -n "pci" > 1/addr_trtype
        # ln -s /sys/kernel/config/nvmet/subsystems/nvmepf.0.nqn \
                /sys/kernel/config/nvmet/ports/1/subsystems/nvmepf.0.nqn

Tạo thiết bị điểm cuối NVMe PCI
------------------------------------

Với hệ thống con đích NVMe và cổng đã sẵn sàng để sử dụng, điểm cuối NVMe PCI
thiết bị bây giờ có thể được tạo và kích hoạt. Trình điều khiển mục tiêu điểm cuối NVMe PCI
phải được tải sẵn (việc này được thực hiện tự động khi cổng được tạo)::

# ls /sys/kernel/config/pci_ep/functions
        nvmet_pci_epf

Tiếp theo, tạo hàm 0::

# cd /sys/kernel/config/pci_ep/functions/nvmet_pci_epf
        # mkdir nvmepf.0
        # ls nvmepf.0/
        baseclass_code msix_interrupts thứ cấp
        cache_line_size nvme subclass_code
        subsys_id chính của thiết bị
        ngắt_pin progif_code subsys_vendor_id
        msi_interrupts revid nhà cung cấp

Định cấu hình chức năng bằng bất kỳ ID thiết bị nào (ID nhà cung cấp cho thiết bị sẽ
được tự động đặt thành cùng giá trị với nhà cung cấp hệ thống con mục tiêu NVMe
Mã số)::

# cd /sys/kernel/config/pci_ep/functions/nvmet_pci_epf
        # echo 0xBEEF > nvmepf.0/deviceid
        # echo 32 > nvmepf.0/msix_interrupts

Nếu bộ điều khiển điểm cuối PCI được sử dụng không hỗ trợ MSI-X, MSI có thể
được cấu hình thay thế::

# echo 32 > nvmepf.0/msi_interrupts

Tiếp theo, hãy liên kết thiết bị đầu cuối của chúng ta với hệ thống con đích và cổng mà chúng ta
đã tạo::

# echo 1 > nvmepf.0/nvme/portid
        # echo "nvmepf.0.nqn" > nvmepf.0/nvme/subsysnqn

Chức năng điểm cuối sau đó có thể được liên kết với bộ điều khiển điểm cuối và
bộ điều khiển đã bắt đầu::

# cd /sys/kernel/config/pci_ep
        # ln -s chức năng/nvmet_pci_epf/nvmepf.0 bộ điều khiển/a40000000.pcie-ep/
        # echo 1 > bộ điều khiển/a40000000.pcie-ep/bắt đầu

Trên máy điểm cuối, thông báo kernel sẽ hiển thị thông tin dưới dạng NVMe
thiết bị đích và thiết bị đầu cuối được tạo và kết nối.

.. code-block:: text

        null_blk: disk nullb0 created
        null_blk: module loaded
        nvmet: adding nsid 1 to subsystem nvmepf.0.nqn
        nvmet_pci_epf nvmet_pci_epf.0: PCI endpoint controller supports MSI-X, 32 vectors
        nvmet: Created nvm controller 1 for subsystem nvmepf.0.nqn for NQN nqn.2014-08.org.nvmexpress:uuid:2ab90791-2246-4fbb-961d-4c3d5a5a0176.
        nvmet_pci_epf nvmet_pci_epf.0: New PCI ctrl "nvmepf.0.nqn", 4 I/O queues, mdts 524288 B

Máy chủ phức hợp gốc PCI
---------------------

Việc khởi động máy chủ PCI sẽ dẫn đến việc khởi tạo liên kết PCIe (điều này
có thể được trình điều khiển điểm cuối PCI báo hiệu bằng thông báo kernel). Một hạt nhân
thông báo trên điểm cuối cũng sẽ báo hiệu khi trình điều khiển NVMe máy chủ kích hoạt
bộ điều khiển thiết bị::

nvmet_pci_epf nvmet_pci_epf.0: Kích hoạt bộ điều khiển

Về phía máy chủ, thiết bị mục tiêu chức năng điểm cuối NVMe PCI được
có thể được phát hiện dưới dạng thiết bị PCI, với ID nhà cung cấp và ID thiết bị như được định cấu hình::

# lspci-n
        0000:01:00.0 0108: 1b96:thịt bò

Thiết bị này sẽ được nhận dạng là thiết bị NVMe với một không gian tên duy nhất::

# lsblk
        NAME MAJ:MIN RM SIZE RO TYPE MOUNTPOINTS
        nvme0n1 259:0 0 250G 0 đĩa

Sau đó, thiết bị chặn điểm cuối NVMe có thể được sử dụng như mọi NVMe thông thường khác
thiết bị chặn không gian tên. Tiện ích dòng lệnh ZZ0000ZZ có thể được sử dụng để nhận được nhiều hơn
thông tin chi tiết về thiết bị đầu cuối::

# nvme id-ctrl /dev/nvme0
        Bộ điều khiển xác định NVME:
        video: 0x1b96
        ssvid : 0x1b96
        sn : 94993c85650ef7bcd625
        mn : Linux-pci-epf
        fr : 6.13.0-r
        thỏ : 6
        ieee: 000000
        cmic : 0xb
        mdt : 7
        cntlid : 0x1
        phiên bản: 0x20100
        ...


Ràng buộc điểm cuối
=================

Trình điều khiển mục tiêu điểm cuối NVMe PCI sử dụng thiết bị cấu hình điểm cuối PCI
các thuộc tính như sau.

==================================================================================
nhà cung cấp bị bỏ qua (id nhà cung cấp của hệ thống con mục tiêu NVMe được sử dụng)
deviceid Mọi thứ đều ổn (ví dụ PCI_ANY_ID)
revid Đừng quan tâm
progif_code Phải là 0x02 (NVM Express)
baseclass_code Phải là 0x01 (PCI_BASE_CLASS_STORAGE)
subclass_code Phải là 0x08 (Bộ điều khiển bộ nhớ không biến đổi)
cache_line_size Đừng quan tâm
subsys_vendor_id Đã bỏ qua (id nhà cung cấp hệ thống con của hệ thống con mục tiêu NVMe
		   được sử dụng)
subsys_id Mọi thứ đều được (ví dụ PCI_ANY_ID)
msi_interrupts Ít nhất bằng số cặp hàng đợi mong muốn
msix_interrupts Ít nhất bằng số lượng cặp hàng đợi mong muốn
ngắt_pin Ngắt PIN để sử dụng nếu MSI và MSI-X không được hỗ trợ
==================================================================================

Chức năng mục tiêu điểm cuối NVMe PCI cũng có một số cấu hình cụ thể
các trường được xác định trong thư mục con ZZ0000ZZ của thư mục hàm. Những cái này
các trường như sau.

==================================================================================
mdts_kb Kích thước truyền dữ liệu tối đa tính bằng KiB (mặc định: 512)
portid ID của cổng mục tiêu sẽ sử dụng
subsysnqn NQN của hệ thống con đích sẽ sử dụng
==================================================================================