.. SPDX-License-Identifier: GPL-2.0-only

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/dev-tools/container.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. Copyright (C) 2025 Guillaume Tucker

==================================
Bản dựng được chứa trong container
==================================

Công cụ ZZ0000ZZ có thể được sử dụng để chạy bất kỳ lệnh nào trong cây nguồn kernel
từ bên trong một thùng chứa.  Làm như vậy sẽ tạo điều kiện thuận lợi cho việc tái tạo các bản dựng trên
các nền tảng khác nhau, ví dụ như khi bot thử nghiệm báo cáo sự cố
yêu cầu một phiên bản cụ thể của trình biên dịch hoặc bộ kiểm tra bên ngoài.  Trong khi
điều này đã có thể được thực hiện bởi những người dùng quen thuộc với vùng chứa, có
công cụ chuyên dụng trong cây nhân làm giảm rào cản gia nhập bằng cách giải quyết các vấn đề chung
các vấn đề một lần và mãi mãi (ví dụ: quản lý id người dùng).  Nó cũng làm cho nó dễ dàng hơn
để chia sẻ một dòng lệnh chính xác dẫn đến một kết quả cụ thể.  Công dụng chính
trường hợp có thể là bản dựng kernel nhưng hầu như mọi thứ đều có thể chạy được: KUnit,
checkpatch, v.v. miễn là có sẵn hình ảnh phù hợp.


Tùy chọn
=======

Cú pháp dòng lệnh::

tập lệnh/vùng chứa -i IMAGE [OPTION]... CMD...

Tùy chọn có sẵn:

ZZ0000ZZ

Đường dẫn đến tệp môi trường để tải vào vùng chứa.

ZZ0000ZZ

Id nhóm để sử dụng bên trong vùng chứa.

ZZ0000ZZ

Tên hình ảnh vùng chứa (bắt buộc).

ZZ0000ZZ

Tên thời gian chạy vùng chứa.  Thời gian chạy được hỗ trợ: ZZ0000ZZ, ZZ0001ZZ.

Nếu không được chỉ định, cái đầu tiên được tìm thấy trên hệ thống sẽ được sử dụng
    tức là Podman nếu có, nếu không thì Docker.

ZZ0000ZZ

Chạy vùng chứa trong trình bao tương tác.

ZZ0000ZZ

Id người dùng để sử dụng bên trong vùng chứa.

Nếu tùy chọn ZZ0000ZZ không được chỉ định, id người dùng cũng sẽ được sử dụng cho
    id nhóm.

ZZ0000ZZ

Kích hoạt đầu ra chi tiết.

ZZ0000ZZ

Hiển thị thông báo trợ giúp và thoát.


Cách sử dụng
=====

Người dùng hoàn toàn có quyền lựa chọn sử dụng hình ảnh nào và ZZ0000ZZ
các đối số được truyền trực tiếp dưới dạng dòng lệnh tùy ý để chạy trong
thùng chứa.  Công cụ sẽ đảm nhiệm việc gắn cây nguồn như hiện tại
thư mục làm việc và điều chỉnh id người dùng và nhóm nếu cần.

Hình ảnh vùng chứa thường bao gồm chuỗi công cụ biên dịch là
do người dùng cung cấp và được chọn thông qua tùy chọn ZZ0000ZZ.  Thời gian chạy vùng chứa
có thể được chọn bằng tùy chọn ZZ0001ZZ, có thể là ZZ0002ZZ hoặc
ZZ0003ZZ.  Nếu không có gì được chỉ định, cái đầu tiên được tìm thấy trên hệ thống sẽ là
được sử dụng trong khi ưu tiên cho Podman.  Hỗ trợ cho các thời gian chạy khác có thể được thêm vào
sau này tùy thuộc vào mức độ phổ biến của chúng đối với người dùng.

Theo mặc định, các lệnh được chạy không tương tác.  Người dùng có thể hủy bỏ một hoạt động đang chạy
vùng chứa bằng SIGINT (Ctrl-C).  Để chạy các lệnh tương tác với TTY,
Có thể sử dụng tùy chọn ZZ0000ZZ hoặc ZZ0001ZZ.  Tín hiệu sau đó sẽ được nhận bởi
shell trực tiếp thay vì quy trình ZZ0002ZZ gốc.  Để thoát khỏi một
shell tương tác, hãy sử dụng Ctrl-D hoặc ZZ0003ZZ.

.. note::

   The only host requirement aside from a container runtime is Python 3.10 or
   later.

.. note::

   Out-of-tree builds are not fully supported yet.  The ``O=`` option can
   however already be used with a relative path inside the source tree to keep
   separate build outputs.  A workaround to build outside the tree is to use
   ``mount --bind``, see the examples section further down.


Biến môi trường
=====================

Các biến môi trường không được truyền tới vùng chứa nên chúng phải được
được xác định trong chính hình ảnh hoặc thông qua tùy chọn ZZ0000ZZ bằng cách sử dụng
tập tin môi trường.  Trong một số trường hợp, sẽ hợp lý hơn khi xác định chúng trong
Containerfile được sử dụng để tạo hình ảnh.  Ví dụ: trình biên dịch chỉ Clang
hình ảnh chuỗi công cụ có thể được xác định ZZ0001ZZ.

Tệp môi trường cục bộ hữu ích hơn cho các biến dành riêng cho người dùng được thêm vào
trong quá trình phát triển.  Nó được truyền nguyên trạng vào thời gian chạy vùng chứa nên định dạng của nó
có thể khác nhau.  Thông thường, nó sẽ trông giống như đầu ra của ZZ0000ZZ.  Ví dụ::

INSTALL_MOD_STRIP=1
  SOME_RANDOM_TEXT=Ngày xửa ngày xưa

Cũng xin lưu ý rằng các tùy chọn ZZ0000ZZ vẫn có thể được truyền trên dòng lệnh,
vì vậy, mặc dù điều này không thể thực hiện được vì đối số đầu tiên cần phải là
thực thi::

scripts/container -i docker.io/tuxmake/korg-clang LLVM=1 khiến # won không hoạt động

cái này sẽ hoạt động::

scripts/container -i docker.io/tuxmake/korg-clang tạo LLVM=1


ID người dùng
========

Đây là lĩnh vực mà hành vi sẽ thay đổi đôi chút tùy thuộc vào
thời gian chạy vùng chứa.  Mục tiêu là chạy các lệnh khi người dùng gọi công cụ.
Với Podman, một không gian tên được tạo để ánh xạ id người dùng hiện tại sang một id khác
một trong vùng chứa (1000 theo mặc định).  Với Docker, trong khi điều này cũng
có thể với các phiên bản gần đây, nó yêu cầu kích hoạt một tính năng đặc biệt trong
daemon nên nó không được sử dụng ở đây vì đơn giản.  Thay vào đó, container được chạy
trực tiếp với id người dùng hiện tại.  Trong cả hai trường hợp, điều này sẽ cung cấp cùng một
quyền truy cập tệp đối với cây nguồn kernel được gắn dưới dạng ổ đĩa.  duy nhất
điểm khác biệt là khi sử dụng Docker không có vùng tên, id người dùng có thể không
giống như cài đặt mặc định trong hình ảnh.

Giả sử chúng tôi đang sử dụng một hình ảnh thiết lập người dùng mặc định có id 1000 và
người dùng hiện tại gọi công cụ ZZ0000ZZ có id 1234. Nguồn kernel
cây đã được người dùng này kiểm tra nên các tệp thuộc về người dùng 1234. Với
Podman, vùng chứa sẽ chạy với tư cách id người dùng 1000 với ánh xạ tới id 1234
để các tập tin từ ổ đĩa được gắn dường như thuộc về id 1000 bên trong
thùng chứa.  Với Docker và không có không gian tên, vùng chứa sẽ chạy
với id người dùng 1234 có thể truy cập các tệp trong ổ đĩa nhưng không có trong người dùng
1000 thư mục chính.  Đây không phải là vấn đề khi chỉ chạy lệnh trong
cây nhân nhưng cần nhấn mạnh ở đây vì nó có thể quan trọng đối với
trường hợp góc đặc biệt.

.. note::

   Podman's `Docker compatibility
   <https://podman-desktop.io/docs/migrating-from-docker/managing-docker-compatibility>`__
   mode to run ``docker`` commands on top of a Podman backend is more complex
   and not fully supported yet.  As such, Podman will take priority if both
   runtimes are available on the system.


Ví dụ
========

Dự án TuxMake cung cấp nhiều hình ảnh vùng chứa dựng sẵn có sẵn
trên ZZ0000ZZ.  Đây là ngắn nhất
ví dụ về xây dựng hạt nhân bằng hình ảnh TuxMake Clang::

scripts/container -i docker.io/tuxmake/korg-clang -- tạo LLVM=1 defconfig
  scripts/container -i docker.io/tuxmake/korg-clang -- tạo LLVM=1 -j$(nproc)

.. note::

   When running a command with options within the container, it should be
   separated with a double dash ``--`` to not confuse them with the
   ``container`` tool options.  Plain commands with no options don't strictly
   require the double dashes e.g.::

     scripts/container -i docker.io/tuxmake/korg-clang make mrproper

Để chạy ZZ0000ZZ trong thư mục ZZ0001ZZ có hình ảnh Perl chung::

scripts/container -i Perl:slim-trixie scripts/checkpatch.pl Patch/*

Để thay thế cho hình ảnh TuxMake, các ví dụ bên dưới đề cập đến
Hình ảnh ZZ0000ZZ dựa trên ZZ0002ZZ.  Những điều này chưa (chưa) chính thức
có sẵn trong bất kỳ cơ quan đăng ký công khai nào nhưng thay vào đó người dùng có thể tự xây dựng cục bộ của mình
sử dụng ZZ0003ZZ này bằng cách chạy ZZ0001ZZ.

Để chỉ xây dựng ZZ0000ZZ bằng Clang ::

scripts/container -i kernel.org/clang -- tạo bzImage -j$(nproc)

Tương tự với GCC 15 dưới dạng thẻ phiên bản cụ thể::

scripts/container -i kernel.org/gcc:15 -- tạo bzImage -j$(nproc)

Đối với bản dựng ngoài cây, một mẹo là gắn kết thư mục đích vào
một đường dẫn tương đối bên trong cây nguồn::

mkdir -p $HOME/tmp/my-kernel-build
  xây dựng mkdir -p
  sudo mount --bind $HOME/tmp/my-kernel-build build
  scripts/container -i kernel.org/gcc -- tạo mrproper
  scripts/container -i kernel.org/gcc -- make O=build defconfig
  scripts/container -i kernel.org/gcc -- make O=build -j$(nproc)

Để chạy KUnit trong shell tương tác và nhận được kết quả đầu ra đầy đủ ::

scripts/container -s -i kernel.org/gcc:kunit -- \
      công cụ/kiểm tra/kunit/kunit.py \
          chạy \
          --arch=x86_64 \
          --cross_compile=x86_64-linux-

Để chỉ bắt đầu một shell tương tác::

scripts/container -si kernel.org/gcc bash

Để xây dựng tài liệu HTML, tài liệu này yêu cầu hình ảnh ZZ0000ZZ được xây dựng bằng
ZZ0001ZZ vì nó không phải là chuỗi công cụ biên dịch ::

scripts/container -i kernel.org/kdocs tạo htmldocs