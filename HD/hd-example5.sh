#!/usr/local/bin/bash
#Declare the function which will retrieve data from Here Document
BookInfo ()
{
read ISBN
read bookName
read authorName
read edition
read publication
read price
}
# Declare here document part to send data into the function
BookInfo <<ADDTEXT5
ISBN-78633567809
Easy Laravel 5
Jason Gilmore
9th Edition
Learpub
100
ADDTEXT5
# Print the value of the function variables after calculating price value with 10% discount
((price=$price-$price*10/100))
echo "$bookName"
echo "$authorName"
echo "$edition, $publication"
echo "$"$price