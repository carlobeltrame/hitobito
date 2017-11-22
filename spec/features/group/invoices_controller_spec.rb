# encoding: utf-8

#  Copyright (c) 2012-2017, Jungwacht Blauring Schweiz, Pfadibewegung Schweiz.
#  This file is part of hitobito and licensed under the Affero General Public
#  License version 3 or later. See the COPYING file at the top-level
#  directory or at https://github.com/hitobito/hitobito.

require 'spec_helper'

describe InvoicesController do

  it 'shows invoices link when person is authorised' do
    sign_in(people(:bottom_member))
    visit root_path
    expect(page).to have_link 'Rechnungen'
  end

  it 'shows invoices subnav when person is authorised' do
    sign_in(people(:bottom_member))
    visit group_invoices_path(groups(:bottom_layer_one))
    expect(page).to have_link 'Rechnungen'
    expect(page).to have_css('nav.nav-left', text: 'Einstellungen')
  end

  it 'hides invoices link when person is authorised' do
    sign_in(people(:top_leader))
    visit root_path
    expect(page).not_to have_link 'Rechnungen'
  end

  context 'export' do
    before do
      @group = groups(:bottom_layer_one)
      @invoice = invoices(:invoice)
      sign_in(people(:bottom_member))
      visit group_invoice_path(@group, @invoice)
      click_link('Export')
    end

    it 'dropdown is available' do
      expect(page).to have_link 'Export'
      expect(page).to have_link 'Rechnung inkl. Einzahlungsschein'
      expect(page).to have_link 'Rechnung separat'
      expect(page).to have_link 'Einzahlungsschein separat'
    end

    it 'exports full invoice' do
      click_link('Rechnung inkl. Einzahlungsschein')
      expect(page).to have_current_path("/groups/#{@group.id}/invoices/#{@invoice.id}.pdf")
    end

    it 'exports only articles' do
      click_link('Rechnung separat')
      expect(page).to have_current_path("/groups/#{@group.id}/invoices/#{@invoice.id}.pdf?esr=false")
    end

    it 'exports only esr' do
      click_link('Einzahlungsschein separat')
      expect(page).to have_current_path("/groups/#{@group.id}/invoices/#{@invoice.id}.pdf?articles=false")
    end
  end
end

