if [ "$1" == "openstack" ]; then
  cat > "$(dirname -- "$0")"/rclone.conf <<EOF
[crypt]
type = swift
env_auth = false
user = ${OS_USERNAME} 
key = ${OS_PASSWORD}
auth = ${OS_AUTH_URL}
domain = ${OS_USER_DOMAIN_NAME}
tenant = ${OS_TENANT_NAME}
tenant_id = ${OS_TENANT_ID}
region = ${OS_REGION_NAME}
auth_version = 3
endpoint_type = public

EOF
elif  [ "$1" == "aws" ]; then
  cat > "$(dirname -- "$0")"/rclone.conf <<EOF
[crypt]
type = s3
provider = AWS
env_auth = false
access_key_id = ${AWS_ACCESS_KEY_ID}
secret_access_key = ${AWS_SECRET_ACCESS_KEY}
region = ${AWS_DEFAULT_REGION}
endpoint = 
location_constraint = 
acl = private
server_side_encryption = 
storage_class = 

EOF

elif  [ "$1" == "azure" ]; then
	if [ -f "$(dirname -- "$0")"/rclone.conf ]; then
	      	rm "$(dirname -- "$0")"/rclone.conf
	fi
fi
