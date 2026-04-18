.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/arch/arm/kernel_user_helpers.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

==============================================
Trình trợ giúp người dùng do hạt nhân cung cấp
==============================================

Đây là phân đoạn kernel được cung cấp mã người dùng có thể truy cập từ không gian người dùng
tại một địa chỉ cố định trong bộ nhớ kernel.  Điều này được sử dụng để cung cấp không gian cho người dùng
với một số thao tác cần sự trợ giúp của kernel do chưa được triển khai
tính năng gốc và/hoặc hướng dẫn trong nhiều CPU ARM. Ý tưởng là dành cho việc này
mã được thực thi trực tiếp trong chế độ người dùng để có hiệu quả tốt nhất nhưng đó là
quá thân mật với phần bộ đếm kernel nên được để lại cho thư viện người dùng.
Trên thực tế, mã này thậm chí có thể khác nhau từ mã CPU này sang mã CPU khác tùy thuộc vào
tập lệnh có sẵn hay đó là hệ thống SMP. Ở nơi khác
từ, kernel có quyền thay đổi mã này khi cần thiết mà không cần
cảnh báo. Chỉ các điểm vào và kết quả của chúng như được ghi lại ở đây là
đảm bảo ổn định.

Điều này khác với (nhưng không loại trừ) VDSO hoàn chỉnh
Tuy nhiên, việc triển khai VDSO sẽ ngăn chặn một số thủ thuật lắp ráp với
các hằng số cho phép phân nhánh hiệu quả tới các đoạn mã đó. Và
vì các đoạn mã đó chỉ sử dụng một vài chu kỳ trước khi quay lại người dùng
mã, chi phí chung của cuộc gọi xa gián tiếp VDSO sẽ thêm một giá trị có thể đo lường được
chi phí cho các hoạt động tối giản như vậy.

Không gian người dùng dự kiến sẽ bỏ qua những người trợ giúp đó và thực hiện những điều đó
nội tuyến (trong mã do trình biên dịch phát ra trực tiếp hoặc một phần của
việc thực hiện lệnh gọi thư viện) khi tối ưu hóa cho một khoảng thời gian đủ gần đây
bộ xử lý có sự hỗ trợ riêng cần thiết, nhưng chỉ khi kết quả
các tệp nhị phân đã không tương thích với các bộ xử lý ARM trước đó do
việc sử dụng các hướng dẫn gốc tương tự cho những thứ khác.  Nói cách khác
đừng làm cho các tệp nhị phân không thể chạy trên các bộ xử lý cũ hơn chỉ vì mục đích
không sử dụng những trình trợ giúp kernel này nếu mã được biên dịch của bạn không hoạt động
sử dụng hướng dẫn mới cho mục đích khác.

Những trợ giúp mới có thể được thêm vào theo thời gian, do đó kernel cũ hơn có thể thiếu một số
những người trợ giúp có trong kernel mới hơn.  Vì lý do này, các chương trình phải kiểm tra
giá trị của __kuser_helper_version (xem bên dưới) trước khi cho rằng đó là
an toàn để gọi bất kỳ người trợ giúp cụ thể nào.  Việc kiểm tra này lý tưởng nhất là nên
chỉ được thực hiện một lần tại thời điểm khởi động quy trình và việc thực thi bị hủy bỏ sớm
nếu những trợ giúp cần thiết không được cung cấp bởi phiên bản kernel
quá trình đang chạy.

kuser_helper_version
--------------------

Vị trí: 0xffff0ffc

Khai báo tham khảo::

bên ngoài int32_t __kuser_helper_version;

Sự định nghĩa:

Trường này chứa số lượng người trợ giúp đang được triển khai bởi
  chạy hạt nhân.  Không gian người dùng có thể đọc phần này để xác định tính khả dụng
  của một người trợ giúp cụ thể.

Ví dụ sử dụng::

#define __kuser_helper_version (ZZ0000ZZ)0xffff0ffc)

void check_kuser_version(void)
  {
	nếu (__kuser_helper_version < 2) {
		fprintf(stderr, "không thể thực hiện các thao tác nguyên tử, kernel quá cũ\n");
		hủy bỏ();
	}
  }

Ghi chú:

Không gian người dùng có thể cho rằng giá trị của trường này không bao giờ thay đổi
  trong suốt thời gian tồn tại của bất kỳ quá trình đơn lẻ nào.  Điều này có nghĩa là điều này
  trường có thể được đọc một lần trong quá trình khởi tạo thư viện hoặc
  giai đoạn khởi động của một chương trình.

kuser_get_tls
-------------

Vị trí: 0xffff0fe0

Nguyên mẫu tham khảo::

void * __kuser_get_tls(void);

đầu vào:

lr = địa chỉ trả lại

Đầu ra:

r0 = giá trị TLS

Các thanh ghi bị chặn:

không có

Sự định nghĩa:

Nhận giá trị TLS như đã đặt trước đó thông qua tòa nhà chọc trời __ARM_NR_set_tls.

Ví dụ sử dụng::

typedef void * (__kuser_get_tls_t)(void);
  #define __kuser_get_tls (ZZ0000ZZ)0xffff0fe0)

khoảng trống foo()
  {
	void *tls = __kuser_get_tls();
	printf("TLS = %p\n", tls);
  }

Ghi chú:

- Chỉ hợp lệ nếu __kuser_helper_version >= 1 (từ phiên bản kernel 2.6.12).

kuser_cmpxchg
-------------

Vị trí: 0xffff0fc0

Nguyên mẫu tham khảo::

int __kuser_cmpxchg(int32_t oldval, int32_t newval, int32_t dễ bay hơi *ptr);

đầu vào:

r0 = giá trị cũ
  r1 = giá trị mới
  r2 = ptr
  lr = địa chỉ trả lại

Đầu ra:

r0 = mã thành công (không hoặc khác 0)
  Cờ C = đặt nếu r0 == 0, xóa nếu r0 != 0

Các thanh ghi bị chặn:

r3, ip, cờ

Sự định nghĩa:

Chỉ lưu trữ newval trong ZZ0000ZZ nếu ZZ0001ZZ bằng oldval.
  Trả về 0 nếu ZZ0002ZZ bị thay đổi hoặc khác 0 nếu không có trao đổi nào xảy ra.
  Cờ C cũng được đặt nếu ZZ0003ZZ được thay đổi để cho phép lắp ráp
  tối ưu hóa trong mã gọi.

Ví dụ sử dụng::

typedef int (__kuser_cmpxchg_t)(int oldval, int newval, int dễ bay hơi *ptr);
  #define __kuser_cmpxchg (ZZ0000ZZ)0xffff0fc0)

int Atomic_add(dễ bay hơi int *ptr, int val)
  {
	int cũ, mới;

làm {
		cũ = *ptr;
		mới = cũ + giá trị;
	} while(__kuser_cmpxchg(cũ, mới, ptr));

trả lại mới;
  }

Ghi chú:

- Thói quen này đã bao gồm các rào cản về trí nhớ nếu cần.

- Chỉ hợp lệ nếu __kuser_helper_version >= 2 (từ phiên bản kernel 2.6.12).

kuser_memory_barrier
--------------------

Vị trí: 0xffff0fa0

Nguyên mẫu tham khảo::

void __kuser_memory_barrier(void);

đầu vào:

lr = địa chỉ trả lại

Đầu ra:

không có

Các thanh ghi bị chặn:

không có

Sự định nghĩa:

Áp dụng bất kỳ rào cản bộ nhớ cần thiết nào để duy trì tính nhất quán với dữ liệu đã sửa đổi
  manually and __kuser_cmpxchg usage.

Ví dụ sử dụng::

typedef void (__kuser_dmb_t)(void);
  #define __kuser_dmb (ZZ0000ZZ)0xffff0fa0)

Ghi chú:

- Chỉ hợp lệ nếu __kuser_helper_version >= 3 (từ phiên bản kernel 2.6.15).

kuser_cmpxchg64
---------------

Vị trí: 0xffff0f60

Nguyên mẫu tham khảo::

int __kuser_cmpxchg64(const int64_t *oldval,
                        const int64_t *newval,
                        dễ bay hơi int64_t *ptr);

đầu vào:

r0 = con trỏ tới oldval
  r1 = con trỏ tới newval
  r2 = con trỏ tới giá trị đích
  lr = địa chỉ trả lại

Đầu ra:

r0 = mã thành công (không hoặc khác 0)
  Cờ C = đặt nếu r0 == 0, xóa nếu r0 != 0

Các thanh ghi bị chặn:

r3, lr, cờ

Sự định nghĩa:

Lưu trữ nguyên tử giá trị 64 bit được trỏ bởi ZZ0000ZZ trong ZZ0001ZZ chỉ khi ZZ0002ZZ
  bằng giá trị 64 bit được chỉ bởi ZZ0003ZZ.  Trả về 0 nếu ZZ0004ZZ là
  đã thay đổi hoặc khác 0 nếu không có trao đổi nào xảy ra.

Cờ C cũng được đặt nếu ZZ0000ZZ được thay đổi để cho phép lắp ráp
  tối ưu hóa trong mã gọi.

Ví dụ sử dụng::

typedef int (__kuser_cmpxchg64_t)(const int64_t *oldval,
                                    const int64_t *newval,
                                    dễ bay hơi int64_t *ptr);
  #define __kuser_cmpxchg64 (ZZ0000ZZ)0xffff0f60)

int64_t Atomic_add64(dễ bay hơi int64_t *ptr, int64_t val)
  {
	int64_t cũ, mới;

làm {
		cũ = *ptr;
		mới = cũ + giá trị;
	} while(__kuser_cmpxchg64(&cũ, &mới, ptr));

trả lại mới;
  }

Ghi chú:

- Thói quen này đã bao gồm các rào cản về trí nhớ nếu cần.

- Do độ dài của chuỗi này, chuỗi này kéo dài 2 kuser thông thường
    "khe", do đó 0xffff0f80 không được sử dụng làm điểm vào hợp lệ.

- Chỉ hợp lệ nếu __kuser_helper_version >= 5 (từ phiên bản kernel 3.1).
