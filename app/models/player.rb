class Player < ApplicationRecord
  belongs_to :league
  has_many :player_games
  has_many :games, through: :player_games
  has_secure_password
  has_attached_file :image,
    styles: { small: "64x64", med: "100x100", large: "200x200" },
    :s3_protocol => 'https',
    :s3_host_name => ENV['s3_host_name'],
    :path => ENV['path'],
    :storage => 's3',
    :s3_credentials => Proc.new{|a| a.instance.s3_credentials},
    :s3_region => ENV['s3_region']

  validates_attachment_content_type :image, :content_type => ["image/jpg", "image/jpeg", "image/png", "image/gif"]
  validates :name, :password, presence: true

  def s3_credentials
    {:bucket => ENV['s3_bucket'], :access_key_id => ENV['access_key_id'], :secret_access_key => ENV['secret_access_key']}
  end

  def player_wins
    wins = 0
    self.player_games.each do |pg|
      my_score = pg.score
      opponent_id = pg.game.opponent.to_i
      if opponent_id == self.id
        opp_score = PlayerGame.where("game_id = ?", pg.game.id).last.score
        if my_score > opp_score
          wins += 1
        end
      else
        opp_score = PlayerGame.find_by(game_id: pg.game.id, player_id: opponent_id ).score
        if my_score > opp_score
          wins += 1
        end
      end
    end
    wins
  end

  def player_losses
    losses = 0
    self.player_games.each do |pg|
      my_score = pg.score
      opponent_id = pg.game.opponent.to_i
      if opponent_id == self.id
        opp_score = PlayerGame.where("game_id = ?", pg.game.id).last.score
        if my_score < opp_score
          losses += 1
        end
      else
        opp_score = PlayerGame.find_by(game_id: pg.game.id, player_id: opponent_id ).score
        if my_score < opp_score
          losses += 1
        end
      end
    end
    losses
  end

  def find_rival
    rival_hash = Hash.new(0)
    self.games.each do |game|
      two_player_games_to_game = PlayerGame.where("game_id = ?", game.id)
      my_player_game = two_player_games_to_game.where("player_id =?", self.id).first
      their_player_game = two_player_games_to_game.where("player_id !=?", self.id).first
      if rival_hash[their_player_game.player.name]
        rival_hash[their_player_game.player.name] += 1
      end
    end
    rival_hash.sort_by{|k, v| v}.last
  end

  def find_nemesis
    nemesis_hash = Hash.new(0)
    self.games.each do |game|
      two_player_games_to_game = PlayerGame.where("game_id = ?", game.id)
      my_player_game = two_player_games_to_game.where("player_id =?", self.id).first
      their_player_game = two_player_games_to_game.where("player_id !=?", self.id).first
      if nemesis_hash[their_player_game.player.name]
        if my_player_game.score < their_player_game.score
          nemesis_hash[their_player_game.player.name] += 1
        end
      end
    end
    nemesis_hash.sort_by{|k, v| v}.last
  end

  # account_sid = "AC585916a90d4ff9504546ca4e1e0b9603"
  # auth_token = "f8876d01f6c92c9ab1de2bfbb7a56cf3"
  #
  # CLIENT = Twilio::REST::Client.new(account_sid, auth_token)
  #
  # def send_twilio_message(user_phone_number)
  #   #byebug
  #   CLIENT.messages.create(
  #     to: "+#{user_phone_number}",
  #     from: "+12677133348",
  #     body: "Welcome to Lawnstar bro! Massacering your bros in cornhole as of late? Make sure you record those W's!"
  #   )
  # end

  def played_any_games?
    !(self.games.empty?)
  end



  def win_percentage
    ((player_wins.to_f/(player_wins + player_losses).to_f)*100).round(1)
  end

  def sports_wins_losses
    sports_hash = {}
    self.player_games.each do |pg|
      sport = pg.game.sport.name
      my_score = pg.score
      opponent_id = pg.game.opponent.to_i
      if sports_hash.keys.include?(sport)
        if opponent_id == self.id
          opp_score = PlayerGame.where("game_id = ?", pg.game.id).last.score
          if my_score > opp_score
            sports_hash[sport]["wins"] += 1
          else
            sports_hash[sport]["losses"] += 1
          end
        else
          opp_score = PlayerGame.find_by(game_id: pg.game.id, player_id: opponent_id).score
          if my_score > opp_score
            sports_hash[sport]["wins"] += 1
          else
            sports_hash[sport]["losses"] += 1
          end
        end
      else
        sports_hash[sport] = {"wins" => 0, "losses" => 0}
        if opponent_id == self.id
          opp_score = PlayerGame.where("game_id = ?", pg.game.id).last.score
          if my_score > opp_score
            sports_hash[sport]["wins"] += 1
          else
            sports_hash[sport]["losses"] += 1
          end
        else
          opp_score = PlayerGame.find_by(game_id: pg.game.id, player_id: opponent_id).score
          if my_score > opp_score
            sports_hash[sport]["wins"] += 1
          else
            sports_hash[sport]["losses"] += 1
          end
        end
      end
    end
    sports_hash
  end

  def naked_laps
    naked_laps = 0
    self.player_games.each do |pg|
      my_score = pg.score
      if my_score == 0
        naked_laps += 1
      end
    end
    naked_laps
  end

end

# working on this March 8, 2017. Access key id does not match up with what it was apparently.

# class Player < ApplicationRecord
#   belongs_to :league
#   has_many :player_games
#   has_many :games, through: :player_games
#   has_secure_password
#   has_attached_file :image,
#     styles: { small: "64x64", med: "100x100", large: "200x200" },
#     :s3_protocol => 'https',
#     :s3_host_name => ENV['s3_host_name'],
#     :path => ENV['path'],
#     :storage => 's3',
#     :s3_credentials => Proc.new{|a| a.instance.s3_credentials},
#     :s3_region => ENV['s3_region']
#
#   validates_attachment_content_type :image, :content_type => ["image/jpg", "image/jpeg", "image/png", "image/gif"]
#   validates :name, :password, presence: true
#
#   def s3_credentials
#     {:bucket => 'lawnstar', :access_key_id => ENV['access_key_id'], :secret_access_key => ENV['secret_access_key']}
#   end
#
#   def player_wins
#     wins = 0
#     self.player_games.each do |pg|
#       my_score = pg.score
#       opponent_id = pg.game.opponent.to_i
#       if opponent_id == self.id
#         opp_score = PlayerGame.where("game_id = ?", pg.game.id).last.score
#         if my_score > opp_score
#           wins += 1
#         end
#       else
#         opp_score = PlayerGame.find_by(game_id: pg.game.id, player_id: opponent_id ).score
#         if my_score > opp_score
#           wins += 1
#         end
#       end
#     end
#     wins
#   end
#
#   def player_losses
#     losses = 0
#     self.player_games.each do |pg|
#       my_score = pg.score
#       opponent_id = pg.game.opponent.to_i
#       if opponent_id == self.id
#         opp_score = PlayerGame.where("game_id = ?", pg.game.id).last.score
#         if my_score < opp_score
#           losses += 1
#         end
#       else
#         opp_score = PlayerGame.find_by(game_id: pg.game.id, player_id: opponent_id ).score
#         if my_score < opp_score
#           losses += 1
#         end
#       end
#     end
#     losses
#   end
#
#   def find_rival
#     rival_hash = Hash.new(0)
#     self.games.each do |game|
#       two_player_games_to_game = PlayerGame.where("game_id = ?", game.id)
#       my_player_game = two_player_games_to_game.where("player_id =?", self.id).first
#       their_player_game = two_player_games_to_game.where("player_id !=?", self.id).first
#       if rival_hash[their_player_game.player.name]
#         rival_hash[their_player_game.player.name] += 1
#       end
#     end
#     rival_hash.sort_by{|k, v| v}.last
#   end
#
#   def find_nemesis
#     nemesis_hash = Hash.new(0)
#     self.games.each do |game|
#       two_player_games_to_game = PlayerGame.where("game_id = ?", game.id)
#       my_player_game = two_player_games_to_game.where("player_id =?", self.id).first
#       their_player_game = two_player_games_to_game.where("player_id !=?", self.id).first
#       if nemesis_hash[their_player_game.player.name]
#         if my_player_game.score < their_player_game.score
#           nemesis_hash[their_player_game.player.name] += 1
#         end
#       end
#     end
#     nemesis_hash.sort_by{|k, v| v}.last
#   end
#
#   # account_sid = "AC585916a90d4ff9504546ca4e1e0b9603"
#   # auth_token = "f8876d01f6c92c9ab1de2bfbb7a56cf3"
#   #
#   # CLIENT = Twilio::REST::Client.new(account_sid, auth_token)
#   #
#   # def send_twilio_message(user_phone_number)
#   #   #byebug
#   #   CLIENT.messages.create(
#   #     to: "+#{user_phone_number}",
#   #     from: "+12677133348",
#   #     body: "Welcome to Lawnstar bro! Massacering your bros in cornhole as of late? Make sure you record those W's!"
#   #   )
#   # end
#
#   def played_any_games?
#     !(self.games.empty?)
#   end
#
#
#
#   def win_percentage
#     ((player_wins.to_f/(player_wins + player_losses).to_f)*100).round(1)
#   end
#
#   def sports_wins_losses
#     sports_hash = {}
#     self.player_games.each do |pg|
#       sport = pg.game.sport.name
#       my_score = pg.score
#       opponent_id = pg.game.opponent.to_i
#       if sports_hash.keys.include?(sport)
#         if opponent_id == self.id
#           opp_score = PlayerGame.where("game_id = ?", pg.game.id).last.score
#           if my_score > opp_score
#             sports_hash[sport]["wins"] += 1
#           else
#             sports_hash[sport]["losses"] += 1
#           end
#         else
#           opp_score = PlayerGame.find_by(game_id: pg.game.id, player_id: opponent_id).score
#           if my_score > opp_score
#             sports_hash[sport]["wins"] += 1
#           else
#             sports_hash[sport]["losses"] += 1
#           end
#         end
#       else
#         sports_hash[sport] = {"wins" => 0, "losses" => 0}
#         if opponent_id == self.id
#           opp_score = PlayerGame.where("game_id = ?", pg.game.id).last.score
#           if my_score > opp_score
#             sports_hash[sport]["wins"] += 1
#           else
#             sports_hash[sport]["losses"] += 1
#           end
#         else
#           opp_score = PlayerGame.find_by(game_id: pg.game.id, player_id: opponent_id).score
#           if my_score > opp_score
#             sports_hash[sport]["wins"] += 1
#           else
#             sports_hash[sport]["losses"] += 1
#           end
#         end
#       end
#     end
#     sports_hash
#   end
#
#   def naked_laps
#     naked_laps = 0
#     self.player_games.each do |pg|
#       my_score = pg.score
#       if my_score == 0
#         naked_laps += 1
#       end
#     end
#     naked_laps
#   end
#
# end
