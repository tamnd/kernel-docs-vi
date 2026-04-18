.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/doc-guide/kernel-doc.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. title:: Kernel-doc comments

==============================
Viết bình luận kernel-doc
==============================

Các tệp nguồn nhân Linux có thể chứa tài liệu có cấu trúc
nhận xét ở định dạng kernel-doc để mô tả các chức năng, kiểu
và thiết kế mã. Việc cập nhật tài liệu dễ dàng hơn
khi nó được nhúng vào các tập tin nguồn.

.. note:: The kernel-doc format is deceptively similar to javadoc,
   gtk-doc or Doxygen, yet distinctively different, for historical
   reasons. The kernel source contains tens of thousands of kernel-doc
   comments. Please stick to the style described here.

.. note:: kernel-doc does not cover Rust code: please see
   Documentation/rust/general-information.rst instead.

Cấu trúc kernel-doc được trích xuất từ ​​các nhận xét và thích hợp
ZZ0000ZZ mô tả chức năng và loại với các điểm neo
được tạo ra từ chúng. Các mô tả được lọc cho kernel-doc đặc biệt
điểm nổi bật và tài liệu tham khảo chéo. Xem bên dưới để biết chi tiết.

.. _Sphinx C Domain: http://www.sphinx-doc.org/en/stable/domains.html

Mọi chức năng được xuất sang các mô-đun có thể tải bằng cách sử dụng
ZZ0000ZZ hoặc ZZ0001ZZ phải có kernel-doc
bình luận. Các chức năng và cấu trúc dữ liệu trong các tệp tiêu đề được dự định
được sử dụng bởi các mô-đun cũng phải có chú thích kernel-doc.

Cách tốt nhất là cung cấp tài liệu có định dạng kernel-doc
đối với các chức năng hiển thị bên ngoài đối với các tệp hạt nhân khác (không được đánh dấu
ZZ0000ZZ). Chúng tôi cũng khuyên bạn nên cung cấp định dạng kernel-doc
tài liệu về các thủ tục riêng tư (tệp ZZ0001ZZ), để đảm bảo tính nhất quán của
bố cục mã nguồn hạt nhân. Đây là mức độ ưu tiên thấp hơn và theo quyết định
của người duy trì tập tin nguồn kernel đó.

Cách định dạng nhận xét kernel-doc
----------------------------------

Dấu nhận xét mở đầu ZZ0000ZZ được sử dụng cho nhận xét kernel-doc. các
Công cụ ZZ0001ZZ sẽ trích xuất những bình luận được đánh dấu theo cách này. Phần còn lại của
nhận xét được định dạng giống như nhận xét nhiều dòng thông thường có một cột
dấu hoa thị ở phía bên trái, đóng lại bằng ZZ0002ZZ trên một dòng.

Hàm và kiểu chú thích kernel-doc phải được đặt ngay trước
the function or type being described in order to maximise the chance
rằng ai đó thay đổi mã cũng sẽ thay đổi tài liệu. các
tổng quan các nhận xét kernel-doc có thể được đặt ở bất kỳ đâu ở phần thụt đầu dòng trên cùng
cấp độ.

Chạy công cụ ZZ0000ZZ với mức độ chi tiết tăng lên và không có
việc tạo đầu ra có thể được sử dụng để xác minh định dạng đúng của
nhận xét tài liệu. Ví dụ::

công cụ/docs/kernel-doc -v -none driver/foo/bar.c

Định dạng tài liệu của các tệp ZZ0000ZZ cũng được xác minh bởi bản dựng kernel
khi được yêu cầu thực hiện kiểm tra gcc bổ sung::

làm cho W=n

Tuy nhiên, lệnh trên không xác minh các tệp tiêu đề. Những điều này nên được kiểm tra
riêng bằng cách sử dụng ZZ0000ZZ.

Tài liệu chức năng
----------------------

Định dạng chung của một hàm và nhận xét kernel-doc macro giống như hàm là::

/**
   * function_name() - Mô tả ngắn gọn về hàm.
   * @arg1: Mô tả đối số đầu tiên.
   * @arg2: Mô tả đối số thứ hai.
   * Người ta có thể cung cấp nhiều mô tả dòng
   * cho các đối số.
   *
   * Mô tả dài hơn, thảo luận nhiều hơn về hàm function_name()
   * có thể hữu ích cho những người sử dụng hoặc sửa đổi nó. Bắt đầu bằng một
   * dòng nhận xét trống và có thể bao gồm thêm dòng trống được nhúng
   * dòng bình luận.
   *
   * Phần mô tả dài hơn có thể có nhiều đoạn văn.
   *
   * Ngữ cảnh: Mô tả liệu chức năng có thể ngủ hay không, nó cần những khóa nào,
   *          releases, or expects to be held. Nó có thể mở rộng trên nhiều
   * dòng.
   * Return: Mô tả giá trị trả về của function_name.
   *
   * Phần mô tả giá trị trả về cũng có thể có nhiều đoạn văn và nên
   * được đặt ở cuối khối bình luận.
   */

Mô tả ngắn gọn sau tên hàm có thể trải dài trên nhiều dòng và
kết thúc bằng một mô tả đối số, một dòng nhận xét trống hoặc kết thúc
khối bình luận.

Thông số chức năng
~~~~~~~~~~~~~~~~~~~

Mỗi đối số của hàm phải được mô tả theo thứ tự, ngay sau
mô tả chức năng ngắn gọn.  Không để lại một dòng trống giữa
mô tả hàm và các đối số, cũng như giữa các đối số.

Mỗi mô tả ZZ0000ZZ có thể trải dài trên nhiều dòng.

.. note::

   If the ``@argument`` description has multiple lines, the continuation
   of the description should start at the same column as the previous line::

      * @argument: some long description
      *            that continues on next lines

   or::

      * @argument:
      *		some long description
      *		that continues on next lines

Nếu một hàm có số lượng đối số thay đổi thì phần mô tả của nó phải
được viết bằng ký hiệu kernel-doc là::

* @...: Sự miêu tả

Bối cảnh chức năng
~~~~~~~~~~~~~~~~~~

Bối cảnh trong đó một hàm có thể được gọi nên được mô tả trong một
phần có tên ZZ0000ZZ. Điều này nên bao gồm liệu chức năng
ngủ hoặc có thể được gọi từ ngữ cảnh ngắt, cũng như khóa nào
nó nhận, giải phóng và mong đợi được giữ bởi người gọi nó.

Ví dụ::

* Bối cảnh: Bất kỳ bối cảnh nào.
  * Bối cảnh: Bất kỳ bối cảnh nào. Lấy và mở khóa RCU.
  * Bối cảnh: Bất kỳ bối cảnh nào. Mong đợi <lock> sẽ được giữ bởi người gọi.
  * Bối cảnh: Bối cảnh quá trình. Có thể ngủ nếu cờ @gfp cho phép.
  * Bối cảnh: Bối cảnh quá trình. Nhận và phát hành <mutex>.
  * Ngữ cảnh: Softirq hoặc ngữ cảnh xử lý. Lấy và nhả <lock>, BH-safe.
  * Ngữ cảnh: Ngữ cảnh ngắt.

Giá trị trả về
~~~~~~~~~~~~~~

Giá trị trả về, nếu có, phải được mô tả trong phần dành riêng
có tên là ZZ0000ZZ (hoặc ZZ0001ZZ).

.. note::

  #) The multi-line descriptive text you provide does *not* recognize
     line breaks, so if you try to format some text nicely, as in::

	* Return:
	* %0 - OK
	* %-EINVAL - invalid argument
	* %-ENOMEM - out of memory

     this will all run together and produce::

	Return: 0 - OK -EINVAL - invalid argument -ENOMEM - out of memory

     So, in order to produce the desired line breaks, you need to use a
     ReST list, e. g.::

      * Return:
      * * %0		- OK to runtime suspend the device
      * * %-EBUSY	- Device should not be runtime suspended

  #) If the descriptive text you provide has lines that begin with
     some phrase followed by a colon, each of those phrases will be taken
     as a new section heading, which probably won't produce the desired
     effect.

Tài liệu về cấu trúc, liên kết và liệt kê
-----------------------------------------------

Định dạng chung của kernel-doc ZZ0000ZZ, ZZ0001ZZ và ZZ0002ZZ
nhận xét là::

/**
   *struct struct_name - Mô tả ngắn gọn.
   * @member1: Mô tả về member1.
   * @member2: Mô tả về member2.
   * Người ta có thể cung cấp nhiều mô tả dòng
   * cho các thành viên.
   *
   * Mô tả cấu trúc.
   */

Bạn có thể thay thế ZZ0000ZZ trong ví dụ trên bằng ZZ0001ZZ hoặc
ZZ0002ZZ để mô tả các hiệp hội hoặc enum. ZZ0003ZZ được hiểu là ZZ0004ZZ
và tên thành viên ZZ0005ZZ cũng như các bảng liệt kê trong ZZ0006ZZ.

Mô tả ngắn gọn sau tên cấu trúc có thể trải rộng trên nhiều
dòng và kết thúc bằng mô tả thành viên, dòng nhận xét trống hoặc
cuối khối bình luận.

Thành viên
~~~~~~~~~~

Các thành viên của structs, unions và enums phải được ghi lại theo cùng một cách
như các tham số chức năng; họ ngay lập tức thành công với mô tả ngắn gọn
và có thể là nhiều dòng.

Bên trong mô tả ZZ0000ZZ hoặc ZZ0001ZZ, bạn có thể sử dụng ZZ0002ZZ và
Thẻ bình luận ZZ0003ZZ. Các trường cấu trúc bên trong ZZ0004ZZ
khu vực không được liệt kê trong tài liệu đầu ra được tạo ra.

Các thẻ ZZ0000ZZ và ZZ0001ZZ phải bắt đầu ngay sau
Điểm đánh dấu nhận xét ZZ0002ZZ. Chúng có thể tùy ý bao gồm các nhận xét giữa
ZZ0003ZZ và điểm đánh dấu ZZ0004ZZ kết thúc.

Khi ZZ0000ZZ được sử dụng trên các cấu trúc lồng nhau, nó chỉ truyền vào bên trong
cấu trúc/công đoàn.


Ví dụ::

/**
   * struct my_struct - mô tả ngắn
   * @a: thành viên đầu tiên
   * @b: thành viên thứ hai
   * @d: thành viên thứ tư
   *
   * Mô tả dài hơn
   */
  cấu trúc my_struct {
      int một;
      int b;
  /* riêng tư: chỉ sử dụng nội bộ */
      int c;
  /* public: cái tiếp theo là public */
      int d;
  };

Cấu trúc/công đoàn lồng nhau
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Có thể ghi lại các cấu trúc và liên kết lồng nhau, như ::

/**
       * struct Nested_foobar - một cấu trúc với các liên kết và cấu trúc lồng nhau
       * @memb1: thành viên đầu tiên của liên minh ẩn danh/cấu trúc ẩn danh
       * @memb2: thành viên thứ hai của liên minh ẩn danh/cấu trúc ẩn danh
       * @memb3: thành viên thứ ba của liên minh ẩn danh/cấu trúc ẩn danh
       * @memb4: thành viên thứ tư của liên minh ẩn danh/cấu trúc ẩn danh
       * @bar: liên minh không ẩn danh
       * @bar.st1: struct st1 bên trong @bar
       * @bar.st2: struct st2 bên trong @bar
       * @bar.st1.memb1: thành viên đầu tiên của struct st1 trên thanh công đoàn
       * @bar.st1.memb2: thành viên thứ hai của struct st1 trên thanh công đoàn
       * @bar.st2.memb1: thành viên đầu tiên của struct st2 trên thanh công đoàn
       * @bar.st2.memb2: thành viên thứ hai của struct st2 trên thanh công đoàn
       */
      cấu trúc lồng_foobar {
        /* Liên kết ẩn danh/struct*/
        công đoàn {
          cấu trúc {
            int memb1;
            /* riêng tư: ẩn memb2 khỏi tài liệu */
            int memb2;
          };
          /* Mọi thứ ở đây lại được công khai, vì phạm vi riêng tư đã hoàn tất */
          cấu trúc {
            void *memb3;
            int memb4;
          };
        };
        công đoàn {
          cấu trúc {
            int memb1;
            int memb2;
          } st1;
          cấu trúc {
            vô hiệu *memb1;
            int memb2;
          } st2;
        } bar;
      };

.. note::

   #) When documenting nested structs or unions, if the ``struct``/``union``
      ``foo`` is named, the member ``bar`` inside it should be documented as
      ``@foo.bar:``
   #) When the nested ``struct``/``union`` is anonymous, the member ``bar`` in
      it should be documented as ``@bar:``

Nhận xét tài liệu thành viên nội tuyến
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Các thành viên cấu trúc cũng có thể được ghi lại nội tuyến trong định nghĩa.
Có hai kiểu, nhận xét một dòng trong đó cả phần mở đầu ZZ0000ZZ và
đóng ZZ0001ZZ nằm trên cùng một dòng và các nhận xét nhiều dòng trong đó mỗi dòng nằm
trên một dòng của riêng họ, giống như tất cả các nhận xét kernel-doc khác ::

/**
   *struct foo - Mô tả ngắn gọn.
   * @foo: Thành viên Foo.
   */
  cấu trúc foo {
        int foo;
        /**
         * @bar: Thành viên của Bar.
         */
        thanh int;
        /**
         * @baz: Thành viên Baz.
         *
         * Ở đây, phần mô tả thành viên có thể chứa nhiều đoạn văn.
         */
        int baz;
        công đoàn {
                /** @foobar: Mô tả một dòng. */
                int foobar;
        };
        /** @bar2: Mô tả cho struct @bar2 bên trong @foo */
        cấu trúc {
                /**
                 * @bar2.barbar: Mô tả cho @barbar bên trong @foo.bar2
                 */
                int barbar;
        } bar2;
  };

Tài liệu Typedef
---------------------

Định dạng chung của nhận xét kernel-doc ZZ0000ZZ là::

/**
   * typedef type_name - Mô tả ngắn gọn.
   *
   * Mô tả loại.
   */

Typedefs với các nguyên mẫu hàm cũng có thể được ghi lại ::

/**
   * typedef type_name - Mô tả ngắn gọn.
   * @arg1: mô tả về arg1
   * @arg2: mô tả về arg2
   *
   * Mô tả loại.
   *
   * Ngữ cảnh: Khóa ngữ cảnh.
   * Trả về: Ý nghĩa của giá trị trả về.
   */
   khoảng trống typedef (*type_name)(struct v4l2_ctrl *arg1, khoảng trống *arg2);

Tài liệu biến
-----------------------

Định dạng chung của nhận xét biến kernel-doc là::

/**
   *var var_name - Mô tả ngắn gọn.
   *
   * Mô tả biến var_name.
   */
   int bên ngoài var_name;

Tài liệu macro giống đối tượng
-------------------------------

Macro giống đối tượng khác với macro giống chức năng. Họ là
được phân biệt bằng việc tên macro có ngay sau đó là một
dấu ngoặc đơn bên trái ('(') cho các macro giống chức năng hoặc không có macro theo sau
cho các macro giống như đối tượng.

Các macro giống chức năng được ZZ0000ZZ xử lý giống như các chức năng.
Họ có thể có một danh sách tham số. Các macro giống đối tượng không có
danh sách tham số.

Định dạng chung của nhận xét kernel-doc macro giống như đối tượng là::

/**
   * định nghĩa object_name - Mô tả ngắn gọn.
   *
   * Mô tả đối tượng.
   */

Ví dụ::

/**
   * xác định MAX_ERRNO - giá trị lỗi tối đa được hỗ trợ
   *
   * Con trỏ hạt nhân có thông tin dư thừa nên chúng ta có thể sử dụng
   * lược đồ trong đó chúng ta có thể trả về mã lỗi hoặc mã thông thường
   * con trỏ có cùng giá trị trả về.
   */
  #define MAX_ERRNO 4095

Ví dụ::

/**
   * xác định DRM_GEM_VRAM_PLANE_HELPER_FUNCS - \
   * Khởi tạo struct drm_plane_helper_funcs để xử lý VRAM
   *
   * Macro này khởi tạo struct drm_plane_helper_funcs để sử dụng
   * chức năng trợ giúp tương ứng.
   */
  #define DRM_GEM_VRAM_PLANE_HELPER_FUNCS \
	.prepare_fb = drm_gem_vram_plane_helper_prepare_fb, \
	.cleanup_fb = drm_gem_vram_plane_helper_cleanup_fb


Điểm nổi bật và tài liệu tham khảo chéo
---------------------------------------

Các mẫu đặc biệt sau đây được nhận dạng trong nhận xét kernel-doc
văn bản mô tả và được chuyển đổi thành đánh dấu reStructuredText và tham chiếu ZZ0000ZZ thích hợp.

.. attention:: The below are **only** recognized within kernel-doc comments,
	       **not** within normal reStructuredText documents.

ZZ0000ZZ
  Tham khảo chức năng.

ZZ0000ZZ
  Tên của một tham số chức năng. (Không tham khảo chéo, chỉ định dạng.)

ZZ0000ZZ
  Tên của một hằng số. (Không tham khảo chéo, chỉ định dạng.)

Ví dụ::

%0 %NULL %-1 %-EFAULT %-EINVAL %-ENOMEM

`ZZ0002ZZ`.

Hữu ích nếu bạn cần sử dụng các ký tự đặc biệt mà lẽ ra sẽ có một số ký tự đặc biệt
  nghĩa là bằng tập lệnh kernel-doc hoặc bằng reStructuredText.

Điều này đặc biệt hữu ích nếu bạn cần sử dụng những thứ như ZZ0000ZZ bên trong
  một mô tả chức năng.

ZZ0000ZZ
  Tên của một biến môi trường. (Không tham khảo chéo, chỉ định dạng.)

ZZ0000ZZ
  Tham khảo cấu trúc.

ZZ0000ZZ
  Tham khảo enum.

ZZ0000ZZ
  Tham chiếu Typedef.

ZZ0000ZZ hoặc ZZ0001ZZ
  Tham khảo thành viên ZZ0002ZZ hoặc ZZ0003ZZ. Việc tham khảo chéo sẽ dành cho
  Định nghĩa ZZ0004ZZ hoặc ZZ0005ZZ, không phải trực tiếp thành viên.

ZZ0000ZZ
  Một tham chiếu kiểu chung. Ưu tiên sử dụng tài liệu tham khảo đầy đủ được mô tả ở trên
  thay vào đó. Điều này chủ yếu là dành cho ý kiến ​​​​di sản.

Tham chiếu chéo từ reStructuredText
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Không cần thêm cú pháp để tham chiếu chéo các hàm và kiểu
được xác định trong nhận xét kernel-doc từ tài liệu reStructuredText.
Chỉ cần kết thúc tên hàm bằng ZZ0000ZZ và viết ZZ0001ZZ, ZZ0002ZZ, ZZ0003ZZ
hoặc ZZ0004ZZ trước các loại.
Ví dụ::

Xem foo().
  Xem cấu trúc foo.
  Xem thanh công đoàn.
  Xem enum baz.
  Xem typedef nhé.

Tuy nhiên, nếu bạn muốn văn bản tùy chỉnh trong liên kết tham chiếu chéo, điều đó có thể được thực hiện
thông qua cú pháp sau::

Xem ZZ0000ZZ.
  Xem ZZ0001ZZ.

Để biết thêm chi tiết, vui lòng tham khảo tài liệu ZZ0000ZZ.

.. note::
   Variables aren't automatically cross referenced. For those, you need to
   explicitly add a C domain cross-reference.

Tổng quan tài liệu nhận xét
-------------------------------

Để tạo điều kiện thuận lợi cho việc có mã nguồn và nhận xét gần nhau, bạn có thể bao gồm
các khối tài liệu kernel-doc là các nhận xét dạng tự do thay vì
kernel-doc cho các hàm, cấu trúc, liên kết, enum, typedef hoặc biến.
Điều này có thể được sử dụng cho những mục đích như lý thuyết hoạt động của bộ điều khiển hoặc
mã thư viện chẳng hạn.

Điều này được thực hiện bằng cách sử dụng từ khóa phần ZZ0000ZZ với tiêu đề phần.

Định dạng chung của nhận xét tài liệu tổng quan hoặc cấp cao là::

/**
   * DOC: Lý thuyết hoạt động
   *
   * Whizbang foobar là một thứ gizmo ngớ ngẩn. Nó có thể làm bất cứ điều gì bạn
   * muốn nó làm, bất cứ lúc nào. Nó đọc được suy nghĩ của bạn. Đây là cách nó hoạt động.
   *
   * thanh foo
   *
   * Hạn chế duy nhất của gizmo này là đôi khi có thể làm hỏng
   * phần cứng, phần mềm hoặc (các) chủ đề của nó.
   */

Tiêu đề theo sau ZZ0000ZZ đóng vai trò như một tiêu đề trong tệp nguồn, nhưng cũng
như một mã định danh để trích xuất nhận xét tài liệu. Vì vậy, tiêu đề phải
là duy nhất trong tập tin.

================================
Bao gồm các bình luận kernel-doc
================================

Các nhận xét tài liệu có thể được bao gồm trong bất kỳ văn bản reStructuredText nào
tài liệu sử dụng phần mở rộng chỉ thị Sphinx kernel-doc chuyên dụng.

Lệnh kernel-doc có định dạng::

  .. kernel-doc:: source
     :option:

ZZ0000ZZ là đường dẫn đến tệp nguồn, liên quan đến nguồn kernel
cây. Các tùy chọn chỉ thị sau được hỗ trợ:

xuất khẩu: ZZ0002ZZ
  Bao gồm tài liệu cho tất cả các chức năng trong ZZ0003ZZ đã được xuất
  sử dụng ZZ0000ZZ hoặc ZZ0001ZZ trong ZZ0004ZZ hoặc trong bất kỳ
  của các tệp được chỉ định bởi ZZ0005ZZ.

ZZ0002ZZ rất hữu ích khi các nhận xét kernel-doc đã được đặt
  trong các tệp tiêu đề, trong khi ZZ0000ZZ và ZZ0001ZZ nằm bên cạnh
  các định nghĩa hàm.

Ví dụ::

    .. kernel-doc:: lib/bitmap.c
       :export:

    .. kernel-doc:: include/net/mac80211.h
       :export: net/mac80211/*.c

nội bộ: ZZ0003ZZ
  Bao gồm tài liệu cho tất cả các chức năng và loại trong ZZ0004ZZ có
  ZZ0002ZZ đã được xuất bằng ZZ0000ZZ hoặc ZZ0001ZZ
  trong ZZ0005ZZ hoặc trong bất kỳ tệp nào được chỉ định bởi ZZ0006ZZ.

Ví dụ::

    .. kernel-doc:: drivers/gpu/drm/i915/intel_audio.c
       :internal:

mã định danh: ZZ0005ZZ
  Bao gồm tài liệu cho từng ZZ0006ZZ và ZZ0007ZZ trong ZZ0008ZZ.
  Nếu không chỉ định ZZ0009ZZ, tài liệu cho tất cả các chức năng
  và các loại trong ZZ0010ZZ sẽ được bao gồm.
  ZZ0011ZZ có thể là ZZ0000ZZ, ZZ0001ZZ, ZZ0002ZZ, ZZ0003ZZ hoặc ZZ0004ZZ
  định danh.

Ví dụ::

    .. kernel-doc:: lib/bitmap.c
       :identifiers: bitmap_parselist bitmap_parselist_user

    .. kernel-doc:: lib/idr.c
       :identifiers:

không có số nhận dạng: ZZ0000ZZ
  Loại trừ tài liệu cho từng ZZ0001ZZ và ZZ0002ZZ trong ZZ0003ZZ.

Ví dụ::

    .. kernel-doc:: lib/bitmap.c
       :no-identifiers: bitmap_parselist

chức năng: ZZ0000ZZ
  Đây là bí danh của lệnh 'định danh' và không được dùng nữa.

tài liệu: ZZ0001ZZ
  Bao gồm tài liệu cho đoạn ZZ0000ZZ được xác định bởi ZZ0002ZZ trong
  ZZ0003ZZ. Khoảng trắng được phép trong ZZ0004ZZ; không trích dẫn ZZ0005ZZ. ZZ0006ZZ
  chỉ được sử dụng làm định danh cho đoạn văn và không được bao gồm trong
  đầu ra. Vui lòng đảm bảo có tiêu đề phù hợp trong phần đính kèm
  tài liệu reStructuredText.

Ví dụ::

    .. kernel-doc:: drivers/gpu/drm/i915/intel_audio.c
       :doc: High Definition Audio over HDMI and Display Port

Không có tùy chọn, lệnh kernel-doc bao gồm tất cả các nhận xét tài liệu
từ tập tin nguồn.

Phần mở rộng kernel-doc được bao gồm trong cây nguồn kernel, tại
ZZ0000ZZ. Trong nội bộ, nó sử dụng
Tập lệnh ZZ0001ZZ để trích xuất các nhận xét tài liệu từ
nguồn.

.. _kernel_doc:

Cách sử dụng kernel-doc để tạo trang man
-------------------------------------------

Để tạo trang man cho tất cả các tệp có chứa đánh dấu kernel-doc, hãy chạy::

$ làm mandocs

Hoặc gọi trực tiếp đến ZZ0000ZZ::

$ ./tools/docs/sphinx-build-wrapper mandocs

Đầu ra sẽ ở thư mục ZZ0000ZZ bên trong thư mục đầu ra
(theo mặc định: ZZ0001ZZ).

Tùy chọn, có thể tạo một phần các trang man bằng cách
sử dụng SPHINXDIRS:

$ make SPHINXDIRS=driver-api/media mandocs

.. note::

   When SPHINXDIRS={subdir} is used, it will only generate man pages for
   the files explicitly inside a ``Documentation/{subdir}/.../*.rst`` file.
