class CoachingSessionAdminPageObject < APageObject

  TABLE = '#tableCoachingSessions > div.el-table__body-wrapper.is-scrolling-none > table'

  def initialize page
    super
  end

  def new_coaching_session
    @page.click_button('Nueva')
  end

  def fill_coaching_session description, kleerers
    fill_date('date-coaching-session', "#{Time.now.year}-#{Time.now.month}-#{Time.now.day}",'form-coaching-session')
    fill_field('description-coaching-session', description)
    fill_field('complementary-coaching-session', description.reverse)
    kleerers.each do |kleerer|
      @page.find_by_id("check-coaching-session#{kleerer}").click
    end

  end

  def create_coaching_session
    @page.click_button('Guardar')
  end

  def count_sessions
    @page.find(:css, TABLE).all(:css, 'tr').size
  end

  def delete_coaching_session(number)
    counter = 1
    @page.find(:css, TABLE).all(:css, 'tr').each do |item|
      if(counter == number)
        item.find(:css,'button').click
        break
      end
      counter += 1
    end
  end

  def close
    @page.click_button('Cerrar')
    return BalanceDetailPageObject.new @page
  end

end