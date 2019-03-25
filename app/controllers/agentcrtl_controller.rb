class AgentcrtlController < ApplicationController
  def index
    @agent = Agent.all
  end

  def new
    @agent = Agent.new
    puts "========= #{@agent}"
  end

  def edit
  end

  def delete
  end
end
