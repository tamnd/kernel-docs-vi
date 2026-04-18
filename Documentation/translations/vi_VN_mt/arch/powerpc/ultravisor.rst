.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/arch/powerpc/ultravisor.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. _ultravisor:

===============================
Cơ sở thi hành án được bảo vệ
===============================

.. contents::
    :depth: 3

Giới thiệu
############

Cơ sở thực thi được bảo vệ (PEF) là một thay đổi kiến trúc cho
    POWER 9 cho phép Máy ảo an toàn (SVM). Chip DD2.3
    (PVR=0x004e1203) hoặc cao hơn sẽ có khả năng PEF. Phiên bản ISA mới
    sẽ bao gồm những thay đổi PEF RFC02487.

Khi được bật, PEF sẽ thêm chế độ đặc quyền mới cao hơn, gọi là Ultravisor
    chế độ, sang kiến trúc POWER. Cùng với chế độ mới còn có chế độ mới
    chương trình cơ sở được gọi là Ultravisor thực thi được bảo vệ (hoặc Ultravisor
    viết tắt). Chế độ Ultravisor là chế độ đặc quyền cao nhất trong POWER
    kiến trúc.

+-------------------+
	ZZ0000ZZ
	+=====================+
	ZZ0001ZZ
	+-------------------+
	ZZ0002ZZ
	+-------------------+
	ZZ0003ZZ
	+-------------------+
	ZZ0004ZZ
	+-------------------+

PEF bảo vệ SVM khỏi trình ảo hóa, người dùng đặc quyền và những người khác
    VM trong hệ thống. SVM được bảo vệ khi ở trạng thái nghỉ và chỉ có thể được
    được thực hiện bởi một máy được ủy quyền. Tất cả các máy ảo đều sử dụng
    dịch vụ ảo hóa. Ultravisor lọc các cuộc gọi giữa các SVM
    và người quản lý ảo hóa để đảm bảo rằng thông tin không vô tình bị
    rò rỉ. Tất cả các siêu giám sát ngoại trừ H_RANDOM đều được phản ánh tới bộ ảo hóa.
    H_RANDOM không được phản ánh để ngăn trình ảo hóa ảnh hưởng
    các giá trị ngẫu nhiên trong SVM.

Để hỗ trợ điều này, cần phải tái cấu trúc quyền sở hữu tài nguyên
    trong CPU. Một số tài nguyên trước đây là hypervisor
    đặc quyền bây giờ là đặc quyền của ultravisor.

Phần cứng
=========

Những thay đổi về phần cứng bao gồm:

* Có một bit mới trong MSR xác định xem dòng điện có
      quy trình đang chạy ở chế độ bảo mật, bit MSR(S) 41. MSR(S)=1, quy trình
      đang ở chế độ bảo mật, quá trình MSR(s)=0 ở chế độ bình thường.

* Bit MSR(S) chỉ có thể được đặt bởi Ultravisor.

* Không thể sử dụng HRFID để đặt bit MSR(S). Nếu hypervisor cần
      để quay lại SVM, nó phải sử dụng ultracall. Nó có thể xác định xem
      VM mà nó đang quay trở lại được bảo mật.

* Có một sổ đăng ký đặc quyền Ultravisor mới, SMFCTRL, có một
      bật/tắt bit SMFCTRL(E).

* Đặc quyền của một quy trình hiện được xác định bởi ba bit MSR,
      MSR(S, HV, PR). Trong mỗi bảng bên dưới các chế độ được liệt kê
      từ đặc quyền tối thiểu đến đặc quyền cao nhất. Đặc quyền cao hơn
      các chế độ có thể truy cập tất cả các tài nguyên của các chế độ đặc quyền thấp hơn.

ZZ0000ZZ

+---+---+---+---------------+
      ZZ0000ZZ HV| PR|Đặc quyền |
      +===+===+===+=================+
      ZZ0002ZZ 0 ZZ0003ZZ Vấn đề |
      +---+---+---+---------------+
      ZZ0004ZZ 0 ZZ0005ZZ Đặc quyền(HĐH)|
      +---+---+---+---------------+
      Máy giám sát ZZ0006ZZ 1 ZZ0007ZZ |
      +---+---+---+---------------+
      ZZ0008ZZ 1 ZZ0009ZZ Đã đặt trước |
      +---+---+---+---------------+

ZZ0000ZZ

+---+---+---+---------------+
      ZZ0000ZZ HV| PR|Đặc quyền |
      +===+===+===+=================+
      ZZ0002ZZ 0 ZZ0003ZZ Vấn đề |
      +---+---+---+---------------+
      ZZ0004ZZ 0 ZZ0005ZZ Đặc quyền(HĐH)|
      +---+---+---+---------------+
      ZZ0006ZZ 1 ZZ0007ZZ Trình ảo hóa |
      +---+---+---+---------------+
      ZZ0008ZZ 1 Sự cố ZZ0009ZZ (Máy chủ)|
      +---+---+---+---------------+

* Bộ nhớ được phân vùng thành bộ nhớ an toàn và bình thường. Chỉ các quy trình
      đang chạy ở chế độ bảo mật có thể truy cập bộ nhớ an toàn.

* Phần cứng không cho phép bất cứ thứ gì không chạy an toàn
      truy cập bộ nhớ an toàn. Điều này có nghĩa là Hypervisor không thể truy cập
      bộ nhớ của SVM mà không cần sử dụng ultracall (yêu cầu
      máy siêu âm). Ultravisor sẽ chỉ cho phép hypervisor nhìn thấy
      bộ nhớ SVM được mã hóa.

* Hệ thống I/O không được phép định địa chỉ trực tiếp vào bộ nhớ an toàn. Cái này
      giới hạn các SVM chỉ ở I/O ảo.

* Kiến trúc cho phép SVM chia sẻ các trang bộ nhớ với
      hypervisor không được bảo vệ bằng mã hóa. Tuy nhiên, điều này
      việc chia sẻ phải được bắt đầu bởi SVM.

* Khi một tiến trình đang chạy ở chế độ bảo mật, tất cả các siêu lệnh
      (syscall lev=1) đi tới Ultravisor.

* Khi một tiến trình ở chế độ an toàn, tất cả các ngắt sẽ chuyển sang
      Máy siêu âm.

* Các tài nguyên sau đây đã trở thành đặc quyền của Ultravisor và
      yêu cầu giao diện Ultravisor để thao tác:

* Thanh ghi cấu hình bộ xử lý (SCOM).

* Dừng thông tin trạng thái.

* Các thanh ghi gỡ lỗi CIABR, DAWR, và DAWRX khi SMFCTRL(D) được thiết lập.
        Nếu SMFCTRL(D) không được đặt thì chúng sẽ không hoạt động ở chế độ bảo mật. Khi thiết lập,
        đọc và viết yêu cầu lệnh gọi Ultravisor, nếu không thì điều đó
        sẽ gây ra sự gián đoạn Hỗ trợ mô phỏng Hypervisor.

* PTCR và các mục trong bảng phân vùng (bảng phân vùng được bảo mật
        trí nhớ). Việc cố gắng ghi vào PTCR sẽ gây ra Hypervisor
        Hỗ trợ thi đua bị gián đoạn.

* LDBAR (Thanh ghi địa chỉ cơ sở LD) và IMC (Bộ sưu tập trong bộ nhớ)
        các thanh ghi không có kiến trúc. Cố gắng viết thư cho họ sẽ gây ra
        Hỗ trợ mô phỏng Hypervisor bị gián đoạn.

* Phân trang cho SVM, chia sẻ bộ nhớ với Hypervisor cho SVM.
        (Bao gồm Vùng xử lý ảo (VPA) và I/O ảo).


Phần mềm/Vi mã
==================

Những thay đổi về phần mềm bao gồm:

* SVM được tạo từ VM thông thường bằng cách sử dụng công cụ (nguồn mở) được cung cấp
      của IBM.

* Tất cả các SVM đều khởi động như các máy ảo thông thường và sử dụng ultracall, UV_ESM
      (Vào Chế độ bảo mật), để thực hiện chuyển đổi.

* Khi ultracall UV_ESM được tạo, Ultravisor sẽ sao chép VM vào
      bộ nhớ an toàn, giải mã thông tin xác minh và kiểm tra
      tính toàn vẹn của SVM. Nếu quá trình kiểm tra tính toàn vẹn vượt qua Ultravisor
      vượt qua sự kiểm soát ở chế độ an toàn.

* Thông tin xác minh bao gồm cụm mật khẩu cho
      đĩa được mã hóa liên kết với SVM. Cụm mật khẩu này được đưa ra
      tới SVM khi được yêu cầu.

* Ultravisor không liên quan đến việc bảo vệ đĩa được mã hóa của
      SVM khi ở trạng thái nghỉ.

* Đối với các ngắt bên ngoài, Ultravisor lưu trạng thái của SVM,
      và phản ánh sự gián đoạn tới bộ ảo hóa để xử lý.
      Đối với siêu cuộc gọi, Ultravisor chèn trạng thái trung lập vào tất cả
      các thanh ghi không cần thiết cho hypercall sau đó phản ánh lệnh gọi đến
      hypervisor để xử lý. Siêu cuộc gọi H_RANDOM được thực hiện
      bởi Ultravisor và không được phản ánh.

* Để I/O ảo hoạt động, tính năng đệm thoát phải được thực hiện.

* Ultravisor sử dụng AES (IAPM) để bảo vệ bộ nhớ SVM. IAPM
      là chế độ của AES cung cấp đồng thời tính toàn vẹn và bí mật.

* Việc di chuyển dữ liệu giữa các trang bình thường và bảo mật được phối hợp
      với Ultravisor bằng plug-in HMM mới trong Hypervisor.

Ultravisor cung cấp các dịch vụ mới cho hypervisor và SVM. Những cái này
    được truy cập thông qua ultracalls.

Thuật ngữ
===========

* Hypercalls: các cuộc gọi hệ thống đặc biệt được sử dụng để yêu cầu dịch vụ từ
      Giám sát viên.

* Bộ nhớ bình thường: Bộ nhớ mà Hypervisor có thể truy cập được.

* Trang thông thường: Trang được hỗ trợ bởi bộ nhớ bình thường và có sẵn cho
      Giám sát viên.

* Trang được chia sẻ: Một trang được hỗ trợ bởi bộ nhớ thông thường và có sẵn cho cả hai
      Hypervisor/QEMU và SVM (tức là trang có ánh xạ trong SVM và
      Trình ảo hóa/QEMU).

* Bộ nhớ an toàn: Bộ nhớ chỉ có thể truy cập được bởi Ultravisor và
      SVM.

* Trang bảo mật: Trang được hỗ trợ bởi bộ nhớ an toàn và chỉ có sẵn cho
      Máy siêu âm và SVM.

* SVM: Máy ảo an toàn.

* Ultracalls: các cuộc gọi hệ thống đặc biệt được sử dụng để yêu cầu dịch vụ từ
      Máy siêu âm.


Ultravisor gọi API
####################

Phần này mô tả các lệnh gọi Ultravisor (ultracalls) cần thiết để
    hỗ trợ Máy ảo an toàn (SVM) và KVM được ảo hóa. các
    ultracalls cho phép SVM và Hypervisor yêu cầu dịch vụ từ
    Ultravisor chẳng hạn như truy cập vào một thanh ghi hoặc vùng bộ nhớ chỉ có thể
    được truy cập khi chạy ở chế độ đặc quyền Ultravisor.

Dịch vụ cụ thể cần thiết từ một ultracall được chỉ định trong sổ đăng ký
    R3 (tham số đầu tiên của ultracall). Các thông số khác của
    ultracall, nếu có, được chỉ định trong các thanh ghi R4 đến R12.

Giá trị trả về của tất cả các ultracall nằm trong thanh ghi R3. Các giá trị đầu ra khác
    từ ultracall, nếu có, sẽ được trả về trong các thanh ghi R4 đến R12.
    Ngoại lệ duy nhất đối với việc sử dụng thanh ghi này là ZZ0000ZZ
    ultracall được mô tả dưới đây.

Mỗi ultracall trả về mã lỗi cụ thể, áp dụng trong ngữ cảnh
    của ultracall. Tuy nhiên, giống như với Nền tảng Kiến trúc PowerPC
    Tham chiếu (PAPR), nếu không có mã lỗi cụ thể nào được xác định cho
    tình huống cụ thể thì ultracall sẽ chuyển sang một kết quả sai
    mã dựa trên tham số-vị trí. tức là U_PARAMETER, U_P2, U_P3, v.v.
    tùy thuộc vào tham số ultracall có thể gây ra lỗi.

Một số cuộc gọi siêu âm liên quan đến việc chuyển một trang dữ liệu giữa Ultravisor
    và Hypervisor.  Các trang bảo mật được chuyển từ bộ nhớ an toàn
    vào bộ nhớ bình thường có thể được mã hóa bằng các khóa được tạo động.
    Khi các trang bảo mật được chuyển trở lại bộ nhớ bảo mật, chúng có thể
    được giải mã bằng cách sử dụng các khóa được tạo động tương tự. Thế hệ và
    việc quản lý các khóa này sẽ được đề cập trong một tài liệu riêng.

Hiện tại, điều này chỉ bao gồm các cuộc gọi siêu âm hiện đang được triển khai và đang được thực hiện
    được sử dụng bởi Hypervisor và SVM nhưng những thứ khác có thể được thêm vào đây khi nó
    có ý nghĩa.

Thông số kỹ thuật đầy đủ cho tất cả các hypercalls/ultracalls cuối cùng sẽ
    được cung cấp ở phiên bản công khai/OpenPower của PAPR
    đặc điểm kỹ thuật.

    .. note::

        If PEF is not enabled, the ultracalls will be redirected to the
        Hypervisor which must handle/fail the calls.

Ultracalls được Hypervisor sử dụng
==================================

Phần này mô tả các ultracall quản lý bộ nhớ ảo được sử dụng
    bởi Hypervisor để quản lý SVM.

UV_PAGE_OUT
-----------

Mã hóa và di chuyển nội dung của một trang từ bộ nhớ an toàn sang bộ nhớ bình thường
    trí nhớ.

Cú pháp
~~~~~~~

.. code-block:: c

	uint64_t ultracall(const uint64_t UV_PAGE_OUT,
		uint16_t lpid,		/* LPAR ID */
		uint64_t dest_ra,	/* real address of destination page */
		uint64_t src_gpa,	/* source guest-physical-address */
		uint8_t  flags,		/* flags */
		uint64_t order)		/* page size order */

Giá trị trả về
~~~~~~~~~~~~~~

Một trong các giá trị sau:

* U_SUCCESS thành công.
	* U_PARAMETER nếu ZZ0000ZZ không hợp lệ.
	* U_P2 nếu ZZ0001ZZ không hợp lệ.
	* U_P3 nếu địa chỉ ZZ0002ZZ không hợp lệ.
	* U_P4 nếu bất kỳ bit nào trong ZZ0003ZZ không được nhận dạng
	* U_P5 nếu tham số ZZ0004ZZ không được hỗ trợ.
	* U_FUNCTION nếu chức năng không được hỗ trợ.
	* U_BUSY nếu trang hiện không thể phân trang được.

Sự miêu tả
~~~~~~~~~~~

Mã hóa nội dung của một trang bảo mật và cung cấp nó cho
    Hypervisor trong một trang bình thường.

Theo mặc định, trang nguồn không được ánh xạ khỏi phân vùng của SVM-
    bảng trang có phạm vi. Nhưng Hypervisor có thể cung cấp gợi ý cho
    Ultravisor để giữ lại ánh xạ trang bằng cách đặt ZZ0000ZZ
    cờ trong tham số ZZ0001ZZ.

Nếu trang nguồn đã là trang được chia sẻ, cuộc gọi sẽ trả về
    U_SUCCESS, không cần làm gì cả.

Trường hợp sử dụng
~~~~~~~~~~~~~~~~~~

#. QEMU cố gắng truy cập vào địa chỉ thuộc SVM nhưng
       khung trang cho địa chỉ đó không được ánh xạ vào địa chỉ của QEMU
       không gian. Trong trường hợp này, Hypervisor sẽ phân bổ một khung trang,
       ánh xạ nó vào không gian địa chỉ của QEMU và cấp ZZ0000ZZ
       gọi để lấy lại nội dung được mã hóa của trang.

#. Khi Ultravisor sắp hết bộ nhớ an toàn và nó cần phân trang
       một trang LRU. Trong trường hợp này, Ultravisor sẽ đưa ra
       ZZ0000ZZ siêu gọi tới Hypervisor. Hypervisor sẽ
       sau đó phân bổ một trang bình thường và đưa ra ultracall ZZ0001ZZ
       và Ultravisor sẽ mã hóa và di chuyển nội dung của dữ liệu an toàn
       trang vào trang bình thường.

#. Khi Hypervisor truy cập dữ liệu SVM, Hypervisor sẽ yêu cầu
       Ultravisor để chuyển trang tương ứng vào một trang không an toàn,
       mà Hypervisor có thể truy cập. Dữ liệu trong trang bình thường sẽ
       mặc dù được mã hóa.

UV_PAGE_IN
----------

Di chuyển nội dung của một trang từ bộ nhớ bình thường sang bộ nhớ an toàn.

Cú pháp
~~~~~~~

.. code-block:: c

	uint64_t ultracall(const uint64_t UV_PAGE_IN,
		uint16_t lpid,		/* the LPAR ID */
		uint64_t src_ra,	/* source real address of page */
		uint64_t dest_gpa,	/* destination guest physical address */
		uint64_t flags,		/* flags */
		uint64_t order)		/* page size order */

Giá trị trả về
~~~~~~~~~~~~~~

Một trong các giá trị sau:

* U_SUCCESS thành công.
	* U_BUSY nếu trang hiện không thể được phân trang.
	* U_FUNCTION nếu chức năng không được hỗ trợ
	* U_PARAMETER nếu ZZ0000ZZ không hợp lệ.
	* U_P2 nếu ZZ0001ZZ không hợp lệ.
	* U_P3 nếu địa chỉ ZZ0002ZZ không hợp lệ.
	* U_P4 nếu bất kỳ bit nào trong ZZ0003ZZ không được nhận dạng
	* U_P5 nếu tham số ZZ0004ZZ không được hỗ trợ.

Sự miêu tả
~~~~~~~~~~~

Di chuyển nội dung của trang được xác định bởi ZZ0000ZZ từ trang thông thường
    bộ nhớ để bảo vệ bộ nhớ và ánh xạ nó tới địa chỉ vật lý của khách
    ZZ0001ZZ.

Nếu ZZ0000ZZ đề cập đến một địa chỉ dùng chung, hãy ánh xạ trang đó vào
    bảng trang có phạm vi phân vùng của SVM.  Nếu ZZ0001ZZ không được chia sẻ,
    sao chép nội dung của trang vào trang bảo mật tương ứng.
    Tùy thuộc vào ngữ cảnh, hãy giải mã trang trước khi sao chép.

Người gọi cung cấp các thuộc tính của trang thông qua ZZ0000ZZ
    tham số. Các giá trị hợp lệ cho ZZ0001ZZ là:

* CACHE_INHIBITED
	* CACHE_ENABLED
	* WRITE_PROTECTION

Hypervisor phải ghim trang vào bộ nhớ trước khi thực hiện
    Siêu cuộc gọi ZZ0000ZZ.

Trường hợp sử dụng
~~~~~~~~~~~~~~~~~~

#. Khi một máy ảo bình thường chuyển sang chế độ bảo mật, tất cả các trang của nó sẽ nằm
       trong bộ nhớ bình thường, được chuyển vào bộ nhớ an toàn.

#. Khi SVM yêu cầu chia sẻ một trang với Hypervisor thì Hypervisor
       phân bổ một trang và thông báo cho Ultravisor.

#. Khi SVM truy cập vào một trang bảo mật đã được phân trang,
       Ultravisor gọi Hypervisor để định vị trang. Sau
       định vị trang, Hypervisor sử dụng UV_PAGE_IN để tạo
       trang có sẵn cho Ultravisor.

UV_PAGE_INVAL
-------------

Vô hiệu hóa ánh xạ Ultravisor của một trang.

Cú pháp
~~~~~~~

.. code-block:: c

	uint64_t ultracall(const uint64_t UV_PAGE_INVAL,
		uint16_t lpid,		/* the LPAR ID */
		uint64_t guest_pa,	/* destination guest-physical-address */
		uint64_t order)		/* page size order */

Giá trị trả về
~~~~~~~~~~~~~~

Một trong các giá trị sau:

* U_SUCCESS thành công.
	* U_PARAMETER nếu ZZ0000ZZ không hợp lệ.
	* U_P2 nếu ZZ0001ZZ không hợp lệ (hoặc tương ứng với bảo mật
                        ánh xạ trang).
	* U_P3 nếu ZZ0002ZZ không hợp lệ.
	* U_FUNCTION nếu chức năng không được hỗ trợ.
	* U_BUSY nếu trang hiện không thể bị vô hiệu.

Sự miêu tả
~~~~~~~~~~~

Ultracall này thông báo cho Ultravisor rằng việc ánh xạ trang trong Hypervisor
    tương ứng với địa chỉ vật lý của khách đã cho đã bị vô hiệu
    và Ultravisor không nên truy cập trang. Nếu được chỉ định
    ZZ0000ZZ tương ứng với một trang bảo mật, Ultravisor sẽ bỏ qua
    cố gắng vô hiệu hóa trang và trả về U_P2.

Trường hợp sử dụng
~~~~~~~~~~~~~~~~~~

#. Khi một trang chia sẻ không được ánh xạ khỏi bảng trang của QEMU, có thể
       vì nó được phân trang ra đĩa nên Ultravisor cần biết rằng
       trang cũng không nên được truy cập từ phía của nó.


UV_WRITE_PATE
-------------

Xác thực và ghi mục nhập bảng phân vùng (PATE) cho một mục nhất định
    phân vùng.

Cú pháp
~~~~~~~

.. code-block:: c

	uint64_t ultracall(const uint64_t UV_WRITE_PATE,
		uint32_t lpid,		/* the LPAR ID */
		uint64_t dw0		/* the first double word to write */
		uint64_t dw1)		/* the second double word to write */

Giá trị trả về
~~~~~~~~~~~~~~

Một trong các giá trị sau:

* U_SUCCESS thành công.
	* U_BUSY nếu PATE hiện không thể ghi vào.
	* U_FUNCTION nếu chức năng không được hỗ trợ.
	* U_PARAMETER nếu ZZ0000ZZ không hợp lệ.
	* U_P2 nếu ZZ0001ZZ không hợp lệ.
	* U_P3 nếu địa chỉ ZZ0002ZZ không hợp lệ.
	* U_PERMISSION nếu Hypervisor đang cố thay đổi PATE
			của một máy ảo an toàn hoặc nếu được gọi từ một
			bối cảnh khác với Hypervisor.

Sự miêu tả
~~~~~~~~~~~

Xác thực và ghi LPID và mục nhập bảng phân vùng của nó cho mục đích đã cho
    LPID.  Nếu LPID đã được phân bổ và khởi tạo, lệnh gọi này
    dẫn đến việc thay đổi mục nhập bảng phân vùng.

Trường hợp sử dụng
~~~~~~~~~~~~~~~~~~

#. Bảng phân vùng nằm trong bộ nhớ an toàn và các mục của nó,
       được gọi là PATE (Mục nhập bảng phân vùng), trỏ đến phân vùng-
       các bảng trang có phạm vi cho Hypervisor cũng như từng
       máy ảo (cả an toàn và bình thường). siêu giám sát
       hoạt động trong phân vùng 0 và các bảng trang trong phạm vi phân vùng của nó
       nằm trong bộ nhớ bình thường.

#. Ultracall này cho phép Hypervisor đăng ký phân vùng-
       các mục trong bảng trang có phạm vi và phạm vi quy trình cho Hypervisor
       và các phân vùng khác (máy ảo) có Ultravisor.

#. Nếu giá trị của PATE cho phân vùng (VM) hiện có thay đổi,
       bộ đệm TLB cho phân vùng bị xóa.

#. Hypervisor chịu trách nhiệm phân bổ LPID. LPID và
       mục nhập PATE của nó được đăng ký cùng nhau.  Hypervisor quản lý
       các mục nhập PATE cho máy ảo thông thường và có thể thay đổi mục nhập PATE
       bất cứ lúc nào. Ultravisor quản lý các mục PATE cho SVM và
       Hypervisor không được phép sửa đổi chúng.

UV_RETURN
---------

Trả lại quyền điều khiển từ Hypervisor cho Ultravisor sau
    xử lý một siêu cuộc gọi hoặc ngắt đã được chuyển tiếp (còn gọi là
    ZZ0000ZZ) tới Hypervisor.

Cú pháp
~~~~~~~

.. code-block:: c

	uint64_t ultracall(const uint64_t UV_RETURN)

Giá trị trả về
~~~~~~~~~~~~~~

Cuộc gọi này không bao giờ quay trở lại Hypervisor nếu thành công.  Nó trở lại
     U_INVALID nếu ultracall không được tạo từ bối cảnh Hypervisor.

Sự miêu tả
~~~~~~~~~~~

Khi SVM thực hiện một siêu cuộc gọi hoặc phát sinh một số ngoại lệ khác,
    Ultravisor thường chuyển tiếp (còn gọi là ZZ0001ZZ) các ngoại lệ cho
    Giám sát viên.  Sau khi xử lý ngoại lệ, Hypervisor sử dụng
    ZZ0000ZZ ultracall để trả lại quyền kiểm soát cho SVM.

Trạng thái đăng ký dự kiến ​​khi truy cập vào ultracall này là:

* Các thanh ghi không thay đổi được khôi phục về giá trị ban đầu.
    * Nếu trở về từ một hypercall, thanh ghi R0 chứa kết quả trả về
      giá trị (ZZ0000ZZ) và đăng ký R4 đến R12
      chứa bất kỳ giá trị đầu ra nào của hypercall.
    * R3 chứa số ultracall, tức là UV_RETURN.
    * Nếu quay lại với một ngắt tổng hợp, R2 chứa
      số ngắt tổng hợp.

Trường hợp sử dụng
~~~~~~~~~~~~~~~~~~

#. Ultravisor dựa vào Hypervisor để cung cấp một số dịch vụ cho
       SVM chẳng hạn như xử lý hypercall và các trường hợp ngoại lệ khác. Sau
       xử lý ngoại lệ, Hypervisor sử dụng UV_RETURN để trả về
       điều khiển trở lại Ultravisor.

#. Hypervisor phải sử dụng ultracall này để trả lại quyền kiểm soát cho SVM.


UV_REGISTER_MEM_SLOT
--------------------

Đăng ký dải địa chỉ SVM với các thuộc tính được chỉ định.

Cú pháp
~~~~~~~

.. code-block:: c

	uint64_t ultracall(const uint64_t UV_REGISTER_MEM_SLOT,
		uint64_t lpid,		/* LPAR ID of the SVM */
		uint64_t start_gpa,	/* start guest physical address */
		uint64_t size,		/* size of address range in bytes */
		uint64_t flags		/* reserved for future expansion */
		uint16_t slotid)	/* slot identifier */

Giá trị trả về
~~~~~~~~~~~~~~

Một trong các giá trị sau:

* U_SUCCESS thành công.
	* U_PARAMETER nếu ZZ0000ZZ không hợp lệ.
	* U_P2 nếu ZZ0001ZZ không hợp lệ.
	* U_P3 nếu ZZ0002ZZ không hợp lệ.
	* U_P4 nếu bất kỳ bit nào trong ZZ0003ZZ không được nhận dạng.
	* U_P5 nếu tham số ZZ0004ZZ không được hỗ trợ.
	* U_PERMISSION nếu được gọi từ ngữ cảnh không phải Hypervisor.
	* U_FUNCTION nếu chức năng không được hỗ trợ.


Sự miêu tả
~~~~~~~~~~~

Đăng ký phạm vi bộ nhớ cho SVM.  Phạm vi bộ nhớ bắt đầu tại
    địa chỉ vật lý của khách ZZ0000ZZ và dài ZZ0001ZZ byte.

Trường hợp sử dụng
~~~~~~~~~~~~~~~~~~


#. Khi một máy ảo được bảo mật, tất cả các khe bộ nhớ được quản lý bởi
       Hypervisor di chuyển vào bộ nhớ an toàn. Hypervisor lặp lại
       qua từng khe bộ nhớ và đăng ký khe đó với
       Máy siêu âm.  Hypervisor có thể loại bỏ một số vị trí như những vị trí được sử dụng
       cho phần sụn (SLOF).

#. Khi bộ nhớ mới được cắm nóng, khe cắm bộ nhớ mới sẽ được đăng ký.


UV_UNREGISTER_MEM_SLOT
----------------------

Hủy đăng ký dải địa chỉ SVM đã được đăng ký trước đó bằng cách sử dụng
    UV_REGISTER_MEM_SLOT.

Cú pháp
~~~~~~~

.. code-block:: c

	uint64_t ultracall(const uint64_t UV_UNREGISTER_MEM_SLOT,
		uint64_t lpid,		/* LPAR ID of the SVM */
		uint64_t slotid)	/* reservation slotid */

Giá trị trả về
~~~~~~~~~~~~~~

Một trong các giá trị sau:

* U_SUCCESS thành công.
	* U_FUNCTION nếu chức năng không được hỗ trợ.
	* U_PARAMETER nếu ZZ0000ZZ không hợp lệ.
	* U_P2 nếu ZZ0001ZZ không hợp lệ.
	* U_PERMISSION nếu được gọi từ ngữ cảnh không phải Hypervisor.

Sự miêu tả
~~~~~~~~~~~

Nhả khe cắm bộ nhớ được xác định bởi ZZ0000ZZ và giải phóng mọi
    nguồn lực được phân bổ cho việc đặt trước.

Trường hợp sử dụng
~~~~~~~~~~~~~~~~~~

#. Bộ nhớ nóng-loại bỏ.


UV_SVM_TERMINATE
----------------

Chấm dứt SVM và giải phóng tài nguyên của nó.

Cú pháp
~~~~~~~

.. code-block:: c

	uint64_t ultracall(const uint64_t UV_SVM_TERMINATE,
		uint64_t lpid,		/* LPAR ID of the SVM */)

Giá trị trả về
~~~~~~~~~~~~~~

Một trong các giá trị sau:

* U_SUCCESS thành công.
	* U_FUNCTION nếu chức năng không được hỗ trợ.
	* U_PARAMETER nếu ZZ0000ZZ không hợp lệ.
	* U_INVALID nếu VM không an toàn.
	* U_PERMISSION nếu không được gọi từ bối cảnh Hypervisor.

Sự miêu tả
~~~~~~~~~~~

Chấm dứt SVM và giải phóng tất cả tài nguyên của nó.

Trường hợp sử dụng
~~~~~~~~~~~~~~~~~~

#. Được Hypervisor gọi khi chấm dứt SVM.


Ultracall được SVM sử dụng
==========================

UV_SHARE_PAGE
-------------

Chia sẻ một tập hợp các trang vật lý của khách với Hypervisor.

Cú pháp
~~~~~~~

.. code-block:: c

	uint64_t ultracall(const uint64_t UV_SHARE_PAGE,
		uint64_t gfn,	/* guest page frame number */
		uint64_t num)	/* number of pages of size PAGE_SIZE */

Giá trị trả về
~~~~~~~~~~~~~~

Một trong các giá trị sau:

* U_SUCCESS thành công.
	* U_FUNCTION nếu chức năng không được hỗ trợ.
	* U_INVALID nếu VM không an toàn.
	* U_PARAMETER nếu ZZ0000ZZ không hợp lệ.
	* U_P2 nếu ZZ0001ZZ không hợp lệ.

Sự miêu tả
~~~~~~~~~~~

Chia sẻ các trang ZZ0000ZZ bắt đầu từ số khung vật lý của khách ZZ0001ZZ
    với Hypervisor. Giả sử kích thước trang là byte PAGE_SIZE. Không
    trang trước khi quay trở lại.

Nếu địa chỉ đã được hỗ trợ bởi một trang bảo mật, hãy hủy ánh xạ trang đó và
    sao lưu nó bằng một trang không an toàn với sự trợ giúp của Hypervisor. Nếu nó
    chưa được hỗ trợ bởi bất kỳ trang nào, hãy đánh dấu PTE là không an toàn và sao lưu nó
    với một trang không an toàn khi địa chỉ được truy cập. Nếu nó đã rồi
    được hỗ trợ bởi một trang không an toàn, xóa trang đó và quay lại.

Trường hợp sử dụng
~~~~~~~~~~~~~~~~~~

#. Hypervisor không thể truy cập các trang SVM vì chúng được hỗ trợ bởi
       các trang an toàn. Do đó, SVM phải yêu cầu rõ ràng Ultravisor cho
       các trang nó có thể chia sẻ với Hypervisor.

#. Cần có các trang được chia sẻ để hỗ trợ virtio và Vùng xử lý ảo
       (VPA) trong SVM.


UV_UNSHARE_PAGE
---------------

Khôi phục trang SVM được chia sẻ về trạng thái ban đầu.

Cú pháp
~~~~~~~

.. code-block:: c

	uint64_t ultracall(const uint64_t UV_UNSHARE_PAGE,
		uint64_t gfn,	/* guest page frame number */
		uint73 num)	/* number of pages of size PAGE_SIZE*/

Giá trị trả về
~~~~~~~~~~~~~~

Một trong các giá trị sau:

* U_SUCCESS thành công.
	* U_FUNCTION nếu chức năng không được hỗ trợ.
	* U_INVALID nếu VM không an toàn.
	* U_PARAMETER nếu ZZ0000ZZ không hợp lệ.
	* U_P2 nếu ZZ0001ZZ không hợp lệ.

Sự miêu tả
~~~~~~~~~~~

Dừng chia sẻ các trang ZZ0000ZZ bắt đầu từ ZZ0001ZZ với Hypervisor.
    Giả sử kích thước trang là PAGE_SIZE. Zero các trang trước
    đang quay trở lại.

Nếu địa chỉ đã được hỗ trợ bởi một trang không an toàn, hãy hủy ánh xạ trang đó
    và sao lưu nó bằng một trang an toàn. Thông báo cho Hypervisor để phát hành
    tham chiếu đến trang được chia sẻ của nó. Nếu địa chỉ không được hỗ trợ bởi một trang
    Tuy nhiên, hãy đánh dấu PTE là an toàn và sao lưu nó bằng một trang bảo mật khi điều đó
    địa chỉ được truy cập. Nếu nó đã được hỗ trợ bởi một trang bảo mật số 0
    trang này và quay lại.

Trường hợp sử dụng
~~~~~~~~~~~~~~~~~~

#. SVM có thể quyết định hủy chia sẻ một trang khỏi Hypervisor.


UV_UNSHARE_ALL_PAGES
--------------------

Hủy chia sẻ tất cả các trang SVM đã chia sẻ với Hypervisor.

Cú pháp
~~~~~~~

.. code-block:: c

	uint64_t ultracall(const uint64_t UV_UNSHARE_ALL_PAGES)

Giá trị trả về
~~~~~~~~~~~~~~

Một trong các giá trị sau:

* U_SUCCESS thành công.
	* U_FUNCTION nếu chức năng không được hỗ trợ.
	* U_INVAL nếu VM không an toàn.

Sự miêu tả
~~~~~~~~~~~

Hủy chia sẻ tất cả các trang được chia sẻ từ Hypervisor. Tất cả các trang không được chia sẻ đều
    bằng 0 khi trả lại. Chỉ những trang được SVM chia sẻ rõ ràng với
    Hypervisor (sử dụng UV_SHARE_PAGE ultracall) không được chia sẻ. siêu âm
    có thể chia sẻ nội bộ một số trang với Hypervisor mà không cần thông báo rõ ràng
    yêu cầu từ SVM.  Những trang này sẽ không bị chia sẻ bởi điều này
    ultracall.

Trường hợp sử dụng
~~~~~~~~~~~~~~~~~~

#. Cuộc gọi này là cần thiết khi ZZ0000ZZ được sử dụng để khởi động một hệ thống khác
       hạt nhân. Nó cũng có thể cần thiết trong quá trình thiết lập lại SVM.

UV_ESM
------

Bảo mật máy ảo (ZZ0000ZZ).

Cú pháp
~~~~~~~

.. code-block:: c

	uint64_t ultracall(const uint64_t UV_ESM,
		uint64_t esm_blob_addr,	/* location of the ESM blob */
		unint64_t fdt)		/* Flattened device tree */

Giá trị trả về
~~~~~~~~~~~~~~

Một trong các giá trị sau:

* U_SUCCESS thành công (bao gồm cả nếu VM đã được bảo mật).
	* U_FUNCTION nếu chức năng không được hỗ trợ.
	* U_INVALID nếu VM không an toàn.
	* U_PARAMETER nếu ZZ0000ZZ không hợp lệ.
	* U_P2 nếu ZZ0001ZZ không hợp lệ.
	* U_PERMISSION nếu bất kỳ kiểm tra tính toàn vẹn nào không thành công.
	* U_RETRY không đủ bộ nhớ để tạo SVM.
	* Không có khóa đối xứng U_NO_KEY.

Sự miêu tả
~~~~~~~~~~~

Bảo mật máy ảo. Sau khi hoàn thành thành công, quay lại
    điều khiển máy ảo tại địa chỉ được chỉ định trong
    ESM đốm màu.

Trường hợp sử dụng
~~~~~~~~~~~~~~~~~~

#. Một máy ảo bình thường có thể chọn chuyển sang chế độ bảo mật.

Hypervisor gọi API
####################

Tài liệu này mô tả các lệnh gọi Hypervisor (hypercalls) được
    cần thiết để hỗ trợ Ultravisor. Hypercalls là các dịch vụ được cung cấp bởi
    Hypervisor cho máy ảo và Ultravisor.

Việc đăng ký sử dụng các hypercall này giống hệt với các hypercall khác
    siêu cuộc gọi được xác định trong Tham chiếu nền tảng kiến trúc sức mạnh (PAPR)
    tài liệu.  tức là ở đầu vào, thanh ghi R3 xác định dịch vụ cụ thể
    đang được yêu cầu và đăng ký R4 đến R11 chứa
    các tham số bổ sung cho hypercall, nếu có. Trên đầu ra, đăng ký
    R3 chứa giá trị trả về và các thanh ghi từ R4 đến R9 chứa bất kỳ
    các giá trị đầu ra khác từ hypercall.

Tài liệu này chỉ bao gồm các siêu cuộc gọi hiện đang được triển khai/lên kế hoạch
    để sử dụng Ultravisor nhưng những thứ khác có thể được thêm vào đây khi thấy hợp lý.

Thông số kỹ thuật đầy đủ cho tất cả các hypercalls/ultracalls cuối cùng sẽ
    được cung cấp ở phiên bản công khai/OpenPower của PAPR
    đặc điểm kỹ thuật.

Hypervisor kêu gọi hỗ trợ Ultravisor
======================================

Sau đây là tập hợp các siêu lệnh cần thiết để hỗ trợ Ultravisor.

H_SVM_INIT_START
----------------

Bắt đầu quá trình chuyển đổi một máy ảo bình thường thành SVM.

Cú pháp
~~~~~~~

.. code-block:: c

	uint64_t hypercall(const uint64_t H_SVM_INIT_START)

Giá trị trả về
~~~~~~~~~~~~~~

Một trong các giá trị sau:

* H_SUCCESS thành công.
        * H_STATE nếu VM không ở trạng thái chuyển sang chế độ bảo mật.

Sự miêu tả
~~~~~~~~~~~

Bắt đầu quá trình bảo mật một máy ảo. Điều này liên quan đến
    phối hợp với Ultravisor, sử dụng ultracalls để phân bổ
    tài nguyên trong Ultravisor cho SVM mới, chuyển VM
    các trang từ bộ nhớ bình thường đến bộ nhớ an toàn, v.v. Khi quá trình này hoàn tất
    hoàn thành, Ultravisor phát hành siêu lệnh gọi H_SVM_INIT_DONE.

Trường hợp sử dụng
~~~~~~~~~~~~~~~~~~

#. Ultravisor sử dụng hypercall này để thông báo cho Hypervisor rằng một máy ảo
        đã bắt đầu quá trình chuyển sang chế độ bảo mật.


H_SVM_INIT_DONE
---------------

Hoàn tất quá trình bảo mật SVM.

Cú pháp
~~~~~~~

.. code-block:: c

	uint64_t hypercall(const uint64_t H_SVM_INIT_DONE)

Giá trị trả về
~~~~~~~~~~~~~~

Một trong các giá trị sau:

* H_SUCCESS thành công.
	* H_UNSUPPORTED nếu được gọi sai ngữ cảnh (ví dụ:
				từ SVM hoặc trước H_SVM_INIT_START
				siêu cuộc gọi).
	* H_STATE nếu hypervisor không thành công
                                chuyển VM sang Secure VM.

Sự miêu tả
~~~~~~~~~~~

Hoàn tất quá trình bảo mật máy ảo. Cuộc gọi này phải
    được thực hiện sau cuộc gọi trước tới siêu cuộc gọi ZZ0000ZZ.

Trường hợp sử dụng
~~~~~~~~~~~~~~~~~~

Khi bảo mật thành công một máy ảo, Ultravisor sẽ thông báo
    Hypervisor về nó. Hypervisor có thể sử dụng lệnh gọi này để hoàn tất cài đặt
    nâng cấp trạng thái bên trong của nó cho máy ảo này.


H_SVM_INIT_ABORT
----------------

Hủy bỏ quá trình bảo mật SVM.

Cú pháp
~~~~~~~

.. code-block:: c

	uint64_t hypercall(const uint64_t H_SVM_INIT_ABORT)

Giá trị trả về
~~~~~~~~~~~~~~

Một trong các giá trị sau:

* H_PARAMETER về việc dọn dẹp trạng thái thành công,
				Hypervisor sẽ trả về giá trị này cho
				ZZ0000ZZ, để chỉ ra rằng cơ sở
				Cuộc gọi siêu âm UV_ESM không thành công.

* H_STATE nếu được gọi sau khi VM đã được bảo mật (tức là
				Siêu cuộc gọi H_SVM_INIT_DONE đã thành công).

* H_UNSUPPORTED nếu được gọi từ ngữ cảnh sai (ví dụ: từ một
				VM bình thường).

Sự miêu tả
~~~~~~~~~~~

Hủy bỏ quá trình bảo mật máy ảo. Cuộc gọi này phải
    được thực hiện sau cuộc gọi trước tới siêu cuộc gọi ZZ0000ZZ và
    trước cuộc gọi tới ZZ0001ZZ.

Khi tham gia vào cuộc gọi siêu tốc này, GPR và FPR không biến động sẽ được
    dự kiến sẽ chứa các giá trị họ có tại thời điểm VM phát hành
    siêu âm UV_ESM. Hơn nữa ZZ0000ZZ dự kiến sẽ chứa
    địa chỉ của lệnh sau ultracall ZZ0001ZZ và ZZ0002ZZ
    giá trị MSR để trả về VM.

Hypercall này sẽ dọn sạch mọi trạng thái từng phần được thiết lập cho
    VM kể từ siêu lệnh ZZ0000ZZ trước đó, bao gồm cả phân trang
    ra các trang đã được phân trang vào bộ nhớ an toàn và đưa ra
    ZZ0001ZZ ultracall để chấm dứt VM.

Sau khi dọn sạch trạng thái một phần, quyền điều khiển sẽ quay trở lại VM
    (ZZ0002ZZ), tại địa chỉ được chỉ định trong ZZ0000ZZ với
    Giá trị MSR được đặt thành giá trị trong ZZ0001ZZ.

Trường hợp sử dụng
~~~~~~~~~~~~~~~~~~

Nếu sau khi gọi thành công tới ZZ0000ZZ, Ultravisor
    gặp lỗi trong khi bảo mật máy ảo, hoặc do
    thiếu tài nguyên hoặc vì thông tin bảo mật của VM có thể
    không được xác thực, Ultravisor sẽ thông báo cho Hypervisor về điều đó.
    Hypervisor nên sử dụng lệnh gọi này để dọn dẹp mọi trạng thái nội bộ cho
    máy ảo này và quay trở lại VM.

H_SVM_PAGE_IN
-------------

Di chuyển nội dung của một trang từ bộ nhớ bình thường sang bộ nhớ an toàn.

Cú pháp
~~~~~~~

.. code-block:: c

	uint64_t hypercall(const uint64_t H_SVM_PAGE_IN,
		uint64_t guest_pa,	/* guest-physical-address */
		uint64_t flags,		/* flags */
		uint64_t order)		/* page size order */

Giá trị trả về
~~~~~~~~~~~~~~

Một trong các giá trị sau:

* H_SUCCESS thành công.
	* H_PARAMETER nếu ZZ0000ZZ không hợp lệ.
	* H_P2 nếu ZZ0001ZZ không hợp lệ.
	* H_P3 nếu ZZ0002ZZ của trang không hợp lệ.

Sự miêu tả
~~~~~~~~~~~

Truy xuất nội dung của trang, thuộc về VM tại địa chỉ đã chỉ định
    địa chỉ vật lý của khách.

Chỉ (các) giá trị hợp lệ trong ZZ0000ZZ là:

* H_PAGE_IN_SHARED cho biết trang này sẽ được chia sẻ
	  với Ultravisor.

* H_PAGE_IN_NONSHARED cho biết tia UV không còn nữa
          quan tâm đến trang. Áp dụng nếu trang là trang được chia sẻ.

Tham số ZZ0000ZZ phải tương ứng với kích thước trang được định cấu hình.

Trường hợp sử dụng
~~~~~~~~~~~~~~~~~~

#. Khi một VM bình thường trở thành một VM an toàn (sử dụng ultracall UV_ESM),
       Ultravisor sử dụng hypercall này để di chuyển nội dung của từng trang
       VM từ bộ nhớ bình thường sang bộ nhớ an toàn.

#. Ultravisor sử dụng hypercall này để yêu cầu Hypervisor cung cấp một trang
       trong bộ nhớ bình thường có thể được chia sẻ giữa SVM và Hypervisor.

#. Ultravisor sử dụng siêu lệnh gọi này để phân trang vào một trang đã phân trang. Cái này
       có thể xảy ra khi SVM chạm vào một trang đã phân trang.

#. Nếu SVM muốn tắt tính năng chia sẻ trang bằng Hypervisor, nó có thể
       thông báo cho Ultravisor để làm như vậy. Ultravisor sau đó sẽ sử dụng hypercall này
       và thông báo cho Hypervisor rằng nó đã cấp quyền truy cập vào phần bình thường
       trang.

H_SVM_PAGE_OUT
---------------

Di chuyển nội dung của trang vào bộ nhớ bình thường.

Cú pháp
~~~~~~~

.. code-block:: c

	uint64_t hypercall(const uint64_t H_SVM_PAGE_OUT,
		uint64_t guest_pa,	/* guest-physical-address */
		uint64_t flags,		/* flags (currently none) */
		uint64_t order)		/* page size order */

Giá trị trả về
~~~~~~~~~~~~~~

Một trong các giá trị sau:

* H_SUCCESS thành công.
	* H_PARAMETER nếu ZZ0000ZZ không hợp lệ.
	* H_P2 nếu ZZ0001ZZ không hợp lệ.
	* H_P3 nếu ZZ0002ZZ không hợp lệ.

Sự miêu tả
~~~~~~~~~~~

Di chuyển nội dung của trang được xác định bởi ZZ0000ZZ sang trang bình thường
    trí nhớ.

Hiện tại ZZ0000ZZ không được sử dụng và phải được đặt thành 0. ZZ0001ZZ
    tham số phải tương ứng với kích thước trang được định cấu hình.

Trường hợp sử dụng
~~~~~~~~~~~~~~~~~~

#. Nếu Ultravisor sắp hết trên các trang bảo mật, nó có thể di chuyển
       nội dung của một số trang bảo mật, vào các trang bình thường bằng cách sử dụng
       hypercall. Nội dung sẽ được mã hóa.

Tài liệu tham khảo
##################

-ZZ0000ZZ