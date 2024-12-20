# mlp_accelerator

## mlp_controller
Controller to interface between Nios V and mvm_noc.
To test in simulation, run: 
```
cd mlp_controller/simulation/modelsim/ && vsim -do testbench.tcl
```

## mlp_accelerator
Full design with Nios V connected to mlp_controller connected to mvm_noc
