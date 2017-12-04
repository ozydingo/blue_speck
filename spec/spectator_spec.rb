require "spec_helper"

describe Despecable::Spectator do
  describe ".string" do
    context "without restricted parameter values" do
      it "specs a param" do
        params = {"name" => "foo"}
        spectator = Despecable::Spectator.new(params)
        spec = spectator.string("name")
        expect(spec).to eq("foo")
        expect(spectator.specd).to eq(["name"])
      end
    end

    context "with restricted parameter values" do
      context "with a valid string parameter" do
        it "specs the param" do
          params = {"name" => "foo"}
          spectator = Despecable::Spectator.new(params)
          spec = spectator.string("name", {in: ["foo", "bar"]})
          expect(spec).to eq("foo")
          expect(spectator.specd).to eq(["name"])
        end
      end

      context "with an invalid string parameter" do
        it "raises an error" do
          params = {"name" => "woof"}
          spectator = Despecable::Spectator.new(params)
          expect { spectator.string("name", {in: ["foo", "bar"]}) }.to raise_error(Despecable::IncorrectParameterError, "Incorrect value for parameter 'name'. Value received: woof.")
        end
      end
    end

    context "with a required parameter" do
      context "when the parameter is passed" do
        it "specs the param" do
          params = {"folder_name" => "Projects"}
          spectator = Despecable::Spectator.new(params)
          spec = spectator.string("folder_name", {required: true})
          expect(spec).to eq("Projects")
          expect(spectator.specd).to eq(["folder_name"])
        end
      end

      context "when the parameter is missing" do
        it "raises an error" do
          params = {}
          spectator = Despecable::Spectator.new(params)
          expect { spectator.string("folder_name", {required: true}) }.to raise_error(Despecable::MissingParameterError, "Missing required parameter 'folder_name'.")
        end
      end
    end

    context "with an arrayable param" do
      it "splits when commas are present" do
        params = {"character_name" => "Homer,Marge Simpson"}
        spectator = Despecable::Spectator.new(params)
        spec = spectator.string("character_name", {arrayable: true})
        expect(spec).to eq(["Homer", "Marge Simpson"])
        expect(spectator.specd).to eq(["character_name"])
      end

      it "does not split if there are no commas" do
        params = {"character_name" => "Homer Marge"}
        spectator = Despecable::Spectator.new(params)
        spec = spectator.string("character_name", {arrayable: true})
        expect(spec).to eq("Homer Marge")
        expect(spectator.specd).to eq(["character_name"])
      end
    end

    context "with an array param" do
      context "when one value is passed" do
        it "specs the param into an array" do
          params = {"character_name" => "Doug"}
          spectator = Despecable::Spectator.new(params)
          spec = spectator.string("character_name", {array: true})
          expect(spec).to eq(["Doug"])
          expect(spectator.specd).to eq(["character_name"])
        end
      end

      context "when multiple values are passed and separated by commas" do
        it "specs the values as an array" do
          params = {"character_name" => "Doug,Patty Mayonaise"}
          spectator = Despecable::Spectator.new(params)
          spec = spectator.string("character_name", {array: true})
          expect(spec).to eq(["Doug", "Patty Mayonaise"])
          expect(spectator.specd).to eq(["character_name"])
        end
      end

      context "when multiple values are passed but not separated by commas" do
        it "specs the values as an array" do
          params = {"character_name" => "Doug Patty Mayonaise"}
          spectator = Despecable::Spectator.new(params)
          spec = spectator.string("character_name", {array: true})
          expect(spec).to eq(["Doug Patty Mayonaise"])
          expect(spectator.specd).to eq(["character_name"])
        end
      end
    end

    context "when multiple values are supplied to a non arrayble param" do
      it "specs just the values as one string" do
        params =  {"annoying_rock_stars" => "Bono,Ted Nugent"}
        spectator = Despecable::Spectator.new(params)
        spec = spectator.string("annoying_rock_stars")
        expect(spec).to eq("Bono,Ted Nugent")
        expect(spectator.specd).to eq(["annoying_rock_stars"])
      end
    end

    context "with a default value" do
      it "assigns a default value when one isn't passed" do
        params = {}
        spectator = Despecable::Spectator.new(params)
        spec = spectator.string("access_level", {default: "account"} )
        expect(spec).to eq("account")
        expect(spectator.specd).to eq(["access_level"])
      end
    end
  end

  describe ".boolean" do
    context "when supplied a digit boolean" do
      it "returns true for 1" do
        params = {"active" => "1"}
        spectator = Despecable::Spectator.new(params)
        spec = spectator.boolean("active")
        expect(spec).to eq(true)
        expect(spectator.specd).to eq(["active"])
      end

      it "returns false for 0" do
        params = {"active" => "0"}
        spectator = Despecable::Spectator.new(params)
        spec = spectator.boolean("active")
        expect(spec).to eq(false)
        expect(spectator.specd).to eq(["active"])
      end
    end

    context "when supplied a string boolean" do
      it "returns true for true" do
        params = {"active" => "true"}
        spectator = Despecable::Spectator.new(params)
        spec = spectator.boolean("active")
        expect(spec).to eq(true)
        expect(spectator.specd).to eq(["active"])
      end

      it "returns false for false" do
        params = {"active" => "false"}
        spectator = Despecable::Spectator.new(params)
        spec = spectator.boolean("active")
        expect(spec).to eq(false)
        expect(spectator.specd).to eq(["active"])
      end
    end

    context "when supplied an invalid boolean value" do
      it "raises an error" do
        params = {"active" => "paranoidandroid"}
        spectator = Despecable::Spectator.new(params)
        expect{ spectator.boolean("active") }.to raise_error(Despecable::InvalidParameterError, "Invalid value for parameter 'active'. Required type: boolean (1/0 or true/false)")
      end
    end
  end

  describe ".date" do
    context "when supplied a valid date" do
      it "specs the param" do
        params = {"start_date" => "1994-05-07"}
        spectator = Despecable::Spectator.new(params)
        spec = spectator.date("start_date")
        expect(spec).to eq(Date.rfc3339("1994-05-07T00:00:00+00:00"))
        expect(spectator.specd).to eq(["start_date"])
      end
    end

    context "when supplied an invalid date" do
      it "raises an error" do
        params = {"start_date" => "1994-5-7"}
        spectator = Despecable::Spectator.new(params)
        expect {spectator.date("start_date")}.to raise_error(Despecable::InvalidParameterError, "Invalid value for parameter 'start_date'. Required type: date (e.g. '2012-12-31').")
      end
    end
  end

  describe ".datetime" do
    context "when supplied a valid datetime" do
      it "specs the param" do
        params = {"start_date" => "1977-05-07T00:00:00-04:00"}
        spectator = Despecable::Spectator.new(params)
        spec = spectator.datetime("start_date")
        expect(spec).to eq(DateTime.rfc3339("1977-05-07T00:00:00-04:00"))
        expect(spectator.specd).to eq(["start_date"])
      end
    end

    context "when supplied an invalid datetime" do
      it "raises an error" do
        params = {"start_date" => "May 5 2017"}
        spectator = Despecable::Spectator.new(params)
        expect {spectator.datetime("start_date")}.to raise_error(Despecable::InvalidParameterError, "Invalid value for parameter 'start_date'. Required type: rfc3339 datetime (e.g. '2009-06-19T00:00:00-04:00').")
      end
    end
  end

  describe ".float" do
    context "when supplied a valid float" do
      it "specs the parameter" do
        params = {"price" => "1.5"}
        spectator = Despecable::Spectator.new(params)
        spec = spectator.float("price")
        expect(spec).to eq(1.5)
        expect(spectator.specd).to eq(["price"])
      end
    end

    context "when supplied an invalid float" do
      it "raises an error" do
        params = {"price" => "one hundred"}
        spectator = Despecable::Spectator.new(params)
        expect {spectator.float("price")}.to raise_error(Despecable::InvalidParameterError, "Invalid value for parameter 'price'. Required type: float")
      end
    end
  end

  describe ".file" do
    context "when supplied a valid file" do
      it "raises an error"
    end

    context "when supplied an invalid file" do
      it "raises an error"
    end

  end

  describe ".any" do
    context "when supplied a string" do
      it "specs the param" do
        params = {"name" => "foo"}
        spectator = Despecable::Spectator.new(params)
        spec = spectator.any("name")
        expect(spec).to eq("foo")
        expect(spectator.specd).to eq(["name"])
      end
    end

    context "when supplied an integer" do
      it "specs the param" do
        params = {"id" => 1234}
        spectator = Despecable::Spectator.new(params)
        spec = spectator.any("id")
        expect(spec).to eq(1234)
        expect(spectator.specd).to eq(["id"])
      end
    end

  end

  describe ".integer" do
    context "when supplied a valid integer" do
      it "specs the param" do
        params = {"file_id" => "16"}
        spectator = Despecable::Spectator.new(params)
        spec = spectator.integer("file_id")
        expect(spec).to eq(16)
        expect(spectator.specd).to eq(["file_id"])
      end
    end

    context "when supplied an invalid integer" do
      it "raises an error" do
        params = {"file_id" => "oixjs9u0902"}
        spectator = Despecable::Spectator.new(params)
        expect{ spectator.integer("file_id") }.to raise_error(Despecable::InvalidParameterError, "Invalid value for parameter 'file_id'. Required type: integer")
      end
    end
  end
end
