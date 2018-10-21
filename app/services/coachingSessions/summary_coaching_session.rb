class SummaryCoachingSession < Publisher

  def call(balance_id, updatePercentage)

    puts balance_id
    puts updatePercentage

    summary = summary(CoachingSession.where(balance_id: balance_id))

    if(updatePercentage)
      UpdatePercentage.new.update_percentage_for_coaching_balance(balance_id, summary)
    end

    publish(:send_response, summary)
  rescue StandardError => error
    publish(:halt_message,
            "Error summarying the coaching sessions #{error.message}")
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
        if(sessions_counter[kleerer])
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