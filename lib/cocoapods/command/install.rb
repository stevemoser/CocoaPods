require 'gh_inspector'

module Pod
  class Command
    class Install < Command
      include RepoUpdate
      include ProjectDirectory

      self.summary = 'Install project dependencies according to versions from a Podfile.lock'

      self.description = <<-DESC
        Downloads all dependencies defined in `Podfile` and creates an Xcode
        Pods library project in `./Pods`.

        The Xcode project file should be specified in your `Podfile` like this:

            project 'path/to/XcodeProject.xcodeproj'

        If no project is specified, then a search for an Xcode project will
        be made. If more than one Xcode project is found, the command will
        raise an error.

        This will configure the project to reference the Pods static library,
        add a build configuration file, and add a post build script to copy
        Pod resources.
      DESC

      def self.options
        [
          ['--repo-update', 'Force running `pod repo update` before install'],
        ].concat(super).reject { |(name, _)| name == '--no-repo-update' }
      end

      def run
        verify_podfile_exists!
        installer = installer_for_config
        installer.repo_update = repo_update?(:default => false)
        installer.update = false
        installer.install!
      rescue StandardError => e
        search_for_exceptions(e)
        raise e
      end

      def search_for_exceptions(exception)
        inspector = GhInspector::Inspector.new 'cocoapods', 'cocoapods'
        message_delegate = UserInterface::InspectorReporter.new
        inspector.search_exception exception, message_delegate
      end
    end
  end
end
