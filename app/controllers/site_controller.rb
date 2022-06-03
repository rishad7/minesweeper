class SiteController < ApplicationController

  $row_count = 9
  $column_count = 9
  $mine_cordinates = [[0,3], [0,4], [1,8], [2,7], [2,8], [5,0], [6,0], [7,2], [8,5], [8,7]]

  def index
    if params[:row_id] && params[:column_id]
      update_game_board(params[:row_id].to_i, params[:column_id].to_i)
    else
      set_game_board
      set_mine_on_game_board
    end
    @game_board = session[:game_board]
  end

  private

  def set_game_board
    game_board = Array.new($row_count){Array.new($column_count)}
    k = 1
    0.upto(game_board.length-1) do |i|
      0.upto(game_board.length-1) do |j|
        obj = {
          id: k,
          is_open: false,
          content: "",
        }
        game_board[i][j] = obj
        k = k + 1
      end
    end
    session[:game_board] = game_board
  end

  def set_mine_on_game_board
    game_board = session[:game_board]
    $mine_cordinates.each do |mc|
      i = mc[0]
      j = mc[1]
      game_board[i][j][:content] = "flag"
    end
    session[:game_board] = game_board;
  end

  def update_game_board(row_id, column_id)
    game_board = session[:game_board]
    game_board[row_id][column_id][:is_open] = true
    session[:game_board] = game_board
  end
end
