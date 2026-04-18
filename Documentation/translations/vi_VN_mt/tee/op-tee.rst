.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/tee/op-tee.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

=========================================================
OP-TEE (Môi trường thực thi tin cậy di động mở)
====================================================

Trình điều khiển OP-TEE xử lý TEE dựa trên OP-TEE [1]. Hiện tại chỉ có ARM
Giải pháp OP-TEE dựa trên TrustZone được hỗ trợ.

Mức liên lạc thấp nhất với OP-TEE được xây dựng trên ARM SMC
Quy ước (SMCCC) [2], là nền tảng cho giao diện SMC của OP-TEE
[3] được người lái xe sử dụng nội bộ. Xếp chồng lên trên đó là Tin nhắn OP-TEE
Giao thức [4].

Giao diện OP-TEE SMC cung cấp các chức năng cơ bản theo yêu cầu của SMCCC và một số
các chức năng bổ sung dành riêng cho OP-TEE. Các chức năng thú vị nhất là:

- OPTEE_SMC_FUNCID_CALLS_UID (một phần của SMCCC) trả về thông tin phiên bản
  sau đó được trả về bởi TEE_IOC_VERSION

- OPTEE_SMC_CALL_GET_OS_UUID trả về triển khai OP-TEE cụ thể, được sử dụng
  chẳng hạn, để phân biệt TrustZone OP-TEE ngoài OP-TEE chạy trên
  bộ đồng xử lý an toàn riêng biệt.

- OPTEE_SMC_CALL_WITH_ARG điều khiển giao thức tin nhắn OP-TEE

- OPTEE_SMC_GET_SHM_CONFIG cho phép trình điều khiển và OP-TEE thống nhất về bộ nhớ
  phạm vi được sử dụng cho bộ nhớ dùng chung giữa Linux và OP-TEE.

GlobalPlatform TEE Client API [5] được triển khai dựa trên phiên bản chung
TEE API.

Hình ảnh về mối quan hệ giữa các thành phần khác nhau trong
Kiến trúc OP-TEE::

Không gian người dùng Kernel Secure world
      ~~~~~~~~~~ ~~~~~~ ~~~~~~~~~~~~
   +--------+ +-------------+
   ZZ0001ZZ ZZ0002ZZ
   +--------+ ZZ0003ZZ
      /\ +-------------+
      || +----------+ /\
      || |tee- ZZ0005ZZ|
      || |người cung cấp|                                           \/
      || +----------+ +-------------+
      \/ /\ ZZ0007ZZ
   +-------+ |ZZ0008ZZ API |
   + TEE ZZ0009ZZ|            +--------+--------+ +-------------+
   ZZ0010ZZ |ZZ0011ZZ TEE ZZ0012ZZ ZZ0013ZZ
   Trình điều khiển ZZ0014ZZ \/ ZZ0015ZZ Hệ điều hành đáng tin cậy ZZ0016ZZ |
   +-------+-------+----+-------+----+----------+-------------+
   ZZ0017ZZ ZZ0018ZZ
   ZZ0019ZZ
   +------------------------------------------+ +------------------------------+

RPC (Cuộc gọi thủ tục từ xa) là các yêu cầu từ thế giới bảo mật đến trình điều khiển kernel
hoặc người cầu xin tee. RPC được xác định bằng phạm vi trả về SMCCC đặc biệt
giá trị từ OPTEE_SMC_CALL_WITH_ARG. Các tin nhắn RPC dành cho
kernel được xử lý bởi trình điều khiển kernel. Các tin nhắn RPC khác sẽ được chuyển tiếp tới
người yêu cầu phát bóng mà không cần có sự tham gia của người lái xe, ngoại trừ việc chuyển đổi
biểu diễn bộ nhớ đệm dùng chung.

Bảng liệt kê thiết bị OP-TEE
-------------------------

OP-TEE cung cấp Ứng dụng đáng tin cậy giả: driver/tee/optee/device.c trong
để hỗ trợ liệt kê thiết bị. Nói cách khác, trình điều khiển OP-TEE gọi điều này
ứng dụng để truy xuất danh sách Ứng dụng đáng tin cậy có thể được đăng ký
như các thiết bị trên bus TEE.

Thông báo OP-TEE
--------------------

Có hai loại thông báo mà thế giới an toàn có thể sử dụng để thực hiện
thế giới bình thường biết về một số sự kiện.

1. Thông báo đồng bộ được gửi bằng ZZ0000ZZ
   sử dụng tham số ZZ0001ZZ.
2. Thông báo không đồng bộ được gửi bằng sự kết hợp của một cơ chế không bảo mật
   ngắt kích hoạt cạnh và lệnh gọi nhanh từ ngắt không an toàn
   người xử lý.

Thông báo đồng bộ bị giới hạn tùy thuộc vào RPC để gửi,
điều này chỉ có thể sử dụng được khi thế giới an toàn được tham gia bằng một cuộc gọi mang lại thông qua
ZZ0000ZZ. Điều này loại trừ các thông báo như vậy khỏi hệ thống an toàn
xử lý ngắt thế giới.

Thông báo không đồng bộ được gửi qua thiết bị kích hoạt cạnh không an toàn
ngắt tới trình xử lý ngắt được đăng ký trong trình điều khiển OP-TEE. các
giá trị thông báo thực tế được lấy bằng cuộc gọi nhanh
ZZ0000ZZ. Lưu ý rằng một ngắt có thể đại diện
nhiều thông báo.

Một giá trị thông báo ZZ0000ZZ có
ý nghĩa đặc biệt. Khi giá trị này được nhận, điều đó có nghĩa là thế giới bình thường
phải thực hiện một cuộc gọi mang lại ZZ0001ZZ. Cái này
cuộc gọi được thực hiện từ luồng hỗ trợ trình xử lý ngắt. Đây là một
khối xây dựng cho hệ điều hành OP-TEE trong thế giới an toàn để triển khai nửa trên và
kiểu nửa dưới của trình điều khiển thiết bị.

Tùy chọn Kconfig OPTEE_INSECURE_LOAD_IMAGE
----------------------------------------

Tùy chọn OPTEE_INSECURE_LOAD_IMAGE Kconfig cho phép khả năng tải
Hình ảnh BL32 OP-TEE từ kernel sau khi kernel khởi động, thay vì tải
nó từ phần sụn trước khi kernel khởi động. Điều này cũng đòi hỏi phải kích hoạt
tùy chọn tương ứng trong Phần sụn đáng tin cậy cho Arm. Firmware đáng tin cậy cho Arm
tài liệu [6] giải thích mối đe dọa bảo mật liên quan đến việc kích hoạt tính năng này như
cũng như các biện pháp giảm nhẹ ở cấp độ phần sụn và nền tảng.

Có các vectơ/ biện pháp giảm thiểu tấn công bổ sung cho kernel cần được
được giải quyết khi sử dụng tùy chọn này.

1. Bảo mật chuỗi khởi động.

* Vector tấn công: Thay thế image OS OP-TEE trong rootfs để giành quyền kiểm soát
     hệ thống.

* Biện pháp giảm thiểu: Phải có bảo mật chuỗi khởi động để xác minh kernel và
     rootfs, nếu không kẻ tấn công có thể sửa đổi tệp nhị phân OP-TEE đã tải bằng cách
     sửa đổi nó trong rootfs.

2. Các chế độ khởi động thay thế.

* Vectơ tấn công: Sử dụng chế độ khởi động thay thế (tức là chế độ khôi phục),
     Trình điều khiển OP-TEE không được tải, khiến lỗ SMC mở.

* Biện pháp giảm thiểu: Nếu có các phương pháp khởi động thiết bị thay thế, chẳng hạn như
     chế độ khôi phục, cần đảm bảo rằng các biện pháp giảm thiểu tương tự được áp dụng
     ở chế độ đó.

3. Tấn công trước khi gọi SMC.

* Vectơ tấn công: Mã được thực thi trước khi đưa ra lệnh gọi SMC để tải
     OP-TEE có thể bị khai thác để tải hình ảnh hệ điều hành thay thế.

* Giảm thiểu: Trình điều khiển OP-TEE phải được tải trước bất kỳ cuộc tấn công tiềm ẩn nào
     vectơ được mở ra Điều này bao gồm việc gắn bất kỳ thiết bị có thể sửa đổi nào
     hệ thống tập tin, mở cổng mạng hoặc giao tiếp với bên ngoài
     thiết bị (ví dụ USB).

4. Chặn cuộc gọi SMC để tải OP-TEE.

* Vector tấn công: Ngăn chặn việc thăm dò driver nên SMC gọi tới
     tải OP-TEE không được thực thi khi muốn, để nó mở để được thực thi
     sau đó và tải một hệ điều hành đã sửa đổi.

* Giảm thiểu: Nên xây dựng trình điều khiển OP-TEE làm trình điều khiển tích hợp
     chứ không phải là một mô-đun để ngăn chặn việc khai thác có thể khiến mô-đun
     không được tải.

Tài liệu tham khảo
==========

[1] ZZ0000ZZ

[2] ZZ0000ZZ

[3] trình điều khiển/tee/optee/optee_smc.h

[4] trình điều khiển/tee/optee/optee_msg.h

[5] ZZ0000ZZ tìm kiếm
    "TEE Client API Thông số kỹ thuật v1.0" và nhấp vào tải xuống.

[6] ZZ0000ZZ