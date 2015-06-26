require File.expand_path('../../../../spec_helper', __FILE__)

describe "/ri_gse/grade_span_expectations/show.html.haml" do
  
  before(:each) do
    target = mock('target', :number => 1, :description => "nothing here", :knowledge_statement => nil, :unifying_themes => [])
    domain = mock('domain')
    canned_responses = {
      :assessment_target => target,
      :domain => domain,
      :expectations => [],
      :gse_key => "GSE_KEY",
      :grade_span => "k-12",
      :number => 1
    }
    
    @gse = mock_model(RiGse::GradeSpanExpectation,canned_responses)
    assign(:grade_span_expectation, @gse)
  end

  it "should render attributes in" do
    render
    # TODO: make some assertions about the view!
  end
end

