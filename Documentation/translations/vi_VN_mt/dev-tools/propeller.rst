.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/dev-tools/propeller.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

========================================
Sử dụng Propeller với nhân Linux
========================================

Điều này cho phép hỗ trợ xây dựng Propeller cho kernel khi sử dụng Clang
trình biên dịch. Cánh quạt là phương pháp tối ưu hóa hướng dẫn cấu hình (PGO) được sử dụng
để tối ưu hóa các tệp thực thi nhị phân. Giống như AutoFDO, nó sử dụng phần cứng
lấy mẫu để thu thập thông tin về tần suất thực hiện của
các đường dẫn mã khác nhau trong một tệp nhị phân. Không giống như AutoFDO, thông tin này
sau đó được sử dụng ngay trước giai đoạn liên kết để tối ưu hóa (trong số những giai đoạn khác)
bố trí khối bên trong và trên các chức năng.

Một số lưu ý quan trọng khi áp dụng tối ưu hóa Propeller:

#. Mặc dù nó có thể được sử dụng như một bước tối ưu hóa độc lập, nhưng nó
   thực sự khuyến khích áp dụng Propeller trên AutoFDO,
   AutoFDO+ThinLTO hoặc Dụng cụ FDO. Phần còn lại của tài liệu này
   giả định mô hình này.

#. Cánh quạt sử dụng một vòng định hình khác phía trên
   AutoFDO/AutoFDO+ThinLTO/iFDO. Toàn bộ quá trình xây dựng bao gồm
   "build-afdo - tàu-afdo - xây dựng cánh quạt - tàu-cánh quạt -
   được tối ưu hóa cho việc xây dựng".

#. Cánh quạt yêu cầu bản phát hành LLVM 19 trở lên cho Clang/Clang++
   và trình liên kết (ld.lld).

#. Ngoài chuỗi công cụ LLVM, Propeller yêu cầu lập hồ sơ
   công cụ chuyển đổi: ZZ0000ZZ có bản phát hành
   sau v0.30.1: ZZ0001ZZ

Quá trình tối ưu hóa cánh quạt bao gồm các bước sau:

#. Xây dựng ban đầu: Xây dựng nhị phân AutoFDO hoặc AutoFDO+ThinLTO dưới dạng
   bạn thường làm như vậy, nhưng với một tập hợp thời gian biên dịch/thời gian liên kết
   cờ, để một phần siêu dữ liệu đặc biệt được tạo trong
   kernel binary. Phần đặc biệt chỉ được sử dụng bởi
   công cụ định hình, nó không phải là một phần của hình ảnh thời gian chạy và cũng không
   thay đổi phần văn bản thời gian chạy kernel.

#. Cấu hình: Kernel trên sau đó được chạy với một đại diện
   khối lượng công việc để thu thập dữ liệu tần suất thực hiện. Dữ liệu này được thu thập
   sử dụng lấy mẫu phần cứng, thông qua perf. Cánh quạt có hiệu quả nhất trên
   nền tảng hỗ trợ các tính năng PMU nâng cao như LBR trên Intel
   máy móc. Bước này giống như lập hồ sơ kernel cho AutoFDO
   (các thông số hoàn hảo chính xác có thể khác nhau).

#. Tạo hồ sơ cánh quạt: Tệp đầu ra Perf được chuyển đổi thành tệp
   cặp cấu hình Cánh quạt thông qua một công cụ ngoại tuyến.

#. Bản dựng được tối ưu hóa: Xây dựng AutoFDO hoặc AutoFDO+ThinLTO được tối ưu hóa
   nhị phân như bạn thường làm, nhưng với thời gian biên dịch /
   cờ thời gian liên kết để nhận thời gian biên dịch Propeller và thời gian liên kết
   hồ sơ. Bước xây dựng này sử dụng 3 cấu hình - cấu hình AutoFDO,
   cấu hình thời gian biên dịch Propeller và thời gian liên kết Propeller
   hồ sơ.

#. Triển khai: Hệ nhị phân hạt nhân được tối ưu hóa được triển khai và sử dụng
   trong môi trường sản xuất, mang lại hiệu suất được cải thiện
   và giảm độ trễ.

Sự chuẩn bị
===========

Cấu hình kernel với::

CONFIG_AUTOFDO_CLANG=y
   CONFIG_PROPELLER_CLANG=y

Tùy chỉnh
=============

Cài đặt CONFIG_PROPELLER_CLANG mặc định bao gồm các đối tượng không gian kernel
cho các bản dựng cánh quạt. Tuy nhiên, người ta có thể bật hoặc tắt bản dựng Propeller
cho các tập tin và thư mục riêng lẻ bằng cách thêm một dòng tương tự như
theo dõi Makefile kernel tương ứng:

- Để kích hoạt một tập tin (ví dụ: foo.o)::

PROPELLER_PROFILE_foo.o := y

- Để kích hoạt tất cả các tập tin trong một thư mục::

PROPELLER_PROFILE := y

- Để vô hiệu hóa một tập tin::

PROPELLER_PROFILE_foo.o := n

- Để vô hiệu hóa tất cả các tập tin trong một thư mục::

PROPELLER__PROFILE := n


Quy trình làm việc
==================

Dưới đây là một quy trình làm việc mẫu để xây dựng hạt nhân AutoFDO+Propeller:

1) Giả sử hồ sơ AutoFDO đã được thu thập sau
   hướng dẫn trong tài liệu AutoFDO, xây dựng kernel trên máy chủ
   máy, với cấu hình xây dựng AutoFDO và Propeller ::

CONFIG_AUTOFDO_CLANG=y
      CONFIG_PROPELLER_CLANG=y

Và ::

$ tạo LLVM=1 CLANG_AUTOFDO_PROFILE=<autofdo-profile-name>

2) Cài đặt kernel trên máy thử nghiệm.

3) Chạy thử nghiệm tải. Tùy chọn '-c' trong perf chỉ định mẫu
   thời kỳ sự kiện. Chúng tôi khuyên bạn nên sử dụng số nguyên tố phù hợp, như 500009,
   cho mục đích này.

- Đối với nền tảng Intel::

$ bản ghi hoàn hảo -e BR_INST_RETIRED.NEAR_TAKEN:k -a -N -b -c <count> -o <perf_file> -- <loadtest>

- Đối với nền tảng AMD::

$ bản ghi hoàn hảo --pfm-event RETIRED_TAKEN_BRANCH_INSTRUCTIONS:k -a -N -b -c <count> -o <perf_file> -- <loadtest>

Lưu ý rằng bạn có thể lặp lại các bước trên để thu thập nhiều <perf_file>.

4) (Tùy chọn) Tải (các) tệp hoàn hảo thô xuống máy chủ.

5) Sử dụng công cụ create_llvm_prof (ZZ0000ZZ để
   tạo hồ sơ cánh quạt. ::

$ create_llvm_prof --binary=<vmlinux> --profile=<perf_file>
                         --format=cánh quạt --propeller_output_module_name
                         --out=<propeller_profile_prefix>_cc_profile.txt
                         --propeller_symorder=<propeller_profile_prefix>_ld_profile.txt

"<propeller_profile_prefix>" có thể giống như "/home/user/dir/any_string".

Lệnh này tạo ra một cặp cấu hình Cánh quạt:
   "<propeller_profile_prefix>_cc_profile.txt" và
   "<propeller_profile_prefix>_ld_profile.txt".

Nếu có nhiều hơn 1 perf_file được thu thập ở bước trước,
   bạn có thể tạo tệp danh sách tạm thời "<perf_file_list>" với mỗi dòng
   chứa một tên tệp hoàn hảo và chạy ::

$ create_llvm_prof --binary=<vmlinux> --profile=@<perf_file_list>
                         --format=cánh quạt --propeller_output_module_name
                         --out=<propeller_profile_prefix>_cc_profile.txt
                         --propeller_symorder=<propeller_profile_prefix>_ld_profile.txt

6) Xây dựng lại kernel bằng AutoFDO và Propeller
   hồ sơ. ::

CONFIG_AUTOFDO_CLANG=y
      CONFIG_PROPELLER_CLANG=y

Và ::

$ tạo LLVM=1 CLANG_AUTOFDO_PROFILE=<profile_file> CLANG_PROPELLER_PROFILE_PREFIX=<propeller_profile_prefix>