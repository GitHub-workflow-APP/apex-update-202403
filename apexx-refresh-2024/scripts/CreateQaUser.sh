#!/bin/bash
# Basic script just executing two commands to create a user and display its properties. There is no error check
# https://developer.salesforce.com/docs/atlas.en-us.sfdx_dev.meta/sfdx_dev/sfdx_dev_scratch_orgs_users_def_file.htm
sf org create user --set-alias joefound --definition-file config/custom-user.json
sf org user display -o joe@example.org
echo "You can log in via 'sf org login web --instance-url https://app-enterprise-303-dev-ed.scratch.my.salesforce.com'"