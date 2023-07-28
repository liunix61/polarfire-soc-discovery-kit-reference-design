puts "TCL_BEGIN: [info script]"

#
# // Discovery Kit Reference Libero design
#

#
# // Check path length to verify project can be created
#

if { [lindex $tcl_platform(os) 0]  == "Windows" } {
    if {[string length [pwd]] < 90} {
        puts "Project path length ok."
    } else {
        error "Path to project is too long, please reduce the path and try again."
    }
}

#
# // Process arguments
#

if { $::argc > 0 } {
    set i 1
    foreach arg $::argv {
        if {[string match "*:*" $arg]} {
            set var [string range $arg 0 [string first ":" $arg]-1]
            set val [string range $arg [string first ":" $arg]+1 end]
            puts "Setting parameter $var to $val"
            set $var "$val"
        } else {
            set $arg 1
            puts "set $arg to 1"
        }
        incr i
    }
} else {
    puts "no command line argument passed"
}

#
# // Set required variables and add functions
#

set libero_release [split [get_libero_version] .]
set install_loc [defvar_get -name ACTEL_SW_DIR]
set mss_config_loc "$install_loc/bin64/pfsoc_mss"
set local_dir [pwd]
set constraint_path ./script_support/constraints

if {[info exists I2C_LOOPBACK]} {
    set project_name "MPFS_DISCOVERY_I2C_LOOPBACK"
    set project_dir "$local_dir/MPFS_DISCOVERY_I2C_LOOPBACK"
} elseif {[info exists VECTORBLOX]} {
    set project_name "MPFS_DISCOVERY_Vectorblox"
    set project_dir "$local_dir/MPFS_DISCOVERY_Vectorblox"
} elseif {[info exists SPI_LOOPBACK]} {
    set project_name "MPFS_DISCOVERY_SPI_LOOPBACK"
    set project_dir "$local_dir/MPFS_DISCOVERY_SPI_LOOPBACK"
} elseif {[info exists DRI_CCC_DEMO]} {
    set project_name "MPFS_DISCOVERY_DRI_CCC_DEMO"
    set project_dir "$local_dir/MPFS_DISCOVERY_DRI_CCC_DEMO"
} elseif {[info exists MICRON_QSPI]} {
    set project_name "MPFS_DISCOVERY_MICRON_QSPI"
    set project_dir "$local_dir/MPFS_DISCOVERY_MICRON_QSPI"
} elseif {[info exists SMARTHLS]} {
    set project_name "Discovery_SoC"
    set project_dir "$local_dir/soc"
} elseif {[info exists BFM_SIMULATION] && [info exists AXI4_STREAM_DEMO]} {
    set project_name "MPFS_DISCOVERY_AXI4_STREAM_DEMO_BFM"
    set project_dir "$local_dir/MPFS_DISCOVERY_AXI4_STREAM_DEMO_BFM"
} elseif {[info exists AXI4_STREAM_DEMO]} {
    set project_name "MPFS_DISCOVERY_AXI4_STREAM_DEMO"
    set project_dir "$local_dir/MPFS_DISCOVERY_AXI4_STREAM_DEMO"
} elseif {[info exists BFM_SIMULATION]} {
    set project_name "MPFS_DISCOVERY_BFM_SIMULATION"
    set project_dir "$local_dir/MPFS_DISCOVERY_BFM_SIMULATION"
} else {
    set project_name "MPFS_DISCOVERY"
    set project_dir "$local_dir/MPFS_DISCOVERY"
}

if {[info exists MSS_LINUX]} {

} elseif {[info exists MSS_BAREMETAL]} {

} else {
    set MSS_LINUX 1
}

source ./script_support/additional_configurations/functions.tcl

#
# // Open or create a Libero project
#
if { [file exists $project_dir/$project_name.prjx] } {
    puts "Open existing project"
    open_project -file $project_dir/$project_name.prjx
    open_smartdesign -sd_name {MPFS_DISCOVERY_KIT}
    set isNewProject 0
} else {
    puts "Creating a new project"
    set isNewProject 1
    new_project \
        -location $project_dir \
        -name $project_name \
        -project_description {} \
        -block_mode 0 \
        -standalone_peripheral_initialization 0 \
        -instantiate_in_smartdesign 1 \
        -ondemand_build_dh 1 \
        -use_relative_path 0 \
        -linked_files_root_dir_env {} \
        -hdl {VERILOG} \
        -family {PolarFireSoC} \
        -die {MPFS095T} \
        -package {FCSG325} \
        -speed {-1} \
        -die_voltage {1.0} \
        -part_range {EXT} \
        -adv_options {IO_DEFT_STD:LVCMOS 1.8V} \
        -adv_options {RESTRICTPROBEPINS:1} \
        -adv_options {RESTRICTSPIPINS:0} \
        -adv_options {SYSTEM_CONTROLLER_SUSPEND_MODE:0} \
        -adv_options {TEMPR:EXT} \
        -adv_options {VCCI_1.2_VOLTR:EXT} \
        -adv_options {VCCI_1.5_VOLTR:EXT} \
        -adv_options {VCCI_1.8_VOLTR:EXT} \
        -adv_options {VCCI_2.5_VOLTR:EXT} \
        -adv_options {VCCI_3.3_VOLTR:EXT} \
        -adv_options {VOLTR:EXT}

    smartdesign \
        -memory_map_drc_change_error_to_warning 1 \
        -bus_interface_data_width_drc_change_error_to_warning 1 \
        -bus_interface_id_width_drc_change_error_to_warning 1 
    #
    # // Download required cores
    #
	try {
		download_core -vlnv {Actel:SgCore:PF_OSC:*} -location {www.microchip-ip.com/repositories/SgCore}
		download_core -vlnv {Actel:SgCore:PF_CCC:*} -location {www.microchip-ip.com/repositories/SgCore}
		download_core -vlnv {Actel:DirectCore:CORERESET_PF:*} -location {www.microchip-ip.com/repositories/DirectCore}
		download_core -vlnv {Microsemi:SgCore:PFSOC_INIT_MONITOR:*} -location {www.microchip-ip.com/repositories/SgCore}
		download_core -vlnv {Actel:DirectCore:COREAXI4INTERCONNECT:2.8.103} -location {www.microchip-ip.com/repositories/DirectCore}
		download_core -vlnv {Actel:SgCore:PF_CLK_DIV:*} -location {www.microchip-ip.com/repositories/SgCore}
		download_core -vlnv {Actel:SgCore:PF_DRI:*} -location {www.microchip-ip.com/repositories/SgCore}
		download_core -vlnv {Actel:SgCore:PF_NGMUX:*} -location {www.microchip-ip.com/repositories/SgCore}
		download_core -vlnv {Actel:SgCore:PF_PCIE:*} -location {www.microchip-ip.com/repositories/SgCore}
		download_core -vlnv {Actel:SgCore:PF_TX_PLL:*} -location {www.microchip-ip.com/repositories/SgCore}
		download_core -vlnv {Actel:SgCore:PF_XCVR_REF_CLK:*} -location {www.microchip-ip.com/repositories/SgCore}
		download_core -vlnv {Actel:DirectCore:CoreAPB3:4.2.100} -location {www.microchip-ip.com/repositories/DirectCore}
		download_core -vlnv {Actel:DirectCore:COREAXI4DMACONTROLLER:2.0.100} -location {www.microchip-ip.com/repositories/DirectCore}
		download_core -vlnv {Actel:DirectCore:CoreGPIO:3.2.102} -location {www.microchip-ip.com/repositories/DirectCore}
		download_core -vlnv {Actel:SystemBuilder:PF_SRAM_AHBL_AXI:*} -location {www.microchip-ip.com/repositories/SgCore}
		download_core -vlnv {Actel:Simulation:CLK_GEN:*} -location {www.microchip-ip.com/repositories/SgCore}
		download_core -vlnv {Actel:Simulation:RESET_GEN:*} -location {www.microchip-ip.com/repositories/SgCore}
		download_core -vlnv {Actel:DirectCore:corepwm:4.5.100} -location {www.microchip-ip.com/repositories/DirectCore} 
		download_core -vlnv {Actel:DirectCore:COREI2C:7.2.101} -location {www.microchip-ip.com/repositories/DirectCore} 
		download_core -vlnv {Actel:DirectCore:CoreUARTapb:5.7.100} -location {www.microchip-ip.com/repositories/DirectCore} 
	} on error err {
		puts "Downloading cores failed, the script will continute but will fail if all of the required cores aren't present in the vault."
	}

    #
    #  // Generate and import MSS component
    #

    if {[file isdirectory $local_dir/script_support/components/MSS]} {
        file delete -force $local_dir/script_support/components/MSS
    }
    file mkdir $local_dir/script_support/components/MSS
	
	exec $mss_config_loc -GENERATE -CONFIGURATION_FILE:$local_dir/script_support/MPFS_DISCOVERY_KIT_MSS.cfg -OUTPUT_DIR:$local_dir/script_support/components/MSS

    import_mss_component -file "$local_dir/script_support/components/MSS/MPFS_DISCOVERY_KIT_MSS.cxz"

    #
    # // Generate base design
    #

    cd ./script_support/
    source MPFS_DISCOVERY_KIT_recursive.tcl
    cd ../
    set_root -module {MPFS_DISCOVERY_KIT::work} 

    #
    # // Import I/O constraints
    #

    import_files \
        -convert_EDN_to_HDL 0 \
        -io_pdc "${constraint_path}/MPFS_DISCOVERY_KIT_BANK_SETTINGS.pdc" \
        -io_pdc "${constraint_path}/MPFS_DISCOVERY_KIT_BOARD_MISC.pdc" \
        -io_pdc "${constraint_path}/MPFS_DISCOVERY_MAC.pdc" \
        -io_pdc "${constraint_path}/MPFS_DISCOVERY_mikroBUS.pdc" \
        -io_pdc "${constraint_path}/MPFS_DISCOVERY_RPi.pdc" \
        -io_pdc "${constraint_path}/MPFS_DISCOVERY_UARTS.pdc" \
		-io_pdc "${constraint_path}/MPFS_DISCOVERY_7_SEG.pdc" 
	
	organize_tool_files \
		-tool {PLACEROUTE} \
		-file "${project_dir}/constraint/io/MPFS_DISCOVERY_KIT_BANK_SETTINGS.pdc" \
		-file "${project_dir}/constraint/io/MPFS_DISCOVERY_KIT_BOARD_MISC.pdc" \
		-file "${project_dir}/constraint/io/MPFS_DISCOVERY_mikroBUS.pdc" \
		-file "${project_dir}/constraint/io/MPFS_DISCOVERY_RPi.pdc" \
		-file "${project_dir}/constraint/io/MPFS_DISCOVERY_UARTS.pdc" \
		-file "${project_dir}/constraint/io/MPFS_DISCOVERY_7_SEG.pdc" \
		-module {MPFS_DISCOVERY_KIT::work} \
		-input_type {constraint}        
        
    #
    # // Build hierarchy before progressing
    #

    build_design_hierarchy

    #
    # // Apply additional design configurations
    #

    if {[info exists MSS_BAREMETAL]} {
	    source script_support/additional_configurations/MSS_BAREMETAL/MSS_BAREMETAL.tcl
    }

    if {[info exists BFM_SIMULATION]} {
        source script_support/simulation/Test_bench.tcl
    }

    if {[info exists AXI4_STREAM_DEMO]} {
        if {[info exists BFM_SIMULATION]} {
            source script_support/additional_configurations/AXI4_STREAM_DATA_GENERATOR/AXI4_STREAM_DATA_GENERATOR_BFM.tcl    
        } else {
            source script_support/additional_configurations/AXI4_STREAM_DATA_GENERATOR/AXI4_STREAM_DATA_GENERATOR.tcl    
        }
    }

    if {[info exists I2C_LOOPBACK]} {
        if {[file isdirectory $local_dir/script_support/components/MSS_I2C_LOOPBACK]} {
            file delete -force $local_dir/script_support/components/MSS_I2C_LOOPBACK
        }
        file mkdir $local_dir/script_support/components/MSS_I2C_LOOPBACK
        create_config $local_dir/script_support/components/MSS/DISCOVERY_MSS.cfg $local_dir/script_support/additional_configurations/I2C_LOOPBACK/DISCOVERY_MSS_I2C_LOOPBACK.cfg
        update_param $local_dir/script_support/additional_configurations/I2C_LOOPBACK/DISCOVERY_MSS_I2C_LOOPBACK.cfg "I2C_1 " "FABRIC"
        exec $mss_config_loc -GENERATE -CONFIGURATION_FILE:$local_dir/script_support/additional_configurations/I2C_LOOPBACK/DISCOVERY_MSS_I2C_LOOPBACK.cfg -OUTPUT_DIR:$local_dir/script_support/components/MSS_I2C_LOOPBACK
        source ./script_support/additional_configurations/I2C_LOOPBACK/I2C_LOOPBACK.tcl
    } elseif {[info exists VECTORBLOX]} {
        source ./script_support/additional_configurations/Vectorblox/Vectorblox.tcl
    } elseif {[info exists SPI_LOOPBACK]} {
        if {[file isdirectory $local_dir/script_support/components/MSS_SPI_LOOPBACK]} {
            file delete -force $local_dir/script_support/components/MSS_SPI_LOOPBACK
        }
        file mkdir $local_dir/script_support/components/MSS_SPI_LOOPBACK
        create_config $local_dir/script_support/components/MSS/DISCOVERY_MSS.cfg $local_dir/script_support/additional_configurations/SPI_LOOPBACK/DISCOVERY_MSS_SPI_LOOPBACK.cfg
        update_param $local_dir/script_support/additional_configurations/SPI_LOOPBACK/DISCOVERY_MSS_SPI_LOOPBACK.cfg "QSPI                                " "UNUSED"
        update_param $local_dir/script_support/additional_configurations/SPI_LOOPBACK/DISCOVERY_MSS_SPI_LOOPBACK.cfg "QSPI_CLK                                " "UNUSED"
        update_param $local_dir/script_support/additional_configurations/SPI_LOOPBACK/DISCOVERY_MSS_SPI_LOOPBACK.cfg "QSPI_DATA_3_2                                " "UNUSED"
        update_param $local_dir/script_support/additional_configurations/SPI_LOOPBACK/DISCOVERY_MSS_SPI_LOOPBACK.cfg "SPI_1                                " "MSSIO_B2_B"
        update_param $local_dir/script_support/additional_configurations/SPI_LOOPBACK/DISCOVERY_MSS_SPI_LOOPBACK.cfg "SPI_1_SS1                                " "FABRIC"
        exec $mss_config_loc -GENERATE -CONFIGURATION_FILE:$local_dir/script_support/additional_configurations/SPI_LOOPBACK/DISCOVERY_MSS_SPI_LOOPBACK.cfg -OUTPUT_DIR:$local_dir/script_support/components/MSS_SPI_LOOPBACK
        source ./script_support/additional_configurations/SPI_LOOPBACK/SPI_LOOPBACK.tcl
    } elseif {[info exists DRI_CCC_DEMO]} {
        source ./script_support/additional_configurations/DRI_CCC_DEMO/DRI_CCC_DEMO.tcl
    }
    #
    # // Derive timing constraints
    #
    build_design_hierarchy
    derive_constraints_sdc 

    #
    # // Auto layout SmartDesigns
    #
    save_project 
    sd_reset_layout -sd_name {CLOCKS_AND_RESETS}
    save_smartdesign -sd_name {CLOCKS_AND_RESETS}
    sd_reset_layout -sd_name {FIC_0_PERIPHERALS}
    save_smartdesign -sd_name {FIC_0_PERIPHERALS}
    sd_reset_layout -sd_name {CORE_I2C_C0_0_WRAPPER}
    save_smartdesign -sd_name {CORE_I2C_C0_0_WRAPPER}
    sd_reset_layout -sd_name {FIC_3_ADDRESS_GENERATION}
    save_smartdesign -sd_name {FIC_3_ADDRESS_GENERATION}
    sd_reset_layout -sd_name {IHC_SUBSYSTEM}
    save_smartdesign -sd_name {IHC_SUBSYSTEM}
    sd_reset_layout -sd_name {FIC_3_PERIPHERALS}
    save_smartdesign -sd_name {FIC_3_PERIPHERALS}
    sd_reset_layout -sd_name {MSS_WRAPPER}
    save_smartdesign -sd_name {MSS_WRAPPER}
    sd_reset_layout -sd_name {MPFS_DISCOVERY_KIT}
    save_smartdesign -sd_name {MPFS_DISCOVERY_KIT}
} ; # // Create new project


# 
# Compile and integrate the SmartHLS code
#
if {[info exists SMARTHLS]} {
    if {$isNewProject} {
        # Prepare the SmartDesign for HLS integration 
        source ./script_support/additional_configurations/smarthls/pre_hls_integration.tcl
    }

    # If the SmartHLS variable points to a valid SmartHLS project directory, then compile it.
    # Otherwise, HLS modules can be added later.
    if {[file isdirectory $SMARTHLS]} {
        source ./script_support/additional_configurations/smarthls/compile_and_integrate_shls_to_refdesign.tcl
    }
}

#
# // Derive timing constraints
#

build_design_hierarchy
derive_constraints_sdc 

#
# // Run the design flow and add eNVM clients if required
#

if {[info exists SYNTHESIZE]} {
    run_tool -name {SYNTHESIZE}
} elseif {[info exists PLACEROUTE]} {
    run_tool -name {PLACEROUTE}
} elseif {[info exists VERIFY_TIMING]} {
    run_tool -name {VERIFYTIMING}
}

if {[info exists HSS_UPDATE]} {
    if !{[file exists "./script_support/hss-envm-wrapper.mpfs-Discovery-kit-es.hex"]} {
        if {[catch    {exec wget https://github.com/polarfire-soc/hart-software-services/releases/latest/download/hss-envm-wrapper.mpfs-Discovery-kit-es.hex -P ./script_support/} issue]} {
        }
    }
    create_eNVM_config "$local_dir/script_support/components/MSS/ENVM.cfg" "$local_dir/script_support/hss-envm-wrapper.mpfs-Discovery-kit-es.hex"
    run_tool -name {GENERATEPROGRAMMINGDATA}
    configure_envm -cfg_file {script_support/components/MSS/ENVM.cfg}
}

if {[info exists GENERATE_PROGRAMMING_DATA]} {
    run_tool -name {GENERATEPROGRAMMINGDATA}
}  elseif {[info exists PROGRAM]} {
    run_tool -name {PROGRAMDEVICE}
} elseif {[info exists EXPORT_FPE]} {   
    set gUseSPI 0
    if {[info exists SMARTHLS]} {
        set gUseSPI [update_snvm_to_spi_ram_cfg $project_dir/designer/MPFS_DISCOVERY_KIT/MPFS_DISCOVERY_KIT_RAM.cfg ]
        generate_design_initialization_data
    }
    
    set jobPath $local_dir
    if {[file isdirectory $EXPORT_FPE]} {set jobPath $EXPORT_FPE}

    set components "FABRIC_SNVM"
    if {[info exists HSS_UPDATE]} { set components "$components ENVM" }

    puts "export_fpe_job $project_name $jobPath $components $gUseSPI"
    export_fpe_job $project_name $jobPath $components $gUseSPI
}

save_project 

puts "TCL_END: [info script]"
