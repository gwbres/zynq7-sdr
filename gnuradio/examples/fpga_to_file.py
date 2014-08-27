#!/usr/bin/env python
##################################################
# Gnuradio Python Flow Graph
# Title: Top Block
# Generated: Sat May 17 16:04:26 2014
##################################################

from gnuradio import eng_notation
from gnuradio import gr
from gnuradio import analog
from gnuradio import blocks

from gnuradio.eng_option import eng_option
from gnuradio.filter import firdes
from optparse import OptionParser
import test1
import sip
import sys
import time

class top_block(gr.top_block):

    def __init__(self):
        gr.top_block.__init__(self, "Top Block")


        ##################################################
        # Variables
        ##################################################
        self.samp_rate = samp_rate = 80000
	self.test1_dds_fpga_0 = test1.dds_fpga(8192*2, "/dev/iqram")
        ##################################################
        # Blocks
        ##################################################
	self.analog_wfm_rcv_0 = analog.wfm_rcv(
		quad_rate=samp_rate,
		audio_decimation=5,
	)        

        self.blocks_file_sink_0 = blocks.file_sink(gr.sizeof_gr_complex*1, "sp440.dat", False)
        self.blocks_file_sink_0.set_unbuffered(False)

        ##################################################
        # Connections
        ##################################################
#        self.connect((self.test1_dds_fpga_0, 0), (self.analog_wfm_rcv_0, 0))
        self.connect((self.test1_dds_fpga_0, 0), (self.blocks_file_sink_0, 0))
#	self.connect((self.analog_wfm_rcv_0, 0), (self.blocks_file_sink_0, 0))


    def get_samp_rate(self):
        return self.samp_rate

    def set_samp_rate(self, samp_rate):
        self.samp_rate = samp_rate

if __name__ == '__main__':
    parser = OptionParser(option_class=eng_option, usage="%prog: [options]")
    (options, args) = parser.parse_args()
    tb = top_block()
    tb.start()
    raw_input('Press Enter to quit: ')
    tb.stop()
    tb.wait()
