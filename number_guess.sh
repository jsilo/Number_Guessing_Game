#!/bin/bash

random_num=$(( RANDOM % 1001 ))

echo "Enter your username:"

read username

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

does_username_exist=$( $PSQL "SELECT EXISTS(SELECT username FROM usernames WHERE username = '$username');" )

if [[ $does_username_exist == "t" ]]; then
  games_played=$( $PSQL "SELECT games_played FROM usernames WHERE username = '$username'" )
  
  best_game=$( $PSQL "SELECT best_game FROM usernames WHERE username = '$username'" )

  echo "Welcome back, $username! You have played $games_played games, and your best game took $best_game guesses."
else
  echo "Welcome, $username! It looks like this is your first time here."

  suppressed=$( $PSQL "INSERT INTO usernames(username) VALUES('$username');" )
fi

guess_validator() {

  local validated_guess=$1

  while true; do
    if [[ $validated_guess =~ ^[[:digit:]]+$ ]]; then
      break
    else
      echo "That is not an integer, guess again:"
      read validated_guess
    fi
  done

  guess=$validated_guess

}

number_of_guesses=0

echo "Guess the secret number between 1 and 1000:"

while true; do
  
  read guess
  guess_validator $guess
  
  (( number_of_guesses++ ))

  if (( guess < $random_num )); then
    echo "It's higher than that, guess again:"

  elif (( guess > $random_num )); then
    echo "It's lower than that, guess again:"
    
  else
    echo "You guessed it in $number_of_guesses tries. The secret number was $random_num. Nice job!"

    break
  fi
done

# Record the results for the username

username_stats_command_string="UPDATE usernames
  SET games_played = games_played + 1,
  best_game =
    CASE
      WHEN best_game IS NULL THEN $number_of_guesses
      WHEN $number_of_guesses < best_game THEN $number_of_guesses
      ELSE best_game
    END
  WHERE username = '$username';"

# Update the database

suppressed=$( $PSQL "$username_stats_command_string" )