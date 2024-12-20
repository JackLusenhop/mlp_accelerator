# mlp_accelerator

## mlp_controller
Controller to interface between Nios V and mvm_noc.
To test in simulation, run: 
```
cd mlp_controller/simulation/modelsim/ && vsim -do testbench.tcl
```

To open the design in quartus, open quartus and select file->open and select the file: 
mlp_controller/mlp_controller.qpf

## mlp_accelerator
Full design with Nios V connected to mlp_controller connected to mvm_noc.

To open the design in quartus, open quartus and select file->open and select the file: 
mlp_accelerator/hw/mvm_noc.qpf

To program the design follow the directions located at: 
https://www.intel.com/content/www/us/en/docs/programmable/784468/current/programming-hardware-sof-file.html
and select mvm_noc.sof

To program the software run the folowing commands: 
```
cd mlp_accelerator/sw/app/build/Debug
niosv-download -g app.elf
```

Alternatively, the project can be opened in the RiscFree IDE. 

To find out more about generating the software use the following links: 
https://www.youtube.com/watch?v=c6t-MVQ_j8Y
https://www.intel.com/content/www/us/en/docs/programmable/743810/24-3/command-line-utilities.html
