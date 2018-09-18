# _The_ movie controller
class MoviesController < ApplicationController
  def movie_params
    params.require(:movie).permit(:title, :rating, :description, :release_date)
  end

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
    @all_ratings = Movie
                   .distinct(:rating)
                   .pluck(:rating)

    session[:ratings] ||= @all_ratings

    @movies = case session[:sort]
              when 'title'
                Movie.where(rating: session[:ratings]).order(:title)
              when 'release_date'
                Movie.where(rating: session[:ratings]).order(:release_date)
              else
                Movie.where(rating: session[:ratings])
              end
  end

  def sorted_by_title
    session[:sort] = 'title'
    redirect_to root_url
  end

  def sorted_by_date
    session[:sort] = 'release_date'
    redirect_to root_url
  end

  def updated_ratings
    session[:ratings] = params[:ratings].keys if params[:ratings]
    redirect_to root_url
  end

  # default: render 'new' template
  def new; end

  def create
    @movie = Movie.create!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully updated."
    redirect_to movie_path(@movie)
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end
end
