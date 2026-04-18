.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/gpu/imagination/uapi.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

====
UAPI
====
Các nguồn liên quan đến phần này có thể được tìm thấy trong ZZ0000ZZ.

.. kernel-doc:: include/uapi/drm/pvr_drm.h
   :doc: PowerVR UAPI

OBJECT ARRAYS
=============
.. kernel-doc:: include/uapi/drm/pvr_drm.h
   :identifiers: drm_pvr_obj_array

.. kernel-doc:: include/uapi/drm/pvr_drm.h
   :identifiers: DRM_PVR_OBJ_ARRAY

IOCTLS
======
.. kernel-doc:: include/uapi/drm/pvr_drm.h
   :doc: PowerVR IOCTL interface

.. kernel-doc:: include/uapi/drm/pvr_drm.h
   :identifiers: PVR_IOCTL

DEV_QUERY
---------
.. kernel-doc:: include/uapi/drm/pvr_drm.h
   :doc: PowerVR IOCTL DEV_QUERY interface

.. kernel-doc:: include/uapi/drm/pvr_drm.h
   :identifiers: drm_pvr_dev_query

.. kernel-doc:: include/uapi/drm/pvr_drm.h
   :identifiers: drm_pvr_ioctl_dev_query_args

.. kernel-doc:: include/uapi/drm/pvr_drm.h
   :identifiers: drm_pvr_dev_query_gpu_info
                 drm_pvr_dev_query_runtime_info
                 drm_pvr_dev_query_hwrt_info
                 drm_pvr_dev_query_quirks
                 drm_pvr_dev_query_enhancements

.. kernel-doc:: include/uapi/drm/pvr_drm.h
   :identifiers: drm_pvr_heap_id
                 drm_pvr_heap
                 drm_pvr_dev_query_heap_info

.. kernel-doc:: include/uapi/drm/pvr_drm.h
   :identifiers: drm_pvr_static_data_area_usage
                 drm_pvr_static_data_area
                 drm_pvr_dev_query_static_data_areas

CREATE_BO
---------
.. kernel-doc:: include/uapi/drm/pvr_drm.h
   :doc: PowerVR IOCTL CREATE_BO interface

.. kernel-doc:: include/uapi/drm/pvr_drm.h
   :identifiers: drm_pvr_ioctl_create_bo_args

.. kernel-doc:: include/uapi/drm/pvr_drm.h
   :doc: Flags for CREATE_BO

GET_BO_MMAP_OFFSET
------------------
.. kernel-doc:: include/uapi/drm/pvr_drm.h
   :doc: PowerVR IOCTL GET_BO_MMAP_OFFSET interface

.. kernel-doc:: include/uapi/drm/pvr_drm.h
   :identifiers: drm_pvr_ioctl_get_bo_mmap_offset_args

CREATE_VM_CONTEXT và DESTROY_VM_CONTEXT
----------------------------------------
.. kernel-doc:: include/uapi/drm/pvr_drm.h
   :doc: PowerVR IOCTL CREATE_VM_CONTEXT and DESTROY_VM_CONTEXT interfaces

.. kernel-doc:: include/uapi/drm/pvr_drm.h
   :identifiers: drm_pvr_ioctl_create_vm_context_args
                 drm_pvr_ioctl_destroy_vm_context_args

VM_MAP và VM_UNMAP
-------------------
.. kernel-doc:: include/uapi/drm/pvr_drm.h
   :doc: PowerVR IOCTL VM_MAP and VM_UNMAP interfaces

.. kernel-doc:: include/uapi/drm/pvr_drm.h
   :identifiers: drm_pvr_ioctl_vm_map_args
                 drm_pvr_ioctl_vm_unmap_args

CREATE_CONTEXT và DESTROY_CONTEXT
----------------------------------
.. kernel-doc:: include/uapi/drm/pvr_drm.h
   :doc: PowerVR IOCTL CREATE_CONTEXT and DESTROY_CONTEXT interfaces

.. kernel-doc:: include/uapi/drm/pvr_drm.h
   :identifiers: drm_pvr_ioctl_create_context_args

.. kernel-doc:: include/uapi/drm/pvr_drm.h
   :identifiers: drm_pvr_ctx_priority
                 drm_pvr_ctx_type
                 drm_pvr_static_render_context_state
                 drm_pvr_static_render_context_state_format
                 drm_pvr_reset_framework
                 drm_pvr_reset_framework_format

.. kernel-doc:: include/uapi/drm/pvr_drm.h
   :identifiers: drm_pvr_ioctl_destroy_context_args

CREATE_FREE_LIST và DESTROY_FREE_LIST
--------------------------------------
.. kernel-doc:: include/uapi/drm/pvr_drm.h
   :doc: PowerVR IOCTL CREATE_FREE_LIST and DESTROY_FREE_LIST interfaces

.. kernel-doc:: include/uapi/drm/pvr_drm.h
   :identifiers: drm_pvr_ioctl_create_free_list_args

.. kernel-doc:: include/uapi/drm/pvr_drm.h
   :identifiers: drm_pvr_ioctl_destroy_free_list_args

CREATE_HWRT_DATASET và DESTROY_HWRT_DATASET
--------------------------------------------
.. kernel-doc:: include/uapi/drm/pvr_drm.h
   :doc: PowerVR IOCTL CREATE_HWRT_DATASET and DESTROY_HWRT_DATASET interfaces

.. kernel-doc:: include/uapi/drm/pvr_drm.h
   :identifiers: drm_pvr_ioctl_create_hwrt_dataset_args

.. kernel-doc:: include/uapi/drm/pvr_drm.h
   :identifiers: drm_pvr_create_hwrt_geom_data_args
                 drm_pvr_create_hwrt_rt_data_args

.. kernel-doc:: include/uapi/drm/pvr_drm.h
   :identifiers: drm_pvr_ioctl_destroy_hwrt_dataset_args

SUBMIT_JOBS
-----------
.. kernel-doc:: include/uapi/drm/pvr_drm.h
   :doc: PowerVR IOCTL SUBMIT_JOBS interface

.. kernel-doc:: include/uapi/drm/pvr_drm.h
   :doc: Flags for the drm_pvr_sync_op object.

.. kernel-doc:: include/uapi/drm/pvr_drm.h
   :identifiers: drm_pvr_ioctl_submit_jobs_args

.. kernel-doc:: include/uapi/drm/pvr_drm.h
   :doc: Flags for SUBMIT_JOB ioctl geometry command.

.. kernel-doc:: include/uapi/drm/pvr_drm.h
   :doc: Flags for SUBMIT_JOB ioctl fragment command.

.. kernel-doc:: include/uapi/drm/pvr_drm.h
   :doc: Flags for SUBMIT_JOB ioctl compute command.

.. kernel-doc:: include/uapi/drm/pvr_drm.h
   :doc: Flags for SUBMIT_JOB ioctl transfer command.

.. kernel-doc:: include/uapi/drm/pvr_drm.h
   :identifiers: drm_pvr_sync_op
                 drm_pvr_job_type
                 drm_pvr_hwrt_data_ref
                 drm_pvr_job

Ghi chú nội bộ
==============
.. kernel-doc:: drivers/gpu/drm/imagination/pvr_device.h
   :doc: IOCTL validation helpers

.. kernel-doc:: drivers/gpu/drm/imagination/pvr_device.h
   :identifiers: PVR_STATIC_ASSERT_64BIT_ALIGNED PVR_IOCTL_UNION_PADDING_CHECK
                 pvr_ioctl_union_padding_check
