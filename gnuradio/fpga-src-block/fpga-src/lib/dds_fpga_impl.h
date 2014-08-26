/* -*- c++ -*- */
/* 
 * Copyright 1970 <+YOU OR YOUR COMPANY+>.
 * 
 * This is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 3, or (at your option)
 * any later version.
 * 
 * This software is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with this software; see the file COPYING.  If not, write to
 * the Free Software Foundation, Inc., 51 Franklin Street,
 * Boston, MA 02110-1301, USA.
 */

#ifndef INCLUDED_TEST1_DDS_FPGA_IMPL_H
#define INCLUDED_TEST1_DDS_FPGA_IMPL_H

#include <gnuradio/thread/thread.h>
#include <boost/thread/mutex.hpp>
#include <boost/thread/condition_variable.hpp>
#include <test1/dds_fpga.h>

namespace gr {
  namespace test1 {

    class dds_fpga_impl : public dds_fpga
    {
     private:
	  int fpga_fd;
	  //FILE *x86_fd;
	  gr::thread::thread _thread;
	  static void _sx1255_wait(dds_fpga_impl *obj);
	  void sx1255_wait();
	  short **_buf;
	  char first;
		int _buf_num;
	  	int _nb_sample;
		unsigned long _buf_head;
		unsigned long _buf_used;
		unsigned long _buf_len;
		unsigned long _buf_offset;
		unsigned long _samp_avail;
		int _running;
		boost::mutex _buf_mutex;
		boost::condition_variable _buf_cond;


     public:
      dds_fpga_impl(int bufLen);
      ~dds_fpga_impl();

      // Where all the action really happens
      int work(int noutput_items,
	       gr_vector_const_void_star &input_items,
	       gr_vector_void_star &output_items);
    };

  } // namespace test1
} // namespace gr

#endif /* INCLUDED_TEST1_DDS_FPGA_IMPL_H */

