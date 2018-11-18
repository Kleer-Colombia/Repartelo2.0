class SummaryCoachingSession
 prepend Service

 attr_accessor :balance_id

 #TODO delete distribution if update percentage inclusive in the front
 def initialize(balance_id)
   @balance_id = balance_id
 end

 def call
   summary = summary(CoachingSession.where(balance_id: @balance_id))
   up_parameter(:summary, summary)
   return summary

 rescue StandardError => error
   errors.add(:messages, "Error summarying the coaching sessions #{error.message}")
 end

 # TODO only one public method

 def summary(coaching_sessions)
    summary = {}
    summary[:totalcs] = coaching_sessions.size
    summary[:distribution] = []
    count_sessions_for_kleerer(coaching_sessions).each_pair do |kleerer,sessions|
      summary[:distribution] << { kleerer: kleerer.name,
                                  kleerer_id: kleerer.id,
                                  sessions: sessions,
                                  percentage: calculate_percentage(summary[:totalcs],sessions)}
    end
    summary
 end

 private

 def count_sessions_for_kleerer(coaching_sessions)
   sessions_counter = {}
   coaching_sessions.each do |cs|
     cs.kleerers.each do |kleerer|
       if (sessions_counter[kleerer])
         sessions_counter[kleerer] += (1.0 / cs.kleerers.size).round(2)
       else
         sessions_counter[kleerer] = (1.0 / cs.kleerers.size).round(2)
       end
     end
   end
   sessions_counter
 end

 def calculate_percentage(total_sessions, kleerer_sessions)
   ((kleerer_sessions*100)/total_sessions.to_f).round(2)
 end


end