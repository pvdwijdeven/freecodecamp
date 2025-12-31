#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

# get username
echo "Enter your username:"
read USER_NAME

# check if in DB
USER_ID=$($PSQL "SELECT user_id FROM users WHERE name='$USER_NAME'";)
if [[ -z $USER_ID ]]
then
  # user does not exist: add user
  RESULT=$($PSQL "INSERT INTO users(name) VALUES('$USER_NAME')";)
  USER_ID=$($PSQL "SELECT user_id FROM users WHERE name='$USER_NAME'";)

  echo "Welcome, $USER_NAME! It looks like this is your first time here."
else
  # user exists: greet current user
  # TODO get other variables
  RESULT=$($PSQL "SELECT MIN(score), COUNT(SCORE) FROM games WHERE user_id='$USER_ID'";)
  IFS="|" read -r MIN_SCORE GAMES_PLAYED <<< "$RESULT"
  echo "Welcome back, $USER_NAME! You have played $GAMES_PLAYED games, and your best game took $MIN_SCORE guesses."
fi
# start guessing game
# create random number
RANDOM_NUMBER=$((1 + RANDOM % 1000))
echo "Guess the secret number between 1 and 1000:"
USER_NUMBER=-1
COUNTER=1
while (( $RANDOM_NUMBER != $USER_NUMBER ))
do
  read USER_NUMBER
  if ! [[ "$USER_NUMBER" =~ ^[0-9]+$ ]]
  then
    echo "That is not an integer, guess again:"
  else
    if (( $RANDOM_NUMBER < $USER_NUMBER ))
    then
      # if lower:
      echo "It's lower than that, guess again:"
      (( COUNTER++ ))
    else
      if (( $RANDOM_NUMBER > $USER_NUMBER ))
      then
        # if higher:
        echo "It's higher than that, guess again:"
        (( COUNTER++ ))
      fi
    fi
  fi
done
# update database
RESULT=$($PSQL "INSERT INTO games(user_id, score) VALUES('$USER_ID',$COUNTER)";)
# message to user
echo "You guessed it in $COUNTER tries. The secret number was $RANDOM_NUMBER. Nice job!"
