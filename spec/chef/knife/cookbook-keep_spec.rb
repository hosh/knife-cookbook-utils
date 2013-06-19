require 'spec_helper'
require 'chef/knife/cookbook-keep'

describe KnifeCookbookUtils::CookbookKeep do

  let(:command) do
    KnifeCookbookUtils::CookbookKeep.new.
      tap(&with_cookbook_listing).
      tap(&with_num_to_keep)
  end

  let(:with_num_to_keep)      { with_stub.(:num_to_keep, num_to_keep) }
  let(:with_cookbook_listing) { with_stub.(:raw_cookbook_listing, raw_cookbook_listing) }
  let(:with_stub)             { ->(stub_name, returns) { ->(x) { x.stub!(stub_name).and_return(returns) } } }
  let(:version)               { ->(v) { Chef::Version.new(v) } }

  let(:num_to_keep) { 1 }
  let(:raw_cookbook_listing) do
    {
      "rbenv"=>{
        "url"=>"https://api.opscode.com/organizations/example-org/cookbooks/rbenv",
        "versions"=>[{"version"=>"1.4.1", "url"=>"https://api.opscode.com/organizations/example-org/cookbooks/rbenv/1.4.1"}]},
      "postgresql"=>{
        "url"=>"https://api.opscode.com/organizations/example-org/cookbooks/postgresql",
        "versions"=>[{"version"=>"3.0.0", "url"=>"https://api.opscode.com/organizations/example-org/cookbooks/postgresql/3.0.0"}]},
    }
  end

  describe "#cookbooks_to_keep" do
    subject { command.cookbooks_to_keep }

    context "with only one cookbook version" do
      context "when keeping latest version" do
        let(:num_to_keep) { 1 }
        it "should only keep latest version" do
          should eql [ ['rbenv', version.('1.4.1')], ['postgresql', version.('3.0.0')] ]
        end
      end

      context "when keeping latest 2 versions" do
        let(:num_to_keep) { 2 }
        it "should only keep latest version" do
          should eql [ ['rbenv', version.('1.4.1')], ['postgresql', version.('3.0.0')] ]
        end
      end
    end
  end
end
