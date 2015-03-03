class Piece
  attr_reader :board, :color
  attr_accessor :pos, :prev_pos, :moved_during_match

  def initialize(color, board, pos)
    raise 'invalid color' unless [:white, :black].include?(color)
    raise 'invalid pos' unless board.valid_pos?(pos)

    @color, @board, @pos, @prev_pos, @moved_during_match = color, board, pos, nil, nil

    board.add_piece(self, pos)
  end

  def symbols
    # subclass implements this with unicode chess char
    # i.e. bishop's symbols method returns '♝' for black
    raise NotImplementedError
  end

  def render
    symbols[color]
  end

  def valid_moves
    moves.select { |to_pos| !move_into_check?(to_pos) }
  end

  private

  def move_into_check?(to_pos)
    dupped_board = board.dup
    dupped_board.move_piece!(pos, to_pos)
    dupped_board.in_check?(color)
  end
end
