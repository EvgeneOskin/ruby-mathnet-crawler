# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'mathnet/crawler/version'

Gem::Specification.new do |spec|
  spec.name = 'mathnet-crawler'
  spec.version = Mathnet::Crawler::VERSION
  spec.authors = ['EvgeneOskin']
  spec.email = ['eoskin@crystalnix.com']

  spec.summary = 'Tool kit to operate with mathnet.ru'
  spec.description = 'The Library provides API and CLI to' \
    'operate with mathnet.ru.'
  spec.homepage = 'https://github.com/EvgeneOskin/ruby-mathnet-crawler'

  # Prevent pushing this gem to RubyGems.org by setting 'allowed_push_host', or
  # delete this section to allow pushing this gem to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  else
    fail 'RubyGems 2.0 or newer is required '\
          'to protect against public gem pushes.'
  end

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'commander', '~> 4.3'
  spec.add_dependency 'nokogiri', '~> 1.6'
  spec.add_dependency 'parallel', '~> 1.3'
  spec.add_dependency 'exponential-backoff'
  spec.add_development_dependency 'bundler', '~> 1.10'
  spec.add_development_dependency 'rake', '~> 13.0'
  spec.add_development_dependency 'rubocop', '~> 0.34.2'
  spec.add_development_dependency 'pry', '~> 0.10'
  spec.add_development_dependency 'byebug', '~> 6.0'
  spec.add_development_dependency 'rspec', '~> 3.3.0'
  spec.add_development_dependency 'simplecov', '~> 0.10.0'
  spec.add_development_dependency 'webmock', '~> 1.22.1'
  spec.add_development_dependency 'coveralls', '~> 0.8.3'
  spec.add_development_dependency 'yard', '~> 0.8'
end
