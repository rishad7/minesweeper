class SiteController < ApplicationController

  $row_count = 9
  $column_count = 9
  $mine_count = 10
  $mine_cordinates = []
  $closed_boxes = $row_count * $column_count
  $game_status = "start"
  $timer = 0
  $click = 0
  $start_time = Time.now.to_i
  $is_first_click = true

  def index
    if params[:row_id] && params[:column_id]
      if $game_status == 'start'
        row_id = params[:row_id].to_i
        column_id = params[:column_id].to_i

        if row_id.between?(0, $row_count - 1) && column_id.between?(0, $column_count - 1)

          # storing the time of first click
          if $is_first_click
            $start_time = Time.now.to_i
            $is_first_click = false
          end

          # counting clicks
          $click = $click + 1

          # calculating time
          $timer = Time.now.to_i - $start_time

          update_game_board(row_id, column_id)
        else
          # show error msg
        end
      end
    else
      set_global_variables
      reset_session
      set_game_board
      set_mine_on_game_board
      p $mine_cordinates
    end
    @game_board = session[:game_board]

    if $game_status == 'won'
      @high_score = $click * $timer / 100
      @result = Result.new
    end
  end

  private

  def set_global_variables
    $row_count = 9
    $column_count = 9
    $mine_count = 10
    $mine_cordinates = []
    $closed_boxes = $row_count * $column_count
    $game_status = "start"
    $timer = 0
    $click = 0
    $start_time = Time.now.to_i
    $is_first_click = true
  end

  def set_game_board
    game_board = Array.new($row_count){Array.new($column_count)}
    k = 1
    for i in 0..$row_count - 1 do
      for j in 0..$column_count - 1 do
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
    @game_board = session[:game_board]
    @game_board[row_id][column_id][:is_open] = true
    $closed_boxes = $closed_boxes - 1


    if @game_board[row_id][column_id][:content] == "flag"
      
      # count no of closed boxes 
      if $closed_boxes > $mine_count - 1
        @game_board[row_id][column_id][:content] = "bomb_exploded"

        # removing clicked flag box from mine cordinates
        bomb_cordinates = $mine_cordinates - [[row_id, column_id]]
        replace_flag_with_bomb(bomb_cordinates)

        $game_status = "lose"
      else
        open_all_mines
        $game_status = "won"
      end

    elsif @game_board[row_id][column_id][:content] == ""
      
      # open closed boxes
      open_blank_closed_boxes(row_id, column_id)
      

    else
      
      if $closed_boxes == $mine_count
        open_all_mines
        $game_status = "won"
      end

    end

    session[:game_board] = @game_board
  end

  def open_blank_closed_boxes(i, j)
  
    adjascent_boxes = get_adjascent_boxes(i, j)

    adjascent_boxes.each do |ab|
      x = ab[0]
      y = ab[1]
      if !@game_board[x][y][:is_open] && (@game_board[x][y][:content] == '' || @game_board[x][y][:content] == 'number')
        @game_board[x][y][:is_open] = true
        $closed_boxes = $closed_boxes - 1

        if @game_board[x][y][:content] == ''
          # take adjascent
          open_blank_closed_boxes(x, y)
        end

        
      end
    end

    return

  end

  def get_adjascent_boxes(i, j)

    closed_boxes = []
    
    a = i - 1
    if a >= 0
      closed_boxes.push([a, j])

      b = j - 1
      if b >= 0
        closed_boxes.push([a, b])
      end

      c = j + 1
      if c < $column_count
        closed_boxes.push([a, c])
      end
    end

    d = j - 1
    if d >= 0
      closed_boxes.push([i, d])
    end

    e = j + 1
    if e < $column_count
      closed_boxes.push([i, e])
    end

    f = i + 1
    if f < $row_count
      closed_boxes.push([f, j])

      b = j - 1
      if b >= 0
        closed_boxes.push([f, b])
      end

      c = j + 1
      if c < $column_count
        closed_boxes.push([f, c])
      end
    end

    return closed_boxes

  end

  def replace_flag_with_bomb(bomb_cordinates)
    bomb_cordinates.each do |mc|
      i = mc[0]
      j = mc[1]
      @game_board[i][j][:is_open] = true
      @game_board[i][j][:content] = "bomb"
    end
  end

  def open_all_mines
    $mine_cordinates.each do |mc|
      i = mc[0]
      j = mc[1]
      @game_board[i][j][:is_open] = true
    end
  end

end
