#!/bin/bash

# Color codes
RED='\033[31m'
GREEN='\033[32m'
YELLOW='\033[33m'
BLUE='\033[34m'
MAGENTA='\033[35m'
CYAN='\033[36m'
WHITE='\033[37m'
LIGHT_RED='\033[91m'
LIGHT_GREEN='\033[92m'
LIGHT_YELLOW='\033[93m'
LIGHT_BLUE='\033[94m'
LIGHT_MAGENTA='\033[95m'
LIGHT_CYAN='\033[96m'
BOLD='\033[1m'
UNDERLINE='\033[4m'
RESET='\033[0m'

# help message
function show_help() {
    printf "\n" 

    echo -e "${LIGHT_CYAN}                                          To Use Tool Type: Kidrecon  and put the Target ${RESET}"
    printf "\n" 

    echo -e "${RED}                     DISCLAIMER: This tool is intended for ethical hacking and penetration testing purposes only.${RESET}"
    echo -e "${RED}                                 The creator is not responsible for any misuse or illegal activities.${RESET}"
    printf "\n" 
    echo -e "${LIGHT_GREEN}                                                        Coded By Angix Black${RESET}"
    exit 0  
}

# help option
if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    show_help
fi


# invalid input
if [[ $# -gt 0 ]]; then
    show_help
fi
printf "\n"

display_title() {
    local text=$1
    local font=$2
    local effect=$3

   
    figlet -f "$font" "$text" | lolcat $effect --animate --freq=0.1 --duration=1 --truecolor
}


display_title "K i d Recon" "big" "--spread=1.0  --speed=20.0"

printf "\n"
printf "\n"
echo -e "${LIGHT_GREEN}                                                 💻 Coded By Angix Black 💻${RESET}"

printf "\n"
echo -e "${RED}                 DISCLAIMER: This tool is intended for ethical hacking and penetration testing purposes only.${RESET}"
    echo -e "${RED}                             The creator is not responsible for any misuse or illegal activities.${RESET}"


printf "\n"
# Input domain
printf "${LIGHT_CYAN}[+] Please Enter The Target : ${RESET}"
read Domin



# validate domain format
validate_domain() {
    local Domin=$1
    # Validating 
    if [[ ! "$Domin" =~ ^([a-zA-Z0-9-]+\.)+[a-zA-Z]{2,}$ ]]; then
        return 1  # Invalid domain
    fi
    return 0  # Valid domain
}


# Sanitize input
sanitize_input() {
    local input=$1
    # Remove any special characters 
    echo "$input" | sed 's/[^a-zA-Z0-9.-]//g'
}


cleanup() {
    echo -e "\n${RED}Exiting the tool. Cleaning up...${RESET}"
   
    echo -e "${RED}Cleanup completed. Exiting.${RESET}"
    exit 0
}


trap cleanup SIGINT

# Sanitize 
Domin=$(sanitize_input "$Domin")

# Check if input is empty or invalid
if [[ -z "$Domin" ]]; then
    echo -e "${LIGHT_RED}[✘] Error: You must enter a value for Domain.${RESET}"
    exit 1
elif ! validate_domain "$Domin"; then
    echo -e "${LIGHT_RED}[✘] Error: Invalid domain format. Please enter a valid domain name.${RESET}"
    exit 1
else
    echo -e "${LIGHT_GREEN}[✓] You entered: ${LIGHT_MAGENTA}$Domin${RESET}\n${LIGHT_YELLOW}[🔍] Starting reconnaissance now And Get All subdomins ....${RESET}"
    sleep 5
fi

ReconDir="${Domin}_recon"

# Create a directory for storing results
if mkdir -p "$ReconDir"; then
    echo -e "${LIGHT_GREEN}[✓] Directory ${LIGHT_MAGENTA}$ReconDir${LIGHT_GREEN} created successfully.${RESET}"
else
    echo -e "${LIGHT_RED}[✘] Error: Failed to create directory ${LIGHT_MAGENTA}$ReconDir.${RESET}"
    exit 1
fi

cd "$ReconDir" || { echo -e "${LIGHT_RED}[✘] Error: Failed to Make directory ): ${LIGHT_MAGENTA}$ReconDir.${RESET}"; exit 1; }

# loading function
loading() {
    local message=$1
    local pid=$2
    local i=0

    echo -ne "${LIGHT_GREEN}${message}... ${RESET}"

    while kill -0 "$pid" 2>/dev/null; do
        printf "\r${LIGHT_GREEN}${message}${RESET}"
        sleep 0.2
    done

    echo -e "\r ${RESET}${LIGHT_GREEN}${message} ${LIGHT_GREEN}done ✓${RESET}"
    echo  
}





trap "kill 0" EXIT




# Run subfinder
(
    subfinder -d "$Domin" -all -recursive -o subfinder.txt > /dev/null 2>&1
) &
pid=$!
loading "[🛠️] Subfinder running "



# Run assetfinder
(
     assetfinder  "$Domin" > assetfinder.txt 

) &
pid=$!
loading "[🛠️] Assetfinder running "


# Run sublist3r

(
    sublist3r -d "$Domin" -o  sublist3r.txt > /dev/null 2>&1
) &
pid=$!
loading "[🛠️] Sublist3r running "




# Fetch domain data from crt.sh
(
    curl -s "https://crt.sh/?q=%25."$Domin"&output=json" | jq -r '.[].name_value' | sed 's/\*\.//g' | sort -u > crt.txt
) &
pid=$!
loading "[🛠️] crt.sh data processing running ... "


wait

# Combine results
echo -e "${LIGHT_CYAN}[⏳] Combining and deduplicating results...${RESET}"
cat subfinder.txt   assetfinder.txt sublist3r.txt  crt.txt | sort -u > all_subdomins.txt


cat all_subdomins.txt

echo -e "${LIGHT_GREEN}[✓] All results saved in the directory: ${LIGHT_MAGENTA}$ReconDir${RESET}"

subfinder_count=$(wc -l < subfinder.txt )
assetfinder_count=$(wc -l < assetfinder.txt)
sublist3r_count=$(wc -l < sublist3r.txt)
crt_count=$(wc -l < crt.txt)
all_count=$(wc -l < all_subdomins.txt)

find . -maxdepth 1 -type f ! -name 'all_subdomins.txt' -exec rm -f {} +

# counts
echo -e "${LIGHT_GREEN}${BOLD}[✓]${RESET} ${CYAN}subfinder found${RESET} ${YELLOW}${BOLD}$subfinder_count${RESET}"
echo -e "${LIGHT_GREEN}${BOLD}[✓]${RESET} ${CYAN}Assetfinder found${RESET} ${YELLOW}${BOLD}$assetfinder_count${RESET}"
echo -e "${LIGHT_GREEN}${BOLD}[✓]${RESET} ${CYAN}Sublist3r found${RESET} ${YELLOW}${BOLD}$sublist3r_count${RESET}"
echo -e "${LIGHT_GREEN}${BOLD}[✓]${RESET} ${CYAN}crt.sh data found${RESET} ${YELLOW}${BOLD}$crt_count${RESET}"
echo -e "${LIGHT_GREEN}${BOLD}[✓]${RESET} ${MAGENTA}Combined and deduplicated results:${RESET} ${YELLOW}${BOLD}$all_count${RESET}"



echo -e "${LIGHT_CYAN}[🔍] Retrieving WHOIS information for ${LIGHT_GREEN}$Domin${RESET}..."
sleep 2 

whois "$Domin" > whois_results.txt


# scanning live subdomains
echo -e "${LIGHT_CYAN}[🔍] Scanning live subdomains...${RESET}"
sleep 2

# Request number of threads
read -p "Please enter the number of threads (default: 100): " threads
threads=${threads:-100}
if ! [[ "$threads" =~ ^[0-9]+$ ]]; then
    echo -e "${LIGHT_RED}[❌] Invalid input. Using default threads: 100${RESET}"
    threads=100
fi

httpx-toolkit -l all_subdomins.txt -p 80,443,8080,8888 -t "$threads" -o info.txt -sc -td -fr -title

echo -e "${LIGHT_GREEN}[✓] Live subdomains scanning completed. Results saved in info.txt${RESET}"

echo -e "${LIGHT_CYAN}[🔍] Extracting domains from results...${RESET}"
grep -oP 'https://\K[^/\s]+' info.txt |  anew domins.txt

echo -e "${LIGHT_GREEN}[✓] Domains extracted and saved in domins.txt${RESET}"
awk '{print "https://" $0}' domins.txt > https_domins.txt


echo -e "${YELLOW}Removing file: ${CYAN}all_subdomins.txt${RESET}"
rm all_subdomins.txt
rm -r knockpy

mkdir technology

mv info.txt technology/info.txt

echo -e "${LIGHT_CYAN}[🔍] Starting the filtering process for technologies...${RESET}"
# Filtertechnology
declare -A techs=(
    
["ASP.NET"]="ASP.NET"
["Apache"]="Apache"
["Nginx"]="nginx"
["IIS"]="Microsoft-IIS"
["Tomcat"]="Tomcat"
["Django"]="Django"
["Flask"]="Flask"
["Rails"]="Ruby on Rails"
["PHP"]="PHP"
["Node.js"]="Node.js"
["Joomla"]="Joomla"
["WordPress"]="WordPress"
["Drupal"]="Drupal"
["ColdFusion"]="ColdFusion"
["JBoss"]="JBoss"
["GlassFish"]="GlassFish"
["WebLogic"]="WebLogic"
["WebSphere"]="WebSphere"
["LiteSpeed"]="LiteSpeed"
["Squarespace"]="Squarespace"
["Wix"]="Wix"
["Magento"]="Magento"
["PrestaShop"]="PrestaShop"
["TYPO3"]="TYPO3"
["OpenCart"]="OpenCart"
["Shopify"]="Shopify"
["Moodle"]="Moodle"
["Zimbra"]="Zimbra"
["Confluence"]="Confluence"
["Redmine"]="Redmine"
["GitLab"]="GitLab"
["Jenkins"]="Jenkins"
["SonarQube"]="SonarQube"
["ElasticSearch"]="ElasticSearch"
["Kibana"]="Kibana"
["Solr"]="Solr"
["Jira"]="Jira"
["Puppet"]="Puppet"
["Chef"]="Chef"
["Ansible"]="Ansible"
["Terraform"]="Terraform"
["Kubernetes"]="Kubernetes"
["Docker"]="Docker"
["Git"]="Git"
["Subversion"]="Subversion"
["Mercurial"]="Mercurial"
["Redis"]="Redis"
["Memcached"]="Memcached"
["RabbitMQ"]="RabbitMQ"
["ActiveMQ"]="ActiveMQ"
["Cassandra"]="Cassandra"
["MongoDB"]="MongoDB"
["MySQL"]="MySQL"
["PostgreSQL"]="PostgreSQL"
["SQLite"]="SQLite"
["MariaDB"]="MariaDB"
["Elasticsearch"]="Elasticsearch"
["Zookeeper"]="Zookeeper"
["Grafana"]="Grafana"
["Prometheus"]="Prometheus"
["InfluxDB"]="InfluxDB"
["Nagios"]="Nagios"
["Splunk"]="Splunk"
["Sentry"]="Sentry"
["Vault"]="Vault"
["Consul"]="Consul"
["Swagger"]="Swagger"
["RedHat"]="RedHat"
["CentOS"]="CentOS"
["Debian"]="Debian"
["Ubuntu"]="Ubuntu"
["Fedora"]="Fedora"
["SUSE"]="SUSE"
["Laravel"]="Laravel"
["OpenResty"]="OpenResty"
["Cherokee"]="Cherokee"
["Caddy"]="Caddy"
["Hiawatha"]="Hiawatha"
["Lighttpd"]="Lighttpd"
["Varnish"]="Varnish"
["HAProxy"]="HAProxy"
["Zabbix"]="Zabbix"
["CockroachDB"]="CockroachDB"
["Neo4j"]="Neo4j"
["CouchDB"]="CouchDB"
["RethinkDB"]="RethinkDB"
["ArangoDB"]="ArangoDB"
["Samba"]="Samba"
["Nexus"]="Nexus"
["Artifactory"]="Artifactory"
["AWS"]="AWS"
["Azure"]="Azure"
["Fastly"]="Fastly"
["Jetty"]="Jetty"
["Express"]="Express"
["WebSocket"]="WebSocket"
["Go"]="Go"
["ASP"]="ASP"
["Perl"]="Perl"
["Lua"]="Lua"
["ExpressionEngine"]="ExpressionEngine"
["Ghost"]="Ghost"
["OpenShift"]="OpenShift"
["Rancher"]="Rancher"
["ClamAV"]="ClamAV"
["OpenVAS"]="OpenVAS"
["Kafka"]="Kafka"
["Hadoop"]="Hadoop"
["Spark"]="Spark"
["CircleCI"]="CircleCI"
["Travis CI"]="Travis CI"
["GCP"]="Google Cloud Platform"
["Oracle Cloud"]="Oracle Cloud"

)

echo -e "${LIGHT_CYAN}[🔍] Starting technology filtering...${RESET}"

for tech in "${!techs[@]}"; do
  echo -e "${LIGHT_CYAN}[🔍] Extracting domains for $tech...${RESET}"
  tech_domains=$(grep "${techs[$tech]}" technology/info.txt | sed -n 's/^\(https\?:\/\/[^ ]*\).*/\1/p')
  if [[ -n "$tech_domains" ]]; then
    echo "$tech_domains" > "technology/$tech.txt"
    echo -e "${LIGHT_GREEN}[✓] $tech domains extracted and saved in technology/$tech.txt${RESET}"
  else
    echo -e "${LIGHT_RED}[⚠️] No domains found for $tech.${RESET}"
  fi
done


# Create output directory
mkdir -p urls
echo -e "${LIGHT_CYAN}🔥 Creating output directory 'urls'...${RESET}"
sleep 1


type_message "🚀 Extracting URLs from various sources and saving them to 'urls' directory..."

type_message "🌐 Fetching historical URLs with waybackurls..."
-c 'cat https_domins.txt | waybackurls | anew urls/waybackurls.txt; sleep 4; exit'" &
wayback_pid=$!


type_message "🔧 Processing endpoints with paramspider..."
-c 'paramspider -l https_domins.txt -o output ; sleep 4; exit' " &
paramspider_pid=$!

type_message "🔫 Processing URLs with katana..."
-c 'katana -list domins.txt -fx -ps -d 5 -pss waybackarchive,commoncrawl,alienvault -jc | anew urls/katana_urls.txt; sleep 4; exit'" &
katana_pid=$!

sleep 4

type_message " Happy Hacking ^_^ - Wait little dont Close any windows  "

wait

type_message "🎉 Everything is done!  ^_^ "


# extensions to search for
extensions="\.(php|asp|aspx|xml|ini|log|cache|secret|db|sqlite|bak|backup|yml|yaml|json|gz|rar|zip|tar|tgz|bz2|7z|sql|csv|md|conf|env|env.example|env.local|config|key|pem|crt|pfx|p12|cer|csr|rsa|pub|private|lock|ssh|id_rsa|ppk|dat|bak2|old|credentials|credentials.json|sublime-project|sublime-workspace|cert|certs|ovpn|ovpn_config|ini|inc|conf|properties|log|lst|jar|war|ear|tmp|temp|old|bkp|swp|sqlite3|sqlite|session|sess|token|jwt|passwd|htpasswd|shadow|psql|mysql|xls|xlsx|doc|docx|ppt|pptx|msg|pst|eml|mdf|ldf|sqlitedb|sqlite-journal|db-journal)"

wait 

# List of files to remove
files=("urls/katana_urls.txt"  "urls/waybackurls.txt" "output/all.txt")

# Merge files into all_urls.txt
echo -e "${BLUE}Merging files into all_urls.txt...${RESET}"
cat "${files[@]}" | anew urls/all_urls.txt
wait

(
    cat urls/all_urls.txt | grep -E "$extensions" | sort -u > urls/important_urls.txt
)
pid=$!
loading "Extracting URLs with specified extensions..."


# Extract JavaScript 
echo -e "${YELLOW}Extracting JavaScript file URLs from all_urls.txt...${RESET}"
cat urls/all_urls.txt | grep -i "\.js$" | awk '{print $1}' > urls/js.txt
echo -e "${GREEN}JavaScript file URLs have been saved to js.txt.${RESET}"


# Extract URLs with parameters and save to all_endpoint.txt
echo -e "${YELLOW}Extracting URLs with parameters from all_urls.txt...${RESET}"
cat urls/all_urls.txt | grep "=" > all_endpoint.txt
echo -e "${GREEN}URLs with parameters have been saved to all_endpoint.txt.${RESET}"
cd output
cat * | anew all.txt
cd ..
# Add unique entries from output/all to all_endpoint.txt
echo -e "${YELLOW}Appending unique entries from output/all to all_endpoint.txt...${RESET}"
cat output/all.txt | anew >> all_endpoint.txt
echo -e "${GREEN}Unique entries from output/all have been appended to all_endpoint.txt.${RESET}"



echo -e "${GREEN}Files merged successfully into all_urls.txt.${RESET}"

# Remove old files
echo -e "${YELLOW}Removing old URL files...${RESET}"
sleep 2

for file in "${files[@]}"; do
  if [ -f "$file" ]; then
    rm "$file"
    echo -e "${GREEN}Removed $file.${RESET}"
  else
    echo -e "${RED}File $file does not exist.${RESET}"
  fi
done


wait

echo -e "${LIGHT_GREEN}[✓] All tasks completed. Results saved in urls/all_urls.txt and urls/js_files.txt${RESET}"


type_message Start Port scan
# Default 
default_threads=100

echo -ne "${LIGHT_CYAN}${BOLD}Enter the number of threads (default is $default_threads): ${RESET}"
read threads

if [ -z "$threads" ]; then
    echo -e "${RED}No input provided. Using default threads: $default_threads${RESET}"
    threads=$default_threads
elif ! [[ "$threads" =~ ^[0-9]+$ ]]; then
    echo -e "${RED}Invalid input. Using default threads: $default_threads${RESET}"
    threads=$default_threads
fi


# Prompt the user for the type of scan
echo -e "${LIGHT_CYAN}${BOLD}Choose the type of port scan:${RESET}"
echo -e "${LIGHT_GREEN}1) Top 1000 ports - (Fast Scan)${RESET}"
echo -e "${LIGHT_GREEN}2) Full scan (1-65535) - (Long Scan)${RESET}"
echo -ne "${LIGHT_CYAN}${BOLD}Enter your choice (default is top 1000 ports): ${RESET}"
read scan_choice

# Validate the user input
if [[ "$scan_choice" =~ ^[1-2]$ ]]; then
    if [ "$scan_choice" -eq 1 ]; then
        scan_option="-top-ports 1000"
        echo -e "${LIGHT_GREEN}Selected: Top 1000 ports (Fast Scan)${RESET}"
    elif [ "$scan_choice" -eq 2 ]; then
        scan_option="-p -"
        echo -e "${LIGHT_GREEN}Selected: Full scan (1-65535) (Long Scan)${RESET}"
    fi
else
    echo -e "${RED}Invalid input. Defaulting to top 1000 ports.${RESET}"
    scan_option="-top-ports 1000"
fi

# Run the port scan with naabu
echo -e "${LIGHT_CYAN}${BOLD}Running the port scan...${RESET}"
naabu -l domins.txt -c "$threads" $scan_option -o naabu.txt
echo -e "${LIGHT_GREEN}Scan completed. Results saved in naabu.txt${RESET}"

type_message "Filter Parameters"

mkdir -p gf

gf_exists=true

if ! command -v gf &> /dev/null
then
    echo "Warning: 'gf' command not found. Skipping all gf-related operations."
    gf_exists=false
fi

if [ "$gf_exists" = true ]; then
    type_message "Filter to get sqli parameters"
    cat all_endpoint.txt | gf sqli | anew gf/sqli.txt

    type_message "Filter to get lfi parameters"
    cat all_endpoint.txt | gf lfi | anew gf/lfi.txt

    type_message "Filter to get xss parameters"
    cat all_endpoint.txt | gf xss | anew gf/xss.txt

    type_message "Filter to get rce parameters"
    cat all_endpoint.txt | gf rce | anew gf/rce.txt

    type_message "Filter to get idor parameters"
    cat all_endpoint.txt | gf idor | anew gf/idor.txt

    type_message "Filter to get redirect parameters"
    cat all_endpoint.txt | gf redirect | anew gf/redirect.txt

    type_message "Filter to get ssrf parameters"
    cat all_endpoint.txt | gf ssrf | anew gf/ssrf.txt
    

    echo "Filtering complete."
else
    echo "Skipping filtering due to missing 'gf'."
fi



