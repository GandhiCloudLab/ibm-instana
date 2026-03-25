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

## 2. Mobile App 

<details><summary>Click me for more info</summary>

Below are screenshots of the TODO Mobile App that we will monitor.

<img src="images/img21.png" >
</details>

## 3. Instrumenting the Mobile App Code

<details><summary>Click me for more info</summary>

The source code of the TODO Mobile app is available [here](./src-todo-app)  

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

<img src="images/img40.png" >
</details>

## 4. View App Dashboard in Instana

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

## 5. View App Analytics in Instana

<details><summary>Click me for more info</summary>

Instana provides detailed **Mobile App Analytics** views:

<img src="images/img51.png" >
<img src="images/img52.png" >
<img src="images/img53.png" >
<img src="images/img54.png" >
<img src="images/img55.png" >
<img src="images/img56.png" >
</details>

## 6. View App Analytics Events

<details><summary>Click me for more info</summary>

You can explore **Mobile App Analytics Events** in Instana:

<img src="images/img61.png" >
<img src="images/img62.png" >
<img src="images/img63.png" >
<img src="images/img64.png" >
<img src="images/img65.png" >

</details>