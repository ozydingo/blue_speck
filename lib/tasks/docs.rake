namespace :despecable do
  namespace :docs do
    desc "Generate a template yml file containing the routes to be doc'd"
    task :template => :environment do
      begin
        template = ENV['template']
        if template.nil?
          existing = {}
          output = $stdout
          $stderr.puts "Writing output to terminal"
        else
          existing = File.exists?(template) ? YAML.load(File.read(template)) : {}
          if !existing.is_a?(Hash)
            $stderr.puts "Data at #{template} appears to be corrupt. It should be a yamli-ized Hash of controllers and actions with descriptions. Please remove or fix the file and try again; run this task with a new file as output to see what the output should look like."
            exit(1)
          end
          output = File.open(template, 'w')
          $stderr.puts "Writing output to #{template}"
        end
        Rails.application.eager_load!
        base = ENV['base']
        if base.nil?
          resp = "~"
          $stderr.puts "You have not specified a root controller. This will template your ENTIRE controller structure. It is more typical to specify a controller such as a root ApiController."
          $stderr.puts "Note: you can suppress this message by specifying `base=ActionController::Base`"
          while resp != "y" && resp != "n"
            $stderr.print "Are you sure you want to continue (Y/n)? "
            $stderr.flush
            resp = $stdin.gets.chomp.downcase
            resp = "y" if resp.empty?
          end
          exit if resp == "n"
        end
        base = ENV['base'] ? ENV['base'].constantize : ActionController::Base
        $stderr.puts "Mapping routes under #{base}"
        controllers = base.descendants
        output.puts "---"
        $stdout.puts "---" if output.is_a?(File)
        controllers.each do |controller|
          existing_info = existing[controller.to_s] || {}
          router = Despecable::ActionDispatchRouting.new(controller)
          output.puts "#{controller}:"
          $stdout.puts "#{controller}:" if output.is_a?(File)
          router.routes.each do |route|
            info = router.route_info(route)
            key = "#{info[:method]} #{info[:path]}"
            description = existing_info[key] || "# enter description"
            output.puts "  #{key}: #{description}"
            $stdout.puts "  #{key}: #{description}" if output.is_a?(File)
          end
        end
        $stderr.puts "Done!"
      ensure
        output.close if output.is_a?(File)
      end
    end

    desc "Auto-generate API docs from despecable usage in your controllers"
    task :generate => :environment do
      template = ENV['template'] or raise "No template file provided, please use `template=path/to/file` in rake task invocation."
      controllers = YAML.load(File.read(template))
      $stderr.puts controllers
      controllers.each do |controller, keys|
        next if keys.nil?
        router = Despecable::ActionDispatchRouting.new(controller.constantize)
        infos = router.routes.map{|route| router.route_info(route)}
        keys.each do |key, description|
          method, path = key.split(" ")
          info = infos.find{|infum| infum[:method] == method && infum[:path] == path} or next
          router.print_table(info[:action], description)
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
