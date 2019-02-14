class HomeController < ApplicationController
  def index
  end

  def public
    @transaction = Transaction.all
  end

  def private
  end

  def login
  end

  def signup
  end
end
