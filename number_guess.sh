#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

MAIN_MENU() {
SECRET_NUMBER=$(( RANDOM % 1000 + 1 ))
GUESSES=1
echo $SECRET_NUMBER
echo "Enter your username:"
read NAME

PLAYER_NAME=$($PSQL "SELECT username FROM users WHERE username='$NAME'")

if [[ -z $PLAYER_NAME ]]
then
  # insert new player
  INSERT_NEW_PLAYER=$($PSQL "INSERT INTO users(username) VALUES('$NAME')")
  echo -e "\nWelcome, $NAME! It looks like this is your first time here."
else
  GAMES_PLAYED=$($PSQL "SELECT COUNT(username) FROM games WHERE username='$PLAYER_NAME'")
  BEST_GAME=$($PSQL "SELECT MIN(number_of_guesses) FROM games WHERE username='$PLAYER_NAME'")
  echo -e "\nWelcome back, $PLAYER_NAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses.\n"
fi

echo -e "Guess the secret number between 1 and 1000:"
read GUESS

while [[ ! $GUESS -eq $SECRET_NUMBER ]]
do
  if [[ ! $GUESS =~ ^[0-9]+$ ]]
    then
      ((GUESSES++))
      echo -e "That is not an integer, guess again:"
      read GUESS
    elif [[ $GUESS -gt $SECRET_NUMBER ]]
    then
      ((GUESSES++))
      echo -e "It's lower than that, guess again:"
      read GUESS
    elif [[ $GUESS -lt $SECRET_NUMBER ]]
    then 
      ((GUESSES++))
      echo -e "It's higher than that, guess again:"
      read GUESS
  fi
done

INSERT_GAME=$($PSQL "INSERT INTO games(username, number_of_guesses) VALUES('$NAME', $GUESSES)")
echo -e "\nYou guessed it in $GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!\n"

}

MAIN_MENU