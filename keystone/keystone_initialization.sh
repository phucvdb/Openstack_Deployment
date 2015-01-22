#!/bin/bash -v
# Export the variable Env
source ../deployment.cfg

export OS_SERVICE_TOKEN=$TOKEN_PASS
export OS_SERVICE_ENDPOINT=http://$KEYSTONE_HOST:35357/v2.0

# To create tenants, users, and roles on Keyston Server
echo "Create tenants, users, and roles"
# Create the admin tenant
keystone tenant-create --name admin --description "Admin Tenant"
# Create the admin user
keystone user-create --name admin --pass $ADMIN_PASS --email $ADMIN_Email
# Create the admin role
keystone role-create --name admin
# Add the admin role to the admin tenant and user
keystone user-role-add --user admin --tenant admin --role admin
# Create the demo tenant
keystone tenant-create --name demo --description "Demo Tenant"
# Create the demo user under the demo tenant
keystone user-create --name demo --tenant demo --pass DEMO_PASS --email EMAIL_ADDRESS
