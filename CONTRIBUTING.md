# Hướng dẫn đóng góp

Tài liệu này mô tả quy trình làm việc và các quy ước áp dụng khi đóng
góp bản dịch cho dự án. Nội dung được viết ngắn gọn, đủ để người đóng
góp mới tham khảo một lần khi bắt đầu.

## Chuẩn bị

1. Chạy `scripts/translation-status.sh` để sinh bản
   `TRANSLATION_STATUS.md` mới nhất. Đây là nguồn thông tin duy nhất
   về các file đã hoặc chưa được dịch.
2. Chọn một file chưa có người nhận. Nếu không chắc chắn về trạng
   thái, có thể mở một issue ngắn để thông báo ý định dịch, nhằm
   tránh trùng lặp công việc giữa các người đóng góp.
3. Đọc file gốc một cách kỹ lưỡng. Tham khảo thêm bản dịch trong
   `zh_CN/`, `ja_JP/`, hoặc `it_IT/` của cùng file (nếu có) để nắm
   cách các ngôn ngữ khác xử lý thuật ngữ chuyên ngành và bố cục
   trình bày. Bước này thường bị bỏ qua nhưng có giá trị tham khảo
   cao.

## Quy tắc dịch

Một bản dịch đạt chất lượng cần cân bằng giữa hai yêu cầu: bám sát
nội dung bản gốc và đồng thời đọc tự nhiên trong tiếng Việt. Không
tồn tại công thức cho việc này; người dịch cần tự cân nhắc. Các quy
tắc cụ thể được liệt kê dưới đây.

### Đường dẫn và SPDX

- File gốc `Documentation/foo/bar.rst` được dịch thành
  `Documentation/translations/vi_VN/foo/bar.rst`. Cấu trúc thư mục
  tương ứng phải được giữ nguyên; không đổi tên file.
- Dòng đầu tiên của file dịch phải giữ nguyên chuỗi
  `SPDX-License-Identifier:` của file gốc. Đây là ràng buộc áp dụng
  cho toàn bộ kernel tree và không phải lựa chọn riêng của người
  dịch.

### Header của file dịch

Sau dòng SPDX, bổ sung khối header theo mẫu của các bản dịch ngôn
ngữ khác:

```rst
.. SPDX-License-Identifier: GPL-2.0

.. include:: ../disclaimer-vi.rst

:Original: Documentation/foo/bar.rst
:Translator: Full Name <email@domain>
```

File `disclaimer-vi.rst` sẽ được thêm vào repo khi bản dịch đầu tiên
được merge. Nếu bạn là người đóng góp bản dịch đầu tiên, vui lòng
copy file `zh_CN/disclaimer-zh_CN.rst`, dịch nội dung sang tiếng
Việt, và đính kèm trong pull request của mình.

### Code và thuật ngữ

- Tên hàm, tên biến, tên macro, tên command-line được giữ nguyên
  tiếng Anh trong mọi trường hợp. Việc Việt hóa một phần định danh
  (ví dụ `pid_của_tiến_trình`) không được chấp nhận do làm giảm
  tính rõ ràng và không hỗ trợ người đọc.
- Thuật ngữ tuân theo `GLOSSARY.md` khi file này đã tồn tại. Trong
  trường hợp thuật ngữ chưa được chuẩn hóa, người dịch chọn một
  phương án và ghi chú lựa chọn trong mô tả pull request, nhằm duy
  trì tính nhất quán cho các lần dịch sau.
- Các từ tiếng Việt đã phổ thông trong tài liệu kỹ thuật (hệ thống,
  tệp, thư mục, lỗi, quyền) được sử dụng bình thường. Khi giới
  thiệu thuật ngữ mới hoặc giữ nguyên dạng tiếng Anh, bổ sung chú
  giải trong ngoặc ở lần xuất hiện đầu tiên, ví dụ: *bộ lập lịch
  (scheduler)*.

## Commit

Commit message tuân theo format của kernel: prefix đường dẫn, viết
bằng tiếng Anh, ngắn gọn.

```
Documentation/translations/vi_VN/admin-guide: translate README.rst

Short description in 1 to 2 paragraphs if needed: what was translated,
any tricky terminology decisions, and the upstream SHA the translation
was done against.

Signed-off-by: Full Name <email@domain>
```

Mỗi commit tương ứng với một thay đổi có tính logic độc lập. Không
gộp nhiều file không liên quan vào cùng một commit. Commit thuộc
loại "sync upstream" (do script sinh) được tách riêng, không trộn
với commit dịch thuật do có quy trình review khác nhau.

## DCO thay cho CLA

Mỗi commit cần có dòng `Signed-off-by:`, được sinh tự động khi sử
dụng cờ `-s` của lệnh `git commit`. Dòng này xác nhận người đóng
góp đồng ý với các điều khoản của
[Developer Certificate of Origin](https://developercertificate.org/),
tóm tắt là: đóng góp do người đóng góp tạo ra và có quyền cấp phép
theo license của dự án, hoặc dựa trên tác phẩm đã có dưới license
tương thích.

Dự án không yêu cầu CLA. Linux kernel cũng không sử dụng CLA, và
không có lý do để áp dụng quy trình khắt khe hơn upstream trong
khi toàn bộ nội dung dịch thuật có nguồn gốc từ kernel.

## Pull request

1. Rebase branch lên `main` mới nhất trước khi mở PR.
2. Chạy lại `scripts/translation-status.sh` và commit file
   `TRANSLATION_STATUS.md` nếu có thay đổi.
3. Mở pull request. Title và description PR được viết bằng tiếng
   Anh, bao gồm thông tin: file nào được dịch, upstream SHA tại
   thời điểm dịch (tham chiếu file `UPSTREAM`), và các quyết định
   về thuật ngữ đáng lưu ý.

Lý do metadata của PR được viết bằng tiếng Anh trong một dự án dịch
tiếng Việt:

- Hỗ trợ reviewer quốc tế khi cần, đặc biệt trong trường hợp dự án
  gửi patch ngược lên LKML trong tương lai.
- Duy trì tính nhất quán với commit message, vốn đã theo chuẩn
  tiếng Anh của kernel.
- Nội dung dịch thuật thuộc về file `.rst`, không thuộc về metadata
  của PR.

Comment trên PR và issue cũng được viết bằng tiếng Anh theo cùng
nguyên tắc.

## Sau khi PR được merge

- Người đóng góp lần đầu bổ sung thông tin cá nhân vào file
  `TRANSLATORS`.
- Upstream có thể sửa đổi file gốc trong những lần sync tiếp theo,
  dẫn đến bản dịch có thể bị lệch so với phiên bản hiện tại. Trong
  trường hợp đó, repo sẽ gắn nhãn issue để đánh dấu các file cần
  review lại. Việc cập nhật lại bản dịch là không bắt buộc, tuy
  nhiên được khuyến khích nếu điều kiện thời gian cho phép.

## Các nguyên tắc loại trừ

Dự án không chấp nhận các thực hành sau:

- Sử dụng machine translation (Google Translate, DeepL, LLM) để
  sinh bản dịch rồi chỉnh sửa tối thiểu. Reviewer có thể nhận
  biết, và chi phí chỉnh sửa thường cao hơn việc dịch thủ công từ
  đầu. Trong trường hợp thời gian không cho phép, nên chọn file
  ngắn hơn.
- Thay đổi cấu trúc bản gốc: thêm ví dụ riêng, lược bỏ các phần
  không quan trọng theo đánh giá cá nhân, hoặc chèn ý kiến cá
  nhân. Bản dịch cần bám sát bản gốc cả về nội dung lẫn thứ tự các
  đoạn. Nếu phát hiện lỗi trong bản gốc, phương án đúng là gửi
  patch sửa ngược lên upstream trước khi tiến hành dịch.
- Dịch từ một kernel version cũ: repo chỉ theo dõi master HEAD của
  upstream. Dịch dựa trên bản cũ sẽ gây conflict không cần thiết
  khi sync.

## Liên hệ

Câu hỏi và thảo luận được đưa qua issue hoặc comment trong pull
request. Nội dung trao đổi được viết bằng tiếng Anh. Phần duy nhất
trong repo bắt buộc viết bằng tiếng Việt là nội dung bên trong các
file dịch dưới thư mục `Documentation/translations/vi_VN/`.
