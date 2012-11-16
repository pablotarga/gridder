class Base

  def initialize(*opts)
    opts.extract_options!.each do |k,v|
      self.send("#{k}=", v) if self.respond_to?("#{k}=")
    end
  end

  def self.load(amount=10)
    data = YAML::load_file("data.yml")[0..amount]

    data.each_with_index.map do |e, i|
      p = Person.new(e)
      p.address = Address.new(e[:address])

      p
    end
  end

end