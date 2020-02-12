LIBRARY := ./hdl/library
IPS := axi_clkgen axi_hdmi_tx axi_spdif_tx axi_dmac

.PHONY: all clean

all:
	for ip in $(IPS); do \
		make -C $(LIBRARY)/$$ip; \
	done

clean:
	for ip in $(IPS); do \
		make -C $(LIBRARY)/$$ip clean; \
	done
