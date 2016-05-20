class ConflictPresenter < Burgundy::Item

  def description
    base + meat
  end

  private

  def base
    "This edit thinks that #{name} is "
  end

  def meat
    " #{from}, but it is actually #{current}."
  end

  def from
    item[:conflict][:from] || 'NULL'
  end

  def current
    item[:conflict][:current] || 'NULL'
  end

  def name
    Development.human_attribute_name item[:name]
  end
end
