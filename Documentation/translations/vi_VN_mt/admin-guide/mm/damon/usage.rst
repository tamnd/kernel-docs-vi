.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/admin-guide/mm/damon/usage.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=====================
Cách sử dụng chi tiết
=====================

DAMON cung cấp các giao diện bên dưới cho những người dùng khác nhau.

-ZZ0007ZZ
  ZZ0000ZZ dành cho những người đang xây dựng,
  phân phối và/hoặc quản trị kernel với DAMON có mục đích đặc biệt
  công dụng.  Bằng cách này, người dùng có thể sử dụng các tính năng chính của DAMON cho
  mục đích xây dựng, khởi động hoặc thời gian chạy theo những cách đơn giản.
-ZZ0008ZZ
  ZZ0004ZZ dành cho những người có đặc quyền như
  quản trị viên hệ thống muốn có giao diện thân thiện với con người.
  Bằng cách này, người dùng có thể sử dụng các tính năng chính của DAMON theo cách thân thiện với con người.
  Tuy nhiên, nó có thể không được điều chỉnh cao cho các trường hợp đặc biệt.  Để biết thêm chi tiết,
  vui lòng tham khảo ZZ0005ZZ của nó.
-ZZ0009ZZ
  ZZ0001ZZ dành cho các lập trình viên không gian người dùng đặc quyền, những người
  muốn sử dụng DAMON tối ưu hơn.  Bằng cách này, người dùng có thể sử dụng chính của DAMON
  các tính năng bằng cách đọc và ghi vào các tệp sysfs đặc biệt.  Vì vậy,
  bạn có thể viết và sử dụng các chương trình bao bọc hệ thống DAMON được cá nhân hóa của mình để
  đọc/ghi các tệp sysfs thay vì bạn.  ZZ0006ZZ là một ví dụ về các chương trình như vậy.
-ZZ0010ZZ
  ZZ0002ZZ dành cho các lập trình viên không gian hạt nhân.  Sử dụng cái này,
  người dùng có thể sử dụng mọi tính năng của DAMON một cách linh hoạt và hiệu quả nhất bằng cách
  viết các chương trình ứng dụng không gian kernel DAMON cho bạn.  Bạn thậm chí có thể mở rộng
  DAMON cho nhiều không gian địa chỉ khác nhau.  Để biết chi tiết, vui lòng tham khảo giao diện
  ZZ0003ZZ.

.. _sysfs_interface:

Giao diện sysfs
===============

Giao diện sysfs DAMON được xây dựng khi ZZ0000ZZ được xác định.  Nó
tạo nhiều thư mục và tập tin trong thư mục sysfs của nó,
ZZ0001ZZ.  Bạn có thể điều khiển DAMON bằng cách ghi và đọc
từ các tập tin trong thư mục.

Trong một ví dụ ngắn, người dùng có thể giám sát không gian địa chỉ ảo của một địa chỉ nhất định
khối lượng công việc như dưới đây. ::

# cd /sys/kernel/mm/damon/admin/
    # echo 1 > kdamonds/nr_kdamonds && echo 1 > kdamonds/0/contexts/nr_contexts
    # echo vaddr > kdamonds/0/contexts/0/hoạt động
    # echo 1 > kdamonds/0/contexts/0/targets/nr_targets
    # echo $(pidof <workload>) > kdamonds/0/contexts/0/targets/0/pid_target
    # echo bật > kdamonds/0/state

Phân cấp tệp
---------------

Hệ thống phân cấp tệp của giao diện sysfs DAMON được hiển thị bên dưới.  Ở bên dưới
hình, mối quan hệ cha mẹ và con cái được thể hiện bằng các vết lõm, mỗi
thư mục có hậu tố ZZ0000ZZ và các tệp trong mỗi thư mục được phân tách bằng
dấu phẩy (",").

.. parsed-literal::

    :ref:`/sys/kernel/mm/damon <sysfs_root>`/admin
    │ :ref:`kdamonds <sysfs_kdamonds>`/nr_kdamonds
    │ │ :ref:`0 <sysfs_kdamond>`/state,pid,refresh_ms
    │ │ │ :ref:`contexts <sysfs_contexts>`/nr_contexts
    │ │ │ │ :ref:`0 <sysfs_context>`/avail_operations,operations,addr_unit
    │ │ │ │ │ :ref:`monitoring_attrs <sysfs_monitoring_attrs>`/
    │ │ │ │ │ │ intervals/sample_us,aggr_us,update_us
    │ │ │ │ │ │ │ intervals_goal/access_bp,aggrs,min_sample_us,max_sample_us
    │ │ │ │ │ │ nr_regions/min,max
    │ │ │ │ │ :ref:`targets <sysfs_targets>`/nr_targets
    │ │ │ │ │ │ :ref:`0 <sysfs_target>`/pid_target,obsolete_target
    │ │ │ │ │ │ │ :ref:`regions <sysfs_regions>`/nr_regions
    │ │ │ │ │ │ │ │ :ref:`0 <sysfs_region>`/start,end
    │ │ │ │ │ │ │ │ ...
    │ │ │ │ │ │ ...
    │ │ │ │ │ :ref:`schemes <sysfs_schemes>`/nr_schemes
    │ │ │ │ │ │ :ref:`0 <sysfs_scheme>`/action,target_nid,apply_interval_us
    │ │ │ │ │ │ │ :ref:`access_pattern <sysfs_access_pattern>`/
    │ │ │ │ │ │ │ │ sz/min,max
    │ │ │ │ │ │ │ │ nr_accesses/min,max
    │ │ │ │ │ │ │ │ age/min,max
    │ │ │ │ │ │ │ :ref:`quotas <sysfs_quotas>`/ms,bytes,reset_interval_ms,effective_bytes,goal_tuner
    │ │ │ │ │ │ │ │ weights/sz_permil,nr_accesses_permil,age_permil
    │ │ │ │ │ │ │ │ :ref:`goals <sysfs_schemes_quota_goals>`/nr_goals
    │ │ │ │ │ │ │ │ │ 0/target_metric,target_value,current_value,nid,path
    │ │ │ │ │ │ │ :ref:`watermarks <sysfs_watermarks>`/metric,interval_us,high,mid,low
    │ │ │ │ │ │ │ :ref:`{core_,ops_,}filters <sysfs_filters>`/nr_filters
    │ │ │ │ │ │ │ │ 0/type,matching,allow,memcg_path,addr_start,addr_end,target_idx,min,max
    │ │ │ │ │ │ │ :ref:`dests <damon_sysfs_dests>`/nr_dests
    │ │ │ │ │ │ │ │ 0/id,weight
    │ │ │ │ │ │ │ :ref:`stats <sysfs_schemes_stats>`/nr_tried,sz_tried,nr_applied,sz_applied,sz_ops_filter_passed,qt_exceeds,nr_snapshots,max_nr_snapshots
    │ │ │ │ │ │ │ :ref:`tried_regions <sysfs_schemes_tried_regions>`/total_bytes
    │ │ │ │ │ │ │ │ 0/start,end,nr_accesses,age,sz_filter_passed
    │ │ │ │ │ │ │ │ ...
    │ │ │ │ │ │ ...
    │ │ │ │ ...
    │ │ ...

.. _sysfs_root:

Gốc
----

Gốc của giao diện sysfs DAMON là ZZ0000ZZ, và nó
có một thư mục có tên ZZ0001ZZ.  Thư mục chứa các tập tin cho
quyền kiểm soát của các chương trình không gian người dùng đặc quyền đối với DAMON.  Công cụ không gian người dùng hoặc daemon
có quyền root có thể sử dụng thư mục này.

.. _sysfs_kdamonds:

kdamonds/
---------

Trong thư mục ZZ0001ZZ, một thư mục, ZZ0002ZZ, chứa các tập tin cho
kiểm soát kdamonds (tham khảo
ZZ0000ZZ để biết thêm
chi tiết) tồn tại.  Lúc đầu thư mục này chỉ có một file
ZZ0003ZZ.  Viết một số (ZZ0004ZZ) vào tệp sẽ tạo ra số lượng
thư mục con có tên ZZ0005ZZ đến ZZ0006ZZ.  Mỗi thư mục đại diện cho mỗi
kdamond.

.. _sysfs_kdamond:

kdamonds/<N>/
-------------

Trong mỗi thư mục kdamond, ba tệp (ZZ0000ZZ, ZZ0001ZZ và ZZ0002ZZ)
và một thư mục (ZZ0003ZZ) tồn tại.

Đọc ZZ0000ZZ trả về ZZ0001ZZ nếu kdamond hiện đang chạy hoặc
ZZ0002ZZ nếu nó không chạy.

Người dùng có thể viết các lệnh dưới đây cho kdamond vào tệp ZZ0000ZZ.

- ZZ0006ZZ: Bắt đầu chạy.
- ZZ0007ZZ: Dừng chạy.
- ZZ0008ZZ: Đọc đầu vào của người dùng trong tệp sysfs ngoại trừ tệp ZZ0009ZZ
  một lần nữa.  Việc giám sát đầu vào ZZ0000ZZ cũng được thực hiện
  bị bỏ qua nếu không có vùng mục tiêu được chỉ định.
- ZZ0010ZZ: Cập nhật nội dung của ZZ0011ZZ và
  Các tệp ZZ0012ZZ của kdamond có tính năng tự động điều chỉnh được áp dụng ZZ0013ZZ và ZZ0014ZZ cho các tệp.  Vui lòng tham khảo
  ZZ0001ZZ
  để biết thêm chi tiết.
- ZZ0015ZZ: Đọc sơ đồ hoạt động dựa trên DAMON'
  ZZ0002ZZ.
- ZZ0016ZZ: Cập nhật nội dung file thống kê cho từng file
  Sơ đồ hoạt động dựa trên DAMON của kdamond.  Để biết chi tiết về số liệu thống kê,
  vui lòng tham khảo ZZ0003ZZ.
- ZZ0017ZZ: Cập nhật sơ đồ hoạt động dựa trên DAMON
  thư mục vùng đã thử hành động cho từng sơ đồ hoạt động dựa trên DAMON của
  kdamond.  Để biết chi tiết về hành động sơ đồ hoạt động dựa trên DAMON đã thử
  thư mục khu vực, vui lòng tham khảo
  ZZ0004ZZ.
- ZZ0018ZZ: Chỉ cập nhật ZZ0019ZZ
  tập tin.
- ZZ0020ZZ: Xóa sơ đồ vận hành dựa trên DAMON
  thư mục vùng đã thử hành động cho từng sơ đồ hoạt động dựa trên DAMON của
  kdamond.
- ZZ0021ZZ: Cập nhật nội dung của
  Các tệp ZZ0022ZZ cho từng sơ đồ hoạt động dựa trên DAMON của
  kdamond.  Để biết thêm chi tiết, hãy tham khảo ZZ0005ZZ.

Nếu trạng thái là ZZ0000ZZ, việc đọc ZZ0001ZZ sẽ hiển thị pid của chuỗi kdamond.

Người dùng có thể yêu cầu kernel cập nhật định kỳ các tệp hiển thị tính năng tự động điều chỉnh
các thông số và số liệu thống kê DAMOS thay vì viết thủ công
ZZ0000ZZ thích từ khóa vào tệp ZZ0001ZZ.  Đối với điều này, người dùng
nên ghi khoảng thời gian cập nhật mong muốn tính bằng mili giây vào ZZ0002ZZ
tập tin.  Nếu khoảng thời gian bằng 0, cập nhật định kỳ sẽ bị tắt.  Đọc
tập tin hiển thị khoảng thời gian hiện được thiết lập.

Thư mục ZZ0000ZZ chứa các tệp để kiểm soát bối cảnh giám sát
mà kdamond này sẽ thực thi.

.. _sysfs_contexts:

kdamonds/<N>/contexts/
----------------------

Ban đầu, thư mục này chỉ có một tệp là ZZ0001ZZ.  Viết một
(ZZ0002ZZ) vào tệp sẽ tạo số lượng thư mục con có tên là
ZZ0003ZZ đến ZZ0004ZZ.  Mỗi thư mục đại diện cho từng bối cảnh giám sát (tham khảo
ZZ0000ZZ để biết thêm
chi tiết).  Hiện tại, chỉ có một ngữ cảnh cho mỗi kdamond được hỗ trợ, vì vậy chỉ
ZZ0005ZZ hoặc ZZ0006ZZ có thể được ghi vào tệp.

.. _sysfs_context:

bối cảnh/<N>/
-------------

Trong mỗi thư mục ngữ cảnh, ba tệp (ZZ0000ZZ, ZZ0001ZZ
và ZZ0002ZZ) và ba thư mục (ZZ0003ZZ, ZZ0004ZZ,
và ZZ0005ZZ) tồn tại.

DAMON hỗ trợ nhiều loại ZZ0000ZZ, bao gồm cả các loại địa chỉ ảo
không gian và không gian địa chỉ vật lý.  Bạn có thể lấy danh sách có sẵn
giám sát các hoạt động được thiết lập trên kernel hiện đang chạy bằng cách đọc
Tệp ZZ0002ZZ.  Dựa trên cấu hình kernel, tập tin sẽ
liệt kê các bộ hoạt động có sẵn khác nhau.  Vui lòng tham khảo ZZ0001ZZ để biết danh sách tất cả các bộ thao tác có sẵn và
giải thích ngắn gọn.

Bạn có thể thiết lập và nhận loại hoạt động giám sát mà DAMON sẽ sử dụng cho
ngữ cảnh bằng cách viết một trong các từ khóa được liệt kê trong tệp ZZ0000ZZ và
đọc từ tệp ZZ0001ZZ.

Tệp ZZ0001ZZ dùng để cài đặt và lấy tham số ZZ0000ZZ của bộ thao tác.

.. _sysfs_monitoring_attrs:

bối cảnh/<N>/monitoring_attrs/
------------------------------

Các tệp để chỉ định các thuộc tính của giám sát bao gồm chất lượng được yêu cầu
và hiệu quả của việc giám sát đều có trong thư mục ZZ0000ZZ.
Cụ thể, có hai thư mục ZZ0001ZZ và ZZ0002ZZ tồn tại trong này
thư mục.

Trong thư mục ZZ0000ZZ, ba tệp cho khoảng thời gian lấy mẫu của DAMON
(ZZ0001ZZ), khoảng thời gian tổng hợp (ZZ0002ZZ) và khoảng thời gian cập nhật
(ZZ0003ZZ) tồn tại.  Bạn có thể đặt và nhận các giá trị tính bằng micro giây bằng cách
ghi và đọc từ các tập tin.

Trong thư mục ZZ0000ZZ, hai tệp dành cho giới hạn dưới và giới hạn trên
trong số các vùng giám sát của DAMON (lần lượt là ZZ0001ZZ và ZZ0002ZZ), trong đó
kiểm soát chi phí giám sát, tồn tại.  Bạn có thể đặt và nhận các giá trị bằng cách
ghi vào và rading từ các tập tin.

Để biết thêm chi tiết về khoảng thời gian và phạm vi vùng giám sát, vui lòng tham khảo
vào tài liệu Thiết kế (ZZ0000ZZ).

.. _damon_usage_sysfs_monitoring_intervals_goal:

bối cảnh/<N>/monitoring_attrs/intervals/intervals_goal/
-------------------------------------------------------

Trong thư mục ZZ0001ZZ, một thư mục để điều chỉnh tự động
ZZ0002ZZ và ZZ0003ZZ, cụ thể là thư mục ZZ0004ZZ cũng tồn tại.
Trong thư mục có bốn tệp để điều khiển tự động điều chỉnh, cụ thể là
ZZ0005ZZ, ZZ0006ZZ, ZZ0007ZZ và ZZ0008ZZ tồn tại.
Vui lòng tham khảo ZZ0000ZZ để biết nội dung điều chỉnh bên trong
cơ chế.  Đọc và ghi bốn tệp trong ZZ0009ZZ
thư mục hiển thị và cập nhật các tham số điều chỉnh được mô tả trong
:ref:tài liệu thiết kế <damon_design_monitoring_intervals_autotuning>` tương tự
những cái tên.  Việc điều chỉnh bắt đầu với ZZ0010ZZ và ZZ0011ZZ do người dùng đặt.  các
giá trị hiện tại được điều chỉnh của hai khoảng có thể được đọc từ
Các tệp ZZ0012ZZ và ZZ0013ZZ sau khi ghi ZZ0014ZZ vào
tệp ZZ0015ZZ.

.. _sysfs_targets:

bối cảnh/<N>/mục tiêu/
---------------------

Ban đầu, thư mục này chỉ có một tệp là ZZ0000ZZ.  Viết một
số (ZZ0001ZZ) vào file sẽ tạo số lượng thư mục con có tên ZZ0002ZZ
tới ZZ0003ZZ.  Mỗi thư mục đại diện cho từng mục tiêu giám sát.

.. _sysfs_target:

mục tiêu/<N>/
------------

Trong mỗi thư mục đích, hai tệp (ZZ0000ZZ và ZZ0001ZZ)
và một thư mục (ZZ0002ZZ) tồn tại.

Nếu bạn đã ghi ZZ0000ZZ vào ZZ0001ZZ, mỗi mục tiêu sẽ
là một quá trình.  Bạn có thể chỉ định quy trình cho DAMON bằng cách viết pid của
xử lý vào tệp ZZ0002ZZ.

Người dùng có thể loại bỏ có chọn lọc các mục tiêu ở giữa mảng mục tiêu bằng cách
ghi giá trị khác 0 vào tệp ZZ0000ZZ và cam kết nó (ghi
Tệp ZZ0001ZZ sang ZZ0002ZZ).  DAMON sẽ loại bỏ các mục tiêu phù hợp khỏi
mảng mục tiêu nội bộ.  Người dùng có trách nhiệm xây dựng các thư mục đích
một lần nữa, để chúng thể hiện chính xác mảng mục tiêu nội bộ đã thay đổi.


.. _sysfs_regions:

mục tiêu/<N>/khu vực
-------------------

Trong trường hợp bộ hoạt động giám sát ZZ0001ZZ hoặc ZZ0002ZZ, người dùng được
cần thiết để thiết lập phạm vi địa chỉ mục tiêu giám sát.  Trong trường hợp ZZ0003ZZ
hoạt động được thiết lập, nó không bắt buộc, nhưng người dùng có thể tùy ý thiết lập ban đầu
vùng giám sát đến các phạm vi địa chỉ cụ thể.  Vui lòng tham khảo ZZ0000ZZ để biết thêm chi tiết.

Đối với những trường hợp như vậy, người dùng có thể đặt rõ ràng các vùng mục tiêu giám sát ban đầu
theo ý muốn của họ bằng cách ghi các giá trị thích hợp vào các tệp trong thư mục này.

Ban đầu, thư mục này chỉ có một tệp là ZZ0000ZZ.  Viết một
số (ZZ0001ZZ) vào file sẽ tạo số lượng thư mục con có tên ZZ0002ZZ
tới ZZ0003ZZ.  Mỗi thư mục đại diện cho từng vùng mục tiêu giám sát ban đầu.

Nếu ZZ0001ZZ bằng 0 khi thực hiện các tham số DAMON mới trực tuyến (ghi
Tệp ZZ0002ZZ sang tệp ZZ0003ZZ của ZZ0000ZZ), cam kết
logic bỏ qua các vùng mục tiêu.  Nói cách khác, việc giám sát hiện tại
kết quả cho mục tiêu được bảo tồn.

.. _sysfs_region:

vùng/<N>/
------------

Trong mỗi thư mục vùng, bạn sẽ tìm thấy hai tệp (ZZ0000ZZ và ZZ0001ZZ).  bạn
có thể thiết lập và lấy địa chỉ bắt đầu và kết thúc của mục tiêu giám sát ban đầu
vùng bằng cách ghi vào và đọc từ các tập tin tương ứng.

Mỗi khu vực không nên chồng chéo với những khu vực khác.  ZZ0000ZZ của thư mục ZZ0001ZZ nên
bằng hoặc nhỏ hơn ZZ0002ZZ của thư mục ZZ0003ZZ.

.. _sysfs_schemes:

bối cảnh/<N>/sơ đồ/
---------------------

Thư mục dành cho các Sơ đồ hoạt động dựa trên DAMON (ZZ0000ZZ).  Người dùng có thể lấy và thiết lập các sơ đồ bằng cách đọc từ và
ghi vào các tập tin trong thư mục này.

Ban đầu, thư mục này chỉ có một tệp là ZZ0000ZZ.  Viết một
số (ZZ0001ZZ) vào file sẽ tạo số lượng thư mục con có tên ZZ0002ZZ
tới ZZ0003ZZ.  Mỗi thư mục đại diện cho mỗi sơ đồ hoạt động dựa trên DAMON.

.. _sysfs_scheme:

kế hoạch/<N>/
------------

Trong mỗi thư mục lược đồ, tám thư mục (ZZ0000ZZ, ZZ0001ZZ,
ZZ0002ZZ, ZZ0003ZZ, ZZ0004ZZ, ZZ0005ZZ, ZZ0006ZZ,
ZZ0007ZZ và ZZ0008ZZ) và ba tệp (ZZ0009ZZ, ZZ0010ZZ
và ZZ0011ZZ) tồn tại.

Tệp ZZ0002ZZ dùng để cài đặt và lấy ZZ0000ZZ của lược đồ.  Các từ khóa có thể được viết và đọc
từ tệp và ý nghĩa của chúng giống với ý nghĩa của danh sách trên
ZZ0001ZZ.

Tệp ZZ0000ZZ dùng để thiết lập nút mục tiêu di chuyển, đó là
chỉ có ý nghĩa khi ZZ0001ZZ là ZZ0002ZZ hoặc
ZZ0003ZZ.

Tệp ZZ0001ZZ dùng để cài đặt và lấy sơ đồ
ZZ0000ZZ tính bằng micro giây.

.. _sysfs_access_pattern:

lược đồ/<N>/access_pattern/
---------------------------

Thư mục dành cho mục tiêu truy cập ZZ0000ZZ của sơ đồ hoạt động dựa trên DAMON đã cho.

Trong thư mục ZZ0000ZZ, ba thư mục (ZZ0001ZZ,
ZZ0002ZZ và ZZ0003ZZ) mỗi tệp có hai tệp (ZZ0004ZZ và ZZ0005ZZ)
tồn tại.  Bạn có thể đặt và lấy mẫu truy cập cho sơ đồ đã cho bằng cách viết
đến và đọc từ các tệp ZZ0006ZZ và ZZ0007ZZ trong ZZ0008ZZ,
Các thư mục ZZ0009ZZ và ZZ0010ZZ tương ứng.  Lưu ý rằng ZZ0011ZZ
và ZZ0012ZZ tạo thành một khoảng khép kín.

.. _sysfs_quotas:

kế hoạch/<N>/hạn ngạch/
-------------------

Thư mục dành cho ZZ0000ZZ đã cho
Sơ đồ hoạt động dựa trên DAMON.

Trong thư mục ZZ0000ZZ, năm tệp (ZZ0001ZZ, ZZ0002ZZ,
ZZ0003ZZ, ZZ0004ZZ và ZZ0005ZZ) và hai
các thư mục (ZZ0006ZZ và ZZ0007ZZ) tồn tại.

Bạn có thể đặt ZZ0001ZZ tính bằng mili giây, ZZ0002ZZ tính bằng byte và
ZZ0003ZZ tính bằng mili giây bằng cách ghi các giá trị vào ba tệp,
tương ứng.  Sau đó, DAMON cố gắng chỉ sử dụng tối đa ZZ0004ZZ mili giây
để áp dụng ZZ0005ZZ cho các vùng bộ nhớ của ZZ0006ZZ và để
chỉ áp dụng hành động cho tối đa ZZ0007ZZ byte của vùng bộ nhớ trong
ZZ0008ZZ.  Việc đặt cả ZZ0009ZZ và ZZ0010ZZ zero sẽ vô hiệu hóa
giới hạn hạn ngạch trừ khi có ít nhất một ZZ0000ZZ
thiết lập.

Bạn có thể đặt thuật toán tự động điều chỉnh hạn ngạch hiệu quả dựa trên mục tiêu để sử dụng bằng cách
ghi tên thuật toán vào tệp ZZ0002ZZ.  Đọc tập tin trả về
thuật toán điều chỉnh hiện đang được chọn.  Tham khảo tài liệu thiết kế của
ZZ0000ZZ cho
thiết kế nền của tính năng và tên của các thuật toán có thể lựa chọn.
Tham khảo ZZ0001ZZ để biết các mục tiêu
thiết lập.

Hạn ngạch thời gian được chuyển đổi nội bộ thành hạn ngạch kích thước.  Giữa
Hạn ngạch kích thước đã chuyển đổi và hạn ngạch kích thước do người dùng chỉ định, hạn ngạch nhỏ hơn sẽ được áp dụng.
Dựa trên ZZ0000ZZ do người dùng chỉ định,
hạn ngạch kích thước hiệu quả được điều chỉnh thêm.  Đọc ZZ0001ZZ trả về
hạn ngạch kích thước hiệu quả hiện tại.  Tệp không được cập nhật theo thời gian thực, vì vậy
người dùng nên yêu cầu giao diện sysfs của DAMON cập nhật nội dung của tệp cho
số liệu thống kê bằng cách viết một từ khóa đặc biệt, ZZ0002ZZ vào
tệp ZZ0003ZZ có liên quan.

Trong thư mục ZZ0001ZZ, ba tệp (ZZ0002ZZ,
ZZ0003ZZ và ZZ0004ZZ) tồn tại.
Bạn có thể đặt ZZ0000ZZ về kích thước, tần suất truy cập và tuổi
tính bằng phần nghìn đơn vị bằng cách ghi các giá trị vào ba tệp bên dưới
Thư mục ZZ0005ZZ.

.. _sysfs_schemes_quota_goals:

kế hoạch/<N>/hạn ngạch/mục tiêu/
-------------------------

Thư mục dành cho ZZ0000ZZ của hoạt động dựa trên DAMON đã cho
kế hoạch.

Ban đầu, thư mục này chỉ có một tệp là ZZ0000ZZ.  Viết một
số (ZZ0001ZZ) vào file sẽ tạo số lượng thư mục con có tên ZZ0002ZZ
tới ZZ0003ZZ.  Mỗi thư mục đại diện cho từng mục tiêu và thành tích hiện tại.
Trong số nhiều phản hồi, phản hồi tốt nhất sẽ được sử dụng.

Mỗi thư mục mục tiêu chứa năm tệp, cụ thể là ZZ0002ZZ,
ZZ0003ZZ, ZZ0004ZZ ZZ0005ZZ và ZZ0006ZZ.  Người dùng có thể thiết lập và
lấy năm tham số cho các mục tiêu tự động điều chỉnh hạn ngạch được chỉ định trên
ZZ0000ZZ bằng cách viết thư tới và
đọc từ mỗi tập tin.  Lưu ý người dùng nên viết thêm
ZZ0007ZZ vào tệp ZZ0008ZZ của ZZ0001ZZ để chuyển phản hồi tới DAMON.

.. _sysfs_watermarks:

lược đồ/<N>/hình mờ/
-----------------------

Thư mục dành cho ZZ0000ZZ của
đưa ra sơ đồ hoạt động dựa trên DAMON.

Trong thư mục hình mờ, năm tệp (ZZ0000ZZ, ZZ0001ZZ,
ZZ0002ZZ, ZZ0003ZZ và ZZ0004ZZ) để cài đặt số liệu, khoảng thời gian
giữa việc kiểm tra số liệu và ba hình mờ tồn tại.  Bạn có thể thiết lập và
lấy năm giá trị bằng cách ghi vào các tập tin tương ứng.

Từ khóa và ý nghĩa của những từ khóa có thể được ghi vào tệp ZZ0000ZZ là
như dưới đây.

- none: Bỏ qua các hình mờ
 - free_mem_rate: Tỷ lệ bộ nhớ trống của hệ thống (phần nghìn)

ZZ0000ZZ phải được viết bằng đơn vị micro giây.

.. _sysfs_filters:

sơ đồ/<N>/{core\_,ops\_,}filters/
-----------------------------------

Thư mục cho ZZ0000ZZ đã cho
Sơ đồ hoạt động dựa trên DAMON.

Các thư mục ZZ0000ZZ và ZZ0001ZZ dành cho các bộ lọc được xử lý bởi
lớp lõi DAMON và lớp thiết lập hoạt động tương ứng.  ZZ0002ZZ
thư mục có thể được sử dụng để cài đặt các bộ lọc bất kể chúng được xử lý như thế nào
các lớp.  Các bộ lọc được ZZ0003ZZ và ZZ0004ZZ yêu cầu sẽ được
được cài đặt trước ZZ0005ZZ.  Cả ba thư mục đều có cùng một tập tin.

Việc sử dụng thư mục ZZ0000ZZ có thể đưa ra các yêu cầu đánh giá mong đợi
bộ lọc với các tập tin trong thư mục hơi khó hiểu.  Do đó người dùng
khuyến nghị sử dụng các thư mục ZZ0001ZZ và ZZ0002ZZ.  các
Thư mục ZZ0003ZZ có thể không được dùng nữa trong tương lai.

Lúc đầu, thư mục chỉ có một tệp là ZZ0000ZZ.  Viết một
số (ZZ0001ZZ) vào file sẽ tạo số lượng thư mục con có tên ZZ0002ZZ
tới ZZ0003ZZ.  Mỗi thư mục đại diện cho mỗi bộ lọc.  Bộ lọc được đánh giá
theo thứ tự số.

Mỗi thư mục bộ lọc chứa chín tệp, cụ thể là ZZ0001ZZ, ZZ0002ZZ,
ZZ0003ZZ, ZZ0004ZZ, ZZ0005ZZ, ZZ0006ZZ, ZZ0007ZZ, ZZ0008ZZ
và ZZ0009ZZ.  Vào tệp ZZ0010ZZ, bạn có thể ghi loại bộ lọc.
Tham khảo ZZ0000ZZ để biết loại có sẵn
tên, ý nghĩa của chúng và chúng được xử lý ở lớp nào.

Đối với loại ZZ0000ZZ, bạn có thể chỉ định nhóm bộ nhớ quan tâm bằng cách
ghi đường dẫn của nhóm bộ nhớ từ điểm gắn kết cgroups tới
Tệp ZZ0001ZZ.  Đối với loại ZZ0002ZZ, bạn có thể chỉ định điểm bắt đầu và kết thúc
địa chỉ của phạm vi (khoảng kết thúc mở) tới ZZ0003ZZ và ZZ0004ZZ
các tập tin tương ứng.  Đối với loại ZZ0005ZZ, bạn có thể chỉ định mức tối thiểu
và kích thước tối đa của phạm vi (khoảng đóng) thành các tệp ZZ0006ZZ và ZZ0007ZZ,
tương ứng.  Đối với loại ZZ0008ZZ, bạn có thể chỉ định chỉ mục của mục tiêu
giữa danh sách mục tiêu giám sát của bối cảnh DAMON với
Tệp ZZ0009ZZ.

Bạn có thể ghi ZZ0000ZZ hoặc ZZ0001ZZ vào tệp ZZ0002ZZ để chỉ định xem bộ lọc có
dành cho bộ nhớ phù hợp với ZZ0003ZZ.  Bạn có thể viết ZZ0004ZZ hoặc ZZ0005ZZ vào
Tệp ZZ0006ZZ để chỉ định xem có áp dụng hành động vào bộ nhớ thỏa mãn hay không
ZZ0007ZZ và ZZ0008ZZ có được phép hay không.

Ví dụ: bên dưới hạn chế hành động DAMOS chỉ được áp dụng cho những người không ẩn danh
trang của tất cả các nhóm bộ nhớ ngoại trừ ZZ0000ZZ.::

# cd ops_filters/0/
    # echo 2 > nr_filters
    ## disallow trang ẩn danh
    echo anon > 0/loại
    echo Y > 0/khớp
    echo N > 0/cho phép
    # # further lọc ra tất cả các nhóm ngoại trừ một nhóm tại '/having_care_already'
    echo memcg > 1/loại
    echo /having_care_already > 1/memcg_path
    echo Y > 1/khớp
    echo N > 1/cho phép

Tham khảo ZZ0000ZZ để biết thêm chi tiết bao gồm cách sử dụng nhiều bộ lọc
của các ZZ0001ZZ khác nhau hoạt động khi mỗi bộ lọc được hỗ trợ và
sự khác biệt về số liệu thống kê.

.. _damon_sysfs_dests:

lược đồ/<N>/đích/
------------------

Thư mục để chỉ định đích của hoạt động dựa trên DAMON nhất định
hành động của sơ đồ.  Thư mục này bị bỏ qua nếu hành động của sơ đồ đã cho
không hỗ trợ nhiều điểm đến.  Chỉ ZZ0000ZZ
hành động đang hỗ trợ nhiều điểm đến.

Lúc đầu, thư mục chỉ có một tệp là ZZ0000ZZ.  Viết một
số (ZZ0001ZZ) vào file sẽ tạo số lượng thư mục con có tên ZZ0002ZZ
tới ZZ0003ZZ.  Mỗi thư mục đại diện cho mỗi đích hành động.

Mỗi thư mục đích chứa hai tệp, đó là ZZ0000ZZ và ZZ0001ZZ.
Người dùng có thể ghi và đọc mã định danh của đích vào tệp ZZ0002ZZ.
Đối với các hành động ZZ0003ZZ, nút của nút đích di chuyển
id phải được ghi vào tệp ZZ0004ZZ.  Người dùng có thể viết và đọc trọng lượng của
đích trong số các đích đã cho cho tệp ZZ0005ZZ.  các
trọng số có thể là một số nguyên tùy ý.  Khi DAMOS áp dụng hành động cho từng thực thể
của vùng bộ nhớ, nó sẽ chọn đích đến của hành động dựa trên
trọng số tương đối của các điểm đến.

.. _sysfs_schemes_stats:

lược đồ/<N>/stats/
------------------

DAMON đếm số liệu thống kê cho từng sơ đồ.  Số liệu thống kê này có thể được sử dụng để
phân tích trực tuyến hoặc điều chỉnh các chương trình.  Tham khảo ZZ0000ZZ để biết thêm chi tiết về số liệu thống kê.

Số liệu thống kê có thể được truy xuất bằng cách đọc các tệp trong thư mục ZZ0000ZZ
(ZZ0001ZZ, ZZ0002ZZ, ZZ0003ZZ, ZZ0004ZZ,
ZZ0005ZZ, ZZ0006ZZ, ZZ0007ZZ và
ZZ0008ZZ), tương ứng.

Theo mặc định, các tập tin không được cập nhật theo thời gian thực.  Người dùng nên hỏi DAMON
sysfs để cập nhật định kỳ những người sử dụng ZZ0001ZZ hoặc thực hiện một giao diện
cập nhật thời gian bằng cách viết một từ khóa đặc biệt, ZZ0002ZZ vào
tập tin ZZ0003ZZ có liên quan.  Tham khảo ZZ0000ZZ để biết thêm chi tiết.

.. _sysfs_schemes_tried_regions:

lược đồ/<N>/thử_khu vực/
--------------------------

Thư mục này ban đầu có một tệp, ZZ0000ZZ.

Khi một từ khóa đặc biệt, ZZ0001ZZ, được ghi vào
tệp ZZ0002ZZ có liên quan, DAMON cập nhật tệp ZZ0003ZZ để
việc đọc nó sẽ trả về tổng kích thước của các vùng đã thử trong lược đồ và tạo ra
thư mục có tên số nguyên bắt đầu từ ZZ0004ZZ trong thư mục này.  Mỗi
thư mục chứa các tập tin hiển thị thông tin chi tiết về từng bộ nhớ
vùng mà ZZ0005ZZ của sơ đồ tương ứng đã cố gắng áp dụng theo
thư mục này, trong ZZ0000ZZ tiếp theo của
sơ đồ tương ứng.  Thông tin bao gồm phạm vi địa chỉ, ZZ0006ZZ,
và ZZ0007ZZ của khu vực.

Viết ZZ0000ZZ vào ZZ0001ZZ có liên quan
sẽ chỉ cập nhật tệp ZZ0002ZZ và sẽ không tạo
các thư mục con.

Các thư mục sẽ bị xóa khi có một từ khóa đặc biệt khác,
ZZ0000ZZ, được viết cho người có liên quan
Tệp ZZ0001ZZ.

Mục đích sử dụng dự kiến của thư mục này là điều tra hành vi của các chương trình,
và truy xuất kết quả giám sát truy cập dữ liệu hiệu quả giống như truy vấn.  Đối với
cụ thể là trong trường hợp sử dụng sau này, người dùng có thể đặt ZZ0000ZZ là ZZ0001ZZ và
đặt ZZ0002ZZ làm mẫu quan tâm mà họ muốn truy vấn.

.. _sysfs_schemes_tried_region:

đã thử_khu vực/<N>/
------------------

Trong mỗi thư mục vùng, bạn sẽ tìm thấy năm tệp (ZZ0000ZZ, ZZ0001ZZ,
ZZ0002ZZ, ZZ0003ZZ và ZZ0004ZZ).  Việc đọc các tập tin sẽ
hiển thị các thuộc tính của vùng tương ứng với hoạt động dựa trên DAMON
Đề án ZZ0005ZZ đã thử được áp dụng.

Ví dụ
~~~~~~~

Các lệnh bên dưới áp dụng sơ đồ có nội dung "Nếu vùng bộ nhớ có kích thước trong [4KiB,
8KiB] đang hiển thị số lượt truy cập trên mỗi khoảng tổng hợp trong [0, 5] để tổng hợp
khoảng trong [10, 20], phân trang ra vùng.  Để phân trang ra, chỉ sử dụng tối đa
10 mili giây mỗi giây và cũng không xuất ra nhiều hơn 1GiB mỗi giây.  Dưới
hạn chế, loại bỏ các vùng nhớ có tuổi dài hơn trước.  Ngoài ra, hãy kiểm tra
tốc độ bộ nhớ trống của hệ thống cứ sau 5 giây, bắt đầu giám sát và phân trang
out khi tốc độ bộ nhớ trống thấp hơn 50%, nhưng hãy dừng nó nếu dung lượng trống
tốc độ bộ nhớ trở nên lớn hơn 60% hoặc thấp hơn 30%. ::

# cd <sysfs>/kernel/mm/damon/admin
    # thư mục # populate
    # echo 1 > kdamonds/nr_kdamonds; echo 1 > kdamonds/0/contexts/nr_contexts;
    # echo 1 > kdamonds/0/contexts/0/schemes/nr_schemes
    # cd kdamonds/0/bối cảnh/0/sơ đồ/0
    # # set mẫu truy cập cơ bản và hành động
    # echo 4096 > access_pattern/sz/min
    # echo 8192 > access_pattern/sz/max
    # echo 0 > access_pattern/nr_accesses/phút
    # echo 5 > access_pattern/nr_accesses/max
    # echo 10 > access_pattern/tuổi/phút
    # echo 20 > access_pattern/age/max
    Trang # echo > hành động
    ## set hạn ngạch
    # echo 10 > hạn ngạch/ms
    # echo $((1024*1024*1024)) > hạn ngạch/byte
    # echo 1000 > hạn ngạch/reset_interval_ms
    Hình mờ ## set
    # echo free_mem_rate > hình mờ/số liệu
    # echo 5000000 > hình mờ/khoảng_us
    # echo 600 > hình mờ/cao
    # echo 500 > hình mờ/giữa
    # echo 300 > hình mờ/thấp

Xin lưu ý rằng chúng tôi khuyên bạn nên sử dụng các công cụ không gian người dùng như ZZ0000ZZ thay vì đọc và viết thủ công
các tập tin như trên.  Trên đây chỉ là một ví dụ.

.. _tracepoint:

Dấu vết cho kết quả giám sát
==================================

Người dùng có thể nhận được kết quả giám sát thông qua ZZ0000ZZ.  Giao diện này rất hữu ích để có được một
ảnh chụp nhanh, nhưng nó có thể không hiệu quả để ghi lại đầy đủ tất cả các hoạt động giám sát
kết quả.  Với mục đích này, hai điểm theo dõi, cụ thể là ZZ0003ZZ
và ZZ0004ZZ, được cung cấp.  ZZ0005ZZ
cung cấp toàn bộ kết quả giám sát, trong khi ZZ0006ZZ
cung cấp kết quả giám sát cho các khu vực mà mỗi Hoạt động dựa trên DAMON
Đề án (ZZ0001ZZ) sẽ được áp dụng.  Do đó,
ZZ0007ZZ hữu ích hơn cho việc ghi lại hành vi nội bộ của
Truy cập mục tiêu DAMOS hoặc DAMOS
Hiệu quả giống như truy vấn dựa trên ZZ0002ZZ
theo dõi ghi nhận kết quả.

Trong khi chức năng giám sát được bật, bạn có thể ghi lại các sự kiện theo dõi và
hiển thị kết quả bằng các công cụ hỗ trợ tracepoint như ZZ0000ZZ.  Ví dụ::

# echo bật > kdamonds/0/state
    Bản ghi # perf -e damon:damon_aggregated &
    # sleep 5
    # kill 9 $(hoàn hảo)
    Tắt # echo > kdamonds/0/state
    Tập lệnh # perf
    kdamond.0 46568 [027] 79357.842179: damon:damon_aggregated: target_id=0 nr_khu vực=11 122509119488-135708762112: 0 864
    […]

Mỗi dòng của đầu ra tập lệnh hoàn hảo đại diện cho từng vùng giám sát.  các
năm trường đầu tiên giống như các kết quả đầu ra khác của tracepoint.  Cánh đồng thứ sáu
(ZZ0002ZZ) hiển thị ide của mục tiêu giám sát của khu vực.  các
trường thứ bảy (ZZ0003ZZ) hiển thị tổng số vùng giám sát
cho mục tiêu.  Trường thứ tám (ZZ0004ZZ) hiển thị phần đầu (ZZ0005ZZ) và phần cuối
(ZZ0006ZZ) địa chỉ của vùng tính bằng byte.  Trường thứ chín (ZZ0007ZZ) hiển thị
ZZ0008ZZ của khu vực (tham khảo
ZZ0000ZZ để biết thêm chi tiết về
bộ đếm).  Cuối cùng, trường thứ mười (ZZ0009ZZ) hiển thị ZZ0010ZZ của khu vực
(tham khảo ZZ0001ZZ để biết thêm chi tiết về
bộ đếm).

Nếu sự kiện là ZZ0000ZZ, đầu ra ZZ0001ZZ sẽ
có phần giống như dưới đây::

kdamond.0 47293 [000] 80801.060214: damon:damos_b Before_apply: ctx_idx=0 diagram_idx=0 target_idx=0 nr_zones=11 121932607488-135128711168: 0 136
    […]

Mỗi dòng đầu ra đại diện cho từng vùng giám sát mà mỗi DAMON dựa trên
Kế hoạch hoạt động sắp được áp dụng vào thời điểm truy tìm.  Năm đầu tiên
trường vẫn như bình thường.  Nó hiển thị chỉ mục của bối cảnh DAMON (ZZ0000ZZ)
của lược đồ trong danh sách các ngữ cảnh của kdamond của ngữ cảnh, chỉ mục
của lược đồ (ZZ0001ZZ) trong danh sách các lược đồ của ngữ cảnh, trong
bổ sung vào đầu ra của điểm theo dõi ZZ0002ZZ.