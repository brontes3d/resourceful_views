module ResourcefulViews
  
  # init.rb extends ActionController::Base with this module
  #
  # Provides controllers with:
  # * render_resource is the resourceful views version of <tt>render :action => </tt>
  # * render_resource_partial is the resourceful views version of <tt>render :partial => </tt>
  module ActionControllerExtensions
    
    # Provides ActionController::Base with resourceful_views_theme for defining the theme folder to use for a given controller 
    def self.included(base)
      base.class_eval do
        # Call this in your controller to specify the name of the themes folder to use for views on this controller
        #
        # For Example, you might make it 'admin' and then have a folder called admin which has the default views for admin resources
        #     resourceful_views_theme 'admin'
        def self.resourceful_views_theme(theme_to_use)
          self.class_eval do
            define_method(:resourceful_views_theme) do
              theme_to_use
            end
          end
        end
      end
    end
    
    # The ResourcefulViews equivalent of
    #     render :partial =>
    #
    # Call me just like you would render a partial
    # Accepts an options hash which is forwarded along to the eventualy call made to <tt>render :file => </tt>
    #
    def render_resource_partial(partial_named, options={})
      render_resource("_#{partial_named.to_s}", {:layout => false}.merge(options))
    end
  
    # The ResourcefulViews equivalent of
    #     render :action =>
    #
    # Call me just like you would render a action
    # Accepts an options hash which is forwarded along to the eventualy call made to render :file
    #
    def render_resource(action, options={})
      
      view_path = ResourcefulViews.determine_view_path(self, action, options[:theme]) do |path_base, path_last|
        template_exists?("#{path_base}/#{path_last}")
      end
      if view_path
        #So, apparently if you say "render :file"
        #then the result is rendered without a layout
        #because of in actionpack, layout.rb
        #if the following is false
        #options.values_at(:text, :xml, :json, :file, :inline, :partial, :nothing).compact.empty?
        #you get no layout
        #i.e. all of the above types of render, means render without a layout
        options = {:file => view_path, :layout => true, :use_full_path => true}.merge(options)
      else
        render :action => action.to_s and return
      end
      render options
    end
    
    #exposes private method template_exists? to the helpers
    def resource_check_template_exists?(path) #:nodoc:
      template_exists?(path)
    end
  end
    
  # Helper method for the various content_for-like methods provided by ResourcefulViewsHelper
  # 
  # Expected to be called with a block that can be used to determine if a template / erb file exists for a yielded base_path and file_name
  #
  # Checks the various combinations of such paths in the order in which they should be checked. 
  # And finally returns the combination for which yield returned true. (meaning, the one for which a template exists)
  #
  # The order of checking goes:
  # * controller folder (rails default)
  # * themes folder
  # * default folder
  # * nil
  #
  def self.determine_view_path(controller, action, theme_given_explicitly = false, &block)# :yields: base_path, file_name
    controller_name = controller.class.controller_path
    action = action.to_s
    theme = nil
    if theme_given_explicitly
      theme = theme_given_explicitly
    elsif controller.respond_to?(:resourceful_views_theme)
      theme = controller.resourceful_views_theme(action)
    end
    determine_view_path_from_parts([controller_name, action], theme, &block)
  end
  
  def self.determine_view_path_from_parts(parts, theme = nil)
    controller_name = parts.first
    action = parts.last
    if( yield "#{controller_name}", "#{action}" )
      return "#{controller_name}/#{action}"
    elsif( theme && yield("themes/#{theme}", "#{action}") )
      return "themes/#{theme}/#{action}"
    elsif( yield "default", "#{action}" )
      return "default/#{action}"
    else
      return nil
    end    
  end
  
end