# frozen_string_literal: true

RSpec.describe Polariscope::Scanner::AdvisoriesHealthScore do
  subject(:advisories_health_score) { described_class.new(dependency_context, calculation_context) }

  describe '#health_score' do
    let(:dependency_context) do
      Polariscope::Scanner::DependencyContext.new(
        gemfile_content: File.read('spec/files/gemfile_with_ruby_version'),
        gemfile_lock_content: File.read('spec/files/gemfile.lock_with_ruby_version')
      )
    end

    let(:calculation_context) { Polariscope::Scanner::CalculationContext.new }

    it 'returns a health score' do
      expect(advisories_health_score.health_score).to be_a(Float)
      expect(advisories_health_score.health_score).to be > 0
      expect(advisories_health_score.health_score).to be < 1.0
    end
  end
end
