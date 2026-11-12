require "test_helper"

class NotebookPaginationTest < ActiveSupport::TestCase
  test "normalizes invalid parameters and caps the page size" do
    [ nil, "abc", "0", "-2", [ "2" ], { page: "2" } ].each do |value|
      pagination = NotebookPagination.new(total_count: 30, page: value, per_page: value)
      assert_equal 1, pagination.page
      assert_equal 5, pagination.per_page
    end

    pagination = NotebookPagination.new(total_count: 31, page: "999", per_page: "999")
    assert_equal 20, pagination.per_page
    assert_equal 2, pagination.page
    assert_equal 21, pagination.first_item
    assert_equal 31, pagination.last_item
  end

  test "empty collections have a single page and zero range" do
    pagination = NotebookPagination.new(total_count: 0, page: "3")
    assert_equal 1, pagination.page
    assert_equal 1, pagination.total_pages
    assert_equal 0, pagination.first_item
    assert_equal 0, pagination.last_item
    assert_equal [ 1 ], pagination.page_numbers
  end

  test "large collections use a compact window with first and last pages" do
    pagination = NotebookPagination.new(total_count: 1000, page: "100")
    assert_equal [ 1, nil, 99, 100, 101, nil, 200 ], pagination.page_numbers
  end
end
