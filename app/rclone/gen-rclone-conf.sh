cat > ../../app/rclone/rclone.conf <<EOF
[remote]
user = ${OS_USERNAME}
key = ${OS_PASSWORD}
auth = ${OS_AUTH_URL}
tenant = ${OS_TENANT_NAME}
tenant_id = ${OS_TENANT_ID}
region = ${OS_REGION_NAME}
endpoint_Type = public

[crypt]
type = crypt
remote = remote:composeexample
filename_encrpytion = standard
password = $(head -c16 </dev/urandom|xxd -p -u)
password2 = $(head -c16 </dev/urandom|xxd -p -u)

EOF
