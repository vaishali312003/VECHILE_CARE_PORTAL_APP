<%@ page import="javax.servlet.http.HttpSession" %>

<form action="adminLogin" method="post">
    <input type="text" name="username" placeholder="Admin Username" required>
    <input type="password" name="password" placeholder="Password" required>
    <button type="submit">Login</button>
</form>
