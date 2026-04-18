.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/userspace-api/vduse.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

===================================================
VDUSE - "Thiết bị vDPA trong không gian người dùng"
===================================================

Thiết bị vDPA (tăng tốc đường dẫn dữ liệu virtio) là thiết bị sử dụng
đường dẫn dữ liệu tuân thủ các thông số kỹ thuật virtio với nhà cung cấp
đường điều khiển cụ thể. Các thiết bị vDPA có thể được đặt ở cả hai vị trí vật lý trên
phần cứng hoặc được mô phỏng bằng phần mềm. VDUSE là một framework làm cho nó
có thể triển khai các thiết bị vDPA được mô phỏng bằng phần mềm trong không gian người dùng. Và
để làm cho việc mô phỏng thiết bị an toàn hơn, thiết bị vDPA được mô phỏng
đường dẫn điều khiển được xử lý trong kernel và chỉ đường dẫn dữ liệu được
được thực hiện trong không gian người dùng.

Lưu ý rằng hiện tại chỉ có thiết bị khối virtio được khung VDUSE hỗ trợ,
có thể giảm rủi ro bảo mật khi quy trình không gian người dùng thực hiện
đường dẫn dữ liệu được điều hành bởi người dùng không có đặc quyền. Hỗ trợ cho thiết bị khác
các loại có thể được thêm vào sau sự cố bảo mật của trình điều khiển thiết bị tương ứng
được làm rõ hoặc cố định trong tương lai.

Tạo/hủy thiết bị VDUSE
----------------------------

Các thiết bị VDUSE được tạo như sau:

1. Tạo một phiên bản VDUSE mới với ioctl(VDUSE_CREATE_DEV) bật
   /dev/vduse/control.

2. Thiết lập từng Virtqueue với ioctl(VDUSE_VQ_SETUP) trên /dev/vduse/$NAME.

3. Bắt đầu xử lý tin nhắn VDUSE từ /dev/vduse/$NAME. đầu tiên
   thông báo sẽ đến trong khi gắn phiên bản VDUSE vào bus vDPA.

4. Gửi tin nhắn liên kết mạng VDPA_CMD_DEV_NEW để đính kèm VDUSE
   dụ tới bus vDPA.

Các thiết bị VDUSE bị phá hủy như sau:

1. Gửi tin nhắn liên kết mạng VDPA_CMD_DEV_DEL để tách VDUSE
   ví dụ từ xe buýt vDPA.

2. Đóng bộ mô tả tệp tham chiếu đến /dev/vduse/$NAME.

3. Phá hủy phiên bản VDUSE bằng ioctl(VDUSE_DESTROY_DEV) bật
   /dev/vduse/control.

Các tin nhắn liên kết mạng có thể được gửi qua công cụ vdpa trong iproute2 hoặc sử dụng
mã mẫu dưới đây:

.. code-block:: c

	static int netlink_add_vduse(const char *name, enum vdpa_command cmd)
	{
		struct nl_sock *nlsock;
		struct nl_msg *msg;
		int famid;

		nlsock = nl_socket_alloc();
		if (!nlsock)
			return -ENOMEM;

		if (genl_connect(nlsock))
			goto free_sock;

		famid = genl_ctrl_resolve(nlsock, VDPA_GENL_NAME);
		if (famid < 0)
			goto close_sock;

		msg = nlmsg_alloc();
		if (!msg)
			goto close_sock;

		if (!genlmsg_put(msg, NL_AUTO_PORT, NL_AUTO_SEQ, famid, 0, 0, cmd, 0))
			goto nla_put_failure;

		NLA_PUT_STRING(msg, VDPA_ATTR_DEV_NAME, name);
		if (cmd == VDPA_CMD_DEV_NEW)
			NLA_PUT_STRING(msg, VDPA_ATTR_MGMTDEV_DEV_NAME, "vduse");

		if (nl_send_sync(nlsock, msg))
			goto close_sock;

		nl_close(nlsock);
		nl_socket_free(nlsock);

		return 0;
	nla_put_failure:
		nlmsg_free(msg);
	close_sock:
		nl_close(nlsock);
	free_sock:
		nl_socket_free(nlsock);
		return -1;
	}

VDUSE hoạt động như thế nào
---------------

Như đã đề cập ở trên, thiết bị VDUSE được tạo bởi ioctl(VDUSE_CREATE_DEV) trên
/dev/vduse/control. Với ioctl này, không gian người dùng có thể chỉ định một số cấu hình cơ bản
chẳng hạn như tên thiết bị (nhận dạng duy nhất một thiết bị VDUSE), tính năng virtio, virtio
không gian cấu hình, số lượng đức tính, v.v. cho thiết bị mô phỏng này.
Sau đó, giao diện thiết bị char (/dev/vduse/$NAME) được xuất sang không gian người dùng cho thiết bị
thi đua. Không gian người dùng có thể sử dụng ioctl VDUSE_VQ_SETUP trên /dev/vduse/$NAME để
thêm cấu hình cho mỗi Virtqueue, chẳng hạn như kích thước tối đa của Virtqueue cho thiết bị.

Sau khi khởi tạo, thiết bị VDUSE có thể được gắn vào bus vDPA thông qua
thông báo liên kết mạng VDPA_CMD_DEV_NEW. Không gian người dùng cần đọc()/write() trên
/dev/vduse/$NAME để nhận/trả lời một số tin nhắn điều khiển từ/đến hạt nhân VDUSE
mô-đun như sau:

.. code-block:: c

	static int vduse_message_handler(int dev_fd)
	{
		int len;
		struct vduse_dev_request req;
		struct vduse_dev_response resp;

		len = read(dev_fd, &req, sizeof(req));
		if (len != sizeof(req))
			return -1;

		resp.request_id = req.request_id;

		switch (req.type) {

		/* handle different types of messages */

		}

		len = write(dev_fd, &resp, sizeof(resp));
		if (len != sizeof(resp))
			return -1;

		return 0;
	}

Hiện tại có ba loại thông báo được giới thiệu bởi khung VDUSE:

- VDUSE_GET_VQ_STATE: Lấy trạng thái cho Virtqueue, userspace sẽ trả về
  chỉ mục tận dụng cho hàng đợi phân chia hoặc bộ đếm vòng bọc thiết bị/trình điều khiển và
  chỉ mục có sẵn và được sử dụng cho hàng đợi đức hạnh được đóng gói.

- VDUSE_SET_STATUS: Đặt trạng thái thiết bị, không gian người dùng phải tuân theo
  thông số kỹ thuật: ZZ0000ZZ
  để xử lý tin nhắn này. Ví dụ: không cài đặt được thiết bị FEATURES_OK
  bit trạng thái nếu thiết bị không thể chấp nhận các tính năng virtio đã thương lượng
  lấy từ VDUSE_DEV_GET_FEATURES ioctl.

- VDUSE_UPDATE_IOTLB: Thông báo cho không gian người dùng cập nhật ánh xạ bộ nhớ cho các mục được chỉ định
  Phạm vi IOVA, không gian người dùng trước tiên phải xóa ánh xạ cũ, sau đó thiết lập ánh xạ mới
  ánh xạ thông qua VDUSE_IOTLB_GET_FD ioctl.

Sau khi bit trạng thái DRIVER_OK được đặt thông qua thông báo VDUSE_SET_STATUS, không gian người dùng sẽ được
có thể bắt đầu xử lý dataplane như sau:

1. Nhận thông tin của hàng đợi đức hạnh được chỉ định bằng ioctl VDUSE_VQ_GET_INFO,
   bao gồm kích thước, IOVA của bảng mô tả, vòng có sẵn và vòng đã sử dụng,
   trạng thái và trạng thái sẵn sàng.

2. Chuyển các IOVA ở trên tới VDUSE_IOTLB_GET_FD ioctl để các vùng IOVA đó
   có thể được ánh xạ vào không gian người dùng. Một số mã mẫu được hiển thị dưới đây:

.. code-block:: c

	static int perm_to_prot(uint8_t perm)
	{
		int prot = 0;

		switch (perm) {
		case VDUSE_ACCESS_WO:
			prot |= PROT_WRITE;
			break;
		case VDUSE_ACCESS_RO:
			prot |= PROT_READ;
			break;
		case VDUSE_ACCESS_RW:
			prot |= PROT_READ | PROT_WRITE;
			break;
		}

		return prot;
	}

	static void *iova_to_va(int dev_fd, uint64_t iova, uint64_t *len)
	{
		int fd;
		void *addr;
		size_t size;
		struct vduse_iotlb_entry entry;

		entry.start = iova;
		entry.last = iova;

		/*
		 * Find the first IOVA region that overlaps with the specified
		 * range [start, last] and return the corresponding file descriptor.
		 */
		fd = ioctl(dev_fd, VDUSE_IOTLB_GET_FD, &entry);
		if (fd < 0)
			return NULL;

		size = entry.last - entry.start + 1;
		*len = entry.last - iova + 1;
		addr = mmap(0, size, perm_to_prot(entry.perm), MAP_SHARED,
			    fd, entry.offset);
		close(fd);
		if (addr == MAP_FAILED)
			return NULL;

		/*
		 * Using some data structures such as linked list to store
		 * the iotlb mapping. The munmap(2) should be called for the
		 * cached mapping when the corresponding VDUSE_UPDATE_IOTLB
		 * message is received or the device is reset.
		 */

		return addr + iova - entry.start;
	}

3. Thiết lập kick eventfd cho các đức tính được chỉ định với VDUSE_VQ_SETUP_KICKFD
   ioctl. Sự kiện kickfd được mô-đun hạt nhân VDUSE sử dụng để thông báo không gian người dùng tới
   tiêu thụ chiếc nhẫn có sẵn. Đây là tùy chọn vì không gian người dùng có thể chọn thăm dò ý kiến
   thay vào đó là chiếc nhẫn có sẵn.

4. Nghe sự kiện kickfd (tùy chọn) và tiêu thụ chiếc nhẫn có sẵn. Bộ đệm
   được mô tả bởi các bộ mô tả trong bảng mô tả cũng phải được ánh xạ vào
   không gian người dùng thông qua VDUSE_IOTLB_GET_FD ioctl trước khi truy cập.

5. Chèn một ngắt cho hàng đợi cụ thể bằng VDUSE_INJECT_VQ_IRQ ioctl
   sau khi chiếc nhẫn đã sử dụng được lấp đầy.

Kích hoạt ASID (API phiên bản 1)
------------------------------

VDUSE hỗ trợ mã định danh trên mỗi không gian địa chỉ (ASID) bắt đầu bằng API
phiên bản 1. Thiết lập nó với ioctl(VDUSE_SET_API_VERSION) trên ZZ0000ZZ
và vượt qua ZZ0001ZZ trước khi tạo phiên bản VDUSE mới với
ioctl(VDUSE_CREATE_DEV).

Sau đó, bạn có thể sử dụng đối số thành viên của ioctl(VDUSE_VQ_SETUP) để
chọn không gian địa chỉ của IOTLB bạn đang truy vấn.  Người lái xe có thể
thay đổi không gian địa chỉ của bất kỳ nhóm Virtqueue nào bằng cách sử dụng
Loại thông báo VDUSE_SET_VQ_GROUP_ASID VDUSE và phiên bản VDUSE cần phải
trả lời bằng VDUSE_REQ_RESULT_OK nếu có thể thay đổi.

Tương tự, bạn có thể sử dụng ioctl(VDUSE_IOTLB_GET_FD2) để lấy bộ mô tả tệp
mô tả vùng IOVA của ASID cụ thể. Cách sử dụng ví dụ:

.. code-block:: c

	static void *iova_to_va(int dev_fd, uint32_t asid, uint64_t iova,
	                        uint64_t *len)
	{
		int fd;
		void *addr;
		size_t size;
		struct vduse_iotlb_entry_v2 entry = { 0 };

		entry.v1.start = iova;
		entry.v1.last = iova;
		entry.asid = asid;

		fd = ioctl(dev_fd, VDUSE_IOTLB_GET_FD2, &entry);
		if (fd < 0)
			return NULL;

		size = entry.v1.last - entry.v1.start + 1;
		*len = entry.v1.last - iova + 1;
		addr = mmap(0, size, perm_to_prot(entry.v1.perm), MAP_SHARED,
			    fd, entry.v1.offset);
		close(fd);
		if (addr == MAP_FAILED)
			return NULL;

		/*
		 * Using some data structures such as linked list to store
		 * the iotlb mapping. The munmap(2) should be called for the
		 * cached mapping when the corresponding VDUSE_UPDATE_IOTLB
		 * message is received or the device is reset.
		 */

		return addr + iova - entry.v1.start;
	}

Để biết thêm chi tiết về uAPI, vui lòng xem include/uapi/linux/vduse.h.
