iWoT Javascript Web Browser SDK 入門教學
========================================

iWoT Device SDK 協助開發者快速地將硬體裝置連接到 iWoT。該套件實作了完整的 iWoT 通訊協定，提供穩定與安全的連線機制，讓開發者專注在裝置端的硬體控制與商業邏輯，搭配 iWoT 雲端平台的強大功能，大幅降低開發物聯網應用的門檻。此範例使用 iWoT Web SDK 實作一個 Ball 網頁，說明如何透過 iWoT 和這個網頁互動。

準備開發環境
------------

1. 下載 `iWoT Web SDK <http://dev.iwot.io/#/web/sdks>`_
2. 取得 `開發者金鑰 <http://dev.iwot.io/#/web/sdks>`_ (在金鑰上按下滑鼠左鍵可複製到剪貼簿)
3. 建立目錄結構

::

    ball/
    ├── iwot/       <- iWoT Web SDK
    ├── ball.js     <- 網頁端程式
    └── ball.html   <- 網頁主畫面

程式碼說明
----------

首先在 ``ball.html`` 檔引入最新版的 iWoT Web SDK

::

    <script type="text/javascript" src="iwot/iwot.min.js"> </script>

並在 ``ball.js`` 裡建立實例

::

    var thing = new window.iWoT.iWoT.Thing();

接下來 iWoT Web SDK 的所有動作都會透過 ``thing`` 來操作。基本流程如下

1. 準備 Web Thing Model
2. 準備 SDK callback
3. 實作透過 UI 更新 property 至 iWoT
4. 實作透過 iWoT 來接收 action 改變 Ball 亮度
5. 初始化並建立連線

準備 Web Thing Model
~~~~~~~~~~~~~~~~~~~~

每一個 iWoT 裝置都會對應到一個 Web Thing Model，用來描述此裝置的能力。

本範例的 model 如下：

::

    var model = {
        "id": "iWoT_ball_1",
        "classID": "model_iWoT_ball",
        "name": "iWoT Ball",
        "properties": {
            "r": {
                "values": {
                    "r": {
                        "type": "integer",
                    }
                }
            },
            "g": {
                "values": {
                    "g": {
                        "type": "integer",
                    }
                }
            },
            "b": {
                "values": {
                    "b": {
                        "type": "integer",
                    }
                }
            }
        },
        "actions": {
            "brightness": {
                "values": {
                    "bright": {
                        "type": "number"
                    }
                }
            }
        }
    };

本網頁範例中的裝置：

-  具有三個 ``properties`` -> r / g / b，代表三種顏色，最大值為 255，最小值為 0。
-  可以接收一個 ``action`` -> brightness，包含一個傳入數值，代表亮度，最大值為 1，最小值為 0。

有關 Web Thing Model 的詳細說明請參閱另一份教學文件。

準備 SDK callback
~~~~~~~~~~~~~~~~~

::

    thing.on('close', function () {
        console.log('event: close');
    });

    thing.on('error', function () {
        console.log('event: error');
    });

    thing.on('offline', function () {
        console.log('event: offline');
    });

    thing.on('reconnect', function () {
        console.log('event: reconnect');
    });

    thing.on('connect', function () {
        console.log('event: connect');
    });

當連線狀態發生變化時，SDK 會觸發對應的 callback，裝置程式可以經由這些 callback 取得目前的連線狀態。 *網路斷線時 SDK 會自動嘗試重新建立連線，您不需要在 callback 中手動重建連線。*

確認收到 ``connect callback`` 之後就可開始與 iWoT 的訊息傳遞。

實作透過 UI 更新 property 至 iWoT
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

為了要透過 UI 控制 property R / G / B，必須先建置 ``ball.html``，撰寫 ``<div id="ball"></div>`` 來產生一個 2D 球形的 UI。

在操控 UI 方面則透過 input [ type = "range" ] 元素進行操控，並依照顏色設定最小值為 0，最大值為 255，間距為 1，且分別命名為不同的 id 方便操控，最後加上 ``onchange="changeColor(this.id)"`` 來觸發此元件的改變顏色事件，並在此函式中透過 ``thing.publishProperties(...)`` 傳遞數值至 iWoT。

::

    var input_r = document.getElementById('ctrl_r'),
        input_g = document.getElementById('ctrl_g'),
        input_b = document.getElementById('ctrl_b'),
        ball = document.getElementById('ball');

    function changeColor(id){
      switch(id){
        case "ctrl_r":
          R = input_r.value;
          document.getElementById('value_r').innerHTML = R;

          // send properties to iWoT
          thing.publishProperties({
              "r": {
                  "values": {
                      "r": R
                  }
              }
          });
          break;

        case "ctrl_g":
          G = input_g.value;
          document.getElementById('value_g').innerHTML = G;
          thing.publishProperties({
              "g": {
                  "values": {
                      "g": G
                  }
              }
          });
          break;

        case "ctrl_b":
          B = input_b.value;
          document.getElementById('value_b').innerHTML = B;
          thing.publishProperties({
              "b": {
                  "values": {
                      "b": B
                  }
              }
          });
          break;
      }

      ball.style.backgroundColor = 'rgb('+ R + ',' + G + ',' + B +')';
    }

實作透過 iWoT 來接收 action 改變亮度
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

要讓網頁接收從 iWoT 送出的訊息，需撰寫 action handler 進行後續的處理工作，本範例會針對此裝置的亮度進行調整，訊息方向由 iWoT 的規則引擎傳遞至本範例的裝置上。

::

    function actionHandler(action, done) {
        if(action.brightness !== undefined){
            Brightness = action.brightness.values.bright;
            document.getElementById('ball').style.filter = 'brightness(' + Brightness + ')';    
            document.getElementById('value_brightness').innerHTML = Brightness;
            done();
        }
    }

當外部呼叫 action 時，會交給 ``action handler`` 去處理。所有的 action 都交由同一個 ``action handler`` 處理，因此要判別觸發哪一個 action ，透過判別式 ``if(action.brightness !== undefined)`` 來確認是否為 ``brightness`` 的 action ，收到後可以取得傳入值： ``action.brightness.values.bright`` ，最後必須呼叫 ``done()`` 通知 iWoT 此 action 已執行完畢。

初始化並建立連線
~~~~~~~~~~~~~~~~

上述的 model、callback 和相關 handler 準備好之後就可以進行初始化並建立連線

::

    thing.init({
        model: JSON.parse(JSON.stringify(model)),
        accessKey: '[your_access_key]',
        secretKey: '[your_secret_key]',
        host: 'dev.iwot.io'
    }, function (err) {
        if (!err) {
            thing.connect({
                actionsHandler: actionHandler,
            });
        }
    });

``accessKey`` 跟 ``secretKey`` 請填入一開始準備開發環境時取得的 *開發者金鑰*。 ``host`` 預設為 *dev.iwot.io* ，如果您使用的 iWoT 為私有雲或特殊客製化版本，請填入對應的 iWoT server 位址。

初始化成功之後呼叫 ``thing.connect()`` 並傳入前一節準備的 action handler。

完整的 ball.html 程式碼
~~~~~~~~~~~~~~~~~~~~~~~

::

    <!DOCTYPE html>
    <html lang="zh-tw">
    <head>
        <meta charset="UTF-8">
        <title>iWoT Javascript Web Browser SDK Tutorial (with RGB ball UI)</title>
        <style>
            body{
              padding-top: 12px;
              padding-left: 12px;
              line-height: 1.5em;
            }
            input{
                display: inline-block;
                vertical-align: middle;
                width: 200px;
                height: 20px;
            }
            #ball{
                width: 80px;
                height: 80px;
                border-radius: 50%;
                background: rgb(0,0,0);
                filter: brightness(1);
                margin-bottom: 16px;
            }
        </style>
    </head>
    <body>
        <div id="ball"></div>
        <div class="control_panel">

            <div>Red</div>
            <input type="range" min="0" max="255" step="1" id="ctrl_r" value="0" onchange="changeColor(this.id)">
            <span id="value_r">0</span>

            <div>Green</div>
            <input type="range" min="0" max="255" step="1" id="ctrl_g" value="0" onchange="changeColor(this.id)">
            <span id="value_g">0</span>

            <div>Blue</div>
            <input type="range" min="0" max="255" step="1" id="ctrl_b" value="0" onchange="changeColor(this.id)">
            <span id="value_b">0</span>

            <div>
              <span>Brightness:</span>
              <span id="value_brightness">1</span>
            </div>

        </div>
        <script type="text/javascript" src="iwot/iwot.min.js"></script>
        <script type="text/javascript" src="ball.js"></script>
    </body>
    </html>

完整的 ball.js 程式碼
~~~~~~~~~~~~~~~~~~~~~

::

    var input_r = document.getElementById('ctrl_r'),
        input_g = document.getElementById('ctrl_g'),
        input_b = document.getElementById('ctrl_b'),
        ball = document.getElementById('ball');

    var R = 0,G = 0,B = 0,Brightness = 1;

    var thing = new window.IWoT.IWoT.Thing();

    var model = {
          "id": "iWoT_ball_1",
          "classID": "Module_iWoT_ball",
          "name": "iWoT Ball",
          "properties": {
            "r": {
                "values": {
                    "r": {
                        "type": "integer"
                    }
                }
            },
            "g": {
                "values": {
                    "g": {
                        "type": "integer"
                    }
                }
            },
            "b": {
                "values": {
                    "b": {
                        "type": "integer"
                    }
                }
            }
        },
        "actions": {
            "brightness": {
                "values": {
                    "bright": {
                        "type": "number"
                    }
                }
            }
        }
    };

    thing.on('close', function () {
        console.log('event: close');
    });

    thing.on('error', function () {
        console.log('event: error');
    });

    thing.on('offline', function () {
        console.log('event: offline');
    });

    thing.on('reconnect', function () {
        console.log('event: reconnect');
    });

    thing.on('connect', function () {
        console.log('event: connect');
    });

    thing.init({
        model: JSON.parse(JSON.stringify(model)),
        accessKey: '[your_access_key]',
        secretKey: '[your_secret_key]',
        host: 'dev.iwot.io'
    }, function (err) {
        if (!err) {
            thing.connect({
                 action: actionHandler
              });
        }
    });

    function actionHandler(action, done) {
      if(action.brightness !== undefined){
          Brightness = action.brightness.values.bright;
          ball.style.filter = 'brightness(' + Brightness + ')';  
          document.getElementById('value_brightness').innerHTML = Brightness;
          done();
        }
    }

    // change ball color and send properties to iWoT when UI has moved
    function changeColor(id){
      switch(id){
        case "ctrl_r":
          R = input_r.value;
          document.getElementById('value_r').innerHTML = R;
          thing.publishProperties({
              "r": {
                  "values": {
                      "r": R
                  }
              }
          });
          break;

        case "ctrl_g":
          G = input_g.value;
          document.getElementById('value_g').innerHTML = G;
          thing.publishProperties({
              "g": {
                  "values": {
                      "g": G
                  }
              }
          });
          break;

        case "ctrl_b":
          B = input_b.value;
          document.getElementById('value_b').innerHTML = B;
          thing.publishProperties({
              "b": {
                  "values": {
                      "b": B
                  }
              }
          });
          break;
      }

      ball.style.backgroundColor = 'rgb('+ R + ',' + G + ',' + B +')';
    }

執行結果
--------

運行本地端伺服器並開啟網頁
~~~~~~~~~~~~~~~~~~~~~~~~~~

本範例需透過本地端伺服器開啟 ``ball.html``，開啟網頁後如下圖所呈現的畫面：
|ball預設呈現畫面|

與 iWoT Cloud 互動
~~~~~~~~~~~~~~~~~~

登入 `iWoT <https://dev.iwot.io>`_，可以看到此裝置已上線
|裝置已連線|

進入 Global Rule Engine
|進入規則引擎|

建立規則一，設定裝置當 ``property r`` 有更新時就顯示在 debug 頁籤上。debug 頁籤在 Rule Engine 畫面右邊。規則若有任何調整，需按下部署按鈕，異動過的規則才會生效。
|建立規則一|

建立規則二，同規則一的操作方式，顯示 ``property g`` 值在 debug 頁籤上。
|建立規則二|

建立規則三，同規則一的操作方式，顯示 ``property b`` 值在 debug 頁籤上。
|建立規則三|

建立規則四，測試 ``action brightness``。
|建立規則四|

按下 inject 元件後，iWoT 呼叫 ``actionHandler()`` 並傳入 action 物件，其中 bright 參數值為 ``0.2``，並將球的亮度調整為此數值。

常見問題
--------

操控 Web UI 改變球的 r / g / b 顏色，debug tab 沒有顯示相對應數值
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

確認規則一至三是否已照上次教學文件正確設定。請注意，因為是 property changed 事件，必須選擇 Apply To one thing 並指定 iWoT\_Ball\_1。如正常輸出數值應呈現如下圖：
|輸出範本|

按下規則四中的 inject 元件，網頁上的球沒有呈現相對應的亮度變化
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

確認規則四的 iWoT\_Thing 元件已依照上述教學文件正確設定。

.. |ball預設呈現畫面| image:: https://raw.githubusercontent.com/iwotdev/sdk_tutorial/master/web_sdk/images/1.png
.. |裝置已連線| image:: https://raw.githubusercontent.com/iwotdev/sdk_tutorial/master/web_sdk/images/2.png
.. |進入規則引擎| image:: https://raw.githubusercontent.com/iwotdev/sdk_tutorial/master/web_sdk/images/3.png
.. |建立規則一| image:: https://raw.githubusercontent.com/iwotdev/sdk_tutorial/master/web_sdk/images/4.png
.. |建立規則二| image:: https://raw.githubusercontent.com/iwotdev/sdk_tutorial/master/web_sdk/images/5.png
.. |建立規則三| image:: https://raw.githubusercontent.com/iwotdev/sdk_tutorial/master/web_sdk/images/6.png
.. |建立規則四| image:: https://raw.githubusercontent.com/iwotdev/sdk_tutorial/master/web_sdk/images/7.png
.. |輸出範本| image:: https://raw.githubusercontent.com/iwotdev/sdk_tutorial/master/web_sdk/images/8.png

