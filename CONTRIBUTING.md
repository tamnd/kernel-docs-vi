# Hướng dẫn đóng góp

Cảm ơn bạn đã quan tâm đến bản dịch tiếng Việt của tài liệu Linux kernel.
Tài liệu này mô tả quy trình dịch và những quy ước chúng ta tuân theo để
giữ phong cách nhất quán với upstream.

## Trước khi bắt đầu

1. Chạy `scripts/translation-status.sh` để sinh `TRANSLATION_STATUS.md`.
2. Chọn một tệp chưa có ai nhận. Nếu không chắc, mở issue để thông báo.
3. Đọc kỹ tệp gốc **và** các bản dịch `zh_CN/` / `ja_JP/` / `it_IT/` của cùng
   tệp (nếu có) để hình dung cách các ngôn ngữ khác xử lý thuật ngữ.

## Quy ước dịch

- **Đường dẫn**: dịch `Documentation/foo/bar.rst` →
  `Documentation/translations/vi_VN/foo/bar.rst` (cùng cấu trúc thư mục).
- **SPDX header**: giữ nguyên dòng `SPDX-License-Identifier:` của tệp gốc ở
  dòng đầu tiên.
- **Dòng tham chiếu bản gốc**: sau SPDX, thêm khối chuẩn mà các bản dịch khác
  dùng, ví dụ:

  ```rst
  .. SPDX-License-Identifier: GPL-2.0

  .. include:: ../disclaimer-vi.rst

  :Original: Documentation/foo/bar.rst
  :Translator: Tên Bạn <email@domain>
  ```

  File `disclaimer-vi.rst` sẽ được bổ sung khi bản dịch đầu tiên được gộp vào.
- **Mã nguồn / lệnh / tên hàm / cấu trúc**: giữ nguyên bằng tiếng Anh.
- **Thuật ngữ**: ưu tiên thuật ngữ đã dùng trong cộng đồng Linux Việt Nam.
  Khi đưa ra thuật ngữ mới, đặt bản tiếng Anh trong ngoặc ở lần xuất hiện
  đầu tiên, ví dụ: *bộ lập lịch (scheduler)*.

## Commit message

Theo đúng format của kernel — ngắn, có tiền tố đường dẫn:

```
Documentation/translations/vi_VN/admin-guide: translate README.rst

Mô tả ngắn 1–2 đoạn nếu cần: bạn dịch gì, lý do, những điểm khó về thuật ngữ.
Nếu dựa trên upstream commit cụ thể, nhắc tới trong phần thân.

Signed-off-by: Tên Bạn <email@domain>
```

### Developer Certificate of Origin (DCO)

Mỗi commit phải có dòng `Signed-off-by:` — tạo bằng `git commit -s`. Chữ ký
này xác nhận bạn đồng ý với các điều khoản [DCO](https://developercertificate.org/):

> Bằng việc ký tên vào đóng góp, tôi xác nhận rằng: (a) đóng góp là do tôi
> tạo ra và tôi có quyền cấp phép nó theo giấy phép mã nguồn mở của dự án;
> hoặc (b) đóng góp dựa trên tác phẩm đã có dưới giấy phép tương thích.

Chúng ta **không** dùng CLA. DCO là đủ.

## Quy tắc commit

- Một commit = một thay đổi hợp lý. Đừng gộp nhiều tệp không liên quan.
- Đừng trộn cập nhật đồng bộ upstream (`scripts/sync-upstream.sh`) với commit
  dịch thuật.
- Nếu tệp gốc upstream đã đổi và bản dịch cần cập nhật, hãy tách thành commit
  riêng và nhắc tới upstream SHA trong thân commit.

## Gửi pull request

1. Rebase nhánh lên `main` mới nhất.
2. `scripts/translation-status.sh` — đảm bảo con số coverage đã cập nhật.
3. Mở PR. Trong mô tả nêu: tệp nào được dịch, upstream SHA tại thời điểm
   dịch (đọc từ tệp `UPSTREAM`), và bất kỳ quyết định thuật ngữ nào đáng
   chú ý.

## Sau khi PR được gộp

- Thêm bạn vào tệp [`TRANSLATORS`](TRANSLATORS) nếu đây là lần đầu đóng góp.
- Theo dõi các commit đồng bộ sau đó — nếu tệp gốc của bạn thay đổi, chúng
  tôi sẽ gắn nhãn trong issue để bạn xem xét cập nhật bản dịch.
