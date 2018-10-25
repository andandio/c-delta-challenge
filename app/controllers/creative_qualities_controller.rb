class CreativeQualitiesController < ApplicationController
  def index
    @creative_qualities = CreativeQuality.all

    scores = CreativeQuality.collect_global_scores
    @scores = CreativeQuality.calculate_normalized_scores(scores)
  end
end
