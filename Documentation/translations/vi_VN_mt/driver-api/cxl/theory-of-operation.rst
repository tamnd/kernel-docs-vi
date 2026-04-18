.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/driver-api/cxl/theory-of-operation.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. include:: <isonum.txt>

=====================================================
Lý thuyết hoạt động của trình điều khiển Express Link
=====================================================

Thiết bị bộ nhớ liên kết điện toán nhanh là thành phần CXL thực hiện
Giao thức CXL.mem. Nó chứa một lượng bộ nhớ khả biến, bộ nhớ liên tục,
hoặc cả hai. Nó được liệt kê là thiết bị PCI để cấu hình và truyền
tin nhắn qua hộp thư MMIO. Đóng góp của nó cho Hệ thống Vật lý
Không gian địa chỉ được xử lý thông qua bộ giải mã HDM (Bộ nhớ thiết bị được quản lý bởi máy chủ)
tùy chọn xác định sự đóng góp của thiết bị cho một địa chỉ xen kẽ
phạm vi trên nhiều thiết bị bên dưới cầu nối máy chủ hoặc xen kẽ
qua các cầu nối máy chủ.

Xe buýt CXL
===========
Tương tự như cách trình điều khiển RAID lấy các đối tượng đĩa và tập hợp chúng thành một ổ đĩa mới
thiết bị logic, hệ thống con CXL có nhiệm vụ lấy các đối tượng PCIe và ACPI và
tập hợp chúng thành cấu trúc liên kết giải mã CXL.mem. Sự cần thiết của cấu hình thời gian chạy
của cấu trúc liên kết CXL.mem cũng tương tự như RAID trong các môi trường khác nhau
với cùng cấu hình phần cứng có thể quyết định tập hợp cấu trúc liên kết trong
những cách tương phản. Người ta có thể chọn phân chia bộ nhớ hiệu suất (RAID0)
nhiều Cầu nối máy chủ và điểm cuối trong khi một cầu nối khác có thể chọn khả năng chịu lỗi
và vô hiệu hóa mọi phân loại trong cấu trúc liên kết CXL.mem.

Phần sụn nền tảng liệt kê một menu các tùy chọn xen kẽ tại "cổng gốc CXL"
(Thuật ngữ Linux chỉ phần trên cùng của cấu trúc liên kết giải mã CXL). Từ đó, cấu trúc liên kết PCIe
chỉ ra điểm cuối nào có thể tham gia vào chế độ giải mã Host Bridge nào.
Mỗi PCIe Switch trong đường dẫn giữa điểm gốc và điểm cuối sẽ giới thiệu một điểm
tại đó phần xen kẽ có thể được phân chia. Ví dụ: phần sụn nền tảng có thể nói một
phạm vi đã cho chỉ giải mã thành một Cầu chủ, nhưng đến lượt Cầu chủ đó có thể
các chu kỳ xen kẽ trên nhiều Cổng gốc. Một sự chuyển đổi can thiệp giữa một
cổng và điểm cuối có thể xen kẽ các chu kỳ trên nhiều Công tắc hạ lưu
Cổng, v.v.

Dưới đây là danh sách mẫu của cấu trúc liên kết CXL được xác định bởi 'cxl_test'. 'cxl_test'
mô-đun tạo ra cấu trúc liên kết CXL mô phỏng gồm 2 Cầu nối máy chủ, mỗi cầu có 2 gốc
Cổng. Mỗi Cổng gốc đó được kết nối với các bộ chuyển mạch 2 chiều với các điểm cuối
được kết nối với các cổng hạ lưu đó với tổng số 8 điểm cuối::

Danh sách # cxl -BEMPu -b cxl_test
    {
      "xe buýt:"root3",
      "nhà cung cấp:"cxl_test",
      "cổng:root3":[
        {
          "cổng:"port5",
          "máy chủ:"cxl_host_bridge.1",
          "cổng:port5":[
            {
              "cổng:"cổng8",
              "máy chủ":"cxl_switch_uport.1",
              "điểm cuối:port8":[
                {
                  "điểm cuối": "điểm cuối9",
                  "máy chủ:"mem2",
                  "memdev":{
                    "memdev:"mem2",
                    "pmem_size:"256,00 MiB (268,44 MB)",
                    "ram_size":256,00 MiB (268,44 MB)",
                    "nối tiếp:"0x1",
                    "numa_node":1,
                    "máy chủ:"cxl_mem.1"
                  }
                },
                {
                  "điểm cuối": "điểm cuối15",
                  "máy chủ:"mem6",
                  "memdev":{
                    "memdev:"mem6",
                    "pmem_size:"256,00 MiB (268,44 MB)",
                    "ram_size":256,00 MiB (268,44 MB)",
                    "nối tiếp:"0x5",
                    "numa_node":1,
                    "máy chủ:"cxl_mem.5"
                  }
                }
              ]
            },
            {
              "cổng:"cổng12",
              "máy chủ:"cxl_switch_uport.3",
              "điểm cuối:port12":[
                {
                  "điểm cuối": "điểm cuối17",
                  "máy chủ:"mem8",
                  "memdev":{
                    "memdev:"mem8",
                    "pmem_size:"256,00 MiB (268,44 MB)",
                    "ram_size":256,00 MiB (268,44 MB)",
                    "nối tiếp:"0x7",
                    "numa_node":1,
                    "máy chủ:"cxl_mem.7"
                  }
                },
                {
                  "điểm cuối": "điểm cuối13",
                  "máy chủ:"mem4",
                  "memdev":{
                    "memdev:"mem4",
                    "pmem_size:"256,00 MiB (268,44 MB)",
                    "ram_size":256,00 MiB (268,44 MB)",
                    "nối tiếp:"0x3",
                    "numa_node":1,
                    "máy chủ:"cxl_mem.3"
                  }
                }
              ]
            }
          ]
        },
        {
          "cổng:"port4",
          "máy chủ:"cxl_host_bridge.0",
          "cổng:port4":[
            {
              "cổng:"cổng6",
              "máy chủ":"cxl_switch_uport.0",
              "điểm cuối:port6":[
                {
                  "điểm cuối": "điểm cuối7",
                  "máy chủ:"mem1",
                  "memdev":{
                    "memdev:"mem1",
                    "pmem_size:"256,00 MiB (268,44 MB)",
                    "ram_size":256,00 MiB (268,44 MB)",
                    "nối tiếp:"0",
                    "numa_node":0,
                    "máy chủ:"cxl_mem.0"
                  }
                },
                {
                  "điểm cuối": "điểm cuối14",
                  "máy chủ:"mem5",
                  "memdev":{
                    "memdev:"mem5",
                    "pmem_size:"256,00 MiB (268,44 MB)",
                    "ram_size":256,00 MiB (268,44 MB)",
                    "nối tiếp:"0x4",
                    "numa_node":0,
                    "máy chủ:"cxl_mem.4"
                  }
                }
              ]
            },
            {
              "cổng:"cổng10",
              "máy chủ":"cxl_switch_uport.2",
              "điểm cuối:port10":[
                {
                  "điểm cuối": "điểm cuối16",
                  "máy chủ:"mem7",
                  "memdev":{
                    "memdev:"mem7",
                    "pmem_size:"256,00 MiB (268,44 MB)",
                    "ram_size":256,00 MiB (268,44 MB)",
                    "nối tiếp:"0x6",
                    "numa_node":0,
                    "máy chủ:"cxl_mem.6"
                  }
                },
                {
                  "điểm cuối": "điểm cuối11",
                  "máy chủ:"mem3",
                  "memdev":{
                    "memdev:"mem3",
                    "pmem_size:"256,00 MiB (268,44 MB)",
                    "ram_size":256,00 MiB (268,44 MB)",
                    "nối tiếp:"0x2",
                    "numa_node":0,
                    "máy chủ:"cxl_mem.2"
                  }
                }
              ]
            }
          ]
        }
      ]
    }

Trong danh sách đó, mỗi đối tượng "root", "port" và "endpoint" tương ứng với một kernel
đối tượng 'struct cxl_port'. 'cxl_port' là một thiết bị có thể giải mã CXL.mem thành
con cháu của nó. Vì vậy, "root" xác nhận phạm vi giải mã nền tảng không đếm được PCIe và
giải mã chúng thành "cổng", "cổng" giải mã thành "điểm cuối" và "điểm cuối"
biểu thị giải mã từ SPA (Địa chỉ vật lý hệ thống) đến DPA (Địa chỉ vật lý thiết bị
Địa chỉ).

Tiếp tục tương tự RAID, các đĩa có cả siêu dữ liệu cấu trúc liên kết và trên thiết bị
siêu dữ liệu xác định tập hợp RAID. Cấu trúc liên kết cổng CXL và liên kết cổng CXL
trạng thái là siêu dữ liệu cho tập hợp CXL.mem. Cấu trúc liên kết cổng CXL được liệt kê
bởi sự xuất hiện của thiết bị CXL.mem. tức là trừ khi và cho đến khi lõi PCIe gắn vào
trình điều khiển cxl_pci cho Bộ mở rộng bộ nhớ CXL không có vai trò gì cho Cổng CXL
đồ vật. Ngược lại, đối với các tình huống rút phích cắm/tháo nóng, không cần
lõi Linux PCI để phá bỏ các tài nguyên CXL cấp chuyển đổi vì điểm cuối
->remove() sự kiện sẽ dọn sạch dữ liệu cổng được thiết lập để hỗ trợ điều đó
Bộ mở rộng bộ nhớ.

Siêu dữ liệu cổng và các sơ đồ giải mã tiềm năng mà một thiết bị bộ nhớ nhất định có thể
việc tham gia có thể được xác định thông qua một lệnh như::

Danh sách # cxl -BDMu -d root -m mem3
    {
      "xe buýt:"root3",
      "nhà cung cấp:"cxl_test",
      "bộ giải mã:root3":[
        {
          "bộ giải mã:"bộ giải mã3.1",
          "tài nguyên:"0x8030000000",
          "size":"512,00 MiB (536,87 MB)",
          "volatile_capable":đúng,
          "nr_target":2
        },
        {
          "bộ giải mã:"bộ giải mã3.3",
          "tài nguyên:"0x8060000000",
          "size":"512,00 MiB (536,87 MB)",
          "pmem_capable":đúng,
          "nr_target":2
        },
        {
          "bộ giải mã">bộ giải mã3.0',
          "tài nguyên:"0x8020000000",
          "size":256,00 MiB (268,44 MB)",
          "volatile_capable":đúng,
          "nr_target":1
        },
        {
          "bộ giải mã:"bộ giải mã3.2",
          "tài nguyên:"0x8050000000",
          "size":256,00 MiB (268,44 MB)",
          "pmem_capable":đúng,
          "nr_target":1
        }
      ],
      "memdevs:root3":[
        {
          "memdev:"mem3",
          "pmem_size:"256,00 MiB (268,44 MB)",
          "ram_size":256,00 MiB (268,44 MB)",
          "nối tiếp:"0x2",
          "numa_node":0,
          "máy chủ:"cxl_mem.2"
        }
      ]
    }

...which queries the CXL topology to ask "given CXL Memory Expander with a kernel
tên thiết bị của 'mem3', thiết bị này có thể giải mã cấp nền tảng nào
tham gia". Một thiết bị mở rộng nhất định có thể tham gia vào nhiều xen kẽ CXL.mem
thiết lập đồng thời tùy thuộc vào số lượng tài nguyên bộ giải mã mà nó có. Trong này
ví dụ mem3 có thể tham gia vào một hoặc nhiều xen kẽ PMEM kéo dài hai
Cầu nối máy chủ, một xen kẽ PMEM nhắm vào một Cầu nối máy chủ duy nhất, một Cầu nối dễ bay hơi
xen kẽ bộ nhớ trải dài trên 2 cầu nối máy chủ và xen kẽ bộ nhớ khả biến
chỉ nhắm mục tiêu vào một Host Bridge duy nhất.

Ngược lại, các thiết bị bộ nhớ có thể tham gia vào một cấp độ nền tảng nhất định
sơ đồ giải mã có thể được xác định thông qua một lệnh như sau ::

Danh sách # cxl -MDu -d 3.2
    [
      {
        "memdev":[
          {
            "memdev:"mem1",
            "pmem_size:"256,00 MiB (268,44 MB)",
            "ram_size":256,00 MiB (268,44 MB)",
            "nối tiếp:"0",
            "numa_node":0,
            "máy chủ:"cxl_mem.0"
          },
          {
            "memdev:"mem5",
            "pmem_size:"256,00 MiB (268,44 MB)",
            "ram_size":256,00 MiB (268,44 MB)",
            "nối tiếp:"0x4",
            "numa_node":0,
            "máy chủ:"cxl_mem.4"
          },
          {
            "memdev:"mem7",
            "pmem_size:"256,00 MiB (268,44 MB)",
            "ram_size":256,00 MiB (268,44 MB)",
            "nối tiếp:"0x6",
            "numa_node":0,
            "máy chủ:"cxl_mem.6"
          },
          {
            "memdev:"mem3",
            "pmem_size:"256,00 MiB (268,44 MB)",
            "ram_size":256,00 MiB (268,44 MB)",
            "nối tiếp:"0x2",
            "numa_node":0,
            "máy chủ:"cxl_mem.2"
          }
        ]
      },
      {
        "bộ giải mã gốc":[
          {
            "bộ giải mã:"bộ giải mã3.2",
            "tài nguyên:"0x8050000000",
            "size":256,00 MiB (268,44 MB)",
            "pmem_capable":đúng,
            "nr_target":1
          }
        ]
      }
    ]

...where the naming scheme for decoders is "decoder<port_id>.<instance_id>".

Cơ sở hạ tầng trình điều khiển
=====================

Phần này bao gồm cơ sở hạ tầng trình điều khiển cho thiết bị bộ nhớ CXL.

Thiết bị bộ nhớ CXL
-----------------

.. kernel-doc:: drivers/cxl/pci.c
   :doc: cxl pci

.. kernel-doc:: drivers/cxl/pci.c
   :internal:

.. kernel-doc:: drivers/cxl/mem.c
   :doc: cxl mem

.. kernel-doc:: drivers/cxl/cxlmem.h
   :internal:

.. kernel-doc:: drivers/cxl/core/memdev.c
   :identifiers:

Cổng CXL
--------
.. kernel-doc:: drivers/cxl/port.c
   :doc: cxl port

Lõi CXL
--------
.. kernel-doc:: drivers/cxl/cxl.h
   :doc: cxl objects

.. kernel-doc:: drivers/cxl/cxl.h
   :internal:

.. kernel-doc:: drivers/cxl/acpi.c
   :identifiers: add_cxl_resources

.. kernel-doc:: drivers/cxl/core/hdm.c
   :doc: cxl core hdm

.. kernel-doc:: drivers/cxl/core/hdm.c
   :identifiers:

.. kernel-doc:: drivers/cxl/core/cdat.c
   :identifiers:

.. kernel-doc:: drivers/cxl/core/port.c
   :doc: cxl core

.. kernel-doc:: drivers/cxl/core/port.c
   :identifiers:

.. kernel-doc:: drivers/cxl/core/pci.c
   :doc: cxl core pci

.. kernel-doc:: drivers/cxl/core/pci.c
   :identifiers:

.. kernel-doc:: drivers/cxl/core/pmem.c
   :doc: cxl pmem

.. kernel-doc:: drivers/cxl/core/pmem.c
   :identifiers:

.. kernel-doc:: drivers/cxl/core/regs.c
   :doc: cxl registers

.. kernel-doc:: drivers/cxl/core/regs.c
   :identifiers:

.. kernel-doc:: drivers/cxl/core/mbox.c
   :doc: cxl mbox

.. kernel-doc:: drivers/cxl/core/mbox.c
   :identifiers:

.. kernel-doc:: drivers/cxl/core/features.c
   :doc: cxl features

Xem ZZ0000ZZ để biết chi tiết về API.

Vùng CXL
-----------
.. kernel-doc:: drivers/cxl/core/region.c
   :doc: cxl core region

.. kernel-doc:: drivers/cxl/core/region.c
   :identifiers:

Giao diện bên ngoài
===================

Giao diện CXL IOCTL
-------------------

.. kernel-doc:: include/uapi/linux/cxl_mem.h
   :doc: UAPI

.. kernel-doc:: include/uapi/linux/cxl_mem.h
   :internal: