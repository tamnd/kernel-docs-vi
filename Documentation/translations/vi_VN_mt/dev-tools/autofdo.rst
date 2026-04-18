.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/dev-tools/autofdo.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

======================================
Sử dụng AutoFDO với nhân Linux
======================================

Điều này cho phép hỗ trợ xây dựng AutoFDO cho kernel khi sử dụng
trình biên dịch Clang. AutoFDO (Tối ưu hóa theo hướng phản hồi tự động)
là một loại tối ưu hóa hướng dẫn hồ sơ (PGO) được sử dụng để nâng cao
hiệu suất của các tệp thực thi nhị phân. Nó thu thập thông tin về
tần suất thực thi các đường dẫn mã khác nhau trong một tệp nhị phân bằng cách sử dụng
lấy mẫu phần cứng. Dữ liệu này sau đó được sử dụng để hướng dẫn trình biên dịch
các quyết định tối ưu hóa, dẫn đến một hệ nhị phân hiệu quả hơn. AutoFDO
là một kỹ thuật tối ưu hóa mạnh mẽ và dữ liệu chỉ ra rằng nó có thể
cải thiện đáng kể hiệu suất hạt nhân. Nó đặc biệt có lợi
cho khối lượng công việc bị ảnh hưởng bởi các gian hàng phía trước.

Đối với các bản dựng AutoFDO, không giống như các bản dựng không phải FDO, người dùng phải cung cấp
hồ sơ. Việc lấy hồ sơ AutoFDO có thể được thực hiện theo nhiều cách.
Cấu hình AutoFDO được tạo bằng cách chuyển đổi lấy mẫu phần cứng bằng cách sử dụng
công cụ "hoàn hảo". Điều quan trọng là khối lượng công việc được sử dụng để tạo ra những
tập tin hoàn hảo là đại diện; họ phải thể hiện thời gian chạy
các đặc điểm tương tự như khối lượng công việc dự kiến
được tối ưu hóa. Không làm như vậy sẽ dẫn đến việc tối ưu hóa trình biên dịch
vì mục tiêu sai lầm.

Cấu hình AutoFDO thường gói gọn hành vi của chương trình. Nếu
các mã quan trọng về hiệu năng không phụ thuộc vào kiến trúc, cấu hình
có thể được áp dụng trên các nền tảng để đạt được hiệu suất. cho
Ví dụ, sử dụng cấu hình được tạo trên kiến trúc Intel để xây dựng
kernel cho kiến trúc AMD cũng có thể mang lại những cải tiến về hiệu suất.

Có hai phương pháp để có được hồ sơ đại diện:
(1) Lấy mẫu khối lượng công việc thực tế bằng môi trường sản xuất.
(2) Tạo hồ sơ bằng cách sử dụng thử nghiệm tải đại diện.
Khi bật cấu hình bản dựng AutoFDO mà không cung cấp
Cấu hình AutoFDO, trình biên dịch chỉ sửa đổi thông tin lùn trong
kernel mà không ảnh hưởng đến hiệu suất thời gian chạy. Đó là khuyến khích để
sử dụng hệ nhị phân hạt nhân được xây dựng với cùng cấu hình AutoFDO để
thu thập hồ sơ hoàn hảo. Mặc dù có thể sử dụng kernel được xây dựng
với các tùy chọn khác nhau, nó có thể dẫn đến hiệu suất kém hơn.

Người ta có thể thu thập hồ sơ bằng cách sử dụng bản dựng AutoFDO cho kernel trước đó.
AutoFDO sử dụng số dòng tương đối để khớp với các cấu hình, cung cấp
một số khả năng chịu đựng đối với những thay đổi nguồn. Chế độ này thường được sử dụng trong
môi trường sản xuất để thu thập hồ sơ.

Trong bộ sưu tập hồ sơ dựa trên thử nghiệm tải, bộ sưu tập AutoFDO
quá trình bao gồm các bước sau:

#. Bản dựng ban đầu: Kernel được xây dựng với các tùy chọn AutoFDO
   không có hồ sơ.

#. Cấu hình: Kernel trên sau đó được chạy với một đại diện
   khối lượng công việc để thu thập dữ liệu tần suất thực hiện. Dữ liệu này là
   được thu thập bằng cách lấy mẫu phần cứng, thông qua perf. AutoFDO là tốt nhất
   hiệu quả trên các nền tảng hỗ trợ các tính năng PMU nâng cao như
   LBR trên máy Intel.

#. Tạo hồ sơ AutoFDO: Tệp đầu ra Perf được chuyển đổi thành
   cấu hình AutoFDO thông qua các công cụ ngoại tuyến.

Hỗ trợ yêu cầu trình biên dịch Clang LLVM 17 trở lên.

Sự chuẩn bị
===========

Cấu hình kernel với::

CONFIG_AUTOFDO_CLANG=y

Tùy chỉnh
=============

Cài đặt CONFIG_AUTOFDO_CLANG mặc định bao gồm các đối tượng không gian kernel cho
Bản dựng AutoFDO. Tuy nhiên, người ta có thể bật hoặc tắt bản dựng AutoFDO cho
các tệp và thư mục riêng lẻ bằng cách thêm một dòng tương tự như sau
vào Makefile kernel tương ứng:

- Để bật một tệp duy nhất (ví dụ: foo.o) ::

AUTOFDO_PROFILE_foo.o := y

- Để kích hoạt tất cả các tập tin trong một thư mục ::

AUTOFDO_PROFILE := y

- Để vô hiệu hóa một tập tin ::

AUTOFDO_PROFILE_foo.o := n

- Để vô hiệu hóa tất cả các tập tin trong một thư mục ::

AUTOFDO_PROFILE := n

Quy trình làm việc
========

Dưới đây là quy trình làm việc mẫu cho kernel AutoFDO:

1) Xây dựng kernel trên máy chủ đã bật LLVM,
    ví dụ:::

$ tạo menuconfig LLVM=1

Bật cấu hình bản dựng AutoFDO ::

CONFIG_AUTOFDO_CLANG=y

Với cấu hình đã bật LLVM, hãy sử dụng lệnh sau ::

$ script/config -e AUTOFDO_CLANG

Sau khi nhận được cấu hình, hãy xây dựng với ::

$ tạo ra LLVM=1

2) Cài đặt kernel trên máy thử nghiệm.

3) Chạy thử nghiệm tải. Tùy chọn '-c' trong perf chỉ định mẫu
   thời kỳ sự kiện. Chúng tôi khuyên bạn nên sử dụng số nguyên tố phù hợp, như 500009,
   cho mục đích này.

- Đối với nền tảng Intel::

$ bản ghi hoàn hảo -e BR_INST_RETIRED.NEAR_TAKEN:k -a -N -b -c <count> -o <perf_file> -- <loadtest>

- Đối với nền tảng AMD:

Các hệ thống được hỗ trợ là: Zen3 với BRS hoặc Zen4 với amd_lbr_v2. Để kiểm tra,

Dành cho Zen3::

$ cat /proc/cpuinfo | grep "brs"

Dành cho Zen4::

$ cat /proc/cpuinfo | grep amd_lbr_v2

Lệnh sau đã tạo tệp dữ liệu perf ::

$ bản ghi hoàn hảo --pfm-events RETIRED_TAKEN_BRANCH_INSTRUCTIONS:k -a -N -b -c <count> -o <perf_file> -- <loadtest>

4) (Tùy chọn) Tải tệp hoàn hảo thô xuống máy chủ.

5) Để tạo hồ sơ AutoFDO, có sẵn hai công cụ ngoại tuyến:
   create_llvm_prof và llvm_profgen. Công cụ create_llvm_prof là một phần
   của dự án AutoFDO và có thể tìm thấy trên GitHub
   (ZZ0000ZZ phiên bản v0.30.1 trở lên.
   Công cụ llvm_profgen được bao gồm trong chính trình biên dịch LLVM. Đó là
   điều quan trọng cần lưu ý là phiên bản của llvm_profgen không cần phải khớp
   phiên bản của Clang. Nó phải là bản phát hành LLVM 19 của Clang
   hoặc mới hơn, hoặc chỉ từ thân LLVM. ::

$ llvm-profgen --kernel --binary=<vmlinux> --perfdata=<perf_file> -o <profile_file>

hoặc ::

$ create_llvm_prof --binary=<vmlinux> --profile=<perf_file> --format=extbinary --out=<profile_file>

Lưu ý rằng nhiều tệp hồ sơ AutoFDO có thể được hợp nhất thành một thông qua ::

$ llvm-profdata hợp nhất -o <profile_file> <profile_1> <profile_2> ... <profile_n>

6) Xây dựng lại kernel bằng tệp hồ sơ AutoFDO có cùng cấu hình như bước 1,
   (Lưu ý cần bật CONFIG_AUTOFDO_CLANG)::

$ tạo LLVM=1 CLANG_AUTOFDO_PROFILE=<profile_file>