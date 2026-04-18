.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/security/SCTP.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

====
SCTP
====

Hỗ trợ SCTP LSM
================

Móc an ninh
--------------

Để hỗ trợ mô-đun bảo mật, ba móc cụ thể SCTP đã được triển khai::

security_sctp_assoc_request()
    security_sctp_bind_connect()
    security_sctp_sk_clone()
    security_sctp_assoc_thành lập()

Việc sử dụng các hook này được mô tả bên dưới khi triển khai SELinux
được mô tả trong chương ZZ0000ZZ.


security_sctp_assoc_request()
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Chuyển ZZ0000ZZ và ZZ0001ZZ của gói INIT liên kết tới
mô-đun bảo mật. Trả về 0 nếu thành công, lỗi nếu thất bại.
::

@asoc - con trỏ tới cấu trúc liên kết sctp.
    @skb - con trỏ tới skbuff của gói liên kết.


security_sctp_bind_connect()
~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Chuyển một hoặc nhiều địa chỉ ipv4/ipv6 tới mô-đun bảo mật để xác thực
dựa trên ZZ0000ZZ sẽ dẫn đến liên kết hoặc kết nối
service như được hiển thị trong bảng kiểm tra quyền bên dưới.
Trả về 0 nếu thành công, lỗi nếu thất bại.
::

@sk - Con trỏ tới cấu trúc vớ.
    @optname - Tên của tùy chọn để xác thực.
    @address - Một hoặc nhiều địa chỉ ipv4 / ipv6.
    @addrlen - Tổng độ dài của (các) địa chỉ. Điều này được tính toán trên mỗi
               địa chỉ ipv4 hoặc ipv6 bằng sizeof(struct sockaddr_in) hoặc
               sizeof(struct sockaddr_in6).

------------------------------------------------------------------
  ZZ0000ZZ
  ZZ0001ZZ @địa chỉ chứa |
  ZZ0002ZZ-----------------------------------|
  ZZ0003ZZ Một hoặc nhiều địa chỉ ipv4 / ipv6 |
  ZZ0004ZZ Địa chỉ ipv4 hoặc ipv6 đơn |
  ZZ0005ZZ Địa chỉ ipv4 hoặc ipv6 đơn |
  ------------------------------------------------------------------

------------------------------------------------------------------
  ZZ0000ZZ
  ZZ0001ZZ @địa chỉ chứa |
  ZZ0002ZZ-----------------------------------|
  ZZ0003ZZ Một hoặc nhiều địa chỉ ipv4 / ipv6 |
  ZZ0004ZZ Một hoặc nhiều địa chỉ ipv4 / ipv6 |
  ZZ0005ZZ Địa chỉ ipv4 hoặc ipv6 đơn |
  ZZ0006ZZ Địa chỉ ipv4 hoặc ipv6 đơn |
  ------------------------------------------------------------------

Tóm tắt các mục ZZ0000ZZ như sau::

SCTP_SOCKOPT_BINDX_ADD - Cho phép thêm địa chỉ liên kết
                             được liên kết sau (tùy chọn) cuộc gọi
                             ràng buộc(3).
                             sctp_bindx(3) thêm một bộ liên kết
                             địa chỉ trên một socket.

SCTP_SOCKOPT_CONNECTX - Cho phép phân bổ nhiều
                            địa chỉ để tiếp cận một người ngang hàng
                            (nhiều nhà).
                            sctp_connectx(3) bắt đầu kết nối
                            trên ổ cắm SCTP sử dụng nhiều
                            các địa chỉ đích.

SCTP_SENDMSG_CONNECT - Bắt đầu kết nối được tạo bởi
                            sendmsg(2) hoặc sctp_sendmsg(3) trên một liên kết mới.

SCTP_PRIMARY_ADDR - Đặt địa chỉ chính cục bộ.

SCTP_SET_PEER_PRIMARY_ADDR - Yêu cầu đặt địa chỉ ngang hàng là
                                 hiệp hội chính.

SCTP_PARAM_ADD_IP - Chúng được sử dụng khi Địa chỉ động
    SCTP_PARAM_SET_PRIMARY - Cấu hình lại được bật như được giải thích bên dưới.


Để hỗ trợ Cấu hình lại địa chỉ động, các tham số sau phải được
được bật trên cả hai điểm cuối (hoặc sử dụng ZZ0000ZZ\(2) thích hợp)::

/proc/sys/net/sctp/addip_enable
    /proc/sys/net/sctp/addip_noauth_enable

sau đó ZZ0001ZZ sau đây sẽ được gửi tới thiết bị ngang hàng trong
Đoạn ASCONF khi có ZZ0000ZZ tương ứng::

@optname ASCONF Tham số
         ---------- ------------------
    SCTP_SOCKOPT_BINDX_ADD -> SCTP_PARAM_ADD_IP
    SCTP_SET_PEER_PRIMARY_ADDR -> SCTP_PARAM_SET_PRIMARY


security_sctp_sk_clone()
~~~~~~~~~~~~~~~~~~~~~~~~
Được gọi bất cứ khi nào một ổ cắm mới được tạo bởi ZZ0000ZZ\(2)
(tức là ổ cắm kiểu TCP) hoặc khi ổ cắm bị 'bóc', ví dụ như không gian người dùng
gọi ZZ0001ZZ\(3).
::

@asoc - con trỏ tới cấu trúc liên kết sctp hiện tại.
    @sk - con trỏ tới cấu trúc vớ hiện tại.
    @newsk - con trỏ tới cấu trúc tất mới.


security_sctp_assoc_thành lập()
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Được gọi khi nhận được COOKIE ACK và secid ngang hàng sẽ được
được lưu vào ZZ0000ZZ cho khách hàng::

@asoc - con trỏ tới cấu trúc liên kết sctp.
    @skb - con trỏ tới skbuff của gói COOKIE ACK.


Móc bảo mật dùng để thành lập Hiệp hội
-------------------------------------------------

Sơ đồ sau đây cho thấy việc sử dụng ZZ0000ZZ,
ZZ0001ZZ, ZZ0002ZZ khi
thành lập một hiệp hội.
::

Điểm cuối SCTP "A" SCTP điểm cuối "Z"
      =====================================
    sctp_sf_do_prm_asoc()
 Thiết lập liên kết có thể được bắt đầu
 bởi một kết nối(2), sctp_connectx(3),
 sendmsg(2) hoặc sctp_sendmsg(3).
 Những điều này sẽ dẫn đến một cuộc gọi đến
 security_sctp_bind_connect() tới
 bắt đầu một hiệp hội để
 Điểm cuối ngang hàng SCTP "Z".
         INIT --------------------------------------------->
                                                   sctp_sf_do_5_1B_init()
                                                 Trả lời một đoạn INIT.
                                             SCTP điểm cuối ngang hàng "A" đang hỏi
                                             cho một hiệp hội tạm thời.
                                             Gọi security_sctp_assoc_request()
                                             để đặt nhãn ngang hàng nếu trước tiên
                                             hiệp hội.
                                             Nếu không phải là hiệp hội đầu tiên, hãy kiểm tra
                                             nếu được phép, NẾU nên gửi:
          <---------------------------------------------- INIT ACK
          |                                  Sự kiện kiểm toán ELSE và âm thầm
          |                                       loại bỏ gói tin.
          |
    COOKIE ECHO ------------------------------------------>
                                                  sctp_sf_do_5_1D_ce()
                                             Trả lời đoạn COOKIE ECHO.
                                             Xác nhận cookie và tạo một
                                             hiệp hội lâu dài.
                                             Gọi security_sctp_assoc_request() tới
                                             làm tương tự như đối với INIT chunk Response.
          <--------------------------------------------------- COOKIE ACK
          ZZ0000ZZ
    sctp_sf_do_5_1E_ca |
 Gọi security_sctp_assoc_thành lập() |
 để đặt nhãn ngang hàng.                                   |
          ZZ0001ZZ
          |                               Nếu SCTP_SOCKET_TCP hoặc bị bong tróc
          |                               ổ cắm security_sctp_sk_clone() là
          |                               được gọi để sao chép ổ cắm mới.
          ZZ0002ZZ
      ESTABLISHED ESTABLISHED
          ZZ0003ZZ
    ------------------------------------------------------------------
    ZZ0004ZZ
    ------------------------------------------------------------------


Hỗ trợ SELinux SCTP
====================

Móc an ninh
--------------

Chương ZZ0000ZZ ở trên mô tả bảo mật SCTP sau
hook với các thông số cụ thể của SELinux được mở rộng bên dưới::

security_sctp_assoc_request()
    security_sctp_bind_connect()
    security_sctp_sk_clone()
    security_sctp_assoc_thành lập()


security_sctp_assoc_request()
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Chuyển ZZ0000ZZ và ZZ0001ZZ của gói INIT liên kết tới
mô-đun bảo mật. Trả về 0 nếu thành công, lỗi nếu thất bại.
::

@asoc - con trỏ tới cấu trúc liên kết sctp.
    @skb - con trỏ tới skbuff của gói liên kết.

Mô-đun bảo mật thực hiện các hoạt động sau:
     NẾU đây là liên kết đầu tiên trên ZZ0000ZZ, thì hãy đặt ngang hàng
     phù hợp với điều đó trong ZZ0001ZZ. Điều này sẽ đảm bảo chỉ có một bên ngang hàng
     được gán cho ZZ0002ZZ có thể hỗ trợ nhiều liên kết.

ELSE xác thực ZZ0000ZZ so với ZZ0001ZZ
     để xác định liệu sự liên kết nên được cho phép hay từ chối.

Đặt sctp ZZ0000ZZ thành sid của ổ cắm (từ ZZ0001ZZ) với
     Phần MLS được lấy từ ZZ0002ZZ. Điều này sẽ được sử dụng bởi SCTP
     Ổ cắm kiểu TCP và các kết nối bị bong tróc khi tạo ra ổ cắm mới
     được tạo ra.

Nếu tùy chọn bảo mật IP được định cấu hình (CIPSO/CALIPSO), thì địa chỉ ip
     các tùy chọn được đặt trên ổ cắm.


security_sctp_bind_connect()
~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Kiểm tra các quyền cần thiết cho địa chỉ ipv4/ipv6 dựa trên ZZ0000ZZ
như sau::

------------------------------------------------------------------
  ZZ0000ZZ
  ZZ0001ZZ @địa chỉ chứa |
  ZZ0002ZZ-----------------------------------|
  ZZ0003ZZ Một hoặc nhiều địa chỉ ipv4 / ipv6 |
  ZZ0004ZZ Địa chỉ ipv4 hoặc ipv6 đơn |
  ZZ0005ZZ Địa chỉ ipv4 hoặc ipv6 đơn |
  ------------------------------------------------------------------

------------------------------------------------------------------
  ZZ0000ZZ
  ZZ0001ZZ @địa chỉ chứa |
  ZZ0002ZZ-----------------------------------|
  ZZ0003ZZ Một hoặc nhiều địa chỉ ipv4 / ipv6 |
  ZZ0004ZZ Một hoặc nhiều địa chỉ ipv4 / ipv6 |
  ZZ0005ZZ Địa chỉ ipv4 hoặc ipv6 đơn |
  ZZ0006ZZ Địa chỉ ipv4 hoặc ipv6 đơn |
  ------------------------------------------------------------------


ZZ0001ZZ đưa ra bản tóm tắt về ZZ0000ZZ
các mục nhập và cũng mô tả quá trình xử lý đoạn ASCONF khi Địa chỉ động
Cấu hình lại được kích hoạt.


security_sctp_sk_clone()
~~~~~~~~~~~~~~~~~~~~~~~~
Được gọi bất cứ khi nào một ổ cắm mới được tạo bởi ZZ0003ZZ\(2) (tức là kiểu TCP
socket) hoặc khi ổ cắm bị 'bóc', ví dụ: các cuộc gọi vùng người dùng
ZZ0004ZZ\(3). ZZ0000ZZ sẽ thiết lập mới
socket sid và ngang hàng với cái có trong ZZ0001ZZ và
ZZ0002ZZ tương ứng.
::

@asoc - con trỏ tới cấu trúc liên kết sctp hiện tại.
    @sk - con trỏ tới cấu trúc vớ hiện tại.
    @newsk - con trỏ tới cấu trúc tất mới.


security_sctp_assoc_thành lập()
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Được gọi khi nhận được COOKIE ACK nơi nó đặt sid ngang hàng của kết nối
với điều đó trong ZZ0000ZZ::

@asoc - con trỏ tới cấu trúc liên kết sctp.
    @skb - con trỏ tới skbuff của gói COOKIE ACK.


Tuyên bố chính sách
-----------------
Lớp và quyền sau đây để hỗ trợ SCTP có sẵn trong
hạt nhân::

lớp sctp_socket kế thừa socket { node_bind }

bất cứ khi nào khả năng chính sách sau được bật::

chính sách mở rộng_socket_class;

Hỗ trợ SELinux SCTP bổ sung quyền ZZ0000ZZ để kết nối
tới một loại cổng cụ thể và quyền ZZ0001ZZ được giải thích
trong phần dưới đây.

Nếu các công cụ không gian người dùng đã được cập nhật, SCTP sẽ hỗ trợ ZZ0000ZZ
câu lệnh như trong ví dụ sau::

portcon sctp 1024-1036 system_u:object_r:sctp_ports_t:s0


Ghi nhãn ngang hàng SCTP
------------------
Ổ cắm SCTP sẽ chỉ có một nhãn ngang hàng được gán cho nó. Đây sẽ là
được giao trong quá trình thành lập hiệp hội đầu tiên. Hơn nữa
các liên kết trên ổ cắm này sẽ có nhãn ngang hàng gói của chúng so với
nhãn ngang hàng của ổ cắm và chỉ khi chúng khác nhau thì
Quyền ZZ0000ZZ được xác thực. Điều này được xác nhận bằng cách kiểm tra
socket ngang hàng dựa vào các gói nhận được sid ngang hàng để xác định xem
hiệp hội nên được cho phép hoặc từ chối.

NOTES:
   1) Nếu ghi nhãn ngang hàng không được bật thì bối cảnh ngang hàng sẽ luôn là
      ZZ0000ZZ (ZZ0001ZZ trong Chính sách tham khảo).

2) Vì SCTP có thể hỗ trợ nhiều địa chỉ truyền tải cho mỗi điểm cuối
      (multi-homing) trên một ổ cắm duy nhất, có thể định cấu hình chính sách
      và NetLabel để cung cấp các nhãn ngang hàng khác nhau cho từng nhãn này. Như
      nhãn ngang hàng của ổ cắm được xác định bởi sự vận chuyển liên kết đầu tiên
      địa chỉ, chúng tôi khuyến nghị rằng tất cả các nhãn ngang hàng đều nhất quán.

3) ZZ0000ZZ\(3) có thể được sử dụng bởi không gian người dùng để truy xuất các ổ cắm ngang hàng
      bối cảnh.

4) Mặc dù không dành riêng cho SCTP, nhưng hãy lưu ý khi sử dụng NetLabel rằng nếu nhãn
      được gán cho một giao diện cụ thể và giao diện đó 'không hoạt động',
      thì dịch vụ NetLabel sẽ xóa mục này. Vì vậy đảm bảo rằng
      các tập lệnh khởi động mạng gọi ZZ0000ZZ\(8) để đặt yêu cầu
      nhãn (xem tập lệnh trợ giúp ZZ0001ZZ\(8) để biết chi tiết).

5) Quy tắc ghi nhãn ngang hàng NetLabel SCTP được áp dụng như được thảo luận sau đây
      tập hợp các bài viết được gắn thẻ "netlabel" tại: ZZ0000ZZ

6) CIPSO chỉ được hỗ trợ cho địa chỉ IPv4: ZZ0000ZZ
      CALIPSO chỉ được hỗ trợ cho địa chỉ IPv6: ZZ0001ZZ

Lưu ý những điều sau khi kiểm tra CIPSO/CALIPSO:
         a) CIPSO sẽ gửi gói ICMP nếu gói SCTP không thể gửi được
            được giao vì nhãn không hợp lệ.
         b) CALIPSO không gửi gói ICMP, chỉ âm thầm loại bỏ nó.

7) IPSEC không được hỗ trợ vì RFC 3554 - chưa hỗ trợ sctp/ipsec
      được triển khai trong không gian người dùng (ZZ0000ZZ\(8) hoặc ZZ0001ZZ\(8)),
      mặc dù kernel hỗ trợ SCTP/IPSEC.