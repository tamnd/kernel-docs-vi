.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/scsi/scsi_fc_transport.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

===================
SCSI FC Vận tải
===================

Ngày: 18/11/2008

Bản sửa đổi hạt nhân cho các tính năng::

cổng : <<TBS>>
  vport : 2.6.22
  hỗ trợ bsg: 2.6.30 (?TBD?)


Giới thiệu
============
Tệp này ghi lại các tính năng và thành phần của SCSI FC Transport.
Nó cũng cung cấp tài liệu về API giữa phương tiện vận tải và FC LLDD.

Việc vận chuyển FC có thể được tìm thấy tại::

trình điều khiển/scsi/scsi_transport_fc.c
  bao gồm/scsi/scsi_transport_fc.h
  bao gồm/scsi/scsi_netlink_fc.h
  bao gồm/scsi/scsi_bsg_fc.h

Tệp này được tìm thấy tại Documentation/scsi/scsi_fc_transport.rst


Cổng từ xa FC (rport)
========================

Trong hệ thống con Kênh sợi quang (FC), một cổng từ xa (rport) đề cập đến một
  nút Kênh sợi quang từ xa mà cổng cục bộ có thể giao tiếp.
  Đây thường là các mục tiêu lưu trữ (ví dụ: mảng, băng) đáp ứng
  tới các lệnh SCSI qua truyền tải FC.

Trong Linux, các rport được quản lý bởi lớp vận chuyển FC và được
  được thể hiện trong sysfs dưới:

/sys/class/fc_remote_ports/

Mỗi thư mục rport chứa các thuộc tính mô tả cổng từ xa,
  chẳng hạn như ID cổng, tên nút, trạng thái cổng và tốc độ liên kết.

Các cổng thường được tạo bởi FC Transport khi có một thiết bị mới
  được phát hiện trong quá trình đăng nhập hoặc quét nội dung và chúng tồn tại cho đến khi
  thiết bị bị xóa hoặc liên kết bị mất.

Thuộc tính chung:
  - node_name: Tên nút toàn cầu (WWNN).
  - port_name: Tên cổng toàn cầu (WWPN).
  - port_id: Địa chỉ FC của cổng remote.
  - vai trò: Cho biết cổng là cổng khởi tạo, mục tiêu hay cả hai.
  - port_state: Hiển thị trạng thái hoạt động hiện tại.

Sau khi phát hiện ra một cổng từ xa, trình điều khiển thường điền một cổng
  cấu trúc fc_rport_identifiers và gọi fc_remote_port_add() tới
  tạo và đăng ký cổng từ xa với hệ thống con SCSI thông qua
  Lớp vận chuyển Kênh sợi quang (FC).

rport cũng được hiển thị qua sysfs dưới dạng con của bộ điều hợp máy chủ FC.

Dành cho nhà phát triển: sử dụng fc_remote_port_add() và fc_remote_port_delete() khi
  triển khai trình điều khiển tương tác với lớp vận chuyển FC.


Cổng ảo FC (vports)
=========================

Tổng quan
--------

Các tiêu chuẩn FC mới đã xác định các cơ chế cho phép một thiết bị vật lý duy nhất
  cổng xuất hiện dưới dạng nhiều cổng giao tiếp. Sử dụng Id N_Port
  Cơ chế ảo hóa (NPIV), kết nối điểm-điểm với Fabric
  có thể được gán nhiều hơn 1 N_Port_ID.  Mỗi N_Port_ID xuất hiện dưới dạng
  cổng riêng biệt tới các điểm cuối khác trên kết cấu, mặc dù nó chia sẻ một cổng
  liên kết vật lý đến switch để liên lạc. Mỗi N_Port_ID có thể có một
  cái nhìn độc đáo về vải dựa trên phân vùng vải và mặt nạ mặt trăng mảng
  (giống như một bộ chuyển đổi không phải NPIV bình thường).  Sử dụng Vải ảo (VF)
  cơ chế, việc thêm tiêu đề vải vào mỗi khung cho phép cổng
  tương tác với Cổng Fabric để nối nhiều loại vải. Cảng sẽ
  lấy N_Port_ID trên mỗi loại vải mà nó tham gia. Mỗi loại vải sẽ có
  cái nhìn độc đáo của riêng mình về các điểm cuối và các tham số cấu hình.  NPIV có thể
  được sử dụng cùng với VF để cổng có thể nhận được nhiều N_Port_ID
  trên mỗi vải ảo.

FC Transport hiện đang nhận dạng một đối tượng mới - vport.  Một vport là
  một thực thể có Tên cổng toàn cầu duy nhất trên toàn thế giới (wwpn) và
  Tên nút toàn cầu (wwnn). Việc vận chuyển cũng cho phép FC4
  được chỉ định cho vport, với FCP_Initiator là vai trò chính
  mong đợi. Sau khi được khởi tạo bằng một trong các phương pháp trên, nó sẽ có một
  N_Port_ID riêng biệt và chế độ xem điểm cuối kết cấu cũng như thực thể lưu trữ.
  Fc_host được liên kết với bộ điều hợp vật lý sẽ xuất khả năng
  để tạo vport. Việc vận chuyển sẽ tạo đối tượng vport trong
  Cây thiết bị Linux và hướng dẫn trình điều khiển của fc_host khởi tạo
  cổng ảo. Thông thường, trình điều khiển sẽ tạo một phiên bản scsi_host mới
  trên vport, tạo ra một vùng tên <H,C,T,L> duy nhất cho vport.
  Do đó, dù cổng FC dựa trên cổng vật lý hay cổng ảo,
  mỗi cái sẽ xuất hiện dưới dạng một scsi_host duy nhất với mục tiêu và không gian lun riêng.

  .. Note::
    At this time, the transport is written to create only NPIV-based
    vports. However, consideration was given to VF-based vports and it
    should be a minor change to add support if needed.  The remaining
    discussion will concentrate on NPIV.

  .. Note::
    World Wide Name assignment (and uniqueness guarantees) are left
    up to an administrative entity controlling the vport. For example,
    if vports are to be associated with virtual machines, a XEN mgmt
    utility would be responsible for creating wwpn/wwnn's for the vport,
    using its own naming authority and OUI. (Note: it already does this
    for virtual MAC addresses).


Cây thiết bị và đối tượng Vport:
-------------------------------

Ngày nay, cây thiết bị thường chứa đối tượng scsi_host,
  với các đối tượng mục tiêu rports và scsi bên dưới nó. Hiện nay FC
  Transport tạo đối tượng vport và đặt nó dưới scsi_host
  đối tượng tương ứng với bộ điều hợp vật lý.  LLDD sẽ phân bổ
  một scsi_host mới cho vport và liên kết đối tượng của nó trong vport.
  Phần còn lại của cây dưới vports scsi_host cũng tương tự
  như trường hợp không phải NPIV. Việc vận chuyển hiện được viết để dễ dàng
  cho phép cha mẹ của vport là một cái gì đó khác với scsi_host.
  Điều này có thể được sử dụng trong tương lai để liên kết đối tượng với một vm cụ thể
  cây thiết bị. Nếu cha của vport không phải là scsi_host của cổng vật lý,
  một liên kết tượng trưng tới đối tượng vport sẽ được đặt trong vùng vật lý
  scsi_host của cổng.

Đây là những gì mong đợi trong cây thiết bị:

Scsi_Host của cổng vật lý điển hình::

/sys/thiết bị/.../host17/

và nó có cây con điển hình::

/sys/devices/.../host17/rport-17:0-0/target17:0:0/17:0:0:0:

và sau đó vport được tạo trên Cổng vật lý ::

/sys/devices/.../host17/vport-17:0-0

và Scsi_Host của vport sau đó được tạo ::

/sys/devices/.../host17/vport-17:0-0/host18

và sau đó phần còn lại của cây tiến triển, chẳng hạn như::

/sys/devices/.../host17/vport-17:0-0/host18/rport-18:0-0/target18:0:0/18:0:0:0:

Đây là những gì mong đợi trong cây sysfs::

scsi_host:
     /sys/class/scsi_host/host17 scsi_host của cổng vật lý
     /sys/class/scsi_host/host18 scsi_host của vport
   fc_hosts:
     /sys/class/fc_host/host17 fc_host của cổng vật lý
     /sys/class/fc_host/host18 fc_host của vport
   fc_vports:
     /sys/class/fc_vports/vport-17:0-0 fc_vport của vport
   fc_rports:
     /sys/class/fc_remote_ports/rport-17:0-0 rport trên cổng vật lý
     /sys/class/fc_remote_ports/rport-18:0-0 rport trên vport


Thuộc tính Vport
----------------

Đối tượng lớp fc_vport mới có các thuộc tính sau

tên_nút: Chỉ đọc
       WWNN của vport

port_name: Chỉ đọc
       WWPN của vport

vai trò: Read_Only
       Cho biết vai trò FC4 được bật trên vport.

tên_biểu tượng: Read_Write
       Một chuỗi được thêm vào chuỗi tên cổng tượng trưng của trình điều khiển, chuỗi này
       được đăng ký với switch để xác định vport. Ví dụ,
       trình ảo hóa có thể đặt chuỗi này thành "Xen Domain 2 VM 5 Vport 2",
       và bộ định danh này có thể được nhìn thấy trên màn hình quản lý switch
       để xác định cổng.

vport_delete: Chỉ viết
       Khi được viết bằng "1", sẽ phá bỏ vport.

vport_disable: Chỉ ghi
       Khi được viết bằng "1", sẽ chuyển vport sang bị vô hiệu hóa.
       tình trạng.  Vport vẫn sẽ được khởi tạo bằng nhân Linux,
       nhưng nó sẽ không hoạt động trên liên kết FC.
       Khi được viết bằng "0", sẽ kích hoạt vport.

vport_last_state: Chỉ đọc
       Cho biết trạng thái trước đó của vport.  Xem phần dưới đây về
       "Các bang Vport".

vport_state: Chỉ đọc
       Cho biết trạng thái của vport.  Xem phần dưới đây về
       "Các bang Vport".

vport_type: Chỉ đọc
       Phản ánh cơ chế FC được sử dụng để tạo cổng ảo.
       Hiện tại chỉ hỗ trợ NPIV.


Đối với đối tượng lớp fc_host, các thuộc tính sau được thêm vào cho vport:

max_npiv_vports: Chỉ đọc
       Cho biết số lượng vport dựa trên NPIV tối đa mà
       trình điều khiển/bộ chuyển đổi có thể hỗ trợ trên fc_host.

npiv_vports_inuse: Chỉ đọc
       Cho biết có bao nhiêu vport dựa trên NPIV đã được khởi tạo trên
       fc_host.

vport_create: Chỉ viết
       Giao diện tạo "đơn giản" để khởi tạo vport trên fc_host.
       Chuỗi "<WWPN>:<WWNN>" được ghi vào thuộc tính. việc vận chuyển
       sau đó khởi tạo đối tượng vport và gọi LLDD để tạo
       vport với vai trò FCP_Initiator.  Mỗi WWN được chỉ định là 16
       các ký tự hex và ZZ0000ZZ có thể chứa bất kỳ tiền tố nào (ví dụ: 0x, x, v.v.).

vport_delete: Chỉ viết
        Giao diện xóa "đơn giản" để chia nhỏ vport. Một "<WWPN>:<WWNN>"
        chuỗi được ghi vào thuộc tính. Việc vận chuyển sẽ xác định vị trí
        vport trên fc_host có cùng WWN và xé nó ra.  Mỗi WWN
        được chỉ định là 16 ký tự hex và ZZ0000ZZ có thể chứa bất kỳ tiền tố nào
        (ví dụ: 0x, x, v.v.).


Các bang Vport
------------

Khởi tạo Vport bao gồm hai phần:

- Tạo bằng kernel và LLDD. Điều này có nghĩa là tất cả các hoạt động vận chuyển và
      Cấu trúc dữ liệu trình điều khiển được xây dựng và các đối tượng thiết bị được tạo.
      Điều này tương đương với việc "đính" trình điều khiển vào bộ chuyển đổi, được
      độc lập với trạng thái liên kết của bộ điều hợp.
    - Khởi tạo vport trên liên kết FC thông qua lưu lượng ELS, v.v.
      Điều này tương đương với việc "liên kết" và khởi tạo liên kết thành công.

Thông tin thêm có thể được tìm thấy trong phần giao diện bên dưới để biết
  Sáng tạo Vport.

Khi một vport đã được khởi tạo bằng kernel/LLDD, trạng thái vport
  có thể được báo cáo thông qua thuộc tính sysfs. Các trạng thái sau tồn tại:

FC_VPORT_UNKNOWN - Không rõ
      Trạng thái tạm thời, thường chỉ được đặt trong khi vport đang được
      được khởi tạo bằng kernel và LLDD.

FC_VPORT_ACTIVE-Hoạt động
      Vport đã được tạo thành công trên link FC.
      Nó có đầy đủ chức năng.

FC_VPORT_DISABLED - Đã tắt
      Vport đã được khởi tạo nhưng bị "vô hiệu hóa". Vport không được khởi tạo
      trên liên kết FC. Điều này tương đương với một cổng vật lý với
      liên kết "xuống".

FC_VPORT_LINKDOWN - Liên kết xuống
      Vport không hoạt động vì liên kết vật lý không hoạt động.

FC_VPORT_INITIALIZING - Đang khởi tạo
      Vport đang trong quá trình khởi tạo trên liên kết FC.
      LLDD sẽ đặt trạng thái này ngay trước khi bắt đầu lưu lượng ELS
      để tạo vport. Trạng thái này sẽ tồn tại cho đến khi vport được
      được tạo thành công (trạng thái trở thành FC_VPORT_ACTIVE) hoặc không thành công
      (trạng thái là một trong các giá trị bên dưới).  Vì trạng thái này là tạm thời,
      nó sẽ không được lưu giữ trong "vport_last_state".

FC_VPORT_NO_FABRIC_SUPP - Không hỗ trợ vải
      Vport không hoạt động. Một trong những điều kiện sau đây đã
      gặp phải:

- Cấu trúc liên kết FC không phải là Point-to-Point
       - Cổng FC không được kết nối với F_Port
       - F_Port đã chỉ ra rằng NPIV không được hỗ trợ.

FC_VPORT_NO_FABRIC_RSCS - Không có tài nguyên vải
      Vport không hoạt động. Vải FDISC bị lỗi với trạng thái
      chỉ ra rằng nó không có đủ nguồn lực để hoàn thành
      hoạt động.

FC_VPORT_FABRIC_LOGOUT - Đăng xuất vải
      Vport không hoạt động. Vải có LOGO có N_Port_ID
      liên kết với vport.

FC_VPORT_FABRIC_REJ_WWN - Vải bị từ chối WWN
      Vport không hoạt động. Vải FDISC bị lỗi với trạng thái
      chỉ ra rằng WWN không hợp lệ.

FC_VPORT_FAILED - VPort không thành công
      Vport không hoạt động. Đây là một điểm thu hút cho tất cả những người khác
      điều kiện lỗi.


Bảng trạng thái sau đây cho biết các chuyển đổi trạng thái khác nhau:

+-------------------+--------------------------------+----------------------+
   ZZ0000ZZ Sự kiện ZZ0001ZZ
   +===================+=============================================================+
   ZZ0002ZZ Khởi tạo ZZ0003ZZ
   +-------------------+--------------------------------+----------------------+
   ZZ0004ZZ Liên kết xuống ZZ0005ZZ
   |                  +--------------------------------+----------------------+
   ZZ0006ZZ Liên kết và lặp lại ZZ0007ZZ
   |                  +--------------------------------+----------------------+
   ZZ0008ZZ Liên kết & không có vải ZZ0009ZZ
   |                  +--------------------------------+----------------------+
   ZZ0010ZZ Liên kết và phản hồi FLOGI ZZ0011ZZ
   ZZ0012ZZ cho biết không có NPIV hỗ trợ ZZ0013ZZ
   |                  +--------------------------------+----------------------+
   ZZ0014ZZ Liên kết lên & FDISC đang được gửi ZZ0015ZZ
   |                  +--------------------------------+----------------------+
   ZZ0016ZZ Vô hiệu hóa yêu cầu ZZ0017ZZ
   +-------------------+--------------------------------+----------------------+
   ZZ0018ZZ Liên kết ZZ0019ZZ
   +-------------------+--------------------------------+----------------------+
   ZZ0020ZZ FDISC ACC ZZ0021ZZ
   |                  +--------------------------------+----------------------+
   ZZ0022ZZ FDISC LS_RJT không có tài nguyên ZZ0023ZZ
   |                  +--------------------------------+----------------------+
   ZZ0024ZZ FDISC LS_RJT với ZZ0025ZZ không hợp lệ
   Tên ZZ0026ZZ hoặc nport_id ZZ0027ZZ không hợp lệ
   |                  +--------------------------------+----------------------+
   ZZ0028ZZ FDISC LS_RJT không thành công đối với ZZ0029ZZ
   ZZ0030ZZ lý do khác ZZ0031ZZ
   |                  +--------------------------------+----------------------+
   ZZ0032ZZ Liên kết xuống ZZ0033ZZ
   |                  +--------------------------------+----------------------+
   ZZ0034ZZ Vô hiệu hóa yêu cầu ZZ0035ZZ
   +-------------------+--------------------------------+----------------------+
   ZZ0036ZZ Kích hoạt yêu cầu ZZ0037ZZ
   +-------------------+--------------------------------+----------------------+
   ZZ0038ZZ LOGO nhận được từ vải ZZ0039ZZ
   |                  +--------------------------------+----------------------+
   ZZ0040ZZ Liên kết xuống ZZ0041ZZ
   |                  +--------------------------------+----------------------+
   ZZ0042ZZ Vô hiệu hóa yêu cầu ZZ0043ZZ
   +-------------------+--------------------------------+----------------------+
   ZZ0044ZZ Link vẫn còn ZZ0045ZZ
   +-------------------+--------------------------------+----------------------+

4 trạng thái lỗi sau đây đều có sự chuyển tiếp giống nhau::

Không hỗ trợ vải:
    Không có tài nguyên vải:
    Vải bị từ chối WWN:
    Vport không thành công:
                        Tắt yêu cầu Tắt
                        Liên kết đi xuống Linkdown


Vận chuyển <-> LLDD Giao diện
-----------------------------

Hỗ trợ Vport của LLDD:

LLDD biểu thị sự hỗ trợ cho vport bằng cách cung cấp vport_create()
  chức năng trong mẫu vận chuyển.  Sự có mặt của chức năng này sẽ
  gây ra việc tạo các thuộc tính mới trên fc_host.  Là một phần của
  cổng vật lý hoàn thành quá trình khởi tạo của nó so với cổng
  Transport, nó nên đặt thuộc tính max_npiv_vports để chỉ ra
  số lượng vport tối đa mà trình điều khiển và/hoặc bộ chuyển đổi hỗ trợ.


Tạo Vport:

Cú pháp LLDD vport_create() là::

int vport_create(struct fc_vport *vport, tắt bool)

Ở đâu:

======= ================================================================
      vport Là đối tượng vport mới được phân bổ
      vô hiệu hóa Nếu "true", vport sẽ được tạo ở trạng thái bị vô hiệu hóa.
                Nếu "false", vport sẽ được bật khi tạo.
      ======= ================================================================

Khi có yêu cầu tạo một vport mới (thông qua sgio/netlink hoặc
  thuộc tính vport_create fc_host), quá trình vận chuyển sẽ xác thực rằng LLDD
  có thể hỗ trợ một vport khác (ví dụ: max_npiv_vports > npiv_vports_inuse).
  Nếu không, yêu cầu tạo sẽ không thành công.  Nếu vẫn còn không gian, việc vận chuyển
  sẽ tăng số lượng vport, tạo đối tượng vport và sau đó gọi
  Hàm vport_create() của LLDD với đối tượng vport mới được phân bổ.

Như đã đề cập ở trên, việc tạo vport được chia thành hai phần:

- Tạo bằng kernel và LLDD. Điều này có nghĩa là tất cả các hoạt động vận chuyển và
      Cấu trúc dữ liệu trình điều khiển được xây dựng và các đối tượng thiết bị được tạo.
      Điều này tương đương với việc "đính" trình điều khiển vào bộ chuyển đổi, được
      độc lập với trạng thái liên kết của bộ điều hợp.
    - Khởi tạo vport trên liên kết FC thông qua lưu lượng ELS, v.v.
      Điều này tương đương với việc "liên kết" và khởi tạo liên kết thành công.

Hàm vport_create() của LLDD sẽ không chờ đồng bộ cho cả hai
  các bộ phận phải được hoàn thành đầy đủ trước khi trở về. Nó phải xác nhận rằng
  cơ sở hạ tầng tồn tại để hỗ trợ NPIV và hoàn thành phần đầu tiên của
  tạo vport (xây dựng cấu trúc dữ liệu) trước khi quay lại.  chúng tôi không
  bản lề vport_create() trong hoạt động phía liên kết chủ yếu là do:

- Liên kết có thể bị hỏng. Nếu đúng như vậy thì đó không phải là một thất bại. Nó đơn giản
      có nghĩa là vport ở trạng thái không thể hoạt động cho đến khi liên kết xuất hiện.
      Điều này phù hợp với việc tạo liên kết nảy bài vport.
    - Vport có thể được tạo ở trạng thái bị vô hiệu hóa.
    - Điều này phù hợp với mô hình trong đó: vport tương đương với một
      Bộ chuyển đổi FC. Vport_create đồng nghĩa với tệp đính kèm trình điều khiển
      đến bộ điều hợp, độc lập với trạng thái liên kết.

  .. Note::

      special error codes have been defined to delineate infrastructure
      failure cases for quicker resolution.

Hành vi dự kiến ​​cho hàm vport_create() của LLDD là:

- Xác thực cơ sở hạ tầng:

- Nếu trình điều khiển hoặc bộ điều hợp không thể hỗ trợ vport khác, cho dù
            do phần sụn không đúng, (nói dối về) max_npiv hoặc thiếu
            một số tài nguyên khác - trả về VPCERR_UNSUPPORTED.
        - Nếu trình điều khiển xác thực WWN so với những trình điều khiển đã hoạt động trên
            bộ chuyển đổi và phát hiện sự chồng chéo - trả về VPCERR_BAD_WWN.
        - Nếu trình điều khiển phát hiện cấu trúc liên kết là vòng lặp, không phải vải hoặc
            FLOGI không hỗ trợ NPIV - trả lại VPCERR_NO_FABRIC_SUPP.

- Phân bổ cấu trúc dữ liệu Nếu gặp lỗi như out
        điều kiện bộ nhớ, trả về mã lỗi Exxx âm tương ứng.
    - Nếu vai trò là Người khởi xướng FCP, LLDD phải:

- Gọi scsi_host_alloc() để cấp phát một scsi_host cho vport.
        - Gọi scsi_add_host(new_shost, &vport->dev) để khởi động scsi_host
          và liên kết nó như một phần tử con của thiết bị vport.
        - Khởi tạo các giá trị thuộc tính fc_host.

- Bắt đầu chuyển tiếp trạng thái vport dựa trên cờ vô hiệu hóa và
        trạng thái liên kết - và trả về thành công (không).

Ghi chú của người triển khai LLDD:

- Nên có một fc_function_templates khác cho
    cổng vật lý và cổng ảo.  Mẫu cổng vật lý
    sẽ có các hàm vport_create, vport_delete và vport_disable,
    trong khi vport thì không.
  - Đề nghị nên có scsi_host_templates khác nhau
    cho cổng vật lý và cổng ảo. Chắc có tài xế
    các thuộc tính, được nhúng vào scsi_host_template, có thể áp dụng
    chỉ dành cho cổng vật lý (tốc độ liên kết, cài đặt cấu trúc liên kết, v.v.). Cái này
    đảm bảo rằng các thuộc tính có thể áp dụng được cho scsi_host tương ứng.


Tắt/Bật Vport:

Cú pháp LLDD vport_disable() là::

int vport_disable(struct fc_vport *vport, tắt bool)

Ở đâu:

======= ===========================================
      vport Vport sẽ được bật hay tắt
      vô hiệu hóa Nếu "true", vport sẽ bị vô hiệu hóa.
                Nếu "false", vport sẽ được bật.
      ======= ===========================================

Khi có yêu cầu thay đổi trạng thái bị vô hiệu hóa trên một vport,
  Transport sẽ xác thực yêu cầu dựa trên trạng thái vport hiện có.
  Nếu yêu cầu bị vô hiệu hóa và vport đã bị vô hiệu hóa,
  yêu cầu sẽ thất bại. Tương tự, nếu yêu cầu được bật và
  vport không ở trạng thái bị vô hiệu hóa, yêu cầu sẽ thất bại.  Nếu yêu cầu
  hợp lệ ở trạng thái vport, phương tiện vận chuyển sẽ gọi LLDD tới
  thay đổi trạng thái của vport.

Trong LLDD, nếu vport bị tắt, nó vẫn được khởi tạo bằng
  kernel và LLDD, nhưng nó không hoạt động hoặc không hiển thị trên liên kết FC trong
  bất kỳ cách nào. (xem phần Tạo Vport và phần thảo luận về khởi tạo gồm 2 phần).
  Vport sẽ vẫn ở trạng thái này cho đến khi bị xóa hoặc kích hoạt lại.
  Khi kích hoạt vport, LLDD sẽ khôi phục vport trên FC
  liên kết - về cơ bản là khởi động lại máy trạng thái LLDD (xem Vport States
  ở trên).


Xóa Vport:

Cú pháp LLDD vport_delete() là::

int vport_delete(struct fc_vport *vport)

Ở đâu:

vport: Là vport để xóa

Khi có yêu cầu xóa một vport (qua sgio/netlink, hoặc qua
  thuộc tính fc_host hoặc fc_vport vport_delete), phương thức vận chuyển sẽ gọi
  LLDD để chấm dứt vport trên liên kết FC và phá bỏ tất cả các cổng khác
  cơ sở dữ liệu và tài liệu tham khảo.  Nếu LLDD hoàn thành thành công,
  việc vận chuyển sẽ phá bỏ các đối tượng vport và hoàn thành vport
  loại bỏ.  Nếu yêu cầu xóa LLDD không thành công, đối tượng vport sẽ vẫn còn,
  nhưng sẽ ở trạng thái không xác định.

Trong LLDD, các đường dẫn mã thông thường để phân tích scsi_host sẽ
  được theo sau. Ví dụ. Nếu vport có vai trò Người khởi tạo FCP, LLDD
  sẽ gọi fc_remove_host() cho vports scsi_host, theo sau là
  scsi_remove_host() và scsi_host_put() cho vport scsi_host.


Khác:
  Thuộc tính fc_host port_type:
    Có một giá trị port_type fc_host mới - FC_PORTTYPE_NPIV. Giá trị này
    phải được đặt trên tất cả các fc_host dựa trên vport.  Thông thường, trên một cổng vật lý,
    thuộc tính port_type sẽ được đặt thành NPORT, NLPORT, v.v. dựa trên
    loại cấu trúc liên kết và sự tồn tại của vải. Vì điều này không áp dụng được cho
    một vport, sẽ hợp lý hơn khi báo cáo cơ chế FC được sử dụng để tạo
    vport.

Dỡ bỏ trình điều khiển:
    Trình điều khiển FC được yêu cầu gọi fc_remove_host() trước khi gọi
    scsi_remove_host().  Điều này cho phép fc_host phá bỏ tất cả các điều khiển từ xa
    cổng trước khi scsi_host bị phá bỏ.  Cuộc gọi fc_remove_host()
    cũng đã được cập nhật để xóa tất cả vport cho fc_host.


Chức năng cung cấp vận chuyển
----------------------------

Các chức năng sau đây được FC-transport cung cấp để LLD sử dụng.

===============================================
   fc_vport_create tạo vport
   fc_vport_terminate tách và xóa một vport
   ===============================================

Chi tiết::

/**
    * fc_vport_create - Ứng dụng quản trị viên hoặc LLDD yêu cầu tạo vport
    * @shost: scsi Host mà cổng ảo được kết nối tới.
    * @ids: Tên trên toàn thế giới, vai trò cổng FC4, v.v.
    * cổng ảo.
    *
    * Ghi chú:
    * Quy trình này giả định rằng không có ổ khóa nào được giữ khi vào.
    */
    cấu trúc fc_vport *
    fc_vport_create(struct Scsi_Host *shost, struct fc_vport_identifiers *ids)

/**
    * fc_vport_terminate - Ứng dụng quản trị viên hoặc LLDD yêu cầu chấm dứt vport
    * @vport: fc_vport bị chấm dứt
    *
    * Gọi hàm LLDD vport_delete(), sau đó giải phóng và xóa
    * vport từ cây shost và cây đối tượng.
    *
    * Ghi chú:
    * Quy trình này giả định rằng không có ổ khóa nào được giữ khi vào.
    */
    int
    fc_vport_terminate(struct fc_vport *vport)


Hỗ trợ FC BSG (passthru CT & ELS, v.v.)
============================================

<< Sẽ được cung cấp >>





Tín dụng
=======
Những người sau đây đã đóng góp cho tài liệu này:






James thông minh
james.smart@broadcom.com
