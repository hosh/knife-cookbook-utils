require 'rlet'

module KnifeCookbookUtils
  class CookbookMissingDeps < Chef::Knife
    include Let

    banner "knife cookbook missing deps (options)"

    option :purge,
      :long        => "--purge",
      :description => "Purges cookbooks with missing deps"

    # A map of all cookbooks and versions
    let(:all_cookbooks) do
      Hash.new { |h, key| h[key] = {} }.tap do |cookbooks|
        rest.get("cookbooks/?num_versions=all").each do |cookbook, info|
          info['versions'].each do |version_info|
            cookbooks[cookbook][version_info['version']] = version_info['url']
          end
        end
      end
    end

    let(:missing_deps) do
      [].tap do |deps|
        all_cookbooks.each do |cookbook_name, versions|
          versions.each do |cookbook_version, cookbook_url|
            cookbook = rest.get("cookbooks/#{cookbook_name}/#{cookbook_version}")
            cookbook.manifest['metadata']['dependencies'].each do |dep_cookbook_name, dep_constraint|
              _constraint = Chef::VersionConstraint.new(dep_constraint)
              available_versions = all_cookbooks[dep_cookbook_name].keys.flatten
              next if available_versions.any? { |c| _constraint.include?(c) }
              deps << [dep_cookbook_name, dep_constraint]
            end
          end
        end
      end
    end

    def run
      puts missing_deps
    end

  end
end

