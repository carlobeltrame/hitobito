# encoding: utf-8

#  Copyright (c) 2012-2017, Jungwacht Blauring Schweiz. This file is part of
#  hitobito and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito.

module Export::Pdf
  module Invoice

    class Runner
      def render(invoice, articles, esr)
        pdf = Prawn::Document.new(page_size: 'A4',
                                  page_layout: :portrait,
                                  margin: 2.cm)
        customize(pdf)
        unless(articles == 'false')
          sections.each { |section| section.new(pdf, invoice).render }
        end
        Esr.new(pdf, invoice).render unless(esr == 'false')
        pdf.render
      end

      private

      def customize(pdf)
        pdf.font_size 10
        pdf.font 'Helvetica'
        pdf
      end

      def sections
        [Header, InvoiceInformation, ReceiverAddress, Articles, InvoiceText]
      end
    end

    mattr_accessor :runner

    self.runner = Runner

    def self.render(invoice, articles, esr)
      runner.new.render(invoice, articles, esr)
    end
  end
end
