
class WelcomeController < ApplicationController
  def index
    @list = Base.load(8)
  end
end