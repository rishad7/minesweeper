require "test_helper"

class ResultTest < ActiveSupport::TestCase
  test 'valid name' do
    result = Result.new(name: 'Rishad', clicks: 7, time_taken: 100, game_board: "", high_score: 77.7)
    assert result.valid?
  end

  test 'invalid without name' do
    result = Result.new(clicks: 7, time_taken: 100, game_board: "", high_score: 77.7)
    refute result.valid?, 'result is valid without a name'
    assert_not_nil result.errors[:name], 'no validation error for name present'
  end
end
