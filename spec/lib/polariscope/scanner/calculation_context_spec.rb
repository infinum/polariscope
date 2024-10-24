# frozen_string_literal: true

RSpec.describe Polariscope::Scanner::CalculationContext do
  subject(:calculation_context) { described_class.new(**opts) }

  let(:opts) { {} }

  describe '#priority_for' do
    it 'returns priority for dependency defined in dependency priorities' do
      dependency = Bundler::Dependency.new('rails', false)

      expect(calculation_context.priority_for(dependency)).to eq(10.0)
    end

    it 'returns group priority for dependency not defined in dependency priorities' do
      dependency = Bundler::Dependency.new('devise', false, { 'group' => :production })

      expect(calculation_context.priority_for(dependency)).to eq(2.0)
    end

    it 'returns default dependency priority for dependency not defined in dependency or group priorities' do
      dependency = Bundler::Dependency.new('devise', false, { 'group' => :custom })

      expect(calculation_context.priority_for(dependency)).to eq(1.0)
    end

    context 'with custom opts' do
      let(:opts) do
        {
          dependency_priorities: { rails: 15.0 },
          group_priorities: { production: 3.0 },
          default_dependency_priority: 1.5
        }
      end

      it 'returns priority for dependency defined in dependency priorities' do
        dependency = Bundler::Dependency.new('rails', false)

        expect(calculation_context.priority_for(dependency)).to eq(15.0)
      end

      it 'returns group priority for dependency not defined in dependency priorities' do
        dependency = Bundler::Dependency.new('devise', false, { 'group' => :production })

        expect(calculation_context.priority_for(dependency)).to eq(3.0)
      end

      it 'returns default dependency priority for dependency not defined in dependency or group priorities' do
        dependency = Bundler::Dependency.new('devise', false, { 'group' => :custom })

        expect(calculation_context.priority_for(dependency)).to eq(1.5)
      end
    end
  end

  describe '#advisory_penalty_for' do
    it 'returns penalty for criticality present in advisory penalties' do
      expect(calculation_context.advisory_penalty_for(:high)).to eq(3.0)
    end

    it 'returns fallback penalty for criticality not present in advisory penalties' do
      expect(calculation_context.advisory_penalty_for(:blabla)).to eq(0.5)
    end

    context 'with custom opts' do
      let(:opts) { { advisory_penalties: { high: 15.0 }, fallback_advisory_penalty: 1.0 } }

      it 'returns custom penalty for criticality present in advisory penalties' do
        expect(calculation_context.advisory_penalty_for(:high)).to eq(15.0)
      end

      it 'returns custom fallback penalty for criticality not present in advisory penalties' do
        expect(calculation_context.advisory_penalty_for(:blabla)).to eq(1.0)
      end
    end
  end

  describe '#segment_severity' do
    it 'returns severity for segment defined in segment severities' do
      expect(calculation_context.segment_severity(1)).to eq(1.15)
    end

    it "returns fallback severity when segment doesn't have a defined severity" do
      expect(calculation_context.segment_severity(4)).to eq(1.0)
    end

    it 'returns 1.0 when segment is falsy' do
      expect(calculation_context.segment_severity(nil)).to eq(1.0)
    end

    context 'with custom opts' do
      let(:opts) { { segment_severities: [10.0, 9.0, 8.0], fallback_segment_severity: 5.0 } }

      it 'returns severity for segment defined in segment severities' do
        expect(calculation_context.segment_severity(1)).to eq(9.0)
      end

      it "returns fallback severity when segment doesn't have a defined severity" do
        expect(calculation_context.segment_severity(4)).to eq(5.0)
      end
    end
  end

  describe '#advisory_severity' do
    it 'returns default advisory severity' do
      expect(calculation_context.advisory_severity).to eq(1.09)
    end

    context 'with custom opts' do
      let(:opts) { { advisory_severity: 2.0 } }

      it 'returns advisory severity' do
        expect(calculation_context.advisory_severity).to eq(2.0)
      end
    end
  end

  describe '#new_versions_severity' do
    it 'returns default new versions severity' do
      expect(calculation_context.new_versions_severity).to eq(1.07)
    end

    context 'with custom opts' do
      let(:opts) { { new_versions_severity: 2.0 } }

      it 'returns new versions severity' do
        expect(calculation_context.new_versions_severity).to eq(2.0)
      end
    end
  end
end
