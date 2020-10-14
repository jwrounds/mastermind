class Board
  attr_accessor :turn, :key_pegs, :game_board

  def initialize 
    @key_pegs = []
    @game_board = []
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
  attr_accessor :guess

  def initialize
    @guess = []
  end

  def make_guess board
    puts (  
      " \nGuess the sequence by entering a combination of four numbers: \n "
      )
    new_guess = gets.chomp
    if new_guess.upcase == "RULES"
      return "RULES"
    else
      self.guess = new_guess.split""
      board.game_board.push self.guess
      new_guess.split""
    end
  end

end

class ComputerPlayer
  attr_reader :code

  def initialize 
    @code = self.generate_code 
  end

  def generate_code 
    random_code = []
    4.times do
      number = (rand 6) + 1
      random_code.push number.to_s
    end
    random_code
  end

  def crack_code board
    set = []
    (1111..6666).each do |num|
      unless /[7890]/.match?(num)
        set << num
      end
    end

  end
end

class Game
  attr_reader :numbers
  attr_accessor :turn, :code_cracked

  def initialize 
    @numbers = [1, 2, 3, 4, 5, 6]
    @turn = 0
    @code_cracked = false
    @codebreaker = nil
  end

  def explain_rules
    puts (
      " \nYou will have 10 turns to guess a random number sequence chosen by the computer. Numbers can repeat. The available numbers are 1, 2, 3, 4, 5, 6, and each turn you will receive a white token for each matching number in the sequence. A black peg represents maching number and position.\n\nIf there are repeating numbers in the sequence (1112) and your guess contains one of the correct numbers out of sequence (ex. 2334), you will receive only one white peg as feedback for that correctly guessed number. Likewise with a black peg if you guess one number out of miltiple repeats in the correct sequence (5416). Type 'rules' to see this statement again.\n "
      ) 
  end

  def check_guess code, guess, board, cache = {number: 0, number_and_space: 0}
    
    code.each_with_index do |code_number, i|
      guess.each_with_index do |guess_number, j|
        if code_number == guess_number && i == j
          cache[:number_and_space] += 1
          new_code = code.slice(i+1, code.length)
          new_guess = guess.slice(j+1, guess.length)
          return self.check_guess(new_code, new_guess, board, cache)
        elsif code_number == guess_number
          cache[:number] += 1
          new_code = code.slice(i+1, code.length)
          new_guess = guess.slice(j+1, guess.length)
          return self.check_guess(new_code, new_guess, board, cache)
        end
      end
    end

    pegs = []
    cache[:number_and_space].times {pegs.push "B"}
    cache[:number].times {pegs.push "W"}
    board.key_pegs.push pegs
    if cache[:number_and_space] == 4
      self.code_cracked = true
      puts "\nCode cracked! You win!" 
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

  end
end

game = Game.new
player = Player.new
computer = ComputerPlayer.new
board = Board.new

game.explain_rules
until game.code_cracked == true
    game.run_player_turn player, computer.code, board
end