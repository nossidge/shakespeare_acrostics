#!/usr/bin/env ruby
# Encoding: UTF-8

################################################################################

require 'poefy'
require 'poefy/pg'
require 'roman-numerals'

require_relative 'shakespeare_acrostics/version.rb'

################################################################################

module ShakespeareAcrostics

  # Open connection to 'shakespeare', execute a single query, close connection.
  def self.run_query query
    begin
      con = PG.connect( ENV['DB_URL_SHAKESPEARE'] )
      rs = con.exec(query)

      # In this context, a 'dialogue' is as an actor's line.
      # This may contain multiple actual 'lines', which is what we want.
      rs.map do |dialogue|
        dialogue['plaintext'].split("\n[p]")
      end.flatten

    rescue => e
      puts e.message
      raise e

    ensure
      con.close if con
    end
  end

  # Get all lines from the database using an SQL query.
  def self.get_text query
    lines = run_query(query).map(&:strip)

    # This is a matter of some debate, but let's fix
    # the missing words in Sonnet 146 with "Why feed'st".
    find = "[         ] these rebel powers that thee array;"
    swap = "Why feed'st these rebel powers that thee array;"
    index = lines.index(find)
    lines[index] = swap

    # Reject lines that contain brackets.
    lines.reject! { |i| i.match(/\[/) || i.match(/\]/) }
    lines
  end

  # Get all lines from the sonnets.
  def self.sonnets
    get_text "
      SELECT plaintext
      FROM public.paragraph
      WHERE workid = 'sonnets'
      ORDER BY paragraphid ASC
    ;"
  end

  # Get all dialogue and poem lines.
  def self.dialogue
    get_text "
      SELECT plaintext
      FROM public.paragraph
      WHERE charid != 'xxx'
      ORDER BY paragraphid ASC
    ;"
  end
end

################################################################################
