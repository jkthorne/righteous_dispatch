class NewsletterTag < ApplicationRecord
  belongs_to :newsletter
  belongs_to :tag
end
