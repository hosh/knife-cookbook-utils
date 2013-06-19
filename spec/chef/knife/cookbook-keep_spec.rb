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
  let(:raw_cookbook_listing) { fail 'Must define let(:raw_cookbook_listing' }
  let(:cookbooks_with_one_version) do
    {
      "rbenv"=>{
        "url"=>"https://api.opscode.com/organizations/example-org/cookbooks/rbenv",
        "versions"=>[{"version"=>"1.4.1", "url"=>"https://api.opscode.com/organizations/example-org/cookbooks/rbenv/1.4.1"}]},
      "postgresql"=>{
        "url"=>"https://api.opscode.com/organizations/example-org/cookbooks/postgresql",
        "versions"=>[{"version"=>"3.0.0", "url"=>"https://api.opscode.com/organizations/example-org/cookbooks/postgresql/3.0.0"}]},
    }
  end

  let(:cookbooks_with_two_versions) do
    {
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

  let(:cookbooks_with_three_versions) do
    {
      "nginx"=>{
        "url"=>"https://api.opscode.com/organizations/example-org/cookbooks/rbenv",
        "versions"=>[
          {"version"=>"1.7.0", "url"=>"https://api.opscode.com/organizations/example-org/cookbooks/rbenv/1.7.0"},
          {"version"=>"1.6.0", "url"=>"https://api.opscode.com/organizations/example-org/cookbooks/rbenv/1.6.0"},
          {"version"=>"1.4.0", "url"=>"https://api.opscode.com/organizations/example-org/cookbooks/rbenv/1.4.0"},
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

  describe "#cookbooks_to_keep" do
    subject { command.cookbooks_to_keep }

    context "with only one cookbook version" do
      let(:raw_cookbook_listing) { cookbooks_with_one_version }

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

    context "with only two cookbook version" do
      let(:raw_cookbook_listing) { cookbooks_with_two_versions }

      context "when keeping latest version" do
        let(:num_to_keep) { 1 }
        it "should only keep latest version" do
          should eql [ ['rbenv', version.('1.4.1')], ['postgresql', version.('3.0.0')] ]
        end
      end

      context "when keeping latest 2 versions" do
        let(:num_to_keep) { 2 }
        it "should only keep latest 2 versions" do
          should eql [ ['rbenv', version.('1.4.1')], ['rbenv', version.('1.4.0')], ['postgresql', version.('3.0.0')] ]
        end
      end
    end

    context "with only three cookbook version" do
      let(:raw_cookbook_listing) { cookbooks_with_three_versions }

      context "when keeping latest version" do
        let(:num_to_keep) { 1 }
        it "should only keep latest version" do
          should eql [ ['nginx', version.('1.7.0') ], ['rbenv', version.('1.4.1')], ['postgresql', version.('3.0.0')] ]
        end
      end

      context "when keeping latest 2 versions" do
        let(:num_to_keep) { 2 }
        it "should only keep latest 2 versions" do
          should eql [
            ['nginx', version.('1.7.0')],
            ['nginx', version.('1.6.0')],
            ['rbenv', version.('1.4.1')],
            ['rbenv', version.('1.4.0')],
            ['postgresql', version.('3.0.0')] ]
        end
      end

      context "when keeping latest 3 versions" do
        let(:num_to_keep) { 3 }
        it "should only keep latest 3 versions" do
          should eql [
            ['nginx', version.('1.7.0')],
            ['nginx', version.('1.6.0')],
            ['nginx', version.('1.4.0')],
            ['rbenv', version.('1.4.1')],
            ['rbenv', version.('1.4.0')],
            ['postgresql', version.('3.0.0')] ]
        end
      end
    end # with only three cookbook versions
  end # #cookbooks_to_keep
end
