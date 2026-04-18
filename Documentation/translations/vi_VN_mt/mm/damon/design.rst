.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/mm/damon/design.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

======
Thiết kế
======


.. _damon_design_execution_model_and_data_structures:

Mô hình thực thi và cấu trúc dữ liệu
===================================

Thông tin liên quan đến giám sát bao gồm yêu cầu giám sát
đặc điểm kỹ thuật và sơ đồ hoạt động dựa trên DAMON được lưu trữ trong cấu trúc dữ liệu
được gọi là DAMON ZZ0000ZZ.  DAMON thực thi từng ngữ cảnh bằng một luồng nhân
được gọi là ZZ0001ZZ.  Nhiều kdamond có thể chạy song song cho các mục đích khác nhau
các loại giám sát.

Để biết cách không gian người dùng có thể thực hiện cấu hình và khởi động/dừng DAMON, hãy tham khảo
Tài liệu ZZ0000ZZ.


Kiến trúc tổng thể
====================

Hệ thống con DAMON được cấu hình với ba lớp bao gồm

- ZZ0000ZZ: Triển khai cơ bản
  hoạt động cho DAMON phụ thuộc vào mục tiêu giám sát nhất định
  không gian địa chỉ và tập hợp nguyên thủy phần mềm/phần cứng có sẵn,
- ZZ0001ZZ: Triển khai các logic cốt lõi bao gồm giám sát
  kiểm soát chi phí/độ chính xác và các hoạt động của hệ thống nhận biết truy cập trên
  lớp thiết lập hoạt động và
- ZZ0002ZZ: Triển khai các mô-đun hạt nhân cho nhiều loại
  mục đích cung cấp giao diện cho không gian người dùng, trên lõi
  lớp.


.. _damon_operations_set:

Lớp thiết lập hoạt động
====================

.. _damon_design_configurable_operations_set:

Để giám sát truy cập dữ liệu và công việc bổ sung ở mức độ thấp, DAMON cần một bộ
triển khai cho các hoạt động cụ thể phụ thuộc vào và được tối ưu hóa cho
không gian địa chỉ đích nhất định.  Ví dụ: dưới đây hai thao tác để truy cập
giám sát phụ thuộc vào không gian địa chỉ.

1. Xác định phạm vi địa chỉ mục tiêu giám sát cho không gian địa chỉ.
2. Kiểm tra truy cập phạm vi địa chỉ cụ thể trong không gian đích.

DAMON hợp nhất các triển khai này trong một lớp gọi là DAMON Operations
Thiết lập và xác định giao diện giữa nó và lớp trên.  Lớp trên
được dành riêng cho logic cốt lõi của DAMON bao gồm cơ chế kiểm soát
giám sát độ chính xác và chi phí chung.

Do đó, DAMON có thể dễ dàng được mở rộng cho bất kỳ không gian địa chỉ nào và/hoặc có sẵn
các tính năng phần cứng bằng cách định cấu hình logic cốt lõi để sử dụng thích hợp
thiết lập các hoạt động.  Nếu không có hoạt động sẵn có nào được thiết lập cho một mục đích nhất định,
tập hoạt động mới có thể được thực hiện theo giao diện giữa
các lớp.

Ví dụ: bộ nhớ vật lý, bộ nhớ ảo, không gian trao đổi, những thứ dành riêng cho
các quy trình, nút NUMA, tệp và thiết bị bộ nhớ sao lưu sẽ có thể được hỗ trợ.
Ngoài ra, nếu một số kiến trúc hoặc thiết bị hỗ trợ kiểm tra truy cập được tối ưu hóa đặc biệt
các tính năng này sẽ có thể cấu hình dễ dàng.

DAMON hiện cung cấp ba bộ hoạt động dưới đây.  Dưới ba tiểu mục
mô tả chúng hoạt động như thế nào.

- vaddr: Giám sát không gian địa chỉ ảo của các tiến trình cụ thể
 - fvaddr: Giám sát các dải địa chỉ ảo cố định
 - paddr: Giám sát không gian địa chỉ vật lý của hệ thống

Để biết cách không gian người dùng có thể thực hiện cấu hình thông qua ZZ0000ZZ, hãy tham khảo phần tệp ZZ0001ZZ của
tài liệu.


 .. _damon_design_vaddr_target_regions_construction:

Xây dựng phạm vi địa chỉ mục tiêu dựa trên VMA
-------------------------------------------

Một cơ chế hoạt động của ZZ0000ZZ DAMON được thiết lập tự động khởi tạo
và cập nhật các vùng địa chỉ mục tiêu giám sát để toàn bộ bộ nhớ
ánh xạ của các quy trình mục tiêu có thể được bao phủ.

Cơ chế này chỉ dành cho bộ hoạt động ZZ0000ZZ.  Trong trường hợp
Bộ thao tác ZZ0001ZZ và ZZ0002ZZ, người dùng được yêu cầu cài đặt thủ công
giám sát phạm vi địa chỉ mục tiêu.

Chỉ những phần nhỏ trong không gian địa chỉ ảo siêu lớn của các tiến trình mới được
được ánh xạ tới bộ nhớ vật lý và được truy cập.  Vì vậy, việc theo dõi các dữ liệu chưa được lập bản đồ
vùng địa chỉ chỉ là lãng phí.  Tuy nhiên, vì DAMON có thể giải quyết một số vấn đề
mức độ tiếng ồn bằng cách sử dụng cơ chế điều chỉnh vùng thích ứng, theo dõi mọi
việc lập bản đồ không bắt buộc phải thực hiện nhưng thậm chí có thể phải chịu chi phí cao ở một số nơi.
trường hợp.  Điều đó nói lên rằng, các khu vực chưa được lập bản đồ quá lớn bên trong mục tiêu giám sát sẽ
bị loại bỏ để không mất thời gian cho cơ chế thích ứng.

Vì lý do này, việc triển khai này chuyển đổi các ánh xạ phức tạp thành ba
các vùng riêng biệt bao gồm mọi vùng được ánh xạ của không gian địa chỉ.  hai
khoảng cách giữa ba khu vực là hai khu vực chưa được lập bản đồ lớn nhất trong khu vực nhất định
không gian địa chỉ.  Hai khu vực chưa được lập bản đồ lớn nhất sẽ là khoảng cách giữa
heap và vùng mmap()-ed trên cùng và khoảng cách giữa vùng thấp nhất
vùng mmap()-ed và ngăn xếp trong hầu hết các trường hợp.  Bởi vì những khoảng trống này là
đặc biệt lớn trong các không gian địa chỉ thông thường, chỉ cần loại trừ những địa chỉ này là đủ
để thực hiện một sự đánh đổi hợp lý.  Dưới đây cho thấy điều này một cách chi tiết::

<đống>
    <BIG UNMAPPED REGION 1>
    <vùng mmap()-ed trên cùng>
    (các vùng nhỏ mmap()-ed và các vùng munmap()-ed)
    <vùng mmap()-ed thấp nhất>
    <BIG UNMAPPED REGION 2>
    <ngăn xếp>


PTE Kiểm tra quyền truy cập dựa trên bit truy cập
-----------------------------------

Cả hai cách triển khai không gian địa chỉ vật lý và ảo đều sử dụng PTE
Accessed-bit để kiểm tra quyền truy cập cơ bản.  Chỉ có một điểm khác biệt duy nhất là cách thức
tìm (các) bit được truy cập PTE có liên quan từ địa chỉ.  Trong khi
việc triển khai địa chỉ ảo sẽ duyệt bảng trang cho tác vụ đích
của địa chỉ, việc triển khai địa chỉ vật lý sẽ đi theo từng trang
bảng có ánh xạ tới địa chỉ.  Bằng cách này, việc triển khai tìm thấy
và xóa (các) bit cho địa chỉ mục tiêu lấy mẫu tiếp theo và kiểm tra xem
(các) bit được thiết lập lại sau một khoảng thời gian lấy mẫu.  Điều này có thể làm phiền kernel khác
các hệ thống con sử dụng các bit được truy cập, cụ thể là theo dõi trang nhàn rỗi và thu hồi
logic.  DAMON không làm gì để tránh làm phiền việc theo dõi trang Nhàn rỗi, do đó việc xử lý
sự can thiệp là trách nhiệm của quản trị viên hệ thống.  Tuy nhiên, nó giải quyết được
xung đột với logic lấy lại bằng cách sử dụng cờ trang ZZ0000ZZ và ZZ0001ZZ,
giống như tính năng theo dõi trang nhàn rỗi.

.. _damon_design_addr_unit:

Đơn vị địa chỉ
------------

Lớp lõi DAMON sử dụng loại ZZ0000ZZ để theo dõi địa chỉ đích
phạm vi.  Trong một số trường hợp, không gian địa chỉ cho một tập hợp thao tác nhất định có thể là
quá lớn để có thể được xử lý với loại này.  ARM (32-bit) với vật lý lớn
phần mở rộng địa chỉ là một ví dụ.  Đối với những trường hợp như vậy, một tập hợp cho mỗi hoạt động
tham số có tên ZZ0001ZZ được cung cấp.  Nó đại diện cho yếu tố quy mô
cần được nhân với địa chỉ của lớp lõi để tính toán số thực
địa chỉ trên không gian địa chỉ nhất định.  Hỗ trợ tham số ZZ0002ZZ là
tùy theo từng hoạt động thiết lập việc thực hiện.  ZZ0003ZZ là tập hoạt động duy nhất
triển khai hỗ trợ tham số.

Nếu giá trị nhỏ hơn ZZ0000ZZ thì chỉ nên sử dụng lũy ​​thừa hai.

.. _damon_core_logic:

Logic cốt lõi
===========

.. _damon_design_monitoring:

Giám sát
----------

Bốn phần bên dưới mô tả từng cơ chế cốt lõi của DAMON và năm cơ chế
thuộc tính giám sát, ZZ0000ZZ, ZZ0001ZZ,
ZZ0002ZZ, ZZ0003ZZ và ZZ0004ZZ.

Lưu ý rằng ZZ0000ZZ phải từ 3 trở lên. Điều này là do
giám sát không gian địa chỉ ảo được thiết kế để xử lý ít nhất ba vùng để
chứa hai khu vực lớn chưa được ánh xạ thường thấy trong địa chỉ ảo thông thường
không gian. Mặc dù hạn chế này có thể không thực sự cần thiết đối với các
các bộ hoạt động như ZZ0001ZZ, nó hiện được thực thi trên tất cả DAMON
hoạt động để thống nhất.

Để biết cách không gian người dùng có thể đặt thuộc tính thông qua ZZ0000ZZ, hãy tham khảo ZZ0001ZZ
một phần của tài liệu.


Giám sát tần số truy cập
~~~~~~~~~~~~~~~~~~~~~~~~~~~

Đầu ra của DAMON cho biết tần suất truy cập các trang nào đối với một trang nhất định
thời lượng.  Độ phân giải của tần số truy cập được điều khiển bằng cách cài đặt
ZZ0000ZZ và ZZ0001ZZ.  Kiểm tra chi tiết DAMON
truy cập vào từng trang trên mỗi ZZ0002ZZ và tổng hợp kết quả.  trong
nói cách khác, đếm số lượng truy cập vào mỗi trang.  Sau mỗi lần
ZZ0003ZZ vượt qua, DAMON gọi các hàm gọi lại trước đó
được người dùng đăng ký để người dùng có thể đọc kết quả tổng hợp và sau đó
xóa kết quả.  Điều này có thể được mô tả bằng mã giả đơn giản dưới đây::

trong khi theo dõi_on:
        cho trang trong theo dõi_target:
            nếu được truy cập (trang):
                nr_accesses[trang] += 1
        nếu time() % aggregation_interval == 0:
            để gọi lại trong user_registered_callbacks:
                gọi lại(monitoring_target, nr_accesses)
            cho trang trong theo dõi_target:
                nr_accesses[trang] = 0
        ngủ (khoảng thời gian lấy mẫu)

Chi phí giám sát của cơ chế này sẽ tăng tùy ý khi
quy mô của khối lượng công việc mục tiêu tăng lên.


.. _damon_design_region_based_sampling:

Lấy mẫu dựa trên khu vực
~~~~~~~~~~~~~~~~~~~~~

Để tránh sự gia tăng không giới hạn của chi phí, DAMON nhóm các trang liền kề
được giả định là có cùng tần số truy cập vào một khu vực.  Miễn là
giả định (các trang trong một khu vực có cùng tần suất truy cập) được giữ lại, chỉ
một trang trong khu vực được yêu cầu phải được kiểm tra.  Do đó, đối với mỗi ZZ0000ZZ, DAMON chọn ngẫu nhiên một trang trong mỗi khu vực, chờ một trang
ZZ0001ZZ, kiểm tra xem trang có được truy cập trong khi đó không và
tăng bộ đếm tần số truy cập của khu vực nếu có.  Bộ đếm là
được gọi là ZZ0002ZZ của khu vực.  Vì vậy, chi phí giám sát là
có thể kiểm soát bằng cách thiết lập số vùng.  DAMON cho phép người dùng thiết lập
số vùng tối thiểu và tối đa để đánh đổi.

Tuy nhiên, chương trình này không thể bảo toàn được chất lượng đầu ra nếu
giả định không được đảm bảo.


.. _damon_design_adaptive_regions_adjustment:

Điều chỉnh vùng thích ứng
~~~~~~~~~~~~~~~~~~~~~~~~~~~

Thậm chí bằng cách nào đó các khu vực mục tiêu giám sát ban đầu được xây dựng tốt để
đáp ứng giả định (các trang trong cùng khu vực có tần suất truy cập tương tự),
mẫu truy cập dữ liệu có thể được thay đổi linh hoạt.  Điều này sẽ dẫn đến thấp
giám sát chất lượng.  Để giữ giả định càng nhiều càng tốt, DAMON
hợp nhất và phân chia một cách thích ứng từng vùng dựa trên tần suất truy cập của chúng.

Đối với mỗi ZZ0000ZZ, nó so sánh tần số truy cập
(ZZ0001ZZ) của các vùng lân cận.  Nếu sự khác biệt là nhỏ và nếu
tổng kích thước của hai vùng nhỏ hơn kích thước của tổng kích thước các vùng được chia
bởi ZZ0002ZZ, DAMON hợp nhất hai khu vực.  Nếu
kết quả là tổng số vùng vẫn cao hơn ZZ0003ZZ, nó lặp lại việc hợp nhất với sự khác biệt về tần số truy cập ngày càng tăng
ngưỡng cho đến khi đạt đến giới hạn trên của số vùng hoặc
ngưỡng trở nên cao hơn giá trị tối đa có thể (ZZ0004ZZ
chia cho ZZ0005ZZ).   Sau đó, sau khi nó báo cáo và xóa
tần số truy cập tổng hợp của từng vùng, nó chia mỗi vùng thành hai hoặc
ba vùng nếu tổng số vùng không vượt quá số lượng do người dùng chỉ định
số vùng tối đa sau khi phân chia.

Bằng cách này, DAMON cung cấp chất lượng tốt nhất và chi phí tối thiểu trong khi
giữ giới hạn mà người dùng đặt ra cho sự đánh đổi của họ.


.. _damon_design_age_tracking:

Theo dõi độ tuổi
~~~~~~~~~~~~

Bằng cách phân tích kết quả giám sát, người dùng cũng có thể tìm thấy thời gian hiện tại
mô hình truy cập của một khu vực đã được duy trì.  Điều đó có thể được sử dụng cho mục đích tốt
hiểu biết về mô hình truy cập.  Ví dụ: thuật toán vị trí trang
việc sử dụng cả tần số và lần truy cập gần đây có thể được thực hiện bằng cách sử dụng điều đó.
Để làm cho việc phân tích thời gian duy trì mẫu truy cập như vậy dễ dàng hơn, DAMON duy trì
một bộ đếm khác có tên ZZ0000ZZ ở mỗi khu vực.  Đối với mỗi ZZ0001ZZ, DAMON sẽ kiểm tra xem kích thước và tần suất truy cập của vùng có
(ZZ0002ZZ) đã thay đổi đáng kể.  Nếu vậy, bộ đếm sẽ được đặt lại về
không.  Ngược lại, bộ đếm sẽ tăng lên.


Xử lý cập nhật không gian mục tiêu động
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Phạm vi địa chỉ mục tiêu giám sát có thể thay đổi linh hoạt.  Ví dụ,
bộ nhớ ảo có thể được ánh xạ động và không được ánh xạ.  Bộ nhớ vật lý có thể
được cắm nóng.

Vì những thay đổi có thể xảy ra khá thường xuyên trong một số trường hợp, DAMON cho phép
hoạt động giám sát để kiểm tra các thay đổi động bao gồm các thay đổi ánh xạ bộ nhớ
và áp dụng nó để giám sát các cấu trúc dữ liệu liên quan đến hoạt động như
vùng nhớ mục tiêu giám sát trừu tượng chỉ trong mỗi khoảng thời gian do người dùng chỉ định
khoảng thời gian (ZZ0000ZZ).

Không gian người dùng có thể nhận kết quả giám sát thông qua giao diện sysfs DAMON và/hoặc
dấu vết.  Để biết thêm chi tiết, vui lòng tham khảo các tài liệu dành cho
ZZ0000ZZ và ZZ0001ZZ,
tương ứng.


.. _damon_design_monitoring_params_tuning_guide:

Hướng dẫn điều chỉnh thông số giám sát
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Nói tóm lại, hãy đặt ZZ0000ZZ để nắm bắt lượng truy cập có ý nghĩa
cho mục đích này.  Số lượng truy cập có thể được đo bằng ZZ0001ZZ
và ZZ0002ZZ của các vùng trong ảnh chụp nhanh kết quả giám sát tổng hợp.  các
giá trị mặc định của khoảng thời gian, ZZ0003ZZ, hóa ra lại quá ngắn trong nhiều trường hợp.
trường hợp.  Đặt ZZ0004ZZ tỷ lệ với ZZ0005ZZ.  Bởi
mặc định, ZZ0006ZZ được khuyến nghị làm tỷ lệ.

ZZ0001ZZ phải được đặt làm khoảng thời gian mà khối lượng công việc
có thể thực hiện một số lượng truy cập cho mục đích giám sát, trong khoảng thời gian đó.
Nếu khoảng thời gian quá ngắn thì chỉ có một số lượng nhỏ truy cập được ghi lại.  Như một
Kết quả là, kết quả giám sát trông giống như mọi thứ hiếm khi được truy cập.
Đối với nhiều mục đích, điều đó sẽ vô ích.  Tuy nhiên, nếu thời gian quá dài
để hội tụ các vùng với ZZ0000ZZ có thể quá dài, tùy thuộc vào
quy mô thời gian của mục đích nhất định.  Điều này có thể xảy ra nếu khối lượng công việc thực sự
chỉ thực hiện các truy cập hiếm nhưng người dùng cho rằng số lượng truy cập cho
mục đích giám sát quá cao.  Đối với những trường hợp như vậy, lượng truy cập mục tiêu vào
việc chụp trên mỗi ZZ0002ZZ nên được xem xét lại cẩn thận.  Ngoài ra, lưu ý
rằng lượng truy cập thu được không chỉ được thể hiện bằng
ZZ0003ZZ, nhưng cũng có ZZ0004ZZ.  Ví dụ: ngay cả khi mọi khu vực trên
kết quả giám sát cho thấy ZZ0005ZZ bằng 0, các khu vực vẫn có thể
được phân biệt bằng cách sử dụng các giá trị ZZ0006ZZ làm thông tin gần đây.

Do đó giá trị tối ưu của ZZ0000ZZ phụ thuộc vào quyền truy cập
cường độ của khối lượng công việc.  Người dùng nên điều chỉnh khoảng thời gian dựa trên
lượng truy cập được ghi lại trên mỗi ảnh chụp nhanh tổng hợp của giám sát
kết quả.

Lưu ý rằng giá trị mặc định của khoảng thời gian là 100 mili giây, quá
ngắn trong nhiều trường hợp, đặc biệt là trên các hệ thống lớn.

ZZ0000ZZ xác định độ phân giải của từng tập hợp.  Nếu nó được thiết lập
quá lớn, kết quả giám sát sẽ có vẻ như mọi khu vực đều hiếm như nhau
được truy cập hoặc được truy cập thường xuyên.  Tức là các vùng trở thành
không thể phân biệt được dựa trên mẫu truy cập và do đó kết quả sẽ là
vô dụng trong nhiều trường hợp sử dụng.  Nếu ZZ0001ZZ quá nhỏ thì sẽ không
làm giảm độ phân giải nhưng sẽ tăng chi phí giám sát.  Nếu nó là
đủ thích hợp để đưa ra giải pháp cho các kết quả giám sát
đủ cho mục đích nhất định, nó không nên đi xa hơn một cách không cần thiết
hạ xuống.  Nên đặt tỷ lệ thuận với ZZ0002ZZ.
Theo mặc định, tỷ lệ này được đặt là ZZ0003ZZ và vẫn được khuyến nghị.

Dựa trên hướng dẫn điều chỉnh thủ công, DAMON cung cấp khả năng điều chỉnh dựa trên núm trực quan hơn
cơ chế điều chỉnh tự động theo khoảng thời gian.  Vui lòng tham khảo ZZ0000ZZ để biết chi tiết.

Tham khảo các tài liệu bên dưới để biết ví dụ điều chỉnh dựa trên hướng dẫn ở trên.

.. toctree::
   :maxdepth: 1

   monitoring_intervals_tuning_example


.. _damon_design_monitoring_intervals_autotuning:

Tự động điều chỉnh khoảng thời gian theo dõi
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

DAMON cung cấp khả năng điều chỉnh tự động ZZ0001ZZ và ZZ0002ZZ dựa trên ZZ0000ZZ.  Cơ chế điều chỉnh cho phép
người dùng đặt số lượng sự kiện truy cập mục tiêu để quan sát thông qua DAMON trong
khoảng thời gian đã cho.  Người dùng có thể chỉ định mục tiêu theo tỷ lệ
Các sự kiện truy cập được quan sát DAMON với số lượng sự kiện tối đa theo lý thuyết
(ZZ0003ZZ) được đo trong một số tập hợp nhất định
(ZZ0004ZZ).

Các sự kiện truy cập do DAMON quan sát được tính toán theo độ chi tiết byte dựa trên
DAMON ZZ0000ZZ.  cho
Ví dụ: nếu tìm thấy một vùng có kích thước ZZ0001ZZ byte của ZZ0002ZZ ZZ0003ZZ, thì nó
có nghĩa là các sự kiện truy cập ZZ0004ZZ được DAMON quan sát.  Lý thuyết tối đa
sự kiện truy cập cho khu vực được tính theo cách tương tự, nhưng thay thế ZZ0005ZZ
với ZZ0006ZZ tối đa theo lý thuyết, có thể được tính như sau
ZZ0007ZZ.

Cơ chế tính toán tỷ lệ các sự kiện truy cập cho các tập hợp ZZ0000ZZ,
và tăng hoặc giảm ZZ0001ZZ và ZZ0002ZZ theo cùng một tỷ lệ, nếu tỷ lệ truy cập được quan sát thấp hơn hoặc cao hơn
mục tiêu tương ứng.  Tỷ lệ thay đổi khoảng thời gian được quyết định trong
tỷ lệ với khoảng cách giữa tỷ lệ mẫu hiện tại và tỷ lệ mục tiêu.

Người dùng có thể đặt thêm ZZ0000ZZ tối thiểu và tối đa có thể
được thiết lập bằng cơ chế điều chỉnh bằng hai tham số (ZZ0001ZZ và
ZZ0002ZZ).  Do cơ chế điều chỉnh thay đổi ZZ0003ZZ
và ZZ0004ZZ luôn có cùng tỷ lệ, tối thiểu và tối đa
ZZ0005ZZ sau mỗi lần thay đổi điều chỉnh có thể tự động thiết lập
cùng nhau.

Tính năng điều chỉnh bị tắt theo mặc định và người dùng cần phải đặt rõ ràng.
Theo nguyên tắc ngón tay cái và nguyên tắc Parreto, mục tiêu tỷ lệ mẫu truy cập 4%
được khuyến khích.  Lưu ý rằng nguyên tắc Parreto (quy tắc 80/20) đã được áp dụng hai lần.
Nghĩa là, giả sử tỷ lệ sự kiện truy cập được quan sát DAMON là 4% (20% của 20%)
để nắm bắt 64% (80% nhân với 80%) sự kiện truy cập thực tế (kết quả).

Để biết cách không gian người dùng có thể sử dụng tính năng này thông qua ZZ0000ZZ, hãy tham khảo phần ZZ0001ZZ của tài liệu.


.. _damon_design_damos:

Đề án hoạt động
-----------------

Một mục đích chung của giám sát truy cập dữ liệu là hiệu quả của hệ thống nhận biết truy cập
tối ưu hóa.  Ví dụ,

phân trang các vùng bộ nhớ không được truy cập trong hơn hai phút

hoặc

sử dụng THP cho các vùng bộ nhớ lớn hơn 2 MiB và hiển thị mức cao
    tần số truy cập trong hơn một phút.

Một cách tiếp cận đơn giản cho các chương trình như vậy sẽ là hướng dẫn hồ sơ
tối ưu hóa.  Nghĩa là, nhận được kết quả giám sát truy cập dữ liệu của
khối lượng công việc hoặc hệ thống sử dụng DAMON, tìm vùng bộ nhớ đặc biệt
đặc điểm bằng cách lập hồ sơ các kết quả giám sát và xây dựng hệ thống
thay đổi hoạt động cho các khu vực.  Những thay đổi có thể được thực hiện bằng cách sửa đổi hoặc
cung cấp lời khuyên cho phần mềm (ứng dụng và/hoặc kernel), hoặc
cấu hình lại phần cứng.  Cả hai cách tiếp cận ngoại tuyến và trực tuyến đều có thể
có sẵn.

Trong số đó, việc cung cấp lời khuyên cho kernel khi chạy sẽ linh hoạt và
hiệu quả nên được sử dụng rộng rãi.   Tuy nhiên, việc thực hiện các kế hoạch như vậy
có thể gây ra sự dư thừa và kém hiệu quả không cần thiết.  Hồ sơ có thể là
dư thừa nếu loại sở thích là phổ biến.  Trao đổi thông tin
bao gồm kết quả giám sát và tư vấn vận hành giữa kernel và người dùng
không gian có thể không hiệu quả.

Để cho phép người dùng giảm sự dư thừa và kém hiệu quả bằng cách giảm tải
hoạt động, DAMON cung cấp một tính năng gọi là Hoạt động dựa trên giám sát truy cập dữ liệu
Đề án (DAMOS).  Nó cho phép người dùng chỉ định các sơ đồ mong muốn của họ ở mức cao
cấp độ.  Đối với các thông số kỹ thuật như vậy, DAMON bắt đầu theo dõi, tìm các vùng có
mẫu truy cập quan tâm và áp dụng các hành động vận hành mà người dùng mong muốn
tới các vùng, trong mỗi khoảng thời gian do người dùng chỉ định, được gọi là
ZZ0000ZZ.

Để biết cách không gian người dùng có thể đặt ZZ0002ZZ qua ZZ0000ZZ, hãy tham khảo ZZ0001ZZ
một phần của tài liệu.


.. _damon_design_damos_action:

Hoạt động hành động
~~~~~~~~~~~~~~~~

Hành động quản lý mà người dùng mong muốn áp dụng cho các khu vực của họ
tiền lãi.  Ví dụ: phân trang ra, ưu tiên cho nạn nhân khai hoang tiếp theo
lựa chọn, khuyên ZZ0000ZZ thu gọn hoặc chia tách hoặc không làm gì khác ngoài
thu thập số liệu thống kê của các khu vực.

Danh sách các hành động được hỗ trợ được xác định trong DAMOS, nhưng việc triển khai
mỗi hành động nằm trong lớp thiết lập hoạt động DAMON vì việc triển khai
thường phụ thuộc vào không gian địa chỉ mục tiêu giám sát.  Ví dụ, mã
đối với việc phân trang các phạm vi địa chỉ ảo cụ thể sẽ khác với phân trang đối với
phạm vi địa chỉ vật lý.  Và các bộ triển khai hoạt động giám sát là
không bắt buộc phải hỗ trợ tất cả các hành động của danh sách.  Do đó, sự sẵn có của
hành động DAMOS cụ thể phụ thuộc vào tập hợp thao tác nào được chọn để sử dụng
cùng nhau.

Danh sách các hành động được hỗ trợ, ý nghĩa của chúng và bộ thao tác DAMON
hỗ trợ từng hành động như dưới đây.

- ZZ0000ZZ: Gọi ZZ0001ZZ vùng có ZZ0002ZZ.
   Được hỗ trợ bởi bộ hoạt động ZZ0003ZZ và ZZ0004ZZ.
 - ZZ0005ZZ: Gọi ZZ0006ZZ cho vùng có ZZ0007ZZ.
   Được hỗ trợ bởi bộ hoạt động ZZ0008ZZ và ZZ0009ZZ.
 - ZZ0010ZZ: Giành lại vùng.
   Được hỗ trợ bởi bộ hoạt động ZZ0011ZZ, ZZ0012ZZ và ZZ0013ZZ.
 - ZZ0014ZZ: Gọi ZZ0015ZZ theo vùng có ZZ0016ZZ.
   Được hỗ trợ bởi bộ hoạt động ZZ0017ZZ và ZZ0018ZZ. Khi nào
   TRANSPARENT_HUGEPAGE bị vô hiệu hóa, việc áp dụng hành động sẽ chỉ
   thất bại.
 - ZZ0019ZZ: Gọi ZZ0020ZZ theo vùng có ZZ0021ZZ.
   Được hỗ trợ bởi bộ hoạt động ZZ0022ZZ và ZZ0023ZZ. Khi nào
   TRANSPARENT_HUGEPAGE bị vô hiệu hóa, việc áp dụng hành động sẽ chỉ
   thất bại.
 - ZZ0024ZZ: Ưu tiên vùng trong danh sách LRU của nó.
   Được hỗ trợ bởi bộ hoạt động ZZ0025ZZ.
 - ZZ0026ZZ: Loại bỏ vùng ưu tiên trong danh sách LRU của nó.
   Được hỗ trợ bởi bộ hoạt động ZZ0027ZZ.
 - ZZ0028ZZ: Di chuyển các vùng ưu tiên các vùng ấm hơn.
   Được hỗ trợ bởi bộ hoạt động ZZ0029ZZ, ZZ0030ZZ và ZZ0031ZZ.
 - ZZ0032ZZ: Di chuyển các vùng ưu tiên vùng lạnh hơn.
   Được hỗ trợ bởi bộ hoạt động ZZ0033ZZ, ZZ0034ZZ và ZZ0035ZZ.
 - ZZ0036ZZ: Không làm gì khác ngoài đếm số liệu thống kê.
   Được hỗ trợ bởi tất cả các bộ hoạt động.

Áp dụng các hành động ngoại trừ ZZ0000ZZ cho một vùng được coi là thay đổi
đặc điểm của vùng.  Do đó, DAMOS đặt lại tuổi của các vùng khi có bất kỳ điều gì như vậy
hành động được áp dụng cho những hành động đó.

Để biết cách không gian người dùng có thể thiết lập hành động thông qua ZZ0000ZZ, hãy tham khảo phần ZZ0001ZZ của
tài liệu.


.. _damon_design_damos_access_pattern:

Mẫu truy cập mục tiêu
~~~~~~~~~~~~~~~~~~~~~

Mô hình truy cập của các chương trình quan tâm.  Các mẫu được xây dựng bằng
các thuộc tính mà kết quả giám sát của DAMON cung cấp, cụ thể là kích thước,
tần suất truy cập và độ tuổi.  Người dùng có thể mô tả kiểu truy cập của họ về
lãi suất bằng cách đặt giá trị tối thiểu và tối đa của ba thuộc tính.  Nếu một
ba thuộc tính của vùng nằm trong phạm vi, DAMOS phân loại nó là một trong những thuộc tính
các khu vực mà chương trình đang quan tâm.

Để biết cách không gian người dùng có thể đặt mẫu truy cập thông qua ZZ0000ZZ, hãy tham khảo phần ZZ0001ZZ của tài liệu.


.. _damon_design_damos_quotas:

hạn ngạch
~~~~~~

Tính năng kiểm soát chi phí giới hạn trên của DAMOS.  DAMOS có thể phải chịu chi phí cao nếu
mẫu truy cập mục tiêu không được điều chỉnh đúng cách.  Ví dụ, nếu một bộ nhớ lớn
khu vực có mẫu truy cập quan tâm được tìm thấy, áp dụng sơ đồ
hành động tới tất cả các trang của khu vực rộng lớn có thể tiêu tốn hệ thống lớn không thể chấp nhận được
tài nguyên.  Ngăn chặn những vấn đề như vậy bằng cách điều chỉnh mẫu truy cập có thể
đầy thách thức, đặc biệt nếu mô hình truy cập của khối lượng công việc rất cao
năng động.

Để giảm thiểu tình trạng đó, DAMOS cung cấp khả năng kiểm soát chi phí giới hạn trên
tính năng được gọi là hạn ngạch.  Nó cho phép người dùng chỉ định giới hạn thời gian trên mà DAMOS
có thể sử dụng để áp dụng hành động và/hoặc số byte tối đa của vùng bộ nhớ mà
hành động có thể được áp dụng trong khoảng thời gian do người dùng chỉ định.

Để biết cách không gian người dùng có thể đặt hạn ngạch cơ bản thông qua ZZ0000ZZ, hãy tham khảo phần ZZ0001ZZ của
tài liệu.


.. _damon_design_damos_quotas_prioritization:

Ưu tiên
^^^^^^^^^^^^^^

Một cơ chế để đưa ra quyết định đúng đắn theo hạn ngạch.  Khi hành động
không thể áp dụng cho tất cả các khu vực quan tâm do hạn ngạch, DAMOS
ưu tiên các khu vực và chỉ áp dụng hành động cho những khu vực có đủ cao
ưu tiên để không vượt quá hạn ngạch.

Cơ chế ưu tiên phải khác nhau đối với mỗi hành động.  Ví dụ,
vùng bộ nhớ hiếm khi được truy cập (lạnh hơn) sẽ được ưu tiên để loại trang
kế hoạch hành động.  Ngược lại, các vùng lạnh hơn sẽ bị mất đi mức độ ưu tiên lớn
hành động kế hoạch thu gọn trang.  Do đó, cơ chế ưu tiên cho từng
hành động được triển khai trong mỗi bộ hoạt động DAMON, cùng với các hành động.

Mặc dù việc triển khai tùy thuộc vào tập hoạt động DAMON, nhưng nó sẽ phổ biến
để tính toán mức độ ưu tiên bằng cách sử dụng thuộc tính mẫu truy cập của các vùng.
Một số người dùng muốn các cơ chế được cá nhân hóa cho mục đích cụ thể của họ
trường hợp.  Ví dụ: một số người dùng muốn cơ chế cân nhắc số lần truy cập gần đây
(ZZ0000ZZ) nhiều hơn tần số truy cập (ZZ0001ZZ).  DAMOS cho phép người dùng
để chỉ định trọng số của từng thuộc tính mẫu truy cập và chuyển
thông tin đến cơ chế cơ bản.  Tuy nhiên, làm thế nào và thậm chí liệu
trọng số sẽ được tôn trọng tùy thuộc vào cơ chế ưu tiên cơ bản
thực hiện.

Để biết cách không gian người dùng có thể đặt trọng số ưu tiên thông qua ZZ0000ZZ, hãy tham khảo phần ZZ0001ZZ của
tài liệu.


.. _damon_design_damos_quotas_auto_tuning:

Tự động điều chỉnh theo hướng phản hồi hướng tới mục tiêu
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Tự động điều chỉnh hạn ngạch dựa trên phản hồi.  Thay vì đặt hạn ngạch tuyệt đối
giá trị, người dùng có thể chỉ định số liệu mà họ quan tâm và giá trị mục tiêu
họ muốn giá trị số liệu là như vậy.  DAMOS sau đó sẽ tự động điều chỉnh
tính quyết liệt (hạn ngạch) của kế hoạch tương ứng.  Ví dụ: nếu DAMOS
đang đạt được mục tiêu, DAMOS sẽ tự động tăng hạn ngạch.  Nếu DAMOS
không đạt được mục tiêu thì giảm chỉ tiêu.

Có hai thuật toán điều chỉnh như vậy mà người dùng có thể chọn khi cần.

- ZZ0000ZZ: Thuật toán dựa trên vòng phản hồi tỷ lệ.  Cố gắng tìm một
  hạn ngạch tối ưu cần được duy trì một cách nhất quán để tiếp tục đạt được mục tiêu.
  Hữu ích cho hoạt động chỉ có kernel trên môi trường năng động và chạy dài.
  Đây là lựa chọn mặc định.  Nếu không chắc chắn, hãy sử dụng cái này.
- ZZ0001ZZ: Thuật toán đơn giản hơn.  Cố gắng đạt được mục tiêu như
  nhanh nhất có thể, sử dụng hạn ngạch tối đa được phép, nhưng chỉ trong một khoảng thời gian ngắn
  thời gian.  Khi chưa đạt được hạn ngạch, thuật toán này sẽ tiếp tục điều chỉnh hạn ngạch để
  mức tối đa cho phép.  Sau khi đã đạt được [vượt quá] hạn ngạch, điều này sẽ đặt ra
  hạn ngạch bằng không.  Hữu ích cho các môi trường cần kiểm soát xác định.

Mục tiêu có thể được chỉ định bằng năm tham số, cụ thể là ZZ0000ZZ,
ZZ0001ZZ, ZZ0002ZZ, ZZ0003ZZ và ZZ0004ZZ.  Sự tự động điều chỉnh
cơ chế cố gắng làm cho ZZ0005ZZ của ZZ0006ZZ giống với
ZZ0007ZZ.

- ZZ0000ZZ: Giá trị do người dùng cung cấp.  Người dùng có thể sử dụng bất kỳ số liệu nào mà họ
  quan tâm đến giá trị.  Sử dụng độ trễ của khối lượng công việc chính của không gian hoặc
  thông lượng, số liệu hệ thống như tỷ lệ bộ nhớ trống hoặc áp suất bộ nhớ bị đình trệ
  thời gian (PSI) có thể là ví dụ.  Lưu ý rằng người dùng nên thiết lập rõ ràng
  ZZ0001ZZ của riêng họ trong trường hợp này.  Nói cách khác, người dùng nên
  liên tục cung cấp thông tin phản hồi.
- ZZ0002ZZ: Thông tin về tình trạng ngừng áp suất bộ nhớ ZZ0003ZZ trên toàn hệ thống
  tính bằng micro giây được tính từ lần đặt lại hạn ngạch cuối cùng đến lần đặt lại hạn ngạch tiếp theo.
  DAMOS tự thực hiện phép đo nên chỉ cần ZZ0004ZZ
  do người dùng thiết lập tại thời điểm ban đầu.  Nói cách khác, DAMOS tự phản hồi.
- ZZ0005ZZ: Tỷ lệ bộ nhớ được sử dụng của nút NUMA cụ thể tính bằng bp (1/10.000).
- ZZ0006ZZ: Tỷ lệ bộ nhớ trống của nút NUMA cụ thể tính bằng bp (1/10.000).
- ZZ0007ZZ: Nút của nhóm cụ thể đã sử dụng tỷ lệ bộ nhớ cho một
  nút NUMA cụ thể, tính bằng bp (1/10.000).
- ZZ0008ZZ: Tỷ lệ bộ nhớ chưa sử dụng của nút cụ thể trong nhóm cho một
  nút NUMA cụ thể, tính bằng bp (1/10.000).
- ZZ0009ZZ: Tỷ lệ kích thước bộ nhớ hoạt động và không hoạt động (LRU) tính bằng bp
  (1/10.000).
- ZZ0010ZZ: Tỷ lệ kích thước bộ nhớ không hoạt động và không hoạt động (LRU) trong
  bp (1/10.000).

ZZ0000ZZ chỉ được yêu cầu tùy chọn cho ZZ0001ZZ,
ZZ0002ZZ, ZZ0003ZZ và ZZ0004ZZ đến
trỏ nút NUMA cụ thể.

ZZ0000ZZ chỉ được yêu cầu tùy chọn cho ZZ0001ZZ và
ZZ0002ZZ để trỏ đường dẫn đến nhóm.  Giá trị phải là
đường dẫn của nhóm bộ nhớ từ điểm gắn kết cgroups.

Để biết cách không gian người dùng có thể đặt chỉ số mục tiêu điều chỉnh, giá trị mục tiêu và/hoặc
giá trị hiện tại thông qua ZZ0000ZZ, hãy tham khảo
ZZ0001ZZ một phần của tài liệu.


.. _damon_design_damos_watermarks:

Hình mờ
~~~~~~~~~~

Tự động kích hoạt DAMOS (de) có điều kiện.  Người dùng có thể muốn DAMOS chạy
chỉ trong những tình huống nhất định.  Ví dụ: khi có đủ số lượng miễn phí
bộ nhớ được đảm bảo, việc chạy một sơ đồ để thu hồi chủ động sẽ chỉ
tiêu tốn tài nguyên hệ thống không cần thiết.  Để tránh việc tiêu thụ như vậy, người dùng sẽ
cần giám sát thủ công một số số liệu như tỷ lệ bộ nhớ trống và chuyển
Bật hoặc tắt DAMON/DAMOS.

DAMOS cho phép người dùng giảm tải những tác phẩm như vậy bằng cách sử dụng ba hình mờ.  Nó cho phép
người dùng định cấu hình số liệu mà họ quan tâm và ba giá trị hình mờ,
cụ thể là cao, trung bình và thấp.  Nếu giá trị của số liệu vượt quá giá trị
hình mờ cao hoặc dưới hình mờ thấp, lược đồ sẽ bị vô hiệu hóa.  Nếu
số liệu trở thành dưới hình mờ ở giữa nhưng ở trên hình mờ thấp, lược đồ
được kích hoạt.  Nếu tất cả các lược đồ bị vô hiệu hóa bởi hình mờ, việc giám sát
cũng bị vô hiệu hóa.  Trong trường hợp này, luồng công nhân DAMON chỉ định kỳ
kiểm tra các hình mờ và do đó phát sinh chi phí gần như bằng không.

Để biết cách không gian người dùng có thể đặt hình mờ thông qua ZZ0000ZZ, hãy tham khảo phần ZZ0001ZZ của
tài liệu.


.. _damon_design_damos_filters:

Bộ lọc
~~~~~~~

Lọc vùng bộ nhớ mục tiêu dựa trên mẫu không truy cập.  Nếu người dùng chạy
chương trình tự viết hoặc có công cụ lập hồ sơ tốt, họ có thể biết điều gì đó
nhiều hơn kernel, chẳng hạn như các mẫu truy cập trong tương lai hoặc một số đặc biệt
yêu cầu đối với các loại bộ nhớ cụ thể. Ví dụ: một số người dùng có thể biết
chỉ những trang ẩn danh mới có thể ảnh hưởng đến hiệu suất chương trình của họ.  Họ cũng có thể
có một danh sách các quy trình quan trọng về độ trễ.

Để cho phép người dùng tối ưu hóa các sơ đồ DAMOS với kiến thức đặc biệt như vậy, DAMOS cung cấp
một tính năng được gọi là bộ lọc DAMOS.  Tính năng cho phép người dùng thiết lập tùy ý
số lượng bộ lọc cho mỗi sơ đồ.  Mỗi bộ lọc chỉ định

- một loại bộ nhớ (ZZ0000ZZ),
- cho dù đó là bộ nhớ của loại hay tất cả ngoại trừ loại
  (ZZ0001ZZ) và
- cho phép (bao gồm) hay từ chối (loại trừ) việc áp dụng
  hành động của lược đồ vào bộ nhớ (ZZ0002ZZ).

Để xử lý hiệu quả các bộ lọc, một số loại bộ lọc được xử lý bởi
lớp lõi, trong khi các lớp khác được xử lý bởi tập hợp các thao tác.  Trong trường hợp sau,
do đó, việc hỗ trợ các loại bộ lọc phụ thuộc vào tập hợp hoạt động DAMON.  trong
trường hợp các bộ lọc được xử lý bởi lớp lõi, các vùng bộ nhớ bị loại trừ bởi
bộ lọc không được tính vì lược đồ đã thử vào khu vực.  Ngược lại, nếu
một vùng bộ nhớ được lọc bởi bộ lọc xử lý lớp tập hợp hoạt động, đó là
được tính như chương trình đã thử.  Sự khác biệt này ảnh hưởng đến số liệu thống kê.

Khi nhiều bộ lọc được cài đặt, nhóm bộ lọc được xử lý bởi
lớp lõi được đánh giá đầu tiên.  Sau đó, nhóm bộ lọc xử lý
bởi lớp hoạt động được đánh giá.  Các bộ lọc trong mỗi nhóm là
đánh giá theo thứ tự cài đặt.  Nếu một phần bộ nhớ khớp với một trong các
lọc, các bộ lọc tiếp theo sẽ bị bỏ qua.  Nếu phần đi qua các bộ lọc
giai đoạn đánh giá vì nó không phù hợp với bất kỳ bộ lọc nào, áp dụng
hành động của chương trình đối với nó phụ thuộc vào loại phụ cấp của bộ lọc cuối cùng.  Nếu cuối cùng
filter dùng để cho phép thì phần bộ nhớ sẽ bị từ chối và ngược lại.

Ví dụ: giả sử 1) bộ lọc để cho phép các trang ẩn danh và 2)
một bộ lọc khác để từ chối các trang trẻ được cài đặt theo thứ tự.  Nếu một trang
của khu vực đủ điều kiện áp dụng hành động của chương trình là một trang ẩn danh,
hành động của lược đồ sẽ được áp dụng cho trang bất kể nó có
trẻ hay không, vì nó phù hợp với bộ lọc cho phép đầu tiên.  Nếu trang đó là
không ẩn danh nhưng còn trẻ, hành động của kế hoạch sẽ không được áp dụng, vì
bộ lọc từ chối thứ hai chặn nó.  Nếu trang này không ẩn danh và không trẻ,
trang sẽ vượt qua giai đoạn đánh giá bộ lọc vì không có
bộ lọc phù hợp và hành động sẽ được áp dụng cho trang.

Các bộ lọc dưới đây ZZ0000ZZ hiện được hỗ trợ.

- Xử lý lớp lõi
    - địa chỉ
        - Áp dụng cho các trang thuộc một dải địa chỉ nhất định.
    - mục tiêu
        - Áp dụng cho các trang thuộc mục tiêu giám sát DAMON nhất định.
- Lớp hoạt động được xử lý, chỉ được hỗ trợ bởi bộ hoạt động ZZ0000ZZ.
    - không
        - Áp dụng cho các trang chứa dữ liệu không được lưu trữ trong tập tin.
    - hoạt động
        - Áp dụng cho các trang đang hoạt động.
    - memcg
        - Áp dụng cho các trang thuộc một nhóm nhất định.
    - trẻ
        - Áp dụng cho các trang được truy cập sau lần kiểm tra truy cập cuối cùng từ
          kế hoạch.
    - Hugepage_size
        - Áp dụng cho các trang được quản lý trong phạm vi kích thước nhất định.
    - chưa được lập bản đồ
        - Áp dụng cho các trang chưa được ánh xạ.

Để biết cách không gian người dùng có thể đặt bộ lọc thông qua ZZ0000ZZ, hãy tham khảo phần ZZ0001ZZ của
tài liệu.

.. _damon_design_damos_stat:

Thống kê
~~~~~~~~~~

Số liệu thống kê về hành vi của DAMOS được thiết kế để giúp theo dõi, điều chỉnh và
gỡ lỗi DAMOS.

DAMOS chiếm số liệu thống kê dưới đây cho từng chương trình, kể từ đầu
việc thực hiện sơ đồ.

- ZZ0000ZZ: Tổng số vùng mà lược đồ được thử áp dụng.
- ZZ0001ZZ: Tổng kích thước của các vùng mà lược đồ được thử áp dụng.
- ZZ0002ZZ: Tổng số byte vượt qua tập phép toán
  bộ lọc DAMOS được xử lý theo lớp.
- ZZ0003ZZ: Tổng số vùng được áp dụng chương trình.
- ZZ0004ZZ: Tổng kích thước vùng áp dụng lược đồ.
- ZZ0005ZZ: Tổng số lần vượt hạn mức của chương trình.
- ZZ0006ZZ: Tổng số ảnh chụp nhanh DAMON mà lược đồ được thử
  được áp dụng.
- ZZ0007ZZ: Giới hạn trên của ZZ0008ZZ.

"Một sơ đồ được cố gắng áp dụng cho một khu vực" có nghĩa là logic lõi DAMOS được xác định
khu vực đó đủ điều kiện để áp dụng ZZ0000ZZ của chương trình.  ZZ0001ZZ, ZZ0002ZZ, ZZ0003ZZ và ZZ0004ZZ xử lý logic lõi có thể ảnh hưởng đến điều này.
Logic cốt lõi sẽ chỉ yêu cầu ZZ0005ZZ cơ bản áp dụng hành động cho khu vực, vì vậy liệu
hành động có thực sự được áp dụng hay không thì không rõ ràng.  Đó là lý do tại sao nó được gọi là "đã thử".

"Một sơ đồ được áp dụng cho một khu vực" nghĩa là ZZ0000ZZ đã áp dụng hành động đó cho ít nhất một phần của
khu vực.  ZZ0001ZZ được xử lý bởi
bộ hoạt động và các loại ZZ0002ZZ
và các trang trong khu vực có thể ảnh hưởng đến điều này.  Ví dụ: nếu bộ lọc được đặt
để loại trừ các trang ẩn danh và khu vực chỉ có các trang ẩn danh, hoặc nếu
hành động là ZZ0003ZZ trong khi tất cả các trang trong khu vực đều không thể lấy lại được, áp dụng
hành động đối với khu vực sẽ thất bại.

Không giống như các số liệu thống kê thông thường, ZZ0000ZZ được thiết lập bởi người dùng.  Nếu nó được đặt là
khác không và ZZ0001ZZ bằng hoặc lớn hơn ZZ0002ZZ,
sơ đồ bị vô hiệu hóa.

Để biết cách không gian người dùng có thể đọc số liệu thống kê qua ZZ0000ZZ, hãy tham khảo phần :ref:s`stats <sysfs_stats>` của
tài liệu.

Khu vực đi bộ
~~~~~~~~~~~~~~~

Tính năng DAMOS cho phép người dùng truy cập vào từng vùng mà hành động DAMOS vừa thực hiện
áp dụng.  Sử dụng tính năng này, DAMON ZZ0000ZZ cho phép người dùng
truy cập đầy đủ các thuộc tính của các khu vực bao gồm cả kết quả giám sát truy cập
và dung lượng bộ nhớ trong của vùng đã vượt qua bộ lọc DAMOS.
ZZ0001ZZ còn cho phép người dùng đọc dữ liệu
thông qua ZZ0002ZZ đặc biệt.

.. _damon_design_api:

Giao diện lập trình ứng dụng
---------------------------------

Giao diện lập trình cho các ứng dụng nhận biết truy cập dữ liệu không gian hạt nhân.
DAMON là một framework nên bản thân nó không làm gì cả.  Thay vào đó, nó chỉ giúp
các thành phần hạt nhân khác như hệ thống con và mô-đun xây dựng dữ liệu của chúng
các ứng dụng nhận biết truy cập bằng các tính năng cốt lõi của DAMON.  Đối với điều này, DAMON tiết lộ
tất cả các tính năng của nó cho các thành phần hạt nhân khác thông qua lập trình ứng dụng của nó
giao diện, cụ thể là ZZ0001ZZ.  Vui lòng tham khảo API
ZZ0000ZZ để biết chi tiết về giao diện.


.. _damon_modules:

Mô-đun
=======

Bởi vì cốt lõi của DAMON là một khung cho các thành phần kernel nên nó không
cung cấp bất kỳ giao diện trực tiếp nào cho không gian người dùng.  Những giao diện như vậy nên
Thay vào đó, được triển khai bởi mỗi thành phần hạt nhân người dùng DAMON API.  Hệ thống con DAMON
chính nó triển khai các mô-đun người dùng DAMON API như vậy, được cho là sẽ được sử dụng
dành cho hệ thống nhận biết truy cập dữ liệu cho mục đích chung DAMON và hệ thống nhận biết truy cập dữ liệu cho mục đích đặc biệt
hoạt động và cung cấp giao diện nhị phân ứng dụng ổn định (ABI) cho
không gian người dùng.  Không gian người dùng có thể xây dựng khả năng nhận biết truy cập dữ liệu hiệu quả của họ
các ứng dụng sử dụng giao diện.


Mô-đun giao diện người dùng cho mục đích chung
--------------------------------------

Các mô-đun DAMON cung cấp ABI không gian người dùng cho mục đích sử dụng DAMON chung trong
thời gian chạy.

Giống như nhiều ABI khác, các mô-đun tạo tệp trên hệ thống tệp giả như
'sysfs', cho phép người dùng chỉ định yêu cầu của họ và nhận câu trả lời từ
DAMON bằng cách ghi và đọc từ các tập tin.  Để đáp lại những thao tác I/O như vậy,
Các mô-đun giao diện người dùng DAMON điều khiển DAMON và truy xuất kết quả dưới dạng người dùng
được yêu cầu thông qua DAMON API và trả kết quả về không gian người dùng.

ABI được thiết kế để sử dụng cho việc phát triển ứng dụng không gian người dùng,
hơn là ngón tay của con người.  Người dùng được khuyến khích sử dụng như vậy
công cụ không gian người dùng.  Một công cụ không gian người dùng được viết bằng Python như vậy có sẵn tại
Github (ZZ0000ZZ Pypi
(ZZ0001ZZ và nhiều bản phân phối
(ZZ0002ZZ

Hiện tại, một mô-đun cho loại này, cụ thể là 'Giao diện sysfs DAMON' là
có sẵn.  Vui lòng tham khảo ABI ZZ0000ZZ để biết chi tiết về
các giao diện.


.. _damon_modules_special_purpose:

Mô-đun hạt nhân nhận biết quyền truy cập có mục đích đặc biệt
-------------------------------------------

Các mô-đun DAMON cung cấp không gian người dùng ABI cho mục đích sử dụng DAMON cụ thể.

Các mô-đun giao diện người dùng DAMON có khả năng kiểm soát hoàn toàn tất cả các tính năng của DAMON trong
thời gian chạy.  Đối với mỗi hệ thống nhận biết truy cập dữ liệu trên toàn hệ thống có mục đích đặc biệt
các hoạt động như chủ động thu hồi hoặc cân bằng danh sách LRU, các giao diện
có thể được đơn giản hóa bằng cách loại bỏ các nút bấm không cần thiết cho mục đích cụ thể và
mở rộng cho thời gian khởi động và thậm chí kiểm soát thời gian biên dịch.  Giá trị mặc định của DAMON
các thông số kiểm soát việc sử dụng cũng cần phải được tối ưu hóa cho
mục đích.

Để hỗ trợ những trường hợp như vậy, vẫn còn nhiều mô-đun hạt nhân người dùng DAMON API cung cấp nhiều hơn
giao diện không gian người dùng đơn giản và tối ưu hóa có sẵn.  Hiện tại, hai
các mô-đun để thu hồi chủ động và thao tác danh sách LRU được cung cấp.  cho
chi tiết hơn, vui lòng đọc tài liệu sử dụng cho những
(ZZ0000ZZ, ZZ0001ZZ và
ZZ0002ZZ).

.. _damon_design_special_purpose_modules_exclusivity:

Lưu ý rằng các mô-đun này hiện đang chạy theo cách độc quyền.  Nếu một trong số đó
đang chạy, những người khác sẽ trả lại ZZ0000ZZ khi có yêu cầu bắt đầu.

Mô-đun DAMON mẫu
--------------------

Các mô-đun DAMON cung cấp ví dụ về cách sử dụng API kernel API.

lập trình viên hạt nhân có thể xây dựng các mô-đun DAMON cho mục đích chung hoặc đặc biệt của riêng họ
sử dụng hạt nhân DAMON API.  Để giúp họ dễ dàng hiểu DAMON kernel API như thế nào
có thể được sử dụng, một số mô-đun mẫu được cung cấp theo ZZ0000ZZ của
cây nguồn linux.  Xin lưu ý rằng các mô-đun này không được phát triển để
được sử dụng trên các sản phẩm thực, nhưng chỉ để hiển thị cách sử dụng kernel DAMON API trong
những cách đơn giản.