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
