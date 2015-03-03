require_relative 'pieces'
require 'colorize'

# Make special string classes for turning background grey or red on board
class String
  def bg_grey
    "\033[47m#{self}\033[0m"
  end

  def bg_red
    "\033[41m#{self}\033[0m"
  end
end

class Board
  def initialize(fill_board = true)
    start_grid(fill_board)
  end

  def [](pos)
    raise 'invalid pos' unless valid_pos?(pos)

    i, j = pos
    @rows[i][j]
  end

  def []=(pos, piece)
    raise 'invalid position' unless valid_pos?(pos)

    i, j = pos
    @rows[i][j] = piece
  end

  def add_piece(piece, pos)
    raise 'position already occupied' unless empty?(pos)

    self[pos] = piece
  end

  def checkmate?(color)
    return false unless in_check?(color)

    filtered_pieces = pieces.select { |p| p.color == color }
    filtered_pieces.all? { |piece| piece.valid_moves.empty? }
  end

  def dup
    new_board = Board.new(false)

    pieces.each do |piece|
      piece.class.new(piece.color, new_board, piece.pos)
    end

    new_board
  end

  def empty?(pos)
    self[pos].nil?
  end

  def in_check?(color)
    king_pos = find_king(color).pos

    pieces.any? do |p|
      p.color != color && p.moves.include?(king_pos)
    end
  end

  def move_piece(turn_color, from_pos, to_pos)
    raise 'no piece at the from position' if empty?(from_pos)

    piece = self[from_pos]
    if piece.color != turn_color
      raise "you cannot move your opponent's piece"
    end

    return if handle_special_moves(from_pos, to_pos)


    if !piece.valid_moves.include?(to_pos)
      raise 'cannot move into check'
    elsif !piece.moves.include?(to_pos)
      raise 'piece cannot move like that'
    end

    move_piece!(from_pos, to_pos)
  end

  # move without performing checks
  def move_piece!(from_pos, to_pos)
    piece = self[from_pos]
    raise 'piece cannot move like that' unless piece.moves.include?(to_pos)

    piece.prev_pos = from_pos
    piece.moved_during_match ||= true

    self[to_pos] = piece
    self[from_pos] = nil
    piece.pos = to_pos

    nil
  end

  def pieces
    @rows.flatten.compact
  end

  def render
    puts '   0  1  2  3  4  5  6  7'
    @rows.each_with_index do |row, i|
      print "#{i} "
      row.each_with_index do |element, i2|
        join_line(element, i, i2)
      end
      puts " #{i}"
    end
    puts '   0  1  2  3  4  5  6  7'
  end

  def join_line(element, i, i2)
    if element.nil?
      if (i + i2).even?
        print '   '.bg_red
      else
        print '   '.bg_grey
      end
    else
      if (i + i2).even?
        print " #{element.render} ".bg_red
      else
        print " #{element.render} ".bg_grey
      end
    end
  end

  def valid_pos?(pos)
    pos.all? { |coord| coord.between?(0, 7) }
  end

  protected

  def fill_back_row(color)
    back_pieces = [
      Rook, Knight, Bishop, Queen, King, Bishop, Knight, Rook
    ]

    i = (color == :white) ? 7 : 0
    back_pieces.each_with_index do |piece_class, j|
      piece_class.new(color, self, [i, j])
    end
  end

  def fill_pawns_row(color)
    i = (color == :white) ? 6 : 1
    8.times { |j| Pawn.new(color, self, [i, j]) }
  end

  def find_king(color)
    king_pos = pieces.find { |p| p.color == color && p.is_a?(King) }
    king_pos || (raise 'king not found?')
  end

  def start_grid(fill_board)
    @rows = Array.new(8) { Array.new(8) }
    return unless fill_board
    [:white, :black].each do |color|
      fill_back_row(color)
      fill_pawns_row(color)
    end
  end

  def perform_move(from_pos, to_pos, available_moves, piece)
    return false unless available_moves.include?(to_pos)

    self[to_pos] = piece
    self[from_pos] = nil

    piece.moved_during_match ||= true
    piece.pos = to_pos
    piece.prev_pos = from_pos
    true
  end

  def handle_special_moves(from_pos, to_pos)
    if castle_possible?(from_pos, to_pos)
      castle(from_pos, to_pos)
      return true
    end

    if en_passant_possible?(from_pos, to_pos)
      en_passant(from_pos, to_pos)
      return true
    end

    false
  end

  def castle(from_pos, to_pos)
    direction = (to_pos[1] > 3) ? [6, 5] : [1, 2]
    e_row, e_col = to_pos
    perform_move(from_pos, [e_row, direction[0]], [[e_row, direction[0]]], self[from_pos]) #King
    perform_move(to_pos, [e_row, direction[1]], [[e_row, direction[1]]], self[to_pos]) #Rook

    nil
  end

  def castle_possible?(from_pos, to_pos)
    from_piece = self[from_pos]
    to_piece = self[to_pos]

    return false unless from_piece.is_a?(King) && to_piece.is_a?(Rook)
    return false if from_piece.moved_during_match || to_piece.moved_during_match
    col_between = ((from_pos[1] + 1)...to_pos[1]).to_a
    positions = col_between.map { |col| [from_pos[0], col] }
    return false unless positions.all? { |pos| self[pos].nil? }

    true
  end

  def en_passant(from_pos, to_pos)
    e_row, e_col = to_pos
    direction = self[from_pos].color == :white ? -1 : 1

    perform_move(from_pos, [e_row + direction, e_col], [[e_row + direction, e_col]], self[from_pos])
    self[to_pos] = nil

    nil
  end

  def en_passant_possible?(from_pos, to_pos)
    from_piece = self[from_pos]
    to_piece = self[to_pos]

    s_row, s_col = from_pos
    e_row, e_col = to_pos

    direction = self[from_pos].color == :white ? -1 : 1

    return false unless from_piece.is_a?(Pawn) && to_piece.is_a?(Pawn)
    return false unless from_piece.color != to_piece.color
    return false unless s_row == e_row
    return false unless (e_col - s_col).abs == 1
    return false unless (to_piece.prev_pos[0] - to_piece.pos[0]).abs == 2
    return false unless self[[e_row + direction, e_col]].nil?

    true
  end
end
