class ResultsController < ApplicationController

  before_action :set_result, only: %i[ show ]

  def show
    @results = Result.all.order("high_score DESC")
  end

  def create
    @result = Result.new(result_params)

    respond_to do |format|
      if @result.save
        format.html { redirect_to result_url(@result), notice: "Your result successfully saved." }
        format.json { render :show, status: :created, location: @result }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @result.errors, status: :unprocessable_entity }
      end
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
