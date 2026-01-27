<p align="center">
  <img src="imgs/Netwizard%2B%2B Banner Image.png" alt="NetWizard++ Banner" width="60%">
</p>

# NetWizard++

NetWizard++ is a lightweight, Bash-based **network mapping and pentesting toolkit** designed for fast reconnaissance, subnet analysis, host discovery, and simple visualization using Nmap and Graphviz.

It is intended for **educational purposes, labs, and authorized security testing only**.

---

## ✨ Features

- 📐 **Subnet Calculator**

  <img src="imgs/Subnet Calculator Image.png" alt="NetWizard++ Banner" width="40%">
  
  - Network ID
  - Broadcast address
  - Subnet mask
  - Usable IP range and host count

- 🔍 **Host Discovery**

  <img src="imgs/Host discovery image.png" alt="NetWizard++ Banner" width="40%">
  
  - Ping-scan based live host detection using Nmap

- 📊 **Readable Host Table**

  <img src="imgs/readable host table image.png" alt="NetWizard++ Banner" width="40%">
  
  - IP address
  - Hostname (if available)
  - MAC address and vendor (when detected)

- 🗺️ **Network Map Visualization**

  <img src="imgs/Network Map Visualizer img.png" alt="NetWizard++ Banner" width="40%">
  
  - ASCII host list
  - Automatically generated PNG network map using Graphviz

- 🛡️ **Pentest Enumeration**

  <img src="imgs/Pentest Enumeration img.png" alt="NetWizard++ Banner" width="40%">
  
  - SYN scan
  - Service/version detection
  - OS detection
  - Output saved for reporting

- 🔔 **New Device Detection**

  <img src="imgs/new device detection (baseline creation).png" alt="NetWizard++ Banner" width="25%">  <img src="imgs/newly added device detection.png" alt="NetWizard++ Banner" width="25%">
  
  - Detects new hosts appearing on a network by comparing scans

---

## 🧠 How Network Mapping Works

NetWizard++ does **not** perform physical topology discovery.

Instead, it:
1. Uses `nmap -sn` to detect live hosts
2. Writes a **Graphviz DOT file** describing relationships between the network and hosts
3. Uses Graphviz (`dot`) to render a **logical host relationship map**

This produces a clean, report-friendly visualization of discovered assets.

---

## 📦 Requirements

NetWizard++ relies on the following tools:

- `bash`
- `nmap`
- `gawk`
- `util-linux`
- `graphviz` (optional, for PNG network maps)

The installer will attempt to install these automatically.

---

## 🚀 Installation

Clone the repository and run the installer:

```bash
git clone https://github.com/GauravNJain/Netwizard-plusplus.git
cd Netwizard-plusplus
sudo bash ./installer.sh
```

---

## 👤 Author

- Developed by Gaurav N Jain

📧 Contact: [LinkedIn Profile](https://www.linkedin.com/in/gauravnjain/)
