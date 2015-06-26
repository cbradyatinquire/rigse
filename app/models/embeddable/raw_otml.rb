class Embeddable::RawOtml < ActiveRecord::Base
  self.table_name = "embeddable_raw_otmls"

  belongs_to :user
  has_many :page_elements, :as => :embeddable
  has_many :pages, :through =>:page_elements
  has_many :teacher_notes, :as => :authored_entity

  after_create :initialize_otml_content_with_local_id

  def initialize_otml_content_with_local_id
    self.otml_content = <<-HEREDOC
<OTCompoundDoc local_id='raw_otml_#{self.id}'>
  <bodyText>
    <div id='content'>Put your content here. Make sure you keep this local id on your root object when you change it: local_id='raw_otml_#{self.id}'</div>
  </bodyText>
</OTCompoundDoc>
    HEREDOC
    self.save
  end
  
  acts_as_replicatable

  include Changeable

  self.extend SearchableModel
  
  @@searchable_attributes = %w{name description}
  
  class <<self
    def searchable_attributes
      @@searchable_attributes
    end
  end

  default_value_for :name, "Embeddable::RawOtml element"
  default_value_for :description, "A simple OTCompoundDoc example ..."

  def imports
    if @imports
      @imports
    else
      models = self.otml_content.scan(/OT\w+/)
      @imports = models.collect { |m| OtrunkExample::OtrunkImport.find_by_classname(m) }.compact
    end
  end

  def otrunk_imports
    self.imports.collect { |i| i.fq_classname }
  end
  
  # [['text_edit_edit_view', 'org.concord.otrunk.ui.OTText', 'org.concord.otrunk.ui.swing.OTTextEditEditView'], ... ]
  def otrunk_view_entries
    if @otrunk_view_entries
      @otrunk_view_entries
    else
      imports_with_views = self.imports.find_all { |import|  import.standard_view_entry }
      view_entries = imports_with_views.collect do |import|
        view_entry = import.standard_view_entry
        [view_entry.name_for_local_id, import.fq_classname, view_entry.fq_classname]
      end
      @otrunk_view_entries = view_entries
    end
  end
  
  def otrunk_edit_view_entries
    if @otrunk_edit_view_entries
      @otrunk_edit_view_entries
    else
      imports_with_views = self.imports.find_all { |import|  import.standard_edit_view_entry }
      edit_view_entries = imports_with_views.collect do |import| 
        view_entry = import.standard_edit_view_entry
        [view_entry.name_for_local_id, import.fq_classname, view_entry.fq_classname]
      end
      @otrunk_edit_view_entries = edit_view_entries
    end    
  end

end
