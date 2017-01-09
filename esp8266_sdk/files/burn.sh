#!/bin/bash

[ "$PJFN" = "" ] && PJFN="esp8266_app" #"esp_iwot_t" # ProjectFolderName
[ "$PJBN" = "" ] && PJBN=".." # ProjectBaseName

[ "$PySCRIPTF" = "" ] && PySCRIPTF="./$PJBN/EspTools/script_smp"
[ "$IMGF" = "" ] && IMGF="./$PJBN/$PJFN/bin"
[ "$ROMN1" = "" ] && ROMN1="eagle.flash.bin"
[ "$ROMN2" = "" ] && ROMN2="eagle.irom0text.bin"

showHelp(){
	echo "\t== Usage Hint ========="
	echo "\tThis script burnning images to esp8266 by EspTools."
	echo "\tEspTools location (PySCRIPTF) = $PySCRIPTF"
	echo "\t"
	echo "\t== options ============"
	echo "\t -a, --app\tBurn application. Images folder (IMGF)=$IMGF, Image name (ROMN1)=$ROMN1, (ROMN2)=$ROMN2"
	echo "\t -f, --filesystem\tBurn file system(clean). Images folder (IMGF)=., Image name (ROMN1)=spiff_rom.bin"
	echo "\t -h, --help\tShow this hint."
	echo "\t"
}

burnApp(){
	res="failed" 
	while [  "$res" = "failed" ]; do
		#IMGF="./$PJBN/$PJFN/bin"
		#ROMN1="eagle.flash.bin"
		#ROMN2="eagle.irom0text.bin"

		# these images are applications.
		python $PySCRIPTF/esptool.py -p /dev/ttyUSB0 write_flash --flash_mode dio --flash_size 32m-c1 0x0 $IMGF/$ROMN1 0x20000 $IMGF/$ROMN2
		
		if [ "$?" = 0 ]; then
			echo "burn succeed!"
			sudo gtkterm --port /dev/ttyUSB0 --speed 115200
			res="succeed" 
		else
			echo "burn failed!"
			res="failed" 
		fi
   done
}
burnFS(){
	IMGF="."
	ROMN1="spiff_rom.bin"
	res="failed" 
	while [  "$res" = "failed" ]; do
	
		python $PySCRIPTF/esptool.py -p /dev/ttyUSB0 write_flash --flash_mode dio --flash_size 32m-c1 0x100000 $IMGF/$ROMN1
		if [ "$?" = 0 ]; then
			echo "burn succeed!"
			#sudo gtkterm --port /dev/ttyUSB0 --speed 115200
			res="succeed" 
		else
			echo "burn failed!"
			res="failed" 
		fi
   done
}

burnNewIWoT(){
	# ready yet
	res="failed" 
	while [  "$res" = "failed" ]; do
	
		python $PySCRIPTF/esptool.py -p /dev/ttyUSB0 write_flash --flash_mode dio --flash_size 32m-c1 0x0 $IMGF/$ROMN1 0xFE000 ./blank.bin 0xFF000 ./blank.bin 0x20000 $IMGF/$ROMN2 0x100000 ./spiff_rom.bin 0x3FC000 ./esp_init_data_default.bin 0x3FE000 ./blank.bin 0x3FF000 ./blank.bin
		if [ "$?" = 0 ]; then
			echo "burn succeed!"
			#sudo gtkterm --port /dev/ttyUSB0 --speed 115200
			res="succeed" 
		else
			echo "burn failed!"
			res="failed" 
		fi
   done
}


case "$1" in
	"--app" | "-a")	
		burnApp
	;;
	"--filesystem" | "-f")
		burnFS
	;;
	"--newiwot" | "-n")
		burnNewIWoT
	;;
	#"--help" | "-h")
	*)
		showHelp
	;;
esac
