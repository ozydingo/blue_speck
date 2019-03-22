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
    it "returns but does not overwrite parsed params" do
      params = ActionController::Parameters.new({integer: "1", string: "hello"})
      controller = Controller.new(params)
      parsed_params = controller.despec do
        integer :integer
      end
      expect(parsed_params[:integer]).to eq(1)
      expect(params[:integer]).to eq("1")
      expect(parsed_params[:string]).to eq("hello")
      expect(params[:string]).to eq("hello")
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
  end

  describe ".despec!" do
    it "overwrites parsed params" do
      params = ActionController::Parameters.new({integer: "1", string: "hello"})
      controller = Controller.new(params)
      parsed_params = controller.despec! do
        integer :integer
      end
      expect(parsed_params[:integer]).to eq(1)
      expect(params[:integer]).to eq(1)
      expect(parsed_params[:string]).to eq("hello")
      expect(params[:string]).to eq("hello")
    end
  end
end
