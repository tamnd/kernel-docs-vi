.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/security/siphash.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

==============================
SipHash - đầu vào ngắn PRF
===========================

:Tác giả: Viết bởi Jason A. Donenfeld <jason@zx2c4.com>

SipHash là PRF được bảo mật bằng mật mã -- một hàm băm có khóa --
hoạt động rất tốt đối với các đầu vào ngắn, do đó có tên như vậy. Nó được thiết kế bởi
nhà mật mã học Daniel J. Bernstein và Jean-Philippe Aumasson. Nó được dự định
thay thế cho một số mục đích sử dụng: ZZ0000ZZ, ZZ0001ZZ, ZZ0002ZZ,
vân vân.

SipHash lấy một khóa bí mật chứa các số được tạo ngẫu nhiên và
một bộ đệm đầu vào hoặc một số số nguyên đầu vào. Nó phun ra một số nguyên là
không thể phân biệt được với ngẫu nhiên. Sau đó bạn có thể sử dụng số nguyên đó như một phần của bảo mật
số thứ tự, cookie bảo mật hoặc ẩn nó để sử dụng trong bảng băm.

Tạo khóa
================

Khóa phải luôn được tạo từ nguồn mã hóa an toàn
số ngẫu nhiên, sử dụng get_random_bytes hoặc get_random_once::

khóa siphash_key_t;
	get_random_bytes(&key, sizeof(key));

Nếu bạn không lấy được chìa khóa từ đây thì bạn đã làm sai.

Sử dụng các chức năng
===================

Có hai biến thể của hàm, một biến thể lấy danh sách các số nguyên và
một cái có bộ đệm ::

u64 siphash(const void *data, size_t len, const siphash_key_t *key);

Và::

u64 siphash_1u64(u64, const siphash_key_t *key);
	u64 siphash_2u64(u64, u64, const siphash_key_t *key);
	u64 siphash_3u64(u64, u64, u64, const siphash_key_t *key);
	u64 siphash_4u64(u64, u64, u64, u64, const siphash_key_t *key);
	u64 siphash_1u32(u32, const siphash_key_t *key);
	u64 siphash_2u32(u32, u32, const siphash_key_t *key);
	u64 siphash_3u32(u32, u32, u32, const siphash_key_t *key);
	u64 siphash_4u32(u32, u32, u32, u32, const siphash_key_t *key);

Nếu bạn truyền vào hàm siphash chung một cái gì đó có độ dài không đổi, thì nó
sẽ liên tục gấp vào thời gian biên dịch và tự động chọn một trong các
các chức năng được tối ưu hóa.

Cách sử dụng chức năng khóa có thể băm::

cấu trúc some_hashtable {
		DECLARE_HASHTABLE(bảng băm, 8);
		khóa siphash_key_t;
	};

void init_hashtable(struct some_hashtable *table)
	{
		get_random_bytes(&table->key, sizeof(table->key));
	}

nội tuyến tĩnh hlist_head *some_hashtable_bucket(struct some_hashtable *table, struct interest_input *input)
	{
		return &table->hashtable[siphash(input, sizeof(*input), &table->key) & (HASH_SIZE(table->hashtable) - 1)];
	}

Sau đó, bạn có thể lặp lại như bình thường đối với nhóm băm được trả về.

Bảo vệ
========

SipHash có mức độ bảo mật rất cao với khóa 128 bit. Miễn là
khóa được giữ bí mật, kẻ tấn công không thể đoán được kết quả đầu ra của
chức năng, ngay cả khi có thể quan sát nhiều đầu ra, vì 2^128 đầu ra
là đáng kể.

Linux triển khai biến thể "2-4" của SipHash.

Cạm bẫy chuyển cấu trúc
=======================

Thông thường, các hàm XuY sẽ không đủ lớn và thay vào đó bạn sẽ
muốn chuyển một cấu trúc được điền sẵn sang siphash. Khi thực hiện điều này, điều quan trọng
để luôn đảm bảo cấu trúc không có lỗ đệm. Cách dễ nhất để làm điều này
chỉ đơn giản là sắp xếp các thành viên của cấu trúc theo thứ tự kích thước giảm dần,
và sử dụng offsetofend() thay vì sizeof() để lấy kích thước. cho
lý do hiệu suất, nếu có thể, có lẽ việc điều chỉnh
struct đến ranh giới bên phải. Đây là một ví dụ::

cấu trúc const {
		struct in6_addr saddr;
		quầy u32;
		cổng u16;
	} __aligned(SIPHASH_ALIGNMENT) kết hợp = {
		.saddr = ZZ0000ZZ)saddr,
		.counter = bộ đếm,
		.dport = dport
	};
	u64 h = siphash(&combined, offsetofend(typeof(combined), dport), &secret);

Tài nguyên
=========

Đọc bài báo SipHash nếu bạn muốn tìm hiểu thêm:
ZZ0000ZZ

-------------------------------------------------------------------------------

====================================================
HalfSipHash - Em họ không an toàn của SipHash
===============================================

:Tác giả: Viết bởi Jason A. Donenfeld <jason@zx2c4.com>

Trong trường hợp SipHash không đủ nhanh cho nhu cầu của bạn, bạn có thể
có thể biện minh cho việc sử dụng HalfSipHash, một công cụ đáng sợ nhưng có khả năng hữu ích
khả năng. HalfSipHash cắt số vòng của SipHash từ "2-4" xuống "1-3" và,
thậm chí còn đáng sợ hơn, sử dụng khóa 64-bit dễ dàng bị cưỡng bức (với đầu ra 32-bit)
thay vì khóa 128-bit của SipHash. Tuy nhiên, điều này có thể hấp dẫn một số
người dùng ZZ0000ZZ hiệu suất cao.

Hỗ trợ HalfSipHash được cung cấp thông qua nhóm chức năng "hsiphash".

.. warning::
   Do not ever use the hsiphash functions except for as a hashtable key
   function, and only then when you can be absolutely certain that the outputs
   will never be transmitted out of the kernel. This is only remotely useful
   over `jhash` as a means of mitigating hashtable flooding denial of service
   attacks.

Trên hạt nhân 64-bit, các hàm hsiphash thực sự triển khai SipHash-1-3, một
biến thể rút gọn của SipHash, thay vì HalfSipHash-1-3. Điều này là do trong
Mã 64 bit, SipHash-1-3 không chậm hơn HalfSipHash-1-3 và có thể nhanh hơn.
Lưu ý, điều này ZZ0000ZZ có nghĩa là trong hạt nhân 64-bit, các hàm hsiphash là
giống như siphash, hoặc chúng an toàn; chức năng hsiphash vẫn còn
sử dụng thuật toán rút gọn vòng kém an toàn hơn và cắt bớt kết quả đầu ra của chúng xuống còn 32
bit.

Tạo khóa hsiphash
=========================

Khóa phải luôn được tạo từ nguồn mã hóa an toàn
số ngẫu nhiên, sử dụng get_random_bytes hoặc get_random_once::

khóa hsiphash_key_t;
	get_random_bytes(&key, sizeof(key));

Nếu bạn không lấy được chìa khóa từ đây thì bạn đã làm sai.

Sử dụng hàm hsiphash
============================

Có hai biến thể của hàm, một biến thể lấy danh sách các số nguyên và
một cái có bộ đệm ::

u32 hsiphash(const void *data, size_t len, const hsiphash_key_t *key);

Và::

u32 hsiphash_1u32(u32, const hsiphash_key_t *key);
	u32 hsiphash_2u32(u32, u32, const hsiphash_key_t *key);
	u32 hsiphash_3u32(u32, u32, u32, const hsiphash_key_t *key);
	u32 hsiphash_4u32(u32, u32, u32, u32, const hsiphash_key_t *key);

Nếu bạn truyền hàm hsiphash chung vào một cái gì đó có độ dài không đổi, thì nó
sẽ liên tục gấp vào thời gian biên dịch và tự động chọn một trong các
các chức năng được tối ưu hóa.

Cách sử dụng chức năng khóa có thể băm
============================

::

cấu trúc some_hashtable {
		DECLARE_HASHTABLE(bảng băm, 8);
		khóa hsiphash_key_t;
	};

void init_hashtable(struct some_hashtable *table)
	{
		get_random_bytes(&table->key, sizeof(table->key));
	}

nội tuyến tĩnh hlist_head *some_hashtable_bucket(struct some_hashtable *table, struct interest_input *input)
	{
		return &table->hashtable[hsiphash(input, sizeof(*input), &table->key) & (HASH_SIZE(table->hashtable) - 1)];
	}

Sau đó, bạn có thể lặp lại như bình thường đối với nhóm băm được trả về.

Hiệu suất
===========

hsiphash() chậm hơn khoảng 3 lần so với jhash(). Đối với nhiều sự thay thế, điều này
sẽ không thành vấn đề vì việc tra cứu có thể băm không phải là nút cổ chai. Và trong
Nói chung, đây có lẽ là một sự hy sinh tốt cho vấn đề bảo mật và DoS
sức đề kháng của hsiphash().
