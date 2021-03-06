# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::SingleLineBlockParams, :config do
  let(:cop_config) { { 'Methods' => [{ 'reduce' => %w[a e] }, { 'test' => %w[x y] }] } }

  it 'finds wrong argument names in calls with different syntax' do
    expect_offense(<<~RUBY)
      def m
        [0, 1].reduce { |c, d| c + d }
                        ^^^^^^ Name `reduce` block params `|a, e|`.
        [0, 1].reduce{ |c, d| c + d }
                       ^^^^^^ Name `reduce` block params `|a, e|`.
        [0, 1].reduce(5) { |c, d| c + d }
                           ^^^^^^ Name `reduce` block params `|a, e|`.
        [0, 1].reduce(5){ |c, d| c + d }
                          ^^^^^^ Name `reduce` block params `|a, e|`.
        [0, 1].reduce (5) { |c, d| c + d }
                            ^^^^^^ Name `reduce` block params `|a, e|`.
        [0, 1].reduce(5) { |c, d| c + d }
                           ^^^^^^ Name `reduce` block params `|a, e|`.
        ala.test { |x, z| bala }
                   ^^^^^^ Name `test` block params `|x, y|`.
      end
    RUBY

    expect_correction(<<~RUBY)
      def m
        [0, 1].reduce { |a, e| a + e }
        [0, 1].reduce{ |a, e| a + e }
        [0, 1].reduce(5) { |a, e| a + e }
        [0, 1].reduce(5){ |a, e| a + e }
        [0, 1].reduce (5) { |a, e| a + e }
        [0, 1].reduce(5) { |a, e| a + e }
        ala.test { |x, y| bala }
      end
    RUBY
  end

  it 'allows calls with proper argument names' do
    expect_no_offenses(<<~RUBY)
      def m
        [0, 1].reduce { |a, e| a + e }
        [0, 1].reduce{ |a, e| a + e }
        [0, 1].reduce(5) { |a, e| a + e }
        [0, 1].reduce(5){ |a, e| a + e }
        [0, 1].reduce (5) { |a, e| a + e }
        [0, 1].reduce(5) { |a, e| a + e }
        ala.test { |x, y| bala }
      end
    RUBY
  end

  it 'allows an unused parameter to have a leading underscore' do
    expect_no_offenses('File.foreach(filename).reduce(0) { |a, _e| a + 1 }')
  end

  it 'finds incorrectly named parameters with leading underscores' do
    expect_offense(<<~RUBY)
      File.foreach(filename).reduce(0) { |_x, _y| }
                                         ^^^^^^^^ Name `reduce` block params `|_a, _e|`.
    RUBY

    expect_correction(<<~RUBY)
      File.foreach(filename).reduce(0) { |_a, _e| }
    RUBY
  end

  it 'ignores do..end blocks' do
    expect_no_offenses(<<~RUBY)
      def m
        [0, 1].reduce do |c, d|
          c + d
        end
      end
    RUBY
  end

  it 'ignores :reduce symbols' do
    expect_no_offenses(<<~RUBY)
      def m
        call_method(:reduce) { |a, b| a + b}
      end
    RUBY
  end

  it 'does not report when destructuring is used' do
    expect_no_offenses(<<~RUBY)
      def m
        test.reduce { |a, (id, _)| a + id}
      end
    RUBY
  end

  it 'does not report if no block arguments are present' do
    expect_no_offenses(<<~RUBY)
      def m
        test.reduce { true }
      end
    RUBY
  end
end
