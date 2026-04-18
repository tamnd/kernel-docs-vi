.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/locking/ww-mutex-design.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

=========================================
Thiết kế Mutex chống bế tắc/chờ đợi
======================================

Vui lòng đọc mutex-design.rst trước vì nó cũng áp dụng cho các mutex chờ/vết thương.

Động lực cho WW-Mutexes
-------------------------

GPU thực hiện các hoạt động thường liên quan đến nhiều bộ đệm.  Những bộ đệm đó
có thể được chia sẻ giữa các bối cảnh/quy trình, tồn tại trong bộ nhớ khác nhau
tên miền (ví dụ VRAM so với bộ nhớ hệ thống), v.v.  Và với
PRIME / dmabuf, chúng thậm chí có thể được chia sẻ trên các thiết bị.  Vậy có
một số tình huống mà người lái xe cần đợi bộ đệm
trở nên sẵn sàng.  Nếu bạn nghĩ về điều này dưới dạng chờ đợi trên bộ đệm
mutex để nó có sẵn, điều này gây ra một vấn đề bởi vì
không có cách nào để đảm bảo rằng bộ đệm xuất hiện trong một tập tin thực thi/đợt trong
thứ tự giống nhau trong mọi ngữ cảnh.  Đó là sự kiểm soát trực tiếp của
không gian người dùng và kết quả của chuỗi lệnh gọi GL mà ứng dụng
làm cho.	Điều này dẫn đến nguy cơ bế tắc.  Vấn đề được
phức tạp hơn khi bạn cho rằng kernel có thể cần phải di chuyển
(các) bộ đệm vào VRAM trước khi GPU hoạt động trên (các) bộ đệm, điều này
đến lượt nó có thể yêu cầu loại bỏ một số bộ đệm khác (và bạn không muốn
loại bỏ các bộ đệm khác đã được xếp hàng vào GPU), nhưng đối với
sự hiểu biết đơn giản về vấn đề bạn có thể bỏ qua điều này.

Thuật toán mà hệ thống con đồ họa TTM đưa ra để xử lý
vấn đề này khá đơn giản.  Đối với mỗi nhóm bộ đệm (execbuf) cần
để bị khóa, người gọi sẽ được chỉ định một id/vé đặt chỗ duy nhất,
từ một bộ đếm toàn cầu.  Trong trường hợp bế tắc trong khi khóa tất cả bộ đệm
được liên kết với một execbuf, một có vé đặt chỗ thấp nhất (tức là
nhiệm vụ cũ nhất) sẽ thắng và nhiệm vụ có id đặt trước cao hơn (tức là
nhiệm vụ trẻ hơn) mở khóa tất cả các bộ đệm mà nó đã khóa, sau đó
thử lại.

Trong tài liệu RDBMS, vé đặt chỗ được liên kết với một giao dịch.
và phương pháp xử lý bế tắc được gọi là Wait-Die. Tên được dựa trên
hành động của một luồng khóa khi nó gặp một mutex đã bị khóa.
Nếu giao dịch giữ khóa trẻ hơn thì giao dịch khóa sẽ chờ.
Nếu giao dịch giữ khóa cũ hơn, giao dịch khóa sẽ bị hủy
và chết. Do đó Chờ-Chết.
Ngoài ra còn có một thuật toán khác gọi là Wound-Wait:
Nếu giao dịch giữ khóa trẻ hơn thì giao dịch khóa
làm tổn thương giao dịch đang giữ khóa, yêu cầu nó chết.
Nếu giao dịch giữ khóa cũ hơn, nó sẽ đợi giao dịch khác
giao dịch. Do đó vết thương-chờ đợi.
Cả hai thuật toán đều công bằng ở chỗ giao dịch cuối cùng sẽ thành công.
Tuy nhiên, thuật toán Wound-Wait thường được tuyên bố là tạo ra ít thời gian chờ hơn
so với Wait-Die, nhưng mặt khác lại gắn liền với nhiều công việc hơn
Chờ-Chết khi đang hồi phục sau khi lùi bước. Wound-Wait cũng là một biện pháp phủ đầu
thuật toán trong các giao dịch đó bị tổn thương bởi các giao dịch khác và
đòi hỏi một cách đáng tin cậy để tiếp nhận tình trạng bị thương và ngăn chặn
giao dịch đang chạy. Lưu ý rằng điều này không giống như quyền ưu tiên của quy trình. A
Giao dịch Wound-Wait được coi là được ưu tiên khi nó chết (trả lại
-EDEADLK) sau vết thương.

Khái niệm
--------

So với các mutex thông thường, hai khái niệm/đối tượng bổ sung xuất hiện trong khóa
giao diện cho w/w mutexes:

Thu thập bối cảnh: Để đảm bảo tiến độ cuối cùng về phía trước, điều quan trọng là một nhiệm vụ phải
cố gắng lấy khóa không lấy được id đặt chỗ mới mà vẫn giữ cái đó
có được khi bắt đầu thu thập khóa. Phiếu này được lưu trữ trong
thu được bối cảnh. Hơn nữa, bối cảnh thu được sẽ theo dõi trạng thái gỡ lỗi
để phát hiện việc lạm dụng giao diện mutex. Một bối cảnh thu được đại diện cho một
giao dịch.

Lớp W/w: Ngược lại với các mutex thông thường, lớp khóa cần phải rõ ràng cho
w/w mutexes, vì nó bắt buộc phải khởi tạo ngữ cảnh thu được. cái khóa
lớp cũng chỉ định thuật toán nào sẽ sử dụng, Wound-Wait hoặc Wait-Die.

Hơn nữa, có ba loại chức năng thu thập khóa w/w khác nhau:

* Thu thập khóa thông thường với ngữ cảnh, sử dụng ww_mutex_lock.

* Thu thập khóa đường dẫn chậm trên khóa cạnh tranh, được sử dụng bởi tác vụ vừa
  đã hủy bỏ giao dịch của nó sau khi đã loại bỏ tất cả các khóa đã có được.
  Các hàm này có hậu tố _slow.

Từ quan điểm ngữ nghĩa đơn giản, các hàm _slow không hoàn toàn phù hợp
  bắt buộc, vì chỉ cần gọi các hàm ww_mutex_lock bình thường trên
  khóa tranh chấp (sau khi đã loại bỏ tất cả các khóa đã có khác) sẽ
  làm việc chính xác. Rốt cuộc, nếu chưa có mutex ww nào khác được mua thì vẫn còn
  không có khả năng bế tắc và do đó cuộc gọi ww_mutex_lock sẽ chặn và không
  trả lại sớm -EDEADLK. Ưu điểm của hàm _slow là ở
  giao diện an toàn:

- ww_mutex_lock có kiểu trả về int __must_check, trong khi ww_mutex_lock_slow
    có kiểu trả về void. Lưu ý rằng vì mã mutex của ww cần vòng lặp/thử lại
    dù sao thì __must_check cũng không dẫn đến cảnh báo giả mạo, mặc dù
    thao tác khóa đầu tiên không bao giờ có thể thất bại.
  - Khi bật tính năng gỡ lỗi hoàn toàn, ww_mutex_lock_slow sẽ kiểm tra xem tất cả đã thu được chưa
    ww mutex đã được phát hành (ngăn chặn bế tắc) và đảm bảo rằng chúng tôi
    chặn trên khóa cạnh tranh (ngăn quay qua -EDEADLK
    đường dẫn chậm cho đến khi có thể lấy được khóa dự kiến).

* Chức năng chỉ thu được một mutex w/w duy nhất, dẫn đến kết quả giống hệt nhau
  ngữ nghĩa như một mutex bình thường. Điều này được thực hiện bằng cách gọi ww_mutex_lock bằng NULL
  bối cảnh.

Một lần nữa điều này không được yêu cầu nghiêm ngặt. Nhưng thường thì bạn chỉ muốn có được một
  khóa đơn trong trường hợp đó việc thiết lập bối cảnh thu thập là vô nghĩa (và do đó
  tốt hơn để tránh lấy một vé tránh bế tắc).

Tất nhiên, tất cả các biến thể thông thường để xử lý việc đánh thức do tín hiệu cũng
được cung cấp.

Cách sử dụng
-----

Thuật toán (Wait-Die vs Wound-Wait) được chọn bằng cách sử dụng một trong hai
DEFINE_WW_CLASS() (Chờ vết thương) hoặc DEFINE_WD_CLASS() (Chờ chết)
Theo nguyên tắc chung, hãy sử dụng Wound-Wait nếu bạn
kỳ vọng số lượng giao dịch cạnh tranh đồng thời thường nhỏ,
và bạn muốn giảm số lần khôi phục.

Ba cách khác nhau để có được khóa trong cùng một lớp w/w. chung
định nghĩa cho các phương thức #1 và #2::

DEFINE_WW_CLASS tĩnh(ww_class);

cấu trúc đối tượng {
	cấu trúc khóa ww_mutex;
	/*dữ liệu đối tượng*/
  };

cấu trúc obj_entry {
	đầu danh sách cấu trúc_head;
	struct obj *obj;
  };

Phương pháp 1, sử dụng danh sách trong execbuf->bộ đệm không được phép sắp xếp lại.
Điều này rất hữu ích nếu danh sách các đối tượng cần thiết đã được theo dõi ở đâu đó.
Hơn nữa, trình trợ giúp khóa có thể sử dụng truyền mã trả về -EALREADY trở lại
người gọi như một tín hiệu cho thấy một đối tượng có hai lần trong danh sách. Điều này rất hữu ích nếu
danh sách được xây dựng từ đầu vào vùng người dùng và ABI yêu cầu vùng người dùng để
không có các mục trùng lặp (ví dụ: đối với gửi bộ đệm lệnh gpu ioctl)::

int lock_objs(struct list_head *list, struct ww_acquire_ctx *ctx)
  {
	struct obj *res_obj = NULL;
	struct obj_entry *contents_entry = NULL;
	struct obj_entry *entry;

ww_acquire_init(ctx, &ww_class);

thử lại:
	list_for_each_entry (mục nhập, danh sách, đầu) {
		if (entry->obj == res_obj) {
			res_obj = NULL;
			Tiếp tục;
		}
		ret = ww_mutex_lock(&entry->obj->lock, ctx);
		nếu (ret < 0) {
			tranh_entry = mục nhập;
			nhầm rồi;
		}
	}

ww_acquire_done(ctx);
	trả về 0;

lỗi:
	list_for_each_entry_continue_reverse (mục nhập, danh sách, đầu)
		ww_mutex_unlock(&entry->obj->lock);

nếu (res_obj)
		ww_mutex_unlock(&res_obj->lock);

nếu (ret == -EDEADLK) {
		/* chúng tôi đã thua trong cuộc đua thứ hai, khóa và thử lại.. */
		ww_mutex_lock_slow(&contends_entry->obj->lock, ctx);
		res_obj = tranh_entry->obj;
		hãy thử lại;
	}
	ww_acquire_fini(ctx);

trở lại ret;
  }

Phương pháp 2, sử dụng danh sách trong execbuf->bộ đệm có thể được sắp xếp lại. Ngữ nghĩa giống nhau
phát hiện mục nhập trùng lặp bằng cách sử dụng -EALREADY như phương pháp 1 ở trên. Nhưng
sắp xếp lại danh sách cho phép mã thành ngữ hơn một chút ::

int lock_objs(struct list_head *list, struct ww_acquire_ctx *ctx)
  {
	cấu trúc obj_entry *entry, *entry2;

ww_acquire_init(ctx, &ww_class);

list_for_each_entry (mục nhập, danh sách, đầu) {
		ret = ww_mutex_lock(&entry->obj->lock, ctx);
		nếu (ret < 0) {
			mục2 = mục nhập;

list_for_each_entry_continue_reverse (mục 2, danh sách, phần đầu)
				ww_mutex_unlock(&entry2->obj->lock);

nếu (ret != -EDEADLK) {
				ww_acquire_fini(ctx);
				trở lại ret;
			}

/* chúng tôi đã thua trong cuộc đua thứ hai, khóa và thử lại.. */
			ww_mutex_lock_slow(&entry->obj->lock, ctx);

/*
			 * Di chuyển buf lên đầu danh sách, thao tác này sẽ trỏ
			 * buf->bên cạnh mục được mở khóa đầu tiên,
			 * khởi động lại vòng lặp for.
			 */
			list_del(&entry->head);
			list_add(&entry->head, list);
		}
	}

ww_acquire_done(ctx);
	trả về 0;
  }

Việc mở khóa hoạt động theo cách tương tự cho cả hai phương pháp #1 và #2::

void unlock_objs(struct list_head *list, struct ww_acquire_ctx *ctx)
  {
	struct obj_entry *entry;

list_for_each_entry (mục nhập, danh sách, đầu)
		ww_mutex_unlock(&entry->obj->lock);

ww_acquire_fini(ctx);
  }

Phương pháp 3 hữu ích nếu danh sách các đối tượng được xây dựng đặc biệt và không phải trả trước,
ví dụ: khi điều chỉnh các cạnh trong biểu đồ trong đó mỗi nút có khóa ww_mutex riêng,
và các cạnh chỉ có thể được thay đổi khi giữ khóa của tất cả các nút liên quan. có/có
mutexes phù hợp tự nhiên cho trường hợp như vậy vì hai lý do:

- Họ có thể xử lý việc thu thập khóa theo bất kỳ thứ tự nào cho phép chúng ta bắt đầu đi bộ
  đồ thị từ điểm bắt đầu và sau đó lặp đi lặp lại việc khám phá các cạnh mới và
  khóa các nút mà các cạnh kết nối tới.
- Do mã trả về -EALREADY báo hiệu rằng một đối tượng nhất định đã được
  cho rằng không cần phải ghi sổ kế toán bổ sung để phá vỡ các chu kỳ trong biểu đồ
  hoặc theo dõi những giao diện nào đã được giữ lại (khi sử dụng nhiều nút
  làm điểm khởi đầu).

Lưu ý rằng phương pháp này khác với các phương pháp trên ở hai điểm quan trọng:

- Vì danh sách các đối tượng được xây dựng động (và rất có thể
  khác khi thử lại do gặp phải tình trạng khuôn -EDEADLK) có
  không cần giữ bất kỳ đối tượng nào trong danh sách liên tục khi nó không bị khóa. Chúng tôi có thể
  do đó di chuyển list_head vào chính đối tượng đó.
- Mặt khác việc xây dựng danh sách đối tượng động cũng có nghĩa là trả về -EALREADY
  mã không thể được truyền bá.

Cũng lưu ý rằng các phương pháp #1 và #2 và phương pháp #3 có thể được kết hợp, ví dụ: đầu tiên khóa một
danh sách các nút bắt đầu (được truyền từ không gian người dùng) bằng cách sử dụng một trong các nút trên
phương pháp. Và sau đó khóa mọi đối tượng bổ sung bị ảnh hưởng bởi các hoạt động bằng cách sử dụng
phương pháp #3 bên dưới. Thủ tục lùi lại/thử lại sẽ phức tạp hơn một chút, vì
khi bước khóa động chạm đến -EDEADLK, chúng ta cũng cần mở khóa tất cả
các đối tượng có được với danh sách cố định. Nhưng kiểm tra gỡ lỗi w/w mutex sẽ bắt được
bất kỳ việc lạm dụng giao diện nào cho những trường hợp này.

Ngoài ra, phương pháp 3 không thể thất bại trong bước lấy khóa vì nó không trả về
-EALREADY. Tất nhiên điều này sẽ khác khi sử dụng _interruptible
các biến thể, nhưng điều đó nằm ngoài phạm vi của các ví dụ sau đây::

cấu trúc đối tượng {
	cấu trúc ww_mutex ww_mutex;
	cấu trúc list_head lock_list;
  };

DEFINE_WW_CLASS tĩnh(ww_class);

void __unlock_objs(struct list_head *list)
  {
	cấu trúc obj *entry, *temp;

list_for_each_entry_safe (mục nhập, tạm thời, danh sách, lock_list) {
		/* cần phải làm điều đó trước khi mở khóa, vì chỉ người giữ khóa hiện tại mới được phép
		được phép sử dụng đối tượng */
		list_del(&entry->locked_list);
		ww_mutex_unlock(entry->ww_mutex)
	}
  }

void lock_objs(struct list_head *list, struct ww_acquire_ctx *ctx)
  {
	struct obj *obj;

ww_acquire_init(ctx, &ww_class);

thử lại:
	/*khởi động lại trạng thái bắt đầu vòng lặp */
	vòng lặp {
		/* mã ma thuật đi qua biểu đồ và quyết định đối tượng nào
		 * để khóa */

ret = ww_mutex_lock(obj->ww_mutex, ctx);
		nếu (ret == -EALREADY) {
			/* Chúng ta đã có đối tượng đó rồi, hãy chuyển sang đối tượng tiếp theo */
			tiếp tục;
		}
		nếu (ret == -EDEADLK) {
			__unlock_objs(danh sách);

ww_mutex_lock_slow(obj, ctx);
			list_add(&entry->locked_list, list);
			hãy thử lại;
		}

/* khóa một đối tượng mới, thêm nó vào danh sách */
		list_add_tail(&entry->locked_list, list);
	}

ww_acquire_done(ctx);
	trả về 0;
  }

void unlock_objs(struct list_head *list, struct ww_acquire_ctx *ctx)
  {
	__unlock_objs(danh sách);
	ww_acquire_fini(ctx);
  }

Cách 4: Chỉ khóa một đối tượng duy nhất. Trong trường hợp đó việc phát hiện bế tắc và
việc phòng ngừa rõ ràng là quá mức cần thiết, vì chỉ cần lấy một ổ khóa bạn không thể
tạo ra sự bế tắc chỉ trong một lớp. Để đơn giản hóa trường hợp này, w/w mutex
api có thể được sử dụng với ngữ cảnh NULL.

Chi tiết triển khai
----------------------

Thiết kế:
^^^^^^^

ww_mutex hiện đang đóng gói một mutex struct, điều này có nghĩa là không cần thêm chi phí cho
  khóa mutex bình thường, phổ biến hơn nhiều. Như vậy chỉ có một phần nhỏ
  tăng kích thước mã nếu không sử dụng các mutex chờ/vết thương.

Chúng tôi duy trì các bất biến sau cho danh sách chờ:

(1) Người phục vụ có bối cảnh tiếp thu được sắp xếp theo thứ tự đóng dấu; bồi bàn
      không có bối cảnh thu được được xen kẽ theo thứ tự FIFO.
  (2) Đối với Wait-Die, trong số những người phục vụ có bối cảnh, chỉ có người đầu tiên mới có thể có
      các khóa khác đã được mua (ctx->acquired > 0). Lưu ý rằng người phục vụ này
      có thể theo sau những người phục vụ khác không có ngữ cảnh trong danh sách.

Quyền ưu tiên Wound-Wait được triển khai với sơ đồ ưu tiên lười biếng:
  Trạng thái bị tổn thương của giao dịch chỉ được kiểm tra khi có
  tranh giành một khóa mới và do đó có nguy cơ bế tắc thực sự. Trong đó
  tình huống, nếu giao dịch bị tổn thương, nó sẽ lùi lại, xóa
  tình trạng bị thương và thử lại. Lợi ích to lớn của việc thực hiện quyền ưu tiên trong
  Bằng cách này, giao dịch bị tổn thương có thể xác định được khóa cạnh tranh với
  chờ đợi trước khi bắt đầu lại giao dịch. Chỉ cần khởi động lại một cách mù quáng
  giao dịch có thể sẽ khiến giao dịch kết thúc trong tình huống
  nó sẽ phải lùi lại lần nữa.

Nói chung dự kiến ​​sẽ không có nhiều tranh cãi. Ổ khóa thường được sử dụng để
  tuần tự hóa quyền truy cập vào tài nguyên cho thiết bị và nên tập trung tối ưu hóa
  do đó được hướng tới các trường hợp không có tranh chấp.

Khóa:
^^^^^^^^

Sự quan tâm đặc biệt đã được thực hiện để cảnh báo nhiều trường hợp lạm dụng api
  càng tốt. Một số hành vi lạm dụng api phổ biến sẽ bị phát hiện
  CONFIG_DEBUG_MUTEXES, nhưng CONFIG_PROVE_LOCKING được khuyên dùng.

Một số lỗi sẽ được cảnh báo:
   - Quên gọi ww_acquire_fini hoặc ww_acquire_init.
   - Cố gắng khóa nhiều mutex hơn sau ww_acquire_done.
   - Cố gắng khóa sai mutex sau -EDEADLK và
     mở khóa tất cả các mutexes.
   - Cố gắng khóa mutex bên phải sau -EDEADLK,
     trước khi mở khóa tất cả các mutex.

- Gọi ww_mutex_lock_slow trước khi -EDEADLK được trả về.

- Mở khóa mutexes với chức năng mở khóa sai.
   - Gọi một trong các ww_acquire_* hai lần trong cùng một ngữ cảnh.
   - Sử dụng ww_class cho mutex khác với ww_acquire_ctx.
   - Lỗi lockdep bình thường có thể dẫn đến bế tắc.

Một số lỗi lockdep có thể dẫn đến bế tắc:
   - Gọi ww_acquire_init để khởi tạo ww_acquire_ctx thứ hai trước đó
     đã gọi ww_acquire_fini ngay lần đầu tiên.
   - bế tắc 'bình thường' có thể xảy ra.

FIXME:
  Cập nhật phần này khi chúng ta có phép thuật cờ trạng thái nhiệm vụ TASK_DEADLOCK
  được thực hiện.
