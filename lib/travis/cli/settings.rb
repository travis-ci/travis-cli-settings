require 'travis/cli'
require 'json'

module Travis
  module CLI
    class Settings < RepoCommand
      description "manage repository settings"

      # We don't check settings validity on the server at this point, so validate here
      SETTINGS = {
        builds_only_with_travis_yml: "Run build only if commit contains .travis.yml file",
        build_pushes: "Build pushes to github",
        build_pull_requests: "Build pull requests"
      }

      def run(setting = nil)
        id = repository.id

        if setting
          error "Setting you provided does not exist, run travis settings to show available settings" unless valid?(setting)

          key, value = setting.split('=')
          value.strip!

          if value !~ /\Atrue|false\Z/
            # we handle only boolean values at this point
            error "Value needs to be either true or false"
          end

          value = value == "true"

          session.raw(:patch, "/repos/#{id}/settings", { :settings => { key => value } }.to_json)
          puts "#{setting.gsub(/=.*$/, '')} was updated to #{value}"
        else
          settings = session.get_raw("/repos/#{id}/settings")
          if settings = settings['settings']
            SETTINGS.each do |k, v|
              puts "#{k}: #{settings[k.to_s]} # #{v}"
            end
          else
            error "Could not fetch settings"
          end
        end
      end

      def valid?(setting)
        setting = setting.gsub(/=.*$/, '')
        SETTINGS.keys.include? setting.to_sym
      end
    end
  end
end
