.. SPDX-License-Identifier: (GPL-2.0+ OR MIT)

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/gpu/nova/guidelines.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

===========
Hướng dẫn
==========

Tài liệu này mô tả các hướng dẫn chung của dự án áp dụng cho nova-core
và nova-drm.

Ngôn ngữ
========

Dự án Nova sử dụng ngôn ngữ lập trình Rust. Trong bối cảnh này, tất cả các quy tắc
của dự án Rust for Linux như được ghi lại trong
Áp dụng ZZ0000ZZ. Ngoài ra, các quy định sau
áp dụng.

- Trừ khi cần thiết về mặt kỹ thuật (ví dụ: uAPI), mọi mã trình điều khiển đều được viết
  ở Rust.

- Trừ khi cần thiết về mặt kỹ thuật, phải tránh mã Rust không an toàn. Trong trường hợp
  cần thiết về mặt kỹ thuật, mã không an toàn cần được cách ly trong một thành phần riêng biệt
  cung cấp API an toàn cho mã trình điều khiển khác sử dụng.

Phong cách
-----

Tất cả các quy tắc của dự án Rust for Linux như được ghi lại trong
Áp dụng ZZ0000ZZ.

Để biết danh sách kiểm tra gửi, vui lòng xem thêm ZZ0000ZZ.

Tài liệu
=============

Sự sẵn có của tài liệu phù hợp là cần thiết về khả năng mở rộng,
khả năng tiếp cận cho những người đóng góp mới và khả năng duy trì của một dự án nói chung,
nhưng đặc biệt đối với trình điều khiển chạy phần cứng phức tạp như Nova đang nhắm mục tiêu.

Do đó, việc bổ sung thêm bất kỳ loại tài liệu nào được dự án rất khuyến khích.

Ngoài ra còn có một số yêu cầu tối thiểu.

- Mỗi cấu trúc không riêng tư cần ít nhất một nhận xét tài liệu ngắn gọn giải thích
  ý nghĩa ngữ nghĩa của cấu trúc, cũng như khả năng khóa và thời gian tồn tại
  yêu cầu. Khuyến khích có cùng tài liệu tối thiểu cho
  cấu trúc tư nhân không tầm thường.

- uAPI phải được ghi lại đầy đủ bằng các nhận xét kernel-doc; Ngoài ra,
  hành vi ngữ nghĩa phải được giải thích bao gồm cả khả năng đặc biệt hoặc góc
  trường hợp.

- Các API kết nối driver cấp 1 (nova-core) với driver cấp 2
  phải được ghi chép đầy đủ. Điều này bao gồm các nhận xét về tài liệu, khả năng khóa và
  yêu cầu trọn đời, cũng như mã ví dụ nếu có.

- Khi giới thiệu phải giải thích các chữ viết tắt; thuật ngữ phải là duy nhất
  được xác định.

- Địa chỉ đăng ký, bố cục, giá trị dịch chuyển và mặt nạ phải được xác định đúng;
  trừ khi rõ ràng, ý nghĩa ngữ nghĩa phải được ghi lại. Điều này chỉ áp dụng nếu
  tác giả có thể thu được thông tin tương ứng.

Tiêu chí chấp nhận
===================

- Các bản vá chỉ được áp dụng nếu được xem xét bởi ít nhất một người khác trên
  danh sách gửi thư; điều này cũng áp dụng cho người bảo trì.