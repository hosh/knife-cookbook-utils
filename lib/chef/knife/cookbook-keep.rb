require 'rlet'

module KnifeCookbookUtils
  class CookbookKeep < Chef::Knife
    include Let

    banner "knife cookbook keep NUM (options)"

    option :purge_old,
      :long => "--purge-old",
      :description => "Purges older cookbook versions from the chef server"

    let(:num_to_keep) { parsed_arg0 < 1 ? 1 : parsed_arg0 }
    let(:dry_run?)    { !config[:purge_old] }
    let(:parsed_arg0) { @name_args[0].to_i }

    let(:cookbooks_to_delete) do
      all_cookbooks.
        map { |name, versions| versions.drop(num_to_keep).map { |version, url| [name, version, url] } }.
        flatten(1)
    end

    let(:all_cookbooks) do
      raw_cookbook_listing.map do |name, info|
        [ name, info['versions'].map(&to_version_and_url) ]
      end
    end

    let(:to_version_and_url)   { lambda { |v| [Chef::Version.new(v['version']), v['url']] } }
    let(:raw_cookbook_listing) { rest.get("cookbooks/?num_versions=all") }

    def run
      puts "Keeping latest #{num_to_keep} versions of cookbooks"
      puts "DRY RUN" if dry_run?
      puts "Will delete the following:", ""

      cookbooks_to_delete.each do |cookbook, version, url|
        puts "#{cookbook} #{version}"
      end

      puts ""
      puts "To delete these cookbooks, use:"
      puts ""
      puts "knife cookbook keep #{num_to_keep} --purge-old"
      puts ""
    end
  end
end
