.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/userspace-api/ntsync.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

======================================
Trình điều khiển nguyên thủy đồng bộ hóa NT
===================================

Trang này ghi lại không gian người dùng API cho trình điều khiển ntsync.

ntsync là trình điều khiển hỗ trợ mô phỏng đồng bộ hóa NT
nguyên thủy bởi trình giả lập NT trong không gian người dùng. Nó tồn tại bởi vì việc thực hiện
trong không gian người dùng, sử dụng các công cụ hiện có, không thể sánh được với hiệu suất của Windows
trong khi cung cấp ngữ nghĩa chính xác. Nó được thực hiện hoàn toàn trong
phần mềm và không điều khiển bất kỳ thiết bị phần cứng nào.

Giao diện này chỉ có ý nghĩa như một công cụ tương thích và không nên
được sử dụng để đồng bộ hóa chung. Thay vào đó hãy sử dụng chung chung, linh hoạt
các giao diện như futex(2) và poll(2).

Đồng bộ hóa nguyên thủy
==========================

Trình điều khiển ntsync hiển thị ba loại nguyên thủy đồng bộ hóa:
ngữ nghĩa, mutexes và sự kiện.

Một semaphore chứa một bộ đếm 32 bit dễ bay hơi và một bộ đếm 32 bit tĩnh
số nguyên biểu thị giá trị tối đa. Nó được coi là tín hiệu (nghĩa là,
có thể được lấy mà không cần tranh chấp hoặc sẽ đánh thức một chuỗi đang chờ)
khi bộ đếm khác 0. Bộ đếm giảm đi một khi
chờ đợi là thỏa mãn. Cả số lượng ban đầu và số lượng tối đa đều được thiết lập
khi semaphore được tạo ra.

Một mutex chứa số đệ quy 32 bit dễ bay hơi và số lần đệ quy 32 bit dễ bay hơi
định danh biểu thị chủ sở hữu của nó. Một mutex được coi là có tín hiệu khi nó
owner bằng 0 (biểu thị rằng nó không được sở hữu). Số đệ quy là
tăng lên khi thời gian chờ được thỏa mãn và quyền sở hữu được đặt thành đã cho
định danh.

Một mutex cũng giữ một cờ nội bộ biểu thị liệu chủ sở hữu trước đó của nó có
đã chết; một mutex như vậy được cho là bị bỏ rơi. Cái chết của chủ sở hữu không phải là
được theo dõi tự động dựa trên sự chết của luồng, nhưng phải
được giao tiếp bằng ZZ0000ZZ. Một mutex bị bỏ rơi là
vốn được coi là vô danh.

Ngoại trừ ngữ nghĩa "không có tên" bằng 0, giá trị thực của
trình điều khiển ntsync hoàn toàn không giải thích được mã định danh chủ sở hữu. các
mục đích sử dụng là để lưu trữ mã định danh luồng; tuy nhiên, ntsync
trình điều khiển không thực sự xác nhận rằng chuỗi cuộc gọi cung cấp
định danh nhất quán hoặc duy nhất.

Một sự kiện tương tự như một semaphore với số lượng tối đa là một. Nó giữ
một trạng thái boolean dễ bay hơi biểu thị liệu nó có được báo hiệu hay không. Ở đó
có hai loại sự kiện, tự động đặt lại và đặt lại thủ công. Tự động thiết lập lại
sự kiện được chỉ định khi sự chờ đợi được thỏa mãn; một sự kiện thiết lập lại thủ công là
không. Loại sự kiện được chỉ định khi sự kiện được tạo.

Trừ khi có quy định khác, tất cả các thao tác trên một đối tượng đều mang tính nguyên tử và
được sắp xếp hoàn toàn đối với các hoạt động khác trên cùng một đối tượng.

Các đối tượng được đại diện bởi các tập tin. Khi tất cả các bộ mô tả tập tin vào một
đối tượng bị đóng thì đối tượng đó sẽ bị xóa.

thiết bị than
===========

Trình điều khiển ntsync tạo một thiết bị char /dev/ntsync. Mỗi tập tin
mô tả được mở trên thiết bị thể hiện một phiên bản duy nhất được dự định
để sao lưu một máy ảo NT riêng lẻ. Các đối tượng được tạo bởi một ntsync
thể hiện chỉ có thể được sử dụng với các đối tượng khác được tạo bởi cùng một
ví dụ.

tham chiếu ioctl
===============

Mọi thao tác trên thiết bị đều được thực hiện thông qua ioctls. Có bốn
cấu trúc được sử dụng trong các cuộc gọi ioctl::

cấu trúc ntsync_sem_args {
   	__u32 đếm;
   	__u32 tối đa;
   };

cấu trúc ntsync_mutex_args {
   	__u32 chủ sở hữu;
   	__u32 đếm;
   };

cấu trúc ntsync_event_args {
   	__u32 ra hiệu;
   	__u32 hướng dẫn sử dụng;
   };

cấu trúc ntsync_wait_args {
   	__u64 hết thời gian chờ;
   	__u64 đối tượng;
   	__u32 đếm;
   	__u32 chủ sở hữu;
   	chỉ số __u32;
   	__u32 cảnh báo;
   	__u32 cờ;
   	__u32 đệm;
   };

Tùy thuộc vào ioctl, các thành viên của cấu trúc có thể được sử dụng làm đầu vào,
đầu ra hoặc không hề xuất hiện.

Các ioctls trên tệp thiết bị như sau:

.. c:macro:: NTSYNC_IOC_CREATE_SEM

  Create a semaphore object. Takes a pointer to struct
  :c:type:`ntsync_sem_args`, which is used as follows:

  .. list-table::

     * - ``count``
       - Initial count of the semaphore.
     * - ``max``
       - Maximum count of the semaphore.

  Fails with ``EINVAL`` if ``count`` is greater than ``max``.
  On success, returns a file descriptor the created semaphore.

.. c:macro:: NTSYNC_IOC_CREATE_MUTEX

  Create a mutex object. Takes a pointer to struct
  :c:type:`ntsync_mutex_args`, which is used as follows:

  .. list-table::

     * - ``count``
       - Initial recursion count of the mutex.
     * - ``owner``
       - Initial owner of the mutex.

  If ``owner`` is nonzero and ``count`` is zero, or if ``owner`` is
  zero and ``count`` is nonzero, the function fails with ``EINVAL``.
  On success, returns a file descriptor the created mutex.

.. c:macro:: NTSYNC_IOC_CREATE_EVENT

  Create an event object. Takes a pointer to struct
  :c:type:`ntsync_event_args`, which is used as follows:

  .. list-table::

     * - ``signaled``
       - If nonzero, the event is initially signaled, otherwise
         nonsignaled.
     * - ``manual``
       - If nonzero, the event is a manual-reset event, otherwise
         auto-reset.

  On success, returns a file descriptor the created event.

Các ioctls trên các đối tượng riêng lẻ như sau:

.. c:macro:: NTSYNC_IOC_SEM_POST

  Post to a semaphore object. Takes a pointer to a 32-bit integer,
  which on input holds the count to be added to the semaphore, and on
  output contains its previous count.

  If adding to the semaphore's current count would raise the latter
  past the semaphore's maximum count, the ioctl fails with
  ``EOVERFLOW`` and the semaphore is not affected. If raising the
  semaphore's count causes it to become signaled, eligible threads
  waiting on this semaphore will be woken and the semaphore's count
  decremented appropriately.

.. c:macro:: NTSYNC_IOC_MUTEX_UNLOCK

  Release a mutex object. Takes a pointer to struct
  :c:type:`ntsync_mutex_args`, which is used as follows:

  .. list-table::

     * - ``owner``
       - Specifies the owner trying to release this mutex.
     * - ``count``
       - On output, contains the previous recursion count.

  If ``owner`` is zero, the ioctl fails with ``EINVAL``. If ``owner``
  is not the current owner of the mutex, the ioctl fails with
  ``EPERM``.

  The mutex's count will be decremented by one. If decrementing the
  mutex's count causes it to become zero, the mutex is marked as
  unowned and signaled, and eligible threads waiting on it will be
  woken as appropriate.

.. c:macro:: NTSYNC_IOC_SET_EVENT

  Signal an event object. Takes a pointer to a 32-bit integer, which on
  output contains the previous state of the event.

  Eligible threads will be woken, and auto-reset events will be
  designaled appropriately.

.. c:macro:: NTSYNC_IOC_RESET_EVENT

  Designal an event object. Takes a pointer to a 32-bit integer, which
  on output contains the previous state of the event.

.. c:macro:: NTSYNC_IOC_PULSE_EVENT

  Wake threads waiting on an event object while leaving it in an
  unsignaled state. Takes a pointer to a 32-bit integer, which on
  output contains the previous state of the event.

  A pulse operation can be thought of as a set followed by a reset,
  performed as a single atomic operation. If two threads are waiting on
  an auto-reset event which is pulsed, only one will be woken. If two
  threads are waiting a manual-reset event which is pulsed, both will
  be woken. However, in both cases, the event will be unsignaled
  afterwards, and a simultaneous read operation will always report the
  event as unsignaled.

.. c:macro:: NTSYNC_IOC_READ_SEM

  Read the current state of a semaphore object. Takes a pointer to
  struct :c:type:`ntsync_sem_args`, which is used as follows:

  .. list-table::

     * - ``count``
       - On output, contains the current count of the semaphore.
     * - ``max``
       - On output, contains the maximum count of the semaphore.

.. c:macro:: NTSYNC_IOC_READ_MUTEX

  Read the current state of a mutex object. Takes a pointer to struct
  :c:type:`ntsync_mutex_args`, which is used as follows:

  .. list-table::

     * - ``owner``
       - On output, contains the current owner of the mutex, or zero
         if the mutex is not currently owned.
     * - ``count``
       - On output, contains the current recursion count of the mutex.

  If the mutex is marked as abandoned, the function fails with
  ``EOWNERDEAD``. In this case, ``count`` and ``owner`` are set to
  zero.

.. c:macro:: NTSYNC_IOC_READ_EVENT

  Read the current state of an event object. Takes a pointer to struct
  :c:type:`ntsync_event_args`, which is used as follows:

  .. list-table::

     * - ``signaled``
       - On output, contains the current state of the event.
     * - ``manual``
       - On output, contains 1 if the event is a manual-reset event,
         and 0 otherwise.

.. c:macro:: NTSYNC_IOC_KILL_OWNER

  Mark a mutex as unowned and abandoned if it is owned by the given
  owner. Takes an input-only pointer to a 32-bit integer denoting the
  owner. If the owner is zero, the ioctl fails with ``EINVAL``. If the
  owner does not own the mutex, the function fails with ``EPERM``.

  Eligible threads waiting on the mutex will be woken as appropriate
  (and such waits will fail with ``EOWNERDEAD``, as described below).

.. c:macro:: NTSYNC_IOC_WAIT_ANY

  Poll on any of a list of objects, atomically acquiring at most one.
  Takes a pointer to struct :c:type:`ntsync_wait_args`, which is
  used as follows:

  .. list-table::

     * - ``timeout``
       - Absolute timeout in nanoseconds. If ``NTSYNC_WAIT_REALTIME``
         is set, the timeout is measured against the REALTIME clock;
         otherwise it is measured against the MONOTONIC clock. If the
         timeout is equal to or earlier than the current time, the
         function returns immediately without sleeping. If ``timeout``
         is U64_MAX, the function will sleep until an object is
         signaled, and will not fail with ``ETIMEDOUT``.
     * - ``objs``
       - Pointer to an array of ``count`` file descriptors
         (specified as an integer so that the structure has the same
         size regardless of architecture). If any object is
         invalid, the function fails with ``EINVAL``.
     * - ``count``
       - Number of objects specified in the ``objs`` array.
         If greater than ``NTSYNC_MAX_WAIT_COUNT``, the function fails
         with ``EINVAL``.
     * - ``owner``
       - Mutex owner identifier. If any object in ``objs`` is a mutex,
         the ioctl will attempt to acquire that mutex on behalf of
         ``owner``. If ``owner`` is zero, the ioctl fails with
         ``EINVAL``.
     * - ``index``
       - On success, contains the index (into ``objs``) of the object
         which was signaled. If ``alert`` was signaled instead,
         this contains ``count``.
     * - ``alert``
       - Optional event object file descriptor. If nonzero, this
         specifies an "alert" event object which, if signaled, will
         terminate the wait. If nonzero, the identifier must point to a
         valid event.
     * - ``flags``
       - Zero or more flags. Currently the only flag is
         ``NTSYNC_WAIT_REALTIME``, which causes the timeout to be
         measured against the REALTIME clock instead of MONOTONIC.
     * - ``pad``
       - Unused, must be set to zero.

  This function attempts to acquire one of the given objects. If unable
  to do so, it sleeps until an object becomes signaled, subsequently
  acquiring it, or the timeout expires. In the latter case the ioctl
  fails with ``ETIMEDOUT``. The function only acquires one object, even
  if multiple objects are signaled.

  A semaphore is considered to be signaled if its count is nonzero, and
  is acquired by decrementing its count by one. A mutex is considered
  to be signaled if it is unowned or if its owner matches the ``owner``
  argument, and is acquired by incrementing its recursion count by one
  and setting its owner to the ``owner`` argument. An auto-reset event
  is acquired by designaling it; a manual-reset event is not affected
  by acquisition.

  Acquisition is atomic and totally ordered with respect to other
  operations on the same object. If two wait operations (with different
  ``owner`` identifiers) are queued on the same mutex, only one is
  signaled. If two wait operations are queued on the same semaphore,
  and a value of one is posted to it, only one is signaled.

  If an abandoned mutex is acquired, the ioctl fails with
  ``EOWNERDEAD``. Although this is a failure return, the function may
  otherwise be considered successful. The mutex is marked as owned by
  the given owner (with a recursion count of 1) and as no longer
  abandoned, and ``index`` is still set to the index of the mutex.

  The ``alert`` argument is an "extra" event which can terminate the
  wait, independently of all other objects.

  It is valid to pass the same object more than once, including by
  passing the same event in the ``objs`` array and in ``alert``. If a
  wakeup occurs due to that object being signaled, ``index`` is set to
  the lowest index corresponding to that object.

  The function may fail with ``EINTR`` if a signal is received.

.. c:macro:: NTSYNC_IOC_WAIT_ALL

  Poll on a list of objects, atomically acquiring all of them. Takes a
  pointer to struct :c:type:`ntsync_wait_args`, which is used
  identically to ``NTSYNC_IOC_WAIT_ANY``, except that ``index`` is
  always filled with zero on success if not woken via alert.

  This function attempts to simultaneously acquire all of the given
  objects. If unable to do so, it sleeps until all objects become
  simultaneously signaled, subsequently acquiring them, or the timeout
  expires. In the latter case the ioctl fails with ``ETIMEDOUT`` and no
  objects are modified.

  Objects may become signaled and subsequently designaled (through
  acquisition by other threads) while this thread is sleeping. Only
  once all objects are simultaneously signaled does the ioctl acquire
  them and return. The entire acquisition is atomic and totally ordered
  with respect to other operations on any of the given objects.

  If an abandoned mutex is acquired, the ioctl fails with
  ``EOWNERDEAD``. Similarly to ``NTSYNC_IOC_WAIT_ANY``, all objects are
  nevertheless marked as acquired. Note that if multiple mutex objects
  are specified, there is no way to know which were marked as
  abandoned.

  As with "any" waits, the ``alert`` argument is an "extra" event which
  can terminate the wait. Critically, however, an "all" wait will
  succeed if all members in ``objs`` are signaled, *or* if ``alert`` is
  signaled. In the latter case ``index`` will be set to ``count``. As
  with "any" waits, if both conditions are filled, the former takes
  priority, and objects in ``objs`` will be acquired.

  Unlike ``NTSYNC_IOC_WAIT_ANY``, it is not valid to pass the same
  object more than once, nor is it valid to pass the same object in
  ``objs`` and in ``alert``. If this is attempted, the function fails
  with ``EINVAL``.
