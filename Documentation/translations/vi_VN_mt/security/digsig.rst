.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/security/digsig.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

=====================================
Xác minh chữ ký số API
==================================

:Tác giả: Dmitry Kasatkin
:Ngày: 06.10.2011


.. CONTENTS

   1. Introduction
   2. API
   3. User-space utilities


Giới thiệu
============

Xác minh chữ ký số API cung cấp phương pháp xác minh chữ ký số.
Hiện tại, chữ ký số được sử dụng bởi hệ thống con bảo vệ tính toàn vẹn IMA/EVM.

Xác minh chữ ký số được thực hiện bằng cách sử dụng cổng kernel cắt xuống của
Thư viện số nguyên đa chính xác GnuPG (MPI). Cổng kernel cung cấp
xử lý lỗi cấp phát bộ nhớ, đã được refactor theo kernel
kiểu mã hóa cũng như các lỗi và cảnh báo được báo cáo của checkpatch.pl đã được sửa.

Khóa công khai và chữ ký bao gồm tiêu đề và MPI::

cấu trúc pubkey_hdr {
		phiên bản uint8_t;	/* Phiên bản định dạng khóa */
		dấu thời gian time_t;	/* khóa được tạo, hiện tại luôn là 0 */
		thuật toán uint8_t;
		uint8_t nmpi;
		char mpi[0];
	} __đóng gói;

cấu trúc chữ ký_hdr {
		phiên bản uint8_t;	/*phiên bản định dạng chữ ký */
		dấu thời gian time_t;	/* chữ ký được tạo */
		thuật toán uint8_t;
		hàm băm uint8_t;
		uint8_t keyid[8];
		uint8_t nmpi;
		char mpi[0];
	} __đóng gói;

keyid bằng SHA1[12-19] trên tổng nội dung khóa.
Tiêu đề chữ ký được sử dụng làm đầu vào để tạo chữ ký.
Cách tiếp cận như vậy đảm bảo rằng tiêu đề khóa hoặc chữ ký không thể thay đổi.
Nó bảo vệ dấu thời gian khỏi bị thay đổi và có thể được sử dụng để khôi phục
bảo vệ.

API
===

API hiện chỉ bao gồm 1 chức năng::

digsig_verify() - xác minh chữ ký số bằng khóa chung


/**
	* digsig_verify() - xác minh chữ ký số bằng khóa chung
	* @keyring: gõ phím để tìm kiếm phím trong
	* @sig: chữ ký số
	* @sigen: độ dài của chữ ký
	* @data: dữ liệu
	* @datalen: độ dài của dữ liệu
	* @return: 0 nếu thành công, -EINVAL nếu ngược lại
	*
	* Xác minh tính toàn vẹn dữ liệu đối với chữ ký số.
	* Hiện tại chỉ hỗ trợ RSA.
	* Thông thường hàm băm của nội dung được sử dụng làm dữ liệu cho hàm này.
	*
	*/
	int digsig_verify(khóa cấu trúc *keyring, const char *sig, int siglen,
			  const char *data, int datalen);

Tiện ích không gian người dùng
====================

Các tiện ích quản lý khóa và ký tên evm-utils cung cấp chức năng
để tạo chữ ký, tải khóa vào khóa kernel.
Các khóa có thể ở dạng PEM hoặc được chuyển đổi sang định dạng kernel.
Khi khóa được thêm vào khóa kernel, keyid sẽ xác định tên
của khóa: 5D2B05FC633EE3E8 trong ví dụ bên dưới.

Đây là ví dụ đầu ra của tiện ích keyctl ::

$ keyctl hiển thị
	Khóa phiên
	-3 --alswrv 0 0 gõ phím: _ses
	603976250 --alswrv 0 -1 \_ móc khóa: _uid.0
	817777377 --alswrv 0 0 \_ người dùng: kmk
	891974900 --alswrv 0 0 \_ được mã hóa: evm-key
	170323636 --alswrv 0 0 \_ móc khóa: _module
	548221616 --alswrv 0 0 \_ móc khóa: _ima
	128198054 --alswrv 0 0 \_ móc khóa: _evm

danh sách $ keyctl 128198054
	1 phím trong móc khóa:
	620789745: --alswrv 0 0 người dùng: 5D2B05FC633EE3E8
