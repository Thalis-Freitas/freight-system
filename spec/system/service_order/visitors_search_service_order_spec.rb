require 'rails_helper'

describe 'Visitante busca por uma ordem de serviço' do 
  it 'na página inicial' do 
    visit root_path
    within('main') do 
      expect(page).to have_field 'Rastrear entrega'
      expect(page).to have_button 'Buscar'
    end
  end

  it 'e encontra uma ordem de serviço em andamento' do 
    express = ModeOfTransport.create!(name:'Express', minimum_distance: 20, maximum_distance: 2000, 
                                      minimum_weight: 0, maximum_weight: 200, flat_rate: 1500, status: :active)
    PriceByWeight.create!(minimum_weight: 0, maximum_weight: 50, value: 100, mode_of_transport: express)
    PricePerDistance.create!(minimum_distance: 21, maximum_distance: 150, rate: 850, mode_of_transport: express)
    Deadline.create!(minimum_distance: 20, maximum_distance: 100, estimated_time: 3, mode_of_transport: express)
    allow(SecureRandom).to receive(:alphanumeric).with(15).and_return('ABC123456789DEF')
    vehicle = Vehicle.create!(nameplate: 'ISX8398', brand: 'Mercedez Benz', model: '710 PLUS', year_of_manufacture: '2020',
                              maximum_capacity: 6700)   
    service_order = ServiceOrder.create!(source_address: 'Avenida Getúlio Vargas, 250 - Feira de Santana', product_code: 'MDKSJ-CADGM-ASM24',
                                         height: 120, width: 65, depth: 70, weight: 12, destination_address: 'Avenida São Rafael, 478 - Salvador',
                                         recipient: 'Joana Matos', recipient_phone: "71999284839", total_distance: 100,
                                         status: :in_progress, mode_of_transport: express, started_in: 16.hours.ago, vehicle: vehicle)
 
    service_order.register_price_and_deadline
    visit root_path
    fill_in 'Rastrear entrega', with: 'ABC123456789DEF'
    click_button 'Buscar'

    expect(page).to have_content 'Código ABC123456789DEF'
    expect(page).to have_content "Iniciada em: #{I18n.l(16.hours.ago, format: :short)}"
    expect(page).to have_content 'Status: Em andamento'
    expect(page).to have_content 'Veículo alocado: ISX8398, Mercedez Benz - 710 PLUS'
    expect(page).to have_content 'Endereço de origem: Avenida Getúlio Vargas, 250 - Feira de Santana'
    expect(page).to have_content 'Endereço destino: Avenida São Rafael, 478 - Salvador'
    expect(page).to have_content "Previsão de entrega: #{I18n.l(16.hours.ago + service_order.deadline, format: :short)}"
  end

  it 'e encontra uma ordem de serviço entregue no prazo' do 
    express = ModeOfTransport.create!(name:'Express', minimum_distance: 20, maximum_distance: 2000, 
                                      minimum_weight: 0, maximum_weight: 200, flat_rate: 1500, status: :active)
    PriceByWeight.create!(minimum_weight: 0, maximum_weight: 50, value: 100, mode_of_transport: express)
    PricePerDistance.create!(minimum_distance: 1001, maximum_distance: 1500, rate: 3550, mode_of_transport: express)
    Deadline.create!(minimum_distance: 1001, maximum_distance: 2000, estimated_time: 48, mode_of_transport: express)
    vehicle = Vehicle.create!(nameplate: 'KER0414', brand: 'Volks', model: 'Constelallation 17.250', year_of_manufacture: '2012',
                              maximum_capacity: 16000)    
    allow(SecureRandom).to receive(:alphanumeric).with(15).and_return('ABC123456789DEF')
    service_order = ServiceOrder.create!(source_address: 'Rua Paracatu, 957 | São Paulo - SP', product_code: 'AMDNF-EOLDF-SHNFK',
                                         height: 70, width: 40, depth: 30, weight: 2, destination_address: 'Rua da Imprensa, 48 | Gramado - RS',
                                         recipient: 'João Cerqueira', recipient_phone: '54988475495', total_distance: 1120, started_in: 1.day.ago,
                                         closed_in: 3.hours.ago, mode_of_transport: express, vehicle: vehicle, status: :closed_on_deadline)       
                                    
    service_order.register_price_and_deadline
    visit root_path
    fill_in 'Rastrear entrega', with: 'ABC123456789DEF'
    click_button 'Buscar'

    expect(page).to have_content 'Código ABC123456789DEF'
    expect(page).to have_content "Iniciada em: #{I18n.l(1.day.ago, format: :short)}"
    expect(page).to have_content 'Status: Encerrada no prazo'
    expect(page).to have_content 'Veículo alocado: KER0414, Volks - Constelallation 17.250'
    expect(page).to have_content 'Endereço de origem: Rua Paracatu, 957 | São Paulo - SP'
    expect(page).to have_content 'Endereço destino: Rua da Imprensa, 48 | Gramado - RS'
    expect(page).to have_content "Encerrada em: #{I18n.l(3.hours.ago, format: :short)}"
  end

  it 'e encontra uma ordem de serviço entregue em atraso' do 
    express = ModeOfTransport.create!(name:'Express', minimum_distance: 20, maximum_distance: 2000, 
                                      minimum_weight: 0, maximum_weight: 200, flat_rate: 1500, status: :active)
    PriceByWeight.create!(minimum_weight: 0, maximum_weight: 50, value: 100, mode_of_transport: express)
    PricePerDistance.create!(minimum_distance: 1001, maximum_distance: 1500, rate: 3550, mode_of_transport: express)
    Deadline.create!(minimum_distance: 1001, maximum_distance: 2000, estimated_time: 48, mode_of_transport: express)
    vehicle = Vehicle.create!(nameplate: 'KER0414', brand: 'Volks', model: 'Constelallation 17.250', year_of_manufacture: '2012',
                              maximum_capacity: 16000)    
    allow(SecureRandom).to receive(:alphanumeric).with(15).and_return('ABC123456789DEF')
    service_order = ServiceOrder.create!(source_address: 'Rua Paracatu, 957 | São Paulo - SP', product_code: 'AMDNF-EOLDF-SHNFK',
                                         height: 70, width: 40, depth: 30, weight: 2, destination_address: 'Rua da Imprensa, 48 | Gramado - RS',
                                         recipient: 'João Cerqueira', recipient_phone: '54988475495', total_distance: 1120, started_in: 1.month.ago,
                                         closed_in: 3.hours.ago, mode_of_transport: express, vehicle: vehicle, status: :closed_in_arrears)       
    overdue_reason = OverdueReason.create!(overdue_reason: 'Falhas na comunicação com o motorista', service_order: service_order)      
    service_order.overdue_reason = overdue_reason     
    service_order.register_price_and_deadline

    visit root_path
    fill_in 'Rastrear entrega', with: 'ABC123456789DEF'
    click_button 'Buscar'

    expect(page).to have_content 'Código ABC123456789DEF'
    expect(page).to have_content "Iniciada em: #{I18n.l(1.month.ago, format: :short)}"
    expect(page).to have_content 'Status: Encerrada em atraso'
    expect(page).to have_content 'Motivo do atraso: Falhas na comunicação com o motorista'
    expect(page).to have_content 'Veículo alocado: KER0414, Volks - Constelallation 17.250'
    expect(page).to have_content 'Endereço de origem: Rua Paracatu, 957 | São Paulo - SP'
    expect(page).to have_content 'Endereço destino: Rua da Imprensa, 48 | Gramado - RS'
    expect(page).to have_content "Encerrada em: #{I18n.l(3.hours.ago, format: :short)}"
  end

  it 'sem preencher o campo' do 
    visit root_path
    fill_in 'Rastrear entrega', with: ''
    click_button 'Buscar'

    expect(page).to have_content 'Para realizar a busca é necessário preencher o campo com o código completo (15 caracteres)'
  end

  it 'e não encontra nenhua ordem de serviço' do
    visit root_path
    fill_in 'Rastrear entrega', with: 'ABC123456789DEF'
    click_on 'Buscar'

    expect(page).to have_content 'Nenhuma Ordem de Serviço encontrada'
  end

  it 'com código inválido' do 
    visit root_path
    fill_in 'Rastrear entrega', with: 'ABC'
    click_button 'Buscar'

    expect(page).to have_content 'Para realizar a busca é necessário preencher o campo com o código completo (15 caracteres)'
  end
end