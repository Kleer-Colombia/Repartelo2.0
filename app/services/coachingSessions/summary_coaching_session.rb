class SummaryCoachingSession
 prepend SimpleCommand

 #TODO delete distribution if update percentage inclusive in the front
 def initialize(balance_id, update_percentage)
   @balance_id = balance_id
   @update_percentage = update_percentage
 end

 def call
   summary = summary(CoachingSession.where(balance_id: @balance_id))
   if @update_percentage
     UpdatePercentage.new.update_percentage_for_coaching_balance(@balance_id, summary)
   else
     puts @update_percentage
   end

   return summary

 rescue StandardError => error
   errors.add(:messages, "Error summarying the coaching sessions #{error.message}")
 end

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

    return summary
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
   return sessions_counter
 end

 def calculate_percentage(total_sessions, kleerer_sessions)
   return ((kleerer_sessions*100)/total_sessions.to_f).round(2)
 end


end