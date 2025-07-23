<%@ page language="java" %>
<html>
<head><title>Vehicle Care App</title></head>
<body>
<h2>Welcome to Vehicle Care App</h2>
<a href="clientRegister.jsp">Register</a> | <a href="login.jsp">Login</a>
   <a href="login.jsp">Login</a> |
    <a href="adminLogin.jsp">Admin Login</a>
</body>
</html>

// File: src/main/webapp/clientRegister.jsp
<%@ page language="java" %>
<html>
<head><title>Client Registration</title></head>
<body>
<h2>Register as Client</h2>
<form action="ClientRegisterServlet" method="post">
    Name: <input type="text" name="name"><br>
    Email: <input type="email" name="email"><br>
    Password: <input type="password" name="password"><br>
    <input type="submit" value="Register">
</form>
</body>
</html>