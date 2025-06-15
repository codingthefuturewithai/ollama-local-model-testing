#!/usr/bin/env python3

"""
Hardware Profile Script for Ollama Testing Framework
Collects system hardware information for test environment documentation.
Cross-platform support for macOS, Linux, and Windows.
"""

import psutil
import platform
import json
import sys
import subprocess
import os
from pathlib import Path


def get_gpu_info():
    """
    Detect GPU information across different platforms and vendors.
    Returns a list of detected GPUs with their properties.
    """
    gpus = []
    
    # Try different methods to detect GPUs
    try:
        # Method 1: Try nvidia-smi for NVIDIA GPUs
        try:
            result = subprocess.run(['nvidia-smi', '--query-gpu=name,memory.total', '--format=csv,noheader,nounits'], 
                                  capture_output=True, text=True, timeout=5)
            if result.returncode == 0:
                lines = result.stdout.strip().split('\n')
                for line in lines:
                    if line.strip():
                        parts = line.split(', ')
                        if len(parts) >= 2:
                            gpus.append({
                                "type": "discrete",
                                "vendor": "NVIDIA",
                                "name": parts[0].strip(),
                                "memory_mb": int(parts[1].strip()),
                                "driver": "CUDA"
                            })
        except (subprocess.TimeoutExpired, subprocess.CalledProcessError, FileNotFoundError):
            pass
        
        # Method 2: Platform-specific detection
        system = platform.system().lower()
        
        if system == "darwin":  # macOS
            try:
                # Use system_profiler for macOS GPU detection
                result = subprocess.run(['system_profiler', 'SPDisplaysDataType', '-json'], 
                                      capture_output=True, text=True, timeout=10)
                if result.returncode == 0:
                    import json
                    data = json.loads(result.stdout)
                    displays = data.get('SPDisplaysDataType', [])
                    
                    for display in displays:
                        gpu_name = display.get('sppci_model', 'Unknown GPU')
                        gpu_vendor_raw = display.get('spdisplays_vendor', display.get('sppci_vendor', 'Unknown'))
                        vram = display.get('spdisplays_vram', 'Unknown')
                        
                        # Clean up vendor name
                        if gpu_vendor_raw and 'sppci_vendor_' in str(gpu_vendor_raw):
                            gpu_vendor = gpu_vendor_raw.replace('sppci_vendor_', '')
                        else:
                            gpu_vendor = gpu_vendor_raw
                        
                        # Detect if it's Apple Silicon integrated GPU
                        is_apple_silicon = ('Apple' in str(gpu_vendor) or 
                                          any(chip in gpu_name for chip in ['M1', 'M2', 'M3', 'M4', 'M5']) or
                                          'Apple' in gpu_name)
                        
                        gpu_info = {
                            "type": "integrated" if is_apple_silicon else "discrete",
                            "vendor": gpu_vendor,
                            "name": gpu_name,
                            "driver": "Metal" if is_apple_silicon else "Unknown"
                        }
                        
                        # Add detailed Apple Silicon GPU specifications
                        if is_apple_silicon:
                            # GPU core count
                            cores = display.get('sppci_cores')
                            if cores:
                                gpu_info["gpu_cores"] = int(cores)
                            
                            # Metal support version
                            metal_support = display.get('spdisplays_mtlgpufamilysupport')
                            if metal_support:
                                # Convert from spdisplays_metal3 to Metal 3
                                if 'metal' in metal_support.lower():
                                    version = metal_support.replace('spdisplays_metal', 'Metal ')
                                    gpu_info["metal_support"] = version
                                else:
                                    gpu_info["metal_support"] = metal_support
                            
                            # Bus type
                            bus = display.get('sppci_bus')
                            if bus:
                                gpu_info["bus_type"] = bus
                            
                            # Device type
                            device_type = display.get('sppci_device_type')
                            if device_type:
                                gpu_info["device_type"] = device_type
                        
                        # Parse VRAM if available
                        if isinstance(vram, str) and 'MB' in vram:
                            try:
                                gpu_info["memory_mb"] = int(vram.replace(' MB', '').replace(',', ''))
                            except:
                                gpu_info["memory_mb"] = "Unknown"
                        
                        gpus.append(gpu_info)
            except:
                pass
                
        elif system == "linux":
            try:
                # Use lspci for Linux GPU detection
                result = subprocess.run(['lspci'], capture_output=True, text=True, timeout=5)
                if result.returncode == 0:
                    lines = result.stdout.split('\n')
                    for line in lines:
                        if 'VGA' in line or 'Display' in line:
                            # Parse GPU info from lspci output
                            if 'NVIDIA' in line:
                                vendor = "NVIDIA"
                            elif 'AMD' in line or 'ATI' in line:
                                vendor = "AMD"
                            elif 'Intel' in line:
                                vendor = "Intel"
                            else:
                                vendor = "Unknown"
                            
                            # Extract GPU name (simplified)
                            parts = line.split(': ')
                            gpu_name = parts[-1] if len(parts) > 1 else "Unknown GPU"
                            
                            gpus.append({
                                "type": "integrated" if vendor == "Intel" else "discrete",
                                "vendor": vendor,
                                "name": gpu_name,
                                "memory_mb": "Unknown",
                                "driver": "Unknown"
                            })
            except:
                pass
    
    except Exception as e:
        # Fallback: indicate GPU detection failed
        gpus = [{"error": f"GPU detection failed: {str(e)}"}]
    
    # If no GPUs detected, add a placeholder
    if not gpus:
        gpus = [{"type": "unknown", "vendor": "Unknown", "name": "No GPU detected", "memory_mb": "Unknown"}]
    
    return gpus


def get_ollama_info():
    """
    Detect Ollama installation and acceleration info.
    """
    ollama_info = {
        "installed": False,
        "version": "Unknown",
        "acceleration": "Unknown"
    }
    
    try:
        # Check if ollama is installed
        result = subprocess.run(['ollama', '--version'], capture_output=True, text=True, timeout=5)
        if result.returncode == 0:
            ollama_info["installed"] = True
            ollama_info["version"] = result.stdout.strip()
            
            # Try to detect acceleration method
            system = platform.system().lower()
            if system == "darwin":
                # On macOS, Ollama typically uses Metal for Apple Silicon
                machine = platform.machine().lower()
                if 'arm' in machine or 'aarch64' in machine:
                    ollama_info["acceleration"] = "Metal (Apple Silicon)"
                else:
                    ollama_info["acceleration"] = "CPU (Intel Mac)"
            elif system == "linux":
                # On Linux, check for CUDA availability
                try:
                    cuda_result = subprocess.run(['nvidia-smi'], capture_output=True, timeout=3)
                    if cuda_result.returncode == 0:
                        ollama_info["acceleration"] = "CUDA (NVIDIA)"
                    else:
                        ollama_info["acceleration"] = "CPU"
                except:
                    ollama_info["acceleration"] = "CPU"
            else:
                ollama_info["acceleration"] = "Unknown"
    
    except (subprocess.TimeoutExpired, subprocess.CalledProcessError, FileNotFoundError):
        pass
    
    return ollama_info


def get_hardware_profile():
    """
    Collect comprehensive hardware information.
    """
    # Collect GPU info first to determine messaging
    gpu_info = get_gpu_info()
    
    # Determine GPU detection level for console messaging
    gpu_detection_level = "basic"
    if gpu_info and len(gpu_info) > 0:
        first_gpu = gpu_info[0]
        if first_gpu.get("gpu_cores"):  # Apple Silicon with detailed specs
            gpu_detection_level = "apple_silicon"
            print("Apple Silicon detected - capturing detailed GPU specifications", file=sys.stderr)
        elif (first_gpu.get("memory_mb") and 
              first_gpu.get("memory_mb") != "Unknown" and 
              first_gpu.get("vendor") == "NVIDIA"):  # NVIDIA with VRAM
            gpu_detection_level = "nvidia_cuda"
            print("NVIDIA drivers detected - capturing CUDA specifications", file=sys.stderr)
        else:
            print("Basic GPU detection only - detailed specs available for Apple Silicon and NVIDIA systems", file=sys.stderr)
    else:
        print("Basic GPU detection only - detailed specs available for Apple Silicon and NVIDIA systems", file=sys.stderr)
    
    profile = {
        "timestamp": psutil.boot_time(),
        "system": {
            "os": platform.system(),
            "os_version": platform.version(),
            "platform": platform.platform(),
            "architecture": platform.machine(),
            "processor": platform.processor(),
            "python_version": platform.python_version()
        },
        "cpu": {
            "physical_cores": psutil.cpu_count(logical=False),
            "logical_cores": psutil.cpu_count(logical=True),
            "current_frequency_mhz": None,
            "max_frequency_mhz": None
        },
        "memory": {
            "total_gb": round(psutil.virtual_memory().total / (1024**3), 2),
            "available_gb": round(psutil.virtual_memory().available / (1024**3), 2),
            "used_gb": round(psutil.virtual_memory().used / (1024**3), 2),
            "percentage_used": psutil.virtual_memory().percent
        },
        "disk": {
            "total_gb": round(psutil.disk_usage('/').total / (1024**3), 2),
            "free_gb": round(psutil.disk_usage('/').free / (1024**3), 2),
            "used_gb": round(psutil.disk_usage('/').used / (1024**3), 2)
        },
        "gpu": gpu_info,
        "ollama": get_ollama_info(),
        "_gpu_detection_level": gpu_detection_level  # Store for report formatting
    }
    
    # Try to get CPU frequency info
    try:
        cpu_freq = psutil.cpu_freq()
        if cpu_freq:
            profile["cpu"]["current_frequency_mhz"] = round(cpu_freq.current, 1) if cpu_freq.current else None
            profile["cpu"]["max_frequency_mhz"] = round(cpu_freq.max, 1) if cpu_freq.max else None
    except:
        pass
    
    return profile


def format_for_report(profile):
    """
    Format hardware profile for inclusion in markdown reports.
    """
    system = profile["system"]
    cpu = profile["cpu"]
    memory = profile["memory"]
    gpu = profile["gpu"][0] if profile["gpu"] else {}
    ollama = profile["ollama"]
    
    # Format CPU info
    cpu_cores = f"{cpu['physical_cores']} cores"
    if cpu["logical_cores"] != cpu["physical_cores"]:
        cpu_cores += f" ({cpu['logical_cores']} logical)"
    
    # Format memory
    memory_info = f"{memory['total_gb']} GB total, {memory['available_gb']} GB available"
    
    # Format GPU info
    gpu_info = "Unknown"
    if gpu and "name" in gpu:
        gpu_name = gpu["name"]
        gpu_type = gpu.get("type", "unknown")
        if gpu_type == "integrated":
            gpu_info = f"{gpu_name} (integrated)"
        else:
            gpu_info = gpu_name
        
        # Add GPU cores for Apple Silicon
        if "gpu_cores" in gpu:
            gpu_info += f", {gpu['gpu_cores']} cores"
        
        # Add Metal support version
        if "metal_support" in gpu:
            gpu_info += f", {gpu['metal_support']}"
        
        # Add VRAM info if available
        if "memory_mb" in gpu and gpu["memory_mb"] != "Unknown":
            try:
                memory_gb = round(int(gpu["memory_mb"]) / 1024, 1)
                gpu_info += f", {memory_gb} GB VRAM"
            except:
                pass
    
    # Format Ollama acceleration
    acceleration = ollama.get("acceleration", "Unknown")
    if ollama.get("installed", False):
        acceleration_info = acceleration
    else:
        acceleration_info = "Ollama not detected"
    
    # Determine appropriate note based on actual GPU capabilities detected
    if gpu and gpu.get("gpu_cores"):  # Apple Silicon with detailed specs
        note = "*Detailed GPU specifications available for Apple Silicon systems*"
    elif (gpu and 
          gpu.get("memory_mb") and 
          gpu.get("memory_mb") != "Unknown" and 
          isinstance(gpu.get("memory_mb"), int)):  # NVIDIA with VRAM
        note = "*GPU specifications detected via NVIDIA drivers*"
    else:
        note = "*Basic GPU detection - detailed specifications available for Apple Silicon and NVIDIA systems with drivers*"
    
    return f"""### Hardware Environment
- **System:** {system['os']} {system.get('architecture', 'unknown')}
- **CPU:** {cpu_cores}
- **Memory:** {memory_info}
- **GPU:** {gpu_info}
- **Ollama Acceleration:** {acceleration_info}

{note}"""


def main():
    """
    Main function - can be called with different output formats.
    """
    import argparse
    
    parser = argparse.ArgumentParser(description='Hardware profiling for Ollama testing framework')
    parser.add_argument('--format', choices=['json', 'markdown', 'summary'], default='json',
                       help='Output format (default: json)')
    parser.add_argument('--output', '-o', type=str, help='Output file path (optional)')
    parser.add_argument('--from-file', type=str, help='Read profile from existing JSON file instead of collecting new data')
    
    args = parser.parse_args()
    
    # Collect or load hardware profile
    if args.from_file:
        try:
            with open(args.from_file, 'r') as f:
                profile = json.load(f)
        except Exception as e:
            print(f"Error reading hardware profile from {args.from_file}: {e}", file=sys.stderr)
            sys.exit(1)
    else:
        profile = get_hardware_profile()
    
    # Clean up internal fields before output
    if "_gpu_detection_level" in profile:
        del profile["_gpu_detection_level"]
    
    # Generate output based on format
    if args.format == 'json':
        output = json.dumps(profile, indent=2)
    elif args.format == 'markdown':
        output = format_for_report(profile)
    elif args.format == 'summary':
        # Short summary format
        system = profile["system"]
        memory = profile["memory"]
        gpu = profile["gpu"][0] if profile["gpu"] else {}
        
        output = f"{system['os']} {system.get('architecture', '')}, {memory['total_gb']}GB RAM, {gpu.get('name', 'Unknown GPU')}"
    
    # Output to file or stdout
    if args.output:
        with open(args.output, 'w') as f:
            f.write(output)
        print(f"Hardware profile saved to {args.output}", file=sys.stderr)
    else:
        print(output)


if __name__ == "__main__":
    main()
