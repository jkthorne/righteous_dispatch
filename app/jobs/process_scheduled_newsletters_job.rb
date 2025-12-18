class ProcessScheduledNewslettersJob < ApplicationJob
  queue_as :default

  def perform
    Newsletter.ready_to_send.find_each do |newsletter|
      newsletter.update!(status: :sending)
      SendNewsletterJob.perform_later(newsletter.id)
    end
  end
end
