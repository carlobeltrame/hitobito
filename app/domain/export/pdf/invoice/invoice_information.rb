# encoding: utf-8

#  Copyright (c) 2012-2017, Jungwacht Blauring Schweiz. This file is part of
#  hitobito and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito.

module Export::Pdf::Invoice
  class InvoiceInformation < Section

    def render
      move_cursor_to 640
      bounding_box([0, cursor], width: bounds.width, height: 80) do
        table(information, cell_style: { borders: [], padding: [1, 20, 0, 0] })
      end
    end

    private

    def information
      [
        ['Rechnungsnummer:', invoice.sequence_number],
        ['Rechnungsdatum:', (invoice.sent_at.strftime('%d.%m.%Y') if invoice.sent_at)],
        ['Fällig bis:', (invoice.due_at.strftime('%d.%m.%Y') if invoice.due_at)]
      ]
    end
  end
end
