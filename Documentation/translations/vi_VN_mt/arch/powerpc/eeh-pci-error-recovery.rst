.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/arch/powerpc/eeh-pci-error-recovery.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=============================
Phục hồi lỗi PCI Bus EEH
=============================

Linas Vepstas <linas@austin.ibm.com>

12 tháng 1 năm 2005


Tổng quan:
---------
Máy tính pSeries và iSeries dựa trên IBM POWER bao gồm bus PCI
chip điều khiển có khả năng mở rộng để phát hiện và
báo cáo nhiều tình trạng lỗi bus PCI.  Những tính năng này
dưới tên "EEH", dành cho "Xử lý lỗi nâng cao".  EEH
các tính năng phần cứng cho phép xóa lỗi bus PCI và PCI
thẻ được "khởi động lại" mà không cần phải khởi động lại hệ điều hành
hệ thống.

Điều này trái ngược với cách xử lý lỗi PCI truyền thống, trong đó
Chip PCI được nối trực tiếp với CPU và lỗi sẽ gây ra
tình trạng dừng kiểm tra/kiểm tra máy CPU, tạm dừng hoàn toàn CPU.
Một kỹ thuật "truyền thống" khác là bỏ qua những lỗi như vậy.
có thể dẫn đến hỏng dữ liệu, cả dữ liệu người dùng hoặc dữ liệu kernel,
bộ điều hợp bị treo/không phản hồi hoặc hệ thống bị treo/khóa.  Như vậy,
Ý tưởng đằng sau EEH là hệ điều hành có thể trở nên tốt hơn
đáng tin cậy và mạnh mẽ bằng cách bảo vệ nó khỏi các lỗi PCI và đưa ra
Hệ điều hành có khả năng "khởi động lại"/khôi phục các thiết bị PCI riêng lẻ.

Các hệ thống trong tương lai từ các nhà cung cấp khác, dựa trên thông số kỹ thuật PCI-E,
có thể chứa các tính năng tương tự.


Nguyên nhân gây ra lỗi EEH
--------------------
EEH ban đầu được thiết kế để bảo vệ khỏi lỗi phần cứng, chẳng hạn như
như thẻ PCI chết vì nóng, ẩm, bụi, rung và xấu
kết nối điện. Phần lớn các lỗi EEH được thấy trong
"đời thực" là do thẻ PCI được đặt không đúng chỗ hoặc,
tiếc là khá phổ biến, do lỗi driver thiết bị, firmware thiết bị
lỗi và đôi khi là lỗi phần cứng thẻ PCI.

Lỗi phần mềm phổ biến nhất là lỗi khiến thiết bị
cố gắng đưa DMA đến một vị trí trong bộ nhớ hệ thống chưa được
dành riêng cho quyền truy cập DMA cho thẻ đó.  Đây là một tính năng mạnh mẽ,
vì nó ngăn cản điều gì; nếu không thì sẽ là ký ức im lặng
tham nhũng do DMA xấu gây ra.  Một số driver thiết bị
lỗi đã được tìm thấy và sửa theo cách này trong vài năm qua
năm.  Các nguyên nhân có thể khác gây ra lỗi EEH bao gồm dữ liệu hoặc
lỗi chẵn lẻ của dòng địa chỉ (ví dụ, do điện kém
kết nối do thẻ được đặt không đúng) và hoàn thành phân chia PCI-X
lỗi (do phần mềm, firmware thiết bị hoặc lỗi phần cứng PCI của thiết bị).
Phần lớn các "lỗi phần cứng thực sự" có thể được khắc phục bằng
tháo và đặt lại thẻ PCI một cách vật lý.


Phát hiện và phục hồi
----------------------
Trong cuộc thảo luận sau đây, một cái nhìn tổng quan chung về cách phát hiện
và khôi phục từ các lỗi EEH sẽ được trình bày. Điều này được theo sau
bằng cái nhìn tổng quan về cách triển khai hiện tại trong Linux
hạt nhân làm điều đó.  Việc thực hiện thực tế có thể thay đổi,
và một số điểm tốt hơn vẫn đang được tranh luận.  Những cái này
đến lượt nó có thể bị ảnh hưởng nếu hoặc khi các kiến trúc khác triển khai
chức năng tương tự.

Khi Cầu nối máy chủ PCI (PHB, bộ điều khiển bus kết nối
Bus PCI đến hệ thống tổ hợp điện tử CPU) phát hiện lỗi PCI
điều kiện, nó sẽ "cô lập" thẻ PCI bị ảnh hưởng.  Cách ly
sẽ chặn tất cả việc ghi (vào thẻ từ hệ thống hoặc
từ thẻ vào hệ thống), và nó sẽ khiến tất cả các lần đọc
trả về tất cả-ff (0xff, 0xffff, 0xffffffff cho các lần đọc 8/16/32-bit).
Giá trị này được chọn vì nó giống với giá trị bạn muốn
nhận được nếu thiết bị đã được rút phích cắm vật lý khỏi khe cắm.
Điều này bao gồm quyền truy cập vào bộ nhớ PCI, không gian I/O và cấu hình PCI
không gian.  Ngắt; tuy nhiên, sẽ tiếp tục được chuyển giao.

Việc phát hiện và phục hồi được thực hiện với sự trợ giúp của ppc64
phần sụn.  Các giao diện lập trình trong nhân Linux
vào phần sụn được gọi là RTAS (Tóm tắt thời gian chạy
Dịch vụ).  Nhân Linux không (không nên) truy cập
chức năng EEH trực tiếp trong chipset PCI, chủ yếu là do
có một số chipset khác nhau, mỗi loại có
giao diện và đặc điểm khác nhau. Phần sụn cung cấp một
lớp trừu tượng thống nhất sẽ hoạt động với tất cả pSeries
và phần cứng iSeries (và tương thích về phía trước).

Nếu hệ điều hành hoặc trình điều khiển thiết bị nghi ngờ rằng khe cắm PCI đã bị
EEH bị cô lập, nó có thể thực hiện lệnh gọi chương trình cơ sở để xác định xem liệu
đây là trường hợp Nếu vậy thì driver thiết bị nên tự đặt
sang trạng thái nhất quán (vì nó sẽ không thể hoàn thành bất kỳ
công việc đang chờ xử lý) và bắt đầu khôi phục thẻ.  Phục hồi bình thường
sẽ bao gồm việc đặt lại thiết bị PCI (giữ PCI #ZZ0004ZZ
ở mức cao trong hai giây), sau đó là thiết lập thiết bị
không gian cấu hình (các thanh ghi địa chỉ cơ sở (BAR's), bộ đếm thời gian trễ,
kích thước dòng bộ đệm, dòng ngắt, v.v.).  Tiếp theo đó là một
khởi động lại trình điều khiển thiết bị.  Trong trường hợp xấu nhất,
nguồn điện của thẻ có thể được chuyển đổi, ít nhất là trên các thiết bị có khả năng cắm nóng
khe cắm.  Về nguyên tắc, các lớp ở trên trình điều khiển thiết bị có thể
không cần biết card PCI đã được "khởi động lại" trong lần này
cách; lý tưởng nhất là có nhiều nhất một khoảng dừng trong Ethernet/đĩa/USB
I/O trong khi thẻ đang được reset.

Nếu thẻ không thể khôi phục được sau ba hoặc bốn lần đặt lại,
Trình điều khiển hạt nhân/thiết bị nên giả sử trường hợp xấu nhất là
thẻ đã chết hoàn toàn và báo cáo lỗi này cho quản trị viên hệ thống.
Ngoài ra, các thông báo lỗi được báo cáo thông qua RTAS và cả thông qua
syslogd (/var/log/messages) để cảnh báo quản trị viên hệ thống về việc đặt lại PCI.
Cách chính xác để xử lý các bộ điều hợp bị lỗi là sử dụng tiêu chuẩn
Công cụ cắm nóng PCI để loại bỏ và thay thế thẻ chết.


Triển khai PPC64 Linux EEH hiện tại
--------------------------------------
Tại thời điểm này, cơ chế phục hồi EEH chung đã được triển khai,
để các trình điều khiển thiết bị riêng lẻ không cần phải sửa đổi để hỗ trợ
Phục hồi EEH.  Cơ chế chung này hỗ trợ trên phích cắm nóng PCI
cơ sở hạ tầng và phân bổ các sự kiện thông qua không gian người dùng/udev
cơ sở hạ tầng.  Sau đây là mô tả chi tiết về cách thực hiện điều này
đã hoàn thành.

EEH phải được kích hoạt trong PHB từ rất sớm trong quá trình khởi động,
và liệu khe cắm PCI có được cắm nóng hay không. Cái trước được thực hiện bởi
eeh_init() trong Arch/powerpc/platforms/pseries/eeh.c và phiên bản sau bởi
driver/pci/hotplug/pSeries_pci.c gọi mã eeh.c.
EEH phải được bật trước khi có thể tiến hành quét thiết bị PCI.
Phần cứng Power5 hiện tại sẽ không hoạt động trừ khi EEH được bật;
mặc dù Power4 cũ hơn có thể chạy khi nó bị vô hiệu hóa.  Một cách hiệu quả,
EEH không thể tắt được nữa.  Thiết bị PCI ZZ0000ZZ được
đã đăng ký với mã EEH; mã EEH cần biết về
phạm vi địa chỉ I/O của thiết bị PCI để phát hiện
lỗi.  Cho một địa chỉ tùy ý, thủ tục
pci_get_device_by_addr() sẽ tìm thấy thiết bị pci được liên kết
với địa chỉ đó (nếu có).

Các macro Arch/powerpc/include/asm/io.h mặc định readb(), inb(), insb(),
v.v. bao gồm kiểm tra xem liệu đọc i/o có trả về tất cả-0xff hay không.
Nếu vậy, chúng sẽ thực hiện lệnh gọi đến eeh_dn_check_failure(), và lần lượt
hỏi phần sụn xem giá trị của all-ff có phải là dấu hiệu của EEH thực sự không
lỗi.  Nếu không, quá trình xử lý vẫn tiếp tục như bình thường.  sự vĩ đại
tổng số các cảnh báo sai hoặc "dương tính giả" này có thể là
thấy trong /proc/ppc64/eeh (có thể thay đổi).  Thông thường, gần như
tất cả những điều này xảy ra trong quá trình khởi động, khi bus PCI được quét, trong đó
một số lượng lớn các lần đọc 0xff là một phần của quy trình quét bus.

Nếu phát hiện thấy khe bị đóng băng, hãy mã hóa
Arch/powerpc/platforms/pseries/eeh.c sẽ in dấu vết ngăn xếp tới
nhật ký hệ thống (/var/log/tin nhắn).  Dấu vết ngăn xếp này đã được chứng minh là rất
hữu ích cho các tác giả trình điều khiển thiết bị để tìm hiểu EEH ở điểm nào
đã phát hiện ra lỗi vì bản thân lỗi thường xảy ra nhẹ
trước đó.

Tiếp theo, nó sử dụng cơ chế chuỗi thông báo/hàng đợi công việc của nhân Linux để
cho phép bất kỳ bên quan tâm nào tìm hiểu về sự thất bại.  Thiết bị
trình điều khiển hoặc các phần khác của kernel có thể sử dụng
ZZ0000ZZ để tìm hiểu về EEH
sự kiện.  Sự kiện này sẽ bao gồm một con trỏ tới thiết bị pci,
nút thiết bị và một số thông tin trạng thái.  Người nhận sự kiện có thể "làm như
họ ước"; trình xử lý mặc định sẽ được mô tả thêm trong phần này
phần.

Để hỗ trợ việc khôi phục thiết bị, eeh.c xuất tệp
các chức năng sau:

rtas_set_slot_reset()
   khẳng định dòng PCI #ZZ0001ZZ trong 1/8 giây
rtas_configure_bridge()
   yêu cầu phần mềm cấu hình bất kỳ cầu nối PCI nào
   nằm theo cấu trúc liên kết dưới khe cắm pci.
eeh_save_bars() và eeh_restore_bars():
   lưu và khôi phục PCI
   thông tin không gian cấu hình cho một thiết bị và mọi thiết bị bên dưới nó.


Trình xử lý các sự kiện notifier_block EEH được triển khai trong
trình điều khiển/pci/hotplug/pSeries_pci.c, được gọi là hand_eeh_events().
Nó lưu thiết bị BAR và sau đó gọi rpaphp_unconfig_pci_adapter().
Cuộc gọi cuối cùng này khiến trình điều khiển thiết bị cho thẻ bị dừng,
khiến các sự kiện đi ra ngoài không gian của người dùng. Điều này kích hoạt
tập lệnh không gian người dùng có thể đưa ra các lệnh như "ifdown eth0"
cho thẻ ethernet, v.v.  Trình xử lý này sau đó sẽ ngủ trong 5 giây,
hy vọng cung cấp cho các tập lệnh không gian người dùng đủ thời gian để hoàn thành.
Sau đó, nó đặt lại thẻ PCI, cấu hình lại thiết bị BAR và
bất kỳ cây cầu nào bên dưới. Sau đó nó gọi rpaphp_enable_pci_slot(),
khởi động lại trình điều khiển thiết bị và kích hoạt nhiều không gian người dùng hơn
sự kiện (ví dụ: gọi "ifup eth0" cho thẻ ethernet).


Tắt thiết bị và sự kiện trong không gian người dùng
-------------------------------------
Phần này ghi lại những gì xảy ra khi khe cắm pci không được định cấu hình,
tập trung vào cách tắt trình điều khiển thiết bị và cách thức
các sự kiện được gửi đến các tập lệnh không gian người dùng.

Sau đây là chuỗi ví dụ về các sự kiện khiến trình điều khiển thiết bị
chức năng đóng được gọi trong giai đoạn đầu tiên của quá trình thiết lập lại EEH.
Trình tự sau đây là ví dụ về trình điều khiển thiết bị pcnet32::

rpa_php_unconfig_pci_adapter (khe cấu trúc *) // trong rpaphp_pci.c
    {
      cuộc gọi
      pci_remove_bus_device (struct pci_dev *) // trong /drivers/pci/remove.c
      {
        cuộc gọi
        pci_destroy_dev (cấu trúc pci_dev *)
        {
          cuộc gọi
          device_unregister (&dev->dev) // trong /drivers/base/core.c
          {
            cuộc gọi
            device_del (thiết bị cấu trúc *)
            {
              cuộc gọi
              bus_remove_device() // trong /drivers/base/bus.c
              {
                cuộc gọi
                device_release_driver()
                {
                  cuộc gọi
                  struct device_driver->remove() chỉ là
                  pci_device_remove() // trong /drivers/pci/pci_driver.c
                  {
                    cuộc gọi
                    struct pci_driver->remove() chỉ là
                    pcnet32_remove_one() // trong /drivers/net/pcnet32.c
                    {
                      cuộc gọi
                      unregister_netdev() // trong /net/core/dev.c
                      {
                        cuộc gọi
                        dev_close() // trong /net/core/dev.c
                        {
                           gọi dev->stop();
                           chỉ là pcnet32_close() // trong pcnet32.c
                           {
                             làm những gì bạn muốn
                             để dừng thiết bị
                           }
                        }
                     }
                   cái nào
                   giải phóng bộ nhớ trình điều khiển thiết bị pcnet32
                }
     }}}}}}


trong trình điều khiển/pci/pci_driver.c,
struct device_driver->remove() chỉ là pci_device_remove()
gọi struct pci_driver->remove() là pcnet32_remove_one()
gọi unregister_netdev() (trong net/core/dev.c)
gọi dev_close() (trong net/core/dev.c)
gọi dev->stop() là pcnet32_close()
sau đó thực hiện tắt máy thích hợp.

---

Sau đây là dấu vết ngăn xếp tương tự cho các sự kiện được gửi tới không gian người dùng
khi thiết bị pci chưa được định cấu hình::

rpa_php_unconfig_pci_adapter() { // trong rpaphp_pci.c
    cuộc gọi
    pci_remove_bus_device (struct pci_dev *) { // trong /drivers/pci/remove.c
      cuộc gọi
      pci_destroy_dev (struct pci_dev *) {
        cuộc gọi
        device_unregister (&dev->dev) { // trong /drivers/base/core.c
          cuộc gọi
          device_del(struct device * dev) { // trong /drivers/base/core.c
            cuộc gọi
            kobject_del() { //trong /libs/kobject.c
              cuộc gọi
              kobject_uevent() { // trong /libs/kobject.c
                cuộc gọi
                kset_uevent() { // trong /lib/kobject.c
                  cuộc gọi
                  kset->uevent_ops->uevent() // thực sự chỉ là
                  một cuộc gọi đến
                  dev_uevent() { // trong /drivers/base/core.c
                    cuộc gọi
                    dev->bus->uevent() thực sự chỉ là một cuộc gọi đến
                    pci_uevent () { // trong trình điều khiển/pci/hotplug.c
                      in tên thiết bị, v.v....
                   }
                 }
                 sau đó kobject_uevent() gửi một sự kiện liên kết mạng tới không gian người dùng
                 --> sự kiện không gian người dùng
                 (trong quá trình khởi động sớm, không ai nghe các sự kiện liên kết mạng và
                 kobject_uevent() thực thi uevent_helper[], chạy chương trình
                 quá trình sự kiện/sbin/hotplug)
             }
           }
           kobject_del() sau đó gọi sysfs_remove_dir(), điều này sẽ
           kích hoạt bất kỳ trình nền không gian người dùng nào đang xem /sysfs,
           và thông báo sự kiện xóa.


Ưu và nhược điểm của thiết kế hiện tại
-------------------------------------
Có một số vấn đề với thiết kế khôi phục phần mềm EEH hiện tại,
có thể được giải quyết trong các lần sửa đổi trong tương lai.  Nhưng trước tiên, hãy lưu ý rằng
Điểm cộng lớn của thiết kế hiện tại là không cần thực hiện thay đổi nào đối với
trình điều khiển thiết bị riêng lẻ, để thiết kế hiện tại tạo ra một mạng lưới rộng khắp.
Điểm tiêu cực lớn nhất của thiết kế là nó có khả năng làm xáo trộn
daemon mạng và hệ thống tập tin không cần phải quấy rầy.

- Một phàn nàn nhỏ là việc reset card mạng gây ra
   không gian người dùng liên tiếp ifdown/ifup ợ có khả năng làm phiền
   daemon mạng, thậm chí không cần biết rằng pci
   thẻ đã được khởi động lại.

- Một mối lo ngại nghiêm trọng hơn là việc thiết lập lại tương tự đối với các thiết bị SCSI,
   gây ra sự tàn phá cho hệ thống tập tin được gắn kết.  Tập lệnh không thể hậu thực tế
   ngắt kết nối hệ thống tệp mà không xóa bộ đệm đang chờ xử lý, nhưng điều này
   là không thể, vì I/O đã bị dừng rồi.  Như vậy,
   lý tưởng nhất là việc thiết lập lại sẽ xảy ra ở hoặc bên dưới lớp khối,
   để hệ thống tập tin không bị xáo trộn.

Ext3fs có vẻ chấp nhận được, thử đọc/ghi lại cho đến khi thực hiện được
   thành công. Cả hai đều chỉ được thử nghiệm nhẹ trong kịch bản này.

Hệ thống con chung SCSI đã có mã tích hợp để thực hiện
   Đặt lại thiết bị SCSI, đặt lại bus SCSI và bộ chuyển đổi bus máy chủ SCSI
   (HBA) đặt lại.  Chúng được xếp thành một chuỗi các nỗ lực
   đặt lại nếu lệnh SCSI không thành công. Những điều này hoàn toàn bị ẩn
   từ lớp khối.  Sẽ rất tự nhiên nếu thêm EEH
   thiết lập lại chuỗi sự kiện này.

- Nếu xảy ra lỗi SCSI đối với thiết bị root, tất cả sẽ bị mất trừ khi
   quản trị viên hệ thống đã có tầm nhìn xa để chạy /bin, /sbin, /etc, /var
   v.v., hết ramdisk/tmpfs.


Kết luận
-----------
Có tiến bộ phía trước...
