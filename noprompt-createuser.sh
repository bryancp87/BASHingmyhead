#!/bin/bash
#
#
# Author: Bryan Cruz
# Organization: Infrastructure
#
# Purpose: script creates of users on Ubuntu Linux servers. Use only to give access to employees from other organizations in the company.
#
# you must supply a username as an argument to the script
# Optional: provide a comment for the account as an argument
# A passport is automatically generated
# The user name, password and host for the account will be displayed

# Make sure the script is executed as root
if [[ "${UID}" -ne 0 ]]; then echo 'Please run as root.'; exit 1 ; fi

# Make sure they supply at least one argument
if [[ "${#}" -lt 1  ]] ; then echo "Usage of command: ${0} USER_NAME [COMMENT]... " ; echo "Create an account on the local system with the name of USER_NAME and a comments field of COMMENT. " ; exit 1 ; fi

# Save the first parameter User Name
USER_NAME="${1}"

# Save subsiquent lines as comments. shift moves the pointer to the next parameter in the input. which is where the comments will begin
shift
COMMENT="${@}"

# Generate a secure password
PASSWORD=$(date +%s%N | sha256sum | shuf | head -c30)

# Create account. -c is for comment -m to force creation of home directory -p password
useradd -c "${COMMENT}" -m ${USER_NAME}

# Check if useradd succeeded. if it did continue and inform the user of the creation. if it failed notify the user of the failure.
if [[ "${?}" -ne 0 ]]
then
        echo "The account could not be created"
        exit 1
fi

# set password and force password change. stdin takes the output from the previous command that is piped into passwd command and uses it as the input . In this case it is PASSWORD that is piped and uses as the input for the passwd command against user USERNAME

echo "${USER_NAME}:${PASSWORD}" | chpasswd

# Check if the passwd command succeeded
if [[ "${?}" -ne 0 ]]
then
	echo "The password could not be set."
fi

# force password change upon first login
passwd --expire ${USER_NAME}


# Display entered information inputed by user.
echo "Account was created . Password will need to be reset upon first login ... "
echo "UserName: ${USER_NAME} "
echo "Comment:  ${COMMENT} "
echo "Password: ${PASSWORD} "
echo "Reach out to IT if you are unable to login"
exit 0
