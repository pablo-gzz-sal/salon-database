#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=salon -t --no-align -c"

echo -e "\n~~~~~ MY SALON ~~~~~\n"

MAIN_MENU(){
  if [[ $1 ]]
   then
   echo -e "\n$1"
  fi 
  echo "Welcome to My Salon, how can I help you?"
  AVAILABLE_SERVICES=$($PSQL "SELECT service_id, name FROM services")
  AVAILABLE_SERVICES_FORMATTED=$(echo $AVAILABLE_SERVICES | sed 's/|/) /g')
  echo "$AVAILABLE_SERVICES_FORMATTED" | while read SERVICE_ID NAME 
  do
    echo "$SERVICE_ID $NAME"
  done
  read SERVICE_ID_SELECTED
  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
   then
      # send to main menu
      MAIN_MENU "That is not a valid service number."
  else 
    SERVICE_AVAILABILITY=$($PSQL "SELECT service_id FROM services WHERE service_id = $SERVICE_ID_SELECTED")
    
    if [[ -z $SERVICE_AVAILABILITY ]]
      then
        MAIN_MENU "That is not a valid service number"
      else
        echo -e "\nWhat's your phone number?"
        read CUSTOMER_PHONE
        CUSTOMER_PHONE_AVAILABLE=$($PSQL "SELECT phone FROM customers WHERE phone = '$CUSTOMER_PHONE'")
        if [[ -z $CUSTOMER_PHONE_AVAILABLE ]]
         then
         echo -e "\nI don't have a record for that phone number, what's your name?"
         read CUSTOMER_NAME
         INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
        fi
        echo -e "\nWhat time would you like your cut, $CUSTOMER_NAME?"
        read SERVICE_TIME
        #get customer id
        CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
        #get service name
        SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_AVAILABILITY")
        INSERT_SERVICE_TIME_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_AVAILABILITY, '$SERVICE_TIME')")
        echo "I have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
    fi
  fi
}

MAIN_MENU