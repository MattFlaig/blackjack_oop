class Deck
  attr_accessor :cards, :first_hand
  def initialize
    @cards = []
  end
  
  def fifty_two
    original_deck = ['2','3','4','5','6','7','8','9','10','Jack','King','Queen','Ace'] 
    cards << original_deck * 4 
    cards.flatten!
    cards.shuffle!
  end

  def deal_one
    cards.pop
  end
end



module Hand

def show_hand
  puts "---#{name}'s hand ---"
  show_cards.each do |card|
    puts "=> #{card}"
  end
  puts "=> Total: #{total(hand)}"
end

def total(face_values)
  total = 0
  face_values.each do |val|
    if val == "Ace"
      total += 11
    elsif val.to_i == 0
      total += 10 
    else
      total += val.to_i
    end
  end

  face_values.select{|val| val == "Ace"}.count.times do
    if total > 21
      total -= 10
    end
  end

  total 
end

def is_busted?(player_or_dealer)
  total(player_or_dealer.hand) > Blackjack::BLACKJACK_AMOUNT
end

end


module Card

  def add_suit(hand)
    suits = [' spades',' hearts',' diamonds',' clubs']
    hand.flatten!
    show_cards << hand.map {|a| a + suits[rand(suits.length)]}
  end

  def add_suit_new(hand_new)
    suits = [' spades',' hearts',' diamonds',' clubs']
    make_arr = hand_new.split
    show_cards << make_arr.map {|a| a + suits[rand(suits.length)]}
  end

  def make_uniq(hand)
    suits = ['spades','hearts','diamonds','clubs']
    substring = []
    substring << hand.pop
    joiner = substring.join
    splitter = joiner.split(' ') 
    remover = suits - splitter[-1]
    output = splitter[0][0].to_s + ' ' + remover[rand(remover.length)].to_s 
    output
  end
end


class Player
  include Card 
  include Hand

  attr_accessor  :show_cards, :hand, :name
  def initialize (n)
    @show_cards = []
    @hand = []
    @name = n
  end
end

class Dealer
  include Card, Hand

  attr_accessor  :show_cards, :hand, :name
  def initialize (n)
    @show_cards = []
    @hand = []
    @name = n
  end
end

class Blackjack
  attr_accessor :deck, :player, :dealer

  BLACKJACK_AMOUNT = 21
  DEALER_HIT_MIN = 17

  def initialize
    @deck = Deck.new
    @player = Player.new("Player")
    @dealer = Dealer.new("Dealer")
  end

  #def set_player_name
  #  puts "What's your name?"
  #  player.name = gets.chomp
  #end
  def make_fifty_two
    deck.fifty_two
  end

  def deal_cards
    player.hand << deck.deal_one
    dealer.hand << deck.deal_one
    player.hand << deck.deal_one
    dealer.hand << deck.deal_one
  end
  
  def adding_suits
    player.add_suit(player.hand)
    dealer.add_suit(dealer.hand)
  end

  def check_uniq_p(show_cards)
    if show_cards != show_cards.uniq
    show_cards.uniq! << player.make_uniq(player.show_cards)
    end
  end

  def check_uniq_d(show_cards)
    if show_cards != show_cards.uniq
    show_cards.uniq! << dealer.make_uniq(dealer.show_cards)
    end
  end

  def show_flop
    player.show_hand
    dealer.show_hand
  end

  def blackjack_or_bust?(player_or_dealer)
    if player_or_dealer.total(player_or_dealer.hand) == BLACKJACK_AMOUNT
      if player_or_dealer.is_a?(Dealer)
        puts "Sorry, dealer hit blackjack. #{player.name} loses."
      else
        puts "Congratulations, you hit blackjack! #{player.name} win!"
      end
      play_again?
    elsif player_or_dealer.is_busted?(player_or_dealer)
      if player_or_dealer.is_a?(Dealer)
        puts "Congratulations, dealer busted. #{player.name} win!"
      else
        puts "Sorry, #{player.name} busted. #{player.name} loses."
      end
      play_again?
    end
  end

  def player_turn
    puts "#{player.name}'s turn."

    blackjack_or_bust?(player)

    while !player.is_busted?(player)
      puts "What would you like to do? 1) hit 2) stay"
      response = gets.chomp

      if !['1', '2'].include?(response)
        puts "Error: you must enter 1 or 2"
        next
      end

      if response == '2'
        puts "#{player.name} chose to stay."
        break
      end

      #hit
      new_card = deck.deal_one
      player.hand << new_card
      suit_card = player.add_suit_new(new_card)
      player.show_cards.flatten!
      if player.show_cards != player.show_cards.uniq
        player.show_cards.uniq! << player.make_uniq(player.show_cards)
      end
      
      puts "Dealing card to #{player.name}: #{suit_card}"
      
      puts "#{player.name}'s total is now: #{player.total(player.hand)}"

      blackjack_or_bust?(player)
    end
    puts "#{player.name} stays at #{player.total(player.hand)}."
  end

  def dealer_turn
    puts "Dealer's turn."

    blackjack_or_bust?(dealer)
    while dealer.total(dealer.hand) < DEALER_HIT_MIN
      new_card = deck.deal_one
      dealer.hand << new_card
      suit_card = dealer.add_suit_new(new_card)
      dealer.show_cards.flatten!
      if dealer.show_cards != dealer.show_cards.uniq
        dealer.show_cards.uniq! << dealer.make_uniq(show_cards)
      end

      puts "Dealing card to dealer: #{suit_card}"
      
      puts "Dealer total is now: #{dealer.total(dealer.hand)}"

      blackjack_or_bust?(dealer)
    end
    puts "Dealer stays at #{dealer.total(dealer.hand)}."
  end

  def who_won?
    if player.total(player.hand) > dealer.total(dealer.hand)
      puts "Congratulations, #{player.name} wins!"
    elsif player.total(player.hand) < dealer.total(dealer.hand)
      puts "Sorry, #{player.name} loses."
    else
      puts "It's a tie!"
    end
    play_again?
  end

  def play_again?
    puts ""
    puts "Would you like to play again? 1) yes 2) no, exit"
    if gets.chomp == '1'
      puts "Starting new game..."
      puts ""
      deck = Deck.new
      player.hand = []
      player.show_cards = []
      dealer.hand = []
      dealer.show_cards = []
      start
    else
      puts "Goodbye!"
      exit
    end
  end

  def start
    #set_player_name
    make_fifty_two
    deal_cards
    adding_suits
    check_uniq_p(player.show_cards)
    check_uniq_d(dealer.show_cards)
    show_flop
    player_turn
    dealer_turn
    who_won?
  end
end

game = Blackjack.new
game.start
