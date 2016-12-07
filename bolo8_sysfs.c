/* ------------------------------------------------------------------------- *
 * bolo8_sysfs.c  D-TACQ ACQ400 FMC  DRIVER
 * Project: ACQ420_FMC
 * Created: 7 Dec 2016  			/ User: pgm
 * ------------------------------------------------------------------------- *
 *   Copyright (C) 2016 Peter Milne, D-TACQ Solutions Ltd         *
 *                      <peter dot milne at D hyphen TACQ dot com>           *
 *                                                                           *
 *  This program is free software; you can redistribute it and/or modify     *
 *  it under the terms of Version 2 of the GNU General Public License        *
 *  as published by the Free Software Foundation;                            *
 *                                                                           *
 *  This program is distributed in the hope that it will be useful,          *
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of           *
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the            *
 *  GNU General Public License for more details.                             *
 *                                                                           *
 *  You should have received a copy of the GNU General Public License        *
 *  along with this program; if not, write to the Free Software              *
 *  Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.                *
 *
 * TODO 
 * TODO
 * ------------------------------------------------------------------------- */

#include "acq400.h"
#include "bolo.h"

#include "acq400_sysfs.h"

static ssize_t show_offset_dacN(
	struct device * dev,
	struct device_attribute *attr,
	char * buf,
	const int ix)
{
	struct acq400_dev* adev = acq400_devices[dev->id];
	u32 offset_dac = bolo8_get_offset_dacN(adev, ix);
	return sprintf(buf, "0x%08x\n", offset_dac);
}

static ssize_t store_offset_dacN(
	struct device * dev,
	struct device_attribute *attr,
	const char * buf,
	size_t count,
	const int ix)
{
	struct acq400_dev* adev = acq400_devices[dev->id];
	int rc = count;
	int offset;

	if (sscanf(buf, "++%d", &offset) == 1){
		offset = adev->bolo8.offset_dacs[ix] + offset;
	}else if (sscanf(buf, "--%d", &offset) == 1){
		offset = adev->bolo8.offset_dacs[ix] - offset;
	}else if (sscanf(buf, "0x%x", &offset) == 1){
		;
	}else if (sscanf(buf, "%d", &offset) == 1){
		;
	}else{
		return -1;
	}

	bolo8_set_offset_dacN(adev, ix, adev->bolo8.offset_dacs[ix] = offset);

	return rc;
}


#define MAKE_OFFSET_DAC(IX)						\
static ssize_t show_offset_dac##IX(					\
	struct device * dev,						\
	struct device_attribute *attr,					\
	char * buf)							\
{									\
	return show_offset_dacN(dev, attr, buf, IX-1);			\
}									\
									\
static ssize_t store_offset_dac##IX(					\
	struct device * dev,						\
	struct device_attribute *attr,					\
	const char * buf,						\
	size_t count)							\
{									\
	return store_offset_dacN(dev, attr, buf, count, IX-1);		\
}									\
static DEVICE_ATTR(offset_dac##IX, S_IRUGO|S_IWUGO, 			\
		show_offset_dac##IX, store_offset_dac##IX)


MAKE_OFFSET_DAC(1);
MAKE_OFFSET_DAC(2);
MAKE_OFFSET_DAC(3);
MAKE_OFFSET_DAC(4);
MAKE_OFFSET_DAC(5);
MAKE_OFFSET_DAC(6);
MAKE_OFFSET_DAC(7);
MAKE_OFFSET_DAC(8);

extern struct device_attribute dev_attr_dacspi;
extern struct device_attribute dev_attr_dacreset;
extern struct device_attribute dev_attr_adc_sample_count;
extern struct device_attribute dev_attr_dac_sample_count;

MAKE_BITS(current_adc_enable, B8_CAD_CON, MAKE_BITS_FROM_MASK, B8_CAD_CON_ENABLE);
MAKE_BITS(offset_dac_enable, B8_ODA_CON, MAKE_BITS_FROM_MASK, B8_ODA_CON_ENABLE);
MAKE_BITS(bolo_dac_lowlat, B8_DAC_CON, MAKE_BITS_FROM_MASK, B8_DAC_CON_LL);
MAKE_BITS(bolo_dac_reset, B8_DAC_CON, MAKE_BITS_FROM_MASK, B8_DAC_CON_RST);
MAKE_BITS(bolo_dac_enable, B8_DAC_CON, MAKE_BITS_FROM_MASK, B8_DAC_CON_ENA);
MAKE_BITS(bolo_dac_data32, B8_DAC_CON, MAKE_BITS_FROM_MASK, B8_DAC_CON_DS32);
MAKE_BITS(bolo_dac_control, B8_DAC_CON, 0, 0x1ff);

const struct attribute *bolo8_attrs[] = {
	&dev_attr_current_adc_enable.attr,
	&dev_attr_offset_dac_enable.attr,
	&dev_attr_bolo_dac_lowlat.attr,
	&dev_attr_bolo_dac_data32.attr,
	&dev_attr_bolo_dac_reset.attr,
	&dev_attr_bolo_dac_enable.attr,
	&dev_attr_dacspi.attr,
	&dev_attr_dacreset.attr,
	&dev_attr_offset_dac1.attr,
	&dev_attr_offset_dac2.attr,
	&dev_attr_offset_dac3.attr,
	&dev_attr_offset_dac4.attr,
	&dev_attr_offset_dac5.attr,
	&dev_attr_offset_dac6.attr,
	&dev_attr_offset_dac7.attr,
	&dev_attr_offset_dac8.attr,
	&dev_attr_adc_sample_count.attr,
	&dev_attr_dac_sample_count.attr,
	NULL
};