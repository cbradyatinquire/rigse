class Reports::Excel
  require 'spreadsheet'
  require 'nokogiri' # text sanitization ...

  def initialize(opts = {})
    @verbose = !!opts[:verbose]
    STDOUT.sync = true if @verbose
  end

  protected

  def iterate_with_status(objects, &block)
    class_str = objects.first.class.to_s
    class_str = class_str.pluralize if objects.size > 1
    puts "Processing #{objects.size} #{class_str} ...\n" if @verbose
    reset_status
    objects.each do |o|
      print_status
      yield o
    end
    puts " done." if @verbose
  end

  def write_sheet_headers(sheet, column_defs)
    column_defs.each do |col|
      col.write_header(sheet)
    end
  end

  def percent(completed, total)
    percent = "n/a"
    percent = (((completed.to_f / total.to_f) * 100).round.to_s + "%") unless total == 0
    return percent
  end

  def print_status
    return unless @verbose
    @count ||= 0
    print "\n#{"%4d" % @count}: " if @count % 50 == 0
    print "."
    @count += 1
  end

  def reset_status
    @count = 0
  end

  def clean_text(html)
    return Nokogiri::HTML(html).inner_text
  end
  
  def school_name_for(student)
    name = student.school ? (student.school.name || "School #{student.school.name}") : "No School"
    return name
  end
  
  def clazz_name_for(offering)
    name = offering.clazz ? (offering.clazz.name || "Class: #{offering.clazz.id}") : "No Class"
    return name
  end

  # Return a list of offerings
  # that have ever been run for a clazz
  # this is to support removed offerings
  def ever_offered_for(clazz)
    id = clazz.id
    @class_offering_map ||= {}
    result =  @class_offering_map[:id]
    unless result
      offerings = clazz.students.map {|s| s.learners.map {|l| l.offering}}.flatten.uniq
      result = @class_offering_map[:id] = offerings
    end
    result
  end

end
