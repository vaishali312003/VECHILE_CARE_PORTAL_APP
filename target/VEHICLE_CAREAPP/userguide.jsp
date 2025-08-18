<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html>
<head>
    <title>User Guide - Vehicle Portal</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            background-color: #f9f9f9;
            margin: 20px;
        }
        h1, h2 {
            color: #333;
        }
        table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 15px;
        }
        th, td {
            border: 1px solid #888;
            padding: 8px;
            text-align: left;
        }
        th {
            background-color: #eee;
        }
        .instructions {
            background-color: #fff;
            padding: 15px;
            margin-top: 20px;
            border: 1px solid #ccc;
        }
    </style>
</head>
<body>
    <h1>Vehicle Portal User Guide</h1>

    <div class="instructions">
        <h2>Admin Panel Login</h2>
        <p>
            You can login as an admin to manage vehicles and clients.
            <strong>Username:</strong> admin<br>
            <strong>Password:</strong> admin123
        </p>
        <p>Once logged in, you can add new vehicles and assign them to clients.</p>
    </div>

    <div class="instructions">
        <h2>Client Login Instructions</h2>
        <p>
            Clients can login using their <strong>vehicle number</strong> and <strong>client password</strong>.
            They will only be able to access details of the vehicle that matches exactly with their vehicle number.
        </p>
    </div>

    <div class="instructions">
        <h2>Sample Client Login Credentials & Vehicle Data</h2>
        <table>
            <tr>
                <th>vehicle_id</th>
                <th>vehicle_number</th>
                <th>model</th>
                <th>client_name</th>
                <th>client_password</th>
                <th>warranty_date</th>
                <th>registration_date</th>
                <th>service_date</th>
            </tr>
            <tr>
                <td>1</td>
                <td>KA01AB1234</td>
                <td>Toyota Corolla</td>
                <td>John Doe</td>
                <td>pass123</td>
                <td>2025-12-31</td>
                <td>2023-01-15</td>
                <td>2024-08-18</td>
            </tr>
            <tr>
                <td>2</td>
                <td>KA02ZZ9999</td>
                <td>Honda Jazz</td>
                <td>Jane Smith</td>
                <td>pass888</td>
                <td>2026-12-31</td>
                <td>2024-02-01</td>
                <td>2025-09-09</td>
            </tr>
            <tr>
                <td>5</td>
                <td>DL12AB1234</td>
                <td>Auro Motrix</td>
                <td>Vaishali Gupta</td>
                <td>vaishalix123</td>
                <td>2040-02-01</td>
                <td>2025-02-12</td>
                <td>2025-12-02</td>
            </tr>
        </table>
        <p>For more clients and vehicles, login to the admin panel and add new entries. Clients must use the exact vehicle number to access their account.</p>
    </div>
</body>
</html>
