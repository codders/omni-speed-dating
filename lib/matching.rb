module Matching

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
      Rails.logger.debug "Removing #{proposer}'s preference for #{proposee}"
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
        Rails.logger.debug "Finding a match for #{proposer}"
        preferences = get_preferences(proposer)
        Rails.logger.debug "Choosing from #{preferences.inspect}"
        if !preferences
          Rails.logger.debug "#{proposer} is all out of options"
          break
        end
        proposee = preferences.first
        proposee = proposee.first unless proposee.is_a?(String)
        Rails.logger.debug "#{proposer} proposes, and becomes engaged to #{proposee}"
        if (partner = get_match(proposee))
          Rails.logger.debug "But #{proposee} already engaged to #{partner}. Clearing #{partner}'s engagement"
          clear_matches(partner)
          Rails.logger.debug "... and #{proposee}'s inferior matches' preferences for them"
          clear_other_preferences(proposer, proposee)
        end
        @matches[proposer] = proposee
        dump_matches
        Rails.logger.debug ""
        iterations += 1
      end
      if iterations == 20
        Rails.logger.debug "Unable to find a match"
        return {}
      end
      @matches
    end

    class << self

      def dump_matches(matches)
        Rails.logger.debug "Matches:"
        matches.each do |k,v|
          Rails.logger.debug "#{k} => #{v}"
        end
      end

      def dump_preferences(preferences)
        Rails.logger.debug "Preferences:"
        preferences.each do |k,v|
          Rails.logger.debug "#{k} => #{v.inspect}"
        end
      end

    end

  end

end
