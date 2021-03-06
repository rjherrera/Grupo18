class EpisodesController < ApplicationController
  before_action :set_episode, only: [:show, :edit, :watch, :update, :destroy]

  # GET /episodes
  # GET /episodes.json
  def index
    @episodes = Episode.all
  end

  # GET /episodes/1
  # GET /episodes/1.json
  def show
    @season = Season.find(@episode.season_id)
    @tv_show = TvShow.find(@season.tv_show_id)
    @reviews = Review.where(episode_id: @episode.id).order('created_at DESC')
    @review = Review.new
    @user = current_user
    if current_user
        @viewed = current_user.viewed_episodes.where(:id => @episode.id).count
    end
  end

  # GET /episodes/new
  def new
    @episode = Episode.new
    @episode.season_id = params[:season_id0]
    @season = Season.find(@episode.season_id)
    @tv_show = TvShow.find(@season.tv_show_id)
  end

  # GET /episodes/1/edit
  def edit
    @season = Season.find(@episode.season_id)
    @tv_show = TvShow.find(@season.tv_show_id)
  end

  # GET /episodes/1/watch
  def watch
    @user = current_user
    @season = Season.find(@episode.season_id)
    @tv_show = TvShow.find(@season.tv_show_id)
    @user.viewed_episodes << @episode
  end

  # GET /episodes/1/list_watched
  def list_watched
    @user = current_user
    total_seconds_time = 0
    @viewed_tv_shows = []
    @user.viewed_episodes.each do |episode|
        total_seconds_time += episode.duration.hour*3600 + episode.duration.min*60 + episode.duration.sec
        episode.season.tv_show.watched_count = 0
        @viewed_tv_shows << episode.season.tv_show
    end
    @viewed_tv_shows.each do |tv_show|
        tv_show.watched_count = @viewed_tv_shows.count(tv_show)
    end
    @viewed_tv_shows = @viewed_tv_shows.uniq

    @days = 0
    @hours = 0
    @minutes = 0
    @seconds = 0
    if (total_seconds_time/(3600*24)).to_i > 0
        @days = (total_seconds_time/(3600*24)).to_i
        total_seconds_time -= @days * (3600*24)
    end
    if (total_seconds_time/3600).to_i > 0
        @hours = (total_seconds_time/3600).to_i
        total_seconds_time -= @hours * 3600
    end
    if (total_seconds_time/60).to_i > 0
        @minutes = (total_seconds_time/60).to_i
        total_seconds_time -= @minutes * 60
    end
    @seconds = total_seconds_time

    respond_to do |format|
      format.html
      format.xlsx {
        response.headers['Content-Disposition'] = 'attachment; filename="my_noflix_stats.xlsx"'
      }
    end

  end

  # POST /episodes
  # POST /episodes.json
  def create
    @episode = Episode.new(episode_params)
    @season = Season.find(@episode.season_id)
    @tv_show = TvShow.find(@season.tv_show_id)

    respond_to do |format|
      if @episode.save
        format.html { redirect_to @episode, notice: 'Episode was successfully created.' }
        format.json { render :show, status: :created, location: @episode }
      else
        format.html { render :new }
        format.json { render json: @episode.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /episodes/1
  # PATCH/PUT /episodes/1.json
  def update
    respond_to do |format|
      if @episode.update(episode_params)
        format.html { redirect_to @episode, notice: 'Episode was successfully updated.' }
        format.json { render :show, status: :ok, location: @episode }
      else
        format.html { render :edit }
        format.json { render json: @episode.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /episodes/1
  # DELETE /episodes/1.json
  def destroy
    @episode.destroy
    respond_to do |format|
      format.html { redirect_to @episode.season, notice: 'Episode was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_episode
      @episode = Episode.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def episode_params
      params.require(:episode).permit(:number, :title, :duration, :plot, :season_id)
    end
end
