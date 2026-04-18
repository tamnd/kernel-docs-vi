.. SPDX-License-Identifier: (LGPL-2.1 OR BSD-2-Clause)

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/bpf/libbpf/libbpf_naming_convention.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

Quy ước đặt tên API
=====================

libbpf API cung cấp quyền truy cập vào một số nhóm được phân tách hợp lý
chức năng và các loại. Mỗi nhóm có quy ước đặt tên riêng
được mô tả ở đây Nên tuân theo những quy ước này bất cứ khi nào
chức năng hoặc loại mới được thêm vào để giữ cho libbpf API sạch sẽ và nhất quán.

Tất cả các loại và chức năng được cung cấp bởi libbpf API phải có một trong các
các tiền tố sau: ZZ0000ZZ, ZZ0001ZZ, ZZ0002ZZ, ZZ0003ZZ,
ZZ0004ZZ, ZZ0005ZZ.

Trình bao bọc cuộc gọi hệ thống
-------------------------------

Trình bao bọc cuộc gọi hệ thống là các trình bao bọc đơn giản cho các lệnh được hỗ trợ bởi
cuộc gọi hệ thống sys_bpf. Các trình bao bọc này sẽ chuyển đến tệp tiêu đề ZZ0000ZZ
và ánh xạ từng cái một tới các lệnh tương ứng.

Ví dụ ZZ0000ZZ bọc ZZ0001ZZ
lệnh của sys_bpf, ZZ0002ZZ bao bọc ZZ0003ZZ, v.v.

Đối tượng
---------

Một lớp loại và hàm khác được cung cấp bởi libbpf API là "đối tượng"
và các chức năng để làm việc với chúng. Các đối tượng là sự trừu tượng hóa cấp cao
chẳng hạn như chương trình BPF hoặc bản đồ BPF. Chúng được đại diện bởi tương ứng
các cấu trúc như ZZ0000ZZ, ZZ0001ZZ,
ZZ0002ZZ, v.v.

Các cấu trúc được khai báo chuyển tiếp và quyền truy cập vào các trường của chúng phải được
được cung cấp thông qua getters và setters tương ứng thay vì trực tiếp.

Các đối tượng này được liên kết với các phần tương ứng của đối tượng ELF
chứa các chương trình BPF đã biên dịch.

Ví dụ ZZ0000ZZ đại diện cho đối tượng ELF do chính nó tạo ra
từ tệp ELF hoặc từ bộ đệm, ZZ0001ZZ đại diện cho một
chương trình trong đối tượng ELF và ZZ0002ZZ là bản đồ.

Các hàm làm việc với một đối tượng có tên được xây dựng từ tên đối tượng,
dấu gạch dưới kép và phần mô tả mục đích của hàm.

Ví dụ ZZ0000ZZ bao gồm tên tương ứng
đối tượng, ZZ0001ZZ, dấu gạch dưới kép và ZZ0002ZZ xác định
mục đích của chức năng mở tệp ELF và tạo ZZ0003ZZ từ
nó.

Tất cả các đối tượng và chức năng tương ứng không liên quan đến BTF sẽ bị loại bỏ
tới ZZ0000ZZ. Các loại và chức năng của BTF nên chuyển đến ZZ0001ZZ.

Chức năng phụ trợ
-------------------

Các chức năng và loại phụ trợ không phù hợp với bất kỳ danh mục nào
được mô tả ở trên phải có tiền tố ZZ0000ZZ, ví dụ:
ZZ0001ZZ hoặc ZZ0002ZZ.

ABI
---

libbpf có thể được liên kết tĩnh hoặc được sử dụng dưới dạng DSO. Để tránh có thể
xung đột với các thư viện khác mà ứng dụng được liên kết, tất cả
các ký hiệu libbpf không tĩnh phải có một trong các tiền tố được đề cập trong
Tài liệu API ở trên. Xem quy ước đặt tên API để chọn đúng
tên cho một biểu tượng mới.

Khả năng hiển thị biểu tượng
----------------------------

libbpf tuân theo mô hình khi tất cả các ký hiệu chung có khả năng hiển thị "ẩn"
theo mặc định và để hiển thị một biểu tượng, nó phải được hiển thị rõ ràng
được quy cho macro ZZ0000ZZ. Ví dụ:

.. code-block:: c

        LIBBPF_API int bpf_prog_get_fd_by_id(__u32 id);

Điều này ngăn cản việc vô tình xuất ra một biểu tượng, điều đó không được phép
trở thành một phần của ABI, điều này sẽ cải thiện cả nhà phát triển libbpf- và
trải nghiệm người dùng.

Phiên bản ABI
--------------

Để có thể mở rộng ABI trong tương lai, libbpf ABI đã được phiên bản.
Việc lập phiên bản được thực hiện bởi tập lệnh phiên bản ZZ0000ZZ.
được chuyển đến trình liên kết.

Tên phiên bản là tiền tố ZZ0000ZZ + phiên bản số ba thành phần,
bắt đầu từ ZZ0001ZZ.

Mỗi khi ABI được thay đổi, ví dụ: bởi vì một biểu tượng mới được thêm vào hoặc
ngữ nghĩa của biểu tượng hiện tại đã thay đổi, phiên bản ABI sẽ bị thay đổi.
Sự thay đổi này trong phiên bản ABI nhiều nhất là một lần trong mỗi chu kỳ phát triển kernel.

Ví dụ: nếu trạng thái hiện tại của ZZ0000ZZ là:

.. code-block:: none

        LIBBPF_0.0.1 {
        	global:
                        bpf_func_a;
                        bpf_func_b;
        	local:
        		\*;
        };

, và một biểu tượng mới ZZ0000ZZ sẽ được giới thiệu, sau đó
ZZ0001ZZ nên được thay đổi như thế này:

.. code-block:: none

        LIBBPF_0.0.1 {
        	global:
                        bpf_func_a;
                        bpf_func_b;
        	local:
        		\*;
        };
        LIBBPF_0.0.2 {
                global:
                        bpf_func_c;
        } LIBBPF_0.0.1;

, trong đó phiên bản mới ZZ0000ZZ phụ thuộc vào phiên bản trước đó
ZZ0001ZZ.

Định dạng tập lệnh phiên bản và cách xử lý các thay đổi của ABI, bao gồm
những cái không tương thích, được mô tả chi tiết trong [1].

Xây dựng độc lập
-------------------

Trong ZZ0000ZZ có một hệ thống (bán) tự động
bản sao của phiên bản libbpf của dòng chính cho bản dựng độc lập.

Tuy nhiên, tất cả các thay đổi đối với cơ sở mã của libbpf phải được cập nhật thông qua
cây hạt nhân chính.


Quy ước tài liệu API
============================

libbpf API được ghi lại thông qua các nhận xét ở trên các định nghĩa trong
các tập tin tiêu đề. Những nhận xét này có thể được hiển thị bởi doxygen và sphinx
để có đầu ra html được tổ chức tốt. Phần này mô tả các
quy ước trong đó những bình luận này nên được định dạng.

Đây là một ví dụ từ btf.h:

.. code-block:: c

        /**
         * @brief **btf__new()** creates a new instance of a BTF object from the raw
         * bytes of an ELF's BTF section
         * @param data raw bytes
         * @param size number of bytes passed in `data`
         * @return new BTF object instance which has to be eventually freed with
         * **btf__free()**
         *
         * On error, error-code-encoded-as-pointer is returned, not a NULL. To extract
         * error code from such a pointer `libbpf_get_error()` should be used. If
         * `libbpf_set_strict_mode(LIBBPF_STRICT_CLEAN_PTRS)` is enabled, NULL is
         * returned on error instead. In both cases thread-local `errno` variable is
         * always set to error code as well.
         */

Nhận xét phải bắt đầu bằng nhận xét khối có dạng '/\ZZ0000ZZ'.

Tài liệu luôn bắt đầu bằng lệnh @brief. Dòng này ngắn
mô tả về API này. Nó bắt đầu bằng tên của API, được ký hiệu bằng chữ in đậm
như vậy: ZZ0000ZZ. Vui lòng bao gồm dấu ngoặc đơn mở và đóng nếu đây là
chức năng. Tiếp theo là mô tả ngắn gọn về API. Mô tả biểu mẫu dài hơn
có thể được thêm vào bên dưới chỉ thị cuối cùng, ở cuối bình luận.

Các tham số được biểu thị bằng lệnh @param, mỗi tham số phải có một tham số
tham số. Nếu đây là hàm có kết quả trả về không trống, hãy sử dụng lệnh @return
để ghi lại nó.

Giấy phép
-------------------

libbpf được cấp phép kép theo LGPL 2.1 và BSD 2-Clause.

Liên kết
-------------------

[1] ZZ0000ZZ
    (Chương 3. Duy trì API và ABI).