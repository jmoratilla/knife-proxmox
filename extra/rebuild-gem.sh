#!/bin/sh

rm knife-proxmox-*.*.*.gem
gem uninstall knife-proxmox
gem build knife-proxmox.gemspec
gem install ./knife-proxmox-*.*.*.gem
rbenv rehash
