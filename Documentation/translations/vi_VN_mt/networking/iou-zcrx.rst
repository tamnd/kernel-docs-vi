.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/networking/iou-zcrx.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=======================
io_uring không sao chép Rx
=====================

Giới thiệu
============

io_uring zero copy Rx (ZC Rx) là tính năng loại bỏ bản sao kernel-to-user trên
đường dẫn nhận mạng, cho phép nhận dữ liệu gói trực tiếp vào
bộ nhớ không gian người dùng. Tính năng này khác với TCP_ZEROCOPY_RECEIVE ở chỗ
không có yêu cầu căn chỉnh nghiêm ngặt và không cần mmap()/munmap().
So với các giải pháp bỏ qua kernel như ví dụ: DPDK, tiêu đề gói là
được xử lý bởi ngăn xếp kernel TCP như bình thường.

Yêu cầu CTNH NIC
===================

Cần có một số tính năng NIC HW để io_uring ZC Rx hoạt động. Hiện tại
kernel API không cấu hình NIC và việc này phải do người dùng thực hiện.

Tách tiêu đề/dữ liệu
-----------------

Cần thiết để phân chia các gói ở ranh giới L4 thành tiêu đề và tải trọng.
Các tiêu đề được nhận vào bộ nhớ kernel như bình thường và được TCP xử lý
xếp chồng lên nhau như bình thường. Tải trọng được nhận trực tiếp vào bộ nhớ không gian người dùng.

Điều khiển dòng chảy
-------------

Hàng đợi HW Rx cụ thể được định cấu hình cho tính năng này, nhưng các NIC hiện đại
thường phân phối các luồng trên tất cả các hàng đợi HW Rx. Cần phải điều khiển dòng chảy
để đảm bảo rằng chỉ các luồng mong muốn mới được hướng tới hàng đợi CTNH được
được cấu hình cho io_uring ZC Rx.

RSS
---

Ngoài việc điều khiển luồng ở trên, RSS còn phải điều khiển tất cả các điểm khác 0 khác
bản sao chảy ra khỏi hàng đợi được định cấu hình cho io_uring ZC Rx.

Cách sử dụng
=====

Cài đặt NIC
---------

Bây giờ phải được thực hiện ngoài ban nhạc.

Đảm bảo có ít nhất hai hàng đợi::

ethtool -L eth0 kết hợp 2

Bật phân chia tiêu đề/dữ liệu::

ethtool -G eth0 tcp-data-split trên

Loại bỏ một nửa hàng đợi HW Rx để không có bản sao nào bằng cách sử dụng RSS::

ethtool -X eth0 bằng 1

Thiết lập điều khiển luồng, lưu ý rằng hàng đợi được lập chỉ mục 0::

ethtool -N eth0 loại luồng tcp6 ... hành động 1

Thiết lập io_uring
--------------

Phần này mô tả hạt nhân io_uring cấp thấp API. Vui lòng tham khảo
tài liệu hướng dẫn cách sử dụng API cấp cao hơn.

Tạo một phiên bản io_uring với các cờ thiết lập bắt buộc sau::

IORING_SETUP_SINGLE_ISSUER
  IORING_SETUP_DEFER_TASKRUN
  IORING_SETUP_CQE32 hoặc IORING_SETUP_CQE_MIXED

Tạo vùng nhớ
------------------

Phân bổ vùng bộ nhớ không gian người dùng để nhận dữ liệu không sao chép::

void *area_ptr = mmap(NULL, size_size,
                        PROT_READ | PROT_WRITE,
                        MAP_ANONYMOUS | MAP_PRIVATE,
                        0, 0);

Tạo vòng nạp tiền
------------------

Phân bổ bộ nhớ cho ringbuf dùng chung được sử dụng để trả về bộ đệm đã sử dụng ::

void *ring_ptr = mmap(NULL, ring_size,
                        PROT_READ | PROT_WRITE,
                        MAP_ANONYMOUS | MAP_PRIVATE,
                        0, 0);

Vòng nạp lại này bao gồm một số khoảng trống cho tiêu đề, theo sau là một mảng
ZZ0000ZZ::

size_t rq_entries = 4096;
  size_t ring_size = rq_entries * sizeof(struct io_uring_zcrx_rqe) + PAGE_SIZE;
  /* căn chỉnh theo kích thước trang */
  ring_size = (ring_size + (PAGE_SIZE - 1)) & ~(PAGE_SIZE - 1);

Đăng ký ZC Rx
--------------

Điền thông tin đăng ký::

cấu trúc io_uring_zcrx_area_reg Area_reg = {
    .addr = (__u64)(dài không dấu)area_ptr,
    .len = kích thước vùng,
    .flags = 0,
  };

cấu trúc io_uring_khu vực_desc khu vực_reg = {
    .user_addr = (__u64)(dài không dấu)ring_ptr,
    .size = ring_size,
    .flags = IORING_MEM_REGION_TYPE_USER,
  };

cấu trúc io_uring_zcrx_ifq_reg reg = {
    .if_idx = if_nametoindex("eth0"),
    /* đây là hàng đợi CTNH có luồng mong muốn được đưa vào đó */
    .if_rxq = 1,
    .rq_entries = rq_entries,
    .area_ptr = (__u64)(dài không dấu)&area_reg,
    .khu vực_ptr = (__u64)(dài không dấu)&khu vực_reg,
  };

Đăng ký với hạt nhân::

io_uring_register_ifq(ring, &reg);

Vòng nạp bản đồ
---------------

Hạt nhân điền vào các trường cho vòng nạp lại trong đăng ký ZZ0000ZZ. Ánh xạ nó vào không gian người dùng::

cấu trúc io_uring_zcrx_rq nạp_ring;

nạp_ring.khead = (ZZ0000ZZ không dấu)ring_ptr + reg.offsets.head);
  nạp_ring.khead = (ZZ0001ZZ không dấu)ring_ptr + reg.offsets.tail);
  nạp_ring.rqes =
    (struct io_uring_zcrx_rqe ZZ0002ZZ)ring_ptr + reg.offsets.rqes);
  nạp_ring.rq_tail = 0;
  nạp_ring.ring_ptr = ring_ptr;

Đang nhận dữ liệu
--------------

Chuẩn bị yêu cầu recv không sao chép::

cấu trúc io_uring_sqe *sqe;

sqe = io_uring_get_sqe(vòng);
  io_uring_prep_rw(IORING_OP_RECV_ZC, sqe, fd, NULL, 0, 0);
  sqe->ioprio |= IORING_RECV_MULTISHOT;

Bây giờ, hãy gửi và chờ đợi::

io_uring_submit_and_wait(ring, 1);

Cuối cùng, quá trình hoàn tất::

cấu trúc io_uring_cqe *cqe;
  số int không dấu = 0;
  đầu int không dấu;

io_uring_for_each_cqe(ring, head, cqe) {
    cấu trúc io_uring_zcrx_cqe ZZ0000ZZ)(cqe + 1);

mặt nạ dài không dấu = (1ULL << IORING_ZCRX_AREA_SHIFT) - 1;
    unsigned char *data = Area_ptr + (rcqe->off & mặt nạ);
    /*làm gì đó với dữ liệu*/

đếm++;
  }
  io_uring_cq_advance(đổ chuông, đếm);

Bộ đệm tái chế
-----------------

Trả bộ đệm trở lại kernel để sử dụng lại ::

cấu trúc io_uring_zcrx_rqe *rqe;
  mặt nạ không dấu = nạp_ring.ring_entries - 1;
  rqe = &refill_ring.rqes[refill_ring.rq_tail & mặt nạ];

vùng dài không dấu_offset = rcqe->off & ~IORING_ZCRX_AREA_MASK;
  rqe->off = Area_offset | khu vực_reg.rq_area_token;
  rqe->len = cqe->res;
  IO_URING_WRITE_ONCE(*refill_ring.ktail, ++refill_ring.rq_tail);

Phân chia khu vực
-------------

zcrx chia vùng bộ nhớ thành các phần liền kề về mặt vật lý có độ dài cố định.
Điều này giới hạn kích thước bộ đệm tối đa được trả về trong một io_uring CQE. Người dùng
có thể cung cấp gợi ý cho kernel để sử dụng các khối lớn hơn bằng cách đặt
Trường ZZ0000ZZ của ZZ0001ZZ theo độ dài mong muốn
trong quá trình đăng ký. Nếu trường này được đặt thành 0 thì kernel mặc định là
kích thước trang hệ thống.

Để sử dụng kích thước lớn hơn, vùng bộ nhớ phải được hỗ trợ bởi các vùng vật lý liền kề
phạm vi có kích thước là bội số của ZZ0000ZZ. Nó cũng yêu cầu kernel
và hỗ trợ phần cứng. Nếu đăng ký không thành công, người dùng thường phải
quay trở lại mặc định bằng cách đặt ZZ0001ZZ về 0.

Các khối lớn hơn không đưa ra bất kỳ đảm bảo bổ sung nào về kích thước bộ đệm được trả về
trong CQE và chúng có thể khác nhau tùy thuộc vào nhiều yếu tố như mô hình lưu lượng truy cập,
giảm tải phần cứng, v.v. Nó không yêu cầu bất kỳ thay đổi ứng dụng nào ngoài zcrx
đăng ký.

Kiểm tra
=======

Xem ZZ0000ZZ