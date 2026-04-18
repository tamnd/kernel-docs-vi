.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/sound/cards/pcmtest.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

Trình điều khiển kiểm tra PCM ảo
===========================

Trình điều khiển kiểm tra PCM ảo mô phỏng thiết bị PCM chung và có thể được sử dụng cho
kiểm tra/làm mờ các ứng dụng ALSA trong không gian người dùng, cũng như để kiểm tra/làm mờ các ứng dụng
lớp giữa PCM. Ngoài ra, nó có thể được sử dụng để mô phỏng khó tái tạo
sự cố với thiết bị PCM.

Người lái xe này có thể làm gì?
~~~~~~~~~~~~~~~~~~~~~~~~

Lúc này người lái xe có thể làm những việc sau:
	* Mô phỏng cả quá trình chụp và phát lại
	* Tạo dữ liệu chụp ngẫu nhiên hoặc dựa trên mẫu
	* Đưa độ trễ vào quá trình phát lại và ghi
	* Đưa ra lỗi trong quá trình gọi lại PCM

Nó hỗ trợ tới 8 luồng con và 4 kênh. Ngoài ra nó hỗ trợ cả xen kẽ và
các chế độ truy cập không xen kẽ.

Ngoài ra, trình điều khiển này có thể kiểm tra luồng phát lại để chứa mẫu được xác định trước,
được sử dụng trong selftest tương ứng (alsa/pcmtest-test.sh) để kiểm tra phần giữa PCM
chức năng truyền dữ liệu lớp. Ngoài ra, trình điều khiển này xác định lại mặc định
RESET ioctl và bản selftest cũng bao gồm chức năng PCM API này.

Cấu hình
-------------

Trình điều khiển có một số tham số ngoài các tham số mô-đun ALSA phổ biến:

* fill_mode (bool) - Chế độ điền vào bộ đệm (xem bên dưới)
	* tiêm_delay (int)
	* tiêm_hwpars_err (bool)
	* tiêm_prepare_err (bool)
	* tiêm_trigger_err (bool)


Thu thập dữ liệu thế hệ
-----------------------

Trình điều khiển có hai chế độ tạo dữ liệu: chế độ thứ nhất (0 trong tham số fill_mode)
có nghĩa là tạo dữ liệu ngẫu nhiên, dữ liệu thứ hai (1 trong fill_mode) - dựa trên mẫu
tạo dữ liệu. Hãy nhìn vào chế độ thứ hai.

Trước hết, bạn có thể muốn chỉ định mẫu để tạo dữ liệu. Bạn có thể làm điều đó
bằng cách ghi mẫu vào tệp debugfs. Có các mục gỡ lỗi bộ đệm mẫu
cho mỗi kênh cũng như các mục chứa độ dài bộ đệm mẫu.

* /sys/kernel/debug/pcmtest/fill_pattern[0-3]
	* /sys/kernel/debug/pcmtest/fill_pattern[0-3]_len

Để đặt mẫu cho kênh 0, bạn có thể thực hiện lệnh sau:

.. code-block:: bash

	echo -n mycoolpattern > /sys/kernel/debug/pcmtest/fill_pattern0

Sau đó, sau mỗi hành động chụp được thực hiện trên thiết bị 'pcmtest', bộ đệm cho
kênh 0 sẽ chứa 'mycoolpatternmycoolpatternmycoolpatternmy...'.

Bản thân mẫu có thể dài tới 4096 byte.

Tiêm trễ
---------------

Trình điều khiển có tham số 'inject_delay', có tên rất tự mô tả và
có thể được sử dụng để mô phỏng thời gian trễ/tăng tốc. Tham số có kiểu số nguyên và
nó có nghĩa là độ trễ được thêm vào giữa các tích tắc hẹn giờ bên trong của mô-đun.

Nếu giá trị 'inject_delay' là dương thì bộ đệm sẽ được lấp đầy chậm hơn.
tiêu cực - nhanh hơn. Bạn có thể tự mình thử bằng cách bắt đầu ghi ở bất kỳ
ứng dụng ghi âm (như Audacity) và chọn thiết bị 'pcmtest' làm
nguồn.

Tham số này cũng có thể được sử dụng để tạo ra một lượng lớn dữ liệu âm thanh trong một khoảng thời gian rất ngắn.
khoảng thời gian ngắn (với giá trị 'inject_delay' âm).

Lỗi tiêm
----------------

Mô-đun này có thể được sử dụng để đưa lỗi vào quá trình giao tiếp PCM. Cái này
hành động có thể giúp bạn tìm ra cách chương trình ALSA trong không gian người dùng hoạt động trong điều kiện bất thường
hoàn cảnh.

Ví dụ: bạn có thể thực hiện tất cả lệnh gọi lại PCM của 'hw_params' trả về lỗi EBUSY bằng cách
ghi '1' vào tham số mô-đun 'inject_hwpars_err':

.. code-block:: bash

	echo 1 > /sys/module/snd_pcmtest/parameters/inject_hwpars_err

Lỗi có thể được đưa vào các lệnh gọi lại PCM sau:

* hw_params (EBUSY)
	* chuẩn bị (EINVAL)
	* kích hoạt (EINVAL)

Kiểm tra phát lại
-------------

Trình điều khiển này cũng có thể được sử dụng để kiểm tra chức năng phát lại - mỗi khi bạn
ghi dữ liệu phát lại vào thiết bị PCM 'pcmtest' và đóng nó lại, trình điều khiển sẽ kiểm tra
bộ đệm để chứa mẫu lặp (được chỉ định trong fill_pattern
debugfs cho mỗi kênh). Nếu nội dung bộ đệm phát lại đại diện cho vòng lặp
mẫu, mục gỡ lỗi 'pc_test' được đặt thành '1'. Nếu không, trình điều khiển sẽ đặt nó thành '0'.

kiểm tra xác định lại ioctl
-----------------------

Trình điều khiển xác định lại ioctl 'đặt lại', mặc định cho tất cả các thiết bị PCM. Để kiểm tra
chức năng này, chúng tôi có thể kích hoạt thiết lập lại ioctl và kiểm tra các bản gỡ lỗi 'ioctl_test'
mục nhập:

.. code-block:: bash

	cat /sys/kernel/debug/pcmtest/ioctl_test

Nếu ioctl được kích hoạt thành công, tệp này sẽ chứa '1' và '0' nếu không.