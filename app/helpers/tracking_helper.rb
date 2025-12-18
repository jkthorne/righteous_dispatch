module TrackingHelper
  # Generate a tracking token for a newsletter/subscriber pair
  def tracking_token(newsletter:, subscriber:)
    Rails.application.message_verifier(:tracking).generate(
      { newsletter_id: newsletter.id, subscriber_id: subscriber.id },
      expires_in: 1.year
    )
  end

  # Generate the tracking pixel URL for open tracking
  def tracking_pixel_url(newsletter:, subscriber:)
    token = tracking_token(newsletter: newsletter, subscriber: subscriber)
    tracking_open_url(token: token)
  end

  # Generate a tracked link URL
  def tracked_link_url(newsletter:, subscriber:, url:)
    token = tracking_token(newsletter: newsletter, subscriber: subscriber)
    tracking_click_url(token: token, url: url)
  end

  # Rewrite links in HTML content to use tracked URLs
  def track_links_in_html(html, newsletter:, subscriber:)
    return html if html.blank?

    doc = Nokogiri::HTML.fragment(html)
    doc.css("a[href]").each do |link|
      original_url = link["href"]

      # Skip unsubscribe links, mailto, tel, and anchor links
      next if original_url.blank?
      next if original_url.start_with?("#", "mailto:", "tel:")
      next if original_url.include?("unsubscribe")

      link["href"] = tracked_link_url(
        newsletter: newsletter,
        subscriber: subscriber,
        url: original_url
      )
    end

    doc.to_html
  end
end
