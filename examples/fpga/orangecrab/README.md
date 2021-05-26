# Ibex RISC-V Core SoC Example

Please see [examples](https://ibex-core.readthedocs.io/en/latest/02_user/examples.html "Ibex User Manual") for a description of this example.

## Requirements

### Tools

  - RV32 compiler
  - srecord
  - `fusesoc` and its dependencies
  - Yosys
  - nextpnr-ecp5 with prjtrellis

### Hardware

  - ornagecrab

## Build

The easiest way to build and execute this example is to call the following make goals from the root directory.

Use the following

```
make build-orangecrab
```

### Software

First the software must be built. Go into `examples/sw/led` and call:

```
make CC=/path/to/RISC-V-compiler
```

The setting of `CC` is only required if `riscv32-unknown-elf-gcc` is not available through the `PATH` environment variable.
The path to the RV32 compiler `/path/to/RISC-V-compiler` depends on the environment.
For example, it can be for example `/opt/riscv/bin/riscv-none-embed-gcc` if the whole path is required or simply the name of the executable if it is available through the `PATH` environment variable.

This should produce a `led.vmem` file which is used in the synthesis to update the SRAM storage.

### Hardware

Run either of the following commands at the top level to build the respective hardware.

```
fusesoc --cores-root=. run --target=synth --setup --build lowrisc:ibex:top_orangecrab
```

This will create a directory `build` which contains the output files, including
the bitstream.
