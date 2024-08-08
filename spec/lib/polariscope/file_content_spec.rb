# frozen_string_literal: true

RSpec.describe Polariscope::FileContent do
  describe '.for' do
    subject(:contents) { described_class.for(path) }

    context 'when file in Dir.pwd exists' do
      let(:path) { 'spec/files/test' }

      it 'returns string with contents of the file' do
        expect(contents).to eq("Actual data\n")
      end
    end

    context 'when file in Dir.pwd missing' do
      let(:path) { 'spec/files/unknown' }

      it 'returns blank string' do
        expect(contents).to eq('')
      end
    end
  end
end
