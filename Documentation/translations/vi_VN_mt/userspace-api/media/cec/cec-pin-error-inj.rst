.. SPDX-License-Identifier: GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/cec/cec-pin-error-inj.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. _cec_pin_error_inj:

Chèn lỗi khung pin CEC
=================================

Khung pin CEC là khung CEC cốt lõi dành cho phần cứng CEC chỉ
có hỗ trợ cấp thấp cho bus CEC. Hầu hết phần cứng ngày nay sẽ có
hỗ trợ CEC cấp cao trong đó phần cứng xử lý việc điều khiển xe buýt CEC,
nhưng một số thiết bị cũ không được ưa chuộng cho lắm. Tuy nhiên, khuôn khổ này cũng
cho phép bạn kết nối chân CEC với GPIO trên ví dụ: một Raspberry Pi và
bây giờ bạn đã tạo bộ chuyển đổi CEC.

Điều khiến việc này trở nên thú vị là vì chúng ta có toàn quyền kiểm soát
trên xe buýt rất dễ hỗ trợ việc tiêm lỗi. Đây là lý tưởng để
kiểm tra xem bộ điều hợp CEC có thể xử lý các tình trạng lỗi tốt như thế nào.

Hiện tại chỉ có trình điều khiển cec-gpio (khi dòng CEC được kết nối trực tiếp
được kết nối với đường dây GPIO kéo lên) và trình điều khiển drm AllWinner A10/A20
hỗ trợ khuôn khổ này.

Nếu ZZ0000ZZ được bật thì tính năng chèn lỗi sẽ khả dụng
thông qua debugfs. Cụ thể, trong ZZ0001ZZ có
bây giờ là tệp ZZ0002ZZ.

.. note::

    The error injection commands are not a stable ABI and may change in the
    future.

Với ZZ0000ZZ, bạn có thể thấy cả các lệnh có thể và lệnh hiện tại
trạng thái tiêm lỗi::

$ cat /sys/kernel/debug/cec/cec0/error-inj
	Tiêm lỗi # Clear:
	#   clear xóa tất cả các lỗi tiêm rx và tx
	#   rx-clear xóa tất cả các lần tiêm lỗi rx
	#   tx-clear xóa tất cả các lần tiêm lỗi tx
	# <op> xóa xóa tất cả các lần chèn lỗi rx và tx cho <op>
	# <op> rx-clear xóa tất cả các lỗi tiêm rx cho <op>
	# <op> tx-clear xóa tất cả các lần chèn lỗi tx cho <op>
	#
	Cài đặt chèn lỗi # RX:
	#   rx-no-low-drive không tạo xung truyền động thấp
	#
	Lỗi tiêm # RX:
	# <op>[,<mode>] rx-nack NACK gửi tin nhắn thay vì gửi ACK
	# <op>[,<mode>] rx-low-drive <bit> buộc điều kiện ổ đĩa thấp ở vị trí bit này
	# <op>[,<mode>] rx-add-byte thêm một byte giả vào tin nhắn CEC đã nhận
	# <op>[,<mode>] rx-remove-byte xóa byte cuối cùng khỏi tin nhắn CEC đã nhận
	#    any[,<mode>] rx-arb-lost [<poll>] tạo thông báo POLL để kích hoạt trọng tài bị mất
	#
	Cài đặt chèn lỗi # TX:
	#   tx-ignore-nack-until-eom bỏ qua NACK sớm cho đến EOM
	#   tx-custom-low-usecs <usecs> xác định thời gian 'thấp' cho xung tùy chỉnh
	#   tx-custom-high-usecs <usecs> xác định thời gian 'cao' cho xung tùy chỉnh
	#   tx-custom-pulse truyền xung tùy chỉnh khi xe buýt không hoạt động
	#   tx-glitch-low-usecs <usecs> xác định thời gian 'thấp' cho xung trục trặc
	#   tx-glitch-high-usecs <usecs> xác định thời gian 'cao' cho xung trục trặc
	#   tx-glitch-falling-edge gửi xung trục trặc sau mỗi cạnh rơi
	#   tx-glitch-rising-edge gửi xung trục trặc sau mỗi cạnh tăng
	#
	Lỗi tiêm # TX:
	# <op>[,<mode>] tx-no-eom không đặt bit EOM
	# <op>[,<mode>] tx-early-eom đặt bit EOM quá sớm một byte
	# <op>[,<mode>] tx-add-bytes <num> nối thêm <num> (1-255) byte giả vào tin nhắn
	# <op>[,<mode>] tx-remove-byte loại bỏ byte cuối cùng khỏi tin nhắn
	# <op>[,<mode>] tx-short-bit <bit> làm cho bit này ngắn hơn mức cho phép
	# <op>[,<mode>] tx-long-bit <bit> làm cho bit này dài hơn mức cho phép
	# <op>[,<mode>] tx-custom-bit <bit> gửi xung tùy chỉnh thay vì bit này
	# <op>[,<mode>] tx-short-start gửi xung bắt đầu quá ngắn
	# <op>[,<mode>] tx-long-start gửi xung bắt đầu quá dài
	# <op>[,<mode>] tx-custom-start gửi xung tùy chỉnh thay vì xung bắt đầu
	# <op>[,<mode>] tx-last-bit <bit> ngừng gửi sau bit này
	# <op>[,<mode>] tx-low-drive <bit> buộc điều kiện ổ đĩa thấp ở vị trí bit này
	#
	# <op> Mã opcode tin nhắn CEC (0-255) hoặc 'bất kỳ'
	# <mode> 'một lần' (mặc định), 'luôn luôn', 'chuyển đổi' hoặc 'tắt'
	# <bit> Bit thông báo CEC (0-159)
	Số bit #            10 trên mỗi 'byte': bit 0-7: dữ liệu, bit 8: EOM, bit 9: ACK
	# <poll> Thông báo thăm dò CEC được sử dụng để kiểm tra trọng tài bị mất (0x00-0xff, 0x0f mặc định)
	# <usecs> micro giây (0-10000000, mặc định 1000)

thông thoáng

Bạn có thể viết lệnh chèn lỗi vào ZZ0000ZZ bằng cách sử dụng
ZZ0001ZZ hoặc ZZ0002ZZ. ZZ0003ZZ
đầu ra chứa các lệnh lỗi hiện tại. Bạn có thể lưu kết quả đầu ra vào một tập tin
và sử dụng nó làm đầu vào cho ZZ0004ZZ sau này.

Cú pháp cơ bản
--------------

Khoảng trắng/tab hàng đầu bị bỏ qua. Nếu ký tự tiếp theo là ZZ0000ZZ hoặc kết thúc
của dòng đã đạt được thì toàn bộ dòng sẽ bị bỏ qua. Nếu không thì một lệnh
được mong đợi.

Các lệnh chèn lỗi được chia thành hai nhóm chính: những lệnh liên quan đến
nhận tin nhắn CEC và những tin nhắn liên quan đến việc truyền tin nhắn CEC. trong
Ngoài ra, còn có các lệnh để xóa các lệnh chèn lỗi hiện có và
để tạo các xung tùy chỉnh trên bus CEC.

Hầu hết các lệnh chèn lỗi có thể được thực thi đối với các mã hoạt động CEC cụ thể hoặc đối với
tất cả các mã hoạt động (ZZ0000ZZ). Mỗi lệnh cũng có một “chế độ” có thể là ZZ0001ZZ
(có thể được sử dụng để tắt lệnh chèn lỗi hiện có), ZZ0002ZZ
(mặc định) sẽ chỉ kích hoạt việc chèn lỗi một lần cho lần tiếp theo
tin nhắn đã nhận hoặc truyền, ZZ0003ZZ luôn gây ra lỗi
tiêm và ZZ0004ZZ để bật hoặc tắt tính năng chèn lỗi cho mỗi lần
truyền hoặc nhận.

Vì vậy, 'ZZ0000ZZ' sẽ là NACK trong tin nhắn CEC nhận được tiếp theo,
'ZZ0001ZZ' sẽ NACK đều nhận được tin nhắn CEC và
'ZZ0002ZZ' sẽ chỉ NACK nếu có thông báo Nguồn hoạt động
đã nhận và chỉ làm điều đó đối với mọi tin nhắn đã nhận khác.

Sau khi một lỗi được chèn vào chế độ ZZ0000ZZ, lệnh chèn lỗi
được xóa tự động, vì vậy ZZ0001ZZ là giao dịch một lần.

Tất cả sự kết hợp của lệnh ZZ0000ZZ và lệnh chèn lỗi có thể cùng tồn tại. Vì vậy
điều này ổn::

0x9e tx-add-byte 1
	0x9e tx-sớm-eom
	0x9f tx-add-byte 2
	bất kỳ rx-nack nào

Tất cả bốn lệnh chèn lỗi sẽ được kích hoạt đồng thời.

Tuy nhiên, nếu chỉ định cùng một ZZ0000ZZ và kết hợp lệnh,
nhưng với các đối số khác nhau ::

0x9e tx-add-byte 1
	0x9e tx-add-byte 2

Sau đó, cái thứ hai sẽ ghi đè lên cái đầu tiên.

Xóa lỗi tiêm
----------------------

ZZ0000ZZ
    Xóa tất cả các lần tiêm lỗi.

ZZ0000ZZ
    Xóa tất cả các lỗi nhận được

ZZ0000ZZ
    Xóa tất cả các lỗi truyền tải

ZZ0000ZZ
    Xóa tất cả các lỗi chèn vào cho opcode đã cho.

ZZ0000ZZ
    Xóa tất cả các lỗi nhận được đối với opcode đã cho.

ZZ0000ZZ
    Xóa tất cả các lần chèn lỗi truyền cho opcode đã cho.

Nhận tin nhắn
----------------

ZZ0000ZZ
    NACK phát tin nhắn và tin nhắn hướng đến bộ chuyển đổi CEC này.
    Mỗi byte của tin nhắn sẽ được NACK trong trường hợp máy phát
    tiếp tục truyền sau khi byte đầu tiên được NACKed.

ZZ0000ZZ
    Buộc điều kiện Low Drive ở vị trí bit này. Nếu <op> chỉ định
    một opcode CEC cụ thể thì vị trí bit ít nhất phải là 18,
    nếu không thì opcode vẫn chưa được nhận. Việc này kiểm tra xem liệu
    máy phát có thể xử lý chính xác tình trạng Ổ đĩa yếu và báo cáo
    lỗi một cách chính xác. Lưu ý rằng Low Drive trong 4 bit đầu tiên cũng có thể
    được hiểu là tình trạng Mất trọng tài bởi máy phát.
    Điều này phụ thuộc vào việc thực hiện.

ZZ0000ZZ
    Thêm một byte 0x55 giả vào tin nhắn CEC đã nhận, được cung cấp
    tin nhắn dài 15 byte hoặc ít hơn. Điều này rất hữu ích để kiểm tra
    giao thức cấp cao vì các byte giả sẽ bị bỏ qua.

ZZ0000ZZ
    Xóa byte cuối cùng khỏi tin nhắn CEC đã nhận, miễn là nó
    dài ít nhất 2 byte. Điều này rất hữu ích để kiểm tra mức độ cao
    giao thức vì những tin nhắn quá ngắn sẽ bị bỏ qua.

ZZ0000ZZ
    Tạo thông báo POLL để kích hoạt tình trạng Trọng tài bị mất.
    Lệnh này chỉ được phép đối với các giá trị ZZ0001ZZ của ZZ0002ZZ hoặc ZZ0003ZZ.
    Ngay sau khi nhận được bit khởi động, bộ chuyển đổi CEC sẽ chuyển đổi
    sang chế độ truyền và nó sẽ truyền tin nhắn POLL. Theo mặc định đây là
    0x0f, nhưng nó cũng có thể được chỉ định rõ ràng thông qua đối số ZZ0004ZZ.

Lệnh này có thể được sử dụng để kiểm tra điều kiện Arbitration Lost trong
    bộ phát CEC từ xa. Trọng tài xảy ra khi hai bộ điều hợp CEC
    bắt đầu gửi tin nhắn cùng một lúc. Trong trường hợp đó người khởi xướng
    với nhiều số 0 đứng đầu nhất sẽ thắng và máy phát khác phải
    ngừng truyền ("Trọng tài bị mất"). Cái này khó kiểm tra lắm
    ngoại trừ việc sử dụng lệnh chèn lỗi này.

Điều này không hoạt động nếu bộ phát CEC từ xa có địa chỉ logic
    0 ('TV') vì số đó sẽ luôn thắng.

ZZ0000ZZ
    Người nhận sẽ bỏ qua các tình huống thường tạo ra
    Xung ổ đĩa thấp (3,6 ms). Điều này thường được thực hiện nếu có một xung giả
    được phát hiện khi nhận được tin nhắn và nó cho máy phát biết rằng
    tin nhắn phải được truyền lại vì người nhận nhầm lẫn.
    Việc tắt tính năng này rất hữu ích để kiểm tra cách các thiết bị CEC khác xử lý sự cố
    bằng cách đảm bảo rằng chúng tôi sẽ không phải là người tạo ra Động lực Thấp.

Truyền tin nhắn
-----------------

ZZ0000ZZ
    Cài đặt này thay đổi hành vi truyền tin nhắn CEC. Thông thường
    ngay khi bên nhận NACK một byte thì quá trình truyền sẽ dừng lại, nhưng
    đặc điểm kỹ thuật cũng cho phép toàn bộ thông báo được truyền đi và chỉ
    ở cuối máy phát sẽ nhìn vào bit ACK. Đây không phải là
    hành vi được khuyến nghị vì không có ích gì khi giữ cho xe buýt CEC bận rộn
    lâu hơn mức thực sự cần thiết. Đặc biệt là xe buýt chạy chậm như thế nào.

Cài đặt này có thể được sử dụng để kiểm tra xem người nhận xử lý tốt như thế nào
    máy phát bỏ qua NACK cho đến cuối tin nhắn.

ZZ0000ZZ
    Không đặt bit EOM. Thông thường byte cuối cùng của tin nhắn có EOM
    Tập bit (Cuối tin nhắn). Với lệnh này việc truyền tải sẽ dừng lại
    mà không bao giờ gửi EOM. Điều này có thể được sử dụng để kiểm tra xem máy thu
    xử lý trường hợp này. Thông thường người nhận có thời gian chờ sau đó
    họ sẽ quay trở lại trạng thái Nhàn rỗi.

ZZ0000ZZ
    Đặt bit EOM một byte quá sớm. Điều này rõ ràng chỉ hoạt động đối với tin nhắn
    từ hai byte trở lên. Bit EOM sẽ được đặt cho byte thứ hai đến byte cuối cùng
    và không dành cho byte cuối cùng. Người nhận nên bỏ qua byte cuối cùng trong
    trường hợp này. Vì thông báo kết quả có thể quá ngắn cho việc này
    lý do tương tự toàn bộ tin nhắn thường bị bỏ qua. Người nhận phải là
    ở trạng thái Không hoạt động sau khi byte cuối cùng được truyền đi.

ZZ0000ZZ
    Nối các byte giả ZZ0001ZZ (1-255) vào tin nhắn. Các byte bổ sung
    có giá trị của vị trí byte trong tin nhắn. Vì vậy nếu bạn truyền tải một
    thông báo hai byte (ví dụ: thông báo Nhận phiên bản CEC) và thêm 2 byte, sau đó
    thông báo đầy đủ mà bộ chuyển đổi CEC từ xa nhận được là
    ZZ0002ZZ.

Lệnh này có thể được sử dụng để kiểm tra lỗi tràn bộ đệm trong bộ thu. Ví dụ.
    nó sẽ làm gì khi nhận được nhiều hơn kích thước tin nhắn tối đa là 16
    byte.

ZZ0000ZZ
    Bỏ byte cuối cùng khỏi tin nhắn, miễn là tin nhắn ít nhất
    dài hai byte. Người nhận nên bỏ qua những tin nhắn quá ngắn.

ZZ0000ZZ
    Làm cho khoảng thời gian bit này ngắn hơn mức cho phép. Vị trí bit không thể
    một chút Ack.  Nếu <op> chỉ định một opcode CEC cụ thể thì vị trí bit
    phải ít nhất là 18, nếu không thì opcode vẫn chưa được nhận.
    Thông thường chu kỳ của một bit dữ liệu là từ 2,05 đến 2,75 mili giây.
    Với lệnh này, khoảng thời gian của bit này là 1,8 mili giây, đây là
    được thực hiện bằng cách giảm thời gian bus CEC ở mức cao. Chu kỳ bit này ngắn hơn
    hơn mức cho phép và người nhận sẽ phản hồi bằng Low Drive
    điều kiện.

Lệnh này bị bỏ qua đối với các bit 0 ở các vị trí bit từ 0 đến 3. Đây là
    bởi vì người nhận cũng tìm kiếm điều kiện Arbitration Lost trong
    bốn bit đầu tiên đó và không xác định được điều gì sẽ xảy ra nếu nó
    thấy bit 0 quá ngắn.

ZZ0000ZZ
    Làm cho khoảng thời gian bit này dài hơn thời gian hợp lệ. Vị trí bit không thể
    một chút Ack.  Nếu <op> chỉ định một opcode CEC cụ thể thì vị trí bit
    phải ít nhất là 18, nếu không thì opcode vẫn chưa được nhận.
    Thông thường chu kỳ của một bit dữ liệu là từ 2,05 đến 2,75 mili giây.
    Với lệnh này, khoảng thời gian của bit này là 2,9 mili giây, đây là
    được thực hiện bằng cách tăng thời gian bus CEC ở mức cao.

Mặc dù khoảng thời gian bit này dài hơn giá trị hợp lệ nhưng vẫn chưa xác định được điều gì
    một người nhận sẽ làm. Nó có thể chấp nhận nó, hoặc có thể hết thời gian và
    trở về trạng thái Idle. Thật không may, thông số kỹ thuật CEC không có thông tin gì về
    cái này.

Lệnh này bị bỏ qua đối với các bit 0 ở các vị trí bit từ 0 đến 3. Đây là
    bởi vì người nhận cũng tìm kiếm điều kiện Arbitration Lost trong
    bốn bit đầu tiên đó và không xác định được điều gì sẽ xảy ra nếu nó
    nhìn thấy bit 0 quá dài.

ZZ0000ZZ
    Làm cho khoảng thời gian bit bắt đầu này ngắn hơn mức cho phép. Thông thường thời kỳ của
    bit bắt đầu là từ 4,3 đến 4,7 mili giây. Với lệnh này
    khoảng thời gian của bit bắt đầu là 4,1 mili giây, điều này được thực hiện bằng cách giảm
    thời điểm bus CEC ở mức cao. Khoảng thời gian bit bắt đầu này nhỏ hơn
    được phép và máy thu sẽ trở về trạng thái Chờ khi phát hiện thấy điều này.

ZZ0000ZZ
    Làm cho khoảng thời gian bit bắt đầu này dài hơn thời gian hợp lệ. Thông thường thời kỳ của
    bit bắt đầu là từ 4,3 đến 4,7 mili giây. Với lệnh này
    khoảng thời gian của bit bắt đầu là 5 mili giây, điều này được thực hiện bằng cách tăng
    thời điểm bus CEC ở mức cao. Khoảng thời gian bit bắt đầu này dài hơn
    hợp lệ và máy thu sẽ trở về trạng thái Chờ khi phát hiện thấy điều này.

Mặc dù khoảng thời gian bit bắt đầu này dài hơn giá trị hợp lệ nhưng nó không được xác định
    người nhận sẽ làm gì. Nó có thể chấp nhận nó, hoặc có thể hết thời gian và
    trở về trạng thái Idle. Thật không may, thông số kỹ thuật CEC không có thông tin gì về
    cái này.

ZZ0000ZZ
    Chỉ cần ngừng truyền sau bit này.  Nếu <op> chỉ định một CEC cụ thể
    opcode thì vị trí bit phải ít nhất là 18, nếu không thì opcode
    vẫn chưa được nhận. Lệnh này có thể được sử dụng để kiểm tra xem người nhận
    phản ứng khi một tin nhắn đột ngột dừng lại. Nó sẽ hết thời gian và quay trở lại
    sang trạng thái rỗi.

ZZ0000ZZ
    Buộc điều kiện Low Drive ở vị trí bit này. Nếu <op> chỉ định một
    opcode CEC cụ thể thì vị trí bit ít nhất phải là 18, nếu không
    opcode vẫn chưa được nhận. Điều này có thể được sử dụng để kiểm tra xem
    máy thu xử lý các điều kiện Ổ đĩa thấp. Lưu ý rằng nếu điều này xảy ra một chút
    vị trí 0-3 người nhận có thể hiểu đây là Trọng tài bị mất
    điều kiện. Điều này phụ thuộc vào việc thực hiện.

Xung tùy chỉnh
--------------

ZZ0000ZZ
    Điều này xác định khoảng thời gian tính bằng micro giây mà xung tùy chỉnh kéo
    dòng CEC ở mức thấp. Mặc định là 1000 micro giây.

ZZ0000ZZ
    Điều này xác định khoảng thời gian tính bằng micro giây mà xung tùy chỉnh giữ
    Dòng CEC ở mức cao (trừ khi một bộ chuyển đổi CEC khác kéo nó xuống mức thấp trong thời gian đó).
    Mặc định là 1000 micro giây. Tổng thời gian của xung tùy chỉnh là
    ZZ0001ZZ.

ZZ0000ZZ
    Gửi bit tùy chỉnh thay vì bit dữ liệu thông thường. Vị trí bit không thể
    có một chút Ack.  Nếu <op> chỉ định một opcode CEC cụ thể thì bit
    vị trí phải ít nhất là 18, nếu không thì opcode vẫn chưa được nhận.

ZZ0000ZZ
    Gửi bit tùy chỉnh thay vì bit bắt đầu thông thường.

ZZ0000ZZ
    Truyền một xung tùy chỉnh ngay khi bus CEC không hoạt động.

Xung trục trặc
--------------

Điều này mô phỏng những gì xảy ra nếu tín hiệu trên đường CEC bị giả
xung. Thông thường, điều này xảy ra sau cạnh giảm hoặc tăng ở nơi có
là một dao động điện áp ngắn mà nếu phần cứng CEC không thực hiện được
mất ổn định, có thể được xem như một xung giả và có thể gây ra Lỗi Truyền động Thấp
tình trạng hoặc dữ liệu bị hỏng.

ZZ0000ZZ
    Điều này xác định khoảng thời gian tính bằng micro giây mà xung trục trặc kéo theo
    dòng CEC ở mức thấp. Mặc định là 1 micro giây. Phạm vi là 0-100
    micro giây. Nếu bằng 0 thì sẽ không có xung trục trặc nào được tạo ra.

ZZ0000ZZ
    Điều này xác định khoảng thời gian tính bằng micro giây mà xung trục trặc giữ cho
    Dòng CEC ở mức cao (trừ khi một bộ chuyển đổi CEC khác kéo nó xuống mức thấp trong thời gian đó).
    Mặc định là 1 micro giây. Phạm vi là 0-100 micro giây. Nếu 0 thì
    sẽ không có xung trục trặc nào được tạo ra. Tổng chu kỳ của xung trục trặc là
    ZZ0001ZZ.

ZZ0000ZZ
    Gửi xung trục trặc ngay sau khi cạnh rơi xuống.

ZZ0000ZZ
    Gửi xung trục trặc ngay sau cạnh tăng.