.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/gpu/nova/core/falcon.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

=================================
Falcon (Bộ điều khiển logic nhanh)
==============================
Các phần sau đây mô tả lõi Falcon và ucode chạy trên nó.
Các mô tả dựa trên Ampere GPU hoặc các thiết kế trước đó; tuy nhiên, họ
chủ yếu nên áp dụng cho các thiết kế trong tương lai, nhưng mọi thứ đều phải tuân theo
thay đổi. Tổng quan được cung cấp ở đây chủ yếu được thiết kế để hiểu được
tương tác của trình điều khiển nova-core với Falcon.

GPU NVIDIA nhúng các bộ vi điều khiển nhỏ giống RISC được gọi là lõi Falcon.
xử lý các tác vụ phần sụn an toàn, khởi tạo và quản lý nguồn. hiện đại
GPU NVIDIA có thể có nhiều phiên bản Falcon như vậy (ví dụ: GSP (hệ thống GPU
bộ xử lý) và SEC2 (công cụ bảo mật)) và cũng có thể tích hợp lõi RISC-V.
Lõi này có khả năng chạy cả mã RISC-V và Falcon.

Mã chạy trên lõi Falcon còn được gọi là 'ucode' và sẽ
được đề cập như vậy trong các phần sau.

Chim ưng có bộ nhớ lệnh và dữ liệu riêng biệt (IMEM/DMEM) và cung cấp một
công cụ DMA nhỏ (thông qua FBIF - "Giao diện bộ đệm khung") để tải mã từ
bộ nhớ hệ thống. Trình điều khiển nova-core phải thiết lập lại và cấu hình Falcon, tải
chương trình cơ sở của nó thông qua DMA và khởi động CPU của nó.

Mức độ an ninh của Falcon
======================
Falcons có thể chạy ở chế độ Không bảo mật (NS), Bảo mật nhẹ (LS) hoặc Bảo mật nặng (HS)
chế độ.

Bảo mật nặng (HS) còn được gọi là Đặc quyền cấp 3 (PL3)
--------------------------------------------------------
HS ucode là mã đáng tin cậy nhất và có quyền truy cập vào hầu hết mọi thứ trên
con chip. Mã nhị phân HS bao gồm một chữ ký được xác minh khi khởi động.
Việc xác minh chữ ký này được thực hiện bởi chính phần cứng, do đó thiết lập một
gốc rễ của niềm tin. Ví dụ: lệnh FWSEC-FRTS (xem fwsec.rst) chạy trên
GSP ở chế độ HS. FRTS, bao gồm việc thiết lập và tải nội dung vào WPR
(Ghi vùng bảo vệ), phải được thực hiện bởi ucode HS và không thể được thực hiện bởi
lưu trữ CPU hoặc LS ucode.

Bảo mật nhẹ (LS hoặc PL2) và Không bảo mật (NS hoặc PL0)
-----------------------------------------------------
Các chế độ này kém an toàn hơn HS. Giống như HS, LS hoặc NS ucode nhị phân cũng
thường bao gồm một chữ ký trong đó. Để tải chương trình cơ sở ở chế độ LS hoặc NS lên máy
Falcon, một Falcon khác cần chạy ở chế độ HS, chế độ này cũng thiết lập
gốc rễ của niềm tin. Ví dụ: trong trường hợp Ampere GPU, CPU chạy "Booter"
ucode ở chế độ HS trên SEC2 Falcon, sau đó xác thực và chạy
nhị phân GSP thời gian chạy (GSP-RM) ở chế độ LS trên GSP Falcon. Tương tự, với tư cách là một
ví dụ: sau khi đặt lại trên Ampe, FWSEC chạy trên GSP, sau đó tải
động cơ devinit lên PMU ở chế độ LS.

Gốc rễ của việc thiết lập niềm tin
---------------------------
Để thiết lập nguồn gốc của sự tin cậy, mã chạy trên Falcon phải bất biến và
được nối cứng vào bộ nhớ chỉ đọc (ROM). Điều này tuân theo các tiêu chuẩn của ngành đối với
xác minh phần sụn. Mã này được gọi là Boot ROM (BROM). Lõi nova
trình điều khiển trên CPU giao tiếp với Falcon's Boot ROM thông qua nhiều Falcon khác nhau
các thanh ghi có tiền tố "BROM" (xem reg.rs).

Sau khi trình điều khiển nova-core đọc ucode cần thiết từ VBIOS, nó sẽ lập trình
BROM và DMA đăng ký để kích hoạt Falcon tải ucode HS từ hệ thống
bộ nhớ vào IMEM/DMEM của Falcon. Khi ucode HS được tải, nó sẽ được xác minh
bởi Falcon's Boot ROM.

Khi mã HS đã được xác minh đang chạy trên Falcon, nó có thể xác minh và tải các mã khác
Các tệp nhị phân LS/NS ucode lên các Falcon khác và khởi động chúng. Quá trình ký kết
xác minh giống như HS; chỉ trong trường hợp này, phần cứng (BROM) không
tính toán chữ ký, nhưng ucode HS thì có.

Do đó, gốc rễ của sự tin cậy được thiết lập như sau:
     Phần cứng (Boot ROM chạy trên Falcon) -> HS ucode -> LS/NS ucode.

Ví dụ: trên Ampere GPU, quy trình xác minh khởi động là:
     Phần cứng (Boot ROM chạy trên SEC2) ->
          HS ucode (Booter chạy trên SEC2) ->
               LS ucode (GSP-RM chạy trên GSP)

.. note::
     While the CPU can load HS ucode onto a Falcon microcontroller and have it
     verified by the hardware and run, the CPU itself typically does not load
     LS or NS ucode and run it. Loading of LS or NS ucode is done mainly by the
     HS ucode. For example, on an Ampere GPU, after the Booter ucode runs on the
     SEC2 in HS mode and loads the GSP-RM binary onto the GSP, it needs to run
     the "SEC2-RTOS" ucode at runtime. This presents a problem: there is no
     component to load the SEC2-RTOS ucode onto the SEC2. The CPU cannot load
     LS code, and GSP-RM must run in LS mode. To overcome this, the GSP is
     temporarily made to run HS ucode (which is itself loaded by the CPU via
     the nova-core driver using a "GSP-provided sequencer") which then loads
     the SEC2-RTOS ucode onto the SEC2 in LS mode. The GSP then resumes
     running its own GSP-RM LS ucode.

Hệ thống con bộ nhớ Falcon và động cơ DMA
======================================
Chim ưng có bộ nhớ dữ liệu và lệnh riêng biệt (IMEM/DMEM)
và chứa một công cụ DMA nhỏ gọi là FBDMA (Framebuffer DMA).
DMA chuyển đến/từ bộ nhớ IMEM/DMEM bên trong Falcon thông qua FBIF
(Giao diện bộ đệm khung), sang bộ nhớ ngoài.

Có thể chuyển DMA từ bộ nhớ của Falcon sang cả bộ nhớ hệ thống
và bộ nhớ đệm khung (VRAM).

Để thực hiện DMA thông qua FBDMA, FBIF được cấu hình để quyết định cách bộ nhớ
được truy cập (còn được gọi là loại khẩu độ). Trong trình điều khiển nova-core, đây là
được xác định bởi enum ZZ0000ZZ.

Khối IO-PMP (Bảo vệ bộ nhớ vật lý đầu vào/đầu ra) trong Falcon
kiểm soát quyền truy cập của FBDMA vào bộ nhớ ngoài.

Sơ đồ khái niệm (không chính xác) của Falcon và hệ thống con bộ nhớ của nó như sau::

Bộ nhớ ngoài (Bộ đệm khung / Hệ thống DRAM)
                              ^ |
                              ZZ0000ZZ
                              |  v
     +------------------------------------------------------+
     ZZ0001ZZ |
     ZZ0002ZZ |
     ZZ0003ZZ FBIF ZZ0004ZZ FALCON
     ZZ0005ZZ (Bộ đệm khung ZZ0006ZZ PROCESSOR
     Giao diện ZZ0007ZZ) ZZ0008ZZ
     ZZ0009ZZ Khẩu độ ZZ0010ZZ
     ZZ0011ZZ Định cấu hình ZZ0012ZZ
     ZZ0013ZZ truy cập bộ nhớ ZZ0014ZZ
     ZZ0015ZZ
     ZZ0016ZZ |
     ZZ0017ZZ FBDMA sử dụng khẩu độ FBIF đã được định cấu hình |
     ZZ0018ZZ để truy cập Bộ nhớ ngoài
     ZZ0019ZZ
     |   +-------v--------+ +--------------+
     ZZ0020ZZ FBDMA ZZ0021ZZ RISC |
     ZZ0022ZZ (FrameBuffer ZZ0023ZZ CORE |------->. Truy cập lõi trực tiếp
     Động cơ ZZ0024ZZ DMA) ZZ0025ZZ ZZ0026ZZ
     ZZ0027ZZ - Nhà phát triển bậc thầy.  ZZ0028ZZ (có thể chạy cả ZZ0029ZZ
     ZZ0030ZZ Chim ưng và ZZ0031ZZ
     ZZ0032ZZ cfg--->ZZ0033ZZ |
     ZZ0034ZZ / ZZ0035ZZ |
     ZZ0036ZZ ZZ0037ZZ +-------------+
     ZZ0038ZZ ZZ0039ZZ ZZ0040ZZ
     ZZ0041ZZ ZZ0042ZZ (Khởi động ROM) |
     ZZ0043ZZ / |    +-----------+
     ZZ0044ZZ v |
     ZZ0045ZZ
     ZZ0046ZZ IO-PMP ZZ0047ZZ
     ZZ0048ZZ (Vật lý IO ZZ0049ZZ
     Bảo vệ bộ nhớ ZZ0050ZZ) |
     ZZ0051ZZ
     ZZ0052ZZ |
     Đường dẫn truy cập được bảo vệ ZZ0053ZZ cho FBDMA |
     ZZ0054ZZ
     ZZ0055ZZ
     ZZ0056ZZ Bộ nhớ ZZ0057ZZ
     ZZ0058ZZ +--------------+ +-----------+ ZZ0059ZZ
     ZZ0060ZZ ZZ0061ZZ ZZ0062ZZ |<------+
     ZZ0063ZZ ZZ0064ZZ ZZ0065ZZ |
     ZZ0066ZZ ZZ0067ZZ ZZ0068ZZ |
     ZZ0069ZZ +--------------+ +-------------+ |
     |   +---------------------------------------+
     +------------------------------------------------------+