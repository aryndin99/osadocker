#!/bin/bash

FIRSTNAMES=(Jackson Aiden Liam Lucas Noah Mason Jayden Ethan Jacob Jack Caden Logan Benjamin Michael Caleb Ryan Alexander Elijah James William Oliver Connor Matthew Daniel Luke Brayden Jayce Henry Carter Dylan Gabriel Joshua Nicholas Isaac Owen Nathan Grayson Eli Landon Andrew Max Samuel Gavin Wyatt Christian Hunter Cameron Evan Charlie David Sebastian Joseph Dominic Anthony Colton John Tyler Zachary Thomas Julian Levi Adam Isaiah Alex Aaron Parker Cooper Miles Chase Muhammad Christopher Blake Austin Jordan Leo Jonathan Adrian Colin Hudson Ian Xavier Camden Tristan Carson Jason Nolan Riley Lincoln Brody Bentley Nathaniel Josiah Declan Jake Asher Jeremiah Cole Mateo Micah Elliot)

LASTNAMES=(SMITH JOHNSON WILLIAMS BROWN JONES MILLER DAVIS GARCIA RODRIGUEZ WILSON MARTINEZ ANDERSON TAYLOR THOMAS HERNANDEZ MOORE MARTIN JACKSON THOMPSON WHITE LOPEZ LEE GONZALEZ HARRIS CLARK LEWIS ROBINSON WALKER PEREZ HALL YOUNG ALLEN SANCHEZ WRIGHT KING SCOTT GREEN BAKER ADAMS NELSON HILL RAMIREZ CAMPBELL MITCHELL ROBERTS CARTER PHILLIPS EVANS TURNER TORRES PARKER COLLINS EDWARDS STEWART FLORES MORRIS NGUYEN MURPHY RIVERA COOK ROGERS MORGAN PETERSON COOPER REED BAILEY BELL GOMEZ KELLY HOWARD WARD COX DIAZ RICHARDSON WOOD WATSON BROOKS BENNETT GRAY JAMES REYES CRUZ HUGHES PRICE MYERS LONG FOSTER SANDERS ROSS MORALES POWELL SULLIVAN RUSSELL ORTIZ JENKINS GUTIERREZ PERRY BUTLER BARNES FISHER)

# write header
echo "purchase_sum,transaction_time,client_name,card_number,client_age"

index=0

while true; do
  FIRSTNAMEINDEX=$[ RANDOM % 100 ]
  LASTNAMEINDEX=$[ RANDOM % 100 ]
  CARDNUMBER="$[ RANDOM % 10]$[ RANDOM % 10]$[ RANDOM % 10]$[ RANDOM % 10]$[ RANDOM % 10]$[ RANDOM % 10]$[ RANDOM % 10]$[ RANDOM % 10]$[ RANDOM % 10]$[ RANDOM % 10]$[ RANDOM % 10]$[ RANDOM % 10]$[ RANDOM % 10]$[ RANDOM % 10]$[ RANDOM % 10]$[ RANDOM % 10]"
  PURCHASESUM=$[ 1 + $[ RANDOM % 10000 ]].$[ 1 + $[ RANDOM % 99 ]]

  #Define client age

  ROUNDPURCHASESUM=`echo $PURCHASESUM | awk '{print int($1)}'`

  if [ $ROUNDPURCHASESUM -ge 5000 ]; then
    CLIENTAGE=$(( 20 + $[ RANDOM % 20 ]))
  else
    CLIENTAGE=$(( 41 + $[ RANDOM % 39 ]))
  fi

  # write data in csv format
  # every 30th line must belong to the same person to facilitate the fraud detection usecase demo
  if [ $(($index%30)) -eq 0 ]; then
    echo "$PURCHASESUM,$(date +%s%N),\"Alphonse Gabriel CAPONE\",\"5512345678901234\",99"
  else
    echo "$PURCHASESUM,$(date +%s%N),\""${FIRSTNAMES[$FIRSTNAMEINDEX]} ${LASTNAMES[$LASTNAMEINDEX]}"\",\"$CARDNUMBER\",$CLIENTAGE"
  fi

  index=$(($index+1))
done


