# Hướng dẫn đóng góp

Cảm ơn bạn đã ghé qua. Dưới đây là workflow của repo, viết ngắn để
người mới đọc một lần là đủ, không phải ghi nhớ.

## Trước khi bắt đầu

1. Chạy `scripts/translation-status.sh` để có `TRANSLATION_STATUS.md`
   mới nhất. Đây là bản đồ duy nhất cho biết file nào đã có ai dịch.
2. Pick một file chưa có ai nhận. Nếu không chắc, mở issue ngắn thông
   báo "sẽ dịch X", tránh dẫm chân nhau.
3. Đọc kỹ file gốc. Đọc thêm bản `zh_CN/`, `ja_JP/`, hoặc `it_IT/` của
   cùng file đó nếu có, để hình dung cách ngôn ngữ khác xử lý thuật
   ngữ và bố cục. Bước này hay bị bỏ qua nhưng rất đáng.

## Quy tắc dịch

Một bản dịch tốt nằm giữa hai thái cực: quá sát nghĩa thì đọc không
giống tiếng Việt, quá thoáng thì mất nội dung gốc. Không có công thức,
phải tự cảm. Vài gợi ý thực tế:

### Path và SPDX

- Dịch `Documentation/foo/bar.rst` thành
  `Documentation/translations/vi_VN/foo/bar.rst`. Giữ nguyên cấu trúc
  thư mục. Đừng đổi tên file.
- Dòng đầu của file dịch: giữ nguyên `SPDX-License-Identifier:` y hệt
  file gốc. Đây là ràng buộc kernel-wide, không phải lựa chọn cá nhân.

### Header của bản dịch

Sau dòng SPDX, thêm khối nhỏ theo mẫu các ngôn ngữ khác:

```rst
.. SPDX-License-Identifier: GPL-2.0

.. include:: ../disclaimer-vi.rst

:Original: Documentation/foo/bar.rst
:Translator: Full Name <email@domain>
```

File `disclaimer-vi.rst` sẽ được thêm vào khi bản dịch đầu tiên được
merge. Nếu bạn là người dịch đầu tiên, copy luôn từ
`zh_CN/disclaimer-zh_CN.rst` rồi dịch lời, thêm vào PR của mình.

### Code và thuật ngữ

- Tên hàm, tên biến, tên macro, tên command: giữ nguyên tiếng Anh. Đừng
  dịch. Kể cả "Việt hóa một phần" kiểu `pid_của_tiến_trình` cũng đừng
  làm. Chỉ rối, không giúp ai.
- Thuật ngữ: theo `GLOSSARY.md` nếu đã có. Chưa có thì pick một cách,
  ghi lại lựa chọn trong mô tả PR, lần sau theo đó cho nhất quán.
- Từ tiếng Việt đã phổ biến trong tài liệu kỹ thuật (hệ thống, tệp,
  thư mục, lỗi, quyền) dùng bình thường. Khi dùng thuật ngữ mới hoặc
  giữ nguyên tiếng Anh, mở ngoặc bản gốc ở lần xuất hiện đầu. Ví dụ:
  *bộ lập lịch (scheduler)* xuất hiện lần đầu, lần sau chỉ cần *bộ lập
  lịch*.

## Commit

Theo format của kernel: tiền tố path, tiếng Anh, ngắn gọn.

```
Documentation/translations/vi_VN/admin-guide: translate README.rst

Short description in 1 or 2 paragraphs if needed: what you translated,
any tricky terminology decisions, the upstream SHA you translated
against.

Signed-off-by: Full Name <email@domain>
```

Một commit gộp một thay đổi hợp lý. Đừng nhét nhiều file không liên
quan vào cùng commit. Đừng trộn commit "sync upstream" với commit
dịch thuật (hai loại công việc khác nhau, review cũng khác nhau).

## DCO thay cho CLA

Mỗi commit phải có dòng `Signed-off-by:`. Tạo tự động bằng `git commit
-s`. Dòng này xác nhận bạn đồng ý với
[Developer Certificate of Origin](https://developercertificate.org/),
đại ý: đóng góp là của bạn và bạn có quyền cấp phép nó theo license
của dự án (hoặc dựa trên tác phẩm đã có dưới license tương thích).

Repo không dùng CLA. Kernel cũng không dùng CLA, và không có lý do
nào để khắt khe hơn kernel trong khi toàn bộ nội dung dịch là từ
kernel.

## Pull request

1. Rebase lên `main` mới nhất.
2. Chạy lại `scripts/translation-status.sh` trước khi push, để
   `TRANSLATION_STATUS.md` có phần trăm cập nhật.
3. Mở PR. Title và mô tả PR viết bằng tiếng Anh. Trong mô tả nêu rõ:
   dịch file nào, upstream SHA tại thời điểm dịch (đọc từ `UPSTREAM`),
   những quyết định thuật ngữ đáng chú ý.

Vì sao metadata của PR lại tiếng Anh khi đây là dự án dịch tiếng Việt?
Ba lý do thực tế:

- Dễ cho reviewer quốc tế ghé qua, nhất là nếu sau này gửi patch ngược
  lên LKML.
- Đồng bộ với commit message (vốn đã tiếng Anh theo format kernel).
- Phần dịch thực sự nằm trong file `.rst`, không phải trong metadata
  của PR. Title PR không phải là nội dung dịch.

Comment trong PR và issue cũng tiếng Anh, cùng lý do.

## Sau khi PR được merge

- Nếu đây là lần đầu bạn đóng góp, thêm tên mình vào `TRANSLATORS`.
- Upstream có thể sửa file gốc trong những lần sync sau. Khi đó file
  dịch có thể lệch. Repo sẽ gắn nhãn issue để rà lại. Không bắt buộc
  phải theo, nhưng nếu còn thời gian thì quay lại xem giúp.

## Vài thứ không nên làm

- Đừng chạy machine translation (Google Translate, DeepL, LLM) rồi sửa
  chút đính vào PR. Reviewer nhận ra, và sửa bản máy dịch thường tốn
  thời gian hơn tự dịch tay. Nếu không đủ thời gian cho một file, pick
  file khác ngắn hơn.
- Đừng đổi cấu trúc bản gốc. Không thêm ví dụ riêng, không cắt phần
  thấy không quan trọng, không chêm ý kiến cá nhân. Bản dịch bám sát
  bản gốc cả về ý lẫn thứ tự đoạn. Nếu thấy bản gốc sai, gửi patch
  sửa bản gốc trước (việc của upstream), rồi mới dịch.
- Đừng lấy file từ một kernel version cũ về dịch. Repo chỉ theo master
  HEAD. Dịch bản cũ thì lúc sync sẽ sinh conflict không đáng.

## Câu hỏi

Mở issue hoặc comment trong PR hiện có. Viết tiếng Anh. Phần duy nhất
trong repo bắt buộc tiếng Việt là nội dung bên trong các file dịch
dưới `Documentation/translations/vi_VN/`.
