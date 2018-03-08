class SessionsController < ApplicationController

  skip_before_action :authorized, only: [:new, :create]

  def new
  end


  def create
    @player = Player.find_by(name: params[:name])
    if @player && @player.authenticate(params[:password])
      # you are who you say you are
      session[:player_id] = @player.id
      flash[:message] = "Welcome #{@player.name}."
      redirect_to league_path(@player.league)
    else
      # byebug
      # sign in failed
      flash[:message] = "Wrong username and password"
      redirect_to signin_path

    end
  end


  def destroy
    session[:player_id] = nil
    redirect_to signin_path
  end



end
