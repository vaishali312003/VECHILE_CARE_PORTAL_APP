<%@ page language="java" contentType="text/html; charset=UTF-8"
         pageEncoding="UTF-8"
         import="java.sql.*, com.example.vehicleportal.util.DBConnection, java.util.*, java.util.Date" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<%
    // --- Session Validation and Cache Prevention ---
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);

    HttpSession userSession = request.getSession(false);
    if (userSession == null || userSession.getAttribute("clientName") == null) {
        response.sendRedirect("login.jsp?error=session_expired");
        return;
    }

    String clientName = (String) userSession.getAttribute("clientName");

    // Fetch vehicle data for the logged-in client
    List<Map<String, Object>> vehicles = new ArrayList<>();
    int totalVehicles = 0;
    int pendingServices = 0;
    int serviceHistory = 0;

    try (Connection conn = DBConnection.getConnection()) {
        PreparedStatement stmt = conn.prepareStatement(
            "SELECT vehicle_id, vehicle_number, model, client_name, client_password, " +
            "warranty_date, registration_date, service_date FROM vehicle_client WHERE client_name = ?"
        );
        stmt.setString(1, clientName);
        ResultSet rs = stmt.executeQuery();

        while (rs.next()) {
            Map<String, Object> vehicle = new HashMap<>();
            vehicle.put("vehicle_id", rs.getInt("vehicle_id"));
            vehicle.put("vehicle_number", rs.getString("vehicle_number"));
            vehicle.put("model", rs.getString("model"));
            vehicle.put("client_name", rs.getString("client_name"));
            vehicle.put("warranty_date", rs.getDate("warranty_date"));
            vehicle.put("registration_date", rs.getDate("registration_date"));
            vehicle.put("service_date", rs.getDate("service_date"));
            vehicles.add(vehicle);
        }

        totalVehicles = vehicles.size();
        for (Map<String, Object> vehicle : vehicles) {
            java.sql.Date serviceDate = (java.sql.Date) vehicle.get("service_date");
            if (serviceDate != null) {
                long daysSince = (System.currentTimeMillis() - serviceDate.getTime()) / (1000 * 60 * 60 * 24);
                if (daysSince > 180) {
                    pendingServices++;
                }
                serviceHistory++;
            }
        }
    } catch (Exception e) {
        e.printStackTrace();
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <meta http-equiv="Cache-Control" content="no-cache, no-store, must-revalidate" />
    <meta http-equiv="Pragma" content="no-cache" />
    <meta http-equiv="Expires" content="0" />
    <title>AutoSpace - Vehicle Dashboard</title>
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet" />
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        :root {
            --primary: #2563eb;
            --primary-dark: #1d4ed8;
            --secondary: #64748b;
            --success: #10b981;
            --warning: #f59e0b;
            --danger: #ef4444;
            --dark: #0f172a;
            --dark-lighter: #1e293b;
            --dark-light: #334155;
            --glass: rgba(255, 255, 255, 0.08);
            --glass-border: rgba(255, 255, 255, 0.12);
            --text-primary: #ffffff;
            --text-secondary: #cbd5e1;
            --text-muted: #94a3b8;
        }

        body {
            font-family: 'Inter', sans-serif;
            background: linear-gradient(135deg,
                rgba(15, 23, 42, 0.95) 0%,
                rgba(30, 41, 59, 0.95) 50%,
                rgba(51, 65, 85, 0.95) 100%
            ), url('img/bg/Abstract car silhouettes.jpg');
            background-size: cover;
            background-attachment: fixed;
            background-position: center;
            color: var(--text-primary);
            min-height: 100vh;
            line-height: 1.6;
        }

        /* Layout */
        .dashboard-layout {
            display: flex;
            min-height: 100vh;
        }

        /* Sidebar */
        .sidebar {
            width: 300px;
            background: rgba(15, 23, 42, 0.95);
            backdrop-filter: blur(25px);
            border-right: 1px solid var(--glass-border);
            position: fixed;
            height: 100vh;
            overflow-y: auto;
            z-index: 1000;
            transition: transform 0.3s ease;
            box-shadow: 4px 0 24px rgba(0, 0, 0, 0.3);
        }

        .sidebar-header {
            padding: 2.5rem 2rem;
            border-bottom: 1px solid var(--glass-border);
            text-align: center;
        }

        .logo {
            display: flex;
            flex-direction: column;
            align-items: center;
        }

        .logo-icon {
            width: 60px;
            height: 60px;
            margin-bottom: 1rem;
            background: linear-gradient(135deg, var(--primary), #3b82f6);
            border-radius: 16px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 2rem;
            color: white;
        }

        .logo h1 {
            font-size: 2.2rem;
            font-weight: 800;
            background: linear-gradient(135deg, var(--primary), #3b82f6);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            margin-bottom: 0.5rem;
        }

        .logo p {
            color: var(--text-muted);
            font-size: 0.9rem;
            font-weight: 500;
        }

        .nav-menu {
            padding: 2rem 0;
        }

        .nav-item {
            margin: 0 1.5rem 0.8rem;
        }

        .nav-link {
            display: flex;
            align-items: center;
            padding: 1.2rem 1.8rem;
            color: var(--text-secondary);
            text-decoration: none;
            border-radius: 16px;
            transition: all 0.3s ease;
            font-weight: 500;
            position: relative;
            overflow: hidden;
        }

        .nav-link::before {
            content: '';
            position: absolute;
            top: 0;
            left: -100%;
            width: 100%;
            height: 100%;
            background: linear-gradient(90deg, transparent, rgba(255, 255, 255, 0.1), transparent);
            transition: left 0.5s;
        }

        .nav-link:hover::before {
            left: 100%;
        }

        .nav-link:hover,
        .nav-link.active {
            background: linear-gradient(135deg, var(--primary), #3b82f6);
            color: white;
            transform: translateX(8px);
            box-shadow: 0 8px 24px rgba(37, 99, 235, 0.3);
        }

        .nav-link i {
            width: 24px;
            margin-right: 1.2rem;
            font-size: 1.2rem;
        }

        /* Main Content */
        .main-content {
            flex: 1;
            margin-left: 300px;
            padding: 2.5rem;
        }

        /* Header */
        .header {
            background: var(--glass);
            backdrop-filter: blur(25px);
            border: 1px solid var(--glass-border);
            border-radius: 24px;
            padding: 2.5rem;
            margin-bottom: 2.5rem;
            display: flex;
            justify-content: space-between;
            align-items: center;
            position: relative;
            overflow: hidden;
            box-shadow: 0 8px 32px rgba(0, 0, 0, 0.2);
        }

        .header::before {
            content: '';
            position: absolute;
            top: 0;
            right: 0;
            width: 200px;
            height: 100%;
            background: url('img/bg/gradient_overlay.jpg') center/cover;
            opacity: 0.1;
            z-index: -1;
        }

        .welcome h1 {
            font-size: 2.8rem;
            font-weight: 700;
            margin-bottom: 0.8rem;
            background: linear-gradient(135deg, var(--primary), #3b82f6, #06b6d4);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
        }

        .welcome p {
            color: var(--text-secondary);
            font-size: 1.2rem;
            font-weight: 500;
        }

        .user-section {
            display: flex;
            align-items: center;
            gap: 2rem;
        }

        .user-info {
            text-align: right;
        }

        .user-name {
            font-size: 1.1rem;
            font-weight: 600;
            color: var(--text-primary);
            margin-bottom: 0.2rem;
        }

        .user-status {
            font-size: 0.85rem;
            color: var(--success);
            display: flex;
            align-items: center;
            justify-content: flex-end;
            gap: 0.5rem;
        }

        .user-avatar {
            width: 70px;
            height: 70px;
            background: linear-gradient(135deg, var(--primary), #3b82f6);
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-weight: 700;
            font-size: 1.5rem;
            position: relative;
            box-shadow: 0 8px 24px rgba(37, 99, 235, 0.3);
        }

        .user-avatar::after {
            content: '';
            position: absolute;
            top: -2px;
            left: -2px;
            right: -2px;
            bottom: -2px;
            background: linear-gradient(45deg, var(--primary), #3b82f6, var(--success), var(--primary));
            border-radius: 50%;
            z-index: -1;
            animation: rotate 3s linear infinite;
        }

        @keyframes rotate {
            from { transform: rotate(0deg); }
            to { transform: rotate(360deg); }
        }

        /* Stats Grid */
        .stats-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
            gap: 2rem;
            margin-bottom: 2.5rem;
        }

        .stat-card {
            background: var(--glass);
            backdrop-filter: blur(25px);
            border: 1px solid var(--glass-border);
            border-radius: 20px;
            padding: 2.5rem;
            text-align: center;
            position: relative;
            overflow: hidden;
            transition: all 0.4s ease;
            box-shadow: 0 8px 32px rgba(0, 0, 0, 0.1);
        }

        .stat-card:hover {
            transform: translateY(-8px) scale(1.02);
            box-shadow: 0 20px 40px rgba(0, 0, 0, 0.3);
        }

        .stat-card::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            height: 4px;
            background: linear-gradient(90deg, var(--primary), #3b82f6, var(--success));
        }

        .stat-icon-container {
            position: absolute;
            top: 2rem;
            right: 2rem;
            width: 60px;
            height: 60px;
            background: rgba(255, 255, 255, 0.1);
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            opacity: 0.8;
        }

        .stat-icon {
            font-size: 1.8rem;
            color: var(--primary);
        }

        .stat-number {
            font-size: 3.5rem;
            font-weight: 800;
            margin-bottom: 0.8rem;
            background: linear-gradient(135deg, var(--primary), #3b82f6);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            line-height: 1;
        }

        .stat-label {
            color: var(--text-secondary);
            font-weight: 600;
            text-transform: uppercase;
            letter-spacing: 1px;
            font-size: 0.9rem;
        }

        /* Content Grid */
        .content-grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 2.5rem;
            margin-bottom: 2.5rem;
        }

        .content-card {
            background: var(--glass);
            backdrop-filter: blur(25px);
            border: 1px solid var(--glass-border);
            border-radius: 20px;
            padding: 2.5rem;
            transition: all 0.3s ease;
            box-shadow: 0 8px 32px rgba(0, 0, 0, 0.1);
            position: relative;
            overflow: hidden;
        }

        .content-card:hover {
            transform: translateY(-4px);
            box-shadow: 0 16px 40px rgba(0, 0, 0, 0.2);
        }

        .card-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 2rem;
        }

        .card-title {
            font-size: 1.6rem;
            font-weight: 700;
            color: var(--text-primary);
        }

        .card-badge {
            background: linear-gradient(135deg, var(--primary), #3b82f6);
            color: white;
            padding: 0.6rem 1.2rem;
            border-radius: 25px;
            font-size: 0.8rem;
            font-weight: 600;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }

        /* Quick Actions */
        .actions-grid {
            display: grid;
            grid-template-columns: repeat(2, 1fr);
            gap: 1.5rem;
        }

        .action-item {
            background: rgba(255, 255, 255, 0.05);
            border: 1px solid rgba(255, 255, 255, 0.1);
            border-radius: 16px;
            padding: 2rem 1.5rem;
            text-align: center;
            text-decoration: none;
            color: inherit;
            transition: all 0.4s ease;
            position: relative;
            overflow: hidden;
        }

        .action-item::before {
            content: '';
            position: absolute;
            top: 0;
            left: -100%;
            width: 100%;
            height: 100%;
            background: linear-gradient(90deg, transparent, rgba(255, 255, 255, 0.1), transparent);
            transition: left 0.5s;
        }

        .action-item:hover::before {
            left: 100%;
        }

        .action-item:hover {
            background: linear-gradient(135deg, var(--primary), #3b82f6);
            transform: translateY(-4px) scale(1.05);
            box-shadow: 0 12px 32px rgba(37, 99, 235, 0.3);
        }

        .action-item i {
            font-size: 2.5rem;
            margin-bottom: 1.2rem;
            color: var(--primary);
            transition: color 0.3s ease;
        }

        .action-item:hover i {
            color: white;
        }

        .action-item span {
            font-weight: 600;
            font-size: 0.95rem;
            display: block;
            transition: color 0.3s ease;
        }

        /* Service Centers */
        .service-list {
            space-y: 1.5rem;
        }

        .service-item {
            display: flex;
            align-items: center;
            padding: 2rem;
            background: rgba(255, 255, 255, 0.05);
            border-radius: 16px;
            margin-bottom: 1.5rem;
            transition: all 0.3s ease;
            position: relative;
            overflow: hidden;
        }

        .service-item::before {
            content: '';
            position: absolute;
            left: 0;
            top: 0;
            bottom: 0;
            width: 4px;
            background: linear-gradient(180deg, var(--primary), #3b82f6);
            transform: scaleY(0);
            transition: transform 0.3s ease;
        }

        .service-item:hover::before {
            transform: scaleY(1);
        }

        .service-item:hover {
            background: rgba(255, 255, 255, 0.1);
            transform: translateX(8px);
        }

        .service-icon {
            width: 70px;
            height: 70px;
            background: linear-gradient(135deg, var(--primary), #3b82f6);
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            margin-right: 1.5rem;
            font-size: 1.5rem;
            color: white;
            box-shadow: 0 8px 24px rgba(37, 99, 235, 0.3);
        }

        .service-info {
            flex: 1;
        }

        .service-info h4 {
            font-weight: 600;
            font-size: 1.1rem;
            margin-bottom: 0.5rem;
            color: var(--text-primary);
        }

        .service-info p {
            color: var(--text-secondary);
            font-size: 0.9rem;
            display: flex;
            align-items: center;
            gap: 1rem;
        }

        .service-rating {
            display: flex;
            align-items: center;
            gap: 0.5rem;
            color: var(--warning);
            font-weight: 600;
            background: rgba(245, 158, 11, 0.1);
            padding: 0.5rem 1rem;
            border-radius: 25px;
        }

        /* Vehicle Section */
        .vehicle-section {
            grid-column: 1 / -1;
        }

        .vehicle-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(350px, 1fr));
            gap: 2rem;
            margin-top: 2rem;
        }

        .vehicle-card {
            background: var(--glass);
            backdrop-filter: blur(25px);
            border: 1px solid var(--glass-border);
            border-radius: 20px;
            padding: 0;
            overflow: hidden;
            transition: all 0.4s ease;
            position: relative;
        }

        .vehicle-card:hover {
            transform: translateY(-8px) scale(1.02);
            box-shadow: 0 20px 40px rgba(0, 0, 0, 0.3);
        }

        .vehicle-image {
            width: 100%;
            height: 200px;
            background: linear-gradient(135deg, var(--dark-light), var(--dark-lighter));
            position: relative;
            overflow: hidden;
        }

        .vehicle-image img {
            width: 100%;
            height: 100%;
            object-fit: cover;
            opacity: 0.8;
        }

        .vehicle-image::after {
            content: '';
            position: absolute;
            bottom: 0;
            left: 0;
            right: 0;
            height: 50%;
            background: linear-gradient(transparent, rgba(15, 23, 42, 0.8));
        }

        .vehicle-info {
            padding: 2rem;
        }

        .vehicle-header {
            display: flex;
            justify-content: space-between;
            align-items: flex-start;
            margin-bottom: 1.5rem;
        }

        .vehicle-number {
            font-size: 1.3rem;
            font-weight: 700;
            color: var(--primary);
            margin-bottom: 0.3rem;
        }

        .vehicle-model {
            color: var(--text-secondary);
            font-weight: 500;
        }

        .vehicle-status-badges {
            display: flex;
            flex-direction: column;
            gap: 0.5rem;
        }

        .vehicle-details {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 1rem;
            margin-bottom: 2rem;
            padding: 1.5rem;
            background: rgba(0, 0, 0, 0.2);
            border-radius: 12px;
        }

        .detail-item {
            display: flex;
            flex-direction: column;
            gap: 0.3rem;
        }

        .detail-label {
            font-size: 0.8rem;
            color: var(--text-muted);
            text-transform: uppercase;
            font-weight: 600;
            letter-spacing: 0.5px;
        }

        .detail-value {
            font-weight: 600;
            color: var(--text-primary);
        }

        .vehicle-actions {
            display: flex;
            gap: 1rem;
        }

        /* Buttons */
        .btn {
            padding: 0.8rem 2rem;
            border: none;
            border-radius: 12px;
            font-weight: 600;
            text-decoration: none;
            display: inline-flex;
            align-items: center;
            gap: 0.5rem;
            transition: all 0.3s ease;
            cursor: pointer;
            font-size: 0.9rem;
            position: relative;
            overflow: hidden;
        }

        .btn::before {
            content: '';
            position: absolute;
            top: 0;
            left: -100%;
            width: 100%;
            height: 100%;
            background: linear-gradient(90deg, transparent, rgba(255, 255, 255, 0.2), transparent);
            transition: left 0.5s;
        }

        .btn:hover::before {
            left: 100%;
        }

        .btn-primary {
            background: linear-gradient(135deg, var(--primary), #3b82f6);
            color: white;
            box-shadow: 0 4px 16px rgba(37, 99, 235, 0.3);
        }

        .btn-primary:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 24px rgba(37, 99, 235, 0.4);
        }

        .btn-secondary {
            background: rgba(255, 255, 255, 0.1);
            color: var(--text-primary);
            border: 1px solid var(--glass-border);
        }

        .btn-secondary:hover {
            background: var(--glass);
            transform: translateY(-2px);
        }

        .btn-small {
            padding: 0.6rem 1.5rem;
            font-size: 0.8rem;
        }

        /* Status badges */
        .status {
            padding: 0.4rem 1rem;
            border-radius: 20px;
            font-size: 0.75rem;
            font-weight: 600;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }

        .status-active {
            background: rgba(16, 185, 129, 0.2);
            color: var(--success);
            border: 1px solid rgba(16, 185, 129, 0.3);
        }

        .status-pending {
            background: rgba(245, 158, 11, 0.2);
            color: var(--warning);
            border: 1px solid rgba(245, 158, 11, 0.3);
        }

        .status-expired {
            background: rgba(239, 68, 68, 0.2);
            color: var(--danger);
            border: 1px solid rgba(239, 68, 68, 0.3);
        }

        /* Empty State */
        .empty-state {
            text-align: center;
            padding: 4rem 2rem;
            color: var(--text-secondary);
        }

        .empty-state i {
            font-size: 5rem;
            margin-bottom: 2rem;
            opacity: 0.3;
            color: var(--primary);
        }

        .empty-state h3 {
            font-size: 1.5rem;
            margin-bottom: 1rem;
            color: var(--text-primary);
        }

        /* Floating Action Button */
        .fab {
            position: fixed;
            bottom: 2.5rem;
            right: 2.5rem;
            width: 70px;
            height: 70px;
            background: linear-gradient(135deg, var(--primary), #3b82f6);
            border: none;
            border-radius: 50%;
            color: white;
            font-size: 1.8rem;
            cursor: pointer;
            box-shadow: 0 12px 32px rgba(37, 99, 235, 0.4);
            transition: all 0.3s ease;
            z-index: 999;
            display: flex;
            align-items: center;
            justify-content: center;
        }

        .fab:hover {
            transform: scale(1.15) rotate(90deg);
            box-shadow: 0 16px 40px rgba(37, 99, 235, 0.5);
        }

        /* Mobile Menu */
        .mobile-menu {
            position: fixed;
            top: 1.5rem;
            left: 1.5rem;
            z-index: 1001;
            background: linear-gradient(135deg, var(--primary), #3b82f6);
            border: none;
            color: white;
            padding: 1rem;
            border-radius: 12px;
            font-size: 1.2rem;
            cursor: pointer;
            display: none;
            box-shadow: 0 8px 24px rgba(37, 99, 235, 0.3);
        }

        /* Responsive Design */
        @media (max-width: 1200px) {
            .sidebar {
                width: 280px;
            }

            .main-content {
                margin-left: 280px;
            }
        }

        @media (max-width: 1024px) {
            .mobile-menu {
                display: block;
            }

            .sidebar {
                transform: translateX(-100%);
            }

            .sidebar.open {
                transform: translateX(0);
            }

            .main-content {
                margin-left: 0;
                padding: 1.5rem;
            }

            .content-grid {
                grid-template-columns: 1fr;
            }

            .header {
                flex-direction: column;
                gap: 1.5rem;
                text-align: center;
                padding: 2rem;
            }

            .welcome h1 {
                font-size: 2.2rem;
            }

            .stats-grid {
                grid-template-columns: repeat(2, 1fr);
            }
        }

        @media (max-width: 768px) {
            .stats-grid {
                grid-template-columns: 1fr;
            }

            .actions-grid {
                grid-template-columns: 1fr;
            }

            .welcome h1 {
                font-size: 1.8rem;
            }

            .vehicle-grid {
                grid-template-columns: 1fr;
            }

            .vehicle-details {
                grid-template-columns: 1fr;
            }

            .vehicle-actions {
                flex-direction: column;
            }
        }

        /* Animations */
        @keyframes slideInUp {
            from {
                opacity: 0;
                transform: translateY(30px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }

        @keyframes slideInLeft {
            from {
                opacity: 0;
                transform: translateX(-30px);
            }
            to {
                opacity: 1;
                transform: translateX(0);
            }
        }

        @keyframes fadeIn {
            from {
                opacity: 0;
            }
            to {
                opacity: 1;
            }
        }

        .animate-in {
            animation: slideInUp 0.6s ease forwards;
        }

        .animate-in-left {
            animation: slideInLeft 0.6s ease forwards;
        }

        .animate-fade {
            animation: fadeIn 0.8s ease forwards;
        }

        .animate-in:nth-child(2) { animation-delay: 0.1s; }
        .animate-in:nth-child(3) { animation-delay: 0.2s; }
        .animate-in:nth-child(4) { animation-delay: 0.3s; }
        .animate-in:nth-child(5) { animation-delay: 0.4s; }

        /* Loading Animation */
        .loading {
            display: inline-block;
            width: 20px;
            height: 20px;
            border: 3px solid rgba(255,255,255,.3);
            border-radius: 50%;
            border-top-color: #fff;
            animation: spin 1s ease-in-out infinite;
        }

        @keyframes spin {
            to { transform: rotate(360deg); }
        }

        /* Notification */
        .notification {
            position: fixed;
            top: 2rem;
            right: 2rem;
            background: var(--glass);
            backdrop-filter: blur(25px);
            border: 1px solid var(--glass-border);
            border-radius: 12px;
            padding: 1rem 1.5rem;
            color: var(--text-primary);
            z-index: 1002;
            transform: translateX(400px);
            transition: transform 0.3s ease;
        }

        .notification.show {
            transform: translateX(0);
        }
    </style>
</head>
<body>
    <button class="mobile-menu" onclick="toggleSidebar()">
        <i class="fas fa-bars"></i>
    </button>

    <div class="dashboard-layout">
        <!-- Sidebar -->
        <div class="sidebar" id="sidebar">
            <div class="sidebar-header">
                <div class="logo">
                    <div class="logo-icon">
                        <i class="fas fa-car"></i>
                    </div>
                    <h1>AutoSpace</h1>
                    <p>Vehicle Care Portal</p>
                </div>
            </div>

            <nav class="nav-menu">
                <div class="nav-item">
                    <a href="dashboard.jsp" class="nav-link active">
                        <i class="fas fa-home"></i>
                        <span>Dashboard</span>
                    </a>
                </div>
                <div class="nav-item">
                    <a href="myvehicles.jsp" class="nav-link">
                        <i class="fas fa-car"></i>
                        <span>My Vehicles</span>
                    </a>
                </div>
                <div class="nav-item">
                    <a href="BookingService.jsp" class="nav-link">
                        <i class="fas fa-calendar-check"></i>
                        <span>Book Service</span>
                    </a>
                </div>
                <div class="nav-item">
                    <a href="profile.jsp" class="nav-link">
                        <i class="fas fa-user"></i>
                        <span>Profile</span>
                    </a>
                </div>
               
            </nav>
        </div>

        <!-- Main Content -->
        <div class="main-content">
            <!-- Header -->
            <div class="header animate-fade">
                <div class="welcome">
                    <h1>Welcome back, <%= clientName %></h1>
                    <p>Ready to take care of your vehicles today?</p>
                </div>
                <div class="user-section">
                    <div class="user-info">
                        <div class="user-name"><%= clientName %></div>
                        <div class="user-status">
                            <i class="fas fa-circle" style="font-size: 0.6rem;"></i>
                            Online
                        </div>
                    </div>
                    <div class="user-avatar">
                        <%= clientName.substring(0, 1).toUpperCase() %>
                    </div>
                    <a href="logout" class="btn btn-secondary" onclick="return confirmLogout();">
                        <i class="fas fa-sign-out-alt"></i>
                        Logout
                    </a>
                </div>
            </div>

            <!-- Stats Grid -->
            <div class="stats-grid">
                <div class="stat-card animate-in">
                    <div class="stat-icon-container">
                        <i class="fas fa-car stat-icon"></i>
                    </div>
                    <div class="stat-number" data-target="<%= totalVehicles %>">0</div>
                    <div class="stat-label">Total Vehicles</div>
                </div>
                <div class="stat-card animate-in">
                    <div class="stat-icon-container">
                        <i class="fas fa-wrench stat-icon"></i>
                    </div>
                    <div class="stat-number" data-target="<%= serviceHistory %>">0</div>
                    <div class="stat-label">Services Completed</div>
                </div>
                <div class="stat-card animate-in">
                    <div class="stat-icon-container">
                        <i class="fas fa-exclamation-triangle stat-icon"></i>
                    </div>
                    <div class="stat-number" data-target="<%= pendingServices %>">0</div>
                    <div class="stat-label">Services Due</div>
                </div>
                <div class="stat-card animate-in">
                    <div class="stat-icon-container">
                        <i class="fas fa-star stat-icon"></i>
                    </div>
                    <div class="stat-number" data-target="4.8">0</div>
                    <div class="stat-label">Service Rating</div>
                </div>
            </div>

            <!-- Content Grid -->
            <div class="content-grid">
                <!-- Quick Actions -->
                <div class="content-card animate-in-left">
                    <div class="card-header">
                        <h3 class="card-title">Quick Actions</h3>
                        <span class="card-badge">Essential</span>
                    </div>
                    <div class="actions-grid">
                        <a href="BookingService.jsp" class="action-item">
                            <i class="fas fa-wrench"></i>
                            <span>Book Service</span>
                        </a>
                        <a href="myvehicles.jsp" class="action-item">
                            <i class="fas fa-eye"></i>
                            <span>View Vehicles</span>
                        </a>
                        <a href="profile.jsp" class="action-item">
                            <i class="fas fa-user-cog"></i>
                            <span>Update Profile</span>
                        </a>
                        <a href="BookingService.jsp" class="action-item">
                            <i class="fas fa-phone-alt"></i>
                            <span>Emergency Help</span>
                        </a>
                    </div>
                </div>

                <!-- Service Centers -->
                <div class="content-card animate-in-left">
                    <div class="card-header">
                        <h3 class="card-title">Nearby Centers</h3>
                        <span class="card-badge">3 Available</span>
                    </div>
                    <div class="service-list">
                        <div class="service-item">
                            <div class="service-icon">
                                <i class="fas fa-tools"></i>
                            </div>
                            <div class="service-info">
                                <h4>AutoCare Premium</h4>
                                <p>
                                    <i class="fas fa-map-marker-alt"></i> 2.3 km away
                                    <i class="fas fa-clock"></i> Open until 8 PM
                                </p>
                            </div>
                            <div class="service-rating">
                                <span>4.8</span>
                                <i class="fas fa-star"></i>
                            </div>
                        </div>
                        <div class="service-item">
                            <div class="service-icon">
                                <i class="fas fa-car-crash"></i>
                            </div>
                            <div class="service-info">
                                <h4>QuickFix Station</h4>
                                <p>
                                    <i class="fas fa-map-marker-alt"></i> 3.1 km away
                                    <i class="fas fa-clock"></i> 24/7 Emergency
                                </p>
                            </div>
                            <div class="service-rating">
                                <span>4.6</span>
                                <i class="fas fa-star"></i>
                            </div>
                        </div>
                        <div class="service-item">
                            <div class="service-icon">
                                <i class="fas fa-oil-can"></i>
                            </div>
                            <div class="service-info">
                                <h4>Elite Motors</h4>
                                <p>
                                    <i class="fas fa-map-marker-alt"></i> 4.7 km away
                                    <i class="fas fa-clock"></i> Luxury Service
                                </p>
                            </div>
                            <div class="service-rating">
                                <span>4.9</span>
                                <i class="fas fa-star"></i>
                            </div>
                        </div>
                    </div>
                    <div style="margin-top: 2rem;">
                        <a href="BookingService.jsp" class="btn btn-primary" style="width: 100%; justify-content: center;">
                            <i class="fas fa-calendar-check"></i>
                            Book Service Now
                        </a>
                    </div>
                </div>
            </div>

            <!-- Vehicles Section -->
            <div class="content-card vehicle-section animate-in">
                <div class="card-header">
                    <h3 class="card-title">Your Vehicle Fleet</h3>
                    <div style="display: flex; gap: 1rem; align-items: center;">
                        <span class="card-badge"><%= totalVehicles %> Vehicles</span>
                        <a href="myvehicles.jsp" class="btn btn-secondary btn-small">
                            <i class="fas fa-eye"></i>
                            View All
                        </a>
                    </div>
                </div>

                <% if (!vehicles.isEmpty()) { %>
                    <div class="vehicle-grid">
                        <%
                        // Show only first 3 vehicles in dashboard
                        int displayCount = Math.min(vehicles.size(), 3);
                        for (int i = 0; i < displayCount; i++) {
                            Map<String, Object> vehicle = vehicles.get(i);
                            java.sql.Date serviceDate = (java.sql.Date) vehicle.get("service_date");
                            java.sql.Date warrantyDate = (java.sql.Date) vehicle.get("warranty_date");
                            String model = (String) vehicle.get("model");

                            String serviceStatus = "Up to date";
                            String statusClass = "status-active";
                            if (serviceDate != null) {
                                long daysSince = (System.currentTimeMillis() - serviceDate.getTime()) / (1000 * 60 * 60 * 24);
                                if (daysSince > 180) {
                                    serviceStatus = "Service Due";
                                    statusClass = "status-pending";
                                } else if (daysSince > 150) {
                                    serviceStatus = "Due Soon";
                                    statusClass = "status-pending";
                                }
                            } else {
                                serviceStatus = "Never Serviced";
                                statusClass = "status-expired";
                            }

                            // Determine vehicle image based on model
                            String vehicleImage = "img/vehicles/xuv.jpg"; // default
                            if (model != null) {
                                if (model.toLowerCase().contains("scorpio")) {
                                    vehicleImage = "img/vehicles/scorpio.jpg";
                                } else if (model.toLowerCase().contains("thar")) {
                                    vehicleImage = "img/vehicles/thar.png";
                                } else if (model.toLowerCase().contains("xuv")) {
                                    vehicleImage = "img/vehicles/xuv.jpg";
                                }
                            }
                        %>
                        <div class="vehicle-card">
                            <div class="vehicle-image">
                                <img src="<%= vehicleImage %>" alt="<%= model %>" onerror="this.style.display='none';">
                            </div>
                            <div class="vehicle-info">
                                <div class="vehicle-header">
                                    <div>
                                        <div class="vehicle-number"><%= vehicle.get("vehicle_number") %></div>
                                        <div class="vehicle-model"><%= model %></div>
                                    </div>
                                    <div class="vehicle-status-badges">
                                        <% if (warrantyDate != null && warrantyDate.after(new java.util.Date())) { %>
                                            <span class="status status-active">Under Warranty</span>
                                        <% } else { %>
                                            <span class="status status-expired">Warranty Expired</span>
                                        <% } %>
                                        <span class="status <%= statusClass %>"><%= serviceStatus %></span>
                                    </div>
                                </div>

                                <div class="vehicle-details">
                                    <div class="detail-item">
                                        <span class="detail-label">Last Service</span>
                                        <span class="detail-value">
                                            <%= serviceDate != null ? serviceDate.toString() : "Never" %>
                                        </span>
                                    </div>
                                    <div class="detail-item">
                                        <span class="detail-label">Warranty Until</span>
                                        <span class="detail-value">
                                            <%= warrantyDate != null ? warrantyDate.toString() : "Expired" %>
                                        </span>
                                    </div>
                                    <div class="detail-item">
                                        <span class="detail-label">Registration</span>
                                        <span class="detail-value">
                                            <%= vehicle.get("registration_date") != null ?
                                                ((java.sql.Date) vehicle.get("registration_date")).toString() : "N/A" %>
                                        </span>
                                    </div>
                                    <div class="detail-item">
                                        <span class="detail-label">Next Service</span>
                                        <span class="detail-value">
                                            <% if (serviceDate != null) {
                                                long daysSince = (System.currentTimeMillis() - serviceDate.getTime()) / (1000 * 60 * 60 * 24);
                                                long daysUntilNext = 180 - daysSince;
                                                if (daysUntilNext <= 0) {
                                                    out.print("Overdue");
                                                } else {
                                                    out.print("In " + daysUntilNext + " days");
                                                }
                                            } else {
                                                out.print("Schedule now");
                                            } %>
                                        </span>
                                    </div>
                                </div>

                                <div class="vehicle-actions">
                                    <a href="BookingService.jsp" class="btn btn-primary btn-small" style="flex: 1;">
                                        <i class="fas fa-calendar-plus"></i>
                                        Book Service
                                    </a>
                                    <a href="myvehicles.jsp" class="btn btn-secondary btn-small">
                                        <i class="fas fa-info-circle"></i>
                                        Details
                                    </a>
                                </div>
                            </div>
                        </div>
                        <% } %>

                        <% if (vehicles.size() > 3) { %>
                        <div class="vehicle-card" style="display: flex; align-items: center; justify-content: center; min-height: 400px; border: 2px dashed var(--glass-border);">
                            <div style="text-align: center;">
                                <i class="fas fa-plus-circle" style="font-size: 3rem; color: var(--primary); margin-bottom: 1rem;"></i>
                                <h4 style="margin-bottom: 1rem; color: var(--text-primary);">
                                    <%= vehicles.size() - 3 %> More Vehicle<%= vehicles.size() - 3 > 1 ? "s" : "" %>
                                </h4>
                                <a href="myvehicles.jsp" class="btn btn-primary">
                                    <i class="fas fa-eye"></i>
                                    View All Vehicles
                                </a>
                            </div>
                        </div>
                        <% } %>
                    </div>
                <% } else { %>
                    <div class="empty-state">
                        <i class="fas fa-car"></i>
                        <h3>No vehicles registered yet</h3>
                        <p>Contact your administrator to add your vehicles to the system</p>
                        <div style="margin-top: 2rem;">
                            <a href="profile.jsp" class="btn btn-primary">
                                <i class="fas fa-phone"></i>
                                Contact Support
                            </a>
                        </div>
                    </div>
                <% } %>
            </div>
        </div>
    </div>

    <!-- Floating Action Button -->
    <button class="fab" onclick="location.href='BookingService.jsp'" title="Quick Book Service">
        <i class="fas fa-plus"></i>
    </button>

    <!-- Notification -->
    <div class="notification" id="notification">
        <div style="display: flex; align-items: center; gap: 1rem;">
            <i class="fas fa-check-circle" style="color: var(--success);"></i>
            <span>Welcome to AutoSpace Dashboard!</span>
        </div>
    </div>

    <script>
        // Security and Session Management
        window.history.pushState(null, null, window.location.href);
        window.onpopstate = function(event) {
            window.history.pushState(null, null, window.location.href);
        };

        // Prevent browser back button
        window.addEventListener('beforeunload', function (e) {
            e.preventDefault();
            e.returnValue = '';
        });

        // Sidebar Toggle
        function toggleSidebar() {
            const sidebar = document.getElementById('sidebar');
            sidebar.classList.toggle('open');
        }

        // Close sidebar when clicking outside on mobile
        document.addEventListener('click', function(event) {
            const sidebar = document.getElementById('sidebar');
            const mobileMenu = document.querySelector('.mobile-menu');

            if (window.innerWidth <= 1024) {
                if (!sidebar.contains(event.target) && !mobileMenu.contains(event.target)) {
                    sidebar.classList.remove('open');
                }
            }
        });

        // Logout Confirmation
        function confirmLogout() {
            return confirm('Are you sure you want to logout?');
        }

        // Animate Numbers
        function animateNumbers() {
            const numbers = document.querySelectorAll('.stat-number[data-target]');

            numbers.forEach(number => {
                const target = parseFloat(number.getAttribute('data-target'));
                const duration = 2000; // 2 seconds
                const increment = target / (duration / 16); // 60fps
                let current = 0;

                const timer = setInterval(() => {
                    current += increment;
                    if (current >= target) {
                        current = target;
                        clearInterval(timer);
                    }

                    // Handle decimal numbers
                    if (target % 1 !== 0) {
                        number.textContent = current.toFixed(1);
                    } else {
                        number.textContent = Math.floor(current);
                    }
                }, 16);
            });
        }

        // Show Welcome Notification
        function showWelcomeNotification() {
            const notification = document.getElementById('notification');
            notification.classList.add('show');

            setTimeout(() => {
                notification.classList.remove('show');
            }, 5000);
        }

        // Initialize Dashboard
        document.addEventListener('DOMContentLoaded', function() {
            // Start number animation after a short delay
            setTimeout(animateNumbers, 500);

            // Show welcome notification
            setTimeout(showWelcomeNotification, 1000);

            // Auto-refresh data every 5 minutes
            setInterval(function() {
                // You can add AJAX calls here to refresh data
                console.log('Refreshing dashboard data...');
            }, 300000);
        });

        // Handle window resize
        window.addEventListener('resize', function() {
            const sidebar = document.getElementById('sidebar');
            if (window.innerWidth > 1024) {
                sidebar.classList.remove('open');
            }
        });

        // Add loading state to buttons
        document.querySelectorAll('.btn').forEach(button => {
            button.addEventListener('click', function(e) {
                if (this.href && this.href.includes('.jsp')) {
                    const originalText = this.innerHTML;
                    this.innerHTML = '<span class="loading"></span> Loading...';
                    this.style.pointerEvents = 'none';

                    // Restore button after 3 seconds (failsafe)
                    setTimeout(() => {
                        this.innerHTML = originalText;
                        this.style.pointerEvents = '';
                    }, 3000);
                }
            });
        });

        // Keyboard shortcuts
        document.addEventListener('keydown', function(e) {
            // Ctrl + B for book service
            if (e.ctrlKey && e.key === 'b') {
                e.preventDefault();
                window.location.href = 'BookingService.jsp';
            }

            // Ctrl + V for view vehicles
            if (e.ctrlKey && e.key === 'v') {
                e.preventDefault();
                window.location.href = 'myvehicles.jsp';
            }

            // Ctrl + P for profile
            if (e.ctrlKey && e.key === 'p') {
                e.preventDefault();
                window.location.href = 'profile.jsp';
            }
        });

        // Add smooth scrolling
        document.querySelectorAll('a[href^="#"]').forEach(anchor => {
            anchor.addEventListener('click', function (e) {
                e.preventDefault();
                document.querySelector(this.getAttribute('href')).scrollIntoView({
                    behavior: 'smooth'
                });
            });
        });
    </script>
</body>
</html>