.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/networking/pse-pd/pse-pi.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

Tài liệu về giao diện nguồn PSE (PSE PI)
==========================================

Giao diện nguồn của thiết bị tìm nguồn điện (PSE PI) đóng vai trò then chốt trong
kiến trúc của hệ thống cấp nguồn qua Ethernet (PoE). Về cơ bản nó là một
kế hoạch chi tiết phác thảo cách một hoặc nhiều nguồn điện được kết nối với
giắc cắm mô-đun tám chân, thường được gọi là cổng Ethernet RJ45. Cái này
sơ đồ kết nối rất quan trọng để cho phép cung cấp năng lượng cùng với dữ liệu
qua cáp Ethernet.

Tài liệu và tiêu chuẩn
---------------------------

Tiêu chuẩn IEEE 802.3 cung cấp tài liệu chi tiết về PSE PI.
Cụ thể:

- Mục "33.2.3 Cách gán chân PI" bao gồm cách gán chân cho PoE
  hệ thống sử dụng hai cặp để cung cấp năng lượng.
- Phần "145.2.4 PSE PI" đề cập đến cấu hình cho hệ thống PoE
  cung cấp năng lượng cho cả bốn cặp cáp Ethernet.

PSE PI và Ethernet cặp đơn
-------------------------------

Ethernet một cặp (SPE) thể hiện một cách tiếp cận khác với Ethernet
kết nối, chỉ sử dụng một cặp dây dẫn cho cả dữ liệu và nguồn điện
truyền tải. Không giống như các cấu hình chi tiết trong PSE PI dành cho tiêu chuẩn
Ethernet, có thể liên quan đến nhiều thỏa thuận tìm nguồn điện trên bốn hoặc
hai cặp dây, SPE hoạt động theo mô hình đơn giản hơn do có một cặp dây
thiết kế. Kết quả là sự phức tạp của việc lựa chọn giữa các pin thay thế
nhiệm vụ phân phối điện năng, như được mô tả trong PSE PI cho nhiều cặp
Ethernet, không áp dụng cho SPE.

Tìm hiểu PSE PI
--------------------

Giao diện nguồn của thiết bị tìm nguồn điện (PSE PI) là một khung xác định
Thiết bị cấp nguồn (PSE) cung cấp điện cho các Thiết bị cấp nguồn (PD) như thế nào
Cáp Ethernet. Nó nêu chi tiết hai cấu hình chính để cung cấp điện, được biết đến
là Phương án A và Phương án B, được phân biệt không chỉ bởi
phương pháp truyền tải điện mà còn bởi những tác động đối với sự phân cực và dữ liệu
hướng truyền tải.

Tổng quan về phương án A và B
-----------------------------

- ZZ0000ZZ Sử dụng dây dẫn RJ45 1, 2, 3 và 6. Trong cả hai trường hợp
  mạng 10/100BaseT hoặc 1G/2G/5G/10GBaseT, các cặp được sử dụng đang mang dữ liệu.
  Độ phân cực của nguồn điện trong giải pháp thay thế này có thể khác nhau tùy theo MDI
  (Giao diện phụ thuộc trung bình) hoặc MDI-X (Giao diện chéo phụ thuộc trung bình)
  cấu hình.

- ZZ0000ZZ Sử dụng dây dẫn RJ45 4, 5, 7 và 8. Trong trường hợp
  Mạng 10/100BaseT mà các cặp được sử dụng là các cặp dự phòng không có dữ liệu và ít hơn
  bị ảnh hưởng bởi hướng truyền dữ liệu. Đây không phải là trường hợp đối với
  Mạng 1G/2G/5G/10GBaseT. Phương án B bao gồm hai cấu hình với
  các cực khác nhau, được gọi là biến thể X và biến thể S, để phù hợp
  yêu cầu mạng khác nhau và thông số kỹ thuật của thiết bị.

Bảng 145-3 Các lựa chọn thay thế sơ đồ chân PSE
-----------------------------------------------

Bảng sau đây phác thảo các cấu hình chân cho cả Phương án A và
Phương án B.

+-------------+-------------------+-----------------+-----------------+----+
ZZ0000ZZ Thay thế A ZZ0001ZZ Thay thế B ZZ0002ZZ
ZZ0003ZZ (MDI-X) ZZ0004ZZ (X) ZZ0005ZZ
+=============+=======================================================================================================================================================================
ZZ0006ZZ Âm V ZZ0007ZZ - ZZ0008ZZ
+-------------+-------------------+-----------------+-----------------+----+
ZZ0009ZZ Âm V ZZ0010ZZ - ZZ0011ZZ
+-------------+-------------------+-----------------+-----------------+----+
ZZ0012ZZ Tích Cực V ZZ0013ZZ - ZZ0014ZZ
+-------------+-------------------+-----------------+-----------------+----+
ZZ0015ZZ - ZZ0016ZZ Âm V ZZ0017ZZ
+-------------+-------------------+-----------------+-----------------+----+
ZZ0018ZZ - ZZ0019ZZ Âm V ZZ0020ZZ
+-------------+-------------------+-----------------+-----------------+----+
ZZ0021ZZ Tích Cực V ZZ0022ZZ - ZZ0023ZZ
+-------------+-------------------+-----------------+-----------------+----+
ZZ0024ZZ - ZZ0025ZZ Tích Cực V ZZ0026ZZ
+-------------+-------------------+-----------------+-----------------+----+
ZZ0027ZZ - ZZ0028ZZ Tích cực V ZZ0029ZZ
+-------------+-------------------+-----------------+-----------------+----+

.. note::
    - "Positive V" and "Negative V" indicate the voltage polarity for each pin.
    - "-" indicates that the pin is not used for power delivery in that
      specific configuration.

Khả năng tương thích của PSE PI
-------------------------------

Bảng sau đây phác thảo khả năng tương thích giữa giải pháp thay thế sơ đồ chân
và 1000/2.5G/5G/10GBaseT trong kết nối 2 cặp PSE.

+----------+--------------+----------------------+--------------+
ZZ0000ZZ Khả năng tương thích ZZ0001ZZ thay thế với |
ZZ0002ZZ (A/B) ZZ0003ZZ 1000/2.5G/5G/10GBaseT |
+========================================================================================================================================================
ZZ0004ZZ A ZZ0005ZZ Có |
+----------+--------------+----------------------+--------------+
ZZ0006ZZ B ZZ0007ZZ Có |
+----------+--------------+----------------------+--------------+
ZZ0008ZZ B ZZ0009ZZ Không |
+----------+--------------+----------------------+--------------+

.. note::
    - "Direct" indicate a variant where the power is injected directly to pairs
       without using magnetics in case of spare pairs.
    - "Phantom" indicate power path over coils/magnetics as it is done for
       Alternative A variant.

Trong trường hợp PSE 4 cặp, PSE chỉ hỗ trợ 10/100BaseT (có nghĩa là Trực tiếp
Bật nguồn sơ đồ chân thay thế B) không tương thích với 4 cặp
1000/2.5G/5G/10GBaseT.

Sơ đồ kết nối giao diện nguồn PSE (PSE PI)
-----------------------------------------------

Sơ đồ bên dưới minh họa kiến trúc kết nối giữa RJ45
cổng, Ethernet PHY (Lớp vật lý) và PSE PI (Nguồn điện
Giao diện nguồn thiết bị), thể hiện cách phân phối nguồn và dữ liệu
đồng thời thông qua cáp Ethernet. Cổng RJ45 đóng vai trò là cổng vật lý
giao diện cho các kết nối này, với mỗi chân trong số tám chân của nó được kết nối với cả hai
Ethernet PHY để truyền dữ liệu và PSE PI để cấp nguồn.

.. code-block::

    +--------------------------+
    |                          |
    |          RJ45 Port       |
    |                          |
    +--+--+--+--+--+--+--+--+--+                +-------------+
      1| 2| 3| 4| 5| 6| 7| 8|                   |             |
       |  |  |  |  |  |  |  o-------------------+             |
       |  |  |  |  |  |  o--|-------------------+             +<--- PSE 1
       |  |  |  |  |  o--|--|-------------------+             |
       |  |  |  |  o--|--|--|-------------------+             |
       |  |  |  o--|--|--|--|-------------------+  PSE PI     |
       |  |  o--|--|--|--|--|-------------------+             |
       |  o--|--|--|--|--|--|-------------------+             +<--- PSE 2 (optional)
       o--|--|--|--|--|--|--|-------------------+             |
       |  |  |  |  |  |  |  |                   |             |
    +--+--+--+--+--+--+--+--+--+                +-------------+
    |                          |
    |       Ethernet PHY       |
    |                          |
    +--------------------------+

Cấu hình PI PSE đơn giản cho giải pháp thay thế A
-------------------------------------------------

Sơ đồ bên dưới minh họa PSE PI (Nguồn điện
Cấu hình Giao diện nguồn thiết bị) được thiết kế để hỗ trợ Giải pháp thay thế A
thiết lập cho Cấp nguồn qua Ethernet (PoE). Việc triển khai này được thiết kế để cung cấp
cấp nguồn thông qua các cặp mang dữ liệu của cáp Ethernet, phù hợp
cho các cấu hình MDI hoặc MDI-X, mặc dù hỗ trợ một biến thể tại một
thời gian.

.. code-block::

         +-------------+
         |    PSE PI   |
 8  -----+                             +-------------+
 7  -----+                    Rail 1   |
 6  -----+------+----------------------+
 5  -----+      |                      |
 4  -----+      |             Rail 2   |  PSE 1
 3  -----+------/         +------------+
 2  -----+--+-------------/            |
 1  -----+--/                          +-------------+
         |
         +-------------+

Trong cấu hình này:

- Chân 1 và 2 cũng như chân 3 và 6 được sử dụng để cấp nguồn trong
  Ngoài việc truyền dữ liệu. Điều này phù hợp với hệ thống dây điện tiêu chuẩn cho
  Mạng Ethernet 10/100BaseT trong đó các cặp này được sử dụng cho dữ liệu.
- Rail 1 và Rail 2 đại diện cho các ray điện áp dương và âm, có
  Đường ray 1 được kết nối với chân 1 và 2 và Đường ray 2 được kết nối với chân 3 và 6.
  Các cấu hình PSE PI nâng cao hơn có thể bao gồm tích hợp hoặc bên ngoài
  công tắc để thay đổi cực tính của đường ray điện áp, cho phép
  khả năng tương thích với cả cấu hình MDI và MDI-X.

Các cấu hình PSE PI phức tạp hơn có thể bao gồm các thành phần bổ sung, để hỗ trợ
Phương án B hoặc để cung cấp các tính năng bổ sung như quản lý năng lượng hoặc
khả năng cung cấp điện bổ sung như cung cấp điện 2 đôi hoặc 4 đôi.

.. code-block::

         +-------------+
         |    PSE PI   |
         |        +---+
 8  -----+--------+   |                 +-------------+
 7  -----+--------+   |       Rail 1   |
 6  -----+--------+   +-----------------+
 5  -----+--------+   |                |
 4  -----+--------+   |       Rail 2   |  PSE 1
 3  -----+--------+   +----------------+
 2  -----+--------+   |                |
 1  -----+--------+   |                 +-------------+
         |        +---+
         +-------------+

Cấu hình cây thiết bị: Mô tả cấu hình PI PSE
-----------------------------------------------------------

Sự cần thiết của nút PI PSE riêng biệt trong cây thiết bị bị ảnh hưởng bởi
sự phức tạp của việc thiết lập hệ thống Cấp nguồn qua Ethernet (PoE). Đây là
mô tả về cấu hình PSE PI đơn giản và phức tạp để minh họa
quá trình ra quyết định này:

ZZ0000ZZ
Trong một kịch bản đơn giản, thiết lập PSE PI liên quan đến việc trực tiếp, một-một
kết nối giữa một bộ điều khiển PSE duy nhất và cổng Ethernet. thiết lập này
thường hỗ trợ chức năng PoE cơ bản mà không cần
cấu hình hoặc quản lý nhiều chế độ cung cấp điện. Đối với đơn giản như vậy
cấu hình, nêu chi tiết PSE PI trong nút của bộ điều khiển PSE hiện có
có thể đủ, vì hệ thống không chứa đựng sự phức tạp bổ sung mà
đảm bảo một nút riêng biệt. Trọng tâm chính ở đây là sự rõ ràng và trực tiếp
liên kết phân phối điện tới một cổng Ethernet cụ thể.

ZZ0000ZZ
Ngược lại, thiết lập PSE PI phức tạp có thể bao gồm nhiều bộ điều khiển PSE hoặc
các mạch phụ trợ quản lý chung việc cung cấp điện cho một Ethernet
cổng. Những cấu hình như vậy có thể hỗ trợ nhiều tiêu chuẩn PoE và yêu cầu
khả năng cấu hình động việc cung cấp điện dựa trên hoạt động
(ví dụ: PoE2 so với PoE4) hoặc các yêu cầu cụ thể của thiết bị được kết nối. trong
trong những trường hợp này, nút PI PSE chuyên dụng trở nên cần thiết để đảm bảo độ chính xác
tài liệu hóa kiến trúc hệ thống. Nút này sẽ phục vụ để trình bày chi tiết
tương tác giữa các bộ điều khiển PSE khác nhau, hỗ trợ cho nhiều PoE khác nhau
các chế độ và bất kỳ logic bổ sung nào cần thiết để điều phối việc cung cấp năng lượng trên
cơ sở hạ tầng mạng.

ZZ0000ZZ

Để thiết lập PSE đơn giản, bao gồm thông tin PI PSE trong nút điều khiển PSE
có thể đủ do tính chất đơn giản của các hệ thống này. Tuy nhiên,
cấu hình phức tạp, liên quan đến nhiều thành phần hoặc tính năng PoE nâng cao,
được hưởng lợi từ nút PI PSE chuyên dụng. Phương pháp này tuân thủ IEEE 802.3
thông số kỹ thuật, cải thiện tính rõ ràng của tài liệu và đảm bảo tính chính xác
thể hiện sự phức tạp của hệ thống PoE.

Nút PSE PI: Thông tin cần thiết
----------------------------------

Nút PSE PI (Giao diện nguồn của thiết bị tìm nguồn điện) trong cây thiết bị có thể
bao gồm một số thông tin quan trọng quan trọng để xác định quyền lực
khả năng phân phối và cấu hình của hệ thống PoE (Cấp nguồn qua Ethernet).
Dưới đây là danh sách các thông tin như vậy, cùng với lời giải thích cho
sự cần thiết và lý do tại sao chúng có thể không được tìm thấy trong nút điều khiển PSE:

1. ZZ0000ZZ

- ZZ0000ZZ Xác định các cặp được sử dụng để cung cấp năng lượng trong
     Cáp Ethernet.
   - ZZ0001ZZ Cần thiết để đảm bảo các cặp chính xác được cấp nguồn theo
     đến thiết kế của bảng.
   - ZZ0002ZZ Thường thiếu thông tin chi tiết về cách sử dụng cặp vật lý,
     tập trung vào việc điều tiết điện năng.

2. ZZ0000ZZ

- ZZ0000ZZ Chỉ định cực (dương hoặc âm) cho mỗi
     cặp được cấp nguồn.
   - ZZ0001ZZ Quan trọng để truyền tải điện an toàn và hiệu quả tới các PD.
   - Quản lý phân cực ZZ0002ZZ có thể vượt quá tiêu chuẩn
     chức năng của bộ điều khiển PSE.

3. ZZ0000ZZ

- ZZ0000ZZ Chi tiết liên kết các ô PSE với cổng Ethernet hoặc
     cặp trong cấu hình đa ô.
   - ZZ0001ZZ Cho phép phân bổ nguồn điện tối ưu trong các hệ thống phức tạp
     hệ thống.
   - Bộ điều khiển ZZ0002ZZ có thể không quản lý các liên kết ô
     trực tiếp, thay vào đó tập trung vào việc điều tiết dòng điện.

4. ZZ0000ZZ

- ZZ0000ZZ Liệt kê các tiêu chuẩn và cấu hình PoE được hỗ trợ bởi
     hệ thống.
   - ZZ0001ZZ Đảm bảo khả năng tương thích của hệ thống với nhiều PD và sự tuân thủ khác nhau
     theo tiêu chuẩn ngành.
   - ZZ0002ZZ Khả năng cụ thể có thể phụ thuộc vào PSE tổng thể
     Thiết kế PI chứ không chỉ riêng bộ điều khiển. Nhiều ô PSE trên mỗi PI
     không nhất thiết ngụ ý hỗ trợ nhiều tiêu chuẩn PoE.

5. ZZ0000ZZ

- ZZ0000ZZ Phác thảo các cơ chế bảo vệ bổ sung, chẳng hạn như
     bảo vệ quá dòng và quản lý nhiệt.
   - ZZ0001ZZ Cung cấp thêm sự an toàn và ổn định, bổ sung cho PSE
     bảo vệ bộ điều khiển.
   - ZZ0002ZZ Một số biện pháp bảo vệ có thể được thực hiện thông qua
     phần cứng hoặc thuật toán dành riêng cho bo mạch bên ngoài bộ điều khiển.