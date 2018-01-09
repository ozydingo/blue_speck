namespace :despecable do
  namespace :docs do
    desc "Generate a template yml file containing the routes to be doc'd"
    # TODO: preserve existing descriptions from specified file
    task :template => :environment do
      template = ENV['template']
      existing = template ? YAML.load(File.read(template)) : {}
      Rails.application.eager_load!
      base = ENV['base'] ? ENV['base'].constantize : ActionController::Base
      $stderr.puts "Mapping routes under #{base}"
      controllers = base.descendants
      puts "---"
      controllers.each do |controller|
        existing_info = existing[controller.to_s] || {}
        router = Despecable::ActionDispatchRouting.new(controller)
        puts "#{controller}:"
        router.routes.each do |route|
          action = route.defaults[:action]
          description = existing_info[action] || "# enter description"
          puts "  #{route.defaults[:action]}: #{description}"
        end
      end
      $stderr.puts "Done!"
    end

    desc "Auto-generate API docs from despecable usage in your controllers"
    task :generate => :environment do
      template = ENV['template'] or raise "No template file provided, please use `template=path/to/file` in rake task invocation."
      controllers = YAML.load(File.read(template))
      $stderr.puts controllers
      controllers.each do |controller, actions|
        next if actions.nil?
        router = Despecable::ActionDispatchRouting.new(controller.constantize)
        actions.each do |action, description|
          router.print_table(action, description)
        end
      end
    end
  end
end

# {
#   alias: route.name,
#   path: route.path.spec.to_s,
#   controller: route.defaults[:controller],
#   method: /\^([^$]*)\$/ =~ route.constraints[:request_method].to_s && $1,
#   subdomain: route.defaults[:subdomain],
#   action: route.defaults[:action]
# }
