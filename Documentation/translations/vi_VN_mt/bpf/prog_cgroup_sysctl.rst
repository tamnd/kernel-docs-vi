.. SPDX-License-Identifier: (LGPL-2.1 OR BSD-2-Clause)

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/bpf/prog_cgroup_sysctl.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

==============================
BPF_PROG_TYPE_CGROUP_SYSCTL
==============================

Tài liệu này mô tả loại chương trình ZZ0000ZZ
cung cấp hook cgroup-bpf cho sysctl.

Móc phải được gắn vào một nhóm và sẽ được gọi mỗi lần
quá trình bên trong nhóm đó cố gắng đọc hoặc ghi vào núm sysctl trong Proc.

1. Kiểu đính kèm
****************

Loại đính kèm ZZ0000ZZ phải được sử dụng để đính kèm
Chương trình ZZ0001ZZ cho một nhóm.

2. Bối cảnh
***********

ZZ0000ZZ cung cấp quyền truy cập vào bối cảnh sau từ
Chương trình BPF::

cấu trúc bpf_sysctl {
        __u32 viết;
        __u32 file_pos;
    };

* ZZ0000ZZ cho biết giá trị sysctl đang được đọc (ZZ0001ZZ) hay được ghi
  (ZZ0002ZZ). Trường này là chỉ đọc.

* ZZ0000ZZ cho biết vị trí file sysctl đang được truy cập tại, đọc
  hoặc được viết. Trường này là đọc-ghi. Viết vào trường thiết lập sự bắt đầu
  vị trí trong tệp Proc sysctl ZZ0001ZZ sẽ được đọc từ hoặc ZZ0002ZZ
  sẽ viết thư cho Viết số 0 vào trường có thể được sử dụng, ví dụ: ghi đè
  toàn bộ giá trị sysctl của ZZ0003ZZ trên ZZ0004ZZ thậm chí
  khi nó được gọi bởi không gian người dùng trên ZZ0005ZZ. Viết khác không
  giá trị vào trường có thể được sử dụng để truy cập một phần giá trị sysctl bắt đầu từ
  được chỉ định ZZ0006ZZ. Không phải tất cả sysctl đều hỗ trợ quyền truy cập bằng ZZ0007ZZ, ví dụ: ghi vào các mục sysctl số phải luôn ở vị trí tệp
  ZZ0008ZZ. Xem thêm hệ thống ZZ0009ZZ.

Xem ZZ0000ZZ để biết thêm chi tiết về cách truy cập trường ngữ cảnh.

3. Mã trả lại
**************

Chương trình ZZ0000ZZ phải trả về một trong những giá trị sau
mã trả lại:

* ZZ0000ZZ có nghĩa là "từ chối quyền truy cập vào sysctl";
* ZZ0001ZZ có nghĩa là "tiếp tục truy cập".

Nếu chương trình trả về ZZ0000ZZ, không gian người dùng sẽ nhận được ZZ0001ZZ từ ZZ0002ZZ hoặc
ZZ0003ZZ và ZZ0004ZZ sẽ được đặt thành ZZ0005ZZ.

4. Người trợ giúp
*****************

Vì núm sysctl được biểu thị bằng tên và giá trị, nên BPF dành riêng cho sysctl
người trợ giúp tập trung vào việc cung cấp quyền truy cập vào các thuộc tính này:

* ZZ0000ZZ để lấy tên sysctl như hiển thị trong
  ZZ0001ZZ được cung cấp bởi bộ đệm chương trình BPF;

* ZZ0000ZZ để lấy giá trị chuỗi hiện đang được giữ bởi
  sysctl được cung cấp bởi bộ đệm chương trình BPF. Trình trợ giúp này có sẵn trên cả hai
  ZZ0001ZZ từ và ZZ0002ZZ tới sysctl;

* ZZ0000ZZ để nhận giá trị chuỗi mới hiện có
  được ghi vào sysctl trước khi việc ghi thực sự diễn ra. Người trợ giúp này chỉ có thể được sử dụng
  trên ZZ0001ZZ;

* ZZ0000ZZ để ghi đè giá trị chuỗi mới hiện có
  được ghi vào sysctl trước khi việc ghi thực sự diễn ra. Giá trị Sysctl sẽ là
  được ghi đè bắt đầu từ ZZ0001ZZ hiện tại. Nếu toàn bộ giá trị
  phải được ghi đè chương trình BPF có thể đặt ZZ0002ZZ về 0 trước khi gọi
  tới người giúp việc. Trình trợ giúp này chỉ có thể được sử dụng trên ZZ0003ZZ. Mới
  giá trị chuỗi do trình trợ giúp đặt được xử lý và xác minh bởi kernel giống như
  một chuỗi tương đương được truyền bởi không gian người dùng.

Chương trình BPF nhìn thấy giá trị sysctl giống như cách không gian người dùng thực hiện trong hệ thống tệp Proc,
tức là như một chuỗi. Vì nhiều giá trị sysctl biểu diễn một số nguyên hoặc một vectơ
của số nguyên, có thể sử dụng các trợ giúp sau để lấy giá trị số từ
chuỗi:

* ZZ0000ZZ để chuyển đổi phần đầu của chuỗi thành số nguyên dài
  tương tự như không gian người dùng ZZ0002ZZ;
* ZZ0001ZZ để chuyển đổi phần đầu của chuỗi thành chuỗi dài không dấu
  số nguyên tương tự như không gian người dùng ZZ0003ZZ;

Xem ZZ0000ZZ để biết thêm chi tiết về những người trợ giúp được mô tả ở đây.

5. Ví dụ
***********

Xem ZZ0000ZZ để biết ví dụ về chương trình BPF trong C truy cập
tên và giá trị sysctl, phân tích giá trị chuỗi để lấy vectơ số nguyên và cách sử dụng
kết quả để đưa ra quyết định cho phép hay từ chối quyền truy cập vào sysctl.

6. Ghi chú
**********

ZZ0000ZZ được thiết kế để sử dụng trong root ZZ0001ZZ
môi trường, ví dụ như để giám sát việc sử dụng sysctl hoặc nắm bắt các giá trị không hợp lý
một ứng dụng chạy bằng root trong một nhóm riêng biệt đang cố gắng thiết lập.

Vì ZZ0001ZZ được gọi tại thời điểm ZZ0002ZZ / ZZ0003ZZ nên
có thể trả về kết quả khác với kết quả tại thời điểm ZZ0004ZZ, tức là xử lý
Tệp sysctl đã mở trong hệ thống tệp Proc có thể khác với quy trình đang cố gắng
để đọc/ghi vào nó và hai quá trình như vậy có thể chạy ở các chế độ khác nhau
cgroups, ZZ0000ZZ không nên được sử dụng như một
cơ chế bảo mật để hạn chế việc sử dụng sysctl.

Như với bất kỳ chương trình cgroup-bpf nào, cần phải cẩn thận hơn nếu
ứng dụng chạy bằng root trong cgroup không được phép
tách/thay thế chương trình BPF do quản trị viên đính kèm.

.. Links
.. _linux/bpf.h: ../../include/uapi/linux/bpf.h
.. _strtol(3): http://man7.org/linux/man-pages/man3/strtol.3p.html
.. _strtoul(3): http://man7.org/linux/man-pages/man3/strtoul.3p.html
.. _test_sysctl_prog.c:
   ../../tools/testing/selftests/bpf/progs/test_sysctl_prog.c