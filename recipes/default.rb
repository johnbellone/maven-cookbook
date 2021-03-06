#
# Cookbook: maven
# License: Apache 2.0
#
# Copyright 2008-2015, Chef Software, Inc.
# Copyright 2015, Bloomberg Finance L.P.
#
include_recipe 'libarchive::default'
include_recipe 'java::default'

artifact_url = node['maven']['remote_url'] % {
  major_version: node['maven']['version'].to_i,
  version: node['maven']['version']
}

basename = File.basename(artifact_url)
remote_file File.join(Chef::Config[:file_cache_path], basename) do
  source artifact_url
  mode '0755'
  checksum node['maven']['remote_checksum']
end

libarchive_file basename do
  action :nothing
  path File.join(Chef::Config[:file_cache_path], basename)
  extract_to node['maven']['extract_to']
  subscribes :extract, "remote_file[#{path}]"
end

if node['platform_family'] == 'windows'
  rc_file File.join(Dir.home, 'mavenrc_pre.bat') do
    type 'bat'
    options node['maven']['mavenrc']
  end
else
  link node['maven']['mavenrc']['M2_HOME'] do
    to File.join(node['maven']['extract_to'], "apache-maven-#{node['maven']['version']}")
  end

  link '/usr/local/bin/mvn' do
    to File.join(node['maven']['mavenrc']['M2_HOME'], 'bin', 'mvn')
  end

  rc_file '/etc/mavenrc' do
    mode '0644'
    options node['maven']['mavenrc']
  end
end
