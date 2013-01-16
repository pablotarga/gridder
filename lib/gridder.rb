require "nokogiri"
module Gridder

  GRID_HEADER_SPLITTER = "::"
  def self.for(data, *opts)
    config = {:empty_message => "Empty"}
    config = config.update(opts.extract_options!)

    titles = config[:body].map{|e| e[:title].to_s}
    max_level = titles.map{|e| e.split(GRID_HEADER_SPLITTER).size}.max

    header_rows = []
    max_level.times{header_rows << []}

    titles.each do |title_token|
      if title_token.blank?
        header_rows[0] << {:title => title_token, :rowspan => max_level}
        next
      end

      splitted_title_token = title_token.split(GRID_HEADER_SPLITTER)

      splitted_title_token.each_with_index do |title, idx|
        level = idx+1
        _hash = {}
        _hash[:title] = title

        if (splitted_title_token.size == level) && (max_level > level)
          _hash[:rowspan] = (max_level - idx)
        end

        if (header_rows[idx].last || {})[:title] != _hash[:title]
          header_rows[idx] << _hash
        else
          a = header_rows[idx].last
          a[:colspan] ||= 1
          a[:colspan] += 1
        end

      end
    end

    builder = Nokogiri::HTML::Builder.new do |doc|

      doc.table(config[:table]) do
        doc.thead(config[:thead]) do
          header_rows.each do |row|
            doc.tr do
              row.each do |cell|
                doc.th(:rowspan => cell[:rowspan], :colspan => cell[:colspan]){ doc.cdata cell[:title] }
              end
            end
          end
        end
        doc.tbody(config[:tbody]) do
          if data.blank?
            doc.tr{ doc.td(config[:empty_message], :class => :empty, :colspan => config[:body].size) }
          else
            data.each do |record|
              tr_config = if config[:tr].blank? && record.is_a?(ActiveRecord::Base)
                            {:id => ActionController::RecordIdentifier.dom_id(record)}
                          elsif config[:tr].is_a?(Proc)
                            config[:tr].arity.zero? ? config[:tr].call : config[:tr].call(record)
                          elsif config[:tr].is_a?(Symbol)
                            record.send(config[:tr])
                          else
                            config[:tr]
                          end

              doc.tr(tr_config) do
                config[:body].each do |cell|
                  r, opts = Gridder.get_cell_content(cell, record)
                  doc.td(opts){doc.cdata r}
                end
              end
            end
          end

        end

        if config[:footer] && config[:footer].is_a?(Array)
          doc.tfoot(config[:tfooter]) do
            doc.tr do
              config[:footer].each do |cell|
                r, opts = Gridder.get_cell_content(cell, data)
                doc.td(opts){doc.cdata r}
              end
            end
          end
        end
      end
    end

    builder.doc.root.to_html.html_safe
  end

private
  def self.get_cell_content(cell, record)
    cell.symbolize_keys!
    opts = {}
    opts[:class] = cell[:class] if cell[:class].present?
    opts[:style] = cell[:style] if cell[:style].present?

    r = if cell[:data].is_a?(Proc)
          cell[:data].arity.zero? ? cell[:data].call : cell[:data].call(record)
        else
          record.send(cell[:data])
        end
    [r, opts]
  end
end
