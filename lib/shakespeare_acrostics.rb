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
  # Write to a file.
  def self.make_acrostics filename

    # Create the database if it doesn't already exist.
    make_database

    # Set up the poem generator with defaults.
    poefy = Poefy::Poem.new('shakespeare_complete', {
        form: :sonnet,
        syllable: 10,
        indent: '',
        transform: proc { |i| i[2] = i[2].upcase ; i }
      }
    )

    # Save to file.
    File.open(filename, 'w') do |f|
      f.puts ''
      f.puts 'Sonnets on The Sonnets'
      f.puts ''
      f.puts '  By William Shakespeare'
      f.puts ''
#     get_sonnet_chunks[-2..-1].each.with_index do |word, index|
#     get_sonnet_chunks[60..65].each.with_index do |word, index|
#     get_sonnet_chunks[0..3].each.with_index do |word, index|
      get_sonnet_chunks.each.with_index do |word, index|
        if word.length == 14
          f.puts ''
          f.puts RomanNumerals.to_roman(index + 1) + '.'
          f.puts (index + 1).to_s + '.'
          f.puts "Acrostic on #{word.downcase}"
          f.puts ''

          # Repeat until a poem is created.
          poem = nil
          options = [
            { acrostic_x: word },
            { acrostic_x: word, proper: false },
            { acrostic_x: word, rhyme: 'abbaabbacdecde' },
            { acrostic_x: word, rhyme: 'abbaabbacdccdc' },
            { acrostic_x: word, rhyme: 'abbaabbacdcddc' },
            { acrostic_x: word, rhyme: 'abbaabbacddcdd' },
            { acrostic_x: word, rhyme: 'abbaabbacddece' },
            { acrostic_x: word, rhyme: 'abbaabbacdcdcd' },
            { acrostic_x: word, rhyme: 'ababbcbccdcdee' },
            { acrostic_x: word, rhyme: 'ababacdcedefef' },
            { acrostic_x: word, rhyme: 'abbaabbacdecde', proper: false },
            { acrostic_x: word, rhyme: 'abbaabbacdccdc', proper: false },
            { acrostic_x: word, rhyme: 'abbaabbacdcddc', proper: false },
            { acrostic_x: word, rhyme: 'abbaabbacddcdd', proper: false },
            { acrostic_x: word, rhyme: 'abbaabbacddece', proper: false },
            { acrostic_x: word, rhyme: 'abbaabbacdcdcd', proper: false },
            { acrostic_x: word, rhyme: 'ababbcbccdcdee', proper: false },
            { acrostic_x: word, rhyme: 'ababacdcedefef', proper: false }
          ]
          options.each do |opt|
            poem = poefy.poem!(opt)
            break if !poem.nil?
          end
          raise StandardError if poem.nil?
          f.puts (poem ? poem : '#')
        else
          f.puts ''
          f.puts 'Envoi'
          f.puts "Acrostic on #{word.downcase}"
          f.puts ''
          f.puts poefy.poem!({ rhyme: 'a' * word.length, acrostic_x: word })
        end
        f.puts ''
      end
      f.puts ''
      f.puts 'THE END'
      f.puts ''
    end
  end
end

################################################################################

# Write the lines to a text file.
# File.open('sonnets.txt', 'w') do |f|
#   f.puts ShakespeareAcrostics.sonnets
# end
# File.open('dialogue.txt', 'w') do |f|
#   f.puts ShakespeareAcrostics.dialogue
# end

#puts ShakespeareAcrostics.get_sonnet_chunks

ShakespeareAcrostics.make_acrostics 'acrostics.txt'

################################################################################
