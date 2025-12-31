#! /bin/bash

# PSQL string
PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"

if [ -z "$1" ]
then
  # no argument provided
  echo "Please provide an element as an argument."
else
  # argument provided, actual program

  # first check if $1 is (numeric) atomic number
  if [[ "$1" =~ ^[0-9]+$ ]]
  then
    ATOMIC_NUMBER=$($PSQL "SELECT atomic_number FROM elements WHERE atomic_number=$1")
  else
    # input is a string, first check if it is symbol
    ATOMIC_NUMBER=$($PSQL "SELECT atomic_number FROM elements WHERE symbol='$1'")
    if [[ -z $ATOMIC_NUMBER ]]
    then
      # it was not a symbol, now try name
      ATOMIC_NUMBER=$($PSQL "SELECT atomic_number FROM elements WHERE name='$1'")
    fi
  fi
  if [[ -z $ATOMIC_NUMBER ]]
  then
    echo "I could not find that element in the database."
  else
    # produce output
    RESULT1=$($PSQL "SELECT symbol,name FROM elements WHERE atomic_number=$ATOMIC_NUMBER")
    IFS="|" read -r SYMBOL NAME <<< "$RESULT1"
    RESULT2=$($PSQL "SELECT atomic_mass, melting_point_celsius, boiling_point_celsius FROM properties WHERE atomic_number=$ATOMIC_NUMBER")
    IFS="|" read -r ATOMIC_MASS MELTING_POINT BOILING_POINT <<< "$RESULT2"
    TYPE=$($PSQL "SELECT type FROM types LEFT JOIN properties USING(type_id) WHERE atomic_number=$ATOMIC_NUMBER;")
    echo -e "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $ATOMIC_MASS amu. $NAME has a melting point of $MELTING_POINT celsius and a boiling point of $BOILING_POINT celsius."
  fi
fi
