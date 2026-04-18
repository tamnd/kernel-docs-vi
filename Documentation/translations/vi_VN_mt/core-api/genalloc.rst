.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/core-api/genalloc.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

Hệ thống con genalloc/genpool
==============================

Có một số hệ thống con cấp phát bộ nhớ trong kernel, mỗi hệ thống con
nhằm vào một nhu cầu cụ thể.  Tuy nhiên, đôi khi nhà phát triển kernel cần phải
triển khai một bộ cấp phát mới cho một phạm vi bộ nhớ có mục đích đặc biệt cụ thể;
thường thì bộ nhớ đó nằm ở đâu đó trên một thiết bị.  Tác giả của
trình điều khiển cho thiết bị đó chắc chắn có thể viết một bộ cấp phát nhỏ để lấy
công việc đã hoàn thành, nhưng đó là cách lấp đầy kernel với hàng tá lỗi kém
bộ phân bổ đã được thử nghiệm.  Trở lại năm 2005, Jes Sorensen đã dỡ bỏ một trong số đó
bộ cấp phát từ trình điều khiển sym53c8xx_2 và đăng_ nó dưới dạng mô-đun chung
để tạo ra các bộ cấp phát bộ nhớ ad hoc.  Mã này đã được hợp nhất
cho bản phát hành 2.6.13; nó đã được sửa đổi đáng kể kể từ đó.

.. _posted: https://lwn.net/Articles/125842/

Mã sử ​​dụng bộ cấp phát này phải bao gồm <linux/genalloc.h>.  hành động
bắt đầu bằng việc tạo một nhóm bằng cách sử dụng một trong:

.. kernel-doc:: lib/genalloc.c
   :functions: gen_pool_create		

.. kernel-doc:: lib/genalloc.c
   :functions: devm_gen_pool_create

Cuộc gọi tới gen_pool_create() sẽ tạo một nhóm.  Độ chi tiết của
phân bổ được đặt bằng min_alloc_order; nó là số log-base-2 như
những thứ được sử dụng bởi bộ cấp phát trang, nhưng nó đề cập đến byte chứ không phải trang.
Vì vậy, nếu min_alloc_order được chuyển thành 3 thì tất cả phân bổ sẽ là
bội số của tám byte.  Tăng min_alloc_order làm giảm bộ nhớ
cần thiết để theo dõi bộ nhớ trong nhóm.  Tham số nid chỉ định
nút NUMA nào sẽ được sử dụng để phân bổ công việc dọn phòng
kết cấu; nó có thể là -1 nếu người gọi không quan tâm.

Giao diện "được quản lý" devm_gen_pool_create() liên kết nhóm với một
thiết bị cụ thể.  Trong số những thứ khác, nó sẽ tự động dọn dẹp
pool khi thiết bị nhất định bị phá hủy.

Một hồ bơi bị đóng cửa với:

.. kernel-doc:: lib/genalloc.c
   :functions: gen_pool_destroy

Cần lưu ý rằng, nếu vẫn còn các khoản phân bổ chưa được phân bổ từ
nhóm đã cho, hàm này sẽ thực hiện một bước khá khó khăn là gọi
BUG(), làm hỏng toàn bộ hệ thống.  Bạn đã được cảnh báo.

Một nhóm mới được tạo không có bộ nhớ để phân bổ.  Nó khá vô dụng trong
trạng thái đó, vì vậy một trong những yêu cầu đầu tiên của công việc thường là thêm bộ nhớ
đến hồ bơi.  Điều đó có thể được thực hiện với một trong:

.. kernel-doc:: include/linux/genalloc.h
   :functions: gen_pool_add

.. kernel-doc:: lib/genalloc.c
   :functions: gen_pool_add_owner

Lệnh gọi tới gen_pool_add() sẽ đặt kích thước byte của bộ nhớ
bắt đầu từ addr (trong không gian địa chỉ ảo của kernel) vào địa chỉ đã cho
pool, một lần nữa sử dụng nid làm ID nút để phân bổ bộ nhớ phụ trợ.
Biến thể gen_pool_add_virt() liên kết một cơ chế vật lý rõ ràng
địa chỉ bằng bộ nhớ; điều này chỉ cần thiết nếu hồ bơi sẽ được sử dụng
để phân bổ DMA.

Các chức năng phân bổ bộ nhớ từ nhóm (và đưa nó trở lại)
là:

.. kernel-doc:: include/linux/genalloc.h
   :functions: gen_pool_alloc

.. kernel-doc:: lib/genalloc.c
   :functions: gen_pool_dma_alloc

.. kernel-doc:: lib/genalloc.c
   :functions: gen_pool_free_owner

Như mọi người mong đợi, gen_pool_alloc() sẽ phân bổ size< byte
từ nhóm nhất định.  Biến thể gen_pool_dma_alloc() phân bổ
bộ nhớ để sử dụng với các hoạt động DMA, trả về vật lý liên quan
địa chỉ trong không gian được chỉ ra bởi dma.  Điều này sẽ chỉ hoạt động nếu bộ nhớ
đã được thêm bằng gen_pool_add_virt().  Lưu ý rằng chức năng này
khác với kiểu genpool thông thường là sử dụng các giá trị dài không dấu để
đại diện cho địa chỉ hạt nhân; thay vào đó nó trả về một khoảng trống *.

Tất cả điều đó có vẻ tương đối đơn giản; thực sự, một số nhà phát triển đã tìm thấy rõ ràng điều đó
trở nên quá đơn giản.  Rốt cuộc, giao diện trên không cung cấp quyền kiểm soát
cách các hàm phân bổ chọn phần bộ nhớ cụ thể để
trở lại.  Nếu cần loại điều khiển đó, các chức năng sau sẽ được
quan tâm:

.. kernel-doc:: lib/genalloc.c
   :functions: gen_pool_alloc_algo_owner

.. kernel-doc:: lib/genalloc.c
   :functions: gen_pool_set_algo

Phân bổ với gen_pool_alloc_algo() chỉ định một thuật toán
được sử dụng để chọn bộ nhớ được cấp phát; thuật toán mặc định có thể được thiết lập
với gen_pool_set_algo().  Giá trị dữ liệu được truyền tới
thuật toán; hầu hết đều bỏ qua nó, nhưng đôi khi nó cũng cần thiết.  Người ta có thể,
một cách tự nhiên, hãy viết một thuật toán có mục đích đặc biệt, nhưng có một tập hợp hợp lý
đã có sẵn:

- gen_pool_first_fit là một công cụ cấp phát phù hợp đầu tiên đơn giản; đây là mặc định
  thuật toán nếu không có thuật toán nào khác được chỉ định.

- gen_pool_first_fit_align buộc việc phân bổ phải có một mục tiêu cụ thể
  căn chỉnh (được truyền qua dữ liệu trong cấu trúc genpool_data_align).

- gen_pool_first_fit_order_align sắp xếp việc phân bổ theo thứ tự của
  kích thước.  Ví dụ: phân bổ 60 byte sẽ được căn chỉnh 64 byte.

- gen_pool_best_fit, như mọi người mong đợi, là một công cụ cấp phát đơn giản phù hợp nhất.

- gen_pool_fixed_alloc phân bổ ở một mức chênh lệch cụ thể (được chuyển vào một
  cấu trúc genpool_data_fixed thông qua tham số dữ liệu) trong nhóm.
  Nếu bộ nhớ được chỉ định không có sẵn thì việc phân bổ không thành công.

Có một số chức năng khác, chủ yếu dành cho các mục đích như truy vấn
không gian có sẵn trong nhóm hoặc lặp qua các khối bộ nhớ.
Tuy nhiên, hầu hết người dùng không cần nhiều hơn những gì đã được mô tả
ở trên.  Nếu may mắn, nhận thức rộng rãi hơn về mô-đun này sẽ giúp ngăn ngừa
viết các bộ cấp phát bộ nhớ có mục đích đặc biệt trong tương lai.

.. kernel-doc:: lib/genalloc.c
   :functions: gen_pool_virt_to_phys

.. kernel-doc:: lib/genalloc.c
   :functions: gen_pool_for_each_chunk

.. kernel-doc:: lib/genalloc.c
   :functions: gen_pool_has_addr

.. kernel-doc:: lib/genalloc.c
   :functions: gen_pool_avail

.. kernel-doc:: lib/genalloc.c
   :functions: gen_pool_size

.. kernel-doc:: lib/genalloc.c
   :functions: gen_pool_get

.. kernel-doc:: lib/genalloc.c
   :functions: of_gen_pool_get
