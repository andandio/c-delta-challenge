class CreativeQuality < ApplicationRecord
  has_many :question_choices

  validates :name, :description, :color, presence: true

  def self.collect_global_scores
    scores = SurveyResponse.all.map do |survey|
      survey.calculate_creative_quality_scores
    end
  end

  def self.calculate_normalized_scores(scores)
    tally = { "Purpose" => {raw: 0, max: 0},
               "Empowerment" => {raw: 0, max: 0},
               "Collaboration" => {raw: 0, max: 0}
             }

    scores.each do |score|
      score.each do |quality|
        qual_name = quality[:name]
        tally[qual_name][:raw] += quality[:raw]
        tally[qual_name][:max] += quality[:max]
      end
    end

    tally.each do |k,v|
      tally[k][:normalized] = (tally[k][:raw].to_f/tally[k][:max] * 100).round
    end
  end
end
