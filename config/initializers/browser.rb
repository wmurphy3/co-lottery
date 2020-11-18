Rails.configuration.middleware.use Browser::Middleware do
  redirect_to upgrade_path if browser.ie?(["<11"])
end