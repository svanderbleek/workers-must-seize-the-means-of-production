class BakeJob < ApplicationJob
  queue_as :default

  TIME = 4.seconds

  def perform(oven)
    oven.bake!
  end
end
