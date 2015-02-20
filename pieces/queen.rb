# -*- coding: utf-8 -*-
require_relative 'piece'
require_relative 'slideable'

class Queen < Piece
  include Slideable

  def symbols
    { white: '♕', black: '♛' }
  end

  protected

  def move_dirs
    horizontal_dirs + diagonal_dirs
  end
end
