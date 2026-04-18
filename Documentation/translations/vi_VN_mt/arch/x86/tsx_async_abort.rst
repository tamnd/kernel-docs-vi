.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/arch/x86/tsx_async_abort.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

Giảm thiểu TSX Hủy bỏ không đồng bộ (TAA)
=========================================

.. _tsx_async_abort:

Tổng quan
---------

TSX Async Abort (TAA) là một cuộc tấn công kênh bên vào bộ đệm bên trong ở một số
Bộ xử lý Intel tương tự như Lấy mẫu dữ liệu vi kiến trúc (MDS).  Trong này
trường hợp một số tải nhất định có thể chuyển dữ liệu không hợp lệ sang các hoạt động phụ thuộc theo suy đoán
khi điều kiện hủy bỏ không đồng bộ đang chờ xử lý trong Giao dịch
Giao dịch Tiện ích mở rộng đồng bộ hóa (TSX).  Điều này bao gồm tải không có
tình trạng lỗi hoặc hỗ trợ. Các tải như vậy có thể làm lộ dữ liệu cũ từ
cấu trúc dữ liệu uarch giống như trong MDS, với cùng phạm vi hiển thị, tức là.
cùng một chủ đề và chéo chủ đề. Sự cố này ảnh hưởng đến tất cả các bộ xử lý hiện tại
hỗ trợ TSX.

Chiến lược giảm thiểu
---------------------

a) Vô hiệu hóa TSX - một trong những biện pháp giảm thiểu là vô hiệu hóa TSX. MSR mới
IA32_TSX_CTRL sẽ có sẵn trong các bộ xử lý hiện tại và tương lai sau
cập nhật vi mã có thể được sử dụng để vô hiệu hóa TSX. Ngoài ra, nó
kiểm soát việc liệt kê các bit tính năng TSX (RTM và HLE) trong CPUID.

b) Xóa bộ đệm CPU - tương tự như MDS, việc xóa bộ đệm CPU sẽ giảm thiểu điều này
tính dễ bị tổn thương. Thông tin chi tiết về phương pháp này có thể được tìm thấy trong
ZZ0000ZZ.

Các chế độ giảm thiểu nội bộ hạt nhân
-------------------------------------

============== =================================================================
 tắt Giảm thiểu bị vô hiệu hóa. CPU không bị ảnh hưởng hoặc
                  tsx_async_abort=off được cung cấp trên dòng lệnh kernel.

tsx bị vô hiệu hóa Giảm nhẹ được bật. Tính năng TSX bị tắt theo mặc định tại
                  khởi động trên bộ xử lý hỗ trợ điều khiển TSX.

verw Giảm thiểu được kích hoạt. CPU bị ảnh hưởng và MD_CLEAR
                  được quảng cáo trong CPUID.

cần ucode Giảm thiểu được kích hoạt. CPU bị ảnh hưởng còn MD_CLEAR thì không
                  được quảng cáo trong CPUID. Cái đó chủ yếu dành cho ảo hóa
                  các tình huống trong đó máy chủ có vi mã được cập nhật nhưng
                  trình ảo hóa không hiển thị MD_CLEAR trong CPUID. Đó là điều tốt nhất
                  cách tiếp cận nỗ lực mà không có sự đảm bảo.
 ============== =================================================================

Nếu CPU bị ảnh hưởng và tham số dòng lệnh kernel "tsx_async_abort" là
không được cung cấp thì kernel sẽ chọn biện pháp giảm thiểu thích hợp tùy thuộc vào
trạng thái của các bit RTM và MD_CLEAR CPUID.

Các bảng bên dưới cho biết tác động của các tùy chọn dòng lệnh tsx=on|off|auto đối với trạng thái
Giảm thiểu TAA, hành vi VERW và tính năng TSX cho các kết hợp khác nhau của
Các bit MSR_IA32_ARCH_CAPABILITIES.

1. "tsx=tắt"

========== ========= ======================================= ==================== =========================
Các bit MSR_IA32_ARCH_CAPABILITIES Kết quả với cmdline tsx=off
---------------------------------- -------------------------------------------------------------------------
TAA_NO MDS_NO TSX_CTRL_MSR TSX trạng thái VERW có thể xóa giảm thiểu TAA Giảm thiểu TAA
                                    sau khi khởi động bộ đệm CPU tsx_async_abort=off tsx_async_abort=full
========== ========= ======================================= ==================== =========================
    0 0 0 HW mặc định Có Tương tự như MDS Tương tự như MDS
    0 0 1 Trường hợp không hợp lệ Trường hợp không hợp lệ Trường hợp không hợp lệ Trường hợp không hợp lệ
    0 1 0 Mặc định phần cứng Không cần cập nhật ucode Cần cập nhật ucode
    0 1 1 Đã tắt Có TSX đã tắt TSX đã tắt
    1 X 1 Bị vô hiệu X Không cần thiết Không cần thiết
========== ========= ======================================= ==================== =========================

2. "tsx=bật"

========== ========= ======================================= ==================== =========================
Các bit MSR_IA32_ARCH_CAPABILITIES Kết quả với cmdline tsx=on
---------------------------------- -------------------------------------------------------------------------
TAA_NO MDS_NO TSX_CTRL_MSR TSX trạng thái VERW có thể xóa giảm thiểu TAA Giảm thiểu TAA
                                    sau khi khởi động bộ đệm CPU tsx_async_abort=off tsx_async_abort=full
========== ========= ======================================= ==================== =========================
    0 0 0 HW mặc định Có Tương tự như MDS Tương tự như MDS
    0 0 1 Trường hợp không hợp lệ Trường hợp không hợp lệ Trường hợp không hợp lệ Trường hợp không hợp lệ
    0 1 0 Mặc định phần cứng Không cần cập nhật ucode Cần cập nhật ucode
    0 1 1 Đã bật Có Không Tương tự như MDS
    1 X 1 Đã bật X Không cần thiết Không cần thiết
========== ========= ======================================= ==================== =========================

3. "tsx=auto"

========== ========= ======================================= ==================== =========================
Các bit MSR_IA32_ARCH_CAPABILITIES Kết quả với cmdline tsx=auto
---------------------------------- -------------------------------------------------------------------------
TAA_NO MDS_NO TSX_CTRL_MSR TSX trạng thái VERW có thể xóa giảm thiểu TAA Giảm thiểu TAA
                                    sau khi khởi động bộ đệm CPU tsx_async_abort=off tsx_async_abort=full
========== ========= ======================================= ==================== =========================
    0 0 0 HW mặc định Có Tương tự như MDS Tương tự như MDS
    0 0 1 Trường hợp không hợp lệ Trường hợp không hợp lệ Trường hợp không hợp lệ Trường hợp không hợp lệ
    0 1 0 Mặc định phần cứng Không cần cập nhật ucode Cần cập nhật ucode
    0 1 1 Đã tắt Có TSX đã tắt TSX đã tắt
    1 X 1 Đã bật X Không cần thiết Không cần thiết
========== ========= ======================================= ==================== =========================

Trong các bảng, TSX_CTRL_MSR là một bit mới trong MSR_IA32_ARCH_CAPABILITIES
cho biết MSR_IA32_TSX_CTRL có được hỗ trợ hay không.

Có hai bit điều khiển trong IA32_TSX_CTRL MSR:

Bit 0: Khi được đặt, nó sẽ vô hiệu hóa Bộ nhớ giao dịch bị hạn chế (RTM)
             tính năng phụ của TSX (sẽ buộc tất cả các giao dịch bị hủy bỏ trên
             Hướng dẫn XBEGIN).

Bit 1: Khi được đặt, nó sẽ tắt tính năng liệt kê RTM và HLE
             (tức là nó sẽ tạo ra CPUID(EAX=7).EBX{bit4} và
             CPUID(EAX=7).EBX{bit11} đọc là 0).