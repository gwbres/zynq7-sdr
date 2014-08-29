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

#ifdef HAVE_CONFIG_H
#include "config.h"
#endif

#include <gnuradio/io_signature.h>
#include <volk/volk.h>
#include <sys/ioctl.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>

#include "dds_fpga_impl.h"

/* 2 8bits I/Q */
#define BYTES_PER_SAMPLE 2 
#define NB_SAMP 16384
//#define NB_SAMP 8192
namespace gr {
  namespace test1 {

    dds_fpga::sptr
    dds_fpga::make(int nbSamp, const std::string &devname)
    {
      return gnuradio::get_initial_sptr
        (new dds_fpga_impl(nbSamp, devname));
    }

    /*
     * The private constructor
     */
    dds_fpga_impl::dds_fpga_impl(int nbSamp, const std::string &devname)
      : gr::sync_block("dds_fpga",
              gr::io_signature::make(0, 0, 0),
              gr::io_signature::make(1, 1, sizeof(gr_complex)/*2*sizeof(char)*/)),
		_buf(NULL)
    {
		printf("hello world\n");
		fpga_fd = open(devname.c_str(), O_RDWR);
		if (fpga_fd < 0) {
			//printf("erreur d'ouverture du fpga (%d) : %s\n", fpga_fd, perror(errno));
			perror("erreur d'ouverture du fpga!!! : ");
		}
		const int alignment_multiple =
		volk_get_alignment() / sizeof(gr_complex);
		set_alignment(std::max(1, alignment_multiple));

		_test = 0;
		_buf_len = _buf_head = _buf_used = _buf_offset = 0;
		_buf_num = 32;	
		_nb_sample = nbSamp;
		_buf_len = _nb_sample * BYTES_PER_SAMPLE;
		_samp_avail = _nb_sample;//_buf_len/BYTES_PER_SAMPLE;
		_running == 0;

		_buf = (short **) malloc(_buf_num * sizeof(short *));	
		if (_buf) {
			for (unsigned int i = 0; i < _buf_num; i++) {
				_buf[i] = (short *)malloc(_buf_len);
			}
		}
		first = 1;
		_running = 1;
		_thread = gr::thread::thread(_sx1255_wait, this);
		printf("c'est parti %d %d\n", _buf_len, _nb_sample);
	}
	

    /*
     * Our virtual destructor.
     */
    dds_fpga_impl::~dds_fpga_impl()
    {
		_running = 0;
		_thread.join();
		close(fpga_fd);
		if (_buf) {
			for (int i = 0; i < _buf_num; i++)
				free(_buf[i]);
			free(_buf);
		}

    }

void dds_fpga_impl::_sx1255_wait(dds_fpga_impl *obj)
{
	obj->sx1255_wait();
}

	void dds_fpga_impl::sx1255_wait()
	{
		short buf[_nb_sample];
		int len;
		int buf_tail;
		while(1) {
			if (_running == 0)
				break;
			len = read(fpga_fd, buf, _buf_len);
			if (len < 0)
				break;
			if (len != _buf_len) 
				printf("plop %d\n", len);
			{
				boost::mutex::scoped_lock lock (_buf_mutex);
				buf_tail = (_buf_head + _buf_used) % _buf_num;
				memcpy(_buf[buf_tail], buf, len);


				if (_buf_used == _buf_num) {
					_buf_head = (_buf_head +1) % _buf_num;
					printf("O. %d\n", _buf_used);
				}else {
					_buf_used ++;
				}
			}
			_buf_cond.notify_one();
		}
	}

	int dds_fpga_impl::work(int noutput_items,
			gr_vector_const_void_star &input_items,
			gr_vector_void_star &output_items)
	{
		float *out = (float *) output_items[0];
		int size = noutput_items;
		short *buf;

		//printf("\twork %d %d\n", noutput_items, _samp_avail);
		{
			boost::mutex::scoped_lock lock(_buf_mutex);
			while (_buf_used < 3) {
				_buf_cond.wait(lock);
				//printf("poll\n");
			}
		}
		//printf("\twork %d %d %d\n", noutput_items, _samp_avail, _buf_used);
		while (1) {
			buf = _buf[_buf_head] + _buf_offset;
		
/*			if (_test == 0) {
				_test = 1;
				for (int i = 0; i<128; i++) {
					printf("%hd %hd\n",(signed short) (buf[i]&0xff), (signed short)((buf[i]&0xff00)>>8));	
				}
			}*/

			if (size <= _samp_avail) {
				//printf("cas 1\n");
				//memcpy(out, buf, size*BYTES_PER_SAMPLE);
				volk_8i_s32f_convert_32f_u(out, (const int8_t*)buf, 1.0, 
								BYTES_PER_SAMPLE*size);
				_buf_offset += size/**BYTES_PER_SAMPLE*/;
				_samp_avail -= size;
				return noutput_items;
			} else {
				//printf("cas 2\n");
				//memcpy(out, buf, _samp_avail*BYTES_PER_SAMPLE);
				volk_8i_s32f_convert_32f_u(out, (const int8_t*)buf, 1.0, 
							BYTES_PER_SAMPLE*_samp_avail);
				/* GGM: not sure: but two float/sample ? true with
				 * gr_complex?
				 */
				out+=(BYTES_PER_SAMPLE*_samp_avail);
				//out+=/*sizeof(float)**/_samp_avail;

				{
					boost::mutex::scoped_lock lock(_buf_mutex);
					while (_buf_used < 1) 
						_buf_cond.wait(lock);
					_buf_head = (_buf_head + 1) % _buf_num;
					_buf_used --;
				}

				buf = _buf[_buf_head];
				int remaining = size - _samp_avail;

				if (remaining > _nb_sample) {
					printf("\tover\t");
					remaining = _nb_sample;
				}
				//printf("part2\n");	
				volk_8i_s32f_convert_32f_u(out, (const int8_t *)buf, 1.0, 
									BYTES_PER_SAMPLE*remaining);
				//memcpy(out, buf, remaining*BYTES_PER_SAMPLE);
				out+=remaining*BYTES_PER_SAMPLE;
				_buf_offset = remaining/**BYTES_PER_SAMPLE*/;
				size -= (_samp_avail+remaining);
				_samp_avail = _nb_sample - remaining;
				/*if (size > 0) {
					printf("%d \n", noutput_items);
				}*/
				//printf("part3\n");	

				return noutput_items;
			}
		}
        // Tell runtime system how many output items we produced.
        return noutput_items;
    }

  } /* namespace test1 */
} /* namespace gr */

