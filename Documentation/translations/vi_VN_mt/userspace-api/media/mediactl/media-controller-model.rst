.. SPDX-License-Identifier: GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/mediactl/media-controller-model.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

.. _media-controller-model:

Mẫu thiết bị đa phương tiện
==================

Khám phá cấu trúc liên kết bên trong của thiết bị và định cấu hình nó khi chạy,
là một trong những mục tiêu của bộ điều khiển phương tiện API. Để đạt được điều này,
các thiết bị phần cứng và giao diện hạt nhân Linux được mô hình hóa dưới dạng biểu đồ
các đối tượng trên đồ thị có hướng. Các loại đối tượng cấu thành biểu đồ
là:

- ZZ0000ZZ là khối xây dựng phần cứng hoặc phần mềm đa phương tiện cơ bản.
   Nó có thể tương ứng với nhiều khối logic khác nhau như
   thiết bị phần cứng vật lý (ví dụ cảm biến CMOS), logic
   thiết bị phần cứng (khối xây dựng trong hình ảnh Hệ thống trên chip
   đường ống xử lý), kênh DMA hoặc đầu nối vật lý.

- ZZ0000ZZ là biểu đồ biểu thị của Hạt nhân Linux
   giao diện không gian người dùng API, giống như nút thiết bị hoặc tệp sysfs
   kiểm soát một hoặc nhiều thực thể trong biểu đồ.

- ZZ0000ZZ là điểm cuối kết nối dữ liệu mà qua đó một thực thể có thể
   tương tác với các thực thể khác. Dữ liệu (không giới hạn ở video) được tạo
   bởi một thực thể chảy từ đầu ra của thực thể này tới một hoặc nhiều thực thể
   đầu vào. Không nên nhầm lẫn các miếng đệm với các chân vật lý trên chip
   ranh giới.

- ZZ0000ZZ là kết nối định hướng điểm-điểm giữa hai
   miếng đệm, trên cùng một thực thể hoặc trên các thực thể khác nhau. Luồng dữ liệu
   từ bảng nguồn đến bảng chìm.

- ZZ0000ZZ là bộ điều khiển hai chiều điểm-điểm
   kết nối giữa giao diện hạt nhân Linux và một thực thể.

- ZZ0000ZZ là kết nối điểm-điểm biểu thị hai
  các thực thể tạo thành một đơn vị logic duy nhất. Ví dụ, điều này có thể đại diện cho
  thực tế là một cảm biến máy ảnh và bộ điều khiển ống kính cụ thể tạo thành một
  mô-đun vật lý, nghĩa là bộ điều khiển ống kính này điều khiển ống kính cho việc này
  cảm biến máy ảnh.