class Portal::FavoritesController < ApplicationController
  def create
    teacher = Portal::Teacher.find params[:teacher]
    runnable_type = params[:type].classify.constantize
    runnable = runnable_type.find params[:runnable]
    favorite = teacher.favorites.create :favoritable => runnable
    redirect_to :back
  end

  def destroy
    runnable_type = params[:type].classify.constantize
    runnable = runnable_type.find params[:runnable]
    favorite = Favorite.find_by_favoritable_id_and_favoritable_type runnable.id, runnable_type.to_s
    favorite.destroy
    redirect_to :back
  end
end
