#!/bin/bash

# Raspi Webhost Manager Installation Script
# Made with ❤️ by Paulify Development

echo "🚀 Starting Raspi Webhost Manager Installation..."

# Check if running as root
if [ "$EUID" -ne 0 ]; then
  echo "❌ Please run as root (use sudo)"
  exit 1
fi

# Update system
echo "📦 Updating system packages..."
apt update
apt upgrade -y

# Install dependencies
echo "📦 Installing required packages..."
apt install -y apache2 php libapache2-mod-php php-curl php-cli php-fpm php-json php-common php-mbstring php-xml php-zip curl unzip certbot python3-certbot-apache git

# Enable required Apache modules
echo "🔌 Enabling Apache modules..."
a2enmod rewrite
a2enmod ssl
a2enmod headers
a2enmod proxy
a2enmod proxy_fcgi
systemctl restart apache2

# Create working directory
INSTALL_DIR="/opt/raspi-webhost-manager"
echo "📁 Creating installation directory: $INSTALL_DIR"
mkdir -p $INSTALL_DIR
mkdir -p $INSTALL_DIR/scripts
mkdir -p $INSTALL_DIR/api

# Set up web interface
echo "🌐 Setting up web interface..."
mkdir -p /var/www/webhost-manager
mkdir -p /var/www/webhost-manager/css
mkdir -p /var/www/webhost-manager/js
mkdir -p /var/www/webhost-manager/img

# Create Apache configuration
echo "🔧 Creating Apache configuration..."
cat > /etc/apache2/sites-available/webhost-manager.conf << EOF
<VirtualHost *:8080>
    ServerAdmin webmaster@localhost
    DocumentRoot /var/www/webhost-manager
    ErrorLog \${APACHE_LOG_DIR}/webhost-manager-error.log
    CustomLog \${APACHE_LOG_DIR}/webhost-manager-access.log combined

    <Directory /var/www/webhost-manager>
        Options Indexes FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>
</VirtualHost>
EOF

# Configure Apache to listen on port 8080
grep -q "Listen 8080" /etc/apache2/ports.conf || echo "Listen 8080" >> /etc/apache2/ports.conf

# Enable site
a2ensite webhost-manager.conf

# Create main CSS file with Space Grotesk and pastel blue theme
cat > /var/www/webhost-manager/css/styles.css << EOF
:root {
    --primary-color: #7EB6FF; /* Pastel blue from Adobe Color */
    --primary-color-light: #BFDAFF;
    --secondary-color: #AEECEF;
    --bg-color: #f8f9fa;
    --card-bg: #ffffff;
    --text-color: #2d3436;
    --text-light: #636e72;
    --border-color: #dfe6e9;
    --sidebar-width: 250px;
    --shadow-light: 0 4px 6px rgba(50, 50, 93, 0.11), 0 1px 3px rgba(0, 0, 0, 0.08);
    --shadow-medium: 0 10px 15px -3px rgba(0, 0, 0, 0.1), 0 4px 6px -2px rgba(0, 0, 0, 0.05);
    --glassmorphism-bg: rgba(255, 255, 255, 0.2);
    --glass-border: 1px solid rgba(255, 255, 255, 0.3);
    --glass-shadow: 0 8px 32px 0 rgba(31, 38, 135, 0.15);
    --transition-speed: 0.3s;
}

[data-theme="dark"] {
    --primary-color: #7EB6FF;
    --primary-color-light: #BFDAFF;
    --secondary-color: #AEECEF;
    --bg-color: #1a1a2e;
    --card-bg: #16213e;
    --text-color: #e9e9e9;
    --text-light: #b3b3b3;
    --border-color: #3a3a5c;
    --glassmorphism-bg: rgba(22, 33, 62, 0.7);
    --glass-border: 1px solid rgba(255, 255, 255, 0.1);
}

[data-theme="sunset"] {
    --primary-color: #7EB6FF;
    --primary-color-light: #BFDAFF;
    --secondary-color: #FFB6C1;
    --bg-color: #2c2c54;
    --card-bg: #40407a;
    --text-color: #f7f1e3;
    --text-light: #d1ccc0;
    --border-color: #474787;
    --glassmorphism-bg: rgba(64, 64, 122, 0.7);
    --glass-border: 1px solid rgba(255, 255, 255, 0.1);
}

[data-theme="ocean"] {
    --primary-color: #5DA3FA;
    --primary-color-light: #A5D8FF;
    --secondary-color: #87EAF2;
    --bg-color: #E7F5FF;
    --card-bg: #ffffff;
    --text-color: #2d3436;
    --text-light: #636e72;
    --border-color: #c7ecee;
    --glassmorphism-bg: rgba(255, 255, 255, 0.25);
    --glass-border: 1px solid rgba(255, 255, 255, 0.4);
}

* {
    margin: 0;
    padding: 0;
    box-sizing: border-box;
    font-family: 'Space Grotesk', sans-serif !important;
}

body {
    font-family: 'Space Grotesk', sans-serif !important;
    background-color: var(--bg-color);
    color: var(--text-color);
    display: flex;
    min-height: 100vh;
    transition: background-color var(--transition-speed), color var(--transition-speed);
}

/* Sidebar */
.sidebar {
    width: var(--sidebar-width);
    background-color: var(--primary-color);
    color: white;
    display: flex;
    flex-direction: column;
    position: fixed;
    height: 100vh;
    top: 0;
    left: 0;
    transition: all var(--transition-speed);
    z-index: 100;
    box-shadow: var(--shadow-medium);
    background: linear-gradient(135deg, var(--primary-color), var(--primary-color-light));
}

.logo {
    display: flex;
    align-items: center;
    padding: 20px;
    margin-bottom: 20px;
}

.logo img {
    width: 40px;
    height: 40px;
    margin-right: 10px;
}

.logo h2 {
    font-size: 1.2rem;
    font-weight: 700;
}

nav ul {
    list-style: none;
    padding: 0;
}

nav ul li {
    padding: 12px 20px;
    display: flex;
    align-items: center;
    cursor: pointer;
    margin-bottom: 5px;
    transition: all var(--transition-speed);
    border-left: 4px solid transparent;
}

nav ul li i {
    margin-right: 10px;
    font-size: 1.2rem;
    width: 24px;
    text-align: center;
}

nav ul li:hover {
    background-color: rgba(255, 255, 255, 0.1);
}

nav ul li.active {
    background-color: rgba(255, 255, 255, 0.2);
    border-left: 4px solid white;
}

.sidebar-footer {
    margin-top: auto;
    padding: 20px;
    text-align: center;
    font-size: 0.8rem;
    opacity: 0.7;
}

/* Main Content */
.main-content {
    flex: 1;
    margin-left: var(--sidebar-width);
    transition: margin-left var(--transition-speed);
}

header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: 20px;
    background-color: var(--card-bg);
    box-shadow: var(--shadow-light);
    border-bottom: 1px solid var(--border-color);
}

.search-container {
    display: flex;
    align-items: center;
    background-color: var(--bg-color);
    border-radius: 20px;
    padding: 8px 15px;
    width: 300px;
}

.search-container i {
    margin-right: 10px;
    color: var(--text-light);
}

.search-container input {
    border: none;
    background: transparent;
    outline: none;
    color: var(--text-color);
    width: 100%;
    font-family: 'Space Grotesk', sans-serif;
}

.user-info {
    display: flex;
    align-items: center;
}

.notifications {
    position: relative;
    margin-right: 20px;
    cursor: pointer;
}

.badge {
    position: absolute;
    top: -8px;
    right: -8px;
    background-color: var(--secondary-color);
    color: white;
    border-radius: 50%;
    width: 18px;
    height: 18px;
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 0.7rem;
}

.user {
    display: flex;
    align-items: center;
    cursor: pointer;
}

.user img {
    width: 35px;
    height: 35px;
    border-radius: 50%;
    margin-right: 10px;
}

/* Content Container */
.content-container {
    padding: 20px;
}

.section {
    display: none;
}

.section.active {
    display: block;
    animation: fadeIn 0.5s ease;
}

@keyframes fadeIn {
    from { opacity: 0; transform: translateY(10px); }
    to { opacity: 1; transform: translateY(0); }
}

/* Dashboard Cards */
.dashboard-cards {
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(250px, 1fr));
    gap: 20px;
    margin-bottom: 20px;
}

.card {
    background-color: var(--card-bg);
    border-radius: 15px;
    padding: 20px;
    display: flex;
    align-items: center;
    box-shadow: var(--shadow-light);
    transition: transform 0.3s ease, box-shadow 0.3s ease;
}

.card:hover {
    transform: translateY(-5px);
    box-shadow: var(--shadow-medium);
}

.card-icon {
    width: 50px;
    height: 50px;
    background: linear-gradient(135deg, var(--primary-color), var(--primary-color-light));
    display: flex;
    align-items: center;
    justify-content: center;
    border-radius: 12px;
    margin-right: 15px;
    color: white;
    font-size: 1.5rem;
}

.card-content {
    flex: 1;
}

.card-content h3 {
    margin-bottom: 5px;
    font-size: 1rem;
}

.card-content p {
    font-size: 1.5rem;
    font-weight: 700;
    color: var(--primary-color);
}

.progress-bar {
    height: 8px;
    background-color: var(--bg-color);
    border-radius: 4px;
    overflow: hidden;
    margin-bottom: 5px;
}

.progress {
    height: 100%;
    background: linear-gradient(to right, var(--primary-color), var(--secondary-color));
    border-radius: 4px;
}

.dashboard-grid {
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
    gap: 20px;
}

.dashboard-item {
    background-color: var(--card-bg);
    border-radius: 15px;
    padding: 20px;
    box-shadow: var(--shadow-light);
}

.dashboard-item h3 {
    margin-bottom: 15px;
    font-size: 1.2rem;
}

.status-card {
    display: flex;
    flex-direction: column;
    gap: 10px;
}

.status-item {
    display: flex;
    justify-content: space-between;
    align-items: center;
}

.status-badge {
    padding: 4px 10px;
    border-radius: 15px;
    font-size: 0.8rem;
    font-weight: 500;
}

.status-badge.active {
    background-color: rgba(46, 213, 115, 0.2);
    color: #2ed573;
}

.status-badge.inactive {
    background-color: rgba(255, 71, 87, 0.2);
    color: #ff4757;
}

.quick-actions {
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(140px, 1fr));
    gap: 10px;
}

/* Glass Button */
.glass-btn {
    background: var(--glassmorphism-bg);
    border: var(--glass-border);
    backdrop-filter: blur(4px);
    border-radius: 10px;
    padding: 10px 15px;
    color: var(--text-color);
    font-family: 'Space Grotesk', sans-serif;
    font-weight: 500;
    display: flex;
    align-items: center;
    justify-content: center;
    cursor: pointer;
    transition: all 0.3s ease;
    box-shadow: var(--glass-shadow);
}

.glass-btn i {
    margin-right: 8px;
}

.glass-btn:hover {
    transform: translateY(-3px);
    box-shadow: 0 15px 30px rgba(0, 0, 0, 0.1);
    border: 1px solid rgba(255, 255, 255, 0.4);
}

.glass-btn:active {
    transform: translateY(0);
}
EOF

# Create the auth CSS file
cat > /var/www/webhost-manager/css/auth.css << EOF
/* Auth Styles - Raspi Webhost Manager */

:root {
    --auth-gradient: linear-gradient(135deg, var(--primary-color), var(--primary-color-light));
    --card-radius: 20px;
    --input-radius: 10px;
}

body {
    background: var(--auth-gradient);
    display: flex;
    align-items: center;
    justify-content: center;
    min-height: 100vh;
    padding: 20px;
    overflow-x: hidden;
    font-family: 'Space Grotesk', sans-serif !important;
}

.auth-container {
    width: 100%;
    max-width: 500px;
    margin: 0 auto;
}

.auth-card {
    background: var(--glassmorphism-bg);
    backdrop-filter: blur(10px);
    border: var(--glass-border);
    border-radius: var(--card-radius);
    padding: 30px;
    box-shadow: var(--glass-shadow);
}

.auth-header {
    text-align: center;
    margin-bottom: 30px;
}

.auth-header img {
    width: 80px;
    height: 80px;
    margin-bottom: 15px;
}

.auth-header h1 {
    font-size: 1.8rem;
    margin: 0;
    background: var(--auth-gradient);
    -webkit-background-clip: text;
    -webkit-text-fill-color: transparent;
    background-clip: text;
    font-family: 'Space Grotesk', sans-serif !important;
    font-weight: 600;
}

.auth-form h2 {
    font-size: 1.5rem;
    margin-bottom: 10px;
    text-align: center;
    font-family: 'Space Grotesk', sans-serif !important;
}

.auth-form p {
    text-align: center;
    margin-bottom: 25px;
    color: var(--text-light);
    font-family: 'Space Grotesk', sans-serif !important;
}

.input-icon {
    position: relative;
}

.input-icon i {
    position: absolute;
    left: 15px;
    top: 50%;
    transform: translateY(-50%);
    color: var(--text-light);
}

.input-icon input {
    padding-left: 45px !important;
    font-family: 'Space Grotesk', sans-serif !important;
}

.form-group.checkbox {
    display: flex;
    align-items: center;
    margin: 15px 0;
}

.form-group.checkbox input {
    margin-right: 10px;
}

.form-group.checkbox label {
    margin: 0;
    font-weight: normal;
    font-family: 'Space Grotesk', sans-serif !important;
}

.full-width {
    width: 100%;
    justify-content: center;
    margin: 15px 0;
    padding: 12px;
}

.auth-error {
    background-color: rgba(231, 76, 60, 0.1);
    color: #e74c3c;
    border: 1px solid rgba(231, 76, 60, 0.2);
    border-radius: 8px;
    padding: 12px;
    margin-bottom: 20px;
    display: flex;
    align-items: center;
}

.auth-error i {
    margin-right: 10px;
    font-size: 1.2rem;
}

.auth-footer {
    text-align: center;
    margin-top: 30px;
    font-size: 0.9rem;
    color: var(--text-light);
    font-family: 'Space Grotesk', sans-serif !important;
}

/* Setup Wizard Styles */
.setup-progress {
    display: flex;
    align-items: center;
    justify-content: center;
    margin-bottom: 30px;
}

.step {
    width: 36px;
    height: 36px;
    border-radius: 50%;
    display: flex;
    align-items: center;
    justify-content: center;
    background-color: var(--bg-color);
    color: var(--text-light);
    font-weight: bold;
    border: 2px solid var(--border-color);
    position: relative;
    z-index: 2;
    font-family: 'Space Grotesk', sans-serif !important;
}

.step.active {
    background: var(--primary-color);
    color: white;
    border-color: var(--primary-color);
}

.step.completed {
    background: var(--primary-color);
    color: white;
    border-color: var(--primary-color);
}

.progress-line {
    height: 2px;
    flex-grow: 1;
    background-color: var(--border-color);
    max-width: 80px;
    position: relative;
    z-index: 1;
}

.progress-line.active {
    background-color: var(--primary-color);
}

.setup-step {
    display: none;
}

.setup-step.active {
    display: block;
    animation: fadeIn 0.5s ease;
}

.welcome-image {
    text-align: center;
    margin: 30px 0;
}

.welcome-image i {
    font-size: 5rem;
    color: var(--primary-color);
    animation: float 3s infinite ease-in-out;
}

@keyframes float {
    0% { transform: translateY(0px); }
    50% { transform: translateY(-15px); }
    100% { transform: translateY(0px); }
}

.setup-description {
    text-align: left;
    background-color: rgba(255, 255, 255, 0.1);
    border-radius: 10px;
    padding: 15px;
    margin: 20px 0;
    border: 1px solid rgba(255, 255, 255, 0.2);
    line-height: 1.6;
    font-family: 'Space Grotesk', sans-serif !important;
}

.button-group {
    display: flex;
    justify-content: space-between;
    margin-top: 20px;
}

.button-group .glass-btn {
    width: 48%;
}

/* Setup Complete Styles */
.success-animation {
    text-align: center;
    margin: 30px 0;
}

.success-animation i {
    font-size: 5rem;
    color: #2ecc71;
    animation: pulse 2s infinite;
}

@keyframes pulse {
    0% { transform: scale(0.95); }
    50% { transform: scale(1.1); }
    100% { transform: scale(0.95); }
}

.setup-info {
    background-color: rgba(255, 255, 255, 0.1);
    border-radius: 10px;
    padding: 15px;
    margin: 20px 0;
    border: 1px solid rgba(255, 255, 255, 0.2);
}

.setup-info p {
    text-align: left;
    margin-bottom: 10px;
    font-family: 'Space Grotesk', sans-serif !important;
}

.setup-info p:last-child {
    margin-bottom: 0;
}
EOF

# Create the auth JS file with fixed password validation
cat > /var/www/webhost-manager/js/auth.js << EOF
document.addEventListener('DOMContentLoaded', function() {
    // Check if this is first run
    const isFirstRun = !localStorage.getItem('setupCompleted');
    
    if (isFirstRun) {
        document.getElementById('login-form').style.display = 'none';
        document.getElementById('setup-wizard').style.display = 'block';
    }
    
    // Setup wizard navigation
    const nextButtons = document.querySelectorAll('.next-step');
    const backButtons = document.querySelectorAll('.back-step');
    const steps = document.querySelectorAll('.setup-step');
    const progressSteps = document.querySelectorAll('.step');
    const progressLines = document.querySelectorAll('.progress-line');
    
    nextButtons.forEach(button => {
        button.addEventListener('click', function() {
            const currentStep = parseInt(this.getAttribute('data-next')) - 1;
            const nextStep = parseInt(this.getAttribute('data-next'));
            
            // First step does not need validation (from step 1 to step 2)
            if (currentStep === 1) { // Validate moving from step 2 to step 3
                const password = document.getElementById('setup-password').value;
                const confirm = document.getElementById('setup-confirm').value;
                
                if (password && password.length < 8) {
                    showToast('Password must be at least 8 characters', 'error');
                    return;
                }
                
                if (password && confirm && password !== confirm) {
                    showToast('Passwords do not match!', 'error');
                    return;
                }
            }
            
            // Update active step
            steps.forEach(step => step.classList.remove('active'));
            document.querySelector('.setup-step[data-step="' + nextStep + '"]').classList.add('active');
            
            // Update progress indicators
            progressSteps.forEach(step => {
                const stepNum = parseInt(step.getAttribute('data-step'));
                if (stepNum < nextStep) {
                    step.classList.add('completed');
                }
                if (stepNum === nextStep) {
                    step.classList.add('active');
                }
            });
            
            // Update progress lines
            progressLines.forEach((line, index) => {
                if (index < nextStep - 1) {
                    line.classList.add('active');
                }
            });
        });
    });
    
    backButtons.forEach(button => {
        button.addEventListener('click', function() {
            const prevStep = parseInt(this.getAttribute('data-back'));
            const currentStep = parseInt(this.getAttribute('data-back')) + 1;
            
            // Update active step
            steps.forEach(step => step.classList.remove('active'));
            document.querySelector('.setup-step[data-step="' + prevStep + '"]').classList.add('active');
            
            // Update progress indicators
            progressSteps.forEach(step => {
                const stepNum = parseInt(step.getAttribute('data-step'));
                if (stepNum === currentStep) {
                    step.classList.remove('active');
                }
            });
            
            // Update progress lines
            progressLines.forEach((line, index) => {
                if (index === prevStep - 1) {
                    line.classList.remove('active');
                }
            });
        });
    });
    
    // Complete setup button
    const completeSetupBtn = document.getElementById('complete-setup');
    if (completeSetupBtn) {
        completeSetupBtn.addEventListener('click', function() {
            const name = document.getElementById('setup-name').value;
            const username = document.getElementById('setup-username').value;
            const password = document.getElementById('setup-password').value;
            const hostname = document.getElementById('setup-hostname').value;
            const email = document.getElementById('setup-email').value;
            const autoUpdates = document.getElementById('auto-updates').checked;
            
            // Validate all fields are filled
            if (!name || !username || !password || !hostname || !email) {
                showToast('Please fill all required fields', 'error');
                return;
            }
            
            // Validate password again
            if (password.length < 8) {
                showToast('Password must be at least 8 characters', 'error');
                return;
            }
            
            // In a real app, this would make an API call to create the user
            // For demo purposes, we'll just store in localStorage
            const userData = {
                name: name,
                username: username,
                password: password, // In a real app, this would be hashed on the server
                hostname: hostname,
                email: email,
                autoUpdates: autoUpdates
            };
            
            localStorage.setItem('userData', JSON.stringify(userData));
            localStorage.setItem('setupCompleted', 'true');
            
            // Show the completed screen
            document.getElementById('setup-wizard').style.display = 'none';
            document.getElementById('setup-complete').style.display = 'block';
            document.getElementById('created-username').textContent = username;
            
            // Simulate server-side processing
            showToast('Creating your account...', 'info');
            
            setTimeout(() => {
                showToast('Setup completed successfully!', 'success');
            }, 2000);
        });
    }
    
    // Go to login button
    const gotoLoginBtn = document.getElementById('goto-login');
    if (gotoLoginBtn) {
        gotoLoginBtn.addEventListener('click', function() {
            document.getElementById('setup-complete').style.display = 'none';
            document.getElementById('login-form').style.display = 'block';
        });
    }
    
    // Login form submission
    const loginForm = document.getElementById('form-login');
    if (loginForm) {
        loginForm.addEventListener('submit', function(e) {
            e.preventDefault();
            
            const username = document.getElementById('username').value;
            const password = document.getElementById('password').value;
            const remember = document.getElementById('remember').checked;
            
            // In a real app, this would make an API call to verify credentials
            // For demo purposes, we'll check against localStorage
            const userData = JSON.parse(localStorage.getItem('userData') || '{}');
            
            if (userData.username === username && userData.password === password) {
                // Set session
                sessionStorage.setItem('loggedIn', 'true');
                if (remember) {
                    localStorage.setItem('rememberedUser', username);
                }
                
                // Redirect to dashboard
                showToast('Login successful. Redirecting...', 'success');
                setTimeout(() => {
                    window.location.href = 'index.html';
                }, 1500);
            } else {
                // Show error
                document.getElementById('login-error').style.display = 'flex';
                document.getElementById('login-error-message').textContent = 'Invalid username or password';
                
                // Clear password field
                document.getElementById('password').value = '';
            }
        });
    }
    
    // Toast notification function
    function showToast(message, type = 'info') {
        const toast = document.createElement('div');
        toast.className = 'toast ' + type;
        
        let icon = 'info-circle';
        if (type === 'success') icon = 'check-circle';
        if (type === 'error') icon = 'exclamation-circle';
        if (type === 'warning') icon = 'exclamation-triangle';
        
        toast.innerHTML = '<i class="fas fa-' + icon + '"></i> ' + message;
        document.body.appendChild(toast);
        
        // Trigger animation
        setTimeout(() => toast.classList.add('show'), 10);
        
        // Auto hide after 3 seconds
        setTimeout(() => {
            toast.classList.remove('show');
            setTimeout(() => toast.remove(), 300);
        }, 3000);
    }
    
    // Pre-fill remembered user if exists
    const rememberedUser = localStorage.getItem('rememberedUser');
    if (rememberedUser && document.getElementById('username')) {
        document.getElementById('username').value = rememberedUser;
        document.getElementById('remember').checked = true;
    }
});
EOF

# Create a login.html file with Space Grotesk font
cat > /var/www/webhost-manager/login.html << EOF
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Login - Raspi Webhost Manager</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Space+Grotesk:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="css/styles.css">
    <link rel="stylesheet" href="css/auth.css">
    <style>
        * {
            font-family: 'Space Grotesk', sans-serif !important;
        }
    </style>
</head>
<body>
    <div class="auth-container">
        <div class="auth-card">
            <div class="auth-header">
                <img src="img/logo.png" alt="Raspi Webhost Manager">
                <h1>Raspi Webhost Manager</h1>
            </div>
            
            <!-- Login Form -->
            <div id="login-form" class="auth-form">
                <h2>Welcome Back</h2>
                <p>Please login to continue to the dashboard</p>
                
                <div id="login-error" class="auth-error" style="display: none;">
                    <i class="fas fa-exclamation-circle"></i>
                    <span id="login-error-message">Invalid username or password</span>
                </div>
                
                <form id="form-login">
                    <div class="form-group">
                        <label for="username">Username</label>
                        <div class="input-icon">
                            <i class="fas fa-user"></i>
                            <input type="text" id="username" name="username" placeholder="Enter your username" required>
                        </div>
                    </div>
                    
                    <div class="form-group">
                        <label for="password">Password</label>
                        <div class="input-icon">
                            <i class="fas fa-lock"></i>
                            <input type="password" id="password" name="password" placeholder="Enter your password" required>
                        </div>
                    </div>
                    
                    <div class="form-group checkbox">
                        <input type="checkbox" id="remember" name="remember">
                        <label for="remember">Remember me</label>
                    </div>
                    
                    <button type="submit" class="glass-btn full-width">
                        <i class="fas fa-sign-in-alt"></i> Login
                    </button>
                </form>
                
                <div class="auth-footer">
                    <p>Made with ❤️ by Paulify Development</p>
                </div>
            </div>
            
            <!-- First Run Setup Wizard -->
            <div id="setup-wizard" class="auth-form" style="display: none;">
                <div class="setup-progress">
                    <div class="step active" data-step="1">1</div>
                    <div class="progress-line"></div>
                    <div class="step" data-step="2">2</div>
                    <div class="progress-line"></div>
                    <div class="step" data-step="3">3</div>
                </div>
                
                <!-- Step 1: Welcome -->
                <div class="setup-step active" data-step="1">
                    <h2>Welcome to Raspi Webhost Manager</h2>
                    <p>Let's set up your account to get started</p>
                    
                    <div class="welcome-image">
                        <i class="fas fa-rocket"></i>
                    </div>
                    
                    <p class="setup-description">This wizard will help you set up your Raspberry Pi hosting platform with Apache, SSL certificates, and optional Nextcloud installation.</p>
                    
                    <button class="glass-btn full-width next-step" data-next="2">
                        <i class="fas fa-arrow-right"></i> Get Started
                    </button>
                </div>
                
                <!-- Step 2: User Information -->
                <div class="setup-step" data-step="2">
                    <h2>Create Your Account</h2>
                    <p>Enter your details below</p>
                    
                    <div class="form-group">
                        <label for="setup-name">Your Name</label>
                        <div class="input-icon">
                            <i class="fas fa-user"></i>
                            <input type="text" id="setup-name" name="name" placeholder="Enter your full name" required>
                        </div>
                    </div>
                    
                    <div class="form-group">
                        <label for="setup-username">Username</label>
                        <div class="input-icon">
                            <i class="fas fa-id-badge"></i>
                            <input type="text" id="setup-username" name="username" placeholder="Choose a username" required>
                        </div>
                    </div>
                    
                    <div class="form-group">
                        <label for="setup-password">Password</label>
                        <div class="input-icon">
                            <i class="fas fa-lock"></i>
                            <input type="password" id="setup-password" name="password" placeholder="Choose a secure password" required>
                        </div>
                    </div>
                    
                    <div class="form-group">
                        <label for="setup-confirm">Confirm Password</label>
                        <div class="input-icon">
                            <i class="fas fa-lock"></i>
                            <input type="password" id="setup-confirm" name="confirm" placeholder="Confirm your password" required>
                        </div>
                    </div>
                    
                    <div class="button-group">
                        <button class="glass-btn back-step" data-back="1">
                            <i class="fas fa-arrow-left"></i> Back
                        </button>
                        <button class="glass-btn next-step" data-next="3">
                            <i class="fas fa-arrow-right"></i> Next
                        </button>
                    </div>
                </div>
                
                <!-- Step 3: System Settings -->
                <div class="setup-step" data-step="3">
                    <h2>System Settings</h2>
                    <p>Configure your hosting environment</p>
                    
                    <div class="form-group">
                        <label for="setup-hostname">Hostname</label>
                        <div class="input-icon">
                            <i class="fas fa-server"></i>
                            <input type="text" id="setup-hostname" name="hostname" placeholder="e.g., webhost.local" required>
                        </div>
                    </div>
                    
                    <div class="form-group">
                        <label for="setup-email">Default Email (for SSL certificates)</label>
                        <div class="input-icon">
                            <i class="fas fa-envelope"></i>
                            <input type="email" id="setup-email" name="email" placeholder="Enter your email address" required>
                        </div>
                    </div>
                    
                    <div class="form-group toggle-container">
                        <label>Enable Automatic Updates</label>
                        <div class="toggle-switch">
                            <input type="checkbox" id="auto-updates" name="auto-updates" checked>
                            <label for="auto-updates"></label>
                        </div>
                    </div>
                    
                    <button class="glass-btn full-width" id="complete-setup">
                        <i class="fas fa-check-circle"></i> Complete Setup
                    </button>
                    
                    <button class="glass-btn back-step" data-back="2" style="margin-top: 10px;">
                        <i class="fas fa-arrow-left"></i> Back
                    </button>
                </div>
            </div>
            
            <!-- Setup Complete -->
            <div id="setup-complete" class="auth-form" style="display: none;">
                <div class="success-animation">
                    <i class="fas fa-check-circle"></i>
                </div>
                
                <h2>Setup Complete!</h2>
                <p>Your Raspi Webhost Manager is ready to use.</p>
                
                <div class="setup-info">
                    <p>You can now log in with your new account:</p>
                    <p><strong>Username:</strong> <span id="created-username">admin</span></p>
                </div>
                
                <button class="glass-btn full-width" id="goto-login">
                    <i class="fas fa-sign-in-alt"></i> Proceed to Login
                </button>
            </div>
        </div>
    </div>
    
    <script src="js/auth.js"></script>
</body>
</html>
EOF

# Create a simple index.html file
cat > /var/www/webhost-manager/index.html << EOF
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Raspi Webhost Manager</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Space+Grotesk:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="css/styles.css">
    <style>
        * {
            font-family: 'Space Grotesk', sans-serif !important;
        }
    </style>
</head>
<body>
    <div class="sidebar">
        <div class="logo">
            <img src="img/logo.png" alt="Raspi Webhost Manager">
            <h2>Raspi Webhost</h2>
        </div>
        <nav>
            <ul>
                <li class="active" data-section="dashboard">
                    <i class="fas fa-tachometer-alt"></i>
                    <span>Dashboard</span>
                </li>
                <li data-section="apache">
                    <i class="fas fa-server"></i>
                    <span>Apache</span>
                </li>
                <li data-section="ssl">
                    <i class="fas fa-lock"></i>
                    <span>SSL Certificates</span>
                </li>
                <li data-section="nextcloud">
                    <i class="fas fa-cloud"></i>
                    <span>Nextcloud</span>
                </li>
                <li data-section="settings">
                    <i class="fas fa-cogs"></i>
                    <span>Settings</span>
                </li>
            </ul>
        </nav>
        <div class="sidebar-footer">
            <p>Made with ❤️</p>
            <p>Paulify Development</p>
        </div>
    </div>

    <div class="main-content">
        <header>
            <div class="search-container">
                <i class="fas fa-search"></i>
                <input type="text" placeholder="Search...">
            </div>
            <div class="user-info">
                <div class="notifications">
                    <i class="fas fa-bell"></i>
                    <span class="badge">3</span>
                </div>
                <div class="user">
                    <img src="img/user.png" alt="User">
                    <span>Admin</span>
                </div>
            </div>
        </header>

        <div class="content-container">
            <h1>Dashboard</h1>
            <p>Welcome to Raspi Webhost Manager</p>
        </div>
    </div>
    
    <script src="js/scripts.js"></script>
</body>
</html>
EOF

# Create a simple scripts.js file
cat > /var/www/webhost-manager/js/scripts.js << EOF
document.addEventListener('DOMContentLoaded', function() {
    // Check if user is logged in
    const isLoggedIn = sessionStorage.getItem('loggedIn') === 'true';
    
    if (!isLoggedIn) {
        // Redirect to login page
        window.location.href = 'login.html';
        return;
    }
    
    // Navigation functionality
    const navItems = document.querySelectorAll('nav ul li');
    
    // Navigation click handlers
    navItems.forEach(item => {
        item.addEventListener('click', function() {
            // Update active nav item
            navItems.forEach(navItem => navItem.classList.remove('active'));
            this.classList.add('active');
        });
    });
});
EOF

# Create placeholder logo
cat > /var/www/webhost-manager/img/logo.png << "EOF"
iVBORw0KGgoAAAANSUhEUgAAAGQAAABkCAIAAAD/gAIDAAAAGXRFWHRTb2Z0d2FyZQBBZG9iZSBJbWFnZVJlYWR5ccllPAAAAyNpVFh0WE1MOmNvbS5hZG9iZS54bXAAAAAAADw/eHBhY2tldCBiZWdpbj0i77u/IiBpZD0iVzVNME1wQ2VoaUh6cmVTek5UY3prYzlkIj8+IDx4OnhtcG1ldGEgeG1sbnM6eD0iYWRvYmU6bnM6bWV0YS8iIHg6eG1wdGs9IkFkb2JlIFhNUCBDb3JlIDYuMC1jMDAyIDc5LjE2NDQ4OCwgMjAyMC8wNy8xMC0yMjowNjo1MyAgICAgICAgIj4gPHJkZjpSREYgeG1sbnM6cmRmPSJodHRwOi8vd3d3LnczLm9yZy8xOTk5LzAyLzIyLXJkZi1zeW50YXgtbnMjIj4gPHJkZjpEZXNjcmlwdGlvbiByZGY6YWJvdXQ9IiIgeG1sbnM6eG1wPSJodHRwOi8vbnMuYWRvYmUuY29tL3hhcC8xLjAvIiB4bWxuczp4bXBNTT0iaHR0cDovL25zLmFkb2JlLmNvbS94YXAvMS4wL21tLyIgeG1sbnM6c3RSZWY9Imh0dHA6Ly9ucy5hZG9iZS5jb20veGFwLzEuMC9zVHlwZS9SZXNvdXJjZVJlZiMiIHhtcDpDcmVhdG9yVG9vbD0iQWRvYmUgUGhvdG9zaG9wIDIyLjAgKFdpbmRvd3MpIiB4bXBNTTpJbnN0YW5jZUlEPSJ4bXAuaWlkOjM2M0ZFNkQzODY3NDExRUJCMTkyODFDQTQ0Qjg5Qzg4IiB4bXBNTTpEb2N1bWVudElEPSJ4bXAuZGlkOjM2M0ZFNkQ0ODY3NDExRUJCMTkyODFDQTQ0Qjg5Qzg4Ij4gPHhtcE1NOkRlcml2ZWRGcm9tIHN0UmVmOmluc3RhbmNlSUQ9InhtcC5paWQ6MzYzRkU2RDE4Njc0MTFFQkIxOTI4MUNBNDRCODlDODgiIHN0UmVmOmRvY3VtZW50SUQ9InhtcC5kaWQ6MzYzRkU2RDI4Njc0MTFFQkIxOTI4MUNBNDRCODlDODgiLz4gPC9yZGY6RGVzY3JpcHRpb24+IDwvcmRmOlJERj4gPC94OnhtcG1ldGE+IDw/eHBhY2tldCBlbmQ9InIiPz6/xmWGAAACiElEQVR42uzbsU4CQRAG4NkFCgkWVLZU1NT0vosvoY/BY9Db2dISQwgW1jZW1CiYmZz3kIC5293b2fn/wiacG75M7lbY3vPb+2ooXJWVUhSJoliWZVmWZY1EFOWo9/FzXZbl0bVt68/TNC2K4vJmfnv/+Dh/etb18+XT/cPcn2NwuVzatnXOTSYT55y19nhWluX2HK3PEfhvL+ecP7her4dhuN/v2QgBXQpM+pvS+D8MQ1VV29hOQN2pLH9I27Za6yAI/BGtdRAEWusoimazGdGIIk3T6XQ6jmPSQzOOY3IbZW5CQPIEEoZr3/dFURweYvddKkgdQA6JGIbBjAiWJqDbIfk7svs7Mhu10Z7EWmTZ0STLss1mM5vNkiQhOjRJkpD/0YyiKP/8IjrEZzc0HiQIAqYROcuy/Mf3pSKKYvkpOsuy3Suyuyi6U9l2Q7PdRbfn2O2o0VZk1NjEvETRnWB0pyK6Exzd6Y7oBId0Rxx0pzv+4SjD/68MlrqUnVIAIRJQdnLSjUxAu9F0fZJl6TpQdIVZXYrr93JJlo7TdO0p0Z3Uu3pKdCdClp4SJq/fX5fuP5UBnCd5p0vdqKHqRmW4E3nTAZQuHcB2o3TdCJAuPZoAR+8pYbJwf7p0JGVgP1+I4CXMm+4ErnuvYBVIMO+qgN7SAtbcKt1LlzSrwPbe+rZLR7KNAgJkvdGU2FYNUzea9BtD1CKC9Ub9qUUE7I3+w+9GU3v7HrlLR8IY8I8WCRDYIgJojBbtn1pEGGlFAG+HEECP0SLCOCwS2g5ZZpFQdmiMFgkMEODFLQLotrz/s2z2Y1lZ8h9HtyzLsizLsqws+RVgANLanGI0D53dAAAAAElFTkSuQmCC
EOF

# Create placeholder user image
cat > /var/www/webhost-manager/img/user.png << "EOF"
iVBORw0KGgoAAAANSUhEUgAAAGQAAABkCAIAAAD/gAIDAAAAGXRFWHRTb2Z0d2FyZQBBZG9iZSBJbWFnZVJlYWR5ccllPAAAAyNpVFh0WE1MOmNvbS5hZG9iZS54bXAAAAAAADw/eHBhY2tldCBiZWdpbj0i77u/IiBpZD0iVzVNME1wQ2VoaUh6cmVTek5UY3prYzlkIj8+IDx4OnhtcG1ldGEgeG1sbnM6eD0iYWRvYmU6bnM6bWV0YS8iIHg6eG1wdGs9IkFkb2JlIFhNUCBDb3JlIDYuMC1jMDAyIDc5LjE2NDQ4OCwgMjAyMC8wNy8xMC0yMjowNjo1MyAgICAgICAgIj4gPHJkZjpSREYgeG1sbnM6cmRmPSJodHRwOi8vd3d3LnczLm9yZy8xOTk5LzAyLzIyLXJkZi1zeW50YXgtbnMjIj4gPHJkZjpEZXNjcmlwdGlvbiByZGY6YWJvdXQ9IiIgeG1sbnM6eG1wPSJodHRwOi8vbnMuYWRvYmUuY29tL3hhcC8xLjAvIiB4bWxuczp4bXBNTT0iaHR0cDovL25zLmFkb2JlLmNvbS94YXAvMS4wL21tLyIgeG1sbnM6c3RSZWY9Imh0dHA6Ly9ucy5hZG9iZS5jb20veGFwLzEuMC9zVHlwZS9SZXNvdXJjZVJlZiMiIHhtcDpDcmVhdG9yVG9vbD0iQWRvYmUgUGhvdG9zaG9wIDIyLjAgKFdpbmRvd3MpIiB4bXBNTTpJbnN0YW5jZUlEPSJ4bXAuaWlkOjE0QzVGQjcxODY3QTExRUI5RTUzRTA3MzNGRThGMTczIiB4bXBNTTpEb2N1bWVudElEPSJ4bXAuZGlkOjE0QzVGQjcyODY3QTExRUI5RTUzRTA3MzNGRThGMTczIj4gPHhtcE1NOkRlcml2ZWRGcm9tIHN0UmVmOmluc3RhbmNlSUQ9InhtcC5paWQ6MTRDNUZCNkY4NjdBMTFFQjlFNTNFMDczM0ZFOEYxNzMiIHN0UmVmOmRvY3VtZW50SUQ9InhtcC5kaWQ6MTRDNUZCNzA4NjdBMTFFQjlFNTNFMDczM0ZFOEYxNzMiLz4gPC9yZGY6RGVzY3JpcHRpb24+IDwvcmRmOlJERj4gPC94OnhtcG1ldGE+IDw/eHBhY2tldCBlbmQ9InIiPz7w0gKNAAAUSklEQVR42uxceXRU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