.. SPDX-License-Identifier: GPL-2.0-or-later

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/arch/powerpc/dexcr.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

==============================================
DEXCR (Thanh ghi điều khiển thực thi động)
==============================================

Tổng quan
=========

DEXCR là thanh ghi mục đích đặc biệt đặc biệt (SPR) được giới thiệu trong
PowerPC ISA 3.1B (Power10) cho phép điều khiển từng CPU đối với một số chức năng động
hành vi thực hiện. Những hành vi này bao gồm suy đoán (ví dụ: gián tiếp
dự đoán mục tiêu nhánh) và cho phép lập trình hướng trở lại (ROP)
hướng dẫn bảo vệ.

Kiểm soát thực thi được hiển thị trong phần cứng lên tới 32 bit ('khía cạnh') trong
DEXCR. Mỗi khía cạnh kiểm soát một hành vi nhất định và có thể được đặt hoặc xóa
để bật/tắt khía cạnh này. Có một số biến thể của DEXCR dành cho
mục đích khác nhau:

DEXCR
    SPR đặc quyền có thể kiểm soát các khía cạnh của không gian người dùng và không gian kernel
HDEXCR
    SPR có đặc quyền của trình ảo hóa có thể kiểm soát các khía cạnh của trình ảo hóa và
    thực thi các khía cạnh cho kernel và không gian người dùng.
UDEXCR
    Một SPR đặc quyền của bộ giám sát tùy chọn có thể kiểm soát các khía cạnh của bộ giám sát.

Không gian người dùng có thể kiểm tra trạng thái DEXCR hiện tại bằng SPR chuyên dụng
cung cấp chế độ xem chỉ đọc không có đặc quyền về các khía cạnh DEXCR của không gian người dùng.
Ngoài ra còn có SPR cung cấp chế độ xem chỉ đọc của trình ảo hóa được thực thi
các khía cạnh mà ORed với chế độ xem DEXCR của không gian người dùng mang lại DEXCR hiệu quả
trạng thái cho một tiến trình.


Cấu hình
=============

prctl
-----

Một tiến trình có thể kiểm soát giá trị DEXCR của không gian người dùng của chính nó bằng cách sử dụng
Cặp ZZ0001ZZ và ZZ0002ZZ
Các lệnh ZZ0000ZZ. Các cuộc gọi này có dạng::

prctl(PR_PPC_GET_DEXCR, unsigned long which, 0, 0, 0);
    prctl(PR_PPC_SET_DEXCR, unsigned long which, unsigned long ctrl, 0, 0);

Các giá trị 'which' và 'ctrl' có thể có như sau. Lưu ý không có mối quan hệ
giữa giá trị 'cái nào' và chỉ mục của khía cạnh DEXCR.

.. flat-table::
   :header-rows: 1
   :widths: 2 7 1

   * - ``prctl()`` which
     - Aspect name
     - Aspect index

   * - ``PR_PPC_DEXCR_SBHE``
     - Speculative Branch Hint Enable (SBHE)
     - 0

   * - ``PR_PPC_DEXCR_IBRTPD``
     - Indirect Branch Recurrent Target Prediction Disable (IBRTPD)
     - 3

   * - ``PR_PPC_DEXCR_SRAPD``
     - Subroutine Return Address Prediction Disable (SRAPD)
     - 4

   * - ``PR_PPC_DEXCR_NPHIE``
     - Non-Privileged Hash Instruction Enable (NPHIE)
     - 5

.. flat-table::
   :header-rows: 1
   :widths: 2 8

   * - ``prctl()`` ctrl
     - Meaning

   * - ``PR_PPC_DEXCR_CTRL_EDITABLE``
     - This aspect can be configured with PR_PPC_SET_DEXCR (get only)

   * - ``PR_PPC_DEXCR_CTRL_SET``
     - This aspect is set / set this aspect

   * - ``PR_PPC_DEXCR_CTRL_CLEAR``
     - This aspect is clear / clear this aspect

   * - ``PR_PPC_DEXCR_CTRL_SET_ONEXEC``
     - This aspect will be set after exec / set this aspect after exec

   * - ``PR_PPC_DEXCR_CTRL_CLEAR_ONEXEC``
     - This aspect will be clear after exec / clear this aspect after exec

Lưu ý rằng

* là giá trị đơn giản, không phải mặt nạ bit. Các khía cạnh phải được xử lý riêng lẻ.

* ctrl là một mặt nạ bit. ZZ0000ZZ trả về cả hiện tại và oneexec
  cấu hình. Ví dụ: ZZ0001ZZ có thể trả về
  ZZ0002ZZ. Điều này sẽ chỉ ra khía cạnh hiện tại
  được đặt, nó sẽ bị xóa khi bạn chạy exec và bạn có thể thay đổi điều này bằng lệnh
  ZZ0003ZZ thực tế.

* Thuật ngữ thiết lập/xóa đề cập đến việc thiết lập/xóa bit trong DEXCR.
  Ví dụ::

prctl(PR_PPC_SET_DEXCR, PR_PPC_DEXCR_IBRTPD, PR_PPC_DEXCR_CTRL_SET, 0, 0);

sẽ đặt bit khía cạnh IBRTPD trong DEXCR, gây ra dự đoán nhánh gián tiếp
  bị vô hiệu hóa.

* Trạng thái được ZZ0000ZZ trả về thể hiện giá trị của quy trình
  muốn áp dụng. Nó không bao gồm bất kỳ phần ghi đè thay thế nào, chẳng hạn như nếu
  trình ảo hóa đang thực thi khía cạnh được thiết lập. Để xem trạng thái DEXCR thực sự
  phần mềm nên đọc trực tiếp các SPR thích hợp.

* Trạng thái khía cạnh khi bắt đầu một quá trình được sao chép từ trạng thái của cha mẹ trên
  ZZ0000ZZ. Trạng thái được đặt lại về giá trị cố định trên
  ZZ0001ZZ. PR_PPC_SET_DEXCR prctl() có thể điều khiển cả hai điều này
  các giá trị.

* Bộ điều khiển ZZ0000ZZ không thay đổi DEXCR của quy trình hiện tại.

Sử dụng ZZ0000ZZ với một trong các ZZ0001ZZ hoặc
ZZ0002ZZ để chỉnh sửa một khía cạnh nhất định.

Các mã lỗi phổ biến cho cả việc nhận và cài đặt DEXCR như sau:

.. flat-table::
   :header-rows: 1
   :widths: 2 8

   * - Error
     - Meaning

   * - ``EINVAL``
     - The DEXCR is not supported by the kernel.

   * - ``ENODEV``
     - The aspect is not recognised by the kernel or not supported by the
       hardware.

ZZ0000ZZ cũng có thể báo cáo các mã lỗi sau:

.. flat-table::
   :header-rows: 1
   :widths: 2 8

   * - Error
     - Meaning

   * - ``EINVAL``
     - The ctrl value contains unrecognised flags.

   * - ``EINVAL``
     - The ctrl value contains mutually conflicting flags (e.g.,
       ``PR_PPC_DEXCR_CTRL_SET | PR_PPC_DEXCR_CTRL_CLEAR``)

   * - ``EPERM``
     - This aspect cannot be modified with prctl() (check for the
       PR_PPC_DEXCR_CTRL_EDITABLE flag with PR_PPC_GET_DEXCR).

   * - ``EPERM``
     - The process does not have sufficient privilege to perform the operation.
       For example, clearing NPHIE on exec is a privileged operation (a process
       can still clear its own NPHIE aspect without privileges).

Giao diện này cho phép một tiến trình kiểm soát các khía cạnh DEXCR của chính nó và cũng có thể thiết lập
giá trị DEXCR ban đầu cho bất kỳ phần tử con nào trong cây quy trình của nó (cho đến phần tiếp theo
trẻ em sử dụng điều khiển ZZ0000ZZ). Điều này cho phép kiểm soát chi tiết hơn đối với
giá trị mặc định của DEXCR, ví dụ như cho phép các container chạy với các
các giá trị mặc định.


coredump và ptrace
===================

Các giá trị không gian người dùng của DEXCR và HDEXCR (theo thứ tự này) được hiển thị bên dưới
ZZ0000ZZ. Đây là mỗi loại 64 bit và chỉ đọc và nhằm mục đích
hỗ trợ với các bãi chứa lõi. DEXCR có thể được ghi ở chế độ ghi trong tương lai. Top 32
các bit của cả hai thanh ghi (tương ứng với các bit không phải của không gian người dùng) bị che đi.

Nếu cấu hình kernel ZZ0000ZZ được bật thì
ZZ0001ZZ có sẵn và hiển thị giá trị HASHKEYR của quy trình
để đọc và viết. Đây là sự cân bằng giữa việc tăng cường an ninh và
hỗ trợ điểm kiểm tra/khôi phục: một quy trình thông thường không cần phải biết về nó
khóa bí mật, nhưng việc khôi phục một quy trình yêu cầu phải đặt khóa gốc của nó. Chìa khóa
do đó xuất hiện trong các kết xuất lõi và kẻ tấn công có thể lấy nó từ
một coredump và vượt qua sự bảo vệ ROP một cách hiệu quả trên bất kỳ chủ đề nào chia sẻ điều này
khóa (có thể là tất cả các luồng từ cùng một nguồn gốc chưa chạy ZZ0002ZZ).