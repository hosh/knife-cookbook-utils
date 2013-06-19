require 'spec_helper'
require 'chef/knife/cookbook-missing-deps'

describe KnifeCookbookUtils::CookbookMissingDeps do

  let(:command) do
    KnifeCookbookUtils::CookbookMissingDeps.new.
      tap(&with_cookbook_listing).
      tap(&with_dependency_check)
  end

  let(:with_cookbook_listing) { with_stub.(:raw_cookbook_listing, raw_cookbook_listing) }
  let(:with_dependency_check) { ->(x) { x.stub(:dependencies_for_cookbook_version, &dependencies_for_cookbook_version)} }
  let(:with_stub)             { ->(stub_name, returns) { ->(x) { x.stub!(stub_name).and_return(returns) } } }

  let(:dependencies_for_cookbook_version) { ->(name, version) { {} } }

  let(:raw_cookbook_listing) do
    {
      "nginx"=>{
        "url"=>"https://api.opscode.com/organizations/example-org/cookbooks/rbenv",
        "versions"=>[
          {"version"=>"1.7.0", "url"=>"https://api.opscode.com/organizations/example-org/cookbooks/nginx/1.7.0"},
          {"version"=>"1.6.0", "url"=>"https://api.opscode.com/organizations/example-org/cookbooks/nginx/1.6.0"},
          {"version"=>"1.4.0", "url"=>"https://api.opscode.com/organizations/example-org/cookbooks/nginx/1.4.0"},
       ]},
      "rbenv"=>{
        "url"=>"https://api.opscode.com/organizations/example-org/cookbooks/rbenv",
        "versions"=>[
          {"version"=>"1.4.1", "url"=>"https://api.opscode.com/organizations/example-org/cookbooks/rbenv/1.4.1"},
          {"version"=>"1.4.0", "url"=>"https://api.opscode.com/organizations/example-org/cookbooks/rbenv/1.4.0"},
       ]},
      "postgresql"=>{
        "url"=>"https://api.opscode.com/organizations/example-org/cookbooks/postgresql",
        "versions"=>[{"version"=>"3.0.0", "url"=>"https://api.opscode.com/organizations/example-org/cookbooks/postgresql/3.0.0"}]},
    }
  end

  describe "#all_cookbooks" do
    subject { command.all_cookbooks }
    let(:expected) do
      {
        "nginx" => {
          "1.7.0" => "https://api.opscode.com/organizations/example-org/cookbooks/nginx/1.7.0",
          "1.6.0" => "https://api.opscode.com/organizations/example-org/cookbooks/nginx/1.6.0",
          "1.4.0" => "https://api.opscode.com/organizations/example-org/cookbooks/nginx/1.4.0", },
        "rbenv" => {
          "1.4.1" => "https://api.opscode.com/organizations/example-org/cookbooks/rbenv/1.4.1",
          "1.4.0" => "https://api.opscode.com/organizations/example-org/cookbooks/rbenv/1.4.0" },
        "postgresql" => {
          "3.0.0" => "https://api.opscode.com/organizations/example-org/cookbooks/postgresql/3.0.0" }
      }
    end

    it "should return a map of all cookbook and versions" do
      should eql expected
    end
  end

  describe "#missing_deps" do
    subject { command.missing_deps }

    context "without missing deps" do
      it { should eql Hash.new }
    end

    context "with missing deps" do
      let(:dependencies_for_cookbook_version) do
        proc do |name, version|
          if name == 'rbenv' and version == '1.4.1'
            { 'ohai' => '>= 1.1' }
          else
            { }
          end
        end
      end

      let(:expected) { { ['rbenv', '1.4.1'] => [['ohai', '>= 1.1']] } }

      it "should return a map of missing deps" do
        should eql expected
      end

    end
  end
end
