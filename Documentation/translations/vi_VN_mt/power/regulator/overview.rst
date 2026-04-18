.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/power/regulator/overview.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=================================================
Khung điều chỉnh điện áp và dòng điện Linux
=============================================

Về
=====

Khung này được thiết kế để cung cấp giao diện kernel tiêu chuẩn để kiểm soát
bộ điều chỉnh điện áp và dòng điện.

Mục đích là cho phép các hệ thống điều khiển động năng đầu ra của bộ điều chỉnh
nhằm tiết kiệm điện năng và kéo dài tuổi thọ pin. Điều này áp dụng cho cả điện áp
bộ điều chỉnh (trong đó điện áp đầu ra có thể điều khiển được) và bộ giảm dòng điện (trong đó
giới hạn hiện tại có thể kiểm soát được).

(C) 2008 Vi điện tử Wolfson PLC.

Tác giả: Liam Girdwood <lrg@slimlogic.co.uk>


Danh pháp
============

Một số thuật ngữ được sử dụng trong tài liệu này:

- Bộ điều chỉnh
                 - Thiết bị điện tử cung cấp điện cho các thiết bị khác.
                   Hầu hết các cơ quan quản lý có thể kích hoạt và vô hiệu hóa đầu ra của họ trong khi
                   một số có thể kiểm soát điện áp và dòng điện đầu ra của chúng.

Điện áp đầu vào -> Bộ điều chỉnh -> Điện áp đầu ra


-PMIC
                 - IC quản lý nguồn. Một IC chứa nhiều
                   bộ điều chỉnh và thường chứa các hệ thống con khác.


- Người tiêu dùng
                 - Thiết bị điện tử được cấp nguồn bằng bộ điều chỉnh.
                   - Người tiêu dùng có thể được phân thành hai loại:

Tĩnh: người tiêu dùng không thay đổi điện áp cung cấp hoặc
                   giới hạn hiện tại. Nó chỉ cần kích hoạt hoặc vô hiệu hóa
                   cung cấp điện. Điện áp cung cấp của nó được thiết lập bởi phần cứng,
                   bootloader, firmware hoặc mã khởi tạo kernel board.

Động: người tiêu dùng cần thay đổi điện áp cung cấp hoặc
                   giới hạn dòng điện để đáp ứng nhu cầu vận hành.


- Miền quyền lực
                 - Mạch điện tử được cung cấp năng lượng đầu vào bởi
                   công suất đầu ra của bộ điều chỉnh, công tắc hoặc bằng nguồn điện khác
                   miền.

Bộ điều chỉnh nguồn cung cấp có thể nằm phía sau (các) công tắc. tức là::

Bộ điều chỉnh -+-> Công tắc-1 -+-> Công tắc-2 --> [Người tiêu dùng A]
                                ZZ0000ZZ
                                |             +-> [Người tiêu dùng B], [Người tiêu dùng C]
                                |
                                +-> [Người tiêu dùng D], [Người tiêu dùng E]

Đó là một bộ điều chỉnh và ba miền năng lượng:

- Miền 1: Switch-1, Consumer D&E.
                   - Miền 2: Switch-2, Consumer B & C.
                   - Miền 3: Người tiêu dùng A.

và điều này thể hiện mối quan hệ "cung cấp":

Tên miền-1 -> Tên miền-2 -> Tên miền-3.

Một miền điện có thể có các bộ điều chỉnh được cung cấp điện
                   bởi các cơ quan quản lý khác. tức là::

Bộ điều chỉnh-1 -+-> Bộ điều chỉnh-2 -+-> [Người tiêu dùng A]
                                  |
                                  +-> [Người tiêu dùng B]

Điều này mang lại cho chúng tôi hai bộ điều chỉnh và hai miền quyền lực:

- Miền 1: Cơ quan quản lý-2, Người tiêu dùng B.
                   - Miền 2: Người tiêu dùng A.

và mối quan hệ "cung cấp":

Tên miền-1 -> Tên miền-2


- Ràng buộc
                 - Các ràng buộc được sử dụng để xác định mức năng lượng cho hiệu suất
                   và bảo vệ phần cứng. Những hạn chế tồn tại ở ba cấp độ:

Mức điều chỉnh: Điều này được xác định bởi phần cứng điều chỉnh
                   các thông số vận hành và được quy định trong bộ điều chỉnh
                   bảng dữ liệu. tức là

- Điện áp đầu ra nằm trong khoảng 800mV -> 3500mV.
                     - giới hạn đầu ra hiện tại của bộ điều chỉnh là 20mA @ 5V nhưng
                       10mA @ 10V.

Cấp miền nguồn: Điều này được xác định trong phần mềm bởi kernel
                   mã khởi tạo bảng cấp độ. Nó được sử dụng để hạn chế một
                   miền năng lượng cho một phạm vi quyền lực cụ thể. tức là

- Điện áp miền 1 là 3300mV
                     - Điện áp miền 2 là 1400mV -> 1600mV
                     - Giới hạn hiện tại của Domain-3 là 0mA -> 20mA.

Cấp độ người tiêu dùng: Điều này được xác định bởi trình điều khiển người tiêu dùng
                   tự động thiết lập mức điện áp hoặc mức giới hạn hiện tại.

ví dụ. trình điều khiển đèn nền của người tiêu dùng yêu cầu mức tăng hiện tại
                   từ 5mA đến 10mA để tăng độ chiếu sáng LCD. Điều này vượt qua
                   để vượt qua các cấp độ như sau: -

Người tiêu dùng: cần tăng độ sáng LCD. Tra cứu và
                   yêu cầu giá trị mA hiện tại tiếp theo trong bảng độ sáng (
                   Trình điều khiển tiêu dùng có thể được sử dụng trên nhiều thiết bị khác nhau
                   tính cách dựa trên cùng một thiết bị tham chiếu).

Power Domain: là giới hạn hiện tại mới trong miền
                   giới hạn hoạt động cho miền này và trạng thái hệ thống (ví dụ:
                   nguồn pin, nguồn USB)

Miền điều chỉnh: là giới hạn hiện tại mới trong
                   thông số vận hành bộ điều chỉnh cho điện áp đầu vào/đầu ra.

Nếu yêu cầu của cơ quan quản lý vượt qua tất cả các bài kiểm tra ràng buộc
                   sau đó giá trị điều chỉnh mới được áp dụng.


Thiết kế
======

Khung này được thiết kế và nhắm mục tiêu vào các thiết bị dựa trên SoC nhưng cũng có thể
liên quan đến các thiết bị không phải SoC và được chia thành bốn giao diện sau: -


1. Giao diện trình điều khiển dành cho người tiêu dùng.

Điều này sử dụng API tương tự với giao diện đồng hồ kernel trong ứng dụng tiêu dùng đó
      người lái xe có thể lấy và đặt một bộ điều chỉnh (giống như họ có thể làm với đồng hồ atm) và
      nhận/đặt điện áp, giới hạn dòng điện, chế độ, bật và tắt. Điều này nên
      cho phép người tiêu dùng kiểm soát hoàn toàn điện áp và dòng điện cung cấp của họ
      giới hạn. Điều này cũng biên dịch nếu không được sử dụng để trình điều khiển có thể được sử dụng lại trong
      hệ thống không có điều khiển công suất dựa trên bộ điều chỉnh.

Xem Tài liệu/power/regulator/consumer.rst

2. Giao diện điều khiển bộ điều chỉnh.

Điều này cho phép người điều khiển bộ điều chỉnh đăng ký bộ điều chỉnh của họ và cung cấp
      hoạt động đến cốt lõi. Nó cũng có một chuỗi cuộc gọi thông báo để truyền bá
      sự kiện điều chỉnh cho khách hàng.

Xem Tài liệu/power/regulator/regulator.rst

3. Giao diện máy.

Giao diện này dành cho mã máy cụ thể và cho phép tạo
      miền điện áp/dòng điện (có ràng buộc) cho mỗi bộ điều chỉnh. Nó có thể
      cung cấp các ràng buộc điều chỉnh sẽ ngăn ngừa hư hỏng thiết bị thông qua
      quá điện áp hoặc quá dòng do trình điều khiển máy khách bị lỗi. Nó cũng
      cho phép tạo ra một cây điều chỉnh theo đó một số bộ điều chỉnh được
      do người khác cung cấp (tương tự như cây đồng hồ).

Xem Tài liệu/nguồn/bộ điều chỉnh/machine.rst

4. Không gian người dùng ABI.

Khung này cũng xuất nhiều dữ liệu điện áp/dòng điện/opmode hữu ích sang
      không gian người dùng thông qua sysfs. Điều này có thể được sử dụng để giúp giám sát nguồn điện của thiết bị
      tiêu dùng và trạng thái.

Xem Tài liệu/ABI/testing/sysfs-class-regulator
