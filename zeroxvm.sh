#!/bin/bash
# =====================#!/bin/bash
# ==========================================
# ZEROXVM Ultimate Installer & Manager 🌐🚀
# Fully loaded, all-in-one DevOps & VPS Suite
# ==========================================

# ---------------------------
# COLORS & EMOJIS
# ---------------------------
R="\e[1;31m" # Red
G="\e[1;32m" # Green
Y="\e[1;33m" # Yellow
B="\e[1;34m" # Blue
C="\e[1;36m" # Cyan
M="\e[1;35m" # Magenta
W="\e[1;37m" # White
N="\e[0m"    # Reset

# ---------------------------
# ZEROX LOGO 🚀
# ---------------------------
print_zerox_logo() {
    echo -e "\n${R}══════════════════════════════════════════════════════${N}"
    echo -e "${R}║${W}                  Z E R O X V M 🚀                  ${R}║${N}"
    echo -e "${R}══════════════════════════════════════════════════════${N}"
    echo -e "${Y}                 Made by ZEROX 💻                     ${N}\n"
}

# ---------------------------
# INSTALL DOCKER IF MISSING
# ---------------------------
install_docker() {
    if ! command -v docker &>/dev/null; then
        echo -e "${Y}🐳 Docker not found. Installing...${N}"
        curl -fsSL https://get.docker.com -o get-docker.sh
        sh get-docker.sh
        sudo usermod -aG docker "$USER"
        echo -e "${G}✅ Docker installed. Logout/login if necessary.${N}"
    else
        echo -e "${G}🐳 Docker already installed.${N}"
    fi
}

# ---------------------------
# FETCH TOOL (neofetch / fastfetch)
# ---------------------------
install_fetch_tool() {
    if command -v fastfetch &>/dev/null; then
        FETCH_TOOL="fastfetch"
    elif command -v neofetch &>/dev/null; then
        FETCH_TOOL="neofetch"
    else
        echo -e "${Y}Installing fastfetch...${N}"
        if command -v apt &>/dev/null; then
            sudo apt update && sudo apt install -y fastfetch || sudo apt install -y neofetch
        elif command -v yum &>/dev/null; then
            sudo yum install -y fastfetch || sudo yum install -y neofetch
        elif command -v pacman &>/dev/null; then
            sudo pacman -Sy --noconfirm fastfetch || sudo pacman -Sy --noconfirm neofetch
        else
            echo -e "${R}Package manager not detected. Cannot auto-install.${N}"
        fi
        FETCH_TOOL=$(command -v fastfetch || command -v neofetch)
    fi
}

# ---------------------------
# NETWORK TOOLS (curl, wget, nmap, etc.)
# ---------------------------
install_network_tools() {
    echo -e "${Y}🌐 Installing essential network & security tools...${N}"
    if command -v apt &>/dev/null; then
        sudo apt install -y curl wget net-tools nmap traceroute iptables ufw
    elif command -v yum &>/dev/null; then
        sudo yum install -y curl wget net-tools nmap traceroute iptables-services firewalld
    elif command -v pacman &>/dev/null; then
        sudo pacman -Sy --noconfirm curl wget net-tools nmap iptables ufw
    fi
}

# ---------------------------
# MENU OPTIONS
# ---------------------------
OPTIONS=(
"🐙 GitHub VPS Maker"
"🛠 IDX Tool Setup"
"🖥 ZEROX IDX VPS Maker"
"🌍 ZEROX Real VPS (Any + KVM)"
"📊 System Info & Monitoring"
"⚡ Multi-VPS Batch Deploy"
"🔒 Security & Firewall Setup"
"💾 Backup & Snapshot Manager"
"☁️ Cloud & API Integration"
"📝 Logs & Alerts"
"❌ Exit"
)

# ---------------------------
# DETECT DEFAULT RESOURCES
# ---------------------------
detect_resources() {
    DEFAULT_RAM=1024
    DEFAULT_CPU=1
    if [ -f "/.codespaces/environment" ]; then
        DEFAULT_RAM=2048
        DEFAULT_CPU=2
        echo -e "${Y}💻 Detected GitHub Codespaces${N}"
    elif grep -qi 'microsoft' /proc/version &>/dev/null; then
        DEFAULT_RAM=1024
        DEFAULT_CPU=1
        echo -e "${Y}🖥 Detected WSL${N}"
    else
        DEFAULT_RAM=$(free -m | awk '/Mem:/ {print int($2/2)}')
        DEFAULT_CPU=$(nproc)
        echo -e "${Y}🌐 Standard VPS / Linux${N}"
    fi
}

# ---------------------------
# INTERACTIVE MENU LOOP
# ---------------------------
interactive_menu() {
    local selected=0
    local total=${#OPTIONS[@]}

    while true; do
        clear
        print_zerox_logo
        echo -e "${C}Use arrow keys ↑ ↓ to navigate, ENTER to select${N}\n"

        for i in "${!OPTIONS[@]}"; do
            if [ "$i" -eq "$selected" ]; then
                echo -e "${R} > ${OPTIONS[$i]}${N}"
            else
                echo -e "   ${OPTIONS[$i]}"
            fi
        done

        read -rsn1 key
        if [[ $key == $'\x1b' ]]; then
            read -rsn2 -t 0.1 key
            if [[ $key == "[A" ]]; then
                ((selected--))
                ((selected<0)) && selected=$((total-1))
            elif [[ $key == "[B" ]]; then
                ((selected++))
                ((selected>=total)) && selected=0
            fi
        elif [[ $key == "" ]]; then
            run_option "$selected"
        fi
    done
}

# ---------------------------
# MENU OPTION HANDLER
# ---------------------------
run_option() {
    case $1 in
        0) github_vps ;;
        1) idx_setup ;;
        2) idx_vps ;;
        3) real_vps ;;
        4) system_info ;;
        5) multi_vps ;;
        6) security_firewall ;;
        7) backup_manager ;;
        8) cloud_integration ;;
        9) logs_alerts ;;
        10) exit_zero ;;
    esac
}

# ---------------------------
# OPTION FUNCTIONS (placeholders kept)
# ---------------------------
github_vps() {
    clear; print_zerox_logo
    install_docker
    echo -e "${G}🐙 Launching GitHub VPS Maker...${N}"
    RAM=${DEFAULT_RAM}
    CPU=${DEFAULT_CPU}
    DISK_SIZE=100G
    CONTAINER_NAME=zeroxvm-github
    IMAGE_NAME=ubuntu:22.04
    VMDATA_DIR="$PWD/vmdata"
    mkdir -p "$VMDATA_DIR"
    docker run -it --rm --name "$CONTAINER_NAME" --device /dev/kvm \
        -v "$VMDATA_DIR":/vmdata -e RAM="$RAM" -e CPU="$CPU" -e DISK_SIZE="$DISK_SIZE" "$IMAGE_NAME"
    read -p "Press Enter to return..."
}

idx_setup() {
    clear; print_zerox_logo
    echo -e "${G}🛠 Setting up ZEROX IDX Tool...${N}"
    mkdir -p ~/zeroxvm/.idx
    cd ~/zeroxvm/.idx || return
    cat <<EOF > dev.nix
{ pkgs, ... }: {
  channel = "stable-24.05";
  packages = with pkgs; [ unzip openssh git qemu_kvm sudo cdrkit cloud-utils qemu ];
  env = { EDITOR = "nano"; };
}
EOF
    echo -e "${G}✅ ZEROX IDX Tool Setup Complete!${N}"
    read -p "Press Enter to return..."
}

idx_vps() {
    clear; print_zerox_logo
    echo -e "${G}🖥 Running ZEROX IDX VPS Maker...${N}"
    echo -e "${Y}⚡ Placeholder for ZEROX IDX VPS script.${N}"
    read -p "Press Enter to return..."
}

real_vps() {
    clear; print_zerox_logo
    install_docker
    echo -e "${G}🌍 Launching ZEROX Real VPS...${N}"
    echo -e "${Y}⚡ Placeholder for your own KVM/Docker VPS scripts.${N}"
    read -p "Press Enter to return..."
}

system_info() {
    clear; print_zerox_logo
    echo -e "${G}📊 System Information & Monitoring:${N}"
    install_fetch_tool
    [ -n "$FETCH_TOOL" ] && $FETCH_TOOL || echo -e "${R}⚠️ No fetch tool installed.${N}"
    echo -e "${C}\n💾 Disk Usage:${N}"
    df -h
    echo -e "${C}\n📈 Top Processes:${N}"
    top -b -n 1 | head -20
    echo -e "${C}\n🌐 Network Info:${N}"
    ip a
    read -p "Press Enter to return..."
}

multi_vps() {
    clear; print_zerox_logo
    install_docker
    echo -e "${M}⚡ Multi-VPS Batch Deploy${N}"
    read -p "Enter number of VPS instances to deploy: " VPS_COUNT
    read -p "Enter Docker image for VPS (default ubuntu:22.04): " VPS_IMAGE
    VPS_IMAGE=${VPS_IMAGE:-ubuntu:22.04}

    if ! [[ "$VPS_COUNT" =~ ^[0-9]+$ ]]; then
        echo -e "${R}Invalid number!${N}"
        sleep 1
        return
    fi

    for ((i=1;i<=VPS_COUNT;i++)); do
        echo -e "${G}🚀 Deploying VPS #$i using $VPS_IMAGE ...${N}"
        docker run -dit --name "zeroxvm-$i" "$VPS_IMAGE"
        sleep 1
    done
    echo -e "${G}✅ Deployed $VPS_COUNT VPS instances successfully!${N}"
    read -p "Press Enter to return..."
}

security_firewall() {
    clear; print_zerox_logo
    install_network_tools
    echo -e "${M}🔒 Security & Firewall Setup${N}"
    if command -v ufw &>/dev/null; then
        sudo ufw enable
        sudo ufw default deny incoming
        sudo ufw default allow outgoing
        sudo ufw allow ssh
        echo -e "${G}✅ UFW Firewall Enabled with SSH allowed.${N}"
    elif command -v firewall-cmd &>/dev/null; then
        sudo systemctl enable --now firewalld
        sudo firewall-cmd --permanent --add-service=ssh
        sudo firewall-cmd --reload
        echo -e "${G}✅ Firewalld Enabled with SSH allowed.${N}"
    fi
    read -p "Press Enter to return..."
}

backup_manager() {
    clear; print_zerox_logo
    echo -e "${M}💾 Backup & Snapshot Manager${N}"
    read -p "Enter container name to backup: " CONTAINER_NAME
    BACKUP_FILE="${CONTAINER_NAME}-backup-$(date +%F-%H%M%S).tar"
    docker export "$CONTAINER_NAME" -o "$BACKUP_FILE" && echo -e "${G}✅ Backup saved as $BACKUP_FILE${N}"
    read -p "Press Enter to return..."
}

cloud_integration() {
    clear; print_zerox_logo
    echo -e "${C}☁️ Cloud & API Integration${N}"
    echo -e "${Y}⚡ Placeholder for AWS, GCP, Azure, DigitalOcean API deployment scripts${N}"
    read -p "Press Enter to return..."
}

logs_alerts() {
    clear; print_zerox_logo
    echo -e "${C}📝 Logs & Alerts${N}"
    echo -e "${Y}⚡ Collecting last 50 system logs...${N}"
    journalctl -n 50 --no-pager
    echo -e "${Y}\n⚡ Placeholder for real-time alert system (email, Telegram, Slack)${N}"
    read -p "Press Enter to return..."
}

exit_zero() {
    clear; print_zerox_logo
    echo -e "${R}❌ ZEROXVM Session Terminated.${N}\n"
    exit 0
}

# ---------------------------
# START SCRIPT
# ---------------------------
detect_resources
interactive_menu
=====================
# ZEROXVM Ultimate Installer & Manager 🌐🚀
# Fully loaded, all-in-one DevOps & VPS Suite
# ==========================================

# ---------------------------
# COLORS & EMOJIS
# ---------------------------
R="\e[1;31m" # Red
G="\e[1;32m" # Green
Y="\e[1;33m" # Yellow
B="\e[1;34m" # Blue
C="\e[1;36m" # Cyan
M="\e[1;35m" # Magenta
W="\e[1;37m" # White
N="\e[0m"    # Reset

# ---------------------------
# ZEROX LOGO 🚀
# ---------------------------
print_zerox_logo() {
    echo -e "\n${R}══════════════════════════════════════════════════════${N}"
    echo -e "${R}║${W}                  Z E R O X V M 🚀                  ${R}║${N}"
    echo -e "${R}══════════════════════════════════════════════════════${N}"
    echo -e "${Y}                 Made by ZEROX 💻                     ${N}\n"
}

# ---------------------------
# INSTALL DOCKER IF MISSING
# ---------------------------
install_docker() {
    if ! command -v docker &>/dev/null; then
        echo -e "${Y}🐳 Docker not found. Installing...${N}"
        curl -fsSL https://get.docker.com -o get-docker.sh
        sh get-docker.sh
        sudo usermod -aG docker $USER
        echo -e "${G}✅ Docker installed. Logout/login if necessary.${N}"
    else
        echo -e "${G}🐳 Docker already installed.${N}"
    fi
}

# ---------------------------
# FETCH TOOL (neofetch / fastfetch)
# ---------------------------
install_fetch_tool() {
    if command -v fastfetch &>/dev/null; then
        FETCH_TOOL="fastfetch"
    elif command -v neofetch &>/dev/null; then
        FETCH_TOOL="neofetch"
    else
        echo -e "${Y}Installing fastfetch...${N}"
        if command -v apt &>/dev/null; then
            sudo apt update && sudo apt install -y fastfetch || sudo apt install -y neofetch
        elif command -v yum &>/dev/null; then
            sudo yum install -y fastfetch || sudo yum install -y neofetch
        elif command -v pacman &>/dev/null; then
            sudo pacman -Sy --noconfirm fastfetch || sudo pacman -Sy --noconfirm neofetch
        else
            echo -e "${R}Package manager not detected. Cannot auto-install.${N}"
        fi
        FETCH_TOOL=$(command -v fastfetch || command -v neofetch)
    fi
}

# ---------------------------
# NETWORK TOOLS (curl, wget, nmap, etc.)
# ---------------------------
install_network_tools() {
    echo -e "${Y}🌐 Installing essential network & security tools...${N}"
    if command -v apt &>/dev/null; then
        sudo apt install -y curl wget net-tools nmap traceroute iptables ufw
    elif command -v yum &>/dev/null; then
        sudo yum install -y curl wget net-tools nmap traceroute iptables-services firewalld
    elif command -v pacman &>/dev/null; then
        sudo pacman -Sy --noconfirm curl wget net-tools nmap iptables ufw
    fi
}

# ---------------------------
# MENU OPTIONS
# ---------------------------
OPTIONS=(
"🐙 GitHub VPS Maker"
"🛠 IDX Tool Setup"
"🖥 ZEROX IDX VPS Maker"
"🌍 ZEROX Real VPS (Any + KVM)"
"📊 System Info & Monitoring"
"⚡ Multi-VPS Batch Deploy"
"🔒 Security & Firewall Setup"
"💾 Backup & Snapshot Manager"
"☁️ Cloud & API Integration"
"📝 Logs & Alerts"
"❌ Exit"
)

# ---------------------------
# DETECT DEFAULT RESOURCES
# ---------------------------
detect_resources() {
    if [ -f "/.codespaces/environment" ]; then
        DEFAULT_RAM=2048
        DEFAULT_CPU=2
        echo -e "${Y}💻 Detected GitHub Codespaces${N}"
    elif grep -qi 'microsoft' /proc/version &>/dev/null; then
        DEFAULT_RAM=1024
        DEFAULT_CPU=1
        echo -e "${Y}🖥 Detected WSL${N}"
    else
        DEFAULT_RAM=$(free -m | awk '/Mem:/ {print int($2/2)}')
        DEFAULT_CPU=$(nproc)
        echo -e "${Y}🌐 Standard VPS / Linux${N}"
    fi
}

# ---------------------------
# INTERACTIVE MENU LOOP
# ---------------------------
interactive_menu() {
    local selected=0
    local total=${#OPTIONS[@]}

    while true; do
        clear
        print_zerox_logo
        echo -e "${C}Use arrow keys ↑ ↓ to navigate, ENTER to select${N}\n"

        for i in "${!OPTIONS[@]}"; do
            if [ "$i" -eq "$selected" ]; then
                echo -e "${R} > ${OPTIONS[$i]}${N}"
            else
                echo -e "   ${OPTIONS[$i]}"
            fi
        done

        read -rsn1 key
        if [[ $key == $'\x1b' ]]; then
            read -rsn2 -t 0.1 key
            if [[ $key == "[A" ]]; then
                ((selected--))
                ((selected<0)) && selected=$((total-1))
            elif [[ $key == "[B" ]]; then
                ((selected++))
                ((selected>=total)) && selected=0
            fi
        elif [[ $key == "" ]]; then
            run_option "$selected"
        fi
    done
}

# ---------------------------
# MENU OPTION HANDLER
# ---------------------------
run_option() {
    case $1 in
        0) github_vps ;;
        1) idx_setup ;;
        2) idx_vps ;;
        3) real_vps ;;
        4) system_info ;;
        5) multi_vps ;;
        6) security_firewall ;;
        7) backup_manager ;;
        8) cloud_integration ;;
        9) logs_alerts ;;
        10) exit_zero ;;
    esac
}

# ---------------------------
# OPTION FUNCTIONS
# ---------------------------
github_vps() {
    clear; print_zerox_logo
    install_docker
    echo -e "${G}🐙 Launching GitHub VPS Maker...${N}"
    RAM=${DEFAULT_RAM}
    CPU=${DEFAULT_CPU}
    DISK_SIZE=100G
    CONTAINER_NAME=zeroxvm-github
    IMAGE_NAME=ubuntu:22.04
    VMDATA_DIR="$PWD/vmdata"
    mkdir -p "$VMDATA_DIR"
    docker run -it --rm --name "$CONTAINER_NAME" --device /dev/kvm \
        -v "$VMDATA_DIR":/vmdata -e RAM="$RAM" -e CPU="$CPU" -e DISK_SIZE="$DISK_SIZE" "$IMAGE_NAME"
    read -p "Press Enter to return..."
}

idx_setup() {
    clear; print_zerox_logo
    echo -e "${G}🛠 Setting up ZEROX IDX Tool...${N}"
    mkdir -p ~/zeroxvm/.idx
    cd ~/zeroxvm/.idx || return
    cat <<EOF > dev.nix
{ pkgs, ... }: {
  channel = "stable-24.05";
  packages = with pkgs; [ unzip openssh git qemu_kvm sudo cdrkit cloud-utils qemu ];
  env = { EDITOR = "nano"; };
}
EOF
    echo -e "${G}✅ ZEROX IDX Tool Setup Complete!${N}"
    read -p "Press Enter to return..."
}

idx_vps() {
    clear; print_zerox_logo
    echo -e "${G}🖥 Running ZEROX IDX VPS Maker...${N}"
    echo -e "${Y}⚡ Placeholder for ZEROX IDX VPS script.${N}"
    read -p "Press Enter to return..."
}

real_vps() {
    clear; print_zerox_logo
    install_docker
    echo -e "${G}🌍 Launching ZEROX Real VPS...${N}"
    echo -e "${Y}⚡ Placeholder for your own KVM/Docker VPS scripts.${N}"
    read -p "Press Enter to return..."
}

system_info() {
    clear; print_zerox_logo
    echo -e "${G}📊 System Information & Monitoring:${N}"
    install_fetch_tool
    [ -n "$FETCH_TOOL" ] && $FETCH_TOOL || echo -e "${R}⚠️ No fetch tool installed.${N}"
    echo -e "${C}\n💾 Disk Usage:${N}"
    df -h
    echo -e "${C}\n📈 Top Processes:${N}"
    top -b -n 1 | head -20
    echo -e "${C}\n🌐 Network Info:${N}"
    ip a
    read -p "Press Enter to return..."
}

multi_vps() {
    clear; print_zerox_logo
    install_docker
    echo -e "${M}⚡ Multi-VPS Batch Deploy${N}"
    read -p "Enter number of VPS instances to deploy: " VPS_COUNT
    read -p "Enter Docker image for VPS (default ubuntu:22.04): " VPS_IMAGE
    VPS_IMAGE=${VPS_IMAGE:-ubuntu:22.04}

    if ! [[ "$VPS_COUNT" =~ ^[0-9]+$ ]]; then
        echo -e "${R}Invalid number!${N}"
        sleep 1
        return
    fi

    for ((i=1;i<=VPS_COUNT;i++)); do
        echo -e "${G}🚀 Deploying VPS #$i using $VPS_IMAGE ...${N}"
        docker run -dit --name "zeroxvm-$i" "$VPS_IMAGE"
        sleep 1
    done
    echo -e "${G}✅ Deployed $VPS_COUNT VPS instances successfully!${N}"
    read -p "Press Enter to return..."
}

security_firewall() {
    clear; print_zerox_logo
    install_network_tools
    echo -e "${M}🔒 Security & Firewall Setup${N}"
    if command -v ufw &>/dev/null; then
        sudo ufw enable
        sudo ufw default deny incoming
        sudo ufw default allow outgoing
        sudo ufw allow ssh
        echo -e "${G}✅ UFW Firewall Enabled with SSH allowed.${N}"
    elif command -v firewall-cmd &>/dev/null; then
        sudo systemctl enable --now firewalld
        sudo firewall-cmd --permanent --add-service=ssh
        sudo firewall-cmd --reload
        echo -e "${G}✅ Firewalld Enabled with SSH allowed.${N}"
    fi
    read -p "Press Enter to return..."
}

backup_manager() {
    clear; print_zerox_logo
    echo -e "${M}💾 Backup & Snapshot Manager${N}"
    read -p "Enter container name to backup: " CONTAINER_NAME
    BACKUP_FILE="${CONTAINER_NAME}-backup-$(date +%F-%H%M%S).tar"
    docker export "$CONTAINER_NAME" -o "$BACKUP_FILE" && echo -e "${G}✅ Backup saved as $BACKUP_FILE${N}"
    read -p "Press Enter to return..."
}

cloud_integration() {
    clear; print_zerox_logo
    echo -e "${C}☁️ Cloud & API Integration${N}"
    echo -e "${Y}⚡ Placeholder for AWS, GCP, Azure, DigitalOcean API deployment scripts${N}"
    read -p "Press Enter to return..."
}

logs_alerts() {
    clear; print_zerox_logo
    echo -e "${C}📝 Logs & Alerts${N}"
    echo -e "${Y}⚡ Collecting last 50 system logs...${N}"
    journalctl -n 50 --no-pager
    echo -e "${Y}\n⚡ Placeholder for real-time alert system (email, Telegram, Slack)${N}"
    read -p "Press Enter to return..."
}

exit_zero() {
    clear; print_zerox_logo
    echo -e "${R}❌ ZEROXVM Session Terminated.${N}\n"
    exit 0
}

# ---------------------------
# START SCRIPT
# ---------------------------
detect_resources
interactive_menu
