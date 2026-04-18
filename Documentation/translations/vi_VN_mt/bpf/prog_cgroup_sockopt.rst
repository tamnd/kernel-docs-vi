.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/bpf/prog_cgroup_sockopt.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

===============================
BPF_PROG_TYPE_CGROUP_SOCKOPT
============================

Loại chương trình ZZ0000ZZ có thể được gắn vào hai
móc nhóm:

* ZZ0000ZZ - được gọi mỗi khi tiến trình thực thi ZZ0001ZZ
  cuộc gọi hệ thống.
* ZZ0002ZZ - được gọi mỗi khi tiến trình thực thi ZZ0003ZZ
  cuộc gọi hệ thống.

Ngữ cảnh (ZZ0000ZZ) có ổ cắm liên quan (ZZ0001ZZ) và
tất cả các đối số đầu vào: ZZ0002ZZ, ZZ0003ZZ, ZZ0004ZZ và ZZ0005ZZ.

BPF_CGROUP_SETSOCKOPT
=====================

ZZ0000ZZ được kích hoạt ZZ0001ZZ xử lý kernel của
sockopt và nó có ngữ cảnh có thể ghi: nó có thể sửa đổi các đối số được cung cấp
trước khi chuyển chúng xuống kernel. Hook này có quyền truy cập vào cgroup
và ổ cắm lưu trữ cục bộ.

Nếu chương trình BPF đặt ZZ0000ZZ thành -1, điều khiển sẽ được trả về
quay lại không gian người dùng sau tất cả các chương trình BPF khác trong nhóm
kết thúc chuỗi (tức là việc xử lý ZZ0001ZZ kernel sẽ ZZ0002ZZ được thực thi).

Lưu ý rằng ZZ0000ZZ không thể tăng vượt quá giới hạn do người dùng cung cấp
giá trị. Nó chỉ có thể giảm hoặc đặt thành -1. Bất kỳ giá trị nào khác sẽ
kích hoạt ZZ0001ZZ.

Kiểu trả về
-----------

* ZZ0000ZZ - từ chối syscall, ZZ0001ZZ sẽ được trả về không gian người dùng.
* ZZ0002ZZ - thành công, tiếp tục với chương trình BPF tiếp theo trong chuỗi cgroup.

BPF_CGROUP_GETSOCKOPT
=====================

ZZ0000ZZ được kích hoạt ZZ0009ZZ việc bàn giao kernel của
sockopt. Móc BPF có thể quan sát ZZ0001ZZ, ZZ0002ZZ và ZZ0003ZZ
nếu nó quan tâm đến bất kỳ kernel nào đã quay trở lại. Móc BPF có thể ghi đè
các giá trị trên, điều chỉnh ZZ0004ZZ và đặt lại ZZ0005ZZ về 0. Nếu ZZ0006ZZ
đã được tăng lên trên giá trị ZZ0007ZZ ban đầu (tức là không gian người dùng
bộ đệm quá nhỏ), ZZ0008ZZ sẽ được trả về.

Móc này có quyền truy cập vào bộ nhớ cục bộ cgroup và socket.

Lưu ý rằng giá trị duy nhất được chấp nhận để đặt thành ZZ0000ZZ là 0 và
giá trị ban đầu mà kernel trả về. Bất kỳ giá trị nào khác sẽ kích hoạt
ZZ0001ZZ.

Kiểu trả về
-----------

* ZZ0000ZZ - từ chối syscall, ZZ0001ZZ sẽ được trả về không gian người dùng.
* ZZ0002ZZ - thành công: sao chép ZZ0003ZZ và ZZ0004ZZ vào không gian người dùng, quay lại
  ZZ0005ZZ từ syscall (lưu ý rằng điều này có thể được ghi đè bởi
  chương trình BPF từ nhóm mẹ).

Kế thừa Cgroup
==================

Giả sử có hệ thống phân cấp cgroup sau đây trong đó mỗi cgroup
có ZZ0000ZZ được gắn ở mỗi cấp độ với
Cờ ZZ0001ZZ::

A (gốc, cha mẹ)
   \
    B (trẻ em)

Khi ứng dụng gọi tới tòa nhà ZZ0000ZZ từ nhóm B,
các chương trình được thực hiện từ dưới lên: B, A. Chương trình đầu tiên
(B) xem kết quả ZZ0001ZZ của kernel. Nó có thể tùy ý
điều chỉnh ZZ0002ZZ, ZZ0003ZZ và reset ZZ0004ZZ về 0. Sau đó
điều khiển sẽ được chuyển cho chương trình (A) thứ hai sẽ xem
bối cảnh tương tự như B bao gồm mọi sửa đổi tiềm năng.

Tương tự với ZZ0000ZZ: nếu chương trình được đính kèm vào
A và B, thứ tự kích hoạt là B thì A. Nếu B có bất kỳ thay đổi nào
đến các đối số đầu vào (ZZ0001ZZ, ZZ0002ZZ, ZZ0003ZZ, ZZ0004ZZ),
thì chương trình tiếp theo trong chuỗi (A) sẽ thấy những thay đổi đó,
ZZ0006ZZ đối số ZZ0005ZZ đầu vào ban đầu. Khả năng
các giá trị được sửa đổi sau đó sẽ được chuyển xuống kernel.

Tối ưu lớn
============
Khi ZZ0000ZZ lớn hơn ZZ0001ZZ, chương trình BPF
chỉ có thể truy cập ZZ0002ZZ đầu tiên của dữ liệu đó. Vì vậy, nó phải có các tùy chọn:

* Đặt ZZ0000ZZ về 0, điều này cho biết kernel sẽ
  sử dụng bộ đệm gốc từ không gian người dùng. Mọi sửa đổi
  được thực hiện bởi chương trình BPF đối với ZZ0001ZZ sẽ bị bỏ qua.
* Đặt ZZ0002ZZ thành giá trị nhỏ hơn ZZ0003ZZ,
  chỉ ra rằng kernel nên sử dụng ZZ0004ZZ đã được cắt bớt của BPF.

Khi chương trình BPF trả về với ZZ0000ZZ lớn hơn
ZZ0001ZZ, không gian người dùng sẽ nhận kernel gốc
bộ đệm mà không có bất kỳ sửa đổi nào mà chương trình BPF có thể có
áp dụng.

Ví dụ
=======

Cách được đề xuất để xử lý các chương trình BPF như sau:

.. code-block:: c

	SEC("cgroup/getsockopt")
	int getsockopt(struct bpf_sockopt *ctx)
	{
		/* Custom socket option. */
		if (ctx->level == MY_SOL && ctx->optname == MY_OPTNAME) {
			ctx->retval = 0;
			optval[0] = ...;
			ctx->optlen = 1;
			return 1;
		}

		/* Modify kernel's socket option. */
		if (ctx->level == SOL_IP && ctx->optname == IP_FREEBIND) {
			ctx->retval = 0;
			optval[0] = ...;
			ctx->optlen = 1;
			return 1;
		}

		/* optval larger than PAGE_SIZE use kernel's buffer. */
		if (ctx->optlen > PAGE_SIZE)
			ctx->optlen = 0;

		return 1;
	}

	SEC("cgroup/setsockopt")
	int setsockopt(struct bpf_sockopt *ctx)
	{
		/* Custom socket option. */
		if (ctx->level == MY_SOL && ctx->optname == MY_OPTNAME) {
			/* do something */
			ctx->optlen = -1;
			return 1;
		}

		/* Modify kernel's socket option. */
		if (ctx->level == SOL_IP && ctx->optname == IP_FREEBIND) {
			optval[0] = ...;
			return 1;
		}

		/* optval larger than PAGE_SIZE use kernel's buffer. */
		if (ctx->optlen > PAGE_SIZE)
			ctx->optlen = 0;

		return 1;
	}

Xem ZZ0000ZZ để biết ví dụ
của chương trình BPF xử lý các tùy chọn ổ cắm.