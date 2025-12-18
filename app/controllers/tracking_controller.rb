class TrackingController < ApplicationController
  skip_before_action :verify_authenticity_token

  # Track email opens via invisible pixel
  # GET /t/o/:token
  def open
    newsletter, subscriber = decode_token(params[:token])

    if newsletter && subscriber
      EmailEvent.record_open(
        newsletter: newsletter,
        subscriber: subscriber,
        ip_address: request.remote_ip,
        user_agent: request.user_agent
      )
    end

    # Return 1x1 transparent GIF
    send_data(transparent_gif, type: "image/gif", disposition: "inline")
  end

  # Track link clicks and redirect
  # GET /t/c/:token
  def click
    newsletter, subscriber = decode_token(params[:token])
    url = params[:url]

    if newsletter && subscriber && url.present?
      EmailEvent.record_click(
        newsletter: newsletter,
        subscriber: subscriber,
        url: url,
        ip_address: request.remote_ip,
        user_agent: request.user_agent
      )
    end

    # Redirect to original URL or fallback
    redirect_to(url.presence || root_url, allow_other_host: true)
  end

  private

  def decode_token(token)
    return [nil, nil] unless token.present?

    data = Rails.application.message_verifier(:tracking).verified(token)
    return [nil, nil] unless data

    newsletter = Newsletter.find_by(id: data[:newsletter_id])
    subscriber = Subscriber.find_by(id: data[:subscriber_id])

    [newsletter, subscriber]
  rescue ActiveSupport::MessageVerifier::InvalidSignature
    [nil, nil]
  end

  def transparent_gif
    # 1x1 transparent GIF
    Base64.decode64("R0lGODlhAQABAIAAAAAAAP///yH5BAEAAAAALAAAAAABAAEAAAIBRAA7")
  end
end
