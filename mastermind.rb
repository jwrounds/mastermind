# mastermind display mockup:
#
#  Y   P   T   G
#  * | * | * | * |          
#  G | R | R | P | [ W W     ]
#  P | O | T | R | [ B W     ]
#  P | T | G | O | [ W W W   ]
#  Y | P | T | G | [ B B B B ]
#
# or:
#
#   Y  P  T  G
#  [*--*--*--*]          
#  [G--R--R--P] [W, W]
#  [P--O--T--R] [B, W]
#  [P--T--G--O] [W, W, W]
#  [Y--P--T--G] [B, B, B, B]


colors = ["red", "green", "turquoise", "yellow", "purple", "orange"]

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
      " \nGuess the sequence by entering a combination of four letters representing each color ('r' for red, 'g' for green, 't' for turquoise, 'y' for yellow, 'p' for purple, or 'o' for orange): \n "
      )
    new_guess = gets.chomp.upcase
    if new_guess == "RULES"
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

  def initialize colors
    @code = self.generate_code colors
  end

  def generate_code colors
    random_code = []
    4.times do 
      random_code.push colors[rand 6][0].upcase
    end
    random_code
  end
end

class Game
  attr_reader :colors
  attr_accessor :turn, :code_cracked

  def initialize color_set
    @colors = color_set
    @turn = 0
    @code_cracked = false
  end

  def explain_rules
    puts (
      " \nYou will have 10 turns to guess a random color sequence chosen by the computer. Colors can repeat. The available colors are #{self.colors.join(', ')} and each turn you will receive a white token for each matching color in the sequence. A black peg represents maching color and position.\n\nIf there are repeating colors in the sequence (ex. 'green, green, blue, blue') and your guess contains one of the correct colors out of sequence (ex. 'purple, red, orange, green'), you will receive only one white peg as feedback for that correctly guessed color. Likewise with a black peg if you guess one color out of miltiple repeats in the correct sequence (ex. 'green, orange, purple, red'). Type 'rules' to see this statement again.\n "
      ) 
  end

  def check_guess code, guess, board, cache = {color: 0, color_and_space: 0}
    
    code.each_with_index do |code_color, i|
      guess.each_with_index do |guess_color, j|
        if code_color == guess_color && i == j
          cache[:color_and_space] += 1
          return self.check_guess(code.slice(i+1, code.length), guess.slice(j+1, guess.length), board, cache)
        elsif code_color == guess_color
          
          cache[:color] += 1
          return self.check_guess(code.slice(i+1, code.length), guess.slice(j+1, guess.length), board, cache)
        end
      end
    end

    pegs = []
    cache[:color_and_space].times {pegs.push "B"}
    cache[:color].times {pegs.push "W"}
    board.key_pegs.push pegs
    if cache[:color_and_space] == 4
      self.code_cracked = true
      puts "\nCode cracked! You win!" 
    end
    
  end

  def run_turn player, code, board
      p code
      board.display
      guess = player.make_guess board

      if guess == "RULES"
        self.explain_rules
      else
        self.check_guess code, guess, board
      end
  end
end

game = Game.new colors
player = Player.new
computer = ComputerPlayer.new colors
board = Board.new

game.explain_rules
until game.code_cracked == true
    game.run_turn player, computer.code, board
end