<?php
// System monitoring functions
header('Content-Type: application/json');

// Get requested action
$action = isset($_GET['action']) ? $_GET['action'] : 'all';

switch ($action) {
    case 'cpu':
        echo json_encode(getCpuUsage());
        break;
    case 'memory':
        echo json_encode(getMemoryUsage());
        break;
    case 'disk':
        echo json_encode(getDiskUsage());
        break;
    case 'uptime':
        echo json_encode(getUptime());
        break;
    case 'services':
        echo json_encode(getServicesStatus());
        break;
    case 'all':
    default:
        echo json_encode([
            'cpu' => getCpuUsage(),
            'memory' => getMemoryUsage(),
            'disk' => getDiskUsage(),
            'uptime' => getUptime(),
            'services' => getServicesStatus(),
            'timestamp' => date('Y-m-d H:i:s')
        ]);
        break;
}

function getCpuUsage() {
    // Get CPU usage from /proc/stat
    $load = sys_getloadavg();
    
    // On Raspberry Pi, get temperature if available
    $temp = null;
    if (file_exists('/sys/class/thermal/thermal_zone0/temp')) {
        $temp = intval(file_get_contents('/sys/class/thermal/thermal_zone0/temp')) / 1000;
    }
    
    // Get CPU usage percentage
    $stat1 = file('/proc/stat');
    sleep(1);
    $stat2 = file('/proc/stat');
    
    $cpu_info1 = explode(" ", preg_replace("!cpu +!", "", $stat1[0]));
    $cpu_info2 = explode(" ", preg_replace("!cpu +!", "", $stat2[0]));
    
    $diff_idle = $cpu_info2[3] - $cpu_info1[3];
    $diff_total = ($cpu_info2[0] + $cpu_info2[1] + $cpu_info2[2] + $cpu_info2[3]) - 
                 ($cpu_info1[0] + $cpu_info1[1] + $cpu_info1[2] + $cpu_info1[3]);
    
    $diff_usage = $diff_total - $diff_idle;
    $percent = ($diff_usage / $diff_total) * 100;
    
    return [
        'percent' => round($percent, 1),
        'load' => $load,
        'temperature' => $temp
    ];
}

function getMemoryUsage() {
    $free = shell_exec('free -m');
    $free = (string)trim($free);
    $free_arr = explode("\n", $free);
    $mem = explode(" ", $free_arr[1]);
    $mem = array_filter($mem);
    $mem = array_merge($mem);
    
    $memory_usage = $mem[2]/$mem[1] * 100;
    
    return [
        'total' => $mem[1],
        'used' => $mem[2],
        'free' => $mem[3],
        'percent' => round($memory_usage, 1)
    ];
}

function getDiskUsage() {
    $disktotal = disk_total_space('/');
    $diskfree = disk_free_space('/');
    $diskused = $disktotal - $diskfree;
    $diskusage = ($diskused / $disktotal) * 100;
    
    return [
        'total' => round($disktotal / 1024 / 1024 / 1024, 2),
        'used' => round($diskused / 1024 / 1024 / 1024, 2),
        'free' => round($diskfree / 1024 / 1024 / 1024, 2),
        'percent' => round($diskusage, 1)
    ];
}

function getUptime() {
    $uptime = shell_exec('cat /proc/uptime');
    $uptime = explode(" ", $uptime)[0];
    
    $days = floor($uptime / 86400);
    $hours = floor(($uptime % 86400) / 3600);
    $minutes = floor(($uptime % 3600) / 60);
    $seconds = $uptime % 60;
    
    return [
        'seconds' => round($uptime),
        'formatted' => "{$days}d {$hours}h {$minutes}m {$seconds}s"
    ];
}

function getServicesStatus() {
    // Check status of important services
    return [
        'apache' => isServiceRunning('apache2'),
        'mysql' => isServiceRunning('mysql') || isServiceRunning('mariadb'),
        'php' => true,
        'certbot' => file_exists('/usr/bin/certbot') || file_exists('/usr/local/bin/certbot')
    ];
}

function isServiceRunning($service) {
    $status = shell_exec("systemctl is-active " . escapeshellarg($service) . " 2>&1");
    return trim($status) === 'active';
}
?>