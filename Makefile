
# The name of your project (used to name the compiled .hex file)
TARGET = main

# configurable options
OPTIONS = -DF_CPU=48000000 -DUSB_SERIAL -DLAYOUT_US_ENGLISH


#************************************************************************
# Location of Teensyduino utilities, Toolchain, and Arduino Libraries.
# To use this makefile without Arduino, copy the resources from these
# locations and edit the pathnames.  The rest of Arduino is not needed.
#************************************************************************

# This is what you should change.... 
ARDUINO_PATH = /home/jjrh/bin/arduino-1.0.3


TEENSY_PATH = $(ARDUINO_PATH)/hardware/teensy/cores/teensy3/

# path location for Teensy Loader, teensy_post_compile and teensy_reboot
TOOLSPATH = $(ARDUINO_PATH)/hardware/tools
#TOOLSPATH = ../../../tools/avr/bin   # on Mac or Windows

# path location for Arduino libraries (currently not used)
LIBRARYPATH = $(ARDUINO_PATH)/libraries

# path location for the arm-none-eabi compiler
COMPILERPATH = $(TOOLSPATH)/arm-none-eabi/bin

#************************************************************************
# Settings below this point usually do not need to be edited
#************************************************************************

# CPPFLAGS = compiler options for C and C++
CPPFLAGS = -Wall -g -Os -mcpu=cortex-m4 -mthumb -nostdlib -MMD $(OPTIONS) -I. -I$(TEENSY_PATH).

# compiler options for C++ only
CXXFLAGS = -std=gnu++0x -felide-constructors -fno-exceptions -fno-rtti

# compiler options for C only
CFLAGS =

# linker options
LDFLAGS = -Os -Wl,--gc-sections -mcpu=cortex-m4 -mthumb -T$(TEENSY_PATH)mk20dx128.ld

# additional libraries to link
LIBS = -lm


# names for the compiler programs
#CC = $(abspath $(COMPILERPATH))/arm-none-eabi-gcc
#CXX = $(abspath $(COMPILERPATH))/arm-none-eabi-g++
#OBJCOPY = $(abspath $(COMPILERPATH))/arm-none-eabi-objcopy
#SIZE = $(abspath $(COMPILERPATH))/arm-none-eabi-size

CC = $(COMPILERPATH)/arm-none-eabi-gcc
CXX = $(COMPILERPATH)/arm-none-eabi-g++
OBJCOPY = $(COMPILERPATH)/arm-none-eabi-objcopy
SIZE = $(COMPILERPATH)/arm-none-eabi-size

# our stuff that we will compile
LOCAL_CPP := $(wildcard *.cpp)
LOCAL_C := $(wildcard *.c)

#PWD = $(shell pwd)

# automatically create lists of the sources and objects
# TODO: this does not handle Arduino libraries yet...
C_FILES := $(wildcard $(TEENSY_PATH)*.c)$(wildcard *.c)
# C_FILES := $(wildcard *.c)
CPP_FILES := $(wildcard $(TEENSY_PATH)*.cpp)$(wildcard *.c)
# CPP_FILES := $(wildcard *.cpp)
OBJS := $(C_FILES:.c=.o) $(CPP_FILES:.cpp=.o) $(LOCAL_CPP:.cpp=.o) $(LOCAL_C:.c=o)

# the actual makefile rules (all .o files built by GNU make's default implicit rules)

all: $(TARGET).hex

$(TARGET).elf: $(OBJS) #mk20dx128.ld
	$(CC) $(LDFLAGS) -o $@ $(OBJS)

%.hex: %.elf
	$(SIZE) $<
	$(OBJCOPY) -O ihex -R .eeprom $< $@
	$(TOOLSPATH)/teensy_post_compile -file=$(basename $@) -path=$(shell pwd) -tools=$(TOOLSPATH)
	-$(TOOLSPATH)/teensy_reboot 


# compiler generated dependency info
-include $(OBJS:.o=.d)

clean:
#	rm -f $(TEENSY_PATH)*.o $(TEENSY_PATH)*.d $(TEENSY_PATH)$(TARGET).elf $(TEENSY_PATH)$(TARGET).hex
	rm -f *.o *.d $(TARGET).elf $(TARGET).hex


