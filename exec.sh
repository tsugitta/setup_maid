#!/usr/bin/env bash

me=tsugitta
repository_name=setup_maid
tempfile=/tmp/${repository_name}.zip
workspace=/tmp/${repository_name}_maid

curl -LSfs -o ${tempfile} https://github.com/${me}/${repository_name}/archive/master.zip
unzip -oq ${tempfile} -d ${workspace}

pushd ${workspace}/${repository_name}-master > /dev/null

if [[ ! -d /usr/include ]]; then
  PLACEHOLDER=/tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress
  touch $PLACEHOLDER
  PROD=$(softwareupdate -l | grep "\*.*Command Line" | head -n 1 | awk -F"*" '{print $2}' | sed -e 's/^ *//' | tr -d '\n')
  softwareupdate -i "${PROD}"
  [[ -f $PLACEHOLDER ]] && rm $PLACEHOLDER
fi

which brew > /dev/null
if [ "$?" -ne 0 ]; then
  ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
fi

sudo gem install bundler
sudo bundle install

sudo bundle exec serverkit apply recipe.yml.erb --variables=variables.yml

popd > /dev/null

rm -rf ${tempfile} ${workspace}
