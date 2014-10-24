# -*- encoding: utf-8 -*-

require 'lazy_loader/version'

case RUBY_ENGINE
when 'jruby' then require 'lazy_loader/jruby'
when 'mri' then require 'lazy_loader/mri'
else raise StandardError.new("LazyLoader is only usable for JRuby and MRI Ruby (are you using Rubinus?)")
end
