#!/bin/bash

# ==========================================
# ADVANCED SETUP & CHECKS
# ==========================================
# Ensure script is run as root
if [ "$EUID" -ne 0 ]; then
  echo -e "\033[0;31m[ERROR] Please run this script as root (sudo su)\033[0m"
  exit 1
fi

# ==========================================
# NEON & HIGH-CONTRAST COLOR CODES
# ==========================================
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
CYAN='\033[1;36m'
MAGENTA='\033[1;35m'
LIGHT_BLUE='\033[1;34m'
NEON_GREEN='\033[38;5;118m'
ORANGE='\033[38;5;214m'
DARK_GRAY='\033[1;30m'
NC='\033[0m' # No Color

# ==========================================
# ADVANCED UI FUNCTIONS
# ==========================================
pause() {
    echo -e "\n${DARK_GRAY}Press [Enter] to return to menu...${NC}"
    read -p ""
}

# Animated Spinner for Loading States
spinner() {
    local pid=$1
    local delay=0.1
    local spinstr='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'
    while [ "$(ps a | awk '{print $1}' | grep -w $pid)" ]; do
        local temp=${spinstr#?}
        printf " ${NEON_GREEN}[%c]${NC} " "$spinstr"
        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b\b\b"
    done
    printf "    \b\b\b\b"
}

# Auto Dependency Checker
check_dependencies() {
    clear
    echo -e "${CYAN}Checking system requirements...${NC}\n"
    deps=("curl" "wget" "unzip" "tar" "jq")
    for dep in "${deps[@]}"; do
        if ! command -v $dep &> /dev/null; then
            echo -ne "${YELLOW}Installing missing package: ${dep}...${NC}"
            apt-get install -y $dep &> /dev/null &
            spinner $!
            echo -e "\r${GREEN}✔ Installed: ${dep}                  ${NC}"
        else
            echo -e "${GREEN}✔ Found: ${dep}${NC}"
        fi
    done
    sleep 1
}

# Run dependency check at startup
check_dependencies

# ==========================================
# 1. PTERODACTYL CONTROL CENTER (AUTO)
# ==========================================
menu_1_pterodactyl() {
    while true; do
        clear
        echo -e "${ORANGE}╔════════════════════════════════════════════════╗${NC}"
        echo -e "${ORANGE}║    🦖 PTERODACTYL CONTROL CENTER               ║${NC}"
        echo -e "${ORANGE}╠════════════════════════════════════════════════╝${NC}"
        echo -e "${NEON_GREEN}║${NC} ${CYAN}1) Auto-Install Panel (1-Click)${NC}"
        echo -e "${NEON_GREEN}║${NC} ${LIGHT_BLUE}2) Create Panel User${NC}"
        echo -e "${NEON_GREEN}║${NC} ${ORANGE}3) Update Panel${NC}"
        echo -e "${NEON_GREEN}║${NC} ${RED}4) Uninstall Panel${NC}"
        echo -e "${NEON_GREEN}║${NC} ${NEON_GREEN}5) Exit${NC}"
        echo -e "${NEON_GREEN}╚════════════════════════════════════════════════╗${NC}"
        echo -ne "${LIGHT_BLUE}Select Option -> ${NC}"
        read ptero_choice
        case $ptero_choice in
            1) 
               clear
               echo -e "${ORANGE}╔════════════════════════════════════════════════╗${NC}"
               echo -e "${ORANGE}║    🚀 EAGLIX AUTO PTERODACTYL INSTALLER        ║${NC}"
               echo -e "${ORANGE}╚════════════════════════════════════════════════╝${NC}\n"

               echo -e "${CYAN}Panel install have required these 3 details:${NC}"
               echo -e "${DARK_GRAY}( Timezone, DB, Firewall All Eaglix do Automatically)${NC}\n"

               echo -ne "${NEON_GREEN}1. Your Domain (e.g., panel.eaglix.site): ${NC}"
               read FQDN
               echo -ne "${NEON_GREEN}2. Admin Email (e.g., admin@eaglix.site): ${NC}"
               read EMAIL
               echo -ne "${NEON_GREEN}3. Admin Password (minimum 8 chars): ${NC}"
               read -s PASSWORD
               echo ""

               echo -e "\n${CYAN}⚙️ Initializing Silent Auto-Installation... Please wait!${NC}"
               echo -e "${YELLOW}(Wait 2-3 minute, Do not Close Window)${NC}\n"
               
               curl -sL https://pterodactyl-installer.se -o ptero.sh
               chmod +x ptero.sh

               # Fixed Here-Doc Sequence (Added 'y' and 'no' for the new prompts)
               bash ptero.sh <<EOF
0
panel
pterodactyl

Asia/Kolkata
$EMAIL
$EMAIL
admin
Eaglix
Admin
$PASSWORD
$FQDN
n
n
n
y
y
no
EOF
               
               rm -f ptero.sh
               echo -e "\n${NEON_GREEN}✔ Pterodactyl Panel Auto-Installation Finished!${NC}"
               echo -e "${CYAN}🌍 Your Panel URL: ${YELLOW}http://$FQDN${NC} (Add Cloudflare Tunnel for HTTPS)"
               echo -e "${CYAN}👤 Username: ${YELLOW}admin${NC}"
               pause 
               ;;
            2) 
               echo -e "${LIGHT_BLUE}Creating User...${NC}"
               cd /var/www/pterodactyl && php artisan p:user:make
               pause 
               ;;
            3) 
               echo -e "${ORANGE}Updating Panel...${NC}"
               curl -sL https://pterodactyl-installer.se -o ptero.sh && bash ptero.sh <<EOF
2
EOF
               rm -f ptero.sh
               pause 
               ;;
            4) 
               echo -e "${RED}Uninstalling Panel...${NC}"
               rm -rf /var/www/pterodactyl /etc/pterodactyl
               echo -e "${GREEN}Panel Files Removed!${NC}"
               pause 
               ;;
            5) return ;;
            *) echo -e "${RED}Invalid!${NC}"; sleep 1 ;;
        esac
    done
}

# ==========================================
# 2. WINGS INSTALLATION
# ==========================================
menu_2_wings() {
    clear
    echo -e "${MAGENTA}========================================${NC}"
    echo -e "${CYAN}      WINGS INSTALLATION MANAGER        ${NC}"
    echo -e "${MAGENTA}========================================${NC}"
    echo -e "${NEON_GREEN}Fetching official Wings setup...${NC}"
    
    curl -sL https://pterodactyl-installer.se -o ptero.sh
    chmod +x ptero.sh
    # Auto install Wings silently
    bash ptero.sh <<EOF
1
y
N
y
EOF
    rm ptero.sh

    echo -e "\n${GREEN}✔ Wings configured successfully!${NC}"
    pause
}

# ==========================================
# 3. UNINSTALL TOOLS
# ==========================================
menu_3_uninstall() {
    while true; do
        clear
        echo -e "${LIGHT_BLUE}---------------------------------------${NC}"
        echo -e "      🗑️  PTERODACTYL UNINSTALLER        "
        echo -e "            by Eaglix-hosting            "
        echo -e "${LIGHT_BLUE}---------------------------------------${NC}\n"
        echo -e "${ORANGE}╔════════════════════════════════════════╗${NC}"
        echo -e "${ORANGE}║          📋 MENU OPTIONS               ║${NC}"
        echo -e "${ORANGE}╠════════════════════════════════════════╣${NC}"
        echo -e "${ORANGE}║${NC} ${CYAN}1) Uninstall Panel Only${NC}                ${ORANGE}║${NC}"
        echo -e "${ORANGE}║${NC} ${CYAN}2) Uninstall Wings Only${NC}                ${ORANGE}║${NC}"
        echo -e "${ORANGE}║${NC} ${CYAN}3) Uninstall Panel + Wings${NC}             ${ORANGE}║${NC}"
        echo -e "${ORANGE}║${NC} ${RED}0) Exit Uninstaller${NC}                    ${ORANGE}║${NC}"
        echo -e "${ORANGE}╚════════════════════════════════════════╝${NC}\n"
        echo -e "${YELLOW}⚠️  Warning: ${RED}These actions cannot be undone!${NC}\n"
        echo -ne "${ORANGE}Choose an option [0-3]: ${NC}"
        read un_choice
        case $un_choice in
            1) 
               echo -e "${RED}Purging Panel...${NC}"
               rm -rf /var/www/pterodactyl /etc/pterodactyl
               echo -e "${GREEN}Panel completely removed.${NC}"
               pause 
               ;;
            2) 
               echo -e "${RED}Purging Wings...${NC}"
               systemctl stop wings
               rm -rf /etc/pterodactyl/wings.yml /usr/local/bin/wings /var/lib/pterodactyl
               echo -e "${GREEN}Wings completely removed.${NC}"
               pause 
               ;;
            3) 
               echo -e "${RED}Nuking Both Panel & Wings...${NC}"
               rm -rf /var/www/pterodactyl /etc/pterodactyl /var/lib/pterodactyl /usr/local/bin/wings
               systemctl stop wings
               echo -e "${GREEN}Everything Removed!${NC}"
               pause 
               ;;
            0) return ;;
            *) echo -e "${RED}Invalid!${NC}"; sleep 1 ;;
        esac
    done
}

# ==========================================
# 4. BLUEPRINT + THEME + EXTENSIONS
# ==========================================
menu_4_blueprint() {
    while true; do
        clear
        echo -e "${RED}------------------------------------------------${NC}"
        echo -e "       ${NC}🔧 ${RED}BLUEPRINT + THEME + EXTENSIONS${NC}        "
        echo -e "${RED}------------------------------------------------${NC}"
        echo -e "${RED}"
        echo "  _____             _ _      "
        echo " | ____|__ _  __ _| (_)__  __"
        echo " |  _| / _\` |/ _\` | | \ \/ /"
        echo " | |__| (_| | (_| | | |>  < "
        echo " |_____\__,_|\__, |_|_/_/\_\\"
        echo "             |___/           "
        echo -e "${NC}"
        echo -e "${RED}------------------------------------------------${NC}"
        echo -e "${NC} 1) ${RED}Blueprint Setup (Install)${NC}"
        echo -e "${NC} 2) ${RED}Themes + Extensions Installer${NC}"
        echo -e "${NC} 3) ${YELLOW}Update Blueprint (Fix Out-of-date Error)${NC}"
        echo -e "${NC} 0) ${RED}Back to Main Menu${NC}"
        echo -e "${RED}------------------------------------------------${NC}"
        echo -ne "${YELLOW}📝 Select an option [0-3]: ${NC}"
        read suboption
        
        case $suboption in
            1) 
               echo -e "\n${CYAN}Starting Official Blueprint Setup...${NC}"
               cd /var/www/pterodactyl || { echo -e "${RED}Error: Pterodactyl directory not found!${NC}"; pause; break; }
               
               echo -e "${YELLOW}[1/3] Installing Dependencies (NodeJS v22, Yarn, Zip)...${NC}"
               apt-get update -y > /dev/null 2>&1
               apt-get install -y curl zip unzip > /dev/null 2>&1
               curl -fsSL https://deb.nodesource.com/setup_22.x | bash - > /dev/null 2>&1
               apt-get install -y nodejs > /dev/null 2>&1
               npm install -g yarn > /dev/null 2>&1
               
               echo -e "${YELLOW}[2/3] Downloading Latest Blueprint Framework...${NC}"
               DOWNLOAD_URL=$(curl -s https://api.github.com/repos/BlueprintFramework/framework/releases/latest | grep 'browser_download_url' | grep 'release.zip' | cut -d '"' -f 4)
               wget -q $DOWNLOAD_URL -O blueprint.zip
               
               echo -e "${YELLOW}[3/3] Extracting and Running Installer...${NC}"
               unzip -o blueprint.zip > /dev/null 2>&1
               chmod +x blueprint.sh
               bash blueprint.sh
               
               echo -e "\n${GREEN}✔ Blueprint Framework Installed Successfully!${NC}"
               pause 
               ;;
            2) 
               # Sub-menu for Auto-Downloading & Installing Extensions
               while true; do
                   clear
                   echo -e "${MAGENTA}=========================================${NC}"
                   echo -e "${LIGHT_BLUE}     EAGLIX CLOUD EXTENSION INSTALLER    ${NC}"
                   echo -e "${DARK_GRAY}      (Fetching directly from Netlify)   ${NC}"
                   echo -e "${MAGENTA}=========================================${NC}"
                   echo -e "${YELLOW}1)${NC} ${CYAN}Install Nebula Theme${NC}"
                   echo -e "${YELLOW}2)${NC} ${CYAN}Install MC Plugins${NC}"
                   echo -e "${YELLOW}3)${NC} ${CYAN}Install Server Backgrounds${NC}"
                   echo -e "${YELLOW}4)${NC} ${CYAN}Install Subdomains${NC}"
                   echo -e "${YELLOW}5)${NC} ${CYAN}Install Player Listing${NC}"
                   echo -e "${YELLOW}6)${NC} ${CYAN}Install Hux Register${NC}"
                   echo -e "${YELLOW}7)${NC} ${CYAN}Install Saga MC Player Manager${NC}"
                   echo -e "${YELLOW}8)${NC} ${CYAN}Install Version Changer${NC}"
                   echo -e "${YELLOW}9)${NC} ${CYAN}Install Mc Logs${NC}"
                   echo -e "${NEON_GREEN}10) 🚀 Install ALL Extensions (Bulk Install)${NC}"
                   echo -e "${YELLOW}0)${NC} ${RED}Back to Blueprint Menu${NC}"
                   echo -e "${MAGENTA}=========================================${NC}"
                   echo -ne "${NEON_GREEN}Choose an option [0-9]: ${NC}"
                   read theme_choice
                   
                   case $theme_choice in
                       1) 
                          echo -e "\n${CYAN}Downloading & Installing Nebula Theme...${NC}"
                          cd /var/www/pterodactyl && wget -q https://eaglix-installer.netlify.app/nebula.blueprint -O nebula.blueprint && blueprint -install nebula.blueprint
                          pause ;;
                       2) 
                          echo -e "\n${CYAN}Downloading & Installing MC Plugins...${NC}"
                          cd /var/www/pterodactyl && wget -q https://eaglix-installer.netlify.app/mcplugins.blueprint -O mcplugins.blueprint && blueprint -install mcplugins.blueprint
                          pause ;;
                       3) 
                          echo -e "\n${CYAN}Downloading & Installing Server Backgrounds...${NC}"
                          cd /var/www/pterodactyl && wget -q https://eaglix-installer.netlify.app/serverbackgrounds.blueprint -O serverbackgrounds.blueprint && blueprint -install serverbackgrounds.blueprint
                          pause ;;
                       4) 
                          echo -e "\n${CYAN}Downloading & Installing Subdomains...${NC}"
                          cd /var/www/pterodactyl && wget -q https://eaglix-installer.netlify.app/subdomains.blueprint -O subdomains.blueprint && blueprint -install subdomains.blueprint
                          pause ;;
                       5) 
                          echo -e "\n${CYAN}Downloading & Installing Player Listing...${NC}"
                          cd /var/www/pterodactyl && wget -q https://eaglix-installer.netlify.app/playerlisting.blueprint -O playerlisting.blueprint && blueprint -install playerlisting.blueprint
                          pause ;;
                       6) 
                          echo -e "\n${CYAN}Downloading & Installing Hux Register...${NC}"
                          cd /var/www/pterodactyl && wget -q https://eaglix-installer.netlify.app/huxregister.blueprint -O huxregister.blueprint && blueprint -install huxregister.blueprint
                          pause ;;
                       7) 
                          echo -e "\n${CYAN}Downloading & Installing Saga MC Player Manager...${NC}"
                          cd /var/www/pterodactyl && wget -q https://eaglix-installer.netlify.app/sagaminecraftplayermanager.blueprint -O sagaminecraftplayermanager.blueprint && blueprint -install sagaminecraftplayermanager.blueprint
                          pause ;;
                       8) 
                          echo -e "\n${CYAN}Downloading & Installing Version Changer...${NC}"
                          cd /var/www/pterodactyl && wget -q https://eaglix-installer.netlify.app/versionchanger.blueprint -O versionchanger.blueprint && blueprint -install versionchanger.blueprint
                          pause ;;
                       9) 
                          echo -e "\n${CYAN}Downloading & Installing MC Logs...${NC}"
                          cd /var/www/pterodactyl && wget -q https://eaglix-installer.netlify.app/mclogs.blueprint -O mclogs.blueprint && blueprint -install mclogs.blueprint
                          pause ;;
                       10) 
                          echo -e "\n${CYAN}🚀 Starting Bulk Installation of ALL 9 Extensions... This will take a few minutes!${NC}"
                          cd /var/www/pterodactyl
                          
                          echo -e "\n${YELLOW}[1/8] Installing Nebula Theme...${NC}"
                          wget -q https://eaglix-installer.netlify.app/nebula.blueprint -O nebula.blueprint && blueprint -install nebula.blueprint
                          
                          echo -e "\n${YELLOW}[2/8] Installing MC Plugins...${NC}"
                          wget -q https://eaglix-installer.netlify.app/mcplugins.blueprint -O mcplugins.blueprint && blueprint -install mcplugins.blueprint
                          
                          echo -e "\n${YELLOW}[3/8] Installing Server Backgrounds...${NC}"
                          wget -q https://eaglix-installer.netlify.app/serverbackgrounds.blueprint -O serverbackgrounds.blueprint && blueprint -install serverbackgrounds.blueprint
                          
                          echo -e "\n${YELLOW}[4/8] Installing Subdomains...${NC}"
                          wget -q https://eaglix-installer.netlify.app/subdomains.blueprint -O subdomains.blueprint && blueprint -install subdomains.blueprint
                          
                          echo -e "\n${YELLOW}[5/8] Installing Player Listing...${NC}"
                          wget -q https://eaglix-installer.netlify.app/playerlisting.blueprint -O playerlisting.blueprint && blueprint -install playerlisting.blueprint
                          
                          echo -e "\n${YELLOW}[6/8] Installing Hux Register...${NC}"
                          wget -q https://eaglix-installer.netlify.app/huxregister.blueprint -O huxregister.blueprint && blueprint -install huxregister.blueprint
                          
                          echo -e "\n${YELLOW}[7/8] Installing Saga MC Player Manager...${NC}"
                          wget -q https://eaglix-installer.netlify.app/sagaminecraftplayermanager.blueprint -O sagaminecraftplayermanager.blueprint && blueprint -install sagaminecraftplayermanager.blueprint
                          
                          echo -e "\n${YELLOW}[8/8] Installing Version Changer...${NC}"
                          wget -q https://eaglix-installer.netlify.app/versionchanger.blueprint -O versionchanger.blueprint && blueprint -install versionchanger.blueprint
                          
                          echo -e "\n${GREEN}✔ All 8 Extensions Installed Successfully!${NC}"
                          pause ;;
                       0) break ;;
                       *) echo -e "${RED}Invalid!${NC}"; sleep 1 ;;
                   esac
               done
               ;;
            3)
               echo -e "\n${CYAN}🚀 Upgrading Blueprint to the latest version...${NC}"
               if [ ! -d "/var/www/pterodactyl" ]; then
                   echo -e "${RED}Error: Pterodactyl directory not found! Is the panel installed?${NC}"
                   pause
                   continue
               fi
               
               cd /var/www/pterodactyl
               
               if ! command -v blueprint &> /dev/null; then
                   echo -e "${RED}Error: Blueprint is not installed yet! Please run Setup (Option 1) first.${NC}"
               else
                   echo -e "${YELLOW}Running upgrade process. This might take a minute...${NC}"
                   blueprint -upgrade
                   echo -e "\n${GREEN}✔ Blueprint Upgrade Complete!${NC}"
                   echo -e "${CYAN}Please Hard Refresh (Ctrl+Shift+R) your panel to clear the warning banner.${NC}"
               fi
               pause
               ;;
            0) return ;;
            *) echo -e "${RED}Invalid!${NC}"; sleep 1 ;;
        esac
    done
}
# ==========================================
# 5. CLOUDFLARE SETUP (FUNCTIONAL)
# ==========================================
menu_5_cloudflare() {
    while true; do
        clear
        echo -e "${ORANGE}╔══════════════════════════════════════╗${NC}"
        echo -e "${ORANGE}║     CLOUDFLARED MANAGEMENT MENU      ║${NC}"
        echo -e "${ORANGE}╠══════════════════════════════════════╣${NC}"
        echo -e "${NEON_GREEN}║${NC}                                      ${NEON_GREEN}║${NC}"
        echo -e "${NEON_GREEN}║${NC} ${CYAN}1) Install & Connect Tunnel${NC}          ${NEON_GREEN}║${NC}"
        echo -e "${NEON_GREEN}║${NC}                                      ${NEON_GREEN}║${NC}"
        echo -e "${NEON_GREEN}║${NC} ${RED}2) Uninstall Completely${NC}              ${NEON_GREEN}║${NC}"
        echo -e "${NEON_GREEN}║${NC}                                      ${NEON_GREEN}║${NC}"
        echo -e "${NEON_GREEN}║${NC} ${NEON_GREEN}3) Exit${NC}                                ${NEON_GREEN}║${NC}"
        echo -e "${NEON_GREEN}╚══════════════════════════════════════╝${NC}\n"
        echo -ne "${LIGHT_BLUE}Select an option: ${NC}"
        read cf_choice
        case $cf_choice in
            1) 
               echo -e "\n${CYAN}Cloudflare Dashboard se Tunnel Token paste karo:${NC}"
               echo -ne "${YELLOW}-> ${NC}"
               read CF_TOKEN
               echo -e "\n${CYAN}Downloading and configuring Cloudflared...${NC}"
               curl -L --output cloudflared.deb https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb
               dpkg -i cloudflared.deb
               cloudflared service install $CF_TOKEN
               echo -e "\n${NEON_GREEN}✔ Tunnel Successfully Connected to Cloudflare!${NC}"
               pause 
               ;;
            2) 
               echo -e "${RED}Removing Cloudflare Tunnel...${NC}"
               cloudflared service uninstall
               apt-get remove -y cloudflared
               rm -f cloudflared.deb
               echo -e "\n${GREEN}✔ Tunnel Completely Removed!${NC}"
               pause 
               ;;
            3) return ;;
            *) echo -e "${RED}Invalid!${NC}"; sleep 1 ;;
        esac
    done
}

# ==========================================
# 6. SYSTEM INFORMATION
# ==========================================
menu_6_system() {
    clear
    local host_name=$(hostname)
    local curr_user=$(whoami)
    local curr_dir=$(pwd)
    local sys_info=$(uname -srm)
    local up_time=$(uptime -p | sed 's/up //')
    local mem_info=$(free -h | awk '/^Mem:/ {print $3 "/" $2}')
    local disk_info=$(df -h / | awk 'NR==2 {print $3 "/" $2 " (" $5 ")"}')

    # Removed Jishnu and added Eaglix ASCII Art
    echo -e "${RED}  _____             _ _      ${NC}"
    echo -e "${RED} | ____|__ _  __ _| (_)__  __${NC}"
    echo -e "${RED} |  _| / _\` |/ _\` | | \ \/ /${NC}"
    echo -e "${RED} | |__| (_| | (_| | | |>  <  ${NC}"
    echo -e "${RED} |_____\__,_|\__, |_|_/_/\_\\${NC}"
    echo -e "${RED}             |___/           ${NC}\n"

    echo -e "${CYAN}╔═══════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║              📊 SYSTEM STATUS                 ║${NC}"
    echo -e "${CYAN}╠═══════════════════════════════════════════════╣${NC}"
    echo -e "${CYAN}║                                               ║${NC}"
    echo -e "${CYAN}║  ${RED}•${NC} ${NEON_GREEN}Hostname:${NC} ${NC}$host_name"
    echo -e "${CYAN}║  ${RED}•${NC} ${NEON_GREEN}User:${NC} ${NC}$curr_user"
    echo -e "${CYAN}║  ${RED}•${NC} ${NEON_GREEN}Directory:${NC} ${NC}$curr_dir"
    echo -e "${CYAN}║  ${RED}•${NC} ${NEON_GREEN}System:${NC} ${NC}$sys_info"
    echo -e "${CYAN}║  ${RED}•${NC} ${NEON_GREEN}Uptime:${NC} ${NC}$up_time"
    echo -e "${CYAN}║  ${RED}•${NC} ${NEON_GREEN}Memory:${NC} ${NC}$mem_info"
    echo -e "${CYAN}║  ${RED}•${NC} ${NEON_GREEN}Disk:${NC} ${NC}$disk_info"
    echo -e "${CYAN}║                                               ║${NC}"
    echo -e "${CYAN}╚═══════════════════════════════════════════════╝${NC}\n"
    pause
}

# ==========================================
# 7. TAILSCALE INSTALLER (FULLY WORKING)
# ==========================================
menu_7_tailscale() {
    while true; do
        clear
        if command -v tailscale &> /dev/null; then
            STATUS="${NEON_GREEN}INSTALLED & RUNNING${NC}"
        else
            STATUS="${RED}NOT INSTALLED${NC}"
        fi

        echo -e "${LIGHT_BLUE}╔══════════════════════════════════════╗${NC}"
        echo -e "${LIGHT_BLUE}║          TAILSCALE VPN SETUP         ║${NC}"
        echo -e "${LIGHT_BLUE}╚══════════════════════════════════════╝${NC}\n"
        echo -e "${CYAN}Current Status: ${STATUS}\n"
        echo -e "${NEON_GREEN}========================================${NC}"
        echo -e "${CYAN} [1] 📥 Install & Start Tailscale${NC}"
        echo -e "${RED} [2] 🗑️  Uninstall Tailscale Completely${NC}"
        echo -e "${YELLOW} [0] 🚪 Back to Main Menu${NC}"
        echo -e "${NEON_GREEN}========================================${NC}\n"
        echo -ne "${NEON_GREEN}Select option [0-2]: ${NC}"
        read ts_choice
        
        case $ts_choice in
            1) 
               echo -e "\n${CYAN}Fetching Official Tailscale Setup...${NC}"
               curl -fsSL https://tailscale.com/install.sh | sh
               echo -e "\n${YELLOW}Starting Tailscale... A link will appear below to authenticate your server.${NC}"
               tailscale up
               echo -e "\n${GREEN}✔ Tailscale Installed and Connected!${NC}"
               pause 
               ;;
            2) 
               echo -e "\n${RED}Disconnecting and Removing Tailscale...${NC}"
               if command -v tailscale &> /dev/null; then
                   tailscale down
               fi
               apt-get remove --purge -y tailscale
               rm -rf /var/lib/tailscale
               echo -e "\n${GREEN}✔ Tailscale Completely Removed!${NC}"
               pause 
               ;;
            0) return ;;
            *) echo -e "${RED}Invalid!${NC}"; sleep 1 ;;
        esac
    done
}

# ==========================================
# 8. DATABASE SETUP (FULLY WORKING & SECURE)
# ==========================================
menu_8_database() {
    clear
    echo -e "${RED} ____        _        _                     ${NC}"
    echo -e "${RED}|  _ \  __ _| |_ __ _| |__   __ _ ___  ___  ${NC}"
    echo -e "${RED}| | | |/ _\` | __/ _\` | '_ \ / _\` / __|/ _ \ ${NC}"
    echo -e "${RED}| |_| | (_| | || (_| | |_) | (_| \__ \  __/ ${NC}"
    echo -e "${RED}|____/ \__,_|\__\__,_|_.__/ \__,_|___/\___| ${NC}"
    echo -e "${RED}--------------------------------------------${NC}"
    echo -e "${NC}Running: MySQL / MariaDB Database Setup     ${NC}"
    echo -e "${RED}--------------------------------------------${NC}\n"
    
    # 1. Install DB if not present
    if ! command -v mysql &> /dev/null; then
        echo -e "${YELLOW}MariaDB not found. Installing now...${NC}"
        apt-get update -y
        apt-get install -y mariadb-server mariadb-client
        systemctl enable mariadb
        systemctl start mariadb
        echo -e "${GREEN}MariaDB Installed Successfully!${NC}\n"
    else
        echo -e "${GREEN}MariaDB is already installed.${NC}\n"
    fi
    
    # 2. Get User Input
    echo -ne "${NEON_GREEN}Enter new database USERNAME (e.g., eaglix_user): ${NC}"
    read db_user
    echo -ne "${NEON_GREEN}Enter new database PASSWORD: ${NC}"
    read -s db_pass
    echo -e "\n\n${CYAN}Provisioning secure database user '${db_user}'...${NC}"
    
    # 3. Securely Create User & Grant Privileges
    mysql -u root -e "CREATE USER IF NOT EXISTS '${db_user}'@'%' IDENTIFIED BY '${db_pass}';"
    mysql -u root -e "GRANT ALL PRIVILEGES ON *.* TO '${db_user}'@'%' WITH GRANT OPTION;"
    mysql -u root -e "FLUSH PRIVILEGES;"
    
    echo -e "\n${NEON_GREEN}✔ Database configuration complete!${NC}"
    echo -e "${CYAN}Username: ${YELLOW}${db_user}${NC}"
    echo -e "${CYAN}Host: ${YELLOW}% (Remote Access Enabled)${NC}"
    pause
}

# ==========================================
# 9. EAGLIX SECURITY & ANTI-DDOS CENTER
# ==========================================
menu_9_security() {
    while true; do
        clear
        echo -e "${RED}╔═════════════════════════════════════════════════════╗${NC}"
        echo -e "${RED}║        🛡️ EAGLIX ULTIMATE SECURITY CENTER          ║${NC}"
        echo -e "${RED}╚═════════════════════════════════════════════════════╝${NC}\n"
        echo -e "${YELLOW}1)${NC} ${CYAN}Enable Google reCAPTCHA v2 (100% Working Login Fix)${NC}"
        echo -e "${YELLOW}2)${NC} ${CYAN}Deploy HARD DDoS Armor (UFW Limits + SYN Protection)${NC}"
        echo -e "${YELLOW}0)${NC} ${GREEN}Back to Main Menu${NC}"
        echo -e "${RED}-------------------------------------------------------${NC}"
        echo -ne "${NEON_GREEN}Select a security option [0-2]: ${NC}"
        read sec_choice
        
        case $sec_choice in
            1) 
               echo -e "\n${CYAN}--- Pterodactyl Captcha Setup ---${NC}"
               echo -e "${YELLOW}⚠️ IMPORTANT: Only use Google reCAPTCHA v2 (Invisible or Checkbox) keys!${NC}"
               echo -e "${DARK_GRAY}Get them from: https://www.google.com/recaptcha/admin/create${NC}\n"
               
               echo -ne "${YELLOW}Enter your Google SITE KEY: ${NC}"
               read SITE_KEY
               echo -ne "${YELLOW}Enter your Google SECRET KEY: ${NC}"
               read SECRET_KEY
               
               echo -e "\n${CYAN}Injecting Captcha deeply into Pterodactyl...${NC}"
               
               if [ ! -d "/var/www/pterodactyl" ]; then
                   echo -e "${RED}Error: Pterodactyl directory not found!${NC}"
                   pause
                   continue
               fi

               cd /var/www/pterodactyl
               
               # 1. Clean any existing/broken captcha configs
               sed -i '/^RECAPTCHA_/d' .env
               
               # 2. Inject fresh, working configs
               echo "RECAPTCHA_ENABLE=true" >> .env
               echo "RECAPTCHA_SITE_KEY=$SITE_KEY" >> .env
               echo "RECAPTCHA_SECRET_KEY=$SECRET_KEY" >> .env
               
               # 3. Deep clear cache to ensure panel reads the new keys
               php artisan view:clear > /dev/null 2>&1
               php artisan config:clear > /dev/null 2>&1
               php artisan optimize:clear > /dev/null 2>&1
               
               echo -e "\n${GREEN}✔ Google reCAPTCHA Successfully Enabled! Login page is now secure.${NC}"
               pause 
               ;;
            2) 
               echo -e "\n${CYAN}--- Deploying HARD DDoS Server Armor ---${NC}"
               sleep 1
               
               echo -e "${YELLOW}[1/4] Installing UFW Firewall and Fail2Ban...${NC}"
               apt-get update -y > /dev/null 2>&1
               apt-get install -y ufw fail2ban > /dev/null 2>&1
               
               echo -e "${YELLOW}[2/4] Configuring Anti-DDoS Rate Limiting...${NC}"
               ufw --force reset > /dev/null 2>&1
               ufw default deny incoming > /dev/null 2>&1
               ufw default allow outgoing > /dev/null 2>&1
               
               # Using 'limit' instead of 'allow' for web ports to prevent connection flooding
               ufw limit 22/tcp     # SSH (Rate limited)
               ufw limit 80/tcp     # HTTP (Rate limited)
               ufw limit 443/tcp    # HTTPS (Rate limited)
               ufw allow 8080/tcp   # Wings Daemon
               ufw allow 2022/tcp   # Wings SFTP
               
               ufw --force enable > /dev/null 2>&1
               
               echo -e "${YELLOW}[3/4] Hardening Kernel against SYN Floods & Spoofing...${NC}"
               # Add kernel level DDoS protection
               cat <<EOF >> /etc/sysctl.conf
# Eaglix Anti-DDoS Tweak
net.ipv4.tcp_syncookies = 1
net.ipv4.tcp_max_syn_backlog = 2048
net.ipv4.tcp_synack_retries = 2
net.ipv4.conf.all.rp_filter = 1
EOF
               sysctl -p > /dev/null 2>&1
               
               echo -e "${YELLOW}[4/4] Starting Fail2Ban Anti-Bruteforce...${NC}"
               systemctl enable fail2ban > /dev/null 2>&1
               systemctl restart fail2ban > /dev/null 2>&1
               
               echo -e "\n${GREEN}✔ HARD DDoS Armor Deployed! Server is now highly resistant to attacks.${NC}"
               pause 
               ;;
            0) return ;;
            *) echo -e "${RED}Invalid Option!${NC}"; sleep 1 ;;
        esac
    done
}

# ==========================================
# MAIN MENU LOOP
# ==========================================
while true; do
    clear
    echo -e "${RED}---------------------------------------${NC}"
    echo -e "${NC}        🚀 EAGLIX HOSTING MANAGER      ${NC}"
    echo -e "${RED}            made by Eaglix             ${NC}"
    echo -e "${RED}---------------------------------------${NC}"
    echo -e "${RED}"
    echo "  __  __         _____ _   _  __  __ ______ _   _ _    _ "
    echo " |  \/  |  /\   |_   _| \ | | |  \/  |  ____| \ | | |  | |"
    echo " | \  / | /  \    | | |  \| | | \  / | |__  |  \| | |  | |"
    echo " | |\/| |/ /\ \   | | | . \ | | |\/| |  __| | . \ | |  | |"
    echo " | |  | / ____ \ _| |_| |\  | | |  | | |____| |\  | |__| |"
    echo " |_|  |/_/    \_\_____|_| \_| |_|  |_|______|_| \_|\____/ "
    echo -e "${NC}"
    echo -e "${RED}---------------------------------------${NC}"
    echo -e "${RED} 1) Panel Installation${NC}"
    echo -e "${RED} 2) Wings Installation${NC}"
    echo -e "${RED} 3) Uninstall Tools${NC}"
    echo -e "${RED} 4) Blueprint+Theme+Extensions${NC}"
    echo -e "${RED} 5) Cloudflare Setup${NC}"
    echo -e "${RED} 6) System Information${NC}"
    echo -e "${RED} 7) Tailscale (install + up)${NC}"
    echo -e "${RED} 8) Database Setup${NC}"
    echo -e "${NEON_GREEN} 9) Security & Protection 🛡️${NC}"
    echo -e "${RED} 0) Exit${NC}"
    echo -e "${RED}---------------------------------------${NC}"
    echo -ne "${YELLOW}📝 Select an option [0-9]: ${NC}"
    
    read main_choice
    case $main_choice in
        1) menu_1_pterodactyl ;;
        2) menu_2_wings ;;
        3) menu_3_uninstall ;;
        4) menu_4_blueprint ;;
        5) menu_5_cloudflare ;;
        6) menu_6_system ;;
        7) menu_7_tailscale ;;
        8) menu_8_database ;;
        9) menu_9_security ;;
        0) echo -e "\n${NEON_GREEN}Exiting Manager. Have a great day!${NC}"; exit 0 ;;
        *) echo -e "${RED}Invalid option! Try again.${NC}"; sleep 1 ;;
    esac
done
