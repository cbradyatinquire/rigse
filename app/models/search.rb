class Search
  attr_accessor :engine
  attr_accessor :results
  attr_accessor :hits
  attr_accessor :text
  attr_accessor :material_types
  attr_accessor :sort_order
  attr_accessor :private
  attr_accessor :probe
  attr_accessor :no_probes
  attr_accessor :grade_span
  attr_accessor :domain_id
  attr_accessor :without_teacher_only
  attr_accessor :page
  attr_accessor :per_page
  attr_accessor :user_id
  attr_accessor :include_contributed

  SearchableModels        = [Investigation, Activity, ResourcePage, ExternalActivity]
  InvestigationMaterial   = "Investigation"
  ActivityMaterial        = "Activity"
  AllMaterials            = [InvestigationMaterial, ActivityMaterial]

  Newest       = 'Newest'
  Oldest       = 'Oldest'
  Alphabetical = 'Alphabetical'
  Popularity   = 'Popularity'
  Score        = 'Score'
  SortOptions  = {
    Newest       => [:updated_at, :desc],
    Oldest       => [:updated_at],
    Alphabetical => [:name],
    Popularity   => [:offerings_count, :desc],
    Score        => [:score, :desc]
  }
  NoSearchTerm    = nil
  NoGradeSpan     = NoDomainID = AnyProbeType =[]
  NoProbeRequired = ["0"]

  def self.clean_search_terms (term)
    return NoSearchTerm unless term
    # http://rubular.com/r/0XlbltgfqY
    not_word_digit_or_space = /[^\w|\s]/
    term.gsub(not_word_digit_or_space,'')
  end

  def self.clean_domain_id(domain_id)
    return NoDomainID unless domain_id
    [domain_id].flatten
  end

  def initialize(opts={})
    @text           = Search.clean_search_terms(opts[:search_term])
    @domain_id      = Search.clean_domain_id(opts[:domain_id])
    @results        = {}
    @hits           = {}
    @no_probes      = false
    @material_types = opts[:material_types] || AllMaterials

    @engine         = opts[:engine]         || Sunspot
    @grade_span     = opts[:grade_span]     || NoGradeSpan
    @probe          = opts[:probe]          || AnyProbeType
    @no_probes      = opts[:no_probe]       || false
    @private        = opts[:private]        || false
    @sort_order     = opts[:sort_order]     || Newest
    @page           = opts[:page]           || 1
    @per_page       = opts[:per_page]       || 10
    @user_id        = opts[:user_id]
    @include_contributed = opts[:include_contributed] || false
    @without_teacher_only = opts[:without_teacher_only] || true
    self.search()
  end

  def search
    self.results[:all] = []
    self.hits[:all] = []
    @material_types.each do |type|
      _results = @engine.search(SearchableModels) do |s|
        s.fulltext(@text)
        s.any_of do |c|
          c.with(:published, true)
          c.with(:published, [true, false]) if @private
          c.with(:user_id, @user_id)
        end
        s.with(:material_type, type)
        s.with(:domain_id, @domain_id) unless @domain_id.empty?
        s.with(:grade_span, @grade_span) unless @grade_span.empty?
        s.with(:probe_type_ids, @probe) unless (@probe.empty? || @no_probes)
        s.with(:no_probes, true) if @no_probes
        s.with(:is_official, true) unless @include_contributed
        s.facet :material_type
        s.order_by(*SortOptions[@sort_order])
        s.paginate(:page => @page, :per_page => @per_page)

      end
      self.results[:all] += _results.results
      self.hits[:all]    += _results.hits
      self.results[type] = _results.results
      self.hits[type]    = _results.hits
    end
  end

  def types(*types)
    type_names = types.map { |t| t.name                           }
    self.results.select    { |r| type_names.include? r.class_name }
  end

  def count; self.hits.size; end
  alias_method :size, :count
  alias_method :len, :count

  alias_method :probe_type, :probe

  def investigation_checkedstatus; @search.material_types.include? ::Investigation ; end
  def activity_checkedstatus; @search.material_types.include? ::Activity ; end
  def external_activity_checkedstatus; @search.material_types.include? ::Activity ; end
  def include_external_activities?; false; end

end