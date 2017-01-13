.. contents::

iWoT Device SDK for C on ESP8266 入門教學
=========================================

iWoT Device SDK 協助開發者快速地將硬體裝置連接到 iWoT。該套件實作了完整的 iWoT 通訊協定，提供穩定與安全的連線機制，讓開發者專注在裝置端的硬體控制與商業邏輯，搭配 iWoT 雲端平台的強大功能，大幅降低開發物聯網應用的門檻。

申請帳號
--------

請先於 `iWoT <http://rc2.iwot.io>`_ 網頁申請帳號，並取得 `開發者金鑰 <http://rc2.iwot.io/#/web/sdks>`_ (在金鑰上按下滑鼠左鍵可複製到剪貼簿)。

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

開發環境為 Ubuntu 14.04 64 位元版本的 PC。


安裝相關程式庫與工具 :

::

    $ sudo apt-get update
    $ sudo apt-get upgrade
    $ sudo apt-get install git autoconf build-essential gperf bison flex texinfo libtool libncurses5-dev wget gawk libc6-dev-amd64 python-serial libexpat-dev gtkterm

首先在欲建立專案的路徑(~/espProjects)下，下載並建立 rtos 基本工具環境 ：

::

    $ cd ~ ; mkdir espProjects; cd espProjects
    $ wget https://raw.githubusercontent.com/iwotdev/sdk_tutorial/master/esp8266_sdk/files/esptools.tar.gz ; tar zxvf esptools.tar.gz


查看 esptools 目錄可以看到以下結構 ：

::

 esptools/
 ├── EspTools/            <- ESP tools
 ├── esp-rtos-sdk-1.4/    <- ESP RTOS SDK
 └── xtensa-lx106-elf/    <- Compile Tool Chain

( 以上建立 rtos 基本工具環境相關細節可參考 `ESP8266 wiki <https://github.com/esp8266/esp8266-wiki/wiki/Toolchain>`_。 )

下載並建立 iWoT SDK 基本工具環境 ：

::

    $ wget http://rc2.iwot.io:9107/sdk/iwot-c-sdk-for-esp8266-rtos.tar.gz ; tar zxvf iwot-c-sdk-for-esp8266-rtos.tar.gz

查看 libraries 目錄可以看到以下結構 :

::

 libraries/
 ├── iwot/
 ├── jsmn/
 └── paho_mqtt_client_embedded_c/

下載 project template 以建立專案 :

::

    $ wget https://raw.githubusercontent.com/iwotdev/sdk_tutorial/master/esp8266_sdk/files/project_template.tar.gz ; tar zxvf project_template.tar.gz

查看 project_template 目錄可以看到以下結構 ：

::

 project_template/
 ├── user/       <- 裝置端主程式
 ├── include/
 └── driver/


複製專案模板並更名為 led_switch 。

::

 $ cp -r project_template led_switch

此時應該可以正常編譯與建立此專案 :

::

 $ cd led_switch
 $ sh build.sh

 ...

 No boot needed.
 Generate eagle.flash.bin and eagle.irom0text.bin successully in BIN_PATH
 eagle.flash.bin-------->0x00000
 eagle.irom0text.bin---->0x20000
 !!!




程式碼說明
----------

我們的程式進入點在 user/user_main.c 裏面的函式 main_task。

::

 void main_task(void * pvParameters)
 {
   while (wait_for_network_on()) {

      while (1) {
        printf("%s \n","Hello World.");

        vTaskDelay(5000 / portTICK_RATE_MS);        
      } 
   } 
 }

以下我們準備
 - 將 NodeMCU 連上 wifi 。
 - 初始化 gpio 。
 - 引入 iWoT 。


裝置設定 
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

- NodeMCU 連網 (僅須做一次) ：

(如果你的 nodeMCU 曾經可以連上你的 wifi ap ，則可省略此動作。)
 
在專案目錄( led_switch )下開啟編輯裝置端主程式檔案( user_main.c ) ：

::

 $ vi user/user_main.c。


首先要先讓 NodeMCU 連上網路，以下必須將 your_wifi_ssid、your_wifi_password 換成使用者的環境設定

::

    void wifi_setup(){
        //Connect WIFI
        struct station_config *cfg = zalloc(sizeof(struct station_config));
        sprintf((char*)cfg->ssid, "your_wifi_ssid");
        sprintf((char*)cfg->password, "your_wifi_password");
        wifi_station_set_config(cfg);
        wifi_set_opmode(STATION_MODE);
        printf("[WiFi]Set wifi mode STATION_MODE");
    }

在主程式裡加上呼叫命令

::

 void main_task(void * pvParameters)
 {
   wifi_setup();                              // <--- add update wifi settings!

   while (wait_for_network_on()) {

      while (1) {
        printf("%s \n","Hello World.");

        vTaskDelay(5000 / portTICK_RATE_MS);        
      } 
   } 
 }

- 初始化 gpio 設定 ：

設定將要使用到的 GPIO 設定；這裡僅用到 D1 做輸出，其 pin 值為 5 ：

::

    #include "gpio.h"

    void gpio_init(){
        uint32 pin = 5; // D1 : GPIO 5
        gpio_pin_intr_state_set(pin, GPIO_PIN_INTR_DISABLE);
        uint16 gpio_pin_mask = BIT(pin); // GPIO_Pin_5;
        GPIO_AS_OUTPUT(gpio_pin_mask);  
    }

在主程式裡加上呼叫命令

::

 void main_task(void * pvParameters)
 {
   wifi_setup();                              // <--- add update wifi settings!
   gpio_init();                               // <--- add update gpio settings!

   while (wait_for_network_on()) {

      while (1) {
        printf("%s \n","Hello World.");

        vTaskDelay(5000 / portTICK_RATE_MS);        
      } 
   } 
 }


- 引入 iWoT SDK

::

    #include "iwot.h"

在 iwot.h 裏定義了 iWoT C Device SDK 的所有動作。

接下來基本流程如下 ：

- 準備 Web Thing Model
- 撰寫 action handler
- 初始化並建立連線

準備 Web Thing Model
~~~~~~~~~~~~~~~~~~~~

每一個 iWoT 裝置都會對應到一個 Web Thing Model。Model 內的 property / action / event 用來描述此裝置的能力；在裝置內部以及 iWoT cloud 規則引擎將依據 model 的描述做對應的處理。

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


以下轉為 C 語言字串格式 :

::

    char * modelJSON  = "{\"classID\":\"model_esp8266_led\",\"id\":\"esp_00001\",\"name\":\"ESP_Sample_Led\",\"actions\":{\"switch\":{\"values\":{\"ledState\":{\"type\":\"integer\"}}}}}";

我們定義此裝置類型的 classID 為 model_esp8266_led；定義此裝置的 id 為 esp\_00001；

並且具備以下能力：

 可以接受一個 actions -> switch，其包含 1 個整數型態的傳入值 ledState : 在本範例中我們用來指定 LED 的開關。

( 有關 Web Thing Model 的詳細說明請參閱另一份教學文件。 )

撰寫 actions handler
~~~~~~~~~~~~~~~~~~~~

我們在 model 中定義了 actions，而在裝置端還必須實作出 action handler 函式；

當外部呼叫此 action 時會交由對應的 action handler 處理。

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

在這裡因為所有的 actions 都交由同一個 action handler 處理，因此必須先判斷所觸發的 action 是哪一個。

 以範例中的 model 為例，判斷方式為比較 identifier 是否為 model 中定義的 "switch"。然後可以由 action 參數中取得參數 ledState (key) 與其傳入值：value.integer 。

最後回傳 return 0 通知 iWoT 該 action handler 已執行完畢。

初始化並建立連線
~~~~~~~~~~~~~~~~

上述的 model ( modelJSON )、和相關 handler 準備好之後就可以進行初始化並建立連線 ：

::

 THING *thing = 0; 

 int connect_iWoT()
 {
    char *host = "rc2.iwot.io";
    char *accessKey = "your_access_key";
    char *secretKey = "your_secret_key";

    IWOTCONFIG *iwotConfig = 0;
    IWOTERRORCODE ec = IWOT_EC_SUCCESS;
    char *modelJSON = "{\"classID\":\"model_esp8266_led\",\"id\":\"esp_00001\",\"name\":\"ESP_Sample_Led\",\"actions\":{\"switch \":{\"values\":{\"ledState\":{\"type\":\"integer\"}}}}}";

    if(IWOT_EC_SUCCESS != iwot_util_create_config(accessKey, secretKey, host,  0, modelJSON, 0, &iwotConfig)) {
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

首先建立一個全域指標變數 thing ，此為我們的 iWoT 客戶端。
 
再藉由 iwot_util_create_config 加入我們的設定產生 iwotConfig 用來作為初始化 iwot_thing_init 所需資訊 ：

 accessKey 跟 secretKey 請填入一開始準備開發環境時取得的 *開發者金鑰*。

 host 預設為 *rc2.iwot.io*，如果您使用的 iWoT 為私有雲或特殊客製化版本，請填入對應的 iWoT server 位址。

呼叫 iwot_thing_init 初始化成功之後，呼叫 iwot_thing_connect() 並傳入前一節準備的各個 handler 開始對 iWoT cloud 做連接的動作。

::

 void main_task(void * pvParameters)
 {
    // wifi_setup();                              // <--- add update wifi settings!
    gpio_init();                                // <--- add update gpio settings!

    while (wait_for_network_on()) {

        if (connect_iWoT()) {                   // <--- add connect to iWoT!

            while (1) {
                printf("%s \n","Hello World.");

                vTaskDelay(5000 / portTICK_RATE_MS);        
            } 
        }
    } 
 }


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
        char *host = "rc2.iwot.io";
        char *accessKey = "your_access_key";
        char *secretKey = "your_secret_key";

        IWOTERRORCODE ec = IWOT_EC_SUCCESS;
        char *modelJSON = "{\"classID\":\"model_esp8266_led\",\"id\":\"esp_00001\",\"name\":\"ESP_Sample_Led\",\"actions\":{\"switch\":{\"values\":{\"ledState\":{\"type\":\"integer\"}}}}}";

        if(IWOT_EC_SUCCESS != iwot_util_create_config(accessKey, secretKey, host,  0, modelJSON, 0, &iwotConfig)) {
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

    int wait_for_network_on() {
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

        return onLine;
    }

    void iwot_task(void * pvParameters)
    {
      wifi_setup();                               // <--- add update wifi settings!
      gpio_init();                                // <--- add update gpio settings!

      while (wait_for_network_on()) {

          if (connect_iWoT()) {                   // <--- add connect to iWoT!

            printf("%s \n","Hello World.");
            while (1) {

                vTaskDelay(5000 / portTICK_RATE_MS);        
            } 
        }
      } 
    }

    void gpio_init() {
        uint32 pin = 5; // D1 : GPIO 5
        gpio_pin_intr_state_set(pin, GPIO_PIN_INTR_DISABLE);
        uint16 gpio_pin_mask = BIT(pin); // GPIO_Pin_5;
        GPIO_AS_OUTPUT(gpio_pin_mask);
    }

    void wifi_setup() {
        //Connect WIFI
        struct station_config *cfg = zalloc(sizeof(struct station_config));
        sprintf((char*)cfg->ssid, "your_wifi_ssid");
        sprintf((char*)cfg->password, "your_wifi_password");
        wifi_station_set_config(cfg);
        wifi_set_opmode(STATION_MODE);
    }
    void user_init(void)
    {
        printf("SDK version:%s,%u\n", system_get_sdk_version(),__LINE__ );

        // Create main task.
        xTaskCreate(iwot_task, "IWOT_TASK", 2000, NULL, tskIDLE_PRIORITY + 2, NULL);
    }

    uint32 user_rf_cal_sector_set(void)
    {
        // or keep original code here.
        return 0;
    }

執行結果
--------

使用命令列編譯並燒錄至 ESP8266 執行
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

編譯指令執行 :

::

    $ sh build.sh

燒錄指令 (將利用 gtkterm 接收NodeMCU輸出結果，需要 sudo 權限) :

::

    $ sh burn.sh -a


|3|

與 iWoT Cloud 互動
~~~~~~~~~~~~~~~~~~

登入 `iWoT <http://rc2.iwot.io>`_，可以看到此裝置已上線

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

可以到 `此 <./files>`_ 下載專案相關檔案。



常見問題
--------

裝置程式沒有輸出 MQTT connected 訊息
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

請確認 wifi 連線正常。

請確認 modelJSON 字串內容是正確的；網路上的工具可以幫忙方便檢視，如 `Json Parser Online <http://json.parser.online.fr/>`_。

請核對 accessKey 及 secretKey 是否正確，並確認 host 指向正確位址。

編譯時期錯誤
~~~~~~~~~~~~

確認SDK的路徑已正確加入全域變數。

若發生檔案缺失: liblto\_plugin.so 或 liblto\_plugin.so.0時，請加入連結檔 :

::

    $ cd tutorial/sdk/xtensa-lx106-elf/libexec/gcc/xtensa-lx106-elf/4.8.5/
    $ ln -s liblto\_plugin.so.0.0.0 liblto\_plugin.so
    $ ln -s liblto\_plugin.so.0.0.0 liblto\_plugin.so.0


執行時期錯誤
~~~~~~~~~~~~

燒錄前可先確認裝置是否存在：

::

 $ ls /dev/ttyUSB0
 /dev/ttyUSB0

若發生程式crash在以下狀態

::

    SSL enabled.
    Fatal exception (3):
    epc1=0x4000df1b
    epc2=0x00000000
    epc3=0x4000dd2d
    epcvaddr=0x4026ca30
    depc=0x00000000
    rtn_add=0x400018bc

此現象為 SSL libraries issue. 請將 rtos sdk 中的 libssl.a (ssl library) 置換為 1.4.0版即可。可以到 `此 <./files>`_ 下載。置換路徑為

::

    tutorial/sdk/esp-rtos-sdk-1.4/lib


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
