require "spec_helper"
require "action_controller"

# Mock controller for testint
class Controller
  include Despecable::ActionController
  attr_reader :params, :request

  def initialize(params = {})
    @params = params
    @request = Request.new(params)
  end
end

# Mock request for testing
class Request
  attr_reader :params
  alias_method :request_parameters, :params
  alias_method :query_parameters, :params

  def initialize(params)
    @params = params
  end
end

describe Despecable::ActionController do
  describe ".despec" do
    it "parses and merges params" do
      params = ActionController::Parameters.new({x: "1", y: "2", z: "3"})
      controller = Controller.new(params)
      parsed_params = controller.despec do
        integer :x
        string :y
      end
      expect(parsed_params[:x]).to eq(1)
      expect(parsed_params[:y]).to eq("2")
      expect(parsed_params[:z]).to eq("3")
    end

    it "does not overwrite params" do
      params = ActionController::Parameters.new({integer: "1"})
      controller = Controller.new(params)
      parsed_params = controller.despec do
        integer :integer
      end
      expect(params[:integer]).to eq("1")
      expect(parsed_params[:integer]).to eq(1)
    end

    it "barfs in strict mode with unspec'd params" do
      params = ActionController::Parameters.new({integer: "1", string: "hello"})
      controller = Controller.new(params)
      expect {controller.despec(strict: true) do
        integer :integer
      end}.to raise_error do |error|
        expect(error).to be_a(Despecable::UnrecognizedParameterError)
        expect(error.parameters).to eq(["string"])
      end
    end

    it "doesn't add param keys that are not requested" do
      params = ActionController::Parameters.new({x: "1", z: "3"})
      controller = Controller.new(params)
      parsed_params = controller.despec do
        integer :x
        string :y
      end
      expect(parsed_params.keys).to eq(["x", "z"])
    end
  end

  describe ".despec!" do
    it "overwrites and merges params" do
      params = ActionController::Parameters.new({x: "1", y: "2", z: "3"})
      controller = Controller.new(params)
      controller.despec! do
        integer :x
        string :y
      end
      expect(params[:x]).to eq(1)
      expect(params[:y]).to eq("2")
      expect(params[:z]).to eq("3")
    end

    it "doesn't add param keys that are not requested" do
      params = ActionController::Parameters.new({x: "1", z: "3"})
      controller = Controller.new(params)
      parsed_params = controller.despec! do
        integer :x
        string :y
      end
      expect(parsed_params.keys).to eq(["x", "z"])
    end
  end
end
