<%@ page language="java" %>
<html>
<head><title>Client Registration</title></head>
<body>
<h2>Register as Client</h2>
<form action="ClientRegisterServlet" method="post">
    Name: <input type="text" name="name"><br>
    Vehicle Number: <input type="text" name="vehicle_number"><br>
    Password: <input type="password" name="password"><br>
    <input type="submit" value="Register">
</form>
</body>
</html>