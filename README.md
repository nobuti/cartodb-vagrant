This is a provision script to install a development environment for [CartoDB](https://github.com/CartoDB/cartodb) using Vagrant. The base OS for this configuration in Vagrant is an Ubuntu 12.04 x64 distro.

It's assumed that all cartodb repos live in the parent scope folder. They are synced in `/opt` inside the vagrant machine.

## Install
```
./repos.sh
vagrant up
```

## Fix the development host for node apps

In `cartodb-sql-api/config/environments/development.js` the `node_host` to `0.0.0.0`. Do the same for `windshaft-cartodb/config/environments/development.js`
