.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/staging/remoteproc.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=============================
Khung xử lý từ xa
=============================

Giới thiệu
============

Các SoC hiện đại thường có các thiết bị xử lý từ xa không đồng nhất ở dạng không đối xứng
cấu hình đa xử lý (AMP), có thể đang chạy các phiên bản khác nhau
của hệ điều hành, cho dù đó là Linux hay bất kỳ phiên bản hệ điều hành thời gian thực nào khác.

Ví dụ: OMAP4 có Cortex-A9 kép, Cortex-M3 kép và C64x+ DSP.
Trong cấu hình thông thường, Cortex-A9 kép đang chạy Linux trên SMP
cấu hình và mỗi lõi trong số ba lõi còn lại (hai lõi M3 và DSP)
đang chạy phiên bản RTOS của riêng nó trong cấu hình AMP.

Khung remoteproc cho phép các nền tảng/kiến trúc khác nhau
điều khiển (bật nguồn, tải chương trình cơ sở, tắt nguồn) các bộ xử lý từ xa đó trong khi
trừu tượng hóa sự khác biệt về phần cứng, do đó toàn bộ trình điều khiển không cần phải
nhân đôi. Ngoài ra framework này còn bổ sung thêm các thiết bị RPMsg virtio
cho các bộ xử lý từ xa hỗ trợ kiểu giao tiếp này. Lối này,
trình điều khiển remoteproc dành riêng cho nền tảng chỉ cần cung cấp một số trình điều khiển cấp thấp
trình xử lý, và sau đó tất cả các trình điều khiển vòng/phút sẽ hoạt động
(để biết thêm thông tin về bus RPMSG dựa trên virtio và các trình điều khiển của nó,
vui lòng đọc Tài liệu/staging/rpmsg.rst).
Hiện nay, bạn cũng có thể đăng ký các loại thiết bị virtio khác. Phần mềm cơ sở
chỉ cần công bố loại thiết bị virtio nào họ hỗ trợ và sau đó
remoteproc sẽ thêm các thiết bị đó. Điều này cho phép tái sử dụng
trình điều khiển virtio hiện có với phần phụ trợ bộ xử lý từ xa ở mức phát triển tối thiểu
chi phí.

Người dùng API
==============

::

int rproc_boot(struct rproc *rproc)

Khởi động bộ xử lý từ xa (tức là tải chương trình cơ sở của nó, bật nguồn, ...).

Nếu bộ xử lý từ xa đã được bật nguồn, chức năng này sẽ ngay lập tức
trả về (thành công).

Trả về 0 nếu thành công và nếu không thì trả về giá trị lỗi thích hợp.
Lưu ý: để sử dụng chức năng này, bạn phải có rproc hợp lệ
xử lý. Có một số cách để đạt được điều đó một cách rõ ràng (devres, pdata,
cách remoteproc_rpmsg.c thực hiện điều này hoặc nếu điều này trở nên phổ biến, chúng tôi
cũng có thể cân nhắc sử dụng dev_archdata cho việc này).

::

int rproc_shutdown(struct rproc *rproc)

Tắt nguồn bộ xử lý từ xa (trước đó đã khởi động bằng rproc_boot()).
Trong trường hợp @rproc vẫn đang được sử dụng bởi (những) người dùng khác, thì
chức năng này sẽ chỉ giảm lượng điện năng đếm lại và thoát ra,
mà không thực sự tắt nguồn thiết bị.

Trả về 0 nếu thành công và nếu không thì trả về giá trị lỗi thích hợp.
Mọi lệnh gọi tới rproc_boot() (cuối cùng) phải kèm theo một lệnh gọi
tới rproc_shutdown(). Gọi rproc_shutdown() dư thừa là một lỗi.

.. note::

  we're not decrementing the rproc's refcount, only the power refcount.
  which means that the @rproc handle stays valid even after
  rproc_shutdown() returns, and users can still use it with a subsequent
  rproc_boot(), if needed.

::

struct rproc *rproc_get_by_phandle(phandle phẩn)

Tìm một tay cầm rproc bằng cách sử dụng phẩn cây thiết bị. Trả về rproc
xử lý thành công và NULL khi thất bại. Hàm này tăng
số lần đếm lại của bộ xử lý từ xa, vì vậy hãy luôn sử dụng rproc_put() để
giảm nó trở lại khi rproc không còn cần thiết nữa.

Cách sử dụng điển hình
======================

::

#include <linux/remoteproc.h>

/* trong trường hợp chúng tôi được cấp một mã điều khiển 'rproc' hợp lệ */
  int dummy_rproc_example(struct rproc *my_rproc)
  {
	int ret;

/* hãy bật nguồn và khởi động bộ xử lý từ xa của chúng ta */
	ret = rproc_boot(my_rproc);
	nếu (ret) {
		/*
		 * có gì đó không ổn. xử lý nó và rời đi.
		 */
	}

/*
	 * bộ xử lý từ xa của chúng tôi hiện đã được bật... hãy xử lý nó đi
	 */

/* hãy tắt nó đi bây giờ */
	rproc_shutdown(my_rproc);
  }

API dành cho người thực hiện
============================

::

struct rproc *rproc_alloc(struct device *dev, const char *name,
				const struct rproc_ops *ops,
				const char *firmware, int len)

Phân bổ một bộ xử lý từ xa mới, nhưng không đăng ký
nó chưa. Các tham số bắt buộc là thiết bị cơ bản,
tên của bộ xử lý từ xa này, trình xử lý hoạt động dành riêng cho nền tảng,
tên của chương trình cơ sở để khởi động rproc này và
độ dài của dữ liệu riêng tư cần thiết bởi trình điều khiển rproc phân bổ (tính bằng byte).

Chức năng này nên được sử dụng khi triển khai rproc trong
khởi tạo bộ xử lý từ xa.

Sau khi tạo một tay cầm rproc bằng hàm này và khi sẵn sàng,
việc triển khai sau đó sẽ gọi rproc_add() để hoàn thành
việc đăng ký bộ xử lý từ xa.

Nếu thành công, rproc mới sẽ được trả về và nếu thất bại, NULL.

.. note::

  **never** directly deallocate @rproc, even if it was not registered
  yet. Instead, when you need to unroll rproc_alloc(), use rproc_free().

::

void rproc_free(struct rproc *rproc)

Giải phóng bộ điều khiển rproc được phân bổ bởi rproc_alloc.

Về cơ bản, hàm này sẽ hủy kiểm soát rproc_alloc(), bằng cách giảm giá trị
rproc hoàn tiền. Nó không trực tiếp giải phóng rproc; điều đó sẽ xảy ra
chỉ khi không có tài liệu tham khảo nào khác về rproc và số tiền hoàn lại của nó bây giờ
giảm xuống bằng không.

::

int rproc_add(struct rproc *rproc)

Đăng ký @rproc với khung remoteproc, sau khi nó được
được phân bổ bằng rproc_alloc().

Điều này được gọi bằng cách triển khai rproc dành riêng cho nền tảng, bất cứ khi nào
một thiết bị xử lý từ xa mới được thăm dò.

Trả về 0 nếu thành công và nếu không thì trả về mã lỗi thích hợp.
Lưu ý: chức năng này bắt đầu tải chương trình cơ sở không đồng bộ
ngữ cảnh sẽ tìm kiếm các thiết bị virtio được hỗ trợ bởi rproc
phần sụn.

Nếu tìm thấy, những thiết bị virtio đó sẽ được tạo và thêm vào, do đó
đăng ký bộ xử lý từ xa này, các trình điều khiển virtio bổ sung có thể nhận được
đã thăm dò.

::

int rproc_del(struct rproc *rproc)

Bỏ đăng ký rproc_add().

Hàm này nên được gọi khi rproc cụ thể của nền tảng
việc triển khai quyết định loại bỏ thiết bị rproc. nó nên
_only_ được gọi nếu có lệnh gọi rproc_add() trước đó
đã hoàn thành thành công.

Sau khi rproc_del() trả về, @rproc vẫn hợp lệ và
số lần đếm cuối cùng sẽ được giảm đi bằng cách gọi rproc_free().

Trả về 0 nếu thành công và -EINVAL nếu @rproc không hợp lệ.

::

void rproc_report_crash(struct rproc *rproc, enum rproc_crash_type type)

Báo cáo sự cố trong remoteproc

Hàm này phải được gọi mỗi khi hệ thống phát hiện ra sự cố.
triển khai rproc cụ thể trên nền tảng. Điều này không nên được gọi từ một
trình điều khiển không remoteproc. Hàm này có thể được gọi từ nguyên tử/ngắt
bối cảnh.

Lệnh gọi lại triển khai
========================

Những cuộc gọi lại này phải được cung cấp bởi remoteproc dành riêng cho nền tảng
trình điều khiển::

/**
   * struct rproc_ops - trình xử lý thiết bị dành riêng cho nền tảng
   * @start: bật nguồn thiết bị và khởi động nó
   * @stop: tắt nguồn thiết bị
   * @kick: đá một virtqueue (id virtqueue được cung cấp dưới dạng tham số)
   */
  cấu trúc rproc_ops {
	int (*start)(struct rproc *rproc);
	int (*stop)(struct rproc *rproc);
	khoảng trống (*kick)(struct rproc *rproc, int vqid);
  };

Mọi triển khai remoteproc ít nhất phải cung cấp ->start và ->stop
người xử lý. Nếu cũng muốn có chức năng RPMsg/virtio thì trình xử lý ->kick
cũng nên được cung cấp.

Trình xử lý ->start() nhận một bộ điều khiển rproc và sau đó sẽ bật nguồn
thiết bị và khởi động nó (sử dụng rproc->priv để truy cập dữ liệu riêng tư dành riêng cho nền tảng).
Địa chỉ khởi động, trong trường hợp cần thiết, có thể được tìm thấy trong rproc->bootaddr (remoteproc
core đặt điểm vào ELF ở đó).
Nếu thành công, sẽ trả về 0 và nếu thất bại, sẽ có mã lỗi thích hợp.

Trình xử lý ->stop() xử lý rproc và tắt nguồn thiết bị.
Nếu thành công, giá trị 0 được trả về và nếu thất bại, mã lỗi thích hợp sẽ được trả về.

Trình xử lý ->kick() lấy một bộ điều khiển rproc và một chỉ mục của một virtqueue
nơi tin nhắn mới được đặt vào. Việc triển khai sẽ làm gián đoạn điều khiển từ xa
bộ xử lý và cho nó biết nó có tin nhắn đang chờ xử lý. Thông báo bộ xử lý từ xa
chỉ số Virtqueue chính xác để tìm kiếm là tùy chọn: thật dễ dàng (và không
quá đắt) để xem xét các ưu điểm hiện có và tìm kiếm bộ đệm mới
trong những chiếc nhẫn đã qua sử dụng.

Cấu trúc phần mềm nhị phân
==========================

Tại thời điểm này, remoteproc hỗ trợ các tệp nhị phân phần sụn ELF32 và ELF64. Tuy nhiên,
khá mong đợi rằng các nền tảng/thiết bị khác mà chúng tôi muốn
hỗ trợ với khung này sẽ dựa trên các định dạng nhị phân khác nhau.

Khi những trường hợp sử dụng đó xuất hiện, chúng ta sẽ phải tách định dạng nhị phân
từ lõi khung, vì vậy chúng tôi có thể hỗ trợ một số định dạng nhị phân mà không cần
sao chép mã chung.

Khi phần sụn được phân tích cú pháp, các phân đoạn khác nhau của nó sẽ được tải vào bộ nhớ
theo địa chỉ thiết bị được chỉ định (có thể là địa chỉ vật lý
nếu bộ xử lý từ xa đang truy cập trực tiếp vào bộ nhớ).

Ngoài các phân đoạn ELF tiêu chuẩn, hầu hết các bộ xử lý từ xa sẽ
cũng bao gồm một phần đặc biệt mà chúng tôi gọi là "bảng tài nguyên".

Bảng tài nguyên chứa các tài nguyên hệ thống mà bộ xử lý từ xa
yêu cầu trước khi bật nguồn, chẳng hạn như phân bổ vật lý
bộ nhớ liền kề hoặc ánh xạ iommu của một số thiết bị ngoại vi trên chip.
Remotecore sẽ chỉ cấp nguồn cho thiết bị sau tất cả các bảng tài nguyên.
yêu cầu được đáp ứng.

Ngoài tài nguyên hệ thống, bảng tài nguyên cũng có thể chứa
các mục tài nguyên công bố sự tồn tại của các tính năng được hỗ trợ
hoặc cấu hình của bộ xử lý từ xa, chẳng hạn như bộ đệm theo dõi và
các thiết bị virtio được hỗ trợ (và cấu hình của chúng).

Bảng tài nguyên bắt đầu bằng tiêu đề này::

/**
   * struct Resource_table - tiêu đề bảng tài nguyên phần sụn
   * @ver: số phiên bản
   * @num: số mục tài nguyên
   * @reserved: dành riêng (phải bằng 0)
   * @offset: mảng các offset trỏ vào các mục tài nguyên khác nhau
   *
   * Tiêu đề của bảng tài nguyên, được thể hiện bằng cấu trúc này,
   * chứa số phiên bản (nếu chúng ta cần thay đổi định dạng này trong
   * tương lai), số lượng mục nhập tài nguyên có sẵn và phần bù của chúng
   * trong bảng.
   */
  cấu trúc bảng_tài nguyên {
	phiên bản u32;
	số u32;
	u32 dành riêng[2];
	bù u32 [0];
  } __đóng gói;

Ngay sau tiêu đề này là các mục tài nguyên,
mỗi trong số đó bắt đầu bằng tiêu đề mục nhập tài nguyên sau::

/**
   * struct fw_rsc_hdr - tiêu đề nhập tài nguyên chương trình cơ sở
   * @type: loại tài nguyên
   * @data: dữ liệu tài nguyên
   *
   * Mọi mục nhập tài nguyên đều bắt đầu bằng tiêu đề 'struct fw_rsc_hdr' cung cấp
   * đó là @type. Nội dung của mục nhập sẽ ngay lập tức theo sau
   * tiêu đề này và nó phải được phân tích cú pháp theo loại tài nguyên.
   */
  cấu trúc fw_rsc_hdr {
	loại u32;
	dữ liệu u8[0];
  } __đóng gói;

Một số mục tài nguyên chỉ là thông báo, trong đó máy chủ được thông báo
cấu hình remoteproc cụ thể. Các mục khác yêu cầu máy chủ phải
làm điều gì đó (ví dụ: phân bổ tài nguyên hệ thống). Đôi khi đàm phán
được mong đợi, trong đó phần sụn yêu cầu tài nguyên và sau khi được phân bổ,
máy chủ nên cung cấp lại thông tin chi tiết của nó (ví dụ: địa chỉ của một
vùng nhớ).

Dưới đây là các loại tài nguyên khác nhau hiện được hỗ trợ::

/**
   * enum fw_resource_type - các loại mục tài nguyên
   *
   * @RSC_CARVEOUT: yêu cầu phân bổ một khu vực tiếp giáp về mặt vật lý
   * vùng nhớ.
   * @RSC_DEVMEM: yêu cầu iommu_map một thiết bị ngoại vi dựa trên bộ nhớ.
   * @RSC_TRACE: thông báo về tính khả dụng của bộ đệm theo dõi trong đó
   * bộ xử lý từ xa sẽ ghi nhật ký.
   * @RSC_VDEV: khai báo hỗ trợ cho một thiết bị virtio và đóng vai trò là thiết bị của nó
   * tiêu đề tài năng.
   * @RSC_LAST: chỉ cần giữ cái này ở cuối
   * @RSC_VENDOR_START: bắt đầu phạm vi loại tài nguyên cụ thể của nhà cung cấp
   * @RSC_VENDOR_END: kết thúc phạm vi loại tài nguyên cụ thể của nhà cung cấp
   *
   * Xin lưu ý rằng các giá trị này được sử dụng làm chỉ số cho rproc_handle_rsc
   * bảng tra cứu, vì vậy hãy giữ chúng lành mạnh. Hơn nữa, @RSC_LAST được sử dụng để
   * kiểm tra tính hợp lệ của một chỉ mục trước khi truy cập bảng tra cứu, vì vậy
   * vui lòng cập nhật nó khi cần thiết.
   */
  enum fw_resource_type {
	RSC_CARVEOUT = 0,
	RSC_DEVMEM = 1,
	RSC_TRACE = 2,
	RSC_VDEV = 3,
	RSC_LAST = 4,
	RSC_VENDOR_START = 128,
	RSC_VENDOR_END = 512,
  };

Để biết thêm chi tiết về một loại tài nguyên cụ thể, vui lòng xem
cấu trúc chuyên dụng trong include/linux/remoteproc.h.

Chúng tôi cũng hy vọng rằng các mục tài nguyên dành riêng cho nền tảng sẽ hiển thị
tại một số điểm. Khi điều đó xảy ra, chúng ta có thể dễ dàng thêm RSC_PLATFORM mới
gõ và giao các tài nguyên đó cho trình điều khiển rproc dành riêng cho nền tảng để xử lý.

Virtio và remoteproc
=====================

Phần sụn sẽ cung cấp thông tin remoteproc về các thiết bị virtio
mà nó hỗ trợ và cấu hình của chúng: mục tài nguyên RSC_VDEV
nên chỉ định id thiết bị virtio (như trong virtio_ids.h), các tính năng của virtio,
không gian cấu hình virtio, thông tin vrings, v.v.

Khi một bộ xử lý từ xa mới được đăng ký, khung remoteproc
sẽ tìm bảng tài nguyên của nó và sẽ đăng ký các thiết bị virtio
nó hỗ trợ. Một chương trình cơ sở có thể hỗ trợ bất kỳ số lượng thiết bị virtio nào và
thuộc bất kỳ loại nào (một bộ xử lý từ xa cũng có thể dễ dàng hỗ trợ một số
các thiết bị virtio RPMSG theo cách này, nếu muốn).

Tất nhiên, các mục nhập tài nguyên RSC_VDEV chỉ đủ tốt cho các mục tĩnh.
phân bổ các thiết bị virtio. Phân bổ động cũng sẽ được thực hiện
bằng cách sử dụng bus RPMSG (tương tự như cách chúng tôi đã thực hiện phân bổ động
kênh vòng/phút; đọc thêm về nó trong RPMsg.txt).
