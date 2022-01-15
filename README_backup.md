# README of dehaze

This is the README of the final project (dclab08, 2021 fall)

## Clock frequency of each module

## Version 1 description
1. Ethernet input image or video
2. reach 5 fps
3. RGB24
4. Frank Algorithm

#### Camera
If you want to use camera
1. replace DE2_115.sv with DE2_115_camera.sv
2. In DCP.sv, use line 241 instead 242

#### sof file
1. DE2_115_camera.sof for camera input
2. DE2_115_ethernet_x_y.sof for ethernet input
> x for ethernet config, y for RGB type

## Add source files (to project)
> Our design
src/*.v
DE2-115/*.v

> Ethernet
verilog-ethernet/rtl/arp.v
verilog-ethernet/rtl/arp_cache.v
verilog-ethernet/rtl/arp_eth_rx.v
verilog-ethernet/rtl/arp_eth_tx.v
verilog-ethernet/rtl/axis_gmii_rx.v
verilog-ethernet/rtl/axis_gmii_tx.v

verilog-ethernet/rtl/eth_mac_1g_rgmii_fifo.v
verilog-ethernet/rtl/eth_mac_1g_rgmii.v
verilog-ethernet/rtl/eth_mac_1g.v
verilog-ethernet/rtl/eth_axis_rx.v
verilog-ethernet/rtl/eth_axis_tx.v
verilog-ethernet/rtl/eth_arb_mux.v
verilog-ethernet/rtl/eth_mux.v

verilog-ethernet/rtl/iddr.v
verilog-ethernet/rtl/ip.v
verilog-ethernet/rtl/ip_arb_mux.v
verilog-ethernet/rtl/ip_complete.v
verilog-ethernet/rtl/ip_eth_rx.v
verilog-ethernet/rtl/ip_eth_tx.v
verilog-ethernet/rtl/ip_mux.v

verilog-ethernet/rtl/lfsr.v

verilog-ethernet/rtl/oddr.v
verilog-ethernet/rtl/rgmii_phy_if.v
verilog-ethernet/rtl/ssio_ddr_in.v
verilog-ethernet/rtl/ssio_ddr_out.v
verilog-ethernet/rtl/udp_complete.v
verilog-ethernet/rtl/udp_checksum_gen.v
verilog-ethernet/rtl/udp.v
verilog-ethernet/rtl/udp_ip_rx.v
verilog-ethernet/rtl/udp_ip_tx.v

verilog-ethernet/lib/axis/rtl/arbiter.v
verilog-ethernet/lib/axis/rtl/axis_fifo.v
verilog-ethernet/lib/axis/rtl/axis_async_fifo.v
verilog-ethernet/lib/axis/rtl/axis_async_fifo_adapter.v
verilog-ethernet/lib/axis/rtl/priority_encoder.v
verilog-ethernet/lib/axis/rtl/sync_reset.v

# qsf file (import assignment)
fpga.qsf

# sdc file (add file to project)
fpga.sdc

