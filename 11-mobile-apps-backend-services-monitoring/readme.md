# Mobile Apps Backend Services Monitoring

This document explains how to monitor a mobile application Backend API services in Instana. It covers Installing Instana Agent, Run the Backend API Application and View Service Dashboard 

Refer to the official product documentation for more details : [IBM Instana – Monitoring Mobile Applications](https://www.ibm.com/docs/en/instana-observability/1.0.315?topic=instana-monitoring-mobile-applications).

## PreRequisite

1. A Linux system with basic configuration (Ubuntu recommended)
2. Docker installed and properly configured
3. Access to Instana 

## 1. Install Instana Agent

1. Install the Instana agent in the Linux box using the steps given here  [Installing Instana Agent in Linux](../51-installing-instana-agent-in-linux).


## 2. Instrumenting the Backend API Application

<details><summary>Click me for more info</summary>

### Instrument the app

<img src="images/img251.png" >

<img src="images/img252.png" >

<img src="images/img253.png" >

### Backend Tracing ID

In server side (Backend API) need to add middleware to inject the **Server-Timing header** with the trace ID. 

<img src="images/img241.png">

<img src="images/img241.png">



</details>

## 3. Run the Backend API Application

<details><summary>Click me for more info</summary>

### 3.1 Source code

The source code of the Python based Backend API is available [here](./files/src)  

### 3.2 Run the app

Lets run the Backend API app in the Linux box, where the instana agent is installed.

#### Run using source code (Optional)

1. You can run the app using the source code from the above link.

```
python -m venv venv
source venv/bin/activate

python -m pip install -r requirements.txt

# Start the app
python main.py
```

#### Run using Docker

1. Run the below command run the app as a docker.

```
docker run -d -p 8000:8000 --name my-todo-app --env INSTANA_AGENT_PORT="443"  gandigit/todo-app:latest
```

### 3.3 Test the app

1. Run the below curl scripts in the linus box to see, whether app is running.

```
# Health check
curl http://localhost:8000/health

# Get statistics
curl http://localhost:8000/api/todos/statistics

# Get all todos
curl http://localhost:8000/api/todos

```

### 3.4 Generate Load in the Backend API App 

1. Run commands one by one available in the load script [here](./files/scripts/10-load.sh)  

### 3.5 Generate Load in the Mobile App 

1. Play around with the Mobile app to generate some load.

</details>

## 4. View Service Dashboard in Instana

<details><summary>Click me for more info</summary>

<img src="images/img101.png" >
<img src="images/img102.png" >

<img src="images/img121.png" >
<img src="images/img122.png" >
<img src="images/img123.png" >
<img src="images/img124.png" >
<img src="images/img125.png" >
<img src="images/img126.png" >

</details>

## 5. View End Point Details

<details><summary>Click me for more info</summary>

<img src="images/img131.png" >
<img src="images/img132.png" >
<img src="images/img133.png" >

</details>

## 6. View Stack Details

<details><summary>Click me for more info</summary>

<img src="images/img140.png" >
<img src="images/img141.png" >

</details>

## 7. View Host Details

<details><summary>Click me for more info</summary>

<img src="images/img150.png" >
<img src="images/img151.png" >
<img src="images/img152.png" >
<img src="images/img153.png" >
<img src="images/img154.png" >
<img src="images/img155.png" >
<img src="images/img156.png" >
<img src="images/img157.png" >
<img src="images/img160.png" >
<img src="images/img161.png" >
<img src="images/img162.png" >
</details>


## 8. View Docker Container Details

<details><summary>Click me for more info</summary>

<img src="images/img171.png" >
<img src="images/img172.png" >
<img src="images/img173.png" >
<img src="images/img174.png" >
<img src="images/img175.png" >

</details>


## 9. View Docker Container Details

<details><summary>Click me for more info</summary>

<img src="images/img181.png" >
<img src="images/img182.png" >
<img src="images/img183.png" >

</details>


## 10. View Python App Details

<details><summary>Click me for more info</summary>

<img src="images/img191.png" >
<img src="images/img192.png" >
<img src="images/img193.png" >

</details>

## 11. View Tracing Details from Services

<details><summary>Click me for more info</summary>

<img src="images/img201.png" >

<img src="images/img202.png" >

<img src="images/img203.png" >

<img src="images/img204.png" >
<img src="images/img205.png" >

</details>

## 12. View Tracing Details from EndPoint

<details><summary>Click me for more info</summary>

<img src="images/img221.png" >

<img src="images/img222.png" >
<img src="images/img223.png" >

<img src="images/img224.png" >

<img src="images/img225.png" >

<img src="images/img226.png" >
<img src="images/img227.png" >
<img src="images/img228.png" >

</details>
