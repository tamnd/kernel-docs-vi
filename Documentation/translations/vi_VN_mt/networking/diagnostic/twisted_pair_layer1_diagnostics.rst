.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/networking/diagnostic/twisted_pair_layer1_diagnostics.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

Khái niệm chẩn đoán để điều tra các biến thể Ethernet cặp xoắn ở lớp 1 OSI
==================================================================================

Giới thiệu
------------

Tài liệu này được thiết kế cho hai đối tượng chính:

1. ZZ0000ZZ: Dành cho những người làm việc với thế giới thực
   vấn đề về Ethernet, hướng dẫn này cung cấp hướng dẫn thực tế từng bước
   quy trình khắc phục sự cố nhằm giúp xác định và giải quyết các sự cố thường gặp trong Twisted
   Ghép nối Ethernet ở OSI Lớp 1. Nếu bạn gặp phải các liên kết không ổn định, tốc độ giảm,
   hoặc các sự cố mạng bí ẩn, hãy xem ngay hướng dẫn từng bước và
   hãy làm theo nó để tìm ra giải pháp của bạn.

2. ZZ0000ZZ: Dành cho nhà phát triển làm việc với trình điều khiển mạng và PHY
   hỗ trợ, tài liệu này phác thảo quá trình chẩn đoán và nêu bật
   các khu vực mà giao diện chẩn đoán của nhân Linux có thể được mở rộng hoặc
   được cải thiện. Bằng cách hiểu rõ quy trình chẩn đoán, nhà phát triển có thể
   ưu tiên những cải tiến trong tương lai.

Hướng dẫn chẩn đoán từng bước từ Linux (Ethernet chung)
-----------------------------------------------------------

Hướng dẫn chẩn đoán này bao gồm các tình huống khắc phục sự cố Ethernet phổ biến,
tập trung vào ZZ0000ZZ trên các Ethernet khác nhau
môi trường, bao gồm ZZ0001ZZ và **Nhiều cặp
Ethernet (MPE)**, as well as power delivery technologies like **PoDL** (Nguồn điện
qua Đường dữ liệu) và ZZ0003ZZ (Khoản 33 PSE).

Hướng dẫn này được thiết kế để giúp người dùng chẩn đoán các sự cố của lớp vật lý (Lớp 1) trên
hệ thống chạy ZZ0000ZZ, sử dụng **ethtool
phiên bản 6.10 trở lên** and **iproute2 phiên bản 6.4.0 trở lên**.

Trong hướng dẫn này, chúng tôi giả định rằng người dùng có thể bị **hạn chế hoặc không có quyền truy cập vào liên kết
đối tác** và sẽ tập trung vào việc chẩn đoán các vấn đề tại địa phương.

Kịch bản chẩn đoán
~~~~~~~~~~~~~~~~~~~~

- ZZ0000ZZ: Nếu link ổn định nhưng
  có vấn đề với việc truyền dữ liệu, hãy tham khảo **OSI Lớp 2
  Hướng dẫn khắc phục sự cố**.

- ZZ0000ZZ: Đặt lại liên kết, giảm tốc độ hoặc các biến động khác
  chỉ ra các vấn đề tiềm ẩn ở lớp phần cứng hoặc vật lý.

- ZZ0000ZZ: Giao diện đã lên nhưng chưa thiết lập được liên kết.

Xác minh trạng thái giao diện
~~~~~~~~~~~~~~~~~~~~~~~

Bắt đầu bằng cách xác minh trạng thái của giao diện Ethernet để kiểm tra xem nó có
lên về mặt hành chính. Không giống như ZZ0000ZZ, cung cấp thông tin về liên kết
và trạng thái PHY, nó không hiển thị ZZ0003ZZ của giao diện.
Để kiểm tra điều này, bạn nên sử dụng lệnh ZZ0001ZZ, lệnh này mô tả giao diện
trạng thái trong dấu ngoặc nhọn ZZ0002ZZ ở đầu ra của nó.

Ví dụ: trong đầu ra ZZ0000ZZ, điều quan trọng
từ khóa là:

- ZZ0000ZZ: Giao diện ở trạng thái "UP" quản trị.
- ZZ0001ZZ: Giao diện được quản trị nhưng không có liên kết vật lý
  được phát hiện.

Nếu đầu ra hiển thị ZZ0000ZZ, điều này cho biết giao diện đang ở trạng thái
trạng thái hành chính "DOWN".

- ZZ0001ZZ ZZ0000ZZ

-ZZ0000ZZ

  .. code-block:: bash

     4: eth0: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 ...
        link/ether 88:14:2b:00:96:f2 brd ff:ff:ff:ff:ff:ff

-ZZ0000ZZ

-ZZ0000ZZ:

- Nếu đầu ra chứa ZZ0000ZZ, giao diện đã được cài đặt về mặt quản trị,
      và hệ thống đang cố gắng thiết lập một liên kết vật lý.

- Nếu bạn cũng thấy ZZ0000ZZ thì có nghĩa là liên kết vật lý chưa được kết nối
      được phát hiện, cho biết các sự cố tiềm ẩn của Lớp 1 như lỗi cáp,
      cấu hình sai hoặc không có kết nối ở đối tác liên kết. Trong trường hợp này,
      tiến tới phần ZZ0001ZZ.

-ZZ0000ZZ:

- Nếu đầu ra thiếu ZZ0000ZZ và chỉ hiển thị các trạng thái như
      ZZ0001ZZ, có nghĩa là giao diện quản trị
      xuống. Trong trường hợp này, hãy mở giao diện bằng lệnh sau:

      .. code-block:: bash

         ip link set dev <interface> up

-ZZ0000ZZ:

- Nếu giao diện là ZZ0000ZZ nhưng hiển thị ZZ0001ZZ,
    tiến tới phần ZZ0002ZZ để
    khắc phục sự cố tiềm ẩn của lớp vật lý.

- Nếu giao diện là ZZ0000ZZ và bạn đã đưa nó lên,
    đảm bảo ZZ0001ZZ xác nhận trạng thái mới của
    giao diện trước khi tiếp tục

-ZZ0000ZZ:

- Nếu đầu ra hiển thị ZZ0001ZZ và có ZZ0002ZZ thì
      giao diện đã được cài đặt về mặt quản trị và liên kết vật lý đã được
      được thiết lập thành công. Nếu mọi thứ hoạt động như mong đợi, Lớp
      1 chẩn đoán đã hoàn tất và không cần thực hiện thêm hành động nào.

- Nếu giao diện hoạt động và liên kết được phát hiện nhưng ** không có dữ liệu nào được thực hiện
      đã được chuyển**, sự cố có thể nằm ngoài Lớp 1 và bạn nên tiếp tục
      với việc chẩn đoán các lớp cao hơn của mô hình OSI. Điều này có thể liên quan đến
      kiểm tra cấu hình Lớp 2 (chẳng hạn như các vấn đề về địa chỉ Vlan hoặc MAC),
      Cài đặt lớp 3 (như địa chỉ IP, định tuyến hoặc ARP) hoặc Lớp 4 và
      ở trên (tường lửa, dịch vụ, v.v.).

- Nếu là ZZ0000ZZ hoặc ZZ0001ZZ thì đây
      có thể chỉ ra sự cố ở lớp vật lý như cáp bị lỗi, nhiễu,
      hoặc các vấn đề về cung cấp điện. Trong trường hợp này, hãy tiến hành bước tiếp theo trong
      hướng dẫn này.

Kiểm tra trạng thái liên kết và cấu hình PHY
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Sử dụng ZZ0000ZZ để kiểm tra trạng thái liên kết, cấu hình PHY, liên kết được hỗ trợ
các chế độ và số liệu thống kê bổ sung như bộ đếm ZZ0001ZZ. Cái này
bước này rất cần thiết để chẩn đoán các vấn đề của Lớp 1 như tốc độ không khớp,
vấn đề song công và sự không ổn định của liên kết.

Dành cho cả ZZ0000ZZ và ZZ0001ZZ
thiết bị, bạn sẽ sử dụng bước này để thu thập thông tin chi tiết chính về liên kết. ZZ0002ZZ
các liên kết thường hỗ trợ một tốc độ và chế độ duy nhất mà không cần tự động thương lượng (với
ngoại trừ ZZ0003ZZ), trong khi các thiết bị ZZ0004ZZ thường hỗ trợ
nhiều chế độ liên kết và tự động đàm phán.

- ZZ0001ZZ ZZ0000ZZ

-ZZ0000ZZ:

  .. code-block:: bash

     Settings for spe4:
         Supported ports: [ TP ]
         Supported link modes:   100baseT1/Full
         Supported pause frame use: No
         Supports auto-negotiation: No
         Supported FEC modes: Not reported
         Advertised link modes: Not applicable
         Advertised pause frame use: No
         Advertised auto-negotiation: No
         Advertised FEC modes: Not reported
         Speed: 100Mb/s
         Duplex: Full
         Auto-negotiation: off
         master-slave cfg: forced slave
         master-slave status: slave
         Port: Twisted Pair
         PHYAD: 6
         Transceiver: external
         MDI-X: Unknown
         Supports Wake-on: d
         Wake-on: d
         Link detected: yes
         SQI: 7/7
         Link Down Events: 2

-ZZ0000ZZ:

  .. code-block:: bash

     Settings for eth1:
         Supported ports: [ TP    MII ]
         Supported link modes:   10baseT/Half 10baseT/Full
                                 100baseT/Half 100baseT/Full
         Supported pause frame use: Symmetric Receive-only
         Supports auto-negotiation: Yes
         Supported FEC modes: Not reported
         Advertised link modes:  10baseT/Half 10baseT/Full
                                 100baseT/Half 100baseT/Full
         Advertised pause frame use: Symmetric Receive-only
         Advertised auto-negotiation: Yes
         Advertised FEC modes: Not reported
         Link partner advertised link modes:  10baseT/Half 10baseT/Full
                                              100baseT/Half 100baseT/Full
         Link partner advertised pause frame use: Symmetric Receive-only
         Link partner advertised auto-negotiation: Yes
         Link partner advertised FEC modes: Not reported
         Speed: 100Mb/s
         Duplex: Full
         Auto-negotiation: on
         Port: Twisted Pair
         PHYAD: 10
         Transceiver: internal
         MDI-X: Unknown
         Supports Wake-on: pg
         Wake-on: p
         Link detected: yes
         Link Down Events: 1

-ZZ0000ZZ:

- Ghi lại kết quả đầu ra do ZZ0000ZZ cung cấp, đặc biệt lưu ý
    ZZ0001ZZ, ZZ0002ZZ, ZZ0003ZZ và các trường liên quan khác.
    Thông tin này sẽ hữu ích cho việc phân tích sâu hơn hoặc xử lý sự cố.
    Khi đầu ra ZZ0004ZZ đã được thu thập và lưu trữ, hãy chuyển sang
    bước chẩn đoán tiếp theo.

Kiểm tra nguồn điện (PoDL hoặc PoE)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Nếu biết ZZ0000ZZ hoặc ZZ0001ZZ là ZZ0002ZZ trên hệ thống,
hoặc ZZ0003ZZ (Thiết bị tìm nguồn điện) được quản lý bởi không gian người dùng độc quyền
phần mềm hoặc công cụ bên ngoài thì bạn có thể bỏ qua bước này. Trong những trường hợp như vậy, hãy xác minh nguồn điện
phân phối thông qua các phương pháp thay thế, chẳng hạn như kiểm tra các chỉ số phần cứng
(đèn LED), sử dụng đồng hồ vạn năng hoặc tư vấn phần mềm dành riêng cho nhà cung cấp để biết
giám sát tình trạng nguồn điện.

Nếu ZZ0000ZZ hoặc ZZ0001ZZ được Linux triển khai và quản lý trực tiếp, hãy làm theo
các bước sau để đảm bảo nguồn điện được phân phối chính xác:

- ZZ0001ZZ ZZ0000ZZ

-ZZ0000ZZ:

1. ZZ0000ZZ:

Nếu không có PSE nào được đính kèm hoặc giao diện không hỗ trợ PSE, hãy làm như sau
     sản lượng dự kiến:

     .. code-block:: bash

        netlink error: No PSE is attached
        netlink error: Operation not supported

2. ZZ0000ZZ:

Khi PoDL được triển khai, bạn có thể thấy các thuộc tính sau:

     .. code-block:: bash

        PSE attributes for eth1:
        PoDL PSE Admin State: enabled
        PoDL PSE Power Detection Status: delivering power

3. ZZ0000ZZ:

Đối với PoE tiêu chuẩn, đầu ra có thể trông như thế này:

     .. code-block:: bash

        PSE attributes for eth1:
        Clause 33 PSE Admin State: enabled
        Clause 33 PSE Power Detection Status: delivering power
        Clause 33 PSE Available Power Limit: 18000

-ZZ0000ZZ:

- Đôi khi, giới hạn công suất khả dụng có thể không đủ cho liên kết
    đối tác. Bạn có thể tăng giới hạn sức mạnh khi cần thiết.

- ZZ0001ZZ ZZ0000ZZ

Ví dụ:

    .. code-block:: bash

      ethtool --set-pse eth1 c33-pse-avail-pw-limit 18000
      ethtool --show-pse eth1

ZZ0000ZZ sau khi điều chỉnh giới hạn công suất:

    .. code-block:: bash

      Clause 33 PSE Available Power Limit: 18000


-ZZ0000ZZ:

- ZZ0000ZZ: Nếu ZZ0001ZZ hoặc ZZ0002ZZ không được triển khai hoặc sử dụng
    trên hệ thống, hãy chuyển sang bước chẩn đoán tiếp theo vì quá trình cấp điện đã được thực hiện
    không liên quan đến thiết lập này.

- ZZ0000ZZ: Nếu sử dụng ZZ0001ZZ hoặc ZZ0002ZZ nhưng
    không được quản lý bởi khung ZZ0003ZZ của nhân Linux (tức là nó được
    được kiểm soát bởi phần mềm không gian người dùng độc quyền hoặc các công cụ bên ngoài), phần này
    nằm ngoài phạm vi của tài liệu này. Vui lòng tham khảo nhà cung cấp cụ thể
    tài liệu hoặc công cụ bên ngoài để theo dõi và quản lý việc cung cấp điện.

-ZZ0000ZZ:

- Nếu ZZ0000ZZ là ZZ0001ZZ, hãy bật nó bằng cách chạy một trong các
      các lệnh sau:

      .. code-block:: bash

         ethtool --set-pse <devname> podl-pse-admin-control enable

hoặc, đối với Điều 33 PSE (PoE):

ethtool --set-pse <devname> c33-pse-admin-control bật

- Sau khi kích hoạt Trạng thái quản trị PSE, hãy quay lại phần đầu **Kiểm tra
      Bước Cấp nguồn (PoDL hoặc PoE)** để kiểm tra lại trạng thái cấp nguồn.

- ZZ0002ZZ: Nếu ZZ0000ZZ hiển thị gì đó
    ngoài "cung cấp năng lượng" (ví dụ: ZZ0001ZZ), hãy khắc phục sự cố
    ZZ0003ZZ. Kiểm tra các vấn đề tiềm ẩn như đoản mạch trong cáp,
    cung cấp điện không đủ hoặc lỗi ở chính PSE.

- ZZ0000ZZ: Nếu nguồn được cấp nhưng không có liên kết
    được thiết lập, hãy tiến hành chẩn đoán thêm bằng cách thực hiện **Cáp
    Diagnostics** or reviewing the **Kiểm tra trạng thái liên kết và PHY
    Các bước cấu hình** để xác định mọi vấn đề cơ bản với hệ thống vật lý
    liên kết hoặc cài đặt.

Chẩn đoán cáp
~~~~~~~~~~~~~~~~~

Sử dụng ZZ0000ZZ để kiểm tra các sự cố lớp vật lý như lỗi cáp. Bài kiểm tra
kết quả có thể khác nhau tùy thuộc vào tình trạng của cáp, công nghệ được sử dụng và
trạng thái của đối tác liên kết. Kết quả kiểm tra cáp sẽ giúp ích trong
chẩn đoán các vấn đề như mạch hở, đoản mạch, trở kháng không khớp và
các vấn đề liên quan đến tiếng ồn.

- ZZ0001ZZ ZZ0000ZZ

Sau đây là các đầu ra điển hình cho ZZ0000ZZ và
ZZ0001ZZ:

-ZZ0000ZZ:
  -ZZ0001ZZ:

  .. code-block:: bash

    Cable test completed for device eth1.
    Pair A, fault length: 25.00m
    Pair A code Open Circuit

Điều này cho thấy mạch hở hoặc lỗi cáp ở khoảng cách được báo cáo, nhưng
  kết quả có thể bị ảnh hưởng bởi trạng thái của đối tác liên kết. Tham khảo
  Phần ZZ0000ZZ để biết thêm
  giải thích các kết quả này.

-ZZ0000ZZ:
  -ZZ0001ZZ:

  .. code-block:: bash

    Cable test completed for device eth0.
    Pair A code OK
    Pair B code OK
    Pair C code Open Circuit

Ở đây, Cặp C được báo cáo là có mạch hở, trong khi Cặp A và B đang bị hở mạch.
  hoạt động chính xác. Tuy nhiên, nếu tự động đàm phán được sử dụng trên Cặp A và
  B, việc kiểm tra cáp có thể bị gián đoạn. Tham khảo phần **"Khắc phục sự cố dựa trên
  Phần Kết quả Kiểm tra Cáp"** để biết giải thích chi tiết về những vấn đề này và
  làm thế nào để giải quyết chúng.

Để biết mô tả chi tiết về các kết quả kiểm tra cáp khác nhau có thể có, vui lòng
tham khảo phần ZZ0000ZZ.

Khắc phục sự cố dựa trên kết quả kiểm tra cáp
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Sau khi chạy kiểm tra cáp, kết quả có thể giúp xác định các vấn đề cụ thể trong
kết nối vật lý. Tuy nhiên, điều quan trọng cần lưu ý là **kiểm tra cáp
kết quả phụ thuộc rất nhiều vào khả năng và đặc điểm của cả
phần cứng cục bộ và đối tác liên kết**. Độ chính xác và độ tin cậy của
kết quả có thể khác nhau đáng kể giữa việc triển khai phần cứng khác nhau.

Trong một số trường hợp, điều này có thể đưa ZZ0000ZZ vào thử nghiệm cáp hiện tại
thực hiện, khi một số kết quả nhất định có thể không phản ánh chính xác kết quả thực tế
trạng thái vật lý của cáp. Ví dụ:

- Kết quả ZZ0000ZZ không chỉ có thể cho biết thiết bị bị hỏng hoặc bị ngắt kết nối
  cáp nhưng cũng xảy ra nếu cáp được gắn đúng cách vào liên kết bị tắt nguồn
  đối tác.

- Một số PHY có thể báo cáo ZZ0000ZZ nếu đối tác liên kết nằm trong
  ZZ0001ZZ, mặc dù thực tế không có đoạn ngắn nào trên cáp.

Để giúp người dùng diễn giải kết quả hiệu quả hơn, có thể có lợi cho
mở rộng ZZ0000ZZ (Người dùng API) để cung cấp thêm ngữ cảnh hoặc
ZZ0001ZZ về các vấn đề dựa trên đặc điểm của phần cứng. Kể từ khi
những điều kỳ quặc này thường dành riêng cho phần cứng, ZZ0002ZZ sẽ là một
nguồn thông tin lý tưởng như vậy. Bằng cách cung cấp cờ hoặc gợi ý liên quan đến
dương tính giả tiềm ẩn đối với mỗi kết quả xét nghiệm, người dùng sẽ có kết quả tốt hơn
hiểu rõ những gì cần xác minh và nơi cần điều tra thêm.

Cho đến khi những cải tiến như vậy được thực hiện, người dùng nên nhận thức được những hạn chế này
và xác minh các vấn đề về cáp theo cách thủ công nếu cần. Kiểm tra vật lý có thể giúp ích
giải quyết những điều không chắc chắn liên quan đến kết quả dương tính giả.

Kết quả có thể là một trong những kết quả sau:

-ZZ0000ZZ:

- Cáp hoạt động bình thường và không phát hiện vấn đề gì.

- ZZ0000ZZ: Nếu bạn vẫn gặp sự cố thì có thể liên quan
    đến các vấn đề ở lớp cao hơn, chẳng hạn như sự không khớp song công hoặc đàm phán tốc độ,
    không phải là vấn đề của lớp vật lý.

- ZZ0002ZZ: Trong hệ thống ZZ0001ZZ, một
    Kết quả "OK" thường cũng có nghĩa là liên kết đã hoạt động và có khả năng ở trạng thái **nô lệ
    chế độ**, vì các bài kiểm tra cáp thường chỉ đạt ở chế độ này. Đối với một số
    ZZ0003ZZ PHYs, kết quả "OK" có thể xảy ra ngay cả khi cáp quá dài
    đối với phạm vi được định cấu hình của PHY (ví dụ: khi phạm vi được định cấu hình
    đối với chế độ khoảng cách ngắn).

-ZZ0000ZZ:

- Kết quả ZZ0000ZZ thường chỉ ra rằng cáp bị hỏng hoặc
    bị ngắt kết nối ở độ dài lỗi được báo cáo. Hãy xem xét những khả năng sau:

- Nếu đối tác liên kết ở trạng thái ZZ0000ZZ hoặc tắt nguồn, bạn có thể
      vẫn nhận được kết quả "Mạch hở" ngay cả khi cáp vẫn hoạt động.

- ZZ0000ZZ: Kiểm tra cáp ở chiều dài lỗi xem có hư hỏng rõ ràng không
      hoặc các kết nối lỏng lẻo. Xác minh đối tác liên kết đã được bật và đang ở trong
      đúng chế độ.

-ZZ0000ZZ:

- ZZ0000ZZ cho biết kết nối ngoài ý muốn trong cùng một
    cặp dây, thường do hư hỏng vật lý đối với cáp.

- ZZ0000ZZ: Thay thế hoặc sửa chữa cáp và kiểm tra các vấn đề vật lý
      hư hỏng hoặc các đầu nối bị uốn không đúng cách.

-ZZ0000ZZ:

- ZZ0000ZZ có nghĩa là dây từ các cặp khác nhau được
    bị chập mạch, có thể xảy ra do hư hỏng vật lý hoặc nối dây không đúng.

- ZZ0000ZZ: Thay thế hoặc sửa chữa cáp bị hỏng. Kiểm tra cáp xem có
      kết thúc không chính xác hoặc hệ thống dây điện bị chèn ép.

-ZZ0000ZZ:

- ZZ0000ZZ biểu thị sự phản xạ gây ra bởi trở kháng
    sự gián đoạn trong cáp. Điều này có thể xảy ra khi một phần của cáp bị
    trở kháng bất thường (ví dụ: khi các loại cáp khác nhau được nối với nhau
    hoặc khi có lỗi ở cáp).

- ZZ0000ZZ: Kiểm tra chất lượng cáp và đảm bảo trở kháng ổn định
      suốt chiều dài của nó. Thay thế bất kỳ phần nào của cáp không đáp ứng
      thông số kỹ thuật.

-ZZ0000ZZ:

- ZZ0000ZZ có nghĩa là thử nghiệm Đo phản xạ miền thời gian (TDR) không thể
    hoàn thành do tiếng ồn quá lớn trên cáp, có thể do
    nhiễu từ các nguồn điện từ.

- ZZ0000ZZ: Xác định và loại bỏ các nguồn điện từ
      nhiễu (EMI) gần cáp. Hãy cân nhắc việc sử dụng cáp có vỏ bọc hoặc
      định tuyến lại cáp khỏi nguồn nhiễu.

-ZZ0000ZZ:

- ZZ0000ZZ có nghĩa là thử nghiệm TDR không thể phát hiện được
    vấn đề do giới hạn độ phân giải của thử nghiệm hoặc do lỗi
    vượt quá khoảng cách mà bài kiểm tra có thể đo được.

- ZZ0000ZZ: Kiểm tra cáp bằng tay nếu có thể hoặc sử dụng cáp thay thế
      công cụ chẩn đoán có thể xử lý khoảng cách lớn hơn hoặc độ phân giải cao hơn.

-ZZ0000ZZ:

- Kết quả ZZ0000ZZ có thể xảy ra khi kiểm tra không thể phân loại được lỗi hoặc
    khi một vấn đề cụ thể nằm ngoài phạm vi phát hiện của công cụ
    khả năng.

- ZZ0000ZZ: Chạy lại thử nghiệm, xác minh trạng thái của đối tác liên kết và kiểm tra
      cáp bằng tay nếu cần thiết.

Xác minh cấu hình PHY của đối tác liên kết
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Nếu kiểm tra cáp đạt nhưng liên kết vẫn không hoạt động chính xác thì đó là
cần thiết để xác minh cấu hình PHY của đối tác liên kết. Sự không phù hợp trong
tốc độ, cài đặt song công hoặc vai trò chính-phụ có thể gây ra sự cố kết nối.

Tự động đàm phán không khớp
^^^^^^^^^^^^^^^^^^^^^^^^

- Nếu cả hai đối tác liên kết đều hỗ trợ tự động thương lượng, hãy đảm bảo rằng quá trình tự động thương lượng được thực hiện
  được bật ở cả hai bên và tất cả các chế độ liên kết được hỗ trợ đều được quảng cáo. A
  không khớp có thể dẫn đến các vấn đề kết nối hoặc hiệu suất phụ tối ưu.

- ZZ0000ZZ Đặt lại tính năng tự động đàm phán về cài đặt mặc định, thao tác này sẽ
  quảng cáo tất cả các chế độ liên kết mặc định:

  .. code-block:: bash

     ethtool -s <interface> autoneg on

- ZZ0001ZZ ZZ0000ZZ

- ZZ0000ZZ Đảm bảo rằng cả hai bên đều quảng cáo các chế độ liên kết tương thích.
  Nếu tính năng tự động thương lượng bị tắt, hãy xác minh rằng cả hai đối tác liên kết đều được định cấu hình cho
  cùng tốc độ và song công.

Ví dụ sau đây cho thấy trường hợp PHY cục bộ quảng cáo ít liên kết hơn
  chế độ hơn nó hỗ trợ. Điều này sẽ làm giảm số lượng các chế độ liên kết chồng chéo
  với đối tác liên kết. Trong trường hợp xấu nhất sẽ không có chế độ liên kết chung,
  và liên kết sẽ không được tạo:

  .. code-block:: bash

     Settings for eth0:
        Supported link modes:  1000baseT/Full, 100baseT/Full
        Advertised link modes: 1000baseT/Full
        Speed: 1000Mb/s
        Duplex: Full
        Auto-negotiation: on

Chế độ kết hợp không khớp (Tự động đàm phán ở một bên, cưỡng bức ở bên kia)
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

- Một vấn đề có thể xảy ra khi một bên đang sử dụng ZZ0000ZZ (như trong
  hầu hết các hệ thống hiện đại) và mặt còn lại được đặt thành ZZ0001ZZ
  (ví dụ: phần cứng cũ hơn có hub tốc độ đơn). Trong những trường hợp như vậy, PHY hiện đại
  sẽ cố gắng phát hiện chế độ bắt buộc ở phía bên kia. Nếu liên kết là
  được thiết lập, bạn có thể nhận thấy:

-ZZ0000ZZ.

- ZZ0000ZZ có phải là ZZ0001ZZ hay không
    hiện tại.

- Kiểu phát hiện này không phải lúc nào cũng hoạt động đáng tin cậy:

- Thông thường PHY hiện đại sẽ mặc định là ZZ0000ZZ, kể cả khi link
    đối tác thực sự được cấu hình cho ZZ0001ZZ.

- Một số PHY có thể không hoạt động đáng tin cậy nếu đối tác liên kết chuyển từ một PHY
    chế độ bắt buộc sang chế độ khác. Trong trường hợp này, chỉ có chu kỳ tăng/giảm mới có thể hữu ích.

- ZZ0000ZZ: Đặt cả hai mặt ở cùng tốc độ cố định và chế độ song công thành
  tránh các vấn đề phát hiện tiềm ẩn.

  .. code-block:: bash

     ethtool -s <interface> speed 1000 duplex full autoneg off

Vai trò Master/Slave không khớp (PHY BaseT1 và 1000BaseT)
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

- Trong các hệ thống ZZ0000ZZ (ví dụ: 1000BaseT1, 100BaseT1), thiết lập liên kết
  yêu cầu một thiết bị được cấu hình là ZZ0001ZZ và thiết bị kia là
  ZZ0002ZZ. Sự không phù hợp trong cấu hình chính-phụ này có thể ngăn cản liên kết
  kể từ khi được thành lập. Tuy nhiên, ZZ0003ZZ cũng hỗ trợ cấu hình
  vai trò chủ/nô lệ và có thể gặp phải các vấn đề tương tự.

- ZZ0000ZZ: Đặc tả ZZ0001ZZ cho phép liên kết
  các đối tác để đàm phán về vai trò chủ-nô hoặc các ưu tiên về vai trò trong quá trình
  tự thương lượng. Một số PHY có những hạn chế về phần cứng hoặc có lỗi ngăn cản
  khiến họ không thể hoạt động bình thường ở những vai trò nhất định. Trong những trường hợp như vậy, người lái xe có thể
  buộc các PHY này vào một vai trò cụ thể (ví dụ: ZZ0002ZZ hoặc **bắt buộc
  Slave**) hoặc thử tùy chọn yếu hơn bằng cách đặt tùy chọn. Nếu cả hai liên kết đối tác
  có cùng một vấn đề và bị buộc vào cùng một chế độ (ví dụ: cả hai đều bị buộc vào
  chế độ chính), họ sẽ không thể thiết lập liên kết.

- ZZ0000ZZ: Đảm bảo rằng một bên được cấu hình là ZZ0001ZZ và
  khác như ZZ0002ZZ để tránh vấn đề này, đặc biệt khi phần cứng
  có những hạn chế hoặc thử tùy chọn ZZ0003ZZ yếu hơn thay vì
  ZZ0004ZZ. Kiểm tra mọi hạn chế hoặc chế độ bắt buộc liên quan đến trình điều khiển.

-ZZ0000ZZ:

  .. code-block:: bash

     ethtool -s <interface> master-slave forced-master

hoặc:

  .. code-block:: bash

     ethtool -s <interface> master-slave forced-master speed 1000 duplex full autoneg off


-ZZ0000ZZ:

  .. code-block:: bash

     ethtool <interface>

Đầu ra ví dụ:

  .. code-block:: bash

     master-slave cfg: forced-master
     master-slave status: master

- ZZ0000ZZ: Nếu một sự cố phần cứng đã biết buộc
  PHY sang một chế độ cụ thể, điều cần thiết là phải kiểm tra mã nguồn trình điều khiển hoặc
  tài liệu phần cứng để biết chi tiết. Đảm bảo rằng các vai trò tương thích
  trên cả hai đối tác liên kết và nếu cả hai PHY bị buộc vào cùng một chế độ,
  điều chỉnh một bên cho phù hợp để giải quyết sự không phù hợp.

Giám sát việc đặt lại liên kết và giảm tốc độ
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Nếu liên kết không ổn định, thường xuyên bị reset hoặc giảm tốc độ, điều này có thể
cho biết sự cố với cáp, cấu hình PHY hoặc các yếu tố môi trường.
Mặc dù Linux vẫn chưa có cách thống nhất hoàn toàn để giám sát trực tiếp
sự kiện giảm tốc độ hoặc thay đổi tốc độ liên kết thông qua các công cụ không gian người dùng, cả Linux
nhật ký kernel và ZZ0000ZZ có thể cung cấp những hiểu biết có giá trị, đặc biệt nếu
driver hỗ trợ báo cáo các sự kiện như vậy.

-ZZ0000ZZ:

- Nhân Linux sẽ in các thay đổi trạng thái liên kết, bao gồm cả downshift
    sự kiện, trong nhật ký hệ thống. Những thông báo này thường bao gồm những thay đổi về tốc độ,
    chế độ song công và tốc độ liên kết giảm xuống (nếu trình điều khiển hỗ trợ).

-ZZ0000ZZ

    .. code-block:: bash

      dmesg -w | grep "Link is Up\|Link is Down"

- Ví dụ đầu ra (nếu xảy ra giảm số):

    .. code-block:: bash

      eth0: Link is Up - 100Mbps/Full (downshifted) - flow control rx/tx
      eth0: Link is Down

Điều này chỉ ra rằng liên kết đã được thiết lập nhưng đã chuyển xuống từ
    tốc độ cao hơn.

- ZZ0000ZZ: Không phải tất cả trình điều khiển hoặc PHY đều hỗ trợ báo cáo về số xuống số, vì vậy bạn có thể
    không thấy thông tin này cho tất cả các thiết bị.

-ZZ0001ZZ:

- Bắt đầu với phiên bản kernel và ZZ0000ZZ mới nhất, bạn có thể theo dõi
    ZZ0002ZZ sử dụng lệnh ZZ0001ZZ. Điều này sẽ cung cấp
    bộ đếm lượng liên kết bị rớt, giúp chẩn đoán các vấn đề về mất ổn định liên kết nếu
    được tài xế hỗ trợ.

-ZZ0000ZZ

    .. code-block:: bash

      ethtool -I <interface>

- Ví dụ đầu ra (nếu được hỗ trợ):

    .. code-block:: bash

      PSE attributes for eth1:
      Link Down Events: 5

Điều này cho thấy liên kết đã giảm 5 lần. Sự kiện liên kết xuống thường xuyên
    có thể chỉ ra các vấn đề về cáp hoặc môi trường cần được tiếp tục
    cuộc điều tra.

-ZZ0000ZZ:

- Mặc dù số lần giảm số hoặc sự kiện không dễ dàng được theo dõi, bạn có thể
    vẫn sử dụng ZZ0000ZZ để kiểm tra thủ công tốc độ và trạng thái liên kết hiện tại.

- ZZ0001ZZ ZZ0000ZZ

-ZZ0000ZZ

    .. code-block:: bash

      Speed: 1000Mb/s
      Duplex: Full
      Auto-negotiation: on
      Link detected: yes

Bất kỳ sự không nhất quán nào về tốc độ dự kiến hoặc cài đặt song công có thể cho thấy
    một vấn đề.

-ZZ0000ZZ:

- ZZ0000ZZ (Ethernet tiết kiệm năng lượng) có thể là nguyên nhân gây mất ổn định liên kết do
    chuyển đổi vào và ra khỏi trạng thái năng lượng thấp. Với mục đích chẩn đoán, nó
    có thể hữu ích khi ZZ0001ZZ vô hiệu hóa EEE để xác định xem nó có
    góp phần làm mất ổn định liên kết. Đây là ZZ0002ZZ
    để vô hiệu hóa quản lý năng lượng.

- ZZ0000ZZ: Tắt EEE và theo dõi xem liên kết có ổn định không. Nếu
    vô hiệu hóa EEE sẽ giải quyết được sự cố, hãy báo cáo lỗi để trình điều khiển có thể
    đã sửa.

-ZZ0000ZZ

    .. code-block:: bash

      ethtool --set-eee <interface> eee off

- ZZ0000ZZ: Nếu việc tắt EEE giải quyết được tình trạng mất ổn định thì vấn đề sẽ xảy ra
    được báo cáo cho người bảo trì như một lỗi và trình điều khiển cần được sửa chữa
    để xử lý EEE đúng cách mà không gây mất ổn định. Vô hiệu hóa EEE
    vĩnh viễn không nên được coi là một giải pháp.

-ZZ0000ZZ:

- Sử dụng ZZ0000ZZ để lấy giao diện chuẩn hóa
    thống kê nếu trình điều khiển hỗ trợ giao diện hợp nhất:

- ZZ0001ZZ ZZ0000ZZ

-ZZ0000ZZ:

    .. code-block:: bash

      phydev-RxFrames: 100391
      phydev-RxErrors: 0
      phydev-TxFrames: 9
      phydev-TxErrors: 0

- Nếu giao diện hợp nhất không được hỗ trợ, hãy sử dụng ZZ0000ZZ để
    truy xuất bộ đếm MAC và PHY. Lưu ý rằng tên bộ đếm PHY không được chuẩn hóa
    thay đổi tùy theo trình điều khiển và phải được giải thích tương ứng:

- ZZ0001ZZ ZZ0000ZZ

-ZZ0000ZZ:

    .. code-block:: bash

      rx_crc_errors: 123
      tx_errors: 45
      rx_frame_errors: 78

- ZZ0000ZZ: Nếu không có bộ đếm lỗi có ý nghĩa hoặc nếu có bộ đếm
    không được hỗ trợ, bạn có thể cần phải dựa vào việc kiểm tra vật lý (ví dụ: cáp
    điều kiện) hoặc thông báo nhật ký kernel (ví dụ: các sự kiện liên kết lên/xuống) để tiếp tục
    chẩn đoán vấn đề.

-ZZ0000ZZ:

- So sánh số lượng khung hình đi ra và đi vào được báo cáo bởi PHY và MAC.

- Có thể xảy ra sự khác biệt nhỏ do chênh lệch tốc độ lấy mẫu giữa
      Trình điều khiển MAC và PHY hoặc nếu PHY và MAC không phải lúc nào cũng đầy đủ
      được đồng bộ hóa ở trạng thái UP hoặc DOWN của chúng.

- Sự khác biệt đáng kể cho thấy các vấn đề tiềm ẩn trong đường dẫn dữ liệu
      giữa MAC và PHY.

Khi mọi cách khác đều thất bại...
~~~~~~~~~~~~~~~~~~~~~~

Vậy là bạn đã kiểm tra cáp, theo dõi nhật ký, tắt EEE và vẫn...
không có gì à? Đừng lo lắng, bạn không đơn độc. Đôi khi, gremlin Ethernet không
muốn hợp tác.

Nhưng trước khi bạn bỏ cuộc (hoặc cáp Ethernet), hãy hít một hơi thật sâu.
Luôn có khả năng là:

1. PHY của bạn có đặc điểm độc đáo, không có giấy tờ.

2. Vấn đề đang nằm im, chờ đợi thời điểm thích hợp để giải quyết một cách kỳ diệu
   tự giải quyết (này, nó sẽ xảy ra!).

3. Hoặc có thể giải pháp tối ưu vẫn chưa được phát minh.

Nếu không có điều nào ở trên mang lại cho bạn sự thoải mái thì còn một bước cuối cùng: đóng góp! Nếu
bạn đã phát hiện ra các vấn đề mới hoặc bất thường hoặc có các phương pháp chẩn đoán sáng tạo,
vui lòng chia sẻ những phát hiện của bạn và mở rộng tài liệu này. Cùng nhau, chúng tôi
có thể truy tìm mọi sự cố mạng khó nắm bắt - mỗi lần một cặp xoắn.

Hãy nhớ rằng: đôi khi giải pháp chỉ là khởi động lại, nhưng nếu không, đã đến lúc bạn phải thực hiện lại.
tìm hiểu sâu hơn - hoặc báo cáo lỗi đó!
