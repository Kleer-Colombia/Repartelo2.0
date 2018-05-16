class LoginPageObject < APageObject

  def initialize page
      super
    end
  def login user
    @page.visit 'http://localhost:3000/#/login'
    @page.fill_in('email',{:name => 'email', :with => user.email})
    @page.fill_in("password", {:name => 'password', :with => user.password})
    @page.click_button("Entrar")
    return BalancePageObject.new @page
  end
end 