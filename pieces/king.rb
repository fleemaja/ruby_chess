# -*- coding: utf-8 -*-
require_relative 'piece'
require_relative 'stepable'

class King < Piece
  include Stepable

  def symbols
    { white: '♔', black: '♚' }
  end

  protected

  def move_diffs
    [[-1, -1],
     [-1, 0],
     [-1, 1],
     [0, -1],
     [0, 1],
     [1, -1],
     [1, 0],
     [1, 1]]
  end
end
