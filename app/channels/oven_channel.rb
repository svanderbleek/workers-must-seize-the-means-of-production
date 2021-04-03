class OvenChannel < ApplicationCable::Channel
  def subscribed
    oven = Oven.find(params[:oven])
    stream_for(oven)
  end
end
