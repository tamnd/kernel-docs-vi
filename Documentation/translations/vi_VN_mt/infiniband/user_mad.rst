.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/infiniband/user_mad.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

======================
Truy cập không gian người dùng MAD
====================

Tệp thiết bị
============

Mỗi cổng của mỗi thiết bị InfiniBand có một thiết bị "umad" và một
  thiết bị "issm" được đính kèm.  Ví dụ: HCA hai cổng sẽ có hai
  thiết bị umad và hai thiết bị issm, trong khi switch sẽ có một thiết bị
  thiết bị của từng loại (đối với cổng switch 0).

Tạo đại lý MAD
===================

Một tác nhân MAD có thể được tạo bằng cách điền vào cấu trúc ib_user_mad_reg_req
  và sau đó gọi IB_USER_MAD_REGISTER_AGENT ioctl trên một tệp
  mô tả cho tập tin thiết bị thích hợp.  Nếu việc đăng ký
  yêu cầu thành công, id 32 bit sẽ được trả về trong cấu trúc.
  Ví dụ::

struct ib_user_mad_reg_req req = { /* ... */ };
	ret = ioctl(fd, IB_USER_MAD_REGISTER_AGENT, (char *) &req);
        nếu (!ret)
		my_agent = req.id;
	khác
		perror("đăng ký đại lý");

Đại lý có thể được hủy đăng ký với IB_USER_MAD_UNREGISTER_AGENT
  ioctl.  Ngoài ra, tất cả các đại lý được đăng ký thông qua bộ mô tả tệp sẽ
  không được đăng ký khi bộ mô tả bị đóng.

2014
       một ioctl đăng ký mới hiện đã được cung cấp cho phép bổ sung
       các trường sẽ được cung cấp trong quá trình đăng ký.
       Người dùng cuộc gọi đăng ký này đang ngầm thiết lập việc sử dụng
       pkey_index (xem bên dưới).

Nhận MAD
==============

MAD được nhận bằng cách sử dụng read().  Bên nhận bây giờ hỗ trợ
  RMPP. Bộ đệm được truyền cho read() phải có ít nhất một
  cấu trúc ib_user_mad + 256 byte. Ví dụ:

Nếu bộ đệm được truyền không đủ lớn để chứa dữ liệu nhận được
  MAD (RMPP), lỗi được đặt thành ENOSPC và độ dài của
  bộ đệm cần thiết được đặt trong mad.length.

Ví dụ cho MAD bình thường (không phải RMPP) đọc::

struct ib_user_mad *mad;
	điên = malloc(sizeof *mad + 256);
	ret = read(fd, mad, sizeof *mad + 256);
	if (ret != sizeof mad + 256) {
		perror("đọc");
		tự do (điên);
	}

Ví dụ cho RMPP đọc::

struct ib_user_mad *mad;
	điên = malloc(sizeof *mad + 256);
	ret = read(fd, mad, sizeof *mad + 256);
	nếu (ret == -ENOSPC)) {
		chiều dài = mad.length;
		tự do (điên);
		mad = malloc(sizeof *mad + length);
		ret = read(fd, mad, sizeof *mad + length);
	}
	nếu (ret < 0) {
		perror("đọc");
		tự do (điên);
	}

Ngoài nội dung MAD thực tế, cấu trúc khác ib_user_mad
  các trường sẽ được điền thông tin về MAD đã nhận.  cho
  ví dụ: LID từ xa sẽ ở dạng mad.lid.

Nếu quá trình gửi hết thời gian, một lần nhận sẽ được tạo với bộ mad.status
  tới ETIMEDOUT.  Ngược lại, khi MAD đã được nhận thành công,
  mad.status sẽ là 0.

poll()/select() có thể được sử dụng để đợi cho đến khi có thể đọc được MAD.

Gửi MAD
============

MAD được gửi bằng cách sử dụng write().  ID tác nhân để gửi phải là
  được điền vào trường id của MAD, LID đích sẽ là
  điền vào trường nắp, v.v.  Bên gửi có hỗ trợ
  RMPP nên có thể gửi MAD với độ dài tùy ý. Ví dụ::

struct ib_user_mad *mad;

mad = malloc(sizeof *mad + mad_length);

/* điền vào mad->data */

mad->hdr.id = my_agent;	/* req.id từ đăng ký đại lý */
	mad->hdr.lid = my_dest;		/* theo thứ tự byte mạng... */
	/* v.v. */

ret = write(fd, &mad, sizeof *mad + mad_length);
	if (ret != sizeof *mad + mad_length)
		lỗi ("viết");

ID giao dịch
===============

Người dùng thiết bị umad có thể sử dụng 32 bit thấp hơn của
  trường ID giao dịch (nghĩa là một nửa ít quan trọng nhất của
  trường theo thứ tự byte mạng) trong MAD được gửi để khớp
  cặp yêu cầu/phản hồi.  32 bit trên được dành riêng để sử dụng bởi
  kernel và sẽ bị ghi đè trước khi MAD được gửi.

Xử lý chỉ mục P_Key
====================

Giao diện ib_umad cũ không cho phép thiết lập chỉ mục P_Key cho
  MAD được gửi và không cung cấp cách lấy P_Key
  chỉ số của MAD nhận được.  Bố cục mới cho struct ib_user_mad_hdr
  với thành viên pkey_index đã được xác định; tuy nhiên, để bảo toàn nhị phân
  khả năng tương thích với các ứng dụng cũ hơn, bố cục mới này sẽ không được sử dụng
  trừ khi một trong các IB_USER_MAD_ENABLE_PKEY hoặc IB_USER_MAD_REGISTER_AGENT2 ioctl
  được gọi trước khi bộ mô tả tệp được sử dụng cho bất kỳ mục đích nào khác.

Vào tháng 9 năm 2008, IB_USER_MAD_ABI_VERSION sẽ được tăng lên
  lên 6, bố cục mới của struct ib_user_mad_hdr sẽ được sử dụng bởi
  mặc định và IB_USER_MAD_ENABLE_PKEY ioctl sẽ bị xóa.

Đặt bit khả năng IsSM
===========================

Để đặt bit khả năng IsSM cho một cổng, chỉ cần mở
  tập tin thiết bị issm tương ứng.  Nếu bit IsSM đã được thiết lập,
  thì lệnh gọi open sẽ chặn cho đến khi bit bị xóa (hoặc trả về
  ngay lập tức với lỗi được đặt thành EAGAIN nếu cờ O_NONBLOCK là
  được chuyển tới open()).  Bit IsSM sẽ bị xóa khi tệp issm
  đã đóng cửa.  Không thể thực hiện đọc, ghi hoặc các thao tác khác trên
  tập tin issm.

tập tin /dev
==========

Để tự động tạo các tập tin thiết bị ký tự phù hợp với
  udev, một quy tắc như::

KERNEL=="umad*", NAME="infiniband/%k"
    KERNEL=="issm*", NAME="infiniband/%k"

có thể được sử dụng  Điều này sẽ tạo các nút thiết bị có tên::

/dev/infiniband/umad0
    /dev/infiniband/issm0

cho cổng đầu tiên, v.v.  Thiết bị và cổng InfiniBand
  được liên kết với các thiết bị này có thể được xác định từ các tệp ::

/sys/class/infiniband_mad/umad0/ibdev
    /sys/class/infiniband_mad/umad0/port

Và::

/sys/class/infiniband_mad/issm0/ibdev
    /sys/class/infiniband_mad/issm0/port
