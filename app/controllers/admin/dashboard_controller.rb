class Admin::DashboardController < Admin::BaseController
 
  layout "admin"

  def index
  end

  def cache
    if Rails.cache.clear
      flash[:success] = "Cache Cleared"
    else
      flash[:error] = "Try Again"
    end

    redirect_to admin_dashboard_index_path
  end

  def report
    @report = Report::Export.new
    csv     = @report.get_csv

    if csv 
      send_data(csv, :filename => "WhiteElephant#{DateTime.now.strftime('%Y%m%d%H%M')}.csv")
    else
      flash[:error] = "Could not get data"
      redirect_to admin_dashboard_index_path
    end
  end
  
end