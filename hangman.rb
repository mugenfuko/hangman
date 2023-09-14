require 'yaml'

module Dictionary
    WORDS_5_TO_12_CHRS = File.read('google-10000-english-no-swears.txt').split(' ').select {|word| word.length >= 5 && word.length <= 12}
end

class Game
    include Dictionary
  
    def initialize
        @random_word = pick_random_word(WORDS_5_TO_12_CHRS)
        @dashed_line = create_dashed_line(@random_word)
        @turns = 1
        @max_incorrect_guesses = 7
        @correct_letters = []
        @incorrect_letters = []
    end

    def pick_random_word(words)
        words[Random.new.rand(words.size - 1)]
    end

    def create_dashed_line(word)
        new_dashed_line = []
        word.length.times do
            new_dashed_line.push('_')
        end
        new_dashed_line
    end

    def save_game
        contents = YAML.dump ({
            :random_word => @random_word,
            :dashed_line => @dashed_line,
            :turns => @turns,
            :max_incorrect_guesses => @max_incorrect_guesses,
            :correct_letters => @correct_letters,
            :incorrect_letters => @incorrect_letters
            })
        save_file = File.open("save_file", "w") {|f| f.write("#{contents}")}
        puts "Game saved!"
        puts "Exiting program..."
    end
    
    def load_game
        save_file = YAML.load(File.read("save_file"))
        @random_word = save_file[:random_word]
        @dashed_line = save_file[:dashed_line]
        @turns = save_file[:turns]
        @max_incorrect_guesses = save_file[:max_incorrect_guesses]
        @correct_letters = save_file[:correct_letters]
        @incorrect_letters = save_file[:incorrect_letters]
        puts "Previous game loaded!"
    end

    def get_input
        input = gets.chomp.downcase
        if input == 'save'
            save_game
            exit
        elsif input == 'load'
            load_game
            play_game
        else
            until input.length == 1 && input.match?(/[a-z]/)
                print "Please choose a single letter: "
                input = gets.chomp.downcase
            end
        end
        input
    end

    def new_game?(condition='win')
        if condition == 'win'
            puts 'You have won the game!'
            print 'Play again?(Y/N): '    
        elsif condition == 'lose'
            puts 'Game over!'
            print 'Try again? (Y/N): '
        end
        input = get_input
        until input == 'y' || input == 'n'
            print "Please type either 'Y'(yes) or 'N'(no): "
            input = get_input
        end
        if input == 'y'
            game = Game.new
            game.play_game
        elsif  input == 'n'
            puts 'Thanks for playing!'
            puts 'Exiting program...'
            exit
        end
    end
  
    def play_game
        puts "WELCOME TO HANGMAN!"
        puts "Type 'load' to resume your previous game, 'save' to save your current game."
        until @dashed_line.join('') == @random_word || @max_incorrect_guesses == 0
            puts "Incorrect guesses remaining: #{@max_incorrect_guesses}"
            puts "Incorrect letters: #{@incorrect_letters.join(', ')}\n\n" unless @incorrect_letters.empty?
            puts "#{@dashed_line.join(' ')}\n\n"
            print 'Choose a letter: '
            input = get_input
      
            while @correct_letters.union(@incorrect_letters).include?(input)
                print "Please choose a letter you haven't used yet: "
                input = get_input
            end
      
            if @random_word.include?(input)
                @dashed_line.each_with_index do |dash, i|
                    if input == @random_word[i]
                        @dashed_line[i] = @random_word[i]
                    end
                end
                puts "\n\nThat letter is in the word!"
                @correct_letters.push(input)
            else
                puts "\n\nThat letter is not in the word!"
                @max_incorrect_guesses -= 1
                @incorrect_letters.push(input)
            end
            if @max_incorrect_guesses == 0
                condition = 'lose'
                new_game?(condition)
            end
            @turns += 1
        end
        puts @dashed_line.join(' ')
        new_game?
    end

end

game = Game.new
game.play_game
