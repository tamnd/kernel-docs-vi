.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/staging/lzo.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

================================================================
Định dạng luồng LZO được hiểu bởi bộ giải nén LZO của Linux
===========================================================

Giới thiệu
============

Đây không phải là một đặc điểm kỹ thuật. Không có thông số kỹ thuật dường như được công bố rộng rãi
  cho định dạng luồng LZO. Tài liệu này mô tả định dạng đầu vào của LZO
  bộ giải nén như được triển khai trong nhân Linux. Chủ đề tập tin
  của phân tích này là lib/lzo/lzo1x_decompress_safe.c. Không có phân tích nào được thực hiện trên
  máy nén cũng như trên bất kỳ triển khai nào khác mặc dù có vẻ như vậy
  định dạng phù hợp với định dạng tiêu chuẩn. Mục đích của tài liệu này là để
  hiểu rõ hơn chức năng của mã để đề xuất cách khắc phục hiệu quả hơn
  cho các báo cáo lỗi trong tương lai.

Sự miêu tả
===========

Luồng bao gồm một loạt các hướng dẫn, toán hạng và dữ liệu. các
  hướng dẫn bao gồm một vài bit đại diện cho một opcode và các bit tạo thành
  các toán hạng cho lệnh, có kích thước và vị trí phụ thuộc vào
  opcode và số lượng chữ được sao chép theo lệnh trước đó. các
  toán hạng được sử dụng để chỉ ra:

- khoảng cách khi sao chép dữ liệu từ từ điển (bộ đệm đầu ra trước đây)
    - độ dài (số byte cần sao chép từ từ điển)
    - số lượng chữ cần sao chép, được giữ lại ở "trạng thái" thay đổi
      như một phần thông tin cho các hướng dẫn tiếp theo.

Tùy chọn tùy thuộc vào opcode và toán hạng, dữ liệu bổ sung có thể theo sau. Những cái này
  dữ liệu bổ sung có thể là phần bổ sung cho toán hạng (ví dụ: độ dài hoặc khoảng cách
  được mã hóa trên các giá trị lớn hơn) hoặc một chữ được sao chép vào bộ đệm đầu ra.

Byte đầu tiên của khối tuân theo một mã hóa khác với các byte khác, nó
  dường như chỉ được tối ưu hóa để sử dụng theo nghĩa đen vì chưa có từ điển
  trước byte đó.

Độ dài luôn được mã hóa trên một kích thước thay đổi bắt đầu bằng một số nhỏ
  số bit trong toán hạng. Nếu số bit không đủ để biểu diễn
  dài, có thể tăng dần lên tới 255 bằng cách tiêu thụ nhiều byte hơn với
  tốc độ tối đa là 255 trên mỗi byte bổ sung (do đó tỷ lệ nén không thể vượt quá
  khoảng 255:1). Mã hóa độ dài thay đổi bằng #bits luôn giống nhau::

độ dài = byte & ((1 << #bits) - 1)
       nếu (! chiều dài) {
               chiều dài = ((1 << #bits) - 1)
               độ dài += 255*(số byte 0)
               độ dài += byte đầu tiên khác 0
       }
       chiều dài += hằng số (thường là 2 hoặc 3)

Để tham khảo từ điển, khoảng cách có liên quan đến đầu ra
  con trỏ. Khoảng cách được mã hóa bằng cách sử dụng rất ít bit thuộc về một số
  phạm vi, dẫn đến nhiều hướng dẫn sao chép bằng cách sử dụng các bảng mã khác nhau.
  Một số mã hóa nhất định liên quan đến một byte bổ sung, các mã hóa khác liên quan đến hai byte bổ sung
  tạo thành số lượng 16-bit endian nhỏ (được đánh dấu LE16 bên dưới).

Sau bất kỳ lệnh nào ngoại trừ bản sao chữ lớn, 0, 1, 2 hoặc 3 chữ
  được sao chép trước khi bắt đầu lệnh tiếp theo. Số chữ đó
  được sao chép có thể thay đổi ý nghĩa và hành vi của lệnh tiếp theo. trong
  thực hành, chỉ cần một hướng dẫn để biết 0, nhỏ hơn 4 hay nhiều hơn
  chữ đã được sao chép. Đây là thông tin được lưu trữ trong biến <state>
  trong việc thực hiện này. Số chữ ngay lập tức được sao chép này là
  thường được mã hóa ở hai bit cuối cùng của lệnh nhưng cũng có thể
  được lấy từ hai bit cuối cùng của toán hạng phụ (ví dụ: khoảng cách).

Kết thúc luồng được khai báo khi nhìn thấy bản sao khối có khoảng cách 0. Chỉ có một
  lệnh có thể mã hóa khoảng cách này (0001HLLL), phải mất một toán hạng LE16
  cho khoảng cách, do đó cần 3 byte.

  .. important::

     In the code some length checks are missing because certain instructions
     are called under the assumption that a certain number of bytes follow
     because it has already been guaranteed before parsing the instructions.
     They just have to "refill" this credit if they consume extra bytes. This
     is an implementation design choice independent on the algorithm or
     encoding.

Phiên bản

0: Phiên bản gốc
1: LZO-RLE

Phiên bản 1 của LZO triển khai tiện ích mở rộng để mã hóa các số 0 bằng cách sử dụng run
mã hóa chiều dài Điều này cải thiện tốc độ cho dữ liệu có nhiều số 0, đây là một
trường hợp phổ biến cho zram. Điều này sửa đổi dòng bit theo cách tương thích ngược
(v1 có thể giải nén chính xác dữ liệu nén v0, nhưng v0 không thể đọc dữ liệu v1).

Để có khả năng tương thích tối đa, cả hai phiên bản đều có sẵn dưới các tên khác nhau
(lzo và lzo-rle). Sự khác biệt trong mã hóa được ghi chú trong tài liệu này với
ví dụ: chỉ phiên bản 1.

Chuỗi byte
==============

Mã hóa byte đầu tiên::

0..16 : làm theo mã hóa hướng dẫn thông thường, xem bên dưới. Nó có giá trị
                lưu ý rằng mã 16 sẽ đại diện cho một bản sao khối từ
                từ điển trống và nó sẽ luôn như vậy
                không hợp lệ ở nơi này.

17 : phiên bản dòng bit. Nếu byte đầu tiên là 17 và được nén
                độ dài luồng ít nhất là 5 byte (độ dài ngắn nhất có thể
                dòng bit được phiên bản), byte tiếp theo cung cấp phiên bản dòng bit
                (chỉ phiên bản 1).
                Ngược lại, phiên bản dòng bit là 0.

18..21 : sao chép 0..3 chữ
                trạng thái = (byte - 17) = 0..3 [ sao chép <trạng thái> bằng chữ]
                bỏ qua byte

22..255 : sao chép chuỗi ký tự
                độ dài = (byte - 17) = 4..238
                trạng thái = 4 [không sao chép thêm chữ]
                bỏ qua byte

Mã hóa hướng dẫn::

0 0 0 0 X X X X (0..15)
        Phụ thuộc vào số lượng chữ được sao chép bởi lệnh cuối cùng.
        Nếu lệnh cuối cùng không sao chép bất kỳ chữ nào (trạng thái == 0), lệnh này
        mã hóa sẽ là bản sao của 4 chữ trở lên và phải được giải thích
        như thế này:

0 0 0 0 L L L L (0..15): sao chép chuỗi ký tự dài
           chiều dài = 3 + (L ?: 15 + (zero_byte * 255) + non_zero_byte)
           state = 4 (không có chữ bổ sung nào được sao chép)

Nếu lệnh cuối cùng được sử dụng để sao chép từ 1 đến 3 chữ (được mã hóa bằng
        mã lệnh hoặc khoảng cách của lệnh), lệnh đó là bản sao của một
        Khối 2 byte từ từ điển trong khoảng cách 1kB. Nó có giá trị
        lưu ý rằng lệnh này tiết kiệm được rất ít vì nó sử dụng 2
        byte để mã hóa bản sao của 2 byte khác nhưng nó mã hóa số lượng
        theo nghĩa đen miễn phí. Nó phải được hiểu như thế này:

0 0 0 0 D D S S (0..15): sao chép 2 byte từ khoảng cách <= 1kB
           chiều dài = 2
           state = S (sao chép chữ S sau khối này)
         Luôn theo sau chính xác một byte: H H H H H H H
           khoảng cách = (H << 2) + D + 1

Nếu lệnh cuối cùng được sử dụng để sao chép 4 chữ trở lên (được phát hiện bởi
        trạng thái == 4), lệnh sẽ trở thành bản sao của khối 3 byte từ
        từ điển từ khoảng cách 2..3kB và phải được hiểu như sau:

0 0 0 0 D D S S (0..15): sao chép 3 byte từ khoảng cách 2..3 kB
           chiều dài = 3
           state = S (sao chép chữ S sau khối này)
         Luôn theo sau chính xác một byte: H H H H H H H
           khoảng cách = (H << 2) + D + 2049

0 0 0 1 H L L L (16..31)
           Bản sao của một khối trong khoảng cách 16..48kB (tốt nhất là nhỏ hơn 10B)
           độ dài = 2 + (L ?: 7 + (zero_byte * 255) + non_zero_byte)
        Luôn theo sau chính xác là một LE16 : D D D D D D D : D D D D D S S
           khoảng cách = 16384 + (H << 14) + D
           state = S (sao chép chữ S sau khối này)
           Kết thúc luồng nếu khoảng cách == 16384
           Chỉ trong phiên bản 1, để tránh sự mơ hồ với trường hợp RLE khi
           ((khoảng cách & 0x803f) == 0x803f) && (261 <= chiều dài <= 264),
           máy nén không được phát ra các bản sao khối trong đó khoảng cách và chiều dài
           đáp ứng những điều kiện này.

Chỉ trong phiên bản 1, lệnh này cũng được sử dụng để mã hóa một chuỗi
           số 0 nếu khoảng cách = 0xbfff, tức là H = 1 và các bit D đều là 1.
           Trong trường hợp này, nó được theo sau bởi byte thứ tư, X.
           chiều dài chạy = ((X << 3) | (0 0 0 0 0 L L L)) + 4

0 0 1 L L L L L (32..63)
           Bản sao của khối nhỏ trong khoảng cách 16kB (tốt nhất là nhỏ hơn 34B)
           độ dài = 2 + (L ?: 31 + (zero_byte * 255) + non_zero_byte)
        Luôn theo sau chính xác là một LE16 : D D D D D D D : D D D D D S S
           khoảng cách = D + 1
           state = S (sao chép chữ S sau khối này)

0 1 L D D D S S (64..127)
           Sao chép 3-4 byte từ khối trong khoảng cách 2kB
           state = S (sao chép chữ S sau khối này)
           chiều dài = 3 + L
         Luôn theo sau chính xác một byte: H H H H H H H
           khoảng cách = (H << 3) + D + 1

1 L L D D S S (128..255)
           Sao chép 5-8 byte từ khối trong khoảng cách 2kB
           state = S (sao chép chữ S sau khối này)
           chiều dài = 5 + L
         Luôn theo sau chính xác một byte: H H H H H H H
           khoảng cách = (H << 3) + D + 1

tác giả
=======

Tài liệu này được viết bởi Willy Tarreau <w@1wt.eu> vào ngày 19/07/2014 trong một cuộc họp
  phân tích mã giải nén có sẵn trong Linux 3.16-rc5 và được cập nhật
  bởi Dave Rodgman <dave.rodgman@arm.com> vào ngày 30/10/2018 để giới thiệu thời lượng dài
  mã hóa. Mã này phức tạp, có thể tài liệu này chứa
  những sai lầm hoặc một vài trường hợp góc đã bị bỏ qua. Trong mọi trường hợp, xin vui lòng
  báo cáo mọi nghi ngờ, sửa chữa hoặc đề xuất cập nhật cho (các) tác giả để
  tài liệu có thể được cập nhật.
