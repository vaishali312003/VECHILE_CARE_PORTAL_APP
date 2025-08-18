-- 1️⃣ Create the database
CREATE DATABASE IF NOT EXISTS vehicle_management;

-- 2️⃣ Use the database
USE vehicle_management;

-- 3️⃣ Create vehicle_client table
CREATE TABLE IF NOT EXISTS vehicle_client (
    vehicle_id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    client_name VARCHAR(100) NOT NULL,
    vehicle_number VARCHAR(50) NOT NULL UNIQUE,
    contact_phone VARCHAR(20),
    email VARCHAR(100)
);

-- 4️⃣ Create service_centers table
CREATE TABLE IF NOT EXISTS service_centers (
    center_id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    center_name VARCHAR(255) NOT NULL UNIQUE,
    location VARCHAR(500) NOT NULL,
    contact_phone VARCHAR(20),
    email VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- 5️⃣ Create service_requests table
CREATE TABLE IF NOT EXISTS service_requests (
    request_id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    vehicle_id INT NOT NULL,
    center_id INT NOT NULL,
    request_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(50) DEFAULT 'Pending',
    approval_date TIMESTAMP,
    remarks TEXT,
    option_1_date DATE,
    option_1_time TIME DEFAULT '09:00:00',
    option_2_date DATE,
    option_2_time TIME DEFAULT '14:00:00',
    option_3_date DATE,
    option_3_time TIME DEFAULT '11:00:00',
    client_selected_option INT,
    final_service_datetime TIMESTAMP,
    date_selection_deadline TIMESTAMP,
    service_type VARCHAR(100),
    FOREIGN KEY (vehicle_id) REFERENCES vehicle_client(vehicle_id) ON DELETE CASCADE,
    FOREIGN KEY (center_id) REFERENCES service_centers(center_id) ON DELETE RESTRICT
);

-- 6️⃣ Create admin table
CREATE TABLE IF NOT EXISTS admin (
    id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(100) NOT NULL UNIQUE,
    password VARCHAR(100) NOT NULL
);
