import sys
import os
import siliconcompiler

def main():

    progname = "oh"
    description = """
    --------------------------------------------------------------
    App for building the ebrick.
    """

    UNSET_DESIGN = '  unset  '
    chip = siliconcompiler.Chip(UNSET_DESIGN)

    chip.create_cmdline(progname,
                    switchlist=['-target', '-design'],
                    description=description)

    # Set default flow
    if not chip.get('option', 'target'):
        chip.load_target("freepdk45_demo")



    chip.set('input', 'verilog', f"rtl/{chip.get('design')}.v")
    chip.add('option', 'ydir', 'rtl')
    chip.set('option', 'quiet', True)
    chip.set('option', 'steplist', ['import','syn'])
    # Run through the flow
    chip.run()

#########################
if __name__ == "__main__":
    sys.exit(main())
