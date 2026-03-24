# Mobile Apps Monitoring - Flutter Based

Refer the product documentation [here](https://www.ibm.com/docs/en/instana-observability/1.0.315?topic=instana-monitoring-mobile-applications) for more detailed info about this.

## 1. Create Mobile App in Instana

<img src="images/img11.png" >

<img src="images/img12.png" >

<img src="images/img13.png" >

Make a note of Key and URL.

<img src="images/img14.png" >

## 2. Mobile App

Here is the screenshots of the TODO Mobile App.

<img src="images/img21.png" >

## 3. Instrumenting the Mobile App Code

The source code of the TODO Mobile app is available [here](../src-todo-app)  

1. Include Instana Agent into dependencies.

<img src="images/img31.png" >

2. InstanaConfig

Configure the Key, URL and Meta data info in the InstanaConfig.

<img src="images/img32.png" >

3. InstanaAgent.setup

In the main method, call the instana setup related to API with the key and URL referenced from Instana Config

<img src="images/img33.png" >

4. InstanaService

Create a InstanaService class with the below functions to call Instana Agent.

<img src="images/img34.png" >
<img src="images/img35.png" >
<img src="images/img36.png" >

5. TrackView

Implement a Track View for all the screens.

<img src="images/img37.png" >
<img src="images/img38.png" >
<img src="images/img39.png" >

6. Track User Action

Implement a Track User Action for add, update and delete functions.

<img src="images/img40.png" >

## 4. View App Dashboard


<img src="images/img41.png" >

<img src="images/img42.png" >
<img src="images/img43.png" >

<img src="images/img44.png" >

<img src="images/img45.png" >

<img src="images/img46.png" >
<img src="images/img47.png" >
<img src="images/img48.png" >

## 5. View App Analytics

<img src="images/img51.png" >
<img src="images/img52.png" >
<img src="images/img53.png" >
<img src="images/img54.png" >
<img src="images/img55.png" >
<img src="images/img56.png" >

## 6. View App Analytics Events

<img src="images/img61.png" >
<img src="images/img62.png" >
<img src="images/img63.png" >
<img src="images/img64.png" >
<img src="images/img65.png" >




