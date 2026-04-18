.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/gpu/amdgpu/display/dc-glossary.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

============
Thuật ngữ DC
============

Trên trang này, chúng tôi cố gắng theo dõi các từ viết tắt liên quan đến màn hình
thành phần. Nếu bạn không tìm thấy những gì bạn đang tìm kiếm, hãy nhìn vào
'Tài liệu/gpu/amdgpu/amdgpu-glossary.rst'; nếu bạn không thể tìm thấy nó ở bất cứ đâu,
hãy cân nhắc việc hỏi danh sách gửi thư amd-gfx và cập nhật trang này.

.. glossary::

    ABM
      Adaptive Backlight Modulation

    APU
      Accelerated Processing Unit

    ASIC
      Application-Specific Integrated Circuit

    ASSR
      Alternate Scrambler Seed Reset

    AZ
      Azalia (HD audio DMA engine)

    BPC
      Bits Per Colour/Component

    BPP
      Bits Per Pixel

    Clocks
      * PCLK: Pixel Clock
      * SYMCLK: Symbol Clock
      * SOCCLK: GPU Engine Clock
      * DISPCLK: Display Clock
      * DPPCLK: DPP Clock
      * DCFCLK: Display Controller Fabric Clock
      * REFCLK: Real Time Reference Clock
      * PPLL: Pixel PLL
      * FCLK: Fabric Clock
      * MCLK: Memory Clock

    CRC
      Cyclic Redundancy Check

    CRTC
      Cathode Ray Tube Controller - commonly called "Controller" - Generates
      raw stream of pixels, clocked at pixel clock

    CVT
      Coordinated Video Timings

    DAL
      Display Abstraction layer

    DC (Software)
      Display Core

    DC (Hardware)
      Display Controller

    DCC
      Delta Colour Compression

    DCE
      Display Controller Engine

    DCHUB
      Display Controller HUB

    ARB
      Arbiter

    VTG
      Vertical Timing Generator

    DCN
      Display Core Next

    DCCG
      Display Clock Generator block

    DDC
      Display Data Channel

    DIO
      Display IO

    DPP
      Display Pipes and Planes

    DSC
      Display Stream Compression (Reduce the amount of bits to represent pixel
      count while at the same pixel clock)

    dGPU
      discrete GPU

    DMIF
      Display Memory Interface

    DML
      Display Mode Library

    DMCU
      Display Micro-Controller Unit

    DMCUB
      Display Micro-Controller Unit, version B

    DPCD
      DisplayPort Configuration Data

    DPM(S)
      Display Power Management (Signaling)

    DRR
      Dynamic Refresh Rate

    DWB
      Display Writeback

    FB
      Frame Buffer

    FBC
      Frame Buffer Compression

    FEC
      Forward Error Correction

    FRL
      Fixed Rate Link

    GCO
      Graphical Controller Object

    GSL
      Global Swap Lock

    iGPU
      integrated GPU

    ISR
      Interrupt Service Request

    ISV
      Independent Software Vendor

    KMD
      Kernel Mode Driver

    LB
      Line Buffer

    LFC
      Low Framerate Compensation

    LTTPR
      Link Training Tunable Phy Repeater

    LUT
      Lookup Table

    MALL
      Memory Access at Last Level

    MPC/MPCC
      Multiple pipes and plane combine

    MPO
      Multi Plane Overlay

    MST
      Multi Stream Transport

    NBP State
      Northbridge Power State

    NBIO
      North Bridge Input/Output

    ODM
      Output Data Mapping

    OPM
      Output Protection Manager

    OPP
      Output Plane Processor

    OPTC
      Output Pipe Timing Combiner

    OTG
      Output Timing Generator

    PCON
      Power Controller

    PGFSM
      Power Gate Finite State Machine

    PSR
      Panel Self Refresh

    SCL
      Scaler

    SDP
      Scalable Data Port

    SLS
      Single Large Surface

    SST
      Single Stream Transport

    TMDS
      Transition-Minimized Differential Signaling

    TTU
      Time to Underflow

    VRR
      Variable Refresh Rate
