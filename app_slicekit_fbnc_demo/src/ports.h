

#include "xa_sk_audio_1v1.h"

//::declaration
on stdcore[1] : r_i2s i2s_resources =
{
    XS1_CLKBLK_1,
    XS1_CLKBLK_2,
    PORT_MCLK_IN,             // Master Clock 
    PORT_I2S_BCLK,            // Bit Clock
    PORT_I2S_LRCLK,           // LR Clock
    {PORT_I2S_ADC0, PORT_I2S_ADC1},
    {PORT_I2S_DAC0, PORT_I2S_DAC1},

};
//::

/* Some extra port declarations */

/* Port for I2C bus. Both SDA and SCL are on lines on same port */
on stdcore[1] : port p_i2c_c = PORT_I2C_C;
on stdcore[1] : port p_i2c_d = PORT_I2C_D;

on stdcore[1]: port reset_n = XS1_PORT_4A;

