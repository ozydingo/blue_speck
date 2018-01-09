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

    def speculate(action)
      route = @routes.find{|route| route.defaults[:action] == action.to_s} or raise "No action #{action} found in routes"
      info = route_info(route)
      spec = Despecable::Specialist.new(controller).spec(action)
      puts "-----"
      puts "#{info[:method]} #{action} #{info[:path]}"
      puts spec.map{|paramspec| "  #{paramspec}"}
    end
  end
end
