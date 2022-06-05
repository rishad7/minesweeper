class ResultsController < ApplicationController

  before_action :set_result, only: %i[ show view_game_board ]

  def index
    @results = Result.all.order("high_score DESC")
  end

  def show
    @results = Result.all.order("high_score DESC").limit(10)
  end

  def create
    @result = Result.new(result_params)

    respond_to do |format|
      if @result.save
        format.html { redirect_to result_url(@result), notice: "Your result successfully saved." }
      else
        format.html { redirect_to root_url }
      end
    end
  end

  def view_game_board
    if @result.game_board != ''
      @game_board = JSON.parse(@result.game_board)
      width = @game_board.length * 40
      @width = "#{width}px"
    else
      redirect_to root_url
    end
  end

  private

    def set_result
      @result = Result.find(params[:id])
    end

    def result_params
      params.require(:result).permit(:name, :clicks, :time_taken, :game_board, :high_score)
    end

end
