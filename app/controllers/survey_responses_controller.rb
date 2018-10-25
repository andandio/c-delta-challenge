class SurveyResponsesController < ApplicationController
  def show
    @survey_response = SurveyResponse
    .includes(
      answers: [
        question_choice: [
          question: :question_choices
        ]
      ]
    )
    .find(params[:id])

    @scores = @survey_response.calculate_creative_quality_scores
  end

  def index
    @survey_responses = SurveyResponse.all
  end
end
