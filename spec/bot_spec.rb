require_relative '../bin/botclient'


class Msg
  attr_accessor :text
  def initialize(text)
    @text = text
  end
end

class Weather
  attr_accessor :temperature
  def initialize(temperature)
    @temperature = temperature
  end
end

RSpec.describe Botclient do
  let(:botclient) { Botclient.new('1109360723:AAHam4xsAf-7wgF8Hjt6ACbxxOH66cimbaM', 'a71219e79a6b01978ac3a9f3ffccca37', false)}
  describe 'tests method celsius_weather' do
    it 'test when param is nil' do
      expect(botclient.chatbot.celsius_weather(nil)).to eql(nil)
    end
    it 'test when passed a valid parameter' do
      expect(botclient.chatbot.celsius_weather(Weather.new(293.15))).to eql("20.0°C")
    end
    it 'test when passed a valid parameter and format is F' do
      botclient.chatbot.chosen_format='F'
      expect(botclient.chatbot.celsius_weather(Weather.new(293.15))).to eql("68.0°F")
    end
    it 'test when passed a valid parameter and format is K' do
      botclient.chatbot.chosen_format='K'
      expect(botclient.chatbot.celsius_weather(Weather.new(293.15))).to eql("293.15°K")
    end
  end
  describe 'tests method give_bot_message' do
    it 'test when param temperature is nil' do
      expect(botclient.chatbot.give_bot_message(nil, "bogotá", "invalid data"){|x,y| "temperature in #{x} is #{y}"}).to eql("invalid data")
    end
    it 'test when param temperature is valid' do
      expect(botclient.chatbot.give_bot_message("16°C", "bogotá", "invalid data"){|x,y| "temperature in #{x} is #{y}"}).to eql("temperature in bogotá is 16°C")
    end
  end
  # it 'test update_after_move when input -5 as move' do
  #   match.players = [Player.new('Oscar', 'x'), Player.new('Ángel', '0')]
  #   expect { match.update_after_move(-5) }.to output("please choose a valid spot\n").to_stdout
  # end
  # it 'test update_after_move when input abc as move' do
  #   match.players = [Player.new('Oscar', 'x'), Player.new('Ángel', '0')]
  #   expect { match.update_after_move('abc') }.to output("please choose a valid spot\n").to_stdout
  # end
  # it 'test update_after_move when input 11 as move' do
  #   match.players = [Player.new('Oscar', 'x'), Player.new('Ángel', '0')]
  #   expect { match.update_after_move(11) }.to output("please choose a valid spot\n").to_stdout
  # end
  # it 'test update_after_move when move is valid and then in a not available spot' do
  #   match.players = [Player.new('Oscar', 'x'), Player.new('Ángel', '0')]
  #   match.movements[4] = 'x'
  #   expect { match.update_after_move(5) }.to output("not available spot\n").to_stdout
  # end
  # it 'test show_board after valid movement' do
  #   match.players = [Player.new('Oscar', 'x'), Player.new('Ángel', '0')]
  #   match.movements = %w[x 0 x 4 5 6 7 8 9]
  #   match.update_board
  #   expect { match.show_board }.to output(" x | 0 | x \n---|---|---\n 4 | 5 | 6 \n---|---|---\n 7 | 8 | 9 \n").to_stdout
  # end
  # it 'test update_board' do
  #   match.players = [Player.new('Oscar', 'x'), Player.new('Ángel', '0')]
  #   match.movements = %w[1 2 3 x 0 x 7 8 9]
  #   match.update_board
  #   row1 = [' x ', '|', ' 2 ', '|', ' 3 ']
  #   mrow = ['---', '|', '---', '|', '---']
  #   row2 = [' x ', '|', ' 0 ', '|', ' x ']
  #   row3 = [' 7 ', '|', ' 8 ', '|', ' 9 ']
  #   arr = [row1, mrow, row2, mrow, row3]
  #   expect(match.board).not_to eql(arr)
  # end
  # it 'test find_winner when there is no winner yet' do
  #   match.players = [Player.new('Oscar', 'x'), Player.new('Ángel', '0')]
  #   match.movements = %w[1 2 3 x 0 x 7 8 9]
  #   match.turn = 2
  #   expect { match.find_winner(6) }.to output('').to_stdout
  # end
  # it 'test find_winner when a winner after first player connects three in a diagonal' do
  #   match.players = [Player.new('Oscar', 'x'), Player.new('Ángel', '0')]
  #   match.movements = %w[x 0 x 0 x 0 x 8 9]
  #   match.update_board
  #   match.turn = 6
  #   output = " x | 0 | x \n---|---|---\n 0 | x | 0 \n---|---|---\n x | 8 | 9 \nOscar is the winner\n"
  #   expect { match.find_winner(7) }.to output(output).to_stdout
  # end
  # it 'test find_winner when a winner after first player connects three in the same column' do
  #   match.players = [Player.new('Oscar', 'x'), Player.new('Ángel', '0')]
  #   match.movements = %w[x 0 3 x 0 6 x 8 9]
  #   match.update_board
  #   match.turn = 4
  #   output = " x | 0 | 3 \n---|---|---\n x | 0 | 6 \n---|---|---\n x | 8 | 9 \nOscar is the winner\n"
  #   expect { match.find_winner(7) }.to output(output).to_stdout
  # end
  # it 'test find_winner when a winner after second player connects three in the same row' do
  #   match.players = [Player.new('Oscar', 'x'), Player.new('Ángel', '0')]
  #   match.movements = %w[0 0 0 x x 6 x 8 9]
  #   match.update_board
  #   match.turn = 5
  #   output = " 0 | 0 | 0 \n---|---|---\n x | x | 6 \n---|---|---\n x | 8 | 9 \nÁngel is the winner\n"
  #   expect { match.find_winner(3) }.to output(output).to_stdout
  # end
  # it 'test find_winner when a winner after 9 movements and no winner' do
  #   match.players = [Player.new('Oscar', 'x'), Player.new('Ángel', '0')]
  #   match.movements = %w[0 0 x x 0 0 x x 0]
  #   match.update_board
  #   match.turn = 8
  #   expect { match.find_winner(8) }.to output('').to_stdout
  # end
  # it 'test winner_conditions when there is no winner yet' do
  #   match.players = [Player.new('Oscar', 'x'), Player.new('Ángel', '0')]
  #   match.movements = %w[1 2 3 x 0 x 7 8 9]
  #   match.turn = 2
  #   expect { match.winner_conditions(6, 2, 'xxx') }.to output('').to_stdout
  # end
  # it 'test winner_conditions when a winner after first player connects three in a diagonal' do
  #   match.players = [Player.new('Oscar', 'x'), Player.new('Ángel', '0')]
  #   match.movements = %w[x 0 x 0 x 0 x 8 9]
  #   match.update_board
  #   match.turn = 6
  #   output = " x | 0 | x \n---|---|---\n 0 | x | 0 \n---|---|---\n x | 8 | 9 \nOscar is the winner\n"
  #   expect { match.winner_conditions(9, 0, 'xxx') }.to output(output).to_stdout
  # end
  # it 'test winner_conditions when a winner after first player connects three in the same column' do
  #   match.players = [Player.new('Oscar', 'x'), Player.new('Ángel', '0')]
  #   match.movements = %w[x 0 3 x 0 6 x 8 9]
  #   match.update_board
  #   match.turn = 4
  #   output = " x | 0 | 3 \n---|---|---\n x | 0 | 6 \n---|---|---\n x | 8 | 9 \nOscar is the winner\n"
  #   expect { match.winner_conditions(9, 0, 'xxx') }.to output(output).to_stdout
  # end
  # it 'test winner_conditions when a winner after second player connects three in the same row' do
  #   match.players = [Player.new('Oscar', 'x'), Player.new('Ángel', '0')]
  #   match.movements = %w[0 0 0 x x 6 x 8 9]
  #   match.update_board
  #   match.turn = 5
  #   output = " 0 | 0 | 0 \n---|---|---\n x | x | 6 \n---|---|---\n x | 8 | 9 \nÁngel is the winner\n"
  #   expect { match.winner_conditions(3, 2, '000') }.to output(output).to_stdout
  # end
  # it 'test winner_conditions when a winner after 9 movements and no winner' do
  #   match.players = [Player.new('Oscar', 'x'), Player.new('Ángel', '0')]
  #   match.movements = %w[0 0 x x 0 0 x x 0]
  #   match.update_board
  #   match.turn = 8
  #   expect { match.winner_conditions(9, 1, 'xxx') }.to output('').to_stdout
  # end
  # it 'test continue_conditions when game_continue is true and turn is less than 9' do
  #   match.players = [Player.new('Oscar', 'x'), Player.new('Ángel', '0')]
  #   match.turn = 1
  #   expect(match.continue_conditions).to eql(true)
  # end
  # it 'test continue_conditions when game_continue is true and turn is less than 9' do
  #   match.players = [Player.new('Oscar', 'x'), Player.new('Ángel', '0')]
  #   match.game_continue = false
  #   match.turn = 5
  #   expect(match.continue_conditions).not_to eql(true)
  # end
  # it 'test continue_conditions when game_continue is true and turn is 9' do
  #   match.players = [Player.new('Oscar', 'x'), Player.new('Ángel', '0')]
  #   match.turn = 9
  #   expect(match.continue_conditions).to eql(false)
  # end
  # it 'test draw_conditions when game_continue is true and turn is less than 9' do
  #   match.players = [Player.new('Oscar', 'x'), Player.new('Ángel', '0')]
  #   match.turn = 1
  #   match.movements = %w[x 2 3 4 5 6 7 8 9]
  #   match.update_board
  #   expect { match.draw_condition }.to output('').to_stdout
  # end
  # it 'test draw_conditions when game_continue is true and turn is less than 9' do
  #   match.players = [Player.new('Oscar', 'x'), Player.new('Ángel', '0')]
  #   match.game_continue = false
  #   match.turn = 5
  #   match.movements = %w[x 0 0 0 x 6 7 8 9]
  #   match.update_board
  #   expect { match.draw_condition }.to output('').to_stdout
  # end
  # it 'test draw_conditions when game_continue is true and turn is 9' do
  #   match.players = [Player.new('Oscar', 'x'), Player.new('Ángel', '0')]
  #   match.turn = 9
  #   match.movements = %w[x 0 0 0 x x x x 0]
  #   match.update_board
  #   output = " x | 0 | 0 \n---|---|---\n 0 | x | x \n---|---|---\n x | x | 0 \nGame was a draw\n"
  #   expect { match.draw_condition }.to output(output).to_stdout
  # end
  # it 'test play_new_game method when choose 1' do
  #   expect { match.play_new_game('1') }.to output("great! let's play again\n").to_stdout
  # end
  # it 'test play_new_game method when choose 2' do
  #   expect { match.play_new_game('2') }.to output("thank you for playing with us\n").to_stdout
  # end
  # it 'test play_new_game method when choose abc' do
  #   expect { match.play_new_game('abc') }.to output("choose a valid option\n").to_stdout
  # end
end
