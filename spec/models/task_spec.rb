require 'spec_helper'

describe Task do
  context 'Relationships' do
    it { should have_many(:case_tasks).dependent(:destroy) }
    it { should have_many(:cases).through(:case_tasks) }
    it { should belong_to(:user) }
    it { should belong_to(:firm) }
  end

  context 'Validations' do
  end

  context 'Accessible attributes' do

  end
end
