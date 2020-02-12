
################################################################################
## This file contains all the message severity changes for Vivado 20xx.x.x
## These should reviewed at each release and updated if necessary

## A MUST: Every severity change must have a well defined and described role
## or purpose, and contains the instance of the original message. The main target
## here is to clean the log file from invalid CRITICAL WARNINGS.
##
## User should never change a CRITICAL WARNING to INFO, just to WARNING!

## This file is source in two places:
#
## at ~/hdl/library/scripts/adi_ip.tcl
## and
## at ~/hdl/projects/scripts/adi_project.tcl
##
################################################################################

################################################################################
## Tool related messages
## IDs : [Vivado 12-xxxx]
################################################################################

## For all projects which has SGMII, the tool presumes that we want ot use the
## eth_avb IP too, and because we don't have any license for it, thoughs out a
## CRITICAL WARNING. Downgrade this critical warning to a simple warning.
set_msg_config -id {Vivado 12-1790} -string "Evaluation features should NOT be used in production systems." -new_severity WARNING

################################################################################
## Block Design related messages
## IDs : [BD 41-xxxx]
################################################################################

## Temporally disabled - could not find and message with this ID
## set_msg_config -id {BD 41-1348} -new_severity WARNING

## Reset pin A (associated clock X) is connected to reset source B (associated
## clock Y) -- this is a reset transfer between two clock domain, it should stay
## CRITICAL -- needs to be reviewed
set_msg_config -id {BD 41-1343} -new_severity WARNING

## The connection to interface pin A is being overridden by the user. This pin
## will not be connected as a part of interface connection B (pin A is part of
## the B interface)
## In the future this should disappear, as we switch to using mostly interfaces
set_msg_config -id {BD 41-1306} -new_severity WARNING

## Cannot set the parameter XXXXXX. It is read-only. | Parameter does not exist.
## To make sure that each and every IP is configured correctly we push this
## CRITICAL WARNING into the ERRORs domain.
set_msg_config -severity {CRITICAL WARNING} -quiet -id {BD 41-1276} -new_severity ERROR

################################################################################
## IP packaging and flow related messages [IP_Flow xx-xxxx]
## IDs : [IP_Flow 19-xxxx]
################################################################################

## Temporally disabled - could not find and message with this ID
## set_msg_config -id {IP_Flow 19-1687} -new_severity WARNING

## If you move the project, the path for repository '~/hdl/library' may become
## invalid. A better location for the repository would be in a path adjacent to
## the project. -- Vivado does not like when library sources are outside the project
## directory.
set_msg_config -id {IP_Flow 19-3656} -new_severity INFO

## Temporally disabled - could not find and message with this ID
## set_msg_config -id {IP_Flow 19-2999} -new_severity INFO

## Temporally disabled - could not find and message with this ID
## set_msg_config -id {IP_Flow 19-1654} -new_severity INFO

## Unrecognized family xxxxxxx. Please verify spelling and reissue command to
## set the supported files. -- the adi_ip.tcl script trying to add all the existent
## family to the supported family list. Apparently Xilinx has some inconsistent
## naming conventions for families. TODO:Maybe we should define exactly the supported
## architectures.
set_msg_config -id {IP_Flow 19-4623} -new_severity INFO

## IP file '~/hdl/library/common/xxxx.v' appears to be outside of the project area.
## This is similar to 19-3656
set_msg_config -id {IP_Flow 19-459} -new_severity INFO

## Temporally disabled - could not find and message with this ID
## set_msg_config -id {filemgmt 20-1763} -new_severity WARNING

################################################################################
## Placer related messages
## IDs : [Place 30-xxxx]
################################################################################

## Invalid constraint on register */axi_spi/*/IOx_I_REG. It has the property IOB=TRUE,
## but is is not driving or driven by any IO element. -- The AXI_SPI IP after
## 2017.4 has a default constraint which setting the input registers property
## IOB=TRUE, this will cause a CRITICAL WARNING is the interface is not used.
set_msg_config -id {Place 30-73} -string "axi_spi" -new_severity WARNING

################################################################################
## Other ID less messages
################################################################################

## After Vivado 2017.4, the tool does not like negative DDR_DQS_TO_CLK_DELAY
## values on the DDRx interface, and throw a CRITICAL WARNING. Although a negative
## value is not necessarily invalid, the ZedBoard's interface is working this way.
set_msg_config -string "PCW_UIPARAM_DDR_DQS_TO_CLK_DELAY" -new_severity WARNING

