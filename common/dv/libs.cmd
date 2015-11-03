#Always search local
-y .

#DV
-y ../../common/dv
-y ../../emesh/dv

#HDL
-y .
-y ../../common/hdl
-y ../../elink/hdl
-y ../../edma/hdl
-y ../../emesh/hdl
-y ../../emmu/hdl
-y ../../emailbox/hdl
-y ../../memory/hdl
-y ../../xilibs/hdl

#INCLUDE PATHS (FOR CONSTANTS)
+incdir+../../emesh/hdl
+incdir+../../elink/hdl
+incdir+../../edma/hdl
+incdir+../../emmu/hdl
+incdir+../../emailbox/hdl
