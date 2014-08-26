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


#ifndef INCLUDED_TEST1_TOTO_H
#define INCLUDED_TEST1_TOTO_H

#include <test1/api.h>
#include <gnuradio/sync_block.h>

namespace gr {
  namespace test1 {

    /*!
     * \brief <+description of block+>
     * \ingroup test1
     *
     */
    class TEST1_API toto : virtual public gr::sync_block
    {
     public:
      typedef boost::shared_ptr<toto> sptr;

      /*!
       * \brief Return a shared_ptr to a new instance of test1::toto.
       *
       * To avoid accidental use of raw pointers, test1::toto's
       * constructor is in a private implementation
       * class. test1::toto::make is the public interface for
       * creating new instances.
       */
      static sptr make(int vlen, const char *filename, int repeat);
    };

  } // namespace test1
} // namespace gr

#endif /* INCLUDED_TEST1_TOTO_H */

