#!/bin/bash
# assume the QA user, with alias joefound, was already created via CreateQaUser.sh.
# An alternative can be to enable the current IP to Trusted IPs so that MFA is disabled for the Scratch Org

# It opens the scratch org in a private window so that the main user can still connect
sfdx force:org:open -u joefound --private