require 'rails_helper'

describe 'Usuário edita uma modalidade de transporte' do
  it 'sem estar autenticado' do
    mode_of_transport = ModeOfTransport.create!(name: 'Express', minimum_distance: 20,
                                                maximum_distance: 2000, minimum_weight: 0,
                                                maximum_weight: 500, flat_rate: 1500,
                                                status: :active)
    patch(mode_of_transport_path(mode_of_transport), params: { mode_of_transport: { flat_rate: 0 } })
    expect(response).to redirect_to new_user_session_path
  end

  it 'e não é admin' do
    mode_of_transport = ModeOfTransport.create!(name: 'Express', minimum_distance: 20,
                                                maximum_distance: 2000, minimum_weight: 0,
                                                maximum_weight: 500, flat_rate: 1500,
                                                status: :active)
    user = User.create!(name: 'Daiane Silva', email: 'daiane_silva@sistemadefrete.com.br', password: 'senha123')
    login_as user
    patch(mode_of_transport_path(mode_of_transport), params: { mode_of_transport: { flat_rate: 0 } })
    expect(response).to redirect_to root_path
  end
end
