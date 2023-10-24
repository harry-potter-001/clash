if [[ $EUID -ne 0 ]]; then
    echo "$0 not running as root. Run using sudo."
    exit 2
fi

mkdir /etc/clash
mkdir /etc/clash/web-ui
mkdir /etc/clash/configs

# Download the latest Clash binary for AMD64
wget https://github.com/Dreamacro/clash/releases/latest/download/clash-linux-amd64-latest.gz
gunzip clash-linux-amd64-latest.gz
mv clash-linux-amd64-latest clash
mv clash /etc/clash
rm -rf clash-linux-amd64-latest.gz
chmod +x /etc/clash/clash

cat << EOF > /etc/systemd/system/clash.service
[Unit]
Description=Clash daemon, A rule-based proxy in Go.
After=network.target

[Service]
Type=simple
Restart=always
ExecStart=/etc/clash/clash -d /etc/clash/configs
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload

wget https://github.com/haishanh/yacd/releases/download/v0.3.8/yacd.tar.xz
tar -xvf yacd.tar.xz
rm -rf yacd.tar.xz
mv public /etc/clash/web-ui

systemctl start clash.service

echo "Waiting 10 seconds to download some files"
sleep 10

systemctl stop clash.service

echo "
*****************************************************************************
Clash Installed Successfully

To start Clash, run: sudo systemctl start clash
To stop Clash, run: sudo systemctl stop clash
To enable Clash on boot, run: sudo systemctl enable clash

To view the web UI, go to http://localhost:9090/ui

To change the config, edit the file at /etc/clash/configs/config.yaml

*****************************************************************************

"
