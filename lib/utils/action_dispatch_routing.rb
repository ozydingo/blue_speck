module Despecable
  class ActionDispatchRouting
    attr_reader :controller, :routes

    def initialize(controller)
      controller.is_a?(Class) or raise TypeError, "ActionController::Base subclass expected, got #{controller.class}"
      controller < ::ActionController::Base or raise TypeError, "ActionController::Base subclass expected, got #{controller}"
      @controller = controller
      @routes = Rails.application.routes.set.to_a.select{|route| route.defaults[:controller] == ctrl_path}
    end

    def inspect
      "#<0x#{(self.class.object_id << 1).to_s(16)} @controller=#{@controller}>"
    end

    def ctrl_path
      @controller.to_s.split("::").map(&:underscore).join("/").sub(/_controller$/,"")
    end

    def resource_name
      @controller.to_s.demodulize.underscore.sub(/_controller$/,"").singularize.humanize
    end

    def describe_all
      routes.map do |route|
        route_info(route).merge(params: Despecable::Specialist.new(@controller).spec(route.defaults[:action]))
      end
    end

    def route_info(route)
      {
        name: route.name,
        controller: route.defaults[:controller],
        method: /\^([^$]*)\$/ =~ route.constraints[:request_method].to_s && $1.to_s.upcase,
        subdomain: route.defaults[:subdomain],
        path: route.path.spec.to_s.sub(/\(\.:format\)$/, ""),
        action: route.defaults[:action]
      }
    end

    # TODO: put this in some output adapter class
    def print_table(action, description = nil)
      route = @routes.find{|route| route.defaults[:action] == action.to_s} or raise "No action #{action} found in routes"
      info = route_info(route)
      spec = Despecable::Specialist.new(controller).spec(action)
      puts "<h3>#{resource_name.titleize} #{action.upcase}</h3>"
      puts "<table class='despecable route'>"
      puts "<tr>"
      puts "<td class=label> Method / URL </td>"
      puts "<td class=data> #{info[:method]} #{info[:path]} </td>"
      puts "</tr>"
      puts "<tr>"
      puts "<td class=label> Description </td>"
      puts "<td class=data> #{description} </td>"
      puts "</tr>"
      puts "<tr>"
      puts "<td class=label> Parameters </td>"
      puts "<td class=data>"
      spec.each do |speck|
        print "#{speck[:name]} ["
        print speck[:type]
        print "(s)" if speck[:array] || speck[:arrayble]
        print " (#{speck[:default]})" if speck[:default]
        print ", required" if speck[:required]
        puts "]"
        if speck[:in]
          puts "<br>"
          puts "&nbsp;&nbsp;(allowed values: #{speck[:in]})"
        end
        puts "<br>"
      end
      puts "</tr>"
      puts "</table>"
    end
  end
end
