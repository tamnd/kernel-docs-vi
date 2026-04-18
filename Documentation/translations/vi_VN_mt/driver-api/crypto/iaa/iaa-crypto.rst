.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/driver-api/crypto/iaa/iaa-crypto.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=============================================
Trình điều khiển mật mã tăng tốc nén IAA
=============================================

Tom Zanussi <tom.zanussi@linux.intel.com>

Trình điều khiển mật mã IAA hỗ trợ tương thích nén/giải nén
với tiêu chuẩn nén DEFLATE được mô tả trong RFC 1951, đó là
thuật toán nén/giải nén được mô-đun này xuất ra.

Thông số phần cứng IAA có thể được tìm thấy ở đây:

ZZ0000ZZ

Trình điều khiển iaa_crypto được thiết kế để hoạt động như một lớp bên dưới
các thiết bị nén cấp cao hơn như zswap.

Người dùng có thể chọn tăng tốc nén/giải nén IAA bằng cách chỉ định
một trong những thuật toán nén IAA được hỗ trợ ở bất kỳ cơ sở nào
cho phép lựa chọn các thuật toán nén.

Ví dụ: thiết bị zswap có thể chọn chế độ 'cố định' IAA
được thể hiện bằng cách chọn nén mật mã 'deflate-iaa'
thuật toán::

# echo giảm phát-iaa > /sys/module/zswap/parameters/compressor

Điều này sẽ yêu cầu zswap sử dụng chế độ nén 'cố định' IAA cho tất cả
nén và giải nén.

Hiện tại chỉ có một chế độ nén duy nhất là “cố định”
chế độ.

Chế độ nén 'cố định' thực hiện sơ đồ nén
được chỉ định bởi RFC 1951 và được đặt tên thuật toán mật mã
'xẹp hơi-iaa'.  (Vì phần cứng IAA có cửa sổ lịch sử 4k
giới hạn, chỉ các bộ đệm <= 4k hoặc đã được nén bằng phần mềm
<= Cửa sổ lịch sử 4k, tuân thủ về mặt kỹ thuật với thông số kỹ thuật giảm phát,
cho phép cửa sổ lên tới 32k.  Vì hạn chế này,
thuật toán giảm phát chế độ cố định IAA được đặt tên thuật toán riêng
thay vì chỉ đơn giản là 'xẹp hơi').


Tùy chọn cấu hình và thiết lập khác
==============================

Trình điều khiển mật mã IAA có sẵn thông qua menuconfig bằng cách sử dụng như sau
đường dẫn::

Mật mã API -> Thiết bị mật mã phần cứng -> Hỗ trợ Bộ tăng tốc nén Intel(R) IAA

Trong tệp cấu hình, tùy chọn có tên CONFIG_CRYPTO_DEV_IAA_CRYPTO.

Trình điều khiển mật mã IAA cũng hỗ trợ số liệu thống kê có sẵn
thông qua menuconfig bằng đường dẫn sau ::

Mật mã API -> Thiết bị mật mã phần cứng -> Hỗ trợ nén Intel(R) IAA -> Kích hoạt Thống kê tăng tốc nén Intel(R) IAA

Trong tệp cấu hình, tùy chọn có tên CONFIG_CRYPTO_DEV_IAA_CRYPTO_STATS.

Các tùy chọn cấu hình sau cũng nên được bật::

CONFIG_IRQ_REMAP=y
  CONFIG_INTEL_IOMMU=y
  CONFIG_INTEL_IOMMU_SVM=y
  CONFIG_PCI_ATS=y
  CONFIG_PCI_PRI=y
  CONFIG_PCI_PASID=y
  CONFIG_INTEL_IDXD=m
  CONFIG_INTEL_IDXD_SVM=y

IAA là một trong những IP tăng tốc đầu tiên của Intel có thể hoạt động trong
kết hợp với Intel IOMMU.  Có nhiều chế độ tồn tại
để thử nghiệm. Dựa trên cấu hình IOMMU, có 3 chế độ::

- Có thể mở rộng
  - Di sản
  - Không có IOMMU


Chế độ có thể mở rộng
-------------

Chế độ có thể mở rộng hỗ trợ Bộ nhớ ảo dùng chung (SVM hoặc SVA). Đó là
đã nhập khi sử dụng dòng lệnh khởi động kernel ::

intel_iommu=bật,sm_on

với VT-d được bật trong BIOS.

Với chế độ có thể mở rộng, cả hàng đợi công việc được chia sẻ và dành riêng đều có sẵn
để sử dụng.

Đối với chế độ có thể mở rộng, phải bật cài đặt BIOS sau::

Cấu hình ổ cắm > Cấu hình IIO > Intel VT cho I/O được điều hướng (VT-d) > Intel VT cho I/O được điều hướng

Cấu hình ổ cắm > Cấu hình IIO > PCIe ENQCMD > ENQCMDS


Chế độ kế thừa
-----------

Chế độ kế thừa được nhập khi sử dụng dòng lệnh khởi động kernel ::

intel_iommu=tắt

hoặc VT-d không được bật trong BIOS.

Nếu bạn đã khởi động vào Linux và không chắc VT-d có bật hay không, hãy thực hiện lệnh "dmesg
| grep -i dmar". Nếu bạn không thấy một số thiết bị DMAR được liệt kê,
rất có thể VT-d chưa bật.

Với chế độ cũ, chỉ có hàng đợi công việc chuyên dụng mới có sẵn để sử dụng.


Không có chế độ IOMMU
-------------

Không có chế độ IOMMU nào được nhập khi sử dụng dòng lệnh khởi động kernel ::

iommu=tắt.

Không có chế độ IOMMU, chỉ có hàng đợi công việc chuyên dụng mới có sẵn để sử dụng.


Cách sử dụng
=====

tăng tốc-config
------------

Khi được tải, trình điều khiển iaa_crypto sẽ tự động tạo một mặc định
cấu hình và kích hoạt nó, đồng thời gán các thuộc tính trình điều khiển mặc định.
Nếu cần một cấu hình hoặc bộ thuộc tính trình điều khiển khác,
trước tiên người dùng phải tắt các thiết bị và hàng công việc IAA, đặt lại
cấu hình, sau đó đăng ký lại thuật toán deflate-iaa với
hệ thống con crypto bằng cách xóa và lắp lại mô-đun iaa_crypto.

ZZ0000ZZ trong 'Trường hợp sử dụng'
phần bên dưới có thể được sử dụng để vô hiệu hóa cấu hình mặc định.

Xem ZZ0000ZZ bên dưới để biết chi tiết về mặc định
cấu hình.

Tuy nhiên, có nhiều khả năng xảy ra hơn và vì sự phức tạp và
khả năng cấu hình của các thiết bị tăng tốc, người dùng sẽ muốn
định cấu hình thiết bị và kích hoạt thủ công các thiết bị mong muốn và
hàng đợi công việc.

Công cụ không gian người dùng để giúp thực hiện điều đó được gọi là accel-config.  sử dụng
accel-config để định cấu hình thiết bị hoặc tải cấu hình đã lưu trước đó
rất được khuyến khích.  Thiết bị có thể được điều khiển thông qua sysfs
trực tiếp nhưng đi kèm với cảnh báo rằng bạn nên thực hiện ONLY này nếu
bạn biết chính xác những gì bạn đang làm.  Các phần sau đây sẽ không
che giao diện sysfs nhưng giả sử bạn sẽ sử dụng accel-config.

Phần ZZ0000ZZ trong phụ lục bên dưới có thể
được tư vấn để biết chi tiết giao diện sysfs nếu quan tâm.

Công cụ accel-config cùng với hướng dẫn xây dựng nó có thể
tìm thấy ở đây:

ZZ0000ZZ

Cách sử dụng điển hình
-------------

Để mô-đun iaa_crypto thực sự thực hiện được bất kỳ
công việc nén/giải nén thay mặt cho một cơ sở, một hoặc nhiều
Hàng đợi công việc IAA cần được liên kết với trình điều khiển iaa_crypto.

Ví dụ: đây là ví dụ về cách định cấu hình hàng đợi công việc IAA và
liên kết nó với trình điều khiển iaa_crypto (lưu ý rằng tên thiết bị là
được chỉ định là 'iax' thay vì 'iaa' - điều này là do thượng nguồn vẫn
đã đặt tên thiết bị 'iax' cũ)::

# configure wq1.0

accel-config config-wq --group-id=0 --mode=dedicated --type=kernel --priority=10 --name="iaa_crypto" --driver-name="crypto" iax1/wq1.0

accel-config config-engine iax1/engine1.0 --group-id=0

Thiết bị # enable IAA iax1

accel-config kích hoạt thiết bị iax1

# enable wq1.0 trên thiết bị IAX iax1

accel-config kích hoạt-wq iax1/wq1.0

Bất cứ khi nào một hàng làm việc mới được liên kết hoặc không liên kết với iaa_crypto
trình điều khiển, các hàng công việc có sẵn sẽ được 'cân bằng lại' để hoạt động
được gửi từ một CPU cụ thể sẽ được trao cho người phù hợp nhất
hàng công việc có sẵn.  Cách thực hành tốt nhất hiện nay là định cấu hình và liên kết
ít nhất một hàng làm việc cho mỗi thiết bị IAA, nhưng miễn là có ít nhất
ít nhất một hàng đợi công việc được định cấu hình và liên kết với bất kỳ thiết bị IAA nào trong
hệ thống, trình điều khiển iaa_crypto sẽ hoạt động, mặc dù rất có thể là không như
một cách hiệu quả.

Thuật toán mật mã IAA đang hoạt động, nén và
hoạt động giải nén được kích hoạt đầy đủ sau khi thành công
liên kết hàng công việc IAA đầu tiên với trình điều khiển iaa_crypto.

Tương tự, thuật toán mật mã IAA không hoạt động và nén
và các hoạt động giải nén bị vô hiệu hóa sau khi hủy liên kết
vấn đề cuối cùng của IAA đối với trình điều khiển iaa_crypto.

Kết quả là các thuật toán mật mã IAA và do đó phần cứng IAA được
chỉ khả dụng khi một hoặc nhiều công việc được liên kết với iaa_crypto
người lái xe.

Khi không có hàng công việc IAA nào được liên kết với trình điều khiển, mật mã IAA
thuật toán có thể được hủy đăng ký bằng cách loại bỏ mô-đun.


Thuộc tính trình điều khiển
-----------------

Có một số thuộc tính trình điều khiển do người dùng định cấu hình có thể được
được sử dụng để cấu hình các chế độ hoạt động khác nhau.  Chúng được liệt kê dưới đây,
cùng với các giá trị mặc định của chúng.  Để đặt bất kỳ thuộc tính nào trong số này, echo
các giá trị thích hợp cho tệp thuộc tính nằm trong
/sys/bus/dsa/drivers/crypto/

Cài đặt thuộc tính tại thời điểm thuật toán IAA được đăng ký
được ghi lại trong crypto_ctx của mỗi thuật toán và được sử dụng cho tất cả các lần nén
và giải nén khi sử dụng thuật toán đó.

Các thuộc tính có sẵn là:

- xác minh_nén

Chuyển đổi xác minh nén.  Nếu được đặt, mỗi lần nén sẽ được
    giải nén nội bộ và nội dung được xác minh, trả về lỗi
    mã nếu không thành công.  Điều này có thể được chuyển đổi bằng 0/1::

echo 0 > /sys/bus/dsa/drivers/crypto/verify_compress

Cài đặt mặc định là '1' - xác minh tất cả các lần nén.

- chế độ đồng bộ hóa

Chọn chế độ sẽ được sử dụng để chờ hoàn thành mỗi lần nén
    và giải nén hoạt động.

Hỗ trợ giao diện không đồng bộ tiền điện tử do iaa_crypto triển khai
    cung cấp một triển khai thỏa mãn giao diện nhưng không
    vì vậy một cách đồng bộ - nó điền và gửi IDXD
    mô tả và sau đó lặp đi lặp lại để chờ nó hoàn thành trước khi
    đang quay trở lại.  Đây không phải là vấn đề vào lúc này, vì tất cả hiện có
    người gọi (ví dụ: zswap) gói bất kỳ cuộc gọi không đồng bộ nào trong một
    Dù sao thì trình bao bọc đồng bộ.

Tuy nhiên, trình điều khiển iaa_crypto cung cấp tính năng không đồng bộ thực sự
    hỗ trợ cho người gọi có thể sử dụng nó.  Ở chế độ này, nó
    điền và gửi bộ mô tả IDXD, sau đó quay lại ngay lập tức
    với -EINPROGRESS.  Sau đó người gọi có thể thăm dò ý kiến để hoàn thành
    chính nó, yêu cầu mã cụ thể trong trình gọi hiện đang
    không có gì trong các triển khai kernel ngược dòng hoặc đi ngủ và chờ đợi
    để hoàn thành tín hiệu ngắt.  Chế độ sau này là
    được hỗ trợ bởi người dùng hiện tại trong kernel chẳng hạn như zswap thông qua
    trình bao bọc đồng bộ.  Mặc dù được hỗ trợ nhưng chế độ này vẫn
    chậm hơn đáng kể so với chế độ đồng bộ thực hiện
    bỏ phiếu trong trình điều khiển iaa_crypto đã đề cập trước đó.

Chế độ này có thể được bật bằng cách ghi 'async_irq' vào sync_mode
    Thuộc tính trình điều khiển iaa_crypto::

echo async_irq > /sys/bus/dsa/drivers/crypto/sync_mode

Chế độ không đồng bộ không bị gián đoạn (người gọi phải thăm dò ý kiến) có thể được bật bằng cách
    viết 'async' cho nó (vui lòng xem Hãy cẩn thận)::

echo async > /sys/bus/dsa/drivers/crypto/sync_mode

Chế độ thực hiện việc bỏ phiếu trong trình điều khiển iaa_crypto có thể là
    được kích hoạt bằng cách viết 'đồng bộ hóa' vào nó::

đồng bộ hóa tiếng vang>/sys/bus/dsa/drivers/crypto/sync_mode

Chế độ mặc định là 'đồng bộ hóa'.

Hãy cẩn thận: vì cơ chế duy nhất mà iaa_crypto hiện đang triển khai
    để bỏ phiếu không đồng bộ mà không bị gián đoạn thông qua chế độ 'đồng bộ hóa' như
    được mô tả trước đó, viết 'không đồng bộ' thành
    '/sys/bus/dsa/drivers/crypto/sync_mode' sẽ kích hoạt nội bộ
    chế độ 'đồng bộ'. Điều này là để đảm bảo hành vi iaa_crypto chính xác cho đến khi đúng
    bỏ phiếu không đồng bộ mà không bị gián đoạn được bật trong iaa_crypto.

.. _iaa_default_config:

Cấu hình mặc định IAA
-------------------------

Khi trình điều khiển iaa_crypto được tải, mỗi thiết bị IAA có một
hàng đợi công việc được định cấu hình cho nó, với các thuộc tính sau::

chế độ "chuyên dụng"
          ngưỡng 0
          kích thước Tổng kích thước WQ từ WQCAP
          ưu tiên 10
          loại IDXD_WQT_KERNEL
          nhóm 0
          tên "iaa_crypto"
          driver_name "mật mã"

Các thiết bị và hàng công việc cũng được kích hoạt và do đó trình điều khiển
đã sẵn sàng để sử dụng mà không cần bất kỳ cấu hình bổ sung nào.

Các thuộc tính trình điều khiển mặc định có hiệu lực khi trình điều khiển được tải là::

sync_mode "đồng bộ hóa"
          xác minh_nén 1

Để thay đổi thuộc tính thiết bị/công việc hoặc trình điều khiển,
các thiết bị và hàng công việc đã bật trước tiên phải được tắt.  theo thứ tự
để áp dụng cấu hình mới cho tiền điện tử deflate-iaa
thuật toán, nó cần phải được đăng ký lại bằng cách loại bỏ và lắp lại
mô-đun iaa_crypto.  ZZ0000ZZ trong 'Sử dụng
Phần trường hợp bên dưới có thể được sử dụng để tắt cấu hình mặc định.

Thống kê
==========

Nếu hỗ trợ thống kê debugfs tùy chọn được bật, mật mã IAA
trình điều khiển sẽ tạo số liệu thống kê có thể được truy cập trong debugfs tại::

# ls -al /sys/kernel/debug/iaa-crypto/
  tổng 0
  drwxr-xr-x 2 gốc gốc 0 Ngày 3 tháng 3 07:55 .
  drwx------ 53 gốc gốc 0 ngày 3 tháng 3 07:55 ..
  -rw-r--r-- 1 gốc 0 Ngày 3 tháng 3 07:55 toàn cầu_stats
  -rw-r--r-- 1 gốc 0 Ngày 3 tháng 3 07:55 stats_reset
  -rw-r--r-- 1 gốc gốc 0 Ngày 3 tháng 3 07:55 wq_stats

Tệp Global_stats hiển thị một tập hợp số liệu thống kê toàn cầu được thu thập kể từ
trình điều khiển đã được tải hoặc đặt lại::

# cat toàn cầu_stats
  số liệu thống kê toàn cầu:
    tổng_comp_calls: 4300
    tổng_decomp_calls: 4164
    tổng_sw_decomp_calls: 0
    tổng_comp_byte_out: 5993989
    tổng_decomp_bytes_in: 5993989
    tổng_hoàn thành_einval_errors: 0
    tổng_hoàn thành_timeout_errors: 0
    tổng_completion_comp_buf_overflow_errors: 136

Tệp wq_stats hiển thị số liệu thống kê trên mỗi wq, một bộ cho từng thiết bị iaa và wq
ngoài một số số liệu thống kê toàn cầu::

# cat wq_stats
  thiết bị iaa:
    mã số: 1
    n_wqs: 1
    comp_calls: 0
    comp_byte: 0
    decom_calls: 0
    decomp_byte: 0
    câu hỏi:
      tên: iaa_crypto
      comp_calls: 0
      comp_byte: 0
      decom_calls: 0
      decomp_byte: 0

thiết bị iaa:
    mã số: 3
    n_wqs: 1
    comp_calls: 0
    comp_byte: 0
    decom_calls: 0
    decomp_byte: 0
    câu hỏi:
      tên: iaa_crypto
      comp_calls: 0
      comp_byte: 0
      decom_calls: 0
      decomp_byte: 0

thiết bị iaa:
    mã số: 5
    n_wqs: 1
    comp_calls: 1360
    comp_byte: 1999776
    decom_calls: 0
    decomp_byte: 0
    câu hỏi:
      tên: iaa_crypto
      comp_calls: 1360
      comp_byte: 1999776
      decom_calls: 0
      decomp_byte: 0

thiết bị iaa:
    mã số: 7
    n_wqs: 1
    comp_calls: 2940
    comp_byte: 3994213
    decom_calls: 4164
    decomp_byte: 5993989
    câu hỏi:
      tên: iaa_crypto
      comp_calls: 2940
      comp_byte: 3994213
      decom_calls: 4164
      decomp_byte: 5993989
    ...

Việc ghi vào 'stats_reset' sẽ đặt lại tất cả số liệu thống kê, bao gồm cả
số liệu thống kê trên mỗi thiết bị và mỗi tuần::

# echo 1 > số liệu thống kê_reset
  # cat wq_stats
    số liệu thống kê toàn cầu:
    tổng_comp_calls: 0
    tổng_decomp_calls: 0
    tổng_comp_byte_out: 0
    tổng_decomp_bytes_in: 0
    tổng_hoàn thành_einval_errors: 0
    tổng_hoàn thành_timeout_errors: 0
    tổng_hoàn thành_comp_buf_overflow_errors: 0
    ...


Trường hợp sử dụng
=========

Kiểm tra zswap đơn giản
-----------------

Trong ví dụ này, kernel nên được cấu hình theo
các tùy chọn chế độ chuyên dụng được mô tả ở trên và zswap phải được bật dưới dạng
ờ::

CONFIG_ZSWAP=y

Đây là một thử nghiệm đơn giản sử dụng iaa_compress làm công cụ nén cho
thiết bị trao đổi (zswap).  Nó thiết lập thiết bị zswap và sau đó sử dụng
chương trình Memory_memadvise được liệt kê bên dưới để buộc phải hoán đổi và chuyển sang
số lượng trang được chỉ định, thể hiện cả nén và giải nén.

Kiểm tra zswap dự kiến hàng đợi công việc cho từng thiết bị IAA trên
hệ thống được cấu hình đúng cách như một hàng đợi công việc hạt nhân với một
tên trình điều khiển công việc của "mật mã".

Bước đầu tiên là đảm bảo mô-đun iaa_crypto đã được tải ::

modprobe iaa_crypto

Nếu các thiết bị và hàng công việc IAA trước đây chưa bị tắt và
được cấu hình lại thì cấu hình mặc định sẽ được giữ nguyên và không
cần thêm cấu hình IAA.  Xem ZZ0000ZZ
bên dưới để biết chi tiết về cấu hình mặc định.

Nếu đã có cấu hình mặc định, bạn sẽ thấy iaa
thiết bị và WQ0 được bật::

# cat /sys/bus/dsa/devices/iax1/state
  đã bật
  # cat /sys/bus/dsa/devices/iax1/wq1.0/state
  đã bật

Để chứng minh rằng các bước sau hoạt động như mong đợi, chúng
các lệnh có thể được sử dụng để kích hoạt đầu ra gỡ lỗi ::

# echo -n 'mô-đun iaa_crypto +p' > /sys/kernel/debug/dynamic_debug/control
  # echo -n 'mô-đun idxd +p' > /sys/kernel/debug/dynamic_debug/control

Sử dụng các lệnh sau để kích hoạt zswap::

# echo 0 > /sys/module/zswap/tham số/kích hoạt
  # echo 50 > /sys/module/zswap/parameters/max_pool_percent
  # echo giảm phát-iaa > /sys/module/zswap/parameters/compressor
  # echo 1 > /sys/module/zswap/tham số/kích hoạt
  # echo 100 > /proc/sys/vm/swappiness
  # echo không bao giờ > /sys/kernel/mm/transparent_hugepage/enabled
  # echo 1 > /proc/sys/vm/overcommit_memory

Bây giờ bạn có thể chạy khối lượng công việc zswap mà bạn muốn đo lường. cho
ví dụ: sử dụng mã Memory_memadvise bên dưới, lệnh sau
sẽ trao đổi vào và ra 100 trang::

./memory_madvise 100

Phân bổ 100 trang để trao đổi vào/ra
  Hoán đổi 100 trang
  Hoán đổi trong 100 trang
  Hoán đổi và trong 100 trang

Bạn sẽ thấy nội dung như sau trong đầu ra dmesg ::

[ 404.202972] idxd 0000:e7:02.0: iaa_comp_acompress: dma_map_sg, src_addr 223925c000, nr_sgs 1, req->src 00000000ee7cb5e6, req->slen 4096, sg_dma_len(sg) 4096
  [ 404.202973] idxd 0000:e7:02.0: iaa_comp_acompress: dma_map_sg, dst_addr 21dadf8000, nr_sgs 1, req->dst 000000008d6acea8, req->dlen 4096, sg_dma_len(sg) 8192
  [ 404.202975] idxd 0000:e7:02.0: iaa_compress: desc->src1_addr 223925c000, desc->src1_size 4096, desc->dst_addr 21dadf8000, desc->max_dst_size 4096, desc->src2_addr 2203543000, desc->src2_size 1568
  [ 404.202981] idxd 0000:e7:02.0: iaa_compress_verify: (xác minh) desc->src1_addr 21dadf8000, desc->src1_size 228, desc->dst_addr 223925c000, desc->max_dst_size 4096, desc->src2_addr 0, desc->src2_size 0
  ...

Bây giờ chức năng cơ bản đã được chứng minh, các giá trị mặc định có thể
sẽ bị xóa và thay thế bằng một cấu hình khác.  Để làm điều đó,
đầu tiên vô hiệu hóa zswap::

# echo lzo > /sys/module/zswap/parameters/compressor
  # swapoff-a
  # echo 0 > /sys/module/zswap/parameters/accept_threshold_percent
  # echo 0 > /sys/module/zswap/parameters/max_pool_percent
  # echo 0 > /sys/module/zswap/tham số/kích hoạt
  # echo 0 > /sys/module/zswap/tham số/kích hoạt

Sau đó chạy ZZ0000ZZ trong phần 'Trường hợp sử dụng'
bên dưới để tắt cấu hình mặc định.

Cuối cùng bật lại trao đổi::

# swapon-a

Sau tất cả những điều đó, (các) thiết bị IAA hiện có thể được định cấu hình lại và
được kích hoạt như mong muốn để thử nghiệm thêm.  Dưới đây là một ví dụ.

Kiểm tra zswap dự kiến hàng đợi công việc cho từng thiết bị IAA trên
hệ thống được cấu hình đúng cách như một hàng đợi công việc hạt nhân với một
tên trình điều khiển công việc của "mật mã".

Đoạn script dưới đây tự động thực hiện điều đó::

#!/bin/bash

echo "Thiết bị IAA:"
  lspci -d:0cfe
  echo "Thiết bị # ZZ0001ZZ:"
  lspci -d:0cfe | wc -l

#
  Phiên bản # count iaa
  #
  iaa_dev_id="0cfe"
  num_iaa=$(lspci -d:${iaa_dev_id} | wc -l)
  echo "Đã tìm thấy phiên bản ${num_iaa} IAA"

#
  # disable iaa wqs và thiết bị
  #
  echo "Vô hiệu hóa IAA"

for ((i = 1; i < ${num_iaa} * 2; i += 2)); làm
      tiếng vang vô hiệu hóa wq iax${i}/wq${i}.0
      accel-config vô hiệu hóa-wq iax${i}/wq${i}.0
      tắt tiếng vang iaa iax${i}
      accel-config vô hiệu hóa thiết bị iax${i}
  xong

echo "Kết thúc Tắt IAA"

echo "Tải lại mô-đun iaa_crypto"

rmmod iaa_crypto
  modprobe iaa_crypto

echo "Kết thúc tải lại mô-đun iaa_crypto"

#
  # configure iaa wqs và thiết bị
  #
  echo "Cấu hình IAA"
  for ((i = 1; i < ${num_iaa} * 2; i += 2)); làm
      accel-config config-wq --group-id=0 --mode=dedicated --wq-size=128 --priority=10 --type=kernel --name="iaa_crypto" --driver-name="crypto" iax${i}/wq${i}.0
      accel-config config-engine iax${i}/engine${i}.0 --group-id=0
  xong

echo "Kết thúc cấu hình IAA"

#
  # enable iaa wqs và thiết bị
  #
  echo "Bật IAA"

for ((i = 1; i < ${num_iaa} * 2; i += 2)); làm
      echo kích hoạt iaa iax${i}
      accel-config kích hoạt thiết bị iax${i}
      echo kích hoạt wq iax${i}/wq${i}.0
      accel-config Enable-wq iax${i}/wq${i}.0
  xong

echo "Kết thúc kích hoạt IAA"

Khi hàng đợi công việc được liên kết với trình điều khiển iaa_crypto, bạn nên
hãy xem nội dung tương tự như sau trong đầu ra dmesg nếu bạn
đầu ra gỡ lỗi đã bật (echo -n 'module iaa_crypto +p' >
/sys/kernel/debug/dynamic_debug/control)::

[ 60.752344] idxd 0000:f6:02.0: add_iaa_wq: đã thêm wq 000000004068d14d vào iaa 00000000c9585ba2, n_wq 1
  [ 60.752346] iaa_crypto: rebalance_wq_table: nr_nodes=2, nr_cpus 160, nr_iaa 8, cpus_per_iaa 20
  [ 60.752347] iaa_crypto: rebalance_wq_table: iaa=0
  [ 60.752349] idxd 0000:6a:02.0: request_iaa_wq: nhận wq từ iaa_device 0000000042d7bc52 (0)
  [ 60.752350] idxd 0000:6a:02.0: request_iaa_wq: trả lại wq 00000000c8bb4452 (0) không sử dụng từ thiết bị iaa 0000000042d7bc52 (0)
  [ 60.752352] iaa_crypto: rebalance_wq_table: gán wq cho cpu=0, node=0 = wq 00000000c8bb4452
  [ 60.752354] iaa_crypto: rebalance_wq_table: iaa=0
  [ 60.752355] idxd 0000:6a:02.0: request_iaa_wq: nhận wq từ iaa_device 0000000042d7bc52 (0)
  [ 60.752356] idxd 0000:6a:02.0: request_iaa_wq: trả lại wq 00000000c8bb4452 (0) không sử dụng từ thiết bị iaa 0000000042d7bc52 (0)
  [ 60.752358] iaa_crypto: rebalance_wq_table: gán wq cho cpu=1, node=0 = wq 00000000c8bb4452
  [ 60.752359] iaa_crypto: rebalance_wq_table: iaa=0
  [ 60.752360] idxd 0000:6a:02.0: request_iaa_wq: nhận wq từ iaa_device 0000000042d7bc52 (0)
  [ 60.752361] idxd 0000:6a:02.0: request_iaa_wq: trả lại wq 00000000c8bb4452 (0) không sử dụng từ thiết bị iaa 0000000042d7bc52 (0)
  [ 60.752362] iaa_crypto: rebalance_wq_table: gán wq cho cpu=2, node=0 = wq 00000000c8bb4452
  [ 60.752364] iaa_crypto: rebalance_wq_table: iaa=0
  .
  .
  .

Khi hàng đợi công việc và thiết bị đã được bật, mật mã IAA
các thuật toán được kích hoạt và có sẵn.  Khi thuật toán mật mã IAA
đã được kích hoạt thành công, bạn sẽ thấy dmesg sau
đầu ra::

[ 64.893759] iaa_crypto: iaa_crypto_enable: iaa_crypto bây giờ là ENABLED

Bây giờ hãy chạy các lệnh thiết lập dành riêng cho zswap sau đây để sử dụng zswap
chế độ nén 'cố định'::

echo 0 > /sys/module/zswap/parameters/enabled
  echo 50 > /sys/module/zswap/parameter/max_pool_percent
  echo deflate-iaa > /sys/module/zswap/parameters/compressor
  echo 1 > /sys/module/zswap/parameters/enabled

echo 100 > /proc/sys/vm/swappiness
  echo never > /sys/kernel/mm/transparent_hugepage/enabled
  echo 1 > /proc/sys/vm/overcommit_memory

Cuối cùng, bây giờ bạn có thể chạy khối lượng công việc zswap mà bạn muốn đo lường. cho
Ví dụ: bằng cách sử dụng mã bên dưới, lệnh sau sẽ hoán đổi và
hết 100 trang::

./memory_madvise 100

Phân bổ 100 trang để trao đổi vào/ra
  Hoán đổi 100 trang
  Hoán đổi trong 100 trang
  Hoán đổi và trong 100 trang

Bạn sẽ thấy nội dung như sau trong đầu ra dmesg nếu
bạn đã bật đầu ra gỡ lỗi (echo -n 'module iaa_crypto +p' >
/sys/kernel/debug/dynamic_debug/control)::

[ 404.202972] idxd 0000:e7:02.0: iaa_comp_acompress: dma_map_sg, src_addr 223925c000, nr_sgs 1, req->src 00000000ee7cb5e6, req->slen 4096, sg_dma_len(sg) 4096
  [ 404.202973] idxd 0000:e7:02.0: iaa_comp_acompress: dma_map_sg, dst_addr 21dadf8000, nr_sgs 1, req->dst 000000008d6acea8, req->dlen 4096, sg_dma_len(sg) 8192
  [ 404.202975] idxd 0000:e7:02.0: iaa_compress: desc->src1_addr 223925c000, desc->src1_size 4096, desc->dst_addr 21dadf8000, desc->max_dst_size 4096, desc->src2_addr 2203543000, desc->src2_size 1568
  [ 404.202981] idxd 0000:e7:02.0: iaa_compress_verify: (xác minh) desc->src1_addr 21dadf8000, desc->src1_size 228, desc->dst_addr 223925c000, desc->max_dst_size 4096, desc->src2_addr 0, desc->src2_size 0
  [ 409.203227] idxd 0000:e7:02.0: iaa_comp_adecompress: dma_map_sg, src_addr 21ddd8b100, nr_sgs 1, req->src 0000000084adab64, req->slen 228, sg_dma_len(sg) 228
  [ 409.203235] idxd 0000:e7:02.0: iaa_comp_adecompress: dma_map_sg, dst_addr 21ee3dc000, nr_sgs 1, req->dst 000000004e2990d0, req->dlen 4096, sg_dma_len(sg) 4096
  [ 409.203239] idxd 0000:e7:02.0: iaa_decompress: desc->src1_addr 21ddd8b100, desc->src1_size 228, desc->dst_addr 21ee3dc000, desc->max_dst_size 4096, desc->src2_addr 0, desc->src2_size 0
  [ 409.203254] idxd 0000:e7:02.0: iaa_comp_adecompress: dma_map_sg, src_addr 21ddd8b100, nr_sgs 1, req->src 0000000084adab64, req->slen 228, sg_dma_len(sg) 228
  [ 409.203256] idxd 0000:e7:02.0: iaa_comp_adecompress: dma_map_sg, dst_addr 21f1551000, nr_sgs 1, req->dst 000000004e2990d0, req->dlen 4096, sg_dma_len(sg) 4096
  [ 409.203257] idxd 0000:e7:02.0: iaa_decompress: desc->src1_addr 21ddd8b100, desc->src1_size 228, desc->dst_addr 21f1551000, desc->max_dst_size 4096, desc->src2_addr 0, desc->src2_size 0

Để hủy đăng ký thuật toán mật mã IAA và đăng ký mới
những cái sử dụng các tham số khác nhau, bất kỳ người dùng nào của thuật toán hiện tại
nên dừng lại và vô hiệu hóa hàng đợi công việc và thiết bị IAA.

Trong trường hợp zswap, hãy loại bỏ thuật toán mật mã IAA làm
máy nén và tắt trao đổi (để xóa tất cả các tham chiếu đến
iaa_crypto)::

echo lzo > /sys/module/zswap/parameters/compressor
  trao đổi -a

echo 0 > /sys/module/zswap/parameters/accept_threshold_percent
  echo 0 > /sys/module/zswap/parameter/max_pool_percent
  echo 0 > /sys/module/zswap/parameters/enabled

Sau khi zswap bị vô hiệu hóa và không còn sử dụng iaa_crypto nữa, IAA wqs và
các thiết bị có thể bị vô hiệu hóa.

.. _iaa_disable_script:

Tập lệnh vô hiệu hóa IAA
------------------

Đoạn script dưới đây tự động thực hiện điều đó::

#!/bin/bash

echo "Thiết bị IAA:"
  lspci -d:0cfe
  echo "Thiết bị # ZZ0001ZZ:"
  lspci -d:0cfe | wc -l

#
  Phiên bản # count iaa
  #
  iaa_dev_id="0cfe"
  num_iaa=$(lspci -d:${iaa_dev_id} | wc -l)
  echo "Đã tìm thấy phiên bản ${num_iaa} IAA"

#
  # disable iaa wqs và thiết bị
  #
  echo "Vô hiệu hóa IAA"

for ((i = 1; i < ${num_iaa} * 2; i += 2)); làm
      tiếng vang vô hiệu hóa wq iax${i}/wq${i}.0
      accel-config vô hiệu hóa-wq iax${i}/wq${i}.0
      tắt tiếng vang iaa iax${i}
      accel-config vô hiệu hóa thiết bị iax${i}
  xong

echo "Kết thúc Tắt IAA"

Cuối cùng, tại thời điểm này, mô-đun iaa_crypto có thể được gỡ bỏ.
sẽ hủy đăng ký thuật toán mật mã IAA hiện tại::

rmmod iaa_crypto


bộ nhớ_madvise.c (gcc -o bộ nhớ_memadvise bộ nhớ_madvise.c)::

#include <stdio.h>
  #include <stdlib.h>
  #include <string.h>
  #include <unistd.h>
  #include <sys/mman.h>
  #include <linux/mman.h>

#ifndef MADV_PAGEOUT
  #define MADV_PAGEOUT 21 /* buộc xuất trang ngay lập tức */
  #endif

#define PG_SZ 4096

int main(int argc, char **argv)
  {
        int i, nr_pages = 1;
        int64_t *dump_ptr;
        ký tự *addr, *a;
        vòng lặp int = 1;

nếu (argc > 1)
                nr_pages = atoi(argv[1]);

printf("Phân bổ %d trang để hoán đổi vào/ra\n", nr_pages);

/* phân bổ trang */
        addr = mmap(NULL, nr_pages * PG_SZ, PROT_READ ZZ0000ZZ MAP_ANONYMOUS, -1, 0);
        *addr = 1;

/* khởi tạo dữ liệu trong trang cho tất cả 'ZZ0000ZZ/
        bộ nhớ (addr, 'ZZ0001ZZ PG_SZ);

printf("Hoán đổi %d trang\n", nr_pages);

/* Yêu cầu kernel hoán đổi nó */
        madvise(addr, nr_pages * PG_SZ, MADV_PAGEOUT);

trong khi (vòng lặp > 0) {
                /*Đợi quá trình hoán đổi hoàn tất */
                ngủ(5);

a = cộng;

printf("Hoán đổi trong %d trang\n", nr_pages);

/* Truy cập trang ... thao tác này sẽ hoán đổi trang đó trở lại */
                for (i = 0; i < nr_pages; i++) {
                        nếu (a[0] != '*') {
                                printf("Dữ liệu xấu khi giải nén!!!!!\n");

dump_ptr = (int64_t *)a;
                                 cho (int j = 0; j < 100; j++) {
                                        printf(" trang %d dữ liệu: %#llx\n", i, *dump_ptr);
                                        dump_ptr++;
                                }
                        }

a += PG_SZ;
                }

vòng lặp --;
        }

printf("Đã hoán đổi và ở trong %d trang\n", nr_pages);

Phụ lục
========

.. _iaa_sysfs_config:

Giao diện cấu hình hệ thống IAA
--------------------------

Dưới đây là mô tả về giao diện sysfs IAA, như đã đề cập
trong tài liệu chính, chỉ nên được sử dụng nếu bạn biết chính xác những gì bạn
đang làm.  Ngay cả khi đó, không có lý do thuyết phục nào để sử dụng nó trực tiếp
vì accel-config có thể làm mọi thứ mà giao diện sysfs có thể và trong
thực tế là accel-config dựa trên nó.

'Đường dẫn cấu hình IAA' là /sys/bus/dsa/devices và chứa
các thư mục con đại diện cho từng thiết bị IAA, hàng công việc, công cụ và
nhóm.  Lưu ý rằng trong giao diện sysfs, các thiết bị IAA thực sự
được đặt tên bằng iax, vd iax1, iax3, v.v. (Lưu ý rằng các thiết bị IAA là
thiết bị số lẻ; các thiết bị được đánh số chẵn là thiết bị DSA và
có thể bỏ qua đối với IAA).

'Đường dẫn liên kết thiết bị IAA' là /sys/bus/dsa/drivers/idxd/bind và là
tệp được ghi để kích hoạt thiết bị IAA.

'Đường dẫn liên kết hàng đợi công việc IAA' là /sys/bus/dsa/drivers/crypto/bind và
là tệp được viết để kích hoạt hàng công việc IAA.

Tương tự /sys/bus/dsa/drivers/idxd/unbind và
/sys/bus/dsa/drivers/crypto/unbind được sử dụng để vô hiệu hóa các thiết bị IAA và
hàng đợi công việc.

Chuỗi lệnh cơ bản cần thiết để thiết lập các thiết bị IAA và
hàng đợi công việc là:

Đối với mỗi thiết bị::
  1) Tắt mọi hàng đợi công việc được bật trên thiết bị.  Ví dụ để
     vô hiệu hóa các công việc 0 và 1 trên thiết bị IAA 3::

# echo wq3.0 > /sys/bus/dsa/drivers/crypto/hủy liên kết
       # echo wq3.1 > /sys/bus/dsa/drivers/crypto/hủy liên kết

2) Tắt thiết bị. Ví dụ để tắt thiết bị IAA 3::

# echo iax3 > /sys/bus/dsa/drivers/idxd/unbind

3) cấu hình hàng đợi công việc mong muốn.  Ví dụ, để cấu hình
     hàng đợi công việc 3 trên thiết bị IAA 3::

# echo chuyên dụng > /sys/bus/dsa/devices/iax3/wq3.3/mode
       # echo 128 > /sys/bus/dsa/devices/iax3/wq3.3/size
       # echo 0 > /sys/bus/dsa/devices/iax3/wq3.3/group_id
       # echo 10 > /sys/bus/dsa/devices/iax3/wq3.3/priority
       # echo "hạt nhân" > /sys/bus/dsa/devices/iax3/wq3.3/type
       # echo "iaa_crypto" > /sys/bus/dsa/devices/iax3/wq3.3/name
       # echo "tiền điện tử" > /sys/bus/dsa/devices/iax3/wq3.3/driver_name

4) Kích hoạt thiết bị. Ví dụ: để bật thiết bị IAA 3::

# echo iax3 > /sys/bus/dsa/drivers/idxd/bind

5) Kích hoạt hàng đợi công việc mong muốn trên thiết bị.  Ví dụ để
     bật công việc 0 và 1 trên thiết bị IAA 3::

# echo wq3.0 > /sys/bus/dsa/drivers/crypto/bind
       # echo wq3.1 > /sys/bus/dsa/drivers/crypto/bind