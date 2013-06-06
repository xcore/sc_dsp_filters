// Copyright (c) 2011, XMOS Ltd., All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

#include <platform.h>
#include "i2s_loopback.h"
#include "i2s_master.h"
#include "app_global.h"
#include "ports.h"

void audio_hw_init(unsigned);
void audio_hw_config(unsigned samFreq);

//::main program
int main()
{
   streaming chan c_data;

   par 
    {
        on stdcore[1] : 
        {
            unsigned mclk_bclk_div = MCLK_FREQ/(SAMP_FREQ * 64);
            audio_hw_init(mclk_bclk_div);

            audio_hw_config(SAMP_FREQ);           
            
            i2s_master(i2s_resources, c_data, mclk_bclk_div);
        }

        on stdcore[1] : loopback(c_data);

    }
   return 0;
}
//::

