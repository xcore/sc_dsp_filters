
#include <xs1.h>
#include <print.h>
#include "app_global.h"
#include "i2c.h"
#include "xa_sk_audio_1v1.h"

extern port p_i2c;
extern out port p_gpio;

void audio_hw_init()
{
    /* Initialise the I2C bus */
    i2c_master_init(p_i2c);
}


#define CODEC1_I2C_DEVICE_ADDR       (0x90)
#define CODEC2_I2C_DEVICE_ADDR       (0x92)

#define CODEC_DEV_ID_ADDR           0x01
#define CODEC_PWR_CTRL_ADDR         0x02
#define CODEC_MODE_CTRL_ADDR        0x03
#define CODEC_ADC_DAC_CTRL_ADDR     0x04
#define CODEC_TRAN_CTRL_ADDR        0x05
#define CODEC_MUTE_CTRL_ADDR        0x06
#define CODEC_DACA_VOL_ADDR         0x07
#define CODEC_DACB_VOL_ADDR         0x08

#define IIC_REGWRITE(reg, val) {data[0] = val; i2c_master_write_reg(CODEC1_I2C_DEVICE_ADDR, reg, data, 1, p_i2c);data[0] = val; i2c_master_write_reg(CODEC2_I2C_DEVICE_ADDR, reg, data, 1, p_i2c);} 
#define IIC_REGREAD(reg, val)  {i2c_master_read_reg(CODEC1_I2C_DEVICE_ADDR, reg, val, 1, p_i2c);}

void audio_hw_config(unsigned samFreq)
{
    timer t;
    unsigned time;
    unsigned tmp;

    int codec_dev_id;
    unsigned char data[1] = {0};

    /* Set CODEC in reset */
    tmp = P_GPIO_COD_RST_N;
    
    /* Set master clock select appropriately */
    if ((samFreq % 22050) == 0) 
    {
        tmp &= ~P_GPIO_MCLK_SEL;
    }
    else //if((samFreq % 24000) == 0) 
    {
        tmp |= P_GPIO_MCLK_SEL;
    }
    
    /* Output to port */  
    p_gpio <: tmp;

    /* Hold in reset for 2ms while waiting for MCLK to stabilise */
    t :> time;
    time += 200000;
    t when timerafter(time) :> int _;

    /* CODEC out of reset */
    tmp |= P_GPIO_COD_RST_N;
    p_gpio <: tmp;
    
    /* Set power down bit in the CODEC over I2C */
    IIC_REGWRITE(CODEC_DEV_ID_ADDR, 0x01);
    
    /* Read CODEC device ID to make sure everything is OK */
    IIC_REGREAD(CODEC_DEV_ID_ADDR, data);
    
    codec_dev_id = data[0];
    if (((codec_dev_id & 0xF0) >> 4) != 0xC) 
    {
        printstr("Unexpected CODEC Device ID, expected 0xC, got ");
        printhex(codec_dev_id);
    }
    
    /* Now set all registers as we want them :    
    Mode Control Reg:
    Set FM[1:0] as 11. This sets Slave mode.
    Set MCLK_FREQ[2:0] as 010. This sets MCLK to 512Fs in Single, 256Fs in Double and 128Fs in Quad Speed Modes.
    This means 24.576MHz for 48k and 22.5792MHz for 44.1k.
    Set Popguard Transient Control.
    So, write 0x35. */
    IIC_REGWRITE(CODEC_MODE_CTRL_ADDR,    0x35);
    
    /* ADC & DAC Control Reg:
       Leave HPF for ADC inputs continuously running.
       Digital Loopback: OFF
       DAC Digital Interface Format: I2S
       ADC Digital Interface Format: I2S
       So, write 0x09. */
    IIC_REGWRITE(CODEC_ADC_DAC_CTRL_ADDR, 0x09);
    
    /* Transition Control Reg:
       No De-emphasis. Don't invert any channels. Independent vol controls. Soft Ramp and Zero Cross enabled.*/
    IIC_REGWRITE(CODEC_TRAN_CTRL_ADDR,    0x60);
    
    /* Mute Control Reg: Turn off AUTO_MUTE */
    IIC_REGWRITE(CODEC_MUTE_CTRL_ADDR,    0x00);
   
    /* DAC Chan A Volume Reg:
       We don't require vol control so write 0x00 (0dB) */
    IIC_REGWRITE(CODEC_DACA_VOL_ADDR,     0x00);
    
    /* DAC Chan B Volume Reg:
       We don't require vol control so write 0x00 (0dB)  */
    IIC_REGWRITE(CODEC_DACB_VOL_ADDR,     0x00);

    /* Clear power down bit in the CODEC over I2C */
    IIC_REGWRITE(CODEC_PWR_CTRL_ADDR, 0x00);
}
//:
