.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/driver-api/infiniband.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

===============================================
Giao diện InfiniBand và Remote DMA (RDMA)
===============================================

Giới thiệu và Tổng quan
=========================

TBD

Giao diện cốt lõi của InfiniBand
==========================

.. kernel-doc:: drivers/infiniband/core/iwpm_util.h
    :internal:

.. kernel-doc:: drivers/infiniband/core/cq.c
    :export:

.. kernel-doc:: drivers/infiniband/core/cm.c
    :export:

.. kernel-doc:: drivers/infiniband/core/rw.c
    :export:

.. kernel-doc:: drivers/infiniband/core/device.c
    :export:

.. kernel-doc:: drivers/infiniband/core/verbs.c
    :export:

.. kernel-doc:: drivers/infiniband/core/packer.c
    :export:

.. kernel-doc:: drivers/infiniband/core/sa_query.c
    :export:

.. kernel-doc:: drivers/infiniband/core/ud_header.c
    :export:

.. kernel-doc:: drivers/infiniband/core/umem.c
    :export:

.. kernel-doc:: drivers/infiniband/core/umem_odp.c
    :export:

Thư viện vận chuyển động từ RDMA
============================

.. kernel-doc:: drivers/infiniband/sw/rdmavt/mr.c
    :export:

.. kernel-doc:: drivers/infiniband/sw/rdmavt/rc.c
    :export:

.. kernel-doc:: drivers/infiniband/sw/rdmavt/ah.c
    :export:

.. kernel-doc:: drivers/infiniband/sw/rdmavt/vt.c
    :export:

.. kernel-doc:: drivers/infiniband/sw/rdmavt/cq.c
    :export:

.. kernel-doc:: drivers/infiniband/sw/rdmavt/qp.c
    :export:

.. kernel-doc:: drivers/infiniband/sw/rdmavt/mcast.c
    :export:

Giao thức lớp trên
=====================

Phần mở rộng iSCSI cho RDMA (iSER)
--------------------------------

.. kernel-doc:: drivers/infiniband/ulp/iser/iscsi_iser.h
   :internal:

.. kernel-doc:: drivers/infiniband/ulp/iser/iscsi_iser.c
   :functions: iscsi_iser_pdu_alloc iser_initialize_task_headers
               iscsi_iser_task_init iscsi_iser_mtask_xmit iscsi_iser_task_xmit
               iscsi_iser_cleanup_task iscsi_iser_check_protection
               iscsi_iser_conn_create iscsi_iser_conn_bind
               iscsi_iser_conn_start iscsi_iser_conn_stop
               iscsi_iser_session_destroy iscsi_iser_session_create
               iscsi_iser_set_param iscsi_iser_ep_connect iscsi_iser_ep_poll
               iscsi_iser_ep_disconnect

.. kernel-doc:: drivers/infiniband/ulp/iser/iser_initiator.c
   :internal:

.. kernel-doc:: drivers/infiniband/ulp/iser/iser_verbs.c
   :internal:

Hỗ trợ Omni-Path (OPA) Virtual NIC
-----------------------------------

.. kernel-doc:: drivers/infiniband/ulp/opa_vnic/opa_vnic_internal.h
   :internal:

.. kernel-doc:: drivers/infiniband/ulp/opa_vnic/opa_vnic_encap.h
   :internal:

.. kernel-doc:: drivers/infiniband/ulp/opa_vnic/opa_vnic_vema_iface.c
   :internal:

.. kernel-doc:: drivers/infiniband/ulp/opa_vnic/opa_vnic_vema.c
   :internal:

Hỗ trợ mục tiêu giao thức InfiniBand SCSI RDMA
--------------------------------------------

.. kernel-doc:: drivers/infiniband/ulp/srpt/ib_srpt.h
   :internal:

.. kernel-doc:: drivers/infiniband/ulp/srpt/ib_srpt.c
   :internal:

Tiện ích mở rộng iSCSI để hỗ trợ mục tiêu RDMA (iSER)
-----------------------------------------------

.. kernel-doc:: drivers/infiniband/ulp/isert/ib_isert.c
   :internal:

