class Navigation::Component::TopBar < PrintLab::Component::Base
  def user_signed_in?
    current_user.present?
  end
end
