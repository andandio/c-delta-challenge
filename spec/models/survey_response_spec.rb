require 'rails_helper'

describe SurveyResponse do
  context 'associations' do
    it { is_expected.to have_many(:answers) }
  end

  context 'validations' do
    it { is_expected.to validate_presence_of :first_name }
    it { is_expected.to validate_presence_of :last_name }
  end

  describe '#display_name' do
    let(:survey_response) { create(:survey_response) }

    it 'concatenates the first and last name' do
      expect(survey_response.display_name).to eql(
        [
          survey_response.first_name,
          survey_response.last_name
        ].join(' ')
      )
    end
  end

  describe '#completed?' do
    let(:survey_response) { build(:survey_response) }

    before do
      allow(Question).to receive(:count).and_return(3)
      allow(survey_response).to receive_message_chain(:answers, :count)
        .and_return(survey_response_count)
    end

    context 'when no responses exist' do
      let(:survey_response_count) { 0 }

      it 'is false' do
        expect(survey_response.completed?).to be(false)
      end
    end

    context 'when some responses exist' do
      let(:survey_response_count) { 1 }

      it 'is false' do
        expect(survey_response.completed?).to be(false)
      end
    end

    context 'when responses exist for all questions' do
      let(:survey_response_count) { 3 }

      it 'is true' do
        expect(survey_response.completed?).to be(true)
      end
    end
  end

  describe 'score calculations' do
    let(:survey_response) { create(:survey_response) }
    let(:answers) { create_list(:answer, 3) }
    let(:cq) { create(:creative_quality) }
    let(:qcs) { create_list(:question_choice, 3) }

    before do
      answers.each_with_index {|answer, i| answer.question_choice = qcs[i]}
      survey_response.answers = answers
      qcs.each{ |qc| qc.creative_quality = cq; qc.save! }
    end

    it 'returns the raw score sum from #calculate_raw_scores' do
      raw_sum = qcs.map {|qc| qc.score }.sum
      expect(survey_response.calculate_raw_scores(cq)).to eq(raw_sum)
    end


    it 'calculates the max possible scores from #calculate_max_scores' do
      new_qcs = create_list(:question_choice, 6)
      new_qcs.each { |qc| qc.creative_quality = cq; qc.save!}
      qcs_for_answers = answers.map { |a| a.question_choice }
      questions = qcs_for_answers.map(&:question_id)
      max = QuestionChoice.where(question_id: questions).map(&:score).sum
      expect(survey_response.calculate_max_score(cq)).to eq(max)
    end
  end
end
