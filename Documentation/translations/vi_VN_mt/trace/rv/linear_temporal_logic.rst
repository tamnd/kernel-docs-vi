.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/trace/rv/linear_temporal_logic.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

Logic thời gian tuyến tính
=====================

Giới thiệu
------------

Giám sát xác minh thời gian chạy là một kỹ thuật xác minh để kiểm tra xem
kernel tuân theo một đặc điểm kỹ thuật. Nó làm như vậy bằng cách sử dụng các điểm theo dõi để theo dõi
dấu vết thực thi của kernel và xác minh rằng dấu vết thực thi thỏa mãn
đặc điểm kỹ thuật.

Ban đầu, đặc tả chỉ có thể được viết dưới dạng xác định
máy tự động (DA).  Tuy nhiên, trong khi cố gắng triển khai màn hình DA cho một số
thông số kỹ thuật phức tạp, máy tự động xác định được cho là không phù hợp vì
ngôn ngữ đặc tả. Máy tự động phức tạp, khó hiểu,
và dễ bị lỗi.

Do đó, màn hình RV dựa trên logic thời gian tuyến tính (LTL) được giới thiệu. Loại này
của màn hình sử dụng LTL làm thông số kỹ thuật thay vì DA. Đối với một số trường hợp, việc viết
đặc điểm kỹ thuật như LTL ngắn gọn và trực quan hơn.

Nhiều tài liệu giải thích chi tiết về LTL. Một cuốn sách là::

Christel Baier và Joost-Pieter Katoen: Nguyên tắc kiểm tra mô hình, MIT
  Báo chí, 2008.

Ngữ pháp
-------

Không giống như một số cú pháp hiện có, việc triển khai LTL của kernel dài dòng hơn.
Điều này được thúc đẩy bởi việc cho rằng những người đọc thông số kỹ thuật LTL
có thể không thành thạo về LTL.

Ngữ pháp:
    ltl ::= opd ZZ0000ZZ ltl binop ltl | mở nó ra

Toán hạng (opd):
    đúng, sai, tên do người dùng xác định bao gồm các ký tự viết hoa, chữ số,
    và gạch dưới.

Toán tử đơn nhất (unop):
    luôn luôn
    cuối cùng
    tiếp theo
    không

Toán tử nhị phân (binop):
    cho đến khi
    và
    hoặc
    ngụ ý
    tương đương

Ngữ pháp này không rõ ràng: độ ưu tiên của toán tử không được xác định. Dấu ngoặc đơn phải
được sử dụng.

Ví dụ logic thời gian tuyến tính
-----------------------------
.. code-block::

   RAIN imply (GO_OUTSIDE imply HAVE_UMBRELLA)

có nghĩa là: nếu trời mưa, đi ra ngoài có nghĩa là phải có ô.

.. code-block::

   RAIN imply (WET until not RAIN)

có nghĩa là: nếu trời mưa thì trời sẽ ướt cho đến khi tạnh mưa.

.. code-block::

   RAIN imply eventually not RAIN

có nghĩa là: nếu trời mưa thì cuối cùng mưa sẽ tạnh.

Các ví dụ trên chỉ đề cập đến phiên bản thời gian hiện tại. Đối với hạt nhân
xác minh, toán tử ZZ0000ZZ thường được sử dụng để xác định rằng
điều gì đó luôn đúng ở hiện tại và cho cả tương lai. Ví dụ::

luôn luôn (RAIN ngụ ý cuối cùng không phải RAIN)

có nghĩa là: ZZ0000ZZ mưa cuối cùng cũng tạnh.

Trong các ví dụ trên, ZZ0000ZZ, ZZ0001ZZ, ZZ0002ZZ và ZZ0003ZZ là
"các mệnh đề nguyên tử".

Giám sát tổng hợp
-----------------

Để tổng hợp LTL thành màn hình kernel, có thể sử dụng công cụ ZZ0000ZZ:
ZZ0001ZZ. Thông số kỹ thuật cần phải được cung cấp dưới dạng tệp,
và nó phải có phép gán "RULE = LTL". Ví dụ::

RULE = luôn luôn (ACQUIRE ngụ ý ((không phải KILLED và không phải CRASHED) cho đến RELEASE))

có nội dung: nếu ZZ0000ZZ thì ZZ0001ZZ phải xảy ra trước ZZ0002ZZ hoặc
ZZ0003ZZ.

LTL có thể được chia nhỏ bằng cách sử dụng các biểu thức phụ. Ở trên tương đương với:

   .. code-block::

    RULE = always (ACQUIRE imply (ALIVE until RELEASE))
    ALIVE = not KILLED and not CRASHED

Từ thông số kỹ thuật này, ZZ0000ZZ tạo ra triển khai C của Buchi
máy tự động - một máy trạng thái không xác định dùng để kiểm tra sự thỏa mãn của
LTL. Xem Documentation/trace/rv/monitor_synthesis.rst để biết chi tiết về cách sử dụng
ZZ0001ZZ.

Tài liệu tham khảo
----------

Một cuốn sách bao gồm việc kiểm tra mô hình và logic thời gian tuyến tính là::

Christel Baier và Joost-Pieter Katoen: Nguyên tắc kiểm tra mô hình, MIT
  Báo chí, 2008.

Để biết ví dụ về cách sử dụng logic thời gian tuyến tính trong kiểm thử phần mềm, hãy xem::

Ruijie Meng, Zhen Dong, Jialin Li, Ivan Beschastnikh và Abhik Roychoudhury.
  2022. Làm mờ hộp xám hướng dẫn logic thời gian tuyến tính theo thời gian tuyến tính. Trong Kỷ yếu tố tụng của
  Hội nghị quốc tế lần thứ 44 về Kỹ thuật phần mềm (ICSE '22).  Hiệp hội
  cho Máy tính, New York, NY, USA, 1343–1355.
  ZZ0000ZZ

Việc triển khai màn hình LTL của kernel dựa trên::

Gerth, R., Peled, D., Vardi, MY, Wolper, P. (1996). Đơn giản ngay lập tức
  Tự động xác minh logic thời gian tuyến tính. Ở: Dembiński, P., Średniawa,
  M. (eds) Đặc tả, kiểm tra và xác minh giao thức XV. PSTV 1995. IFIP
  Những tiến bộ trong công nghệ thông tin và truyền thông. Springer, Boston, MA.
  ZZ0000ZZ
