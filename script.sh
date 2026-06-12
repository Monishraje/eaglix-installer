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

               echo -e "${CYAN}Panel install karne ke liye bas 3 details chahiye:${NC}"
               echo -e "${DARK_GRAY}(Baaki Timezone, DB, Firewall sab Eaglix khud set kar dega)${NC}\n"

               echo -ne "${NEON_GREEN}1. Apna Domain (e.g., panel.eaglix.site): ${NC}"
               read FQDN
               echo -ne "${NEON_GREEN}2. Admin Email (e.g., admin@eaglix.site): ${NC}"
               read EMAIL
               echo -ne "${NEON_GREEN}3. Admin Password (minimum 8 chars): ${NC}"
               read -s PASSWORD
               echo ""

               echo -e "\n${CYAN}⚙️ Initializing Silent Auto-Installation... Please wait!${NC}"
               echo -e "${YELLOW}(Yeh 2-3 minute lega, please screen close mat karna)${NC}\n"
               
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
# 4. BLUEPRINT + THEME (FULLY WORKING UI)
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
        echo -e "${NC} 1) ${RED}Blueprint Setup${NC}"
        echo -e "${NC} 2) ${RED}Themes + Extensions${NC}"
        echo -e "${NC} 0) ${RED}Back to Main Menu${NC}"
        echo -e "${RED}------------------------------------------------${NC}"
        echo -ne "${YELLOW}📝 Select an option [0-2]: ${NC}"
        read suboption
        
        case $suboption in
            1) 
               echo -e "\n${CYAN}Starting Official Blueprint Setup...${NC}"
               cd /var/www/pterodactyl || { echo -e "${RED}Error: Pterodactyl directory not found!${NC}"; pause; break; }
               
               echo -e "${YELLOW}[1/3] Installing Dependencies (NodeJS v22, Yarn, Zip)...${NC}"
               apt-get update -y > /dev/null 2>&1
               apt-get install -y curl zip unzip > /dev/null 2>&1
               
               # Yahan setup_20.x ki jagah setup_22.x kar diya hai
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
               # Sub-menu for Local Themes & Extensions
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
                   echo -e "${YELLOW}0)${NC} ${GREEN}Back to Blueprint Menu${NC}"
                   echo -e "${MAGENTA}=========================================${NC}"
                   echo -ne "${NEON_GREEN}Choose an option: ${NC}"
                   read theme_choice
                   
                   case $theme_choice in
                       1) 
                          echo -e "\n${CYAN}Downloading & Installing Nebula Theme...${NC}"
                          cd /var/www/pterodactyl
                          wget -q https://eaglix-installer.netlify.app/nebula.blueprint -O nebula.blueprint
                          blueprint -install nebula.blueprint
                          pause 
                          ;;
                       2) 
                          echo -e "\n${CYAN}Downloading & Installing MC Plugins...${NC}"
                          cd /var/www/pterodactyl
                          wget -q https://eaglix-installer.netlify.app/mcplugins.blueprint -O mcplugins.blueprint
                          blueprint -install mcplugins.blueprint
                          pause 
                          ;;
                       3) 
                          echo -e "\n${CYAN}Downloading & Installing Server Backgrounds...${NC}"
                          cd /var/www/pterodactyl
                          wget -q https://eaglix-installer.netlify.app/serverbackgrounds.blueprint -O serverbackgrounds.blueprint
                          blueprint -install serverbackgrounds.blueprint
                          pause 
                          ;;
                       4) 
                          echo -e "\n${CYAN}Downloading & Installing Subdomains...${NC}"
                          cd /var/www/pterodactyl
                          wget -q https://eaglix-installer.netlify.app/subdomains.blueprint -O subdomains.blueprint
                          blueprint -install subdomains.blueprint
                          pause 
                          ;;
                       5) 
                          echo -e "\n${CYAN}Downloading & Installing Player Listing...${NC}"
                          cd /var/www/pterodactyl
                          wget -q https://eaglix-installer.netlify.app/playerlisting.blueprint -O playerlisting.blueprint
                          blueprint -install playerlisting.blueprint
                          pause 
                          ;;
                       0) break ;;
                       *) echo -e "${RED}Invalid!${NC}"; sleep 1 ;;
                   esac
               done
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

    echo -e "${DARK_GRAY}       _       _${NC}"
    echo -e "${DARK_GRAY}      (_)     | |${NC}"
    echo -e "${RED}       _ _ ___| |__  _ __  _   _${NC}"
    echo -e "${RED}      | | / __| '_ \| '_ \| | | |${NC}"
    echo -e "${RED}      | | \__ \ | | | | | | |_| |${NC}"
    echo -e "${RED}      | | |___/_| |_|_| |_|\__,_|${NC}"
    echo -e "${RED}     _/ |${NC}"
    echo -e "${RED}    |__/${NC}\n"

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
# 7. TAILSCALE INSTALLER
# ==========================================
menu_7_tailscale() {
    while true; do
        clear
        if command -v tailscale &> /dev/null; then
            STATUS="${NEON_GREEN}INSTALLED${NC}"
        else
            STATUS="${RED}NOT INSTALLED${NC}"
        fi

        echo -e "${LIGHT_BLUE}╔══════════════════════════════════════╗${NC}"
        echo -e "${LIGHT_BLUE}║          TAILSCALE INSTALLER         ║${NC}"
        echo -e "${LIGHT_BLUE}╚══════════════════════════════════════╝${NC}\n"
        echo -e "${CYAN}Status: ${STATUS}\n"
        echo -e "${NEON_GREEN}========================================${NC}"
        echo -e "${CYAN} [1] 📥 Install Tailscale${NC}"
        echo -e "${RED} [2] 🗑️  Uninstall Tailscale${NC}"
        echo -e "${YELLOW} [3] 🚪 Exit${NC}"
        echo -e "${NEON_GREEN}========================================${NC}\n"
        echo -ne "${NEON_GREEN}Select option [1-3]: ${NC}"
        read ts_choice
        case $ts_choice in
            1) 
               echo -e "${CYAN}Fetching Tailscale Node...${NC}"
               curl -fsSL https://tailscale.com/install.sh | sh
               tailscale up
               pause 
               ;;
            2) 
               echo -e "${RED}Disconnecting Tailscale...${NC}"
               apt-get remove -y tailscale
               echo -e "${GREEN}Tailscale Removed!${NC}"
               pause 
               ;;
            3) return ;;
            *) echo -e "${RED}Invalid!${NC}"; sleep 1 ;;
        esac
    done
}

# ==========================================
# 8. DATABASE SETUP
# ==========================================
menu_8_database() {
    clear
    echo -e "${RED} ____        _        _                     ${NC}"
    echo -e "${RED}|  _ \  __ _| |_ __ _| |__   __ _ ___  ___  ${NC}"
    echo -e "${RED}| | | |/ _\` | __/ _\` | '_ \ / _\` / __|/ _ \ ${NC}"
    echo -e "${RED}| |_| | (_| | || (_| | |_) | (_| \__ \  __/ ${NC}"
    echo -e "${RED}|____/ \__,_|\__\__,_|_.__/ \__,_|___/\___| ${NC}"
    echo -e "${RED}--------------------------------------------${NC}"
    echo -e "${RED}Running: MySQL / MariaDB Database Setup     ${NC}"
    echo -e "${RED}--------------------------------------------${NC}\n"
    
    echo -ne "${NEON_GREEN}Enter new database username: ${NC}"
    read db_user
    echo -ne "${NEON_GREEN}Enter new database password: ${NC}"
    read -s db_pass
    echo -e "\n\n${CYAN}Provisioning secure database user '${db_user}'...${NC}"
    
    # Secure DB setup
    apt update && apt install -y mariadb-server
    mysql -e "CREATE USER IF NOT EXISTS '$db_user'@'%' IDENTIFIED BY '$db_pass';"
    mysql -e "GRANT ALL PRIVILEGES ON *.* TO '$db_user'@'%' WITH GRANT OPTION;"
    mysql -e "FLUSH PRIVILEGES;"
    
    echo -e "\n${NEON_GREEN}✔ Database configuration complete!${NC}"
    pause
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
    echo -e "${RED} 0) Exit${NC}"
    echo -e "${RED}---------------------------------------${NC}"
    echo -ne "${YELLOW}📝 Select an option [0-8]: ${NC}"
    
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
        0) echo -e "\n${NEON_GREEN}Exiting Manager. Have a great day!${NC}"; exit 0 ;;
        *) echo -e "${RED}Invalid option! Try again.${NC}"; sleep 1 ;;
    esac
done
