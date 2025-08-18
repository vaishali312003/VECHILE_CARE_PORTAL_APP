<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <title>Client Registration</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            background: linear-gradient(to right, #6dd5ed, #2193b0);
            color: #fff;
            display: flex;
            justify-content: center;
            align-items: center;
            height: 100vh;
        }
        .form-container {
            background-color: rgba(0,0,0,0.6);
            padding: 30px;
            border-radius: 10px;
            box-shadow: 0 0 10px #000;
        }
        input[type=text], input[type=password] {
            width: 100%;
            padding: 10px;
            margin: 8px 0;
            border: none;
            border-radius: 5px;
        }
        input[type=submit] {
            width: 100%;
            background-color: #4CAF50;
            color: white;
            padding: 10px;
            border: none;
            border-radius: 5px;
            cursor: pointer;
        }
        input[type=submit]:hover {
            background-color: #45a049;
        }
        h2 {
            text-align: center;
        }
    </style>
</head>
<body>
    <div class="form-container">
        <h2>Register as Client</h2>
        <form action="clientRegister" method="post">
            Name: <input type="text" name="name" required><br>
            Vehicle Number: <input type="text" name="vehicle_number" required><br>
            Password: <input type="password" name="password" required><br>
            <input type="submit" value="Register">
        </form>
    </div>
</body>
</html>
