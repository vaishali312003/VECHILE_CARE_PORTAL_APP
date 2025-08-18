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

- `src/` - Java source code for servlets and utility classes  
- `webapp/` - JSP pages, images, and web resources  
- `DOCKER_VK/` - Docker setup including `dockerfile`, database scripts (`db.sql`), and WAR deployment target  
- `pom.xml` - Maven configuration file  

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
