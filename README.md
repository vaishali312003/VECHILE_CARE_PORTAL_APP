# 🚗 Vehicle Care Portal App

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](LICENSE)
[![Java](https://img.shields.io/badge/Java-Servlets-orange)](https://www.oracle.com/java/)
[![Docker](https://img.shields.io/badge/Docker-Container-blue)](https://www.docker.com/)

Vehicle Care Portal App is a **Java web application** for managing vehicle services, client registrations, and administrative operations. Vehicle owners can register, book services, and track their vehicles, while administrators can efficiently manage vehicles, service requests, and client data.

---

## 🌐 Live Demo

Access the deployed Vehicle Care Portal App here: [**Live App on Render**](https://vehicle-portal-app.onrender.com/)

---

## 📂 Project Structure

```

VECHILE\_CAREAPP/
├── .gitignore
├── pom.xml
├── .idea/
├── .mvn/
├── DOCKER\_VK/
│   ├── db.sql
│   ├── dockerfile
│   ├── .idea/
│   └── target/
│       └── ROOT.war
├── src/
│   └── main/
│       ├── java/com/example/vehicleportal/
│       │   ├── servlet/
│       │   │   ├── AddVehicleServlet.java
│       │   │   ├── AdminLoginServlet.java
│       │   │   ├── AuthenticationFilter.java
│       │   │   ├── ClientRegisterServlet.java
│       │   │   ├── DeleteVehicleServlet.java
│       │   │   ├── LoginServlet.java
│       │   │   ├── LogoutServlet.java
│       │   │   └── UpdateVehicleServlet.java
│       │   └── util/
│       │       └── DBConnection.java
│       └── webapp/
│           ├── adminDashboard.jsp
│           ├── adminLogin.jsp
│           ├── BookingService.jsp
│           ├── clientRegister.jsp
│           ├── dashboard.jsp
│           ├── index.jsp
│           ├── jstl\_test.jsp
│           ├── login.jsp
│           ├── myvehicles.jsp
│           ├── profile.jsp
│           ├── serviceRequests.jsp
│           ├── userguide.jsp
│           ├── vehicleDetails.jsp
│           ├── img/
│           │   ├── bg/
│           │   ├── icon/
│           │   ├── service\_station/
│           │   └── vehicles/
│           └── WEB-INF/
│               ├── web.xml
│               └── lib/
│                   ├── jakarta.servlet-api-6.0.0.jar
│                   ├── jstl-1.2.jar
│                   ├── mysql-connector-j-8.3.0.jar
│                   └── postgresql-42.6.0.jar
└── target/
└── VEHICLE\_CAREAPP.war

````

---

## 🛠️ Tech Stack

- **Backend:** Java Servlet, JSP  
- **Build Tool:** Maven  
- **Web Server:** Apache Tomcat  
- **Database:** PostgreSQL (hosted on Render)  
- **Containerization:** Docker  
- **Deployment:** Render  

---

## 🚀 Features

### Client
- Register and login  
- Book vehicle services  
- Track vehicles  

### Admin
- Manage vehicles, clients, and service requests  
- View dashboard of all operations  

### Dockerized Setup
- Dockerfile included for containerized deployment  
- PostgreSQL scripts included for database setup  

---

## ⚙️ How to Run Locally

1. **Clone the repository**  

```bash
git clone https://github.com/vaishali312003/VECHILE_CARE_PORTAL_APP.git
cd VECHILE_CARE_PORTAL_APP
````

2. **Download the `DOCKER_VK` folder**

   * Contains Dockerfile, WAR file, and PostgreSQL scripts

3. **Build and run using Docker**

```bash
cd DOCKER_VK
docker build -t vehicle-care-app .
docker run -p 8080:8080 vehicle-care-app
```

4. **Database Setup**

   * PostgreSQL is hosted on Render
   * If you want to run locally, execute `db.sql` included in `DOCKER_VK`

5. **Access the App**

   * Open [http://localhost:8080](http://localhost:8080) in your browser

---

## 📦 Notes

* Ensure Docker is installed and running
* WAR file is included in `DOCKER_VK/target` for deployment

---

## 📄 License

This project is licensed under the [Apache License 2.0](LICENSE)

```

---

If you want, I can also **highlight the `DOCKER_VK` folder structure separately** in the README so it’s crystal clear for anyone using Docker to deploy.  

Do you want me to do that?
```
