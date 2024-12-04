class HomeController < ApplicationController
  def index
    endpoint Home::Operation::Index, Home::Component::Index
  end
end
