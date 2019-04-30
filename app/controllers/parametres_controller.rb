class ParametresController < ApplicationController
  before_action :authenticate_agent!
  def index

  end

  # permet d'afficher le rapprochement bancaire
  def rapprochement

  end

  # permet la gestion des agences
  def agence

  end

  # permet la gestion des utilisateurs
  def utilisateur

  end

  # permet d'afficher le journale
  def journal

  end
end
