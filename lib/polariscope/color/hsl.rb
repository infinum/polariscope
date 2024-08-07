# frozen_string_literal: true

module Polariscope
  module Color
    class Hsl
      MAX_HUE = 120

      class << self
        def for(score)
          new(score).hsl
        end
      end

      def initialize(score)
        @score = score
      end

      def hsl
        return '' unless score

        "hsl(#{hue}, 100%, 45%)"
      end

      private

      attr_reader :score

      def hue
        (MAX_HUE * (rounded_score / 100.0)).round
      end

      def rounded_score
        (score / 5).round * 5
      end
    end
  end
end
