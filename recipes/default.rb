#
# Cookbook Name:: httperf
# Recipe:: default
#
if node["platform"] == "windows"
  return "#{node['platform']} is not supported by the #{cookbook_name}::#{recipe_name} recipe"
end

include_recipe "build-essential"
include_recipe 'git'
include_recipe "autoconf"

url    = node['httperf']['src_url']
branch = node['httperf']['git_branch']
cache  = node['httperf']['cache_dir']
dest   = node['httperf']['dest_dir']
ver    = "0.9.1"

git "#{cache}" do
  action :export
  repository url
  revision branch
end

execute "autoreconf -i" do
  cwd cache
  creates "#{cache}/configure"
end

execute "configure httperf" do
  cwd cache
  command "./configure"
  creates "#{cache}/Makefile"
end

execute "make httperf" do
  cwd cache
  command "make"
  creates "#{cache}/bin/httperf"
end

execute "install httperf" do
  command "make install"
  cwd cache
  not_if {File.exists?("#{dest}/httperf") && !!(`httperf --version`.strip =~ Regexp.new(ver))}
  creates "#{dest}/httperf"
end

# vim: filetype=ruby
