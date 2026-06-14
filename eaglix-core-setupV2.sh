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
# COLOR CODES
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
# 1. PTERODACTYL CONTROL CENTER
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

               echo -ne "${NEON_GREEN}1. Your Domain (e.g., panel.eaglix.site): ${NC}"
               read FQDN
               echo -ne "${NEON_GREEN}2. Admin Email (e.g., admin@eaglix.site): ${NC}"
               read EMAIL
               echo -ne "${NEON_GREEN}3. Admin Password (minimum 8 chars): ${NC}"
               read -s PASSWORD
               echo ""

               echo -e "\n${CYAN}⚙️ Initializing Silent Auto-Installation... Please wait!${NC}"
               curl -sL https://pterodactyl-installer.se -o ptero.sh
               chmod +x ptero.sh

               printf "0\npanel\npterodactyl\n\nAsia/Kolkata\n%s\n%s\nadmin\nEaglix\nAdmin\n%s\n%s\nn\nn\nn\ny\ny\nno\n" "$EMAIL" "$EMAIL" "$PASSWORD" "$FQDN" | bash ptero.sh
               
               rm -f ptero.sh
               echo -e "\n${NEON_GREEN}✔ Pterodactyl Panel Auto-Installation Finished!${NC}"
               pause 
               ;;
            2) 
               cd /var/www/pterodactyl && php artisan p:user:make
               pause 
               ;;
            3) 
               curl -sL https://pterodactyl-installer.se -o ptero.sh 
               printf "2\n" | bash ptero.sh
               rm -f ptero.sh
               pause 
               ;;
            4) 
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
    curl -sL https://pterodactyl-installer.se -o ptero.sh
    chmod +x ptero.sh
    printf "1\ny\nN\ny\n" | bash ptero.sh
    rm -f ptero.sh
    echo -e "\n${GREEN}✔ Wings configured successfully!${NC}"
    pause
}

# ==========================================
# 3. UNINSTALL TOOLS
# ==========================================
menu_3_uninstall() {
    while true; do
        clear
        echo -e "${ORANGE}╔════════════════════════════════════════╗${NC}"
        echo -e "${ORANGE}║          📋 UNINSTALL MENU             ║${NC}"
        echo -e "${ORANGE}╠════════════════════════════════════════╣${NC}"
        echo -e "${ORANGE}║${NC} ${CYAN}1) Uninstall Panel Only${NC}                ${ORANGE}║${NC}"
        echo -e "${ORANGE}║${NC} ${CYAN}2) Uninstall Wings Only${NC}                ${ORANGE}║${NC}"
        echo -e "${ORANGE}║${NC} ${CYAN}3) Uninstall Panel + Wings${NC}             ${ORANGE}║${NC}"
        echo -e "${ORANGE}║${NC} ${RED}0) Exit Uninstaller${NC}                    ${ORANGE}║${NC}"
        echo -e "${ORANGE}╚════════════════════════════════════════╝${NC}\n"
        echo -ne "${ORANGE}Choose an option [0-3]: ${NC}"
        read un_choice
        case $un_choice in
            1) 
               rm -rf /var/www/pterodactyl /etc/pterodactyl
               echo -e "${GREEN}Panel completely removed.${NC}"
               pause 
               ;;
            2) 
               systemctl stop wings
               rm -rf /etc/pterodactyl/wings.yml /usr/local/bin/wings /var/lib/pterodactyl
               echo -e "${GREEN}Wings completely removed.${NC}"
               pause 
               ;;
            3) 
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
# 4. BLUEPRINT + THEME + EXTENSIONS (AUTO-LOCK FIX)
# ==========================================
clean_blueprint_locks() {
    # Yeh function automatically background locks ko kill karega
    echo -e "${YELLOW}Cleaning zombie processes and lockfiles...${NC}"
    pkill -9 -f blueprint > /dev/null 2>&1
    pkill -9 -f yarn > /dev/null 2>&1
    find /var/www/pterodactyl -name "*lock*" -type f -delete > /dev/null 2>&1
}

install_extension() {
    local ext_name=$1
    local url=$2
    local filename=$3
    echo -e "\n${CYAN}Downloading & Installing ${ext_name}...${NC}"
    cd /var/www/pterodactyl
    clean_blueprint_locks
    wget -q $url -O $filename
    blueprint -install $filename
}

menu_4_blueprint() {
    while true; do
        clear
        echo -e "${RED}------------------------------------------------${NC}"
        echo -e "       ${NC}🔧 ${RED}BLUEPRINT + THEME + EXTENSIONS${NC}        "
        echo -e "${RED}------------------------------------------------${NC}"
        echo -e "${NC} 1) ${RED}Blueprint Setup (Install)${NC}"
        echo -e "${NC} 2) ${RED}Themes + Extensions Installer${NC}"
        echo -e "${NC} 3) ${YELLOW}Update Blueprint / Fix Errors${NC}"
        echo -e "${NC} 0) ${RED}Back to Main Menu${NC}"
        echo -e "${RED}------------------------------------------------${NC}"
        echo -ne "${YELLOW}📝 Select an option [0-3]: ${NC}"
        read suboption
        
        case $suboption in
            1) 
               echo -e "\n${CYAN}Starting Official Blueprint Setup...${NC}"
               cd /var/www/pterodactyl || { echo -e "${RED}Error: Panel not found!${NC}"; pause; break; }
               
               apt-get update -y > /dev/null 2>&1
               apt-get install -y curl zip unzip > /dev/null 2>&1
               curl -fsSL https://deb.nodesource.com/setup_22.x | bash - > /dev/null 2>&1
               apt-get install -y nodejs > /dev/null 2>&1
               npm install -g yarn > /dev/null 2>&1
               
               DOWNLOAD_URL=$(curl -s https://api.github.com/repos/BlueprintFramework/framework/releases/latest | grep 'browser_download_url' | grep 'release.zip' | cut -d '"' -f 4)
               wget -q $DOWNLOAD_URL -O blueprint.zip
               unzip -o blueprint.zip > /dev/null 2>&1
               chmod +x blueprint.sh
               bash blueprint.sh
               
               echo -e "\n${GREEN}✔ Blueprint Framework Installed Successfully!${NC}"
               pause 
               ;;
            2) 
               while true; do
                   clear
                   echo -e "${MAGENTA}=========================================${NC}"
                   echo -e "${LIGHT_BLUE}     EAGLIX CLOUD EXTENSION INSTALLER    ${NC}"
                   echo -e "${MAGENTA}=========================================${NC}"
                   echo -e "${YELLOW}1)${NC} ${CYAN}Nebula Theme${NC}          ${YELLOW}9)${NC} ${CYAN}Mc Logs${NC}"
                   echo -e "${YELLOW}2)${NC} ${CYAN}MC Plugins${NC}            ${YELLOW}10)${NC} ${CYAN}Custom Server Sort${NC}"
                   echo -e "${YELLOW}3)${NC} ${CYAN}Server Backgrounds${NC}    ${YELLOW}11)${NC} ${CYAN}Laravel Logs${NC}"
                   echo -e "${YELLOW}4)${NC} ${CYAN}Subdomains${NC}            ${YELLOW}12)${NC} ${CYAN}Minecraft Player Mgr${NC}"
                   echo -e "${YELLOW}5)${NC} ${CYAN}Player Listing${NC}        ${YELLOW}13)${NC} ${CYAN}Minecraft Plugin Mgr${NC}"
                   echo -e "${YELLOW}6)${NC} ${CYAN}Hux Register${NC}          ${YELLOW}14)${NC} ${CYAN}Monaco Editor${NC}"
                   echo -e "${YELLOW}7)${NC} ${CYAN}Saga MC Player Mgr${NC}    ${YELLOW}15)${NC} ${CYAN}Refresh theme${NC}"
                   echo -e "${YELLOW}8)${NC} ${CYAN}Version Changer${NC}       ${YELLOW}16)${NC} ${CYAN}Resource Manager${NC}"
                   echo -e "${YELLOW}0)${NC} ${RED}Back to Menu${NC}"
                   echo -e "${MAGENTA}=========================================${NC}"
                   echo -ne "${NEON_GREEN}Choose an option [0-16]: ${NC}"
                   read theme_choice
                   
                   case $theme_choice in
                       1) install_extension "Nebula Theme" "https://eaglix-installer.netlify.app/nebula.blueprint" "nebula.blueprint"; pause ;;
                       2) install_extension "MC Plugins" "https://eaglix-installer.netlify.app/mcplugins.blueprint" "mcplugins.blueprint"; pause ;;
                       3) install_extension "Server Backgrounds" "https://eaglix-installer.netlify.app/serverbackgrounds.blueprint" "serverbackgrounds.blueprint"; pause ;;
                       4) install_extension "Subdomains" "https://eaglix-installer.netlify.app/subdomains.blueprint" "subdomains.blueprint"; pause ;;
                       5) install_extension "Player Listing" "https://eaglix-installer.netlify.app/playerlisting.blueprint" "playerlisting.blueprint"; pause ;;
                       6) install_extension "Hux Register" "https://eaglix-installer.netlify.app/huxregister.blueprint" "huxregister.blueprint"; pause ;;
                       7) install_extension "Saga MC Player Manager" "https://eaglix-installer.netlify.app/sagaminecraftplayermanager.blueprint" "sagaminecraftplayermanager.blueprint"; pause ;;
                       8) install_extension "Version Changer" "https://eaglix-installer.netlify.app/versionchanger.blueprint" "versionchanger.blueprint"; pause ;;
                       9) install_extension "MC Logs" "https://eaglix-installer.netlify.app/mclogs.blueprint" "mclogs.blueprint"; pause ;;
                       10) install_extension "Custom Server Sort" "https://eaglix-installer.netlify.app/customserversort.blueprint" "customserversort.blueprint"; pause ;;
                       11) install_extension "Laravel Logs" "https://eaglix-installer.netlify.app/laravellogs.blueprint" "laravellogs.blueprint"; pause ;;
                       12) install_extension "Minecraft Player Manager" "https://eaglix-installer.netlify.app/minecraftplayermanager.blueprint" "minecraftplayermanager.blueprint"; pause ;;
                       13) install_extension "Minecraft Plugin Manager" "https://eaglix-installer.netlify.app/minecraftpluginmanager.blueprint" "minecraftpluginmanager.blueprint"; pause ;;
                       14) install_extension "Monaco Editor" "https://eaglix-installer.netlify.app/monacoeditor.blueprint" "monacoeditor.blueprint"; pause ;;
                       15) install_extension "Refresh Theme" "https://eaglix-installer.netlify.app/refreshtheme.blueprint" "refreshtheme.blueprint"; pause ;;
                       16) install_extension "Resource Manager" "https://eaglix-installer.netlify.app/resourcemanager.blueprint" "resourcemanager.blueprint"; pause ;;
                       0) break ;;
                       *) echo -e "${RED}Invalid!${NC}"; sleep 1 ;;
                   esac
               done
               ;;
            3)
               echo -e "\n${CYAN}🚀 Fixing & Upgrading Blueprint...${NC}"
               cd /var/www/pterodactyl
               php artisan up
               blueprint -upgrade
               echo -e "\n${GREEN}✔ Blueprint Fix Complete!${NC}"
               pause
               ;;
            0) return ;;
            *) echo -e "${RED}Invalid!${NC}"; sleep 1 ;;
        esac
    done
}

# ==========================================
# 5. CLOUDFLARE SETUP
# ==========================================
menu_5_cloudflare() {
    while true; do
        clear
        echo -e "${ORANGE}╔══════════════════════════════════════╗${NC}"
        echo -e "${ORANGE}║     CLOUDFLARED MANAGEMENT MENU      ║${NC}"
        echo -e "${ORANGE}╠══════════════════════════════════════╣${NC}"
        echo -e "${NEON_GREEN}║${NC} ${CYAN}1) Install & Connect Tunnel${NC}          ${NEON_GREEN}║${NC}"
        echo -e "${NEON_GREEN}║${NC} ${RED}2) Uninstall Completely${NC}              ${NEON_GREEN}║${NC}"
        echo -e "${NEON_GREEN}║${NC} ${NEON_GREEN}3) Exit${NC}                                ${NEON_GREEN}║${NC}"
        echo -e "${NEON_GREEN}╚══════════════════════════════════════╝${NC}\n"
        echo -ne "${LIGHT_BLUE}Select an option: ${NC}"
        read cf_choice
        case $cf_choice in
            1) 
               echo -ne "\n${YELLOW}Paste Tunnel Token: ${NC}"
               read CF_TOKEN
               curl -L --output cloudflared.deb https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb
               dpkg -i cloudflared.deb
               cloudflared service install $CF_TOKEN
               echo -e "\n${NEON_GREEN}✔ Tunnel Connected!${NC}"
               pause 
               ;;
            2) 
               cloudflared service uninstall
               apt-get remove -y cloudflared
               rm -f cloudflared.deb
               echo -e "\n${GREEN}✔ Tunnel Removed!${NC}"
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
    local up_time=$(uptime -p)
    echo -e "${CYAN}╔═══════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║              📊 SYSTEM STATUS                 ║${NC}"
    echo -e "${CYAN}╠═══════════════════════════════════════════════╣${NC}"
    echo -e "${CYAN}║  ${RED}•${NC} ${NEON_GREEN}Hostname:${NC} ${NC}$host_name"
    echo -e "${CYAN}║  ${RED}•${NC} ${NEON_GREEN}Uptime:${NC} ${NC}$up_time"
    echo -e "${CYAN}╚═══════════════════════════════════════════════╝${NC}\n"
    pause
}

# ==========================================
# MAIN MENU LOOP
# ==========================================
while true; do
    clear
    echo -e "${RED}---------------------------------------${NC}"
    echo -e "${NC}        🚀 EAGLIX HOSTING MANAGER      ${NC}"
    echo -e "${RED}---------------------------------------${NC}"
    echo -e "${RED} 1) Panel Installation${NC}"
    echo -e "${RED} 2) Wings Installation${NC}"
    echo -e "${RED} 3) Uninstall Tools${NC}"
    echo -e "${RED} 4) Blueprint+Theme+Extensions${NC}"
    echo -e "${RED} 5) Cloudflare Setup${NC}"
    echo -e "${RED} 6) System Info${NC}"
    echo -e "${RED} 0) Exit${NC}"
    echo -e "${RED}---------------------------------------${NC}"
    echo -ne "${YELLOW}📝 Select an option [0-6]: ${NC}"
    
    read main_choice
    case $main_choice in
        1) menu_1_pterodactyl ;;
        2) menu_2_wings ;;
        3) menu_3_uninstall ;;
        4) menu_4_blueprint ;;
        5) menu_5_cloudflare ;;
        6) menu_6_system ;;
        0) echo -e "\n${NEON_GREEN}Exiting. Have a great day!${NC}"; exit 0 ;;
        *) echo -e "${RED}Invalid option! Try again.${NC}"; sleep 1 ;;
    esac
done
