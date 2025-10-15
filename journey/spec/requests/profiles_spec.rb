require 'rails_helper'

RSpec.describe Profile, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:user) }
  end

  describe 'validations' do
    it { is_expected.to validate_length_of(:headquarters).is_at_most(100).allow_nil }
  end

  describe 'picture validations (ActiveStorage)' do
    let(:user) { create(:user) }

    let(:allowed_types) { %w(image/jpeg image/png image/webp image/avif) }
    let(:disallowed_types) { %w(image/gif image/bmp text/plain application/pdf) }

    def attach_with_type(record, content_type, size_bytes: 1024, name: 'dummy')
      io = StringIO.new('0' * size_bytes)
      record.picture.attach(
        io: io,
        filename: "#{name}.#{content_type.split('/').last}",
        content_type: content_type,
      )
    end

    context 'when no picture is attached' do
      it 'is valid (conditional validation)' do
        p = build(:profile, user: user)
        expect(p.picture).not_to be_attached
        expect(p).to be_valid
      end
    end

    context 'content type whitelist' do
      it 'accepts allowed image types' do
        allowed_types.each do |mime|
          p = build(:profile, user: user)
          attach_with_type(p, mime)
          expect(p).to be_valid, "expected #{mime} to be allowed"
        end
      end

      it 'rejects disallowed types' do
        disallowed_types.each do |mime|
          p = build(:profile, user: user)
          attach_with_type(p, mime)
          expect(p).to be_invalid, "expected #{mime} to be rejected"
          expect(p.errors[:picture]).to be_present
        end
      end
    end

    context 'file size limit' do
      it 'rejects files > 5 MB' do
        p = build(:profile, user: user)
        attach_with_type(p, 'image/jpeg', size_bytes: 5.megabytes + 1)
        expect(p).to be_invalid
        expect(p.errors[:picture]).to be_present
      end

      it 'accepts files <= 5 MB' do
        p = build(:profile, user: user)
        attach_with_type(p, 'image/jpeg', size_bytes: 5.megabytes)
        expect(p).to be_valid
      end
    end
  end
end
