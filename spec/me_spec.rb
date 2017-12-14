require "spec_helper"

describe Despecable::Me do
  describe ".doit" do
    skip "still developing strategy" do
      before(:each) do
        @request_params = {"subdomain"=>"api", "controller"=>"api/files", "action"=>"index"}
        @default_args = []
      end

      context "in non-strict mode" do
        before(:each) do
          @strict = false
        end

        context "when supplied valid params" do
          it "returns the original params hash" do
            blk = lambda do
              string :name
            end

            query_params = {"name"=> "it's a hat"}
            full_params = @request_params.merge(query_params)
            new_me = Despecable::Me.new(full_params, query_params)
            done_it = new_me.doit(@default_args, strict: @strict, &blk)
            expect(done_it).to eq(full_params)
          end
        end

        context "when missing a required param" do
          it "raises an error"
        end

        context "when passed a param with an invalid string value" do
          it "raises an error" do
            blk = lambda do
              string :resource, in: ["account", "project"]
            end

            query_params = {"resource" => "user"}
            new_me = Despecable::Me.new(@request_params.merge(query_params), query_params)
            expect { new_me.doit(@default_args, strict: @strict, &blk) }.to raise_error(Despecable::IncorrectParameterError, "Value received: user.")
          end
        end

        context "when passed a param with an invalid integer value" do
          it "raises an error" do
            blk = lambda do
              integer :file_id, in: 1..5
            end
            query_params = {"file_id" => 6}
            new_me = Despecable::Me.new(@request_params.merge(query_params), query_params)
            expect { new_me.doit(@default_args, strict: @strict, &blk) }.to raise_error(Despecable::IncorrectParameterError, "Value received: 6.")
          end
        end

        context "when a default value is present" do
          context "when that value is not passed" do
            it "assigns the default value"
          end

          context "when the value is passed" do
            it "shows up in the params hash"
          end
        end

        context "in strict mode" do
          before(:each) do
            @strict = true
          end

          context "when passed an extraneous param" do
            it "raises an error"
          end

          context "when passed only the despecd params" do
            it "does not raise an error"
          end
        end
      end
    end
  end

  describe ".unspecd" do
    pending "Do it"
  end

  describe ".despecably_strict" do
    pending "Do it"
  end
end
