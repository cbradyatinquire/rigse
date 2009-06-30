class Admin::VendorInterfacesController < ApplicationController
  before_filter :ensure_admin
  layout "admin"
  active_scaffold :vendor_interface
  
  def ensure_admin
    unless (current_user.has_role?("admin"))
      flash[:error] = "You must be an admin to access the /admin location"
      redirect_back_or home_path
    end
  end
  
  
end