#!/bin/bash
#  Email Validation --->
read -p "Enter your email address (optional): " Email
if echo "${Email}" | grep '^[a-zA-Z0-9]*@[a-zA-Z0-9]*\.[a-zA-Z0-9]*$' >/dev/null; then
    echo "Valid Email address."
else
    echo "Invalid Email address."
                    Email="Invalid"
fi
