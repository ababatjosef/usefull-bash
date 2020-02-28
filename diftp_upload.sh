#!/bin/bash
# Diftp upload script
#

if [ -z $1 ]; then
	clear
    cat <<-EOF
	===============================================
	What can this script do?: 
	Remove characters present in \"*.dat\" files such as: {, }, [, and ].
	Relocate files hidden under \".ssh\" directory.
	Update the timestamp of all the \"dat\" files it finds.
	Shows you a list of files that were successfully uploaded(cleared) and files that needs manual check.
	Sends email of the processing results.
	===============================================
EOF

    Dir=~/Desktop
    cd $Dir

    #  Email Validation --->
    read -p "Enter your email address (optional): " Email
    if echo "${Email}" | grep '^[a-zA-Z0-9]*@[a-zA-Z0-9]*\.[a-zA-Z0-9]*$' >/dev/null; then
        echo "Valid Email address."
    else
        echo "Invalid Email address."
			Email="Invalid"
    fi
    # <---

	Row_a=$(ls | grep -i eml | cat -n | cut -f1)
	Row_b=$(ls | grep -i eml | cat -n | cut -f2)
	Row_count=$(ls | grep -i eml | wc -l)

	echo "Select an eml file to load: "
	ls | grep -i eml | cat -n
	read -p "Enter your choice(number) or q to Quit: " Choice_0

	# Matches existing eml files
	if [ -f $Choice_0 ]; then
   	emlFile=$Choice_0

	# Matches q/Q to quit
	elif [[ $Choice_0 =~ ^[qQ]$ ]] || [[ $Choice_0 =~ ^$ ]]; then
		exit 1

	# Matches any number less than $Row_count
	elif [[ $Choice_0 -le $Row_count ]] && [[ $Choice_0 =~ ^[0123456789]$ ]]; then
   	Choice_1=$(ls | grep -i eml | cat -n | sed -n ${Choice_0}p | cut -f 2)
   	emlFile=$Choice_1

	else
   	echo "File not found."
		exit 1
	fi

	NumberofSlices=$(grep -c /slices/ $emlFile)

	if [  ! -f $emlFile ] || [ $(grep -c /slices/ $emlFile) -eq 0 ] ; then
		echo "The file is either empty or it does not contain the expected strings."
		echo "Please check your Email again and save it in your Desktop."
		exit 1
	else
		Count=$(grep -c /slices/ $emlFile)
	fi
	cat /dev/null > /tmp/diftp_upload.log
	echo "There are $Count files that will be processed: " | tee -a /tmp/diftp_upload.log
	grep /slices/prodpmpsftp $emlFile | cat -n -s | grep --color '{\|}\|\[\|\]\|.ssh'
   read -p "Continue? [y/n]: " Continue
   if [[ ! $Continue =~ ^[Yy]$ ]]; then
	 echo "Quitting..."
    exit 1
   fi
	if [ -e $emlFile ]; then
		Curfile=diftp-load-$(date +%m-%d-%Y-%H%M) # saves the filename format
		mv $emlFile $(echo ${Curfile})				# format input file to diftp-load-$(date +%m-%d-%Y-%H%M)
		echo "Uploading file $Curfile to Diftp Host..."
		scp $Curfile pmpdiftp:/var/tmp/Diftp/
		if [ $? -eq "0" ]; then
			echo "$(date) - $Curfile successfully uploaded!" | tee -a /tmp/diftp_upload.log
			echo "Connecting to Diftp host..."
			ssh pmpdiftp # at this point the script will automatically log you in to the DIFTP Host.
								# then run the command: sudo Diftp/Diftp_processing.sh
			cat /dev/null > /tmp/diftp_process.log
			cat /dev/null > /tmp/diftp_process.log.00
			echo "$(date) - -------------------------------" >> /tmp/diftp_process.log.00
			ssh pmpdiftp "cat /var/tmp/Diftp/diftp_process.log" >> /tmp/diftp_process.log.00
			Success=$(grep -ci successfully /tmp/diftp_process.log.00)
			Notfound=$(grep -ci "not found" /tmp/diftp_process.log.00)
			manualCheck=$(grep -ci "check manually" /tmp/diftp_process.log.00)
			echo "Summary: " >> /tmp/diftp_process.log
			echo "File processed: pmpdiftp:/var/tmp/Diftp/${Curfile}.dir" >> /tmp/diftp_process.log
			echo "There are ${NumberofSlices} total Files (stuck) processed." >> /tmp/diftp_process.log
			echo "There are ${Success} files that were cleared." >> /tmp/diftp_process.log
			echo "There are ${Notfound} files that cannot be located in the FTP host." >> /tmp/diftp_process.log
			echo "There are ${manualCheck} files that needs to be checked manually." >> /tmp/diftp_process.log
			echo "Please check log file: /tmp/diftp_process.log for more details." >> /tmp/diftp_process.log
			echo -e "\n" >> /tmp/diftp_process.log
			rm -f $Curfile
			cat /tmp/diftp_process.log.00 >> /tmp/diftp_process.log
			#echo "Displaying results: "
			#cat /tmp/diftp_process.log
			echo -e "\n"
			echo "============================================================"
			if [ $Email != "Invalid" ]; then
				mail -s "DIFTP file processing results: ${Success} files cleared." ${Email} < /tmp/diftp_process.log
				echo -e "\nResults sent to: ${Email}"
			else
				echo -e "\nInvalid Email entered. No Email sent."
			fi
			echo "Summary: "
			echo "File processed: pmpdiftp:/var/tmp/Diftp/${Curfile}.dir"
			echo "There are ${NumberofSlices} total Files (stuck) processed."
			echo "There are ${Success} files that were cleared."
			echo "There are ${Notfound} files that cannot be located in the FTP host."
			echo "There are ${manualCheck} files that needs to be checked manually."
			echo "Please check log file: /tmp/diftp_process.log for more details."
			echo -e "\n"
		else
			echo "Upload failed."
			exit
		fi
	else
		echo "Cannot locate the file. Please try again."
	fi

else
	echo "Do not provide arguments to the command."

fi
