.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/input/uinput.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

==============
mô-đun đầu vào
==============

Giới thiệu
============

uinput là một mô-đun hạt nhân cho phép mô phỏng các thiết bị đầu vào
từ không gian người dùng. Bằng cách ghi vào thiết bị /dev/uinput (hoặc /dev/input/uinput), một
quá trình có thể tạo ra một thiết bị đầu vào ảo với các khả năng cụ thể. Một lần
thiết bị ảo này được tạo, tiến trình có thể gửi các sự kiện thông qua nó,
sẽ được gửi đến không gian người dùng và người tiêu dùng trong hạt nhân.

Giao diện
=========

::

linux/uinput.h

Tiêu đề uinput xác định ioctls để tạo, thiết lập và hủy ảo
thiết bị.

libevdev
========

libevdev là thư viện trình bao bọc cho các thiết bị evdev cung cấp giao diện cho
tạo thiết bị đầu vào và gửi sự kiện. libevdev ít bị lỗi hơn
truy cập trực tiếp vào uinput và cần được xem xét đối với phần mềm mới.

Để biết ví dụ và biết thêm thông tin về libevdev:
ZZ0000ZZ

Ví dụ
========

Sự kiện bàn phím
---------------

Ví dụ đầu tiên này cho thấy cách tạo một thiết bị ảo mới và cách
gửi một sự kiện quan trọng. Tất cả các trình xử lý lỗi và nhập mặc định đã bị xóa vì
vì sự đơn giản.

.. code-block:: c

   #include <linux/uinput.h>

   void emit(int fd, int type, int code, int val)
   {
      struct input_event ie;

      ie.type = type;
      ie.code = code;
      ie.value = val;
      /* timestamp values below are ignored */
      ie.time.tv_sec = 0;
      ie.time.tv_usec = 0;

      write(fd, &ie, sizeof(ie));
   }

   int main(void)
   {
      struct uinput_setup usetup;

      int fd = open("/dev/uinput", O_WRONLY | O_NONBLOCK);


      /*
       * The ioctls below will enable the device that is about to be
       * created, to pass key events, in this case the space key.
       */
      ioctl(fd, UI_SET_EVBIT, EV_KEY);
      ioctl(fd, UI_SET_KEYBIT, KEY_SPACE);

      memset(&usetup, 0, sizeof(usetup));
      usetup.id.bustype = BUS_USB;
      usetup.id.vendor = 0x1234; /* sample vendor */
      usetup.id.product = 0x5678; /* sample product */
      strcpy(usetup.name, "Example device");

      ioctl(fd, UI_DEV_SETUP, &usetup);
      ioctl(fd, UI_DEV_CREATE);

      /*
       * On UI_DEV_CREATE the kernel will create the device node for this
       * device. We are inserting a pause here so that userspace has time
       * to detect, initialize the new device, and can start listening to
       * the event, otherwise it will not notice the event we are about
       * to send. This pause is only needed in our example code!
       */
      sleep(1);

      /* Key press, report the event, send key release, and report again */
      emit(fd, EV_KEY, KEY_SPACE, 1);
      emit(fd, EV_SYN, SYN_REPORT, 0);
      emit(fd, EV_KEY, KEY_SPACE, 0);
      emit(fd, EV_SYN, SYN_REPORT, 0);

      /*
       * Give userspace some time to read the events before we destroy the
       * device with UI_DEV_DESTROY.
       */
      sleep(1);

      ioctl(fd, UI_DEV_DESTROY);
      close(fd);

      return 0;
   }

Chuyển động của chuột
---------------

Ví dụ này cho thấy cách tạo một thiết bị ảo hoạt động giống như một thiết bị vật lý
chuột.

.. code-block:: c

   #include <linux/uinput.h>

   /* emit function is identical to of the first example */

   int main(void)
   {
      struct uinput_setup usetup;
      int i = 50;

      int fd = open("/dev/uinput", O_WRONLY | O_NONBLOCK);

      /* enable mouse button left and relative events */
      ioctl(fd, UI_SET_EVBIT, EV_KEY);
      ioctl(fd, UI_SET_KEYBIT, BTN_LEFT);

      ioctl(fd, UI_SET_EVBIT, EV_REL);
      ioctl(fd, UI_SET_RELBIT, REL_X);
      ioctl(fd, UI_SET_RELBIT, REL_Y);

      memset(&usetup, 0, sizeof(usetup));
      usetup.id.bustype = BUS_USB;
      usetup.id.vendor = 0x1234; /* sample vendor */
      usetup.id.product = 0x5678; /* sample product */
      strcpy(usetup.name, "Example device");

      ioctl(fd, UI_DEV_SETUP, &usetup);
      ioctl(fd, UI_DEV_CREATE);

      /*
       * On UI_DEV_CREATE the kernel will create the device node for this
       * device. We are inserting a pause here so that userspace has time
       * to detect, initialize the new device, and can start listening to
       * the event, otherwise it will not notice the event we are about
       * to send. This pause is only needed in our example code!
       */
      sleep(1);

      /* Move the mouse diagonally, 5 units per axis */
      while (i--) {
         emit(fd, EV_REL, REL_X, 5);
         emit(fd, EV_REL, REL_Y, 5);
         emit(fd, EV_SYN, SYN_REPORT, 0);
         usleep(15000);
      }

      /*
       * Give userspace some time to read the events before we destroy the
       * device with UI_DEV_DESTROY.
       */
      sleep(1);

      ioctl(fd, UI_DEV_DESTROY);
      close(fd);

      return 0;
   }


đầu vào giao diện cũ
--------------------

Trước uinput phiên bản 5, không có ioctl chuyên dụng để thiết lập ảo
thiết bị. Các chương trình hỗ trợ giao diện uinput phiên bản cũ hơn cần điền
cấu trúc uinput_user_dev và ghi nó vào bộ mô tả tệp uinput để
cấu hình thiết bị đầu vào mới. Code mới không nên sử dụng giao diện cũ
nhưng tương tác với uinput thông qua các lệnh gọi ioctl hoặc sử dụng libevdev.

.. code-block:: c

   #include <linux/uinput.h>

   /* emit function is identical to of the first example */

   int main(void)
   {
      struct uinput_user_dev uud;
      int version, rc, fd;

      fd = open("/dev/uinput", O_WRONLY | O_NONBLOCK);
      rc = ioctl(fd, UI_GET_VERSION, &version);

      if (rc == 0 && version >= 5) {
         /* use UI_DEV_SETUP */
         return 0;
      }

      /*
       * The ioctls below will enable the device that is about to be
       * created, to pass key events, in this case the space key.
       */
      ioctl(fd, UI_SET_EVBIT, EV_KEY);
      ioctl(fd, UI_SET_KEYBIT, KEY_SPACE);

      memset(&uud, 0, sizeof(uud));
      snprintf(uud.name, UINPUT_MAX_NAME_SIZE, "uinput old interface");
      write(fd, &uud, sizeof(uud));

      ioctl(fd, UI_DEV_CREATE);

      /*
       * On UI_DEV_CREATE the kernel will create the device node for this
       * device. We are inserting a pause here so that userspace has time
       * to detect, initialize the new device, and can start listening to
       * the event, otherwise it will not notice the event we are about
       * to send. This pause is only needed in our example code!
       */
      sleep(1);

      /* Key press, report the event, send key release, and report again */
      emit(fd, EV_KEY, KEY_SPACE, 1);
      emit(fd, EV_SYN, SYN_REPORT, 0);
      emit(fd, EV_KEY, KEY_SPACE, 0);
      emit(fd, EV_SYN, SYN_REPORT, 0);

      /*
       * Give userspace some time to read the events before we destroy the
       * device with UI_DEV_DESTROY.
       */
      sleep(1);

      ioctl(fd, UI_DEV_DESTROY);

      close(fd);
      return 0;
   }

