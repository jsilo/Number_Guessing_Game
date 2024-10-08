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

guess_validator() {

  local validated_guess=$1

  while true; do
    if [[ $validated_guess =~ ^[[:digit:]]+$ ]]; then
      echo -e "\nThe guess is a pure integer."
      break
    else
      echo -e "\nThat is not an integer, guess again:"
      read validated_guess
    fi
  done

  echo -e "\nExiting the guess_validator function. The validated guess is: $validated_guess\nNow overwriting global variable 'guess'.\n"

  guess=$validated_guess

}

number_of_guesses=0

echo -e "\nGuess the secret number between 1 and 1000:"

while true; do
  
  read guess
  guess_validator $guess

  echo -e "Start of while loop. \$guess is: $guess"
  
  (( number_of_guesses++ ))

  if (( guess < $random_num )); then
    echo -e "\nIt's higher than that, guess again:"

  elif (( guess > $random_num )); then
    echo -e "\nIt's lower than that, guess again:"
    
  else
    echo "You guessed it in $number_of_guesses tries. The secret number was $random_num. Nice job!"

    break
  fi
done