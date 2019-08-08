#! /bin/bash

# Note versions are manually encoded in the script:
# Machine 0.16.1
# Compose: 1.24.0
#
MACHINE_VER="0.16.1"
COMPOSE_VER="1.24.0"
DISTRIB_ID="$(lsb_release -is|awk '{print tolower($0)}')"
DISTRIB_CODENAME="$(lsb_release -cs)"

GREEN='\033[0;32m'
NC='\033[0m'
EXE_PATH=$(dirname $0)

# Update package list ( -qq and send to dev/null to not spam output)
apt-get -qq update > /dev/null
DEBIAN_FRONTEND=noninteractive apt-get -qq -y upgrade

# Install docker and dependencies
install_docker () {
  echo -e "${GREEN} =====> Installing Docker${NC}"
  apt-get install -y apt-transport-https ca-certificates curl software-properties-common monitoring-plugins
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
  echo "deb [arch=amd64] https://download.docker.com/linux/${DISTRIB_ID} ${DISTRIB_CODENAME} stable" > /etc/apt/sources.list.d/docker.list
  apt-get -qq update > /dev/null
  apt-get install -y docker-ce
}

# Install Docker Machine (15)
install_docker_machine() {
  echo -e "${GREEN} =====> Installing Docker Machine${NC}"
  base=https://github.com/docker/machine/releases/download/v${MACHINE_VER}
  curl -L $base/docker-machine-$(uname -s)-$(uname -m) >/tmp/docker-machine
  install /tmp/docker-machine /usr/local/bin/docker-machine
}

# Install docker-compose (1.22)
install_docker_compose() {
  echo -e "${GREEN} =====> Installing Docker Compose${NC}"
  curl -L "https://github.com/docker/compose/releases/download/${COMPOSE_VER}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
  chmod +x /usr/local/bin/docker-compose
}

# Configure syslog
config_rsyslog() {
  sed -i '17s/^#//' /etc/rsyslog.conf
  sed -i '18s/^#//' /etc/rsyslog.conf
  sed -i '21s/^#//' /etc/rsyslog.conf
  sed -i '22s/^#//' /etc/rsyslog.conf
  service rsyslog restart
}

# Add docker logging driver to syslog
prep_docker() {
  cp ${EXE_PATH}/docker_files/daemon.json /etc/docker
  service docker restart
}

run_containers() {
  echo -e "${GREEN} =====> Bringing up containers${NC}"
  pushd ${EXE_PATH}/docker_files

  mkdir -p data/sensu-backend data/influxdb/{config,data}
  docker-compose up -d --build

  # Inject the admin user (eventually we'll fix this with loading a backup database)
  sleep 5
  docker-compose run app python3 manage.py shell -c "from django.contrib.auth.models import User; User.objects.create_superuser('admin', 'admin@example.com', 'P@ssw0rd!')"

  popd

  # Create tutorial_metrics in influxDB
  echo -e "${GREEN} =====> Creating tutorial_metrics database in InfluxDB${NC}"
  curl -i -XPOST http://localhost:8086/query --data-urlencode "q=CREATE DATABASE tutorial_metrics"
  curl -i -XPOST http://localhost:8086/query --data-urlencode "q=CREATE USER admin WITH PASSWORD 'pass' WITH ALL PRIVILEGES"

  # Configure Grafana to use Influx
  # Copy the file to provisioning/datasources?
}

# Install Sensu 5.9 CLI tool and configure
install_sensu() {
  echo -e "${GREEN} =====> Installing Sensu CLI tool and add checks${NC}"
  curl -s https://packagecloud.io/install/repositories/sensu/stable/script.deb.sh | sudo bash
  sudo apt-get -y install sensu-go-agent sensu-go-cli

  # Configure sensu. Note DEFAULT password
  # admin: admin/P@ssw0rd!
  # read only: sensu/sensu

  # To change: sensuctl configure -n --url "http://127.0.0.1:8080" --username "admin" --password "SOMEPASSWORD"
  # sensuctl configure -n --url "http://127.0.0.1:8080" --username "sensu" --password "SOMEPASSWORD"

  sensuctl configure -n --url "http://127.0.0.1:8080" --username "admin" --password "P@ssw0rd!"

  pushd ${EXE_PATH}/sensu

  # Configure the local sensu agent (for host metrics and checks)
  cp agent.yml /etc/sensu/agent.yml
  # Enable access to docker socket for sensu checks
  usermod -aG docker sensu

  systemctl enable sensu-agent
  systemctl start sensu-agent

  popd

  # Install InfluxDB handler - not used but convenient
  echo -e "${GREEN} =====> Installing InfluxDB handler and configure${NC}"
  wget -qO- https://github.com/sensu/sensu-influxdb-handler/releases/download/3.1.2/sensu-influxdb-handler_3.1.2_linux_amd64.tar.gz | tar xzv --strip-components 1 bin/sensu-influxdb-handler

  # Add handler to influx container
  docker cp ./sensu-influxdb-handler sensu-backend:/usr/local/bin/
  docker exec sensu-backend chown root:root /usr/local/bin/sensu-influxdb-handler
  docker exec sensu-backend chmod +x /usr/local/bin/sensu-influxdb-handler

  # Configure handler
  sensuctl handler create influxdb --type pipe --command "/usr/local/bin/sensu-influxdb-handler --addr 'http://influxdb:8086' --db-name tutorial_metrics --username admin --password pass"

  # Install and configure sensu scripts
  wget -O /usr/local/bin/check_docker https://raw.githubusercontent.com/timdaman/check_docker/master/check_docker/check_docker.py
  chmod 755 /usr/local/bin/check_docker

  cat ${EXE_PATH}/sensu/sensu-go-checks.json | sensuctl create
}

# Metrics via telegraf
install_metrics() {
  echo -e "${GREEN} =====> Installing Telegraf${NC}"
  curl -sL https://repos.influxdata.com/influxdb.key | apt-key add -
  echo "deb https://repos.influxdata.com/${DISTRIB_ID} ${DISTRIB_CODENAME} stable" | tee /etc/apt/sources.list.d/influxdb.list

  apt-get -qq update
  apt-get install -y telegraf
  sudo systemctl enable telegraf

  usermod -aG docker telegraf
  cp ${EXE_PATH}/telegraf/telegraf.conf /etc/telegraf/telegraf.conf

  sudo systemctl start telegraf
  echo "Waiting for telegraf to start ..."
  sleep 5
  systemctl restart telegraf
}

install_rclone() {
  echo -e "${GREEN} =====> Installing Rclone${NC}"
  bash ${EXE_PATH}/rclone/rclone-setup.sh
}

# Main Script flow
install_docker
install_docker_machine
install_docker_compose
config_rsyslog
prep_docker
run_containers
install_sensu
install_metrics
install_rclone
