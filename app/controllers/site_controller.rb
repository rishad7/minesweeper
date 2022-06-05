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
$game_mode = "beginner"
$width = "360px"

class SiteController < ApplicationController

  def index
    
    # Accepting row_id and column_id as get parameters
    if params[:row_id] && params[:column_id]
      if $game_status == 'start'
        row_id = params[:row_id].to_i
        column_id = params[:column_id].to_i

        # Checking the parameters are valid or not. which should be included in our game board
        if row_id.between?(0, $row_count - 1) && column_id.between?(0, $column_count - 1)

          # Storing the time of first click
          if $is_first_click
            $start_time = Time.now.to_i
            $is_first_click = false
          end

          # Counting each clicks
          $click = $click + 1

          # Calculating time in each click
          $timer = Time.now.to_i - $start_time

          # Updating the game board only if the previous click and currrent click are not same
          if session[:previous_row_id] != row_id || session[:previous_column_id] != column_id

            session[:previous_row_id] = row_id
            session[:previous_column_id] = column_id

            update_game_board(row_id, column_id)
          end
        else
          # show error msg
        end
      end
    else
      set_global_variables
      reset_session
      set_game_board
      set_mine_on_game_board
      set_previous_row_column_id
    end
    @game_board = session[:game_board]

    if $game_status == 'won'
      ideal_click = $timer.to_f / 10.to_f
      @high_score = ($click.to_f / ideal_click * 100).round(2)
      @result = Result.new
    end
  end

  def mode
    if params[:type]
      $game_mode = params[:type]
      if $game_mode == 'custom'
        session[:custom_row_count] = 9
        session[:custom_column_count] = 9
        session[:custom_mine_count] = 40
        session[:custom_width] = "360px"
      end
    end
    redirect_to root_url
  end

  def custom
    if params[:height] != '' && params[:width] != '' && params[:mines] != ''

      row_count = params[:height].to_i
      column_count = params[:width].to_i
      mines = params[:mines].to_i

      min_mine_count = (row_count * column_count) / ((row_count + column_count) / 2)
      max_mine_count = (row_count * column_count) / 2

      if mines >= min_mine_count && mines <= max_mine_count
        session[:custom_row_count] = row_count
        session[:custom_column_count] = column_count
        session[:custom_mine_count] = mines
        custom_width = mines * 40
        session[:custom_width] = "#{custom_width}px"
      end
    end
    redirect_to root_url
  end

  private

  # Setting global variables when it comes to home page
  def set_global_variables

    if $game_mode == "beginner"
      $row_count = 9
      $column_count = 9
      $mine_count = 10
      $width = "360px"
    elsif $game_mode == "intermediate"
      $row_count = 16
      $column_count = 16
      $mine_count = 40
      $width = "640px"
    elsif $game_mode == "expert"
      $row_count = 16
      $column_count = 30
      $mine_count = 99
      $width = "1200px"
    elsif $game_mode == "custom"
      $row_count = session[:custom_row_count] ? session[:custom_row_count] : 9
      $column_count = session[:custom_column_count] ? session[:custom_column_count] : 9
      $mine_count = session[:custom_mine_count] ? session[:custom_mine_count] : 40
      $width = session[:custom_width] ? session[:custom_width] : "360px"
    end
    
    $mine_cordinates = []
    $closed_boxes = $row_count * $column_count
    $game_status = "start"
    $timer = 0
    $click = 0
    $start_time = Time.now.to_i
    $is_first_click = true
  end

  # Creating game board with $row_count rows and $column_count columns and assigning an object to each position
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

    # Storing the game board to session
    session[:game_board] = game_board
  end

  # Adding $mine_count number of flags to random positions 
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

  # Finding $mine_count number of cordinates with a recursive function
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

  # Assigning hint numbers adjascent to flags. it will be max 8 positions
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

  # Adding 1 to the corresponding position as hint number
  def set_increment_value(x, y)
    if @game_board[x][y][:content] != 'flag'
      @game_board[x][y][:content] = "number"
      @game_board[x][y][:value] = @game_board[x][y][:value] + 1
    end
  end

  # Assign previous row id and column id as blank
  def set_previous_row_column_id
    session[:previous_row_id] = ""
    session[:previous_column_id] = ""
  end

  # Updating game board when a box clicked
  def update_game_board(row_id, column_id)
    @game_board = session[:game_board]
    @game_board[row_id][column_id][:is_open] = true
    $closed_boxes = $closed_boxes - 1

    # Checking the clicked box contain flag
    if @game_board[row_id][column_id][:content] == "flag"
      
      # If closed boxes are more than mines all flags will be replaced with bomb 
      if $closed_boxes > $mine_count - 1
        @game_board[row_id][column_id][:content] = "bomb_exploded"

        # Removing clicked flag box from mine cordinates
        bomb_cordinates = $mine_cordinates - [[row_id, column_id]]
        replace_flag_with_bomb(bomb_cordinates)

        $game_status = "lose"
      else
        open_all_mines
        $game_status = "won"
      end

    elsif @game_board[row_id][column_id][:content] == ""
      
      # If clicked box is empty, it will open all other blank boxes upto number hints
      open_blank_closed_boxes(row_id, column_id)
      
    else
      
      # If hint number opened, it will check remaining closed boxes. And if it is equal to mines, then you won the game
      if $closed_boxes == $mine_count
        open_all_mines
        $game_status = "won"
      end

    end

    session[:game_board] = @game_board
  end

  # changing is_open to true from false
  def open_blank_closed_boxes(i, j)
  
    adjascent_boxes = get_adjascent_boxes(i, j)

    # Iterating adjascent boxes and find next blank box upto hint number
    adjascent_boxes.each do |ab|
      x = ab[0]
      y = ab[1]
      if !@game_board[x][y][:is_open] && (@game_board[x][y][:content] == '' || @game_board[x][y][:content] == 'number')
        @game_board[x][y][:is_open] = true
        $closed_boxes = $closed_boxes - 1

        if @game_board[x][y][:content] == ''
          # Recursive function to reach upto hint number
          open_blank_closed_boxes(x, y)
        end
        
      end
    end

    return

  end

  # Fetching all adjascent boxes near to [i,j] cordinates. It will be maximum of 8 cordinates.
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

  # If lose the game, all flags will be replaced with bomb
  def replace_flag_with_bomb(bomb_cordinates)
    bomb_cordinates.each do |mc|
      i = mc[0]
      j = mc[1]
      @game_board[i][j][:is_open] = true
      @game_board[i][j][:content] = "bomb"
    end
  end

  # Open all boxes which contains flag
  def open_all_mines
    $mine_cordinates.each do |mc|
      i = mc[0]
      j = mc[1]
      @game_board[i][j][:is_open] = true
    end
  end

end
