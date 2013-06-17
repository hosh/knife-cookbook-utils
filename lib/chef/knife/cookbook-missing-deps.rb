require 'rlet'
require 'ap'

module KnifeCookbookUtils
  class CookbookMissingDeps < Chef::Knife
    include Let

    banner "knife cookbook missing deps (options)"

    option :purge,
      :long        => "--purge",
      :description => "Purges cookbooks with missing deps"

    # A map of all cookbooks and versions
    let(:all_cookbooks) do
      Hash.new.tap do |cookbooks|
        rest.get("cookbooks/?num_versions=all").each do |cookbook, info|
          info['versions'].each do |version_info|
            # We cannot use Hash.new to initialize a new hash, since it will try to
            # add a new key while iterating
            cookbooks[cookbook] ||= {}
            cookbooks[cookbook][version_info['version']] = version_info['url']
          end
        end
      end
    end

    let(:missing_deps) do
      Hash.new.tap do |deps|
        all_cookbooks.each do |cookbook_name, versions|
          versions.each do |cookbook_version, cookbook_url|
            Chef::Log.info("Checking deps for #{cookbook_name} #{cookbook_version}")
            cookbook = rest.get("cookbooks/#{cookbook_name}/#{cookbook_version}")
            cookbook.manifest['metadata']['dependencies'].each do |dep_cookbook_name, dep_constraint|
              _constraint = Chef::VersionConstraint.new(dep_constraint)
              available_versions = (all_cookbooks[dep_cookbook_name] || {}).keys.flatten
              next if available_versions.any? { |c| _constraint.include?(c) }
              Chef::Log.info("  Unsatisfied constraint: #{dep_cookbook_name} #{dep_constraint}")
              deps[[cookbook_name, cookbook_version]] ||= []
              deps[[cookbook_name, cookbook_version]] << [dep_cookbook_name, dep_constraint]
            end
          end
        end
      end
    end

    def run
      puts "Missing dependencies:" if missing_deps.any?
      missing_deps.each do |cookbook, missing_deps|
        puts "#{cookbook[0]} #{cookbook[1]}"
        missing_deps.each { |dep_name, dep_constraint| puts "  #{dep_name} #{dep_constraint}" }
      end

      puts "To delete these cookbooks, use: knife cookbook missing deps --purge" if missing_deps.any? and !config[:purge]
      return unless config[:purge] and missing_deps.any?

      puts "Purging cookbooks with missing dependencies"
      missing_deps.keys.each do |cookbook_name, cookbook_version|
        puts "Deleting #{cookbook_name} #{cookbook_version}"
        rest.delete("cookbooks/#{cookbook_name}/#{cookbook_version}")
      end
    end

  end
end

