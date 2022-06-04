class SiteController < ApplicationController

  $row_count = 9
  $column_count = 9
  $mine_count = 10
  $mine_cordinates = []

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
          value: 0,
        }
        game_board[i][j] = obj
        k = k + 1
      end
    end
    session[:game_board] = game_board
  end

  def set_mine_on_game_board
    @game_board = session[:game_board]
    set_mine_coordinates(1)
    $mine_cordinates.each do |mc|
      i = mc[0]
      j = mc[1]
      @game_board[i][j][:content] = "flag"
      set_count(i,j)
    end
    session[:game_board] = @game_board;
  end

  def set_mine_coordinates(i)

    if i > $mine_count
      return
    end
    
    single_mine = [*0..$row_count - 1].sample(2)
    if $mine_cordinates.include?(single_mine)
      set_mine_coordinates(i)
    else
      $mine_cordinates.push(single_mine)
      set_mine_coordinates(i + 1)
    end

  end

  def set_count(i, j)
    
    a = i - 1
    if a >= 0
      set_increment_value(a, j)

      b = j - 1
      if b >= 0
        set_increment_value(a, b)
      end

      c = j + 1
      if c < $column_count
        set_increment_value(a, c)
      end
    end

    d = j - 1
    if d >= 0
      set_increment_value(i, d)
    end

    e = j + 1
    if e < $column_count
      set_increment_value(i, e)
    end

    f = i + 1
    if f < $row_count
      set_increment_value(f, j)

      b = j - 1
      if b >= 0
        set_increment_value(f, b)
      end

      c = j + 1
      if c < $column_count
        set_increment_value(f, c)
      end
    end
    
  end

  def set_increment_value(x, y)
    if @game_board[x][y][:content] != 'flag'
      @game_board[x][y][:content] = "number"
      @game_board[x][y][:value] = @game_board[x][y][:value] + 1
    end
  end

  def update_game_board(row_id, column_id)
    game_board = session[:game_board]
    game_board[row_id][column_id][:is_open] = true
    session[:game_board] = game_board
  end
end
