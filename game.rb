require_relative 'board'

class Game
  attr_reader :board, :current_player, :players

  def initialize
    @board = Board.new
    @players = {
      white: HumanPlayer.new(:white),
      black: HumanPlayer.new(:black)
    }
    @current_player = :white
  end

  def play
    until board.checkmate?(current_player)
      players[current_player].play_turn(board)
      @current_player = (current_player == :white) ? :black : :white
    end

    puts board.render
    puts "#{current_player} is checkmated."

    nil
  end
end

class HumanPlayer
  attr_reader :color

  def initialize(color)
    @color = color
  end

  def play_turn(board)
    puts board.render
    puts "Current player: #{color}"

    from_pos = get_pos('Which piece do you want to move? Separate row and column with a space')
    to_pos = get_pos('Where do you want to move to? Separate row and column with a space')
    board.move_piece(color, from_pos, to_pos)
  rescue StandardError => e
    puts "Error: #{e.message}"
    retry
  end

  private

  def get_pos(prompt)
    puts prompt
    gets.chomp.split(' ').map { |coord_s| Integer(coord_s) }
  end
end

g = Game.new()
g.play
