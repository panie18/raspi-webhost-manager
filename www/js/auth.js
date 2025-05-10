document.addEventListener('DOMContentLoaded', function() {
    console.log("Auth script loaded");
    
    // Get all necessary elements
    const step1 = document.querySelector('.setup-step[data-step="1"]');
    const step2 = document.querySelector('.setup-step[data-step="2"]');
    const step3 = document.querySelector('.setup-step[data-step="3"]');
    
    // Get Started button (Step 1 to Step 2)
    const getStartedBtn = document.querySelector('button[data-next="2"]');
    if (getStartedBtn) {
        getStartedBtn.addEventListener('click', function() {
            console.log("Get Started button clicked");
            step1.classList.remove('active');
            step2.classList.add('active');
        });
    } else {
        console.error("Get Started button not found");
    }
    
    // Back button (Step 2 to Step 1)
    const backToStep1Btn = document.querySelector('button[data-back="1"]');
    if (backToStep1Btn) {
        backToStep1Btn.addEventListener('click', function() {
            step2.classList.remove('active');
            step1.classList.add('active');
        });
    }
    
    // Next button (Step 2 to Step 3)
    const nextToStep3Btn = document.querySelector('button[data-next="3"]');
    if (nextToStep3Btn) {
        nextToStep3Btn.addEventListener('click', function() {
            // Validate password
            const password = document.getElementById('setup-password').value;
            const confirm = document.getElementById('setup-confirm').value;
            
            if (password && password.length < 8) {
                alert('Password must be at least 8 characters');
                return;
            }
            
            if (password !== confirm) {
                alert('Passwords do not match!');
                return;
            }
            
            step2.classList.remove('active');
            step3.classList.add('active');
        });
    }
    
    // Back button (Step 3 to Step 2)
    const backToStep2Btn = document.querySelector('button[data-back="2"]');
    if (backToStep2Btn) {
        backToStep2Btn.addEventListener('click', function() {
            step3.classList.remove('active');
            step2.classList.add('active');
        });
    }
});