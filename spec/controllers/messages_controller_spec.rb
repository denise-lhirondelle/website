require 'rails_helper'

# frozen_string_literal: true
RSpec.describe MessagesController, type: :controller, js: true do
  describe 'GET #index' do
    subject { get :index }

    it_behaves_like 'action not allowed for guests'
    it_behaves_like 'action to be authorized with logged in user', Message
  end

  describe 'POST #create' do
    let(:message_params) do
      { message: { sender: 'sender',
                   email: 'valid@email.com',
                   content: 'A nice message' } }
    end

    subject { post :create, params: message_params, format: :js }

    it_behaves_like 'action that is allowed for guests'

    context 'with valid params' do
      let(:mailer) { double 'mailer', deliver_later: true }

      before do
        allow(MessageMailer).to receive(:send_to_admin).and_return mailer
      end

      it_behaves_like 'successful request'

      it 'tells the mailer to deliver' do
        post :create, params: message_params, format: :js
        expect(mailer).to have_received :deliver_later
      end
    end

    context 'with invalid params' do
      let(:message_params) do
        { message: { sender: '',
                     email: 'valid@com' } }
      end

      it_behaves_like 'successful request'
    end
  end
end
