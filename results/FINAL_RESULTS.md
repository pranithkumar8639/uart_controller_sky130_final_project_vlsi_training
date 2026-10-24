# UART timing: synthesis-stage results (corrected routed results at the bottom)

## Final design
- RTL: `rtl/uart_tx_C_experiment.v` + `rtl/uart_rx_split_experiment.v` + `rtl/uart_top.v`
- Synthesis: `synthesis_optimized/run_synthesis_C_D7000.tcl` (SS liberty, ABC `-D 7000`)
- Netlist: `synthesis_optimized/uart_C_D7000_mapped.v`
- Constraints: `constraints/uart.sdc` (10 ns clock, 0.2 ns uncertainty)

## Timing (OpenSTA, ideal clock, pre-layout; superseded by the results_D section below)
| Corner | Setup slack | Hold slack |
|---|---|---|
| SS (-40C, 1.28V) | +0.70 ns (0 violated paths) | +2.05 ns |
| TT (25C, 1.80V) | +8.48 ns | +0.19 ns |
| FF (-40C, 1.65V) | +8.71 ns | +0.12 ns |

## Progress (worst SS setup slack)
| Step | Slack |
|---|---|
| TT-mapped baseline | -3.99 ns |
| SS-library mapping | -2.94 ns |
| TX registered flags + shift register | -1.68 ns |
| RX LFSR baud counter | -1.14 ns |
| RX split compare | -0.75 ns |
| TX LFSR baud counter | -0.51 ns |
| TX registered shift enable | -0.22 ns |
| ABC target -D 7000 (synthesis setting, no RTL change) | +0.70 ns |

## Verification
- RTL: TX and RX each cycle-equivalent to the original over random stimulus (N=16, 17, 5208; 600,000 cycles at 5208).
- RTL `uart_tb`: both tests pass.
- Gate level: `uart_tb` passes on the mapped netlist, compiled with `-DFUNCTIONAL -DUNIT_DELAY='#0'`.

## Limitations
- Gate-level test uses only the two `uart_tb` bytes, not random traffic.
- Last improvement came from the ABC target, not RTL.
- TT/FF hold margins are small; clocks are ideal (no skew or CTS).
- Physical design scripts predate this netlist and were not rerun.

## Corrected physical design results (results_D)

Supersedes all earlier routed numbers from results_C. The results_C flow routed
a database that had no clock tree (PDN started from the floorplan, not from CTS),
so its routed slack figures are not valid.

Flow order: floorplan + placement, CTS, PDN, PDN via repair, SS setup repair
(1 buffer), SS hold repair (7 buffers), legalization, global route, detailed route.

| Corner | Setup (ns) | Hold (ns) |
|--------|-----------|-----------|
| SS (-40C, 1.28 V) | +0.27 | +0.12 |
| TT (25C, 1.80 V)  | +7.74 | +0.22 |
| FF (-40C, 1.65 V) | +7.80 | +0.15 |

Detailed route DRC violations: 0. Clock buffers in routed DEF: 31 (same as CTS).

Basis and caveats:
- STA uses a propagated clock and estimate_parasitics -placement (placement-based
  wire RC), not extracted routed RC. This is not signoff.
- Repair used a 0.2 ns setup margin and a 0.1 ns hold margin at the SS corner.
- SS hold margin is small (+0.12 ns) and relies on 7 input hold buffers. The SDC
  models the external clock as ideal while the internal clock tree has about
  1.76 ns insertion delay, so input-to-flop hold paths needed delay buffers.
- lpflow_* cells already present in the synthesized netlist remain. set_dont_use
  only constrained new repair choices.
- CTS ran with the TT liberty and default settings.
- Earlier "+0.70 ns SS setup" was a pre-layout, no-parasitics synthesis figure.

## Functional verification
- RTL simulation (final RTL: uart_tx_C_experiment.v, uart_rx_split_experiment.v, uart_top.v), tb/uart_tb.v: TEST 1 (0x55) and TEST 2 (0xA5) PASSED.
- Gate-level simulation of synthesis_optimized/uart_C_D7000_mapped.v with the sky130 PDK functional models (-DFUNCTIONAL -DUNIT_DELAY='#0'): both tests PASSED.
- The 8 timing-repair buffers added in results_D do not change logic and were not simulated separately.
- The testbench sends two bytes in loopback, so this is a basic functional check, not exhaustive verification.
