.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/gpu/komeda-kms.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

==============================================
 trình điều khiển hiển thị cánh tay drm/komeda
==============================================

Trình điều khiển drm/komeda hỗ trợ bộ xử lý màn hình Arm D71 và các sản phẩm mới hơn,
tài liệu này cung cấp một cái nhìn tổng quan ngắn gọn về thiết kế trình điều khiển: nó hoạt động như thế nào và tại sao
thiết kế nó như vậy.

Tổng quan về D71 giống như IP hiển thị
======================================

Từ D71, IP hiển thị Arm bắt đầu áp dụng linh hoạt và được mô-đun hóa
kiến trúc. Một đường ống hiển thị được tạo thành từ nhiều cá nhân và
các giai đoạn của quy trình chức năng được gọi là các thành phần và mỗi thành phần đều có một số
các khả năng cụ thể có thể cung cấp cho dữ liệu pixel đường dẫn luồng một
xử lý cụ thể.

Các thành phần D71 điển hình:

Lớp
-----
Lớp là giai đoạn quy trình đầu tiên, chuẩn bị dữ liệu pixel cho giai đoạn tiếp theo
sân khấu. Nó tìm nạp pixel từ bộ nhớ, giải mã nó nếu đó là AFBC, xoay
hình ảnh nguồn, giải nén hoặc chuyển đổi các pixel YUV thành các pixel RGB bên trong thiết bị,
sau đó điều chỉnh color_space của pixel nếu cần.

Bộ chia tỷ lệ
-------------
Đúng như tên gọi của nó, bộ chia tỷ lệ chịu trách nhiệm chia tỷ lệ và D71 cũng vậy
hỗ trợ cải tiến hình ảnh bằng bộ chia tỷ lệ.
Việc sử dụng bộ chia tỷ lệ rất linh hoạt và có thể được kết nối với đầu ra của lớp
để chia tỷ lệ lớp hoặc kết nối với bộ tổng hợp và chia tỷ lệ toàn bộ màn hình
frame và sau đó đưa dữ liệu đầu ra vào wb_layer, sau đó sẽ ghi nó
vào bộ nhớ.

Bộ tổng hợp (compiz)
--------------------
Bộ tổng hợp kết hợp nhiều lớp hoặc luồng dữ liệu pixel vào một màn hình duy nhất
khung. khung đầu ra của nó có thể được đưa vào bộ xử lý hình ảnh sau để hiển thị nó trên
màn hình hoặc được đưa vào wb_layer và ghi vào bộ nhớ cùng một lúc.
người dùng cũng có thể chèn bộ chia tỷ lệ giữa bộ tổng hợp và wb_layer để giảm tỷ lệ
khung hiển thị trước rồi mới ghi vào bộ nhớ.

Lớp ghi lại (wb_layer)
--------------------------
Lớp Writeback thực hiện những điều ngược lại với Lớp, kết nối với compiz
và ghi kết quả tổng hợp vào bộ nhớ.

Đăng bộ xử lý hình ảnh (improc)
-------------------------------
Bộ xử lý hình ảnh sau điều chỉnh dữ liệu khung hình như gamma và không gian màu để phù hợp với
yêu cầu của màn hình.

Bộ điều khiển thời gian (timing_ctrlr)
--------------------------------------
Giai đoạn cuối cùng của quy trình hiển thị, Bộ điều khiển thời gian không dành cho pixel
xử lý, nhưng chỉ để kiểm soát thời gian hiển thị.

Sáp nhập
--------
Bộ chia tỷ lệ D71 hầu hết chỉ có khả năng đầu vào/đầu ra một nửa theo chiều ngang
so với Lớp, chẳng hạn như nếu Lớp hỗ trợ kích thước đầu vào 4K thì bộ chia tỷ lệ chỉ có thể
hỗ trợ đầu vào/đầu ra 2K cùng lúc. Để đạt được tỷ lệ khung hình tối đa, D71
giới thiệu Layer Split, chia toàn bộ hình ảnh thành hai nửa phần và nguồn cấp dữ liệu
chúng thành hai Lớp A và B và thực hiện chia tỷ lệ một cách độc lập. Sau khi chia tỷ lệ
kết quả cần được đưa vào quá trình hợp nhất để hợp nhất hai phần hình ảnh lại với nhau, sau đó
xuất kết quả đã hợp nhất thành compiz.

Bộ chia
--------
Tương tự như Layer Split, nhưng Splitter được sử dụng để viết lại, chia tách
compiz thành hai phần và sau đó đưa chúng vào hai bộ chia tỷ lệ.

Có thể sử dụng đường ống D71
============================

Hưởng lợi từ kiến trúc được mô đun hóa, các đường ống D71 có thể dễ dàng
được điều chỉnh để phù hợp với các mục đích sử dụng khác nhau. Và D71 có hai đường ống hỗ trợ hai
các loại chế độ làm việc:

- Chế độ hiển thị kép
    Hai đường ống hoạt động độc lập và riêng biệt để điều khiển hai đầu ra màn hình.

- Chế độ hiển thị đơn
    Hai đường ống làm việc cùng nhau để chỉ điều khiển một đầu ra màn hình.

Ở chế độ này, pipe_B không hoạt động độc lập mà xuất ra
    kết quả tổng hợp thành pipe_A và thời gian pixel của nó cũng bắt nguồn từ
    pipe_A.timing_ctrlr. pipe_B hoạt động giống như một "nô lệ" của
    đường ống_A (chính)

Luồng dữ liệu đường ống đơn
---------------------------

.. kernel-render:: DOT
   :alt: Single pipeline digraph
   :caption: Single pipeline data flow

   digraph single_ppl {
      rankdir=LR;

      subgraph {
         "Memory";
         "Monitor";
      }

      subgraph cluster_pipeline {
          style=dashed
          node [shape=box]
          {
              node [bgcolor=grey style=dashed]
              "Scaler-0";
              "Scaler-1";
              "Scaler-0/1"
          }

         node [bgcolor=grey style=filled]
         "Layer-0" -> "Scaler-0"
         "Layer-1" -> "Scaler-0"
         "Layer-2" -> "Scaler-1"
         "Layer-3" -> "Scaler-1"

         "Layer-0" -> "Compiz"
         "Layer-1" -> "Compiz"
         "Layer-2" -> "Compiz"
         "Layer-3" -> "Compiz"
         "Scaler-0" -> "Compiz"
         "Scaler-1" -> "Compiz"

         "Compiz" -> "Scaler-0/1" -> "Wb_layer"
         "Compiz" -> "Improc" -> "Timing Controller"
      }

      "Wb_layer" -> "Memory"
      "Timing Controller" -> "Monitor"
   }

Đường ống kép có bật Slave
--------------------------------

.. kernel-render:: DOT
   :alt: Slave pipeline digraph
   :caption: Slave pipeline enabled data flow

   digraph slave_ppl {
      rankdir=LR;

      subgraph {
         "Memory";
         "Monitor";
      }
      node [shape=box]
      subgraph cluster_pipeline_slave {
          style=dashed
          label="Slave Pipeline_B"
          node [shape=box]
          {
              node [bgcolor=grey style=dashed]
              "Slave.Scaler-0";
              "Slave.Scaler-1";
          }

         node [bgcolor=grey style=filled]
         "Slave.Layer-0" -> "Slave.Scaler-0"
         "Slave.Layer-1" -> "Slave.Scaler-0"
         "Slave.Layer-2" -> "Slave.Scaler-1"
         "Slave.Layer-3" -> "Slave.Scaler-1"

         "Slave.Layer-0" -> "Slave.Compiz"
         "Slave.Layer-1" -> "Slave.Compiz"
         "Slave.Layer-2" -> "Slave.Compiz"
         "Slave.Layer-3" -> "Slave.Compiz"
         "Slave.Scaler-0" -> "Slave.Compiz"
         "Slave.Scaler-1" -> "Slave.Compiz"
      }

      subgraph cluster_pipeline_master {
          style=dashed
          label="Master Pipeline_A"
          node [shape=box]
          {
              node [bgcolor=grey style=dashed]
              "Scaler-0";
              "Scaler-1";
              "Scaler-0/1"
          }

         node [bgcolor=grey style=filled]
         "Layer-0" -> "Scaler-0"
         "Layer-1" -> "Scaler-0"
         "Layer-2" -> "Scaler-1"
         "Layer-3" -> "Scaler-1"

         "Slave.Compiz" -> "Compiz"
         "Layer-0" -> "Compiz"
         "Layer-1" -> "Compiz"
         "Layer-2" -> "Compiz"
         "Layer-3" -> "Compiz"
         "Scaler-0" -> "Compiz"
         "Scaler-1" -> "Compiz"

         "Compiz" -> "Scaler-0/1" -> "Wb_layer"
         "Compiz" -> "Improc" -> "Timing Controller"
      }

      "Wb_layer" -> "Memory"
      "Timing Controller" -> "Monitor"
   }

Các đường ống phụ cho đầu vào và đầu ra
---------------------------------------

Một quy trình hiển thị hoàn chỉnh có thể dễ dàng được chia thành ba quy trình phụ
theo cách sử dụng vào/ra.

Đường ống lớp (đầu vào)
~~~~~~~~~~~~~~~~~~~~~~~

.. kernel-render:: DOT
   :alt: Layer data digraph
   :caption: Layer (input) data flow

   digraph layer_data_flow {
      rankdir=LR;
      node [shape=box]

      {
         node [bgcolor=grey style=dashed]
           "Scaler-n";
      }

      "Layer-n" -> "Scaler-n" -> "Compiz"
   }

.. kernel-render:: DOT
   :alt: Layer Split digraph
   :caption: Layer Split pipeline

   digraph layer_data_flow {
      rankdir=LR;
      node [shape=box]

      "Layer-0/1" -> "Scaler-0" -> "Merger"
      "Layer-2/3" -> "Scaler-1" -> "Merger"
      "Merger" -> "Compiz"
   }

Đường dẫn Writeback (đầu ra)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~
.. kernel-render:: DOT
   :alt: writeback digraph
   :caption: Writeback(output) data flow

   digraph writeback_data_flow {
      rankdir=LR;
      node [shape=box]

      {
         node [bgcolor=grey style=dashed]
           "Scaler-n";
      }

      "Compiz" -> "Scaler-n" -> "Wb_layer"
   }

.. kernel-render:: DOT
   :alt: split writeback digraph
   :caption: Writeback(output) Split data flow

   digraph writeback_data_flow {
      rankdir=LR;
      node [shape=box]

      "Compiz" -> "Splitter"
      "Splitter" -> "Scaler-0" -> "Merger"
      "Splitter" -> "Scaler-1" -> "Merger"
      "Merger" -> "Wb_layer"
   }

Hiển thị đường dẫn đầu ra
~~~~~~~~~~~~~~~~~~~~~~~~~
.. kernel-render:: DOT
   :alt: display digraph
   :caption: display output data flow

   digraph single_ppl {
      rankdir=LR;
      node [shape=box]

      "Compiz" -> "Improc" -> "Timing Controller"
   }

Trong phần sau chúng ta sẽ thấy ba đường ống phụ này sẽ được xử lý
bởi KMS-plane/wb_conn/crtc tương ứng.

Trừu tượng tài nguyên Komeda
============================

struct komeda_pipeline/thành phần
---------------------------------

Để tận dụng tối đa và dễ dàng truy cập/cấu hình CTNH, phía trình điều khiển cũng sử dụng
một kiến trúc tương tự: Đường ống/Thành phần để mô tả các tính năng CTNH và
khả năng, và một thành phần cụ thể bao gồm hai phần:

- Kiểm soát luồng dữ liệu.
- Khả năng và tính năng thành phần cụ thể.

Vì vậy, trình điều khiển xác định một tiêu đề chung struct komeda_comComponent để mô tả
kiểm soát luồng dữ liệu và tất cả các thành phần cụ thể là một lớp con của cơ sở này
cấu trúc.

.. kernel-doc:: drivers/gpu/drm/arm/display/komeda/komeda_pipeline.h
   :internal:

Khám phá và khởi tạo tài nguyên
=====================================

Đường dẫn và thành phần được sử dụng để mô tả cách xử lý dữ liệu pixel. Chúng tôi
vẫn cần @struct komeda_dev để mô tả toàn bộ chế độ xem của thiết bị và
khả năng điều khiển của thiết bị.

Chúng tôi có &komeda_dev, &komeda_pipeline, &komeda_comComponent. Bây giờ điền vào các thiết bị với
đường ống. Vì komeda không chỉ dành cho D71 mà còn dành cho các sản phẩm sau này,
tất nhiên chúng tôi nên chia sẻ càng nhiều càng tốt giữa các sản phẩm khác nhau. Đến
đạt được điều này, hãy chia thiết bị komeda thành hai lớp: CORE và CHIP.

- CORE: dành cho các tính năng và khả năng xử lý thông thường.
- CHIP: để lập trình đăng ký và xử lý tính năng (giới hạn) cụ thể của CTNH.

CORE có thể truy cập CHIP bằng ba cấu trúc chức năng chip:

- struct komeda_dev_funcs
- struct komeda_pipeline_funcs
- struct komeda_comComponent_funcs

.. kernel-doc:: drivers/gpu/drm/arm/display/komeda/komeda_dev.h
   :internal:

Xử lý định dạng
===============

.. kernel-doc:: drivers/gpu/drm/arm/display/komeda/komeda_format_caps.h
   :internal:
.. kernel-doc:: drivers/gpu/drm/arm/display/komeda/komeda_framebuffer.h
   :internal:

Đính kèm komeda_dev vào DRM-KMS
===============================

Komeda trừu tượng hóa tài nguyên theo đường ống/thành phần, nhưng DRM-KMS sử dụng
crtc/mặt phẳng/đầu nối. Một KMS-obj không thể chỉ đại diện cho một thành phần duy nhất,
vì các yêu cầu của một đối tượng KMS không thể đạt được một cách đơn giản bằng một
thành phần đơn lẻ, thường cần nhiều thành phần để phù hợp với yêu cầu.
Giống như chế độ cài đặt, gamma, ctm cho KMS đều nhắm mục tiêu trên CRTC-obj, nhưng komeda cần
compiz, improc và Timing_ctrlr hoạt động cùng nhau để đáp ứng các yêu cầu này.
Và KMS-Plane có thể yêu cầu nhiều tài nguyên komeda: layer/scaler/compiz.

Vì vậy, một KMS-Obj đại diện cho một hệ thống phụ chứa tài nguyên komeda.

- Máy bay: ZZ0000ZZ
- Wb_connector: ZZ0001ZZ
- Crtc: ZZ0002ZZ

Vì vậy, đối với komeda, chúng tôi coi crtc/mặt phẳng/đầu nối KMS là người dùng đường ống và
thành phần và tại bất kỳ thời điểm nào, một đường ống/thành phần chỉ có thể được sử dụng bởi một
người dùng. Và đường ống/thành phần sẽ được coi là đối tượng riêng tư của DRM-KMS; cái
state cũng sẽ được quản lý bởi drm_atomic_state.

Cách ánh xạ mặt phẳng tới đường ống Lớp (đầu vào)
-------------------------------------------------

Komeda có nhiều đường dẫn đầu vào Lớp, xem:
-ZZ0000ZZ
-ZZ0001ZZ

Cách dễ nhất là liên kết một mặt phẳng với một đường ống Lớp cố định, nhưng hãy xem xét
khả năng komeda:

- Tách lớp, xem ZZ0000ZZ

Layer_Split là tính năng khá phức tạp, giúp chia một hình ảnh lớn thành hai
    các bộ phận và xử lý nó bằng hai lớp và hai bộ chia tỷ lệ riêng lẻ. Nhưng nó
    nhập một vấn đề hoặc hiệu ứng cạnh vào giữa hình ảnh sau khi phân chia.
    Để tránh vấn đề như vậy, cần có một phép tính Tách phức tạp và một số
    cấu hình đặc biệt cho lớp và bộ chia tỷ lệ. Tốt nhất chúng ta nên giấu phần cứng đó đi
    độ phức tạp liên quan đến chế độ người dùng.

- Đường ống nô lệ, Xem ZZ0000ZZ

Vì thành phần compiz không xuất ra giá trị alpha nên đường dẫn nô lệ
    chỉ có thể được sử dụng cho thành phần lớp dưới cùng. Người lái xe komeda muốn
    ẩn giới hạn này cho người dùng. Cách để làm điều này là chọn một phương pháp phù hợp
    Lớp theo mặt phẳng_state->zpos.

Vì vậy, đối với komeda, mặt phẳng KMS không đại diện cho đường ống lớp komeda cố định,
nhưng nhiều Lớp có cùng khả năng. Komeda sẽ chọn một hoặc nhiều
Các lớp phù hợp với yêu cầu của một mặt phẳng KMS.

Đặt thành phần/đường dẫn thành drm_private_obj
----------------------------------------------

Thêm ZZ0000ZZ vào ZZ0001ZZ, ZZ0002ZZ

.. code-block:: c

    struct komeda_component {
        struct drm_private_obj obj;
        ...
    }

    struct komeda_pipeline {
        struct drm_private_obj obj;
        ...
    }

Theo dõi thành phần_state/pipeline_state bởi drm_atomic_state
-------------------------------------------------------------

Thêm ZZ0000ZZ và người dùng vào ZZ0001ZZ,
ZZ0002ZZ

.. code-block:: c

    struct komeda_component_state {
        struct drm_private_state obj;
        void *binding_user;
        ...
    }

    struct komeda_pipeline_state {
        struct drm_private_state obj;
        struct drm_crtc *crtc;
        ...
    }

xác thực thành phần komeda
---------------------------

Komeda có nhiều loại thành phần, nhưng quá trình xác nhận
tương tự nhau, thường bao gồm các bước sau:

.. code-block:: c

    int komeda_xxxx_validate(struct komeda_component_xxx xxx_comp,
                struct komeda_component_output *input_dflow,
                struct drm_plane/crtc/connector *user,
                struct drm_plane/crtc/connector_state, *user_state)
    {
         setup 1: check if component is needed, like the scaler is optional depending
                  on the user_state; if unneeded, just return, and the caller will
                  put the data flow into next stage.
         Setup 2: check user_state with component features and capabilities to see
                  if requirements can be met; if not, return fail.
         Setup 3: get component_state from drm_atomic_state, and try set to set
                  user to component; fail if component has been assigned to another
                  user already.
         Setup 3: configure the component_state, like set its input component,
                  convert user_state to component specific state.
         Setup 4: adjust the input_dflow and prepare it for the next stage.
    }

komeda_kms Trừu tượng
----------------------

.. kernel-doc:: drivers/gpu/drm/arm/display/komeda/komeda_kms.h
   :internal:

komde_kms Chức năng
-------------------
.. kernel-doc:: drivers/gpu/drm/arm/display/komeda/komeda_crtc.c
   :internal:
.. kernel-doc:: drivers/gpu/drm/arm/display/komeda/komeda_plane.c
   :internal:

Xây dựng komeda để trở thành trình điều khiển mô-đun Linux
==========================================================

Bây giờ chúng tôi có hai thiết bị cấp độ:

- komeda_dev: mô tả phần cứng hiển thị thực.
- komeda_kms_dev: gắn hoặc kết nối komeda_dev với DRM-KMS.

Tất cả các hoạt động của komeda được cung cấp hoặc vận hành bởi komeda_dev hoặc komeda_kms_dev,
trình điều khiển mô-đun chỉ là một trình bao bọc đơn giản để truyền lệnh Linux
(thăm dò/xóa/pm) vào komeda_dev hoặc komeda_kms_dev.