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
            document.querySelector(`.setup-step[data-step="${nextStep}"]`).classList.add('active');
            
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
            document.querySelector(`.setup-step[data-step="${prevStep}"]`).classList.add('active');
            
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
        toast.className = `toast ${type}`;
        
        let icon = 'info-circle';
        if (type === 'success') icon = 'check-circle';
        if (type === 'error') icon = 'exclamation-circle';
        if (type === 'warning') icon = 'exclamation-triangle';
        
        toast.innerHTML = `<i class="fas fa-${icon}"></i> ${message}`;
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