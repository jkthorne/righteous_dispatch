require "test_helper"

class NewsletterTagTest < ActiveSupport::TestCase
  test "valid newsletter tag" do
    newsletter_tag = NewsletterTag.new(
      newsletter: newsletters(:draft_newsletter),
      tag: tags(:tech)
    )
    assert newsletter_tag.valid?
  end

  test "belongs to newsletter" do
    assert_equal newsletters(:scheduled_newsletter), newsletter_tags(:scheduled_tech).newsletter
  end

  test "belongs to tag" do
    assert_equal tags(:tech), newsletter_tags(:scheduled_tech).tag
  end

  test "same newsletter can have multiple tags" do
    newsletter = newsletters(:scheduled_newsletter)
    new_tag = NewsletterTag.new(
      newsletter: newsletter,
      tag: tags(:sports)
    )
    assert new_tag.valid?
  end

  test "same tag can be on multiple newsletters" do
    tag = tags(:tech)
    new_newsletter_tag = NewsletterTag.new(
      newsletter: newsletters(:draft_newsletter),
      tag: tag
    )
    assert new_newsletter_tag.valid?
  end
end
