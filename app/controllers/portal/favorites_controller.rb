class Portal::FavoritesController < ApplicationController
  def create
    teacher = Portal::Teacher.find params[:teacher]
    runnable_type = params[:type].classify.constantize
    runnable = runnable_type.find params[:runnable]
    teacher.favorites << runnable
    teacher.save
  end
end
