.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/process/kernel-docs.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

.. _kernel_docs:

Chỉ mục tài liệu hạt nhân bổ sung
=====================================

Sự cần thiết của một tài liệu như thế này đã trở nên rõ ràng trong hạt nhân linux
danh sách gửi thư như những câu hỏi tương tự, yêu cầu gợi ý thông tin,
xuất hiện nhiều lần.

May mắn thay, khi ngày càng có nhiều người sử dụng GNU/Linux, thì ngày càng có nhiều
quan tâm đến hạt nhân. Nhưng đọc các nguồn không phải lúc nào cũng đủ. Nó
mã dễ hiểu nhưng bỏ sót các khái niệm, triết lý và
quyết định thiết kế đằng sau mã này.

Thật không may, không có nhiều tài liệu dành cho người mới bắt đầu.
Và, ngay cả khi chúng tồn tại, không có nơi nào "nổi tiếng" theo dõi
của họ. Những dòng này cố gắng che đậy sự thiếu sót này.

PLEASE, nếu bạn biết bất kỳ giấy tờ nào không được liệt kê ở đây hoặc viết một tài liệu mới,
bao gồm một tham chiếu đến nó ở đây, sau khi gửi bản vá của kernel
quá trình. Mọi chỉnh sửa, ý tưởng hoặc nhận xét đều được hoan nghênh.

Tất cả các tài liệu được phân loại với các trường sau: tài liệu
"Tiêu đề",/các "Tác giả", "URL" nơi có thể tìm thấy chúng, một số "Từ khóa"
hữu ích khi tìm kiếm các chủ đề cụ thể và phần "Mô tả" ngắn gọn về
Tài liệu.

.. note::

   The documents on each section of this document are ordered by its
   published date, from the newest to the oldest. The maintainer(s) should
   periodically retire resources as they become obsolete or outdated; with
   the exception of foundational books.

Tài liệu tại cây hạt nhân Linux
-----------------------------

Sách Sphinx nên được xây dựng bằng ZZ0000ZZ.

* Tên: ZZ0000ZZ

:Tác giả: Nhiều.
      :Vị trí: Tài liệu/
      :Từ khóa: tập tin văn bản, Sphinx.
      :Mô tả: Tài liệu đi kèm với nguồn kernel,
        bên trong thư mục Tài liệu. Một số trang trong tài liệu này
        (bao gồm cả tài liệu này) đã được chuyển đến đó và có thể
        cập nhật hơn phiên bản web.

Tài liệu trực tuyến
------------

* Tiêu đề: ZZ0000ZZ

:Tác giả: khác nhau
      :URL: ZZ0000ZZ
      :Ngày: phiên bản cuộn
      :Từ khóa: bảng thuật ngữ, thuật ngữ, linux-kernel.
      :Mô tả: Từ phần giới thiệu: "Bảng thuật ngữ này nhằm mục đích
        mô tả ngắn gọn về một số từ viết tắt và thuật ngữ bạn có thể nghe thấy
        trong cuộc thảo luận về nhân Linux".

* Tiêu đề: ZZ0000ZZ

:Tác giả: Peter Jay Salzman, Michael Burian, Ori Pomerantz, Bob Mottram,
        Jim Huang.
      :URL: ZZ0000ZZ
      :Ngày: 2021
      :Từ khóa: mô-đun, sách GPL, /proc, ioctls, lệnh gọi hệ thống,
        trình xử lý ngắt.
      :Mô tả: Một cuốn sách GPL rất hay về chủ đề module
        lập trình. Rất nhiều ví dụ. Hiện nay phiên bản mới đang được
        được duy trì tích cực tại ZZ0001ZZ

Sách đã xuất bản
---------------

* Tiêu đề: ZZ0000ZZ

:Tác giả: Lorenzo Stoakes
      :Nhà xuất bản: No Starch Press
      :Ngày: Tháng 2 năm 2025
      :Trang: 1300
      :ISBN: 978-1718504462
      :Ghi chú: Quản lý bộ nhớ. Bản nháp đầy đủ có sẵn dưới dạng quyền truy cập sớm cho
              đặt hàng trước, dự kiến phát hành đầy đủ vào Mùa thu năm 2025. Xem
              ZZ0000ZZ để biết thêm thông tin.

* Tiêu đề: ZZ0000ZZ

:Tác giả: Kenneth Hess
      :Nhà xuất bản: O'Reilly Media
      :Ngày: Tháng 5 năm 2023
      :Trang: 246
      :ISBN: 978-1098109035
      :Ghi chú: Quản trị hệ thống

* Tiêu đề: ZZ0000ZZ

:Tác giả: Kaiwan N Billimoria
      :Nhà xuất bản: Packt Publishing Ltd
      :Ngày: Tháng 8 năm 2022
      :Trang: 638
      :ISBN: 978-1801075039
      :Ghi chú: Sách gỡ lỗi

* Tiêu đề: ZZ0000ZZ

:Tác giả: Kaiwan N Billimoria
      :Nhà xuất bản: Packt Publishing Ltd
      :Ngày: Tháng 3 năm 2021 (Ấn bản thứ hai xuất bản năm 2024)
      :Trang: 754
      :ISBN: 978-1789953435 (ISBN phiên bản thứ hai là 978-1803232225)

* Tiêu đề: ZZ0000ZZ

:Tác giả: Kaiwan N Billimoria
      :Nhà xuất bản: Packt Publishing Ltd
      :Ngày: Tháng 3 năm 2021
      :Trang: 452
      :ISBN: 978-1801079518

* Tiêu đề: ZZ0000ZZ

:Tác giả: Robert Love
      :Nhà xuất bản: O'Reilly Media
      :Ngày: tháng 6 năm 2013
      :Trang: 456
      :ISBN: 978-1449339531
      :Ghi chú: Sách nền tảng

* Tiêu đề: ZZ0000ZZ

:Tác giả: Robert Love
      :Nhà xuất bản: Addison-Wesley
      :Ngày: Tháng 7 năm 2010
      :Trang: 440
      :ISBN: 978-0672329463
      :Ghi chú: Sách nền tảng

.. _ldd3_published:

    * Title: **Linux Device Drivers, 3rd Edition**

      :Authors: Jonathan Corbet, Alessandro Rubini, and Greg Kroah-Hartman
      :Publisher: O'Reilly & Associates
      :Date: 2005
      :Pages: 636
      :ISBN: 0-596-00590-3
      :Notes: Foundational book. Further information in
        http://www.oreilly.com/catalog/linuxdrive3/
        PDF format, URL: https://lwn.net/Kernel/LDD3/

    * Title: **The Design of the UNIX Operating System**

      :Author: Maurice J. Bach
      :Publisher: Prentice Hall
      :Date: 1986
      :Pages: 471
      :ISBN: 0-13-201757-1
      :Notes: Foundational book

Linh tinh
-------------

* Tên: ZZ0000ZZ

:URL: ZZ0000ZZ
      :Từ khóa: Duyệt mã nguồn.
      :Mô tả: Một trình duyệt mã nguồn nhân Linux dựa trên web khác.
        Rất nhiều tham chiếu chéo đến các biến và hàm. Bạn có thể thấy
        nơi chúng được xác định và nơi chúng được sử dụng.

* Tên: ZZ0000ZZ

:URL: ZZ0000ZZ
      :Từ khóa: tin tức kernel mới nhất.
      :Mô tả: Tiêu đề đã nói lên tất cả. Có phần kernel cố định
        tóm tắt công việc của nhà phát triển, sửa lỗi, tính năng và phiên bản mới
        sản xuất trong tuần.

* Tên: ZZ0000ZZ

:Tác giả: Nhóm Linux-MM.
      :URL: ZZ0000ZZ
      :Từ khóa: quản lý bộ nhớ, Linux-MM, bản vá lỗi mm, TODO, tài liệu,
        danh sách gửi thư.
      :Mô tả: Trang web dành riêng cho việc phát triển Quản lý bộ nhớ Linux.
        Các bản vá liên quan đến bộ nhớ, HOWTO, liên kết, nhà phát triển mm... Đừng bỏ lỡ
        nếu bạn quan tâm đến việc phát triển quản lý bộ nhớ!

* Tên: ZZ0000ZZ

:URL: ZZ0000ZZ
      :Từ khóa: IRC, người mới, kênh, thắc mắc.
      :Mô tả: #kernelnewbies trên irc.oftc.net.
        #kernelnewbies là mạng IRC dành riêng cho 'người mới'
        hacker hạt nhân. Khán giả chủ yếu bao gồm những người
        tìm hiểu về kernel, làm việc trên các dự án kernel hoặc
        các hacker kernel chuyên nghiệp muốn giúp đỡ kernel ít dày dặn hơn
        mọi người.
        #kernelnewbies nằm trên Mạng OFTC IRC.
        Hãy thử irc.oftc.net làm máy chủ của bạn rồi /join #kernelnewbies.
        Trang web kernelnewbies cũng lưu trữ các bài viết, tài liệu, Câu hỏi thường gặp...

* Tên: ZZ0000ZZ

:URL: ZZ0000ZZ
      :URL: ZZ0001ZZ
      :Từ khóa: linux-kernel, archives, search.
      :Mô tả: Một số trình lưu trữ danh sách gửi thư nhân linux. Nếu
        bạn có cái nào tốt hơn/cái khác, xin vui lòng cho tôi biết.

* Tên: ZZ0000ZZ

:URL: ZZ0000ZZ
      :Từ khóa: linux, video, linux-foundation, youtube.
      :Mô tả: Quỹ Linux tải lên các bản ghi video của họ
        sự kiện hợp tác, hội nghị Linux bao gồm LinuxCon, và
        nghiên cứu và nội dung ban đầu khác liên quan đến Linux và phần mềm
        sự phát triển.

rỉ sét
----

* Tiêu đề: ZZ0000ZZ

:Tác giả: khác nhau
      :URL: ZZ0000ZZ
      :Ngày: phiên bản cuộn
      :Từ khóa: bảng thuật ngữ, thuật ngữ, linux-kernel, rỉ sét.
      :Mô tả: Từ trang web: "Rust for Linux là dự án bổ sung
        hỗ trợ ngôn ngữ Rust cho nhân Linux. Trang web này là
        nhằm mục đích là trung tâm của các liên kết, tài liệu và tài nguyên liên quan đến
        dự án".

* Tiêu đề: ZZ0000ZZ

:Tác giả: Cliff L. Biffle
      :URL: ZZ0000ZZ
      :Ngày: Truy cập ngày 11 tháng 9 năm 2024
      :Từ khóa: rỉ sét, blog.
      :Mô tả: Từ website: "LRtDW là một chuỗi các bài viết
        đưa các tính năng của Rust vào ngữ cảnh dành cho các lập trình viên C cấp thấp, những người
        có thể không có nền tảng CS chính thức - loại người
        hoạt động trên phần sụn, công cụ trò chơi, nhân hệ điều hành và những thứ tương tự.
        Về cơ bản thì mọi người đều thích tôi." Nó minh họa từng dòng một
        chuyển đổi từ C sang Rust.

* Tiêu đề: ZZ0000ZZ

:Tác giả: Steve Klabnik và Carol Nichols, với sự đóng góp của
        Cộng đồng rỉ sét
      :URL: ZZ0000ZZ
      :Ngày: Truy cập ngày 11 tháng 9 năm 2024
      :Từ khóa: rỉ sét, sách.
      :Mô tả: Từ trang web: "Cuốn sách này đề cập đầy đủ đến
        tiềm năng của Rust trong việc trao quyền cho người dùng. Đó là sự thân thiện và
        văn bản dễ tiếp cận nhằm mục đích giúp bạn thăng cấp không chỉ
        kiến thức về Rust mà còn cả khả năng tiếp cận và sự tự tin của bạn với tư cách là một
        lập trình viên nói chung. Vì vậy, hãy bắt đầu, sẵn sàng học hỏi—và chào đón
        tới cộng đồng Rust!".

* Tiêu đề: ZZ0000ZZ

:Tác giả: Ian Jackson
      :URL: ZZ0000ZZ
      :Ngày: Tháng 12 năm 2022
      :Từ khóa: rỉ sét, blog, dụng cụ.
      :Mô tả: Từ trang web: "Có rất nhiều hướng dẫn và
        giới thiệu về Rust. Cái này thì khác: nó là
        dành cho lập trình viên có kinh nghiệm đã biết nhiều
        ngôn ngữ lập trình khác. Tôi cố gắng đủ toàn diện để có thể
        điểm khởi đầu cho bất kỳ khu vực nào của Rust, nhưng tránh đi sâu vào
        nhiều chi tiết ngoại trừ những chỗ mọi thứ không như bạn mong đợi. Ngoài ra
        hướng dẫn này không hoàn toàn không có ý kiến, bao gồm cả
        khuyến nghị của thư viện (thùng), dụng cụ, v.v.".

* Tiêu đề: ZZ0000ZZ

:Tác giả: Amos Wenger
      :URL: ZZ0000ZZ
      :Ngày: Truy cập ngày 11 tháng 9 năm 2024
      :Từ khóa: rỉ sét, blog, tin tức.
      :Mô tả: Từ trang web: "Tôi làm các bài viết và video về cách
        máy tính làm việc. Nội dung của tôi có dạng dài, mang tính mô phạm và mang tính khám phá
        — và thường là cái cớ để dạy Rust!”.

* Tiêu đề: ZZ0000ZZ

:Tác giả: Nhóm Android tại Google
      :URL: ZZ0000ZZ
      :Ngày: Truy cập ngày 13 tháng 9 năm 2024
      :Từ khóa: rỉ sét, blog.
      :Mô tả: Từ trang web: "Khóa học bao gồm đầy đủ các lĩnh vực
        của Rust, từ cú pháp cơ bản đến các chủ đề nâng cao như khái quát và
        xử lý lỗi".

* Tiêu đề: ZZ0000ZZ

:Tác giả: Nhiều người đóng góp, chủ yếu là Jorge Aparermo
      :URL: ZZ0000ZZ
      :Ngày: Truy cập ngày 13 tháng 9 năm 2024
      :Từ khóa: rỉ sét, blog.
      :Mô tả: Từ trang web: "Cuốn sách giới thiệu về cách sử dụng
        Ngôn ngữ lập trình Rust trên các hệ thống nhúng "Bare Metal",
        chẳng hạn như Vi điều khiển".

* Tiêu đề: ZZ0000ZZ

:Tác giả: Phòng thí nghiệm Kỹ thuật Nhận thức tại Đại học Brown
      :URL: ZZ0000ZZ
      :Ngày: Truy cập ngày 22 tháng 9 năm 2024
      :Từ khóa: rỉ sét, blog.
      :Mô tả: Từ trang web: "Mục tiêu của thí nghiệm này là
        đánh giá và cải tiến nội dung Rust Book nhằm giúp đỡ mọi người
        học Rust hiệu quả hơn.".

* Tiêu đề: ZZ0000ZZ (podcast)

:Tác giả: Chris Krycho
      :URL: ZZ0000ZZ
      :Ngày: Truy cập ngày 22 tháng 9 năm 2024
      :Từ khóa: rỉ sét, podcast.
      :Mô tả: Từ trang web: "Đây là podcast về việc học
        ngôn ngữ lập trình Rust—từ đầu! Ngoại trừ điều này
        trang đích, tất cả nội dung trang đều được xây dựng bằng chính Rust
        công cụ tài liệu."

* Tiêu đề: ZZ0000ZZ (kho lưu trữ)

:Tác giả: Nhóm ngữ nghĩa vận hành
      :URL: ZZ0000ZZ
      :Ngày: Truy cập ngày 22 tháng 9 năm 2024
      :Từ khóa: rỉ sét, kho lưu trữ.
      :Mô tả: Từ README: "Nhóm opsem là đội kế thừa của
        nhóm làm việc về hướng dẫn mã không an toàn và chịu trách nhiệm về
        trả lời nhiều câu hỏi khó về ngữ nghĩa của
        Rust không an toàn".

* Tiêu đề: ZZ0000ZZ

:Tác giả: Alexis Beingessner
      :URL: ZZ0000ZZ
      :Ngày: 2015
      :Từ khóa: rỉ sét, thạc sĩ, luận án.
      :Mô tả: Luận án này tập trung vào hệ thống sở hữu của Rust, trong đó
        đảm bảo an toàn bộ nhớ bằng cách kiểm soát thao tác dữ liệu và
        suốt đời, đồng thời nêu bật những hạn chế của nó và so sánh nó
        với các hệ thống tương tự trong Cyclone và C++.

* Tên: ZZ0000ZZ

:Title: Hội nghị vi mô Rust
      :URL: ZZ0000ZZ
      :Tiêu đề: Rust cho Linux
      :URL: ZZ0001ZZ
      :Title: Hành trình của một kỹ sư kernel C bắt đầu dự án Rust driver
      :URL: ZZ0002ZZ
      :Title: Tạo bộ lập lịch nhân Linux chạy trong không gian người dùng
        sử dụng Rust
      :URL: ZZ0003ZZ
      :Title: openHCL: Paravisor dựa trên Linux và Rust
      :URL: ZZ0004ZZ
      :Từ khóa: rỉ sét, lpc, thuyết trình.
      :Mô tả: Một số bài nói chuyện của LPC liên quan đến Rust.

* Tên: ZZ0000ZZ

:URL: ZZ0000ZZ
      :Từ khóa: rỉ sét, podcast.
      :Mô tả: Một dự án cộng đồng nhằm tạo nội dung podcast cho
        ngôn ngữ lập trình Rust.

-------

Tài liệu này ban đầu được dựa trên:

ZZ0000ZZ

và được viết bởi Juan-Mariano de Goyeneche
