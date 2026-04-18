.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/userspace-api/mseal.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=======================
Giới thiệu về mseal
=======================

:Tác giả: Jeff Xu <jeffxu@chromium.org>

CPU hiện đại hỗ trợ các quyền bộ nhớ như bit RW và NX. Bộ nhớ
tính năng cấp phép cải thiện quan điểm bảo mật đối với các lỗi hỏng bộ nhớ, tức là.
kẻ tấn công không thể chỉ ghi vào bộ nhớ tùy ý và trỏ mã vào đó,
bộ nhớ phải được đánh dấu bằng bit X, nếu không sẽ xảy ra ngoại lệ.

Việc niêm phong bộ nhớ còn bảo vệ bản thân ánh xạ khỏi
sửa đổi. Điều này rất hữu ích để giảm thiểu các vấn đề hỏng bộ nhớ khi một
con trỏ bị hỏng được chuyển đến hệ thống quản lý bộ nhớ. Ví dụ,
kẻ tấn công nguyên thủy như vậy có thể phá vỡ sự đảm bảo tính toàn vẹn của luồng điều khiển
vì bộ nhớ chỉ đọc được cho là đáng tin cậy có thể trở thành bộ nhớ có thể ghi
hoặc các trang .text có thể được ánh xạ lại. Việc niêm phong bộ nhớ có thể được thực hiện tự động
được áp dụng bởi trình tải thời gian chạy để đóng dấu các trang .text và .rodata và
Ngoài ra, các ứng dụng có thể niêm phong dữ liệu quan trọng về bảo mật trong thời gian chạy.

Một tính năng tương tự đã tồn tại trong kernel XNU với
Cờ VM_FLAGS_PERMANENT [1] và trên OpenBSD với tòa nhà có thể thay đổi được [2].

SYSCALL
=======
chữ ký tòa nhà mseal
-----------------------
ZZ0000ZZ

ZZ0000ZZ/ZZ0001ZZ: dải địa chỉ bộ nhớ ảo.
      Dải địa chỉ do ZZ0002ZZ/ZZ0003ZZ đặt phải đáp ứng:
         - Địa chỉ bắt đầu phải nằm trong VMA được phân bổ.
         - Địa chỉ bắt đầu phải được căn chỉnh theo trang.
         - Địa chỉ cuối (ZZ0004ZZ + ZZ0005ZZ) phải nằm trong VMA được phân bổ.
         - không có khoảng cách (bộ nhớ chưa được phân bổ) giữa địa chỉ bắt đầu và kết thúc.

ZZ0000ZZ sẽ được phân trang được căn chỉnh hoàn toàn bởi kernel.

ZZ0000ZZ: dành riêng cho việc sử dụng sau này.

ZZ0007ZZ:
      - ZZ0008ZZ: Thành công.
      -ZZ0009ZZ:
         * Đầu vào không hợp lệ ZZ0000ZZ.
         * Địa chỉ bắt đầu (ZZ0001ZZ) không được căn chỉnh theo trang.
         * Tràn dải địa chỉ (ZZ0002ZZ + ZZ0003ZZ).
      -ZZ0010ZZ:
         * Địa chỉ bắt đầu (ZZ0004ZZ) không được phân bổ.
         * Địa chỉ cuối (ZZ0005ZZ + ZZ0006ZZ) không được phân bổ.
         * Khoảng cách (bộ nhớ chưa được phân bổ) giữa địa chỉ bắt đầu và kết thúc.
      -ZZ0011ZZ:
         * Việc niêm phong chỉ được hỗ trợ trên CPU 64 bit, 32 bit không được hỗ trợ.

ZZ0000ZZ:
      - Đối với các trường hợp lỗi trên, người dùng có thể mong đợi phạm vi bộ nhớ cho trước là
        chưa sửa đổi, tức là không cập nhật một phần.
      - Có thể có các lỗi/trường hợp nội bộ khác không được liệt kê ở đây, ví dụ:
        lỗi trong quá trình hợp nhất/tách VMA hoặc quá trình đạt mức tối đa
        số lượng VMA được hỗ trợ. Trong những trường hợp đó, cập nhật một phần cho
        phạm vi bộ nhớ có thể xảy ra. Tuy nhiên, những trường hợp đó nên rất hiếm.

ZZ0000ZZ:
      mseal chỉ hoạt động trên CPU 64 bit chứ không phải CPU 32 bit.

ZZ0000ZZ:
      người dùng có thể gọi mseal nhiều lần. mseal trên bộ nhớ đã được niêm phong
      là không có hành động (không phải lỗi).

ZZ0000ZZ
      Một khi bản đồ đã được niêm phong, nó không thể được niêm phong. Hạt nhân không bao giờ nên
      có munseal, điều này phù hợp với tính năng niêm phong khác, ví dụ:
      F_SEAL_SEAL cho tập tin.

Tòa nhà mm bị chặn để lập bản đồ kín
-------------------------------------
Điều quan trọng cần lưu ý: **khi bản đồ được niêm phong, nó sẽ
   lưu lại trong bộ nhớ của tiến trình cho đến khi quá trình kết thúc**.

Ví dụ::

*ptr = mmap(0, 4096, PROT_READ, MAP_ANONYMOUS | MAP_PRIVATE, 0, 0);
         rc = mseal(ptr, 4096, 0);
         /* munmap sẽ thất bại */
         rc = munmap(ptr, 4096);
         khẳng định (rc < 0);

Tòa nhà mm bị chặn:
      - bản đồ
      - mmap
      - mremap
      - mprotect và pkey_mprotect
      - một số hành vi phá hoại điên cuồng: MADV_DONTNEED, MADV_FREE,
        MADV_DONTNEED_LOCKED, MADV_FREE, MADV_DONTFORK, MADV_WIPEONFORK

Nhóm syscall đầu tiên cần chặn là munmap, mremap, mmap. Họ có thể
   hoặc để lại một khoảng trống trong không gian địa chỉ, do đó cho phép
   thay thế bằng ánh xạ mới bằng tập thuộc tính mới hoặc có thể
   ghi đè lên ánh xạ hiện có bằng một ánh xạ khác.

mprotect và pkey_mprotect bị chặn vì chúng thay đổi
   các bit bảo vệ (RWX) của ánh xạ.

Một số hành vi phá hoại điên rồ nhất định, cụ thể là MADV_DONTNEED,
   MADV_FREE, MADV_DONTNEED_LOCKED và MADV_WIPEONFORK, có thể giới thiệu
   rủi ro khi áp dụng vào bộ nhớ ẩn danh bởi các luồng thiếu ghi
   quyền. Do đó, các hoạt động này bị cấm theo các điều kiện như vậy.
   điều kiện. Những hành vi nói trên có khả năng làm thay đổi
   nội dung khu vực bằng cách loại bỏ các trang, thực hiện hiệu quả memset(0)
   hoạt động trên bộ nhớ ẩn danh.

Kernel sẽ trả về -EPERM cho các cuộc gọi chung bị chặn.

Khi cuộc gọi tòa nhà bị chặn trả về -EPERM do bị niêm phong, các vùng bộ nhớ có thể
   hoặc có thể không thay đổi, tùy thuộc vào tòa nhà bị chặn:

- munmap: munmap mang tính nguyên tử. Nếu một trong các VMA trong phạm vi nhất định là
        kín, không có VMA nào được cập nhật.
      - mprotect, pkey_mprotect, madvise: có thể xảy ra cập nhật một phần, ví dụ:
        khi mprotect qua nhiều VMA, mprotect có thể cập nhật phần đầu
        VMA trước khi đạt VMA đã được niêm phong và trả về -EPERM.
      - mmap và mremap: hành vi không xác định.

Trường hợp sử dụng
==================
- glibc:
  Trình liên kết động, trong khi tải các tệp thực thi ELF, có thể áp dụng việc niêm phong cho
  các phân đoạn ánh xạ.

- Trình duyệt Chrome: bảo vệ một số cấu trúc dữ liệu nhạy cảm về bảo mật.

- Sơ đồ hệ thống:
  Ánh xạ hệ thống được tạo bởi kernel và bao gồm vdso, vvar,
  vvar_vclock, vectơ (chế độ tương thích cánh tay), sigpage (chế độ tương thích cánh tay), uprobes.

Các ánh xạ hệ thống đó chỉ ở dạng chỉ đọc hoặc chỉ thực thi, việc niêm phong bộ nhớ có thể
  bảo vệ chúng khỏi việc thay đổi thành có thể ghi hoặc không được ánh xạ/ánh xạ lại thành khác
  thuộc tính. Điều này rất hữu ích để giảm thiểu các vấn đề hỏng bộ nhớ khi một
  con trỏ bị hỏng được chuyển đến hệ thống quản lý bộ nhớ.

Nếu được hỗ trợ bởi kiến trúc (CONFIG_ARCH_SUPPORTS_MSEAL_SYSTEM_MAPPINGS),
  CONFIG_MSEAL_SYSTEM_MAPPINGS niêm phong tất cả các ánh xạ hệ thống này
  kiến trúc.

Các kiến trúc sau hiện hỗ trợ tính năng này: x86-64, arm64,
  loongarch và s390.

WARNING: Tính năng này phá vỡ các chương trình dựa vào việc di chuyển
  hoặc lập bản đồ hệ thống. Đã biết phần mềm bị hỏng vào thời điểm đó
  văn bản bao gồm CHECKPOINT_RESTORE, UML, gVisor, rr. Vì thế
  cấu hình này không thể được kích hoạt phổ biến.

Khi nào không nên sử dụng mseal
===============================
Các ứng dụng có thể áp dụng việc niêm phong cho bất kỳ vùng bộ nhớ ảo nào từ không gian người dùng,
nhưng trước đó nó là ZZ0000ZZ
áp dụng niêm phong. Điều này là do bản đồ kín ZZ0001ZZ
cho đến khi quá trình kết thúc hoặc lệnh gọi hệ thống exec được gọi.

Ví dụ:
   - aio/shm
     aio/shm có thể gọi mmap và munmap thay mặt cho không gian người dùng, ví dụ:
     ksys_shmdt() trong shm.c. Thời gian tồn tại của những bản đồ đó không bị ràng buộc với
     thời gian tồn tại của quá trình. Nếu những ký ức đó bị phong ấn khỏi không gian người dùng,
     thì munmap sẽ thất bại, gây rò rỉ không gian địa chỉ VMA trong quá trình
     thời gian tồn tại của quá trình.

- ptr được phân bổ bởi malloc (heap)
     Không sử dụng mseal trên bộ nhớ ptr trả về từ malloc().
     malloc() được triển khai bởi bộ cấp phát, ví dụ: của glibc. Trình quản lý heap có thể
     phân bổ ptr từ brk hoặc ánh xạ được tạo bởi mmap.
     Nếu một ứng dụng gọi mseal trên ptr được trả về từ malloc(), điều này có thể ảnh hưởng
     khả năng quản lý ánh xạ của người quản lý heap; kết quả là
     không xác định.

Ví dụ::

ptr = malloc(size);
        /* không gọi mseal trên ptr return từ malloc. */
        mseal(ptr, kích thước);
        /* free sẽ thành công, bộ cấp phát không thể thu nhỏ heap xuống thấp hơn ptr */
        miễn phí(ptr);

mseal không chặn
===================
Tóm lại, mseal chặn một số mm syscall nhất định sửa đổi một số VMA
các thuộc tính, chẳng hạn như các bit bảo vệ (RWX). Ánh xạ kín không có nghĩa là
bộ nhớ là bất biến.

Như Jann Horn đã chỉ ra trong [3], vẫn còn một số cách để viết
sang bộ nhớ RO, theo một cách nào đó, là do thiết kế. Và những thứ đó có thể bị chặn
bằng các biện pháp an ninh khác nhau.

Những trường hợp đó là:

- Ghi vào bộ nhớ chỉ đọc thông qua giao diện /proc/self/mem (FOLL_FORCE).
   - Ghi vào bộ nhớ chỉ đọc thông qua ptrace (chẳng hạn như PTRACE_POKETEXT).
   - userfaultfd.

Ý tưởng truyền cảm hứng cho bản vá này đến từ tác phẩm của Stephen Röttger trong V8
CFI [4]. Trình duyệt Chrome trong ChromeOS sẽ là người dùng đầu tiên của API này.

Thẩm quyền giải quyết
=====================
- [1] ZZ0000ZZ
- [2] ZZ0001ZZ
- [3] ZZ0002ZZ
- [4] ZZ0003ZZ