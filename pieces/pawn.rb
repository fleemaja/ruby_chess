# -*- coding: utf-8 -*-
require_relative 'piece'

class Pawn < Piece
  def symbols
    { white: '♙', black: '♟' }
  end

  def moves
    forward_steps + side_attacks
  end

  private

  def at_start_row?
    pos[0] == ((color == :white) ? 6 : 1)
  end

  def forward_direction
    (color == :white) ? -1 : 1
  end

  def forward_steps
    i, j = pos
    one_step = [i + forward_direction, j]
    return [] unless board.valid_pos?(one_step) && board.empty?(one_step)

    steps = [one_step]
    two_step = [i + 2 * forward_direction, j]
    steps << two_step if at_start_row? && board.empty?(two_step)
    steps
  end

  def side_attacks
    i, j = pos

    side_moves = [[i + forward_direction, j - 1], [i + forward_direction, j + 1]]

    side_moves.select do |new_pos|
      if board.valid_pos?(new_pos)

        piece_under_threat = board[new_pos]
        piece_under_threat && piece_under_threat.color != color
      end
    end
  end
end
