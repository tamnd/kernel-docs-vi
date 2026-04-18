.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/networking/tipc.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

===================
Hạt nhân Linux TIPC
=================

Giới thiệu
============

TIPC (Giao tiếp giữa các quá trình trong suốt) là một giao thức được thiết kế đặc biệt
được thiết kế để liên lạc nội bộ cụm. Nó có thể được cấu hình để truyền
tin nhắn trên UDP hoặc trực tiếp qua Ethernet. Việc gửi tin nhắn là
trình tự được đảm bảo, không bị mất mát và được kiểm soát dòng chảy. Thời gian trễ ngắn hơn
hơn bất kỳ giao thức nào đã biết khác, trong khi thông lượng tối đa có thể so sánh với
của TCP.

Tính năng TIPC
-------------

- Dịch vụ IPC toàn cụm

Bạn đã bao giờ ước mình có được sự tiện lợi của Ổ cắm tên miền Unix ngay cả khi
  truyền dữ liệu giữa các nút cụm? Nơi bạn tự xác định
  địa chỉ bạn muốn liên kết và sử dụng? Nơi bạn không phải thực hiện DNS
  tra cứu và lo lắng về địa chỉ IP? Nơi bạn không phải bắt đầu hẹn giờ
  để theo dõi sự tồn tại liên tục của các ổ cắm ngang hàng? Tuy nhiên, nếu không có
  nhược điểm của loại ổ cắm đó, chẳng hạn như nguy cơ các nút in còn sót lại?

Chào mừng bạn đến với dịch vụ Giao tiếp giữa các quá trình minh bạch, gọi tắt là TIPC,
  mang lại cho bạn tất cả những điều này và nhiều hơn thế nữa.

- Địa chỉ dịch vụ

Một khái niệm cơ bản trong TIPC là Địa chỉ dịch vụ khiến nó
  lập trình viên có thể chọn địa chỉ của riêng mình, liên kết nó với máy chủ
  socket và cho phép các chương trình máy khách chỉ sử dụng địa chỉ đó để gửi tin nhắn.

- Theo dõi dịch vụ

Một khách hàng muốn chờ máy chủ sẵn sàng sử dụng Dịch vụ
  Cơ chế theo dõi để đăng ký các sự kiện ràng buộc và hủy ràng buộc/đóng cho
  socket có địa chỉ dịch vụ liên quan.

Cơ chế theo dõi dịch vụ cũng có thể được sử dụng để Theo dõi cấu trúc liên kết cụm,
  tức là đăng ký tính khả dụng/không khả dụng của các nút cụm.

Tương tự, cơ chế theo dõi dịch vụ có thể được sử dụng cho Kết nối cụm
  Theo dõi, tức là đăng ký các sự kiện tăng/giảm cho các liên kết riêng lẻ giữa
  các nút cụm.

- Chế độ truyền

Sử dụng địa chỉ dịch vụ, máy khách có thể gửi tin nhắn datagram đến ổ cắm máy chủ.

Sử dụng cùng loại địa chỉ, nó có thể thiết lập kết nối tới nơi chấp nhận
  ổ cắm máy chủ.

Nó cũng có thể sử dụng địa chỉ dịch vụ để tạo và tham gia Nhóm Truyền thông,
  đó là biểu hiện TIPC của bus tin nhắn không cần môi giới.

Multicast với hiệu suất rất tốt và khả năng mở rộng có sẵn ở cả
  chế độ datagram và chế độ nhóm truyền thông.

- Liên kết nút liên

Giao tiếp giữa hai nút bất kỳ trong một cụm được duy trì bởi một hoặc hai
  Liên kết nút liên kết, vừa đảm bảo tính toàn vẹn lưu lượng dữ liệu vừa giám sát
  tính sẵn có của nút ngang hàng.

- Khả năng mở rộng cụm

Bằng cách áp dụng thuật toán Giám sát vòng chồng chéo trên các liên kết giữa các nút
  có thể mở rộng quy mô cụm TIPC lên tới 1000 nút với tốc độ được duy trì
  thời gian phát hiện lỗi hàng xóm là 1-2 giây. Đối với các cụm nhỏ hơn, điều này
  thời gian có thể được thực hiện ngắn hơn nhiều.

- Khám phá hàng xóm

Việc khám phá nút lân cận trong cụm được thực hiện bằng phát sóng Ethernet hoặc UDP
  multicast, khi bất kỳ dịch vụ nào trong số đó có sẵn. Nếu không, cấu hình ngang hàng
  Địa chỉ IP có thể được sử dụng.

- Cấu hình

Khi chạy TIPC ở chế độ nút đơn, không cần cấu hình gì.
  Khi chạy ở chế độ cụm, TIPC tối thiểu phải được cung cấp một địa chỉ nút
  (trước Linux 4.17) và cho biết nên đính kèm vào giao diện nào. "tipc"
  công cụ cấu hình giúp có thể thêm và duy trì nhiều hơn nữa
  các thông số cấu hình.

- Hiệu suất

Thời gian trễ truyền tin nhắn TIPC tốt hơn bất kỳ giao thức nào đã biết khác.
  Thông lượng byte tối đa cho các kết nối giữa các nút vẫn thấp hơn một chút so với
  đối với TCP, trong khi chúng vượt trội hơn về thông lượng trong nút và giữa các vùng chứa
  trên cùng một máy chủ.

- Hỗ trợ ngôn ngữ

Người dùng TIPC API có hỗ trợ cho C, Python, Perl, Ruby, D và Go.

Thêm thông tin
----------------

- Cách thiết lập TIPC:

ZZ0000ZZ

- Cách lập trình với TIPC:

ZZ0000ZZ

- Cách đóng góp cho TIPC:

ZZ0000ZZ

- Thông tin chi tiết về thông số kỹ thuật TIPC:

ZZ0000ZZ


Thực hiện
==============

TIPC được triển khai dưới dạng mô-đun hạt nhân trong thư mục net/tipc/.

Các loại cơ sở TIPC
---------------

.. kernel-doc:: net/tipc/subscr.h
   :internal:

.. kernel-doc:: net/tipc/bearer.h
   :internal:

.. kernel-doc:: net/tipc/name_table.h
   :internal:

.. kernel-doc:: net/tipc/name_distr.h
   :internal:

.. kernel-doc:: net/tipc/bcast.c
   :internal:

Giao diện mang TIPC
----------------------

.. kernel-doc:: net/tipc/bearer.c
   :internal:

.. kernel-doc:: net/tipc/udp_media.c
   :internal:

Giao diện tiền điện tử TIPC
----------------------

.. kernel-doc:: net/tipc/crypto.c
   :internal:

Giao diện khám phá TIPC
--------------------------

.. kernel-doc:: net/tipc/discover.c
   :internal:

Giao diện liên kết TIPC
--------------------

.. kernel-doc:: net/tipc/link.c
   :internal:

Giao diện tin nhắn TIPC
-------------------

.. kernel-doc:: net/tipc/msg.c
   :internal:

Giao diện tên TIPC
--------------------

.. kernel-doc:: net/tipc/name_table.c
   :internal:

.. kernel-doc:: net/tipc/name_distr.c
   :internal:

Giao diện quản lý nút TIPC
-------------------------------

.. kernel-doc:: net/tipc/node.c
   :internal:

Giao diện ổ cắm TIPC
----------------------

.. kernel-doc:: net/tipc/socket.c
   :internal:

Giao diện cấu trúc liên kết mạng TIPC
--------------------------------

.. kernel-doc:: net/tipc/subscr.c
   :internal:

Giao diện máy chủ TIPC
----------------------

.. kernel-doc:: net/tipc/topsrv.c
   :internal:

Giao diện theo dõi TIPC
---------------------

.. kernel-doc:: net/tipc/trace.c
   :internal: