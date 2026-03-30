# Mobile Apps Monitoring - Flutter Based

This document explains how to monitor a mobile application in Instana. It covers creating a Mobile App Perspective in Instana, instrumenting the Flutter code, and viewing dashboards and analytics.

Refer to the official product documentation for more details : [IBM Instana – Monitoring Mobile Applications](https://www.ibm.com/docs/en/instana-observability/1.0.315?topic=instana-monitoring-mobile-applications).

## 1. Create Mobile App Perspective in Instana

<details><summary>Click me for more info</summary>

Let's create a Mobile App Perspective in Instana

1. Click on **Website and Mobile Apps** in the left navigation menu.

<img src="images/img11.png" >

2. Click the **Mobile Apps** tab
3. Click the **Add Mobile App** button

<img src="images/img12.png" >

4. Enter the **Mobile App Name**
5. Click the **Add Mobile App** button

<img src="images/img13.png" >

Your app is now created. Make a note of the **Key** and **Reporting URL**.

<img src="images/img14.png" >

You can now see the newly created app in the list.

<img src="images/img15.png" >

</details>

## 2. Mobile App UI

<details><summary>Click me for more info</summary>

Below are screenshots of the TODO Mobile App that we will monitor.

<img src="images/img21.png" >
</details>

## 3. Instrumenting the Mobile App Code

<details><summary>Click me for more info</summary>

The source code of the TODO Mobile app is available [here](./files)  

#### Dependencies

 1. Add the **Instana Agent** to the project dependencies.

<img src="images/img31.png" >

#### InstanaConfig

2. Configure the **Key**, **Reporting URL** and **Meta data** in the InstanaConfig.

<img src="images/img32.png" >

#### InstanaAgent.setup

3. In the main method, call the instana setup API using the **Key**, **Reporting URL** from Configuration.

<img src="images/img33.png" >

#### InstanaService

4. Create a InstanaService class with the functions to interact with the Instana Agent..

<img src="images/img34.png" >
<img src="images/img35.png" >
<img src="images/img36.png" >

#### TrackView

5. Implement **Track View** for all the screens.

<img src="images/img37.png" >
<img src="images/img38.png" >
<img src="images/img39.png" >

#### Track User Action

6. Implement **Track User Action** for operations like add, update, and delete.

<img src="images/img40a.png" >

<img src="images/img40b.png" >

<img src="images/img40c.png" >

#### Http Request Monitoring

7. Implement **Http Request Monitoring** for operations that calls Backend APIs and so on.

<img src="images/img90.png" >
<img src="images/img91.png" >

<img src="images/img92.png" >
<img src="images/img93.png" >

#### Backend Tracing

7. Implement **Backend Tracing** for operations that calls Backend APIs and so on.

The frontend to extract the **backendTracingID** from the **Server-Timing** header and set it on the marker. 

<img src="images/img94.png" >

<img src="images/img95.png" >

Note : In server side (Backend API) need to add middleware to inject the **Server-Timing header** with the trace ID. This is documented separately.

<img src="images/img241.png">

<img src="images/img241.png">

</details>

## 4. Connecting from Mobile App to Backend API
<details><summary>Click me for more info</summary>

1. See the backend API URL is given below.

<img src="images/img71.png" >

2. See the backend API **getTodos** implemented here.

<img src="images/img72.png" >

</details>

## 5. Running Mobile App

<details><summary>Click me for more info</summary>

### 5.1 Running in MacOS with iOS Simulator


1. Open Xcode using the command below.
```
open -a Xcode
```

XCode opens like this.

<img src="images/img81.png" >

2. Open the Simulator using the command below.
```
open -a Simulator
```

Simulator opens like this.

<img src="images/img82.png" >

3. Run the app using the command below.
```
flutter run
```

App opens like this.

<img src="images/img83.png" >

4. Play around the app and generate traffic.

### 5.2 Running in Android

To be done.

</details>

## 6. View App Dashboard in Instana

<details><summary>Click me for more info</summary>

Below are various sections of the **Mobile App Dashboard** in Instana:

<img src="images/img41.png" >

<img src="images/img42.png" >
<img src="images/img43.png" >

<img src="images/img44.png" >

<img src="images/img45.png" >

<img src="images/img46.png" >
<img src="images/img47.png" >
<img src="images/img48.png" >
</details>

## 7. View App Analytics in Instana

<details><summary>Click me for more info</summary>

Instana provides detailed **Mobile App Analytics** views:

<img src="images/img51.png" >
<img src="images/img52.png" >
<img src="images/img53.png" >
<img src="images/img54.png" >
<img src="images/img55.png" >
<img src="images/img56.png" >
</details>

## 8. View App Analytics Events

<details><summary>Click me for more info</summary>

You can explore **Mobile App Analytics Events** in Instana:

<img src="images/img61.png" >
<img src="images/img62.png" >
<img src="images/img63.png" >
<img src="images/img64.png" >
<img src="images/img65.png" >

</details>