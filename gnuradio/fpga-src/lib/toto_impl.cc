/* -*- c++ -*- */
/* 
 * Copyright 2013 <+YOU OR YOUR COMPANY+>.
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

#ifdef HAVE_CONFIG_H
#include "config.h"
#endif

#include <gnuradio/io_signature.h>
#include "toto_impl.h"

namespace gr {
  namespace test1 {

    toto::sptr
    toto::make(int vlen, const char *filename, int repeat)
    {
      return gnuradio::get_initial_sptr
        (new toto_impl());
    }

    /*
     * The private constructor
     */
    toto_impl::toto_impl()
      : gr::sync_block("toto",
              gr::io_signature::make(0, 0, 0),
              gr::io_signature::make(1, 1, 1024*sizeof(short)))
    {
		counter = 0;	
	}

    /*
     * Our virtual destructor.
     */
    toto_impl::~toto_impl()
    {
    }

    int
    toto_impl::work(int noutput_items,
			  gr_vector_const_void_star &input_items,
			  gr_vector_void_star &output_items)
    {
        short *out = (short *) output_items[0];
		int i;
		for (i = 0; i< noutput_items;i++) {
			out[i] = counter;
			if (counter == 1024)
				counter = 0;
			else 
				counter ++;
		}


        // Tell runtime system how many output items we produced.
        return noutput_items;
    }

  } /* namespace test1 */
} /* namespace gr */

