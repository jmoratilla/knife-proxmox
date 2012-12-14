#!/bin/sh

gem uninstall knife-proxmox
rm pkg
rake repackage
gem install pkg/knife-proxmox-?.?.?.gem
rbenv rehash
