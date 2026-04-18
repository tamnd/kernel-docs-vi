.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/pcmcia/driver-changes.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

================
Thay đổi trình điều khiển
==============

Tệp này nêu chi tiết những thay đổi trong 2.6 ảnh hưởng đến tác giả trình điều khiển thẻ PCMCIA:

* pcmcia_loop_config() và tự động cấu hình (kể từ 2.6.36)
   Nếu ZZ0000ZZ được đặt tương ứng,
   pcmcia_loop_config() hiện thiết lập các giá trị cấu hình nhất định
   tự động, mặc dù trình điều khiển vẫn có thể ghi đè cài đặt
   trong chức năng gọi lại. Các tùy chọn cấu hình tự động sau
   được cung cấp tại thời điểm này:

- CONF_AUTO_CHECK_VCC : kiểm tra Vcc phù hợp
	- CONF_AUTO_SET_VPP: đặt Vpp
	- CONF_AUTO_AUDIO: tự động kích hoạt đường truyền âm thanh nếu cần
	- CONF_AUTO_SET_IO : thiết lập tài nguyên ioport (->resource[0,1])
	- CONF_AUTO_SET_IOMEM : đặt tài nguyên iomem đầu tiên (->resource[2])

* pcmcia_request_configuration -> pcmcia_enable_device (kể từ phiên bản 2.6.36)
   pcmcia_request_configuration() đã được đổi tên thành pcmcia_enable_device(),
   vì nó phản chiếu pcmcia_disable_device(). Cài đặt cấu hình bây giờ
   được lưu trữ trong struct pcmcia_device, ví dụ: trong các trường config_flags,
   config_index, config_base, vpp.

* thay đổi pcmcia_request_window (kể từ phiên bản 2.6.36)
   Thay vì win_req_t, trình điều khiển hiện được yêu cầu điền vào
   ZZ0000ZZ cho tối đa bốn cổng ioport
   phạm vi. Sau lệnh gọi tới pcmcia_request_window(), các vùng được tìm thấy ở đó
   được bảo lưu và có thể được sử dụng ngay lập tức -- cho đến khi pcmcia_release_window()
   được gọi.

* thay đổi pcmcia_request_io (kể từ phiên bản 2.6.36)
   Thay vì io_req_t, trình điều khiển hiện được yêu cầu điền vào
   ZZ0000ZZ cho tối đa hai cổng ioport
   phạm vi. Sau cuộc gọi tới pcmcia_request_io(), các cổng được tìm thấy ở đó
   được bảo lưu, sau khi gọi pcmcia_request_configuration(), chúng có thể
   được sử dụng.

* Không có dev_info_t, không có cs_types.h (kể từ phiên bản 2.6.36)
   dev_info_t và một số typedef khác sẽ bị xóa. Không còn sử dụng chúng nữa
   trong trình điều khiển thiết bị PCMCIA. Ngoài ra, không bao gồm pcmcia/cs_types.h, vì
   tập tin này đã biến mất.

* Không có dev_node_t (kể từ phiên bản 2.6.35)
   Không cần phải điền vào cấu trúc "dev_node_t" nữa.

* Quy tắc yêu cầu IRQ mới (kể từ 2.6.35)
   Thay vì giao diện pcmcia_request_irq() cũ, trình điều khiển giờ đây có thể
   chọn giữa:

- gọi trực tiếp request_irq/free_irq. Sử dụng IRQ từ ZZ0000ZZ.
   - sử dụng pcmcia_request_irq(p_dev, handler_t); lõi PCMCIA sẽ
     tự động dọn dẹp các cuộc gọi đến pcmcia_disable_device() hoặc
     phóng thiết bị.

* không có cs_error / CS_CHECK / CONFIG_PCMCIA_DEBUG (kể từ phiên bản 2.6.33)
   Thay vì gọi lại cs_error() hoặc macro CS_CHECK(), vui lòng sử dụng
   Kiểm tra các giá trị trả về theo kiểu Linux và -- nếu cần -- gỡ lỗi
   tin nhắn sử dụng "dev_dbg()" hoặc "pr_debug()".

* Truy cập bộ dữ liệu CIS mới (kể từ 2.6.33)
   Thay vì pcmcia_get_{first,next__tuple(), pcmcia_get_tuple_data() và
   pcmcia_parse_tuple(), trình điều khiển sẽ sử dụng "pcmcia_get_tuple()" nếu đúng như vậy
   chỉ quan tâm đến một bộ dữ liệu (thô) hoặc "pcmcia_loop_tuple()" nếu có
   quan tâm đến tất cả các bộ dữ liệu cùng loại. Để giải mã MAC từ CISTPL_FUNCE,
   một người trợ giúp mới "pcmcia_get_mac_from_cis()" đã được thêm vào.

* Trình trợ giúp vòng lặp cấu hình mới (kể từ 2.6.28)
   Bằng cách gọi pcmcia_loop_config(), trình điều khiển có thể lặp lại tất cả các
   các tùy chọn cấu hình. Trong giai đoạn thăm dò() của trình điều khiển, người ta không cần
   để sử dụng pcmcia_get_{first,next__tuple, pcmcia_get_tuple_data và
   pcmcia_parse_tuple trực tiếp trong hầu hết các trường hợp nếu không phải tất cả.

* Trình trợ giúp phát hành mới (kể từ 2.6.17)
   Thay vì gọi pcmcia_release_{configuration,io,irq,win}, tất cả chỉ là
   điều cần thiết bây giờ là gọi pcmcia_disable_device. Vì không có giá trị hợp lệ
   lý do còn lại để gọi pcmcia_release_io và pcmcia_release_irq,
   xuất khẩu cho họ đã bị loại bỏ.

* Thống nhất mã sự kiện tách và REMOVAL, cũng như đính kèm và INSERTION
  mã (kể từ 2.6.16)::

khoảng trống (*remove)          (struct pcmcia_device *dev);
       int (*probe)            (struct pcmcia_device *dev);

* Di chuyển tạm dừng, tiếp tục và đặt lại ra khỏi trình xử lý sự kiện (kể từ 2.6.16)::

int (*suspend)          (struct pcmcia_device *dev);
       int (*resume)           (struct pcmcia_device *dev);

nên được khởi tạo trong struct pcmcia_driver và xử lý
  Sự kiện (SUSPEND == RESET_PHYSICAL) và (RESUME == CARD_RESET)

* khởi tạo trình xử lý sự kiện trong struct pcmcia_driver (kể từ phiên bản 2.6.13)
   Trình xử lý sự kiện được thông báo về tất cả các sự kiện và phải được khởi tạo
   như lệnh gọi lại sự kiện() trong cấu trúc pcmcia_driver của trình điều khiển.

* pcmcia/version.h không nên được sử dụng (kể từ phiên bản 2.6.13)
   Tập tin này cuối cùng sẽ bị xóa.

* thiết bị trong nhân<->khớp trình điều khiển (kể từ 2.6.13)
   Giờ đây, các thiết bị PCMCIA và trình điều khiển chính xác của chúng có thể được kết hợp trong
   không gian hạt nhân. Xem 'devicetable.txt' để biết chi tiết.

* Tích hợp kiểu thiết bị (kể từ 2.6.11)
   Cấu trúc pcmcia_device được đăng ký với lõi mẫu thiết bị,
   và có thể được sử dụng (ví dụ: đối với SET_NETDEV_DEV) bằng cách sử dụng
   hand_to_dev(client_handle_t * xử lý).

* Chuyển đổi địa chỉ cổng I/O nội bộ thành unsigned int (kể từ 2.6.11)
   ioaddr_t nên được thay thế bằng unsigned int trong trình điều khiển thẻ PCMCIA.

* tham số irq_mask và irq_list (kể từ phiên bản 2.6.11)
   Các tham số irq_mask và irq_list không còn được sử dụng trong
   Trình điều khiển thẻ PCMCIA. Thay vào đó, nhiệm vụ của lõi PCMCIA là
   xác định IRQ nào nên được sử dụng. Do đó, liên kết->irq.IRQInfo2
   bị bỏ qua.

* client->Sự kiện đang chờ xử lý không còn nữa (kể từ phiên bản 2.6.11)
   client->PendingEvents không còn khả dụng nữa.

* client->Thuộc tính không còn nữa (kể từ phiên bản 2.6.11)
   client->Thuộc tính không được sử dụng, do đó nó bị xóa khỏi tất cả
   Trình điều khiển thẻ PCMCIA

* các chức năng cốt lõi không còn khả dụng (kể từ phiên bản 2.6.11)
   Các chức năng sau đã bị xóa khỏi nguồn kernel
   bởi vì chúng không được sử dụng bởi tất cả các trình điều khiển trong kernel và không có trình điều khiển bên ngoài
   người lái xe đã được báo cáo là dựa vào họ::

pcmcia_get_first_khu vực()
	pcmcia_get_next_khu vực()
	pcmcia_modify_window()
	pcmcia_set_event_mask()
	pcmcia_get_first_window()
	pcmcia_get_next_window()

* lặp lại danh sách thiết bị khi loại bỏ mô-đun (kể từ 2.6.10)
   Không còn cần thiết phải lặp lại nội bộ của trình điều khiển
   danh sách khách hàng và gọi hàm ->detach() khi xóa mô-đun.

* Quản lý tài nguyên. (kể từ phiên bản 2.6.8)
   Mặc dù hệ thống con PCMCIA sẽ phân bổ tài nguyên cho thẻ,
   nó không còn đánh dấu các tài nguyên này đang bận nữa. Điều này có nghĩa là người lái xe
   tác giả hiện có trách nhiệm xác nhận quyền sở hữu tài nguyên của bạn theo
   trình điều khiển khác trong Linux. Bạn nên sử dụng request_zone() để đánh dấu
   Các vùng IO đang sử dụng của bạn và request_mem_khu vực() để đánh dấu
   vùng nhớ đang được sử dụng. Đối số tên phải là một con trỏ tới
   tên tài xế của bạn. Ví dụ: đối với pcnet_cs, tên phải trỏ đến
   chuỗi "pcnet_cs".

* Dịch vụ thẻ đã biến mất
  CardServices() trong 2.4 chỉ là một câu lệnh chuyển đổi lớn để gọi nhiều
  dịch vụ.  Trong 2.6, tất cả các điểm vào đó đều được xuất và được gọi
  trực tiếp (ngoại trừ pcmcia_report_error(), thay vào đó chỉ cần sử dụng cs_error()).

*cấu trúc pcmcia_driver
  Bạn cần sử dụng struct pcmcia_driver và pcmcia_{un,}register_driver
  thay vì {un,}register_pccard_driver
