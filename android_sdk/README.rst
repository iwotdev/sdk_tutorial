.. contents::

iWoT Device SDK for Android 入門教學
====================================

iWoT Device SDK 協助開發者快速地將硬體裝置連接到 iWoT。該套件實作了完整的 iWoT 通訊協定，提供穩定與安全的連線機制，讓開發者專注在裝置端的硬體控制與商業邏輯，搭配 iWoT 雲端平台的強大功能，大幅降低開發物聯網應用的門檻。

本教學範例示範如何建立一個 Android 的 iWoT 裝置，此裝置會將 Accelerometer 的數值傳遞給 iWoT Cloud 並從 iWoT Cloud 接收相關的參數設定並反應在裝置上。

準備開發環境
------------

1. 安裝 `Android Studio <https://developer.android.com/studio/index.html>`_
2. 下載 `iWoT Android SDK <http://rc2.iwot.io/#/web/sdks>`_
3. 取得 `開發者金鑰 <http://rc2.iwot.io/#/web/sdks>`_
4. 建立一個顯示 Accelerometer 數值的專案。流程如下

首先建立一個 Android Studio 的新專案。在這個示範，我們使用的是 Android Studio 2.2.3 的版本。請選擇 Start a new Android Studio project。

|建立專案畫面一|

接著，在 Application Name 及 Company Domain 填上適當的名稱，然後按下 Next。

|建立專案畫面二|

Target Android Devices 的部份，我們選擇 Phone and Tablet，而 Minimum SDK 請使用 API 19 以上的選項，然後按下 Next。

|建立專案畫面三|

然後選擇 Empty Activity，按下 Next。

|建立專案畫面四|

最後，接受預設值，按下 Finish，就完成了這個新專案的建立。

|建立專案畫面五|

有了專案之後，接著我們就要把 iWoT Android SDK 加入此專案中。首先把下載回來的 SDK(iwot-sdk.aar) 複製一份到專案目錄的 app/libs/ 下。然後從上層選單選擇 File -> New -> New Module 開啟對話框，然後選擇 Import .JAR/.AAR Package，按下Next。

|Import Library一|

接著按下 ... 選擇上一步所複製進專案目錄的 SDK，按下 OK，就可以將 SDK 匯入到專案中了，最後按下Next，回到主畫面。

|Import Library二|

這時候，Android Studio 會提示說 Gradle files 已經改變了，需要做 Sync。所以按下 Sync Now，或是工具列的 Sync Project with Gradle Files 也可以。

|Import Library三|

Sync 完成後，就可以看到專案裡出現了 iwot-sdk 這個新的 module。

|Import Library四|

最後設定 App 的 Dependencies，此時就可以開始使用 SDK 所提供的 API 了。

|Import Library五|

接著開始修改 Layout 檔，預設為 activity\_main.xml，加入 3 個 TextView 分別來顯示 Accelerometer 的 XYZ 值，並用 1 個 Switch 來暫停或重啟 Accelerometer 數值的顯示

::

    <LinearLayout xmlns:android="http://schemas.android.com/apk/res/android"
        xmlns:tools="http://schemas.android.com/tools" android:layout_width="match_parent"
        android:layout_height="match_parent" android:paddingLeft="@dimen/activity_horizontal_margin"
        android:paddingRight="@dimen/activity_horizontal_margin"
        android:paddingTop="@dimen/activity_vertical_margin"
        android:orientation="vertical"
        android:paddingBottom="@dimen/activity_vertical_margin" tools:context=".MainActivity">

        <LinearLayout
            android:layout_width="match_parent"
            android:layout_height="wrap_content"
            android:orientation="horizontal" >

            <TextView
                android:layout_width="wrap_content"
                android:layout_height="wrap_content"
                android:text = "Paused" />

            <Switch
                android:id="@+id/paused"
                android:layout_width="wrap_content"
                android:layout_height="wrap_content"/>

        </LinearLayout>

        <TextView
            android:id="@+id/tv_x"
            android:layout_width="wrap_content"
            android:layout_height="wrap_content"
            android:layout_marginTop="10dp"
            android:text="X:"
            android:textSize="30sp"
            android:textStyle="bold" />

        <TextView
            android:id="@+id/tv_y"
            android:layout_width="wrap_content"
            android:layout_height="wrap_content"
            android:layout_marginTop="10dp"
            android:text="Y:"
            android:textSize="30sp"
            android:textStyle="bold" />

        <TextView
            android:id="@+id/tv_z"
            android:layout_width="wrap_content"
            android:layout_height="wrap_content"
            android:layout_marginTop="10dp"
            android:text="Z:"
            android:textSize="30sp"
            android:textStyle="bold" />

    </LinearLayout>

接下來，修改 MainActivity 類別，預設為 MainActivity.java，實作 SensorEventListener 以取得 Accelerometer 的數值並顯示於畫面中

::

    public class MainActivity extends AppCompatActivity implements SensorEventListener {

        private Switch s_paused;
        private boolean paused = false;
        private TextView tv_x;
        private TextView tv_y;
        private TextView tv_z;
        private SensorManager sManager;
        private Sensor mSensorOrientation;

        @Override
        protected void onCreate(Bundle savedInstanceState) {
            super.onCreate(savedInstanceState);
            setContentView(R.layout.activity_main);

            sManager = (SensorManager) getSystemService(SENSOR_SERVICE);
            mSensorOrientation = sManager.getDefaultSensor(Sensor.TYPE_ORIENTATION);
            sManager.registerListener(this, mSensorOrientation, SensorManager.SENSOR_DELAY_UI);

            tv_x = (TextView) findViewById(R.id.tv_x);
            tv_y = (TextView) findViewById(R.id.tv_y);
            tv_z = (TextView) findViewById(R.id.tv_z);

            s_paused = (Switch) findViewById(R.id.paused);
            s_paused.setOnCheckedChangeListener(new CompoundButton.OnCheckedChangeListener() {
                @Override
                public void onCheckedChanged(CompoundButton buttonView, boolean isChecked) {
                    paused = isChecked;
                }
            });        
        }

        @Override
        public void onSensorChanged(SensorEvent event) {
            if (!paused) {
                float x = event.values[1];
                float y = event.values[2];
                float z = event.values[0];

                tv_x.setText("X: " + x);
                tv_y.setText("Y: " + y);
                tv_z.setText("Z: " + z);
            }
        }

        @Override
        public void onAccuracyChanged(Sensor sensor, int accuracy) {

        }
    }

至此，我們已完成一個可以讀取並顯示 Accelerometer 的數值的 App。下一節，我們將描述如何使用 iWoT SDK 來與 iWoT Cloud 連線

程式碼說明
------------

首先，在 MainActivity 新增以下三個 member variables

::

    private Thing thing = null;
    private boolean connected = false;
    private int precision = 100;

| ``thing`` 是表示用 iWoT SDK 所創建的裝置實例 (thing instance)
| ``connected`` 是表示此裝置與 iWoT Cloud 的連線狀態
| ``precision`` 是表示 Accelerometer 數值的精準度，我們之後會從 iWoT Cloud 來操作他

接下來 iWoT Device SDK 的所有動作都會透過 ``thing`` 來操作。基本流程如下

1. 準備 Web Thing Model
2. 準備 SDK callback
3. 實作發送 event 及更新 property 至 iWoT
4. 撰寫 action/properties handler
5. 初始化並建立連線

準備 Web Thing Model
~~~~~~~~~~~~~~~~~~~~

每一個 iWoT 裝置都會對應到一個 Web Thing Model。Model 內的 property/action/event 用來描述此裝置的能力，裝置內部及 iWoT 規則引擎將依據 model 的描述做對應處理。

本範例裝置的 model 如下：

::

    {
        "id": "iwot_android_thing_1",
        "classID": "iwot_android_thing_model",
        "name": "iWoT Android Thing",
        "properties": {
          "pause": {
            "name": "Pause or Resume Sensors",
            "values": {
              "paused": {
                "type": "boolean"
              }
            }
          }
        },
        "actions": {
          "precision": {
            "name": "Set Precision",
            "values": {
              "decimal": {
                "description": "decimal places",
                "type": "integer",
                "minValue": 0,
                "maxValue": 5,
                "required": true
              }
            }
          }
        },
        "events": {
          "orientation": {
            "name": "Orientation Sensor",
            "values": {
              "x": {
                "type": "float"
              },
              "y": {
                "type": "float"
              },
              "z": {
                "type": "float"
              }
            }
          }
        }
      }

其中定義了此裝置的 id 為 ``iwot_android_thing_1``，並且具備以下能力：

-  擁有一個 property -> ``pause``，裡面有一個布林型態的值。Property 通常代表裝置的狀態，在本範例中我們宣告了一個變數用來對應這個 property：

::

    private boolean paused = false;

-  可以接受一個 action -> ``precision``，包含一個整數型態的傳入值
-  具有發出一個 event -> ``orientation`` 的能力，附帶三個浮點數值

有關 Web Thing Model 的詳細說明請參閱另一份教學文件。

準備 SDK callback
~~~~~~~~~~~~~~~~~

::

    new Thing.IThingListener() {
        @Override
        public void onConnect() {
            Log.v("[iWoT]", "onConnect");
            connected = true;
        }

        @Override
        public void onReconnect() {
            Log.v("[iWoT]", "onReconnect");
        }

        @Override
        public void onOffline() {
            Log.v("[iWoT]", "onOffline");
            connected = false;
        }

        @Override
        public void onClose() {
            Log.v("[iWoT]", "onClose");
            connected = false;
        }

        @Override
        public boolean onActions(Model.VarObject var) {
            Log.v("iWoT", "onActions");
            return true;
        }

        @Override
        public boolean onProperties(Model.VarObject var) {
            Log.v("iWoT", "onProperties");
            return true;
        }

        @Override
        public boolean onSystems(Model.VarObject var) {
            Log.v("iWoT", "onSystems");
            return true;
        }

        @Override
        public void onError(String s) {
            Log.v("[iWoT]", "onError: " + s);
        }
    }

當連線狀態發生變化時，SDK 會觸發對應的 callback，裝置程式可以經由這些 callback 取得目前的連線狀態。 *網路斷線時 SDK 會自動嘗試重新建立連線，您不需要在 callback 中手動重建連線。*

實作發送 event 及更新 property 至 iWoT
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

在收到 ``onConnect`` callback 之後將 ``connected`` 設定成 ``true``，然後就開始與 iWoT 的訊息傳遞。第一步是將 Accelerometer 的數值，以 event 的形式發送出去。event 的訊息傳遞方向為裝置端到 iWoT，使用以下的 API

::

    thing.emitEvents(var);

其中 var 參數為 event 內容。這個 event 必須包含在此裝置的 model 當中，以這個範例來講就是 **帶有三個浮點數值的 orientation**。這個參數是 ``Model.VarObject`` 的物件形式，你可以透過 ``Model.parseVarObject()`` 來將一個 JSON 字串轉換成此物件形式，或是自行以 ``new`` 的方式來建立，關於第二種方式，在下面提及 property 時會有範例。

本範例發送 event 的動作實作在 ``onSensorChanged`` callback 中，在每次更新 Accelerometer 時，如果已連上 iWoT，會先根據 ``precision`` (使用者可透過 action 設定) 來修改 Accelerometer 數值的精準度，然後串成一個 JSON 字串，接著透過 ``Model.parseVarObject()`` 將此 JSON 字串轉成物件型態，最後透過 ``thing.emitEvents()`` 將此 event 發送出去。

::

        public void onSensorChanged(SensorEvent event) {
            if (!paused) {
                float x = event.values[1];
                float y = event.values[2];
                float z = event.values[0];

                if (connected) {
                    x = (float)Math.floor(x * precision) / precision;
                    y = (float)Math.floor(y * precision) / precision;
                    z = (float)Math.floor(z * precision) / precision;

                    String json = "{\"events\":{\"orientation\":{\"values\":{\"x\":" + x + ",\"y\":" + y + ",\"z\":" + z + "}}}}";
                    Model.VarObject var = Model.parseVarObject(json);
                    if(false == thing.emitEvents(var)) {
                        Log.v("iWoT", "fail to emit events.");
                    }
                }

                tv_x.setText("X: " + x);
                tv_y.setText("Y: " + y);
                tv_z.setText("Z: " + z);
            }
        }

接下來說明如何更新 property。property 的訊息傳遞方向是雙向的，可能會由外部觸發，經由 iWoT shadow device 設定裝置端的 property；或是裝置內部更新完之後發出 property changed 通知 iWoT shadow device。後者使用以下 API

::

    thing.publishProperties(delta);

其中 delta 參數為 property 內容。同樣的，這個 property 必須包含在此裝置的 model 當中。如果有多個 property，delta 可以只包含其中一個或部分 property。

本範例使用 property -> ``pause`` 表示 pause 開關的狀態，並在狀態改變時將新的狀態通知 iWoT。

我們修改 Switch 的 callback，在 ``onCheckedChanged`` 裡面建立一個 ``Model.VarObject`` 的物件，這裡示範使用 ``new`` 的方式來建立。在 iWoT Android SDK，property、event 及 action 的參數型態為 ``Model.VarObject``。每個 ``Model.VarObject`` 只能描述 property、event 或是 action 其中一種，不能混用，所以在這個例子，我們在 ``Model.VarObject`` 的初始化參數填上 "properties" 關鍵字。而一個 ``Model.VarObject`` 裡面可以有數個 ``Model.VarGroup``，每個 ``Model.VarGroup`` 表示一個 property。在這個例子，就是 "pause"。而一個 ``Model.VarGroup`` 裡面還可以有數個 ``Model.VarItem``，每個 ``Model.VarItem`` 表示一個 property 的一組 value，這組 value 是以一個 key-value pair 的形式來描述，在這個例子，key 就是 "paused"，而 value 就是一個表示 pause 開關的狀態的 boolean 值。由於這個過程有點繁瑣，所以我們實作一個 ``createSingleProperty`` function 來建立這個 ``Model.VarObject``，最後再透過 ``thing.publishProperties()`` 將此 property 發送出去。

::

    private Model.VarObject createSingleProperty(String property, String key, boolean enabled) {
        ArrayList items = new ArrayList();
        items.add(new Model.VarItem(key, new Boolean(enabled)));

        ArrayList groups = new ArrayList();
        groups.add(new Model.VarGroup(property, items, null, null, null));

        return new Model.VarObject("properties", groups);
    }

    s_paused.setOnCheckedChangeListener(new CompoundButton.OnCheckedChangeListener() {
        @Override
        public void onCheckedChanged(CompoundButton buttonView, boolean isChecked) {
            paused = isChecked;
            if (null != thing && connected) {
                Model.VarObject delta = createSingleProperty("pause", "paused", paused);
                thing.publishProperties(delta);
            }
        }
    });

撰寫 action/properties handler
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

如果 model 中定義了 action，我們還必須實作 action handler，當外部呼叫此 action 時會交由對應的 action handler 處理。實作 action handler 就是 override ``Thing.IThingListener`` 的 ``onActions``。

::

    @Override
    public boolean onActions(Model.VarObject var) {
        Log.v("iWoT", "onActions");
        for (Model.VarGroup vg : var.groups) {
            if ("precision".equals(vg.identifier)) {
                for (Model.VarItem vi : vg.items) {
                    if ("decimal".equals(vi.key)) {
                        precision = (int) Math.pow(10, vi.numValue.intValue());
                    }
                }
            }
        }

        return true;
    }

所有的 action 都交由同一個 action handler 處理，因此必須先判斷所觸發的 action 是哪一個。以範例中的 model 為例，判斷方式為 ``Model.VarGroup.identifier`` 等於 "precision" 而且 ``Model.VarItem.key`` 等於 "decimal"。收到後可以由 action 參數中取得傳入值： ``vi.numValue.intValue``。

最後回傳 ``true`` 通知 iWoT 該 action 已執行完畢。 *請注意，若執行結果為失敗，必須回傳 ``false``，如此 iWoT 會紀錄該 action 的執行結果為失敗。*

前一節提到 property 訊息傳遞方向是雙向的，如果有來自裝置外部要求設定 property 的需求，則必須實作 properties handler。實作properties handler 就是 override ``Thing.IThingListener`` 的 ``onProperties``。

::

    @Override
    public boolean onProperties(Model.VarObject var) {
        Log.v("iWoT", "onProperties");
        for (Model.VarGroup group : var.groups) {
            for (Model.VarItem item : group.items) {
                if (group.identifier.equals("pause") && item.key.equals("paused")) {
                    s_paused.setChecked(item.boolValue);
                }
            }
        }

        return true;
    }

同樣的，所有設定 property 的要求都交由同一個 handler 處理，因此必須先判斷要設定的 property 是哪一個。以範例中的 model 為例，判斷方式為 ``Model.VarGroup.identifier`` 等於 "pause" 而且 ``Model.VarItem.key`` 等於 "paused"。設定值可以由 ``item.boolValue`` 取得。

最後也必須回傳 ``true`` 或是 ``false`` 來通知 iWoT 該 property 的設定成功與否。

初始化並建立連線
~~~~~~~~~~~~~~~~~~~~~~~

上述的 model、callback 和相關 handler 準備好之後就可以進行初始化並建立連線

::

    private void connectIWoT() {
        String modelJSON = "{\"id\":\"iwot_android_thing_1\",\"classID\":\"iwot_android_thing_model\",\"name\":\"iWoT Android Thing\",\"properties\":{\"pause\":{\"name\":\"Pause or Resume Sensors\",\"values\":{\"paused\":{\"type\":\"boolean\"}}}},\"actions\":{\"precision\":{\"name\":\"Set Precision\",\"values\":{\"decimal\":{\"description\":\"decimal places\",\"type\":\"integer\",\"minValue\":0,\"maxValue\":5,\"required\":true}}}},\"events\":{\"orientation\":{\"name\":\"Orientation Sensor\",\"values\":{\"x\":{\"type\":\"float\"},\"y\":{\"type\":\"float\"},\"z\":{\"type\":\"float\"}}}}}";
        String host = "rc2.iwot.io";
        String accessKey = "[your_access_key]";
        String secretKey = "[your_secret_key]";
        int keepAlive = 60;
        Model.VarObject defaultProperties = Model.parseVarObject("{\"pause\":{\"values\":{\"paused\":false}}}");

        Thing.Config config = new Thing.Config(accessKey, secretKey, modelJSON, defaultProperties, keepAlive, host);
        thing = new Thing();
        if (!thing.init(config)) {
            Log.v("[iWoT]", "Fail to init iWoT SDK");
            return;
        }
        thing.connect(getApplicationContext(), new Thing.IThingListener() {
            .............
        });        
    }

``accessKey`` 跟 ``secretKey`` 請填入一開始準備開發環境時取得的 *開發者金鑰*。 ``host`` 預設為 *rc2.iwot.io*，如果您使用的 iWoT 為私有雲或特殊客製化版本，請填入對應的 iWoT server 位址。 ``modelJSON`` 就是本範例 model 的字串型態。 ``keepAlive`` 是本裝置與iWoT Cloud 更新連線的間隔時間，詳細說明請參閱 API 文件，在此設定為 60 秒。 ``defaultProperties`` 是本裝置初始的 Properties，在此填入 pause 開關的初始狀態。

初始化成功之後呼叫 ``thing.connect()`` 並傳入 context 與前一節準備的 callback 及 handler。

完整的 MainActivity.java 程式碼
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

::

    public class MainActivity extends AppCompatActivity implements SensorEventListener {

        private Switch s_paused;
        private boolean paused = false;
        private TextView tv_x;
        private TextView tv_y;
        private TextView tv_z;
        private SensorManager sManager;
        private Sensor mSensorOrientation;

        private Thing thing = null;
        private boolean connected = false;
        private int precision = 100;

        @Override
        protected void onCreate(Bundle savedInstanceState) {
            super.onCreate(savedInstanceState);
            setContentView(R.layout.activity_main);

            sManager = (SensorManager) getSystemService(SENSOR_SERVICE);
            mSensorOrientation = sManager.getDefaultSensor(Sensor.TYPE_ORIENTATION);
            sManager.registerListener(this, mSensorOrientation, SensorManager.SENSOR_DELAY_UI);

            tv_x = (TextView) findViewById(R.id.tv_x);
            tv_y = (TextView) findViewById(R.id.tv_y);
            tv_z = (TextView) findViewById(R.id.tv_z);

            s_paused = (Switch) findViewById(R.id.paused);
            s_paused.setOnCheckedChangeListener(new CompoundButton.OnCheckedChangeListener() {
                @Override
                public void onCheckedChanged(CompoundButton buttonView, boolean isChecked) {
                    paused = isChecked;
                    if (null != thing && connected) {
                        Model.VarObject delta = createSingleProperty("pause", "paused", paused);
                        thing.publishProperties(delta);
                    }
                }
            });


            connectIWoT();
        }
        
        private void connectIWoT() {
            String modelJSON = "{\"id\":\"iwot_android_thing_1\",\"classID\":\"iwot_android_thing_model\",\"name\":\"iWoT Android Thing\",\"properties\":{\"pause\":{\"name\":\"Pause or Resume Sensors\",\"values\":{\"paused\":{\"type\":\"boolean\"}}}},\"actions\":{\"precision\":{\"name\":\"Set Precision\",\"values\":{\"decimal\":{\"description\":\"decimal places\",\"type\":\"integer\",\"minValue\":0,\"maxValue\":5,\"required\":true}}}},\"events\":{\"orientation\":{\"name\":\"Orientation Sensor\",\"values\":{\"x\":{\"type\":\"float\"},\"y\":{\"type\":\"float\"},\"z\":{\"type\":\"float\"}}}}}";
            String host = "192.168.22.3";
            String accessKey = "NhhUzHnodoEbleowIFupo7Dk";
            String secretKey = "9BF9w3d4WHJGfuoJjy-epSP9HbaVtgHBAgCE9g7is9kg_wv7";
            int keepAlive = 60;
            Model.VarObject defaultProperties = Model.parseVarObject("{\"pause\":{\"values\":{\"paused\":false}}}");

            Thing.Config config = new Thing.Config(accessKey, secretKey, modelJSON, defaultProperties, keepAlive, host);
            thing = new Thing();
            if (!thing.init(config)) {
                Log.v("[iWoT]", "Fail to init iWoT SDK");
                return;
            }
            thing.connect(getApplicationContext(), new Thing.IThingListener() {

                @Override
                public void onConnected() {
                    Log.v("[iWoT]", "onConnected");
                    connected = true;
                }

                @Override
                public void onDisconnected() {
                    Log.v("[iWoT]", "onDisconnected");
                    connected = false;
                }

                @Override
                public boolean onActions(Model.VarObject var) {
                    Log.v("iWoT", "onActions");
                    for (Model.VarGroup vg : var.groups) {
                        if ("precision".equals(vg.identifier)) {
                            for (Model.VarItem vi : vg.items) {
                                if ("decimal".equals(vi.key)) {
                                    precision = (int) Math.pow(10, vi.numValue.intValue());
                                }
                            }
                        }
                    }

                    return true;
                }

                @Override
                public boolean onProperties(Model.VarObject var) {
                    Log.v("iWoT", "onProperties");

                    for (Model.VarGroup group : var.groups) {
                        for (Model.VarItem item : group.items) {
                            if (group.identifier.equals("pause") && item.key.equals("paused")) {
                                s_paused.setChecked(item.boolValue);
                            }
                        }
                    }

                    return true;
                }

                @Override
                public boolean onSystem(Model.VarObject var) {
                    Log.v("iWoT", "onSystem");
                    return true;
                }

                @Override
                public void onFailure(String s) {
                    Log.v("[iWoT]", "onError: " + s);
                }
            });
        }

        private Model.VarObject createSingleProperty(String property, String key, boolean enabled) {
            ArrayList items = new ArrayList();
            items.add(new Model.VarItem(key, new Boolean(enabled)));

            ArrayList groups = new ArrayList();
            groups.add(new Model.VarGroup(property, items, null, null, null));

            return new Model.VarObject("properties", groups);
        }

        @Override
        public void onSensorChanged(SensorEvent event) {
            if (!paused) {
                float x = event.values[1];
                float y = event.values[2];
                float z = event.values[0];

                if (connected) {
                    x = (float)Math.floor(x * precision) / precision;
                    y = (float)Math.floor(y * precision) / precision;
                    z = (float)Math.floor(z * precision) / precision;

                    String json = "{\"events\":{\"orientation\":{\"values\":{\"x\":" + x + ",\"y\":" + y + ",\"z\":" + z + "}}}}";
                    Model.VarObject var = Model.parseVarObject(json);
                    if(false == thing.emitEvents(var)) {
                        Log.v("iWoT", "fail to emit events.");
                    }
                }

                tv_x.setText("X: " + x);
                tv_y.setText("Y: " + y);
                tv_z.setText("Z: " + z);
            }
        }

        @Override
        public void onAccuracyChanged(Sensor sensor, int accuracy) {

        }
    }

執行結果
--------

|執行畫面|

與 iWoT Cloud 互動
~~~~~~~~~~~~~~~~~~

登入 `iWoT <https://rc2.iwot.io>`_，可以看到此裝置已上線

|裝置已連線|

進入 Global Rule Engine

|進入規則引擎|

建立規則一，這個規則將來自裝置的 event -> ``orientation`` 參數顯示在右方的 debug 頁籤中

|建立規則一|

建立規則二，這個規則的作用是收到來自裝置的 property -> ``pause`` 更新訊息時，將內容顯示在 debug 頁籤中

|建立規則二|

裝置端會送出 orientation 及 pause 更新訊息，因此 Global Rule Engine 將顯示以下訊息

::

    2017/1/4 下午4:01:32b436ef92.00fc
    msg.payload : Object
    { "x": 1.4, "y": -2, "z": 114.46 }
    2017/1/4 下午4:01:32b436ef92.00fc
    msg.payload : Object
    { "x": 1.4, "y": -2.01, "z": 114.46 }
    2017/1/4 下午4:01:32b436ef92.00fc
    msg.payload : Object
    { "x": 1.4, "y": -2.01, "z": 114.46 }
    2017/1/4 下午4:01:32b436ef92.00fc
    msg.payload : Object
    { "x": 1.4, "y": -2.01, "z": 114.46 }
    2017/1/4 下午4:01:32b436ef92.00fc
    msg.payload : Object
    { "paused": true }

接著建立規則三，測試 action handler

|建立規則三|

按下 ``2`` 或是 ``4`` 的 inject 元件後，iWoT 會呼叫裝置的 ``onActions()`` 並傳入 var 物件，其中 vi.numValue 參數值為 ``2`` 或是 ``4`` 。依照 ``onActions()`` 的實作，會將 Accelerometer 數值顯示的精準度改為小數點下 2 位或是 4 位

|Set Precision|

建立規則四，測試設定 property

|建立規則四|

按下 ``true`` 或是\ ``false`` 的 inject 元件後，iWoT 會呼叫裝置的 ``onProperties()`` 並傳入 var 物件，其中 item.boolValue 參數值為 ``true``\ 或是\ ``false``\ 。依照 ``onProperties()`` 的實作，會將pause的開關設定為開或是關，另外，也會暫停或是開始發送Accelerometer 的數值到 iWoT

|Pause Resume|

常見問題
--------

在 iWoT Cloud 看不到此裝置
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

請核對 ``accessKey`` 及 ``secretKey`` 是否正確，並確認 ``host`` 指向正確位址。

Global Rule Engine 的 debug 頁籤沒有顯示預期中的資料
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

確認規則一與規則二的 iWoT Android Thing 元件已依照上述教學文件正確設定。請注意規則二，因為是 property changed 事件，必須選擇 Apply To one thing 並指定 iwot\_android\_thing\_1。

按下規則三或規則四的 inject 元件，裝置端沒有對應的輸出
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

確認規則三與規則四的 iWoT Android Thing 元件已依照上述教學文件正確設定。請注意規則四，因為是 set property 動作，必須選擇 Apply To one thing 並指定 iwot\_android\_thing\_1。

.. |執行畫面| image:: https://raw.githubusercontent.com/iwotdev/sdk_tutorial/master/android_sdk/images/1.png
.. |裝置已連線| image:: https://raw.githubusercontent.com/iwotdev/sdk_tutorial/master/android_sdk/images/2.png
.. |進入規則引擎| image:: https://raw.githubusercontent.com/iwotdev/sdk_tutorial/master/android_sdk/images/3.png
.. |建立規則一| image:: https://raw.githubusercontent.com/iwotdev/sdk_tutorial/master/android_sdk/images/4.png
.. |建立規則二| image:: https://raw.githubusercontent.com/iwotdev/sdk_tutorial/master/android_sdk/images/5.png
.. |建立規則三| image:: https://raw.githubusercontent.com/iwotdev/sdk_tutorial/master/android_sdk/images/6.png
.. |Set Precision| image:: https://raw.githubusercontent.com/iwotdev/sdk_tutorial/master/android_sdk/images/7.png
.. |建立規則四| image:: https://raw.githubusercontent.com/iwotdev/sdk_tutorial/master/android_sdk/images/8.png
.. |Pause Resume| image:: https://raw.githubusercontent.com/iwotdev/sdk_tutorial/master/android_sdk/images/9.png
.. |建立專案畫面一| image:: https://raw.githubusercontent.com/iwotdev/sdk_tutorial/master/android_sdk/images/10.png
.. |建立專案畫面二| image:: https://raw.githubusercontent.com/iwotdev/sdk_tutorial/master/android_sdk/images/11.png
.. |建立專案畫面三| image:: https://raw.githubusercontent.com/iwotdev/sdk_tutorial/master/android_sdk/images/12.png
.. |建立專案畫面四| image:: https://raw.githubusercontent.com/iwotdev/sdk_tutorial/master/android_sdk/images/13.png
.. |建立專案畫面五| image:: https://raw.githubusercontent.com/iwotdev/sdk_tutorial/master/android_sdk/images/14.png
.. |Import Library一| image:: https://raw.githubusercontent.com/iwotdev/sdk_tutorial/master/android_sdk/images/15.png
.. |Import Library二| image:: https://raw.githubusercontent.com/iwotdev/sdk_tutorial/master/android_sdk/images/16.png
.. |Import Library三| image:: https://raw.githubusercontent.com/iwotdev/sdk_tutorial/master/android_sdk/images/17.png
.. |Import Library四| image:: https://raw.githubusercontent.com/iwotdev/sdk_tutorial/master/android_sdk/images/18.png
.. |Import Library五| image:: https://raw.githubusercontent.com/iwotdev/sdk_tutorial/master/android_sdk/images/19.png

