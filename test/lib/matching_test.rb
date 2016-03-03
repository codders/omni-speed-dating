require 'test_helper'
require 'matching'

class MatchingTest < ActiveSupport::TestCase

  def assert_matched(user1, user2, matches)
    assert((matches[user1] == user2 or matches[user2] == user1), "Failed to find match for #{user1} and #{user2}")
  end

  def assert_sane_match(matches, prefs)
    Matching::Matcher.dump_matches(matches)
    Matching::Matcher.dump_preferences(prefs)
    assert(matches.size > 0, "No matches found")
    assert(matches.size >= prefs.keys.size / 2, "Some people left unmatched")
    matches.each do |proposer, matched|
      if proposer != matched
        assert(prefs[proposer].flatten.include?(matched), "#{proposer} doesn't want to go out with #{matched}")
        assert(prefs[matched].flatten.include?(proposer), "#{matched} doesn't want to go out with #{proposer}")
      end
    end
  end

  test "simple match" do
    prefs = {
      "Sam" => [ "Louise" ],
      "Louise" => [ "Sam" ]
    }

    matches = Matching::Matcher.new.match(prefs)
    assert_sane_match(matches, prefs)
    assert_equal(1, matches.length)
    assert_matched("Sam", "Louise", matches)
  end

  test "unhappy match" do
    prefs = {
      "Sam" => [ [ "Louise", "Sally" ], "Guillaume" ],
      "Louise" => [ "Sam", [ "Phil", "Sally" ] ],
      "Phil" => [ "Guillaume", "Sally" ],
      "Guillaume" => [ "Sally", "Louise" ],
      "Sally" => [ [ "Phil", "Sam" ] ]
    }
    matches = Matching::Matcher.new.match(prefs)
    assert_sane_match(matches, prefs)
    assert_matched("Sally", "Phil", matches)
    assert_matched("Sam", "Louise", matches)
  end

  test "complex match" do
    prefs = {
      "Sam" => [ [ "Louise", "Sally" ], "Guillaume" ],
      "Louise" => [ "Sam", [ "Phil", "Sally" ] ],
      "Phil" => [ "Guillaume", "Sally" ],
      "Guillaume" => [ "Sally", "Louise" ],
      "Sally" => [ [ "Phil", "Sam" ] ],
      "Robert" => [ "Sam" ]
    }
    matches = Matching::Matcher.new.match(prefs)
    assert_sane_match(matches, prefs)
  end

  test "match with popular person" do
    prefs = {
      "Sam" => [ "Guillaume", "Chris", "Tom", "Phil" ],
      "Sally" => [ "Phil" ],
      "Lucy" => [ "Chris" ],
      "Elaine" => [ "Tom" ],
      "Phil" => [ "Sam", "Sally" ],
      "Chris" => [ "Elaine", "Lucy", "Sam" ],
      "Tom" => [ "Elaine", "Sam" ],
      "Adele" => [ "Tom", "Guillaume" ],
      "Guillaume" => [ "Adele", "Sam" ]
    }
    matches = Matching::Matcher.new.match(prefs)
    assert_sane_match(matches, prefs)
  end

end
