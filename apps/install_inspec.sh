#! /bin/bash
sudo apt-get -y install --no-install-recommends software-properties-common
sudo apt-add-repository -y ppa:rael-gc/rvm
sudo apt-get update
sudo apt-get install -y --no-install-recommends rvm
sudo usermod -a -G rvm ubuntu
sudo /usr/share/rvm/bin/rvm user gemsets
sudo /usr/share/rvm/bin/rvm install ruby 2.7
# Below line should be safe as long as 2.7/2 is the default 2.7, but is a source of breakage
sudo ln -s /usr/share/rvm/rubies/ruby-2.7.2/bin/gem /usr/local/bin/gem
sudo ln -s /usr/share/rvm/rubies/ruby-2.7.2/bin/ruby /usr/local/bin/ruby
# Remove gemwrappers 
sudo gem uninstall gem-wrappers