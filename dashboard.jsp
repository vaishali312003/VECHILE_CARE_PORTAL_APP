<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Your Space - Automotive Dashboard</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #0f0f23 0%, #1a1a2e 50%, #16213e 100%);
            background-image: url('img/bg/gradient_overlay.jpg');
            background-blend-mode: overlay;
            background-size: cover;
            background-attachment: fixed;
            color: #ffffff;
            min-height: 100vh;
            overflow-x: hidden;
        }

        .dashboard-container {
            display: grid;
            grid-template-columns: 250px 1fr;
            min-height: 100vh;
        }

        /* Sidebar */
        .sidebar {
            background: rgba(15, 15, 35, 0.9);
            backdrop-filter: blur(10px);
            border-right: 1px solid rgba(255, 255, 255, 0.1);
            padding: 2rem 1rem;
        }

        .logo {
            font-size: 1.5rem;
            font-weight: bold;
            color: #ff9500;
            margin-bottom: 2rem;
            text-align: center;
        }

        .nav-menu {
            list-style: none;
        }

        .nav-item {
            margin-bottom: 0.5rem;
        }

        .nav-link {
            display: flex;
            align-items: center;
            padding: 1rem;
            color: #b0b0b0;
            text-decoration: none;
            border-radius: 10px;
            transition: all 0.3s ease;
        }

        .nav-link:hover, .nav-link.active {
            background: rgba(255, 149, 0, 0.1);
            color: #ff9500;
            transform: translateX(5px);
        }

        .nav-icon {
            width: 20px;
            height: 20px;
            margin-right: 10px;
            background-size: contain;
        }

        .nav-icon.dashboard { background-image: url('img/icon/dashboard_icon.png'); }
        .nav-icon.vehicle { background-image: url('img/icon/fue_gauge_icon.png'); }
        .nav-icon.service { background-image: url('img/icon/servicecentre_icon.png'); }
        .nav-icon.booking { background-image: url('img/icon/wrenc_tool_icon.png'); }
        .nav-icon.profile { background-image: url('img/icon/profile_icon.png'); }

        /* Main Content */
        .main-content {
            padding: 2rem;
            overflow-y: auto;
        }

        .header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 2rem;
        }

        .welcome-text {
            font-size: 2rem;
            font-weight: 300;
            color: #ff9500;
        }

        .user-info {
            display: flex;
            align-items: center;
            gap: 1rem;
        }

        .user-avatar {
            width: 50px;
            height: 50px;
            border-radius: 50%;
            background: url('img/icon/profile_icon.png') center/cover;
            border: 2px solid #ff9500;
        }

        .stats-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 1rem;
            margin-bottom: 2rem;
        }

        .stat-card {
            background: rgba(22, 33, 62, 0.6);
            backdrop-filter: blur(10px);
            border: 1px solid rgba(255, 255, 255, 0.1);
            border-radius: 15px;
            padding: 1.5rem;
            text-align: center;
            transition: transform 0.3s ease, box-shadow 0.3s ease;
            position: relative;
            overflow: hidden;
        }

        .stat-card::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            height: 3px;
            background: linear-gradient(90deg, #ff9500, #ff6b35);
        }

        .stat-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 10px 30px rgba(255, 149, 0, 0.2);
        }

        .stat-number {
            font-size: 2rem;
            font-weight: bold;
            color: #ff9500;
        }

        .stat-label {
            color: #b0b0b0;
            margin-top: 0.5rem;
        }

        /* Cards Grid */
        .cards-container {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(350px, 1fr));
            gap: 2rem;
            margin-bottom: 2rem;
        }

        .feature-card {
            background: rgba(22, 33, 62, 0.8);
            backdrop-filter: blur(15px);
            border: 1px solid rgba(255, 255, 255, 0.1);
            border-radius: 20px;
            padding: 2rem;
            position: relative;
            overflow: hidden;
            transition: all 0.3s ease;
        }

        .feature-card:hover {
            transform: scale(1.02);
            box-shadow: 0 20px 40px rgba(0, 0, 0, 0.3);
        }

        .feature-card::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            height: 3px;
            background: linear-gradient(90deg, #ff9500, #ff6b35);
        }

        .card-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 1rem;
        }

        .card-title {
            font-size: 1.2rem;
            font-weight: 600;
            color: #ffffff;
        }

        .card-badge {
            background: #ff9500;
            color: #000;
            padding: 0.3rem 0.8rem;
            border-radius: 20px;
            font-size: 0.8rem;
            font-weight: 600;
        }

        .vehicle-image {
            width: 100%;
            height: 200px;
            background: linear-gradient(45deg, #2a2a3e, #3a3a5e);
            border-radius: 15px;
            margin-bottom: 1rem;
            position: relative;
            overflow: hidden;
        }

        .vehicle-image img {
            width: 100%;
            height: 100%;
            object-fit: cover;
            border-radius: 15px;
        }

        .vehicle-details {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 1rem;
            margin-bottom: 1rem;
        }

        .detail-item {
            display: flex;
            flex-direction: column;
        }

        .detail-label {
            color: #b0b0b0;
            font-size: 0.8rem;
            margin-bottom: 0.2rem;
        }

        .detail-value {
            color: #ffffff;
            font-weight: 600;
        }

        .action-buttons {
            display: flex;
            gap: 1rem;
            margin-top: 1rem;
        }

        .btn {
            padding: 0.8rem 1.5rem;
            border: none;
            border-radius: 25px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s ease;
            text-decoration: none;
            display: inline-flex;
            align-items: center;
            justify-content: center;
        }

        .btn-primary {
            background: linear-gradient(45deg, #ff9500, #ff6b35);
            color: #000;
        }

        .btn-primary:hover {
            transform: translateY(-2px);
            box-shadow: 0 10px 20px rgba(255, 149, 0, 0.3);
        }

        .btn-secondary {
            background: rgba(255, 255, 255, 0.1);
            color: #ffffff;
            border: 1px solid rgba(255, 255, 255, 0.2);
        }

        .btn-secondary:hover {
            background: rgba(255, 255, 255, 0.2);
        }

        /* Service Station Card */
        .service-card {
            background: rgba(26, 26, 46, 0.8);
            border-radius: 20px;
            padding: 1.5rem;
            margin-bottom: 1rem;
            background-image: url('img/service_station/clean_env.jpg');
            background-size: cover;
            background-position: center;
            background-blend-mode: overlay;
        }

        .service-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 1rem;
        }

        .service-name {
            font-weight: 600;
            color: #ffffff;
        }

        .service-rating {
            display: flex;
            align-items: center;
            gap: 0.5rem;
            color: #ff9500;
        }

        .service-rating img {
            width: 16px;
            height: 16px;
        }

        .service-details {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 1rem;
            margin-bottom: 1rem;
        }

        .floating-elements {
            position: fixed;
            top: 50%;
            right: 2rem;
            transform: translateY(-50%);
            display: flex;
            flex-direction: column;
            gap: 1rem;
        }

        .floating-btn {
            width: 60px;
            height: 60px;
            border-radius: 50%;
            background: linear-gradient(45deg, #ff9500, #ff6b35);
            border: none;
            color: #000;
            font-size: 1.5rem;
            cursor: pointer;
            box-shadow: 0 10px 20px rgba(255, 149, 0, 0.3);
            transition: all 0.3s ease;
        }

        .floating-btn:hover {
            transform: scale(1.1);
        }

        .quick-actions-grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 1rem;
        }

        .quick-action-item {
            background: rgba(255, 255, 255, 0.1);
            border-radius: 15px;
            padding: 1.5rem;
            text-align: center;
            transition: all 0.3s ease;
            cursor: pointer;
        }

        .quick-action-item:hover {
            background: rgba(255, 149, 0, 0.1);
            transform: translateY(-3px);
        }

        .quick-action-icon {
            width: 40px;
            height: 40px;
            margin: 0 auto 10px;
            background-size: contain;
        }

        .fuel-icon { background-image: url('img/icon/fue_gauge_icon.png'); }
        .location-icon { background-image: url('img/icon/location_pin.png'); }
        .service-icon { background-image: url('img/icon/servicecentre_icon.png'); }
        .gear-icon { background-image: url('img/icon/gear-settings_icon.png'); }

        @media (max-width: 768px) {
            .dashboard-container {
                grid-template-columns: 1fr;
            }

            .sidebar {
                display: none;
            }

            .cards-container {
                grid-template-columns: 1fr;
            }

            .stats-grid {
                grid-template-columns: repeat(2, 1fr);
            }
        }
    </style>
</head>
<body>
    <div class="dashboard-container">
        <!-- Sidebar -->
        <div class="sidebar">
            <div class="logo">Your Space</div>
            <ul class="nav-menu">
                <li class="nav-item">
                    <a href="dashboard.jsp" class="nav-link active">
                        <div class="nav-icon dashboard"></div>
                        Dashboard
                    </a>
                </li>
                <li class="nav-item">
                    <a href="#" class="nav-link">
                        <div class="nav-icon vehicle"></div>
                        My Vehicles
                    </a>
                </li>
                <li class="nav-item">
                    <a href="#" class="nav-link">
                        <div class="nav-icon service"></div>
                        Service Centers
                    </a>
                </li>
                <li class="nav-item">
                    <a href="#" class="nav-link">
                        <div class="nav-icon booking"></div>
                        Bookings
                    </a>
                </li>
                <li class="nav-item">
                    <a href="#" class="nav-link">
                        <div class="nav-icon profile"></div>
                        Profile
                    </a>
                </li>
            </ul>
        </div>

        <!-- Main Content -->
        <div class="main-content">
            <div class="header">
                <h1 class="welcome-text">Welcome back, ${sessionScope.clientName != null ? sessionScope.clientName : 'Client'}</h1>
                <div class="user-info">
                    <div class="user-avatar"></div>
                    <a href="LogoutServlet" class="btn btn-secondary">Logout</a>
                </div>
            </div>

            <!-- Stats Grid -->
            <div class="stats-grid">
                <div class="stat-card">
                    <div class="stat-number" data-target="3">0</div>
                    <div class="stat-label">Active Vehicles</div>
                </div>
                <div class="stat-card">
                    <div class="stat-number" data-target="12">0</div>
                    <div class="stat-label">Service History</div>
                </div>
                <div class="stat-card">
                    <div class="stat-number" data-target="2">0</div>
                    <div class="stat-label">Pending Services</div>
                </div>
                <div class="stat-card">
                    <div class="stat-number" data-target="8">0</div>
                    <div class="stat-label">Avg Rating</div>
                </div>
            </div>

            <!-- Feature Cards -->
            <div class="cards-container">
                <!-- Vehicle Card 1 -->
                <div class="feature-card">
                    <div class="card-header">
                        <h3 class="card-title">Mahindra Thar</h3>
                        <span class="card-badge">Active</span>
                    </div>
                    <div class="vehicle-image">
                        <img src="img/vehicles/thar.png" alt="Mahindra Thar" onerror="this.src='img/bg/Abstract car silhouettes.jpg'">
                    </div>
                    <div class="vehicle-details">
                        <div class="detail-item">
                            <span class="detail-label">Registration</span>
                            <span class="detail-value">MH 12 AB 1234</span>
                        </div>
                        <div class="detail-item">
                            <span class="detail-label">Last Service</span>
                            <span class="detail-value">15 Days Ago</span>
                        </div>
                        <div class="detail-item">
                            <span class="detail-label">Next Service</span>
                            <span class="detail-value">2 Months</span>
                        </div>
                        <div class="detail-item">
                            <span class="detail-label">Fuel Status</span>
                            <span class="detail-value">75%</span>
                        </div>
                    </div>
                    <div class="action-buttons">
                        <a href="#" class="btn btn-primary">Book Service</a>
                        <a href="#" class="btn btn-secondary">View Details</a>
                    </div>
                </div>

                <!-- Service Center Card -->
                <div class="feature-card">
                    <div class="card-header">
                        <h3 class="card-title">Nearby Service Centers</h3>
                        <span class="card-badge">3 Found</span>
                    </div>

                    <div class="service-card">
                        <div class="service-header">
                            <span class="service-name">AutoCare Station</span>
                            <div class="service-rating">
                                <span>4.8</span>
                                <img src="img/icon/star_rating.png" alt="Star">
                            </div>
                        </div>
                        <div class="service-details">
                            <div class="detail-item">
                                <span class="detail-label">Distance</span>
                                <span class="detail-value">2.3 km</span>
                            </div>
                            <div class="detail-item">
                                <span class="detail-label">Wait Time</span>
                                <span class="detail-value">30 min</span>
                            </div>
                            <div class="detail-item">
                                <span class="detail-label">Status</span>
                                <span class="detail-value">Open</span>
                            </div>
                        </div>
                    </div>

                    <div class="action-buttons">
                        <a href="#" class="btn btn-primary">Book Now</a>
                        <a href="#" class="btn btn-secondary">View All</a>
                    </div>
                </div>

                <!-- Quick Actions Card -->
                <div class="feature-card">
                    <div class="card-header">
                        <h3 class="card-title">Quick Actions</h3>
                    </div>
                    <div class="quick-actions-grid">
                        <div class="quick-action-item" onclick="location.href='AddVehicleServlet'">
                            <div class="quick-action-icon fuel-icon"></div>
                            <span>Add Vehicle</span>
                        </div>
                        <div class="quick-action-item">
                            <div class="quick-action-icon service-icon"></div>
                            <span>Emergency Service</span>
                        </div>
                        <div class="quick-action-item">
                            <div class="quick-action-icon location-icon"></div>
                            <span>Find Parking</span>
                        </div>
                        <div class="quick-action-item">
                            <div class="quick-action-icon gear-icon"></div>
                            <span>Fuel Stations</span>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Floating Action Buttons -->
    <div class="floating-elements">
        <button class="floating-btn" title="Add Vehicle" onclick="location.href='AddVehicleServlet'">+</button>
        <button class="floating-btn" title="Emergency">🚨</button>
    </div>

    <script>
        // Add interactive animations
        document.addEventListener('DOMContentLoaded', function() {
            // Animate stats on load
            const statNumbers = document.querySelectorAll('.stat-number');
            statNumbers.forEach(stat => {
                const finalValue = parseInt(stat.getAttribute('data-target'));
                let currentValue = 0;
                const increment = finalValue / 50;

                const counter = setInterval(() => {
                    currentValue += increment;
                    if (currentValue >= finalValue) {
                        stat.textContent = finalValue;
                        clearInterval(counter);
                    } else {
                        stat.textContent = Math.floor(currentValue);
                    }
                }, 30);
            });

            // Add hover effects to cards
            const cards = document.querySelectorAll('.feature-card');
            cards.forEach(card => {
                card.addEventListener('mouseenter', function() {
                    this.style.transform = 'scale(1.02) rotateY(2deg)';
                });

                card.addEventListener('mouseleave', function() {
                    this.style.transform = 'scale(1) rotateY(0deg)';
                });
            });

            // Floating button animations
            const floatingBtns = document.querySelectorAll('.floating-btn');
            floatingBtns.forEach((btn, index) => {
                btn.style.animationDelay = `${index * 0.1}s`;
                btn.addEventListener('click', function() {
                    this.style.transform = 'scale(0.9)';
                    setTimeout(() => {
                        this.style.transform = 'scale(1.1)';
                    }, 100);
                });
            });

            // Quick action items hover effect
            const quickActions = document.querySelectorAll('.quick-action-item');
            quickActions.forEach(action => {
                action.addEventListener('mouseenter', function() {
                    this.style.transform = 'translateY(-5px) scale(1.05)';
                });

                action.addEventListener('mouseleave', function() {
                    this.style.transform = 'translateY(0) scale(1)';
                });
            });
        });
    </script>
</body>
</html>