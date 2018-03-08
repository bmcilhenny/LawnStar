class PlayersController < ApplicationController

  skip_before_action :authorized, only: [:new, :create]

  def new
    @player = Player.new
  end
#
  def create
    @player = Player.new(player_params)
    # byebug
    if @player.valid?
      # @player.send_twilio_message(16093206378)
      # byebug
      @player.save
      session[:player_id] = @player.id

      redirect_to player_path(@player)
      # @player.send_twilio_message(16093206378)
    else
      render 'new'
    end
  end

  def show
    if Player.exists?(params[:id])
      @player = Player.find(params[:id])
    else
      flash[:message] = "Do not have access to view this page."
      redirect_to player_path(@current_player)
    end
    @player.player_wins
    @wins = @player.player_wins
    @losses = @player.player_losses
    @win_percentage = @player.win_percentage
    @total_games_played = @wins + @losses
    @sports_record = @player.sports_wins_losses

    if @player.played_any_games?
      @rival_name = @player.find_rival.first
      @amount_of_times_youve_played_eachother = @player.find_rival.last
      if @player.find_nemesis == nil
        @nemesis_name = "\"N/A\""
        @nemesis_wins = 0
      else
        @nemesis_name = @player.find_nemesis.first
        @nemesis_wins = @player.find_nemesis.last
      end
    else
      @rival_name = nil
      @amount_of_times_youve_played_eachother = 0
      @nemesis_name = "\"N/A\""
      @nemesis_wins = 0
    end
  end

  private

  def player_params
    params.require(:player).permit(:name, :league_id, :password, :password_confirmation, :image)
  end

end
