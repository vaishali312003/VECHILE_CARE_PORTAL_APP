<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta http-equiv="Cache-Control" content="no-cache, no-store, must-revalidate">
    <meta http-equiv="Pragma" content="no-cache">
    <meta http-equiv="Expires" content="0">
    <title>Vehicle Care App - Your Trusted Car Service Partner</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            line-height: 1.6;
            color: #333;
            overflow-x: hidden;
        }

        /* Hero Section */
        .hero {
            height: 100vh;
            background: linear-gradient(135deg, rgba(0, 0, 0, 0.7), rgba(0, 188, 212, 0.6)),
                        url('img/bg/Abstract car silhouettes.jpg') center/cover;
            display: flex;
            flex-direction: column;
            justify-content: center;
            align-items: center;
            text-align: center;
            color: white;
            position: relative;
        }

        /* Animated Background Elements */
        .hero::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            background: radial-gradient(circle at 30% 80%, rgba(0, 188, 212, 0.1) 0%, transparent 50%),
                        radial-gradient(circle at 80% 20%, rgba(255, 193, 7, 0.1) 0%, transparent 50%);
            animation: pulse 4s ease-in-out infinite alternate;
        }

        @keyframes pulse {
            0% { opacity: 0.5; }
            100% { opacity: 1; }
        }

        /* Navigation */
        .navbar {
            position: fixed;
            top: 0;
            width: 100%;
            background: rgba(0, 0, 0, 0.95);
            backdrop-filter: blur(10px);
            padding: 15px 0;
            z-index: 1000;
            transition: all 0.3s ease;
        }

        .nav-container {
            max-width: 1200px;
            margin: 0 auto;
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 0 20px;
        }

        .logo {
            display: flex;
            align-items: center;
            gap: 12px;
            font-size: 24px;
            font-weight: 700;
            color: #00bcd4;
        }

        .logo img {
            width: 40px;
            height: 40px;
            filter: drop-shadow(0 0 10px rgba(0, 188, 212, 0.5));
        }

        .nav-links {
            display: flex;
            list-style: none;
            gap: 30px;
        }

        .nav-links a {
            color: white;
            text-decoration: none;
            font-weight: 500;
            transition: color 0.3s ease;
            position: relative;
        }

        .nav-links a:hover {
            color: #00bcd4;
        }

        .nav-links a::after {
            content: '';
            position: absolute;
            bottom: -5px;
            left: 0;
            width: 0;
            height: 2px;
            background: #00bcd4;
            transition: width 0.3s ease;
        }

        .nav-links a:hover::after {
            width: 100%;
        }

        /* Hero Content */
        .hero-content {
            max-width: 800px;
            padding: 0 20px;
            z-index: 2;
            position: relative;
        }

        .hero-title {
            font-size: 3.5rem;
            font-weight: 800;
            margin-bottom: 20px;
            background: linear-gradient(45deg, #00bcd4, #ffc107);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            background-clip: text;
            animation: slideInUp 1s ease-out;
        }

        .hero-subtitle {
            font-size: 1.3rem;
            margin-bottom: 40px;
            color: #e0e0e0;
            animation: slideInUp 1s ease-out 0.2s both;
        }

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

        /* Action Buttons */
        .action-buttons {
            display: flex;
            justify-content: center;
            gap: 25px;
            margin-top: 50px;
            flex-wrap: wrap;
            animation: slideInUp 1s ease-out 0.4s both;
        }

        .action-btn {
            display: flex;
            flex-direction: column;
            align-items: center;
            padding: 25px 30px;
            background: rgba(255, 255, 255, 0.1);
            backdrop-filter: blur(10px);
            border: 2px solid rgba(0, 188, 212, 0.3);
            border-radius: 20px;
            color: white;
            text-decoration: none;
            transition: all 0.4s cubic-bezier(0.4, 0, 0.2, 1);
            min-width: 180px;
            position: relative;
            overflow: hidden;
        }

        .action-btn::before {
            content: '';
            position: absolute;
            top: 0;
            left: -100%;
            width: 100%;
            height: 100%;
            background: linear-gradient(90deg, transparent, rgba(255, 255, 255, 0.2), transparent);
            transition: left 0.6s;
        }

        .action-btn:hover::before {
            left: 100%;
        }

        .action-btn:hover {
            background: rgba(0, 188, 212, 0.2);
            border-color: #00bcd4;
            transform: translateY(-8px);
            box-shadow: 0 15px 40px rgba(0, 188, 212, 0.4);
        }

        .action-btn img {
            width: 48px;
            height: 48px;
            margin-bottom: 15px;
            filter: drop-shadow(0 0 10px rgba(255, 255, 255, 0.3));
            transition: transform 0.3s ease;
        }

        .action-btn:hover img {
            transform: scale(1.1) rotate(5deg);
        }

        .btn-title {
            font-size: 1.2rem;
            font-weight: 600;
            margin-bottom: 8px;
        }

        .btn-subtitle {
            font-size: 0.9rem;
            color: #b0bec5;
            text-align: center;
        }

        /* Services Section */
        .services {
            padding: 100px 20px;
            background: linear-gradient(135deg, #f5f7fa 0%, #c3cfe2 100%);
        }

        .services-container {
            max-width: 1200px;
            margin: 0 auto;
            text-align: center;
        }

        .services h2 {
            font-size: 2.8rem;
            color: #333;
            margin-bottom: 20px;
            position: relative;
        }

        .services h2::after {
            content: '';
            position: absolute;
            bottom: -10px;
            left: 50%;
            transform: translateX(-50%);
            width: 100px;
            height: 4px;
            background: linear-gradient(45deg, #00bcd4, #ffc107);
            border-radius: 2px;
        }

        .services-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
            gap: 30px;
            margin-top: 60px;
        }

        .service-card {
            background: white;
            padding: 40px 30px;
            border-radius: 20px;
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.1);
            transition: all 0.3s ease;
            position: relative;
            overflow: hidden;
        }

        .service-card::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 4px;
            background: linear-gradient(45deg, #00bcd4, #ffc107);
        }

        .service-card:hover {
            transform: translateY(-10px);
            box-shadow: 0 20px 50px rgba(0, 188, 212, 0.2);
        }

        .service-card img {
            width: 60px;
            height: 60px;
            margin-bottom: 20px;
            filter: drop-shadow(0 0 10px rgba(0, 188, 212, 0.3));
        }

        .service-card h3 {
            font-size: 1.5rem;
            color: #333;
            margin-bottom: 15px;
        }

        .service-card p {
            color: #666;
            line-height: 1.6;
        }

        /* User Guide Section */
        .user-guide {
            padding: 80px 20px;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            text-align: center;
        }

        .guide-btn {
            display: inline-flex;
            align-items: center;
            gap: 15px;
            padding: 20px 40px;
            background: rgba(255, 255, 255, 0.15);
            border: 2px solid rgba(255, 255, 255, 0.3);
            border-radius: 50px;
            color: white;
            text-decoration: none;
            font-size: 1.1rem;
            font-weight: 600;
            transition: all 0.3s ease;
            margin-top: 30px;
        }

        .guide-btn:hover {
            background: rgba(255, 255, 255, 0.25);
            transform: translateY(-3px);
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.2);
        }

        .guide-btn img {
            width: 30px;
            height: 30px;
        }

        /* Contact Footer */
        .footer {
            background: linear-gradient(135deg, #2c3e50 0%, #34495e 100%);
            color: white;
            padding: 60px 20px 40px;
        }

        .footer-container {
            max-width: 1200px;
            margin: 0 auto;
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 40px;
        }

        .footer-section h3 {
            color: #00bcd4;
            margin-bottom: 20px;
            font-size: 1.3rem;
        }

        .footer-section p {
            margin-bottom: 10px;
            color: #bdc3c7;
        }

        .footer-section i {
            color: #00bcd4;
            margin-right: 10px;
        }

        .footer-bottom {
            text-align: center;
            padding-top: 30px;
            margin-top: 30px;
            border-top: 1px solid #34495e;
            color: #95a5a6;
        }

        /* Responsive Design */
        @media (max-width: 768px) {
            .hero-title {
                font-size: 2.5rem;
            }

            .hero-subtitle {
                font-size: 1.1rem;
            }

            .action-buttons {
                gap: 15px;
            }

            .action-btn {
                min-width: 150px;
                padding: 20px 25px;
            }

            .nav-links {
                display: none;
            }

            .services h2 {
                font-size: 2.2rem;
            }
        }

        @media (max-width: 480px) {
            .hero-title {
                font-size: 2rem;
            }

            .action-buttons {
                flex-direction: column;
                align-items: center;
            }

            .action-btn {
                width: 250px;
            }
        }

        /* Scroll Animations */
        .fade-in {
            opacity: 0;
            transform: translateY(20px);
            transition: all 0.6s ease;
        }

        .fade-in.visible {
            opacity: 1;
            transform: translateY(0);
        }
    </style>
</head>
<body>
    <!-- Navigation -->
    <nav class="navbar">
        <div class="nav-container">
            <div class="logo">
                <img src="img/icon/dashboard_icon.png" alt="Vehicle Care App Logo">
                <span>Vehicle Care App</span>
            </div>
            <ul class="nav-links">
                <li><a href="#home">Home</a></li>
                <li><a href="#services">Services</a></li>
                <li><a href="#contact">Contact</a></li>
            </ul>
        </div>
    </nav>

    <!-- Hero Section -->
    <section class="hero" id="home">
        <div class="hero-content">
            <h1 class="hero-title">Vehicle Care App</h1>
            <p class="hero-subtitle">Your trusted partner for comprehensive vehicle maintenance and care. Experience professional service with cutting-edge technology.</p>

            <div class="action-buttons">
                <a href="clientRegister.jsp" class="action-btn">
                    <img src="img/icon/profile_icon.png" alt="Register">
                    <div class="btn-title">Register</div>
                    <div class="btn-subtitle">Create your account</div>
                </a>

                <a href="login.jsp" class="action-btn">
                    <img src="img/icon/gear-settings_icon.png" alt="Client Login">
                    <div class="btn-title">Client Portal</div>
                    <div class="btn-subtitle">Access your dashboard</div>
                </a>

                <a href="adminLogin.jsp" class="action-btn">
                    <img src="img/icon/servicecentre_icon.png" alt="Admin Login">
                    <div class="btn-title">Admin Panel</div>
                    <div class="btn-subtitle">Service management</div>
                </a>
            </div>
        </div>
    </section>

    <!-- Services Section -->
    <section class="services fade-in" id="services">
        <div class="services-container">
            <h2>Our Premium Services</h2>
            <p style="font-size: 1.1rem; color: #666; margin-bottom: 20px;">Professional automotive care with state-of-the-art equipment</p>

            <div class="services-grid">
                <div class="service-card">
                    <img src="img/icon/wrenc_tool_icon.png" alt="Maintenance">
                    <h3>Regular Maintenance</h3>
                    <p>Comprehensive vehicle inspection and maintenance services to keep your car running smoothly and efficiently.</p>
                </div>

                <div class="service-card">
                    <img src="img/icon/fue_gauge_icon.png" alt="Diagnostics">
                    <h3>Advanced Diagnostics</h3>
                    <p>Modern diagnostic equipment to identify and resolve issues quickly, ensuring optimal vehicle performance.</p>
                </div>

                <div class="service-card">
                    <img src="img/icon/star_rating.png" alt="Quality Service">
                    <h3>Quality Assurance</h3>
                    <p>Certified technicians and quality parts ensure your vehicle receives the best care with guaranteed satisfaction.</p>
                </div>
            </div>
        </div>
    </section>

    <!-- User Guide Section -->
    <section class="user-guide fade-in">
        <div class="services-container">
            <h2>Need Help Getting Started?</h2>
            <p style="font-size: 1.1rem; margin-bottom: 20px;">Learn how to make the most of our Vehicle Care App</p>

            <a href="userguide.jsp" class="guide-btn">
                <img src="img/icon/profile_icon.png" alt="User Guide">
                <span>View User Guide</span>
            </a>
        </div>
    </section>

    <!-- Contact Footer -->
    <footer class="footer fade-in" id="contact">
        <div class="footer-container">
            <div class="footer-section">
                <h3>📍 Visit Us</h3>
                <p>Vehicle Care App Center</p>
                <p>Dehradun, Uttarakhand, India</p>
            </div>

            <div class="footer-section">
                <h3>📞 Contact Info</h3>
                <p>📧 support@vehiclecareapp.com</p>
                <p>☎️ +91 98765 43210</p>
            </div>

            <div class="footer-section">
                <h3>🕐 Business Hours</h3>
                <p>Monday - Saturday</p>
                <p>9:00 AM - 7:00 PM</p>
            </div>

            <div class="footer-section">
                <h3>⭐ Why Choose Us</h3>
                <p>✓ Expert Technicians</p>
                <p>✓ Modern Equipment</p>
                <p>✓ Quality Guaranteed</p>
            </div>
        </div>

        <div class="footer-bottom">
            <p>&copy; 2025 Vehicle Care App. All rights reserved. | Dehradun, India</p>
        </div>
    </footer>

    <script>
        // Clear session on back navigation
        if (performance.navigation.type === performance.navigation.TYPE_BACK_FORWARD) {
            window.location.replace(window.location.href);
        }

        // Smooth scrolling for navigation links
        document.querySelectorAll('a[href^="#"]').forEach(anchor => {
            anchor.addEventListener('click', function (e) {
                e.preventDefault();
                const target = document.querySelector(this.getAttribute('href'));
                if (target) {
                    target.scrollIntoView({
                        behavior: 'smooth',
                        block: 'start'
                    });
                }
            });
        });

        // Scroll animations
        const observerOptions = {
            threshold: 0.1,
            rootMargin: '0px 0px -50px 0px'
        };

        const observer = new IntersectionObserver(function(entries) {
            entries.forEach(entry => {
                if (entry.isIntersecting) {
                    entry.target.classList.add('visible');
                }
            });
        }, observerOptions);

        document.querySelectorAll('.fade-in').forEach(el => {
            observer.observe(el);
        });

        // Navbar scroll effect
        window.addEventListener('scroll', function() {
            const navbar = document.querySelector('.navbar');
            if (window.scrollY > 100) {
                navbar.style.background = 'rgba(0, 0, 0, 0.98)';
            } else {
                navbar.style.background = 'rgba(0, 0, 0, 0.95)';
            }
        });
    </script>
</body>
</html>