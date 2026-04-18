.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/admin-guide/perf/mrvl-odyssey-ddr-pmu.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

========================================================================
Thiết bị giám sát hiệu suất Marvell Odyssey DDR PMU (PMU UNCORE)
===================================================================

Hệ thống con Odyssey DRAM hỗ trợ tám bộ đếm để theo dõi hiệu suất
và phần mềm có thể lập trình các bộ đếm đó để theo dõi bất kỳ thông số nào được xác định
sự kiện biểu diễn. Các sự kiện biểu diễn được hỗ trợ bao gồm những sự kiện được tính
tại giao diện giữa bộ điều khiển DDR và PHY, giao diện giữa
Bộ điều khiển DDR và kết nối CHI hoặc trong Bộ điều khiển DDR.

Ngoài ra DSS còn hỗ trợ hai bộ đếm sự kiện hiệu suất cố định, một
cho ddr đọc và cái còn lại cho ghi ddr.

Bộ đếm sẽ hoạt động ở chế độ thủ công hoặc tự động.

Trình điều khiển PMU hiển thị các sự kiện và tùy chọn định dạng có sẵn trong sysfs::

/sys/bus/event_source/devices/mrvl_ddr_pmu_<>/events/
        /sys/bus/event_source/devices/mrvl_ddr_pmu_<>/format/

Ví dụ::

danh sách hoàn hảo $ | grep ddr
        mrvl_ddr_pmu_<>/ddr_act_bypass_access/ [Sự kiện hạt nhân PMU]
        mrvl_ddr_pmu_<>/ddr_bsm_alloc/ [Sự kiện hạt nhân PMU]
        mrvl_ddr_pmu_<>/ddr_bsm_starvation/ [Sự kiện hạt nhân PMU]
        mrvl_ddr_pmu_<>/ddr_cam_active_access/ [Sự kiện hạt nhân PMU]
        mrvl_ddr_pmu_<>/ddr_cam_mwr/ [Sự kiện hạt nhân PMU]
        mrvl_ddr_pmu_<>/ddr_cam_rd_active_access/ [Sự kiện hạt nhân PMU]
        mrvl_ddr_pmu_<>/ddr_cam_rd_or_wr_access/ [sự kiện Kernel PMU]
        mrvl_ddr_pmu_<>/ddr_cam_read/ [Sự kiện hạt nhân PMU]
        mrvl_ddr_pmu_<>/ddr_cam_wr_access/ [Sự kiện hạt nhân PMU]
        mrvl_ddr_pmu_<>/ddr_cam_write/ [Sự kiện hạt nhân PMU]
        mrvl_ddr_pmu_<>/ddr_capar_error/ [Sự kiện hạt nhân PMU]
        mrvl_ddr_pmu_<>/ddr_crit_ref/ [Sự kiện hạt nhân PMU]
        mrvl_ddr_pmu_<>/ddr_ddr_reads/ [Sự kiện hạt nhân PMU]
        mrvl_ddr_pmu_<>/ddr_ddr_writes/ [Sự kiện hạt nhân PMU]
        mrvl_ddr_pmu_<>/ddr_dfi_cmd_is_retry/ [Sự kiện hạt nhân PMU]
        mrvl_ddr_pmu_<>/ddr_dfi_cycles/ [Sự kiện hạt nhân PMU]
        mrvl_ddr_pmu_<>/ddr_dfi_parity_poison/ [Sự kiện hạt nhân PMU]
        mrvl_ddr_pmu_<>/ddr_dfi_rd_data_access/ [Sự kiện hạt nhân PMU]
        mrvl_ddr_pmu_<>/ddr_dfi_wr_data_access/ [Sự kiện hạt nhân PMU]
        mrvl_ddr_pmu_<>/ddr_dqsosc_mpc/ [Sự kiện hạt nhân PMU]
        mrvl_ddr_pmu_<>/ddr_dqsosc_mrr/ [Sự kiện hạt nhân PMU]
        mrvl_ddr_pmu_<>/ddr_enter_mpsm/ [Sự kiện hạt nhân PMU]
        mrvl_ddr_pmu_<>/ddr_enter_powerdown/ [Sự kiện hạt nhân PMU]
        mrvl_ddr_pmu_<>/ddr_enter_selfref/ [Sự kiện hạt nhân PMU]
        mrvl_ddr_pmu_<>/ddr_hif_pri_rdaccess/ [Sự kiện hạt nhân PMU]
        mrvl_ddr_pmu_<>/ddr_hif_rd_access/ [Sự kiện hạt nhân PMU]
        mrvl_ddr_pmu_<>/ddr_hif_rd_or_wr_access/ [Sự kiện hạt nhân PMU]
        mrvl_ddr_pmu_<>/ddr_hif_rmw_access/ [Sự kiện hạt nhân PMU]
        mrvl_ddr_pmu_<>/ddr_hif_wr_access/ [Sự kiện hạt nhân PMU]
        mrvl_ddr_pmu_<>/ddr_hpri_sched_rd_crit_access/ [Sự kiện hạt nhân PMU]
        mrvl_ddr_pmu_<>/ddr_load_mode/ [Sự kiện hạt nhân PMU]
        mrvl_ddr_pmu_<>/ddr_lpri_sched_rd_crit_access/ [Sự kiện hạt nhân PMU]
        mrvl_ddr_pmu_<>/ddr_precharge/ [Sự kiện hạt nhân PMU]
        mrvl_ddr_pmu_<>/ddr_precharge_for_other/ [Sự kiện hạt nhân PMU]
        mrvl_ddr_pmu_<>/ddr_precharge_for_rdwr/ [Sự kiện hạt nhân PMU]
        mrvl_ddr_pmu_<>/ddr_raw_hazard/ [Sự kiện hạt nhân PMU]
        mrvl_ddr_pmu_<>/ddr_rd_bypass_access/ [Sự kiện hạt nhân PMU]
        mrvl_ddr_pmu_<>/ddr_rd_crc_error/ [Sự kiện hạt nhân PMU]
        mrvl_ddr_pmu_<>/ddr_rd_uc_ecc_error/ [Sự kiện hạt nhân PMU]
        mrvl_ddr_pmu_<>/ddr_rdwr_transitions/ [Sự kiện hạt nhân PMU]
        mrvl_ddr_pmu_<>/ddr_refresh/ [Sự kiện hạt nhân PMU]
        mrvl_ddr_pmu_<>/ddr_retry_fifo_full/ [Sự kiện hạt nhân PMU]
        mrvl_ddr_pmu_<>/ddr_spec_ref/ [Sự kiện hạt nhân PMU]
        mrvl_ddr_pmu_<>/ddr_tcr_mrr/ [Sự kiện hạt nhân PMU]
        mrvl_ddr_pmu_<>/ddr_war_hazard/ [Sự kiện hạt nhân PMU]
        mrvl_ddr_pmu_<>/ddr_waw_hazard/ [Sự kiện hạt nhân PMU]
        mrvl_ddr_pmu_<>/ddr_win_limit_reached_rd/ [Sự kiện Kernel PMU]
        mrvl_ddr_pmu_<>/ddr_win_limit_reached_wr/ [Sự kiện Kernel PMU]
        mrvl_ddr_pmu_<>/ddr_wr_crc_error/ [Sự kiện hạt nhân PMU]
        mrvl_ddr_pmu_<>/ddr_wr_trxn_crit_access/ [Sự kiện hạt nhân PMU]
        mrvl_ddr_pmu_<>/ddr_write_combine/ [Sự kiện hạt nhân PMU]
        mrvl_ddr_pmu_<>/ddr_zqcl/ [Sự kiện hạt nhân PMU]
        mrvl_ddr_pmu_<>/ddr_zqlatch/ [Sự kiện hạt nhân PMU]
        mrvl_ddr_pmu_<>/ddr_zqstart/ [Sự kiện hạt nhân PMU]

$ chỉ số hoàn hảo -e ddr_cam_read,ddr_cam_write,ddr_cam_active_access,ddr_cam
          rd_or_wr_access,ddr_cam_rd_active_access,ddr_cam_mwr <khối lượng công việc>
