.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/admin-guide/LSM/landlock.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. Copyright © 2025 Microsoft Corporation

====================================
Landlock: quản lý toàn hệ thống
====================================

:Tác giả: Mickaël Salaün
:Ngày: Tháng 1 năm 2026

Landlock có thể tận dụng khung kiểm toán để ghi lại các sự kiện.

Tài liệu về không gian người dùng có thể được tìm thấy ở đây:
Tài liệu/userspace-api/landlock.rst.

Kiểm toán
=========

Các yêu cầu truy cập bị từ chối được ghi lại theo mặc định cho chương trình được đóng hộp cát nếu ZZ0000ZZ
được kích hoạt.  Hành vi mặc định này có thể được thay đổi bằng
cờ sys_landlock_restrict_self() (cf.
Tài liệu/userspace-api/landlock.rst).  Nhật ký vùng đất liền cũng có thể được che dấu
nhờ các quy tắc kiểm toán.  Landlock có thể tạo ra 2 loại hồ sơ kiểm toán.

Các loại bản ghi
----------------

AUDIT_LANDLOCK_ACCESS
    Loại bản ghi này xác định yêu cầu truy cập bị từ chối vào tài nguyên kernel.
    Trường ZZ0000ZZ cho biết ID của miền đã chặn
    yêu cầu.  Trường ZZ0001ZZ cho biết (các) nguyên nhân của việc từ chối này
    (được phân tách bằng dấu phẩy) và các trường sau xác định đối tượng kernel
    (tương tự như SELinux).  Có thể có nhiều hơn một loại bản ghi này cho mỗi
    sự kiện kiểm toán.

Ví dụ về yêu cầu liên kết tệp tạo hai bản ghi trong cùng một sự kiện::

domain=195ba459b blockers=fs.refer path="/usr/bin" dev="vda2" ino=351
        domain=195ba459b blockers=fs.make_reg,fs.refer path="/usr/local" dev="vda2" ino=365


Trường ZZ0000ZZ sử dụng tiền tố được phân tách bằng dấu chấm để biểu thị loại
    hạn chế gây ra sự từ chối:

ZZ0000ZZ* - Quyền truy cập hệ thống tệp (ABI 1+):
        - fs.execute, fs.write_file, fs.read_file, fs.read_dir
        - fs.remove_dir, fs.remove_file
        - fs.make_char, fs.make_dir, fs.make_reg, fs.make_sock
        - fs.make_fifo, fs.make_block, fs.make_sym
        - fs.refer (ABI 2+)
        - fs.truncate (ABI 3+)
        - fs.ioctl_dev (ABI 5+)

ZZ0000ZZ* - Quyền truy cập mạng (ABI 4+):
        - net.bind_tcp - Liên kết cổng TCP bị từ chối
        - net.connect_tcp - Kết nối TCP bị từ chối

ZZ0000ZZ* - Giới hạn phạm vi IPC (ABI 6+):
        - phạm vi.abstract_unix_socket - Kết nối ổ cắm UNIX trừu tượng bị từ chối
        - phạm vi.signal - Gửi tín hiệu bị từ chối

Nhiều trình chặn có thể xuất hiện trong một sự kiện (được phân tách bằng dấu phẩy) khi
    nhiều quyền truy cập bị thiếu. Ví dụ: tạo một tập tin thông thường
    trong thư mục thiếu cả quyền ZZ0000ZZ và ZZ0001ZZ sẽ hiển thị
    ZZ0002ZZ.

Các trường nhận dạng đối tượng (path, dev, ino cho hệ thống tập tin; opid,
    ocomm cho tín hiệu) tùy thuộc vào loại truy cập bị chặn và cung cấp
    bối cảnh về tài nguyên nào có liên quan đến việc từ chối.


AUDIT_LANDLOCK_DOMAIN
    Loại bản ghi này mô tả trạng thái của miền Landlock.  ZZ0000ZZ
    trường có thể là ZZ0001ZZ hoặc ZZ0002ZZ.

Trạng thái ZZ0000ZZ là một phần của cùng một sự kiện kiểm tra và tuân theo
    bản ghi ZZ0001ZZ được ghi lại đầu tiên của một miền.  Nó xác định
    Thông tin miền Landlock tại thời điểm sys_landlock_restrict_self()
    gọi với các trường sau:

- ID ZZ0000ZZ
    - việc thực thi ZZ0001ZZ
    - ZZ0002ZZ của người tạo miền
    - ZZ0003ZZ của người tạo miền
    - đường dẫn thực thi của người tạo miền (ZZ0004ZZ)
    - dòng lệnh của người tạo miền (ZZ0005ZZ)

Ví dụ::

miền=195ba459b trạng thái=chế độ phân bổ=thực thi pid=300 uid=0 exe="/root/sandboxer" comm="sandboxer"

Trạng thái ZZ0000ZZ tự nó là một sự kiện và nó xác định một
    Phát hành tên miền Landlock.  Sau sự kiện đó, đảm bảo rằng
    ID miền liên quan sẽ không bao giờ được sử dụng lại trong suốt thời gian tồn tại của hệ thống.
    Trường ZZ0001ZZ cho biết ID của miền được phát hành và
    trường ZZ0002ZZ cho biết tổng số yêu cầu truy cập bị từ chối,
    có thể chưa được ghi lại theo các quy tắc kiểm toán và
    cờ của sys_landlock_restrict_self().

Ví dụ::

tên miền=195ba459b trạng thái=từ chối được phân bổ=3


Mẫu sự kiện
--------------

Dưới đây là hai ví dụ về sự kiện nhật ký (xem số sê-ri).

Trong ví dụ này, một chương trình đóng hộp cát (ZZ0000ZZ) cố gắng gửi tín hiệu đến
quá trình init bị từ chối do hạn chế phạm vi tín hiệu
(ZZ0001ZZ)::

$ LL_FS_RO=/ LL_FS_RW=/ LL_SCOPED=s LL_FORCE_LOG=1 ./sandboxer giết 1

Lệnh này tạo ra hai sự kiện, mỗi sự kiện được xác định bằng một chuỗi duy nhất
số theo dấu thời gian (ZZ0000ZZ).  đầu tiên
sự kiện (nối tiếp ZZ0001ZZ) chứa 4 bản ghi.  Kỷ lục đầu tiên
(ZZ0002ZZ) hiển thị quyền truy cập bị miền ZZ0005ZZ từ chối.
Nguyên nhân của sự từ chối này là hạn chế phạm vi tín hiệu
(ZZ0003ZZ).  Quá trình sẽ nhận được tín hiệu này
là quá trình init (ZZ0004ZZ).

Bản ghi thứ hai (ZZ0000ZZ) mô tả (ZZ0001ZZ)
tên miền ZZ0004ZZ.  Miền này được tạo bởi quá trình ZZ0002ZZ thực thi
Chương trình ZZ0003ZZ do người dùng root khởi chạy.

Bản ghi thứ ba (ZZ0000ZZ) mô tả tòa nhà cao tầng, nó được cung cấp
đối số, kết quả của nó (ZZ0001ZZ) và quá trình gọi nó.

Bản ghi thứ tư (ZZ0000ZZ) hiển thị tên của lệnh dưới dạng
giá trị thập lục phân.  Điều này có thể được dịch bằng ZZ0001ZZ.

Cuối cùng, bản ghi cuối cùng (ZZ0000ZZ) cũng là bản ghi duy nhất từ ​​
sự kiện thứ hai (nối tiếp ZZ0001ZZ).  Nó không bị ràng buộc với hành động không gian người dùng trực tiếp
nhưng một tài nguyên không đồng bộ để giải phóng tài nguyên gắn liền với miền Landlock
(ZZ0002ZZ).  Điều này có thể hữu ích khi biết rằng các nhật ký sau
sẽ không còn liên quan đến tên miền ZZ0003ZZ nữa.  Bản ghi này cũng tóm tắt
số lượng yêu cầu mà miền này bị từ chối (ZZ0004ZZ), cho dù chúng có
đã đăng nhập hay chưa.

.. code-block::

  type=LANDLOCK_ACCESS msg=audit(1729738800.268:30): domain=1a6fdc66f blockers=scope.signal opid=1 ocomm="systemd"
  type=LANDLOCK_DOMAIN msg=audit(1729738800.268:30): domain=1a6fdc66f status=allocated mode=enforcing pid=286 uid=0 exe="/root/sandboxer" comm="sandboxer"
  type=SYSCALL msg=audit(1729738800.268:30): arch=c000003e syscall=62 success=no exit=-1 [..] ppid=272 pid=286 auid=0 uid=0 gid=0 [...] comm="kill" [...]
  type=PROCTITLE msg=audit(1729738800.268:30): proctitle=6B696C6C0031
  type=LANDLOCK_DOMAIN msg=audit(1729738800.324:31): domain=1a6fdc66f status=deallocated denials=1

Đây là một ví dụ khác thể hiện khả năng kiểm soát truy cập hệ thống tập tin::

$ LL_FS_RO=/ LL_FS_RW=/tmp LL_FORCE_LOG=1 ./sandboxer sh -c "echo > /etc/passwd"

Nhật ký kiểm tra liên quan chứa 8 bản ghi từ 3 sự kiện khác nhau (số 33,
34 và 35) được tạo bởi cùng một tên miền ZZ0000ZZ::

type=LANDLOCK_ACCESS msg=audit(1729738800.221:33): domain=1a6fdc679 blockers=fs.write_file path="/dev/tty" dev="devtmpfs" ino=9
  type=LANDLOCK_DOMAIN msg=audit(1729738800.221:33): domain=1a6fdc679 status=allocated mode=thực thi pid=289 uid=0 exe="/root/sandboxer" comm="sandboxer"
  type=SYSCALL msg=audit(1729738800.221:33): Arch=c000003e syscall=257 thành công=no exit=-13 […] ppid=272 pid=289 auid=0 uid=0 gid=0 […] comm="sh" [...]
  type=PROCTITLE msg=audit(1729738800.221:33): proctitle=7368002D63006563686F203E202F6574632F706173737764
  type=LANDLOCK_ACCESS msg=audit(1729738800.221:34): domain=1a6fdc679 blockers=fs.write_file path="/etc/passwd" dev="vda2" ino=143821
  type=SYSCALL msg=audit(1729738800.221:34): Arch=c000003e syscall=257 thành công=no exit=-13 […] ppid=272 pid=289 auid=0 uid=0 gid=0 […] comm="sh" [...]
  type=PROCTITLE msg=audit(1729738800.221:34): proctitle=7368002D63006563686F203E202F6574632F706173737764
  type=LANDLOCK_DOMAIN msg=audit(1729738800.261:35): miền=1a6fdc679 trạng thái=từ chối phân bổ=2


Lọc sự kiện
---------------

Nếu bạn bị spam nhật ký kiểm tra liên quan đến Landlock, thì đây có thể là một
nỗ lực tấn công hoặc một lỗi trong chính sách bảo mật.  Chúng ta có thể đặt một số
bộ lọc để hạn chế tiếng ồn bằng hai cách bổ sung:

- với các cờ của sys_landlock_restrict_self() nếu chúng tôi có thể sửa lỗi sandbox
  chương trình,
- hoặc với các quy tắc kiểm toán (xem ZZ0000ZZ).

Tài liệu bổ sung
========================

* ZZ0000ZZ
* Tài liệu/userspace-api/landlock.rst
* Tài liệu/bảo mật/landlock.rst
* ZZ0001ZZ

.. Links
.. _Linux Audit Documentation:
   https://github.com/linux-audit/audit-documentation/wiki