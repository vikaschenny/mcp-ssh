#!/bin/bash

# Simplified System Resource Monitoring Script for CentOS 7
# Collects comprehensive system information and outputs in JSON format

echo '{'

# System Information
echo '  "system_info": {'
echo '    "hostname": "'$(hostname)'",'
echo '    "os": "'$(cat /etc/redhat-release 2>/dev/null || echo "CentOS Linux")'",'
echo '    "kernel": "'$(uname -r)'",'
echo '    "architecture": "'$(uname -m)'",'
echo '    "uptime": "'$(uptime -p | sed 's/up //')'",'
echo '    "timestamp": "'$(date -u +"%Y-%m-%dT%H:%M:%SZ")'"'
echo '  },'

# CPU Information
echo '  "cpu_info": {'
echo '    "model": "'$(lscpu | grep "Model name" | cut -d':' -f2 | sed 's/^[ \t]*//')'",'
echo '    "cores": "'$(nproc)'",'
echo '    "threads_per_core": "'$(lscpu | grep "Thread(s) per core" | cut -d':' -f2 | sed 's/^[ \t]*//')'",'
echo '    "cpu_mhz": "'$(lscpu | grep "CPU MHz" | cut -d':' -f2 | sed 's/^[ \t]*//')'",'
echo '    "cache_size": "'$(lscpu | grep "L3 cache" | cut -d':' -f2 | sed 's/^[ \t]*//')'"'
echo '  },'

# CPU Usage
echo '  "cpu_usage": {'
load_avg=$(uptime | awk -F'load average:' '{print $2}' | sed 's/,//g')
echo '    "load_average_1min": "'$(echo $load_avg | awk '{print $1}')'",'
echo '    "load_average_5min": "'$(echo $load_avg | awk '{print $2}')'",'
echo '    "load_average_15min": "'$(echo $load_avg | awk '{print $3}')'",'
echo '    "cpu_utilization": "'$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | sed 's/%us,//')'%"'
echo '  },'

# Memory Information
echo '  "memory_info": {'
total_mem=$(free -h | grep Mem | awk '{print $2}')
used_mem=$(free -h | grep Mem | awk '{print $3}')
free_mem=$(free -h | grep Mem | awk '{print $4}')
available_mem=$(free -h | grep Mem | awk '{print $7}')
mem_percent=$(free | grep Mem | awk '{printf "%.1f", $3/$2 * 100.0}')

echo '    "total": "'$total_mem'",'
echo '    "used": "'$used_mem'",'
echo '    "free": "'$free_mem'",'
echo '    "available": "'$available_mem'",'
echo '    "usage_percent": '$mem_percent','
echo '    "swap_total": "'$(free -h | grep Swap | awk '{print $2}')'",'
echo '    "swap_used": "'$(free -h | grep Swap | awk '{print $3}')'",'
echo '    "swap_free": "'$(free -h | grep Swap | awk '{print $4}')'"'
echo '  },'

# Disk Information
echo '  "disk_info": {'
echo '    "filesystems": ['
first=true
df -h | tail -n +2 | while read fs size used avail percent mount; do
  if [ "$first" = true ]; then
    first=false
  else
    echo ','
  fi
  echo -n '      {'
  echo -n '"filesystem": "'$fs'",'
  echo -n '"size": "'$size'",'
  echo -n '"used": "'$used'",'
  echo -n '"available": "'$avail'",'
  echo -n '"use_percent": "'$percent'",'
  echo -n '"mount_point": "'$mount'"'
  echo -n '}'
done
echo ''
echo '    ],'
echo '    "physical_disks": ['
first=true
for disk in /sys/block/sd* /sys/block/vd* /sys/block/nvme*; do
  if [ -e "$disk" ]; then
    if [ "$first" = true ]; then
      first=false
    else
      echo ','
    fi
    name=$(basename $disk)
    size_sectors=$(cat $disk/size 2>/dev/null || echo 0)
    size_gb=$((size_sectors * 512 / 1073741824))
    model="unknown"
    if [ -f "$disk/device/model" ]; then
      model=$(cat $disk/device/model 2>/dev/null | tr -d '\n' | sed 's/[[:space:]]*$//')
    fi
    rotational="unknown"
    if [ -f "$disk/queue/rotational" ]; then
      if [ $(cat $disk/queue/rotational) = "1" ]; then
        rotational="HDD"
      else
        rotational="SSD"
      fi
    fi
    echo -n '      {"name": "'$name'", "size_gb": '$size_gb', "model": "'$model'", "type": "'$rotational'"}'
  fi
done
echo ''
echo '    ]'
echo '  },'

# Network Information (simplified)
echo '  "network_info": {'
echo '    "interfaces": ['
first=true
ifconfig 2>/dev/null | grep -E "^[a-zA-Z0-9]+" | awk '{print $1}' | while read interface; do
  ip=$(ifconfig $interface 2>/dev/null | grep "inet " | awk '{print $2}')
  if [ -n "$ip" ] && [ "$ip" != "127.0.0.1" ]; then
    if [ "$first" = true ]; then
      first=false
    else
      echo ','
    fi
    echo -n '      {"interface": "'$interface'", "ip_address": "'$ip'"}'
  fi
done
echo ''
echo '    ],'
echo '    "connections": {'
echo '      "established": "'$(netstat -an 2>/dev/null | grep ESTABLISHED | wc -l)'",'
echo '      "listening": "'$(netstat -an 2>/dev/null | grep LISTEN | wc -l)'"'
echo '    }'
echo '  },'

# Process Information
echo '  "process_info": {'
echo '    "total_processes": "'$(ps aux | wc -l)'",'
echo '    "running_processes": "'$(ps aux | grep -v grep | grep -c " R ")'",'
echo '    "sleeping_processes": "'$(ps aux | grep -v grep | grep -c " S ")'",'
echo '    "top_processes_by_cpu": ['
ps aux --sort=-%cpu | head -6 | tail -5 | while read user pid cpu mem vsz rss tty stat start time command; do
  echo -n '      {"user": "'$user'", "pid": "'$pid'", "cpu": "'$cpu'", "memory": "'$mem'", "command": "'$command'"},'
done | sed '$ s/,$//'
echo ''
echo '    ],'
echo '    "top_processes_by_memory": ['
ps aux --sort=-%mem | head -6 | tail -5 | while read user pid cpu mem vsz rss tty stat start time command; do
  echo -n '      {"user": "'$user'", "pid": "'$pid'", "cpu": "'$cpu'", "memory": "'$mem'", "command": "'$command'"},'
done | sed '$ s/,$//'
echo ''
echo '    ]'
echo '  },'

# System Load and Performance
echo '  "performance_metrics": {'
echo '    "load_average_per_core": "'$(echo "scale=2; $(uptime | awk -F'load average:' '{print $2}' | awk '{print $1}' | sed 's/,//') / $(nproc)" | bc 2>/dev/null || echo "N/A")'",'
echo '    "context_switches_per_sec": "'$(vmstat 1 2 | tail -1 | awk '{print $12}')'",'
echo '    "interrupts_per_sec": "'$(vmstat 1 2 | tail -1 | awk '{print $11}')'",'
echo '    "io_wait_percent": "'$(vmstat 1 2 | tail -1 | awk '{print $16}')'%"'
echo '  },'

# System Services
echo '  "system_services": {'
echo '    "running_services": "'$(systemctl list-units --type=service --state=running 2>/dev/null | wc -l || echo "0")'",'
echo '    "failed_services": "'$(systemctl list-units --type=service --state=failed 2>/dev/null | wc -l || echo "0")'",'
echo '    "sshd_status": "'$(systemctl is-active sshd 2>/dev/null || echo "unknown")'",'
echo '    "firewalld_status": "'$(systemctl is-active firewalld 2>/dev/null || echo "unknown")'"'
echo '  }'

echo '}'
