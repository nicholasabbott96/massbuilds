class DevelopmentTeamSerializer

  # Use inside DevelopmentSerializer
  def initialize(development, max_team_size)
    @development   = development
    @max_team_size = max_team_size
    @row = Array.new(@max_team_size * team_attributes_count)
  end

  # TODO Refactor and clean up
  def to_row
    # Get attributes from all of the team members
    values = @development.team_memberships.map { |team_membership|
      [team_membership.organization.attributes.values_at(*member_attributes),
        # Need to get around Enumerize here -> the attribute is technically
        # serialized as an integer, so we need to #send instead.
        # Should we also test saving it? Test didn't catch this.
        membership_attributes.map{ |a| team_membership.send(a)}]
    }.flatten
    # then apply them to the nil-filled row
    values.each_with_index { |v, i| @row[i] = v }
    @row # and return the row
  end

  def to_header
    @max_team_size.times.map{ |id|
      header_template(id+1) # #times is 0-index, we want 1-index
    }.flatten
  end

  private

    def header_template(id)
      team_attributes.map{ |attrib| "team_member_#{id}_#{attrib}"}
    end

    def member_attributes
      Organization.attribute_names - %w(id creator_id created_at updated_at)
    end

    def membership_attributes
      %w( role )
    end

    def team_attributes
      member_attributes + membership_attributes
    end

    def team_attributes_count
      team_attributes.count
    end
end
