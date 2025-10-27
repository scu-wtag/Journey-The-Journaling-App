require 'rails_helper'
require 'i18n/tasks'

RSpec.describe 'I18n housekeeping' do
  let(:i18n) { I18n::Tasks::BaseTask.new }

  it 'does not have missing keys' do
    missing = i18n.missing_keys
    expect(missing).to be_empty,
                       "Missing #{missing.leaves.count} i18n keys.\nRun: `i18n-tasks missing`"
  end

  it 'does not have unused keys' do
    unused = i18n.unused_keys
    expect(unused).to be_empty,
                      "#{unused.leaves.count} unused i18n keys.\nRun: `i18n-tasks unused`"
  end

  it 'files are normalized' do
    non_normalized = i18n.non_normalized_paths
    expect(non_normalized).to be_empty,
                              "These files need normalization:\n#{non_normalized.map do |p|
                                "  #{p}"
                              end.join("\n")}\nRun: `i18n-tasks normalize`"
  end

  it 'does not have inconsistent interpolations' do
    inconsistent = i18n.inconsistent_interpolations
    expect(inconsistent).to be_empty,
                            "#{inconsistent.leaves.count} inconsistent interpolations.
                            \nRun: `i18n-tasks check-consistent-interpolations`"
  end
end
