.. contents::

iWoT Device SDK for C on ESP8266 入門教學
=========================================

iWoT Device SDK 協助開發者快速地將硬體裝置連接到 iWoT。該套件實作了完整的 iWoT 通訊協定，提供穩定與安全的連線機制，讓開發者專注在裝置端的硬體控制與商業邏輯，搭配 iWoT 雲端平台的強大功能，大幅降低開發物聯網應用的門檻。

硬體
----

本次操作硬體為 NodeMCU，這是一塊 ESP8266 的開發版，由 USB 提供電源並連接至 PC。

LED 傳感器一枚

杜邦線 x 2
|1|

電路示意圖
|2|

準備開發環境
------------

PC 開發環境為 Ubuntu 14.04 64位元版本。

請確認 PC 環境: `GCC <https://gcc.gnu.org/>`_ [GCC 4.8以上版本]、python [Python 2.7 or Python 3.4以上版本] ( Ubuntu 14 版預載的 Python 是 2.7.x 版 )

安裝GCC :

::

$ sudo apt-get update
$ sudo apt-get upgrade
$ sudo apt-get install build-essential

確認版本 :

::

$ gcc -v

安裝相關程式庫 :

::

$ sudo apt-get install git autoconf build-essential gperf bison flex texinfo libtool libncurses5-dev wget gawk libc6-dev-amd64 python-serial libexpat-dev

下載並建立 `Compile-Tool-Chain [xtensa-lx106-elf] <https://github.com/pfalcon/esp-open-sdk.git>`_

下載並建立 `esp rtos SDK [esp-rtos-sdk-1.4] <https://github.com/espressif/ESP8266_RTOS_SDK/tree/1.4.x>`_

下載並建立 `ESP image tool <https://github.com/espressif/esptool>`_

以上相關建立細節可參考 `ESP8266 wiki <https://github.com/esp8266/esp8266-wiki/wiki/Toolchain>`_。(或由 `此 <./files>`_ 下載已建立完成檔案)

(解壓命令提示: tar zxvf *FILENAME*.tar.gz)

建立目錄結構 tutorial 為我們這次的基礎目錄名稱

::

 tutorial/
 ├── EspTools/                <- Esp tool
 ├── sdk/esp-rtos-sdk-1.4/    <- Esp Rtos SDK
 └── sdk/xtensa-lx106-elf/    <- Tool Chain

安裝終端機工具 `gtkterm <http://gtkterm.feige.net/>`_

::

 $ sudo apt-get install gtkterm

建立專案資料夾 esp8266\_app

::

 tutorial/
 ├── esp8266_app/            <- 專案資料夾
 ├── EspTools/
 ├── sdk/esp-rtos-sdk-1.4/
 └── sdk/xtensa-lx106-elf/

由 RTOS SDK 中，複製 gpio interface 到專案資料夾 esp8266\_app 中

::

 $ cp –r tutorial/sdk/esp-rtos-sdk-1.4/examples/driver_lib/. tutorial/esp8266_app/

目錄結構如下

::

 esp8266_app/
 ├── include/
 └── driver/     <- gpio driver

由 RTOS SDK 中，複製 user 到 esp8266\_app

::

 $ cp –r tutorial/sdk/esp-rtos-sdk-1.4/examples/project_template/.
 tutorial/esp8266_app/

資料夾 user 應該包含 user\_main.c 與 Makefile。

資料夾 esp8266\_app 應該包含 gen\_misc.sh 與 Makefile。

主程式進入點裝置端程式為 tutorial/esp8266\_app/user/user\_main.c

建立目錄結構lib

::

 esp8266_app/
 ├── user/       <- 裝置端程式
 ├── lib/        <- 建立 Makefile 會用到的空目錄
 ├── include/
 └── driver/

下載並解壓縮 `iWoT C SDK <http://dev.iwot.io/#/web/sdks>`_。

下載並解壓縮 iWoT 需要的程式庫， `jsmn <https://github.com/zserge/jsmn`_ 和 `paho <https://eclipse.org/paho/clients/c/embedded/`_

並放置於 libraries/

(或由`此 <./files`_ 下載)

建立目錄結構

::

 esp8266_app/
 ├── iwot/          <- iWoT C SDK
 ├── libraries/     <- libraries for iWoT
 ├── libraries/jsmn
 ├── libraries/paho_mqtt_client_embedded_c
 ├── user/
 ├── lib/
 ├── include/
 └── driver/

將 iwot.h 由 esp8266\_app/iwot/ 複製一份到 esp8266\_app/include/ 。

設定 Makefile

替 user、iwot、libraries/jsmn、libraries/paho\_mqtt\_client\_embedded\_c 設定 Makefile

修改 iwot jsmn paho\_mqtt\_client\_embedded\_c 三者主要不同處為 LIB 處路徑名

以下為 iwot Makefile 完整檔案 :

::

	############################ Modify Block
	# name for the target project !
	LIB		= ../lib/libiwot.a
	# which modules (subdirectories) of the project to include in compiling
	MODULES		= .
	EXTRA_INCDIR	= . ../libraries/jsmn ../libraries/paho_mqtt_client_embedded_c
	# various paths from the SDK used in this project
	SDK_LIBDIR	= lib
	SDK_LDDIR	= ld
	############################

	# Directory the Makefile is in. Please don't include other Makefiles before this.
	THISDIR:=$(dir $(abspath $(lastword $(MAKEFILE_LIST))))
	#For FreeRTOS
	FREERTOS ?= yes
	# Output directors to store intermediate compiled files
	# relative to the project directory
	BUILD_BASE	= build
	# Base directory for the compiler. Needs a / at the end; if not set it'll use the tools that are in
	# the PATH.
	XTENSA_TOOLS_ROOT ?= 
	# Base directory of the ESP8266 FreeRTOS SDK package, absolute
	# Only used for the FreeRTOS build
	SDK_PATH	?= /opt/Espressif/ESP8266_RTOS_SDK

	# compiler flags using during compilation of source files
	CFLAGS		= -Os -ggdb -std=c99 -Werror -Wpointer-arith -Wundef -Wall -Wl,-EL -fno-inline-functions \
				-nostdlib -mlongcalls -mtext-section-literals  -D__ets__ -DICACHE_FLASH -mforce-l32 \
				-Wno-address -Wno-format-contains-nul -DESP8266 -Wno-unused -Wno-pointer-sign \
				-DFREERTOS -DLWIP_OPEN_SRC -ffunction-sections -fdata-sections \
				-DESP8266

	SDK_INCDIR	= include \
				include/freertos \
				include/espressif/esp8266 \
				include/espressif \
				extra_include \
				include/lwip \
				include/lwip/lwip \
				include/lwip/ipv4 \
				include/lwip/ipv6 \
					include/spiffs      

	SDK_INCDIR	:= $(addprefix -I$(SDK_PATH)/,$(SDK_INCDIR))

	TOOLPREFIX	=xtensa-lx106-elf-

	# select which tools to use as compiler, librarian and linker
	CC		:= $(XTENSA_TOOLS_ROOT)$(TOOLPREFIX)gcc
	AR		:= $(XTENSA_TOOLS_ROOT)$(TOOLPREFIX)ar
	LD		:= $(XTENSA_TOOLS_ROOT)$(TOOLPREFIX)gcc
	OBJCOPY	:= $(XTENSA_TOOLS_ROOT)$(TOOLPREFIX)objcopy

	####
	#### no user configurable options below here
	####
	SRC_DIR		:= $(MODULES)
	BUILD_DIR	:= $(addprefix $(BUILD_BASE)/,$(MODULES))

	SRC		:= $(foreach sdir,$(SRC_DIR),$(wildcard $(sdir)/*.c))
	OBJ		:= $(patsubst %.c,$(BUILD_BASE)/%.o,$(SRC))

	INCDIR	:= $(addprefix -I,$(SRC_DIR))
	EXTRA_INCDIR	:= $(addprefix -I,$(EXTRA_INCDIR))
	MODULE_INCDIR	:= $(addsuffix /include,$(INCDIR))

	V ?= $(VERBOSE)
	ifeq ("$(V)","1")
	Q :=
	vecho := @true
	else
	Q := @
	vecho := @echo
	endif

	vpath %.c $(SRC_DIR)

	define compile-objects
	$1/%.o: %.c
		$(vecho) "CC $$<"
		$(Q) $(CC) $(INCDIR) $(MODULE_INCDIR) $(EXTRA_INCDIR) $(SDK_INCDIR) $(CFLAGS)  -c $$< -o $$@
	endef

	.PHONY: all checkdirs clean 

	all: checkdirs $(LIB) 

	$(LIB): $(BUILD_DIR) $(OBJ)
		$(vecho) "AR $@"
		$(Q) $(AR) cru $@ $(OBJ)

	checkdirs: $(BUILD_DIR)

	$(BUILD_DIR):
		$(Q) mkdir -p $@

	clean:
		$(Q) rm -f $(LIB)
		$(Q) find $(BUILD_BASE) -type f | xargs rm -f
		$(Q) rm -rf $(FW_BASE)


	$(foreach bdir,$(BUILD_DIR),$(eval $(call compile-objects,$(bdir))))

以下為 jsmn Makefile 修改處

::

	############################ Modify Block
	# name for the target project !
	LIB		= ../../lib/libjsmn.a
	# which modules (subdirectories) of the project to include in compiling
	MODULES		= .
	EXTRA_INCDIR	= .  
	# various paths from the SDK used in this project
	SDK_LIBDIR	= lib
	SDK_LDDIR	= ld
	############################

以下為 paho\_mqtt\_client\_embedded\_c Makefile 修改處

::

	############################ Modify Block
	# name for the target project !
	LIB		= ../../lib/libpaho_mqtt_client.a
	# which modules (subdirectories) of the project to include in compiling
	MODULES		= .
	EXTRA_INCDIR	= .  
	# various paths from the SDK used in this project
	SDK_LIBDIR	= lib
	SDK_LDDIR	= ld
	############################

以下為 user Makefile 完整檔案

::

	#############################################################
	# Required variables for each makefile
	# Discard this section from all parent makefiles
	# Expected variables (with automatic defaults):
	#   CSRCS (all "C" files in the dir)
	#   SUBDIRS (all subdirs with a Makefile)
	#   GEN_LIBS - list of libs to be generated ()
	#   GEN_IMAGES - list of images to be generated ()
	#   COMPONENTS_xxx - a list of libs/objs in the form
	#     subdir/lib to be extracted and rolled up into
	#     a generated lib/image xxx.a ()
	#
	ifndef PDIR
	GEN_LIBS = libuser.a
	endif

	#############################################################
	# Configuration i.e. compile options etc.
	# Target specific stuff (defines etc.) goes in here!
	# Generally values applying to a tree are captured in the
	#   makefile at its root level - these are then overridden
	#   for a subtree within the makefile rooted therein
	#
	#DEFINES += 
	DEFINES += -DSPIFFS_HAL_CALLBACK_EXTRA=false -DSPIFFS_FILEHDL_OFFSET=true -DLOG_STR_CONST_ATTR="__attribute__((aligned(4))) __attribute__((section(\".irom.text\")))" -mforce-l32

	#############################################################
	# Recursion Magic - Don't touch this!!
	#
	# Each subtree potentially has an include directory
	#   corresponding to the common APIs applicable to modules
	#   rooted at that subtree. Accordingly, the INCLUDE PATH
	#   of a module can only contain the include directories up
	#   its parent path, and not its siblings
	#
	# Required for each makefile to inherit from the parent
	#

	INCLUDES := $(INCLUDES) -I $(PDIR)include
	INCLUDES += -I ./  -I ../iwot
	PDIR := ../$(PDIR)
	sinclude $(PDIR)Makefile

在 tutorial 專案資料夾下的 Makefile 需要將我們用到的模組設定加進去的地方有 lib/libjsmn.a、lib/libpaho\_mqtt\_client.a、lib/iwot.a、LINKFLAGS\_eagle.app.v6、DEPENDS\_eagle.app.v6。

::

	#############################################################
	# Required variables for each makefile
	# Discard this section from all parent makefiles
	# Expected variables (with automatic defaults):
	#   CSRCS (all "C" files in the dir)
	#   SUBDIRS (all subdirs with a Makefile)
	#   GEN_LIBS - list of libs to be generated ()
	#   GEN_IMAGES - list of object file images to be generated ()
	#   GEN_BINS - list of binaries to be generated ()
	#   COMPONENTS_xxx - a list of libs/objs in the form
	#     subdir/lib to be extracted and rolled up into
	#     a generated lib/image xxx.a ()
	#
	TARGET = eagle
	#FLAVOR = release
	FLAVOR = debug

	#EXTRA_CCFLAGS += -u

	ifndef PDIR # {
	GEN_IMAGES= eagle.app.v6.out
	GEN_BINS= eagle.app.v6.bin
	SPECIAL_MKTARGETS=$(APP_MKTARGETS)
	SUBDIRS=    \
		user    \
		driver  
		
	endif # } PDIR

	LDDIR = $(SDK_PATH)/ld

	CCFLAGS += -Os

	TARGET_LDFLAGS =		\
		-nostdlib		\
		-Wl,-EL \
		--longcalls \
		--text-section-literals \
		--force-l32

	ifeq ($(FLAVOR),debug)
		TARGET_LDFLAGS += -g -O2
	endif

	ifeq ($(FLAVOR),release)
		TARGET_LDFLAGS += -g -O0
	endif

	dummy: all

	lib/libjsmn.a: libraries/jsmn/Makefile 
		make -C libraries/jsmn FREERTOS=yes

	lib/libpaho_mqtt_client.a: libraries/paho_mqtt_client_embedded_c/Makefile 
		make -C libraries/paho_mqtt_client_embedded_c FREERTOS=yes

	lib/iwot.a: iwot/Makefile lib/libjsmn.a lib/libpaho_mqtt_client.a
		make -C iwot FREERTOS=yes


	COMPONENTS_eagle.app.v6 = \
		user/libuser.a  \
		driver/libdriver.a 
		
	LINKFLAGS_eagle.app.v6 = \
		-L$(SDK_PATH)/lib        \
		-Wl,--gc-sections   \
		-nostdlib	\
		-T$(LD_FILE)   \
		-Wl,--no-check-sections	\
		-u call_user_start	\
		-Wl,-static						\
		-Wl,--start-group					\
		-lcirom \
		-lcrypto	\
		-lespconn	\
		-lespnow	\
		-lfreertos	\
		-lgcc					\
		-lhal					\
		-ljson	\
		-llwip	\
		-lmain	\
		-lmesh	\
		-lmirom	\
		-lnet80211	\
		-lnopoll	\
		-lphy	\
		-lpp	\
		-lpwm	\
		-lsmartconfig	\
		-lspiffs	\
		-lssl	\
		-lwpa	\
		-lwps		\
		-L./lib \
		-ljsmn \
		-lpaho_mqtt_client \
		-liwot \
		$(DEP_LIBS_eagle.app.v6)					\
		-Wl,--end-group

	DEPENDS_eagle.app.v6 = \
					$(LD_FILE) \
					$(LDDIR)/eagle.rom.addr.v6.ld \
					lib/iwot.a         

	#############################################################
	# Configuration i.e. compile options etc.
	# Target specific stuff (defines etc.) goes in here!
	# Generally values applying to a tree are captured in the
	#   makefile at its root level - these are then overridden
	#   for a subtree within the makefile rooted therein
	#

	#UNIVERSAL_TARGET_DEFINES =		\

	# Other potential configuration flags include:
	#	-DTXRX_TXBUF_DEBUG
	#	-DTXRX_RXBUF_DEBUG
	#	-DWLAN_CONFIG_CCX
	CONFIGURATION_DEFINES =	-DICACHE_FLASH
	# CONFIGURATION_DEFINES =	-DICACHE_FLASH -U__STRICT_ANSI__

	# ifeq ($(SPI_SIZE_MAP), 2) 
	#   CONFIGURATION_DEFINES += -DESP01 
	# endif 

	DEFINES +=				\
		$(UNIVERSAL_TARGET_DEFINES)	\
		$(CONFIGURATION_DEFINES)

	DDEFINES +=				\
		$(UNIVERSAL_TARGET_DEFINES)	\
		$(CONFIGURATION_DEFINES)


	#############################################################
	# Recursion Magic - Don't touch this!!
	#
	# Each subtree potentially has an include directory
	#   corresponding to the common APIs applicable to modules
	#   rooted at that subtree. Accordingly, the INCLUDE PATH
	#   of a module can only contain the include directories up
	#   its parent path, and not its siblings
	#
	# Required for each makefile to inherit from the parent
	#

	INCLUDES := $(INCLUDES) -I $(PDIR)include
	sinclude $(SDK_PATH)/Makefile

	.PHONY: FORCE
	FORCE:

此處 RTOS SDK 的 sample 有提供一個可修改參數的 bash script gen\_misc.sh 可以利用來編譯與建立程式碼 (build code)，但要先將 SDK 的路徑加入全域變數。

::

	XTENSA_TOOLS_ROOT=”~/tutorial/sdk/xtensa-lx106-elf/bin/”    <- Your SDK location
	SDK_PATH=”~/tutorial/sdk/esp-rtos-sdk-1.4”                  <- Your SDK location
	export PATH=$PATH:$XTENSA_TOOLS_ROOT 
	export XTENSA_TOOLS_ROOT=$XTENSA_TOOLS_ROOT
	export SDK_PATH=$SDK_PATH

此時應該可以正常編譯與建立此專案。

(或由`此 <./files>`_ 下載)

程式碼說明
----------

設定 NodeMCU 連網
~~~~~~~~~~~~~~~~~

接下來開啟檔案 tutorial/esp8266\_app/user/user\_main.c。

首先要先讓 NodeMCU 連上網路，以下必須將 wifi\_ssid、wifi\_password 換成使用者的環境設定

::

	void wifi_setup(){
		//Connect WIFI
		struct station_config *cfg = zalloc(sizeof(struct station_config));
		sprintf((char*)cfg->ssid, "wifi_ssid");
		sprintf((char*)cfg->password, "wifi_password");
		wifi_station_set_config(cfg);
		wifi_set_opmode(STATION_MODE);
		printf("[WiFi]Set wifi mode STATION_MODE");
	}

並且先完成將要使用到的 GPIO 設定，這裡僅用到 D0 做輸出

::

    void gpio_init(){
    uint32 pin = 5; // D1 : GPIO 5
    gpio_pin_intr_state_set(pin, GPIO_PIN_INTR_DISABLE);
    uint16 gpio_pin_mask = BIT(pin); // GPIO_Pin_5;
    GPIO_AS_OUTPUT(gpio_pin_mask);  
    }


引入 iWoT SDK

::

    #include “iwot.h”;

接下來 iWoT Device SDK 的所有動作都定義在 iwot.h 來操作。基本流程如下

準備 Web Thing Model

撰寫 action handler

初始化並建立連線

準備 Web Thing Model
~~~~~~~~~~~~~~~~~~~~

每一個 iWoT 裝置都會對應到一個 Web Thing Model。Model 內的 property/action/event 用來描述此裝置的能力，裝置內部及 iWoT 規則引擎將依據 model 的描述做對應處理。

本範例裝置的 model 如下 (JSON 格式)：

::

    {
        "classID":"model_esp8266_led",
        "id":"esp_00001",
        "name":"ESP_Sample_Led",
        "actions":{
            "switch":{
                "values":{
                    "ledState":{
                        "type":"integer"
                    }
                }
            }
        }
    }


以下為 C 語言字串格式 :

::

    char * modelJSON  = "{\"classID\":\"model_esp8266_led\",\"id\":\"esp_00001\",\"name\":\"ESP_Sample_Led\",\"actions\":{\"switch\":{\"values\":{\"ledState\":{\"type\":\"integer\"}}}}}";

稍後我們將定義此裝置的 id 為 esp\_00001，並且具備以下能力：

可以接受一個 actions -> switch，包含 1 個整數型態的傳入值。在本範例中我們用來指定 LED 的開關。

有關 Web Thing Model 的詳細說明請參閱另一份教學文件。

實作接收來自 iWoT 的 actions 及點亮 LED
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

撰寫 actions handler
~~~~~~~~~~~~~~~~~~~~

在 model 中定義了 actions，我們還必須實作 action handler，當外部呼叫此
action 時會交由對應的 action handler 處理。

::

    int actionHandler(IWOTVAROBJECT *var)
    {
    IWOTVARGROUP **groups = var->groups;
    IWOTVARITEM **items;

    int s = 0;
    int i, j;
    
    for (i = 0; i < var->groupCount; i++, groups++) {  
        
        if(0 == strcmp((*groups)->identifier, "switch")) {
        items = (*groups)->items;  
        for (j = 0; j < (*groups)->itemCount; j++, items++) {
            if (0 == strcmp((*items)->key, "ledState")) {
            s = (*items)->value.integer;  
            printf("switch ledState to :%d \n",s);
            GPIO_OUTPUT(GPIO_Pin_5, s);
            } 
        }    
        }          
    }

    return 0;
    }

所有的 action 都交由同一個 action handler 處理，因此必須先判斷所觸發的 action 是哪一個。以範例中的 model 為例，判斷方式為 if(0 == strcmp((\*groups)->identifier, "switch")) {...}。收到後可以由 action 參數中取得參數 ledState (key) 與其傳入值：value.integer 。

最後回傳 return 0 通知 iWoT 該 action 已執行完畢。

初始化並建立連線
~~~~~~~~~~~~~~~~

上述的 model、和相關 handler 準備好之後就可以進行初始化並建立連線

::

    THING *thing = 0;
    IWOTCONFIG *iwotConfig = 0;

    char *host = "dev.iwot.io";
    char *accessKey = "your_access_key";
    char *secretKey = "your_secret_key";

    char * modelJSON  = "{\"classID\":\"model_esp8266_led\",\"id\":\"esp_00001\",\"name\":\"ESP_Sample_Led\",\"actions\":{\"switch\":{\"name\":\"LED Light Switch\",\"description\":\"Set esp8266 LED light on/off\",\"values\":{\"ledState\":{\"name\":\"LED State\",\"description\":\"LED state\",\"type\":\"integer\",\"minValue\":0,\"maxValue\":1}}}}}";

    if(IWOT_EC_SUCCESS != iwot_util_create_config(
            accessKey, secretKey, host,  0, 
            modelJSON, 0, &iwotConfig)){

        return 0;
    }    

    if(IWOT_EC_SUCCESS != iwot_thing_init(iwotConfig, &thing)) {    
        return 0;
    }

    if(IWOT_EC_SUCCESS != iwot_thing_connect(thing, actionHandler, 0, 0)) {
        iwot_thing_uninit(&thing);

        return 0;
    }

首先產生 iwotConfig 用來作為初始化所需資訊；accessKey 跟 secretKey 請填入一開始準備開發環境時取得的 *開發者金鑰*。host 預設為 *dev.iwot.io*，如果您使用的 iWoT 為私有雲或特殊客製化版本，請填入對應的 iWoT server 位址。

初始化成功之後呼叫 iwot\_thing\_connect() 並傳入前一節準備的 handler。

完整的 user\_main.c 程式碼
~~~~~~~~~~~~~~~~~~~~~~~~~~

::

	#include <stdio.h>
	#include "esp_common.h"
	#include "uart.h"
	#include "iwot.h"
	#include "gpio.h"


	THING *thing = 0;
	IWOTCONFIG *iwotConfig = 0;

	int actionHandler(IWOTVAROBJECT *var)
	{
	  IWOTVARGROUP **groups = var->groups;
	  IWOTVARITEM **items;

	  int s = 0;
	  int i, j;
	  
	  for (i = 0; i < var->groupCount; i++, groups++) {  
		
		if(0 == strcmp((*groups)->identifier, "switch")) {
		  items = (*groups)->items;  
		  for (j = 0; j < (*groups)->itemCount; j++, items++) {
			if (0 == strcmp((*items)->key, "ledState")) {
			  s = (*items)->value.integer;  
			  printf("switch ledState to :%d \n",s);
			  GPIO_OUTPUT(GPIO_Pin_5, s);
			} 
		  }    
		}          
	  }

	  return 0;
	}

	int connect_iWoT() 
	{
	  char *host = "dev.iwot.io"; 
	  char *accessKey = "your_access_key"; 
	  char *secretKey = "your_secret_key"; 

	  IWOTERRORCODE ec = IWOT_EC_SUCCESS;
	  char * modelJSON  = "{\"classID\":\"model_esp8266_led\",\"id\":\"esp_00001\",\"name\":\"ESP_Sample_Led\",\"actions\":{\"switch\":{\"values\":{\"ledState\":{\"type\":\"integer\"}}}}}";
	  
	  if(IWOT_EC_SUCCESS != iwot_util_create_config(
			accessKey, secretKey, host,  0, 
			modelJSON, 0, &iwotConfig)){

		return 0;
	  }    

	  if(IWOT_EC_SUCCESS != iwot_thing_init(iwotConfig, &thing)) {    

		return 0;
	  }

	  if(IWOT_EC_SUCCESS != iwot_thing_connect(thing, actionHandler, 0, 0)) {
		iwot_thing_uninit(&thing);

		return 0;
	  }
	  
	  return 1;
	}

	int wait_for_network_on(){
		int onLine = 0;  

		// Wait till connect
		STATION_STATUS sta_stat = STATION_CONNECTING;
		int count = 0;
		do {
			vTaskDelay(1000/portTICK_RATE_MS);
			sta_stat = wifi_station_get_connect_status();
			count++;
		} while(STATION_CONNECTING == sta_stat);
		if (STATION_GOT_IP == sta_stat) {
		  onLine = 1;
		}
		// printf("[WiFi][Done]Network status %d\n", sta_stat);
		return onLine;
	}

	void iwot_task(void * pvParameters)
	{
	  while (wait_for_network_on()) {
		printf("%s \n","MQTT connecting...");    
		if(connect_iWoT()) {
		  printf("%s \n","MQTT connected.");
		  while (1) {
			vTaskDelay(5000 / portTICK_RATE_MS);
		  } 
		} 
	  } 
	}

	void gpio_init(){
	  uint32 pin = 5; // D1 : GPIO 5
	  gpio_pin_intr_state_set(pin, GPIO_PIN_INTR_DISABLE);
	  uint16 gpio_pin_mask = BIT(pin); // GPIO_Pin_5;
	  GPIO_AS_OUTPUT(gpio_pin_mask);  
	}

	void wifi_setup(){
		//Connect WIFI
		struct station_config *cfg = zalloc(sizeof(struct station_config));
		sprintf((char*)cfg->ssid, "your_wifi_ssid"); //
		sprintf((char*)cfg->password, "your_wifi_password"); //
		wifi_station_set_config(cfg);
		wifi_set_opmode(STATION_MODE);
	}
	void user_init(void)
	{
		printf("SDK version:%s,%u\n", system_get_sdk_version(),__LINE__ );
		
		// Connect to internet.
		wifi_setup();
		// Init gpio.
		gpio_init();
		// GPIO_OUTPUT(GPIO_Pin_5, 1);

		// Create main task.
		xTaskCreate(iwot_task, "IWOT_TASK", 2000, NULL, tskIDLE_PRIORITY + 2, NULL);
	}

	uint32 user_rf_cal_sector_set(void)
	{
		return 0;
	}

執行結果
--------

使用命令列編譯並燒錄至esp8266執行
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

編譯指令 :

::

    $ cd tutorial/esp8266\_app/

為編譯命令腳本gen\_misc.sh加入環境變數 :

::

    XTENSA_TOOLS_ROOT=$PWD/../sdk/xtensa-lx106-elf/bin/
    SDK_PATH=$PWD/../sdk/esp-rtos-sdk-1.4

    export PATH=$PATH:$XTENSA_TOOLS_ROOT 
    export XTENSA_TOOLS_ROOT=$XTENSA_TOOLS_ROOT
    export SDK_PATH=$SDK_PATH
    export BIN_PATH=./bin

執行 :

::

    $ sh gen\_misc.sh

燒錄指令 :

::

    $ cd tutorial/

    $ python EspTools/script\_smp/esptool.py -p /dev/ttyUSB0 write\_flash --flash\_mode qio --flash\_size 32m-c1 0x0 esp8266\_app/bin/eagle.flash.bin 0x20000 esp8266\_app/bin/eagle.irom0text.bin

利用 gtkterm (需要用sudo)接收NodeMCU輸出結果如下：

::

    $ sudo gtkterm --port /dev/ttyUSB0 --speed 115200

|3|

與 iWoT Cloud 互動
~~~~~~~~~~~~~~~~~~

登入 `iWoT <https://dev.iwot.io>`_，可以看到此裝置已上線
|4|

以及我們 Actions 的設定
|5|

進入 Global Rule Engine
|6|

建立規則一 (esp8266)，測試 action :
|7|
|8|

分別按下 On/Off 的 inject 元件後，iWoT 會呼叫裝置的 actionHandler() 並傳入 switch 物件，其中 ledState參數值為 0 or 1。觀察裝置端的輸出。依照 actionHandler() 的實作，會顯示在 LED 的明暗上。
|9|
|10|

下載鏈結
--------

可以到以下 `鏈結 <https://justup.co/share.html?id=d036f824-3c22-431a-9e12-3a80b71a41e9>`_ 下載專案相關檔案。

RTOS SDK : esp8266\_rtos\_sdk\_1.4.x.tar.gz

Tool Chain : xtensa-lx106-elf.tar.gz

Burn Tool : EspTools.tar.gz

iWoT SDK : iwot.tar.gz

iWoT SDK dependency libraries : libraries.tar.gz

Sample project : esp8266\_app.tar.gz

Tutorial (Full with SDK and Tools): tutorial.tar.gz

常見問題
--------

裝置程式沒有輸出 MQTT connected 訊息
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

請確認wifi連線正常。

請確認modelJSON 字串內容是正確的；網路上的工具可以幫忙方便檢視，如 `Json Parser Online <http://json.parser.online.fr/>`_。

請核對 accessKey 及 secretKey 是否正確，並確認 host 指向正確位址。

編譯時期錯誤
~~~~~~~~~~~~

確認SDK的路徑已正確加入全域變數。

若發生檔案缺失: liblto\_plugin.so 或 liblto\_plugin.so.0時，請加入連結檔 :

::

    $ cd tutorial/sdk/xtensa-lx106-elf/libexec/gcc/xtensa-lx106-elf/4.8.5/
    $ ln -s liblto\_plugin.so.0.0.0 liblto\_plugin.so
    $ ln -s liblto\_plugin.so.0.0.0 liblto\_plugin.so.0

Global Rule Engine 的頁籤沒有顯示預期中的資料
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

請確認兩次連線間，是否更動過 modelJSON 字串內容。若已更動，可先在 Devices->ListView 裡將裝置刪除後，再次連線。

按下規則一的 inject 元件，裝置端沒有對應的輸出
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

確認規則的 iWoT\_Thing 元件已依照上述教學文件正確設定。

.. |1| image:: https://raw.githubusercontent.com/iwotdev/sdk_tutorial/master/esp8266_sdk/images/1.jpg
.. |2| image:: https://raw.githubusercontent.com/iwotdev/sdk_tutorial/master/esp8266_sdk/images/2.png
.. |3| image:: https://raw.githubusercontent.com/iwotdev/sdk_tutorial/master/esp8266_sdk/images/3.png
.. |4| image:: https://raw.githubusercontent.com/iwotdev/sdk_tutorial/master/esp8266_sdk/images/4.png
.. |5| image:: https://raw.githubusercontent.com/iwotdev/sdk_tutorial/master/esp8266_sdk/images/5.png
.. |6| image:: https://raw.githubusercontent.com/iwotdev/sdk_tutorial/master/esp8266_sdk/images/6.png
.. |7| image:: https://raw.githubusercontent.com/iwotdev/sdk_tutorial/master/esp8266_sdk/images/7.png
.. |8| image:: https://raw.githubusercontent.com/iwotdev/sdk_tutorial/master/esp8266_sdk/images/8.png
.. |9| image:: https://raw.githubusercontent.com/iwotdev/sdk_tutorial/master/esp8266_sdk/images/9.png
.. |10| image:: https://raw.githubusercontent.com/iwotdev/sdk_tutorial/master/esp8266_sdk/images/10.jpg
