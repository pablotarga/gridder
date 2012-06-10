require "nokogiri"
module Gridder

  extend self

  GRID_HEADER_SPLITTER = "::"
  def for(data, *opts)
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
            data.each do |d|
              doc.tr do
                config[:body].each do |b|
                  b.symbolize_keys!
                  opts = {}
                  opts[:class] = b[:class] if b[:class].present?
                  opts[:style] = b[:style] if b[:style].present?
                  
                  r = if b[:data].is_a?(Proc)
                        b[:data].arity.zero? ? b[:data].call : b[:data].call(d)
                      else
                        d.send(b[:data])
                      end

                  doc.td(opts){doc.cdata r}
                end
              end
            end
          end
          
        end
      end      
    end
    
    builder.to_html.html_safe
  end

end
