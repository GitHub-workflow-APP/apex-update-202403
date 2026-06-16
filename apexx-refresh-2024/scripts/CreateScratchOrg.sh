#!/bin/bash
sf org create scratch --set-default -f config/project-scratch-def.json --alias apexxrefresh2024 --duration-days 30
sf config set target-org apexxrefresh2024
sf project deploy start

# Create a  temporary user
echo "Creating Standard User joe@example.org"
sf org create user --set-alias joefound --definition-file config/custom-user.json
sf org user display -o joe@example.org

# Adding some initial data into Custom objects
sf data create record --sobject Dialog__c --values "Name='Uno', Message__c='Msg Uno'"
sf data create record --sobject Dialog__c --values "Name='Due', Message__c='Msg Due'"
sf data create record --sobject Dialog__c --values "Name='Tre', Message__c='Msg Tre'"
sf data create record --sobject Dialog__c --values "Name='Tre', Message__c='Msg Tre'"
sf data create record --sobject Pagghiazzu__c --values "Name='Primo Pagghiazzu' Color__c='Red'"
sf data create record --sobject Pagghiazzu__c --values "Name='Secondo Pagghiazzu' Color__c='Blue'"
sf data create record --sobject Pagghiazzu__c --values "Name='Terzo Pagghiazzu' Color__c='Yellow'"

echo "Remember to disable 'Enhanced Tracking Protection' in Firefox to avoid the error message related to sharing cookies"