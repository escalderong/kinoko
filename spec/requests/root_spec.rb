require 'rails_helper'

RSpec.describe "Root", type: :request do
  context 'when the user is authenticated' do
    it 'redirects to /app/orders' do
      user = create(:user)
      sign_in user

      get "/"

      expect(response).to redirect_to("/app/orders")
    end
  end

  context 'when the user is not authenticated' do
    it 'redirects to the sign-in page' do
      get "/"

      expect(response).to redirect_to("/users/sign_in")
    end
  end
end
