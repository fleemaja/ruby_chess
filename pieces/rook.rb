# -*- coding: utf-8 -*-
require_relative 'piece'
require_relative 'slideable'

class Rook < Piece
  include Slideable

  def symbols
    { white: '♖', black: '♜' }
  end

  protected

  def move_dirs
    horizontal_dirs
  end
end
