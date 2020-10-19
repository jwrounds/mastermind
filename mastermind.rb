module CodeComparisons

  def check_black code, guess
    cache = {number: 0, number_and_space: 0}
    code.each_index do |i|
      if code[i]
        if code[i] == guess[i]
          cache[:number_and_space] += 1
          code.delete_at(i)
          code.insert(i, nil)
          guess.delete_at(i)
          guess.insert(i, nil)
        end
      end
    end
    cache
  end

  def check_white code, guess, cache
    code.each_with_index do |code_number, i|
      guess.each_with_index do |guess_number, j|
        if code[i] && guess[j]
          if code[i] == guess[j]
            cache[:number] += 1
            code.delete_at(i)
            code.insert(i, nil)
            guess.delete_at(j)
            guess.insert(j, nil)
          end
        end
      end
    end
    cache
  end
  
  def compare_codes code, guess
    cache = self.check_black code, guess
    self.check_white code, guess, cache
  end

end

class Board
  attr_accessor :turn, :key_pegs, :game_board, :key_cache

  def initialize 
    @game_board = []
    @key_pegs = []
    @key_cache = nil
  end

  def display 
    display = "[*, *, *, *] \n"
    self.game_board.each_with_index do |row, i|
      display += "[#{row.join('--')}] [#{self.key_pegs[i]}]\n"
    end
    puts display
  end
end

class Player
  attr_accessor :guess, :codemaker

  def initialize codemaker
    @codemaker = codemaker
    @guess = []
  end

  def make_guess board
    puts (  
      " \n> Guess the sequence by entering a combination of four numbers: \n ")
    new_guess = gets.chomp
    if new_guess.upcase == "RULES"
      return "RULES"
    else
      self.guess = new_guess.split""
      board.game_board.push self.guess
      new_guess.split""
    end
  end

  def generate_code
    puts (
      " \n> Please enter a four digit code using numbers from 1 to 6 (repeating numbers are okay):\n ")
    gets.chomp.split""
  end
end

class ComputerPlayer
  attr_reader :code, :codemaker
  attr_accessor :set

  include CodeComparisons

  def initialize codemaker
    @codemaker = codemaker
    if codemaker
      @code = self.generate_code     
    else
      @set = self.generate_set
    end 
  end

  def generate_code 
    random_code = []
    4.times do
      number = (rand 6) + 1
      random_code.push number.to_s
    end
    random_code
  end

  def generate_set
    set = []
    (1111..6666).each do |num|
      unless /[7890]/.match?(num.to_s)
        set.push num.to_s.split""
      end
    end
    set
  end

  def reduce_set white, black, pseudocode
    self.set.each_with_index do |num, i|
      code_copy = []
      pseudocode.each {|e| code_copy << e}
      num_copy = []
      num.each {|e| num_copy << e}
      cache = self.compare_codes code_copy, num_copy
      unless cache[:number] == white && cache[:number_and_space] == black
        self.set.delete_at(i)
      end
    end
    
    p self.set.length
    new_guess = self.set.sample
    return new_guess
  end

  def crack_code board, turn
    if turn == 1
      guess = ["1", "1", "2", "2"]
      board.game_board.push guess
      return guess
    end
    black = board.key_cache[:number_and_space]
    white = board.key_cache[:number]
    last_guess = board.game_board.last
    new_guess = self.reduce_set white, black, last_guess
    board.game_board.push new_guess
    new_guess
  end
end

class Game
  attr_reader :numbers
  attr_accessor :turn, :code_cracked

  include CodeComparisons

  def initialize 
    @numbers = [1, 2, 3, 4, 5, 6]
    @turn = 1
    @code_cracked = false
  end

  def explain_rules
    puts (
      " \n> You will have 10 turns to guess a random number sequence chosen by the computer. Numbers can repeat. The available numbers are 1, 2, 3, 4, 5, 6, and each turn you will receive a white token for each matching number in the sequence. A black peg represents maching number and position.\n\n> If there are repeating numbers in the sequence (1112) and your guess contains one of the correct numbers out of sequence (ex. 2334), you will receive only one white peg as feedback for that correctly guessed number. Likewise with a black peg if you guess one number out of miltiple repeats in the correct sequence (5416). Type 'rules' to see this statement again.\n "
      ) 
  end

  def check_guess code, guess, board
    code_copy = []
    code.each {|num| code_copy << num}
    guess_copy = []
    guess.each {|num| guess_copy << num}
    cache = self.compare_codes code_copy, guess_copy
    
    pegs = []
    cache[:number_and_space].times {pegs.push "B"}
    cache[:number].times {pegs.push "W"}
    board.key_pegs.push pegs
    board.key_cache = cache

    if cache[:number_and_space] == 4
      self.code_cracked = true
      puts "\n> Code cracked! Game over!" 
    end
    
  end

  def run_player_turn player, code, board
      p code
      board.display
      guess = player.make_guess board

      if guess == "RULES"
        self.explain_rules
      else
        self.check_guess code, guess, board
      end
  end

  def run_computer_turn computer, code, board
    until self.turn > 10 || self.code_cracked
      guess = computer.crack_code board, self.turn
      self.check_guess code, guess, board
      board.display
      self.turn += 1

    end
  end

end
   

game = Game.new
board = Board.new

#game.compare_codes(["1", "2", "1", "3"], ["1", "1", "2", "2"])


puts "> Will you make the code, or break the code?\n "
response = gets.chomp.upcase
if response == "MAKE" || response == "CODEMAKER" || response == "MAKER"
  puts " \n> You are the codemaker. The computer will break your code.\n "
  player = Player.new true
  computer = ComputerPlayer.new false
  player_code = player.generate_code
  #until game.code_cracked
    game.run_computer_turn computer, player_code, board
  #end
else
  puts " \n> You are the codebreaker. You will break the computer's code.\n "
  game.explain_rules 
  computer = ComputerPlayer.new true
  player = Player.new false
  until game.code_cracked
    game.run_player_turn player, computer.code, board
  end
end
