.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/fault-injection/fault-injection.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

===============================================
Cơ sở hạ tầng khả năng tiêm lỗi
===========================================

Xem thêm tùy chọn mô-đun "every_nth" cho scsi_debug.


Khả năng tiêm lỗi có sẵn
--------------------------------------

- thất bại

tiêm các lỗi phân bổ bản sàn. (kmalloc(), kmem_cache_alloc(), ...)

- failed_page_alloc

tiêm các lỗi phân bổ trang. (alloc_pages(), get_free_pages(), ...)

- lỗi_usercopy

tiêm các lỗi vào chức năng truy cập bộ nhớ của người dùng. (copy_from_user(), get_user(), ...)

- thất bại_futex

tiêm vào bế tắc futex và lỗi uaddr.

- failed_sunrpc

tiêm kernel RPC vào lỗi máy khách và máy chủ.

- failed_make_request

tiêm các lỗi IO vào đĩa trên các thiết bị được cài đặt cho phép
  /sys/block/<device>/make-it-fail hoặc
  /sys/block/<thiết bị>/<phân vùng>/make-it-fail. (submit_bio_noacct())

- thất bại_mmc_request

gây ra lỗi dữ liệu MMC trên các thiết bị được cài đặt cho phép
  gỡ lỗi các mục trong /sys/kernel/debug/mmc0/fail_mmc_request

- chức năng thất bại

đưa lỗi trả về vào các hàm cụ thể, được đánh dấu bằng
  Macro ALLOW_ERROR_INJECTION(), bằng cách đặt các mục debugfs
  trong /sys/kernel/debug/fail_function. Không có tùy chọn khởi động được hỗ trợ.

- failed_skb_realloc

đưa các sự kiện tái phân bổ skb (bộ đệm ổ cắm) vào đường dẫn mạng. các
  mục tiêu chính là xác định và ngăn chặn các vấn đề liên quan đến con trỏ
  quản lý sai trong hệ thống con mạng.  Bằng cách buộc tái phân bổ skb tại
  điểm chiến lược, tính năng này tạo ra các kịch bản trong đó các con trỏ hiện có tới
  tiêu đề skb trở nên không hợp lệ.

Khi lỗi được đưa vào và việc phân bổ lại được kích hoạt, các con trỏ được lưu trong bộ nhớ đệm
  đến các tiêu đề và dữ liệu skb không còn tham chiếu đến các vị trí bộ nhớ hợp lệ. Cái này
  vô hiệu hóa có chủ ý giúp hiển thị các đường dẫn mã nơi cập nhật con trỏ thích hợp
  bị bỏ qua sau một sự kiện tái phân bổ.

Bằng cách tạo ra các kịch bản lỗi được kiểm soát này, hệ thống có thể phát hiện các trường hợp
  nơi sử dụng con trỏ cũ, có khả năng dẫn đến hỏng bộ nhớ hoặc
  sự mất ổn định của hệ thống.

Để chọn giao diện để thao tác, hãy viết tên mạng vào
  /sys/kernel/debug/fail_skb_realloc/devname.
  Nếu trường này để trống (là giá trị mặc định), việc phân bổ lại skb
  sẽ bị ép buộc trên tất cả các giao diện mạng.

Hiệu quả của việc phát hiện lỗi này được nâng cao khi KASAN được
  được bật, vì nó giúp xác định các tham chiếu bộ nhớ không hợp lệ và thời gian sử dụng miễn phí
  (UAF) vấn đề.

- Tiêm lỗi NVMe

chèn mã trạng thái NVMe và cờ thử lại trên các thiết bị được cài đặt cho phép
  các mục gỡ lỗi trong /sys/kernel/debug/nvme*/fault_inject. Mặc định
  mã trạng thái là NVME_SC_INVALID_OPCODE không cần thử lại. Mã trạng thái và
  cờ thử lại có thể được đặt thông qua debugfs.

- Tiêm lỗi trình điều khiển khối thử nghiệm Null

thêm thời gian chờ IO bằng cách đặt các mục cấu hình bên dưới
  /sys/kernel/config/nullb/<đĩa>/timeout_inject,
  đưa ra các yêu cầu hàng đợi bằng cách đặt các mục cấu hình trong
  /sys/kernel/config/nullb/<đĩa>/requeue_inject và
  tiêm lỗi init_hctx() bằng cách đặt các mục cấu hình bên dưới
  /sys/kernel/config/nullb/<đĩa>/init_hctx_fault_inject.

Định cấu hình hành vi của khả năng đưa lỗi
-----------------------------------------------

mục gỡ lỗi
^^^^^^^^^^^^^^^

mô-đun hạt nhân error-inject-debugfs cung cấp một số mục debugfs cho thời gian chạy
cấu hình khả năng tiêm lỗi.

- /sys/kernel/gỡ lỗi/thất bại*/xác suất:

khả năng tiêm thất bại, tính bằng phần trăm.

Định dạng: <phần trăm>

Lưu ý rằng một lỗi trên một trăm là tỷ lệ lỗi rất cao
	đối với một số trường hợp thử nghiệm.  Xem xét cài đặt xác suất = 100 và định cấu hình
	/sys/kernel/debug/fail*/interval cho các trường hợp thử nghiệm như vậy.

- /sys/kernel/gỡ lỗi/thất bại*/khoảng:

chỉ định khoảng thời gian giữa các lần thất bại, cho các cuộc gọi đến
	Should_fail() vượt qua tất cả các bài kiểm tra khác.

Lưu ý rằng nếu bạn bật tính năng này, bằng cách đặt khoảng>1, bạn sẽ
	có lẽ muốn đặt xác suất = 100.

- /sys/kernel/gỡ lỗi/thất bại*/lần:

chỉ định số lần thất bại có thể xảy ra nhiều nhất. Giá trị -1
	có nghĩa là "không có giới hạn".

- /sys/kernel/gỡ lỗi/thất bại*/dấu cách:

chỉ định "ngân sách" tài nguyên ban đầu, giảm dần theo "kích thước"
	trên mỗi lệnh gọi tới Should_fail(,size).  Tiêm thất bại là
	bị triệt tiêu cho đến khi "không gian" bằng không.

- /sys/kernel/debug/fail*/verbose

Định dạng: { 0 ZZ0000ZZ 2 }

chỉ định mức độ chi tiết của thông báo khi xảy ra lỗi
	được tiêm.  '0' có nghĩa là không có tin nhắn; '1' sẽ chỉ in một
	dòng nhật ký cho mỗi lần thất bại; '2' cũng sẽ in dấu vết cuộc gọi -- hữu ích
	để gỡ lỗi các vấn đề được phát hiện do lỗi tiêm.

- /sys/kernel/debug/fail*/task-filter:

Định dạng: { 'Y' | 'N' }

Giá trị 'N' sẽ tắt tính năng lọc theo quy trình (mặc định).
	Bất kỳ giá trị dương nào cũng hạn chế lỗi ở các quy trình được chỉ định bởi
	/proc/<pid>/make-it-fail==1.

- /sys/kernel/debug/fail*/require-start,
  /sys/kernel/gỡ lỗi/thất bại*/require-end,
  /sys/kernel/gỡ lỗi/thất bại*/từ chối-bắt đầu,
  /sys/kernel/gỡ lỗi/thất bại*/từ chối-end:

chỉ định phạm vi địa chỉ ảo được kiểm tra trong
	stacktrace đi bộ.  Lỗi chỉ được đưa vào nếu một số người gọi
	trong stacktrace đã đi nằm trong phạm vi yêu cầu và
	không có gì nằm trong phạm vi bị từ chối.
	Phạm vi bắt buộc mặc định là [0,ULONG_MAX) (toàn bộ không gian địa chỉ ảo).
	Phạm vi bị từ chối mặc định là [0,0).

- /sys/kernel/debug/fail*/stacktrace-deep:

chỉ định độ sâu stacktrace tối đa đã đi trong quá trình tìm kiếm
	đối với người gọi trong [require-start,require-end) HOẶC
	[từ chối-bắt đầu, từ chối-kết thúc).

- /sys/kernel/debug/fail_page_alloc/ignore-gfp-highmem:

Định dạng: { 'Y' | 'N' }

mặc định là 'Y', đặt nó thành 'N' cũng sẽ đưa các lỗi vào
	phân bổ highmem/người dùng (phân bổ __GFP_HIGHMEM).

- /sys/kernel/debug/failslab/cache-filter
	Định dạng: { 'Y' | 'N' }

mặc định là 'N', đặt nó thành 'Y' sẽ chỉ gây ra lỗi khi
        đối tượng là các yêu cầu từ bộ đệm nhất định.

Chọn bộ đệm bằng cách ghi '1' vào /sys/kernel/slab/<cache>/failslab:

- /sys/kernel/debug/failslab/ignore-gfp-wait:
- /sys/kernel/debug/fail_page_alloc/ignore-gfp-wait:

Định dạng: { 'Y' | 'N' }

mặc định là 'Y', đặt nó thành 'N' cũng sẽ gây ra lỗi
	vào các phân bổ có thể ngủ (phân bổ __GFP_DIRECT_RECLAIM).

- /sys/kernel/debug/fail_page_alloc/min-order:

chỉ định thứ tự phân bổ trang tối thiểu được đưa vào
	những thất bại.

- /sys/kernel/debug/fail_futex/ignore-private:

Định dạng: { 'Y' | 'N' }

mặc định là 'N', đặt thành 'Y' sẽ vô hiệu hóa việc tiêm lỗi
	khi xử lý các futex riêng tư (không gian địa chỉ).

- /sys/kernel/debug/fail_sunrpc/ignore-client-disconnect:

Định dạng: { 'Y' | 'N' }

mặc định là 'N', đặt thành 'Y' sẽ vô hiệu hóa việc ngắt kết nối
	tiêm vào máy khách RPC.

- /sys/kernel/debug/fail_sunrpc/ignore-server-disconnect:

Định dạng: { 'Y' | 'N' }

mặc định là 'N', đặt thành 'Y' sẽ vô hiệu hóa việc ngắt kết nối
	tiêm trên máy chủ RPC.

- /sys/kernel/debug/fail_sunrpc/ignore-cache-wait:

Định dạng: { 'Y' | 'N' }

mặc định là 'N', đặt thành 'Y' sẽ vô hiệu hóa việc chờ bộ đệm
	tiêm trên máy chủ RPC.

- /sys/kernel/debug/fail_function/inject:

Định dạng: { 'tên hàm' ZZ0000ZZ '' }

chỉ định chức năng đích của việc chèn lỗi theo tên.
	Nếu tên hàm dẫn đầu '!' tiền tố, hàm đã cho là
	bị loại khỏi danh sách tiêm. Nếu không có gì được chỉ định ('')
	danh sách tiêm được xóa.

- /sys/kernel/debug/fail_function/injectable:

(chỉ đọc) hiển thị các chức năng có thể tiêm lỗi và loại
	giá trị lỗi có thể được chỉ định. Loại lỗi sẽ là một trong
	bên dưới;
	- NULL: giá trị hồi quy phải bằng 0.
	- ERRNO: giá trị trả về phải từ -1 đến -MAX_ERRNO (-4096).
	- ERR_NULL: giá trị trả về phải là 0 hoặc -1 đến -MAX_ERRNO (-4096).

- /sys/kernel/debug/fail_function/<function-name>/retval:

chỉ định giá trị trả về "lỗi" để đưa vào hàm đã cho.
	Điều này sẽ được tạo khi người dùng chỉ định một mục tiêm mới.
	Lưu ý rằng tệp này chỉ chấp nhận các giá trị không dấu. Vì vậy, nếu bạn muốn
	sử dụng một lỗi phủ định, tốt hơn bạn nên sử dụng 'printf' thay vì 'echo', ví dụ:
	$ printf %#x -12 > giá trị trả về

- /sys/kernel/debug/fail_skb_realloc/devname:

Chỉ định giao diện mạng để buộc phân bổ lại SKB.  Nếu
        để trống, việc phân bổ lại SKB sẽ được áp dụng cho tất cả các giao diện mạng.

Ví dụ sử dụng::

Tái phân bổ # Force skb trên eth0
          echo "eth0" > /sys/kernel/debug/fail_skb_realloc/devname

# Clear lựa chọn và buộc tái phân bổ skb trên tất cả các giao diện
          echo "" > /sys/kernel/debug/fail_skb_realloc/devname

Tùy chọn khởi động
^^^^^^^^^^^

Để thêm lỗi trong khi không có debugfs (thời gian khởi động sớm),
sử dụng tùy chọn khởi động ::

thất bại=
	lỗi_page_alloc=
	failed_usercopy=
	thất bại_make_request=
	thất bại_futex=
	failed_skb_realloc=
	mmc_core.fail_request=<interval>,<xác suất>,<dấu cách>,<lần>

mục nhập thủ tục
^^^^^^^^^^^^

- /proc/<pid>/fail-nth,
  /proc/self/task/<tid>/fail-nth:

Ghi vào tệp này số nguyên N khiến lệnh gọi thứ N trong tác vụ không thành công.
	Đọc từ tệp này trả về một giá trị nguyên. Giá trị '0' biểu thị
	rằng thiết lập lỗi với lần ghi trước đó vào tệp này đã được đưa vào.
	Số nguyên dương N chỉ ra rằng lỗi chưa được đưa vào.
	Lưu ý rằng tệp này cho phép tất cả các loại lỗi (slab, futex, v.v.).
	Cài đặt này được ưu tiên hơn tất cả các cài đặt gỡ lỗi chung khác
	như xác suất, khoảng thời gian, v.v. Nhưng cài đặt theo khả năng
	(ví dụ: failed_futex/ignore-private) được ưu tiên hơn nó.

Tính năng này nhằm mục đích kiểm tra lỗi một cách có hệ thống trong một lần
	cuộc gọi hệ thống. Xem một ví dụ dưới đây.


Chức năng tiêm lỗi
--------------------------

Phần này dành cho các nhà phát triển kernel đang cân nhắc việc thêm một chức năng vào
Macro ALLOW_ERROR_INJECTION().

Yêu cầu đối với các chức năng có thể tiêm lỗi
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Do việc chèn lỗi ở cấp độ chức năng buộc phải thay đổi đường dẫn mã
và trả về lỗi ngay cả khi đầu vào và điều kiện phù hợp, điều này có thể
gây ra sự cố kernel không mong muốn nếu bạn cho phép chèn lỗi vào hàm
đó là lỗi NOT có thể tiêm được. Vì vậy, bạn (và người đánh giá) phải đảm bảo;

- Hàm trả về mã lỗi nếu thất bại và người gọi phải kiểm tra
  nó một cách chính xác (cần phải phục hồi từ nó).

- Hàm không thực thi bất kỳ mã nào có thể thay đổi bất kỳ trạng thái nào trước đó
  sự trở lại lỗi đầu tiên. Trạng thái bao gồm toàn cầu hoặc cục bộ hoặc đầu vào
  biến. Ví dụ: xóa lưu trữ địa chỉ đầu ra (ví dụ ZZ0000ZZ),
  bộ đếm tăng/giảm, đặt cờ, vô hiệu hóa ưu tiên/irq hoặc nhận
  một khóa (nếu chúng được khôi phục trước khi trả về lỗi, điều đó sẽ ổn.)

Yêu cầu đầu tiên là quan trọng và nó sẽ dẫn đến việc phát hành
Các hàm (đối tượng miễn phí) thường khó chèn lỗi hơn so với phân bổ
chức năng. Nếu lỗi của các chức năng phát hành đó không được xử lý chính xác
nó sẽ dễ dàng gây rò rỉ bộ nhớ (người gọi sẽ nhầm lẫn rằng đối tượng
đã được phát hành hoặc bị hỏng.)

Cái thứ hai dành cho người gọi mong đợi hàm này sẽ luôn
làm điều gì đó Vì vậy, nếu việc tiêm lỗi chức năng bỏ qua toàn bộ
chức năng, kỳ vọng sẽ bị phản bội và gây ra lỗi không mong muốn.

Loại lỗi Chức năng có thể tiêm
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Mỗi hàm chèn lỗi sẽ có loại lỗi được chỉ định bởi
Macro ALLOW_ERROR_INJECTION(). Bạn phải chọn nó một cách cẩn thận nếu bạn thêm
một chức năng tiêm lỗi mới. Nếu chọn sai loại lỗi,
kernel có thể gặp sự cố vì nó không thể xử lý được lỗi.
Có 4 loại lỗi được xác định trong include/asm-generic/error-injection.h

EI_ETYPE_NULL
  Hàm này sẽ trả về ZZ0000ZZ nếu thất bại. ví dụ. trả lại một khoản được phân bổ
  địa chỉ đối tượng.

EI_ETYPE_ERRNO
  Hàm này sẽ trả về mã lỗi ZZ0000ZZ nếu không thành công. ví dụ. trở về
  -EINVAL nếu nhập sai. Điều này sẽ bao gồm các chức năng sẽ
  trả về một địa chỉ mã hóa ZZ0001ZZ bằng macro ERR_PTR().

EI_ETYPE_ERRNO_NULL
  Hàm này sẽ trả về ZZ0000ZZ hoặc ZZ0001ZZ nếu thất bại. Nếu người gọi
  của hàm này sẽ kiểm tra giá trị trả về bằng macro IS_ERR_OR_NULL(), cái này
  loại sẽ phù hợp.

EI_ETYPE_TRUE
  Hàm này sẽ trả về ZZ0000ZZ (giá trị dương khác 0) nếu thất bại.

Nếu bạn chỉ định sai loại, ví dụ: EI_TYPE_ERRNO cho hàm
trả về một đối tượng được phân bổ, nó có thể gây ra vấn đề vì kết quả được trả về
giá trị không phải là địa chỉ đối tượng và người gọi không thể truy cập vào địa chỉ đó.


Cách thêm khả năng chèn lỗi mới
-----------------------------------------

- #include <linux/fault-inject.h>

- xác định các thuộc tính lỗi

DECLARE_FAULT_ATTR(tên);

Vui lòng xem định nghĩa của struct error_attr trong error-inject.h
  để biết chi tiết.

- cung cấp một cách để cấu hình các thuộc tính lỗi

- tùy chọn khởi động

Nếu bạn cần kích hoạt khả năng chèn lỗi từ lúc khởi động, bạn có thể
  cung cấp tùy chọn khởi động để cấu hình nó. Có một chức năng trợ giúp cho nó:

setup_fault_attr(attr, str);

- mục gỡ lỗi

Failslab, Fail_page_alloc, Fail_usercopy và Fail_make_request hãy sử dụng cách này.
  Các chức năng trợ giúp:

error_create_debugfs_attr(tên, cha mẹ, attr);

- thông số mô-đun

Nếu phạm vi khả năng chèn lỗi bị giới hạn ở một
  mô-đun hạt nhân đơn lẻ, tốt hơn là cung cấp các tham số mô-đun cho
  cấu hình các thuộc tính lỗi.

- thêm một cái móc để chèn lỗi

Khi Should_fail() trả về true, mã máy khách sẽ báo lỗi:

nên_fail(attr, kích thước);

Ví dụ ứng dụng
--------------------

- Đưa các lỗi phân bổ bản sàn vào mã khởi tạo/thoát mô-đun::

#!/bin/bash

FAILTYPE=bảng lỗi
    echo Y > /sys/kernel/debug/$FAILTYPE/task-filter
    echo 10 > /sys/kernel/debug/$FAILTYPE/xác suất
    echo 100 > /sys/kernel/debug/$FAILTYPE/interval
    echo -1 > /sys/kernel/debug/$FAILTYPE/lần
    echo 0 > /sys/kernel/debug/$FAILTYPE/space
    echo 2 > /sys/kernel/debug/$FAILTYPE/verbose
    echo Y > /sys/kernel/debug/$FAILTYPE/ignore-gfp-wait

bị lỗi_system()
    {
	bash -c "echo 1 > /proc/self/make-it-fail && exec $*"
    }

nếu [ $# -eq 0]
    sau đó
	echo "Cách sử dụng: $0 tên mô-đun [ tên mô-đun ... ]"
	lối ra 1
    fi

cho m ở $*
    làm
	echo chèn $m...
	máy dò mod_system bị lỗi $m

tiếng vang loại bỏ $m...
	bị lỗi_system modprobe -r $m
    xong

------------------------------------------------------------------------------

- Chỉ đưa vào các lỗi phân bổ trang cho một mô-đun cụ thể::

#!/bin/bash

FAILTYPE=fail_page_alloc
    mô-đun=$1

nếu [ -z $ mô-đun ]
    sau đó
	echo "Cách sử dụng: $0 <tên mô-đun>"
	lối ra 1
    fi

modprobe $ mô-đun

nếu như [ ! -d /sys/module/$module/sections ]
    sau đó
	echo Mô-đun $ mô-đun không được tải
	lối ra 1
    fi

cat /sys/module/$module/sections/.text > /sys/kernel/debug/$FAILTYPE/require-start
    cat /sys/module/$module/sections/.data > /sys/kernel/debug/$FAILTYPE/require-end

echo N > /sys/kernel/debug/$FAILTYPE/task-filter
    echo 10 > /sys/kernel/debug/$FAILTYPE/xác suất
    echo 100 > /sys/kernel/debug/$FAILTYPE/interval
    echo -1 > /sys/kernel/debug/$FAILTYPE/lần
    echo 0 > /sys/kernel/debug/$FAILTYPE/space
    echo 2 > /sys/kernel/debug/$FAILTYPE/verbose
    echo Y > /sys/kernel/debug/$FAILTYPE/ignore-gfp-wait
    echo Y > /sys/kernel/debug/$FAILTYPE/ignore-gfp-highmem
    echo 10 > /sys/kernel/debug/$FAILTYPE/stacktrace-deep

bẫy "echo 0 > /sys/kernel/debug/$FAILTYPE/probability" SIGINT SIGTERM EXIT

echo "Đưa lỗi vào mô-đun $module... (ngắt để dừng)"
    ngủ 1000000

------------------------------------------------------------------------------

- Chèn lỗi open_ctree trong khi btrfs mount::

#!/bin/bash

rm -f testfile.img
    dd if=/dev/zero of=testfile.img bs=1M seek=1000 count=1
    DEVICE=$(losetup --show -f testfile.img)
    mkfs.btrfs -f $DEVICE
    mkdir -p tmpmnt

FAILTYPE=chức năng thất bại
    FAILFUNC=open_ctree
    echo $FAILFUNC > /sys/kernel/debug/$FAILTYPE/tiêm
    printf %#x -12 > /sys/kernel/debug/$FAILTYPE/$FAILFUNC/retval
    echo N > /sys/kernel/debug/$FAILTYPE/task-filter
    echo 100 > /sys/kernel/debug/$FAILTYPE/xác suất
    echo 0 > /sys/kernel/debug/$FAILTYPE/interval
    echo -1 > /sys/kernel/debug/$FAILTYPE/lần
    echo 0 > /sys/kernel/debug/$FAILTYPE/space
    echo 1 > /sys/kernel/debug/$FAILTYPE/verbose

mount -t btrfs $DEVICE tmpmnt
    nếu [ $? -ne 0 ]
    sau đó
	tiếng vang "SUCCESS!"
    khác
	tiếng vang "FAILED!"
	số lượng tmpmnt
    fi

echo > /sys/kernel/debug/$FAILTYPE/tiêm

rmdir tmpmnt
    thua lỗ -d $DEVICE
    rm testfile.img

------------------------------------------------------------------------------

- Chỉ tiêm các lỗi phân bổ skbuff ::

# mark skbuff_head_cache bị lỗi
    echo 1 > /sys/kernel/slab/skbuff_head_cache/failslab
    # Turn trên bộ lọc bộ đệm (tắt theo mặc định)
    echo 1 > /sys/kernel/debug/failslab/cache-filter
    # Turn khi phun lỗi
    echo 1 > /sys/kernel/debug/failslab/times
    echo 1 > /sys/kernel/debug/failslab/xác suất


Công cụ chạy lệnh với failedlab hoặc failed_page_alloc
----------------------------------------------------
Để dễ dàng thực hiện các nhiệm vụ nêu trên, chúng ta có thể sử dụng
công cụ/kiểm tra/lỗi-tiêm/failcmd.sh.  Hãy chạy một lệnh
"./tools/testing/fault-injection/failcmd.sh --help" để biết thêm thông tin và
xem các ví dụ sau.

Ví dụ:

Chạy lệnh "make -C tools/testing/selftests/ run_tests" bằng cách tiêm bản sàn
lỗi phân bổ::

# ./tools/testing/fault-injection/failcmd.sh \
		-- tạo -C công cụ/kiểm tra/selftests/ run_tests

Tương tự như trên ngoại trừ việc chỉ định tối đa 100 lần thất bại thay vì một lần
nhiều nhất theo mặc định::

# ./tools/testing/fault-injection/failcmd.sh --times=100 \
		-- tạo -C công cụ/kiểm tra/selftests/ run_tests

Tương tự như trên ngoại trừ việc chèn lỗi phân bổ trang thay vì bản phiến
lỗi phân bổ::

# env FAILCMD_TYPE=fail_page_alloc \
		./tools/testing/fault-injection/failcmd.sh --times=100 \
		-- tạo -C công cụ/kiểm tra/selftests/ run_tests

Lỗi hệ thống khi sử dụng failed-nth
---------------------------------

Đoạn mã sau mắc lỗi một cách có hệ thống thứ 0, thứ 1, thứ 2, v.v.
các khả năng trong lệnh gọi hệ thống socketpair() ::

#include <sys/types.h>
  #include <sys/stat.h>
  #include <sys/socket.h>
  #include <sys/syscall.h>
  #include <fcntl.h>
  #include <unistd.h>
  #include <string.h>
  #include <stdlib.h>
  #include <stdio.h>
  #include <errno.h>

int chính()
  {
	int i, err, res, failed_nth, fds[2];
	char buf[128];

system("echo N > /sys/kernel/debug/failslab/ignore-gfp-wait");
	sprintf(buf, "/proc/self/task/%ld/fail-nth", syscall(SYS_gettid));
	failed_nth = open(buf, O_RDWR);
	vì (i = 1;; i++) {
		sprintf(buf, "%d", i);
		write(fail_nth, buf, strlen(buf));
		res = cặp ổ cắm (AF_LOCAL, SOCK_STREAM, 0, fds);
		err = errno;
		pread(fail_nth, buf, sizeof(buf), 0);
		nếu (res == 0) {
			đóng(fds[0]);
			đóng(fds[1]);
		}
		printf("%d-th error %c: res=%d/%d\n", i, atoi(buf) ? 'N' : 'Y',
			độ phân giải, lỗi);
		nếu (atoi(buf))
			phá vỡ;
	}
	trả về 0;
  }

Một đầu ra ví dụ::

Lỗi thứ 1 Y: res=-1/23
	Lỗi thứ 2 Y: res=-1/23
	Lỗi thứ 3 Y: res=-1/12
	Lỗi thứ 4 Y: res=-1/12
	Lỗi thứ 5 Y: res=-1/23
	Lỗi thứ 6 Y: res=-1/23
	Lỗi thứ 7 Y: res=-1/23
	Lỗi thứ 8 Y: res=-1/12
	Lỗi thứ 9 Y: res=-1/12
	Lỗi thứ 10 Y: res=-1/12
	Lỗi thứ 11 Y: res=-1/12
	Lỗi thứ 12 Y: res=-1/12
	Lỗi thứ 13 Y: res=-1/12
	Lỗi thứ 14 Y: res=-1/12
	Lỗi thứ 15 Y: res=-1/12
	Lỗi thứ 16 N: res=0/12
