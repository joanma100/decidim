# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe Component do
    subject { component }

    let(:component) { build(:component, manifest_name: "dummy") }

    it { is_expected.to be_valid }
    it { is_expected.to be_versioned }

    include_examples "publicable"
    include_examples "resourceable"

    it "overwrites the log presenter" do
      expect(described_class.log_presenter_class_for(:foo))
        .to eq Decidim::AdminLog::ComponentPresenter
    end

    describe "default scope" do
      subject { described_class.all }

      it "orders the components by weight and by manifest name" do
        described_class.destroy_all

        component_b = create :component, manifest_name: :b, weight: 0
        component_c = create :component, manifest_name: :c, weight: 2
        component_a = create :component, manifest_name: :a, weight: 0

        expect(subject).to eq [component_a, component_b, component_c]
      end
    end

    describe "with scope setting" do
      let!(:organization) { create(:organization) }
      let(:participatory_space) do
        create(:participatory_process, organization: organization, scopes_enabled: space_scopes_enabled,
                                       scope: space_scope)
      end

      let!(:component) do
        create(:component,
               manifest_name: "dummy",
               participatory_space: participatory_space,
               settings: {
                 scopes_enabled: component_scopes_enabled,
                 scope_id: component_scope&.id
               })
      end

      context "when component scopes are enabled" do
        let(:space_scope) { create :scope, organization: organization }
        let(:space_scopes_enabled) { true }
        let(:component_scopes_enabled) { true }
        let(:component_scope) { create(:scope, organization: organization) }

        it "returns true for component scopes_enabled" do
          expect(subject.scopes_enabled).to eq true
        end

        it "returns the component scope" do
          expect(subject.scope).to eq component_scope
          expect(participatory_space.scope).to eq space_scope
        end
      end

      context "when component scopes are disabled" do
        let(:space_scope) { create :scope, organization: organization }
        let(:space_scopes_enabled) { true }
        let(:component_scopes_enabled) { false }
        let(:component_scope) { nil }

        it "returns false for component scopes_enabled" do
          expect(subject.scopes_enabled).to eq false
        end

        it "returns the space's scope" do
          expect(subject.scope).to eq space_scope
          expect(participatory_space.scope).to eq space_scope
        end
      end

      context "when the component and the participatory_space have scopes disabled" do
        let(:space_scope) { nil }
        let(:space_scopes_enabled) { false }
        let(:component_scopes_enabled) { false }
        let(:component_scope) { nil }

        it "scopes_enabled returns false" do
          expect(subject.scopes_enabled).to eq false
          expect(participatory_space.scopes_enabled).to eq false
        end

        it "returns no scope" do
          expect(subject.scope).to eq nil
          expect(participatory_space.scope).to eq nil
        end
      end
    end
  end
end
