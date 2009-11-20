# require 'resourceful_views'
$:.unshift "#{File.dirname(__FILE__)}/lib"
require 'resourceful_views_helper'
require 'resourceful_views'

ActionController::Base.helper ResourcefulViewsHelper
ActionView::Base.class_eval do
  include ResourcefulViewsHelper
end

ActionController::Base.class_eval do
  include ResourcefulViews::ActionControllerExtensions
end

require 'rails23_hooks'