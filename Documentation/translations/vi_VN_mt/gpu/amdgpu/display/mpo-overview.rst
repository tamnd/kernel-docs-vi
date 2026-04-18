.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/gpu/amdgpu/display/mpo-overview.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

===========================
Lớp phủ đa tầng (MPO)
===========================

.. note:: You will get more from this page if you have already read the
   'Documentation/gpu/amdgpu/display/dcn-overview.rst'.


Lớp phủ đa mặt phẳng (MPO) cho phép kết hợp nhiều bộ đệm khung thông qua
phần cứng có chức năng cố định trong bộ điều khiển hiển thị thay vì sử dụng đồ họa hoặc
tính toán các shader cho bố cục. Điều này có thể mang lại một số tiết kiệm năng lượng nếu nó có nghĩa là
các đường ống đồ họa/điện toán có thể được đưa vào trạng thái năng lượng thấp. Tóm lại,
MPO có thể mang lại những lợi ích sau:

* Giảm khối lượng công việc GPU và CPU - không cần trình đổ bóng tổng hợp, không cần thêm
  cần bản sao bộ đệm, GPU có thể không hoạt động.
* Lật trang độc lập trên mặt phẳng - Không cần phải gắn với bộ tổng hợp toàn cầu
  tốc độ hiện tại khi lật trang, độ trễ giảm, thời gian độc lập.

.. note:: Keep in mind that MPO is all about power-saving; if you want to learn
   more about power-save in the display context, check the link:
   `Power <https://gitlab.freedesktop.org/pq/color-and-hdr/-/blob/main/doc/power.rst>`__.

Lớp phủ nhiều mặt chỉ khả dụng khi sử dụng mô hình nguyên tử DRM. Nguyên tử
kiểu máy chỉ sử dụng một không gian người dùng duy nhất IOCTL để định cấu hình phần cứng màn hình
(cài đặt chế độ, lật trang, v.v.) - drmModeAtomicCommit. Để truy vấn phần cứng
tài nguyên và giới hạn không gian người dùng cũng gọi vào drmModeGetResources
báo cáo lại số lượng mặt phẳng, CRTC và đầu nối. Có ba loại
của các mặt phẳng DRM mà người lái xe có thể đăng ký và làm việc với:

* ZZ0000ZZ: Các mặt phẳng chính biểu thị mặt phẳng "chính" cho
  CRTC, các mặt phẳng chính là các mặt phẳng được vận hành bởi cài đặt chế độ CRTC và
  thao tác lật.
* ZZ0001ZZ: Mặt phẳng con trỏ biểu thị mặt phẳng "con trỏ" cho
  CRTC. Mặt phẳng con trỏ là các mặt phẳng được vận hành bởi IOCTL con trỏ
* ZZ0002ZZ: Các mặt phẳng lớp phủ đại diện cho tất cả các mặt phẳng không chính,
  mặt phẳng không có con trỏ. Một số tài xế gọi những loại máy bay này là "sprite"
  nội bộ.

Để minh họa cách thức hoạt động của nó, chúng ta hãy xem xét một thiết bị có
các mặt phẳng sau vào không gian người dùng:

* 4 mặt phẳng chính (1 mặt phẳng trên CRTC).
* 4 mặt phẳng con trỏ (1 trên mỗi CRTC).
* 1 mặt phẳng lớp phủ (được chia sẻ giữa các CRTC).

.. note:: Keep in mind that different ASICs might expose other numbers of
   planes.

Đối với ví dụ phần cứng này, chúng tôi có 4 ống (nếu bạn không biết ống AMD là gì
có nghĩa là, hãy xem phần 'Documentation/gpu/amdgpu/display/dcn-overview.rst'
"Đường ống phần cứng AMD"). Thông thường, hầu hết các thiết bị AMD đều hoạt động ở chế độ phân chia đường ống.
cấu hình cho đầu ra hiển thị đơn tối ưu (ví dụ: 2 ống trên mỗi mặt phẳng).

Cấu hình MPO điển hình từ không gian người dùng - 1 lớp phủ chính + 1 trên một
hiển thị - sẽ thấy 4 ống đang được sử dụng, 2 ống trên mỗi mặt phẳng.

Phải sử dụng ít nhất 1 ống cho mỗi mặt phẳng (chính và lớp phủ), vì vậy đối với điều này
phần cứng giả định mà chúng tôi đang sử dụng làm ví dụ, chúng tôi có một kết quả tuyệt đối
giới hạn 4 mặt phẳng trên tất cả các CRTC. Cam kết nguyên tử sẽ bị từ chối hiển thị
cấu hình sử dụng nhiều hơn 4 mặt phẳng. Một lần nữa, điều quan trọng cần nhấn mạnh là
mỗi DCN đều có những hạn chế khác nhau; ở đây, chúng tôi chỉ đang cố gắng cung cấp
ý tưởng khái niệm.

Hạn chế về máy bay
==================

AMDGPU áp đặt các hạn chế đối với việc sử dụng mặt phẳng DRM trong trình điều khiển.

Các cam kết nguyên tử sẽ bị từ chối đối với các cam kết không tuân theo những điều này
hạn chế:

* Mặt phẳng lớp phủ phải ở định dạng ARGB8888 hoặc XRGB8888
* Không thể đặt máy bay bên ngoài hình chữ nhật đích CRTC
* Không thể thu nhỏ mặt phẳng xuống quá 1/4 lần kích thước ban đầu của chúng
* Máy bay không thể được nâng cấp quá 16 lần kích thước ban đầu của chúng

Không phải mọi thuộc tính đều có sẵn trên mọi máy bay:

* Chỉ các mặt phẳng chính mới có hỗ trợ định dạng không gian màu và không phải RGB
* Chỉ các mặt phẳng lớp phủ mới có hỗ trợ trộn alpha

Hạn chế con trỏ
===================

Trước khi chúng tôi bắt đầu mô tả một số hạn chế xung quanh con trỏ và MPO, hãy xem phần
hình ảnh dưới đây:

.. kernel-figure:: mpo-cursor.svg

Hình ảnh ở phía bên trái thể hiện cách DRM mong đợi con trỏ và mặt phẳng
được hòa trộn. Tuy nhiên, phần cứng AMD xử lý con trỏ theo cách khác, như bạn có thể thấy
ở phía bên phải; về cơ bản, con trỏ của chúng ta không thể được vẽ ra bên ngoài liên kết của nó
mặt phẳng vì nó đang được coi như một phần của mặt phẳng. Một hậu quả khác của việc đó
là con trỏ kế thừa màu sắc và tỷ lệ từ mặt phẳng.

Do hành vi trên, không sử dụng API cũ để thiết lập con trỏ
mặt phẳng khi làm việc với MPO; nếu không, bạn có thể gặp phải bất ngờ
hành vi.

Tóm lại, AMD HW không có mặt phẳng con trỏ chuyên dụng. Một con trỏ được gắn vào
một mặt phẳng khác và do đó kế thừa bất kỳ sự chia tỷ lệ hoặc xử lý màu nào từ mặt phẳng đó
mặt phẳng mẹ.

Trường hợp sử dụng
=========

Phát lại hình ảnh trong hình (PIP) - Chiến lược lớp lót
-----------------------------------------------------

Việc phát lại video phải được thực hiện bằng cách sử dụng "mặt phẳng chính làm lớp nền" MPO
chiến lược. Đây là cấu hình 2 mặt phẳng:

* 1 Mặt phẳng chính YUV DRM (ví dụ: Video NV12)
* 1 Mặt phẳng lớp phủ RGBA DRM (ví dụ: máy tính để bàn ARGB8888). Nhà soạn nhạc nên
  chuẩn bị bộ đệm khung cho các mặt phẳng như sau:
  - Mặt phẳng lớp phủ chứa giao diện người dùng chung trên máy tính để bàn, điều khiển trình phát video và phụ đề video
  - Mặt phẳng chính chứa một hoặc nhiều video

.. note:: Keep in mind that we could extend this configuration to more planes,
   but that is currently not supported by our driver yet (maybe if we have a
   userspace request in the future, we can change that).

Xem bên dưới một ví dụ về một video:

.. kernel-figure:: single-display-mpo.svg

.. note:: We could extend this behavior to more planes, but that is currently
   not supported by our driver.

Bộ đệm video nên được sử dụng trực tiếp cho mặt phẳng chính. Video có thể
được thu nhỏ và định vị cho màn hình bằng các thuộc tính: CRTC_X, CRTC_Y,
CRTC_W và CRTC_H. Mặt phẳng chính cũng phải có mã màu và
thuộc tính dải màu được đặt dựa trên nội dung nguồn:

* ZZ0000ZZ, ZZ0001ZZ

Mặt phẳng lớp phủ phải có kích thước gốc của CRTC. Người soạn nhạc phải
vẽ một đường cắt trong suốt để đặt video trên màn hình
(tức là đặt alpha về 0). Video mặt phẳng chính sẽ được hiển thị thông qua
lớp lót. Bộ đệm của mặt phẳng lớp phủ có thể vẫn tĩnh trong khi bộ đệm chính
bộ đệm khung của máy bay được sử dụng để phát lại bộ đệm đôi tiêu chuẩn.

Bộ tổng hợp sẽ tạo bộ đệm YUV phù hợp với kích thước gốc của CRTC.
Mỗi bộ đệm video phải được tổng hợp vào bộ đệm YUV này cho YUV trực tiếp
scanout. Mặt phẳng chính phải có mã màu và dải màu
thuộc tính được đặt dựa trên nội dung nguồn: ZZ0000ZZ,
ZZ0001ZZ. Tuy nhiên, hãy lưu ý rằng không gian màu nguồn và
khớp mã hóa cho từng video vì nó ảnh hưởng đến toàn bộ mặt phẳng.

Mặt phẳng lớp phủ phải có kích thước gốc của CRTC. Người soạn nhạc phải
vẽ một đường cắt trong suốt về vị trí đặt mỗi video trên màn hình
(tức là đặt alpha về 0). Các video mặt phẳng chính sẽ được hiển thị thông qua
lớp lót. Bộ đệm của mặt phẳng lớp phủ có thể vẫn tĩnh trong khi tổng hợp
các thao tác phát lại video sẽ được thực hiện trên bộ đệm video.

Giao diện kernel này được xác thực bằng Công cụ IGT GPU. Các thử nghiệm sau đây có thể
được chạy để xác nhận việc định vị, trộn, chia tỷ lệ theo nhiều trình tự khác nhau
và tương tác với các hoạt động như DPMS và S3:

-ZZ0000ZZ
-ZZ0001ZZ
-ZZ0002ZZ
-ZZ0003ZZ
-ZZ0004ZZ
-ZZ0005ZZ
-ZZ0006ZZ
-ZZ0007ZZ
-ZZ0008ZZ
-ZZ0009ZZ
-ZZ0010ZZ
-ZZ0011ZZ
-ZZ0012ZZ
-ZZ0013ZZ

Nhiều màn hình MPO
--------------------

AMDGPU hỗ trợ hiển thị MPO khi sử dụng nhiều màn hình; tuy nhiên, tính năng này
hành vi phụ thuộc rất nhiều vào việc triển khai bộ tổng hợp. Hãy nhớ rằng
không gian người dùng có thể xác định các chính sách khác nhau. Ví dụ: một số hệ điều hành có thể sử dụng MPO để
bảo vệ mặt phẳng xử lý việc phát lại video; lưu ý rằng chúng tôi không có
nhiều hạn chế cho một màn hình duy nhất. Tuy nhiên, thao tác này có thể có
nhiều hạn chế hơn cho kịch bản nhiều màn hình. Ví dụ dưới đây cho thấy một
phát lại video ở giữa hai màn hình và tùy thuộc vào bộ tổng hợp
xác định chính sách về cách xử lý nó:

.. kernel-figure:: multi-display-hdcp-mpo.svg

Hãy thảo luận về một số hạn chế về phần cứng mà chúng ta gặp phải khi xử lý
đa màn hình với MPO.

Hạn chế
~~~~~~~~~~~

Để đơn giản, để thảo luận về giới hạn phần cứng, điều này
tài liệu giả sử một ví dụ trong đó chúng tôi có hai màn hình và phát lại video
sẽ được di chuyển xung quanh các màn hình khác nhau.

* ZZ0000ZZ

Từ trang tổng quan về DCN, mỗi màn hình yêu cầu ít nhất một ống và mỗi ống
Máy bay MPO cần một đường ống khác. Kết quả là, khi video ở giữa
hai màn hình, chúng ta cần sử dụng 2 ống. Xem ví dụ bên dưới nơi chúng tôi tránh
chia ống:

- 1 màn hình (1 ống) + MPO (1 ống), chúng ta sẽ sử dụng 2 ống
- 2 màn hình (2 ống) + MPO (1-2 ống); chúng ta sẽ sử dụng 4 ống. MPO trong
  giữa cả hai màn hình cần 2 ống.
- 3 Displays (3 ống) + MPO (1-2 ống), ta cần 5 ống.

Nếu chúng tôi sử dụng MPO với nhiều màn hình, không gian người dùng phải quyết định bật
nhiều MPO với mức giá giới hạn số lượng màn hình ngoài được hỗ trợ
hoặc vô hiệu hóa nó để có nhiều màn hình; đó là một quyết định chính sách. Ví dụ:

* Khi ASIC có 3 ống, phần cứng AMD có thể NOT hỗ trợ 2 màn hình với MPO
* Khi ASIC có 4 ống, phần cứng AMD có thể NOT hỗ trợ 3 màn hình với MPO

Hãy cùng khám phá ngắn gọn cách không gian người dùng có thể xử lý hai cấu hình hiển thị này
trên ASIC chỉ hỗ trợ ba ống. Chúng ta có thể có:

.. kernel-figure:: multi-display-hdcp-mpo-less-pipe-ex.svg

- Tổng số ống là 3
- Người dùng sáng 2 màn hình (sử dụng 2 trong 3 ống)
- Người dùng ra mắt video (1 ống dùng cho MPO)
- Bây giờ, nếu người dùng di chuyển video vào giữa 2 màn hình, một phần của
  video sẽ không phải là MPO vì chúng ta đã sử dụng ống 3/3.

* ZZ0000ZZ

MPO không thể xử lý tỷ lệ nhỏ hơn 0,25 và lớn hơn x16. Ví dụ:

Nếu video 4k (3840x2160) đang phát ở chế độ cửa sổ, kích thước vật lý của
cửa sổ không thể nhỏ hơn (960x540).

.. note:: These scaling limitations might vary from ASIC to ASIC.

* ZZ0000ZZ

Kích thước MPO tối thiểu là 12px.
