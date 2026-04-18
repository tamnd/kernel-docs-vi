.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/virt/kvm/review-checklist.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=============================================
Xem lại danh sách kiểm tra cho các bản vá kvm
=============================================

1. Bản vá phải tuân theo Documentation/process/coding-style.rst và
    Tài liệu/quy trình/gửi-patches.rst.

2. Các bản vá phải chống lại kvm.git master hoặc các nhánh tiếp theo.

3. Nếu bản vá giới thiệu hoặc sửa đổi không gian người dùng mới API:
    - API phải được ghi lại trong Documentation/virt/kvm/api.rst
    - API phải được phát hiện bằng KVM_CHECK_EXTENSION

4. Trạng thái mới phải bao gồm hỗ trợ lưu/khôi phục.

5. Các tính năng mới phải được tắt theo mặc định (không gian người dùng phải yêu cầu chúng một cách rõ ràng).
    Cải thiện hiệu suất có thể và nên được bật theo mặc định.

6. Các tính năng CPU mới sẽ được hiển thị qua KVM_GET_SUPPORTED_CPUID2,
    hoặc tương đương với kiến trúc không phải x86

7. Tính năng này phải có thể kiểm tra được (xem bên dưới).

8. Các thay đổi phải mang tính trung lập với nhà cung cấp khi có thể.  Thay đổi mã chung
    tốt hơn là sao chép các thay đổi đối với mã nhà cung cấp.

9. Tương tự, thích thay đổi mã độc lập Arch hơn là phụ thuộc Arch
    mã.

10. Giao diện người dùng/nhân và giao diện khách/máy chủ phải sạch 64-bit
    (tất cả các biến và kích thước được căn chỉnh tự nhiên trên 64-bit; sử dụng các loại cụ thể
    chỉ - u64 chứ không phải ulong).

11. Các tính năng mới hiển thị cho khách phải được ghi lại trong sổ tay phần cứng
    hoặc kèm theo tài liệu.

Kiểm tra mã KVM
-------------------

Tất cả các tính năng đều được đóng góp cho KVM và trong nhiều trường hợp, cả các bản sửa lỗi cũng phải được
đi kèm với một số loại thử nghiệm và/hoặc hỗ trợ đối với khách nguồn mở
và VMM.  KVM được bao phủ bởi nhiều bộ thử nghiệm:

ZZ0002ZZ
  Đây là các thử nghiệm cấp thấp cho phép thử nghiệm chi tiết các API hạt nhân.
  Điều này bao gồm các tình huống lỗi API, gọi API sau khi cụ thể
  hướng dẫn khách và kiểm tra nhiều cuộc gọi đến ZZ0000ZZ
  trong một thử nghiệm duy nhất.  Chúng được bao gồm trong cây hạt nhân tại
  ZZ0001ZZ.

ZZ0000ZZ
  Một nhóm khách nhỏ dùng thử CPU và các tính năng của thiết bị mô phỏng
  từ góc nhìn của một vị khách.  Chúng chạy dưới QEMU hoặc ZZ0001ZZ và
  nói chung không dành riêng cho KVM: chúng có thể chạy với bất kỳ máy gia tốc nào
  mà QEMU hỗ trợ hoặc thậm chí trên kim loại trần, giúp bạn có thể so sánh
  hành vi giữa các bộ ảo hóa và các họ bộ xử lý.

Bộ thử nghiệm chức năng
  Có nhiều bộ kiểm tra chức năng khác nhau, chẳng hạn như ZZ0000ZZ của QEMU
  bộ và ZZ0001ZZ.
  Những điều này thường liên quan đến việc chạy một hệ điều hành đầy đủ trong một máy ảo
  máy.

Phương pháp thử nghiệm tốt nhất phụ thuộc vào độ phức tạp của tính năng và
hoạt động. Dưới đây là một số ví dụ và hướng dẫn:

Hướng dẫn mới (không có đăng ký hoặc API mới)
  Các tính năng CPU tương ứng (nếu có) phải được cung cấp
  trong QEMU.  Nếu hướng dẫn yêu cầu hỗ trợ mô phỏng hoặc mã khác trong
  KVM, đáng để bổ sung phạm vi phủ sóng cho ZZ0000ZZ hoặc bản tự kiểm tra;
  cái sau có thể là lựa chọn tốt hơn nếu hướng dẫn liên quan đến API
  đã có phạm vi bảo hiểm selftest tốt.

Các tính năng phần cứng mới (đăng ký mới, không có API mới)
  Chúng nên được kiểm tra thông qua ZZ0000ZZ; điều này ít nhiều ngụ ý
  hỗ trợ chúng trong QEMU và/hoặc ZZ0001ZZ.  Trong một số trường hợp tự kiểm tra
  có thể được sử dụng thay thế, tương tự như trường hợp trước hoặc cụ thể là
  kiểm tra các trường hợp góc trong trạng thái lưu/khôi phục của khách.

Sửa lỗi và cải tiến hiệu suất
  Chúng thường không giới thiệu các API mới nhưng rất đáng để chia sẻ
  bất kỳ điểm chuẩn và bài kiểm tra nào sẽ xác nhận sự đóng góp của bạn,
  lý tưởng nhất là ở dạng kiểm tra hồi quy.  Kiểm tra và điểm chuẩn
  có thể được đưa vào ZZ0000ZZ hoặc tự kiểm tra, tùy thuộc vào
  về các chi tiết cụ thể của sự thay đổi của bạn.  Tự kiểm tra đặc biệt hữu ích cho
  kiểm tra hồi quy vì chúng được đưa trực tiếp vào cây của Linux.

Những thay đổi nội bộ quy mô lớn
  Mặc dù khó có thể đưa ra một chính sách duy nhất nhưng bạn nên đảm bảo rằng
  mã đã thay đổi được bao phủ bởi ZZ0000ZZ hoặc tự kiểm tra.
  Trong một số trường hợp, mã bị ảnh hưởng được chạy cho bất kỳ khách nào và chức năng
  xét nghiệm đủ.  Giải thích quá trình thử nghiệm của bạn trong thư xin việc,
  vì điều đó có thể giúp xác định các lỗ hổng trong bộ thử nghiệm hiện có.

API mới
  Điều quan trọng là phải chứng minh trường hợp sử dụng của bạn.  Điều này có thể đơn giản như
  giải thích rằng tính năng này đã được sử dụng trên kim loại trần hoặc có thể
  triển khai bằng chứng khái niệm trong không gian người dùng.  Cái sau không cần thiết
  nguồn mở, mặc dù điều đó tất nhiên là thích hợp hơn để thử nghiệm dễ dàng hơn.
  Việc tự kiểm tra nên kiểm tra các trường hợp góc của API và cũng phải bao gồm
  Hoạt động cơ bản của máy chủ và máy khách nếu VMM nguồn mở không sử dụng tính năng này.

Các tính năng lớn hơn, thường bao gồm máy chủ và khách
  Những điều này cần được hỗ trợ bởi khách Linux, với một số ngoại lệ hạn chế đối với
  Các tính năng Hyper-V có thể kiểm tra được trên máy khách Windows.  Nó mạnh mẽ
  đề xuất rằng tính năng này có thể sử dụng được với máy chủ nguồn mở VMM, chẳng hạn như
  ít nhất một trong số QEMU hoặc crosvm và chương trình cơ sở khách.  Tự kiểm tra nên
  kiểm tra ít nhất các trường hợp lỗi API.  Hoạt động của khách có thể được bao phủ bởi
  hoặc tự kiểm tra của ZZ0000ZZ (điều này đặc biệt quan trọng đối với
  các tính năng ảo hóa và chỉ dành cho Windows).  Bảo hiểm tự kiểm tra mạnh mẽ
  cũng có thể là sự thay thế cho việc triển khai trong VMM nguồn mở,
  nhưng điều này thường không được khuyến khích.

Làm theo những gợi ý ở trên để thử nghiệm trong các bài tự kiểm tra và
ZZ0000ZZ sẽ giúp người bảo trì xem xét dễ dàng hơn
và chấp nhận mã của bạn.  Trên thực tế, ngay cả trước khi bạn đóng góp những thay đổi của mình
ngược dòng, nó sẽ giúp bạn phát triển KVM dễ dàng hơn.

Tất nhiên, những người bảo trì KVM có quyền yêu cầu nhiều thử nghiệm hơn,
mặc dù đôi khi họ cũng có thể từ bỏ yêu cầu này.