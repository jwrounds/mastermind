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
    @key_pegs = nil
    @game_board = [["*", "*", "*", "*"]]
  end

  def display 
    self.game_board.each_with_index do |row, i|
      displayed_row = "[#{row.join('--')}]"
      if i > 0 && key_pegs
        display_row += "[#{self.key_pegs[i]}]"
      end
      puts displayed_row
    end
  end
end

class Player
  attr_accessor :guess

  def initialize
    @guess = []
  end

  def make_guess board
    puts (  
      " \nGuess the sequence by entering a combination of four letters representing each color ('r' for red, 'g' for green, 't' for turquoise, 'y' for yellow, 'p' for purple, or 'o' for orange): \n"
      )
    new_guess = gets.chomp.upcase
    self.guess = new_guess.split""
    board.game_board.push self.guess
  end

end

class ComputerPlayer
  attr_accessor :code

  def initialize colors
    @code = self.generate_code colors
  end

  def generate_code colors
    random_code = []
    4.times do 
      random_code.push colors[rand 6]
    end
    random_code
  end
end

class Game
  attr_reader :colors, :board
  attr_accessor :turn

  def initialize color_set, board
    @colors = color_set
    @board = board
    @turn = 0
  end

  new_board = Board.new
  def explain_rules
    puts (
      " \nYou will have 10 turns to guess a random color sequence chosen by the computer. Colors can repeat. The available colors are #{self.colors.join(', ')} and each turn you will receive a white token for each matching color in the sequence. A black peg represents maching color and position.\n\nIf there are repeating colors in the sequence (ex. 'green, green, blue, blue') and your guess contains one of the correct colors out of sequence (ex. 'purple, red, orange, green'), you will receive only one white peg as feedback for that correctly guessed color. Likewise with a black peg if you guess one color out of miltiple repeats in the correct sequence (ex. 'green, orange, purple, red'). Type 'rules' to see this statement again.\n "
      ) 
  end

  def start
    self.explain_rules
    @Computer_player = ComputerPlayer.new self.colors
    self.board.display
  end
end

