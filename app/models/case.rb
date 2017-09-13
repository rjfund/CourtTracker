class Case < ApplicationRecord
  has_many :documents, dependent: :destroy
  has_many :hearings, dependent: :destroy
end
