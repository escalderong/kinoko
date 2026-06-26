require 'rails_helper'

RSpec.describe "Flash messages", type: :request do
  let(:user) { create(:user, :waiter) }

  before { sign_in user }

  context "after an action that sets a flash" do
    before { get "/app/settings" }

    it "renders exactly once in the DOM" do
      follow_redirect!

      expect(response.body.scan('role="alert"').count).to eq(1)
    end

    it "does not persist to the next request" do
      follow_redirect!

      get app_orders_path
      expect(response.body).not_to include('role="alert"')
    end
  end
end
