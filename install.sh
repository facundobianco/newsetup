#!/bin/bash

/bin/bash bootstrap_salt.sh stable 2018.3.2 || exit 1

sed -e '/^#file_client:/s/.*/file_client: local/' \
    -e '/^#id:/s/.*/id: '`hostname -s`'/' \
    -i /etc/salt/minion

mkdir /srv/{salt,pillar}
mkdir /srv/salt/base

cat > /srv/salt/top.sls <<EOF
base:
  '*':
    - base
EOF

ln -s `pwd`/init.sls /srv/salt/base/init.sls

#salt-call --local state.apply -l info
