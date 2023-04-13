#!/bin/sh
# Ansible managed

hole_host=http://localhost
api_token=$(awk -F "=" '/WEBPASSWORD/ {print $2}' /etc/pihole/setupVars.conf)

response=$(curl -s "${hole_host}/admin/api.php?summary&auth=${api_token}")

pi_domains_being_blocked=$(jq --raw-output -n --argjson data "$response" '$data.domains_being_blocked')
pi_dns_queries_today=$(jq --raw-output -n --argjson data "$response" '$data.dns_queries_today')
pi_ads_blocked_today=$(jq --raw-output -n --argjson data "$response" '$data.ads_blocked_today')
pi_status=$(jq --raw-output -n --argjson data "$response" '$data.status')

###

BYellow='\033[1;33m'
BIBlack='\033[1;90m'
Yellow='\033[0;33m'
NC='\e[0m'
bor='=========================================='

echo "$(tput setaf 2)$BIBlack $bor $NC
$BYellow Stats:$NC
$Yellow Status..............:$NC  $pi_status
$Yellow Domains in blocklist:$NC  $pi_domains_being_blocked
$Yellow Queries today.......:$NC  $pi_dns_queries_today
$Yellow Blocked today.......:$NC  $pi_ads_blocked_today$(tput sgr0)"
