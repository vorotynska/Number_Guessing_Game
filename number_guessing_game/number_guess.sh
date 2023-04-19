#! /bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

PLAY() {
  echo "Enter your username:"
  read USERNAME

  USER_ID=$($PSQL "SELECT user_id from users WHERE username = '$USERNAME'")

  if [[ $USER_ID ]];
  then
  
    GAMES_PLAYED=$($PSQL "SELECT count(user_id) FROM games WHERE user_id = '$USER_ID'")

    BEST_GUESS=$($PSQL "select min(guesses) FROM games WHERE user_id = '$USER_ID'")

    echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GUESS guesses."
  else
    echo "Welcome, $USERNAME! It looks like this is your first time here."

    INSERTED_TO_USERS=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME')")
    USER_ID=$($PSQL "SELECT user_id FROM users WHERE username = '$USERNAME'")
    
  fi

  GAME
}

GAME() {
  
  SECRET=$((1 + $RANDOM % 1000))

  #count guesses
  NUMBER_OF_GUESSES=0

  #guess number
  # echo $SECRET
  GUESSED=0
  echo "Guess the secret number between 1 and 1000:"
  
  while [[ $GUESSED = 0 ]]; 
  do
    read GUESS

    #if not a number
    if [[ ! $GUESS =~ ^[0-9]+$ ]]; then
      echo "That is not an integer, guess again:"
    #if correct guess
    elif [[ $SECRET = $GUESS ]];
     then
      NUMBER_OF_GUESSES=$(($NUMBER_OF_GUESSES + 1))
      echo "You guessed it in $NUMBER_OF_GUESSES tries. The secret number was $SECRET. Nice job!"
      #insert into db
      INSERTED_TO_GAMES=$($PSQL "INSERT INTO games(user_id, guesses) values($USER_ID, $NUMBER_OF_GUESSES)")
      GUESSED=1
    #if greater
    elif [[ $SECRET -gt $GUESS ]]; then
      NUMBER_OF_GUESSES=$(($NUMBER_OF_GUESSES + 1))
      echo "It's higher than that, guess again:"
    #if smaller
    else
      NUMBER_OF_GUESSES=$(($NUMBER_OF_GUESSES + 1))
      echo "It's lower than that, guess again:"
    fi
  done

}

PLAY    