.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/trace/coresight/panic.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

========================================================
Sử dụng Coresight để khắc phục sự cố hạt nhân và thiết lập lại Watchdog
===================================================

Giới thiệu
------------
Tài liệu này nói về việc sử dụng hỗ trợ theo dõi coresight của Linux để
gỡ lỗi các kịch bản thiết lập lại kernel và watchdog.

Dấu vết Coresight trong cơn hoảng loạn hạt nhân
-----------------------------------
Từ quan điểm của trình điều khiển coresight, giải quyết vấn đề hoảng loạn hạt nhân
Tình hình có bốn yêu cầu chính.

Một. Hỗ trợ phân bổ các trang đệm theo dõi từ vùng bộ nhớ dành riêng.
   Nền tảng có thể quảng cáo điều này bằng cách sử dụng thuộc tính cây thiết bị mới được thêm vào
   các nút coresight có liên quan.

b. Hỗ trợ dừng chặn coresight vào thời điểm hoảng loạn

c. Lưu siêu dữ liệu cần thiết ở định dạng đã chỉ định

d. Hỗ trợ đọc dữ liệu dấu vết được ghi lại vào thời điểm hoảng loạn

Phân bổ các trang đệm theo dõi từ RAM dành riêng
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Một thuộc tính cây thiết bị tùy chọn mới "vùng bộ nhớ" được thêm vào
Các nút thiết bị Coresight TMC, sẽ cung cấp địa chỉ cơ sở và kích thước của dấu vết
bộ đệm.

Việc phân bổ tĩnh các bộ đệm theo dõi sẽ đảm bảo rằng cả IOMMU đều được kích hoạt
và các trường hợp khuyết tật được xử lý. Ngoài ra, các nền tảng hỗ trợ liên tục
RAM sẽ cho phép người dùng đọc dữ liệu theo dõi trong lần khởi động tiếp theo mà không cần
khởi động kernel Crashdump.

Lưu ý:
Đối với các thiết bị chìm ETR, vùng dành riêng này sẽ được sử dụng cho cả dấu vết
thu thập và truy xuất dữ liệu theo dõi.
Đối với các thiết bị bồn rửa ETF, SRAM bên trong sẽ được sử dụng để ghi lại dấu vết,
và chúng sẽ được đồng bộ hóa với vùng dành riêng để truy xuất.


Vô hiệu hóa các khối coresight vào thời điểm hoảng loạn
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Để tránh tình trạng mất dữ liệu theo dõi liên quan sau
hạt nhân hoảng loạn, điều mong muốn là dừng các khối coresight ở
lúc hoảng loạn.

Điều này có thể đạt được bằng cách định cấu hình bộ so sánh, CTI và bộ chìm
các thiết bị như sau::

Kích hoạt sự hoảng loạn
    Bộ so sánh --->Đầu ra ngoài --->CTI -->Đầu vào bên ngoài---->ETR/ETF dừng

Lưu siêu dữ liệu vào thời điểm kernel hoảng loạn
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Siêu dữ liệu của Coresight bao gồm tất cả dữ liệu bổ sung cần thiết cho
giải mã dấu vết thành công bên cạnh dữ liệu dấu vết. Điều này liên quan đến
Ảnh chụp nhanh đăng ký ETR/ETF/ETB, v.v.

Một thuộc tính thiết bị tùy chọn mới "vùng bộ nhớ" được thêm vào
các nút thiết bị ETR/ETF/ETB cho việc này.

Đọc dữ liệu dấu vết được ghi lại tại thời điểm hoảng loạn
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Dữ liệu dấu vết được ghi lại tại thời điểm hoảng loạn, có thể được đọc từ kernel đã khởi động lại
hoặc từ kernel Crashdump bằng tệp thiết bị đặc biệt /dev/crash_tmc_xxx.
Tệp thiết bị này chỉ được tạo khi có sẵn dữ liệu sự cố hợp lệ.

Luồng thu thập và giải mã dấu vết chung trong trường hợp hạt nhân bị hoảng loạn
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
1. Kích hoạt nguồn và chìm trên tất cả các lõi bằng giao diện sysfs.
   Bồn rửa ETR phải có bộ đệm theo dõi được phân bổ từ bộ nhớ dành riêng,
   bằng cách chọn chế độ bộ đệm "resrv" từ sysfs.

2. Chạy thử nghiệm liên quan.

3. Trong trường hợp kernel hoảng loạn, tất cả các khối coresight đều bị vô hiệu hóa, cần thiết
   siêu dữ liệu được đồng bộ hóa bởi trình xử lý hoảng loạn hạt nhân.

Hệ thống cuối cùng sẽ khởi động lại hoặc khởi động kernel bị hỏng.

4. Đối với các nền tảng hỗ trợ kernel Crashdump, dữ liệu theo dõi thô có thể được
   được kết xuất bằng giao diện coresight sysfs từ kernel Crashdump
   chính nó. RAM liên tục không phải là một yêu cầu trong trường hợp này.

5. Đối với các nền tảng hỗ trợ RAM liên tục, dữ liệu theo dõi có thể bị hủy
   bằng cách sử dụng giao diện sysfs coresight trong lần khởi động Linux tiếp theo.
   Hạt nhân Crashdump không phải là một yêu cầu trong trường hợp này. RAM liên tục
   đảm bảo rằng dữ liệu theo dõi được nguyên vẹn trong quá trình khởi động lại.

Dấu vết Coresight trong quá trình thiết lập lại Watchdog
-------------------------------------
Sự khác biệt chính giữa việc giải quyết việc thiết lập lại cơ quan giám sát và sự hoảng loạn của kernel
trường hợp dưới đây,

Một. Việc lưu siêu dữ liệu coresight cần được quan tâm bởi
   Phần sụn SCP(bộ xử lý điều khiển hệ thống) ở định dạng được chỉ định,
   thay vì hạt nhân.

b. Vùng bộ nhớ dành riêng được cung cấp bởi phần sụn cho bộ đệm theo dõi và siêu dữ liệu
   phải ở dạng RAM liên tục.
   Lưu ý: Đây là yêu cầu đối với trường hợp thiết lập lại cơ quan giám sát nhưng không bắt buộc
   trong trường hợp hoảng loạn hạt nhân.

Việc thiết lập lại cơ quan giám sát chỉ có thể được hỗ trợ trên các nền tảng đáp ứng các yêu cầu trên
hai yêu cầu.

Các lệnh mẫu để kiểm tra trường hợp hoảng loạn Kernel với bồn rửa ETR
-------------------------------------------------------------

1. Khởi động kernel Linux với "crash_kexec_post_notifiers" được thêm vào kernel
   bootargs. Điều này là bắt buộc nếu người dùng muốn đọc dữ liệu theo dõi
   từ hạt nhân sụp đổ.

2. Kích hoạt cấu hình ETM được tải sẵn::

#echo 1 > /sys/kernel/config/cs-syscfg/configurations/panicstop/bật

3. Cấu hình CTI bằng giao diện sysfs ::

#./cti_setup.sh

#cat cti_setup.sh


cd /sys/bus/coresight/thiết bị/

ap_cti_config () {
      #ZZ0000ZZ kích hoạt [0] tới Kênh 0
      echo 0 4 > kênh/trigin_attach
    }

etf_cti_config () {
      #ZZ0000ZZ Kích hoạt tuôn ra từ Kênh 0
      echo 0 1 > kênh/trigout_attach
      echo 1 > kênh/trig_filter_enable
    }

etr_cti_config () {
      #ZZ0000ZZ Kết nối từ Kênh 0
      echo 0 1 > kênh/trigout_attach
      echo 1 > kênh/trig_filter_enable
    }

ctidevs=ZZ0000ZZ

cho tôi ở $ctidevs
    làm
            cd $i

kết nối=ZZ0000ZZ
            nếu [ ! -z "$kết nối"]
            sau đó
                    echo "Cấu hình AP CTI cho $i"
                    ap_cti_config
            fi

kết nối=ZZ0000ZZ
            nếu [ ! -z "$kết nối"]
            sau đó
                    echo "Cấu hình ETF CTI cho $i"
                    etf_cti_config
            fi

kết nối=ZZ0000ZZ
            nếu [ ! -z "$kết nối"]
            sau đó
                    echo "Cấu hình ETR CTI cho $i"
                    etr_cti_config
            fi

đĩa ..
    xong

Lưu ý: Các kết nối CTI là dành riêng cho SOC và do đó tập lệnh trên là
thêm vào chỉ để tham khảo.

4. Chọn chế độ đệm dành riêng cho bộ đệm ETR::

#echo "resrv" > /sys/bus/coresight/devices/tmc_etr0/buf_mode_preferred

5. Cho phép dừng cấu hình kích hoạt xả::

#echo 1 > /sys/bus/coresight/devices/tmc_etr0/stop_on_flush

6. Bắt đầu theo dõi Coresight trên lõi 1 và 2 bằng giao diện sysfs

7. Chạy một số ứng dụng trên core 1::

#taskset -c 1 dd if=/dev/urandom of=/dev/null &

8. Gọi kernel hoảng loạn trên lõi 2::

#echo 1 > /proc/sys/kernel/panic
    #taskset -c 2 echo c > /proc/sysrq-trigger

9. Từ kernel đã được khởi động lại hoặc kernel Crashdump, hãy đọc Crashdata::

#dd if=/dev/crash_tmc_etr0 of=/trace/cstrace.bin

10. Chạy các công cụ/tập lệnh giải mã opencsd để tạo dấu vết lệnh.

Kết xuất dấu vết hướng dẫn mẫu
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Kết xuất Core1::

Một etm4_enable_hw: ffff800008ae1dd4
    CONTEXT EL2 etm4_enable_hw: ffff800008ae1dd4
    Tôi etm4_enable_hw: ffff800008ae1dd4:
    d503201f không
    Tôi etm4_enable_hw: ffff800008ae1dd8:
    d503201f không
    Tôi etm4_enable_hw: ffff800008ae1ddc:
    d503201f không
    Tôi etm4_enable_hw: ffff800008ae1de0:
    d503201f không
    Tôi etm4_enable_hw: ffff800008ae1de4:
    d503201f không
    Tôi etm4_enable_hw: ffff800008ae1de8:
    d503233f paciasp
    Tôi etm4_enable_hw: ffff800008ae1dec:
    a9be7bfd stp x29, x30, [sp, #-32]!
    Tôi etm4_enable_hw: ffff800008ae1df0:
    910003fd Mov x29, sp
    Tôi etm4_enable_hw: ffff800008ae1df4:
    a90153f3 stp x19, x20, [sp, #16]
    Tôi etm4_enable_hw: ffff800008ae1df8:
    2a0003f4 di chuyển w20, w0
    Tôi etm4_enable_hw: ffff800008ae1dfc:
    900085b3 adrp x19, ffff800009b95000 <reserved_mem+0xc48>
    Tôi etm4_enable_hw: ffff800008ae1e00:
    910f4273 thêm x19, x19, #0x3d0
    Tôi etm4_enable_hw: ffff800008ae1e04:
    f8747a60 ldr x0, [x19, x20, lsl #3]
    E etm4_enable_hw: ffff800008ae1e08:
    b4000140 cbz x0, ffff800008ae1e30 <etm4_starting_cpu+0x50>
    Tôi 149.039572921 etm4_enable_hw: ffff800008ae1e30:
    a94153f3 ldp x19, x20, [sp, #16]
    Tôi 149.039572921 etm4_enable_hw: ffff800008ae1e34:
    52800000 mov w0, #0x0 // #0
    Tôi 149.039572921 etm4_enable_hw: ffff800008ae1e38:
    a8c27bfd ldp x29, x30, [sp], #32

    ..snip

        149.052324811           chacha_block_generic: ffff800008642d80:
9100a3e0 thêm x0,
    Tôi 149.052324811 chacha_block_generic: ffff800008642d84:
    b86178a2 ldr w2, [x5, x1, lsl #2]
    Tôi 149.052324811 chacha_block_generic: ffff800008642d88:
    8b010803 thêm x3, x0, x1, lsl #2
    Tôi 149.052324811 chacha_block_generic: ffff800008642d8c:
    b85fc063 ldur w3, [x3, #-4]
    Tôi 149.052324811 chacha_block_generic: ffff800008642d90:
    0b030042 thêm w2, w2, w3
    Tôi 149.052324811 chacha_block_generic: ffff800008642d94:
    b8217882 str w2, [x4, x1, lsl #2]
    Tôi 149.052324811 chacha_block_generic: ffff800008642d98:
    91000421 thêm x1, x1, #0x1
    Tôi 149.052324811 chacha_block_generic: ffff800008642d9c:
    f100443f cmp x1, #0x11


Kết xuất lõi 2::

Một etm4_enable_hw: ffff800008ae1dd4
    CONTEXT EL2 etm4_enable_hw: ffff800008ae1dd4
    Tôi etm4_enable_hw: ffff800008ae1dd4:
    d503201f không
    Tôi etm4_enable_hw: ffff800008ae1dd8:
    d503201f không
    Tôi etm4_enable_hw: ffff800008ae1ddc:
    d503201f không
    Tôi etm4_enable_hw: ffff800008ae1de0:
    d503201f không
    Tôi etm4_enable_hw: ffff800008ae1de4:
    d503201f không
    Tôi etm4_enable_hw: ffff800008ae1de8:
    d503233f paciasp
    Tôi etm4_enable_hw: ffff800008ae1dec:
    a9be7bfd stp x29, x30, [sp, #-32]!
    Tôi etm4_enable_hw: ffff800008ae1df0:
    910003fd Mov x29, sp
    Tôi etm4_enable_hw: ffff800008ae1df4:
    a90153f3 stp x19, x20, [sp, #16]
    Tôi etm4_enable_hw: ffff800008ae1df8:
    2a0003f4 di chuyển w20, w0
    Tôi etm4_enable_hw: ffff800008ae1dfc:
    900085b3 adrp x19, ffff800009b95000 <reserved_mem+0xc48>
    Tôi etm4_enable_hw: ffff800008ae1e00:
    910f4273 thêm x19, x19, #0x3d0
    Tôi etm4_enable_hw: ffff800008ae1e04:
    f8747a60 ldr x0, [x19, x20, lsl #3]
    E etm4_enable_hw: ffff800008ae1e08:
    b4000140 cbz x0, ffff800008ae1e30 <etm4_starting_cpu+0x50>
    Tôi 149.046243445 etm4_enable_hw: ffff800008ae1e30:
    a94153f3 ldp x19, x20, [sp, #16]
    Tôi 149.046243445 etm4_enable_hw: ffff800008ae1e34:
    52800000 mov w0, #0x0 // #0
    Tôi 149.046243445 etm4_enable_hw: ffff800008ae1e38:
    a8c27bfd ldp x29, x30, [sp], #32
    Tôi 149.046243445 etm4_enable_hw: ffff800008ae1e3c:
    tự động d50323bf
    E 149.046243445 etm4_enable_hw: ffff800008ae1e40:
    d65f03c0 ret
    Một ete_sysreg_write: ffff800008adfa18

    ..snip

Tôi 149.05422547 hoảng hốt: ffff800008096300:
    a90363f7 stp x23, x24, [sp, #48]
    Tôi 149.05422547 hoảng hốt: ffff800008096304:
    6b00003f cmp w1, w0
    Tôi 149.05422547 hoảng hốt: ffff800008096308:
    3a411804 ccmn w0, #0x1, #0x4, ne // ne = bất kỳ
    N 149.05422547 hoảng hốt: ffff80000809630c:
    540001e0 b.eq ffff800008096348 <panic+0xe0> // b.none
    Tôi 149.05422547 hoảng hốt: ffff800008096310:
    f90023f9 str x25, [sp, #64]
    E 149.05422547 hoảng hốt: ffff800008096314:
    97fe44ef bl ffff8000080276d0 <panic_smp_self_stop>
    Một sự hoảng loạn: ffff80000809634c
    Tôi 149.05422547 hoảng hốt: ffff80000809634c:
    910102d5 thêm x21, x22, #0x40
    Tôi 149.05422547 hoảng hốt: ffff800008096350:
    52800020 mov w0, #0x1 // #1
    E 149.05422547 hoảng hốt: ffff800008096354:
    94166b8b bl ffff800008631180 <bust_spinlocks>
    N 149.054225518 bust_spinlocks: ffff800008631180:
    340000c0 cbz w0, ffff800008631198 <bust_spinlocks+0x18>
    Tôi 149.054225518 bust_spinlocks: ffff800008631184:
    f000a321 adrp x1, ffff800009a98000 <pbufs.0+0xbb8>
    Tôi 149.054225518 bust_spinlocks: ffff800008631188:
    b9405c20 ldr w0, [x1, #92]
    Tôi 149.054225518 bust_spinlocks: ffff80000863118c:
    11000400 thêm w0, w0, #0x1
    Tôi 149.054225518 bust_spinlocks: ffff800008631190:
    b9005c20 str w0, [x1, #92]
    E 149.054225518 bust_spinlocks: ffff800008631194:
    d65f03c0 ret
    Một sự hoảng loạn: ffff800008096358

Thử nghiệm dựa trên Perf
------------------

Bắt đầu phiên biểu diễn
~~~~~~~~~~~~~~~~~~~~~
ETF::

bản ghi hoàn hảo -e cs_etm/panicstop,@tmc_etf1/ -C 1
    bản ghi hoàn hảo -e cs_etm/panicstop,@tmc_etf2/ -C 2

ETR::

bản ghi hoàn hảo -e cs_etm/panicstop,@tmc_etr0/ -C 1,2

Đọc dữ liệu dấu vết sau hoảng loạn
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Phương pháp dựa trên sysfs tương tự được giải thích ở trên có thể được sử dụng để truy xuất và
giải mã dữ liệu theo dõi sau khi khởi động lại kernel.
