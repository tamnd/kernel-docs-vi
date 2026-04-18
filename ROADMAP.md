# Roadmap

Ghi chép về hướng đi của kho này. Đây không phải kế hoạch cứng, và cũng
không có deadline. Cái nào làm xong thì đánh dấu, cái nào đổi ý giữa đường
thì sửa lại hoặc xóa đi.

## Đã xong

- Import `Documentation/` từ torvalds/linux master, commit `8541d8f`.
- Bốn script trong `scripts/`: init, sync, diff, translation-status.
  Dùng blobless + shallow + sparse clone, không phải tải cả kernel về.
- README, CONTRIBUTING, TRANSLATORS, stub `index.rst` cho `vi_VN/`.
- `TRANSLATION_STATUS.md` sinh tự động, 0% tại thời điểm init.
- Repo public tại https://github.com/tamnd/kernel-docs-vi.

## Giai đoạn 1: phần nền

Trước khi ngồi dịch một đống file, cần chuẩn bị vài thứ. Nếu không thì
sau này phải sửa đi sửa lại.

### disclaimer-vi.rst

Các bản dịch khác (zh_CN, ja_JP, it_IT) đều có file disclaimer nhỏ gắn
đầu mỗi trang dịch, đại loại nói rằng đây là bản dịch và nếu có khác biệt
với bản gốc thì bản gốc thắng. Chép theo mẫu của `zh_CN/disclaimer-zh_CN.rst`
là nhanh nhất.

### GLOSSARY.md

Cần thống nhất thuật ngữ từ sớm. Có ba nhóm cần phân loại:

1. Từ giữ nguyên tiếng Anh: kernel, userspace, process, thread, syscall,
   driver, module, scheduler, interrupt, RCU, spinlock, memory barrier,
   bootloader, BIOS. Tài liệu kỹ thuật tiếng Việt vốn đã quen dùng nguyên
   bản, dịch ra thường nghe lạ.
2. Từ dịch hẳn: system thành hệ thống, file thành tệp, directory thành
   thư mục, permission thành quyền, error thành lỗi. Những từ này dịch
   không gây hiểu lầm.
3. Từ nhập nhằng, phải chốt một lần rồi theo: lock (khóa hay lock), queue
   (hàng đợi hay queue), buffer (bộ đệm hay buffer), pipe (ống hay pipe).
   Loại này chọn một rồi cả kho dùng nhất quán là được, không có câu trả
   lời đúng tuyệt đối.

Format đơn giản, bảng ba cột: English, Tiếng Việt, Ghi chú. Thêm từ mới
khi gặp, không phải bịa ra một lần cho xong.

### Tệp dịch đầu tiên: process/howto.rst

Đây là cửa vào của kernel cho dev mới. Nếu bản tiếng Việt không có file
này thì coi như chưa có gì. Nó cũng dài nhưng không quá nặng kỹ thuật,
phù hợp để rút kinh nghiệm về format, cách xử lý link tham chiếu, cách
để code block nguyên bản, chỗ nào giữ tiếng Anh chỗ nào dịch.

### admin-guide/README.rst và admin-guide/index.rst

Trang đích cho người dùng kernel, không phải dev. Ngắn, thiết thực. Dịch
song song với `process/howto.rst` để phục vụ cả hai nhóm độc giả ngay từ
ngày đầu.

## Giai đoạn 2: mở rộng coverage

Thứ tự ưu tiên theo độ hữu ích với người đọc Việt Nam:

1. `process/`. Coding style, submitting patches, email client config,
   maintainer handbook. Đây là thứ dev Việt hay tra cứu khi muốn đóng
   góp upstream.
2. `admin-guide/` các trang phổ biến nhất: kernel-parameters, bootloaders,
   module signing, sysctl, các trang hướng dẫn xử lý sự cố.
3. `core-api/`. Memory management, locking, concurrency primitives. Kiến
   thức nền mà cả dev userspace cũng nên biết.
4. `dev-tools/`. kgdb, kasan, ftrace, perf. Thực dụng, nhiều người cần.
5. `filesystems/`, `networking/`, `scheduler/`. Theo nhu cầu thực tế của
   người đóng góp, không theo thứ tự bảng chữ cái.

Không đặt mục tiêu số file mỗi tháng. Mỗi tháng thêm được vài tệp tử tế
là tốt rồi. Dịch ẩu để tăng số lượng là phản tác dụng, vì ai đọc phải
bản ẩu sẽ mất niềm tin vào toàn bộ kho.

## Giai đoạn 3: tự động hóa

Khi số file dịch đã kha khá, vài chục trở lên, bắt đầu cần mấy thứ sau.

### Theo dõi drift với upstream

Khi upstream sửa `process/howto.rst` sau khi bản tiếng Việt đã được merge,
bản dịch có thể lệch. Cần một cơ chế nhận biết: với mỗi file dịch, upstream
SHA tại thời điểm dịch là gì, và hiện tại đã cách bao xa.

Cách đơn giản là thêm metadata ở đầu mỗi file dịch:

```
:Upstream-at: 8541d8f725c6
```

Script so sánh SHA này với `UPSTREAM` hiện tại, liệt kê file nào cần review
lại. Không cần chính xác tuyệt đối, chỉ cần cảnh báo đủ sớm là được.

### CI

GitHub Actions là đủ, không cần Jenkins hay gì phức tạp hơn.

- Chạy `scripts/translation-status.sh` mỗi lần merge PR hoặc sync upstream,
  commit lại `TRANSLATION_STATUS.md` nếu đổi.
- Lint RST cơ bản: docutils không được báo lỗi. Nếu muốn kỹ hơn thì dùng
  sphinx-build để xác nhận build ra HTML.
- Kiểm tra SPDX header còn nguyên ở đầu mỗi file dịch. Đây là ràng buộc
  từ kernel, dễ bị quên khi copy-paste.
- Kiểm tra file dịch có dòng `:Original:` trỏ về file gốc.

### Build Sphinx

Chạy thử `make htmldocs` với cấu hình giới hạn cho `vi_VN/` để xác nhận
toctree của mình build được. Nếu chỉ có `index.rst` thì chưa có gì để thử,
nhưng khi đã có khoảng chục trang thì làm sớm để tránh lỗi dồn.

## Giai đoạn 4: cộng đồng

Phần khó đoán nhất. Một người dịch một mình thì rất chậm, và kiệt sức.
Cần thêm người. Cách tiếp cận thực tế:

- Viết một bài giới thiệu dự án: bối cảnh, mục tiêu, cách đóng góp. Đăng
  lên một vài kênh dev Việt: Daynhauhoc, nhóm Facebook chuyên về Linux
  và open source, diễn đàn của các công ty làm kernel/embedded.
- Trong `TRANSLATION_STATUS.md` hoặc một file riêng, đánh dấu các file
  ngắn và dễ để làm `good first translation`. Đây là cách thông thường
  để đón người mới.
- Review pull request nhanh, trong vòng vài ngày. Không để PR nằm đó hai
  ba tuần, người đóng góp sẽ mất hứng và không quay lại nữa.
- Chấp nhận PR ngắn. Một file dịch là một PR, không ép gom nhiều file.
  Gom nhiều file làm PR khó review và làm nản người mới.

Không kỳ vọng quá cao. Dịch kernel docs là việc không có tiền, không có
huy hiệu, không có deadline ép. Chỉ những người thực sự thích mảng này
mới gắn bó, và số đó ở Việt Nam không nhiều.

## Những thứ cố tình không làm

- Không dịch comment và docstring trong mã nguồn. Mã nguồn là upstream,
  không phải sân chơi của bản dịch.
- Không tạo ra bản dịch biến thể: không thêm ví dụ riêng, không đổi cấu
  trúc, không chêm ý kiến cá nhân. Bản dịch bám sát nguyên bản cả về ý
  lẫn cấu trúc đoạn. Nếu bản gốc có chỗ khó hiểu, sửa bản gốc trước
  (gửi patch upstream) rồi mới dịch.
- Không duy trì song song bản dịch cho nhiều phiên bản kernel. Theo master
  HEAD, rebase theo từng đợt sync. Ai cần bản cũ tự dùng `git checkout`.
- Không dùng máy dịch hàng loạt rồi sửa. Có thể dùng máy dịch để tham
  khảo thuật ngữ hoặc câu khó, nhưng không paste thẳng bản máy dịch vào
  PR. Người review sẽ nhận ra, và nó không tiết kiệm thời gian thật sự
  nếu tính cả công sửa.
- Không yêu cầu CLA. DCO đủ, kernel cũng chỉ dùng DCO.

## Mục tiêu dài hạn

Nếu dự án sống được qua một vài năm, kết quả có thể ra sao:

- Khoảng 20 đến 50 tệp cốt lõi được dịch tử tế, tập trung ở `process/`,
  `admin-guide/`, và `core-api/`.
- Một nhóm nhỏ đều đặn đóng góp, không phụ thuộc vào một người duy nhất.
- Glossary ổn định, được tham chiếu cả ở các dự án dịch tài liệu kỹ thuật
  khác (không chỉ kernel).
- Xem xét gửi patch lên LKML để đưa `Documentation/translations/vi_VN/`
  vào cây chính thức. Việc này cần đủ nội dung để chứng minh dự án còn
  sống, không phải nộp một lần rồi bỏ hoang.

Gửi upstream không phải mục tiêu bắt buộc. Có một kho public, sạch, đều
được cập nhật theo upstream cũng là đủ hữu ích rồi.
