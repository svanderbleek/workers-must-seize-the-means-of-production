$(document).on "turbolinks:load", ->
  oven_channel = $(".oven-channel")
  if oven_channel.length
    App.cable.subscriptions.create {channel: "OvenChannel", oven: oven_channel.data("oven")},
      received: (data) ->
        oven_channel.replaceWith(data)
        $.rails.refreshCSRFTokens()
        