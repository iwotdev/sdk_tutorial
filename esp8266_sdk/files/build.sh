#!/bin/bash


[ "$XTENSA_TOOLS_ROOT" = "" ] && XTENSA_TOOLS_ROOT=$PWD/../sdk/xtensa-lx106-elf/bin/
[ "$SDK_PATH" = "" ] && SDK_PATH=$PWD/../sdk/esp-rtos-sdk-1.4

export PATH=$PATH:$XTENSA_TOOLS_ROOT 
export XTENSA_TOOLS_ROOT=$XTENSA_TOOLS_ROOT
export SDK_PATH=$SDK_PATH
export BIN_PATH=./bin


echo "gen_misc.sh version 20150911"
echo ""

if [ $SDK_PATH ]; then
    echo "SDK_PATH:"
    echo "$SDK_PATH"
    echo ""
else
    echo "ERROR: Please export SDK_PATH in gen_misc.sh firstly, exit!!!"
    exit
fi

if [ $BIN_PATH ]; then
    echo "BIN_PATH:"
    echo "$BIN_PATH"
    echo ""
else
    echo "ERROR: Please export BIN_PATH in gen_misc.sh firstly, exit!!!"
    exit
fi

# sh gen_misc.sh 
boot=new
app=0
spi_speed=40 
spi_mode=DIO 
spi_size_map=6

make clean	
make $1 BOOT=$boot APP=$app SPI_SPEED=$spi_speed SPI_MODE=$spi_mode SPI_SIZE_MAP=$spi_size_map 
