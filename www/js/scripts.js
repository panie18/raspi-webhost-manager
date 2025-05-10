document.addEventListener('DOMContentLoaded', function() {
    // Check if user is logged in
    const isLoggedIn = sessionStorage.getItem('loggedIn') === 'true';
    
    if (!isLoggedIn) {
        // Redirect to login page
        window.location.href = 'login.html';
        return;
    }
    
    // Get user data
    const userData = JSON.parse(localStorage.getItem('userData') || '{}');
    
    // Update user display name if available
    const userDisplay = document.querySelector('.user span');
    if (userDisplay && userData.name) {
        userDisplay.textContent = userData.name;
    }
    
    // Navigation functionality
    const navItems = document.querySelectorAll('nav ul li');
    const sections = document.querySelectorAll('.section');
    const quickActionButtons = document.querySelectorAll('.quick-actions .glass-btn');
    
    // Theme selector
    const themeOptions = document.querySelectorAll('.theme-option');
    
    // Initialize counters with animation
    const counters = document.querySelectorAll('.counter');
    
    // Initialize current theme
    let currentTheme = localStorage.getItem('theme') || 'light';
    document.body.setAttribute('data-theme', currentTheme);
    
    // Update theme option selection
    themeOptions.forEach(option => {
        if (option.getAttribute('data-theme') === currentTheme) {
            option.classList.add('active');
        } else {
            option.classList.remove('active');
        }
    });
    
    // Add logout button to user menu
    const userInfo = document.querySelector('.user');
    if (userInfo) {
        userInfo.addEventListener('click', function() {
            const logoutMenu = document.createElement('div');
            logoutMenu.className = 'logout-menu';
            logoutMenu.innerHTML = `
                <div class="logout-user-info">
                    <img src="img/user.png" alt="User">
                    <div>
                        <p class="logout-name">${userData.name || 'Admin'}</p>
                        <p class="logout-username">@${userData.username || 'admin'}</p>
                    </div>
                </div>
                <div class="logout-divider"></div>
                <div class="logout-item" id="btnLogout">
                    <i class="fas fa-sign-out-alt"></i> Logout
                </div>
            `;
            
            // Check if menu already exists
            if (!document.querySelector('.logout-menu')) {
                document.body.appendChild(logoutMenu);
                
                // Position the menu
                const rect = userInfo.getBoundingClientRect();
                logoutMenu.style.top = `${rect.bottom + 10}px`;
                logoutMenu.style.right = `20px`;
                
                // Add event listener to logout button
                document.getElementById('btnLogout').addEventListener('click', function() {
                    sessionStorage.removeItem('loggedIn');
                    window.location.href = 'login.html';
                });
                
                // Close menu when clicking outside
                document.addEventListener('click', function closeMenu(e) {
                    if (!logoutMenu.contains(e.target) && !userInfo.contains(e.target)) {
                        logoutMenu.remove();
                        document.removeEventListener('click', closeMenu);
                    }
                });
            }
        });
    }
    
    // Navigation click handlers
    navItems.forEach(item => {
        item.addEventListener('click', function() {
            const sectionId = this.getAttribute('data-section');
            
            // Update active nav item
            navItems.forEach(navItem => navItem.classList.remove('active'));
            this.classList.add('active');
            
            // Show selected section
            sections.forEach(section => {
                if (section.id === sectionId) {
                    section.classList.add('active');
                } else {
                    section.classList.remove('active');
                }
            });
        });
    });
    
    // Quick action buttons
    quickActionButtons.forEach(button => {
        button.addEventListener('click', function() {
            const targetSection = this.getAttribute('data-section');
            
            // Update active nav item
            navItems.forEach(navItem => {
                if (navItem.getAttribute('data-section') === targetSection) {
                    navItem.classList.add('active');
                } else {
                    navItem.classList.remove('active');
                }
            });
            
            // Show target section
            sections.forEach(section => {
                if (section.id === targetSection) {
                    section.classList.add('active');
                } else {
                    section.classList.remove('active');
                }
            });
        });
    });
    
    // Theme selector
    themeOptions.forEach(option => {
        option.addEventListener('click', function() {
            const theme = this.getAttribute('data-theme');
            
            // Update active theme option
            themeOptions.forEach(opt => opt.classList.remove('active'));
            this.classList.add('active');
            
            // Set theme
            document.body.setAttribute('data-theme', theme);
            localStorage.setItem('theme', theme);
            
            // Show toast notification
            showToast('Theme updated successfully', 'success');
        });
    });
    
    // Counter animation
    counters.forEach(counter => {
        const target = 0; // This would come from server data in a real app
        let count = 0;
        const speed = 200; // Speed of counting animation
        
        const updateCount = () => {
            const increment = target / speed;
            
            if (count < target) {
                count += increment;
                counter.innerText = Math.ceil(count);
                setTimeout(updateCount, 1);
            } else {
                counter.innerText = target;
            }
        };
        
        updateCount();
    });
    
    // Form submissions
    const apacheForm = document.getElementById('apache-form');
    const sslForm = document.getElementById('ssl-form');
    const nextcloudForm = document.getElementById('nextcloud-form');
    const settingsForm = document.getElementById('settings-form');
    
    if (apacheForm) {
        apacheForm.addEventListener('submit', function(e) {
            e.preventDefault();
            const siteName = document.getElementById('site-name').value;
            const docRoot = document.getElementById('document-root').value;
            
            // This would make an API call to the backend in a real app
            console.log(`Creating website: ${siteName} with document root: ${docRoot}`);
            
            // Show success notification
            showToast(`Website ${siteName} created successfully!`, 'success');
            
            // Clear form
            this.reset();
            
            // Update the websites list (mock data for demo)
            updateWebsitesList(siteName, docRoot);
        });
    }
    
    if (sslForm) {
        sslForm.addEventListener('submit', function(e) {
            e.preventDefault();
            const domain = document.getElementById('ssl-domain').value;
            const email = document.getElementById('ssl-email').value;
            
            // This would make an API call to the backend in a real app
            console.log(`Generating SSL certificate for: ${domain} with email: ${email}`);
            
            // Show a loading toast
            showToast(`Generating SSL certificate for ${domain}. This may take a moment...`, 'info');
            
            // Simulate certificate generation process
            setTimeout(() => {
                // Update certificates list (mock data for demo)
                updateCertificatesList(domain);
                
                // Show success notification
                showToast(`SSL certificate for ${domain} generated successfully!`, 'success');
                
                // Clear form
                this.reset();
            }, 3000);
        });
    }
    
    if (nextcloudForm) {
        nextcloudForm.addEventListener('submit', function(e) {
            e.preventDefault();
            const domain = document.getElementById('nc-domain').value;
            const directory = document.getElementById('nc-directory').value;
            const admin = document.getElementById('nc-admin').value;
            const password = document.getElementById('nc-password').value;
            
            // This would make an API call to the backend in a real app
            console.log(`Installing Nextcloud on: ${domain} in directory: ${directory}`);
            
            // Show a loading toast
            showToast(`Installing Nextcloud. This may take several minutes...`, 'info');
            
            // Simulate installation process
            setTimeout(() => {
                // Show success notification
                showToast(`Nextcloud installed successfully!`, 'success');
                
                // Update UI to show Nextcloud installed
                document.getElementById('nextcloud-status').innerHTML = 
                    '<i class="fas fa-check-circle"></i> Nextcloud is installed and running.';
                document.getElementById('nextcloud-status').className = 'alert alert-success';
                
                // Show config section
                document.getElementById('nextcloud-config').style.display = 'block';
                
                // Update Nextcloud details
                document.getElementById('nc-status').textContent = 'Running';
                document.getElementById('nc-url').textContent = `https://${domain}`;
                document.getElementById('nc-url').href = `https://${domain}`;
                document.getElementById('nc-version').textContent = '25.0.3';
                
                // Clear form
                this.reset();
            }, 5000);
        });
    }
    
    if (settingsForm) {
        settingsForm.addEventListener('submit', function(e) {
            e.preventDefault();
            
            // This would make an API call to the backend in a real app
            console.log('Saving settings');
            
            // Show success notification
            showToast('Settings saved successfully!', 'success');
        });
    }
    
    // Function to update websites list (mock data for demo)
    function updateWebsitesList(siteName, docRoot) {
        const websitesList = document.getElementById('websites-list');
        
        // Clear "no websites" message if it exists
        if (websitesList.innerHTML.includes('No websites configured yet')) {
            websitesList.innerHTML = '';
        }
        
        // Add new website to list
        const newRow = document.createElement('tr');
        newRow.innerHTML = `
            <td>${siteName}</td>
            <td>${docRoot}</td>
            <td><span class="status-badge inactive">No</span></td>
            <td>
                <button class="glass-btn" onclick="showToast('Managing site...', 'info')">
                    <i class="fas fa-cog"></i>
                </button>
                <button class="glass-btn" onclick="showToast('Deleting site...', 'info')">
                    <i class="fas fa-trash"></i>
                </button>
            </td>
        `;
        websitesList.appendChild(newRow);
        
        // Update dashboard counter
        const websiteCounter = document.querySelector('.card:nth-child(1) .counter');
        if (websiteCounter) {
            const currentCount = parseInt(websiteCounter.textContent || '0');
            websiteCounter.textContent = currentCount + 1;
        }
    }
    
    // Function to update certificates list (mock data for demo)
    function updateCertificatesList(domain) {
        const certificatesList = document.getElementById('certificates-list');
        
        // Clear "no certificates" message if it exists
        if (certificatesList.innerHTML.includes('No certificates found')) {
            certificatesList.innerHTML = '';
        }
        
        // Calculate expiry date (3 months from now)
        const expiryDate = new Date();
        expiryDate.setMonth(expiryDate.getMonth() + 3);
        const expiryFormatted = expiryDate.toLocaleDateString();
        
        // Add new certificate to list
        const newRow = document.createElement('tr');
        newRow.innerHTML = `
            <td>${domain}</td>
            <td>${expiryFormatted}</td>
            <td><span class="status-badge active">Valid</span></td>
            <td>
                <button class="glass-btn" onclick="showToast('Renewing certificate...', 'info')">
                    <i class="fas fa-sync"></i>
                </button>
                <button class="glass-btn" onclick="showToast('Removing certificate...', 'info')">
                    <i class="fas fa-trash"></i>
                </button>
            </td>
        `;
        certificatesList.appendChild(newRow);
        
        // Update dashboard counter
        const sslCounter = document.querySelector('.card:nth-child(2) .counter');
        if (sslCounter) {
            const currentCount = parseInt(sslCounter.textContent || '0');
            sslCounter.textContent = currentCount + 1;
        }
    }
});

// Global toast notification function
function showToast(message, type = 'info') {
    const toast = document.getElementById('toast') || document.createElement('div');
    toast.id = 'toast';
    toast.className = `toast ${type}`;
    
    let icon = 'info-circle';
    if (type === 'success') icon = 'check-circle';
    if (type === 'error') icon = 'exclamation-circle';
    if (type === 'warning') icon = 'exclamation-triangle';
    
    toast.innerHTML = `<i class="fas fa-${icon}"></i> ${message}`;
    
    if (!document.getElementById('toast')) {
        document.body.appendChild(toast);
    }
    
    // Trigger animation
    setTimeout(() => toast.classList.add('show'), 10);
    
    // Auto hide after 3 seconds
    setTimeout(() => {
        toast.classList.remove('show');
    }, 3000);
}