.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/arch/arm64/gcs.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

====================================================
Hỗ trợ ngăn xếp điều khiển được bảo vệ cho AArch64 Linux
===============================================

Tài liệu này phác thảo ngắn gọn giao diện được cung cấp cho không gian người dùng bởi Linux trong
để hỗ trợ sử dụng tính năng Ngăn xếp điều khiển được bảo vệ ARM (GCS).

Đây chỉ là bản tóm tắt các tính năng và vấn đề quan trọng nhất chứ không phải
nhằm mục đích đầy đủ.



1. Chung
-----------

* GCS là một tính năng kiến trúc nhằm cung cấp khả năng bảo vệ tốt hơn
  chống lại các cuộc tấn công lập trình định hướng trở lại (ROP) và để đơn giản hóa
  triển khai các tính năng cần thu thập dấu vết ngăn xếp như
  hồ sơ.

* Khi GCS được bật, ngăn xếp điều khiển được bảo vệ riêng biệt được duy trì bởi
  PE chỉ có thể ghi thông qua các hoạt động GCS cụ thể.  Cái này
  chỉ lưu trữ ngăn xếp cuộc gọi khi lệnh gọi thủ tục được thực hiện
  đã thực hiện, PC hiện tại được đẩy lên GCS và trên RET,
  địa chỉ trong LR được xác minh dựa trên địa chỉ trên đầu GCS.

* Khi hoạt động, con trỏ GCS hiện tại được lưu trong thanh ghi hệ thống
  GCSPR_EL0.  Điều này có thể được đọc bởi không gian người dùng nhưng chỉ có thể được cập nhật
  thông qua các hướng dẫn GCS cụ thể.

* Kiến trúc cung cấp hướng dẫn chuyển đổi giữa các mạng được bảo vệ
  kiểm soát ngăn xếp bằng các kiểm tra để đảm bảo rằng ngăn xếp mới hợp lệ
  mục tiêu chuyển đổi.

* Chức năng của GCS tương tự như chức năng được cung cấp bởi x86 Shadow
  Tính năng ngăn xếp, do chia sẻ giao diện không gian người dùng mà ABI đề cập đến
  ngăn xếp bóng thay vì GCS.

* Hỗ trợ cho GCS được báo cáo tới không gian người dùng thông qua HWCAP_GCS trong vectơ phụ trợ
  Mục nhập AT_HWCAP.

* GCS được bật trên mỗi luồng.  Mặc dù có hỗ trợ tắt GCS
  trong thời gian chạy, việc này phải được thực hiện hết sức cẩn thận.

* Lỗi truy cập bộ nhớ GCS được báo cáo là lỗi truy cập bộ nhớ thông thường.

* Các lỗi cụ thể của GCS (những lỗi được báo cáo với EC 0x2d) sẽ được báo cáo dưới dạng
  SIGSEGV có si_code là SEGV_CPERR (lỗi bảo vệ điều khiển).

* GCS chỉ được hỗ trợ cho AArch64.

* Trên các hệ thống có hỗ trợ GCS, GCSPR_EL0 luôn có thể đọc được bởi EL0
  bất kể cấu hình GCS cho luồng.

* Kiến trúc hỗ trợ kích hoạt GCS mà không cần xác minh các giá trị trả về
  trong LR khớp với những gì trong GCS, LR sẽ bị bỏ qua.  Điều này không được hỗ trợ
  bởi Linux.



2. Kích hoạt và vô hiệu hóa Ngăn xếp điều khiển được bảo vệ
-------------------------------------------------

* GCS được bật và tắt cho một chuỗi thông qua PR_SET_SHADOW_STACK_STATUS
  prctl(), điều này lấy một đối số cờ duy nhất xác định các tính năng của GCS
  nên được sử dụng.

* Khi đặt cờ PR_SHADOW_STACK_ENABLE sẽ phân bổ Ngăn điều khiển được bảo vệ
  và kích hoạt GCS cho luồng, cho phép chức năng được kiểm soát bởi
  GCSCRE0_EL1.{nTR, RVCHKEN, PCRSEL}.

* Khi đặt cờ PR_SHADOW_STACK_PUSH sẽ bật chức năng được kiểm soát
  bởi GCSCRE0_EL1.PUSHMEn, cho phép đẩy GCS rõ ràng.

* Khi đặt cờ PR_SHADOW_STACK_WRITE sẽ bật chức năng được kiểm soát
  bởi GCSCRE0_EL1.STREn, cho phép lưu trữ rõ ràng vào Ngăn xếp điều khiển được bảo vệ.

* Bất kỳ cờ không xác định nào sẽ khiến PR_SET_SHADOW_STACK_STATUS trả về -EINVAL.

* PR_LOCK_SHADOW_STACK_STATUS được chuyển giao một bitmask gồm các tính năng tương tự
  các giá trị được sử dụng cho PR_SET_SHADOW_STACK_STATUS.  Bất kỳ thay đổi nào trong tương lai đối với
  trạng thái của các bit chế độ GCS được chỉ định sẽ bị từ chối.

* PR_LOCK_SHADOW_STACK_STATUS cho phép khóa bất kỳ bit nào, điều này cho phép
  không gian người dùng để ngăn chặn những thay đổi đối với bất kỳ tính năng nào trong tương lai.

* Không có hỗ trợ cho quy trình xóa khóa đã được đặt cho
  nó.

* PR_SET_SHADOW_STACK_STATUS và PR_LOCK_SHADOW_STACK_STATUS chỉ ảnh hưởng đến
  thread đã gọi chúng thì mọi thread đang chạy khác sẽ không bị ảnh hưởng.

* Chủ đề mới kế thừa cấu hình GCS của chủ đề đã tạo ra chúng.

* GCS bị tắt trên exec().

* Cấu hình GCS hiện tại cho một luồng có thể được đọc bằng
  PR_GET_SHADOW_STACK_STATUS prctl(), điều này trả về các cờ tương tự
  được chuyển tới PR_SET_SHADOW_STACK_STATUS.

* Nếu GCS bị vô hiệu hóa cho một luồng sau khi đã được bật trước đó thì
  ngăn xếp sẽ vẫn được phân bổ trong suốt thời gian tồn tại của luồng.  Hiện tại
  mọi nỗ lực kích hoạt lại GCS cho chuỗi sẽ bị từ chối, điều này có thể
  được xem xét lại trong tương lai.

* Cần lưu ý rằng việc kích hoạt GCS sẽ khiến GCS trở thành
  hoạt động ngay lập tức, thông thường không thể quay lại từ hàm
  đã gọi prctl() kích hoạt GCS.  Dự kiến là bình thường
  Việc sử dụng sẽ là GCS được kích hoạt từ rất sớm khi thực hiện chương trình.



3. Phân bổ ngăn xếp điều khiển được bảo vệ
----------------------------------------

* Khi GCS được bật cho một luồng, Ngăn xếp điều khiển được bảo vệ mới sẽ được kích hoạt
  được phân bổ cho nó bằng một nửa kích thước ngăn xếp tiêu chuẩn hoặc 2 gigabyte,
  cái nào nhỏ hơn.

* Khi một luồng mới được tạo bởi một luồng đã bật GCS thì
  Ngăn xếp điều khiển được bảo vệ mới sẽ được phân bổ cho luồng mới với
  một nửa kích thước của ngăn xếp tiêu chuẩn.

* Khi một ngăn xếp được phân bổ bằng cách bật GCS hoặc trong quá trình tạo luồng thì
  8 byte trên cùng của ngăn xếp sẽ được khởi tạo thành 0 và GCSPR_EL0 sẽ
  được đặt để trỏ tới địa chỉ của giá trị 0 này, giá trị này có thể được sử dụng để
  phát hiện đỉnh của ngăn xếp.

* Các ngăn xếp điều khiển được bảo vệ bổ sung có thể được phân bổ bằng cách sử dụng
  lệnh gọi hệ thống map_shadow_stack().

* Các ngăn xếp được phân bổ bằng cách sử dụng map_shadow_stack() có thể tùy chọn có phần cuối là
  điểm đánh dấu ngăn xếp và nắp được đặt ở đầu ngăn xếp.  Nếu lá cờ
  SHADOW_STACK_SET_TOKEN được chỉ định một nắp sẽ được đặt trên ngăn xếp,
  nếu SHADOW_STACK_SET_MARKER không được chỉ định thì giới hạn sẽ nằm trong top 8
  byte của ngăn xếp và nếu nó được chỉ định thì giới hạn sẽ là giá trị tiếp theo
  8 byte.  Trong khi chỉ xác định riêng SHADOW_STACK_SET_MARKER là
  hợp lệ vì điểm đánh dấu là tất cả các bit 0 nên nó không có tác dụng quan sát được.

* Các ngăn xếp được phân bổ bằng map_shadow_stack() phải có kích thước là
  bội số của 8 byte lớn hơn 8 byte và phải được căn chỉnh 8 byte.

* Một địa chỉ có thể được chỉ định cho map_shadow_stack(), nếu địa chỉ đó được cung cấp thì
  nó phải được căn chỉnh theo ranh giới trang.

* Khi một luồng được giải phóng, Ngăn xếp điều khiển được bảo vệ ban đầu được phân bổ cho
  chủ đề đó sẽ được giải phóng.  Lưu ý cẩn thận rằng nếu ngăn xếp đã được
  đã chuyển đổi đây có thể không phải là ngăn xếp hiện đang được luồng sử dụng.


4. Xử lý tín hiệu
--------------------

* Bản ghi khung tín hiệu mới gcs_context mã hóa chế độ GCS hiện tại và
  con trỏ cho bối cảnh bị gián đoạn khi truyền tín hiệu.  Điều này sẽ luôn
  có mặt trên các hệ thống hỗ trợ GCS.

* Bản ghi chứa trường cờ báo cáo cấu hình GCS hiện tại
  cho bối cảnh bị gián đoạn như PR_GET_SHADOW_STACK_STATUS.

* Bộ xử lý tín hiệu được chạy với cấu hình GCS giống như cấu hình bị gián đoạn
  bối cảnh.

* Khi GCS được bật cho luồng bị gián đoạn, việc xử lý tín hiệu cụ thể
  Mã thông báo giới hạn GCS sẽ được ghi vào GCS, đây là giới hạn GCS kiến trúc
  với loại mã thông báo (bit 0..11) đều rõ ràng.  GCSPR_EL0 được báo cáo trong
  khung tín hiệu sẽ trỏ đến mã thông báo giới hạn này.

* Bộ xử lý tín hiệu sẽ sử dụng GCS giống như bối cảnh bị gián đoạn.

* Khi GCS được bật khi nhập tín hiệu, một khung có địa chỉ của tín hiệu
  bộ xử lý trả về sẽ được đẩy lên GCS, cho phép trả về từ tín hiệu
  xử lý qua RET như bình thường.  Điều này sẽ không được báo cáo trong gcs_context trong
  khung tín hiệu


5. Tín hiệu trở lại
-----------------

Khi trở về từ bộ xử lý tín hiệu:

* Nếu có bản ghi gcs_context trong khung tín hiệu thì cờ GCS
  và GCSPR_EL0 sẽ được khôi phục từ bối cảnh đó trước khi tiếp tục
  xác nhận.

* Nếu không có bản ghi gcs_context trong khung tín hiệu thì GCS
  cấu hình sẽ không thay đổi.

* Nếu GCS được bật khi trả về từ bộ xử lý tín hiệu thì GCSPR_EL0 phải
  trỏ đến bản ghi giới hạn tín hiệu GCS hợp lệ, bản ghi này sẽ xuất hiện từ
  GCS trước khi tín hiệu trở lại.

* Nếu cấu hình GCS bị khóa khi quay lại từ tín hiệu thì bất kỳ
  cố gắng thay đổi cấu hình GCS sẽ bị coi là lỗi.  Cái này
  đúng ngay cả khi GCS không được bật trước khi nhập tín hiệu.

* GCS có thể bị vô hiệu hóa thông qua tín hiệu trở lại nhưng mọi nỗ lực kích hoạt GCS thông qua
  tín hiệu trở lại sẽ bị từ chối.


6. phần mở rộng ptrace
---------------------

* Một regset mới NT_ARM_GCS được xác định để sử dụng với PTRACE_GETREGSET và
  PTRACE_SETREGSET.

* Chế độ GCS, bao gồm bật và tắt, có thể được cấu hình thông qua ptrace.
  Nếu GCS được kích hoạt thông qua ptrace thì sẽ không có GCS mới nào được phân bổ cho chuỗi.

* Cấu hình qua ptrace bỏ qua việc khóa các bit chế độ GCS.


7. Tiện ích mở rộng lõi của ELF
---------------------------

* Ghi chú NT_ARM_GCS sẽ được thêm vào mỗi coredump cho mỗi luồng của
  quá trình đổ thải.  Nội dung sẽ tương đương với dữ liệu sẽ
  đã được đọc nếu PTRACE_GETREGSET thuộc loại tương ứng
  được thực thi cho mỗi luồng khi coredump được tạo.



8. /proc tiện ích mở rộng
--------------------

* Các trang Ngăn xếp Điều khiển được Bảo vệ sẽ bao gồm "ss" trong VmFlags của chúng trong
  /proc/<pid>/smaps.
