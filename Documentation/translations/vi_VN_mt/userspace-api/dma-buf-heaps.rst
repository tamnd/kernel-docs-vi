.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/userspace-api/dma-buf-heaps.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

======================================
Phân bổ dma-buf bằng cách sử dụng đống
======================================

Vùng Dma-buf là một cách để không gian người dùng phân bổ các đối tượng dma-buf. Họ là
thường được sử dụng để phân bổ bộ đệm từ một nhóm phân bổ cụ thể hoặc để chia sẻ
bộ đệm trên các khung công tác.

Đống
=====

Một đống đại diện cho một bộ cấp phát cụ thể. Nhân Linux hiện hỗ trợ
đống sau:

- Vùng nhớ ZZ0000ZZ phân bổ các bộ đệm gần như liền kề, có thể lưu vào bộ nhớ đệm.

- Vùng nhớ ZZ0000ZZ phân bổ gần như liền kề, có thể lưu vào bộ nhớ đệm,
   bộ đệm sử dụng bộ nhớ chia sẻ (được giải mã). Nó chỉ hiện diện trên
   máy ảo điện toán bí mật (CoCo) nơi mã hóa bộ nhớ đang hoạt động
   (ví dụ: AMD SEV, Intel TDX). Các trang được phân bổ có mã hóa
   bit bị xóa, giúp chúng có thể truy cập được đối với thiết bị DMA mà không cần TDISP
   hỗ trợ. Trên các cấu hình VM không phải CoCo, vùng heap này không được đăng ký.

- Vùng ZZ0000ZZ phân bổ liền kề về mặt vật lý,
   có thể lưu vào bộ nhớ đệm, bộ đệm. Chỉ xuất hiện nếu có vùng CMA. Như vậy
   vùng thường được tạo thông qua dòng lệnh kernel
   thông qua tham số ZZ0001ZZ, nút Cây thiết bị vùng bộ nhớ với
   tập thuộc tính ZZ0002ZZ hoặc thông qua
   Tùy chọn Kconfig ZZ0003ZZ hoặc ZZ0004ZZ. Trước
   sang Linux 6.17, tên của nó không ổn định và có thể được gọi là
   ZZ0005ZZ, ZZ0006ZZ hoặc ZZ0007ZZ, tùy thuộc vào
   nền tảng.

- Một vùng heap sẽ được tạo cho từng vùng có thể tái sử dụng trong cây thiết bị
   tương thích với ZZ0000ZZ, sử dụng cây thiết bị đầy đủ
   tên nút như tên của nó. Ngữ nghĩa của bộ đệm giống hệt với
   ZZ0001ZZ.

Quy ước đặt tên
=================

Tên vùng heap ZZ0000ZZ phải đáp ứng một số hạn chế:

- Tên phải ổn định, không được thay đổi từ phiên bản này sang phiên bản khác.
  Vùng người dùng xác định các vùng nhớ theo tên của chúng, vì vậy nếu tên thay đổi, chúng tôi
  sẽ có khả năng đưa ra các hồi quy.

- Tên phải mô tả vùng bộ nhớ mà heap sẽ phân bổ từ đó và
  phải xác định duy nhất nó trong một nền tảng nhất định. Vì các ứng dụng không gian người dùng
  sử dụng tên heap làm phân biệt đối xử, nó phải có khả năng cho biết đó là heap nào
  muốn sử dụng một cách đáng tin cậy nếu có nhiều đống.

- Tên không được đề cập chi tiết triển khai, chẳng hạn như người cấp phát. các
  trình điều khiển heap sẽ thay đổi theo thời gian và chi tiết triển khai khi nó được thực hiện
  được giới thiệu có thể không còn phù hợp trong tương lai.

- Tên phải mô tả thuộc tính của bộ đệm sẽ được phân bổ.
  Làm như vậy sẽ giúp việc nhận dạng heap dễ dàng hơn cho không gian người dùng. Những tính chất như vậy
  là:

- ZZ0000ZZ cho bộ đệm liền kề về mặt vật lý;

- ZZ0000ZZ dành cho bộ đệm được mã hóa mà hệ điều hành không thể truy cập được;

- Tên có thể mô tả mục đích sử dụng. Làm như vậy sẽ giúp nhận dạng heap
  dễ dàng hơn cho các ứng dụng và người dùng không gian người dùng.

Ví dụ: giả sử một nền tảng có vùng bộ nhớ dành riêng được đặt
tại địa chỉ RAM 0x42000000, nhằm phân bổ bộ đệm khung video,
liền kề về mặt vật lý và được hỗ trợ bởi bộ cấp phát hạt nhân CMA, tốt
tên sẽ là ZZ0000ZZ hoặc ZZ0001ZZ, nhưng
ZZ0002ZZ thì không.