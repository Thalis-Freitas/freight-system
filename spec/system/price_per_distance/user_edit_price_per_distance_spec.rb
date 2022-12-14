require 'rails_helper'

describe 'Usuário edita uma configuração de preço por distância de uma modalidade de transporte' do
  it 'se estiver autenticado' do
    mode_of_transport = ModeOfTransport.create!(name: 'Express', minimum_distance: 20,
                                                maximum_distance: 2000, minimum_weight: 0,
                                                maximum_weight: 500, flat_rate: 1500,
                                                status: :active)
    price_per_distance = PricePerDistance.create!(minimum_distance: 20, maximum_distance: 80, rate: 500,
                                                  mode_of_transport:)
    visit edit_mode_of_transport_price_per_distance_path(mode_of_transport, price_per_distance)
    expect(current_path).to eq new_user_session_path
    expect(page).to have_content 'Para continuar, faça login ou registre-se'
  end

  it 'se for admin' do
    mode_of_transport = ModeOfTransport.create!(name: 'Express', minimum_distance: 20,
                                                maximum_distance: 2000, minimum_weight: 0,
                                                maximum_weight: 500, flat_rate: 1500,
                                                status: :active)
    PricePerDistance.create!(minimum_distance: 20, maximum_distance: 80, rate: 500,
                             mode_of_transport:)
    user = User.create!(name: 'Daiane Silva', email: 'daiane_silva@sistemadefrete.com.br', password: 'senha123')
    login_as user
    visit mode_of_transport_path(mode_of_transport)
    expect(page).not_to have_link 'Editar'
  end

  it 'a partir da url se for admin' do
    mode_of_transport = ModeOfTransport.create!(name: 'Express', minimum_distance: 20,
                                                maximum_distance: 2000, minimum_weight: 0,
                                                maximum_weight: 500, flat_rate: 1500,
                                                status: :active)
    price_per_distance = PricePerDistance.create!(minimum_distance: 20, maximum_distance: 80, rate: 500,
                                                  mode_of_transport:)
    user = User.create!(name: 'Daiane Silva', email: 'daiane_silva@sistemadefrete.com.br', password: 'senha123')
    login_as user
    visit edit_mode_of_transport_price_per_distance_path(mode_of_transport, price_per_distance)
    expect(current_path).to eq root_path
    expect(page).to have_content 'Acesso não autorizado'
  end

  it 'a partir do menu' do
    admin = User.create!(name: 'Marta Alves', email: 'marta@sistemadefrete.com.br', password: 'password', role: :admin)
    mode_of_transport = ModeOfTransport.create!(name: 'Express', minimum_distance: 20,
                                                maximum_distance: 2000, minimum_weight: 0,
                                                maximum_weight: 500, flat_rate: 1500,
                                                status: :active)
    price_per_distance = PricePerDistance.create!(minimum_distance: 20, maximum_distance: 80, rate: 500,
                                                  mode_of_transport:)

    login_as admin
    visit root_path
    within('nav') do
      click_link 'Modalidades de Transporte'
    end
    click_link 'Express'
    click_link 'Editar'

    expect(current_path).to eq edit_mode_of_transport_price_per_distance_path(mode_of_transport, price_per_distance)
    expect(page).to have_content 'Editar configuração de preço por distância'
    expect(page).to have_content 'Modalidade Express'
    within('main form') do
      expect(page).to have_field 'Distância mínima', with: '20'
      expect(page).to have_field 'Distância máxima', with: '80'
      expect(page).to have_field 'Taxa (em centavos)', with: '500'
      expect(page).to have_button 'Salvar'
    end
  end

  it 'com sucesso' do
    admin = User.create!(name: 'Marta Alves', email: 'marta@sistemadefrete.com.br', password: 'password', role: :admin)
    mode_of_transport = ModeOfTransport.create!(name: 'Express', minimum_distance: 20,
                                                maximum_distance: 2000, minimum_weight: 0,
                                                maximum_weight: 500, flat_rate: 1500,
                                                status: :active)
    price_per_distance = PricePerDistance.create!(minimum_distance: 20, maximum_distance: 80, rate: 500,
                                                  mode_of_transport:)
    login_as admin
    visit edit_mode_of_transport_price_per_distance_path(mode_of_transport, price_per_distance)
    fill_in 'Distância mínima', with: '25'
    fill_in 'Distância máxima', with: '90'
    fill_in 'Taxa (em centavos)', with: '1000'
    click_button 'Salvar'

    expect(page).to have_content 'Configuração de preço por distância atualizada com sucesso'
    expect(page).to have_content 'De 25km a 90km R$ 10,00'
  end

  it 'e deixa campos obrigatórios em branco' do
    admin = User.create!(name: 'Marta Alves', email: 'marta@sistemadefrete.com.br', password: 'password', role: :admin)
    mode_of_transport = ModeOfTransport.create!(name: 'Express', minimum_distance: 20,
                                                maximum_distance: 2000, minimum_weight: 0,
                                                maximum_weight: 500, flat_rate: 1500,
                                                status: :active)
    price_per_distance = PricePerDistance.create!(minimum_distance: 20, maximum_distance: 80, rate: 500,
                                                  mode_of_transport:)
    login_as admin
    visit edit_mode_of_transport_price_per_distance_path(mode_of_transport, price_per_distance)
    fill_in 'Distância mínima', with: ''
    fill_in 'Distância máxima', with: ''
    fill_in 'Taxa (em centavos)', with: ''
    click_button 'Salvar'

    expect(page).to have_content 'Não foi possível atualizar a configuração de preço por distância'
    expect(page).to have_content 'Distância mínima não pode ficar em branco'
    expect(page).to have_content 'Distância máxima não pode ficar em branco'
    expect(page).to have_content 'Taxa não pode ficar em branco'
    expect(page).not_to have_content 'Configuração de preço por distância atualizada com sucesso'
  end

  it 'com dados inválidos' do
    admin = User.create!(name: 'Marta Alves', email: 'marta@sistemadefrete.com.br', password: 'password', role: :admin)
    mode_of_transport = ModeOfTransport.create!(name: 'Express', minimum_distance: 20,
                                                maximum_distance: 2000, minimum_weight: 0,
                                                maximum_weight: 500, flat_rate: 1500,
                                                status: :active)
    price_per_distance = PricePerDistance.create!(minimum_distance: 20, maximum_distance: 80, rate: 500,
                                                  mode_of_transport:)
    login_as admin
    visit edit_mode_of_transport_price_per_distance_path(mode_of_transport, price_per_distance)
    fill_in 'Distância mínima', with: '2900'
    fill_in 'Distância máxima', with: '10'
    fill_in 'Taxa (em centavos)', with: '-10'
    click_button 'Salvar'

    expect(page).to have_content 'Distância mínima deve ser menor que 2000'
    expect(page).to have_content 'Distância máxima deve ser maior que 20'
    expect(page).to have_content 'Taxa deve ser maior ou igual a 0'
  end

  it 'com distâncias não atendidas pela modalidade de transporte' do
    admin = User.create!(name: 'Marta Alves', email: 'marta@sistemadefrete.com.br', password: 'password', role: :admin)
    mode_of_transport = ModeOfTransport.create!(name: 'Express', minimum_distance: 20,
                                                maximum_distance: 2000, minimum_weight: 0,
                                                maximum_weight: 500, flat_rate: 1500,
                                                status: :active)
    price_per_distance = PricePerDistance.create!(minimum_distance: 20, maximum_distance: 80, rate: 500,
                                                  mode_of_transport:)
    login_as admin
    visit edit_mode_of_transport_price_per_distance_path(mode_of_transport, price_per_distance)
    fill_in 'Distância mínima', with: '5'
    fill_in 'Distância máxima', with: '2700'
    click_button 'Salvar'

    expect(page).to have_content 'Distância mínima deve ser maior ou igual a 20'
    expect(page).to have_content 'Distância máxima deve ser menor ou igual a 2000'
  end

  it 'sem modificar os campos' do
    admin = User.create!(name: 'Marta Alves', email: 'marta@sistemadefrete.com.br', password: 'password', role: :admin)
    mode_of_transport = ModeOfTransport.create!(name: 'Express', minimum_distance: 20,
                                                maximum_distance: 2000, minimum_weight: 0,
                                                maximum_weight: 500, flat_rate: 1500,
                                                status: :active)
    price_per_distance = PricePerDistance.create!(minimum_distance: 20, maximum_distance: 80, rate: 500,
                                                  mode_of_transport:)
    login_as admin
    visit edit_mode_of_transport_price_per_distance_path(mode_of_transport, price_per_distance)
    click_button 'Salvar'

    expect(page).to have_content 'Nenhuma modificação encontrada'
  end
end
