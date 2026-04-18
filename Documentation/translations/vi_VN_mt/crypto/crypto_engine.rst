.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/crypto/crypto_engine.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

Công cụ tiền điện tử
=============

Tổng quan
--------
Công cụ tiền điện tử (CE) API là trình quản lý hàng đợi tiền điện tử.

Yêu cầu
-----------
Bạn phải đặt, ở đầu bối cảnh biến đổi your_tfm_ctx, cấu trúc
mật mã_engine:

::

cấu trúc your_tfm_ctx {
		cấu trúc công cụ crypto_engine;
		...
	};

Công cụ mã hóa chỉ quản lý các yêu cầu không đồng bộ dưới dạng
crypto_async_request. Nó không thể biết loại yêu cầu cơ bản và do đó chỉ
có quyền truy cập vào cấu trúc biến đổi. Không thể truy cập vào ngữ cảnh
sử dụng container_of. Ngoài ra, động cơ không biết gì về bạn
cấu trúc "ZZ0000ZZ". Động cơ giả định (yêu cầu) vị trí
của thành viên được biết đến ZZ0001ZZ lúc đầu.

Trình tự thao tác
-------------------
Bạn được yêu cầu lấy struct crypto_engine thông qua ZZ0000ZZ.
Bắt đầu nó thông qua ZZ0001ZZ. Khi hoàn tất công việc, hãy tắt máy
động cơ sử dụng ZZ0002ZZ và phá hủy động cơ bằng
ZZ0003ZZ.

Trước khi chuyển bất kỳ yêu cầu nào, bạn phải điền vào context enginectx bằng cách
cung cấp các chức năng sau:

* ZZ0000ZZ/ZZ0001ZZ: Được gọi trước mỗi
  yêu cầu tương ứng được thực hiện. Nếu một số quá trình xử lý hoặc chuẩn bị khác
  công việc được yêu cầu, hãy làm điều đó ở đây.

* ZZ0000ZZ/ZZ0001ZZ: Được gọi sau mỗi lần
  yêu cầu được xử lý. Dọn dẹp/hoàn tác những gì đã được thực hiện trong chức năng chuẩn bị.

* ZZ0000ZZ/ZZ0001ZZ: Xử lý yêu cầu hiện tại bằng cách
  thực hiện thao tác.

Lưu ý rằng các hàm này truy cập vào cấu trúc crypto_async_request
liên quan đến yêu cầu nhận được. Bạn có thể lấy lại bản gốc
yêu cầu bằng cách sử dụng:

::

container_of(areq, struct yourrequesttype_request, base);

Khi trình điều khiển của bạn nhận được crypto_request, bạn phải chuyển nó sang
công cụ mật mã thông qua một trong:

* crypto_transfer_aead_request_to_engine()

* crypto_transfer_akcipher_request_to_engine()

* crypto_transfer_hash_request_to_engine()

* crypto_transfer_kpp_request_to_engine()

* crypto_transfer_skcipher_request_to_engine()

Khi kết thúc quá trình yêu cầu, cần gọi đến một trong các chức năng sau:

* crypto_finalize_aead_request()

* crypto_finalize_akcipher_request()

* crypto_finalize_hash_request()

* crypto_finalize_kpp_request()

* crypto_finalize_skcipher_request()