.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/sound/kernel-api/writing-an-alsa-driver.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

========================
Viết trình điều khiển ALSA
======================

:Tác giả: Takashi Iwai <tiwai@suse.de>

Lời nói đầu
=======

Tài liệu này mô tả cách viết trình điều khiển ZZ0000ZZ. Tài liệu
tập trung chủ yếu vào soundcard PCI. Trong trường hợp các loại thiết bị khác,
API cũng có thể khác. Tuy nhiên, ít nhất kernel ALSA API là
nhất quán, và do đó việc viết chúng sẽ vẫn hữu ích đôi chút.

Tài liệu này nhắm đến những người đã có đủ kỹ năng ngôn ngữ C
và có kiến thức lập trình kernel linux cơ bản. Tài liệu này không
giải thích chủ đề chung về mã hóa hạt nhân linux và không đề cập đến
chi tiết triển khai trình điều khiển cấp thấp. Nó chỉ mô tả tiêu chuẩn
cách viết trình điều khiển âm thanh PCI trên ALSA.

Cấu trúc cây tệp
===================

Tổng quan
-------

Cấu trúc cây tệp của trình điều khiển ALSA được mô tả bên dưới::

âm thanh
                    /lõi
                            /oss
                            /seq
                                    /oss
                    /bao gồm
                    /trình điều khiển
                            /mpu401
                            /opl3
                    /i2c
                    /synth
                            /emux
                    /pci
                            /(thẻ)
                    /isa
                            /(thẻ)
                    /cánh tay
                    /ppc
                    /sparc
                    /usb
                    /pcmcia /(thẻ)
                    /soc
                    /oss


thư mục cốt lõi
--------------

Thư mục này chứa lớp giữa là trái tim của ALSA
trình điều khiển. Trong thư mục này, các mô-đun ALSA gốc được lưu trữ. các
các thư mục con chứa các mô-đun khác nhau và phụ thuộc vào
cấu hình hạt nhân.

lõi/oss
~~~~~~~~

Mã cho OSS PCM và các mô-đun mô phỏng bộ trộn được lưu trữ trong này
thư mục. Mô phỏng rawmidi OSS được bao gồm trong rawmidi ALSA
mã vì nó khá nhỏ. Mã trình tự được lưu trữ trong
Thư mục ZZ0000ZZ (xem ZZ0001ZZ).

lõi/seq
~~~~~~~~

Thư mục này và các thư mục con của nó dành cho trình sắp xếp thứ tự ALSA. Cái này
thư mục chứa lõi của trình sắp xếp thứ tự và các mô-đun của trình sắp xếp thứ tự chính như
như snd-seq-midi, snd-seq-virmidi, v.v. Chúng chỉ được biên dịch khi
ZZ0000ZZ được đặt trong cấu hình kernel.

lõi/seq/oss
~~~~~~~~~~~~

Nó chứa mã mô phỏng trình sắp xếp thứ tự OSS.

bao gồm thư mục
-----------------

Đây là nơi chứa các tệp tiêu đề công khai của trình điều khiển ALSA, được
được xuất sang không gian người dùng hoặc được đưa vào một số tệp ở các định dạng khác nhau
thư mục. Về cơ bản, không nên đặt các tệp tiêu đề riêng tư trong
thư mục này, nhưng bạn vẫn có thể tìm thấy các tập tin ở đó, do lịch sử
lý do :)

thư mục trình điều khiển
-----------------

Thư mục này chứa mã được chia sẻ giữa các trình điều khiển khác nhau trên các thiết bị khác nhau.
kiến trúc. Do đó, chúng được coi là không có kiến ​​trúc cụ thể.
Ví dụ: tìm thấy trình điều khiển PCM giả và trình điều khiển MIDI nối tiếp
trong thư mục này. Trong các thư mục con có mã các thành phần
độc lập với kiến trúc bus và cpu.

trình điều khiển/mpu401
~~~~~~~~~~~~~~

Các mô-đun MPU401 và MPU401-UART được lưu trữ ở đây.

trình điều khiển/opl3 và opl4
~~~~~~~~~~~~~~~~~~~~~

Nội dung tổng hợp FM OPL3 và OPL4 được tìm thấy ở đây.

thư mục i2c
-------------

Nó chứa các thành phần ALSA i2c.

Mặc dù có lớp i2c tiêu chuẩn trên Linux nhưng ALSA có lớp i2c riêng
mã cho một số card, vì soundcard chỉ cần một thao tác đơn giản
và i2c API tiêu chuẩn quá phức tạp cho mục đích như vậy.

thư mục tổng hợp
---------------

Điều này chứa các mô-đun tổng hợp cấp trung.

Cho đến nay, chỉ có trình điều khiển tổng hợp Emu8000/Emu10k1 trong
Thư mục con ZZ0000ZZ.

thư mục pci
-------------

Thư mục này và các thư mục con của nó chứa các mô-đun thẻ cấp cao nhất
dành cho card âm thanh PCI và mã dành riêng cho PCI BUS.

Các trình điều khiển được biên dịch từ một tệp duy nhất được lưu trữ trực tiếp trong pci
thư mục, trong khi trình điều khiển với một số tệp nguồn được lưu trữ trên
thư mục con của riêng họ (ví dụ: emu10k1, Ice1712).

thư mục isa
-------------

Thư mục này và các thư mục con của nó chứa các mô-đun thẻ cấp cao nhất
dành cho card âm thanh ISA.

thư mục arm, ppc và sparc
-------------------------------

Chúng được sử dụng cho các mô-đun thẻ cấp cao nhất dành riêng cho một trong các mô-đun thẻ
những kiến trúc này.

thư mục usb
-------------

Thư mục này chứa trình điều khiển âm thanh USB.
Trình điều khiển USB MIDI được tích hợp trong trình điều khiển âm thanh usb.

thư mục pcmcia
----------------

PCMCIA, đặc biệt là trình điều khiển PCCard sẽ xuất hiện ở đây. Trình điều khiển CardBus sẽ
nằm trong thư mục pci, vì API của họ giống hệt với thư mục của
thẻ PCI tiêu chuẩn.

thư mục soc
-------------

Thư mục này chứa các mã cho ASoC (Hệ thống ALSA trên Chip)
lớp bao gồm lõi ASoC, codec và trình điều khiển máy.

thư mục oss
-------------

Nó chứa mã OSS/Lite.
Tại thời điểm viết bài, tất cả mã đã bị xóa ngoại trừ dmasound
trên m68k.


Luồng cơ bản cho trình điều khiển PCI
==========================

phác thảo
-------

Luồng tối thiểu cho card âm thanh PCI như sau:

- xác định bảng ID PCI (xem phần ZZ0000ZZ).

- tạo cuộc gọi lại ZZ0000ZZ.

- tạo cuộc gọi lại ZZ0000ZZ.

- tạo cấu trúc struct pci_driver
   chứa ba con trỏ trên.

- tạo một hàm ZZ0001ZZ chỉ cần gọi
   ZZ0000ZZ để đăng ký pci_driver
   bảng được xác định ở trên.

- tạo hàm ZZ0001ZZ để gọi
   Chức năng ZZ0000ZZ.

Ví dụ mã đầy đủ
-----------------

Ví dụ mã được hiển thị dưới đây. Một số phần vẫn chưa được thực hiện tại
thời điểm này nhưng sẽ được điền vào các phần tiếp theo. Những con số trong
dòng chú thích của hàm ZZ0000ZZ tham khảo
đến chi tiết được giải thích ở phần sau.

::

#include <linux/init.h>
      #include <linux/pci.h>
      #include <linux/slab.h>
      #include <sound/core.h>
      #include <sound/initval.h>

/* tham số mô-đun (xem "Tham số mô-đun") */
      /* SNDRV_CARDS: số lượng thẻ tối đa được mô-đun này hỗ trợ */
      chỉ số int tĩnh[SNDRV_CARDS] = SNDRV_DEFAULT_IDX;
      char tĩnh *id[SNDRV_CARDS] = SNDRV_DEFAULT_STR;
      kích hoạt bool tĩnh[SNDRV_CARDS] = SNDRV_DEFAULT_ENABLE_PNP;

/* định nghĩa bản ghi dành riêng cho chip */
      cấu trúc mychip {
              struct snd_card *card;
              /* phần còn lại của quá trình triển khai sẽ nằm trong phần
               * "Quản lý tài nguyên PCI"
               */
      };

/* hàm hủy dành riêng cho chip
       * (xem "Quản lý tài nguyên PCI")
       */
      int tĩnh snd_mychip_free(cấu trúc mychip *chip)
      {
              .... /* will be implemented later... */
      }

/* hàm hủy thành phần
       * (xem "Quản lý thẻ và linh kiện")
       */
      int tĩnh snd_mychip_dev_free(struct snd_device *device)
      {
              trả về snd_mychip_free(device->device_data);
      }

/* hàm tạo dành riêng cho chip
       * (xem "Quản lý thẻ và linh kiện")
       */
      int tĩnh snd_mychip_create(struct snd_card *card,
                                   cấu trúc pci_dev * pci,
                                   cấu trúc mychip **rchip)
      {
              cấu trúc mychip *chip;
              int lỗi;
              cấu trúc const tĩnh snd_device_ops ops = {
                     .dev_free = snd_mychip_dev_free,
              };

*rchip = NULL;

/* kiểm tra tính khả dụng của PCI tại đây
               * (xem "Quản lý tài nguyên PCI")
               */
              ....

/* phân bổ dữ liệu dành riêng cho chip với số 0 được điền */
              chip = kzalloc(sizeof(*chip), GFP_KERNEL);
              nếu (chip == NULL)
                      trả về -ENOMEM;

chip->thẻ = thẻ;

/* phần khởi tạo còn lại ở đây; sẽ được thực hiện
               * sau này, xem "Quản lý tài nguyên PCI"
               */
              ....

err = snd_device_new(thẻ, SNDRV_DEV_LOWLEVEL, chip, &ops);
              nếu (lỗi < 0) {
                      snd_mychip_free(chip);
                      trả lại lỗi;
              }

*rchip = chip;
              trả về 0;
      }

/* hàm tạo -- xem phần phụ "Trình tạo trình điều khiển" */
      int tĩnh snd_mychip_probe(struct pci_dev *pci,
                                  const struct pci_device_id *pci_id)
      {
              phát triển int tĩnh;
              struct snd_card *card;
              cấu trúc mychip *chip;
              int lỗi;

/* (1) */
              nếu (dev >= SNDRV_CARDS)
                      trả về -ENODEV;
              if (!enable[dev]) {
                      phát triển++;
                      trả về -ENOENT;
              }

/* (2) */
              err = snd_card_new(&pci->dev, index[dev], id[dev], THIS_MODULE,
                                 0, &thẻ);
              nếu (lỗi < 0)
                      trả lại lỗi;

/* (3) */
              err = snd_mychip_create(thẻ, pci, &chip);
              nếu (lỗi < 0)
                      lỗi đi đến;

/* (4) */
              strcpy(thẻ->trình điều khiển, "Chip của tôi");
              strcpy(card->shortname, "My Own Chip 123");
              sprintf(card->longname, "%s at 0x%lx irq %i",
                      thẻ->tên ngắn, chip->cổng, chip->irq);

/* (5) */
              .... /* implemented later */

/* (6) */
              err = snd_card_register(thẻ);
              nếu (lỗi < 0)
                      lỗi đi đến;

/* (7) */
              pci_set_drvdata(pci, thẻ);
              phát triển++;
              trả về 0;

lỗi:
              snd_card_free(thẻ);
              trả lại lỗi;
      }

/* hàm hủy -- xem phần phụ "Trình hủy" */
      static void snd_mychip_remove(struct pci_dev *pci)
      {
              snd_card_free(pci_get_drvdata(pci));
      }



Trình xây dựng trình điều khiển
------------------

Hàm tạo thực sự của trình điều khiển PCI là lệnh gọi lại ZZ0000ZZ. các
Lệnh gọi lại ZZ0001ZZ và các hàm tạo thành phần khác được gọi là
từ cuộc gọi lại ZZ0002ZZ không thể được sử dụng với tiền tố ZZ0003ZZ
bởi vì mọi thiết bị PCI đều có thể là thiết bị cắm nóng.

Trong lệnh gọi lại ZZ0000ZZ, sơ đồ sau thường được sử dụng.

1) Kiểm tra và tăng chỉ số thiết bị.
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

::

phát triển int tĩnh;
  ....
nếu (dev >= SNDRV_CARDS)
          trả về -ENODEV;
  if (!enable[dev]) {
          phát triển++;
          trả về -ENOENT;
  }


trong đó ZZ0000ZZ là tùy chọn mô-đun.

Mỗi lần gọi lại ZZ0000ZZ, hãy kiểm tra tính khả dụng của
thiết bị. Nếu không có sẵn, chỉ cần tăng chỉ số thiết bị và
trở lại. dev cũng sẽ được tăng sau (ZZ0001ZZ).

2) Tạo một phiên bản thẻ
~~~~~~~~~~~~~~~~~~~~~~~~~

::

struct snd_card *card;
  int lỗi;
  ....
err = snd_card_new(&pci->dev, index[dev], id[dev], THIS_MODULE,
                     0, &thẻ);


Chi tiết sẽ được giải thích trong phần ZZ0000ZZ.

3) Tạo thành phần chính
~~~~~~~~~~~~~~~~~~~~~~~~~~

Trong phần này, tài nguyên PCI được phân bổ::

cấu trúc mychip *chip;
  ....
err = snd_mychip_create(thẻ, pci, &chip);
  nếu (lỗi < 0)
          lỗi đi đến;

Chi tiết sẽ được giải thích trong phần ZZ0000ZZ.

Khi có sự cố xảy ra, chức năng thăm dò cần xử lý
lỗi.  Trong ví dụ này, chúng tôi có một đường dẫn xử lý lỗi duy nhất được đặt
ở cuối hàm::

lỗi:
          snd_card_free(thẻ);
          trả lại lỗi;

Vì mỗi thành phần có thể được giải phóng đúng cách, nên một thành phần
Cuộc gọi ZZ0000ZZ là đủ trong hầu hết các trường hợp.


4) Đặt chuỗi tên và ID trình điều khiển.
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

::

strcpy(thẻ->trình điều khiển, "Chip của tôi");
  strcpy(card->shortname, "My Own Chip 123");
  sprintf(card->longname, "%s at 0x%lx irq %i",
          thẻ->tên ngắn, chip->cổng, chip->irq);

Trường trình điều khiển chứa chuỗi ID tối thiểu của chip. Cái này được sử dụng
bởi bộ cấu hình của alsa-lib, vì vậy hãy giữ nó đơn giản nhưng độc đáo. Ngay cả
cùng một trình điều khiển có thể có các ID trình điều khiển khác nhau để phân biệt
chức năng của từng loại chip.

Trường tên viết tắt là một chuỗi được hiển thị dưới dạng tên dài dòng hơn. Tên dài
trường chứa thông tin được hiển thị trong ZZ0000ZZ.

5) Tạo các thành phần khác, chẳng hạn như bộ trộn, MIDI, v.v.
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Ở đây bạn xác định các thành phần cơ bản như ZZ0000ZZ,
máy trộn (ví dụ: ZZ0001ZZ), MIDI (ví dụ:
ZZ0002ZZ) và các giao diện khác.
Ngoài ra, nếu bạn muốn ZZ0003ZZ, hãy xác định nó ở đây,
quá.

6) Đăng ký phiên bản thẻ.
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

::

err = snd_card_register(thẻ);
  nếu (lỗi < 0)
          lỗi đi đến;

Cũng sẽ được giải thích trong phần ZZ0000ZZ.

7) Đặt dữ liệu trình điều khiển PCI và trả về số 0.
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

::

pci_set_drvdata(pci, thẻ);
  phát triển++;
  trả về 0;

Ở trên, bản ghi thẻ được lưu trữ. Con trỏ này được sử dụng trong
cũng loại bỏ các cuộc gọi lại và các cuộc gọi lại quản lý nguồn.

Hàm hủy diệt
----------

Hàm hủy, lệnh gọi lại loại bỏ, chỉ cần giải phóng phiên bản thẻ.
Khi đó lớp giữa ALSA sẽ giải phóng tất cả các thành phần kèm theo
tự động.

Thông thường nó sẽ chỉ gọi ZZ0000ZZ::

static void snd_mychip_remove(struct pci_dev *pci)
  {
          snd_card_free(pci_get_drvdata(pci));
  }


Đoạn mã trên giả định rằng con trỏ thẻ được đặt thành trình điều khiển PCI
dữ liệu.

Tệp tiêu đề
------------

Đối với ví dụ trên, ít nhất các tệp bao gồm sau đây là
cần thiết::

#include <linux/init.h>
  #include <linux/pci.h>
  #include <linux/slab.h>
  #include <sound/core.h>
  #include <sound/initval.h>

trong đó cái cuối cùng chỉ cần thiết khi các tùy chọn mô-đun được xác định
trong tập tin nguồn. Nếu mã được chia thành nhiều tệp, các tệp
không có tùy chọn mô-đun thì không cần chúng.

Ngoài các tiêu đề này, bạn sẽ cần ZZ0002ZZ cho
xử lý ngắt và ZZ0003ZZ để truy cập I/O. Nếu bạn sử dụng
Các chức năng ZZ0000ZZ hoặc ZZ0001ZZ, bạn sẽ cần
bao gồm cả ZZ0004ZZ nữa.

Các giao diện ALSA như PCM và các API điều khiển được xác định trong các
Tệp tiêu đề ZZ0000ZZ. Chúng phải được đưa vào sau
ZZ0001ZZ.

Quản lý thẻ và linh kiện
==================================

Phiên bản thẻ
-------------

Đối với mỗi soundcard, một bản ghi “thẻ” phải được phân bổ.

Bản ghi thẻ là trụ sở của soundcard. Nó quản lý toàn bộ
danh sách các thiết bị (linh kiện) trên soundcard như PCM, mixer,
MIDI, bộ tổng hợp, v.v. Ngoài ra, hồ sơ thẻ còn chứa ID và
chuỗi tên của thẻ, quản lý thư mục gốc của các tập tin Proc và điều khiển
trạng thái quản lý nguồn và ngắt kết nối phích cắm nóng. thành phần
danh sách trên bản ghi thẻ được sử dụng để quản lý việc phát hành chính xác
tài nguyên lúc bị phá hủy.

Như đã đề cập ở trên, để tạo một phiên bản thẻ, hãy gọi
ZZ0000ZZ::

struct snd_card *card;
  int lỗi;
  err = snd_card_new(&pci->dev, chỉ mục, id, mô-đun, extra_size, &card);


Hàm này có sáu đối số: con trỏ thiết bị cha,
số chỉ mục thẻ, chuỗi id, con trỏ mô-đun (thường
ZZ0001ZZ), kích thước của không gian dữ liệu bổ sung và con trỏ tới
trả lại phiên bản thẻ. Đối số extra_size được sử dụng để phân bổ
card->private_data cho dữ liệu dành riêng cho chip. Lưu ý rằng những dữ liệu này là
được phân bổ bởi ZZ0000ZZ.

Đối số đầu tiên, con trỏ của thiết bị struct, chỉ định thiết bị cha
thiết bị. Đối với các thiết bị PCI, thông thường ZZ0000ZZ được chuyển đến đó.

Linh kiện
----------

Sau khi tạo thẻ, bạn có thể gắn các thành phần (thiết bị) vào
trường hợp thẻ. Trong trình điều khiển ALSA, một thành phần được biểu diễn dưới dạng
đối tượng struct snd_device. Một thành phần
có thể là phiên bản PCM, giao diện điều khiển, giao diện MIDI thô, v.v.
Mỗi trường hợp như vậy có một mục thành phần.

Một thành phần có thể được tạo thông qua ZZ0000ZZ
chức năng::

snd_device_new(thẻ, SNDRV_DEV_XXX, chip, &ops);

Việc này lấy con trỏ thẻ, cấp thiết bị (ZZ0000ZZ),
con trỏ dữ liệu và con trỏ gọi lại (ZZ0001ZZ). Cấp độ thiết bị
xác định loại thành phần và thứ tự đăng ký và
hủy đăng ký. Đối với hầu hết các thành phần, cấp độ thiết bị đã
được xác định. Đối với thành phần do người dùng xác định, bạn có thể sử dụng
ZZ0002ZZ.

Bản thân chức năng này không phân bổ không gian dữ liệu. Dữ liệu phải được
được phân bổ thủ công trước đó và con trỏ của nó được truyền dưới dạng
lý lẽ. Con trỏ này (ZZ0000ZZ trong ví dụ trên) được sử dụng làm
định danh cho cá thể.

Mỗi thành phần ALSA được xác định trước như các lệnh gọi AC97 và PCM
ZZ0000ZZ bên trong hàm tạo của nó. Kẻ hủy diệt
cho mỗi thành phần được xác định trong con trỏ gọi lại. Do đó, bạn không
cần phải quan tâm đến việc gọi một hàm hủy cho một thành phần như vậy.

Nếu bạn muốn tạo thành phần của riêng mình, bạn cần đặt hàm hủy
hoạt động với lệnh gọi lại dev_free trong ZZ0001ZZ, để nó có thể
được phát hành tự động thông qua ZZ0000ZZ. Tiếp theo
ví dụ sẽ hiển thị việc triển khai dữ liệu dành riêng cho chip.

Dữ liệu dành riêng cho chip
------------------

Thông tin cụ thể về chip, ví dụ: địa chỉ cổng I/O, tài nguyên của nó
con trỏ hoặc số irq, được lưu trữ trong bản ghi dành riêng cho chip::

cấu trúc mychip {
          ....
  };


Nói chung, có hai cách phân bổ bản ghi chip.

1. Phân bổ qua ZZ0000ZZ.
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Như đã đề cập ở trên, bạn có thể chuyển độ dài dữ liệu bổ sung sang thứ 5
đối số của ZZ0000ZZ, ví dụ::

err = snd_card_new(&pci->dev, index[dev], id[dev], THIS_MODULE,
                     sizeof(struct mychip), &card);

struct mychip là loại bản ghi chip.

Đổi lại, bản ghi được phân bổ có thể được truy cập dưới dạng

::

struct mychip *chip = card->private_data;

Với phương pháp này, bạn không phải phân bổ hai lần. Kỷ lục là
được phát hành cùng với phiên bản thẻ.

2. Phân bổ một thiết bị bổ sung.
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Sau khi phân bổ phiên bản thẻ qua ZZ0000ZZ
(với ZZ0002ZZ ở đối số thứ 4), hãy gọi ZZ0001ZZ::

struct snd_card *card;
  cấu trúc mychip *chip;
  err = snd_card_new(&pci->dev, index[dev], id[dev], THIS_MODULE,
                     0, &thẻ);
  .....
chip = kzalloc(sizeof(*chip), GFP_KERNEL);

Bản ghi chip ít nhất phải có trường để giữ con trỏ thẻ,

::

cấu trúc mychip {
          struct snd_card *card;
          ....
  };


Sau đó, đặt con trỏ thẻ trong phiên bản chip được trả về::

chip->thẻ = thẻ;

Tiếp theo, khởi tạo các trường và đăng ký bản ghi chip này làm
thiết bị cấp thấp có ZZ0000ZZ được chỉ định::

cấu trúc const tĩnh snd_device_ops ops = {
          .dev_free = snd_mychip_dev_free,
  };
  ....
snd_device_new(thẻ, SNDRV_DEV_LOWLEVEL, chip, &ops);

ZZ0000ZZ là trình phá hủy thiết bị
hàm này sẽ gọi hàm hủy thực sự::

int tĩnh snd_mychip_dev_free(struct snd_device *device)
  {
          trả về snd_mychip_free(device->device_data);
  }

trong đó ZZ0000ZZ là hàm hủy thực sự.

Nhược điểm của phương pháp này rõ ràng là số lượng mã lớn hơn.
Tuy nhiên, điều đáng khen là bạn có thể kích hoạt cuộc gọi lại của riêng mình tại
đăng ký và ngắt kết nối thẻ thông qua cài đặt trong snd_device_ops.
Về việc đăng ký và ngắt thẻ xem các phần phụ
bên dưới.


Đăng ký và phát hành
------------------------

Sau khi tất cả các thành phần được chỉ định, hãy đăng ký phiên bản thẻ bằng cách gọi
ZZ0000ZZ. Truy cập vào các tập tin thiết bị là
được kích hoạt vào thời điểm này. Tức là trước
ZZ0001ZZ được gọi, các thành phần được an toàn
không thể tiếp cận được từ phía bên ngoài. Nếu cuộc gọi này không thành công, hãy thoát khỏi đầu dò
hoạt động sau khi giải phóng thẻ thông qua ZZ0002ZZ.

Để giải phóng phiên bản thẻ, bạn có thể gọi đơn giản
ZZ0000ZZ. Như đã đề cập trước đó, tất cả các thành phần
được giải phóng tự động bởi cuộc gọi này.

Đối với thiết bị cho phép cắm nóng, bạn có thể sử dụng
ZZ0000ZZ. Điều này sẽ trì hoãn
sự phá hủy cho đến khi tất cả các thiết bị được đóng lại.

Quản lý tài nguyên PCI
=======================

Ví dụ mã đầy đủ
-----------------

Trong phần này, chúng ta sẽ hoàn thiện hàm tạo dành riêng cho chip,
hàm hủy và các mục PCI. Mã ví dụ được hiển thị đầu tiên, bên dưới::

cấu trúc mychip {
              struct snd_card *card;
              cấu trúc pci_dev *pci;

cổng dài không dấu;
              int irq;
      };

int tĩnh snd_mychip_free(cấu trúc mychip *chip)
      {
              /* vô hiệu hóa phần cứng ở đây nếu có */
              .... /* (not implemented in this document) */

/* giải phóng irq */
              nếu (chip->irq >= 0)
                      free_irq(chip->irq, chip);
              /* giải phóng các cổng I/O và bộ nhớ */
              pci_release_khu vực(chip->pci);
              /* vô hiệu hóa mục nhập PCI */
              pci_disable_device(chip->pci);
              /*giải phóng dữ liệu*/
              kfree(chip);
              trả về 0;
      }

/* hàm tạo dành riêng cho chip */
      int tĩnh snd_mychip_create(struct snd_card *card,
                                   cấu trúc pci_dev * pci,
                                   cấu trúc mychip **rchip)
      {
              cấu trúc mychip *chip;
              int lỗi;
              cấu trúc const tĩnh snd_device_ops ops = {
                     .dev_free = snd_mychip_dev_free,
              };

*rchip = NULL;

/* khởi tạo mục nhập PCI */
              lỗi = pci_enable_device(pci);
              nếu (lỗi < 0)
                      trả lại lỗi;
              /* kiểm tra tính khả dụng của PCI (28bit DMA) */
              nếu (pci_set_dma_mask(pci, DMA_BIT_MASK(28)) < 0 ||
                  pci_set_consistent_dma_mask(pci, DMA_BIT_MASK(28)) < 0) {
                      printk(KERN_ERR "lỗi đặt mặt nạ 28 bit DMA\n");
                      pci_disable_device(pci);
                      trả về -ENXIO;
              }

chip = kzalloc(sizeof(*chip), GFP_KERNEL);
              nếu (chip == NULL) {
                      pci_disable_device(pci);
                      trả về -ENOMEM;
              }

/*khởi tạo nội dung */
              chip->thẻ = thẻ;
              chip->pci = pci;
              chip->irq = -1;

/* (1) Phân bổ tài nguyên PCI */
              err = pci_request_khu vực(pci, "Chip của tôi");
              nếu (lỗi < 0) {
                      kfree(chip);
                      pci_disable_device(pci);
                      trả lại lỗi;
              }
              chip->port = pci_resource_start(pci, 0);
              if (request_irq(pci->irq, snd_mychip_interrupt,
                              IRQF_SHARED, KBUILD_MODNAME, chip)) {
                      printk(KERN_ERR "không thể lấy irq %d\n", pci->irq);
                      snd_mychip_free(chip);
                      trả về -EBUSY;
              }
              chip->irq = pci->irq;
              thẻ->sync_irq = chip->irq;

/* (2) khởi tạo phần cứng chip */
              .... /*   (not implemented in this document) */

err = snd_device_new(thẻ, SNDRV_DEV_LOWLEVEL, chip, &ops);
              nếu (lỗi < 0) {
                      snd_mychip_free(chip);
                      trả lại lỗi;
              }

*rchip = chip;
              trả về 0;
      }

/* ID PCI */
      cấu trúc tĩnh pci_device_id snd_mychip_ids[] = {
              {PCI_VENDOR_ID_FOO, PCI_DEVICE_ID_BAR,
                PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0, },
              ....
{ 0, }
      };
      MODULE_DEVICE_TABLE(pci, snd_mychip_ids);

/* định nghĩa pci_driver */
      trình điều khiển pci_driver cấu trúc tĩnh = {
              .name = KBUILD_MODNAME,
              .id_table = snd_mychip_ids,
              .probe = snd_mychip_probe,
              .remove = snd_mychip_remove,
      };

/*khởi tạo mô-đun */
      int tĩnh __init alsa_card_mychip_init(void)
      {
              trả về pci_register_driver(&driver);
      }

/* dọn dẹp mô-đun */
      khoảng trống tĩnh __exit alsa_card_mychip_exit(void)
      {
              pci_unregister_driver(&driver);
      }

module_init(alsa_card_mychip_init)
      module_exit(alsa_card_mychip_exit)

EXPORT_NO_SYMBOLS; /*chỉ dành cho kernel cũ */

Một số Hafta
------------

Việc phân bổ tài nguyên PCI được thực hiện trong hàm ZZ0001ZZ và
thông thường một hàm ZZ0000ZZ bổ sung được viết cho việc này
mục đích.

Trong trường hợp thiết bị PCI, trước tiên bạn phải gọi
Chức năng ZZ0000ZZ trước khi phân bổ
tài nguyên. Ngoài ra, bạn cần đặt mặt nạ PCI DMA thích hợp để hạn chế
phạm vi I/O được truy cập. Trong một số trường hợp, bạn có thể cần gọi
Chức năng ZZ0001ZZ cũng vậy.

Giả sử mặt nạ 28 bit, mã được thêm vào sẽ trông như sau::

lỗi = pci_enable_device(pci);
  nếu (lỗi < 0)
          trả lại lỗi;
  nếu (pci_set_dma_mask(pci, DMA_BIT_MASK(28)) < 0 ||
      pci_set_consistent_dma_mask(pci, DMA_BIT_MASK(28)) < 0) {
          printk(KERN_ERR "lỗi đặt mặt nạ 28 bit DMA\n");
          pci_disable_device(pci);
          trả về -ENXIO;
  }
  

Phân bổ nguồn lực
-------------------

Việc phân bổ các cổng I/O và irq được thực hiện thông qua kernel tiêu chuẩn
chức năng.  Các tài nguyên này phải được giải phóng trong hàm hủy
chức năng (xem bên dưới).

Bây giờ giả sử rằng thiết bị PCI có cổng I/O với 8 byte và
ngắt lời. Sau đó struct mychip sẽ có
các trường sau::

cấu trúc mychip {
          struct snd_card *card;

cổng dài không dấu;
          int irq;
  };


Đối với cổng I/O (và cả vùng bộ nhớ), bạn cần có
con trỏ tài nguyên để quản lý tài nguyên tiêu chuẩn. Đối với một iq, bạn
chỉ phải giữ lại số irq (số nguyên). Nhưng bạn cần khởi tạo
số này thành -1 trước khi phân bổ thực tế, vì irq 0 hợp lệ. các
địa chỉ cổng và con trỏ tài nguyên của nó có thể được khởi tạo là null bằng cách
ZZ0000ZZ tự động nên bạn không cần phải quan tâm
thiết lập lại chúng.

Việc phân bổ cổng I/O được thực hiện như sau::

err = pci_request_khu vực(pci, "Chip của tôi");
  nếu (lỗi < 0) { 
          kfree(chip);
          pci_disable_device(pci);
          trả lại lỗi;
  }
  chip->port = pci_resource_start(pci, 0);

Nó sẽ dự trữ vùng cổng I/O 8 byte của thiết bị PCI đã cho.
Giá trị trả về, ZZ0003ZZ, được phân bổ thông qua
ZZ0000ZZ bởi ZZ0001ZZ. Con trỏ
phải được phát hành qua ZZ0002ZZ, nhưng có vấn đề với
cái này. Vấn đề này sẽ được giải thích sau.

Việc phân bổ nguồn ngắt được thực hiện như sau::

if (request_irq(pci->irq, snd_mychip_interrupt,
                  IRQF_SHARED, KBUILD_MODNAME, chip)) {
          printk(KERN_ERR "không thể lấy irq %d\n", pci->irq);
          snd_mychip_free(chip);
          trả về -EBUSY;
  }
  chip->irq = pci->irq;

trong đó ZZ0000ZZ là trình xử lý ngắt
được xác định ZZ0003ZZ. Lưu ý rằng
ZZ0002ZZ chỉ nên được xác định khi ZZ0001ZZ
đã thành công.

Trên bus PCI, các ngắt có thể được chia sẻ. Vì vậy, ZZ0001ZZ được sử dụng
làm cờ ngắt của ZZ0000ZZ.

Đối số cuối cùng của ZZ0000ZZ là con trỏ dữ liệu
được chuyển tới bộ xử lý ngắt. Thông thường, bản ghi dành riêng cho chip là
được sử dụng cho việc đó, nhưng bạn cũng có thể sử dụng những gì bạn thích.

Tôi sẽ không cung cấp thông tin chi tiết về trình xử lý ngắt vào thời điểm này, nhưng tại
ít nhất sự xuất hiện của nó có thể được giải thích bây giờ. Trình xử lý ngắt trông
thường như sau::

irqreturn_t tĩnh snd_mychip_interrupt(int irq, void *dev_id)
  {
          struct mychip *chip = dev_id;
          ....
trả lại IRQ_HANDLED;
  }

Sau khi yêu cầu IRQ, bạn có thể chuyển nó cho ZZ0000ZZ
lĩnh vực::

thẻ->irq = chip->irq;

Điều này cho phép lõi PCM tự động gọi
ZZ0000ZZ vào đúng thời điểm, giống như trước ZZ0001ZZ.
Xem phần sau ZZ0002ZZ để biết chi tiết.

Bây giờ hãy viết hàm hủy tương ứng cho các tài nguyên ở trên.
Vai trò của hàm hủy rất đơn giản: vô hiệu hóa phần cứng (nếu đã
được kích hoạt) và giải phóng tài nguyên. Cho đến nay, chúng tôi không có phần cứng,
vì vậy mã vô hiệu hóa không được viết ở đây.

Để giải phóng tài nguyên, phương pháp “kiểm tra và giải phóng” là cách an toàn hơn.
Đối với ngắt, hãy làm như thế này ::

nếu (chip->irq >= 0)
          free_irq(chip->irq, chip);

Vì số irq có thể bắt đầu từ 0 nên bạn nên khởi tạo
ZZ0000ZZ có giá trị âm (ví dụ -1), để bạn có thể kiểm tra
tính hợp lệ của số irq như trên.

Khi bạn yêu cầu cổng I/O hoặc vùng bộ nhớ qua
ZZ0000ZZ hoặc
ZZ0001ZZ giống như trong ví dụ này, hãy thả
(các) tài nguyên bằng cách sử dụng chức năng tương ứng,
ZZ0002ZZ hoặc
ZZ0003ZZ::

pci_release_khu vực(chip->pci);

Khi bạn yêu cầu thủ công qua ZZ0000ZZ hoặc
ZZ0001ZZ, bạn có thể phát hành nó qua
ZZ0002ZZ. Giả sử bạn giữ tài nguyên
con trỏ được trả về từ ZZ0003ZZ trong
chip->res_port, quy trình phát hành sẽ như sau::

phát hành_and_free_resource(chip->res_port);

Đừng quên gọi ZZ0000ZZ trước
kết thúc.

Và cuối cùng, phát hành bản ghi dành riêng cho chip::

kfree(chip);

Chúng tôi đã không triển khai phần vô hiệu hóa phần cứng ở trên. Nếu bạn
cần thực hiện việc này, xin lưu ý rằng hàm hủy có thể được gọi ngay cả
trước khi quá trình khởi tạo chip hoàn tất. Sẽ tốt hơn
có cờ để bỏ qua việc tắt phần cứng nếu phần cứng không
đã khởi tạo chưa.

Khi dữ liệu chip được gán cho thẻ bằng cách sử dụng
ZZ0000ZZ với ZZ0001ZZ, nó
hàm hủy được gọi cuối cùng. Nghĩa là, nó được đảm bảo rằng tất cả những thứ khác
các thành phần như PCM và bộ điều khiển đã được phát hành. bạn không
phải dừng PCM, v.v. một cách rõ ràng mà chỉ cần gọi phần cứng cấp thấp
dừng lại.

Việc quản lý vùng được ánh xạ bộ nhớ gần giống như quản lý
quản lý cổng I/O. Bạn sẽ cần hai trường như sau::

cấu trúc mychip {
          ....
iobase_phys dài không dấu;
          void __iomem *iobase_virt;
  };

và việc phân bổ sẽ như sau::

err = pci_request_khu vực(pci, "Chip của tôi");
  nếu (lỗi < 0) {
          kfree(chip);
          trả lại lỗi;
  }
  chip->iobase_phys = pci_resource_start(pci, 0);
  chip->iobase_virt = ioremap(chip->iobase_phys,
                                      pci_resource_len(pci, 0));

và hàm hủy tương ứng sẽ là::

int tĩnh snd_mychip_free(cấu trúc mychip *chip)
  {
          ....
nếu (chip->iobase_virt)
                  iounmap(chip->iobase_virt);
          ....
pci_release_khu vực(chip->pci);
          ....
  }

Tất nhiên, một cách hiện đại với ZZ0000ZZ sẽ khiến mọi việc trở nên dễ dàng hơn.
cũng dễ dàng hơn một chút::

err = pci_request_khu vực(pci, "Chip của tôi");
  nếu (lỗi < 0) {
          kfree(chip);
          trả lại lỗi;
  }
  chip->iobase_virt = pci_iomap(pci, 0, 0);

được ghép nối với ZZ0000ZZ tại hàm hủy.


Mục nhập PCI
-----------

Cho đến nay, rất tốt. Hãy hoàn thành những thứ PCI còn thiếu. Lúc đầu, chúng ta cần một
bảng cấu trúc pci_device_id cho
chipset này. Đó là bảng gồm số ID nhà cung cấp/thiết bị PCI và một số
mặt nạ.

Ví dụ::

cấu trúc tĩnh pci_device_id snd_mychip_ids[] = {
          {PCI_VENDOR_ID_FOO, PCI_DEVICE_ID_BAR,
            PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0, },
          ....
{ 0, }
  };
  MODULE_DEVICE_TABLE(pci, snd_mychip_ids);

Trường đầu tiên và thứ hai của cấu trúc pci_device_id là nhà cung cấp
và ID thiết bị. Nếu bạn không có lý do gì để lọc các thiết bị phù hợp, bạn có thể
các trường còn lại để nguyên như trên. Trường cuối cùng của
struct pci_device_id chứa dữ liệu riêng tư cho mục này. Bạn có thể chỉ định
bất kỳ giá trị nào ở đây, chẳng hạn, để xác định các hoạt động cụ thể cho các hoạt động được hỗ trợ
ID thiết bị. Ví dụ như vậy được tìm thấy trong trình điều khiển intel8x0.

Mục cuối cùng của danh sách này là dấu kết thúc. Bạn phải chỉ định điều này
mục nhập hoàn toàn bằng không.

Sau đó chuẩn bị struct pci_driver
ghi lại::

trình điều khiển pci_driver cấu trúc tĩnh = {
          .name = KBUILD_MODNAME,
          .id_table = snd_mychip_ids,
          .probe = snd_mychip_probe,
          .remove = snd_mychip_remove,
  };

Các hàm ZZ0000ZZ và ZZ0001ZZ đã được xác định trong
các phần trước. Trường ZZ0002ZZ là chuỗi tên của trường này
thiết bị. Lưu ý không được sử dụng dấu gạch chéo (“/”) trong chuỗi này.

Và cuối cùng, các mục mô-đun ::

int tĩnh __init alsa_card_mychip_init(void)
  {
          trả về pci_register_driver(&driver);
  }

khoảng trống tĩnh __exit alsa_card_mychip_exit(void)
  {
          pci_unregister_driver(&driver);
  }

module_init(alsa_card_mychip_init)
  module_exit(alsa_card_mychip_exit)

Lưu ý rằng các mục mô-đun này được gắn thẻ ZZ0000ZZ và ZZ0001ZZ
tiền tố.

Thế thôi!

Giao diện PCM
=============

Tổng quan
-------

Lớp giữa PCM của ALSA khá mạnh và chỉ cần thiết
cho mỗi trình điều khiển thực hiện các chức năng cấp thấp để truy cập vào nó
phần cứng.

Để truy cập lớp PCM, bạn cần bao gồm ZZ0000ZZ
đầu tiên. Ngoài ra, ZZ0001ZZ có thể cần thiết nếu bạn
truy cập một số chức năng liên quan đến hw_param.

Mỗi thiết bị thẻ có thể có tối đa bốn phiên bản PCM. Một phiên bản PCM
tương ứng với tệp thiết bị PCM. Giới hạn số lượng instance
chỉ đến từ kích thước bit có sẵn của số thiết bị Linux.
Sau khi sử dụng số thiết bị 64bit, chúng tôi sẽ có nhiều phiên bản PCM hơn
có sẵn.

Một phiên bản PCM bao gồm các luồng ghi và phát lại PCM, và mỗi luồng
Luồng PCM bao gồm một hoặc nhiều luồng con PCM. Một số soundcard
hỗ trợ nhiều chức năng phát lại. Ví dụ: emu10k1 có PCM
phát lại 32 luồng âm thanh nổi. Trong trường hợp này, tại mỗi lần mở, một
dòng phụ được (thường) tự động chọn và mở. Trong khi đó, khi
chỉ có một luồng con tồn tại và nó đã được mở, luồng mở tiếp theo
sẽ chặn hoặc báo lỗi với ZZ0000ZZ tùy theo tệp đang mở
chế độ. Nhưng bạn không cần phải quan tâm đến những chi tiết như vậy trong trình điều khiển của mình. các
Lớp giữa PCM sẽ đảm nhiệm công việc đó.

Ví dụ mã đầy đủ
-----------------

Mã ví dụ bên dưới không bao gồm bất kỳ quy trình truy cập phần cứng nào nhưng
chỉ hiển thị khung, cách xây dựng giao diện PCM::

#include <âm thanh/pcm.h>
      ....

/*định nghĩa phần cứng */
      cấu trúc tĩnh snd_pcm_hardware snd_mychip_playback_hw = {
              .info = (SNDRV_PCM_INFO_MMAP |
                       SNDRV_PCM_INFO_INTERLEAVED |
                       SNDRV_PCM_INFO_BLOCK_TRANSFER |
                       SNDRV_PCM_INFO_MMAP_VALID),
              .format = SNDRV_PCM_FMTBIT_S16_LE,
              .giá = SNDRV_PCM_RATE_8000_48000,
              .rate_min = 8000,
              .rate_max = 48000,
              .channels_min = 2,
              .channels_max = 2,
              .buffer_bytes_max = 32768,
              . Period_bytes_min = 4096,
              . Period_bytes_max = 32768,
              .thời gian_min = 1,
              .thời gian_max = 1024,
      };

/*định nghĩa phần cứng */
      cấu trúc tĩnh snd_pcm_hardware snd_mychip_capture_hw = {
              .info = (SNDRV_PCM_INFO_MMAP |
                       SNDRV_PCM_INFO_INTERLEAVED |
                       SNDRV_PCM_INFO_BLOCK_TRANSFER |
                       SNDRV_PCM_INFO_MMAP_VALID),
              .format = SNDRV_PCM_FMTBIT_S16_LE,
              .giá = SNDRV_PCM_RATE_8000_48000,
              .rate_min = 8000,
              .rate_max = 48000,
              .channels_min = 2,
              .channels_max = 2,
              .buffer_bytes_max = 32768,
              . Period_bytes_min = 4096,
              . Period_bytes_max = 32768,
              .thời gian_min = 1,
              .thời gian_max = 1024,
      };

/* mở lệnh gọi lại */
      int tĩnh snd_mychip_playback_open(struct snd_pcm_substream *substream)
      {
              struct mychip *chip = snd_pcm_substream_chip(substream);
              struct snd_pcm_runtime *runtime = substream->runtime;

thời gian chạy->hw = snd_mychip_playback_hw;
              /* Việc khởi tạo phần cứng khác sẽ được thực hiện ở đây */
              ....
trả về 0;
      }

/*đóng lệnh gọi lại */
      int tĩnh snd_mychip_playback_close(struct snd_pcm_substream *substream)
      {
              struct mychip *chip = snd_pcm_substream_chip(substream);
              /* các mã dành riêng cho phần cứng sẽ có ở đây */
              ....
trả về 0;

      }

/* mở lệnh gọi lại */
      int tĩnh snd_mychip_capture_open(struct snd_pcm_substream *substream)
      {
              struct mychip *chip = snd_pcm_substream_chip(substream);
              struct snd_pcm_runtime *runtime = substream->runtime;

thời gian chạy->hw = snd_mychip_capture_hw;
              /* Việc khởi tạo phần cứng khác sẽ được thực hiện ở đây */
              ....
trả về 0;
      }

/*đóng lệnh gọi lại */
      int tĩnh snd_mychip_capture_close(struct snd_pcm_substream *substream)
      {
              struct mychip *chip = snd_pcm_substream_chip(substream);
              /* các mã dành riêng cho phần cứng sẽ có ở đây */
              ....
trả về 0;
      }

/* hw_params gọi lại */
      int tĩnh snd_mychip_pcm_hw_params(struct snd_pcm_substream *substream,
                                   cấu trúc snd_pcm_hw_params *hw_params)
      {
              /* các mã dành riêng cho phần cứng sẽ có ở đây */
              ....
trả về 0;
      }

/* hw_free gọi lại */
      int tĩnh snd_mychip_pcm_hw_free(struct snd_pcm_substream *substream)
      {
              /* các mã dành riêng cho phần cứng sẽ có ở đây */
              ....
trả về 0;
      }

/*chuẩn bị gọi lại */
      int tĩnh snd_mychip_pcm_prepare(struct snd_pcm_substream *substream)
      {
              struct mychip *chip = snd_pcm_substream_chip(substream);
              struct snd_pcm_runtime *runtime = substream->runtime;

/* thiết lập phần cứng với cấu hình hiện tại
               * ví dụ...
               */
              mychip_set_sample_format(chip, thời gian chạy->định dạng);
              mychip_set_sample_rate(chip, thời gian chạy->tốc độ);
              mychip_set_channels(chip, thời gian chạy->kênh);
              mychip_set_dma_setup(chip, thời gian chạy->dma_addr,
                                   chip->buffer_size,
                                   chip-> Period_size);
              trả về 0;
      }

/* kích hoạt gọi lại */
      int tĩnh snd_mychip_pcm_trigger(struct snd_pcm_substream *substream,
                                        int cmd)
      {
              chuyển đổi (cmd) {
              vỏ SNDRV_PCM_TRIGGER_START:
                      /* làm gì đó để khởi động động cơ PCM */
                      ....
phá vỡ;
              vỏ SNDRV_PCM_TRIGGER_STOP:
                      /* làm gì đó để dừng động cơ PCM */
                      ....
phá vỡ;
              mặc định:
                      trả về -EINVAL;
              }
      }

/* gọi lại con trỏ */
      snd_pcm_uframes_t tĩnh
      snd_mychip_pcm_pointer(struct snd_pcm_substream *substream)
      {
              struct mychip *chip = snd_pcm_substream_chip(substream);
              unsigned int current_ptr;

/*lấy con trỏ phần cứng hiện tại */
              current_ptr = mychip_get_hw_pointer(chip);
              trả về current_ptr;
      }

/* toán tử */
      cấu trúc tĩnh snd_pcm_ops snd_mychip_playback_ops = {
              .open = snd_mychip_playback_open,
              .close = snd_mychip_playback_close,
              .hw_params = snd_mychip_pcm_hw_params,
              .hw_free = snd_mychip_pcm_hw_free,
              .prepare = snd_mychip_pcm_prepare,
              .trigger = snd_mychip_pcm_trigger,
              .pointer = snd_mychip_pcm_pointer,
      };

/* toán tử */
      cấu trúc tĩnh snd_pcm_ops snd_mychip_capture_ops = {
              .open = snd_mychip_capture_open,
              .close = snd_mychip_capture_close,
              .hw_params = snd_mychip_pcm_hw_params,
              .hw_free = snd_mychip_pcm_hw_free,
              .prepare = snd_mychip_pcm_prepare,
              .trigger = snd_mychip_pcm_trigger,
              .pointer = snd_mychip_pcm_pointer,
      };

/*
       * định nghĩa về việc chụp được bỏ qua ở đây...
       */

/*tạo thiết bị pcm */
      int tĩnh snd_mychip_new_pcm(struct mychip *chip)
      {
              cấu trúc snd_pcm *pcm;
              int lỗi;

err = snd_pcm_new(chip->thẻ, "Chip của tôi", 0, 1, 1, &pcm);
              nếu (lỗi < 0)
                      trả lại lỗi;
              pcm->private_data = chip;
              strcpy(pcm->name, "Chip của tôi");
              chip->pcm = pcm;
              /*thiết lập các toán tử */
              snd_pcm_set_ops(pcm, SNDRV_PCM_STREAM_PLAYBACK,
                              &snd_mychip_playback_ops);
              snd_pcm_set_ops(pcm, SNDRV_PCM_STREAM_CAPTURE,
                              &snd_mychip_capture_ops);
              /* phân bổ trước bộ đệm */
              /* NOTE: điều này có thể thất bại */
              snd_pcm_set_managed_buffer_all(pcm, SNDRV_DMA_TYPE_DEV,
                                             &chip->pci->dev,
                                             64*1024, 64*1024);
              trả về 0;
      }


Trình xây dựng PCM
---------------

Một phiên bản PCM được phân bổ bởi ZZ0000ZZ
chức năng. Sẽ tốt hơn nếu tạo một hàm tạo cho PCM, cụ thể là::

int tĩnh snd_mychip_new_pcm(struct mychip *chip)
  {
          cấu trúc snd_pcm *pcm;
          int lỗi;

err = snd_pcm_new(chip->thẻ, "Chip của tôi", 0, 1, 1, &pcm);
          nếu (lỗi < 0) 
                  trả lại lỗi;
          pcm->private_data = chip;
          strcpy(pcm->name, "Chip của tôi");
          chip->pcm = pcm;
          ...
trả về 0;
  }

Hàm ZZ0000ZZ có sáu đối số. các
đối số đầu tiên là con trỏ thẻ mà PCM này được gán và
thứ hai là chuỗi ID.

Đối số thứ ba (ZZ0000ZZ, 0 ở trên) là chỉ mục của mới này
PCM. Nó bắt đầu từ số không. Nếu bạn tạo nhiều phiên bản PCM,
chỉ định các số khác nhau trong đối số này. Ví dụ: ZZ0001ZZ cho thiết bị PCM thứ hai.

Đối số thứ tư và thứ năm là số lượng luồng con để phát lại
và chụp tương ứng. Ở đây 1 được sử dụng cho cả hai đối số. Khi không
có sẵn các luồng con phát lại hoặc chụp, chuyển 0 cho
luận cứ tương ứng.

Nếu một chip hỗ trợ nhiều lần phát lại hoặc ghi lại, bạn có thể chỉ định thêm
số, nhưng chúng phải được xử lý đúng cách khi mở/đóng, v.v.
cuộc gọi lại. Khi bạn cần biết bạn đang đề cập đến dòng con nào,
thì nó có thể được lấy từ dữ liệu struct snd_pcm_substream được truyền cho mỗi
gọi lại như sau::

struct snd_pcm_substream *dòng phụ;
  chỉ số int = dòng con->số;


Sau khi PCM được tạo, bạn cần đặt toán tử cho mỗi luồng PCM::

snd_pcm_set_ops(pcm, SNDRV_PCM_STREAM_PLAYBACK,
                  &snd_mychip_playback_ops);
  snd_pcm_set_ops(pcm, SNDRV_PCM_STREAM_CAPTURE,
                  &snd_mychip_capture_ops);

Các toán tử được định nghĩa điển hình như thế này::

cấu trúc tĩnh snd_pcm_ops snd_mychip_playback_ops = {
          .open = snd_mychip_pcm_open,
          .close = snd_mychip_pcm_close,
          .hw_params = snd_mychip_pcm_hw_params,
          .hw_free = snd_mychip_pcm_hw_free,
          .prepare = snd_mychip_pcm_prepare,
          .trigger = snd_mychip_pcm_trigger,
          .pointer = snd_mychip_pcm_pointer,
  };

Tất cả các cuộc gọi lại được mô tả trong tiểu mục Operators_.

Sau khi thiết lập các toán tử, có thể bạn sẽ muốn phân bổ trước
đệm và thiết lập chế độ phân bổ được quản lý.
Đối với điều đó, chỉ cần gọi như sau ::

snd_pcm_set_managed_buffer_all(pcm, SNDRV_DMA_TYPE_DEV,
                                 &chip->pci->dev,
                                 64*1024, 64*1024);

Nó sẽ phân bổ bộ đệm lên tới 64kB theo mặc định. Quản lý bộ đệm
chi tiết sẽ được mô tả trong phần sau ZZ0000ZZ.

Ngoài ra, bạn có thể đặt một số thông tin bổ sung cho PCM này trong
ZZ0000ZZ. Các giá trị có sẵn được định nghĩa là
ZZ0001ZZ trong ZZ0002ZZ, được sử dụng cho
định nghĩa phần cứng (được mô tả sau). Khi soundchip của bạn chỉ hỗ trợ
bán song công, hãy chỉ định nó như thế này ::

pcm->info_flags = SNDRV_PCM_INFO_HALF_DUPLEX;


... And the Destructor?
-----------------------

Hàm hủy cho phiên bản PCM không phải lúc nào cũng cần thiết. Kể từ PCM
thiết bị sẽ được giải phóng tự động bởi mã lớp giữa, bạn
không cần phải gọi hàm hủy một cách rõ ràng.

Hàm hủy sẽ cần thiết nếu bạn tạo các bản ghi đặc biệt
nội bộ và cần thiết để giải phóng chúng. Trong trường hợp như vậy, hãy đặt
hàm hủy cho ZZ0000ZZ::

khoảng trống tĩnh mychip_pcm_free(struct snd_pcm *pcm)
      {
              struct mychip *chip = snd_pcm_chip(pcm);
              /* giải phóng dữ liệu của riêng bạn */
              kfree(chip->my_private_pcm_data);
              /*làm những gì bạn thích*/
              ....
      }

int tĩnh snd_mychip_new_pcm(struct mychip *chip)
      {
              cấu trúc snd_pcm *pcm;
              ....
/*phân bổ dữ liệu của riêng bạn */
              chip->my_private_pcm_data = kmalloc(...);
              /*đặt hàm hủy */
              pcm->private_data = chip;
              pcm->private_free = mychip_pcm_free;
              ....
      }



Con trỏ thời gian chạy - Rương thông tin của PCM
----------------------------------------------

Khi dòng con PCM được mở, phiên bản thời gian chạy PCM được phân bổ
và được gán cho dòng con. Con trỏ này có thể truy cập được thông qua
ZZ0000ZZ. Con trỏ thời gian chạy này chứa hầu hết thông tin mà bạn
cần điều khiển PCM: một bản sao của hw_params và sw_params
cấu hình, con trỏ bộ đệm, bản ghi mmap, khóa spin, v.v.

Định nghĩa về phiên bản thời gian chạy được tìm thấy trong ZZ0000ZZ. đây
là phần có liên quan của tập tin này::

cấu trúc _snd_pcm_runtime {
          /* -- Trạng thái -- */
          cấu trúc snd_pcm_substream *trigger_master;
          snd_timestamp_t trigger_tstamp;	/* dấu thời gian kích hoạt */
          int vượt quá phạm vi;
          snd_pcm_uframes_t tận dụng_max;
          snd_pcm_uframes_t hw_ptr_base;	/* Vị trí lúc khởi động lại bộ đệm */
          snd_pcm_uframes_t hw_ptr_interrupt; /*Vị trí tại thời điểm ngắt*/
  
/* -- Thông số HW -- */
          truy cập snd_pcm_access_t;	/*chế độ truy cập */
          định dạng snd_pcm_format_t;	/*SNDRV_PCM_FORMAT_* */
          định dạng con snd_pcm_subformat_t;	/* dạng con */
          tỷ lệ int không dấu;		/* tốc độ tính bằng Hz */
          kênh int không dấu;		/* kênh */
          snd_pcm_uframes_t Period_size;	/* kích thước dấu chấm */
          dấu chấm int không dấu;		/* dấu chấm */
          snd_pcm_uframes_t buffer_size;	/* kích thước bộ đệm */
          int không dấu tích_time;		/*đánh dấu thời gian*/
          snd_pcm_uframes_t phút_align;	/* Căn chỉnh tối thiểu cho định dạng */
          size_t byte_align;
          unsigned int frame_bits;
          mẫu int không dấu_bits;
          thông tin int không dấu;
          int rate_num không dấu;
          unsign int rate_den;
  
/* -- Thông số SW -- */
          cấu trúc timespec tstamp_mode;	/* Dấu thời gian mmap được cập nhật */
          unsign int Period_step;
          unsign int sleep_min;		/* phút tích tắc để ngủ */
          snd_pcm_uframes_t start_threshold;
          /*
           * Hai ngưỡng sau đây giúp giảm bớt tình trạng chạy dưới bộ đệm phát lại; khi nào
           * hw_avail giảm xuống dưới ngưỡng, hành động tương ứng sẽ được kích hoạt:
           */
          snd_pcm_uframes_t stop_threshold;	/* - dừng phát lại */
          snd_pcm_uframes_t im lặng_threshold;	/* - điền trước bộ đệm bằng khoảng lặng */
          snd_pcm_uframes_t Silence_size;       /* kích thước tối đa của khoảng trống điền trước; khi >= ranh giới,
                                                 * lấp đầy khu vực chơi bằng sự im lặng ngay lập tức */
          ranh giới snd_pcm_uframes_t;	/*điểm bao bọc của con trỏ */
  
/*dữ liệu nội bộ của bộ giảm thanh tự động */
          snd_pcm_uframes_t Silence_start; /* Con trỏ bắt đầu tới vùng im lặng */
          snd_pcm_uframes_t Silence_fill; /* kích thước tràn ngập sự im lặng */
  
đồng bộ hóa snd_pcm_sync_id_t;		/* ID đồng bộ hóa phần cứng */
  
/* -- mmap -- */
          cấu trúc dễ bay hơi snd_pcm_mmap_status * trạng thái;
          cấu trúc dễ bay hơi snd_pcm_mmap_control *control;
          nguyên tử_t mmap_count;
  
/* -- khóa / lập lịch -- */
          khóa spinlock_t;
          wait_queue_head_t ngủ;
          cấu trúc bộ đếm thời gian_list tick_timer;
          struct fasync_struct *fasync;

/* -- phần riêng tư -- */
          void *private_data;
          khoảng trống (*private_free)(struct snd_pcm_runtime *runtime);
  
/* -- mô tả phần cứng -- */
          cấu trúc snd_pcm_hardware hw;
          cấu trúc snd_pcm_hw_constraint hw_constraint;
  
/* -- đồng hồ bấm giờ -- */
          int unsigned_độ phân giải;	/*độ phân giải của bộ đếm thời gian */
  
/* -- DMA -- */           
          vùng ký tự không dấu ZZ0000ZZ DMA */
          dma_addr_t dma_addr;		/* địa chỉ bus vật lý (không thể truy cập từ CPU chính) */
          size_t dma_byte;		/* kích thước của vùng DMA */
  
struct snd_dma_buffer ZZ0000ZZ bộ đệm được phân bổ */
  
#if được xác định(CONFIG_SND_PCM_OSS) || được xác định (CONFIG_SND_PCM_OSS_MODULE)
          /* -- OSS các thứ -- */
          cấu trúc snd_pcm_oss_runtime oss;
  #endif
  };


Đối với người vận hành (gọi lại) của từng trình điều khiển âm thanh, hầu hết trong số này
hồ sơ được cho là chỉ đọc. Chỉ có lớp giữa PCM thay đổi
/ cập nhật chúng. Các trường hợp ngoại lệ là mô tả phần cứng (hw) DMA
thông tin đệm và dữ liệu riêng tư. Ngoài ra, nếu bạn sử dụng
chế độ phân bổ bộ đệm được quản lý tiêu chuẩn, bạn không cần thiết lập
Thông tin bộ đệm DMA do chính bạn cung cấp.

Trong các phần bên dưới, các hồ sơ quan trọng sẽ được giải thích.

Mô tả phần cứng
~~~~~~~~~~~~~~~~~~~~

Bộ mô tả phần cứng (struct snd_pcm_hardware) chứa các định nghĩa về
cấu hình phần cứng cơ bản. Trên hết, bạn sẽ cần xác định điều này
trong ZZ0001ZZ. Lưu ý rằng phiên bản thời gian chạy chứa một bản sao của
bộ mô tả, không phải là con trỏ tới bộ mô tả hiện có. Đó là,
trong cuộc gọi lại mở, bạn có thể sửa đổi bộ mô tả đã sao chép
(ZZ0000ZZ) khi bạn cần. Ví dụ: nếu số lượng tối đa
kênh chỉ là 1 trên một số mẫu chip, bạn vẫn có thể sử dụng kênh tương tự
mô tả phần cứng và thay đổi các kênh_max sau::

struct snd_pcm_runtime *runtime = substream->runtime;
          ...
thời gian chạy->hw = snd_mychip_playback_hw; /*định nghĩa chung */
          if (chip->model == VERY_OLD_ONE)
                  thời gian chạy->hw.channels_max = 1;

Thông thường, bạn sẽ có bộ mô tả phần cứng như sau::

cấu trúc tĩnh snd_pcm_hardware snd_mychip_playback_hw = {
          .info = (SNDRV_PCM_INFO_MMAP |
                   SNDRV_PCM_INFO_INTERLEAVED |
                   SNDRV_PCM_INFO_BLOCK_TRANSFER |
                   SNDRV_PCM_INFO_MMAP_VALID),
          .format = SNDRV_PCM_FMTBIT_S16_LE,
          .giá = SNDRV_PCM_RATE_8000_48000,
          .rate_min = 8000,
          .rate_max = 48000,
          .channels_min = 2,
          .channels_max = 2,
          .buffer_bytes_max = 32768,
          . Period_bytes_min = 4096,
          . Period_bytes_max = 32768,
          .thời gian_min = 1,
          .thời gian_max = 1024,
  };

- Trường ZZ0000ZZ chứa loại và khả năng của điều này
   PCM. Cờ bit được định nghĩa trong ZZ0001ZZ là
   ZZ0002ZZ. Ở đây, ít nhất, bạn phải xác định liệu
   mmap được hỗ trợ và các định dạng xen kẽ nào được hỗ trợ
   được hỗ trợ. Khi phần cứng hỗ trợ mmap, hãy thêm
   Cờ ZZ0003ZZ tại đây. Khi phần cứng hỗ trợ
   các định dạng xen kẽ hoặc không xen kẽ,
   ZZ0004ZZ hoặc ZZ0005ZZ
   cờ phải được đặt tương ứng. Nếu cả hai đều được hỗ trợ, bạn có thể đặt
   cả hai nữa.

Trong ví dụ trên, ZZ0000ZZ và ZZ0001ZZ là
   được chỉ định cho chế độ mmap OSS. Thông thường cả hai đều được thiết lập. Tất nhiên,
   ZZ0002ZZ chỉ được đặt nếu mmap thực sự được hỗ trợ.

Các cờ có thể khác là ZZ0000ZZ và
   ZZ0001ZZ. Bit ZZ0002ZZ có nghĩa là PCM
   hỗ trợ hoạt động “tạm dừng”, trong khi bit ZZ0003ZZ có nghĩa là
   PCM hỗ trợ toàn bộ thao tác “tạm dừng/tiếp tục”. Nếu
   Cờ ZZ0004ZZ được đặt, lệnh gọi lại ZZ0005ZZ bên dưới phải xử lý
   các lệnh tương ứng (tạm dừng đẩy/nhả). Việc đình chỉ/tiếp tục
   lệnh kích hoạt có thể được xác định ngay cả khi không có ZZ0006ZZ
   cờ. Xem phần ZZ0007ZZ để biết chi tiết.

Khi các dòng con PCM có thể được đồng bộ hóa (thông thường,
   bắt đầu/dừng đồng bộ hóa quá trình phát lại và luồng chụp), bạn
   cũng có thể tặng ZZ0000ZZ. Trong trường hợp này, bạn sẽ
   cần kiểm tra danh sách liên kết của các luồng con PCM trong trình kích hoạt
   gọi lại. Điều này sẽ được mô tả ở phần sau.

- Trường ZZ0000ZZ chứa cờ bit của các định dạng được hỗ trợ
   (ZZ0001ZZ). Nếu phần cứng hỗ trợ nhiều hơn một
   định dạng, cung cấp tất cả các bit hoặc'ed. Trong ví dụ trên, 16bit đã ký
   định dạng little-endian được chỉ định.

- Trường ZZ0000ZZ chứa cờ bit của tốc độ được hỗ trợ
   (ZZ0001ZZ). Khi chip hỗ trợ tốc độ liên tục,
   chuyển thêm bit ZZ0002ZZ. Các bit tốc độ được xác định trước
   chỉ được cung cấp cho mức giá thông thường. Nếu chip của bạn hỗ trợ
   tỷ lệ độc đáo, bạn cần thêm bit ZZ0003ZZ và thiết lập
   ràng buộc phần cứng theo cách thủ công (được giải thích sau).

- ZZ0000ZZ và ZZ0001ZZ xác định mẫu tối thiểu và tối đa
   tỷ lệ. Điều này sẽ tương ứng bằng cách nào đó với các bit ZZ0002ZZ.

- Định nghĩa ZZ0000ZZ và ZZ0001ZZ, như bạn có thể đã định nghĩa
   dự kiến, số lượng kênh tối thiểu và tối đa.

- ZZ0000ZZ xác định kích thước bộ đệm tối đa trong
   byte. Không có trường ZZ0001ZZ vì nó có thể
   được tính từ quy mô kỳ tối thiểu và số lượng tối thiểu của
   thời kỳ. Trong khi đó, ZZ0002ZZ và ZZ0003ZZ
   xác định kích thước tối thiểu và tối đa của khoảng thời gian tính bằng byte.
   ZZ0004ZZ và ZZ0005ZZ xác định mức tối đa và tối thiểu
   số chu kỳ trong bộ đệm.

“Thời kỳ” là một thuật ngữ tương ứng với một đoạn trong OSS
   thế giới. Khoảng thời gian xác định thời điểm tại đó ngắt PCM được thực hiện
   được tạo ra. Điểm này phụ thuộc nhiều vào phần cứng. Nói chung,
   kích thước khoảng thời gian nhỏ hơn sẽ mang lại cho bạn nhiều gián đoạn hơn, kết quả là
   trong việc có thể lấp đầy/xóa bộ đệm kịp thời hơn. Trong trường hợp của
   chụp, kích thước này xác định độ trễ đầu vào. Mặt khác,
   toàn bộ kích thước bộ đệm xác định độ trễ đầu ra để phát lại
   hướng.

- Ngoài ra còn có trường ZZ0000ZZ. Điều này xác định kích thước của
   phần cứng FIFO, nhưng hiện tại nó không được trình điều khiển sử dụng cũng như không
   trong alsa-lib. Vì vậy, bạn có thể bỏ qua trường này.

Cấu hình PCM
~~~~~~~~~~~~~~~~~~

Được rồi, hãy quay lại bản ghi thời gian chạy PCM. nhất
các bản ghi thường được nhắc đến trong phiên bản thời gian chạy là PCM
cấu hình. Cấu hình PCM được lưu trữ trong thời gian chạy
dụ sau khi ứng dụng gửi dữ liệu ZZ0000ZZ qua
alsa-lib. Có nhiều trường được sao chép từ hw_params và sw_params
cấu trúc. Ví dụ: ZZ0001ZZ giữ loại định dạng được chọn bởi
ứng dụng. Trường này chứa giá trị enum
ZZ0002ZZ.

Một điều cần lưu ý là kích thước bộ đệm và khoảng thời gian được định cấu hình
được lưu trữ trong các “khung” trong thời gian chạy. Trong thế giới ALSA, ZZ0002ZZ. Để chuyển đổi giữa các khung và byte,
bạn có thể sử dụng ZZ0000ZZ và
Chức năng trợ giúp ZZ0001ZZ::

Period_bytes = frame_to_bytes(thời gian chạy, thời gian chạy-> Period_size);

Ngoài ra, nhiều tham số phần mềm (sw_params) cũng được lưu trữ trong khung.
Vui lòng kiểm tra loại trường. ZZ0000ZZ dành cho
khung dưới dạng số nguyên không dấu trong khi ZZ0001ZZ dành cho
khung dưới dạng số nguyên có dấu.

Thông tin bộ đệm DMA
~~~~~~~~~~~~~~~~~~~~~~

Bộ đệm DMA được xác định bởi bốn trường sau: ZZ0001ZZ,
ZZ0002ZZ, ZZ0003ZZ và ZZ0004ZZ. ZZ0005ZZ
giữ con trỏ đệm (địa chỉ logic). Bạn có thể gọi
ZZ0000ZZ từ/đến con trỏ này. Trong khi đó, ZZ0006ZZ giữ
địa chỉ vật lý của bộ đệm. Trường này chỉ được chỉ định khi
bộ đệm là bộ đệm tuyến tính. ZZ0007ZZ giữ kích thước của
bộ đệm theo byte. ZZ0008ZZ được sử dụng cho bộ cấp phát ALSA DMA.

Nếu bạn sử dụng chế độ phân bổ bộ đệm được quản lý hoặc chế độ tiêu chuẩn
API Chức năng ZZ0000ZZ để phân bổ bộ đệm,
các trường này được thiết lập bởi lớp giữa ALSA và bạn nên ZZ0004ZZ
tự mình thay đổi chúng. Bạn có thể đọc chúng nhưng không thể viết chúng. Trên
Mặt khác, nếu bạn muốn tự mình phân bổ bộ đệm, bạn sẽ
cần quản lý nó trong cuộc gọi lại hw_params. Ít nhất thì ZZ0001ZZ là
bắt buộc. ZZ0002ZZ là cần thiết khi bộ đệm được thêm vào. Nếu
trình điều khiển của bạn không hỗ trợ mmap, trường này không hỗ trợ
cần thiết. ZZ0003ZZ cũng là tùy chọn. Bạn có thể sử dụng dma_private làm
bạn cũng thích.

Trạng thái chạy
~~~~~~~~~~~~~~

Trạng thái đang chạy có thể được tham chiếu qua ZZ0000ZZ. Đây là
một con trỏ tới bản ghi struct snd_pcm_mmap_status.
Ví dụ: bạn có thể nhận được hiện tại
Con trỏ phần cứng DMA thông qua ZZ0001ZZ.

Con trỏ ứng dụng DMA có thể được giới thiệu qua ZZ0000ZZ,
trỏ tới bản ghi struct snd_pcm_mmap_control.
Tuy nhiên, việc truy cập trực tiếp vào giá trị này không được khuyến khích.

Dữ liệu riêng tư
~~~~~~~~~~~~

Bạn có thể phân bổ một bản ghi cho luồng con và lưu trữ nó trong
ZZ0000ZZ. Thông thường, việc này được thực hiện trong ZZ0004ZZ. Đừng trộn cái này với ZZ0001ZZ. các
ZZ0002ZZ thường trỏ đến phiên bản chip được chỉ định
tĩnh tại thời điểm tạo thiết bị PCM, trong khi
ZZ0003ZZ
trỏ đến cấu trúc dữ liệu động được tạo trong PCM mở
gọi lại::

int tĩnh snd_xxx_open(struct snd_pcm_substream *substream)
  {
          cấu trúc dữ liệu my_pcm_data *;
          ....
dữ liệu = kmalloc(sizeof(*data), GFP_KERNEL);
          dòng phụ->thời gian chạy->private_data = dữ liệu;
          ....
  }


Đối tượng được phân bổ phải được giải phóng trong ZZ0000ZZ.

Toán tử
---------

Được rồi, bây giờ hãy để tôi cung cấp thông tin chi tiết về từng lệnh gọi lại PCM (ZZ0000ZZ). trong
nói chung, mọi lệnh gọi lại phải trả về 0 nếu thành công hoặc âm
số lỗi chẳng hạn như ZZ0001ZZ. Để chọn một lỗi thích hợp
số, nên kiểm tra giá trị của các phần khác của kernel
quay lại khi cùng loại yêu cầu không thành công.

Mỗi hàm gọi lại có ít nhất một đối số chứa
con trỏ struct snd_pcm_substream. Để lấy lại chip
record từ phiên bản dòng con đã cho, bạn có thể sử dụng cách sau
vĩ mô::

int xxx(...) {
          struct mychip *chip = snd_pcm_substream_chip(substream);
          ....
  }

Macro đọc ZZ0000ZZ, đây là bản sao của
ZZ0001ZZ. Bạn có thể ghi đè lên cái trước nếu bạn cần
chỉ định các bản ghi dữ liệu khác nhau cho mỗi luồng con PCM. Ví dụ,
Trình điều khiển cmi8330 gán ZZ0002ZZ khác nhau để phát lại và
nắm bắt hướng, bởi vì nó sử dụng hai codec khác nhau (SB- và
Tương thích với AD) cho các hướng khác nhau.

PCM mở cuộc gọi lại
~~~~~~~~~~~~~~~~~

::

int tĩnh snd_xxx_open(struct snd_pcm_substream *substream);

Điều này được gọi khi dòng con PCM được mở.

Ít nhất ở đây bạn phải khởi tạo ZZ0000ZZ
ghi lại. Thông thường, việc này được thực hiện như thế này::

int tĩnh snd_xxx_open(struct snd_pcm_substream *substream)
  {
          struct mychip *chip = snd_pcm_substream_chip(substream);
          struct snd_pcm_runtime *runtime = substream->runtime;

thời gian chạy->hw = snd_mychip_playback_hw;
          trả về 0;
  }

trong đó ZZ0000ZZ là phần cứng được xác định trước
mô tả.

Bạn có thể phân bổ dữ liệu riêng tư trong lệnh gọi lại này, như được mô tả trong
Phần ZZ0000ZZ.

Nếu cấu hình phần cứng cần nhiều ràng buộc hơn, hãy đặt cấu hình phần cứng
những hạn chế ở đây cũng vậy. Xem Ràng buộc_ để biết thêm chi tiết.

đóng cuộc gọi lại
~~~~~~~~~~~~~~

::

int tĩnh snd_xxx_close(struct snd_pcm_substream *substream);


Rõ ràng, điều này được gọi khi dòng con PCM bị đóng.

Bất kỳ phiên bản riêng tư nào cho luồng con PCM được phân bổ trong ZZ0000ZZ
cuộc gọi lại sẽ được phát hành tại đây::

int tĩnh snd_xxx_close(struct snd_pcm_substream *substream)
  {
          ....
kfree(substream->runtime->private_data);
          ....
  }

gọi lại ioctl
~~~~~~~~~~~~~~

Điều này được sử dụng cho bất kỳ cuộc gọi đặc biệt nào tới PCM ioctls. Nhưng thông thường bạn có thể
cứ để nó NULL, sau đó lõi PCM gọi callback ioctl chung
chức năng ZZ0000ZZ.  Nếu bạn cần giải quyết một
thiết lập duy nhất thông tin kênh hoặc quy trình đặt lại, bạn có thể vượt qua thông tin kênh của riêng mình
chức năng gọi lại ở đây.

gọi lại hw_params
~~~~~~~~~~~~~~~~~~~

::

int tĩnh snd_xxx_hw_params(struct snd_pcm_substream *substream,
                               cấu trúc snd_pcm_hw_params *hw_params);

Điều này được gọi khi các tham số phần cứng (ZZ0000ZZ) được thiết lập
bởi ứng dụng, nghĩa là, một khi kích thước bộ đệm, khoảng thời gian
kích thước, định dạng, v.v. được xác định cho luồng con PCM.

Nhiều thiết lập phần cứng phải được thực hiện trong lệnh gọi lại này, bao gồm cả
phân bổ bộ đệm.

Các tham số được khởi tạo sẽ được truy xuất bởi
Macro ZZ0000ZZ.

Khi bạn chọn chế độ phân bổ bộ đệm được quản lý cho luồng con,
bộ đệm đã được phân bổ trước khi lệnh gọi lại này được thực hiện
được gọi. Ngoài ra, bạn có thể gọi một hàm trợ giúp bên dưới để
phân bổ bộ đệm::

snd_pcm_lib_malloc_pages(dòng con, params_buffer_bytes(hw_params));

ZZ0000ZZ chỉ khả dụng khi
Bộ đệm DMA đã được phân bổ trước. Xem phần ZZ0001ZZ
để biết thêm chi tiết.

Lưu ý rằng lệnh gọi lại này và lệnh gọi lại ZZ0000ZZ có thể được gọi là nhiều
lần mỗi lần khởi tạo. Ví dụ: mô phỏng OSS có thể gọi đây là
cuộc gọi lại ở mỗi thay đổi thông qua ioctl của nó.

Vì vậy, bạn cần phải cẩn thận để không phân bổ nhiều bộ đệm giống nhau.
lần, điều này sẽ dẫn đến rò rỉ bộ nhớ! Gọi hàm trợ giúp
trên nhiều lần là được. Nó sẽ giải phóng bộ đệm trước đó
tự động khi nó đã được phân bổ.

Một lưu ý khác là cuộc gọi lại này không mang tính nguyên tử (có thể lập lịch) bởi
mặc định, tức là khi không có cờ ZZ0000ZZ nào được đặt. Điều này quan trọng,
vì lệnh gọi lại ZZ0001ZZ là nguyên tử (không thể lập lịch). Đó là,
mutexes hoặc bất kỳ chức năng nào liên quan đến lịch trình đều không có sẵn trong
Gọi lại ZZ0002ZZ. Vui lòng xem tiểu mục Atomicity_ để biết
chi tiết.

hw_free gọi lại
~~~~~~~~~~~~~~~~~

::

int tĩnh snd_xxx_hw_free(struct snd_pcm_substream *substream);

Điều này được gọi để giải phóng các tài nguyên được phân bổ thông qua
ZZ0000ZZ.

Hàm này luôn được gọi trước khi gọi lại lệnh đóng.
Ngoài ra, lệnh gọi lại cũng có thể được gọi nhiều lần. Theo dõi
liệu mỗi tài nguyên đã được phát hành hay chưa.

Khi bạn đã chọn chế độ phân bổ bộ đệm được quản lý cho PCM
luồng con, bộ đệm PCM được phân bổ sẽ tự động được giải phóng
sau khi cuộc gọi lại này được gọi.  Nếu không bạn sẽ phải phát hành
đệm bằng tay.  Thông thường, khi bộ đệm được cấp phát từ
nhóm được phân bổ trước, bạn có thể sử dụng chức năng API tiêu chuẩn
ZZ0000ZZ thích::

snd_pcm_lib_free_pages(dòng phụ);

chuẩn bị gọi lại
~~~~~~~~~~~~~~~~

::

int tĩnh snd_xxx_prepare(struct snd_pcm_substream *substream);

Cuộc gọi lại này được gọi khi PCM được "chuẩn bị". Bạn có thể thiết lập
loại định dạng, tốc độ mẫu, v.v. tại đây. Sự khác biệt so với ZZ0001ZZ
là lệnh gọi lại ZZ0002ZZ sẽ được gọi mỗi lần
ZZ0000ZZ được gọi, tức là khi khôi phục sau
chạy ngầm, v.v.

Lưu ý rằng cuộc gọi lại này không mang tính nguyên tử. Bạn có thể sử dụng
các chức năng liên quan đến lịch trình một cách an toàn trong lệnh gọi lại này.

Trong cuộc gọi lại này và các cuộc gọi lại sau, bạn có thể tham khảo các giá trị thông qua
bản ghi thời gian chạy, ZZ0000ZZ. Ví dụ, để có được
tốc độ, định dạng hoặc kênh hiện tại, truy cập vào ZZ0001ZZ,
ZZ0002ZZ hoặc ZZ0003ZZ tương ứng. các
địa chỉ vật lý của bộ đệm được phân bổ được đặt thành
ZZ0004ZZ. Kích thước bộ đệm và khoảng thời gian nằm trong
ZZ0005ZZ và ZZ0006ZZ tương ứng.

Hãy cẩn thận rằng lệnh gọi lại này sẽ được gọi nhiều lần trong mỗi lần thiết lập,
quá.

kích hoạt gọi lại
~~~~~~~~~~~~~~~~

::

int tĩnh snd_xxx_trigger(struct snd_pcm_substream *substream, int cmd);

Điều này được gọi khi PCM được khởi động, dừng hoặc tạm dừng.

Hành động được chỉ định trong đối số thứ hai, ZZ0000ZZ
được xác định trong ZZ0001ZZ. Ít nhất là ZZ0002ZZ
và các lệnh ZZ0003ZZ phải được xác định trong lệnh gọi lại này ::

chuyển đổi (cmd) {
  vỏ SNDRV_PCM_TRIGGER_START:
          /* làm gì đó để khởi động động cơ PCM */
          phá vỡ;
  vỏ SNDRV_PCM_TRIGGER_STOP:
          /* làm gì đó để dừng động cơ PCM */
          phá vỡ;
  mặc định:
          trả về -EINVAL;
  }

Khi PCM hỗ trợ thao tác tạm dừng (được cung cấp trong trường thông tin của
bảng phần cứng), các lệnh ZZ0000ZZ và ZZ0001ZZ
cũng phải xử lý ở đây. Trước đây là lệnh tạm dừng PCM,
và cái sau để khởi động lại PCM một lần nữa.

Khi PCM hỗ trợ hoạt động tạm dừng/tiếp tục, bất kể
hoặc hỗ trợ tạm dừng/tiếp tục một phần, ZZ0000ZZ và ZZ0001ZZ
các lệnh cũng phải được xử lý. Các lệnh này được đưa ra khi
trạng thái quản lý nguồn được thay đổi. Rõ ràng, ZZ0002ZZ và
Các lệnh ZZ0003ZZ tạm dừng và tiếp tục luồng phụ PCM và thông thường,
chúng giống hệt với các lệnh ZZ0004ZZ và ZZ0005ZZ tương ứng.
Xem phần ZZ0006ZZ để biết chi tiết.

Như đã đề cập, lệnh gọi lại này theo mặc định là nguyên tử trừ khi ZZ0000ZZ
đặt cờ và bạn không thể gọi các chức năng có thể ngủ. các
Cuộc gọi lại ZZ0001ZZ phải ở mức tối thiểu nhất có thể, thực sự
kích hoạt DMA. Những thứ khác nên được khởi tạo trong
Gọi lại ZZ0002ZZ và ZZ0003ZZ đúng cách trước đó.

gọi lại sync_stop
~~~~~~~~~~~~~~~~~~

::

int tĩnh snd_xxx_sync_stop(struct snd_pcm_substream *substream);

Cuộc gọi lại này là tùy chọn và NULL có thể được thông qua.  Nó được gọi theo tên
lõi PCM dừng luồng trước khi nó thay đổi trạng thái luồng thông qua
ZZ0001ZZ, ZZ0002ZZ hoặc ZZ0003ZZ.
Vì trình xử lý IRQ có thể vẫn đang chờ xử lý nên chúng ta cần đợi cho đến khi
nhiệm vụ đang chờ xử lý kết thúc trước khi chuyển sang bước tiếp theo; nếu không thì nó
có thể dẫn đến sự cố do xung đột tài nguyên hoặc truy cập vào giải phóng
tài nguyên.  Một hành vi điển hình là gọi hàm đồng bộ hóa
như ZZ0000ZZ ở đây.

Đối với phần lớn các tài xế chỉ cần một cuộc gọi
ZZ0000ZZ, cũng có cách thiết lập đơn giản hơn.
Trong khi vẫn giữ lệnh gọi lại ZZ0002ZZ PCM NULL, trình điều khiển có thể đặt
trường ZZ0003ZZ sang số ngắt được trả về sau
thay vào đó hãy yêu cầu IRQ.   Sau đó lõi PCM sẽ gọi
ZZ0001ZZ với IRQ đã cho một cách thích hợp.

Nếu trình xử lý IRQ được giải phóng bởi trình hủy thẻ, bạn không cần
để xóa ZZ0000ZZ vì bản thân thẻ đang được phát hành.
Vì vậy, thông thường bạn chỉ cần thêm một dòng để gán
ZZ0001ZZ trong mã trình điều khiển trừ khi trình điều khiển lấy lại
IRQ.  Khi trình điều khiển giải phóng và thu lại IRQ một cách linh hoạt
(ví dụ: tạm dừng/tiếp tục), cần xóa và đặt lại
ZZ0002ZZ một lần nữa một cách thích hợp.

gọi lại con trỏ
~~~~~~~~~~~~~~~~

::

snd_pcm_uframes_t tĩnh snd_xxx_pointer(struct snd_pcm_substream *substream)

Cuộc gọi lại này được gọi khi lớp giữa PCM hỏi hiện tại
vị trí phần cứng trong bộ đệm. Vị trí phải được trả lại trong
khung, từ 0 đến ZZ0000ZZ.

Điều này thường được gọi từ quy trình cập nhật bộ đệm trong PCM
lớp giữa, được gọi khi ZZ0000ZZ
được gọi bởi chương trình ngắt. Sau đó, lớp giữa PCM cập nhật
vị trí và tính toán không gian có sẵn, đồng thời đánh thức
chủ đề thăm dò ý kiến đang ngủ, v.v.

Cuộc gọi lại này cũng là nguyên tử theo mặc định.

sao chép và fill_silence hoạt động
~~~~~~~~~~~~~~~~~~~~~~~~~

Những lệnh gọi lại này không bắt buộc và có thể được bỏ qua trong hầu hết các trường hợp.
Những cuộc gọi lại này được sử dụng khi bộ đệm phần cứng không thể ở trong
không gian bộ nhớ bình thường. Một số chip có bộ đệm riêng trong phần cứng
không thể lập bản đồ được. Trong trường hợp đó, bạn phải chuyển dữ liệu
thủ công từ bộ nhớ đệm đến bộ đệm phần cứng. Hoặc, nếu
bộ đệm không liền kề trên cả không gian bộ nhớ vật lý và ảo,
những cuộc gọi lại này cũng phải được xác định.

Nếu hai lệnh gọi lại này được xác định, các thao tác sao chép và đặt im lặng
được thực hiện bởi họ. Chi tiết sẽ được mô tả ở phần sau
ZZ0000ZZ.

gọi lại xác nhận
~~~~~~~~~~~~

Cuộc gọi lại này cũng không bắt buộc. Cuộc gọi lại này được gọi khi
ZZ0000ZZ được cập nhật trong hoạt động đọc hoặc ghi. Một số trình điều khiển thích
emu10k1-fx và cs46xx cần theo dõi ZZ0001ZZ hiện tại để biết
bộ đệm nội bộ và lệnh gọi lại này chỉ hữu ích cho mục đích đó.

Hàm gọi lại có thể trả về 0 hoặc lỗi âm. Khi
giá trị trả về là ZZ0000ZZ, lõi PCM coi đó là bộ đệm XRUN,
và tự động thay đổi trạng thái thành ZZ0001ZZ.

Cuộc gọi lại này là nguyên tử theo mặc định.

gọi lại trang
~~~~~~~~~~~~~

Cuộc gọi lại này cũng là tùy chọn. Mmap gọi cuộc gọi lại này để nhận
địa chỉ lỗi trang.

Bạn không cần gọi lại đặc biệt cho bộ đệm SG hoặc vmalloc- tiêu chuẩn
bộ đệm. Do đó, cuộc gọi lại này hiếm khi được sử dụng.

gọi lại mmap
~~~~~~~~~~~~~

Đây là một lệnh gọi lại tùy chọn khác để kiểm soát hành vi mmap.
Khi được xác định, lõi PCM sẽ gọi lại lệnh gọi lại này khi một trang được
ánh xạ bộ nhớ, thay vì sử dụng trình trợ giúp tiêu chuẩn.
Nếu bạn cần xử lý đặc biệt (do một số kiến trúc hoặc
các vấn đề dành riêng cho thiết bị), hãy triển khai mọi thứ ở đây theo ý muốn.


Trình xử lý ngắt PCM
---------------------

Phần còn lại của nội dung PCM là trình xử lý ngắt PCM. Vai trò
của PCM
trình xử lý ngắt trong trình điều khiển âm thanh là cập nhật vị trí bộ đệm
và thông báo cho lớp giữa PCM khi vị trí bộ đệm đi qua
ranh giới thời kỳ xác định. Để thông báo về điều này, hãy gọi
Chức năng ZZ0000ZZ.

Có một số cách mà chip âm thanh có thể tạo ra sự gián đoạn.

Ngắt ở ranh giới giai đoạn (đoạn)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Đây là loại thường gặp nhất: phần cứng tạo ra một
ngắt tại mỗi ranh giới thời kỳ. Trong trường hợp này, bạn có thể gọi
ZZ0000ZZ tại mỗi lần ngắt.

ZZ0000ZZ lấy con trỏ dòng phụ là
lập luận của nó. Vì vậy, bạn cần giữ con trỏ dòng con có thể truy cập được
từ phiên bản chip. Ví dụ: xác định trường ZZ0001ZZ trong
bản ghi chip để giữ con trỏ luồng phụ đang chạy hiện tại và đặt
giá trị con trỏ khi gọi lại ZZ0002ZZ (và đặt lại khi gọi lại ZZ0003ZZ).

Nếu bạn có được một khóa xoay trong trình xử lý ngắt và khóa được sử dụng
trong các cuộc gọi lại PCM khác cũng vậy, thì bạn phải nhả khóa trước
gọi ZZ0000ZZ, bởi vì
ZZ0001ZZ gọi các cuộc gọi lại PCM khác
bên trong.

Mã điển hình sẽ trông giống như::


irqreturn_t tĩnh snd_mychip_interrupt(int irq, void *dev_id)
      {
              struct mychip *chip = dev_id;
              spin_lock(&chip->lock);
              ....
nếu (pcm_irq_invoked(chip)) {
                      /* gọi trình cập nhật, mở khóa trước nó */
                      spin_unlock(&chip->lock);
                      snd_pcm_ Period_elapsed(chip->substream);
                      spin_lock(&chip->lock);
                      /* xác nhận ngắt nếu cần thiết */
              }
              ....
spin_unlock(&chip->lock);
              trả lại IRQ_HANDLED;
      }

Ngoài ra, khi thiết bị có thể phát hiện lỗi thiếu/tràn bộ đệm, trình điều khiển
có thể thông báo trạng thái XRUN tới lõi PCM bằng cách gọi
ZZ0000ZZ. Chức năng này dừng luồng và đặt
trạng thái PCM thành ZZ0001ZZ. Lưu ý rằng nó phải được gọi
bên ngoài khóa luồng PCM, do đó không thể gọi nó từ nguyên tử
gọi lại.


Ngắt hẹn giờ tần số cao
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Điều này xảy ra khi phần cứng không tạo ra ngắt tại thời điểm đó
ranh giới nhưng gây ra các ngắt hẹn giờ ở tốc độ hẹn giờ cố định (ví dụ: es1968
hoặc trình điều khiển ymfpci). Trong trường hợp này, bạn cần kiểm tra phần cứng hiện tại
định vị và tích lũy chiều dài mẫu đã xử lý tại mỗi lần ngắt.
Khi kích thước tích lũy vượt quá kích thước thời gian, hãy gọi
ZZ0000ZZ và đặt lại bộ tích lũy.

Mã điển hình sẽ trông như sau::


irqreturn_t tĩnh snd_mychip_interrupt(int irq, void *dev_id)
      {
              struct mychip *chip = dev_id;
              spin_lock(&chip->lock);
              ....
nếu (pcm_irq_invoked(chip)) {
                      unsigned int Last_ptr, kích thước;
                      /* lấy con trỏ phần cứng hiện tại (trong khung) */
                      Last_ptr = get_hw_ptr(chip);
                      /* tính toán các khung được xử lý kể từ
                       * cập nhật lần cuối
                       */
                      nếu (last_ptr < chip->last_ptr)
                              kích thước = thời gian chạy->buffer_size + Last_ptr
                                       - chip->last_ptr;
                      khác
                              kích thước = Last_ptr - chip->last_ptr;
                      /*nhớ điểm cập nhật gần đây nhất*/
                      chip->last_ptr = Last_ptr;
                      /* tích lũy kích thước */
                      chip->kích thước += kích thước;
                      /* qua ranh giới thời kỳ? */
                      if (chip->size >= thời gian chạy-> Period_size) {
                              /*đặt lại bộ tích lũy */
                              chip->size %= thời gian chạy-> Period_size;
                              /* trình cập nhật cuộc gọi */
                              spin_unlock(&chip->lock);
                              snd_pcm_ Period_elapsed(substream);
                              spin_lock(&chip->lock);
                      }
                      /* xác nhận ngắt nếu cần thiết */
              }
              ....
spin_unlock(&chip->lock);
              trả lại IRQ_HANDLED;
      }



Khi gọi ZZ0000ZZ
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Trong cả hai trường hợp, ngay cả khi đã hơn một kỳ học trôi qua, bạn vẫn không có
để gọi ZZ0000ZZ nhiều lần. Chỉ gọi
một lần. Và lớp PCM sẽ kiểm tra con trỏ phần cứng hiện tại và
cập nhật trạng thái mới nhất.

Tính nguyên tử
---------

Một trong những vấn đề quan trọng nhất (và do đó khó gỡ lỗi) trong
lập trình hạt nhân là điều kiện chạy đua. Trong nhân Linux, chúng là
thường được tránh thông qua khóa xoay, mutexes hoặc semaphores. Nói chung, nếu một
điều kiện chủng tộc có thể xảy ra trong trình xử lý ngắt, nó phải được quản lý
về mặt nguyên tử và bạn phải sử dụng khóa xoay để bảo vệ phần quan trọng
phần. Nếu phần quan trọng không có trong mã xử lý ngắt và nếu
mất một thời gian tương đối dài để thực thi là có thể chấp nhận được, bạn nên sử dụng
thay vào đó là mutexes hoặc semaphores.

Như đã thấy, một số lệnh gọi lại PCM là nguyên tử và một số thì không. cho
ví dụ: cuộc gọi lại ZZ0000ZZ là phi nguyên tử, trong khi ZZ0001ZZ
gọi lại là nguyên tử. Điều này có nghĩa là cái sau đã được gọi trong một
spinlock được giữ bởi lớp giữa PCM, khóa luồng PCM. làm ơn
hãy tính đến tính nguyên tử này khi bạn chọn sơ đồ khóa trong
các cuộc gọi lại.

Trong các cuộc gọi lại nguyên tử, bạn không thể sử dụng các hàm có thể gọi
ZZ0000ZZ hoặc truy cập ZZ0001ZZ. Ngữ nghĩa và
mutexes có thể ngủ và do đó chúng không thể được sử dụng bên trong nguyên tử
cuộc gọi lại (ví dụ: cuộc gọi lại ZZ0004ZZ). Để thực hiện một số độ trễ trong một
gọi lại, vui lòng sử dụng ZZ0002ZZ hoặc ZZ0003ZZ.

Tất cả ba lệnh gọi lại nguyên tử (kích hoạt, con trỏ và ack) đều được gọi với
ngắt cục bộ bị vô hiệu hóa.

Tuy nhiên, có thể yêu cầu tất cả các hoạt động PCM không phải là nguyên tử.
Điều này giả định rằng tất cả các trang web cuộc gọi đều ở
bối cảnh phi nguyên tử. Ví dụ, chức năng
ZZ0000ZZ thường được gọi từ
trình xử lý ngắt. Tuy nhiên, nếu bạn thiết lập trình điều khiển để sử dụng luồng
trình xử lý ngắt, cuộc gọi này cũng có thể ở trong bối cảnh phi nguyên tử. Trong đó
trong trường hợp này, bạn có thể đặt trường ZZ0001ZZ của đối tượng struct snd_pcm
sau khi tạo ra nó. Khi cờ này được đặt, mutex và rwsem được sử dụng nội bộ
trong lõi PCM thay vì quay và rwlock, để bạn có thể gọi tất cả PCM
hoạt động an toàn trong môi trường phi nguyên tử
bối cảnh.

Ngoài ra, trong một số trường hợp, bạn có thể cần gọi
ZZ0000ZZ trong bối cảnh nguyên tử (ví dụ:
khoảng thời gian đã trôi qua trong khi ZZ0002ZZ hoặc cuộc gọi lại khác). có một
biến thể có thể được gọi bên trong khóa luồng PCM
ZZ0001ZZ cho mục đích đó,
quá.

Hạn chế
-----------

Do những hạn chế về mặt vật lý, phần cứng không thể cấu hình được vô hạn.
Những hạn chế này được thể hiện bằng cách thiết lập các ràng buộc.

Ví dụ: để hạn chế tốc độ mẫu ở một số
giá trị, hãy sử dụng ZZ0000ZZ. Bạn cần phải
gọi hàm này trong cuộc gọi lại mở::

tỷ lệ int không dấu tĩnh [] =
              {4000, 10000, 22050, 44100};
      cấu trúc tĩnh snd_pcm_hw_constraint_list các ràng buộc_rates = {
              .count = ARRAY_SIZE(giá),
              .list = giá,
              .mặt nạ = 0,
      };

int tĩnh snd_mychip_pcm_open(struct snd_pcm_substream *substream)
      {
              int lỗi;
              ....
err = snd_pcm_hw_constraint_list(substream->runtime, 0,
                                               SNDRV_PCM_HW_PARAM_RATE,
                                               &ràng buộc_rates);
              nếu (lỗi < 0)
                      trả lại lỗi;
              ....
      }

Có nhiều ràng buộc khác nhau. Nhìn vào ZZ0000ZZ để biết
danh sách đầy đủ. Bạn thậm chí có thể xác định các quy tắc ràng buộc của riêng bạn. cho
Ví dụ: giả sử my_chip có thể quản lý luồng con gồm 1 kênh nếu
và chỉ khi định dạng là ZZ0001ZZ, nếu không thì nó hỗ trợ mọi định dạng
được chỉ định trong struct snd_pcm_hardware (hoặc trong bất kỳ
ràng buộc_list). Bạn có thể xây dựng một quy tắc như thế này::

int tĩnh hw_rule_channels_by_format(struct snd_pcm_hw_params *params,
                                            cấu trúc snd_pcm_hw_rule *quy tắc)
      {
              struct snd_interval *c = hw_param_interval(params,
                            SNDRV_PCM_HW_PARAM_CHANNELS);
              struct snd_mask *f = hw_param_mask(params, SNDRV_PCM_HW_PARAM_FORMAT);
              struct snd_interval ch;

snd_interval_any(&ch);
              nếu (f->bit[0] == SNDRV_PCM_FMTBIT_S16_LE) {
                      ch.min = ch.max = 1;
                      ch.số nguyên = 1;
                      trả về snd_interval_refine(c, &ch);
              }
              trả về 0;
      }


Sau đó, bạn cần gọi hàm này để thêm quy tắc của mình ::

snd_pcm_hw_rule_add(dòng phụ->thời gian chạy, 0, SNDRV_PCM_HW_PARAM_CHANNELS,
                      hw_rule_channels_by_format, NULL,
                      SNDRV_PCM_HW_PARAM_FORMAT, -1);

Hàm quy tắc được gọi khi ứng dụng đặt định dạng PCM và
nó tinh chỉnh số lượng kênh cho phù hợp. Nhưng một ứng dụng có thể
đặt số lượng kênh trước khi đặt định dạng. Vì vậy bạn cũng cần
để xác định quy tắc nghịch đảo::

int tĩnh hw_rule_format_by_channels(struct snd_pcm_hw_params *params,
                                            cấu trúc snd_pcm_hw_rule *quy tắc)
      {
              struct snd_interval *c = hw_param_interval(params,
                    SNDRV_PCM_HW_PARAM_CHANNELS);
              struct snd_mask *f = hw_param_mask(params, SNDRV_PCM_HW_PARAM_FORMAT);
              cấu trúc snd_mask fmt;

snd_mask_any(&fmt);    /* Khởi tạo cấu trúc */
              nếu (c->phút < 2) {
                      fmt.bits[0] &= SNDRV_PCM_FMTBIT_S16_LE;
                      trả về snd_mask_refine(f, &fmt);
              }
              trả về 0;
      }


... and in the open callback::

  snd_pcm_hw_rule_add(substream->runtime, 0, SNDRV_PCM_HW_PARAM_FORMAT,
                      hw_rule_format_by_channels, NULL,
                      SNDRV_PCM_HW_PARAM_CHANNELS, -1);

Một cách sử dụng điển hình của các ràng buộc hw là căn chỉnh kích thước bộ đệm
với kích thước thời kỳ.  Theo mặc định, lõi ALSA PCM không thực thi
kích thước bộ đệm được căn chỉnh với kích thước khoảng thời gian.  Ví dụ, nó sẽ là
có thể có sự kết hợp như 256 byte thời gian với bộ đệm 999
byte.

Tuy nhiên, nhiều chip thiết bị yêu cầu bộ đệm phải là bội số của
thời kỳ.  Trong trường hợp như vậy, hãy gọi
ZZ0000ZZ cho
ZZ0001ZZ::

snd_pcm_hw_constraint_integer(substream->runtime,
                                SNDRV_PCM_HW_PARAM_PERIODS);

Điều này đảm bảo rằng số lượng thời gian là số nguyên, do đó bộ đệm
kích thước được căn chỉnh với kích thước thời kỳ.

Ràng buộc hw là một cơ chế rất mạnh để xác định
cấu hình PCM ưa thích và có những người trợ giúp liên quan.
Tôi sẽ không cung cấp thêm chi tiết ở đây, thay vào đó tôi muốn nói, “Luke, hãy sử dụng
nguồn.”

Giao diện điều khiển
=================

Tổng quan
-------

Giao diện điều khiển được sử dụng rộng rãi cho nhiều công tắc, thanh trượt, v.v.
được truy cập từ không gian người dùng. Công dụng quan trọng nhất của nó là máy trộn
giao diện. Nói cách khác, kể từ ALSA 0.9.x, tất cả nội dung của bộ trộn đều được
được triển khai trên hạt nhân điều khiển API.

ALSA có mô-đun điều khiển AC97 được xác định rõ ràng. Nếu chip của bạn chỉ hỗ trợ
AC97 và không có gì khác, bạn có thể bỏ qua phần này.

Điều khiển API được xác định trong ZZ0000ZZ. Bao gồm tập tin này
nếu bạn muốn thêm điều khiển của riêng bạn.

Định nghĩa kiểm soát
----------------------

Để tạo một điều khiển mới, bạn cần xác định ba điều sau
lệnh gọi lại: ZZ0000ZZ, ZZ0001ZZ và ZZ0002ZZ. Sau đó, xác định một
struct snd_kcontrol_new bản ghi, chẳng hạn như::


cấu trúc tĩnh snd_kcontrol_new my_control = {
              .iface = SNDRV_CTL_ELEM_IFACE_MIXER,
              .name = "Chuyển đổi phát lại PCM",
              .index = 0,
              .access = SNDRV_CTL_ELEM_ACCESS_READWRITE,
              .private_value = 0xffff,
              .info = my_control_info,
              .get = my_control_get,
              .put = my_control_put
      };


Trường ZZ0000ZZ chỉ định loại điều khiển,
ZZ0001ZZ, thường là ZZ0002ZZ. Sử dụng ZZ0003ZZ
đối với các điều khiển chung không phải là một phần hợp lý của bộ trộn. Nếu
điều khiển được liên kết chặt chẽ với một số thiết bị cụ thể trên âm thanh
thẻ, sử dụng ZZ0004ZZ, ZZ0005ZZ, ZZ0006ZZ, ZZ0007ZZ hoặc ZZ0008ZZ,
và chỉ định số thiết bị bằng ZZ0009ZZ và ZZ0010ZZ
lĩnh vực.

ZZ0000ZZ là chuỗi định danh tên. Kể từ ALSA 0.9.x,
Tên điều khiển rất quan trọng vì vai trò của nó được phân loại từ
tên của nó. Có tên điều khiển tiêu chuẩn được xác định trước. Các chi tiết
được mô tả trong tiểu mục ZZ0001ZZ.

Trường ZZ0000ZZ chứa số chỉ mục của điều khiển này. Nếu có
là một số điều khiển khác nhau có cùng tên, chúng có thể
phân biệt bằng số chỉ mục. Đây là trường hợp khi một số
codec tồn tại trên thẻ. Nếu chỉ số bằng 0, bạn có thể bỏ qua
định nghĩa trên.

Trường ZZ0000ZZ chứa kiểu truy cập của điều khiển này. cho
sự kết hợp của mặt nạ bit, ZZ0001ZZ,
ở đó. Chi tiết sẽ được giải thích trong ZZ0002ZZ
tiểu mục.

Trường ZZ0000ZZ chứa giá trị số nguyên dài tùy ý
cho kỷ lục này. Khi sử dụng ZZ0001ZZ, ZZ0002ZZ và ZZ0003ZZ chung
gọi lại, bạn có thể chuyển một giá trị qua trường này. Nếu một số nhỏ
số là cần thiết, bạn có thể kết hợp chúng theo bit. Hoặc, đó là
có thể lưu trữ một con trỏ (được truyền tới chiều dài không dấu) của một số bản ghi trong
lĩnh vực này nữa.

Trường ZZ0000ZZ có thể được sử dụng để cung cấp siêu dữ liệu về điều khiển;
xem tiểu mục ZZ0001ZZ.

Ba cái còn lại là ZZ0000ZZ.

Tên điều khiển
-------------

Có một số tiêu chuẩn để xác định tên điều khiển. Một điều khiển là
thường được định nghĩa từ ba phần là “SOURCE DIRECTION FUNCTION”.

Đầu tiên, ZZ0000ZZ, chỉ định nguồn của điều khiển và là một
chuỗi chẳng hạn như “Master”, “PCM”, “CD” và “Line”. Có rất nhiều
nguồn được xác định trước.

Chuỗi thứ hai, ZZ0000ZZ, là một trong những chuỗi sau theo
hướng điều khiển: “Phát lại”, “Chụp”, “Bỏ qua phát lại”
và “Bỏ qua chụp”. Hoặc, nó có thể được bỏ qua, nghĩa là cả việc phát lại và
nắm bắt chỉ đường.

Chuỗi thứ ba, ZZ0000ZZ, là một trong những chuỗi sau theo
chức năng điều khiển: “Chuyển đổi”, “Âm lượng” và “Tuyến đường”.

Do đó, ví dụ về tên điều khiển là “Master Capture Switch” hoặc “PCM
Âm lượng phát lại”.

Có một số trường hợp ngoại lệ:

Chụp và phát lại toàn cầu
~~~~~~~~~~~~~~~~~~~~~~~~~~~

“Nguồn chụp”, “Công tắc chụp” và “Âm lượng chụp” được sử dụng cho
nguồn, chuyển đổi và âm lượng chụp toàn cầu (đầu vào). Tương tự, “Phát lại
Switch” và “Âm lượng phát lại” được sử dụng cho công tắc khuếch đại đầu ra chung
và khối lượng.

Điều khiển giai điệu
~~~~~~~~~~~~~

công tắc và âm lượng điều khiển âm thanh được chỉ định như “Điều khiển âm thanh - XXX”,
ví dụ: “Điều khiển giai điệu - Chuyển đổi”, “Điều khiển giai điệu - Âm trầm”, “Điều khiển giai điệu -
Trung tâm”.

điều khiển 3D
~~~~~~~~~~~

Công tắc và âm lượng điều khiển 3D được chỉ định như “Điều khiển 3D - XXX”,
ví dụ: “Điều khiển 3D - Chuyển đổi”, “Điều khiển 3D - Trung tâm”, “Điều khiển 3D - Không gian”.

Tăng cường micrô
~~~~~~~~~

Công tắc tăng cường micrô được đặt thành “Mic Boost” hoặc “Mic Boost (6dB)”.

Thông tin chính xác hơn có thể được tìm thấy trong
ZZ0000ZZ.

Cờ truy cập
------------

Cờ truy cập là mặt nạ bit xác định kiểu truy cập của
quyền kiểm soát được trao. Kiểu truy cập mặc định là
ZZ0000ZZ, có nghĩa là cả đọc và ghi đều được
được phép kiểm soát điều này. Khi cờ truy cập bị bỏ qua (tức là = 0), nó
theo mặc định được coi là quyền truy cập ZZ0001ZZ.

Khi điều khiển ở chế độ chỉ đọc, hãy chuyển ZZ0000ZZ
thay vào đó. Trong trường hợp này, bạn không phải xác định lệnh gọi lại ZZ0001ZZ.
Tương tự, khi điều khiển ở chế độ chỉ ghi (mặc dù đây là một trường hợp hiếm gặp),
thay vào đó bạn có thể sử dụng cờ ZZ0002ZZ và bạn không cần ZZ0003ZZ
gọi lại.

Nếu giá trị điều khiển thay đổi thường xuyên (ví dụ: đồng hồ đo VU),
Nên đưa ra cờ ZZ0000ZZ. Điều này có nghĩa là việc kiểm soát có thể
đã thay đổi mà không có ZZ0001ZZ. Các ứng dụng nên thăm dò ý kiến như vậy
một sự kiểm soát liên tục.

Khi điều khiển có thể được cập nhật nhưng hiện tại không có tác dụng gì,
cài đặt cờ ZZ0000ZZ có thể phù hợp. Ví dụ: PCM
các điều khiển sẽ không hoạt động khi không có thiết bị PCM nào được mở.

Có cờ ZZ0000ZZ và ZZ0001ZZ để thay đổi quyền ghi.

Kiểm soát cuộc gọi lại
-----------------

gọi lại thông tin
~~~~~~~~~~~~~

Lệnh gọi lại ZZ0000ZZ được sử dụng để nhận thông tin chi tiết về điều này
kiểm soát. Điều này phải lưu trữ các giá trị của đã cho
đối tượng struct snd_ctl_elem_info. Ví dụ,
đối với điều khiển boolean với một phần tử duy nhất ::


int tĩnh snd_myctl_mono_info(struct snd_kcontrol *kcontrol,
                              cấu trúc snd_ctl_elem_info *uinfo)
      {
              uinfo->type = SNDRV_CTL_ELEM_TYPE_BOOLEAN;
              uinfo->đếm = 1;
              uinfo->value.integer.min = 0;
              uinfo->value.integer.max = 1;
              trả về 0;
      }



Trường ZZ0000ZZ chỉ định loại điều khiển. có
ZZ0001ZZ, ZZ0002ZZ, ZZ0003ZZ, ZZ0004ZZ, ZZ0005ZZ và
ZZ0006ZZ. Trường ZZ0007ZZ chỉ định số phần tử trong
sự kiểm soát này. Ví dụ: âm lượng âm thanh nổi sẽ có số đếm = 2.
Trường ZZ0008ZZ là một liên kết và các giá trị được lưu trữ phụ thuộc vào
loại. Các kiểu boolean và số nguyên giống hệt nhau.

Kiểu liệt kê hơi khác một chút so với các kiểu khác. Bạn sẽ cần phải
đặt chuỗi cho chỉ mục mục selectec ::

int tĩnh snd_myctl_enum_info(struct snd_kcontrol *kcontrol,
                          cấu trúc snd_ctl_elem_info *uinfo)
  {
          char tĩnh *texts[4] = {
                  “Thứ nhất”, “Thứ hai”, “Thứ ba”, “Thứ tư”
          };
          uinfo->type = SNDRV_CTL_ELEM_TYPE_ENUMERATED;
          uinfo->đếm = 1;
          uinfo->value.enumerated.items = 4;
          if (uinfo->value.enumerated.item > 3)
                  uinfo->value.enumerated.item = 3;
          strcpy(uinfo->value.enumerated.name,
                 văn bản [uinfo->value.enumerated.item]);
          trả về 0;
  }

Cuộc gọi lại ở trên có thể được đơn giản hóa bằng chức năng trợ giúp,
ZZ0000ZZ. Mã cuối cùng trông như dưới đây.
(Bạn có thể chuyển ZZ0001ZZ thay vì 4 trong đối số thứ ba;
đó là vấn đề về hương vị.)

::

int tĩnh snd_myctl_enum_info(struct snd_kcontrol *kcontrol,
                          cấu trúc snd_ctl_elem_info *uinfo)
  {
          char tĩnh *texts[4] = {
                  “Thứ nhất”, “Thứ hai”, “Thứ ba”, “Thứ tư”
          };
          trả về snd_ctl_enum_info(uinfo, 1, 4, text);
  }


Một số lệnh gọi lại thông tin phổ biến có sẵn để thuận tiện cho bạn:
ZZ0000ZZ và
ZZ0001ZZ. Rõ ràng, trước đây
là một cuộc gọi lại thông tin cho một mục boolean kênh đơn, giống như
ZZ0002ZZ ở trên và cái sau dành cho
mục boolean kênh âm thanh nổi.

nhận cuộc gọi lại
~~~~~~~~~~~~

Cuộc gọi lại này được sử dụng để đọc giá trị hiện tại của điều khiển, vì vậy nó
có thể được trả về không gian người dùng.

Ví dụ::

int tĩnh snd_myctl_get(struct snd_kcontrol *kcontrol,
                               cấu trúc snd_ctl_elem_value *ucontrol)
      {
              struct mychip *chip = snd_kcontrol_chip(kcontrol);
              ucontrol->value.integer.value[0] = get_some_value(chip);
              trả về 0;
      }



Trường ZZ0000ZZ phụ thuộc vào loại điều khiển cũng như
thông tin gọi lại. Ví dụ: trình điều khiển sb sử dụng trường này để lưu trữ
thanh ghi offset, dịch chuyển bit và mặt nạ bit. ZZ0001ZZ
trường được đặt như sau::

.private_value = reg ZZ0000ZZ (mặt nạ << 24)

và được truy xuất trong các cuộc gọi lại như::

int tĩnh snd_sbmixer_get_single(struct snd_kcontrol *kcontrol,
                                    cấu trúc snd_ctl_elem_value *ucontrol)
  {
          int reg = kcontrol->private_value & 0xff;
          int shift = (kcontrol->private_value >> 16) & 0xff;
          mặt nạ int = (kcontrol->private_value >> 24) & 0xff;
          ....
  }

Trong lệnh gọi lại ZZ0000ZZ, bạn phải điền tất cả các thành phần nếu
điều khiển có nhiều hơn một phần tử, tức là ZZ0001ZZ. Trong ví dụ
ở trên, chúng tôi chỉ điền một phần tử (ZZ0002ZZ) vì
ZZ0003ZZ được giả định.

gọi lại
~~~~~~~~~~~~

Cuộc gọi lại này được sử dụng để ghi một giá trị đến từ không gian người dùng.

Ví dụ::

int tĩnh snd_myctl_put(struct snd_kcontrol *kcontrol,
                               cấu trúc snd_ctl_elem_value *ucontrol)
      {
              struct mychip *chip = snd_kcontrol_chip(kcontrol);
              int đã thay đổi = 0;
              if (chip->current_value !=
                   ucontrol->value.integer.value[0]) {
                      thay đổi_current_value(chip,
                                  ucontrol->value.integer.value[0]);
                      đã thay đổi = 1;
              }
              trở lại đã thay đổi;
      }



Như đã thấy ở trên, bạn phải trả về 1 nếu giá trị bị thay đổi. Nếu
giá trị không thay đổi, thay vào đó trả về 0. Nếu có bất kỳ lỗi nghiêm trọng nào xảy ra,
trả về mã lỗi âm như bình thường.

Như trong lệnh gọi lại ZZ0000ZZ, khi điều khiển có nhiều hơn một
phần tử, tất cả các phần tử cũng phải được đánh giá trong lệnh gọi lại này.

Cuộc gọi lại không phải là nguyên tử
~~~~~~~~~~~~~~~~~~~~~~~~

Tất cả ba cuộc gọi lại này đều không phải là nguyên tử.

Trình xây dựng điều khiển
-------------------

Khi mọi thứ đã sẵn sàng, cuối cùng chúng ta có thể tạo một điều khiển mới. Để tạo
một điều khiển, có hai chức năng được gọi,
ZZ0000ZZ và ZZ0001ZZ.

Theo cách đơn giản nhất, bạn có thể làm như sau::

err = snd_ctl_add(thẻ, snd_ctl_new1(&my_control, chip));
  nếu (lỗi < 0)
          trả lại lỗi;

trong đó ZZ0000ZZ là đối tượng struct snd_kcontrol_new được xác định ở trên,
và chip là con trỏ đối tượng được truyền tới kcontrol->private_data
có thể được đề cập đến trong các cuộc gọi lại.

ZZ0000ZZ phân bổ một phiên bản struct snd_kcontrol mới và
ZZ0001ZZ gán thành phần điều khiển đã cho cho
thẻ.

Thay đổi thông báo
-------------------

Nếu bạn cần thay đổi và cập nhật một điều khiển trong quy trình ngắt, bạn
có thể gọi ZZ0000ZZ. Ví dụ::

snd_ctl_notify(thẻ, SNDRV_CTL_EVENT_MASK_VALUE, id_pointer);

Hàm này lấy con trỏ thẻ, mặt nạ sự kiện và id điều khiển
con trỏ cho thông báo. Mặt nạ sự kiện chỉ định các loại
thông báo, ví dụ như trong ví dụ trên, việc thay đổi quyền kiểm soát
các giá trị được thông báo. Con trỏ id là con trỏ của struct snd_ctl_elem_id
để được thông báo. Bạn có thể tìm thấy một số ví dụ trong ZZ0000ZZ hoặc ZZ0001ZZ
đối với các ngắt âm lượng phần cứng.

Siêu dữ liệu
--------

Để cung cấp thông tin về giá trị dB của bộ điều khiển bộ trộn, hãy sử dụng một trong các
macro ZZ0000ZZ từ ZZ0001ZZ để xác định
biến chứa thông tin này, hãy đặt trường ZZ0002ZZ để trỏ tới
biến này và bao gồm cờ ZZ0003ZZ
trong trường ZZ0004ZZ; như thế này::

DECLARE_TLV_DB_SCALE tĩnh (db_scale_my_control, -4050, 150, 0);

cấu trúc tĩnh snd_kcontrol_new my_control = {
          ...
.access = SNDRV_CTL_ELEM_ACCESS_READWRITE |
                    SNDRV_CTL_ELEM_ACCESS_TLV_READ,
          ...
.tlv.p = db_scale_my_control,
  };


Macro ZZ0000ZZ xác định thông tin
về điều khiển bộ trộn trong đó mỗi bước trong giá trị của điều khiển sẽ thay đổi
giá trị dB bằng một lượng dB không đổi. Tham số đầu tiên là tên của
biến cần xác định. Tham số thứ hai là giá trị tối thiểu, trong
đơn vị 0,01 dB. Tham số thứ ba là kích thước bước, tính bằng đơn vị 0,01
dB. Đặt tham số thứ tư thành 1 nếu giá trị tối thiểu thực sự tắt tiếng
sự kiểm soát.

Macro ZZ0000ZZ xác định thông tin
về điều khiển bộ trộn trong đó giá trị của điều khiển ảnh hưởng đến đầu ra
tuyến tính. Tham số đầu tiên là tên của biến cần xác định.
Tham số thứ hai là giá trị tối thiểu, tính bằng đơn vị 0,01 dB. các
tham số thứ ba là giá trị tối đa, tính bằng đơn vị 0,01 dB. Nếu
giá trị tối thiểu tắt điều khiển, đặt tham số thứ hai thành
ZZ0001ZZ.

API cho Bộ giải mã AC97
==================

Tổng quan
-------

Lớp codec ALSA AC97 là lớp được xác định rõ ràng và bạn không cần phải
viết nhiều mã để kiểm soát nó. Chỉ có các thủ tục kiểm soát ở mức độ thấp mới được
cần thiết. Codec AC97 API được xác định trong ZZ0000ZZ.

Ví dụ mã đầy đủ
-----------------

::

cấu trúc mychip {
              ....
cấu trúc snd_ac97 *ac97;
              ....
      };

snd_mychip_ac97_read ngắn không dấu tĩnh (struct snd_ac97 *ac97,
                                                 reg ngắn không dấu)
      {
              struct mychip *chip = ac97->private_data;
              ....
/* đọc giá trị thanh ghi ở đây từ codec */
              trả về_register_value;
      }

khoảng trống tĩnh snd_mychip_ac97_write(struct snd_ac97 *ac97,
                                       reg ngắn không dấu, val ngắn không dấu)
      {
              struct mychip *chip = ac97->private_data;
              ....
/* ghi giá trị thanh ghi đã cho vào codec */
      }

int tĩnh snd_mychip_ac97(cấu trúc mychip *chip)
      {
              cấu trúc snd_ac97_bus *bus;
              cấu trúc snd_ac97_template ac97;
              int lỗi;
              cấu trúc tĩnh snd_ac97_bus_ops ops = {
                      .write = snd_mychip_ac97_write,
                      .read = snd_mychip_ac97_read,
              };

err = snd_ac97_bus(chip->thẻ, 0, &ops, NULL, &bus);
              nếu (lỗi < 0)
                      trả lại lỗi;
              bộ nhớ(&ac97, 0, sizeof(ac97));
              ac97.private_data = chip;
              trả về snd_ac97_mixer(bus, &ac97, &chip->ac97);
      }


Trình xây dựng AC97
----------------

Để tạo phiên bản ac97, trước tiên hãy gọi ZZ0000ZZ
với bản ghi ZZ0001ZZ có chức năng gọi lại::

cấu trúc snd_ac97_bus *bus;
  cấu trúc tĩnh snd_ac97_bus_ops ops = {
        .write = snd_mychip_ac97_write,
        .read = snd_mychip_ac97_read,
  };

snd_ac97_bus(thẻ, 0, &ops, NULL, &pbus);

Bản ghi xe buýt được chia sẻ giữa tất cả các phiên bản ac97 thuộc về.

Và sau đó gọi ZZ0000ZZ bằng cấu trúc snd_ac97_template
bản ghi cùng với con trỏ bus được tạo ở trên::

cấu trúc snd_ac97_template ac97;
  int lỗi;

bộ nhớ(&ac97, 0, sizeof(ac97));
  ac97.private_data = chip;
  snd_ac97_mixer(bus, &ac97, &chip->ac97);

trong đó chip->ac97 là con trỏ tới ZZ0000ZZ mới được tạo
ví dụ. Trong trường hợp này, con trỏ chip được đặt làm dữ liệu riêng tư,
để các chức năng gọi lại đọc/ghi có thể tham chiếu đến chip này
ví dụ. Phiên bản này không nhất thiết phải được lưu trữ trong chip
ghi lại. Nếu bạn cần thay đổi giá trị đăng ký từ trình điều khiển, hoặc
cần tạm dừng/tiếp tục codec ac97, hãy giữ con trỏ này để chuyển tới
các chức năng tương ứng.

Gọi lại AC97
--------------

Các cuộc gọi lại tiêu chuẩn là ZZ0000ZZ và ZZ0001ZZ. Rõ ràng là họ
tương ứng với các chức năng truy cập đọc và ghi vào
mã cấp thấp phần cứng.

Lệnh gọi lại ZZ0000ZZ trả về giá trị thanh ghi được chỉ định trong
đối số::

snd_mychip_ac97_read ngắn không dấu tĩnh (struct snd_ac97 *ac97,
                                             reg ngắn không dấu)
  {
          struct mychip *chip = ac97->private_data;
          ....
trả về_register_value;
  }

Ở đây, chip có thể được đúc từ ZZ0000ZZ.

Trong khi đó, lệnh gọi lại ZZ0000ZZ được sử dụng để thiết lập thanh ghi
giá trị::

khoảng trống tĩnh snd_mychip_ac97_write(struct snd_ac97 *ac97,
                       reg ngắn không dấu, val ngắn không dấu)


Các lệnh gọi lại này không mang tính nguyên tử như các lệnh gọi lại API điều khiển.

Ngoài ra còn có các lệnh gọi lại khác: ZZ0000ZZ, ZZ0001ZZ và ZZ0002ZZ.

Lệnh gọi lại ZZ0000ZZ được sử dụng để đặt lại codec. Nếu con chip
yêu cầu một kiểu đặt lại đặc biệt, bạn có thể xác định cuộc gọi lại này.

Lệnh gọi lại ZZ0000ZZ được sử dụng để thêm thời gian chờ đợi trong tiêu chuẩn
khởi tạo codec. Nếu chip yêu cầu phải chờ thêm
thời gian, hãy xác định cuộc gọi lại này.

Lệnh gọi lại ZZ0000ZZ được sử dụng để khởi tạo bổ sung
codec.

Cập nhật sổ đăng ký trong trình điều khiển
--------------------------------

Nếu bạn cần truy cập vào codec từ trình điều khiển, bạn có thể gọi
các chức năng sau: ZZ0000ZZ,
ZZ0001ZZ, ZZ0002ZZ và
ZZ0003ZZ.

Cả ZZ0000ZZ và
Các hàm ZZ0001ZZ được sử dụng để đặt giá trị thành
thanh ghi đã cho (ZZ0004ZZ). Sự khác biệt giữa chúng là ở chỗ
ZZ0002ZZ không ghi giá trị nếu giá trị đã cho
giá trị đã được đặt, trong khi ZZ0003ZZ
luôn viết lại giá trị::

snd_ac97_write(ac97, AC97_MASTER, 0x8080);
  snd_ac97_update(ac97, AC97_MASTER, 0x8080);

ZZ0000ZZ được sử dụng để đọc giá trị của giá trị đã cho
đăng ký. Ví dụ::

giá trị = snd_ac97_read(ac97, AC97_MASTER);

ZZ0000ZZ được sử dụng để cập nhật một số bit trong
thanh ghi đã cho::

snd_ac97_update_bits(ac97, reg, mặt nạ, giá trị);

Ngoài ra, còn có chức năng thay đổi tốc độ mẫu (của một thanh ghi nhất định
chẳng hạn như ZZ0001ZZ) khi VRA hoặc DRA được hỗ trợ bởi
mã hóa: ZZ0000ZZ::

snd_ac97_set_rate(ac97, AC97_PCM_FRONT_DAC_RATE, 44100);


Các thanh ghi sau đây có sẵn để thiết lập tỷ lệ:
ZZ0000ZZ, ZZ0001ZZ,
ZZ0002ZZ, ZZ0003ZZ. Khi ZZ0004ZZ là
được chỉ định, thanh ghi không thực sự thay đổi nhưng tương ứng
Các bit trạng thái IEC958 sẽ được cập nhật.

Điều chỉnh đồng hồ
----------------

Ở một số chip, đồng hồ của codec không phải là 48000 mà sử dụng đồng hồ PCI
(để cứu thạch anh!). Trong trường hợp này, thay đổi trường ZZ0000ZZ thành
giá trị tương ứng. Ví dụ: trình điều khiển intel8x0 và es1968 có
chức năng riêng của họ để đọc từ đồng hồ.

Tệp Proc
----------

Giao diện ALSA AC97 sẽ tạo một tệp Proc như
ZZ0000ZZ và ZZ0001ZZ. bạn
có thể tham khảo các tập tin này để xem trạng thái hiện tại và các sổ đăng ký của
bộ giải mã.

Nhiều Codec
---------------

Khi có nhiều codec trên cùng một thẻ, bạn cần gọi
ZZ0000ZZ nhiều lần với ZZ0001ZZ hoặc
lớn hơn. Trường ZZ0002ZZ chỉ định số codec.

Nếu bạn thiết lập nhiều codec, bạn cần phải viết các codec khác nhau
gọi lại cho từng codec hoặc kiểm tra ZZ0000ZZ trong lệnh gọi lại
thói quen.

Giao diện MIDI (MPU401-UART)
============================

Tổng quan
-------

Nhiều soundcard có giao diện MIDI (MPU401-UART) tích hợp. Khi
soundcard hỗ trợ giao diện MPU401-UART tiêu chuẩn, rất có thể bạn
có thể sử dụng ALSA MPU401-UART API. MPU401-UART API được định nghĩa trong
ZZ0000ZZ.

Một số soundchip có cách triển khai tương tự nhưng hơi khác một chút.
nội dung mpu401. Ví dụ: emu10k1 có thói quen mpu401 riêng.

Trình xây dựng MIDI
----------------

Để tạo một đối tượng rawmidi, hãy gọi ZZ0000ZZ::

struct snd_rawmidi *rmidi;
  snd_mpu401_uart_new(thẻ, 0, MPU401_HW_MPU401, cổng, info_flags,
                      irq, &rmidi);


Đối số đầu tiên là con trỏ thẻ và đối số thứ hai là chỉ mục của
thành phần này. Bạn có thể tạo tối đa 8 thiết bị rawmidi.

Đối số thứ ba là loại phần cứng, ZZ0000ZZ. Nếu
nó không phải là cái đặc biệt, bạn có thể sử dụng ZZ0001ZZ.

Đối số thứ 4 là địa chỉ cổng I/O. Nhiều tính năng tương thích ngược
MPU401 có cổng I/O như 0x330. Hoặc, nó có thể là một phần của riêng nó
Vùng I/O PCI. Nó phụ thuộc vào thiết kế chip.

Đối số thứ 5 là bitflag để biết thêm thông tin. Khi I/O
địa chỉ cổng ở trên là một phần của vùng I/O PCI, cổng I/O MPU401
có thể đã được phân bổ (dành riêng) bởi chính trình điều khiển. trong
trong trường hợp như vậy, hãy chuyển cờ bit ZZ0000ZZ và
Lớp mpu401-uart sẽ tự phân bổ các cổng I/O.

Khi bộ điều khiển chỉ hỗ trợ luồng MIDI đầu vào hoặc đầu ra, hãy chuyển
cờ bit ZZ0000ZZ hoặc ZZ0001ZZ,
tương ứng. Sau đó, phiên bản rawmidi được tạo dưới dạng một luồng duy nhất.

Bitflag ZZ0001ZZ được sử dụng để thay đổi phương thức truy cập thành MMIO
(thông qua readb và writeb) thay vì iob và outb. Trong trường hợp này, bạn có
để chuyển địa chỉ iomapped tới ZZ0000ZZ.

Khi ZZ0001ZZ được đặt, luồng đầu ra không được kiểm tra
trình xử lý ngắt mặc định. Tài xế cần gọi
ZZ0000ZZ tự khởi động
xử lý luồng đầu ra trong trình xử lý irq.

Nếu giao diện MPU-401 chia sẻ ngắt của nó với giao diện logic khác
thiết bị trên thẻ, đặt ZZ0000ZZ (xem
ZZ0001ZZ).

Thông thường, địa chỉ cổng tương ứng với cổng lệnh và port + 1
tương ứng với cổng dữ liệu. Nếu không, bạn có thể thay đổi ZZ0001ZZ
trường struct snd_mpu401 theo cách thủ công sau đó.
Tuy nhiên, con trỏ struct snd_mpu401 là
không được trả về một cách rõ ràng bởi ZZ0000ZZ. bạn
cần truyền ZZ0002ZZ tới struct snd_mpu401 một cách rõ ràng ::

cấu trúc snd_mpu401 *mpu;
  mpu = rmidi->private_data;

và đặt lại ZZ0000ZZ theo ý muốn ::

mpu->cport = my_own_control_port;

Đối số thứ 6 chỉ định số irq ISA sẽ được phân bổ. Nếu
không có sự gián đoạn nào được phân bổ (vì mã của bạn đã được phân bổ
ngắt được chia sẻ hoặc do thiết bị không sử dụng ngắt), hãy chuyển
-1 thay vào đó. Đối với thiết bị MPU-401 không bị gián đoạn, bộ đếm thời gian bỏ phiếu
sẽ được sử dụng thay thế.

Trình xử lý ngắt MIDI
----------------------

Khi ngắt được phân bổ vào
ZZ0000ZZ, ngắt ISA độc quyền
trình xử lý được sử dụng tự động, do đó bạn không có việc gì khác để làm
hơn là tạo ra những thứ mpu401. Nếu không, bạn phải thiết lập
ZZ0002ZZ và gọi
ZZ0001ZZ rõ ràng là từ chính bạn
trình xử lý ngắt khi nó xác định rằng ngắt UART có
đã xảy ra.

Trong trường hợp này, bạn cần chuyển dữ liệu riêng tư của rawmidi được trả về
đối tượng từ ZZ0000ZZ là đối tượng thứ hai
đối số của ZZ0001ZZ::

snd_mpu401_uart_interrupt(irq, rmidi->private_data, regs);


Giao diện RawMIDI
=================

Tổng quan
--------

Giao diện MIDI thô được sử dụng cho các cổng MIDI phần cứng có thể
được truy cập dưới dạng luồng byte. Nó không được sử dụng cho các chip tổng hợp có chức năng
không hiểu trực tiếp MIDI.

ALSA xử lý việc quản lý tập tin và bộ đệm. Tất cả những gì bạn phải làm là viết
một số mã để di chuyển dữ liệu giữa bộ đệm và phần cứng.

Rawmidi API được định nghĩa trong ZZ0000ZZ.

Trình tạo MIDI thô
-------------------

Để tạo thiết bị rawmidi, hãy gọi ZZ0000ZZ
chức năng::

struct snd_rawmidi *rmidi;
  err = snd_rawmidi_new(chip->card, "MyMIDI", 0, out, ins, &rmidi);
  nếu (lỗi < 0)
          trả lại lỗi;
  rmidi->private_data = chip;
  strcpy(rmidi->name, "MIDI của tôi");
  rmidi->info_flags = SNDRV_RAWMIDI_INFO_OUTPUT |
                      SNDRV_RAWMIDI_INFO_INPUT |
                      SNDRV_RAWMIDI_INFO_DUPLEX;

Đối số đầu tiên là con trỏ thẻ, đối số thứ hai là ID
chuỗi.

Đối số thứ ba là chỉ mục của thành phần này. Bạn có thể tạo tối đa
8 thiết bị rawmidi.

Đối số thứ tư và thứ năm là số lượng đầu ra và đầu vào
các dòng con tương ứng của thiết bị này (một dòng con tương đương
của cổng MIDI).

Đặt trường ZZ0000ZZ để chỉ định khả năng của
thiết bị. Đặt ZZ0001ZZ nếu có ít nhất một
cổng đầu ra, ZZ0002ZZ nếu có ít nhất một
cổng đầu vào và ZZ0003ZZ nếu thiết bị có thể xử lý
đầu ra và đầu vào cùng một lúc.

Sau khi thiết bị rawmidi được tạo, bạn cần đặt toán tử
(gọi lại) cho mỗi luồng con. Có các chức năng trợ giúp để thiết lập
toán tử cho tất cả các dòng con của thiết bị::

snd_rawmidi_set_ops(rmidi, SNDRV_RAWMIDI_STREAM_OUTPUT, &snd_mymidi_output_ops);
  snd_rawmidi_set_ops(rmidi, SNDRV_RAWMIDI_STREAM_INPUT, &snd_mymidi_input_ops);

Các toán tử thường được định nghĩa như sau::

cấu trúc tĩnh snd_rawmidi_ops snd_mymidi_output_ops = {
          .open = snd_mymidi_output_open,
          .close = snd_mymidi_output_close,
          .trigger = snd_mymidi_output_trigger,
  };

Những lệnh gọi lại này được giải thích trong phần ZZ0000ZZ.

Nếu có nhiều hơn một luồng con, bạn nên đặt một tên duy nhất cho
mỗi người trong số họ::

struct snd_rawmidi_substream *dòng phụ;
  list_for_each_entry(dòng phụ,
                      &rmidi->streams[SNDRV_RAWMIDI_STREAM_OUTPUT].substreams,
                      danh sách {
          sprintf(substream->name, "My MIDI Port %d", substream->number + 1);
  }
  /* tương tự với SNDRV_RAWMIDI_STREAM_INPUT */

Lệnh gọi lại RawMIDI
-----------------

Trong tất cả các cuộc gọi lại, dữ liệu riêng tư mà bạn đã đặt cho rawmidi
thiết bị có thể được truy cập dưới dạng ZZ0000ZZ.

Nếu có nhiều cổng, lệnh gọi lại của bạn có thể xác định cổng
chỉ mục từ dữ liệu struct snd_rawmidi_substream được truyền cho mỗi
gọi lại::

struct snd_rawmidi_substream *dòng phụ;
  chỉ số int = dòng con->số;

Gọi lại mở RawMIDI
~~~~~~~~~~~~~~~~~~~~~

::

int tĩnh snd_xxx_open(struct snd_rawmidi_substream *substream);


Điều này được gọi khi một luồng con được mở. Bạn có thể khởi tạo
phần cứng ở đây, nhưng bạn chưa nên bắt đầu truyền/nhận dữ liệu.

Gọi lại đóng RawMIDI
~~~~~~~~~~~~~~~~~~~~~~

::

int tĩnh snd_xxx_close(struct snd_rawmidi_substream *substream);

Đoán xem.

Lệnh gọi lại ZZ0000ZZ và ZZ0001ZZ của thiết bị rawmidi là
được tuần tự hóa bằng một mutex và có thể ngủ.

Lệnh gọi lại kích hoạt Rawmidi cho luồng con đầu ra
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

::

static void snd_xxx_output_trigger(struct snd_rawmidi_substream *substream, int up);


Điều này được gọi với tham số ZZ0000ZZ khác 0 khi có một số dữ liệu
trong bộ đệm dòng con phải được truyền đi.

Để đọc dữ liệu từ bộ đệm, hãy gọi
ZZ0000ZZ. Nó sẽ trả về số
số byte đã được đọc; số này sẽ nhỏ hơn số byte
được yêu cầu khi không còn dữ liệu trong bộ đệm. Sau khi dữ liệu có
đã được truyền thành công, hãy gọi
ZZ0001ZZ để xóa dữ liệu khỏi
bộ đệm phụ::

dữ liệu char không dấu;
  while (snd_rawmidi_transmit_peek(substream, &data, 1) == 1) {
          nếu (snd_mychip_try_to_transmit(dữ liệu))
                  snd_rawmidi_transmit_ack(substream, 1);
          khác
                  phá vỡ; /* phần cứng FIFO đầy đủ */
  }

Nếu bạn biết trước rằng phần cứng sẽ chấp nhận dữ liệu, bạn có thể sử dụng
hàm ZZ0000ZZ đọc một số
dữ liệu và xóa chúng khỏi bộ đệm cùng một lúc::

trong khi (snd_mychip_transmit_possible()) {
          dữ liệu char không dấu;
          if (snd_rawmidi_transmit(substream, &data, 1) != 1)
                  phá vỡ; /*không còn dữ liệu nữa*/
          snd_mychip_transmit(dữ liệu);
  }

Nếu bạn biết trước bạn có thể chấp nhận bao nhiêu byte, bạn có thể sử dụng
kích thước bộ đệm lớn hơn một với các chức năng ZZ0000ZZ.

Cuộc gọi lại ZZ0000ZZ không được ngủ. Nếu phần cứng FIFO đã đầy
trước khi bộ đệm phụ được làm trống, bạn phải tiếp tục
truyền dữ liệu sau đó bằng trình xử lý ngắt hoặc bằng
hẹn giờ nếu phần cứng không có ngắt truyền MIDI.

Cuộc gọi lại ZZ0000ZZ được gọi với tham số ZZ0001ZZ bằng 0 khi
việc truyền dữ liệu phải bị hủy bỏ.

Lệnh gọi lại kích hoạt RawMIDI cho các luồng con đầu vào
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

::

static void snd_xxx_input_trigger(struct snd_rawmidi_substream *substream, int up);


Điều này được gọi với tham số ZZ0000ZZ khác 0 để cho phép nhận dữ liệu,
hoặc với tham số ZZ0001ZZ bằng 0 sẽ vô hiệu hóa việc nhận dữ liệu.

Cuộc gọi lại ZZ0000ZZ không được ngủ; việc đọc dữ liệu thực tế
từ thiết bị thường được thực hiện trong trình xử lý ngắt.

Khi bật tính năng nhận dữ liệu, trình xử lý ngắt của bạn sẽ gọi
ZZ0000ZZ cho tất cả dữ liệu đã nhận::

void snd_mychip_midi_interrupt(...)
  {
          trong khi (mychip_midi_available()) {
                  dữ liệu char không dấu;
                  dữ liệu = mychip_midi_read();
                  snd_rawmidi_receive(substream, &data, 1);
          }
  }


gọi lại cống
~~~~~~~~~~~~~~

::

static void snd_xxx_drain(struct snd_rawmidi_substream *substream);


Điều này chỉ được sử dụng với dòng con đầu ra. Chức năng này nên chờ
cho đến khi tất cả dữ liệu đọc từ bộ đệm dòng phụ được truyền đi.
Điều này đảm bảo rằng thiết bị có thể được đóng và tải trình điều khiển
mà không bị mất dữ liệu.

Cuộc gọi lại này là tùy chọn. Nếu bạn không đặt ZZ0000ZZ trong cấu trúc
Cấu trúc snd_rawmidi_ops, ALSA sẽ chỉ đợi trong 50 mili giây
thay vào đó.

Thiết bị khác
=====================

FM OPL3
-------

FM OPL3 vẫn được sử dụng trong nhiều chip (chủ yếu cho các chip lùi
khả năng tương thích). ALSA cũng có lớp điều khiển OPL3 FM tuyệt vời. OPL3 API
được định nghĩa trong ZZ0000ZZ.

Các thanh ghi FM có thể được truy cập trực tiếp thông qua API FM trực tiếp, được xác định
trong ZZ0000ZZ. Ở chế độ gốc ALSA, các thanh ghi FM được
được truy cập thông qua tiện ích mở rộng FM trực tiếp của Thiết bị phụ thuộc vào phần cứng API,
trong khi ở chế độ tương thích OSS, các thanh ghi FM có thể được truy cập bằng
OSS tương thích trực tiếp FM API trong thiết bị ZZ0001ZZ.

Để tạo thành phần OPL3, bạn có hai hàm để gọi. đầu tiên
one là hàm tạo cho phiên bản ZZ0000ZZ ::

cấu trúc snd_opl3 *opl3;
  snd_opl3_create(thẻ, lport, rport, OPL3_HW_OPL3_XXX,
                  tích hợp, &opl3);

Đối số đầu tiên là con trỏ thẻ, đối số thứ hai là cổng bên trái
địa chỉ thứ ba là địa chỉ cổng phù hợp. Trong hầu hết các trường hợp,
cổng bên phải được đặt ở cổng bên trái +2.

Đối số thứ tư là loại phần cứng.

Khi các cổng trái và phải đã được thẻ phân bổ
trình điều khiển, chuyển giá trị khác 0 cho đối số thứ năm (ZZ0000ZZ). Nếu không,
mô-đun opl3 sẽ tự phân bổ các cổng được chỉ định.

Khi việc truy cập phần cứng yêu cầu phương pháp đặc biệt thay vì
truy cập I/O tiêu chuẩn, bạn có thể tạo phiên bản opl3 riêng biệt với
ZZ0000ZZ::

cấu trúc snd_opl3 *opl3;
  snd_opl3_new(thẻ, OPL3_HW_OPL3_XXX, &opl3);

Sau đó đặt ZZ0000ZZ, ZZ0001ZZ và ZZ0002ZZ cho
chức năng truy cập riêng tư, dữ liệu riêng tư và hàm hủy. các
ZZ0003ZZ và ZZ0004ZZ không nhất thiết phải được đặt. Chỉ có lệnh
phải được thiết lập đúng cách. Bạn có thể truy xuất dữ liệu từ
Trường ZZ0005ZZ.

Sau khi tạo phiên bản opl3 qua ZZ0000ZZ,
gọi ZZ0001ZZ để khởi tạo chip cho
trạng thái thích hợp. Lưu ý rằng ZZ0002ZZ luôn gọi
nó trong nội bộ.

Nếu phiên bản opl3 được tạo thành công thì hãy tạo thiết bị hwdep
cho opl3 này::

struct snd_hwdep *opl3hwdep;
  snd_opl3_hwdep_new(opl3, 0, 1, &opl3hwdep);

Đối số đầu tiên là phiên bản ZZ0000ZZ mà bạn đã tạo và đối số
thứ hai là số chỉ mục, thường là 0.

Đối số thứ ba là phần bù chỉ mục cho máy khách trình sắp xếp thứ tự được chỉ định
đến cổng OPL3. Khi có MPU401-UART thì cho 1 cho đây (UART
luôn lấy 0).

Thiết bị phụ thuộc vào phần cứng
--------------------------

Một số chip cần quyền truy cập vào không gian người dùng để điều khiển đặc biệt hoặc để tải
mã vi mô. Trong trường hợp như vậy, bạn có thể tạo một hwdep
thiết bị (phụ thuộc vào phần cứng). hwdep API được định nghĩa trong
ZZ0000ZZ. Bạn có thể tìm thấy các ví dụ trong trình điều khiển opl3 hoặc
ZZ0001ZZ.

Việc tạo phiên bản ZZ0001ZZ được thực hiện thông qua
ZZ0000ZZ::

cấu trúc snd_hwdep *hw;
  snd_hwdep_new(thẻ, "HWDEP của tôi", 0, &hw);

trong đó đối số thứ ba là số chỉ mục.

Sau đó, bạn có thể chuyển bất kỳ giá trị con trỏ nào tới ZZ0000ZZ. Nếu bạn
gán dữ liệu riêng tư, bạn cũng nên xác định hàm hủy. các
hàm hủy được đặt trong trường ZZ0001ZZ ::

cấu trúc mydata *p = kmalloc(sizeof(*p), GFP_KERNEL);
  hw->private_data = p;
  hw->private_free = mydata_free;

và việc thực hiện hàm hủy sẽ là ::

static void mydata_free(struct snd_hwdep *hw)
  {
          struct mydata *p = hw->private_data;
          kfree(p);
  }

Các hoạt động tập tin tùy ý có thể được xác định cho trường hợp này. tập tin
các toán tử được định nghĩa trong bảng ZZ0000ZZ. Ví dụ, giả sử rằng
con chip này cần một ioctl::

hw->ops.open = mydata_open;
  hw->ops.ioctl = mydata_ioctl;
  hw->ops.release = mydata_release;

Và thực hiện các chức năng gọi lại theo ý muốn.

IEC958 (S/PDIF)
---------------

Thông thường việc điều khiển cho các thiết bị IEC958 được thực hiện thông qua điều khiển
giao diện. Có macro soạn chuỗi tên cho IEC958
điều khiển, ZZ0000ZZ được xác định trong
ZZ0001ZZ.

Có một số điều khiển tiêu chuẩn cho các bit trạng thái IEC958. Những điều khiển này
sử dụng loại ZZ0000ZZ và kích thước của phần tử là
đã sửa thành mảng 4 byte (value.iec958.status[x]). Dành cho ZZ0001ZZ
gọi lại, bạn không chỉ định trường giá trị cho loại này (số lượng
Tuy nhiên, trường phải được đặt).

“IEC958 Playback Con Mask” được sử dụng để trả lại mặt nạ bit cho IEC958
bit trạng thái của chế độ tiêu dùng. Tương tự, “IEC958 Playback Pro Mask”
trả về bitmask cho chế độ chuyên nghiệp. Chúng là các điều khiển chỉ đọc.

Trong khi đó, điều khiển “Mặc định phát lại IEC958” được xác định để nhận và
thiết lập các bit IEC958 mặc định hiện tại.

Vì lý do lịch sử, cả hai biến thể của Mặt nạ phát lại và
Phát lại Các điều khiển mặc định có thể được triển khai trên một
ZZ0000ZZ hoặc mặt ZZ0001ZZ.
Tuy nhiên, các trình điều khiển nên để lộ mặt nạ và mặc định trên cùng một mặt nạ.

Ngoài ra, bạn có thể xác định các công tắc điều khiển để bật/tắt hoặc để
đặt chế độ bit thô. Việc thực hiện sẽ phụ thuộc vào chip, nhưng
điều khiển phải được đặt tên là “IEC958 xxx”, tốt nhất là sử dụng
Macro ZZ0000ZZ.

Bạn có thể tìm thấy một số trường hợp, ví dụ: ZZ0000ZZ,
ZZ0001ZZ, hoặc ZZ0002ZZ.

Quản lý bộ đệm và bộ nhớ
============================

Các loại bộ đệm
------------

ALSA cung cấp một số chức năng phân bổ bộ đệm khác nhau tùy thuộc vào
xe buýt và kiến trúc. Tất cả những thứ này đều có API nhất quán. các
việc phân bổ các trang liền kề về mặt vật lý được thực hiện thông qua
Chức năng ZZ0000ZZ, trong đó xxx là bus
loại.

Việc phân bổ các trang có dự phòng được thực hiện thông qua
ZZ0000ZZ. Chức năng này cố gắng
để phân bổ số lượng trang được chỉ định, nhưng nếu không đủ trang thì
có sẵn, nó cố gắng giảm kích thước yêu cầu cho đến khi đủ dung lượng
được tìm thấy, xuống đến một trang.

Để giải phóng các trang, hãy gọi ZZ0000ZZ
chức năng.

Thông thường, trình điều khiển ALSA cố gắng phân bổ và dự trữ một lượng lớn liền kề
không gian vật lý tại thời điểm mô-đun được tải để sử dụng sau này. Cái này
được gọi là “phân bổ trước”. Như đã viết, bạn có thể gọi
chức năng sau tại thời điểm xây dựng phiên bản PCM (trong trường hợp PCI
xe buýt)::

snd_pcm_lib_preallocate_pages_for_all(pcm, SNDRV_DMA_TYPE_DEV,
                                        &pci->dev, kích thước, tối đa);

trong đó ZZ0000ZZ là kích thước byte được phân bổ trước và ZZ0001ZZ là
kích thước tối đa có thể cài đặt thông qua tệp Proc ZZ0002ZZ. các
người cấp phát sẽ cố gắng lấy được một diện tích càng lớn càng tốt trong phạm vi
kích thước nhất định.

Đối số thứ hai (loại) và đối số thứ ba (con trỏ thiết bị) là
phụ thuộc vào xe buýt. Đối với các thiết bị bình thường, chuyển con trỏ thiết bị
(thường giống với ZZ0000ZZ) với đối số thứ ba với
Loại ZZ0001ZZ.

Một bộ đệm liên tục không liên quan đến
xe buýt có thể được phân bổ trước với loại ZZ0000ZZ.
Bạn có thể chuyển NULL tới con trỏ thiết bị trong trường hợp đó, đó là
chế độ mặc định ngụ ý phân bổ bằng cờ ZZ0001ZZ.
Nếu bạn cần một địa chỉ bị hạn chế (thấp hơn), hãy thiết lập mặt nạ DMA mạch lạc
bit cho thiết bị và chuyển con trỏ thiết bị, giống như thông thường
phân bổ bộ nhớ thiết bị.  Đối với loại này vẫn được phép pass
NULL tới con trỏ thiết bị, nếu không cần hạn chế địa chỉ.

Đối với bộ đệm thu thập phân tán, hãy sử dụng ZZ0000ZZ với
con trỏ thiết bị (xem phần ZZ0001ZZ).

Sau khi bộ đệm được cấp phát trước, bạn có thể sử dụng bộ cấp phát trong
Gọi lại ZZ0000ZZ::

snd_pcm_lib_malloc_pages(substream, kích thước);

Lưu ý bạn phải phân bổ trước để sử dụng chức năng này.

Nhưng hầu hết các trình điều khiển đều sử dụng "chế độ phân bổ bộ đệm được quản lý"
phân bổ và giải phóng thủ công.
Điều này được thực hiện bằng cách gọi ZZ0000ZZ
thay vì ZZ0001ZZ::

snd_pcm_set_managed_buffer_all(pcm, SNDRV_DMA_TYPE_DEV,
                                 &pci->dev, kích thước, tối đa);

trong đó các đối số được truyền giống hệt nhau cho cả hai hàm.
Sự khác biệt trong chế độ được quản lý là lõi PCM sẽ gọi
ZZ0000ZZ đã có sẵn nội bộ trước khi gọi
gọi lại PCM ZZ0002ZZ và gọi ZZ0001ZZ
sau khi tự động gọi lại PCM ZZ0003ZZ.  Vì thế người lái xe
không cần phải gọi các hàm này một cách rõ ràng trong lệnh gọi lại của nó bất kỳ
lâu hơn.  Điều này cho phép nhiều trình điều khiển có NULL ZZ0004ZZ và
Các mục ZZ0005ZZ.

Bộ đệm phần cứng bên ngoài
-------------------------

Một số chip có bộ đệm phần cứng riêng và chuyển DMA từ
bộ nhớ máy chủ không có sẵn. Trong trường hợp như vậy, bạn cần phải 1)
sao chép/đặt dữ liệu âm thanh trực tiếp vào bộ đệm phần cứng bên ngoài hoặc 2)
tạo một bộ đệm trung gian và sao chép/đặt dữ liệu từ nó vào
bộ đệm phần cứng bên ngoài trong các ngắt (hoặc tốt nhất là trong các tác vụ nhỏ).

Trường hợp đầu tiên hoạt động tốt nếu bộ đệm phần cứng bên ngoài lớn
đủ rồi. Phương pháp này không cần thêm bất kỳ bộ đệm nào và do đó hiệu quả hơn
hiệu quả. Bạn cần xác định cuộc gọi lại ZZ0000ZZ
để truyền dữ liệu, ngoài ZZ0001ZZ
gọi lại để phát lại. Tuy nhiên có một nhược điểm là không thể
mmapped. Các ví dụ là GF1 PCM của GUS hoặc PCM có thể quét của emu8000.

Trường hợp thứ hai cho phép mmap trên bộ đệm, mặc dù bạn phải
xử lý một ngắt hoặc một tasklet để truyền dữ liệu từ
bộ đệm trung gian vào bộ đệm phần cứng. Bạn có thể tìm thấy một ví dụ trong
trình điều khiển vxpocket.

Một trường hợp khác là khi chip sử dụng vùng bản đồ bộ nhớ PCI cho
đệm thay vì bộ nhớ máy chủ. Trong trường hợp này, mmap chỉ khả dụng
trên một số kiến trúc nhất định như kiến trúc Intel. Ở chế độ không phải mmap, dữ liệu
không thể chuyển giao như cách thông thường. Vì vậy bạn cần xác định
Các lệnh gọi lại ZZ0000ZZ và ZZ0001ZZ cũng vậy,
như các trường hợp trên. Các ví dụ được tìm thấy trong ZZ0002ZZ và
ZZ0003ZZ.

Việc triển khai ZZ0000ZZ và
Lệnh gọi lại ZZ0001ZZ phụ thuộc vào việc phần cứng có hỗ trợ hay không
mẫu xen kẽ hoặc không xen kẽ. Lệnh gọi lại ZZ0002ZZ là
được xác định như bên dưới, hơi khác một chút tùy thuộc vào hướng
là phát lại hoặc chụp::

int tĩnh phát lại_copy(struct snd_pcm_substream *substream,
               kênh int, vị trí dài không dấu,
               struct iov_iter *src, số lượng dài không dấu);
  int static capture_copy(struct snd_pcm_substream *substream,
               kênh int, vị trí dài không dấu,
               struct iov_iter *dst, số lượng dài không dấu);

Trong trường hợp các mẫu xen kẽ, đối số thứ hai (ZZ0000ZZ) là
không được sử dụng. Đối số thứ ba (ZZ0001ZZ) chỉ định vị trí tính bằng byte.

Ý nghĩa của đối số thứ tư là khác nhau giữa phát lại và
bắt giữ. Để phát lại, nó giữ con trỏ dữ liệu nguồn và để
capture, đó là con trỏ dữ liệu đích.

Đối số cuối cùng là số byte được sao chép.

Những gì bạn phải làm trong cuộc gọi lại này lại khác giữa các lần phát lại
và nắm bắt chỉ đường. Trong trường hợp phát lại, bạn sao chép số tiền đã cho
của dữ liệu (ZZ0000ZZ) tại con trỏ được chỉ định (ZZ0001ZZ) tới con trỏ được chỉ định
offset (ZZ0002ZZ) trong bộ đệm phần cứng. Khi được mã hóa giống như memcpy
Nhân tiện, bản sao sẽ trông như thế này::

my_memcpy_from_iter(my_buffer + pos, src, count);

Đối với hướng chụp, bạn sao chép lượng dữ liệu đã cho (ZZ0000ZZ)
tại độ lệch được chỉ định (ZZ0001ZZ) trong bộ đệm phần cứng tới
con trỏ được chỉ định (ZZ0002ZZ)::

my_memcpy_to_iter(dst, my_buffer + pos, count);

ZZ0000ZZ hoặc ZZ0001ZZ đã cho là một con trỏ struct iov_iter chứa
con trỏ và kích thước.  Sử dụng các trợ giúp hiện có để sao chép hoặc truy cập
dữ liệu như được xác định trong ZZ0002ZZ.

Những người đọc cẩn thận có thể nhận thấy rằng những lệnh gọi lại này nhận được
đối số theo byte, không phải trong khung như các lệnh gọi lại khác.  Đó là bởi vì
điều này làm cho việc viết mã dễ dàng hơn như trong các ví dụ trên và nó cũng làm cho
việc thống nhất cả hai trường hợp xen kẽ và không xen kẽ sẽ dễ dàng hơn, vì
giải thích dưới đây.

Trong trường hợp các mẫu không xen kẽ, việc thực hiện sẽ hơi phức tạp
phức tạp hơn.  Cuộc gọi lại được gọi cho mỗi kênh, được chuyển vào
đối số thứ hai, do đó tổng cộng nó được gọi là N lần cho mỗi lần truyền.

Ý nghĩa của các lập luận khác gần giống như trong
trường hợp xen kẽ.  Cuộc gọi lại có nhiệm vụ sao chép dữ liệu từ/đến
bộ đệm không gian người dùng nhất định, nhưng chỉ dành cho kênh nhất định. cho
chi tiết, vui lòng kiểm tra ZZ0000ZZ hoặc ZZ0001ZZ
như những ví dụ.

Thông thường để phát lại, một lệnh gọi lại ZZ0000ZZ khác là
được xác định.  Nó được triển khai theo cách tương tự như lệnh gọi lại sao chép
ở trên::

int im lặng tĩnh (struct snd_pcm_substream *substream, kênh int,
                     pos dài không dấu, số lượng dài không dấu);

Ý nghĩa của các đối số giống như trong lệnh gọi lại ZZ0000ZZ,
mặc dù không có con trỏ đệm
lý lẽ. Trong trường hợp các mẫu xen kẽ, đối số kênh có
không có ý nghĩa gì, đối với lệnh gọi lại ZZ0001ZZ.

Vai trò của lệnh gọi lại ZZ0000ZZ là đặt số tiền đã cho
(ZZ0001ZZ) của dữ liệu im lặng ở độ lệch được chỉ định (ZZ0002ZZ) trong
bộ đệm phần cứng. Giả sử rằng định dạng dữ liệu được ký (nghĩa là,
dữ liệu im lặng là 0) và việc triển khai bằng hàm giống như bộ nhớ
sẽ trông giống như::

my_memset(my_buffer + pos, 0, count);

Trong trường hợp các mẫu không xen kẽ, việc thực hiện
trở nên phức tạp hơn một chút, vì nó được gọi là N lần mỗi lần chuyển
cho mỗi kênh. Ví dụ, hãy xem ZZ0000ZZ.

Bộ đệm không liền kề
----------------------

Nếu phần cứng của bạn hỗ trợ bảng trang như trong emu10k1 hoặc bộ đệm
mô tả như trong via82xx, bạn có thể sử dụng bộ thu thập phân tán (SG) DMA. ALSA
cung cấp một giao diện để xử lý bộ đệm SG. API được cung cấp trong
ZZ0000ZZ.

Để tạo trình xử lý bộ đệm SG, hãy gọi
ZZ0000ZZ hoặc
ZZ0001ZZ với
ZZ0002ZZ trong hàm tạo PCM giống như PCI khác
phân bổ trước. Bạn cần phải vượt qua ZZ0003ZZ, nơi pci ở
con trỏ struct pci_dev của chip cũng vậy ::

snd_pcm_set_managed_buffer_all(pcm, SNDRV_DMA_TYPE_DEV_SG,
                                 &pci->dev, kích thước, tối đa);

Phiên bản ZZ0000ZZ được tạo dưới dạng
ZZ0001ZZ lần lượt. Bạn có thể truyền con trỏ như::

struct snd_sg_buf ZZ0000ZZ)substream->dma_private;

Sau đó, trong lệnh gọi ZZ0000ZZ, bộ đệm SG chung
trình xử lý sẽ phân bổ các trang kernel không liền kề có kích thước nhất định
và ánh xạ chúng dưới dạng bộ nhớ gần như liền kề. Con trỏ ảo
được giải quyết thông qua thời gian chạy-> dma_area. Địa chỉ vật lý
(ZZ0002ZZ) được đặt thành 0, vì bộ đệm được
về mặt vật lý không liền kề nhau. Bảng địa chỉ vật lý được thiết lập trong
ZZ0003ZZ. Bạn có thể lấy địa chỉ vật lý ở một mức chênh lệch nhất định
thông qua ZZ0001ZZ.

Nếu bạn cần giải phóng dữ liệu bộ đệm SG một cách rõ ràng, hãy gọi
API tiêu chuẩn có chức năng ZZ0000ZZ như bình thường.

Bộ đệm Vmalloc'ed
------------------

Có thể sử dụng bộ đệm được phân bổ thông qua ZZ0000ZZ, để
ví dụ, đối với bộ đệm trung gian.
Bạn chỉ có thể phân bổ nó thông qua tiêu chuẩn
ZZ0001ZZ và cộng sự. sau khi thiết lập
Phân bổ trước bộ đệm với loại ZZ0002ZZ::

snd_pcm_set_managed_buffer_all(pcm, SNDRV_DMA_TYPE_VMALLOC,
                                 NULL, 0, 0);

NULL được truyền dưới dạng đối số con trỏ thiết bị, cho biết
các trang mặc định đó (GFP_KERNEL và GFP_HIGHMEM) sẽ
được phân bổ.

Ngoài ra, hãy lưu ý rằng số 0 được chuyển ở cả kích thước và kích thước tối đa
tranh luận ở đây.  Vì mỗi cuộc gọi vmalloc sẽ thành công bất cứ lúc nào,
chúng ta không cần phân bổ trước bộ đệm như các cách liên tục khác
trang.

Giao diện Proc
==============

ALSA cung cấp giao diện dễ dàng cho các quy trình. Các tập tin proc rất
hữu ích cho việc gỡ lỗi. Tôi khuyên bạn nên thiết lập các tập tin Proc nếu bạn viết một
trình điều khiển và muốn có trạng thái đang chạy hoặc đăng ký kết xuất. API là
được tìm thấy trong ZZ0000ZZ.

Để tạo tệp Proc, hãy gọi ZZ0000ZZ::

struct snd_info_entry *entry;
  int err = snd_card_proc_new(thẻ, "tệp của tôi", &entry);

trong đó đối số thứ hai chỉ định tên của tệp Proc sẽ được
được tạo ra. Ví dụ trên sẽ tạo một tệp ZZ0000ZZ trong phần mở rộng
thư mục thẻ, ví dụ: ZZ0001ZZ.

Giống như các thành phần khác, mục Proc được tạo thông qua
ZZ0000ZZ sẽ được đăng ký và phát hành
tự động trong chức năng đăng ký và phát hành thẻ.

Khi quá trình tạo thành công, hàm sẽ lưu một phiên bản mới vào
con trỏ được đưa ra trong đối số thứ ba. Nó được khởi tạo dưới dạng văn bản
tập tin proc chỉ để đọc. Để sử dụng tệp Proc này làm tệp văn bản chỉ đọc
nguyên trạng, hãy đặt lệnh gọi lại đã đọc với dữ liệu riêng tư thông qua
ZZ0000ZZ::

snd_info_set_text_ops(entry, chip, my_proc_read);

trong đó đối số thứ hai (ZZ0000ZZ) là dữ liệu riêng tư được sử dụng trong
cuộc gọi lại. Tham số thứ ba chỉ định kích thước bộ đệm đọc và
thứ tư (ZZ0001ZZ) là chức năng gọi lại, đó là
được xác định như::

static void my_proc_read(struct snd_info_entry *entry,
                           struct snd_info_buffer *bộ đệm);

Trong lệnh gọi lại đã đọc, hãy sử dụng ZZ0000ZZ cho đầu ra
chuỗi, hoạt động giống như ZZ0001ZZ bình thường. Ví dụ::

static void my_proc_read(struct snd_info_entry *entry,
                           cấu trúc snd_info_buffer *bộ đệm)
  {
          struct my_chip *chip = entry->private_data;

snd_iprintf(bộ đệm, "Đây là chip của tôi!\n");
          snd_iprintf(bộ đệm, "Cổng = %ld\n", chip->port);
  }

Quyền của tập tin có thể được thay đổi sau đó. Theo mặc định, chúng là
chỉ đọc cho tất cả người dùng. Nếu bạn muốn thêm quyền ghi cho
người dùng (root theo mặc định), hãy làm như sau ::

mục->chế độ = S_IFREG ZZ0000ZZ S_IWUSR;

và đặt kích thước bộ đệm ghi và gọi lại ::

entry->c.text.write = my_proc_write;

Trong cuộc gọi lại ghi, bạn có thể sử dụng ZZ0000ZZ
để lấy một dòng văn bản và ZZ0001ZZ để truy xuất
một chuỗi từ dòng. Một số ví dụ được tìm thấy trong
ZZ0002ZZ, lõi/oss/và ZZ0003ZZ.

Đối với tệp Proc dữ liệu thô, hãy đặt các thuộc tính như sau ::

cấu trúc const tĩnh snd_info_entry_ops my_file_io_ops = {
          .read = my_file_io_read,
  };

mục->nội dung = SNDRV_INFO_CONTENT_DATA;
  mục->private_data = chip;
  entry->c.ops = &my_file_io_ops;
  mục-> kích thước = 4096;
  mục->chế độ = S_IFREG | S_IRUGO;

Đối với dữ liệu thô, trường ZZ0000ZZ phải được đặt đúng. Điều này chỉ định
kích thước tối đa của quyền truy cập tệp Proc.

Lệnh gọi lại đọc/ghi ở chế độ thô trực tiếp hơn chế độ văn bản.
Bạn cần sử dụng các chức năng I/O cấp thấp như
ZZ0000ZZ và ZZ0001ZZ để chuyển
dữ liệu::

ssize_t tĩnh my_file_io_read(struct snd_info_entry *entry,
                              vô hiệu *file_private_data,
                              tập tin cấu trúc * tập tin,
                              char *buf,
                              số lượng size_t,
                              tư thế loff_t)
  {
          if (copy_to_user(buf, local_data + pos, count))
                  trả về -EFAULT;
          số lần trả lại;
  }

Nếu kích thước của mục nhập thông tin đã được thiết lập đúng cách, ZZ0000ZZ và
ZZ0001ZZ được đảm bảo vừa với 0 và kích thước nhất định. bạn không
phải kiểm tra phạm vi trong các cuộc gọi lại trừ khi có bất kỳ điều kiện nào khác
được yêu cầu.

Quản lý nguồn điện
================

Nếu chip được cho là hoạt động với chức năng tạm dừng/tiếp tục, bạn cần
để thêm mã quản lý nguồn cho trình điều khiển. Mã bổ sung cho
quản lý năng lượng phải được ifdef-ed với ZZ0000ZZ hoặc được chú thích
với thuộc tính __maybe_unused; nếu không trình biên dịch sẽ khiếu nại.

Nếu trình điều khiển ZZ0002ZZ hỗ trợ tạm dừng/tiếp tục thì thiết bị có thể
được khôi phục đúng cách về trạng thái của nó khi tạm dừng được gọi, bạn có thể đặt
Cờ ZZ0000ZZ trong trường thông tin PCM. Thông thường, đây là
có thể thực hiện được khi các thanh ghi của chip có thể được lưu và khôi phục một cách an toàn
tới RAM. Nếu điều này được đặt, lệnh gọi lại kích hoạt sẽ được gọi với
ZZ0001ZZ sau khi quá trình gọi lại tiếp tục hoàn tất.

Ngay cả khi trình điều khiển không hỗ trợ PM đầy đủ nhưng tạm dừng/tiếp tục một phần
vẫn có thể, vẫn đáng để thực hiện tạm dừng/tiếp tục
cuộc gọi lại. Trong trường hợp như vậy, các ứng dụng sẽ đặt lại trạng thái bằng cách
gọi ZZ0000ZZ và khởi động lại luồng
một cách thích hợp. Do đó, bạn có thể xác định tạm dừng/tiếp tục cuộc gọi lại bên dưới nhưng
không đặt cờ thông tin ZZ0001ZZ thành PCM.

Lưu ý rằng trình kích hoạt với SUSPEND luôn có thể được gọi khi
ZZ0000ZZ được gọi, bất kể
Cờ ZZ0002ZZ. Cờ ZZ0003ZZ chỉ ảnh hưởng đến
hành vi của ZZ0001ZZ. (Như vậy, về mặt lý thuyết,
ZZ0004ZZ không cần phải được xử lý trong trình kích hoạt
gọi lại khi không có cờ ZZ0005ZZ nào được đặt. Nhưng, tốt hơn
để giữ nó vì lý do tương thích.)

Người lái xe cần xác định
tạm dừng/tiếp tục móc theo xe buýt mà thiết bị được kết nối. trong
trong trường hợp trình điều khiển PCI, lệnh gọi lại trông như dưới đây::

int tĩnh __maybe_unused snd_my_suspend(thiết bị cấu trúc *dev)
  {
          .... /* do things for suspend */
trả về 0;
  }
  int tĩnh __maybe_unused snd_my_resume(thiết bị cấu trúc *dev)
  {
          .... /* do things for suspend */
trả về 0;
  }

Sơ đồ của công việc đình chỉ thực sự như sau:

1. Lấy lại thẻ và dữ liệu chip.

2. Gọi ZZ0000ZZ bằng
   ZZ0001ZZ để thay đổi trạng thái nguồn.

3. Nếu sử dụng codec AC97, hãy gọi ZZ0000ZZ để biết
   mỗi bộ giải mã.

4. Lưu các giá trị đăng ký nếu cần.

5. Dừng phần cứng nếu cần thiết.

Mã điển hình sẽ trông giống như::

int tĩnh __maybe_unused mychip_suspend(thiết bị cấu trúc *dev)
  {
          /* (1) */
          struct snd_card *card = dev_get_drvdata(dev);
          struct mychip *chip = card->private_data;
          /* (2) */
          snd_power_change_state(thẻ, SNDRV_CTL_POWER_D3hot);
          /* (3) */
          snd_ac97_suspend(chip->ac97);
          /* (4) */
          snd_mychip_save_registers(chip);
          /* (5) */
          snd_mychip_stop_hardware(chip);
          trả về 0;
  }


Sơ đồ của công việc sơ yếu lý lịch thực tế như sau:

1. Lấy lại thẻ và dữ liệu chip.

2. Khởi tạo lại chip.

3. Khôi phục các thanh ghi đã lưu nếu cần.

4. Tiếp tục lại máy trộn, ví dụ: bằng cách gọi ZZ0000ZZ.

5. Khởi động lại phần cứng (nếu có).

6. Gọi ZZ0000ZZ bằng
   ZZ0001ZZ để thông báo các quy trình.

Mã điển hình sẽ trông giống như::

int tĩnh __maybe_unused mychip_resume(struct pci_dev *pci)
  {
          /* (1) */
          struct snd_card *card = dev_get_drvdata(dev);
          struct mychip *chip = card->private_data;
          /* (2) */
          snd_mychip_reinit_chip(chip);
          /* (3) */
          snd_mychip_restore_registers(chip);
          /* (4) */
          snd_ac97_resume(chip->ac97);
          /* (5) */
          snd_mychip_restart_chip(chip);
          /* (6) */
          snd_power_change_state(thẻ, SNDRV_CTL_POWER_D0);
          trả về 0;
  }

Lưu ý rằng, tại thời điểm lệnh gọi lại này được gọi, luồng PCM có
đã bị đình chỉ thông qua cuộc gọi PM ops của chính nó
ZZ0000ZZ bên trong.

Được rồi, bây giờ chúng tôi có tất cả lệnh gọi lại. Hãy thiết lập chúng. Trong quá trình khởi tạo
của thẻ, hãy đảm bảo rằng bạn có thể lấy dữ liệu chip từ thẻ
chẳng hạn, thường thông qua trường ZZ0000ZZ, trong trường hợp bạn đã tạo
dữ liệu chip riêng lẻ::

int tĩnh snd_mychip_probe(struct pci_dev *pci,
                              const struct pci_device_id *pci_id)
  {
          ....
struct snd_card *card;
          cấu trúc mychip *chip;
          int lỗi;
          ....
err = snd_card_new(&pci->dev, index[dev], id[dev], THIS_MODULE,
                             0, &thẻ);
          ....
chip = kzalloc(sizeof(*chip), GFP_KERNEL);
          ....
thẻ->private_data = chip;
          ....
  }

Khi bạn tạo dữ liệu chip bằng ZZ0000ZZ, nó
vẫn có thể truy cập được qua trường ZZ0001ZZ::

int tĩnh snd_mychip_probe(struct pci_dev *pci,
                              const struct pci_device_id *pci_id)
  {
          ....
struct snd_card *card;
          cấu trúc mychip *chip;
          int lỗi;
          ....
err = snd_card_new(&pci->dev, index[dev], id[dev], THIS_MODULE,
                             sizeof(struct mychip), &card);
          ....
chip = thẻ->private_data;
          ....
  }

Nếu bạn cần dung lượng để lưu các thanh ghi, hãy phân bổ bộ đệm cho nó
ở đây cũng vậy, vì sẽ nguy hiểm nếu bạn không thể cấp phát bộ nhớ trong
giai đoạn đình chỉ. Bộ đệm được phân bổ sẽ được giải phóng trong
hàm hủy tương ứng.

Và tiếp theo, đặt lệnh gọi lại tạm dừng/tiếp tục thành pci_driver::

DEFINE_SIMPLE_DEV_PM_OPS tĩnh (snd_my_pm_ops, mychip_suspend, mychip_resume);

trình điều khiển pci_driver cấu trúc tĩnh = {
          .name = KBUILD_MODNAME,
          .id_table = snd_my_ids,
          .probe = snd_my_probe,
          .remove = snd_my_remove,
          .driver = {
                  .pm = &snd_my_pm_ops,
          },
  };

Thông số mô-đun
=================

Có các tùy chọn mô-đun tiêu chuẩn cho ALSA. Ít nhất, mỗi mô-đun nên
có các tùy chọn ZZ0000ZZ, ZZ0001ZZ và ZZ0002ZZ.

Nếu mô-đun hỗ trợ nhiều thẻ (thường lên tới 8 = ZZ0000ZZ
thẻ), chúng phải là mảng. Các giá trị ban đầu mặc định được xác định
đã là hằng số để lập trình dễ dàng hơn::

chỉ số int tĩnh [SNDRV_CARDS] = SNDRV_DEFAULT_IDX;
  char tĩnh *id[SNDRV_CARDS] = SNDRV_DEFAULT_STR;
  kích hoạt int tĩnh [SNDRV_CARDS] = SNDRV_DEFAULT_ENABLE_PNP;

Nếu mô-đun chỉ hỗ trợ một thẻ duy nhất thì chúng có thể là thẻ đơn
thay vào đó là các biến. Tùy chọn ZZ0000ZZ không phải lúc nào cũng cần thiết trong trường hợp này
trường hợp này, nhưng sẽ tốt hơn nếu có một tùy chọn giả để tương thích.

Các thông số module phải được khai báo đúng tiêu chuẩn
ZZ0001ZZ, ZZ0002ZZ và
Macro ZZ0000ZZ.

Mã điển hình sẽ trông như dưới đây::

#define CARD_NAME "Chip của tôi"

module_param_array(index, int, NULL, 0444);
  MODULE_PARM_DESC(chỉ mục, "Giá trị chỉ mục cho soundcard " CARD_NAME.");
  module_param_array(id, charp, NULL, 0444);
  MODULE_PARM_DESC(id, "Chuỗi ID cho soundcard " CARD_NAME.");
  module_param_array(bật, bool, NULL, 0444);
  MODULE_PARM_DESC(bật, "Bật card âm thanh " CARD_NAME ".");

Ngoài ra, đừng quên xác định mô tả mô-đun và giấy phép.
Đặc biệt, modprobe gần đây yêu cầu xác định
giấy phép mô-đun như GPL, v.v., nếu không thì hệ thống được hiển thị là “bị nhiễm độc”::

MODULE_DESCRIPTION("Trình điều khiển âm thanh cho Chip của tôi");
  MODULE_LICENSE("GPL");


Tài nguyên do thiết bị quản lý
========================

Trong các ví dụ trên, tất cả tài nguyên được phân bổ và giải phóng
bằng tay.  Nhưng bản chất con người là lười biếng, đặc biệt là các nhà phát triển
lười biếng hơn  Vì vậy có một số cách để tự động hóa phần phát hành; đó là
tài nguyên được quản lý (thiết bị-) hay còn gọi là họ devres hoặc devm.  cho
ví dụ, một đối tượng được phân bổ thông qua ZZ0000ZZ sẽ là
được giải phóng tự động khi hủy liên kết thiết bị.

Lõi ALSA cũng cung cấp trình trợ giúp do thiết bị quản lý, cụ thể là:
ZZ0000ZZ để tạo đối tượng thẻ.
Gọi hàm này thay vì ZZ0001ZZ thông thường,
và bạn có thể quên cuộc gọi ZZ0002ZZ rõ ràng, như
nó được gọi tự động ở các đường dẫn lỗi và loại bỏ.

Một lưu ý là lệnh gọi ZZ0000ZZ sẽ được đặt
ở đầu chuỗi cuộc gọi chỉ sau khi bạn gọi
ZZ0001ZZ.

Ngoài ra, cuộc gọi lại ZZ0001ZZ luôn được gọi miễn phí,
vì vậy hãy cẩn thận thực hiện quy trình dọn dẹp phần cứng
Gọi lại ZZ0002ZZ.  Nó có thể được gọi ngay cả trước khi bạn
thực sự được thiết lập ở đường dẫn lỗi trước đó.  Để tránh một điều như vậy
khởi tạo không hợp lệ, bạn có thể đặt gọi lại ZZ0003ZZ sau
Cuộc gọi ZZ0000ZZ thành công.

Một điều cần lưu ý nữa là bạn nên sử dụng tính năng quản lý thiết bị
người trợ giúp cho từng thành phần nhiều nhất có thể một lần khi bạn quản lý
thẻ theo cách đó.  Trộn lẫn giữa bình thường và được quản lý
tài nguyên có thể làm hỏng thứ tự phát hành.


Cách đưa trình điều khiển của bạn vào cây ALSA
=====================================

Tổng quan
-------

Cho đến nay, bạn đã học được cách viết mã trình điều khiển. Và bạn có thể có
bây giờ câu hỏi là: làm cách nào để đưa trình điều khiển của riêng tôi vào cây trình điều khiển ALSA? đây
(cuối cùng :) quy trình chuẩn được mô tả ngắn gọn.

Giả sử bạn tạo trình điều khiển PCI mới cho thẻ “xyz”. Thẻ
tên mô-đun sẽ là snd-xyz. Trình điều khiển mới thường được đưa vào
cây trình điều khiển alsa, thư mục ZZ0000ZZ trong trường hợp PCI
thẻ.

Trong các phần sau, mã trình điều khiển sẽ được đưa vào
Cây nhân Linux. Hai trường hợp được bảo hiểm: một người lái xe bao gồm một
một tệp nguồn duy nhất và một tệp bao gồm nhiều tệp nguồn.

Trình điều khiển với một tệp nguồn duy nhất
--------------------------------

1. Sửa đổi âm thanh/pci/Makefile

Giả sử bạn có một tệp xyz.c. Thêm hai dòng sau::

snd-xyz-y := xyz.o
     obj-$(CONFIG_SND_XYZ) += snd-xyz.o

2. Tạo mục Kconfig

Thêm mục mới của Kconfig cho trình điều khiển xyz của bạn ::

cấu hình SND_XYZ
       tristate "Foobar XYZ"
       phụ thuộc vào SND
       chọn SND_PCM
       giúp đỡ
         Nói Y ở đây để bao gồm hỗ trợ cho soundcard Foobar XYZ.
         Để biên dịch trình điều khiển này thành một mô-đun, hãy chọn M tại đây:
         mô-đun sẽ được gọi là snd-xyz.

Dòng ZZ0000ZZ chỉ định rằng trình điều khiển xyz hỗ trợ PCM.
Ngoài SND_PCM, các thành phần sau được hỗ trợ cho
chọn lệnh: SND_RAWMIDI, SND_TIMER, SND_HWDEP, SND_MPU401_UART,
SND_OPL3_LIB, SND_OPL4_LIB, SND_VX_LIB, SND_AC97_CODEC.
Thêm lệnh chọn cho từng thành phần được hỗ trợ.

Lưu ý rằng một số lựa chọn ngụ ý các lựa chọn cấp thấp. Ví dụ,
PCM bao gồm TIMER, MPU401_UART bao gồm RAWMIDI, AC97_CODEC
bao gồm PCM và OPL3_LIB bao gồm HWDEP. Bạn không cần phải đưa
các lựa chọn cấp thấp một lần nữa.

Để biết chi tiết về tập lệnh Kconfig, hãy tham khảo tài liệu kbuild.

Trình điều khiển với một số tệp nguồn
---------------------------------

Giả sử trình điều khiển snd-xyz có một số tệp nguồn. Họ là
nằm trong thư mục con mới, sound/pci/xyz.

1. Thêm thư mục mới (ZZ0000ZZ) trong ZZ0001ZZ
   như dưới đây::

obj-$(CONFIG_SND) += âm thanh/pci/xyz/


2. Trong thư mục ZZ0000ZZ, tạo Makefile::

snd-xyz-y := xyz.o abc.o def.o
         obj-$(CONFIG_SND_XYZ) += snd-xyz.o

3. Tạo mục Kconfig

Thủ tục này giống như trong phần cuối cùng.


Chức năng hữu ích
================

ZZ0000ZZ
-------------------

Nó hiển thị thông báo ZZ0001ZZ và dấu vết ngăn xếp cũng như
ZZ0000ZZ tại điểm. Thật hữu ích khi chỉ ra rằng một
lỗi nghiêm trọng xảy ra ở đó.

Khi không có cờ gỡ lỗi nào được đặt, macro này sẽ bị bỏ qua.

ZZ0000ZZ
----------------------

Macro ZZ0000ZZ tương tự với
Macro ZZ0001ZZ. Ví dụ: snd_BUG_ON(!pointer); hoặc
nó có thể được sử dụng làm điều kiện, if (snd_BUG_ON(non_zero_is_bug))
trả về -EINVAL;

Macro lấy một biểu thức có điều kiện để đánh giá. Khi nào
ZZ0000ZZ, được đặt, nếu biểu thức khác 0, nó hiển thị
thông báo cảnh báo như ZZ0001ZZ thường được theo sau bởi ngăn xếp
dấu vết. Trong cả hai trường hợp, nó trả về giá trị được đánh giá.

Lời cảm ơn
===============

Tôi xin cảm ơn Phil Kerr vì sự giúp đỡ của ông trong việc cải tiến và
sửa chữa của tài liệu này.

Kevin Conder đã định dạng lại văn bản gốc thành định dạng DocBook.

Giuliano Pochini đã sửa lỗi chính tả và đóng góp các mã mẫu trong
phần hạn chế phần cứng.
