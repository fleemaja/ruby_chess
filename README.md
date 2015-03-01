# Ruby OOP Chess
Chess game that is 100% Ruby and played in the terminal.

Leverages class inheritance to DRY code by dividing move logic into stepping and sliding pieces.

Validates whether a player is in check without modifying the game state by calling a deep duplicate of the board.

##Screen Shot

![Screen Shot](https://raw.githubusercontent.com/fleemaja/ruby_chess/master/images/chess.png)

##To Play:

Download the zip of the full project, navigate to the project directory, and type:

    ruby game.rb

to play.

Please note Ruby Chess relies on the colorize gem in order to work. Ensure this gem is installed before running.

to install the colorize gem:
    gem install colorize
