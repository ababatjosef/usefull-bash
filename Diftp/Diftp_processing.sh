$ cat Diftp/Diftp_processing.sh
#!/bin/bash
clear
Dir=/var/tmp/Diftp
cd $Dir

#--- Process input
Row_a=$(find . -maxdepth 1 -type f | grep -v log | cat -n | cut -f1)
Row_b=$(find . -maxdepth 1 -type f | grep -v log | cat -n | cut -f2)
Row_count=$(find . -maxdepth 1 -type f | grep -v log | wc -l)

echo "Select an eml file to load: "
find . -maxdepth 1 -type f | grep -v log | cat -n
read -p "Enter your choice(number) or q to Quit: " Choice_0

#
# Matches q/Q to quit
if [[ $Choice_0 =~ ^[qQ]$ ]] || [[ $Choice_0 =~ ^$ ]]; then
   exit 1

# Matches existing eml files
elif [ -f $Choice_0 ]; then
   emlFile=$Choice_0

# Matches any number less than $Row_count
elif [[ $Choice_0 -le $Row_count ]] && [[ $Choice_0 =~ ^[0123456789]$ ]]; then
   Choice_1=$(find . -maxdepth 1 -type f | grep -v log | cat -n | sed -n ${Choice_0}p | cut -f2)
   emlFile=$Choice_1

else
   echo "$(date) - File not found." | tee -a ${emlFile}.log
   exit 1
fi

#---

if [ ! -f $emlFile ]; then
        echo "$(date) - EML file not found." | tee -a ${emlFile}.log
        exit 1
else
        mkdir ${emlFile}.dir
        mv $emlFile ${emlFile}.dir
        cd ${emlFile}.dir
	echo "$(date) - Start processing..."
        echo "$(date) - Processing eml file: ${emlFile}." | tee -a ${emlFile}.log
        grep slices $emlFile | while read alpha beta ; do echo $alpha ; done > ${emlFile}.txt1                      # remove unnecessary columns
        grep slices $emlFile | while read alpha beta ; do echo $alpha ; done | sed 's/{\|}\|\[\|\]\|.ssh\///g' > ${emlFile}.txt2    # remove '.ssh/', '[', ']', '{' and '}'
        paste ${emlFile}.txt1 ${emlFile}.txt2 > ${emlFile}.txt3                                                   # combine the files together
        cat ${emlFile}.txt3 | sed -e "s/  */ /g" > ${emlFile}.txt4                                                    # remove excess tabs and spaces
        Total_lines=$(wc -l < ${emlFile}.txt4)
        Indx=1
        while [ $Indx -le $Total_lines ]; do
                Line_a[$Indx]=$(sed -n ${Indx}p ${emlFile}.txt1)  # each line in the file is saved into an array variable
                Line_b[$Indx]=$(sed -n ${Indx}p ${emlFile}.txt2)  # same for txt2 file
                if [ -f ${Line_a[$Indx]} ]; then
			echo "$(date) - Processing file: ${Line_a[$Indx]}" | tee -a ${emlFile}.log
                        touch ${Line_a[$Indx]}
                        sleep 3
                        if [ -f ${Line_a[$Indx]} ]; then
				echo "$(date) - Renaming: ${Line_a[$Indx]}" | tee -a ${emlFile}.log
                                mv ${Line_a[$Indx]} ${Line_b[$Indx]}
                                sleep 3
                                        if [ -f ${Line_b[$Indx]} ]; then
                                                echo "$(date) - Please check manually: ${Line_b[$Indx]}." | tee -a ${emlFile}.log
					else
						echo "$(date) - Cleared successfully: ${Line_b[$Indx]}." | tee -a ${emlFile}.log

                                        fi
			else
				echo "$(date) - Cleared successfully: ${Line_a[$Indx]}". | tee -a ${emlFile}.log
                        fi
                else
                        echo "$(date) - File not found: ${Line_a[$Indx]}." | tee -a ${emlFile}.log
                fi
        Indx=$[$Indx + 1]
        done
	Success=$(grep -ci Cleared ${emlFile}.log)
        echo "$(date) - Script execution completed with $Success files cleared." | tee -a ${emlFile}.results
	cat ${emlFile}.log >> ${emlFile}.results
	cp ${emlFile}.results $Dir/diftp_process.log

	 NumberofSlices=$(grep -ci "/slices" ${emlFile})
         Success=$(grep -ci successfully $Dir/diftp_process.log)
         Notfound=$(grep -ci "not found" $Dir/diftp_process.log)
         manualCheck=$(grep -ci "check manually" $Dir/diftp_process.log)
         echo "Summary: "
         echo "File processed: pmpdiftp:${Dir}/${emlFile}.dir"
         echo "There are ${NumberofSlices} total Files (stuck) processed."
         echo "There are ${Success} files that were cleared."
         echo "There are ${Notfound} files that cannot be located in the FTP host."
         echo "There are ${manualCheck} files that needs to be checked manually."
         echo "Please check log file: $Dir/diftp_process.log for more details."

fi

