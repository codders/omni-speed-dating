#!/usr/bin/ruby

require 'test/unit'

class Matcher

  def all_users
    if @all_users.nil?
      @all_users = @preferences.keys
    end
    @all_users
  end

  def get_preferences(user)
    @preferences[user]
  end

  def get_flat_preferences(user)
    if (p = get_preferences(user))
      p.flatten
    else
      nil
    end
  end

  def set_preferences(proposer, preferences)
    newp = preferences.select { |p| !(p.nil? or p.size == 0) }
    if (newp.size > 0)
      @preferences[proposer] = newp
    else
      @preferences.delete proposer
    end
  end

  def remove_preference(proposer, proposee)
    puts "Removing #{proposer}'s preference for #{proposee}"
    prefs = get_preferences(proposer)
    return if prefs.nil?
    if prefs.include?(proposee)
      prefs.delete(proposee)
      set_preferences(proposer, prefs)
    else
      set_preferences(proposer, prefs.map { |subpref| subpref.delete(proposee) if !subpref.is_a?(String); subpref } )
    end
  end

  def remove_crushes
    @preferences.each do |k,v|
      crushes = get_flat_preferences(k).select { |pref| !get_flat_preferences(pref).include?(k) }
      crushes.each { |c| remove_preference(k,c) }
    end
  end

  def fill_out_preferences
    @preferences.each do |k,v|
      preference = get_flat_preferences(k)
      missing = all_users - preference
      v.push(missing)
    end
  end

  def get_match(participant)
    if @matches.keys.include?(participant)
      @matches[participant]
    elsif @matches.values.include?(participant)
      @matches.detect {|k,v| v == participant }[0]
    else 
      nil
    end
  end

  def unmatched
    all_users.select { |s| !get_match(s) }
  end

  def clear_matches(participant)
    @matches.delete participant
    if (partner = get_match(participant))
      @matches.delete partner
    end
  end


  # for each (successor m'' of m on w’s list) do
  #   delete the pair (m'', w)
  def clear_other_preferences(proposer, proposee)
    others = []
    return if get_preferences(proposee).nil?
    get_preferences(proposee).reverse.each do |other|
      if (other == proposer or other.include?(proposer))
        break
      end
      others << other
    end
    
    others.reverse.each do |relegated|
      (relegated.is_a?(String) ? [relegated] : relegated).each do |i|
        remove_preference(i, proposee)
      end
    end
  end

  def dump_matches
    Matcher.dump_matches(@matches)
  end

  def dump_preferences
    Matcher.dump_preferences(@preferences)
  end

  def match(preferences)
    # Assign each person to be free
    @matches = Hash.new

    @preferences = preferences.dup

    # Remove unrequited preferences
    remove_crushes

    # Add back lonely people
    preferences.each do |k,v| 
      if get_preferences(k).nil?
        set_preferences(k, [k])
      end
    end

    # Fill up the preference array
    fill_out_preferences

    # While some person is free...
    iterations = 0
    while ((free = unmatched).size > 0 && iterations < 20)
      dump_preferences
      proposer = free.first
      puts "Finding a match for #{proposer}"
      preferences = get_preferences(proposer)
      puts "Choosing from #{preferences.inspect}"
      if !preferences
        puts "#{proposer} is all out of options"
        break
      end
      proposee = preferences.first
      proposee = proposee.first unless proposee.is_a?(String)
      puts "#{proposer} proposes, and becomes engaged to #{proposee}"
      if (partner = get_match(proposee))
        puts "But #{proposee} already engaged to #{partner}. Clearing #{partner}'s engagement"
        clear_matches(partner)
        puts "... and #{proposee}'s inferior matches' preferences for them"
        clear_other_preferences(proposer, proposee)
      end
      @matches[proposer] = proposee
      dump_matches
      puts ""
      iterations += 1
    end
    if iterations == 20
      puts "Unable to find a match"
      return {}
    end
    @matches
  end

  class << self

    def dump_matches(matches)
      puts "Matches:"
      matches.each do |k,v|
        puts "#{k} => #{v}"
      end
    end

    def dump_preferences(preferences)
      puts "Preferences:"
      preferences.each do |k,v|
        puts "#{k} => #{v.inspect}"
      end
    end

  end

end


class MatchTest < Test::Unit::TestCase

  def assert_matched(user1, user2, matches)
    assert((matches[user1] == user2 or matches[user2] == user1), "Failed to find match for #{user1} and #{user2}")
  end

  def assert_sane_match(matches, prefs)
    Matcher.dump_matches(matches)
    Matcher.dump_preferences(prefs)
    assert(matches.size > 0, "No matches found")
    assert(matches.size >= prefs.keys.size / 2, "Some people left unmatched")
    matches.each do |proposer, matched|
      if proposer != matched
        assert(prefs[proposer].flatten.include?(matched), "#{proposer} doesn't want to go out with #{matched}")
        assert(prefs[matched].flatten.include?(proposer), "#{matched} doesn't want to go out with #{proposer}")
      end
    end
  end

  def test_simple_match
    prefs = {
      "Sam" => [ "Louise" ],
      "Louise" => [ "Sam" ]
    }

    matches = Matcher.new.match(prefs)
    assert_sane_match(matches, prefs)
    assert_equal(1, matches.length)
    assert_matched("Sam", "Louise", matches)
  end

  def test_unhappy_match
    prefs = {
      "Sam" => [ [ "Louise", "Sally" ], "Guillaume" ],
      "Louise" => [ "Sam", [ "Phil", "Sally" ] ],
      "Phil" => [ "Guillaume", "Sally" ],
      "Guillaume" => [ "Sally", "Louise" ],
      "Sally" => [ [ "Phil", "Sam" ] ]
    }
    matches = Matcher.new.match(prefs)
    assert_sane_match(matches, prefs)
    assert_matched("Sally", "Phil", matches)
    assert_matched("Sam", "Louise", matches)
  end

  def test_complex_match
    prefs = {
      "Sam" => [ [ "Louise", "Sally" ], "Guillaume" ],
      "Louise" => [ "Sam", [ "Phil", "Sally" ] ],
      "Phil" => [ "Guillaume", "Sally" ],
      "Guillaume" => [ "Sally", "Louise" ],
      "Sally" => [ [ "Phil", "Sam" ] ],
      "Robert" => [ "Sam" ]
    }
    matches = Matcher.new.match(prefs)
    assert_sane_match(matches, prefs)
  end

end
