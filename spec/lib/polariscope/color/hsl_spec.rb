# frozen_string_literal: true

RSpec.describe Polariscope::Color::Hsl do
  describe '.for' do
    subject(:hsl) { described_class.for(100) }

    it 'instantiates new object and calls #hsl' do
      expect(hsl).to eq('hsl(120, 100%, 45%)')
    end
  end

  describe '#hsl' do
    subject(:color) { described_class.new(health_score) }

    context 'when health score is a number' do
      let(:health_score) { 50.94 }

      it 'calculates the hue based on health score' do
        expect(color.hsl).to eq('hsl(60, 100%, 45%)')
      end
    end

    context 'when health score is nil' do
      let(:health_score) { nil }

      it 'returns an empty string' do
        expect(color.hsl).to eq('')
      end
    end
  end
end
