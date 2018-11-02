class CoachingSessionAdminPageObject < APageObject

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
    @page.find_by_id("check-coaching-session#{kleerers}").click
  end

  def create_coaching_session
    @page.click_button('Guardar')
  end

  def count_sessions
    @page.find(:css, '#tableCoachingSessions > div.el-table__body-wrapper.is-scrolling-none > table').all(:css, 'tr').size
  end

  def close
    @page.click_button('Cerrar')
    return BalanceDetailPageObject.new @page
  end

end