#
# Cookbook: maven
# License: Apache 2.0
#
# Copyright 2008-2015, Chef Software, Inc.
# Copyright 2015, Bloomberg Finance L.P.
#
require 'poise'

module MavenCookbook
  module Resource
    # A resource which executes Maven commands.
    # @since 2.0.0
    class MavenExecute < Chef::Resource
      include Poise(fused: true)
      provides(:maven_execute)

      attribute(:directory, kind_of: String, default: '/var/run/java')
      attribute(:user, kind_of: String, default: 'root')
      attribute(:group, kind_of: String, default: 'root')

      attribute(:command, kind_of: String, name_attribute: true)
      attribute(:environment, kind_of: Hash, default: lazy { default_environment })
      attribute(:options, option_collector: true)

      def default_environment
        {
          'PATH' => '/usr/local/bin:/usr/bin:/bin',
          'HOME' => Dir.home(user)
        }
      end

      action(:run) do
        options = new_resource.options.delete_if { |_, v| v.nil? }.map { |kv| '-D' + kv.join('=') }
        notifying_block do
          execute "mvn #{new_resource.command}" do # ~FC009
            command ['mvn', new_resource.command, options].flatten.map(&:strip).join(' ')
            user new_resource.user
            group new_resource.group
            cwd new_resource.directory
            environment new_resource.environment
            sensitive true
          end
        end
      end
    end
  end
end
