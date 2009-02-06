ActionView::Base.class_eval do

  def _pick_template_with_extra_default_paths(template_path)
    begin
      _pick_template_without_extra_default_paths(template_path)
    rescue ActionView::MissingTemplate => e

      template_exists_checker = Proc.new do |template_name|
        begin
          _pick_template_without_extra_default_paths(template_name) ? true : false
        rescue ActionView::MissingTemplate
          false
        end
      end

      theme = nil
      if self.respond_to?(:controller)
        if controller.respond_to?(:resourceful_views_theme)
          theme = controller.resourceful_views_theme(controller.action_name)
        end
      end

      template_path = ResourcefulViews.determine_view_path_from_parts(template_path.split("/"), theme) do |path_base, path_last|
        template_exists_checker.call("#{path_base}/#{path_last}")
      end
      if template_path
        _pick_template_without_extra_default_paths(template_path)
      else
        raise e
      end
    end
  end
  
  alias_method_chain :_pick_template, :extra_default_paths

end