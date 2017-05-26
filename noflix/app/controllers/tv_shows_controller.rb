class TvShowsController < ApplicationController
  before_action :set_tv_show, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!, only: [:new, :create, :edit, :update, :destroy]

  # GET /tv_shows
  # GET /tv_shows.json
  def index
    @user = current_user
    if @user
        @user.private_tv_shows.each do |tv_show|
            stars_avg = Review.where(tv_show_id: tv_show.id).average(:stars)
            if stars_avg != nil
                tv_show.stars_avg = stars_avg.round
            else
                tv_show.stars_avg = "-"
            end
        end
    end
    @tv_shows = TvShow.all
    @tv_shows.each do |tv_show|
        stars_avg = Review.where(tv_show_id: tv_show.id).average(:stars)
        if stars_avg != nil
            tv_show.stars_avg = stars_avg.round
        else
            tv_show.stars_avg = "-"
        end
    end

    # Filter by Category
    if params[:filter_category]
        @filter_category = params[:filter_category]
        @tv_shows = @tv_shows.select {|tv_show| tv_show.category == @filter_category }
        if @private_tv_shows
            @private_tv_shows = @private_tv_shows.select {|tv_show| tv_show.category == @filter_category }
        end
    end

  end

  # GET /tv_shows/1
  # GET /tv_shows/1.json
  def show
    @user = current_user
    @seasons = Season.where(tv_show_id: @tv_show.id).order('number ASC')
    @season = Season.new
    @articles = Article.where(tv_show_id: @tv_show.id).order('created_at DESC')
    @article = Article.new
    @subtitles = @tv_show.subtitles;
  end

  # GET /tv_shows/new
  def new
    @user = current_user
    @tv_show = TvShow.new
    @subtitles = Subtitle.all
    @actors = Actor.all
    @tv_shows = TvShow.all
  end

  # GET /tv_shows/1/edit
  def edit
    @user = current_user
    @tv_shows = TvShow.all
    @subtitles = Subtitle.all
    @actors = Actor.all
    if !current_user.is_admin and current_user.id != @tv_show.user_id
      redirect_to TvShow
    end
  end

  # POST /tv_shows
  # POST /tv_shows.json
  def create
    # Director Name
    name = tv_show_params[:director_id].split.map(&:capitalize).join(' ')
    if !Director.exists?(:name => name)
        Director.create(name: name)
    end
    new_tsp = tv_show_params
    new_tsp[:director_id] = Director.find_by_name(name).id

    # Subtitles
    subs_params = tv_show_params[:subtitles]
    new_subtitles = []
    subs_params.split(";").each do |s|
        if Subtitle.find_by_language(s)
            new_subtitles << Subtitle.find_by_language(s)
        end
    end
    new_tsp[:subtitles] = new_subtitles

    # Actors
    actors_params = tv_show_params[:actors]
    new_actors = []
    actors_params.split(";").each do |a|
        if Actor.find_by_name(a)
            new_actors << Actor.find_by_name(a)
        end
    end
    new_tsp[:actors] = new_actors

    new_tsp[:user_id] = current_user.id
    @tv_show = TvShow.new(new_tsp)

    if current_user.is_admin
      @tv_show.user_id = nil
    end

    respond_to do |format|
      if @tv_show.save
        format.html { redirect_to @tv_show, notice: 'Tv show was successfully created.' }
        format.json { render :show, status: :created, location: @tv_show }
      else
        format.html { render :new }
        format.json { render json: @tv_show.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /tv_shows/1
  # PATCH/PUT /tv_shows/1.json
  def update
    new_tsp = tv_show_params
    # Director Name
    name = tv_show_params[:director_id].split.map(&:capitalize).join(' ')
    if !Director.exists?(:name => name)
        Director.create(name: name)
    end
    new_tsp[:director_id] = Director.find_by_name(name).id

    # Subtitles
    subs_params = tv_show_params[:subtitles]
    new_subtitles = []
    subs_params.split(";").each do |s|
        if Subtitle.find_by_language(s)
            new_subtitles << Subtitle.find_by_language(s)
        end
    end
    new_tsp[:subtitles] = new_subtitles

    # Actors
    actors_params = tv_show_params[:actors]
    new_actors = []
    actors_params.split(";").each do |a|
        if Actor.find_by_name(a)
            new_actors << Actor.find_by_name(a)
        end
    end
    new_tsp[:actors] = new_actors

    respond_to do |format|
      if @tv_show.update(new_tsp)
        format.html { redirect_to @tv_show, notice: 'Tv show was successfully updated.' }
        format.json { render :show, status: :ok, location: @tv_show }
      else
        format.html { render :edit }
        format.json { render json: @tv_show.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /tv_shows/1
  # DELETE /tv_shows/1.json
  def destroy
    @tv_show.destroy
    respond_to do |format|
      format.html { redirect_to tv_shows_url, notice: 'Tv show was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_tv_show
      @tv_show = TvShow.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def tv_show_params
      params.require(:tv_show).permit(:title, :language, :country, :category, :start_year, :end_year, :plot, :director_id, :user_id, :subtitles, :actors)
    end
end
