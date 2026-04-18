.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../../../disclaimer-vi.rst

:Original: Documentation/driver-api/cxl/linux/example-configurations/hb-interleave.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

===============================
Inter-Host-Bridge Interleave
============================
Kết xuất cấu hình cxl-cli này hiển thị cấu hình máy chủ sau:

* Một hệ thống ổ cắm duy nhất có một gốc CXL
* Root CXL có Bốn (4) Cầu nối máy chủ CXL
* Hai cầu nối máy chủ CXL có một Bộ mở rộng bộ nhớ CXL được đính kèm
* Root CXL được cấu hình để xen kẽ qua hai cầu nối máy chủ.

Đầu ra này được tạo bởi ZZ0000ZZ và mô tả các mối quan hệ
giữa các đối tượng được hiển thị trong ZZ0001ZZ.

::

[
    {
        "xe buýt:"root0",
        "nhà cung cấp:"ACPI.CXL",
        "nr_dports":4,
        "dport":[
            {
                "dport":pci0000:00",
                "bí danh":ACPI0016:01",
                "id":0
            },
            {
                "dport":pci0000:a8",
                "bí danh":ACPI0016:02",
                "id":4
            },
            {
                "dport":pci0000:2a",
                "bí danh":ACPI0016:03",
                "id":1
            },
            {
                "dport":pci0000:d2",
                "bí danh":ACPI0016:00",
                "id":5
            }
        ],

Đoạn này cho thấy "bus" CXL (root0) có 4 cổng xuôi dòng được gắn vào CXL
Cầu chủ.  ZZ0000ZZ có thể được coi là cổng ngược dòng duy nhất được gắn vào
tới bộ điều khiển bộ nhớ của nền tảng - định tuyến các yêu cầu bộ nhớ tới nó.

Phần ZZ0000ZZ trình bày cách hoạt động của từng cổng hạ lưu này.
được cấu hình.  Nếu một cổng không được cấu hình (id là 0 và 1), chúng sẽ bị bỏ qua.

::

"cổng:root0":[
            {
                "cổng:"cổng1",
                "máy chủ:"pci0000:d2",
                "độ sâu":1,
                "nr_dports":3,
                "dport":[
                    {
                        "dport://0000:d2:01.1",
                        "bí danh":thiết bị:02",
                        "id":0
                    },
                    {
                        "dport:"0000:d2:01.3",
                        "bí danh":thiết bị:05",
                        "id":2
                    },
                    {
                        "dport://0000:d2:07.1",
                        "bí danh":thiết bị:0d",
                        "id":113
                    }
                ],

Đoạn này hiển thị các cổng xuôi dòng có sẵn được liên kết với Máy chủ CXL
Cầu ZZ0000ZZ.  Trong trường hợp này, ZZ0001ZZ có sẵn 3 luồng hạ lưu
cổng: ZZ0002ZZ, ZZ0003ZZ và ZZ0004ZZ..

::

"điểm cuối:port1":[
                    {
                        "điểm cuối": "điểm cuối5",
                        "máy chủ:"mem0",
                        "parent_dport":0000:d2:01.1",
                        "độ sâu":2,
                        "memdev":{
                            "memdev:"mem0",
                            "kích thước ram":137438953472,
                            "nối tiếp":0,
                            "numa_node":0,
                            "máy chủ:":0000:d3:00.0"
                        },
                        "bộ giải mã:điểm cuối5":[
                            {
                                "bộ giải mã:"bộ giải mã5.0",
                                "tài nguyên":825975898112,
                                "kích thước":274877906944,
                                "interleave_ways":2,
                                "interleave_grainarity":256,
                                "khu vực:"khu vực0",
                                "dpa_resource":0,
                                "dpa_size":137438953472,
                                "chế độ:"ram"
                            }
                        ]
                    }
                ],

Đoạn này hiển thị các điểm cuối được gắn vào cầu chủ ZZ0000ZZ.

ZZ0000ZZ chứa một bộ giải mã được cấu hình duy nhất ZZ0001ZZ
có cấu hình xen kẽ tương tự như ZZ0002ZZ (hiển thị sau).

Tiếp theo chúng ta có bộ giải mã thuộc về cầu chủ:

::

"bộ giải mã:port1":[
                    {
                        "bộ giải mã:"bộ giải mã1.0",
                        "tài nguyên":825975898112,
                        "kích thước":274877906944,
                        "interleave_ways":1,
                        "khu vực:"khu vực0",
                        "nr_target":1,
                        "mục tiêu":[
                            {
                                "mục tiêu:"0000:d2:01.1",
                                "bí danh":thiết bị:02",
                                "vị trí":0,
                                "id":0
                            }
                        ]
                    }
                ]
            },

Cầu máy chủ ZZ0000ZZ có một bộ giải mã duy nhất (ZZ0001ZZ), chỉ có một bộ giải mã
mục tiêu là ZZ0002ZZ - được gắn vào ZZ0003ZZ.

Đoạn sau đây hiển thị cấu hình tương tự cho Host Bridge ZZ0000ZZ,
cầu máy chủ thứ hai có gắn thiết bị bộ nhớ.

::

{
                "cổng:"port3",
                "máy chủ:"pci0000:a8",
                "độ sâu":1,
                "nr_dports":1,
                "dport":[
                    {
                        "dport://0000:a8:01.1",
                        "bí danh":thiết bị:c3",
                        "id":0
                    }
                ],
                "điểm cuối:port3":[
                    {
                        "điểm cuối": "điểm cuối6",
                        "máy chủ:"mem1",
                        "parent_dport":0000:a8:01.1",
                        "độ sâu":2,
                        "memdev":{
                            "memdev:"mem1",
                            "kích thước ram":137438953472,
                            "nối tiếp":0,
                            "numa_node":0,
                            "máy chủ:"0000:a9:00.0"
                        },
                        "bộ giải mã:điểm cuối6":[
                            {
                                "bộ giải mã:"bộ giải mã6.0",
                                "tài nguyên":825975898112,
                                "kích thước":274877906944,
                                "interleave_ways":2,
                                "interleave_grainarity":256,
                                "khu vực:"khu vực0",
                                "dpa_resource":0,
                                "dpa_size":137438953472,
                                "chế độ:"ram"
                            }
                        ]
                    }
                ],
                "bộ giải mã:port3":[
                    {
                        "bộ giải mã">bộ giải mã3.0',
                        "tài nguyên":825975898112,
                        "kích thước":274877906944,
                        "interleave_ways":1,
                        "khu vực:"khu vực0",
                        "nr_target":1,
                        "mục tiêu":[
                            {
                                "mục tiêu:"0000:a8:01.1",
                                "bí danh":thiết bị:c3",
                                "vị trí":0,
                                "id":0
                            }
                        ]
                    }
                ]
            },


Đoạn tiếp theo hiển thị hai cầu nối máy chủ CXL không có điểm cuối kèm theo.

::

{
                "cổng:"port2",
                "máy chủ:"pci0000:00",
                "độ sâu":1,
                "nr_dports":2,
                "dport":[
                    {
                        "dport":0000:00:01.3",
                        "bí danh":thiết bị:55",
                        "id":2
                    },
                    {
                        "dport":0000:00:07.1",
                        "bí danh":thiết bị:5d",
                        "id":113
                    }
                ]
            },
            {
                "cổng:"port4",
                "máy chủ:"pci0000:2a",
                "độ sâu":1,
                "nr_dports":1,
                "dport":[
                    {
                        "dport://0000:2a:01.1",
                        "bí danh":thiết bị:d0",
                        "id":0
                    }
                ]
            }
        ],

Tiếp theo chúng ta có ZZ0003ZZ thuộc ZZ0000ZZ.  Bộ giải mã gốc này
áp dụng xen kẽ qua các cổng hạ lưu ZZ0001ZZ và
ZZ0002ZZ - với độ chi tiết 256 byte.

Thông tin này được tạo bởi trình điều khiển CXL đọc ACPI CEDT CMFWS.

::

"bộ giải mã:root0":[
            {
                "bộ giải mã">bộ giải mã0.0',
                "tài nguyên":825975898112,
                "kích thước":274877906944,
                "interleave_ways":2,
                "interleave_grainarity":256,
                "max_available_extent":0,
                "volatile_capable":đúng,
                "nr_target":2,
                "mục tiêu":[
                    {
                        "mục tiêu:"pci0000:a8",
                        "bí danh":ACPI0016:02",
                        "vị trí":1,
                        "id":4
                    },
                    {
                        "mục tiêu:"pci0000:d2",
                        "bí danh":ACPI0016:00",
                        "vị trí":0,
                        "id":5
                    }
                ],

Cuối cùng chúng ta có ZZ0001ZZ được liên kết với ZZ0002ZZ
ZZ0000ZZ.  Vùng này mô tả cấu hình xen kẽ tổng thể
của tập xen kẽ.

::

"vùng: bộ giải mã0.0":[
                    {
                        "khu vực:"khu vực0",
                        "tài nguyên":825975898112,
                        "kích thước":274877906944,
                        "loại:"ram",
                        "interleave_ways":2,
                        "interleave_grainarity":256,
                        "decode_state:"cam kết",
                        "ánh xạ":[
                            {
                                "vị trí":1,
                                "memdev:"mem1",
                                "bộ giải mã:"bộ giải mã6.0"
                            },
                            {
                                "vị trí":0,
                                "memdev:"mem0",
                                "bộ giải mã:"bộ giải mã5.0"
                            }
                        ]
                    }
                ]
            }
        ]
    }
  ]