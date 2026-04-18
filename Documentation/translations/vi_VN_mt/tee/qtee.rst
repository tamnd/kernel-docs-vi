.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/tee/qtee.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

=================================================
QTEE (Môi trường thực thi đáng tin cậy của Qualcomm)
=============================================

Trình điều khiển QTEE xử lý giao tiếp với Qualcomm TEE [1].

Mức độ giao tiếp thấp nhất với QTEE được xây dựng trên ARM SMC
Convention (SMCCC) [2], là nền tảng cho Kênh bảo mật của QTEE
Trình quản lý (SCM) [3] được trình điều khiển sử dụng nội bộ.

Trong hệ thống dựa trên QTEE, các dịch vụ được biểu diễn dưới dạng các đối tượng với một loạt
các hoạt động có thể được gọi để tạo ra kết quả, bao gồm cả các đối tượng khác.

Khi một đối tượng được lưu trữ trong QTEE, việc thực thi các hoạt động của nó sẽ được tham chiếu
thành "lời gọi trực tiếp". QTEE cũng có thể gọi các đối tượng được lưu trữ ở nơi không an toàn
world bằng phương pháp được gọi là "yêu cầu gọi lại".

SCM cung cấp hai chức năng để hỗ trợ các yêu cầu gọi lại và gọi lại trực tiếp:

- QCOM_SCM_SMCINVOKE_INVOKE: Dùng để gọi trực tiếp. Nó có thể trở lại
  một kết quả hoặc bắt đầu một yêu cầu gọi lại.
- QCOM_SCM_SMCINVOKE_CB_RSP: Dùng để gửi phản hồi cho yêu cầu gọi lại
  được kích hoạt bởi lời gọi trực tiếp trước đó.

Thông báo vận chuyển QTEE [4] được xếp chồng lên trên các chức năng của trình điều khiển SCM.

Một tin nhắn bao gồm hai bộ đệm được chia sẻ với QTEE: gửi đến và gửi đi
bộ đệm. Bộ đệm gửi đến được sử dụng để gọi trực tiếp và bộ đệm gửi đi
bộ đệm được sử dụng để thực hiện các yêu cầu gọi lại. Hình ảnh này thể hiện nội dung của
tin nhắn truyền tải QTEE::

+----------------------+
                                      |                     v
    +--------+-------+-------+------+-----------------+
    | qcomtee_msg_    |object ZZ0001ZZ |
    ZZ0002ZZ id ZZ0003ZZ | (bộ đệm gửi đến)
    +--------+-------+--------------+--------------------------+
    <---- tiêu đề -----><--- đối số ------><- tải trọng bộ đệm vào/ra ->

+----------+
                                      |           v
    +--------+-------+-------+------+----------------------+
    | qcomtee_msg_    |object ZZ0001ZZ |
    ZZ0002ZZ id ZZ0003ZZ | (bộ đệm gửi đi)
    +--------+-------+--------------+----------------------+

Mỗi bộ đệm được bắt đầu bằng một tiêu đề và mảng đối số.

QTEE Transport Message hỗ trợ bốn loại đối số:

- Đối tượng đầu vào (IO) là tham số đối tượng cho lệnh gọi hiện tại
  hoặc yêu cầu gọi lại.
- Đối tượng đầu ra (OO) là tham số đối tượng từ lệnh gọi hiện tại
  hoặc yêu cầu gọi lại.
- Bộ đệm đầu vào (IB) là cặp (offset, size) cho vùng vào hoặc ra
  để lưu trữ tham số cho yêu cầu gọi hoặc gọi lại hiện tại.
- Bộ đệm đầu ra (OB) là cặp (offset, size) cho vùng vào hoặc ra
  để lưu trữ tham số từ yêu cầu gọi hoặc gọi lại hiện tại.

Hình ảnh về mối quan hệ giữa các thành phần khác nhau trong QTEE
kiến trúc::

Không gian người dùng Kernel Secure world
         ~~~~~~~~~~ ~~~~~~ ~~~~~~~~~~~~
   +--------+ +----------+ +--------------+
   ZZ0001ZZ ZZ0002ZZ ZZ0003ZZ
   +--------+ ZZ0004ZZ ZZ0005ZZ
      /\ +----------+ +--------------+
      ||  +----------+ /\ /\
      ||  |gọi lại ZZ0007ZZZZ0008ZZ|
      ||  |máy chủ ZZ0010ZZ|                                          \/
      |ZZ0011ZZ|                                   +--------------+
      |ZZ0012ZZZZ0013ZZ TEE Nội bộ |
      |ZZ0014ZZZZ0015ZZZZ0016ZZ API |
      \/ \/ \/ +--------+--------+ +--------------+
   +----------------------+ ZZ0017ZZ QTEE ZZ0018ZZ QTEE |
   Trình điều khiển ZZ0019ZZ ZZ0020ZZ ZZ0021ZZ Hệ điều hành đáng tin cậy |
   +-------+--------------+--+----+-------+----+-------------+--------------+
   ZZ0022ZZ ZZ0023ZZ
   ZZ0024ZZ
   +------------------------------------------+ +---------------------------------+

Tài liệu tham khảo
==========

[1] ZZ0000ZZ

[2] ZZ0000ZZ

[3] trình điều khiển/chương trình cơ sở/qcom/qcom_scm.c

[4] trình điều khiển/tee/qcomtee/qcomtee_msg.h

[5] ZZ0000ZZ