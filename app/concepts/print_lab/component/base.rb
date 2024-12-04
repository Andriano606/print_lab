class PrintLab::Component::Base < ViewComponent::Base
  attr_reader :current_user

  def initialize(current_user: nil, **)
    @current_user = current_user
    super
  end
end
