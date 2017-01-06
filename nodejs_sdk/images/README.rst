################################
revue: getting Tumbleweed on it.
################################

iWoT Device SDK for Node.JS 入門教學
====================================

iWoT Device SDK 協助開發者快速地將硬體裝置連接到
iWoT。該套件實作了完整的 iWoT
通訊協定，提供穩定與安全的連線機制，讓開發者專注在裝置端的硬體控制與商業邏輯，搭配
iWoT 雲端平台的強大功能，大幅降低開發物聯網應用的門檻。 ## 準備開發環境
1. 安裝 `Node.JS <https://nodejs.org/en/download/>`__ 2. 下載並解壓縮
`iWoT Node.JS SDK <http://dev.iwot.io/#/web/sdks>`__ 3.
取得\ `開發者金鑰 <http://dev.iwot.io/#/web/sdks>`__
(在金鑰上按下滑鼠左鍵可複製到剪貼簿) 4. 建立目錄結構

::

    tutorial/
    ├── iwot/       <- iWoT Node.JS SDK
    └── index.js    <- 裝置端程式

程式碼說明
----------

首先引入 iWoT SDK 並創建裝置實例 (thing instance)

::

    var iWoT = require('./iwot').IWoT;
    var thing = new iWoT.Thing();

接下來 iWoT Device SDK 的所有動作都會透過 ``thing`` 來操作。基本流程如下

1. 準備 Web Thing Model
2. 準備 SDK callback
3. 實作發送 event 及更新 property 至 iWoT
4. 撰寫 action/properties handler
5. 初始化並建立連線

準備 Web Thing Model
~~~~~~~~~~~~~~~~~~~~

| 每一個 iWoT 裝置都會對應到一個 Web Thing Model。Model 內的
  property/action/event 用來描述此裝置的能力，裝置內部及 iWoT
  規則引擎將依據 model 的描述做對應處理。
| 本範例裝置的 model 如下：

::

    var model = {
        "id": "iwot_thing_1",
        "name": "iWoT_Thing",
        "properties": {
          "property1": {
            "values": {
              "b": {
                "type": "boolean"
              }
            }
          }
        },
        "actions": {
          "action1": {
            "values": {
              "s": {
                "type": "string"
              }
            }
          }
        },
        "events": {
          "event1": {
            "values": {
              "n": {
                "type": "integer"
              }
            }
          }
        }
    };

其中定義了此裝置的 id 為 ``iwot_thing_1``\ ，並且具備以下能力：

-  擁有一個 property ->
   ``property1``\ ，裡面有一個布林型態的值。Property
   通常代表裝置的狀態，在本範例中我們宣告了一個變數用來對應這個
   property：

   ::

       var property_b = false;

-  可以接受一個 action -> ``action1``\ ，包含一個字串型態的傳入值
-  具有發出一個 event -> ``event1`` 的能力，附帶一個整數值

有關 Web Thing Model 的詳細說明請參閱另一份教學文件。 ### 準備 SDK
callback


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
        ...
    });

當連線狀態發生變化時，SDK 會觸發對應的 callback，裝置程式可以經由這些
callback 取得目前的連線狀態。\ *網路斷線時 SDK
會自動嘗試重新建立連線，您不需要在 callback 中手動重建連線。* ###
實作發送 event 及更新 property 至 iWoT 在收到 ``connect`` callback
之後就可以開始與 iWoT 的訊息傳遞。本範例將發送 event 及更新 property
直接實作在 ``connect`` callback 中：

::

    thing.on('connect', function () {
        console.log('event: connect');

        // 發送 event
        var n = 0;
        setInterval(function() {
            var val = {
                "event1": {
                    "values": {
                        "n": n++
                    }
                }
            };
            console.log('emit events -> ' + JSON.stringify(val));
            thing.emitEvent(val);
        }, 3000);

        // 更新 property
        setInterval(function() {
            property_b = !property_b;
            var delta = {
                "property1": {
                    "values": {
                        "b": property_b
                    }
                }
            };
            console.log('update property -> ' + JSON.stringify(delta));
            thing.publishProperties(delta);
        }, 6000);
    });

event 的訊息傳遞方向為裝置端到 iWoT。上述程式碼在連線後每 3 秒鐘發送一個
event 到 iWoT

::

    thing.emitEvent(val);

其中 val 參數為 event 內容，這個 event 必須包含在此裝置的 model
當中，以這個範例來講就是\ **帶有一個整數值的 ``event1``**\ 。
同時我們將這個整數值依次遞增以便觀察 event 的變化。

property 的訊息傳遞方向是雙向的，可能會由外部觸發，經由 iWoT shadow
device 設定裝置端的 property；或是裝置內部更新完之後發出 property
changed 通知 iWoT shadow device。上述程式碼實作了後者，每 6 秒鐘改變一次
``property_b`` 並更新到 iWoT shadow device 上

::

    thing.publishProperties(delta);

其中 delta 參數為 property 內容，同樣的，這個 property
必須包含在此裝置的 model 當中。如果有多個 property，delta
可以只包含其中一個或部分 property。 ### 撰寫 action/properties handler
如果 model 中定義了 action，我們還必須實作 action handler，當外部呼叫此
action 時會交由對應的 action handler 處理。

::

    function actionHandler(action, done) {
        if (action.action1 !== undefined) {
            console.log("received action -> " + JSON.stringify(action));
            done();
        }
    }

| 所有的 action 都交由同一個 action handler 處理，因此必須先判斷所觸發的
  action 是哪一個。以範例中的 model 為例，判斷方式為
  ``if (action.action1 !== undefined) {...}``\ 。收到後可以由 action
  參數中取得傳入值：\ ``action.action1.values.s``\ 。
| 最後呼叫 ``done()`` 通知 iWoT 該 action 已執行完畢。\ *請注意，若
  handler 內有其他非同步函式呼叫，必須將 ``done()`` 置於該非同步函式的
  callback 當中，以確認當呼叫 ``done()`` 時所有動作都已執行完畢。*

前一節提到 property 訊息傳遞方向是雙向的，如果有來自裝置外部要求設定
property 的需求，則必須實作 properties handler。

::

    function propertiesHandler(property, done) {
        if (property.property1 !== undefined) {
            property_b = property.property1.values.b;
            console.log("property changed -> " + JSON.stringify(property));
            done();
        }
    }

| 同樣的，所有設定 property 的要求都交由同一個 handler
  處理，因此必須先判斷要設定的 property
  是哪一個：\ ``if (property.property1 !== undefined) {...}``\ 。設定值可以由
  ``property.property1.values.b`` 取得。
| 最後也必須呼叫 ``done()`` 通知 iWoT 該 property 已設定完畢。 ###
  初始化並建立連線 上述的 model、callback 和相關 handler
  準備好之後就可以進行初始化並建立連線

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
                propertiesHandler: propertiesHandler
            });
        }
    });

| ``accessKey`` 跟 ``secretKey``
  請填入一開始準備開發環境時取得的\ *開發者金鑰*\ 。\ ``host`` 預設為
  *dev.iwot.io*\ ，如果您使用的 iWoT
  為私有雲或特殊客製化版本，請填入對應的 iWoT server 位址。
| 初始化成功之後呼叫 ``thing.connect()`` 並傳入前一節準備的 handler。
  ### 完整的 index.js 程式碼

::

    var iWoT = require('./iwot').IWoT;
    var thing = new iWoT.Thing();

    // web thing model of this device
    var model = {
        "id": "iwot_thing_1",
        "name": "iWoT_Thing",
        "properties": {
          "property1": {
            "values": {
              "b": {
                "type": "boolean"
              }
            }
          }
        },
        "actions": {
          "action1": {
            "values": {
              "s": {
                "type": "string"
              }
            }
          }
        },
        "events": {
          "event1": {
            "values": {
              "n": {
                "type": "integer"
              }
            }
          }
        }
    };

    // property of this device
    var property_b = false;

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
        // always emit events or update properties after connected
        console.log('event: connect');

        // emit events
        var n = 0;
        setInterval(function() {
            var val = {
                "event1": {
                    "values": {
                        "n": n++
                    }
                }
            };
            console.log('emit events -> ' + JSON.stringify(val));
            thing.emitEvent(val);
        }, 3000);

        // update property
        setInterval(function() {
            property_b = !property_b;
            var delta = {
                "property1": {
                    "values": {
                        "b": property_b
                    }
                }
            };
            console.log('update property -> ' + JSON.stringify(delta));
            thing.publishProperties(delta);
        }, 6000);
    });

    function actionHandler(action, done) {
        if (action.action1 !== undefined) {
            // received action request
            console.log("received action -> " + JSON.stringify(action));
            done();
        }
    }

    function propertiesHandler(property, done) {
        if (property.property1 !== undefined) {
            // received property change request from outside of thing (device shadow),
            // update thing property accordingly
            property_b = property.property1.values.b;
            console.log("property changed -> " + JSON.stringify(property));
            done();
        }
    }

    thing.init({
        model: JSON.parse(JSON.stringify(model)),
        accessKey: '[your_access_key]',
        secretKey: '[your_secret_key]',
        host: 'dev.iwot.io'
    }, function (err) {
        if (!err) {
            thing.connect({
                actionsHandler: actionHandler,
                propertiesHandler: propertiesHandler
            });
        }
    });

執行結果
--------

使用 Node.JS 命令列執行
~~~~~~~~~~~~~~~~~~~~~~~

本範例可在 Windows、Linux 等支援 Node.JS
的環境中執行。執行指令及輸出結果如下：

::

    >node index.js
    event: connect
    emit events -> {"event1":{"values":{"n":0}}}
    update property -> {"property1":{"values":{"b":true}}}
    emit events -> {"event1":{"values":{"n":1}}}
    emit events -> {"event1":{"values":{"n":2}}}
    update property -> {"property1":{"values":{"b":false}}}
    emit events -> {"event1":{"values":{"n":3}}}
    emit events -> {"event1":{"values":{"n":4}}}
    update property -> {"property1":{"values":{"b":true}}}

與 iWoT Cloud 互動
~~~~~~~~~~~~~~~~~~

| 登入 `iWoT <https://dev.iwot.io>`__\ ，可以看到此裝置已上線
| |裝置已連線|

| 進入 Global Rule Engine
| |進入規則引擎|

| 建立規則一，這個規則將來自裝置的 event1 參數顯示在右方的 debug 頁籤中
| |建立規則一|

| 建立規則二，這個規則的作用是收到來自裝置的 property1
  更新訊息時，將內容顯示在 debug 頁籤中
| |建立規則二|

裝置端每 3 秒及 6 秒會分別送出 event1 及 property1 更新訊息，因此 Global
Rule Engine 將顯示以下訊息

::

    2016/12/19 下午1:33:274cd1f7b6.ea5e58
    msg.payload : number
    0
    2016/12/19 下午1:33:304cd1f7b6.ea5e58
    msg.payload : number
    1
    2016/12/19 下午1:33:3086887d28.0ec3a
    msg.payload : boolean
    true
    2016/12/19 下午1:33:334cd1f7b6.ea5e58
    msg.payload : number
    2
    2016/12/19 下午1:33:3686887d28.0ec3a
    msg.payload : boolean
    false
    2016/12/19 下午1:33:364cd1f7b6.ea5e58
    msg.payload : number
    3
    2016/12/19 下午1:33:394cd1f7b6.ea5e58
    msg.payload : number
    4

| 接著建立規則三，測試 action handler
| |建立規則三|
| 按下 ``test string`` 的 inject 元件後，iWoT 會呼叫裝置的
  ``actionHandler()`` 並傳入 action1 物件，其中 s 參數值為
  ``test string``\ 。觀察裝置端的輸出。依照 ``actionHandler()``
  的實作，會顯示 ``console.log()`` 訊息

::

    received action -> {"action1":{"values":{"s":"test string"}}}

| 建立規則四，測試設定 property
| |建立規則四|
| 按下 ``true`` 的 inject 元件後，iWoT 呼叫 ``propertiesHandler()``
  並傳入 property1 物件，其中 b 參數值為 ``true``\ 。裝置端輸出為

::

    property changed -> {"property1":{"values":{"b":true}}}


常見問題
--------


裝置程式沒有輸出 ``event: connect`` 訊息
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
