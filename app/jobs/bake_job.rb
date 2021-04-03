class BakeJob < ActiveJob::Base
  queue_as :default

  TIME = 4.seconds

  def perform(oven)
    oven.bake!
    data = ApplicationController.render(template: "ovens/show", assigns: {oven: oven}, layout: false) 
    OvenChannel.broadcast_to(oven, data)
  end
end
