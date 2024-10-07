#!/bin/bash

random_num=$(( RANDOM % 1001 ))

echo -e "\nThe random number generated is: $random_num\n"

echo -e "\nEnter your username:\n"

read username

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

does_username_exist=$( $PSQL "SELECT EXISTS(SELECT username FROM usernames WHERE username = '$username');" )

echo -e "\nUsername is: $username. What is does_username_exist? It is: $does_username_exist\n"

if [[ $does_username_exist == "t" ]]; then
  games_played=$( $PSQL "SELECT games_played FROM usernames WHERE username = '$username'" )
  
  best_game=$( $PSQL "SELECT best_game FROM usernames WHERE username = '$username'" )

  echo -e "\nWelcome back, $username! You have played $games_played games, and your best game took $best_game guesses.\n"
else
  echo -e "\nWelcome, $username! It looks like this is your first time here.\n"

  $PSQL "INSERT INTO usernames(username) VALUES('$username');" 
fi