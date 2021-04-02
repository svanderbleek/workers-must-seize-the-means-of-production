class BakeJob < ApplicationJob
  queue_as :default

  def perform(oven)
    oven.bake!
  end
end
