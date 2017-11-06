#!/usr/bin/env ruby
# Encoding: UTF-8

################################################################################

require 'poefy'
require 'poefy/pg'
require 'roman-numerals'

require_relative 'shakespeare_acrostics/version.rb'

################################################################################

module ShakespeareAcrostics

  # Reference to the root directory.
  def self.root
    File.expand_path('../../', __FILE__)
  end

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
  # Z lines are tricky to match, so kill the leading apostrophe on "'zounds".
  def self.dialogue
    lines = get_text "
      SELECT plaintext
      FROM public.paragraph
      WHERE charid != 'xxx'
      ORDER BY paragraphid ASC
    ;"
    lines.map! { |i| i.sub(/^'zounds/, 'zounds')}
    lines.map! { |i| i.sub(/^'Zounds/, 'Zounds')}
  end

  ##############################################################################

  # Remove every character from the Sonnets, except for alphas.
  # Chunk alphas into 14 character sections.
  def self.get_sonnet_chunks
    sonnets.join('')
           .downcase
           .delete('^a-z')
           .scan(/.{1,14}/m)
  end

  # Make a database with the full Shakespeare data.
  # Create the database only if it doesn't already exist.
  def self.make_database
    poefy = Poefy::Poem.new('shakespeare_complete')
    poefy.make_database(ShakespeareAcrostics.dialogue, false)
    poefy.close
  end

  ##############################################################################

  # For each 14 character section, generate an acrostic sonnet.
  # Write to a file as we go, so we can see where it errors (if it does).
  def self.save_acrostics filename

    # Create the database if it doesn't already exist.
    make_database

    # Set up the poem generator with our defaults.
    # We are making sonnets, with 10-syllable lines.
    # A 2-space indent will be added by the 'acrostic_x' option.
    # Use transform to uppercase the 3rd letter in each line.
    # Because of the indent, this will be the letter of the acrostic.
    poefy = Poefy::Poem.new('shakespeare_complete', {
        form: :sonnet,
        syllable: 10,
        indent: '',
        transform: proc { |i| i[2] = i[2].upcase ; i }
      }
    )

    # Open and write to file.
    File.open(filename, 'w') do |f|
      f.puts ''
      f.puts 'Acrostic Sonnets on The Sonnets'
      f.puts ''
      f.puts '  By William Shakespeare'
      f.puts ''

      # All but the last poem will be a 14-line sonnet.
      # Write an envoi acrostic with any remaining letters.
      get_sonnet_chunks.each.with_index do |word, index|
        if word.length == 14
          f.puts ''
          f.puts RomanNumerals.to_roman(index + 1) + " - \"#{word.upcase}\""
          f.puts ''
          f.puts poefy.poem({ acrostic_x: word })
        else
          f.puts ''
          f.puts "Envoi - \"#{word.upcase}\""
          f.puts ''
          f.puts poefy.poem({ rhyme: 'a' * word.length, acrostic_x: word })
        end
        f.puts ''
      end

      f.puts ''
      f.puts 'THE END'
    end
  end
end

################################################################################

# Module alias.
sa = ShakespeareAcrostics

# Write the input data to a text file each.
File.open("#{sa.root}/data/input_sonnets.txt", 'w') do |f|
  f.puts sa.sonnets
end
File.open("#{sa.root}/data/input_dialogue.txt", 'w') do |f|
  f.puts sa.dialogue
end

# Generate the acrostics and save to a file.
sa.save_acrostics "#{sa.root}/data/output_acrostics.txt"

################################################################################
