#! /bin/bash
PSQL="psql --username=freecodecamp --dbname=periodic_table --no-align --tuples-only -c"

NOT_IN_DB() {
  echo "I could not find that element in the database."
}

IN_DB() {
  echo $($PSQL "SELECT name, symbol, type, atomic_mass, melting_point_celsius, boiling_point_celsius FROM elements INNER JOIN properties USING(atomic_number) INNER JOIN types USING(type_id) WHERE atomic_number=$ATOMIC_NUMBER") | while IFS='|' read NAME SYMBOL TYPE ATOMIC_MASS MELTING_POINT BOILING_POINT
  do
    echo "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $ATOMIC_MASS amu. $NAME has a melting point of $MELTING_POINT celsius and a boiling point of $BOILING_POINT celsius."
  done
}

ELEMENT() {
  if [[ $1 ]]
  then
    if [[ $1 =~ ^[0-9]+$ ]]
    then
      #check if it is a known atomic number
      ATOMIC_NUMBER=$1
      SYMBOL=$($PSQL "SELECT symbol FROM elements WHERE atomic_number=$ATOMIC_NUMBER")
      if [[ -z $SYMBOL ]]
      then
        NOT_IN_DB
      else
        IN_DB $ATOMIC_NUMBER
      fi
    else
      #check if it is a symbol
      SYMBOL=$1
      ATOMIC_NUMBER=$($PSQL "SELECT atomic_number FROM elements WHERE symbol='$SYMBOL'")
      if [[ -z $ATOMIC_NUMBER ]]
      then
        #if it is not a symbol, check if it is a name
        NAME=$1
        ATOMIC_NUMBER=$($PSQL "SELECT atomic_number FROM elements WHERE name='$NAME'")
        if [[ -z $ATOMIC_NUMBER ]]
        then
          NOT_IN_DB
        else
          IN_DB $ATOMIC_NUMBER
        fi
      else
        IN_DB $ATOMIC_NUMBER
      fi
    fi
  else
    echo "Please provide an element as an argument."
  fi
}

ELEMENT $1