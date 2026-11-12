class NotebookPagination
  DEFAULT_PER_PAGE = 5
  MAX_PER_PAGE = 20

  attr_reader :page, :per_page, :total_count

  def initialize(total_count:, page: nil, per_page: nil)
    @total_count = total_count
    @per_page = positive_integer(per_page, DEFAULT_PER_PAGE).clamp(1, MAX_PER_PAGE)
    @page = positive_integer(page, 1).clamp(1, total_pages)
  end

  def total_pages
    [ (total_count.to_f / per_page).ceil, 1 ].max
  end

  def offset
    (page - 1) * per_page
  end

  def first_item
    total_count.zero? ? 0 : offset + 1
  end

  def last_item
    [ offset + per_page, total_count ].min
  end

  def page_numbers
    numbers = [ 1, page - 1, page, page + 1, total_pages ].select { |number| number.between?(1, total_pages) }.uniq.sort
    numbers.each_cons(2).flat_map { |left, right| right - left > 1 ? [ left, nil ] : [ left ] } + [ numbers.last ]
  end

  private

    def positive_integer(value, fallback)
      value.to_s.match?(/\A[1-9]\d*\z/) ? value.to_i : fallback
    end
end
