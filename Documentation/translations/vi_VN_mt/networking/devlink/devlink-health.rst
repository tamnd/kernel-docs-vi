.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/networking/devlink/devlink-health.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

================
Sức khỏe Devlink
==============

Lý lịch
==========

Cơ chế sức khỏe ZZ0000ZZ được nhắm mục tiêu cho Cảnh báo theo thời gian thực, trong
để biết khi nào có sự cố xảy ra với thiết bị PCI.

* Cung cấp thông tin gỡ lỗi cảnh báo.
  * Tự chữa lành.
  * Nếu vấn đề cần sự hỗ trợ của nhà cung cấp, hãy cung cấp cách thu thập tất cả những gì cần thiết
    thông tin gỡ lỗi.

Tổng quan
========

Ý tưởng chính là thống nhất và tập trung các báo cáo sức khỏe lái xe trong
phiên bản ZZ0000ZZ chung và cho phép người dùng thiết lập khác nhau
các thuộc tính của thủ tục báo cáo và phục hồi sức khỏe.

Phóng viên sức khỏe ZZ0000ZZ:
Trình điều khiển thiết bị tạo "trình báo cáo tình trạng" cho mỗi loại lỗi/tình trạng.
Loại lỗi/Tình trạng có thể là lỗi đã biết/chung (ví dụ: lỗi PCI, lỗi fw, lỗi rx/tx)
hoặc không xác định (trình điều khiển cụ thể).
Đối với mỗi báo cáo sức khỏe đã đăng ký, người lái xe có thể đưa ra các báo cáo về lỗi/sức khỏe
không đồng bộ. Tất cả việc xử lý các báo cáo sức khỏe đều được thực hiện bởi ZZ0001ZZ.
Trình điều khiển thiết bị có thể cung cấp các lệnh gọi lại cụ thể cho từng "báo cáo sức khỏe", ví dụ:

* Thủ tục phục hồi
  * Quy trình chẩn đoán
  * Thủ tục kết xuất đối tượng
  * Thông số ban đầu Out Of Box

Các bộ phận khác nhau của tài xế có thể đăng ký các loại phóng viên sức khỏe khác nhau
với các trình xử lý khác nhau.

hành động
=======

Khi một lỗi được báo cáo, tình trạng liên kết nhà phát triển sẽ thực hiện các hành động sau:

* Nhật ký đang được gửi đến bộ đệm sự kiện theo dõi kernel
  * Tình trạng sức khỏe và số liệu thống kê đang được cập nhật cho phiên bản phóng viên
  * Kết xuất đối tượng đang được lấy và lưu tại phiên bản trình báo cáo (miễn là
    tự động kết xuất được đặt và không có kết xuất nào khác đã được lưu trữ)
  * Nỗ lực khôi phục tự động đang được thực hiện. Phụ thuộc vào:

- Cấu hình tự động phục hồi
    - Thời gian gia hạn (và thời gian bùng nổ) so với thời gian trôi qua kể từ lần phục hồi cuối cùng

Thông báo được định dạng Devlink
=========================

Để xử lý các yêu cầu chẩn đoán tình trạng và kết xuất tình trạng của devlink, devlink tạo một
cấu trúc tin nhắn được định dạng ZZ0000ZZ và gửi nó đến cuộc gọi lại của trình điều khiển
để điền dữ liệu bằng cách sử dụng devlink fmsg API.

Devlink fmsg là một cơ chế để chuyển các bộ mô tả giữa trình điều khiển và devlink, trong
định dạng giống json. API cho phép trình điều khiển thêm các thuộc tính lồng nhau như
đối tượng, cặp đối tượng và mảng giá trị, ngoài các thuộc tính như tên và
giá trị.

Trình điều khiển nên sử dụng API này để điền vào ngữ cảnh fmsg theo định dạng sẽ
được devlink dịch sang tin nhắn netlink sau này. Khi cần gửi
dữ liệu sử dụng SKB vào lớp liên kết mạng, nó sẽ phân mảnh dữ liệu giữa
SKB khác nhau. Để thực hiện việc phân mảnh này, nó sử dụng các tổ ảo
các thuộc tính, để tránh việc sử dụng lồng nhau thực tế mà không thể phân chia giữa
SKB khác nhau.

Giao diện người dùng
==============

Người dùng có thể truy cập/thay đổi thông số của từng trình báo cáo và lệnh gọi lại cụ thể của trình điều khiển
thông qua ZZ0000ZZ, ví dụ: mỗi loại lỗi (mỗi báo cáo sức khỏe):

* Định cấu hình các tham số chung của người báo cáo (như: tắt/bật tự động khôi phục)
  * Gọi thủ tục phục hồi
  * Chạy chẩn đoán
  * Đổ đối tượng

.. list-table:: List of devlink health interfaces
   :widths: 10 90

   * - Name
     - Description
   * - ``DEVLINK_CMD_HEALTH_REPORTER_GET``
     - Retrieves status and configuration info per DEV and reporter.
   * - ``DEVLINK_CMD_HEALTH_REPORTER_SET``
     - Allows reporter-related configuration setting.
   * - ``DEVLINK_CMD_HEALTH_REPORTER_RECOVER``
     - Triggers reporter's recovery procedure.
   * - ``DEVLINK_CMD_HEALTH_REPORTER_TEST``
     - Triggers a fake health event on the reporter. The effects of the test
       event in terms of recovery flow should follow closely that of a real
       event.
   * - ``DEVLINK_CMD_HEALTH_REPORTER_DIAGNOSE``
     - Retrieves current device state related to the reporter.
   * - ``DEVLINK_CMD_HEALTH_REPORTER_DUMP_GET``
     - Retrieves the last stored dump. Devlink health
       saves a single dump. If an dump is not already stored by devlink
       for this reporter, devlink generates a new dump.
       Dump output is defined by the reporter.
   * - ``DEVLINK_CMD_HEALTH_REPORTER_DUMP_CLEAR``
     - Clears the last saved dump file for the specified reporter.

Sơ đồ sau đây cung cấp cái nhìn tổng quan chung về ZZ0000ZZ::

liên kết mạng
                                          +--------------------------+
                                          ZZ0000ZZ
                                          ZZ0001ZZ
                                          ZZ0002ZZ |
                                          +--------------------------+
                                                       |yêu cầu hoạt động
                                                       |(chẩn đoán,
      trình điều khiển devlink |recover,
                                                       |đổ)
    +--------+ +-----------------+
    ZZ0003ZZ ZZ0004ZZ |
    ZZ0005ZZ ZZ0006ZZ
    ZZ0007ZZ thực thi hoạt động ZZ0008ZZ ZZ0009ZZ
    ZZ0010ZZ |
    ZZ0011ZZ ZZ0012ZZ ZZ0013ZZ
    ZZ0014ZZ ZZ0015ZZ
    ZZ0016ZZ ZZ0017ZZ yêu cầu hoạt động |
    ZZ0018ZZ ZZ0019ZZ (phục hồi, kết xuất) |
    ZZ0020ZZ ZZ0021ZZ |
    ZZ0022ZZ ZZ0023ZZ
    Báo cáo sức khỏe ZZ0024ZZ Trình xử lý sức khỏe ZZ0025ZZ ZZ0026ZZ
    ZZ0027ZZ |
    ZZ0028ZZ ZZ0029ZZ
    Phóng viên sức khỏe ZZ0030ZZ tạo ZZ0031ZZ
    ZZ0032ZZ
    +--------+ +-----------------+