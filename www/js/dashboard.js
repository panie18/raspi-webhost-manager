// Dashboard specific JavaScript
document.addEventListener('DOMContentLoaded', function() {
    // Initialize system stats
    fetchSystemStats();
    
    // Update stats every 5 seconds
    setInterval(fetchSystemStats, 5000);
    
    // Initialize counters
    updateCounters();
});

function fetchSystemStats() {
    // In a real implementation, this would call the API
    // For now, we'll simulate fetching data
    fetch('/api/system.php?action=all')
        .then(response => response.json())
        .then(data => {
            // Update CPU usage
            updateCpuUsage(data.cpu);
            
            // Update memory usage
            updateMemoryUsage(data.memory);
            
            // Update disk usage
            updateDiskUsage(data.disk);
            
            // Update services status
            updateServicesStatus(data.services);
            
            // Update uptime
            updateUptime(data.uptime);
        })
        .catch(error => {
            console.error('Error fetching system stats:', error);
            
            // If API is not yet available, use simulated data
            simulateSystemStats();
        });
}

function simulateSystemStats() {
    // Simulate CPU usage
    updateCpuUsage({
        percent: Math.floor(Math.random() * 30) + 10,
        temperature: (Math.random() * 10 + 40).toFixed(1),
        load: [0.25, 0.17, 0.15]
    });
    
    // Simulate memory usage
    updateMemoryUsage({
        total: 1024,
        used: Math.floor(Math.random() * 400) + 200,
        free: 824,
        percent: Math.floor(Math.random() * 30) + 20
    });
    
    // Simulate disk usage
    updateDiskUsage({
        total: 32,
        used: Math.floor(Math.random() * 10) + 5,
        free: 27,
        percent: Math.floor(Math.random() * 30) + 15
    });
    
    // Simulate services status
    updateServicesStatus({
        apache: true,
        mysql: true,
        php: true,
        certbot: true
    });
}

function updateCpuUsage(data) {
    const cpuProgress = document.querySelector('.cpu-progress');
    const cpuPercentage = document.querySelector('.cpu-percentage');
    
    if (cpuProgress && cpuPercentage) {
        cpuProgress.style.width = data.percent + '%';
        cpuPercentage.textContent = data.percent + '%';
    }
    
    // Update CPU temperature if element exists
    const cpuTemp = document.querySelector('.cpu-temperature');
    if (cpuTemp && data.temperature) {
        cpuTemp.textContent = data.temperature + '°C';
    }
}

function updateMemoryUsage(data) {
    const memoryProgress = document.querySelector('.memory-progress');
    const memoryPercentage = document.querySelector('.memory-percentage');
    const memoryDetails = document.querySelector('.memory-details');
    
    if (memoryProgress && memoryPercentage) {
        memoryProgress.style.width = data.percent + '%';
        memoryPercentage.textContent = data.percent + '%';
    }
    
    if (memoryDetails) {
        memoryDetails.textContent = `${data.used}MB used of ${data.total}MB`;
    }
}

function updateDiskUsage(data) {
    const diskProgress = document.querySelector('.disk-progress');
    const diskPercentage = document.querySelector('.disk-percentage');
    const diskDetails = document.querySelector('.disk-details');
    
    if (diskProgress && diskPercentage) {
        diskProgress.style.width = data.percent + '%';
        diskPercentage.textContent = data.percent + '%';
    }
    
    if (diskDetails) {
        diskDetails.textContent = `${data.used}GB used of ${data.total}GB`;
    }
}

function updateServicesStatus(data) {
    const statusItems = document.querySelectorAll('.status-item');
    
    statusItems.forEach(item => {
        const serviceType = item.getAttribute('data-service');
        const statusBadge = item.querySelector('.status-badge');
        
        if (serviceType && statusBadge && data[serviceType] !== undefined) {
            if (data[serviceType]) {
                statusBadge.className = 'status-badge active';
                statusBadge.textContent = 'Running';
            } else {
                statusBadge.className = 'status-badge inactive';
                statusBadge.textContent = 'Stopped';
            }
        }
    });
}

function updateUptime(data) {
    const uptimeElement = document.querySelector('.uptime');
    if (uptimeElement && data.formatted) {
        uptimeElement.textContent = data.formatted;
    }
}

function updateCounters() {
    // Get all counters
    const websitesCounter = document.querySelector('.website-counter');
    const sslCounter = document.querySelector('.ssl-counter');
    
    // Check if we have counters in localStorage
    const websites = localStorage.getItem('websitesCount') || 0;
    const certificates = localStorage.getItem('certificatesCount') || 0;
    
    // Update counters with animation
    if (websitesCounter) animateCounter(websitesCounter, websites);
    if (sslCounter) animateCounter(sslCounter, certificates);
}

function animateCounter(element, target) {
    target = parseInt(target);
    let count = 0;
    const duration = 1000; // animation duration in milliseconds
    const increment = target / (duration / 16); // 60 fps
    
    const timer = setInterval(() => {
        count += increment;
        
        if (count >= target) {
            clearInterval(timer);
            count = target;
        }
        
        element.textContent = Math.floor(count);
    }, 16);
}