require 'spec_helper'
require 'chef/knife/cookbook-missing-deps'

describe KnifeCookbookUtils::CookbookMissingDeps do

  let(:command) do
    KnifeCookbookUtils::CookbookMissingDeps.new.
      tap(&with_cookbook_listing)
  end

  let(:with_cookbook_listing) { with_stub.(:raw_cookbook_listing, raw_cookbook_listing) }
  let(:with_stub)             { ->(stub_name, returns) { ->(x) { x.stub!(stub_name).and_return(returns) } } }

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
end
