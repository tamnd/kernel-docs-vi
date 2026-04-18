.. SPDX-License-Identifier: GPL-2.0+

.. include:: ../../../../../disclaimer-vi.rst

:Original: Documentation/networking/device_drivers/ethernet/intel/idpf.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=========================================================================================
idpf Linux* Trình điều khiển cơ sở cho Chức năng đường dẫn dữ liệu cơ sở hạ tầng Intel(R)
=========================================================================================

Trình điều khiển Intel idpf Linux.
Copyright(C) 2023 Tập đoàn Intel.

.. contents::

Trình điều khiển idpf đóng vai trò là cả Chức năng vật lý (PF) và Chức năng ảo
(VF) cho Chức năng đường dẫn dữ liệu cơ sở hạ tầng Intel(R).

Thông tin trình điều khiển có thể được lấy bằng ethtool, lspci và ip.

Đối với các câu hỏi liên quan đến yêu cầu phần cứng, hãy tham khảo tài liệu
được cung cấp cùng với bộ điều hợp Intel của bạn. Tất cả các yêu cầu phần cứng được liệt kê đều áp dụng để sử dụng
với Linux.


Xác định bộ điều hợp của bạn
========================
Để biết thông tin về cách xác định bộ điều hợp của bạn và để có phiên bản Intel mới nhất
trình điều khiển mạng, hãy tham khảo trang web Hỗ trợ của Intel:
ZZ0000ZZ


Các tính năng và cấu hình bổ sung
======================================

công cụ đạo đức
-------
Trình điều khiển sử dụng giao diện ethtool để cấu hình trình điều khiển và
chẩn đoán cũng như hiển thị thông tin thống kê. Công cụ đạo đức mới nhất
Phiên bản này là cần thiết cho chức năng này. Nếu bạn chưa có, bạn có thể
lấy nó tại:
ZZ0000ZZ


Xem tin nhắn liên kết
---------------------
Thông báo liên kết sẽ không được hiển thị trên bảng điều khiển nếu việc phân phối
hạn chế tin nhắn hệ thống. Để xem thông báo liên kết trình điều khiển mạng trên
bảng điều khiển của bạn, hãy đặt dmesg thành 8 bằng cách nhập thông tin sau::

# dmesg-n 8

.. note::
   This setting is not saved across reboots.


Khung Jumbo
------------
Hỗ trợ Khung Jumbo được bật bằng cách thay đổi Đơn vị truyền tối đa (MTU)
đến giá trị lớn hơn giá trị mặc định là 1500.

Sử dụng lệnh ip để tăng kích thước MTU. Ví dụ: nhập như sau
trong đó <ethX> là số giao diện::

Bộ liên kết # ip mtu 9000 dev <ethX>
  Liên kết # ip thiết lập dev <ethX>

.. note::
   The maximum MTU setting for jumbo frames is 9706. This corresponds to the
   maximum jumbo frame size of 9728 bytes.

.. note::
   This driver will attempt to use multiple page sized buffers to receive
   each jumbo packet. This should help to avoid buffer starvation issues when
   allocating receive packets.

.. note::
   Packet loss may have a greater impact on throughput when you use jumbo
   frames. If you observe a drop in performance after enabling jumbo frames,
   enabling flow control may mitigate the issue.


Tối ưu hóa hiệu suất
========================
Các cài đặt mặc định của trình điều khiển nhằm mục đích phù hợp với nhiều khối lượng công việc khác nhau, nhưng nếu tiếp tục
cần phải tối ưu hóa, chúng tôi khuyên bạn nên thử nghiệm những điều sau
cài đặt.


Giới hạn tốc độ ngắt
-----------------------
Trình điều khiển này hỗ trợ cơ chế điều chỉnh tốc độ ngắt thích ứng (ITR)
được điều chỉnh cho khối lượng công việc chung. Người dùng có thể tùy chỉnh tốc độ ngắt
kiểm soát khối lượng công việc cụ thể, thông qua ethtool, điều chỉnh số lượng
micro giây giữa các lần ngắt.

Để đặt tốc độ ngắt theo cách thủ công, bạn phải tắt chế độ thích ứng::

# ethtool -C <ethX> tắt Adaptive-rx Tắt Adaptive-tx

Để sử dụng CPU thấp hơn:
 - Vô hiệu hóa ITR thích ứng và giảm các ngắt Rx và Tx. Các ví dụ dưới đây
   ảnh hưởng đến mọi hàng đợi của giao diện được chỉ định.

- Đặt rx-usecs và tx-usecs thành 80 sẽ giới hạn số lần ngắt trong khoảng
   12.500 ngắt mỗi giây trên mỗi hàng đợi::

# ethtool -C <ethX> tắt Adaptive-rx Adaptive-tx tắt rx-usecs 80
     tx-usecs 80

Để giảm độ trễ:
 - Tắt ITR và ITR thích ứng bằng cách đặt rx-usecs và tx-usecs thành 0
   sử dụng ethtool::

# ethtool -C <ethX> tắt Adaptive-rx Adaptive-tx tắt rx-usecs 0
     tx-usecs 0

Cài đặt tốc độ ngắt trên mỗi hàng đợi:
 - Các ví dụ sau dành cho hàng đợi 1 và 3, nhưng bạn có thể điều chỉnh khác
   hàng đợi.

- Để tắt ITR thích ứng Rx và đặt Rx ITR tĩnh thành 10 micro giây hoặc
   khoảng 100.000 ngắt/giây, đối với hàng đợi 1 và 3::

# ethtool --per-queue <ethX> queue_mask 0xa --tắt liên kết thích ứng-rx
     rx-usecs 10

- Để hiển thị cài đặt hợp nhất hiện tại cho hàng đợi 1 và 3::

# ethtool --per-queue <ethX> queue_mask 0xa --show-coalesce



Môi trường ảo hóa
------------------------
Ngoài những gợi ý khác trong phần này, những điều sau đây có thể
hữu ích để tối ưu hóa hiệu suất trong VM.

- Sử dụng cơ chế thích hợp (vcpupin) trong VM, ghim các CPU vào
   LCPU riêng lẻ, đảm bảo sử dụng một bộ CPU có trong
   local_cpulist của thiết bị: /sys/class/net/<ethX>/device/local_cpulist.

- Định cấu hình càng nhiều hàng đợi Rx/Tx trong VM càng tốt. (Xem trình điều khiển idpf
   tài liệu về số lượng hàng đợi được hỗ trợ.) Ví dụ::

# ethtool -L <virt_interface> rx <max> tx <max>


Ủng hộ
=======
Để biết thông tin chung, hãy truy cập trang web hỗ trợ của Intel tại:
ZZ0000ZZ

Nếu xác định được sự cố với mã nguồn đã phát hành trên hạt nhân được hỗ trợ
với bộ điều hợp được hỗ trợ, hãy gửi email thông tin cụ thể liên quan đến sự cố
tới intel-wired-lan@lists.osuosl.org.


Nhãn hiệu
==========
Intel là nhãn hiệu hoặc nhãn hiệu đã đăng ký của Tập đoàn Intel hoặc
các công ty con ở Hoa Kỳ và/hoặc các quốc gia khác.

* Các tên và thương hiệu khác có thể được coi là tài sản của người khác.