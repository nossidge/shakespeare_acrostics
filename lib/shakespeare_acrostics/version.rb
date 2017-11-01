#!/usr/bin/env ruby
# Encoding: UTF-8

module ShakespeareAcrostics

  ##
  # The number of the current version.
  #
  def self.version_number
    major = 0
    minor = 0
    tiny  = 1
    pre   = 'pre'

    string = [major, minor, tiny, pre].compact.join('.')
    Gem::Version.new string
  end

  ##
  # The date of the current version.
  #
  def self.version_date
    '2017-11-01'
  end
end
