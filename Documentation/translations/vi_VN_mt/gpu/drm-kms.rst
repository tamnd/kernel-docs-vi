.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/gpu/drm-kms.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=============================
Cài đặt chế độ hạt nhân (KMS)
=============================

Trình điều khiển phải khởi tạo lõi cài đặt chế độ bằng cách gọi
drmm_mode_config_init() trên thiết bị DRM. chức năng
khởi tạo ZZ0000ZZ
trường mode_config và không bao giờ bị lỗi. Sau khi thực hiện xong, cấu hình chế độ phải
được thiết lập bằng cách khởi tạo các trường sau.

- int min_width, min_height; int max_width, max_height;
   Chiều rộng và chiều cao tối thiểu và tối đa của vùng đệm khung tính bằng pixel
   đơn vị.

- struct drm_mode_config_funcs \*funcs;
   Chức năng cài đặt chế độ.

Tổng quan
========

.. kernel-render:: DOT
   :alt: KMS Display Pipeline
   :caption: KMS Display Pipeline Overview

   digraph "KMS" {
      node [shape=box]

      subgraph cluster_static {
          style=dashed
          label="Static Objects"

          node [bgcolor=grey style=filled]
          "drm_plane A" -> "drm_crtc"
          "drm_plane B" -> "drm_crtc"
          "drm_crtc" -> "drm_encoder A"
          "drm_crtc" -> "drm_encoder B"
      }

      subgraph cluster_user_created {
          style=dashed
          label="Userspace-Created"

          node [shape=oval]
          "drm_framebuffer 1" -> "drm_plane A"
          "drm_framebuffer 2" -> "drm_plane B"
      }

      subgraph cluster_connector {
          style=dashed
          label="Hotpluggable"

          "drm_encoder A" -> "drm_connector A"
          "drm_encoder B" -> "drm_connector B"
      }
   }

Cấu trúc đối tượng cơ bản mà KMS trình bày cho không gian người dùng khá đơn giản.
Bộ đệm khung (đại diện bởi ZZ0000ZZ,
xem ZZ0003ZZ) đưa vào mặt phẳng. Các mặt phẳng được biểu diễn bởi
ZZ0001ZZ, xem ZZ0004ZZ để biết thêm
chi tiết. Một hoặc nhiều (hoặc thậm chí không có) mặt phẳng nào cung cấp dữ liệu pixel của chúng vào CRTC
(đại diện bởi ZZ0002ZZ, xem ZZ0005ZZ)
để pha trộn. Bước trộn chính xác được giải thích chi tiết hơn trong ZZ0006ZZ và các chương liên quan.

Để định tuyến đầu ra, bước đầu tiên là bộ mã hóa (được biểu thị bằng
ZZ0000ZZ, xem ZZ0001ZZ). Những cái đó
thực sự chỉ là tạo phẩm nội bộ của các thư viện trợ giúp được sử dụng để triển khai KMS
trình điều khiển. Ngoài ra, chúng còn khiến không gian người dùng trở nên phức tạp hơn một cách không cần thiết.
để tìm ra những kết nối nào có thể thực hiện được giữa CRTC và đầu nối và
loại nhân bản nào được hỗ trợ, chúng không phục vụ mục đích nào trong không gian người dùng API.
Rất tiếc, bộ mã hóa đã tiếp xúc với không gian người dùng nên không thể xóa chúng
vào thời điểm này.  Hơn nữa, các hạn chế được đưa ra thường được đặt sai bởi
trình điều khiển và trong nhiều trường hợp không đủ mạnh để thể hiện những hạn chế thực sự.
CRTC có thể được kết nối với nhiều bộ mã hóa và đối với CRTC đang hoạt động thì phải có
có ít nhất một bộ mã hóa.

Điểm cuối thực và cuối cùng trong chuỗi hiển thị là đầu nối (được biểu thị
bởi ZZ0000ZZ, xem ZZ0001ZZ). Các trình kết nối có thể có các bộ mã hóa khác nhau, nhưng hạt nhân
trình điều khiển chọn bộ mã hóa sẽ sử dụng cho mỗi đầu nối. Trường hợp sử dụng là DVI,
có thể chuyển đổi giữa bộ mã hóa analog và kỹ thuật số. Bộ mã hóa cũng có thể
điều khiển nhiều đầu nối khác nhau. Có chính xác một trình kết nối hoạt động cho
mọi bộ mã hóa đang hoạt động.

Quy trình đầu ra bên trong phức tạp hơn một chút và phù hợp với quy trình ngày nay
phần cứng chặt chẽ hơn:

.. kernel-render:: DOT
   :alt: KMS Output Pipeline
   :caption: KMS Output Pipeline

   digraph "Output Pipeline" {
      node [shape=box]

      subgraph {
          "drm_crtc" [bgcolor=grey style=filled]
      }

      subgraph cluster_internal {
          style=dashed
          label="Internal Pipeline"
          {
              node [bgcolor=grey style=filled]
              "drm_encoder A";
              "drm_encoder B";
              "drm_encoder C";
          }

          {
              node [bgcolor=grey style=filled]
              "drm_encoder B" -> "drm_bridge B"
              "drm_encoder C" -> "drm_bridge C1"
              "drm_bridge C1" -> "drm_bridge C2";
          }
      }

      "drm_crtc" -> "drm_encoder A"
      "drm_crtc" -> "drm_encoder B"
      "drm_crtc" -> "drm_encoder C"


      subgraph cluster_output {
          style=dashed
          label="Outputs"

          "drm_encoder A" -> "drm_connector A";
          "drm_bridge B" -> "drm_connector B";
          "drm_bridge C2" -> "drm_connector C";

          "drm_panel"
      }
   }

Bên trong có hai đối tượng trợ giúp bổ sung phát huy tác dụng. Đầu tiên, để có thể
chia sẻ mã cho bộ mã hóa (đôi khi trên cùng một SoC, đôi khi ngoài chip) một hoặc
thêm ZZ0000ZZ (đại diện là ZZ0001ZZ) có thể được liên kết với bộ mã hóa. Liên kết này là tĩnh và không thể
đã thay đổi, có nghĩa là thanh ngang (nếu có) cần được ánh xạ giữa
CRTC và bất kỳ bộ mã hóa nào. Thường đối với những người lái xe có cầu thì không còn mã
ở cấp độ bộ mã hóa. Trình điều khiển nguyên tử có thể loại bỏ tất cả lệnh gọi lại bộ mã hóa thành
về cơ bản chỉ để lại một đối tượng định tuyến giả phía sau, điều này cần thiết cho
khả năng tương thích ngược vì bộ mã hóa được tiếp xúc với không gian người dùng.

Đối tượng thứ hai dành cho các bảng, được biểu thị bằng ZZ0000ZZ, xem ZZ0001ZZ. Các tấm không có ràng buộc cố định
điểm, nhưng thường được liên kết với cấu trúc riêng của trình điều khiển nhúng
ZZ0002ZZ.

Lưu ý rằng hiện tại việc kết nối cầu nối và tương tác với các đầu nối và
các bảng vẫn đang thay đổi và chưa thực sự được sắp xếp đầy đủ.

Cấu trúc và chức năng cốt lõi của KMS
=================================

.. kernel-doc:: include/drm/drm_mode_config.h
   :internal:

.. kernel-doc:: drivers/gpu/drm/drm_mode_config.c
   :export:

.. _kms_base_object_abstraction:

Trừu tượng hóa đối tượng cơ sở Modeset
===============================

.. kernel-render:: DOT
   :alt: Mode Objects and Properties
   :caption: Mode Objects and Properties

   digraph {
      node [shape=box]

      "drm_property A" -> "drm_mode_object A"
      "drm_property A" -> "drm_mode_object B"
      "drm_property B" -> "drm_mode_object A"
   }

Cấu trúc cơ sở cho tất cả các đối tượng KMS là ZZ0000ZZ. Một trong những dịch vụ cơ bản mà nó cung cấp là theo dõi các thuộc tính,
điều này đặc biệt quan trọng đối với IOCTL nguyên tử (xem ZZ0002ZZ). Phần đáng ngạc nhiên ở đây là các thuộc tính không
được khởi tạo trực tiếp trên từng đối tượng, nhưng bản thân các đối tượng ở chế độ độc lập,
được đại diện bởi ZZ0001ZZ, chỉ xác định
loại và phạm vi giá trị của một thuộc tính. Bất kỳ thuộc tính nào cũng có thể được đính kèm
nhiều lần tới các đối tượng khác nhau bằng cách sử dụng drm_object_attach_property().

.. kernel-doc:: include/drm/drm_mode_object.h
   :internal:

.. kernel-doc:: drivers/gpu/drm/drm_mode_object.c
   :export:

Cài đặt chế độ nguyên tử
===================


.. kernel-render:: DOT
   :alt: Mode Objects and Properties
   :caption: Mode Objects and Properties

   digraph {
      node [shape=box]

      subgraph cluster_state {
          style=dashed
          label="Free-standing state"

          "drm_atomic_state" -> "duplicated drm_plane_state A"
          "drm_atomic_state" -> "duplicated drm_plane_state B"
          "drm_atomic_state" -> "duplicated drm_crtc_state"
          "drm_atomic_state" -> "duplicated drm_connector_state"
          "drm_atomic_state" -> "duplicated driver private state"
      }

      subgraph cluster_current {
          style=dashed
          label="Current state"

          "drm_device" -> "drm_plane A"
          "drm_device" -> "drm_plane B"
          "drm_device" -> "drm_crtc"
          "drm_device" -> "drm_connector"
          "drm_device" -> "driver private object"

          "drm_plane A" -> "drm_plane_state A"
          "drm_plane B" -> "drm_plane_state B"
          "drm_crtc" -> "drm_crtc_state"
          "drm_connector" -> "drm_connector_state"
          "driver private object" -> "driver private state"
      }

      "drm_atomic_state" -> "drm_device" [label="atomic_commit"]
      "duplicated drm_plane_state A" -> "drm_device"[style=invis]
   }

Atomic cung cấp các cập nhật về chế độ giao dịch (bao gồm cả mặt phẳng), nhưng một
hơi khác so với cách tiếp cận giao dịch thông thường của cam kết thử và
quay lại:

- Thứ nhất, không được phép thay đổi phần cứng khi cam kết không thành công. Cái này
  cho phép chúng tôi triển khai chế độ DRM_MODE_ATOMIC_TEST_ONLY, cho phép
  không gian người dùng để khám phá xem một số cấu hình nhất định có hoạt động hay không.

- Điều này vẫn sẽ cho phép cài đặt và khôi phục trạng thái phần mềm,
  đơn giản hóa việc chuyển đổi các trình điều khiển hiện có. Nhưng việc kiểm tra trình điều khiển cho
  tính chính xác của mã Atomic_check trở nên thực sự khó khăn với điều đó: Cán
  khó có thể thực hiện đúng những thay đổi trong cấu trúc dữ liệu ở khắp mọi nơi.

- Cuối cùng, để tương thích ngược và hỗ trợ tất cả các trường hợp sử dụng, nguyên tử
  các bản cập nhật cần phải tăng dần và có thể thực hiện song song. Phần cứng
  không phải lúc nào cũng cho phép, nhưng nếu có thể, hãy cập nhật máy bay trên các CRTC khác nhau
  không nên can thiệp và không bị đình trệ do định tuyến đầu ra thay đổi
  CRTC khác nhau.

Tổng hợp tất cả lại, có hai hệ quả đối với thiết kế nguyên tử:

- Trạng thái tổng thể được chia thành các cấu trúc trạng thái theo từng đối tượng:
  ZZ0000ZZ cho mặt phẳng, ZZ0001ZZ cho CRTC và ZZ0002ZZ cho đầu nối. Đây là những thứ duy nhất
  các đối tượng có trạng thái có thể nhìn thấy và có thể cài đặt trong không gian người dùng. Đối với trình điều khiển trạng thái nội bộ
  có thể phân lớp các cấu trúc này thông qua việc nhúng hoặc thêm trạng thái hoàn toàn mới
  cấu trúc cho các chức năng phần cứng được chia sẻ toàn cầu của họ, xem ZZ0003ZZ.

- Một bản cập nhật nguyên tử được tập hợp và xác nhận dưới dạng một đống hoàn toàn độc lập
  của các cấu trúc trong ZZ0000ZZ
  thùng chứa. Cấu trúc trạng thái riêng của trình điều khiển cũng được theo dõi trong cùng
  kết cấu; xem chương tiếp theo.  Chỉ khi một trạng thái được cam kết thì nó mới được áp dụng
  tới các đối tượng trình điều khiển và chế độ. Bằng cách này, việc khôi phục bản cập nhật sẽ hoàn tất
  để giải phóng bộ nhớ và các đối tượng không tham chiếu như bộ đệm khung.

Khóa cấu trúc trạng thái nguyên tử được sử dụng nội bộ bằng ZZ0000ZZ. Theo nguyên tắc chung, không nên khóa
tiếp xúc với người lái xe, thay vào đó, các khóa phù hợp sẽ được tự động lấy bằng cách
bất kỳ chức năng nào sao chép hoặc nhìn vào một trạng thái, chẳng hạn như
drm_atomic_get_crtc_state().  Khóa chỉ bảo vệ dữ liệu phần mềm
cấu trúc, thứ tự cam kết thay đổi trạng thái đối với phần cứng được sắp xếp theo trình tự bằng cách sử dụng
ZZ0001ZZ.

Đọc tiếp trong chương này và cả trong ZZ0000ZZ để biết thêm chi tiết
bao quát các chủ đề cụ thể.

Xử lý trạng thái riêng của tài xế
-----------------------------

.. kernel-doc:: drivers/gpu/drm/drm_atomic.c
   :doc: handling driver private state

Tham khảo chức năng cài đặt chế độ nguyên tử
--------------------------------------

.. kernel-doc:: include/drm/drm_atomic.h
   :internal:

.. kernel-doc:: drivers/gpu/drm/drm_atomic.c
   :export:

Cài đặt chế độ nguyên tử Chức năng IOCTL và UAPI
--------------------------------------------

.. kernel-doc:: drivers/gpu/drm/drm_atomic_uapi.c
   :doc: overview

.. kernel-doc:: drivers/gpu/drm/drm_atomic_uapi.c
   :export:

Trừu tượng CRTC
================

.. kernel-doc:: drivers/gpu/drm/drm_crtc.c
   :doc: overview

Tham khảo chức năng CRTC
--------------------------------

.. kernel-doc:: include/drm/drm_crtc.h
   :internal:

.. kernel-doc:: drivers/gpu/drm/drm_crtc.c
   :export:

Tham khảo chức năng quản lý màu
------------------------------------

.. kernel-doc:: drivers/gpu/drm/drm_color_mgmt.c
   :export:

.. kernel-doc:: include/drm/drm_color_mgmt.h
   :internal:

Trừu tượng bộ đệm khung
========================

.. kernel-doc:: drivers/gpu/drm/drm_framebuffer.c
   :doc: overview

Tham khảo chức năng bộ đệm khung
--------------------------------

.. kernel-doc:: include/drm/drm_framebuffer.h
   :internal:

.. kernel-doc:: drivers/gpu/drm/drm_framebuffer.c
   :export:

Xử lý định dạng DRM
===================

.. kernel-doc:: include/uapi/drm/drm_fourcc.h
   :doc: overview

Tham khảo hàm định dạng
--------------------------

.. kernel-doc:: include/drm/drm_fourcc.h
   :internal:

.. kernel-doc:: drivers/gpu/drm/drm_fourcc.c
   :export:

.. _kms_dumb_buffer_objects:

Đối tượng đệm câm
===================

.. kernel-doc:: drivers/gpu/drm/drm_dumb_buffers.c
   :doc: overview

Trừu tượng mặt phẳng
=================

.. kernel-doc:: drivers/gpu/drm/drm_plane.c
   :doc: overview

Tham khảo hàm mặt phẳng
-------------------------

.. kernel-doc:: include/drm/drm_plane.h
   :internal:

.. kernel-doc:: drivers/gpu/drm/drm_plane.c
   :export:

Tham chiếu hàm thành phần mặt phẳng
-------------------------------------

.. kernel-doc:: drivers/gpu/drm/drm_blend.c
   :export:

Tham khảo chức năng theo dõi hư hỏng máy bay
-----------------------------------------

.. kernel-doc:: drivers/gpu/drm/drm_damage_helper.c
   :export:

.. kernel-doc:: include/drm/drm_damage_helper.h
   :internal:

Tính năng hoảng loạn máy bay
-------------------

.. kernel-doc:: drivers/gpu/drm/drm_panic.c
   :doc: overview

Tài liệu tham khảo về chức năng hoảng loạn của máy bay
-------------------------------

.. kernel-doc:: include/drm/drm_panic.h
   :internal:

.. kernel-doc:: drivers/gpu/drm/drm_panic.c
   :export:

Trừu tượng màu
===================

.. kernel-doc:: drivers/gpu/drm/drm_colorop.c
   :doc: overview

Tham khảo chức năng Colorop
---------------------------

.. kernel-doc:: include/drm/drm_colorop.h
   :internal:

.. kernel-doc:: drivers/gpu/drm/drm_colorop.c
   :export:

Chế độ hiển thị Chức năng Tham khảo
================================

.. kernel-doc:: include/drm/drm_modes.h
   :internal:

.. kernel-doc:: drivers/gpu/drm/drm_modes.c
   :export:

Trừu tượng hóa trình kết nối
=====================

.. kernel-doc:: drivers/gpu/drm/drm_connector.c
   :doc: overview

Tham khảo chức năng kết nối
-----------------------------

.. kernel-doc:: include/drm/drm_connector.h
   :internal:

.. kernel-doc:: drivers/gpu/drm/drm_connector.c
   :export:

Trình kết nối ghi lại
--------------------

.. kernel-doc:: drivers/gpu/drm/drm_writeback.c
  :doc: overview

.. kernel-doc:: include/drm/drm_writeback.h
  :internal:

.. kernel-doc:: drivers/gpu/drm/drm_writeback.c
  :export:

Trừu tượng bộ mã hóa
===================

.. kernel-doc:: drivers/gpu/drm/drm_encoder.c
   :doc: overview

Tham khảo chức năng bộ mã hóa
---------------------------

.. kernel-doc:: include/drm/drm_encoder.h
   :internal:

.. kernel-doc:: drivers/gpu/drm/drm_encoder.c
   :export:

Khóa KMS
===========

.. kernel-doc:: drivers/gpu/drm/drm_modeset_lock.c
   :doc: kms locking

.. kernel-doc:: include/drm/drm_modeset_lock.h
   :internal:

.. kernel-doc:: drivers/gpu/drm/drm_modeset_lock.c
   :export:

Thuộc tính KMS
==============

Phần tài liệu này chủ yếu nhắm đến các nhà phát triển không gian người dùng.
Đối với API trình điều khiển, hãy xem các phần khác.

Yêu cầu
------------

Trình điều khiển KMS có thể cần thêm các thuộc tính bổ sung để hỗ trợ các tính năng mới. Mỗi
Thuộc tính mới được giới thiệu trong trình điều khiển cần phải đáp ứng một số yêu cầu, trong
ngoài cái đã đề cập ở trên:

* Phải được chuẩn hóa, ghi chép:

* Chuỗi tên đầy đủ, chính xác;
  * Nếu thuộc tính là enum, tất cả các chuỗi tên giá trị hợp lệ;
  * Những giá trị nào được chấp nhận và những giá trị này có ý nghĩa gì;
  * Tài sản có tác dụng gì và có thể sử dụng tài sản đó như thế nào;
  * Làm thế nào tài sản có thể tương tác với các tài sản hiện có khác.

* Nó phải cung cấp một trình trợ giúp chung trong mã lõi để đăng ký
  thuộc tính trên đối tượng mà nó gắn vào.

* Nội dung của nó phải được giải mã bởi lõi và cung cấp trong đối tượng
  cấu trúc trạng thái liên quan Điều đó bao gồm mọi thứ mà người lái xe có thể muốn
  để tính toán trước, như struct drm_clip_ect cho mặt phẳng.

* Trạng thái ban đầu của nó phải khớp với hành vi trước thuộc tính
  giới thiệu. Đây có thể là một giá trị cố định phù hợp với những gì phần cứng
  có, hoặc nó có thể được kế thừa từ trạng thái phần sụn còn lại
  hệ thống trong khi khởi động.

* Phải gửi bài kiểm tra IGT nếu hợp lý.

Vì lý do lịch sử, tồn tại các thuộc tính không chuẩn, dành riêng cho trình điều khiển. Nếu là KMS
driver muốn thêm hỗ trợ cho một trong những thuộc tính đó, các yêu cầu đối với
các thuộc tính mới được áp dụng nếu có thể. Ngoài ra, hành vi được ghi lại phải
khớp với ngữ nghĩa thực tế của thuộc tính hiện có để đảm bảo tính tương thích.
Các nhà phát triển trình điều khiển đã thêm thuộc tính lần đầu tiên sẽ trợ giúp những vấn đề đó
nhiệm vụ và phải ACK hành vi được ghi lại nếu có thể.

Các loại thuộc tính và hỗ trợ thuộc tính Blob
----------------------------------------

.. kernel-doc:: drivers/gpu/drm/drm_property.c
   :doc: overview

.. kernel-doc:: include/drm/drm_property.h
   :internal:

.. kernel-doc:: drivers/gpu/drm/drm_property.c
   :export:

.. _standard_connector_properties:

Thuộc tính kết nối tiêu chuẩn
-----------------------------

.. kernel-doc:: drivers/gpu/drm/drm_connector.c
   :doc: standard connector properties

Thuộc tính kết nối cụ thể của HDMI
----------------------------------

.. kernel-doc:: drivers/gpu/drm/drm_connector.c
   :doc: HDMI connector properties

Thuộc tính kết nối cụ thể của TV analog
---------------------------------------

.. kernel-doc:: drivers/gpu/drm/drm_connector.c
   :doc: Analog TV Connector Properties

Thuộc tính CRTC tiêu chuẩn
------------------------

.. kernel-doc:: drivers/gpu/drm/drm_crtc.c
   :doc: standard CRTC properties

Thuộc tính mặt phẳng tiêu chuẩn
-------------------------

.. kernel-doc:: drivers/gpu/drm/drm_plane.c
   :doc: standard plane properties

.. _plane_composition_properties:

Thuộc tính thành phần mặt phẳng
----------------------------

.. kernel-doc:: drivers/gpu/drm/drm_blend.c
   :doc: overview

.. _damage_tracking_properties:

Thuộc tính theo dõi thiệt hại
--------------------------

.. kernel-doc:: drivers/gpu/drm/drm_plane.c
   :doc: damage tracking

Thuộc tính quản lý màu
---------------------------

.. kernel-doc:: drivers/gpu/drm/drm_color_mgmt.c
   :doc: overview

Thuộc tính nhóm ngói
-------------------

.. kernel-doc:: drivers/gpu/drm/drm_connector.c
   :doc: Tile group

Thuộc tính hàng rào rõ ràng
---------------------------

.. kernel-doc:: drivers/gpu/drm/drm_atomic_uapi.c
   :doc: explicit fencing properties


Thuộc tính làm mới biến
---------------------------

.. kernel-doc:: drivers/gpu/drm/drm_connector.c
   :doc: Variable refresh properties

Thuộc tính điểm phát sóng con trỏ
---------------------------

.. kernel-doc:: drivers/gpu/drm/drm_plane.c
   :doc: hotspot properties

Thuộc tính KMS hiện có
-----------------------

Bảng sau đây mô tả các thuộc tính drm được thể hiện bằng nhiều
mô-đun/trình điều khiển. Vì bảng này rất khó sử dụng nên đừng thêm bất kỳ cái gì mới
tài sản ở đây. Thay vào đó hãy ghi lại chúng trong phần trên.

.. csv-table::
   :header-rows: 1
   :file: kms-properties.csv

Dọc trống
=================

.. kernel-doc:: drivers/gpu/drm/drm_vblank.c
   :doc: vblank handling

Tham khảo chức năng xử lý ngắt và xóa dọc
------------------------------------------------------------

.. kernel-doc:: include/drm/drm_vblank.h
   :internal:

.. kernel-doc:: drivers/gpu/drm/drm_vblank.c
   :export:

Công việc trống dọc
===================

.. kernel-doc:: drivers/gpu/drm/drm_vblank_work.c
   :doc: vblank works

Tham khảo chức năng làm việc trống dọc
---------------------------------------

.. kernel-doc:: include/drm/drm_vblank_work.h
   :internal:

.. kernel-doc:: drivers/gpu/drm/drm_vblank_work.c
   :export:
