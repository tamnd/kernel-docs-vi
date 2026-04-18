.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/gpu/vkms.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. _vkms:

==============================================
 drm/vkms Cài đặt chế độ hạt nhân ảo
==============================================

.. kernel-doc:: drivers/gpu/drm/vkms/vkms_drv.c
   :doc: vkms (Virtual Kernel Modesetting)

Cài đặt
=====

Trình điều khiển VKMS có thể được thiết lập theo các bước sau:

Để kiểm tra xem VKMS đã được tải chưa, hãy chạy::

lsmod | grep vkm

Điều này sẽ liệt kê trình điều khiển VKMS. Nếu không thu được đầu ra thì
bạn cần kích hoạt và/hoặc tải trình điều khiển VKMS.
Đảm bảo rằng trình điều khiển VKMS đã được đặt làm mô-đun có thể tải trong
tập tin cấu hình kernel. LÀM::

tạo nconfig

Đi đến ZZ0000ZZ

Kích hoạt ZZ0000ZZ

Biên dịch và xây dựng kernel để những thay đổi được phản ánh.
Bây giờ, để tải trình điều khiển, hãy sử dụng::

sudo modprobe vkms

Khi chạy lệnh lsmod bây giờ, trình điều khiển VKMS sẽ xuất hiện trong danh sách.
Bạn cũng có thể quan sát trình điều khiển đang được tải trong nhật ký dmesg.

Trình điều khiển VKMS có các tính năng tùy chọn để mô phỏng các loại phần cứng khác nhau,
được hiển thị dưới dạng tùy chọn mô-đun. Bạn có thể sử dụng lệnh ZZ0000ZZ
để xem các tùy chọn mô-đun cho vkms::

modinfo vkms

Tùy chọn mô-đun rất hữu ích khi thử nghiệm và kích hoạt mô-đun
có thể được thực hiện trong khi tải vkms. Ví dụ: để tải vkm khi bật con trỏ,
sử dụng::

Sudo modprobe vkms Enable_cursor=1

Để tắt trình điều khiển, hãy sử dụng ::

sudo modprobe -r vkms

Định cấu hình bằng Configfs
=========================

Có thể tạo và định cấu hình nhiều phiên bản VKMS thông qua configfs.

Bắt đầu bằng cách gắn configfs và tải VKMS::

sudo mount -t configfs none/config
  sudo modprobe vkms

Khi VKMS được tải, ZZ0000ZZ sẽ được tạo tự động. Mỗi thư mục
trong ZZ0001ZZ đại diện cho một phiên bản VKMS, hãy tạo một phiên bản mới::

sudo mkdir /config/vkms/my-vkms

Theo mặc định, phiên bản bị tắt::

mèo /config/vkms/my-vkms/enabled
  0

Và các thư mục được tạo cho từng mục có thể định cấu hình của đường dẫn hiển thị ::

cây /config/vkms/my-vkms
  ├── đầu nối
  ├── crtcs
  ├── đã bật
  ├── bộ mã hóa
  └── máy bay

Để thêm các mục vào đường dẫn hiển thị, hãy tạo một hoặc nhiều thư mục trong
những con đường có sẵn.

Bắt đầu bằng cách tạo một hoặc nhiều mặt phẳng::

sudo mkdir /config/vkms/my-vkms/planes/plane0

Máy bay có 1 thuộc tính có thể cấu hình:

- loại: Loại mặt phẳng: 0 lớp phủ, 1 chính, 2 con trỏ (cùng giá trị với các giá trị đó
  được hiển thị bởi thuộc tính "loại" của mặt phẳng)

Tiếp tục bằng cách tạo một hoặc nhiều CRTC::

sudo mkdir /config/vkms/my-vkms/crtcs/crtc0

CRTC có 1 thuộc tính có thể định cấu hình:

- writeback: Bật hoặc tắt hỗ trợ trình kết nối ghi lại bằng cách viết 1 hoặc 0

Tiếp theo, tạo một hoặc nhiều bộ mã hóa::

Sudo mkdir /config/vkms/my-vkms/bộ mã hóa/bộ mã hóa0

Cuối cùng nhưng không kém phần quan trọng, hãy tạo một hoặc nhiều trình kết nối::

sudo mkdir /config/vkms/my-vkms/connectors/connector0

Trình kết nối có 1 thuộc tính có thể định cấu hình:

- trạng thái: Trạng thái kết nối: 1 đã kết nối, 2 đã ngắt kết nối, 3 không xác định (cùng giá trị
  như những thuộc tính được hiển thị bởi thuộc tính "trạng thái" của trình kết nối)

Để hoàn tất cấu hình, hãy liên kết các mục quy trình khác nhau::

sudo ln -s /config/vkms/my-vkms/crtcs/crtc0 /config/vkms/my-vkms/planes/plane0/possible_crtcs
  Sudo ln -s /config/vkms/my-vkms/crtcs/crtc0 /config/vkms/my-vkms/bộ mã hóa/bộ mã hóa0/possible_crtcs
  sudo ln -s /config/vkms/my-vkms/encodes/encode0 /config/vkms/my-vkms/connectors/connector0/possible_encodings

Vì cần có ít nhất một mặt phẳng chính nên hãy đảm bảo đặt đúng loại ::

tiếng vang "1" | sudo tee /config/vkms/my-vkms/planes/plane0/type

Khi bạn đã hoàn tất việc định cấu hình phiên bản VKMS, hãy kích hoạt nó::

tiếng vang "1" | sudo tee /config/vkms/my-vkms/enabled

Cuối cùng, bạn có thể xóa phiên bản VKMS đang vô hiệu hóa nó::

tiếng vang "0" | sudo tee /config/vkms/my-vkms/enabled

Và xóa thư mục cấp cao nhất và các thư mục con của nó ::

sudo rm /config/vkms/my-vkms/planes/ZZ0000ZZ
  sudo rm /config/vkms/my-vkms/bộ mã hóa/ZZ0001ZZ
  sudo rm /config/vkms/my-vkms/connectors/ZZ0002ZZ
  sudo rmdir /config/vkms/my-vkms/planes/*
  sudo rmdir /config/vkms/my-vkms/crtcs/*
  Sudo rmdir /config/vkms/my-vkms/bộ mã hóa/*
  Sudo rmdir /config/vkms/my-vkms/connectors/*
  sudo rmdir /config/vkms/my-vkms

Thử nghiệm với IGT
================

Công cụ IGT GPU là bộ thử nghiệm được sử dụng riêng để gỡ lỗi và
phát triển trình điều khiển DRM.
Công cụ IGT có thể được cài đặt từ
ZZ0000ZZ.

Các bài kiểm tra cần được chạy mà không có bộ tổng hợp, vì vậy bạn cần chuyển sang văn bản
chế độ duy nhất. Bạn có thể làm điều này bằng cách::

sudo systemctl cô lập nhiều người dùng.target

Để quay lại chế độ đồ họa, hãy thực hiện::

sudo systemctl cô lập đồ họa.target

Khi ở chế độ chỉ văn bản, bạn có thể chạy thử nghiệm bằng IGT_FORCE_DRIVER
biến để chỉ định bộ lọc thiết bị cho trình điều khiển mà chúng tôi muốn kiểm tra.
IGT_FORCE_DRIVER cũng có thể được sử dụng với tập lệnh run-tests.sh để chạy
kiểm tra cho một trình điều khiển cụ thể::

sudo IGT_FORCE_DRIVER="vkms" ./build/tests/<tên bài kiểm tra>
  sudo IGT_FORCE_DRIVER="vkms" ./scripts/run-tests.sh -t <tên bài kiểm tra>

Ví dụ: để kiểm tra chức năng của thư viện writeback,
chúng ta có thể chạy thử nghiệm kms_writeback::

sudo IGT_FORCE_DRIVER="vkms" ./build/tests/kms_writeback
  sudo IGT_FORCE_DRIVER="vkms" ./scripts/run-tests.sh -t kms_writeback

Bạn cũng có thể chạy bài kiểm tra phụ nếu bạn không muốn chạy toàn bộ bài kiểm tra::

sudo IGT_FORCE_DRIVER="vkms" ./build/tests/kms_flip --run-subtest basic-plain-flip

Kiểm tra với KUnit
==================

KUnit (Khung kiểm thử đơn vị hạt nhân) cung cấp một khung chung cho các thử nghiệm đơn vị
bên trong nhân Linux.
Thông tin thêm trong ../dev-tools/kunit/index.rst .

Để chạy thử nghiệm VKMS KUnit::

công cụ/kiểm tra/kunit/kunit.py chạy --kunitconfig=drivers/gpu/drm/vkms/tests

TODO
====

Nếu bạn muốn thực hiện bất kỳ mục nào được liệt kê dưới đây, vui lòng chia sẻ sở thích của bạn
với bộ bảo trì VKMS.

IGT hỗ trợ tốt hơn
------------------

Gỡ lỗi:

- kms_plane: một số trường hợp thử nghiệm không thành công do hết thời gian chờ chụp CRC;

Chế độ phần cứng ảo (vblank-less):

- VKMS đã hỗ trợ vblank được mô phỏng thông qua đồng hồ tính giờ, có thể
  đã thử nghiệm với thử nghiệm kms_flip; theo một cách nào đó, chúng ta có thể nói rằng VKMS đã bắt chước
  vblank phần cứng thực sự. Tuy nhiên, chúng tôi cũng có phần cứng ảo có thể
  không hỗ trợ ngắt vblank và hoàn thành ngay sự kiện page_flip; trong
  trong trường hợp này, các nhà phát triển bộ tổng hợp có thể sẽ tạo ra một vòng lặp bận rộn trên máy ảo
  phần cứng. Sẽ rất hữu ích khi hỗ trợ hành vi Phần cứng ảo trong VKMS
  vì điều này có thể giúp các nhà phát triển bộ tổng hợp kiểm tra các tính năng của họ trong
  nhiều kịch bản.

Thêm tính năng máy bay
------------------

Có rất nhiều tính năng trên máy bay mà chúng tôi có thể thêm hỗ trợ cho:

- Thêm thuộc tính màu nền KMS [Tốt để bắt đầu].

- Thu nhỏ.

- Các định dạng bộ đệm bổ sung. Các định dạng RGB bpp thấp/cao sẽ rất thú vị
  [Tốt để bắt đầu].

- Cập nhật không đồng bộ (hiện chỉ có thể thực hiện được trên mặt phẳng con trỏ bằng cách sử dụng phiên bản cũ
  api con trỏ).

Đối với tất cả những điều này, chúng tôi cũng muốn xem xét phạm vi kiểm tra igt và đảm bảo
tất cả các trường hợp thử nghiệm igt có liên quan đều hoạt động trên vkm. Họ là những lựa chọn tốt cho việc thực tập
dự án.

Cấu hình thời gian chạy
---------------------

Chúng tôi muốn có thể cấu hình lại phiên bản vkms mà không cần phải tải lại
mô-đun thông qua configfs. Trường hợp sử dụng/thử nghiệm:

- Đầu nối hotplug/hotremove nhanh chóng (để có thể kiểm tra khả năng xử lý DP MST
  của các nhà soạn nhạc).

- Thay đổi cấu hình đầu ra: Cắm/rút màn hình, thay đổi EDID, cho phép thay đổi
  tốc độ làm mới.

Hỗ trợ viết lại
-----------------

- Các hoạt động ghi lại và ghi CRC chia sẻ việc sử dụng Composer_enabled
  boolean để đảm bảo vblanks. Có lẽ, khi các hoạt động này phối hợp với nhau,
  Composer_enabled cần đếm lại trạng thái của nhà soạn nhạc để hoạt động phù hợp.
  [Tốt để bắt đầu]

- Thêm hỗ trợ cho các đầu ra ghi lại nhân bản và các trường hợp kiểm thử liên quan bằng cách sử dụng
  đầu ra được nhân bản trong IGT kms_writeback.

- Là một thiết bị v4l. Điều này rất hữu ích để gỡ lỗi các bộ tổng hợp trên các vkm đặc biệt
  cấu hình, để các nhà phát triển thấy được điều gì đang thực sự diễn ra.

Tính năng đầu ra
---------------

- Hỗ trợ tốc độ làm mới/freesync thay đổi. Điều này có lẽ cần bộ đệm chính
  hỗ trợ chia sẻ để chúng tôi có thể sử dụng hàng rào vgem để mô phỏng kết xuất trong
  thử nghiệm. Cũng cần hỗ trợ để chỉ định EDID.

- Thêm hỗ trợ cho trạng thái liên kết để các nhà soạn nhạc có thể xác thực thời gian chạy của họ
  dự phòng khi ví dụ: liên kết Cổng hiển thị bị lỗi.

CRC API Cải tiến
--------------------

- Tối ưu hóa tính toán CRC ZZ0000ZZ và trộn mặt phẳng ZZ0001ZZ

Kiểm tra nguyên tử bằng eBPF
-----------------------

Trình điều khiển nguyên tử có rất nhiều hạn chế không được tiếp xúc với không gian người dùng trong
bất kỳ hình thức rõ ràng nào thông qua ví dụ: các giá trị thuộc tính có thể có. Không gian người dùng chỉ có thể
yêu cầu về các giới hạn này thông qua IOCTL nguyên tử, có thể sử dụng
Cờ TEST_ONLY. Đang cố gắng thêm mã có thể định cấu hình cho tất cả các giới hạn này để cho phép
các nhà soạn nhạc được thử nghiệm với chúng sẽ là một việc làm vô ích. Thay vào đó
chúng tôi có thể thêm hỗ trợ cho eBPF để xác thực bất kỳ loại trạng thái nguyên tử nào và
thực hiện một thư viện các hạn chế khác nhau.

Điều này cần một loạt các tính năng (tổng hợp mặt phẳng, nhiều đầu ra, ...)
kích hoạt đã có ý nghĩa.
