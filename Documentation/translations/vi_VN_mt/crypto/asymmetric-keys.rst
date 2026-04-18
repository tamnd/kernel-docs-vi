.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/crypto/asymmetric-keys.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=================================================
Loại khóa mật mã khóa công khai/bất đối xứng
=================================================

.. Contents:

  - Overview.
  - Key identification.
  - Accessing asymmetric keys.
    - Signature verification.
  - Asymmetric key subtypes.
  - Instantiation data parsers.
  - Keyring link restrictions.


Tổng quan
=========

Loại khóa "bất đối xứng" được thiết kế để chứa các khóa được sử dụng trong
mật mã khóa công khai mà không áp đặt bất kỳ hạn chế cụ thể nào đối với
hình thức hoặc cơ chế của mật mã hoặc hình thức của khóa.

Khóa bất đối xứng được cung cấp một kiểu con xác định loại dữ liệu
được liên kết với khóa và cung cấp các thao tác để mô tả và hủy khóa đó.
Tuy nhiên, không có yêu cầu nào được đưa ra rằng dữ liệu chính thực sự được lưu trữ trong
chìa khóa.

Một kiểu con hoạt động và lưu giữ khóa hoàn toàn trong kernel có thể được xác định, nhưng
cũng có thể cung cấp quyền truy cập vào phần cứng mật mã (chẳng hạn như
TPM) có thể được sử dụng để giữ lại khóa liên quan và thực hiện
thao tác sử dụng phím đó.  Trong trường hợp như vậy, khóa bất đối xứng sẽ
chỉ đơn thuần là một giao diện cho trình điều khiển TPM.

Cũng được cung cấp là khái niệm về trình phân tích cú pháp dữ liệu.  Người phân tích dữ liệu có trách nhiệm
để trích xuất thông tin từ các khối dữ liệu được chuyển đến phần khởi tạo
chức năng.  Trình phân tích cú pháp dữ liệu đầu tiên nhận ra blob sẽ thiết lập
kiểu con của khóa và xác định các thao tác có thể thực hiện trên khóa đó.

Trình phân tích cú pháp dữ liệu có thể diễn giải blob dữ liệu có chứa các bit đại diện cho một
khóa hoặc nó có thể diễn giải nó như một tham chiếu đến khóa được giữ ở một nơi khác trong
hệ thống (ví dụ: TPM).


Nhận dạng khóa
==================

Nếu một khóa được thêm với tên trống, trình phân tích cú pháp dữ liệu khởi tạo sẽ được cung cấp
cơ hội phân tích trước khóa và xác định mô tả khóa
nên được đưa ra từ nội dung của khóa.

Sau đó, điều này có thể được sử dụng để tham chiếu tới khóa, bằng cách khớp hoàn toàn hoặc bằng
khớp một phần.  Loại khóa cũng có thể sử dụng các tiêu chí khác để tham chiếu đến khóa.

Khi đó, chức năng khớp của loại khóa bất đối xứng có thể thực hiện phạm vi rộng hơn
so sánh hơn là chỉ so sánh đơn giản mô tả với
chuỗi tiêu chí:

1) Nếu chuỗi tiêu chí có dạng "id:<hexdigits>" thì kết quả khớp
     sẽ kiểm tra dấu vân tay của khóa để xem liệu các chữ số hex đã cho có
     sau "id:" khớp với đuôi.  Ví dụ::

tìm kiếm keyctl @s id bất đối xứng: 5acc2142

sẽ khớp một khóa với dấu vân tay::

1A00 2040 7601 7889 DE11 882C 3823 04AD 5ACC 2142

2) Nếu chuỗi tiêu chí có dạng "<subtype>:<hexdigits>" thì
     match sẽ khớp với ID như trong (1), nhưng có thêm hạn chế
     chỉ các khóa của loại phụ được chỉ định (ví dụ: tpm) mới được khớp.  cho
     ví dụ::

tìm kiếm keyctl @s bất đối xứng tpm:5acc2142

Nhìn vào /proc/keys, 8 chữ số thập lục phân cuối cùng của dấu vân tay chính là
được hiển thị, cùng với kiểu con::

1a39e171 I------ 1 perm 3f010000 0 0 modsign bất đối xứng.0: DSA 5acc2142 []


Truy cập các khóa bất đối xứng
==============================

Để truy cập chung vào các khóa bất đối xứng từ bên trong kernel, cách sau
bắt buộc phải đưa vào::

#include <crypto/public_key.h>

Điều này cho phép truy cập vào các chức năng để xử lý khóa bất đối xứng/khóa chung.
Ba enum được xác định ở đó để thể hiện mật mã khóa công khai
thuật toán::

enum pkey_algo

thuật toán tiêu hóa được sử dụng bởi những người::

enum pkey_hash_algo

và các biểu diễn định danh chính::

enum pkey_id_type

Lưu ý rằng các kiểu biểu diễn kiểu khóa là bắt buộc vì khóa
số nhận dạng từ các tiêu chuẩn khác nhau không nhất thiết phải tương thích.  cho
Ví dụ: PGP tạo mã định danh khóa bằng cách băm dữ liệu khóa cộng với một số
Siêu dữ liệu dành riêng cho PGP, trong khi X.509 có số nhận dạng chứng chỉ tùy ý.

Các hoạt động được xác định trên một khóa là:

1) Xác minh chữ ký.

Có thể thực hiện các hoạt động khác (chẳng hạn như mã hóa) với cùng dữ liệu chính
cần thiết để xác minh, nhưng hiện không được hỗ trợ và những thứ khác
(ví dụ: giải mã và tạo chữ ký) yêu cầu dữ liệu khóa bổ sung.


Xác minh chữ ký
----------------------

Một thao tác được cung cấp để thực hiện xác minh chữ ký mật mã, sử dụng
một khóa bất đối xứng để cung cấp hoặc cung cấp quyền truy cập vào khóa chung::

int verify_signature(const struct key *key,
			     const struct public_key_signature *sig);

Người gọi phải đã lấy được khóa từ một nguồn nào đó và sau đó có thể sử dụng
nó để kiểm tra chữ ký.  Người gọi phải phân tích chữ ký và
đã chuyển các bit liên quan tới cấu trúc được chỉ ra bởi sig::

cấu trúc public_key_signature {
		u8 *tiêu hóa;
		u8 dig_size;
		enum pkey_hash_algo pkey_hash_algo : 8;
		u8 nr_mpi;
		công đoàn {
			MPI mpi[2];
			...
		};
	};

Thuật toán được sử dụng phải được ghi chú trong sig->pkey_hash_algo và tất cả MPI
chữ ký thực tế phải được lưu trữ trong sig->mpi[] và số lượng MPI
được đặt trong sig->nr_mpi.

Ngoài ra, dữ liệu phải được người gọi xử lý và kết quả là
hàm băm phải được trỏ tới bởi sig->digest và kích thước của hàm băm được đặt trong
sig->digest_size.

Hàm sẽ trả về 0 khi thành công hoặc -EKEYREJECTED nếu chữ ký
không khớp.

Hàm cũng có thể trả về -ENOTSUPP nếu thuật toán khóa chung không được hỗ trợ
hoặc kết hợp thuật toán băm/khóa công khai được chỉ định hoặc khóa không
hỗ trợ hoạt động; -EBADMSG hoặc -ERANGE nếu một số thông số có dấu hiệu lạ
dữ liệu; hoặc -ENOMEM nếu việc phân bổ không thể thực hiện được.  -EINVAL có thể được trả lại
nếu đối số chính sai loại hoặc được thiết lập không đầy đủ.


Các kiểu con khóa bất đối xứng
==============================

Khóa bất đối xứng có một kiểu con xác định tập hợp các thao tác có thể được thực hiện
được thực hiện trên khóa đó và xác định dữ liệu nào được đính kèm làm khóa
tải trọng.  Định dạng tải trọng hoàn toàn tùy ý thích của loại phụ.

Loại phụ được chọn bởi trình phân tích cú pháp dữ liệu chính và trình phân tích cú pháp phải khởi tạo
dữ liệu cần thiết cho nó.  Khóa bất đối xứng giữ lại một tham chiếu trên
mô-đun kiểu phụ.

Cấu trúc định nghĩa kiểu con có thể được tìm thấy trong::

#include <phím/bất đối xứng-subtype.h>

và trông giống như sau::

cấu trúc bất đối xứng_key_subtype {
		mô-đun cấu trúc * chủ sở hữu;
		const char *tên;

khoảng trống (*describe)(const struct key *key, struct seq_file *m);
		khoảng trống (tải trọng *destroy)(void *);
		int (*query)(const struct kernel_pkey_params *params,
			     struct kernel_pkey_query *thông tin);
		int (*eds_op)(struct kernel_pkey_params *params,
			      const void *in, void *out);
		int (*verify_signature)(const struct key *key,
					const struct public_key_signature *sig);
	};

Các khóa bất đối xứng chỉ ra điều này với thành viên payload[asym_subtype] của chúng.

Các trường chủ sở hữu và tên phải được đặt thành mô-đun sở hữu và tên của
kiểu phụ.  Hiện tại, tên này chỉ được sử dụng cho các câu lệnh in.

Có một số hoạt động được xác định bởi kiểu con:

1) mô tả().

Bắt buộc.  Điều này cho phép kiểu con hiển thị nội dung nào đó trong /proc/keys
     chống lại chìa khóa.  Ví dụ: tên của loại thuật toán khóa công khai
     có thể được hiển thị  Kiểu key sẽ hiển thị đuôi phím
     chuỗi nhận dạng sau này.

2) hủy().

Bắt buộc.  Điều này sẽ giải phóng bộ nhớ liên quan đến khóa.  các
     khóa bất đối xứng sẽ đảm nhiệm việc giải phóng dấu vân tay và giải phóng
     tham chiếu trên mô-đun kiểu con.

3) truy vấn().

Bắt buộc.  Đây là một chức năng để truy vấn các khả năng của một khóa.

4) eds_op().

Không bắt buộc.  Đây là điểm vào cho quá trình mã hóa, giải mã và
     hoạt động tạo chữ ký (được phân biệt bằng ID hoạt động
     trong cấu trúc tham số).  Loại phụ có thể làm bất cứ điều gì nó thích
     thực hiện một hoạt động, bao gồm cả việc giảm tải cho phần cứng.

5) verify_signature().

Không bắt buộc.  Đây là điểm vào để xác minh chữ ký.  các
     kiểu con có thể làm bất cứ điều gì nó thích để thực hiện một thao tác, bao gồm
     giảm tải cho phần cứng.

Trình phân tích dữ liệu khởi tạo
================================

Loại khóa bất đối xứng thường không muốn lưu trữ hoặc xử lý dữ liệu thô
đốm dữ liệu chứa dữ liệu quan trọng.  Nó sẽ phải phân tích nó và báo lỗi
kiểm tra nó mỗi lần nó muốn sử dụng nó.  Hơn nữa, nội dung của blob có thể
có nhiều cách kiểm tra khác nhau có thể được thực hiện trên đó (ví dụ: tự ký, tính hợp lệ
ngày) và có thể chứa dữ liệu hữu ích về khóa (số nhận dạng, khả năng).

Ngoài ra, đốm màu có thể biểu thị một con trỏ tới một số phần cứng chứa khóa
chứ không phải là chính chìa khóa.

Ví dụ về các định dạng blob mà trình phân tích cú pháp có thể được triển khai bao gồm:

- Luồng gói OpenPGP [RFC 4880].
 - Luồng X.509 ASN.1.
 - Con trỏ tới phím TPM.
 - Con trỏ tới phím UEFI.
 - Khóa riêng PKCS#8 [RFC 5208].
 - Khóa riêng được mã hóa PKCS#5 [RFC 2898].

Trong quá trình khởi tạo khóa, mỗi trình phân tích cú pháp trong danh sách sẽ được thử cho đến khi không còn trình phân tích cú pháp nào nữa.
trả về -EBADMSG.

Cấu trúc định nghĩa trình phân tích cú pháp có thể được tìm thấy trong::

#include <keys/aĐối xứng-parser.h>

và trông giống như sau::

cấu trúc bất đối xứng_key_parser {
		mô-đun cấu trúc * chủ sở hữu;
		const char *tên;

int (*parse)(struct key_preparsed_payload *prep);
	};

Các trường chủ sở hữu và tên phải được đặt thành mô-đun sở hữu và tên của
trình phân tích cú pháp.

Hiện tại chỉ có một thao tác duy nhất được xác định bởi trình phân tích cú pháp và đó là
bắt buộc:

1) phân tích cú pháp().

Lệnh này được gọi để chuẩn bị khóa từ đường dẫn tạo và cập nhật khóa.
     Đặc biệt, nó được gọi trong quá trình tạo khóa _trước_ một khóa được
     được phân bổ và do đó được phép cung cấp mô tả của khóa trong
     trường hợp người gọi từ chối thực hiện.

Người gọi chuyển một con trỏ tới cấu trúc sau với tất cả các trường
     đã được xóa, ngoại trừ dữ liệu, datalen và Quatelen [xem
     Tài liệu/bảo mật/khóa/core.rst]::

cấu trúc key_preparsed_payload {
		char *mô tả;
		void *tải trọng[4];
		const void *dữ liệu;
		dữ liệu size_t;
		size_t hạn ngạch;
	};

Dữ liệu khởi tạo nằm trong một blob được trỏ tới bởi dữ liệu và được lưu trữ trong
     kích thước.  Hàm phân tích cú pháp () không được phép thay đổi hai giá trị này tại
     tất cả và không nên thay đổi bất kỳ giá trị nào khác _trừ khi_ chúng
     nhận ra định dạng blob và sẽ không trả về -EBADMSG để cho biết đó là
     không phải của họ.

Nếu trình phân tích cú pháp hài lòng với blob, nó sẽ đề xuất một mô tả cho
     khóa và đính kèm nó vào ->description, ->payload[asym_subtype] phải là
     được đặt để trỏ đến loại phụ sẽ được sử dụng, ->payload[asym_crypto] phải là
     được đặt để trỏ đến dữ liệu khởi tạo cho kiểu con đó,
     ->payload[asym_key_ids] phải trỏ đến một hoặc nhiều dấu vân tay hex và
     Quorlen phải được cập nhật để cho biết khóa này sẽ có bao nhiêu hạn ngạch
     tính đến.

Khi xóa, dữ liệu được đính kèm ->payload[asym_key_ids] và
     ->mô tả sẽ là kfree()'d và dữ liệu được đính kèm
     ->payload[asm_crypto] sẽ được chuyển tới phương thức ->destroy() của kiểu con
     để được xử lý.  Một tham chiếu mô-đun cho kiểu con được trỏ tới bởi
     ->payload[asym_subtype] sẽ được đặt.


Nếu định dạng dữ liệu không được nhận dạng, -EBADMSG sẽ được trả về.  Nếu nó
     được nhận dạng, nhưng vì lý do nào đó, khóa không thể được thiết lập, một số lý do khác
     mã lỗi tiêu cực phải được trả lại.  Khi thành công, 0 sẽ được trả về.

Chuỗi dấu vân tay của khóa có thể được khớp một phần.  Đối với một
     thuật toán khóa công khai như RSA và DSA, đây có thể sẽ là một thuật toán có thể in được
     phiên bản hex của dấu vân tay của chìa khóa.

Các chức năng được cung cấp để đăng ký và hủy đăng ký trình phân tích cú pháp ::

int register_a Đối xứng_key_parser(cấu trúc bất đối xứng_key_parser *trình phân tích cú pháp);
	void unregister_a Đối xứng_key_parser(cấu trúc bất đối xứng_key_parser *kiểu con);

Trình phân tích cú pháp có thể không có cùng tên.  Các tên khác chỉ được sử dụng cho
hiển thị trong thông báo gỡ lỗi.


Hạn chế liên kết khóa
=========================

Chuỗi khóa được tạo từ không gian người dùng bằng add_key có thể được định cấu hình để kiểm tra
chữ ký của khóa được liên kết.  Các khóa không có chữ ký hợp lệ thì không
được phép liên kết.

Một số phương pháp hạn chế có sẵn:

1) Hạn chế sử dụng khóa đáng tin cậy dựng sẵn trong kernel

- Chuỗi tùy chọn sử dụng với KEYCTL_RESTRICT_KEYRING:
       - "buildin_trusted"

Khóa đáng tin cậy dựng sẵn trong kernel sẽ được tìm kiếm để tìm khóa ký.
     Nếu khóa đáng tin cậy dựng sẵn không được định cấu hình thì tất cả các liên kết sẽ bị
     bị từ chối.  Tham số kernel ca_keys cũng ảnh hưởng đến khóa nào được sử dụng
     để xác minh chữ ký.

2) Hạn chế sử dụng kernel dựng sẵn và chuỗi khóa đáng tin cậy thứ cấp

- Chuỗi tùy chọn sử dụng với KEYCTL_RESTRICT_KEYRING:
       - "buildin_and_secondary_trusted"

Nội dung kernel và chuỗi khóa đáng tin cậy thứ cấp sẽ được tìm kiếm
     khóa ký.  Nếu khóa đáng tin cậy thứ cấp không được định cấu hình, điều này
     hạn chế sẽ hoạt động giống như tùy chọn "buildin_trusted".  các ca_keys
     Tham số kernel cũng ảnh hưởng đến khóa nào được sử dụng cho chữ ký
     xác minh.

3) Hạn chế sử dụng chìa khóa hoặc móc khóa riêng

- Chuỗi tùy chọn sử dụng với KEYCTL_RESTRICT_KEYRING:
       - "key_or_keyring:<số sê-ri chìa khóa hoặc vòng khóa>[:chain]"

Bất cứ khi nào một liên kết khóa được yêu cầu, liên kết sẽ chỉ thành công nếu khóa
     được liên kết được ký bởi một trong các khóa được chỉ định.  Chìa khóa này có thể
     được chỉ định trực tiếp bằng cách cung cấp số sê-ri cho một khóa bất đối xứng hoặc
     một nhóm khóa có thể được tìm kiếm khóa ký bằng cách cung cấp
     số sê-ri cho một chiếc móc khóa.

Khi tùy chọn "chuỗi" được cung cấp ở cuối chuỗi, các phím
     trong vòng khóa đích cũng sẽ được tìm kiếm để tìm khóa ký.
     Điều này cho phép xác minh chuỗi chứng chỉ bằng cách thêm từng chuỗi
     chứng chỉ theo thứ tự (bắt đầu gần nhất với thư mục gốc) vào một chuỗi khóa.  cho
     Ví dụ, một khóa có thể được điền với các liên kết đến một tập hợp gốc
     chứng chỉ, với một khóa riêng biệt, hạn chế được thiết lập cho mỗi chứng chỉ
     chuỗi chứng chỉ cần được xác thực::

# Create và điền khóa cho chứng chỉ gốc
	root_id=ZZ0000ZZ
	keyctl padd bất đối xứng "" $root_id < root1.cert
	keyctl padd bất đối xứng "" $root_id < root2.cert

# Create và hạn chế khóa cho chuỗi chứng chỉ
	chuỗi_id=ZZ0000ZZ
	keyctl limit_keyring $chain_id bất đối xứng key_or_keyring:$root_id:chain

# Attempt để thêm từng chứng chỉ vào chuỗi, bắt đầu bằng
	# certificate gần gốc nhất.
	keyctl padd bất đối xứng "" $chain_id < trung gianA.cert
	keyctl padd bất đối xứng "" $chain_id < trung gianB.cert
	keyctl padd bất đối xứng "" $chain_id < end-entity.cert

Nếu chứng chỉ thực thể cuối cùng được thêm thành công vào "chuỗi"
     keyring, chúng ta có thể chắc chắn rằng nó có chuỗi ký hợp lệ quay trở lại
     một trong những chứng chỉ gốc.

Một khóa đơn có thể được sử dụng để xác minh một chuỗi chữ ký bằng cách
     hạn chế khóa sau khi liên kết chứng chỉ gốc::

# Create một khóa cho chuỗi chứng chỉ và thêm gốc
	chuỗi2_id=ZZ0000ZZ
	keyctl padd bất đối xứng "" $chain2_id < root1.cert

# Restrict khóa đã được liên kết root1.cert.  Chứng chỉ
	# will vẫn được liên kết bằng móc khóa.
	keyctl limit_keyring $chain2_id bất đối xứng key_or_keyring:0:chain

# Attempt để thêm từng chứng chỉ vào chuỗi, bắt đầu bằng
	# certificate gần gốc nhất.
	keyctl padd bất đối xứng "" $chain2_id < trung gianA.cert
	keyctl padd bất đối xứng "" $chain2_id < trung gianB.cert
	keyctl padd bất đối xứng "" $chain2_id < end-entity.cert

Nếu chứng chỉ thực thể cuối cùng được thêm thành công vào "chain2"
     keyring, chúng ta có thể chắc chắn rằng có một chuỗi ký hợp lệ quay trở lại
     vào chứng chỉ gốc đã được thêm trước khi khóa bị hạn chế.


Trong tất cả các trường hợp này, nếu tìm thấy khóa ký thì chữ ký của khóa
được liên kết sẽ được xác minh bằng khóa ký.  Khóa được yêu cầu đã được thêm
chỉ đến móc khóa nếu chữ ký được xác minh thành công.  -ENOKEY là
được trả về nếu không tìm thấy chứng chỉ gốc hoặc -EKEYREJECTED là
được trả về nếu kiểm tra chữ ký không thành công hoặc khóa bị liệt vào danh sách đen.  Các lỗi khác
có thể được trả lại nếu việc kiểm tra chữ ký không thể thực hiện được.