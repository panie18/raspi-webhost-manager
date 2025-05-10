#!/bin/bash

# Raspi Webhost Manager Simple Installation Script
# Made with ❤️ by Paulify Development

echo "🚀 Starting Raspi Webhost Manager Installation..."

# Check if running as root
if [ "$EUID" -ne 0 ]; then
  echo "❌ Please run as root (use sudo)"
  exit 1
fi

# Create necessary directories
mkdir -p /var/www/webhost-manager/css
mkdir -p /var/www/webhost-manager/js
mkdir -p /var/www/webhost-manager/img

# Create CSS files one at a time to avoid here-document issues
echo "📝 Creating CSS files..."
cat > /var/www/webhost-manager/css/styles.css << 'EOFCSS'
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
    min-height: 100vh;
}

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
EOFCSS

cat > /var/www/webhost-manager/css/auth.css << 'EOFCSS'
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

.auth-header h1 {
    font-size: 1.8rem;
    font-family: 'Space Grotesk', sans-serif !important;
    color: #fff;
}

.setup-step {
    display: none;
}

.setup-step.active {
    display: block;
}

.form-group {
    margin-bottom: 15px;
}

.form-group label {
    display: block;
    margin-bottom: 8px;
    font-weight: 500;
    color: #fff;
}

.form-group input {
    width: 100%;
    padding: 10px 15px;
    border-radius: 8px;
    border: 1px solid rgba(255, 255, 255, 0.3);
    background: rgba(255, 255, 255, 0.1);
    color: #fff;
    font-family: 'Space Grotesk', sans-serif !important;
}
EOFCSS

# Create JavaScript files
echo "📝 Creating JavaScript files..."
cat > /var/www/webhost-manager/js/auth.js << 'EOFJS'
document.addEventListener('DOMContentLoaded', function() {
    // Next step buttons
    const nextButtons = document.querySelectorAll('.next-step');
    
    nextButtons.forEach(button => {
        button.addEventListener('click', function() {
            const currentStep = parseInt(this.getAttribute('data-next')) - 1;
            const nextStep = parseInt(this.getAttribute('data-next'));
            
            // Skip validation on first step
            if (currentStep === 1) {
                // Only validate when moving from step 2 to 3
                const password = document.getElementById('setup-password').value;
                const confirm = document.getElementById('setup-confirm').value;
                
                if (password && password.length < 8) {
                    alert('Password must be at least 8 characters');
                    return;
                }
            }
            
            // Update active step
            document.querySelectorAll('.setup-step').forEach(step => {
                step.classList.remove('active');
            });
            
            document.querySelector('.setup-step[data-step="' + nextStep + '"]').classList.add('active');
        });
    });
    
    // Back buttons
    const backButtons = document.querySelectorAll('.back-step');
    backButtons.forEach(button => {
        button.addEventListener('click', function() {
            const prevStep = parseInt(this.getAttribute('data-back'));
            
            document.querySelectorAll('.setup-step').forEach(step => {
                step.classList.remove('active');
            });
            
            document.querySelector('.setup-step[data-step="' + prevStep + '"]').classList.add('active');
        });
    });
});
EOFJS

cat > /var/www/webhost-manager/js/scripts.js << 'EOFJS'
document.addEventListener('DOMContentLoaded', function() {
    console.log('Raspi Webhost Manager loaded');
});
EOFJS

# Create HTML files
echo "📝 Creating HTML files..."
cat > /var/www/webhost-manager/login.html << 'EOFHTML'
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
    <style>* { font-family: 'Space Grotesk', sans-serif !important; }</style>
</head>
<body>
    <div class="auth-container">
        <div class="auth-card">
            <div class="auth-header">
                <h1>Raspi Webhost Manager</h1>
            </div>
            
            <div id="setup-wizard" class="auth-form">
                <!-- Step 1: Welcome -->
                <div class="setup-step active" data-step="1">
                    <h2 style="color: white; margin-bottom: 20px;">Welcome to Raspi Webhost Manager</h2>
                    
                    <p style="color: white; margin-bottom: 30px;">This wizard will help you set up your Raspberry Pi hosting platform</p>
                    
                    <button class="glass-btn next-step" data-next="2" style="margin-top: 20px; width: 100%;">
                        <i class="fas fa-arrow-right"></i> Get Started
                    </button>
                </div>
                
                <!-- Step 2: User Information -->
                <div class="setup-step" data-step="2">
                    <h2 style="color: white; margin-bottom: 20px;">Create Your Account</h2>
                    
                    <div class="form-group">
                        <label for="setup-name">Your Name</label>
                        <input type="text" id="setup-name" name="name" placeholder="Enter your full name" required>
                    </div>
                    
                    <div class="form-group">
                        <label for="setup-username">Username</label>
                        <input type="text" id="setup-username" name="username" placeholder="Choose a username" required>
                    </div>
                    
                    <div class="form-group">
                        <label for="setup-password">Password</label>
                        <input type="password" id="setup-password" name="password" placeholder="Choose a secure password" required>
                    </div>
                    
                    <div class="form-group">
                        <label for="setup-confirm">Confirm Password</label>
                        <input type="password" id="setup-confirm" name="confirm" placeholder="Confirm your password" required>
                    </div>
                    
                    <div style="display: flex; gap: 10px; margin-top: 20px;">
                        <button class="glass-btn back-step" data-back="1" style="flex: 1;">Back</button>
                        <button class="glass-btn next-step" data-next="3" style="flex: 1;">Next</button>
                    </div>
                </div>
                
                <!-- Step 3: Finish -->
                <div class="setup-step" data-step="3">
                    <h2 style="color: white; margin-bottom: 20px;">Almost Done!</h2>
                    <p style="color: white;">Your Raspi Webhost Manager is almost ready.</p>
                    
                    <button class="glass-btn" style="width: 100%; margin-top: 20px;">
                        Complete Setup
                    </button>
                    
                    <button class="glass-btn back-step" data-back="2" style="width: 100%; margin-top: 10px;">
                        Back
                    </button>
                </div>
            </div>
            
            <div style="text-align: center; margin-top: 30px; color: white;">
                <p>Made with ❤️ by Paulify Development</p>
            </div>
        </div>
    </div>
    
    <script src="js/auth.js"></script>
</body>
</html>
EOFHTML

cat > /var/www/webhost-manager/index.html << 'EOFHTML'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Dashboard - Raspi Webhost Manager</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Space+Grotesk:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="css/styles.css">
    <style>
        * { font-family: 'Space Grotesk', sans-serif !important; }
        body {
            background: linear-gradient(135deg, #7EB6FF, #BFDAFF);
            padding: 20px;
        }
        .container {
            max-width: 1200px;
            margin: 0 auto;
        }
        .card {
            background: rgba(255, 255, 255, 0.2);
            backdrop-filter: blur(10px);
            border: 1px solid rgba(255, 255, 255, 0.3);
            border-radius: 15px;
            padding: 30px;
            margin-bottom: 20px;
            box-shadow: 0 8px 32px 0 rgba(31, 38, 135, 0.15);
        }
        h1 {
            color: white;
            margin-bottom: 30px;
        }
        footer {
            text-align: center;
            color: white;
            margin-top: 50px;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>Raspi Webhost Manager Dashboard</h1>
        
        <div class="card">
            <h2>Welcome to your Raspberry Pi Web Hosting Platform</h2>
            <p>Your installation was successful. You'll soon be able to configure websites, SSL certificates, and more.</p>
        </div>
        
        <footer>
            <p>Made with ❤️ by Paulify Development</p>
        </footer>
    </div>
</body>
</html>
EOFHTML

# Create Apache configuration
echo "🔧 Setting up Apache configuration..."
cat > /etc/apache2/sites-available/webhost-manager.conf << 'EOFCONF'
<VirtualHost *:8080>
    ServerAdmin webmaster@localhost
    DocumentRoot /var/www/webhost-manager
    ErrorLog ${APACHE_LOG_DIR}/webhost-manager-error.log
    CustomLog ${APACHE_LOG_DIR}/webhost-manager-access.log combined

    <Directory /var/www/webhost-manager>
        Options Indexes FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>
</VirtualHost>
EOFCONF

# Configure Apache to listen on port 8080
grep -q "Listen 8080" /etc/apache2/ports.conf || echo "Listen 8080" >> /etc/apache2/ports.conf

# Enable site if not already enabled
a2ensite webhost-manager.conf

# Set permissions
chown -R www-data:www-data /var/www/webhost-manager
chmod -R 755 /var/www/webhost-manager

# Restart Apache
systemctl restart apache2

# Get IP address
IP_ADDRESS=$(hostname -I | awk '{print $1}')

# Display completion message
echo "✅ Installation complete!"
echo "🌍 You can access the Raspi Webhost Manager at: http://$IP_ADDRESS:8080"
echo "Made with ❤️ by Paulify Development"