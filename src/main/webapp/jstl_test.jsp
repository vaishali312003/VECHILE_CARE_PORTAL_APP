<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
<head>
    <title>Debug Test</title>
</head>
<body>
    <h1>Debug Information</h1>

    <h2>Basic JSTL Test:</h2>
    <c:set var="testVar" value="JSTL is working!" />
    <p>Test variable: ${testVar}</p>

    <h2>Servlet Data:</h2>
    <p>Test Message: ${testMessage}</p>
    <p>Vehicles object: ${vehicles}</p>
    <p>Vehicles is null: ${vehicles == null}</p>
    <p>Vehicles is empty: ${empty vehicles}</p>
    <p>Vehicles size: ${vehicles.size()}</p>

    <h2>Raw Vehicle Data:</h2>
    <c:forEach var="vehicle" items="${vehicles}" varStatus="status">
        <p>Vehicle ${status.index + 1}: ${vehicle}</p>
    </c:forEach>

    <h2>Session Info:</h2>
    <p>Client Name: ${sessionScope.clientName}</p>

    <a href="VehicleDetailsServlet">Test VehicleDetailsServlet</a>
</body>
</html>