# encoding: utf-8

#  Copyright (c) 2012-2017, Jungwacht Blauring Schweiz. This file is part of
#  hitobito and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito.

module Export::Pdf::Invoice
  class ReceiverAddress < Section

    def render
      float do
        move_cursor_to 640
        bounding_box([290, cursor], width: bounds.width, height: 80) do
          receiver_address_table
        end
      end
    end
  end
end
