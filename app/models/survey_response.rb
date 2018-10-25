class SurveyResponse < ApplicationRecord
  has_many :answers

  validates :first_name, presence: true
  validates :last_name, presence: true

  delegate :count, to: :answers, prefix: true

  def display_name
    "#{first_name} #{last_name}"
  end

  def completed?
    answers_count == Question.count
  end

  def calculate_creative_quality_scores
    CreativeQuality.all.map do |cq|
      raw = calculate_raw_scores(cq)
      max = calculate_max_score(cq)
      { name: cq.name, raw: raw, max: max }
    end
  end

  def calculate_raw_scores(cq)
    QuestionChoice.where(creative_quality_id: cq.id)
                  .joins(:answers)
                  .where(answers: {survey_response_id: id})
                  .sum(:score)
  end

  def calculate_max_score(cq)
    question_ids = QuestionChoice.where(creative_quality_id: cq.id)
                                 .joins(:answers)
                                 .where(answers: {survey_response_id: id})
                                 .map(&:question_id)

    max_score = question_ids.map do |qid|
      QuestionChoice.where(question_id: qid).maximum("score")
    end.inject(0, :+)
  end
end
