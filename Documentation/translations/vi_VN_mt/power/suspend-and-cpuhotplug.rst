.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/power/suspend-and-cpuhotplug.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

==========================================================================
Tương tác của mã Tạm dừng (S3) với cơ sở hạ tầng cắm nóng CPU
====================================================================

(C) 2011 - 2014 Srivatsa S. Bhat <srivatsa.bhat@linux.vnet.ibm.com>


I. Sự khác biệt giữa hotplug CPU và Suspend-to-RAM
======================================================

Mã hotplug CPU thông thường khác với mã Suspend-to-RAM như thế nào
cơ sở hạ tầng sử dụng nó trong nội bộ? Và họ chia sẻ mã chung ở đâu?

Chà, một bức tranh đáng giá ngàn lời nói... Vì vậy, nghệ thuật ASCII tuân theo :-)

[Điều này mô tả thiết kế hiện tại trong kernel và chỉ tập trung vào
tương tác liên quan đến tủ đông và phích cắm nóng CPU và cũng cố gắng giải thích
việc khóa liên quan. Nó cũng phác thảo các thông báo liên quan.
Nhưng xin lưu ý rằng ở đây chỉ minh họa đường dẫn cuộc gọi với mục đích
mô tả nơi họ đi những con đường khác nhau và nơi họ chia sẻ mã.
Điều gì xảy ra khi hotplug CPU thông thường và Suspend-to-RAM chạy đua với nhau
không được mô tả ở đây.]

Ở mức độ cao, chu trình tạm dừng-tiếp tục diễn ra như sau::

ZZ0000ZZ -> ZZ0001ZZ -> ZZ0002ZZ -> ZZ0003ZZ -> ZZ0004ZZ
  ZZ0005ZZ ZZ0006ZZ ZZ0007ZZ ZZ0008ZZ ZZ0009ZZ


Thông tin chi tiết theo sau::

Tạm dừng đường dẫn cuộc gọi
                                ------------------

Viết 'mem' vào
                                /sys/nguồn/trạng thái
                                    tập tin sysfs
                                        |
                                        v
                               Có được khóa system_transition_mutex
                                        |
                                        v
                             Gửi PM_SUSPEND_PREPARE
                                   thông báo
                                        |
                                        v
                                   Đóng băng nhiệm vụ
                                        |
                                        |
                                        v
                              đóng băng_thứ cấp_cpus()
                                   /*bắt đầu*/
                                        |
                                        v
                            Nhận cpu_add_remove_lock
                                        |
                                        v
                             Lặp lại CURRENTLY
                                   CPU trực tuyến
                                        |
                                        |
                                        |                ----------
                                        v | L
             ======> _cpu_down() |
            ZZ0000ZZ
  ZZ0001ZZ chung
   mã ZZ0002ZZ O
            ZZ0003ZZ
            ZZ0004ZZ
             ======> bằng cách chạy tất cả lệnh gọi lại đã đăng ký.      |
                                        ZZ0005ZZ O
                                        ZZ0006ZZ
                                        ZZ0007ZZ
                                        v |
                            Ghi lại những CPU này trong | P
                                mặt nạ Frozen_cpus ----------
                                        |
                                        v
                           Vô hiệu hóa hotplug cpu thông thường
                        bằng cách tăng cpu_hotplug_disabled
                                        |
                                        v
                            Giải phóng cpu_add_remove_lock
                                        |
                                        v
                       /* đóng băng_secondary_cpus() hoàn thành */
                                        |
                                        v
                                   Đừng đình chỉ



Việc tiếp tục trở lại cũng tương tự như vậy, với các đối tác là (theo thứ tự
thực hiện trong quá trình tiếp tục):

* thaw_secondary_cpus() bao gồm::

|  Nhận cpu_add_remove_lock
   |  Giảm cpu_hotplug_disabled, từ đó kích hoạt tính năng cắm nóng CPU thông thường
   |  Gọi _cpu_up() [cho tất cả các CPU đó trong mặt nạ Frozen_cpus, trong một vòng lặp]
   |  Giải phóng cpu_add_remove_lock
   v

* nhiệm vụ tan băng
* gửi thông báo PM_POST_SUSPEND
* Phát hành khóa system_transition_mutex.


Cần lưu ý ở đây rằng khóa system_transition_mutex được lấy tại
ngay từ đầu, khi chúng ta mới bắt đầu tạm dừng và sau đó chỉ phát hành
sau khi toàn bộ chu trình hoàn tất (tức là tạm dừng + tiếp tục).

::



Đường dẫn cuộc gọi hotplug CPU thông thường
                          -----------------------------

Viết 0 (hoặc 1) vào
                       /sys/devices/system/cpu/cpu*/trực tuyến
                                    tập tin sysfs
                                        |
                                        |
                                        v
                                    cpu_down()
                                        |
                                        v
                           Nhận cpu_add_remove_lock
                                        |
                                        v
                          Nếu cpu_hotplug_disabled > 0
                                trở lại một cách duyên dáng
                                        |
                                        |
                                        v
             ======> _cpu_down()
            |              [Việc này cần có cpuhotplug.lock
  Chung |               trước khi hạ CPU
   mã |               và thả nó ra khi hoàn tất]
            |            Trong khi đó, các thông báo
            |           được gửi khi các sự kiện đáng chú ý xảy ra,
             ======> bằng cách chạy tất cả lệnh gọi lại đã đăng ký.
                                        |
                                        |
                                        v
                          Giải phóng cpu_add_remove_lock
                               [Chính là nó!, vì
                              phích cắm nóng CPU thông thường]



Vì vậy, như có thể thấy từ hai sơ đồ (các phần được đánh dấu là "Mã chung"),
hotplug CPU thông thường và đường dẫn mã tạm dừng hội tụ tại _cpu_down() và
_cpu_up() hàm. Chúng khác nhau ở các đối số được truyền cho các hàm này,
trong đó trong quá trình cắm nóng CPU thông thường, 0 được chuyển cho 'tasks_frozen'
lý lẽ. Nhưng trong thời gian tạm dừng, vì các nhiệm vụ đã bị đóng băng vào thời điểm đó
các CPU không khởi động được ngoại tuyến hoặc trực tuyến, các hàm _cpu_*() được gọi
với đối số 'tasks_frozen' được đặt thành 1.
[Xem bên dưới để biết một số vấn đề đã biết liên quan đến vấn đề này.]


Các tập tin và chức năng/điểm vào quan trọng:
-------------------------------------------

- kernel/power/process.c : đóng băng_processes(), thaw_processes()
- kernel/power/suspend.c : đình chỉ_prepare(), đình chỉ_enter(), đình chỉ_finish()
- kernel/cpu.c: cpu_[up|down](), _cpu_[up|down](),
  [tắt|bật]_nonboot_cpus()



II. Các vấn đề liên quan đến hotplug CPU là gì?
------------------------------------------------

Có một số tình huống thú vị liên quan đến hotplug và microcode CPU
cập nhật trên CPU, như được thảo luận dưới đây:

[Xin lưu ý rằng kernel yêu cầu các hình ảnh vi mã từ
không gian người dùng, sử dụng hàm request_firmware() được xác định trong
driver/base/firmware_loader/main.c]


Một. Khi tất cả các CPU giống hệt nhau:

Đây là tình huống phổ biến nhất và khá đơn giản: chúng tôi muốn
   để áp dụng cùng một bản sửa đổi vi mã cho từng CPU.
   Để đưa ra ví dụ về x86, hàm coll_cpu_info() được xác định trong
   Arch/x86/kernel/microcode_core.c giúp khám phá loại CPU
   và từ đó áp dụng bản sửa đổi vi mã chính xác cho nó.
   Nhưng lưu ý rằng hạt nhân không duy trì một hình ảnh vi mã chung cho
   tất cả các CPU, để xử lý trường hợp 'b' được mô tả bên dưới.


b. Khi một số CPU khác với phần còn lại:

Trong trường hợp này vì có lẽ chúng ta cần áp dụng các bản sửa đổi vi mã khác nhau
   đối với các CPU khác nhau, hạt nhân sẽ duy trì một bản sao của vi mã chính xác
   hình ảnh cho mỗi CPU (sau khi khám phá loại/mô hình CPU thích hợp bằng cách sử dụng
   các hàm như coll_cpu_info()).


c. Khi CPU được rút phích cắm nóng về mặt vật lý và một thiết bị mới (và có thể khác
   loại) CPU được cắm nóng vào hệ thống:

Trong thiết kế hiện tại của kernel, bất cứ khi nào CPU bị ngoại tuyến trong quá trình
   thao tác cắm nóng CPU thông thường, khi nhận được thông báo CPU_DEAD
   (được gửi bởi mã cắm nóng CPU), trình điều khiển cập nhật vi mã
   cuộc gọi lại cho sự kiện đó phản ứng bằng cách giải phóng bản sao của kernel
   hình ảnh vi mã cho CPU đó.

Do đó, khi một CPU mới được đưa lên mạng, vì kernel nhận thấy rằng nó
   không có hình ảnh vi mã, nó thực hiện khám phá loại/mô hình CPU
   làm mới và sau đó yêu cầu không gian người dùng để có hình ảnh vi mã thích hợp
   cho CPU đó, sau đó sẽ được áp dụng.

Ví dụ: trong x86, hàm mc_cpu_callback() (là vi mã
   cập nhật cuộc gọi lại của trình điều khiển đã đăng ký cho các sự kiện cắm nóng CPU)
   microcode_update_cpu() sẽ gọi microcode_init_cpu() trong trường hợp này,
   thay vì microcode_resume_cpu() khi nhận thấy kernel không
   có một hình ảnh vi mã hợp lệ. Điều này đảm bảo rằng loại/model CPU
   quá trình khám phá được thực hiện và vi mã phù hợp được áp dụng cho CPU sau
   lấy nó từ không gian người dùng.


d. Xử lý cập nhật vi mã trong khi tạm dừng/ngủ đông:

Nói đúng ra, trong quá trình vận hành cắm nóng CPU không liên quan đến
   tháo hoặc lắp CPU về mặt vật lý, CPU không thực sự được cấp nguồn
   tắt trong khi CPU ngoại tuyến. Chúng chỉ được đặt ở trạng thái C thấp nhất có thể.
   Do đó, trong trường hợp như vậy, việc áp dụng lại vi mã là không thực sự cần thiết.
   khi CPU được đưa trở lại trực tuyến, vì chúng sẽ không bị mất
   hình ảnh trong quá trình hoạt động ngoại tuyến CPU.

Đây là tình huống thông thường gặp phải trong quá trình tiếp tục sau khi tạm dừng.
   Tuy nhiên, trong trường hợp ngủ đông, vì tất cả các CPU đều hoàn toàn
   tắt nguồn, trong quá trình khôi phục cần phải áp dụng vi mã
   hình ảnh tới tất cả các CPU.

[Lưu ý rằng chúng tôi không mong đợi ai đó kéo các nút ra và chèn
   các nút có loại CPU khác ở giữa tạm dừng-tiếp tục hoặc
   chu kỳ ngủ đông/khôi phục.]

Tuy nhiên, trong thiết kế hiện tại của kernel, trong quá trình hoạt động ngoại tuyến CPU
   như một phần của chu trình tạm dừng/ngủ đông (cpuhp_tasks_frozen được đặt),
   bản sao hiện có của hình ảnh vi mã trong kernel không được giải phóng.
   Và trong các hoạt động trực tuyến của CPU (trong quá trình tiếp tục/khôi phục), vì
   kernel thấy rằng nó đã có bản sao của các ảnh vi mã cho tất cả các
   CPU, nó chỉ áp dụng chúng cho CPU, tránh việc phát hiện lại CPU
   loại/kiểu máy và nhu cầu xác nhận xem các bản sửa đổi vi mã có phù hợp hay không
   có phù hợp với CPU hay không (do giả định ở trên rằng CPU vật lý
   hotplug sẽ không được thực hiện trong khoảng thời gian tạm dừng/tiếp tục hoặc ngủ đông/khôi phục
   chu kỳ).


III. vấn đề đã biết
===================

Có bất kỳ vấn đề nào đã biết khi cắm nóng CPU thông thường và tạm dừng cuộc đua không?
với nhau?

Có, chúng được liệt kê dưới đây:

1. Khi gọi hotplug CPU thông thường, đối số 'tasks_frozen' được chuyển tới
   hàm _cpu_down() và _cpu_up() là ZZ0000ZZ 0.
   Điều này có thể không phản ánh đúng trạng thái hiện tại của hệ thống, vì
   các nhiệm vụ có thể đã bị đóng băng bởi một sự kiện ngoài phạm vi, chẳng hạn như tạm dừng
   đang hoạt động. Do đó, biến cpuhp_tasks_frozen sẽ không
   phản ánh trạng thái đóng băng và các cuộc gọi lại cắm nóng CPU để đánh giá
   biến đó có thể thực thi đường dẫn mã sai.

2. Nếu quá trình kiểm tra sức chịu tải của phích cắm nóng CPU thông thường xảy ra với ngăn đông do
   đến một hoạt động tạm dừng đang diễn ra cùng lúc, thì chúng ta có thể đạt được
   tình huống được mô tả dưới đây:

* Hoạt động trực tuyến của CPU thông thường tiếp tục hành trình từ không gian người dùng
      vào nhân vì quá trình đóng băng vẫn chưa bắt đầu.
    * Sau đó, tủ đông sẽ hoạt động và đóng băng không gian người dùng.
    * Nếu CPU trực tuyến vẫn chưa hoàn thành việc cập nhật vi mã,
      bây giờ nó sẽ bắt đầu chờ trên không gian người dùng bị đóng băng trong
      Trạng thái TASK_UNINTERRUPTIBLE, để có được hình ảnh vi mã.
    * Bây giờ tủ đông tiếp tục và cố gắng đóng băng các tác vụ còn lại. Nhưng
      do sự chờ đợi đã đề cập ở trên, tủ đông sẽ không thể đóng băng
      tác vụ cắm nóng CPU trực tuyến và do đó việc đóng băng các tác vụ không thành công.

Do lỗi đóng băng tác vụ này, hoạt động tạm dừng sẽ bị
   bị hủy bỏ.
