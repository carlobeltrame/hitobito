# encoding: utf-8

#  Copyright (c) 2012-2017, Jungwacht Blauring Schweiz. This file is part of
#  hitobito and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito.

class InvoicesController < CrudController
  self.nesting = Group
  self.permitted_attrs = [:title, :description, :invoice_items_attributes]
  self.sort_mappings = { recipient: Person.order_by_name_statement }


  def destroy
    cancelled = run_callbacks(:destroy) { entry.update(state: :cancelled) }
    set_failure_notice unless cancelled
    respond_with(entry, success: cancelled, location: group_invoices_path(parent))
  end

  def show
    respond_to do |format|
      format.html { super }
      format.pdf { render_pdf }
    end
  end

  private

  def render_pdf
    pdf = Export::Pdf::Invoice.render(entry, params[:articles], params[:esr])
    send_data pdf, type: :pdf, disposition: 'inline', filename: pdf_filename
  end

  def list_entries
    scope = super.includes(recipient: [:groups, :roles]).references(:recipient).list
    scope.page(params[:page]).per(50)
  end

  def authorize_class
    authorize!(:create, parent.invoices.build)
  end

  def pdf_filename
    "#{entry.title.tr(' ', '_')}_#{entry.sequence_number}.pdf"
  end

end
