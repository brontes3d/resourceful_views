# require 'resourceful_views'
$:.unshift "#{File.dirname(__FILE__)}/lib"
require 'resourceful_views_helper'
require 'resourceful_views'

ActionController::Base.helper ResourcefulViewsHelper

ActionController::Base.class_eval do
  include ResourcefulViews::ActionControllerExtensions
end
