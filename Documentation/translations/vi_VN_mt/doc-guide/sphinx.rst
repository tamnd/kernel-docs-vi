.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/doc-guide/sphinx.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. _sphinxdoc:

========================================
Sử dụng Sphinx cho tài liệu kernel
========================================

Nhân Linux sử dụng ZZ0004ZZ để tạo tài liệu đẹp từ
Các tệp ZZ0005ZZ trong ZZ0000ZZ. Để xây dựng tài liệu trong
Định dạng HTML hoặc PDF, sử dụng ZZ0001ZZ hoặc ZZ0002ZZ. Việc tạo ra
tài liệu được đặt trong ZZ0003ZZ.

.. _Sphinx: http://www.sphinx-doc.org/
.. _reStructuredText: http://docutils.sourceforge.net/rst.html

Các tập tin reStructuredText có thể chứa các lệnh bao gồm cấu trúc
nhận xét tài liệu hoặc nhận xét kernel-doc từ các tệp nguồn. Thông thường những điều này
được sử dụng để mô tả các chức năng, loại và thiết kế của mã. các
chú thích kernel-doc có một số cấu trúc và định dạng đặc biệt, nhưng hơn thế nữa
chúng cũng được coi là reStructuredText.

Cuối cùng, có hàng nghìn tệp tài liệu văn bản đơn giản nằm rải rác khắp nơi.
ZZ0000ZZ. Một số trong số này có thể sẽ được chuyển đổi thành reStructuredText
theo thời gian, nhưng phần lớn chúng sẽ vẫn ở dạng văn bản thuần túy.

.. _sphinx_install:

Cài đặt nhân sư
==============

Các đánh dấu ReST hiện được sử dụng bởi Tài liệu/tệp có nghĩa là
được xây dựng với ZZ0000ZZ phiên bản 3.4.3 trở lên.

Có một đoạn script kiểm tra các yêu cầu của Sphinx. Xin vui lòng xem
ZZ0000ZZ để biết thêm chi tiết.

Hầu hết các bản phân phối đều được vận chuyển bằng Sphinx, nhưng chuỗi công cụ của nó rất dễ vỡ,
và không có gì lạ khi nâng cấp nó hoặc một số gói Python khác
trên máy của bạn sẽ khiến quá trình xây dựng tài liệu bị hỏng.

Một cách để tránh điều đó là sử dụng phiên bản khác với phiên bản được giao
với các bản phân phối của bạn. Để làm được điều đó, nên cài đặt
Nhân sư bên trong môi trường ảo, sử dụng ZZ0000ZZ
hoặc ZZ0001ZZ, tùy thuộc vào cách phân phối của bạn đóng gói Python 3.

Tóm lại, nếu bạn muốn cài đặt phiên bản Sphinx mới nhất, bạn
nên làm::

$ virtualenv sphinx_latest
       $ . sphinx_latest/bin/kích hoạt
       (sphinx_latest) $ pip cài đặt -r Tài liệu/sphinx/requirements.txt

Sau khi chạy ZZ0000ZZ, lời nhắc sẽ thay đổi,
để cho biết rằng bạn đang sử dụng môi trường mới. Nếu bạn
mở shell mới bạn cần chạy lại lệnh này để vào lại lúc
môi trường ảo trước khi xây dựng tài liệu.

Đầu ra hình ảnh
------------

Hệ thống xây dựng tài liệu kernel chứa phần mở rộng
xử lý hình ảnh ở cả hai định dạng GraphViz và SVG (xem ZZ0000ZZ).

Để nó hoạt động, bạn cần cài đặt cả GraphViz và ImageMagick
gói. Nếu những gói đó chưa được cài đặt, hệ thống xây dựng sẽ
vẫn xây dựng tài liệu nhưng sẽ không bao gồm bất kỳ hình ảnh nào tại
đầu ra.

Bản dựng PDF và LaTeX
--------------------

Các bản dựng như vậy hiện chỉ được hỗ trợ với Sphinx phiên bản 2.4 trở lên.

Đối với đầu ra PDF và LaTeX, bạn cũng sẽ cần ZZ0000ZZ phiên bản 3.14159265.

Tùy thuộc vào bản phân phối, bạn cũng có thể cần cài đặt một loạt
Các gói ZZ0000ZZ cung cấp bộ chức năng tối thiểu
required for ZZ0001ZZ to work.

Biểu thức toán học trong HTML
------------------------

Một số trang ReST chứa các biểu thức toán học. Do cách hoạt động của Sphinx,
những biểu thức đó được viết bằng ký hiệu LaTeX.
Có hai tùy chọn để Sphinx hiển thị các biểu thức toán học ở đầu ra html.
Một là phần mở rộng có tên ZZ0000ZZ, dùng để chuyển đổi các biểu thức toán học thành
hình ảnh và nhúng chúng vào các trang html.
Cái còn lại là một tiện ích mở rộng có tên ZZ0001ZZ, ủy quyền kết xuất toán học
tới các trình duyệt web có khả năng JavaScript.
Cái trước là lựa chọn duy nhất cho tài liệu kernel trước 6.1 và nó
yêu cầu khá nhiều gói texlive bao gồm amsfonts và amsmath trong số
những người khác.

Kể từ khi phát hành kernel 6.1, các trang html có biểu thức toán học có thể được xây dựng
mà không cần cài đặt bất kỳ gói texlive nào. Xem ZZ0000ZZ để biết
thông tin thêm.

.. _imgmath: https://www.sphinx-doc.org/en/master/usage/extensions/math.html#module-sphinx.ext.imgmath
.. _mathjax: https://www.sphinx-doc.org/en/master/usage/extensions/math.html#module-sphinx.ext.mathjax

.. _sphinx-pre-install:

Kiểm tra sự phụ thuộc của Sphinx
--------------------------------

Có một tập lệnh tự động kiểm tra các phần phụ thuộc của Sphinx. Nếu nó có thể
nhận ra bản phân phối của bạn, nó cũng sẽ đưa ra gợi ý về quá trình cài đặt
tùy chọn dòng lệnh cho bản phân phối của bạn ::

$ ./tools/docs/sphinx-pre-install
	Kiểm tra xem các công cụ cần thiết cho Fedora phát hành 26 (Hai mươi sáu) có sẵn không
	Cảnh báo: tốt hơn nên cài đặt "texlive-luatex85".
	Bạn nên chạy:

cài đặt sudo dnf -y texlive-luatex85
		/usr/bin/virtualenv sphinx_2.4.4
		. sphinx_2.4.4/bin/kích hoạt
		cài đặt pip -r Tài liệu/sphinx/requirements.txt

Không thể xây dựng vì thiếu 1 phần phụ thuộc bắt buộc tại dòng ./tools/docs/sphinx-pre-install 468.

Theo mặc định, nó kiểm tra tất cả các yêu cầu cho cả html và PDF, bao gồm
các yêu cầu về hình ảnh, biểu thức toán học và bản dựng LaTeX và giả định
rằng môi trường Python ảo sẽ được sử dụng. Những thứ cần thiết cho html
việc xây dựng được coi là bắt buộc; những cái khác là tùy chọn.

Nó hỗ trợ hai tham số tùy chọn:

ZZ0000ZZ
	Vô hiệu hóa kiểm tra PDF;

ZZ0000ZZ
	Sử dụng bao bì hệ điều hành cho Sphinx thay vì môi trường ảo Python.

Cài đặt phiên bản tối thiểu Sphinx
---------------------------------

Khi thay đổi hệ thống xây dựng Sphinx, điều quan trọng là phải đảm bảo rằng
phiên bản tối thiểu vẫn sẽ được hỗ trợ. Ngày nay, nó là
việc thực hiện điều đó trên các bản phân phối hiện đại trở nên khó khăn hơn vì nó không
có thể cài đặt với Python 3.13 trở lên.

Thử nghiệm với phiên bản Python được hỗ trợ thấp nhất như được xác định tại
Documentation/process/changes.rst có thể được thực hiện bằng cách tạo
một venv với nó và cài đặt các yêu cầu tối thiểu với::

/usr/bin/python3.9 -m venv sphinx_min
	. sphinx_min/bin/kích hoạt
	cài đặt pip -r Tài liệu/sphinx/min_requirements.txt

Một bài kiểm tra toàn diện hơn có thể được thực hiện bằng cách sử dụng:

công cụ/tài liệu/test_doc_build.py

Tập lệnh như vậy tạo một venv Python cho mỗi phiên bản được hỗ trợ,
tùy chọn xây dựng tài liệu cho một loạt phiên bản Sphinx.


Xây dựng nhân sư
============

Cách thông thường để tạo tài liệu là chạy ZZ0000ZZ hoặc
ZZ0001ZZ. Ngoài ra còn có các định dạng khác: xem tài liệu
phần của ZZ0002ZZ. Tài liệu được tạo ra sẽ được đặt trong
thư mục con có định dạng cụ thể trong ZZ0003ZZ.

Để tạo tài liệu, Sphinx (ZZ0000ZZ) rõ ràng phải là
đã cài đặt.  Đối với đầu ra PDF, bạn cũng sẽ cần ZZ0001ZZ và ZZ0002ZZ
từ ImageMagick (ZZ0003ZZ [#ink]_ Tất cả những thứ này đều là
có sẵn rộng rãi và được đóng gói trong các bản phân phối.

Để chuyển các tùy chọn bổ sung cho Sphinx, bạn có thể sử dụng ZZ0000ZZ
biến. Ví dụ: sử dụng ZZ0001ZZ để biết thêm chi tiết
đầu ra.

Cũng có thể chuyển một tệp lớp phủ DOCS_CSS bổ sung để tùy chỉnh
bố cục html, bằng cách sử dụng biến tạo ZZ0000ZZ.

Theo mặc định, chủ đề "Thạch cao thạch cao" được sử dụng để xây dựng tài liệu HTML;
chủ đề này đi kèm với Sphinx và không cần phải cài đặt riêng.
Chủ đề Sphinx có thể được ghi đè bằng cách sử dụng biến tạo ZZ0000ZZ.

.. note::

   Some people might prefer to use the RTD theme for html output.
   Depending on the Sphinx version, it should be installed separately,
   with ``pip install sphinx_rtd_theme``.

Có một biến tạo ZZ0000ZZ khác, rất hữu ích khi kiểm tra
xây dựng một tập hợp con của tài liệu.  Ví dụ: bạn có thể xây dựng tài liệu
dưới ZZ0001ZZ bằng cách chạy
ZZ0002ZZ.
Phần tài liệu của ZZ0003ZZ sẽ hiển thị cho bạn danh sách
thư mục con bạn có thể chỉ định.

Để xóa tài liệu đã tạo, hãy chạy ZZ0000ZZ.

.. [#ink] Having ``inkscape(1)`` from Inkscape (https://inkscape.org)
	  as well would improve the quality of images embedded in PDF
	  documents, especially for kernel releases 5.18 and later.

Lựa chọn Trình kết xuất Toán học
-----------------------

Kể từ phiên bản kernel 6.1, mathjax hoạt động như một trình kết xuất toán học dự phòng cho
đầu ra html.\ [#sph1_8]_

Trình kết xuất toán học được chọn tùy thuộc vào các lệnh có sẵn như dưới đây:

.. table:: Math Renderer Choices for HTML

    ============= ================= ============
    Math renderer Required commands Image format
    ============= ================= ============
    imgmath       latex, dvipng     PNG (raster)
    mathjax
    ============= ================= ============

Lựa chọn có thể được ghi đè bằng cách đặt biến môi trường
ZZ0000ZZ như hình dưới đây:

.. table:: Effect of Setting ``SPHINX_IMGMATH``

    ====================== ========
    Setting                Renderer
    ====================== ========
    ``SPHINX_IMGMATH=yes`` imgmath
    ``SPHINX_IMGMATH=no``  mathjax
    ====================== ========

.. [#sph1_8] Fallback of math renderer requires Sphinx >=1.8.


Viết tài liệu
=====================

Việc thêm tài liệu mới có thể đơn giản như:

1. Thêm tệp ZZ0000ZZ mới ở đâu đó trong ZZ0001ZZ.
2. Tham khảo từ Sphinx main ZZ0003ZZ trong ZZ0002ZZ.

.. _TOC tree: http://www.sphinx-doc.org/en/stable/markup/toctree.html

Điều này thường đủ tốt cho các tài liệu đơn giản (như tài liệu bạn đang
đang đọc ngay bây giờ), nhưng đối với các tài liệu lớn hơn thì có thể nên tạo một
thư mục con (hoặc sử dụng thư mục hiện có). Ví dụ: hệ thống con đồ họa
tài liệu nằm dưới ZZ0000ZZ, được chia thành nhiều tệp ZZ0001ZZ,
và có một ZZ0002ZZ riêng biệt (với một ZZ0003ZZ riêng) được tham chiếu từ
chỉ số chính.

Xem tài liệu về ZZ0000ZZ và ZZ0001ZZ về những gì bạn có thể làm
với họ. Đặc biệt, Sphinx ZZ0002ZZ là một nơi tốt
để bắt đầu với reStructuredText. Ngoài ra còn có một số ZZ0003ZZ.

.. _reStructuredText Primer: http://www.sphinx-doc.org/en/stable/rest.html
.. _Sphinx specific markup constructs: http://www.sphinx-doc.org/en/stable/markup/index.html

Hướng dẫn cụ thể cho tài liệu kernel
------------------------------------------------

Dưới đây là một số hướng dẫn cụ thể cho tài liệu kernel:

* Vui lòng không quá nhiệt tình với đánh dấu reStructuredText. Giữ nó
  đơn giản. Đối với hầu hết các phần, tài liệu phải ở dạng văn bản thuần túy với
  vừa đủ nhất quán trong định dạng để có thể chuyển đổi thành
  các định dạng khác.

* Vui lòng giữ những thay đổi định dạng ở mức tối thiểu khi chuyển đổi
  tài liệu về reStructuredText.

* Đồng thời cập nhật nội dung, không chỉ định dạng, khi chuyển đổi
  tài liệu.

* Hãy tuân theo thứ tự tiêu đề trang sức sau:

1. ZZ0000ZZ có dòng chữ tiêu đề tài liệu::

================
       Tiêu đề tài liệu
       ================

2. ZZ0000ZZ cho các chương::

chương
       ========

3. ZZ0000ZZ cho các phần::

Phần
       -------

4. ZZ0000ZZ cho các tiểu mục::

tiểu mục
       ~~~~~~~~~~

Mặc dù RST không yêu cầu một lệnh cụ thể ("Thay vì áp đặt một lệnh cố định
  số lượng và thứ tự các kiểu trang trí tiêu đề phần thì thứ tự thi hành sẽ là
  thứ tự như đã gặp."), có mức độ cao hơn thì tổng thể giống nhau
  việc theo dõi các tài liệu trở nên dễ dàng hơn.

* Để chèn các khối văn bản có chiều rộng cố định (ví dụ về mã, trường hợp sử dụng
  ví dụ, v.v.), hãy sử dụng ZZ0000ZZ cho bất kỳ việc gì không thực sự mang lại lợi ích
  từ việc tô sáng cú pháp, đặc biệt là các đoạn ngắn. sử dụng
  ZZ0001ZZ cho các khối mã dài hơn có lợi
  từ việc làm nổi bật. Đối với một đoạn mã ngắn được nhúng trong văn bản, hãy sử dụng \ZZ0002ZZ.


miền C
------------

ZZ0000ZZ (tên c) phù hợp với tài liệu của C API. Ví dụ. một
nguyên mẫu hàm:

.. code-block:: rst

    .. c:function:: int ioctl( int fd, int request )

Miền C của kernel-doc có một số tính năng bổ sung. Ví dụ. bạn có thể
ZZ0002ZZ tên tham chiếu của hàm có tên phổ biến như ZZ0000ZZ hoặc
ZZ0001ZZ:

.. code-block:: rst

     .. c:function:: int ioctl( int fd, int request )
        :name: VIDIOC_LOG_STATUS

Tên func (ví dụ: ioctl) vẫn ở đầu ra nhưng tên ref đã thay đổi từ
ZZ0000ZZ đến ZZ0001ZZ. Mục nhập chỉ mục cho chức năng này cũng là
đổi thành ZZ0002ZZ.

Xin lưu ý rằng không cần sử dụng ZZ0000ZZ để tạo chéo
tham chiếu đến tài liệu chức năng.  Do một số phép thuật mở rộng Sphinx,
hệ thống xây dựng tài liệu sẽ tự động chuyển tham chiếu đến
ZZ0001ZZ thành tham chiếu chéo nếu mục nhập chỉ mục cho giá trị đã cho
tên chức năng tồn tại.  Nếu bạn thấy ZZ0002ZZ được sử dụng trong tài liệu kernel,
xin vui lòng loại bỏ nó.

Bàn
------

ReStructuredText cung cấp một số tùy chọn cho cú pháp bảng. Kiểu hạt nhân cho
các bảng thích hợp với cú pháp ZZ0001ZZ hoặc cú pháp ZZ0002ZZ. Xem
ZZ0000ZZ để biết thêm chi tiết.

.. _reStructuredText user reference for table syntax:
   https://docutils.sourceforge.io/docs/user/rst/quickref.html#tables

liệt kê các bảng
~~~~~~~~~~~

Các định dạng bảng danh sách có thể hữu ích cho các bảng không dễ đặt
ở định dạng nghệ thuật Sphinx ASCII thông thường.  Các định dạng này gần như
Tuy nhiên, người đọc các tài liệu văn bản đơn giản không thể hiểu được,
và nên tránh trong trường hợp không có lý do chính đáng cho việc họ
sử dụng.

ZZ0000ZZ là một danh sách hai giai đoạn tương tự như ZZ0001ZZ với
một số tính năng bổ sung:

* cột-span: với vai trò ZZ0000ZZ, một ô có thể được mở rộng thông qua
  cột bổ sung

* row-span: với vai trò ZZ0000ZZ, một ô có thể được mở rộng thông qua
  hàng bổ sung

* tự động kéo dài ô ngoài cùng bên phải của một hàng trong bảng lên trên các ô bị thiếu ở bên phải
  bên của hàng bảng đó.  Với Tùy chọn ZZ0000ZZ, hành vi này có thể
  đã thay đổi từ ZZ0001ZZ thành ZZ0002ZZ, tự động chèn (trống)
  các ô thay vì bao trùm ô cuối cùng.

tùy chọn:

* ZZ0000ZZ [int] số lượng hàng tiêu đề
* ZZ0001ZZ [int] số lượng cột còn sơ khai
* ZZ0002ZZ [[int] [int] ... ] chiều rộng của cột
* ZZ0003ZZ thay vì tự động kéo dài các ô bị thiếu, hãy chèn các ô bị thiếu

vai trò:

* ZZ0000ZZ [int] cột bổ sung (ZZ0002ZZ)
* ZZ0001ZZ [int] hàng bổ sung (ZZ0003ZZ)

Ví dụ dưới đây cho thấy cách sử dụng đánh dấu này.  Cấp độ đầu tiên của sân khấu
danh sách là ZZ0004ZZ. Trong ZZ0005ZZ chỉ cho phép một đánh dấu,
danh sách các ô trong ZZ0006ZZ này. Ngoại lệ là ZZ0007ZZ ( ZZ0002ZZ )
và ZZ0008ZZ (ví dụ: tham chiếu đến ZZ0003ZZ / ZZ0001ZZ).

.. code-block:: rst

   .. flat-table:: table title
      :widths: 2 1 1 3

      * - head col 1
        - head col 2
        - head col 3
        - head col 4

      * - row 1
        - field 1.1
        - field 1.2 with autospan

      * - row 2
        - field 2.1
        - :rspan:`1` :cspan:`1` field 2.2 - 3.3

      * .. _`last row`:

        - row 3

Kết xuất như:

   .. flat-table:: table title
      :widths: 2 1 1 3

      * - head col 1
        - head col 2
        - head col 3
        - head col 4

      * - row 1
        - field 1.1
        - field 1.2 with autospan

      * - row 2
        - field 2.1
        - :rspan:`1` :cspan:`1` field 2.2 - 3.3

      * .. _`last row`:

        - row 3

Tham khảo chéo
-----------------

Việc tham chiếu chéo từ trang tài liệu này sang trang tài liệu khác có thể được thực hiện đơn giản bằng cách
viết đường dẫn đến tệp tài liệu, không cần cú pháp đặc biệt. Con đường có thể
là tuyệt đối hoặc tương đối. Đối với đường dẫn tuyệt đối, hãy bắt đầu với
"Tài liệu/". Ví dụ: để tham khảo chéo tới trang này, tất cả
sau đây là các tùy chọn hợp lệ, tùy thuộc vào thư mục của tài liệu hiện tại (lưu ý
rằng phần mở rộng ZZ0000ZZ là bắt buộc)::

Xem Tài liệu/doc-guide/sphinx.rst. Điều này luôn hoạt động.
    Hãy xem sphinx.rst, nằm trong cùng thư mục này.
    Đọc ../sphinx.rst, là một thư mục ở trên.

Nếu bạn muốn liên kết có văn bản được hiển thị khác với văn bản của tài liệu
tiêu đề, bạn cần sử dụng vai trò ZZ0000ZZ của Sphinx. Ví dụ::

Xem ZZ0000ZZ.

Đối với hầu hết các trường hợp sử dụng, cách thứ nhất được ưa thích hơn vì nó sạch hơn và phù hợp hơn
cho những người đọc các tập tin nguồn. Nếu bạn gặp cách sử dụng ZZ0000ZZ
không thêm bất kỳ giá trị nào, vui lòng chuyển đổi nó thành tài liệu
con đường.

Để biết thông tin về tham chiếu chéo đến các hàm hoặc loại kernel-doc, hãy xem
Tài liệu/doc-guide/kernel-doc.rst.

Tham chiếu cam kết
~~~~~~~~~~~~~~~~~~~

Các tham chiếu đến các cam kết git được tự động siêu liên kết vì chúng
được viết bằng một trong các định dạng sau::

cam kết 72bf4f1767f0
    cam kết 72bf4f1767f0 ("net: không để trống skb trong hàng đợi ghi")

.. _sphinx_kfigure:

Số liệu & Hình ảnh
================

Nếu bạn muốn thêm hình ảnh, bạn nên sử dụng ZZ0001ZZ và
Chỉ thị ZZ0002ZZ. Ví dụ. để chèn một hình có khả năng mở rộng
định dạng hình ảnh, sử dụng SVG (ZZ0000ZZ)::

    .. kernel-figure::  svg_image.svg
       :alt:    simple SVG image

       SVG image example

.. _svg_image_example:

.. kernel-figure::  svg_image.svg
   :alt:    simple SVG image

   SVG image example

Lệnh hình ảnh (và hình ảnh) kernel hỗ trợ các tệp có định dạng ZZ0000ZZ, xem

*DOT: ZZ0000ZZ
* Đồ họa: ZZ0001ZZ

Một ví dụ đơn giản (ZZ0000ZZ)::

  .. kernel-figure::  hello.dot
     :alt:    hello world

     DOT's hello world example

.. _hello_dot_file:

.. kernel-figure::  hello.dot
   :alt:    hello world

   DOT's hello world example

Các đánh dấu ZZ0002ZZ nhúng (hoặc ngôn ngữ) như ZZ0001ZZ của Graphviz được cung cấp bởi
Chỉ thị ZZ0000ZZ.::

  .. kernel-render:: DOT
     :alt: foobar digraph
     :caption: Embedded **DOT** (Graphviz) code

     digraph foo {
      "bar" -> "baz";
     }

Việc này sẽ được hiển thị như thế nào tùy thuộc vào các công cụ được cài đặt. Nếu Graphviz là
được cài đặt, bạn sẽ thấy một hình ảnh vector. Nếu không, đánh dấu thô sẽ được chèn dưới dạng
ZZ0001ZZ (ZZ0000ZZ).

.. _hello_dot_render:

.. kernel-render:: DOT
   :alt: foobar digraph
   :caption: Embedded **DOT** (Graphviz) code

   digraph foo {
      "bar" -> "baz";
   }

Lệnh ZZ0004ZZ có tất cả các tùy chọn được biết đến từ lệnh ZZ0005ZZ,
cộng với tùy chọn ZZ0001ZZ.  Nếu ZZ0002ZZ có một giá trị thì nút ZZ0006ZZ là
chèn vào. Nếu không, nút ZZ0007ZZ sẽ được chèn vào. Cũng cần có ZZ0003ZZ nếu
bạn muốn tham khảo nó (ZZ0000ZZ).

ZZ0000ZZ nhúng::

  .. kernel-render:: SVG
     :caption: Embedded **SVG** markup
     :alt: so-nw-arrow

     <?xml version="1.0" encoding="UTF-8"?>
     <svg xmlns="http://www.w3.org/2000/svg" version="1.1" ...>
        ...
     </svg>

.. _hello_svg_render:

.. kernel-render:: SVG
   :caption: Embedded **SVG** markup
   :alt: so-nw-arrow

   <?xml version="1.0" encoding="UTF-8"?>
   <svg xmlns="http://www.w3.org/2000/svg"
     version="1.1" baseProfile="full" width="70px" height="40px" viewBox="0 0 700 400">
   <line x1="180" y1="370" x2="500" y2="50" stroke="black" stroke-width="15px"/>
   <polygon points="585 0 525 25 585 50" transform="rotate(135 525 25)"/>
   </svg>
