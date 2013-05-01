class ActivityRuntimeAPI
  def self.publish(hash, user)
    external_activity = nil
    Investigation.transaction do
      investigation = Investigation.create(:name => hash["name"], :user => user)
      activity = Activity.create(:name => hash["name"], :user => user, :investigation => investigation)
      external_activity = ExternalActivity.create(
        :name             => hash["name"],
        :description      => hash["description"],
        :url              => hash["url"],
        :rest_create_url  => hash["create_url"],
        :template         => activity,
        :user => user
      )

      hash["sections"].each do |section_data|
        section = Section.create(
          :name => section_data["name"],
          :activity => activity,
          :user => user
        )

        section_data["pages"].each do |page_data|
          page = Page.create(
            :name => page_data["name"],
            :section => section,
            :user => user
          )

          page_data["elements"].each do |element_data|
            embeddable = case element_data["type"]
            when "open_response"
              create_open_response(element_data, user)
            when "multiple_choice"
              create_multiple_choice(element_data, user)
            else
              next
            end

            page.add_embeddable(embeddable)
          end
        end
      end
    end

    return external_activity
  end

  private

  def self.create_open_response(or_data, user)
    Embeddable::OpenResponse.create(
      :prompt => or_data["prompt"],
      :external_id => or_data["id"],
      :user => user
    )
  end

  def self.create_multiple_choice(mc_data, user)
    mc = Embeddable::MultipleChoice.create(
      :prompt => mc_data["prompt"],
      :external_id => mc_data["id"],
      :allow_multiple_selection => mc_data["allow_multiple_selection"],
      :user => user
    )

    mc_data["choices"].each do |choice_data|
      Embeddable::MultipleChoiceChoice.create(
        :multiple_choice => mc,
        :choice => choice_data["content"],
        :external_id => choice_data["id"],
        :is_correct => choice_data["correct"]
      )
    end

    return mc
  end
end