module Helper2
  module HelperByPartials
    helper_dirname = 'helper'

    helper_names = Rails.configuration.paths['app/views'].map do |view_path|
      base_path = "#{Rails.root}/#{view_path}/#{helper_dirname}"
      ActionView::Template.template_handler_extensions.map do |ext|
        Dir.glob("#{base_path}/**/_*.#{ext}").map do |candidate_path|
          candidate_path.gsub(/#{base_path}\/_/, '')
        end
      end
    end.flatten

    helper_names.each do |helper_name|
      dirname, filename = File.split(helper_name)
      method_name = filename.split('.', 2)[0]

      next if self.methods.include? method_name.to_sym

      define_method method_name do |*arguments|
        options = (arguments[0]) ? arguments[0] : {}
        partial_name = "#{helper_dirname}/#{dirname}/#{method_name}"
        render partial: partial_name, locals: { options: options }
      end
    end
  end

  def self.included(klass)
    klass.class_eval { helper Helper2::HelperByPartials }
  end
end
