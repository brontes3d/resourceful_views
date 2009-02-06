# require 'resourceful_views'
$:.unshift "#{File.dirname(__FILE__)}/lib"
require 'resourceful_views_helper'
require 'resourceful_views'

ActionController::Base.helper ResourcefulViewsHelper

ActionController::Base.class_eval do
  include ResourcefulViews::ActionControllerExtensions
end

if ActionController::Base.private_instance_methods.include?('template_exists?')
  #Rails 2.2 and earlier:
  require 'rails22_hooks'
else
  #Rails 2.3 and later:
  require 'rails23_hooks'
end
