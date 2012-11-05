#!/bin/sh

rm knife-proxmox-0.0.1.gem
gem uninstall knife-proxmox
gem build knife-proxmox.gemspec
gem install ./knife-proxmox-0.0.1.gem
rbenv rehash
