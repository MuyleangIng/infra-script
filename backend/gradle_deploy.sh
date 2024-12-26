#!/bin/bash
echo "----------Enter server1 & port1--------------"
read -p "Enter server1: " server1
read -p "Enter port1: " port1


echo "------------------------"
echo "please input ip address 188.166.191.62 "
while true; do
  read -p "Enter ipaddress: " ipaddress
  if [ -n "$ipaddress" ] ; then
    # Both inputs provided, exit the loop
    break
  else
    echo " inputs are required. Please try again."
  fi
done
echo "You entered ip address : $ipaddress"

echo "Enter 1 to input a subdomain, 2 to auto-generate or press Enter to skip:"
echo "1. subdomain"
echo "2. auto-generate"
read -p "Enter your choice (1 or 2): " option
if [ "$option" = "1" ]; then
  echo "Enter your subdomain"
  while true; do
    read -p "Enter subdomain: " subdomain
    if [ -n "$subdomain" ]; then
      # User provided a subdomain, exit the loop
      break
    else
      echo "Input is required. Please try again."
    fi
  done
  echo "Your domain name: $subdomain"
elif [ "$option" = "2" ]; then
  subdomain="automatex-$(date +%s)"
  echo "Auto-generated subdomain: $subdomain"
else
  echo "No action taken. Proceeding without setting a custom subdomain."
fi

#input domain name
curl -u 'muyleanging:c8c2397f4a299ed82757ff33c4326a07403586c1' 'https://api.name.com/v4/domains/sen-pai.live/records' -X POST -H 'Content-Type: application/json' --data '{"host":"'"$subdomain"'","type":"A","answer":"'"$ipaddress"'","ttl":300}'

echo "Here is you file site-aviable: $nginxConfigName"
nginxConfigDir="/etc/nginx/sites-available"

# Generate the NGINX configuration dynamically with the updated port
nginxConfigContent="
server {
    listen 80;
    server_name $subdomain.sen-pai.live;

    location / {
        proxy_pass http://$server1:$port1;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}"

# Create the NGINX configuration file
echo "$nginxConfigContent" > "$nginxConfigDir/$nginxConfigName"

# Create a symbolic link to enable the configuration
sudo ln -s "$nginxConfigDir/$nginxConfigName" "/etc/nginx/sites-enabled/$nginxConfigName"

# Reload NGINX to apply the changes
sudo systemctl reload nginx  # Use 'service nginx reload' on some systems

echo "NGINX configuration updated with server_name: $subdomain.sen-pai.live and container port: $port1."
echo "NGINX configuration file created: $nginxConfigDir/$nginxConfigName."
echo "Symbolic link created in /etc/nginx/sites-enabled/$nginxConfigName."

# Run Certbot after NGINX configuration is updated and container is ready
if certbot --nginx -d "$subdomain.sen-pai.live" --non-interactive; then
    echo "Certbot successful."
    # Send a success message to Telegram with the domain
    curl -s -X POST https://api.telegram.org/bot6678469501:AAGO8syPMTxn0gQGksBPRchC-EoC6QRoS5o/sendMessage -d chat_id=1162994521 -d text="                             
                ……….
            ……………….......
        ……       ✨       …
    …    ✨              ✨ ….
  ……           𝐜𝐨𝐧𝐠𝐫𝐚𝐭𝐳         ……
………        👏    🎉   👍        ………
  ……   ✨     ◝(ᵔᵕᵔ)◜     ✨  ……
    << $subdomain.sen-pai.live >>
                              …….
        ……        ✨     ….
                ……………....
                 ……."
else
    echo "Certbot failed."
    # Send an error message to Telegram with the domain
    curl -s -X POST https://api.telegram.org/bot6678469501:AAGO8syPMTxn0gQGksBPRchC-EoC6QRoS5o/sendMessage -d chat_id=1162994521 -d text="Certbot failed for domain: $subdomain.sen-pai.live."
fi

